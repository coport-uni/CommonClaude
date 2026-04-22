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

---

## CommonClaude Improvement Track (from Concept.md)

### Background
Concept.md proposes seven incremental improvements adopted selectively
from ECC to strengthen CommonClaude while preserving its minimalist
philosophy. This entry decomposes that plan into seven independently
executable, independently rollbackable tasks. Each task gets its own
GitHub issue and its own commit. User approval is required at every
checkpoint marked **[APPROVAL]**. Phase 4 (continuous accumulation) is
a standing practice that begins once Tasks 1-7 land, and is therefore
not a discrete task here.

### Diagnosis Baseline (captured 2026-04-22)
- ToDo.md Completed: 4 top-level doc/setup tasks. Sample below the
  10-item threshold for pattern extraction; Task 5 will follow the
  "insufficient sample -> Phase 2 only" branch (Concept.md L99-101).
- CLAUDE.md: sections Overview, Environment, §1-§5 present. Missing:
  priority-override statement, Exceptions subsections, Research
  Before Coding section, Learned Patterns Reference section.
- Hooks present: pre-write-guard, post-write-lint,
  post-write-debug-remind, Stop prompt. Missing: Bash secret scan,
  Read env-file guard.
- MCP: no MCP config exists in repo. Task 3 is effectively null op
  unless the user decides to add filesystem MCP.

### Task 1. Restructure CLAUDE.md rule layer
Risk: low. Rollback: `git revert`.
Bundled with Tasks 2 and 4 under issue #14 per user decision.
- [x] Add priority-override statement near the top of CLAUDE.md
      ("Project-level CLAUDE.md rules override this global file")
- [x] Add Exceptions subsection under §2 Debug Files (waive 80-col
      and docstring requirements inside `claude_test/`)
- [x] Add Exceptions subsection under §4 Testing (allow magic
      numbers in one-off exploratory scripts when intent comment
      is present at file top)
