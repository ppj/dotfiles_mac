---
name: add-task
description: Add a task under an existing epic for a project in Linear (task = Issue, epic = Milestone). Use when the user asks to add a task to a specific epic, e.g. "add a task to the Auth epic in shruti: fix login bug". Works from any project's own working directory, not just from the journal vault.
---

# Add Task

Adds a task under a specific epic by creating a Linear **Issue** attached to that
project's **Milestone**. Uses the Linear MCP tools (`mcp__plugin_linear_linear__*` or
`mcp__claude_ai_Linear__*`, whichever is connected).

## Linear structure

All tracking lives under the single **Prasanna Joshi** Linear team (free tier only
allows one team). Each of these is a Linear **Project** in that team:
`iswarmandal`, `swarmandal`, `shruti`, `naadshala`, `geetkosh`.

- Project = codebase.
- Milestone = epic.
- Issue = task (what this skill creates).

## Steps

1. Identify the project name — must be one of the 5 above.
2. List milestones in that project (`list_milestones`, `project: <name>`) and find the
   one matching the epic name given, case-insensitively; a partial match is fine if
   unambiguous.
   - If no epic matches, tell the user and ask whether to create it first (via the
     `add-epic` skill) rather than creating an untracked/epic-less issue.
   - If more than one could match, ask the user to disambiguate.
3. Create the issue (`save_issue`, `team: "Prasanna Joshi"`, `project: <name>`,
   `milestone: <matched epic name>`, `title: <task text>`).
4. Confirm what was created, including the issue identifier/URL the tool call returns.

## Notes

- This skill only attaches issues to an existing milestone; use `add-epic` to create a
  new one first.
