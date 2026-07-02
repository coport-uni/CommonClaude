#!/usr/bin/env bash
#
# ubuntu2404-setup.sh
# -------------------
# Ubuntu 24.04 (Noble) 신규 설치 후 초기 환경 자동 구성 스크립트
#
#   1) SSH 포트를 22 -> 6800 으로 변경 (ssh.socket / ssh.service 모두 대응)
#   2) Docker Engine 설치 (공식 apt 저장소, deb822 형식)
#   3) Visual Studio Code & Google Chrome 설치
#   4) Anaconda 설치 (최신 버전 자동 탐지, 사용자 계정에 설치)
#   5) 설치 결과 검증
#
# 사용법:
#   chmod +x ubuntu2404-setup.sh
#   sudo ./ubuntu2404-setup.sh
#
# 주의:
#   - 반드시 sudo 로 실행하세요.
#   - SSH 포트 변경 후, 로그아웃하기 전에 *새 터미널*에서
#     `ssh -p 6800 사용자@서버` 접속이 되는지 꼭 확인하세요.
#
set -euo pipefail

# ===================== 설정 (필요시 수정) =====================
SSH_PORT=6800                 # 변경할 SSH 포트
REMOVE_OLD_SSH_PORT=false     # true 로 하면 방화벽에서 기존 22번 포트 제거

# 단계별 on/off 스위치 (특정 단계를 건너뛰려면 false)
DO_SSH=true
DO_DOCKER=true
DO_APPS=true        # VSCode + Chrome
DO_ANACONDA=true
DO_VERIFY=true      # 마지막 검증 단계
# =============================================================

LOG_FILE="/var/log/ubuntu2404-setup.log"

# ----------------------- 공통 함수 ---------------------------
log()  { echo -e "\n\033[1;32m[+]\033[0m $*"; }
warn() { echo -e "\033[1;33m[!]\033[0m $*"; }
err()  { echo -e "\033[1;31m[x]\033[0m $*" >&2; }

# 검증 결과 누적용
PASS_LIST=()
FAIL_LIST=()
check_pass() { PASS_LIST+=("$1"); echo "  [OK]   $1"; }
check_fail() { FAIL_LIST+=("$1"); echo "  [FAIL] $1"; }

# 모든 출력 로그 파일에도 기록
exec > >(tee -a "$LOG_FILE") 2>&1

# root 권한 확인
if [[ $EUID -ne 0 ]]; then
  err "이 스크립트는 root 권한이 필요합니다. 'sudo $0' 로 실행하세요."
  exit 1
fi

# 실제 사용자(=sudo 호출자) 정보 — Anaconda 설치, docker 그룹 추가에 사용
TARGET_USER="${SUDO_USER:-root}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
[[ -z "$TARGET_HOME" ]] && TARGET_HOME="/root"

# 아키텍처 감지
DPKG_ARCH="$(dpkg --print-architecture)"   # amd64 / arm64 ...
case "$DPKG_ARCH" in
  amd64) ANACONDA_ARCH="x86_64" ;;
  arm64) ANACONDA_ARCH="aarch64" ;;
  *)     ANACONDA_ARCH="" ;;
esac

export DEBIAN_FRONTEND=noninteractive

log "Ubuntu 버전 확인"
. /etc/os-release
echo "    -> ${PRETTY_NAME} (${DPKG_ARCH})"
if [[ "${VERSION_ID:-}" != "24.04" ]]; then
  warn "이 스크립트는 Ubuntu 24.04 기준으로 작성되었습니다. 현재: ${VERSION_ID:-unknown}"
fi

log "apt 패키지 목록 갱신 및 기본 도구 설치"
apt-get update -y
apt-get install -y ca-certificates curl wget gnupg apt-transport-https

# ============================================================
# [1/5] SSH 설치 및 포트 변경 (22 -> ${SSH_PORT})
# ============================================================
if [[ "$DO_SSH" == true ]]; then
  log "[1/5] OpenSSH 서버 설치 및 포트 ${SSH_PORT} 설정"

  apt-get install -y openssh-server

  # drop-in 설정 파일로 포트 지정 (sshd_config 직접 수정보다 안전)
  mkdir -p /etc/ssh/sshd_config.d
  cat > /etc/ssh/sshd_config.d/10-custom-port.conf <<EOF