- [x] **[APPROVAL]** Bundled approval granted 2026-04-22
- [x] GitHub issue register and cross-link (#14)
- [x] Commit and push (aa15cb9)
- [x] GitHub issue update (#14 closed)

### Task 2. Add token-optimization env vars
Risk: low. Rollback: `git revert`.
Bundled with Tasks 1 and 4 under issue #14 per user decision.
- [x] Add `env` block to `.claude/settings.json` with
      `MAX_THINKING_TOKENS=10000` and
      `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50`
- [x] Verify existing `hooks` block is untouched
- [x] **[APPROVAL]** Values confirmed as-is per user 2026-04-22
- [x] GitHub issue register (#14)
- [x] Commit and push (aa15cb9)
- [x] GitHub issue update (#14 closed)

### Task 3. MCP reconfiguration decision
Risk: low (decision only). Rollback: n/a (no repo change).
Resolved by user 2026-04-22: keep Context7 MCP as-is. No repo MCP
config is introduced. This task closes without file changes.
- [x] User decision: keep Context7 MCP, add nothing else
- [ ] GitHub issue register and close immediately as "no change"

### Task 4. Add Search-first section to CLAUDE.md
Risk: low. Rollback: `git revert`.
Bundled with Tasks 1 and 2 under issue #14 per user decision.
- [x] Draft a new §6 "Research Before Coding" covering doc lookup,
      prior-implementation search, and the rule against guessing
      APIs from memory
- [x] **[APPROVAL]** Bundled approval granted 2026-04-22
- [x] GitHub issue register (#14)
- [x] Commit and push (aa15cb9)
- [x] GitHub issue update (#14 closed)

### Task 5. Phase 0-1 diagnosis and (abridged) pattern extraction
Risk: low. Rollback: discard draft file.
Tracked under issue #16.
- [x] Document diagnosis outcome: sample < 10, Phase 1 extraction
      skipped per Concept.md L99-101 (recorded in #16 body)
- [x] Produce a short seed list of candidate patterns from the
      four Completed tasks plus current session — five
      workflow-level lessons L1-L5 (recorded in #16 body)
- [ ] **[APPROVAL]** Review seed list before Task 6 creates the
      actual `LearnedPatterns.md`

### Task 6. Create LearnedPatterns.md and wire it into CLAUDE.md
Risk: low. Rollback: delete file + `git revert` CLAUDE.md.
- [ ] Create `LearnedPatterns.md` seeded with Task 5 output and
      the section skeleton (§1-§5) from Concept.md L131-164
- [ ] Add §7 "Learned Patterns Reference" to CLAUDE.md instructing
      Claude to consult `LearnedPatterns.md` before drafting ToDo
- [ ] **[APPROVAL]** Show both artifacts
- [ ] GitHub issue register
- [ ] Commit and push
- [ ] GitHub issue update

### Task 7. Add secret-scan and env-file-guard hooks
Risk: medium (false positives can block legitimate work).
Rollback: disable in `settings.json` + `git revert` scripts.
- [x] Write `.claude/hooks/pre-bash-secret-scan.sh` blocking
      Bash commands that contain `sk-`, `ghp_`, `AKIA`, or
      obvious password literals (expanded to cover more vendor
      prefixes and `api_key=` / `access_token=` / etc.)
- [x] Write `.claude/hooks/pre-read-env-guard.sh` blocking
      reads of `.env`, `.pem`, `.key` (renamed from
      `pre-read-envfile-guard.sh` per user 2026-04-22)
- [x] ~~Add fixture scripts under `claude_test/`~~ dropped per
      user 2026-04-22; manual verification scenarios used instead
- [x] Wire both hooks into `.claude/settings.json` under
      `PreToolUse` with matchers `Bash` and `Read` respectively
- [x] **[APPROVAL]** Demonstrated block behaviour live in session
- [x] GitHub issue register (#15)
- [x] Commit and push (72fef2c — landed alongside Task 5 update)
- [x] GitHub issue update (#15 closed)

### Task Ordering and Independence
- Tasks 1, 2, 4 are independent and may be executed in any order.
- Task 3 is a decision gate and can run in parallel with others.
- Task 5 must precede Task 6.
- Task 7 is self-contained but its fixtures must land together
  with the hook scripts.

### Out of Scope
- Phase 4 ongoing accumulation: standing workflow, begins after
  Tasks 1-7 land.
- Phase 5 Stop-hook extension: deferred until pattern accumulation
  demonstrates a real need.

### Meta-task checklist (this drafting session)
- [x] GitHub umbrella issue registered (#13)
- [x] Commit and push draft (84d99f5)
- [x] User approved plan; Tasks 1+2+4 bundle executed in aa15cb9
- [x] Umbrella issue updated to reflect bundle closure

---

## Task 7 execution: secret-scan and env-file-guard hooks

### Background
Executing Task 7 from the umbrella plan (#13). Scope refinements
agreed with the user on 2026-04-22:
- Rename `pre-read-envfile-guard.sh` -> `pre-read-env-guard.sh`
  to match the user's preferred filename.
- Expand Bash scan to include `api_key=` literal in addition to
  `sk-`, `ghp_`, `AKIA`, `password=`.
- Drop `claude_test/` fixtures; use manual verification scenarios
  supplied by the assistant.

Verification strings such as `sk-test1234567890abcdef` are
illustrative test tokens, not real credentials.

### Work items
- [x] Write `.claude/hooks/pre-bash-secret-scan.sh`
- [x] Write `.claude/hooks/pre-read-env-guard.sh`
- [x] `chmod +x` both scripts
- [x] Register both hooks in `.claude/settings.json`
- [x] Manual verification: `sk-*`, `ghp_*`, `password=`, `api_key=`
      blocked via Bash; `.env` blocked via Read; benign `ls`
      command and `README.md` read pass through
- [x] GitHub issue register (#15)
- [x] Commit and push (72fef2c)
- [x] GitHub issue update and tick remaining Task 7 boxes

### Side fix
- [x] Install `jq` via apt; the existing three hooks also depend on
      it and were silently no-op'd before this fix.

### Scope notes
Bash pattern set finalized as: `sk-`, `ghp_`, `gho_`, `ghu_`, `ghs_`,
`github_pat_`, `AKIA*`, `AIza*`, `xox[baprs]-*`, `glpat-*`, plus
generic literal assignments `password=`, `api_key=`, `access_token=`,
`secret_key=`, `auth_token=`. Expanded beyond the original five per
user direction "암호 뿐만 아니라 API 키도 거부하도록".

---

## CLAUDE.md §7 — Learned Patterns Bootstrap rule

### Background
Splits Task 6 of the umbrella plan (#13) into Part A (rule) and
Part B (generate the file). User directed adding the bootstrap
procedure to `CLAUDE.md` now, so future sessions know how to
generate `LearnedPatterns.md` from `ToDo.md` when it is absent.
Tracked under issue #17.

### Rule outline
- Classify `[x]` items into §1-§5 plus §99 fallback.
- Each entry: Problem / Cause / Fix / Rule (one-liner each).
- Append `(from ToDo#N)` for traceability.
- `ToDo.md` stays append-only; `LearnedPatterns.md` is a new
  file in repo root; content in English; ambiguous items go
  to §99 rather than being guessed.

### Work items
- [x] Add §7 "Learned Patterns Bootstrap" to `CLAUDE.md`
- [x] GitHub issue register (#17)
- [x] Commit and push (4628a61)
- [x] GitHub issue update (#17 closed)

---

## CLAUDE.md restructure — Rule Priority, Exceptions, Learned Patterns Reference

### Background
User direction 2026-04-22: promote the existing `## Priority`
subsection and the two `### Exceptions` subsections to proper
numbered top-level sections, and add a new `Learned Patterns
Reference` section (distinct from the generation-rule §7
`Learned Patterns Bootstrap` that just landed). Tracked under
issue #18. No file change until the diff preview is approved.

### Work items
- [x] Draft proposed numbering map and new-section text
- [x] GitHub issue register (#18)
- [x] **[APPROVAL]** User approved 2026-04-22
- [x] Apply restructure (renumber §1-§7, add §1 Rule Priority,
      add §8 Exceptions, add §9 Learned Patterns Reference,
      move former §7 to §10 Learned Patterns Bootstrap)
- [x] Update internal cross-references (§1 Structure ->
      §2 Structure; §1 Documentation -> §2 Documentation;
      §1 Language rule -> §2 Language rule)
- [x] Commit and push (b2a39a1)
- [x] GitHub issue update (#18 closed)

---

## CLAUDE.md §8 — ToDo.md checkbox update exception

### Background
User direction 2026-04-22: the append-only rule in §4 Task
Management Rule 2 and the "do not modify ToDo.md" constraint in
§10 Learned Patterns Bootstrap were written to preserve history,
not to prohibit progress marking. Every task-completion step
flips a `[ ]` to `[x]`; this behavior needs an explicit carve-out
so future sessions do not misread the rule. Tracked under issue
#20.

### Work items
- [x] Add `ToDo.md checkbox updates` subsection under §8
- [x] GitHub issue register (#20)
- [ ] Commit and push
- [ ] GitHub issue update
