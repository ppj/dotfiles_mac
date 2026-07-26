---
name: add-task
description: Add a task (checklist item) under an existing epic in a project's tracker note in the personal Obsidian journal vault at /Users/prasanna/journal. Use when the user asks to add a task to a specific epic, e.g. "add a task to the Auth epic in shruti: fix login bug".
---

# Add Task

Adds a `- [ ]` checklist item under a specific epic's heading in a project's tracker note
in the journal vault.

## Vault conventions

See `/Users/prasanna/journal/AGENTS.md` for full conventions.

## Steps

1. Identify the project name (lowercase, matches `~/code/<name>` — currently:
   `iswarmandal`, `swarmandal`, `shruti`, `naadshala`, `geetkosh`) and read
   `/Users/prasanna/journal/Projects/<name>/<name>.md`.
2. Find the matching `### Epic: <name> — Status: ...` heading.
   - Match on the epic name given, case-insensitively; a partial match is fine if it's
     unambiguous.
   - If no epic matches, tell the user and ask whether to create it first (via the
     `add-epic` skill) rather than silently creating one.
   - If more than one epic could match, ask the user to disambiguate.
3. Insert `- [ ] <task text>` as the last checklist item under that epic (before the next
   `###` heading or end of file).
4. Save the file and confirm what was added, and to which project/epic.

## Notes

- Tasks are always plain two-state checkboxes (`- [ ]` / `- [x]`) — no other syntax.
- This skill only edits existing epics; use the `add-epic` skill to create a new one.
