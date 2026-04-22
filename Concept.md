CommonClaude 철학 파악
레포는 매우 미니멀합니다. 18개 커밋, 핵심 파일은 .claude/, CLAUDE.md, CLAUDECowork.md, README.md, ToDo.md, ruff.toml github이 전부예요. 이 구조에서 읽히는 철학은:

Python 전용, Docker/Ubuntu 환경 특화 — 범용성을 추구하지 않음
작업 흐름이 엄격함 — 입력 검증 → ToDo.md 작성 → 사용자 확인 → GitHub 이슈 생성 → 실행 → 이슈 업데이트 github라는 고정된 6단계 프로세스
Rule vs Hook 경계가 이미 명확 — 주석 품질, English-only 규칙, magic-number/hardcoding 규칙, command input validation — 이건 인간 판단이 필요해서 CLAUDE.md에 유지 github
학계/연구 환경 특화 — Cowork 규칙에 경비 리포트, 서류 작업, 메일 답장 등 학계 행정 작업 포함
한국 대학 연구실 맥락 — 레퍼런스 서적이 한국 책, coport-uni 네이밍

즉 ECC의 "모든 걸 다 하는 하네스"와 정반대입니다. 이런 미니멀·명시적 레포를 유지하려면 ECC에서 가져오는 건 선별적이어야 해요.
가져올 만한 것 (CommonClaude 철학과 호환)
Rule 적용 관점 — 최우선 고려사항
1. 계층적 Rule 구조 개념
지금은 CLAUDE.md 하나에 MIT 컨벤션, 디버그 파일 관리, 작업 관리, 테스팅, ultrathink가 다 들어가 있어요. 파일이 커지면 LLM이 중요한 부분을 놓칠 수 있습니다. ECC의 계층 분리 아이디어를 가져오되 디렉터리로 쪼개지 말고 단일 파일 내 명확한 섹션으로 유지하면 좋아요. 예를 들어:
CLAUDE.md
  ## §1. Common Principles (언어 무관)
  ## §2. Python Conventions (MIT 스타일, ruff)
  ## §3. Task Management Workflow
  ## §4. Project-Specific Overrides
ECC의 common/python/project 레이어 개념이지만 파일 구조가 아니라 문서 구조로. 현재 CommonClaude의 미니멀함을 깨지 않으면서 스케일링 가능해집니다.
2. 우선순위 오버라이드 원칙을 명시
CLAUDE.md 상단에 한 줄 추가하는 것만으로 큰 효과:

프로젝트 수준의 CLAUDE.md에 있는 규칙은 이 전역 규칙보다 우선한다. 구체적인 것이 일반적인 것을 이긴다.

CommonClaude는 여러 프로젝트에서 재사용하는 global conventions인데, 특정 프로젝트에서 예외가 필요할 때 LLM이 헷갈리지 않도록 명시해두는 거예요. ECC의 설계 원칙 중 하나입니다.
3. "예외 상황" 섹션 추가
현재 규칙들이 다소 절대적으로 서술되어 있어요. "No magic numbers", "No hardcoding" 같은 것들이 탐색적 코드, 일회성 분석, Jupyter 노트북에서는 오히려 방해가 될 수 있습니다. ECC의 rules에는 "허용되는 예외"가 종종 명시되어 있는데, 이걸 가져올 가치가 있어요:
markdown## Exceptions
- `claude_test/` 디렉터리 내 스크립트는 80-column 제한, docstring 요구사항 면제
- 일회성 데이터 탐색 스크립트는 magic number 허용 (단, 파일 상단에 의도 주석 필수)
Rule 외 가져올 만한 것
4. Token 최적화 settings
.claude/settings.json에 추가 (기존 훅 설정과 충돌 없음):
json{
  "env": {
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  }
}
CommonClaude 워크플로우가 ToDo 작성 + 이슈 생성 + 실행까지 여러 단계라 한 세션이 길어지는데, 이 설정으로 긴 세션에서의 품질 유지 + 비용 절감 효과가 커요.
5. Search-first 원칙 한 줄
CLAUDE.md에 한 섹션으로 추가:
markdown## §N. Research Before Coding
새로운 라이브러리나 API를 쓰기 전, 공식 문서와 기존 레포 내 유사 구현을 먼저 찾는다.
Context7 MCP 또는 web search 사용. 기억으로 API를 추측하지 않는다.
분석화학 실험실 맥락에서 의외로 큰 효과를 봅니다. pyserial, numpy 같은 라이브러리의 잘못된 API 추측으로 생기는 버그가 많아요.
6. 훅 아이디어 2개만 추가 고려
현재 4개 훅이 정확히 타겟팅되어 있어서 이걸 깨지 말고, 명백히 빠진 것만 보강:

