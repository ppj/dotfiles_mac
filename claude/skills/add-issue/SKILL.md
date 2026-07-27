---
name: add-issue
description: Add an issue (task) under an existing milestone (epic) for a project in Linear. Use when the user asks to add a task/issue to a specific epic/milestone, e.g. "add an issue to the Auth milestone in shruti: fix login bug". Works from any project's own working directory, not just from the journal vault.
---

# Add Issue

Adds a task by creating a Linear **Issue** attached to a project's **Milestone**. Uses
the Linear MCP tools (`mcp__plugin_linear_linear__*` or `mcp__claude_ai_Linear__*`,
whichever is connected).

## Linear structure

Tracking spans two Linear teams (free tier caps a workspace at 2): **Code** for coding
projects, **Other** for personal/non-code projects. Each tracked project is a Linear
**Project** under whichever team fits — the current list is whatever `list_projects`
returns (across both teams), not a fixed set, since new projects get added over time via
`add-project`.

- Project = one per project returned by `list_projects`, under either team.
- Milestone = epic.
- Issue = task (what this skill creates).

## Steps

1. Call `list_projects` (no `team` filter, so results include both teams) to get the
   current project names — each result's `teams` field gives its team.
2. Identify the project name.
   - If the user names a project explicitly in the request, use that.
   - Otherwise, infer it from the current git repo: run
     `git rev-parse --show-toplevel` and take the basename of that path. Match it
     (case-insensitive) against the names from `list_projects` and use it if it matches.
   - In either case it must match one of the projects from `list_projects` — if it
     doesn't (including when not run inside a git repo, or the repo's name doesn't
     match), ask the user to confirm or pick from the existing ones.
3. List milestones in that project (`list_milestones`, `project: <name>`) and find the
   one matching the milestone name given, case-insensitively; a partial match is fine if
   unambiguous.
   - If no milestone matches, tell the user and ask whether to create it first (via the
     `add-milestone` skill) rather than creating an untracked/milestone-less issue.
   - If more than one could match, ask the user to disambiguate.
4. Create the issue (`save_issue`, `team: <the project's team from step 1's `teams`
   field>`, `project: <name>`, `milestone: <matched milestone name>`,
   `title: <task text>`, `assignee: "me"` — assigns it to the logged-in user running
   this skill).
5. Confirm what was created, including the issue identifier/URL the tool call returns.

## Notes

- This skill only attaches issues to an existing milestone; use `add-milestone` to create
  a new one first.
