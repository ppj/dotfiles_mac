---
name: add-milestone
description: Add a new milestone (epic-equivalent) to a project in Linear. Use when the user asks to add/create a new epic or milestone for a project, e.g. "add a milestone to shruti called Auth Rework", "new epic for naadshala: onboarding flow". Works from any project's own working directory, not just from the journal vault.
---

# Add Milestone

Adds a new epic to a project by creating a Linear **Milestone** inside that project. Uses
the Linear MCP tools (`mcp__plugin_linear_linear__*` or `mcp__claude_ai_Linear__*`,
whichever is connected).

## Linear structure

All tracking lives under the single **Prasanna Joshi** Linear team (free tier only
allows one team). Each of these is a Linear **Project** in that team:
`iswarmandal`, `swarmandal`, `shruti`, `naadshala`, `geetkosh`.

- Project = codebase (already created, one per name above).
- Milestone = epic.
- Issue = task (see the `add-issue` skill).

## Steps

1. Identify the project name from the request. It must be one of the 5 above — if it
   doesn't match, ask the user to confirm or pick from the existing ones. Don't invent a
   new Linear project; use the `add-project` skill (in the journal vault) for that.
2. List existing milestones in that project (`list_milestones`, `project: <name>`) and
   check whether one with the same name (case-insensitive) already exists.
   - If it does, tell the user it already exists and stop — don't create a duplicate.
3. Create the milestone (`save_milestone`, `project: <name>`, `name: <milestone name>`,
   and `description` if the user gave one).
4. If the user gave initial tasks, create each as an issue (`save_issue`,
   `team: "Prasanna Joshi"`, `project: <name>`, `milestone: <milestone name>`,
   `title: <task>`).
5. Confirm what was created, including the Linear URL/identifier the tool call returns.

## Notes

- Never create a new Linear project from this skill — only add milestones to the 5
  existing ones.