Bash 실행 전 시크릿 스캔 — 커밋 명령에 API 키/토큰 패턴(sk-, ghp_, AKIA, 비밀번호 리터럴)이 들어가 있으면 차단. 실험 장비 제어 코드에 하드웨어 IP/인증 토큰이 들어가기 쉬워서 가치 있음
PreToolUse — 환경 변수 파일 보호 — .env, .pem, .key 파일 읽기를 기본 차단. Docker privileged 환경이라 특히 필요

이 두 개만 추가하면 CommonClaude의 미니멀함 유지하면서 보안 수준이 올라갑니다.
7. ToDo.md에 "학습된 패턴" 섹션 추가
CommonClaude는 이미 ToDo.md를 append-only로 관리해요. 여기에 한 섹션을 덧붙이는 방식으로 ECC의 continuous-learning 개념을 수동 버전으로 도입 가능:
markdown# ToDo.md

## Active Tasks
- [ ] ...

## Completed
- [x] ...

## Learned Patterns
- 2026-04-15: pyserial 연결 시 `timeout` 파라미터 없으면 무한 블록. 항상 명시.
- 2026-04-18: ruff가 `F401`로 잡는 import는 `# noqa: F401  # re-export` 주석으로 의도 표시.
훅 없이 수동 관리하는 거라 CommonClaude 철학에 잘 맞고, 나중에 자주 나오는 패턴은 CLAUDE.md의 Python Conventions로 승격시키면 됩니다. ECC의 /evolve 명령의 수동 버전이에요.
가져오지 말아야 할 것
항목이유183개 스킬 전체컨텍스트 오염, 미니멀 철학 파괴48개 에이전트현재 워크플로우(ToDo + 이슈) 간섭플러그인 설치 (/plugin install)기존 .claude/ 구조 덮어씀, hooks.json 중복 에러 위험continuous-learning v1 Stop hookCommonClaude는 이미 Stop hook을 ToDo/이슈 검증에 쓰고 있어 충돌다언어 rulesPython 전용이라 불필요/plan, /tdd 같은 슬래시 커맨드CommonClaude의 ToDo 기반 워크플로우를 우회해버림복잡한 훅 프로파일 (ECC_HOOK_PROFILE)4개 훅으로 충분, 복잡도만 증가MCP 서버 대량 설치200k 컨텍스트가 70k로 쪼그라듦
Stop hook 충돌 문제는 특히 조심
이게 가장 중요한 주의사항이에요. CommonClaude의 Stop hook은 Claude가 마치기 전에 ToDo.md에 엔트리가 있고 GitHub 이슈가 존재하는지 검증 github합니다. ECC의 Stop hook들은 세션 요약 저장, 패턴 추출 등 다른 일을 해요. 둘이 같은 이벤트에 걸리면 실행 순서가 꼬이거나 한쪽이 무시될 수 있습니다.
ECC의 Stop hook 관련 기능(continuous-learning, 세션 상태 저장 등)을 가져오고 싶다면 Stop 이벤트가 아닌 다른 이벤트로 리매핑하거나, CommonClaude의 기존 Stop hook 안에 로직을 통합해야 해요. 단순 복사는 안 됩니다.
정리된 추천 적용 순서

Rule 재구조화: CLAUDE.md를 섹션별로 재구성하고 "Exceptions", "우선순위 오버라이드" 원칙 추가 — 즉시 가능, 리스크 없음
Token 최적화: .claude/settings.json에 env 변수 추가 — 즉시 가능
Search-first 한 섹션 추가 — 즉시 가능
ToDo.md에 "Learned Patterns" 섹션 추가 — 즉시 가능
시크릿 스캔 훅 추가: .claude/hooks/pre-bash-secret-scan.sh 신규 작성, PreToolUse(Bash) 이벤트에 연결 — 기존 훅 구조 따라서 추가
환경 파일 보호 훅 추가 — 같은 방식

