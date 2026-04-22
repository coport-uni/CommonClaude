# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a conventions repository that defines project-wide standards for Claude Code sessions. The primary artifact is `CommonClaude.md`.

## Environment

This project runs inside a **Docker container** with [Claude Code](https://claude.ai/code) as the primary development tool.

| Item              | Detail                                         |
|-------------------|-------------------------------------------------|
| Runtime           | Docker container (`--privileged`)               |
| OS                | Ubuntu 24.04 (Noble)                            |
| Dev tool          | Claude Code (CLI / VS Code extension)           |

## 1. Rule Priority

Project-level `CLAUDE.md` files take precedence over this global ruleset. Specific rules beat general ones. When a conflict arises, the more-specific context wins.

---

## 2. MIT Code Convention

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

- All code comments, docstrings, commit messages, documentation files (including README), **GitHub issues, and pull requests** must be written in **English**.

### Documentation

- All public functions and classes must have **docstrings** (PEP 257 / Google style).
- A docstring states **what** and **why**, not **how**.
- Include `Args:`, `Returns:`, and `Raises:` sections when applicable.

---

## 3. Debug File Management

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

## 4. Task Management

> **MANDATORY**: This workflow applies to **every task without exception**, regardless of size or complexity. No task may begin without writing `ToDo.md` and creating a GitHub issue via `gh`. Skipping any step is not allowed.

### Rules

1. **Write ToDo.md**: For every task requested by the user, create a `ToDo.md` file and confirm the contents with the user before starting work.
2. **Accumulate ToDo.md**: Do not overwrite previous entries in `ToDo.md`. Always **append** new tasks below existing ones so that the file serves as a cumulative command history for Claude's actions.
3. **Register GitHub issues**: When possible, use the `gh` CLI to register the Todo list and details as a GitHub issue.

### Command Input Validation

Before writing ToDo.md, the following two checks must be performed:

1. **Is the command explicit?**: If the request is ambiguous or open to interpretation, do not start work. Instead, ask the user for specifics:
   - What is being changed? (target)
   - How is it being changed? (method)
   - Why is it being changed? (purpose)
2. **Are there reference materials?**: Check whether related PDFs, websites, or documents exist. If so, review them before incorporating into the work.

> Do not proceed if either check is not satisfied.

### Workflow

1. Receive the user's task request and **validate the command input**.
2. Once validated, organize the task list in `ToDo.md`.
3. Get the user's confirmation on the `ToDo.md` contents.
4. Once confirmed, create a GitHub issue via `gh issue create`.
5. Check off completed items in `ToDo.md` as work progresses.
6. Update the GitHub issue via `gh issue edit` for completed items.
7. **Commit and push** changes after every user command is completed.

> **Reminder**: Steps 2 (`ToDo.md`) and 4 (`gh issue create`) are **non-negotiable**. Every task must have a corresponding `ToDo.md` entry and a GitHub issue before any work begins.

---

## 5. Testing Rules

Tests exist to verify the **correctness and quality** of code. Code quality must never be sacrificed just to pass tests.

### Rules

1. **No magic numbers**: Do not use arbitrary numbers or values directly to pass tests. All values must be defined as meaningful constants or variables.
   ```python
   # Bad: passing tests with magic numbers
   def calculate_area(radius):
       return 3.14 * radius * radius  # Why 3.14?

   # Good: use meaningful constants
   import math

   def calculate_area(radius):
       return math.pi * radius * radius
   ```

2. **No hardcoding**: Do not hardcode values to match expected test results. Code must work through correct logic, not through branches or fixed values tailored to specific inputs.
   ```python
   # Bad: hardcoded to match test inputs
   def convert_temperature(celsius):
       if celsius == 100:
           return 212
       if celsius == 0:
           return 32
       return celsius * 1.8 + 32

   # Good: correct logic implementation
   def convert_temperature(celsius):
       return celsius * 1.8 + 32
   ```

3. **Code quality first**: Prioritize readability, maintainability, and correctness over whether tests pass. If a test fails, fix the logic correctly rather than tricking the test.

---

## 6. Linting

All Python code must pass **Ruff** checks before committing.

### Rules

1. **Line length**: 80 columns (`line-length = 80` in `ruff.toml`).
2. **Run on every commit**: Before committing, run:
   ```bash
   ruff check <file>.py
   ruff format --check <file>.py
   ```
3. **Fix before committing**: If either command reports errors, fix them before proceeding. Use `ruff format <file>.py` to auto-format.

---

## 7. Research Before Coding

Before calling into an unfamiliar library, API, or CLI, verify its actual interface rather than guessing from memory.

### Rules

1. **Consult official documentation first** via Context7 MCP or web search.
2. **Search the repository** for prior implementations before writing new code against the same interface.
3. **Trust documentation over intuition**: when the docs disagree with the mental model, update the mental model.

---

## 8. Exceptions

The rules above are written for production code and CI tests. The following contexts receive formal waivers.

### `claude_test/` scripts

Scripts inside `claude_test/` are exempt from:

- The 80-column line limit (§2 Structure).
- Mandatory docstrings on public functions and classes (§2 Documentation).

Rationale: `claude_test/` is a scratch area for one-off diagnostics where strict readability conventions slow exploration. Anything later promoted into `tests/` must conform fully.

### One-off exploratory analysis

Exploratory or analysis scripts (typically under `claude_test/`) may use numeric literals directly, provided the file opens with a short intent comment explaining purpose and expected lifetime. This waiver does not apply to code under `tests/` or to production modules.

### `ToDo.md` checkbox updates

Marking completion checkboxes in `ToDo.md` (flipping `- [ ]` to `- [x]`, or appending a commit hash or issue link to a completed line) is permitted. The append-only rule in §4 Task Management Rule 2 and the "do not modify `ToDo.md`" constraint in §10 Learned Patterns Bootstrap forbid prose rewrites, reordering of entries, and deletion of historical items — not progress marking.

---

## 9. Learned Patterns Reference

When `LearnedPatterns.md` exists, treat it as part of the workflow. The file captures lessons from past work so they can be reused rather than rediscovered.

### Rules

1. **Before drafting `ToDo.md`**, read the sections of `LearnedPatterns.md` relevant to the new task. Relevance can be filtered by library, environment, or the general problem domain.
2. **Reference applicable patterns in the ToDo entry** using `(see LP §X)` where `X` is the section of `LearnedPatterns.md` being cited. Example:
   ```
   - [ ] Connect to device over serial (see LP §3)
   ```
3. **After the task completes**, if a new recurring issue, gotcha, library quirk, workflow lesson, or environment-specific note surfaced, append it to the correct section of `LearnedPatterns.md`. Use the Problem / Cause / Fix / Rule format specified in §10 Learned Patterns Bootstrap.
4. **Promote stable patterns**: entries in `LearnedPatterns.md` that stabilize across many tasks should be lifted into a formal rule inside this `CLAUDE.md`. Remove the promoted entry from `LearnedPatterns.md` to avoid duplication.

---

## 10. Learned Patterns Bootstrap

If `LearnedPatterns.md` does not exist in the repository root, generate it by analyzing the `Completed` items in `ToDo.md` using the procedure below. Once the file exists, this bootstrap procedure no longer applies — consult the file directly.

### Procedure

1. Read every `[x]` item across all sections in `ToDo.md`.
2. Classify each item into exactly one of the following categories:
   - **§1. Recurring Issues** — the same or a similar problem appeared **two or more times**.
   - **§2. Solved Gotchas** — a one-time trap with a credible chance of recurring.
   - **§3. Library Quirks** — hidden or surprising behavior of a specific library or tool.
   - **§4. Workflow Lessons** — lessons learned about the development or collaboration process itself.
   - **§5. Environment Specifics** — Docker, Ubuntu, or hardware-specific notes.
3. Items that do not cleanly fit any category go into **§99. Uncategorized**. Do **not** discard them.
4. For each entry, record four single-line fields:
   - **Problem**: what went wrong.
   - **Cause**: the underlying reason.
   - **Fix**: the specific change that resolved it.
   - **Rule**: a short general directive in `Always ...` or `Never ...` form.
5. Append `(from ToDo#N)` at the end of each entry, where `N` identifies the source ToDo item, so the original record can be recovered on later review.

### Constraints

- **Do not modify `ToDo.md`.** It is append-only; edits happen only in `LearnedPatterns.md`.
- **Create `LearnedPatterns.md` as a new file** in the repository root. Do not inline patterns into `ToDo.md` or `CLAUDE.md`.
- **Do not invent patterns.** When a ToDo item is ambiguous, place it under §99 rather than guessing.
- **Write all content in English**, consistent with §2 Language rule.
