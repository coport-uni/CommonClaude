# CommonClaude.md

This file contains the project-wide conventions that **all Claude Code sessions** must follow when working in this repository.

## Environment

This project runs inside a **Docker container** with [Claude Code](https://claude.ai/code) as the primary development tool.

| Item              | Detail                                         |
|-------------------|-------------------------------------------------|
| Runtime           | Docker container (`--privileged`)               |
| OS                | Ubuntu 24.04 (Noble)                            |
| Dev tool          | Claude Code (CLI / VS Code extension)           |


## 1. MIT Code Convention

All code follows the [MIT CommLab Coding and Comment Style](https://mitcommlab.mit.edu/broad/commkit/coding-and-comment-style/).

### Naming

- **Variables and classes** are nouns; **functions and methods** are verbs.
- Names must be pronounceable and straightforward.
- Name length is proportional to scope: short for local, descriptive for broad.
- Avoid abbreviations unless self-explanatory. If unavoidable, define them in a comment block.
- Python conventions:

| Element    | Style        | Example               |
|------------|--------------|-----------------------|
| Variable   | `lower_case` | `joint_angle`         |
| Function   | `lower_case` | `send_action`         |
| Class      | `CamelCase`  | `FairinoFollower`     |
| Constant   | `lower_case` | `_settle_mid_s`       |
| Module     | `lowercase`  | `fairino_follower`    |

### Structure

- **80-column limit** for all new code.
- One statement per line.
- Indent with **4 spaces** (never tabs).
- Place operators on the **left side** of continuation lines so the reader can see at a glance that a line continues.
- Group related items visually with alignment.

### Spacing

- One space after commas, none before: `foo(a, b, c)`.
- One space on each side of `=`, `==`, `<`, `>`, etc.
- Be consistent with arithmetic operators within a file.

### Comments

- Use **complete sentences**.
- Only comment for **context** or **non-obvious choices**. Never restate what the code already says.
- Outdated comments are worse than none. Keep them current or delete them.
- TODO format:
  ```python
  # TODO: (@owner) Implement 2-step predictor-corrector
  # for stability. Adams-Bashforth causes shocks.
  ```

### Language

- All code comments, docstrings, commit messages, and documentation files (including README) must be written in **English**.

### Documentation

- All public functions and classes must have **docstrings** (PEP 257 / Google style).
- A docstring states **what** and **why**, not **how**.
- Include `Args:`, `Returns:`, and `Raises:` sections when applicable.

---

## 2. Debug File Management

All debug, exploratory, and throwaway test scripts must be saved in `claude_test/`, **not** in `tests/`.

### Rules

| Location        | What goes there                                      |
|-----------------|------------------------------------------------------|
| `tests/`        | Production-quality tests that are part of CI/CD.     |
| `claude_test/`  | Debug scripts, one-off experiments, diagnostic code. |

### When writing debug code

1. Create the file directly in `claude_test/` (e.g., `claude_test/debug_servo_timing.py`).
2. Add a one-line docstring at the top explaining the purpose.
3. If the debug script leads to a real fix, move the relevant parts into a proper test under `tests/` and delete or archive the debug version.

### README

`claude_test/README.md` is the index. When adding a new debug file, add a row to the table in that README describing what the file does and what was learned.

---

## 3. Task Management

### Rules

1. **ToDo.md 작성**: 사용자가 요구하는 모든 작업에 대해 `ToDo.md` 파일을 작성하고, 작업을 시작하기 전에 사용자와 내용을 확인한다.
2. **GitHub 이슈 등록**: 가능한 경우 `gh` CLI를 활용하여 Todo 목록과 내용을 GitHub 이슈로 등록한다.

### 명령 입력 형태 확인

작업 요청을 받으면 ToDo.md 작성 **전에** 다음 두 가지를 반드시 확인한다.

1. **명시적인 명령인가?**: 요청이 모호하거나 해석의 여지가 있으면 작업을 시작하지 않고 사용자에게 구체적인 내용을 되묻는다.
   - 무엇을 변경하는가? (대상)
   - 어떻게 변경하는가? (방법)
   - 왜 변경하는가? (목적)
2. **참고 자료가 있는가?**: 관련 PDF, 웹사이트, 문서 등 참고할 자료가 있는지 확인한다. 자료가 있으면 해당 내용을 먼저 검토한 뒤 작업에 반영한다.

> 두 항목이 확인되지 않으면 작업을 진행하지 않는다.

### Workflow

1. 사용자의 작업 요청을 받으면 **명령 입력 형태를 확인**한다.
2. 확인이 완료되면 `ToDo.md`에 할 일 목록을 정리한다.
3. 사용자에게 `ToDo.md` 내용을 확인받는다.
4. 확인이 완료되면 `gh issue create` 명령으로 GitHub 이슈를 생성한다.
5. 작업 진행 중 완료된 항목은 `ToDo.md`에서 체크 표시한다.
6. 완료된 항목을 `gh issue edit` 명령으로 GitHub 이슈에도 업데이트한다.

---

## 4. Testing Rules

테스트는 코드의 **정확성과 품질**을 검증하기 위한 것이다. 테스트를 통과시키기 위해 코드 품질을 희생해서는 안 된다.

### Rules

1. **매직넘버 금지**: 테스트를 통과시키기 위해 의미 없는 특정 숫자나 값을 직접 사용하지 않는다. 모든 값은 명확한 의미를 가지는 상수나 변수로 정의한다.
   ```python
   # Bad: 매직넘버로 테스트 통과
   def calculate_area(radius):
       return 3.14 * radius * radius  # 왜 3.14인가?

   # Good: 의미 있는 상수 사용
   import math

   def calculate_area(radius):
       return math.pi * radius * radius
   ```

2. **하드코딩 금지**: 테스트 케이스의 예상 결과에 맞추어 코드를 하드코딩하지 않는다. 코드는 올바른 로직으로 동작해야 하며, 특정 입력에만 맞춘 분기나 고정값을 사용하지 않는다.
   ```python
   # Bad: 테스트 입력에 맞춘 하드코딩
   def convert_temperature(celsius):
       if celsius == 100:
           return 212
       if celsius == 0:
           return 32
       return celsius * 1.8 + 32

   # Good: 올바른 로직 구현
   def convert_temperature(celsius):
       return celsius * 1.8 + 32
   ```

3. **코드 품질 우선**: 테스트 통과 여부보다 코드의 가독성, 유지보수성, 정확성을 우선시한다. 테스트가 실패하면 테스트를 속이는 것이 아니라 로직을 올바르게 수정한다.