# ubuntu2404-setup.sh 에 의해 생성됨
Port ${SSH_PORT}
EOF

  # Ubuntu 24.04 는 기본적으로 socket 기반 활성화(ssh.socket)를 사용.
  # socket 이 22번을 계속 점유하므로, socket 의 ListenStream 도 함께 변경하거나
  # socket 을 끄고 ssh.service 를 직접 사용해야 함. 여기서는 후자를 택함.
  if systemctl is-enabled ssh.socket &>/dev/null; then
    echo "    -> ssh.socket 감지: socket 활성화를 끄고 ssh.service 직접 구동으로 전환"
    systemctl disable --now ssh.socket
  fi
  systemctl enable ssh.service
  systemctl restart ssh.service

  # 방화벽(ufw) 사용 중이면 새 포트 허용
  if command -v ufw &>/dev/null && ufw status | grep -q "Status: active"; then
    ufw allow "${SSH_PORT}/tcp"
    if [[ "$REMOVE_OLD_SSH_PORT" == true ]]; then
      ufw delete allow 22/tcp || true
      ufw delete allow OpenSSH || true
    fi
    echo "    -> ufw 에 ${SSH_PORT}/tcp 허용 추가"
  fi

  echo "    -> SSH 포트 변경 완료. 현재 세션을 닫기 전에 새 터미널에서 접속 테스트 필수!"
else
  log "[1/5] SSH 단계 건너뜀 (DO_SSH=false)"
fi

