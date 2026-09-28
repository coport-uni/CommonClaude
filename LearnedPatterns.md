# LearnedPatterns.md

> Patterns extracted from `ToDo.md` Completed items. Consult the relevant sections before drafting new ToDo entries. Append new patterns after each task completes (see CLAUDE.md §9 Learned Patterns Reference).
>
> Last updated: 2026-09-28
> Total patterns: 16
>
> Provenance format: `(from ToDo#N)` where N is the 1-based index of the top-level `##` section in `ToDo.md` at the time of extraction.

---

## §1. Recurring Issues

### R1. Stop hook halts tasks missing ToDo entry or GitHub issue

- **Problem**: Session ended with the Stop hook blocking because the user request had been fulfilled but no `ToDo.md` entry or GitHub issue existed for it.
- **Cause**: The CommonClaude Stop hook enforces a ToDo entry and a GitHub issue for every user-requested task, including read-only or informational ones; the check runs regardless of surface task type.
- **Fix**: Register a ToDo entry and a GitHub issue before responding to informational asks, not only before "code" work.
- **Rule**: Always create a ToDo entry and a GitHub issue for every user request, even read-only summaries or document reviews. (from ToDo#4, ToDo#5)

---

## §2. Solved Gotchas

### G1. `Edit(replace_all=true)` flips sibling skeletons

- **Problem**: Marking one task's checkboxes with `replace_all=true` also flipped identical `- [ ] Commit and push` / `- [ ] GitHub issue update` lines in unrelated sibling tasks.
- **Cause**: Checkbox skeleton lines repeat verbatim across many task entries, so the global replacement matched every instance.
- **Fix**: Reverted the unintended sibling changes via narrow context-scoped edits and re-committed.
- **Rule**: Never use `replace_all=true` on short skeleton lines that repeat across sibling sections. Scope the match with unique surrounding context instead. (from ToDo#5)

### G2. Unrelated staged changes ride along on commits

- **Problem**: A commit scoped to `ToDo.md` also included hook scripts and `settings.json` wiring because the git index already held earlier user-side edits.
- **Cause**: `git add <path>` adds to the existing index rather than defining the final commit set; unrelated staged changes carry over.
- **Fix**: Documented the bundling on the relevant issue and continued; all included content was intentional at the repo level.
- **Rule**: Always run `git status` and `git diff --cached --stat` immediately before `git commit`. Treat unexpected files in the index as an alert. (from ToDo#5, ToDo#6)

### G3. IDE auto-trim creates phantom whitespace diffs

- **Problem**: Opening `Concept.md` in the IDE produced a 2-blank-line trim that would have polluted commits scoped to other files.
- **Cause**: The IDE trims trailing blank lines on save or open; the change appears in `git status` as `modified:` even though the assistant did not touch the file.
- **Fix**: Staged only the intentionally modified files and left `Concept.md` unstaged.
- **Rule**: When `git status` shows modifications to files you did not touch, stage explicit paths only; never use `git add -A` or `git add .`. (from ToDo#5)

### G4. `gh issue close` after `Closes #N` commit returns "already closed"

- **Problem**: A follow-up `gh issue close` call reported the issue was already closed because the preceding commit carried `Closes #N` in its message.
- **Cause**: GitHub auto-closes issues referenced with `Closes/Fixes/Resolves #N` when the commit lands on the default branch.
- **Fix**: Used `gh issue comment` to attach trailing notes instead of a redundant close call.
- **Rule**: Never chain `gh issue close` after a commit whose message already contains `Closes #N`; use `gh issue comment` for trailing notes. (from ToDo#5)

---

## §3. Library Quirks

### Q1. `jq` is required by hooks but not pre-installed

- **Problem**: Three existing hook scripts silently no-op'd because `jq` was missing from the container image.
- **Cause**: Base Ubuntu 24.04 ships without `jq`, and the hooks parse tool-input JSON through it.
- **Fix**: Installed `jq` via `apt install -y jq` as a side fix during Task 7.
- **Rule**: Always verify `jq` is present in hook scripts with `command -v jq` and surface a clear error when it is missing. (from ToDo#6)

### Q2. Secret-scan PreToolUse hook inspects the entire Bash command string

- **Problem**: Heredoc bodies passed to `gh issue create --body` or `git commit -m` can match credential-like patterns even when the literal strings are illustrative, tripping the secret-scan hook.
- **Cause**: The hook scans the full Bash `command` string before execution, including everything inside `<<'EOF' ... EOF` blocks.
- **Fix**: Describe credential patterns with wildcards or obfuscated variants (for example `sk-*`, `ghp_*`) in Bash payloads. Keep literal test strings confined to file content written via Write or Edit.
- **Rule**: Never embed literal credential prefixes in Bash command strings; such strings are safe only in files written via Write/Edit. (from ToDo#6)

---

## §4. Workflow Lessons

### W1. Informational tasks still require the full CommonClaude workflow

- **Lesson**: Read-and-summarize requests were initially treated as workflow-exempt and triggered a Stop hook block at the end of the session.
- **Rule**: Always write a ToDo entry and open a GitHub issue for every user request, including summaries, code reviews, and exploratory reads. (from ToDo#4)

### W2. Bundle low-risk independent tasks under one issue when pre-approved

- **Lesson**: Tasks 1, 2, 4 of the improvement plan landed as a single commit under issue #14 because the three edits were independent, low-risk, and approved together.
- **Rule**: Bundle only when tasks are (a) low-risk, (b) independent of each other, and (c) pre-approved together by the user. Otherwise keep one commit per task. (from ToDo#5)

### W3. User prefers diff-first approval for structural edits

- **Lesson**: The CLAUDE.md restructure was presented as a structured proposal and approved before any file edit ran.
- **Rule**: Always preview structural edits (renumbering, section reorganization, content migration) as text or a preview diff before executing. Apply only after explicit user approval. (from ToDo#8)

### W4. Stage explicit file paths; never `git add -A` or `git add .`

- **Lesson**: Broad staging risks pulling in IDE auto-trim whitespace changes, unrelated scratch files, or previously-staged artifacts.
- **Rule**: Always stage files by explicit path and verify the staged set with `git status` plus `git diff --cached --stat` before committing. (from ToDo#5)

### W5. Use `Closes #N` in commit messages to auto-close issues

- **Lesson**: `Closes #N` in the commit body closes the referenced issue when the commit lands on the default branch; explicit `gh issue close` afterwards is redundant and errors.
- **Rule**: Always write `Closes #N` (or `Refs #N` for partial work) in commit messages. Follow up with `gh issue comment` for trailing notes instead of `gh issue close`. (from ToDo#5)

---

## §5. Environment Specifics

### E1. Docker `--privileged` warrants strict Read guards on credentials

- **Note**: The container runs with `--privileged`, which raises the impact of any accidental read of `.env`, `.pem`, or `.key` files.
- **Rule**: Always gate reads of credential-bearing files behind a PreToolUse hook in any `--privileged` Docker environment. (from ToDo#6)

### E2. Ubuntu 24.04 base image lacks `jq`

- **Note**: Hook scripts that parse JSON input with `jq` fail silently because the binary is absent from the base image.
- **Rule**: Always verify `jq` availability in the hook prelude and install via `apt install -y jq` as a one-time setup step. (from ToDo#6)

### E3. `$CLAUDE_PROJECT_DIR` is the portable repo-root path in hooks

- **Note**: Hooks are invoked from arbitrary working directories, so absolute paths must be derived from `$CLAUDE_PROJECT_DIR`.
- **Rule**: Never hardcode a repo path in hook scripts; always reference `$CLAUDE_PROJECT_DIR`. (from ToDo#2)

### E4. Claude Code on Windows passes backslash paths to hooks

- **Problem**: `pre-write-guard.sh` and `post-write-debug-remind.sh` never fired on a Windows 11 host, so a debug script landed in `tests/`.
- **Cause**: Claude Code sends `tool_input.file_path` as `C:\...\tests\x.py`; the hooks test `*/tests/*` with forward-slash globs.
- **Fix**: Normalise `file_path="${file_path//\\//}"` right after the `jq` extraction in every hook that inspects a path.
- **Rule**: Always normalise path separators before matching paths in hooks, and verify hooks with the real tool on each host rather than with a hand-written payload only. (from ToDo#7)

---

## §99. Uncategorized

Items that recur across nearly every top-level ToDo task as procedural ritual rather than distinct patterns. Preserved here so the full `[x]` inventory from `ToDo.md` is accounted for, per CLAUDE.md §10 Bootstrap rule 3.

- Per-task workflow steps: `GitHub 이슈 등록`, `커밋 및 푸시`, `GitHub 이슈 업데이트`. These are workflow scaffolding captured in §4 Task Management of CLAUDE.md, not lessons.
- Content writes that are task-specific and yield no transferable rule: README sections (from ToDo#1, ToDo#3), individual CLAUDE.md section bodies added during the improvement track (from ToDo#5, ToDo#7, ToDo#8, ToDo#9).
- One-shot directory or config creations: `ruff.toml`, `.claude/hooks/` directory, `.claude/settings.json` base structure (from ToDo#2).
- Per-task approval checkpoints (`[APPROVAL]`) — subsumed into W3.
- Manual verification steps for hook behavior (from ToDo#6) — subsumed into Q2.