이 정도면 CommonClaude의 미니멀·엄격함을 유지하면서 ECC의 실용적 이점을 흡수할 수 있어요. 특히 1-4번은 파일 편집만으로 끝나서 오늘 바로 적용 가능합니다.
혹시 현재 CLAUDE.md 내용을 공유해주시면, 위 개선안을 실제 본인 파일에 맞춰 구체적으로 어디에 어떤 문구를 추가할지 예시로 작성해드릴 수 있어요.


2. 기존 ToDo.md 기반 Continuous-Learning 마이그레이션 계획
현재 ToDo.md에 쌓인 작업 이력이 있다면, 그걸 자산으로 전환하는 계획입니다. ECC의 continuous-learning-v2 철학을 CommonClaude의 수동 워크플로우로 옮기는 거예요.
Phase 0: 기존 ToDo.md 진단 (30분)
먼저 레포별로 ToDo.md 상태를 파악합니다. 체크리스트:

 Completed 섹션에 얼마나 많은 항목이 있는가? (10개 미만이면 패턴 추출 어려움, 30개 이상이면 충분한 샘플)
 항목마다 "어떻게 해결했는지"가 기록되어 있는가? 아니면 체크만 되어있나?
 GitHub 이슈 링크가 연결되어 있는가? (이슈 코멘트가 추가 정보원)
 반복적으로 겹치는 주제가 눈에 보이는가?

결과에 따른 분기:

샘플 충분 + 해결 방법 기록됨 → Phase 1-3 진행
샘플 부족 → Phase 2만 적용하고 새 세션에서 축적 시작
체크만 되어있고 해결 방법 없음 → GitHub 이슈 코멘트에서 복원 시도, 아니면 Phase 2로

Phase 1: 패턴 추출 세션 (1-2시간, Claude와 함께)
기존 Completed 항목을 Claude에게 주고 패턴을 분류합니다. 이때 사용할 수 있는 프롬프트 템플릿:
ultrathink

@ToDo.md를 읽고, Completed 섹션의 모든 항목을 다음 카테고리로 분류해줘:

1. **Recurring Issues** — 2회 이상 같은/유사한 문제가 나타난 경우
2. **Solved Gotchas** — 한 번 해결했지만 미래에 또 나올 가능성이 높은 함정
3. **Library Quirks** — 특정 라이브러리의 숨겨진 동작
4. **Workflow Lessons** — 작업 프로세스 자체에서 얻은 교훈
5. **Environment Specifics** — Docker/Ubuntu/하드웨어 환경 관련 이슈

각 항목은 다음 형식으로 정리:
- 문제 (한 줄)
- 원인 (한 줄)
- 해결 (한 줄)
- 재발 방지 규칙 (한 줄, "항상 ~한다" 형식)

출력은 `LearnedPatterns.md` 파일로 저장.
ultrathink를 붙이는 건 CommonClaude의 기존 컨벤션을 따르기 위함이에요. 이 작업은 패턴 추출이라 복잡한 추론이 필요합니다.
Phase 2: LearnedPatterns.md 파일 구조 정착
추출된 내용을 새 파일로 저장합니다. ToDo.md에 섞지 않는 이유:

역할 분리: ToDo.md는 "무엇을 할지", LearnedPatterns.md는 "어떻게 해야 하는지"
ToDo.md의 append-only 규칙을 깨지 않음: 과거 항목 이동/편집 없이 별도 파일로
세션 시작 시 선택적 로드: 필요할 때만 참조

추천 파일 구조:
markdown# LearnedPatterns.md

> Patterns extracted from past work. Referenced when starting new tasks.
> Last updated: 2026-04-22
> Total patterns: N

## §1. Recurring Issues
### pyserial connection timeout
- **Problem**: pyserial 연결 시 응답이 오지 않고 블록되는 경우 발생
- **Cause**: `timeout` 파라미터 기본값이 `None`이라 무한 대기
- **Fix**: `Serial(port, baudrate, timeout=1.0)` 명시
- **Rule**: pyserial 연결 시 `timeout`을 항상 명시한다

### (다른 항목들...)

## §2. Solved Gotchas
### ruff F401 re-export
- **Problem**: `__init__.py`에서 의도적 re-export가 F401로 잡힘
- **Fix**: `# noqa: F401  # re-export` 주석
- **Rule**: 의도적 unused import는 noqa + 이유 주석으로 표시

