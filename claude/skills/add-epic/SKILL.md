---
name: add-epic
description: Add a new epic to a project's tracker note in the personal Obsidian journal vault at /Users/prasanna/journal. Use when the user asks to add/create a new epic for a project, e.g. "add an epic to shruti called Auth Rework", "new epic for naadshala: onboarding flow".
---

# Add Epic

Adds a new `### Epic:` section to a project's tracker note in the journal vault.

## Vault conventions

See `/Users/prasanna/journal/AGENTS.md` for the full conventions this skill follows
(epic status values, checklist-only tasks, lowercase project names).

## Steps

1. Identify the project name from the request. Project notes live at
   `/Users/prasanna/journal/Projects/<name>/<name>.md`, where `<name>` is lowercase and
   matches the project's codebase folder at `~/code/<name>` (currently: `iswarmandal`,
   `swarmandal`, `shruti`, `naadshala`, `geetkosh`).
   - If the given name doesn't match an existing project folder, ask the user to confirm
     or pick from the existing ones — don't guess a new project into existence.
2. Read the project note.
3. Append a new epic under the `## Epics` heading, after the last existing epic (or right
   after the heading if this is the first one):

   ```markdown
   ### Epic: <epic name> — Status: Not Started
   - [ ] <task>
   ```

   - If the user gave initial tasks, add each as a `- [ ]` checklist item under the epic.
   - If not, add a single placeholder `- [ ]` line for them to fill in later.
4. Save the file and tell the user what was added and where (project + epic name).

## Notes

- Never invent a project folder — this skill only adds epics to existing projects
  already tracked in the vault.
- Epic status is always one of: `Not Started`, `In Progress`, `Blocked`, `Done`.
