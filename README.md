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

## Claude Code IDE Commands

| Command            | Description                                         |
|--------------------|-----------------------------------------------------|
| `/clear`           | Clears Claude's memory context.                     |
| `/rewind`            | Re-executes the previous action.                  |
| `/memory`          | Adds specific content to memory.                    |
| `/permission`      | Configures permissions for Bash, Edit, Write, etc.  |
| `/review`          | Checks the current session's context cost.          |

---

## Claude Code Shortcuts (VS Code)

| Shortcut                     | Description                                      |
|------------------------------|--------------------------------------------------|
| `Shift` + `Tab`              | Toggles approval mode.                           |
| `Ctrl` + `Shift` + `E`       | Opens the Explorer panel.                        |
| `Ctrl` + `Shift` + `X`       | Opens the Extensions panel.                      |
| `Ctrl/Cmd` + `K`             | Starts an inline editor reference.               |


---

## References

- Full rules: [`CommonClaude.md`](CommonClaude.md)
- Debug file index: [`claude_test/README.md`](claude_test/README.md)
- [ClaudeCode for vscode"](https://code.claude.com/docs/en/vs-code#extension-settings)
- [클로드 코드를 활용한 바이브 코딩 완벽입문](https://product.kyobobook.co.kr/detail/S000219349783)
- [한 걸음 앞선 개발자가 지금 꼭 알아야할 클로드 코드](https://product.kyobobook.co.kr/detail/S000217402731)  