## §3. Library Quirks
...

## §4. Workflow Lessons
### GitHub issue 작성 시점
- **Lesson**: ToDo.md 작성 전에 이슈를 만들면 나중에 번호 맞추기 번거로움
- **Rule**: ToDo.md 초안 → 사용자 승인 → 이슈 생성 순서 고수

## §5. Environment Specifics
### Docker privileged + serial port
- **Problem**: Docker 컨테이너에서 `/dev/ttyUSB0` 접근 안 됨
- **Fix**: `--privileged` 또는 `--device=/dev/ttyUSB0` 지정
- **Rule**: 새 Docker 세션 시작 시 시리얼 장치 매핑 먼저 확인
Phase 3: CLAUDE.md에 연결 지시 추가
CLAUDE.md에 한 섹션을 추가해서 새 작업 시작 시 이 파일을 참조하도록 만듭니다:
markdown## §N. Learned Patterns Reference

매 작업 시작 시 다음을 수행한다:

1. ToDo.md 작성 **전에** `LearnedPatterns.md`를 읽고 현재 작업과 관련된 패턴이 있는지 확인
2. 관련 패턴이 있다면 ToDo.md 항목에 `(see LP §X)` 식으로 참조 추가
3. 작업 중 새로운 반복 패턴/gotcha를 발견하면 작업 완료 후 `LearnedPatterns.md`에 추가 (Phase 4 참고)
Phase 4: 지속 축적 워크플로우
매 작업 완료 시 (Stop hook에서 검증 가능):

ToDo.md 항목 체크 완료
해당 작업에서 예상 밖의 문제가 있었는가? 있었다면 LearnedPatterns.md에 추가
GitHub 이슈 코멘트에 해결 과정 기록
3개월에 한 번 LearnedPatterns.md를 재검토하여:

승격: 여러 번 참조된 패턴은 CLAUDE.md의 본 규칙으로 이동
삭제: 환경 변경으로 더 이상 유효하지 않은 항목 제거



이 승격 단계가 ECC의 /evolve 명령에 해당하는 수동 버전이에요. 자주 활용되는 패턴은 "임시 학습"에서 "공식 규칙"으로 올라가는 구조입니다.
Phase 5 (선택): Stop hook 확장
현재 CommonClaude의 Stop hook은 ToDo/이슈 존재만 검증하는데, 여기에 한 단계 추가하면 continuous-learning이 자동화돼요:
bash# pseudo-code for extended stop hook
1. ToDo.md 엔트리 존재 검증 (기존)
2. GitHub 이슈 존재 검증 (기존)
3. NEW: 이번 세션에서 새 에러/예외를 발견했는지 로그 스캔
   → 발견했으면 Claude에게 "LearnedPatterns.md 업데이트 제안"을 마지막 응답에 포함시키도록 요청
다만 이건 구현 복잡도가 있어서 Phase 4까지만 먼저 굳히고 나중에 고려하시는 게 좋아요. 수동으로 몇 번 해보면서 실제로 반복되는 패턴이 무엇인지 감을 잡은 후 자동화 지점을 정하는 게 맞습니다.
업데이트된 전체 적용 순서
앞서 제안한 순서를 수정된 요구사항 반영해서 다시 정리하면:

Rule 재구조화 (CLAUDE.md 섹션 분리, Exceptions, 우선순위 명시) — 즉시
Token 최적화 환경변수 (MAX_THINKING_TOKENS, 필요 시 CLAUDE_AUTOCOMPACT_PCT_OVERRIDE) — 즉시
MCP 재구성 (Context7 제거 판단 + filesystem 추가) — 10분
Search-first 원칙 섹션 추가 — 즉시
Phase 0-1: 기존 ToDo.md 진단 + 패턴 추출 세션 — 1-2시간, 한 번 집중
Phase 2-3: LearnedPatterns.md 생성 + CLAUDE.md 연결 — 30분
시크릿 스캔 훅, 환경 파일 보호 훅 추가 — 30분
Phase 4: 지속 운영 시작 — 일상 워크플로우로 녹임

5-6번이 가장 가치가 큽니다. 기존 ToDo.md에 쌓인 내용이 많다면 특히 그래요. 과거 작업의 교훈이 그냥 묻혀있는 상태인데, 이걸 한 번에 자산으로 전환하는 작업이에요.

