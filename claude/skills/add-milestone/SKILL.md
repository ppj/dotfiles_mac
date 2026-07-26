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
allows one team). Each tracked codebase is a Linear **Project** in that team — the
current list is whatever `list_projects` returns, not a fixed set, since new projects
get added over time via `add-project`.

- Project = codebase (one per project returned by `list_projects`).
- Milestone = epic.
- Issue = task (see the `add-issue` skill).

## Steps

1. Call `list_projects` (team: "Prasanna Joshi") to get the current project names.
2. Identify the project name.
   - If the user names a project explicitly in the request, use that.
   - Otherwise, infer it from the current git repo: run
     `git rev-parse --show-toplevel` and take the basename of that path. Match it
     (case-insensitive) against the names from `list_projects` and use it if it matches.
   - In either case it must match one of the projects from `list_projects` — if it
     doesn't (including when not run inside a git repo, or the repo's name doesn't
     match), ask the user to confirm or pick from the existing ones. Don't invent a new
     Linear project; use the `add-project` skill (in the journal vault) for that.
3. List existing milestones in that project (`list_milestones`, `project: <name>`) and
   check whether one with the same name (case-insensitive) already exists.
   - If it does, tell the user it already exists and stop — don't create a duplicate.
4. Create the milestone (`save_milestone`, `project: <name>`, `name: <milestone name>`,
   and `description` if the user gave one).
5. If the user gave initial tasks, create each as an issue (`save_issue`,
   `team: "Prasanna Joshi"`, `project: <name>`, `milestone: <milestone name>`,
   `title: <task>`).
6. Confirm what was created, including the Linear URL/identifier the tool call returns.

## Notes

- Never create a new Linear project from this skill — only add milestones to existing
  ones returned by `list_projects`.
