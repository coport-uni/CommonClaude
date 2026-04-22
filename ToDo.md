# ToDo

## GitHub README.md 작성

### 배경
CommonClaude.md 내용을 설명하는 README.md를 작성한다.
IDECommand.png, ShortCut.png 내용을 포함한다.

### 할 일

- [x] CommonClaude.md에 영어 작성 규칙 추가
- [x] README.md 작성 (영어)
  - [x] CommonClaude.md 내용 요약 및 설명
  - [x] IDE 명령어 정보 (IDECommand.png 참고)
  - [x] 단축키 정보 (ShortCut.png 참고)
- [x] GitHub 이슈 등록
- [x] 커밋 및 푸시
- [x] GitHub 이슈 업데이트

---

## CLAUDE.md 규칙을 Claude Code Hooks로 구현

### 배경
CLAUDE.md에 정의된 코딩 규칙(린트, 디버그 파일 배치, 작업관리 등)을 Claude Code hooks로 자동 강제하여, "읽고 따르는" 수준에서 "시스템이 자동 검증하는" 수준으로 강화한다.

### 할 일

- [x] `ruff.toml` 생성 (line-length=80, indent-width=4)
- [x] `.claude/hooks/` 디렉토리 생성
- [x] `pre-write-guard.sh` 작성 — tests/에 디버그 파일 쓰기 차단 (§2)
- [x] `post-write-lint.sh` 작성 — Python 파일 ruff check + format 피드백 (§5)
- [x] `post-write-debug-remind.sh` 작성 — claude_test/ 파일 추가 시 README 리마인더 (§2)
- [x] `.claude/settings.json` 작성 — Hook 설정 + Stop prompt hook (§3 ToDo/이슈 확인)
- [x] GitHub 이슈 등록
- [x] 커밋 및 푸시
- [x] GitHub 이슈 업데이트

---

## README.md에 /output-style 명령어 및 Hook 설명 추가

### 배경
README.md의 IDE Commands 표에 `/output-style`이 누락되어 있고, 직전에 추가된 Claude Code hooks 자동 강제 메커니즘에 대한 설명이 README에 없어 사용자가 프로젝트의 규칙 강제 방식을 이해하기 어렵다.

### 할 일

- [x] IDE Commands 표에 `/output-style` 행 추가
- [x] `Automated Enforcement (Hooks)` 섹션 신규 추가 (Convention Summary와 IDE Commands 사이)
- [x] GitHub 이슈 등록
- [x] 커밋 및 푸시
- [x] GitHub 이슈 업데이트

---

## Concept.md 내용 정리

### 배경
사용자가 Concept.md에 CommonClaude 개선 아이디어(ECC에서 선별 흡수할
Rule 재구조화, Token 최적화, Search-first, Learned Patterns 마이그레이션
등)를 작성하였다. 이를 읽고 섹션별로 구조화하여 사용자가 전체 구상을
한눈에 파악할 수 있도록 정리한다.
실제 적용은 본 작업 범위에서 제외하며, 이후 별도 세션에서 새 ToDo로
착수한다.

### 할 일

- [x] Concept.md 전체 내용 읽기
- [x] 6개 섹션으로 구조화된 요약 제공
      (철학 진단 / Rule 관점 / Rule 외 / 제외 항목 /
      Continuous-Learning 마이그레이션 Phase 0–5 / 최종 적용 순서)
- [x] GitHub 이슈 등록 (#12)
- [x] 커밋 및 푸시
- [x] GitHub 이슈 업데이트
