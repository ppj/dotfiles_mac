# Update Plan

Revise your current task plan to incorporate the following execution discipline before making any commits:

## 1. Work on a branch
- If already on a non-default branch, continue on it.
- If on `main` (or the repo's default branch), create a feature branch before making changes:
  - Suggest 2-3 branch name options for the user to pick from.
  - If a Jira ticket key (e.g. TX-3456) is known from context, prefix each suggestion with `<ticket-key>/` (e.g. `TX-3456/add-usage-metrics`).
  - Let the user choose or provide their own name, then create and switch to the branch.

## 2. Keep commits small and logically contained
- Each commit should represent one logical unit of change (e.g. one function, one refactor, one fix).
- Do not bundle unrelated changes in a single commit.

## 3. Write clear commit messages
- Follow the conventional commits format (e.g. `feat:`, `fix:`, `chore:`) if the repository enforces it.
- Keep the message to a single line where possible.
- If a description is needed, make it succinct and explain the *why*, not the *what*.

## 4. Avoid unnecessary comments
- Code should be self-documenting through clear naming and structure.
- Only add a comment when the *why* is non-obvious: a hidden constraint, a subtle invariant, or a workaround for a specific external bug. If removing the comment wouldn't confuse a future reader, don't write it.

## 5. Before committing, verify tests pass
- Identify and run the tests relevant to the changes (unit, integration, etc.).
- Do not commit if any relevant tests are broken.

## 6. Prefer test-driven development where it makes sense
- If the change adds new behavior, a new code path, or fixes a bug, determine whether a test is worth writing — only if it provides long-term value (would catch a real regression, covers non-obvious logic, or protects a critical code path). Skip tests for trivial getters, simple config, a one-off regression the change fixes, or one-off scripts.
- When tests are worth writing, **pause and ask the user** before finalizing the plan. Use `AskUserQuestion` to confirm the testing approach. Tailor the questions to the change, but cover:
  - **Approach** — full TDD (write failing test first, then implement), test-alongside, or test-after? Recommend full TDD where the behavior can be expressed as a failing test up front.
  - **Behaviors to test** — which behaviors matter most? You can't test everything; confirm the priorities (critical paths, complex logic) rather than every edge case.
  - **Interface / seams** — what should the public interface look like, and is anything still in flux that would make test-first premature?
  - **Test level** — unit, integration, or end-to-end for this change?
- Once the user answers, **refine the plan** to reflect their choices: if TDD, restructure the relevant steps into red → green → refactor cycles, working in vertical slices (one test → one implementation → repeat) rather than writing all tests up front.
- Test behavior through public interfaces, not implementation details, so the tests survive refactors.
- TDD won't fit every change (e.g. exploratory spikes, hard-to-isolate UI tweaks, or where the interface is still in flux). When the user opts out or it clearly doesn't fit, fall back to writing the test alongside or after the change — but still write it before committing.

## 7. Before committing, check for formatter/linter violations
- Detect the project's formatter and linter setup (e.g. package.json scripts, Makefile targets, pre-commit config, .rubocop.yml, ruff.toml, etc.).
- Run the relevant formatter/linter and fix any violations before committing.

---

**Apply instructions 1–4 as general guidance for your plan. For instruction 6, ask the user the testing questions and refine the plan around their answers *before* you start writing code (test-first where they choose TDD). Verify instructions 5–7 before every commit in your plan, then continue execution.**
