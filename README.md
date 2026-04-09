# CommonClaude

**Project-wide conventions for all Claude Code sessions**

This repository defines the rules and workflows that every [Claude Code](https://claude.ai/code) session must follow. The core document is [`CommonClaude.md`](CommonClaude.md).

---

## Environment

| Item       | Detail                                 |
|------------|----------------------------------------|
| Runtime    | Docker container (`--privileged`)      |
| OS         | Ubuntu 24.04 (Noble)                   |
| Dev tool   | Claude Code (CLI / VS Code extension)  |

---

## Convention Summary

### 1. MIT Code Convention

Follows the [MIT CommLab Coding and Comment Style](https://mitcommlab.mit.edu/broad/commkit/coding-and-comment-style/).

| Element  | Style        | Example            |
|----------|--------------|--------------------|
| Variable | `lower_case` | `joint_angle`      |
| Function | `lower_case` | `send_action`      |
| Class    | `CamelCase`  | `FairinoFollower`  |
| Constant | `lower_case` | `_settle_mid_s`    |
| Module   | `lowercase`  | `fairino_follower`  |

- 80-column limit, 4-space indentation
- Google-style docstrings required (`Args:`, `Returns:`, `Raises:`)
- All comments, docstrings, and documentation must be in **English**
- TODO format: `# TODO: (@owner) description`

### 2. Debug File Management

| Location        | Purpose                                     |
|-----------------|---------------------------------------------|
| `tests/`        | Production-quality tests for CI/CD          |
| `claude_test/`  | Debug scripts, one-off experiments          |

### 3. Task Management

Every task follows this workflow:

1. **Validate input** — Check if the command is explicit and if reference materials exist
2. **Write ToDo.md** — Organize the task list
3. **User confirmation** — Get approval on ToDo.md contents
4. **Create GitHub issue** — Register via `gh issue create`
5. **Execute** — Check off completed items in ToDo.md
6. **Update issue** — Sync progress via `gh issue edit`

### 4. Testing Rules

- **No magic numbers** — Use meaningful constants instead of unexplained values
- **No hardcoding** — Never write code that only passes specific test inputs
- **Code quality first** — Prioritize readability, maintainability, and correctness over passing tests

### 5. Using `ultrathink`

When in **plan mode** or tackling **complex tasks**, append `ultrathink` to the end of your command. This signals Claude to use extended reasoning for deeper analysis.

```
# Example
Review this entire codebase ultrathink
```

---

## Automated Enforcement (Hooks)

This repository uses [Claude Code hooks](https://code.claude.com/docs/en/hooks) to automatically enforce the conventions above. Hooks run on every tool call matching their event and either block the action or feed errors back to Claude for self-correction.

| Hook Script | Event | Rule Enforced | Behavior |
|---|---|---|---|
| [`pre-write-guard.sh`](.claude/hooks/pre-write-guard.sh) | PreToolUse (Write/Edit) | §2 Debug File Management | **Blocks** writing `debug_*`, `scratch_*`, `tmp_*`, `experiment_*` files into `tests/` |
| [`post-write-lint.sh`](.claude/hooks/post-write-lint.sh) | PostToolUse (Write/Edit) | §5 Linting | Runs `ruff check` + `ruff format --check` on every Python file write; **feeds errors back** to Claude |
| [`post-write-debug-remind.sh`](.claude/hooks/post-write-debug-remind.sh) | PostToolUse (Write/Edit) | §2 Debug File Management | Reminds to update `claude_test/README.md` when adding files to `claude_test/` |
| Stop prompt hook | Stop | §3 Task Management | Verifies that `ToDo.md` has an entry and a GitHub issue exists before Claude finishes |

Configuration lives in [`.claude/settings.json`](.claude/settings.json), and the linter is configured by [`ruff.toml`](ruff.toml) (80-column, 4-space, rules `E/F/W/I/N`).

**Not enforced via hooks** (kept in `CLAUDE.md` as instructions): comment quality, English-only rule, magic-number/hardcoding rules, and command input validation — these require human judgment.

---

## Claude Code IDE Commands

| Command            | Description                                         |
|--------------------|-----------------------------------------------------|
| `/clear`           | Clears Claude's memory context.                     |
| `/rewind`            | Re-executes the previous action.                  |
| `/memory`          | Adds specific content to memory.                    |
| `/permission`      | Configures permissions for Bash, Edit, Write, etc.  |
| `/review`          | Checks the current session's context cost.          |
| `/output-style`    | Switches the output style (Default, Explanatory, Learning) or applies a custom style. |

---

## Claude Code Shortcuts (VS Code)

| Shortcut                     | Description                                      |
|------------------------------|--------------------------------------------------|
| `Shift` + `Tab`              | Toggles approval mode.                           |
| `Ctrl` + `Shift` + `E`       | Opens the Explorer panel.                        |
| `Ctrl` + `Shift` + `X`       | Opens the Extensions panel.                      |
| `Alt` + `K`                  | Starts an inline editor reference.               |


---

## Cowork Session Rules (`CLAUDECowork.md`)

[`CLAUDECowork.md`](CLAUDECowork.md) defines rules specific to the Cowork workspace session.

### Expense Report Preparation

Rules for writing research expense reports under `서류 작업/`:
- Extract item names, quantities, amounts, and dates from transaction statements, quotes, and card receipts (PDF)
- Fields to update: date, amount (formatted as `"315,000 원"`), usage details (`"{item} 외 {count}건"`)
- Protected fields (names, budget codes, affiliations) must not be changed
- Verify against source PDFs after completion, then back up to the designated archive path

### ToDo Workflow

- Write a new entry in `ToDo.md` **before** starting any task (append only, never delete)
- Get user approval before executing
- Check off items as they are completed; keep all history intact

### Mail Reply Rules

- Use `DocumentMailReply.md` as the reply template
- Replace the `{friendly name}` placeholder with the sender's first name
- Always show the draft to the user and get approval **before** sending

---

## References

- Full rules: [`CommonClaude.md`](CommonClaude.md)
- Cowork rules: [`CLAUDECowork.md`](CLAUDECowork.md)
- Debug file index: [`claude_test/README.md`](claude_test/README.md)
- [ClaudeCode for vscode](https://code.claude.com/docs/en/vs-code#extension-settings)
- [클로드 코드를 활용한 바이브 코딩 완벽입문](https://product.kyobobook.co.kr/detail/S000219349783)
- [한 걸음 앞선 개발자가 지금 꼭 알아야할 클로드 코드](https://product.kyobobook.co.kr/detail/S000217402731)  
