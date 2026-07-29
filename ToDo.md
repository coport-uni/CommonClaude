# ToDo

## feat/c-language-support branch creation — C language convention split

### Background
User request (2026-05-19): `main` focuses on Python; create a dedicated
C language branch `feat/c-language-support` cut from `main`. Replace
Python-specific content in `CLAUDE.md` with C equivalents grounded in
the MIT CommLab Coding and Comment Style guideline.
Reference: https://mitcommlab.mit.edu/broad/commkit/coding-and-comment-style/

### Decisions (2026-05-19)
- Branch base: `main` — `git checkout -b feat/c-language-support origin/main`
  (verified HEAD = origin/main HEAD = 43a9ae6)
- Convention depth: cite MIT guideline + minimal applied rules
  (concrete brace/indent style left for later)
- Linter / formatter: `clang-format` + `cppcheck`
- File handling: remove Python-only artifacts, add C-only artifacts,
  refresh shared metadata

### Change map (CLAUDE.md)

| Area                     | main (Python)                          | C branch                                                                |
|--------------------------|----------------------------------------|-------------------------------------------------------------------------|
| §2 Naming table          | Python `lower_case` / `CamelCase`      | C: `snake_case` (func/var), `UPPER_SNAKE` (macro/const), `PascalCase` or `_t` (type) |
| §2 TODO example          | `# TODO ...` (Python)                  | `/* TODO ... */` (C)                                                    |
| §2 Documentation         | PEP 257 / Google docstring             | Doxygen `/** @brief @param @return */`                                  |
| §3 Debug example         | `debug_servo_timing.py`                | `debug_servo_timing.c`                                                  |
| §5 Testing examples      | Python (`math.pi`, def)                | C (`M_PI`, `<math.h>`, function definition)                             |
| §6 Linting               | Ruff (`ruff check`, `ruff format`)     | `clang-format --dry-run --Werror` + `cppcheck`                          |
| §8 Exceptions docstring  | Python docstring waiver                | Doxygen block waiver                                                    |
| §11.4 Commit example     | "JSON config loader in Python"         | "JSON config loader in C"                                               |
| §13 .gitignore           | "Cover both C and Python"              | "Cover C only"; drop Python section + Python sources link               |
| §16 Git Automation       | ruff-pre-commit + mirrors-clang-format | mirrors-clang-format only (drop ruff block)                             |

### File handling

| File                     | Action                                                                |
|--------------------------|-----------------------------------------------------------------------|
| `CLAUDE.md`              | Update per change map above                                           |
| `ruff.toml`              | Delete                                                                |
| `.clang-format`          | Add (BasedOnStyle: LLVM, IndentWidth: 4, ColumnLimit: 80)             |
| `README.md`              | Update to C convention (drop Ruff/Python wording)                     |
| `ToDo.md`                | Restart on this branch (this entry only; main Python history stays on main) |
| `LearnedPatterns.md`     | Keep as-is (meta workflow patterns are language-neutral)              |
| `CLAUDECowork.md`        | Keep main content as-is                                               |

### Work items
- [x] User confirmation of this ToDo content (2026-05-19)
- [x] GitHub issue registered (#25)
- [x] `git checkout -b feat/c-language-support origin/main` (HEAD = 43a9ae6)
- [x] Verify branch reflects latest `origin/main` (HEAD/diff check)
- [x] Record this ToDo entry in `ToDo.md`
- [x] Edit `CLAUDE.md`: §2 Naming table, TODO example, Documentation
- [x] Edit `CLAUDE.md`: §3 debug example extension
- [x] Edit `CLAUDE.md`: §5 Testing examples (Python → C)
- [x] Edit `CLAUDE.md`: §6 Linting (Ruff → clang-format + cppcheck)
- [x] Edit `CLAUDE.md`: §8 Exceptions wording (docstring → Doxygen)
- [x] Edit `CLAUDE.md`: §11.4 commit example
- [x] Edit `CLAUDE.md`: §13 .gitignore template (drop Python section)
- [x] Edit `CLAUDE.md`: §16 pre-commit config (drop ruff block)
- [x] Delete `ruff.toml`
- [x] Add `.clang-format`
- [x] Update `README.md`
- [ ] Commit with Conventional Commits format
- [ ] Push branch to remote
- [ ] Open PR via `gh pr create`
- [ ] Update / close GitHub issue #25

### Follow-up (out of scope for this task)
- `.claude/hooks/post-write-lint.sh` still invokes `ruff` on Python files.
  Rewire it to call `clang-format --dry-run --Werror` and `cppcheck`
  on `*.c` / `*.h` writes. README §Automated Enforcement already reflects
  the target behavior; the script change is deferred to a separate task.

---

## 2026-07-29 — Verification Gate: no git operation before the work is verified

**Issue**: #29 · **Branch**: `docs/verification-gate`

The ruleset said how to move work through git, never when work has
earned the right to enter it. Requested by the operator after hardware
changes reached `main` without ever having run on the bench.

### Work items
- [x] Register GitHub issue (#29)
- [x] `git checkout -b docs/verification-gate origin/main`
- [x] Record this ToDo entry in `ToDo.md`
- [x] `CLAUDE.md` §5.1: new Verification Gate (mandatory; hardware needs
      a real run with the operator present; 7 rules)
- [x] `CLAUDE.md` §5.2: renumber the existing test-quality rules
- [x] `CLAUDE.md` §4 Workflow: verification is a step before the first
      commit; merge gated on a clean Testing section
- [x] `CLAUDE.md` §8: the gate is explicitly **not** waivable
- [x] `CLAUDE.md` §12.1 principles + §15.2 PR template
- [x] `README.md`: Verification Gate summary, sections renumbered
- [ ] Verify cross-references, commit, push, open PR
- [ ] Merge and close #29