# ============================================================
# [2/5] Docker Engine 설치 (공식 apt 저장소)
#   참고: https://docs.docker.com/engine/install/ubuntu/
# ============================================================
if [[ "$DO_DOCKER" == true ]]; then
  log "[2/5] Docker Engine 설치"

  # 충돌 가능성이 있는 비공식 패키지 제거
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    apt-get remove -y "$pkg" 2>/dev/null || true
  done

  # Docker 공식 GPG 키 등록
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  # 공식 문서의 최신 방식인 deb822(.sources) 형식으로 저장소 등록
  cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: ${DPKG_ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io \
                     docker-buildx-plugin docker-compose-plugin

  systemctl enable --now docker.service containerd.service

  # sudo 없이 docker 사용을 위해 사용자를 docker 그룹에 추가
  if [[ "$TARGET_USER" != "root" ]]; then
    usermod -aG docker "$TARGET_USER"
    echo "    -> '${TARGET_USER}' 를 docker 그룹에 추가 (재로그인 후 적용)"
  fi
else
  log "[2/5] Docker 단계 건너뜀 (DO_DOCKER=false)"
fi

# ============================================================
# [3/5] Visual Studio Code & Google Chrome 설치
# ============================================================
if [[ "$DO_APPS" == true ]]; then
  log "[3/5] VSCode / Chrome 설치"

  # --- VSCode: Microsoft 공식 apt 저장소 ---
  if ! command -v code &>/dev/null; then
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
      | gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg
    chmod a+r /etc/apt/keyrings/packages.microsoft.gpg
    cat > /etc/apt/sources.list.d/vscode.sources <<EOF
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64 arm64 armhf
Signed-By: /etc/apt/keyrings/packages.microsoft.gpg
EOF
    apt-get update -y
    apt-get install -y code
    echo "    -> VSCode 설치 완료"
  else
    echo "    -> VSCode 가 이미 설치되어 있어 건너뜁니다."
  fi

  # --- Google Chrome: 공식 deb 패키지 (amd64 전용) ---
  if ! command -v google-chrome &>/dev/null; then
    if [[ "$DPKG_ARCH" == "amd64" ]]; then
      CHROME_DEB="/tmp/google-chrome-stable_current_amd64.deb"
      wget -q -O "$CHROME_DEB" \
        "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
      apt-get install -y "$CHROME_DEB"
      rm -f "$CHROME_DEB"
      echo "    -> Chrome 설치 완료"
    else
      warn "Google Chrome 은 amd64 만 공식 지원합니다. 현재: ${DPKG_ARCH}. 건너뜁니다."
    fi
  else
    echo "    -> Chrome 이 이미 설치되어 있어 건너뜁니다."
  fi
else
  log "[3/5] VSCode/Chrome 단계 건너뜀 (DO_APPS=false)"
fi

# ============================================================
# [4/5] Anaconda 설치 (최신 버전 자동 탐지)
# ============================================================
if [[ "$DO_ANACONDA" == true ]]; then
  log "[4/5] Anaconda 설치"

  if [[ -z "$ANACONDA_ARCH" ]]; then
    warn "지원하지 않는 아키텍처(${DPKG_ARCH})라 Anaconda 설치를 건너뜁니다."
  elif [[ "$TARGET_USER" == "root" ]]; then
    warn "일반 사용자(sudo 호출자)를 찾지 못해 Anaconda 설치를 건너뜁니다."
    warn "일반 사용자 계정에서 'sudo' 로 다시 실행하세요."
  else
    # Navigator 등 GUI 패키지 구동에 필요한 라이브러리
    apt-get install -y libgl1 libegl1 libxrandr2 libxss1 libxcursor1 \
                       libxcomposite1 libasound2t64 libxi6 libxtst6 || true

    log "최신 Anaconda 설치 파일 탐색 중..."
    INSTALLER_NAME="$(curl -fsSL https://repo.anaconda.com/archive/ \
      | grep -oE "Anaconda3-[0-9]{4}\.[0-9]{2}-[0-9]+-Linux-${ANACONDA_ARCH}\.sh" \
      | sort -V | tail -n 1)"

    if [[ -z "$INSTALLER_NAME" ]]; then
      err "Anaconda 설치 파일을 찾지 못했습니다. 네트워크를 확인하세요."
    else
      INSTALLER_URL="https://repo.anaconda.com/archive/${INSTALLER_NAME}"
      INSTALLER_PATH="/tmp/${INSTALLER_NAME}"
      ANACONDA_DIR="${TARGET_HOME}/anaconda3"
      echo "    -> 대상: ${INSTALLER_NAME}"

      if [[ -d "$ANACONDA_DIR" ]]; then
        warn "${ANACONDA_DIR} 가 이미 존재합니다. Anaconda 재설치를 건너뜁니다."
      else
        wget -q -O "$INSTALLER_PATH" "$INSTALLER_URL"
        # 사용자 권한으로 배치(batch) 모드 설치
        sudo -u "$TARGET_USER" bash "$INSTALLER_PATH" -b -p "$ANACONDA_DIR"
        # conda init (사용자 셸 설정에 conda 추가)
        sudo -u "$TARGET_USER" "$ANACONDA_DIR/bin/conda" init bash
        rm -f "$INSTALLER_PATH"
        echo "    -> Anaconda 설치 완료: ${ANACONDA_DIR}"
        echo "    -> 새 터미널을 열거나 'source ~/.bashrc' 실행 후 conda 사용 가능"
      fi
    fi
  fi
else
  log "[4/5] Anaconda 단계 건너뜀 (DO_ANACONDA=false)"
fi

# ============================================================
# [5/5] 설치 결과 검증
# ============================================================
if [[ "$DO_VERIFY" == true ]]; then
  log "[5/5] 설치 결과 검증"

  # --- SSH 검증 ---
  if [[ "$DO_SSH" == true ]]; then
    if systemctl is-active --quiet ssh.service; then
      check_pass "ssh.service 실행 중"
    else
      check_fail "ssh.service 가 실행되고 있지 않음"
    fi
    if ss -tlnp | grep -q ":${SSH_PORT} "; then
      check_pass "포트 ${SSH_PORT} 에서 리스닝 중"
    else
      check_fail "포트 ${SSH_PORT} 리스닝 확인 실패"
    fi
    if sshd -t 2>/dev/null; then
      check_pass "sshd 설정 파일 문법 검사 통과"
    else
      check_fail "sshd 설정 파일 문법 오류"
    fi
    # 실제 SSH 프로토콜 응답 확인: 포트에 접속해 배너 문자열 수신
    SSH_BANNER="$(timeout 5 bash -c "exec 3<>/dev/tcp/127.0.0.1/${SSH_PORT} && head -c 32 <&3" 2>/dev/null || true)"
    if [[ "$SSH_BANNER" == SSH-2.0-* ]]; then
      check_pass "포트 ${SSH_PORT} SSH 프로토콜 응답 확인: ${SSH_BANNER}"
    else
      check_fail "포트 ${SSH_PORT} 에서 SSH 배너 응답을 받지 못함"
    fi
  fi

  # --- Docker 검증 ---
  if [[ "$DO_DOCKER" == true ]]; then
    if command -v docker &>/dev/null; then
      check_pass "docker 명령 존재: $(docker --version)"
    else
      check_fail "docker 명령을 찾을 수 없음"
    fi
    if systemctl is-active --quiet docker.service; then
      check_pass "docker.service 실행 중"
    else
      check_fail "docker.service 가 실행되고 있지 않음"
    fi
    if docker run --rm hello-world &>/dev/null; then
      check_pass "hello-world 컨테이너 실행 성공"
    else
      check_fail "hello-world 컨테이너 실행 실패"
    fi
    if docker compose version &>/dev/null; then
      check_pass "docker compose 플러그인 동작: $(docker compose version --short)"
    else
      check_fail "docker compose 플러그인 확인 실패"
    fi
  fi

  # --- VSCode / Chrome 검증 ---
  if [[ "$DO_APPS" == true ]]; then
    if command -v code &>/dev/null; then
      check_pass "VSCode 설치됨: $(sudo -u "$TARGET_USER" code --version 2>/dev/null | head -n1 || echo 버전확인생략)"
    else
      check_fail "VSCode 설치 확인 실패"
    fi
    if command -v google-chrome &>/dev/null; then
      check_pass "Chrome 설치됨: $(google-chrome --version 2>/dev/null || echo 버전확인생략)"
    else
      if [[ "$DPKG_ARCH" == "amd64" ]]; then
        check_fail "Chrome 설치 확인 실패"
      else
        check_pass "Chrome: 비 amd64 환경이라 의도적으로 건너뜀"
      fi
    fi
  fi

  # --- Anaconda 검증 ---
  if [[ "$DO_ANACONDA" == true && "$TARGET_USER" != "root" && -n "$ANACONDA_ARCH" ]]; then
    if [[ -x "${TARGET_HOME}/anaconda3/bin/conda" ]]; then
      check_pass "conda 설치됨: $(sudo -u "$TARGET_USER" "${TARGET_HOME}/anaconda3/bin/conda" --version)"
    else
      check_fail "conda 실행 파일 확인 실패"
    fi
  fi
fi

# ============================================================
# 완료 요약
# ============================================================
log "모든 작업 완료!"
cat <<EOF

────────────────────────────────────────────────
 설치 요약
────────────────────────────────────────────────
 SSH 포트     : $([[ "$DO_SSH" == true ]] && echo "${SSH_PORT} 로 변경됨" || echo "건너뜀")
 Docker       : $([[ "$DO_DOCKER" == true ]] && echo "설치됨" || echo "건너뜀")
 VSCode/Chrome: $([[ "$DO_APPS" == true ]] && echo "설치됨" || echo "건너뜀")
 Anaconda     : $([[ "$DO_ANACONDA" == true ]] && echo "설치 시도됨" || echo "건너뜀")

 검증 통과    : ${#PASS_LIST[@]} 건
 검증 실패    : ${#FAIL_LIST[@]} 건
 로그 파일    : ${LOG_FILE}
────────────────────────────────────────────────
EOF

if (( ${#FAIL_LIST[@]} > 0 )); then
  warn "실패한 검증 항목:"
  for item in "${FAIL_LIST[@]}"; do echo "   - $item"; done
fi

cat <<EOF

 다음 사항을 확인하세요:
  1) [중요] 새 터미널에서 SSH 접속 테스트:
       ssh -p ${SSH_PORT} ${TARGET_USER}@<서버주소>
     접속이 확인되기 전에는 현재 세션을 닫지 마세요.
  2) docker 그룹 적용을 위해 재로그인(또는 'newgrp docker') 필요
  3) conda 명령 사용을 위해 'source ~/.bashrc' 또는 새 터미널 필요
────────────────────────────────────────────────
EOF
