---
name: add-initiative
description: Add a new Linear Initiative for work spanning multiple projects, e.g. "add an initiative spanning shruti and naadshala for the audio pipeline redesign", "create an initiative across all projects for the Q3 release". Works from any project's own working directory, not just from the journal vault.
---

# Add Initiative

Creates a Linear **Initiative** and attaches it to the projects the work spans. Uses the
Linear MCP tools (`mcp__plugin_linear_linear__*` or `mcp__claude_ai_Linear__*`, whichever
is connected).

## Linear structure

All tracking lives under the single **Prasanna Joshi** Linear team (free tier only allows
one team). Each of these is a Linear **Project** in that team: `iswarmandal`,
`swarmandal`, `shruti`, `naadshala`, `geetkosh`.

- **Initiative** = groups multiple **Projects** together (workspace-level, not
  team-scoped). This is what this skill creates.
- **Project** = codebase.
- **Milestone** = epic, scoped to one project.
- **Issue** = task.

**Important constraint**: Linear initiatives attach to Projects only — there's no way to
attach an initiative directly to specific Milestones across projects. If the request
calls out particular milestones (e.g. "the swarmandal pluck sound epic and the shruti
tuning epic"), still attach the initiative at the project level, and record the specific
milestones it concerns in the initiative's description — don't silently drop that detail.

## Steps

1. Identify the initiative's name/goal and which project(s) it spans from the request.
   - If project(s) are named explicitly in the request, use those.
   - Otherwise, infer a candidate from the current git repo: run
     `git rev-parse --show-toplevel` and take the basename of that path, matched
     (case-insensitive) against the 5 project names above. Since initiatives span
     multiple projects, treat this only as a starting point — confirm with the user
     which other project(s) it should also span rather than assuming it's just the one.
   - If it's unclear which of the 5 projects apply, ask rather than guessing.
   - If only one project ends up named (whether from the request or git-root
     inference), confirm with the user that an initiative is actually wanted (vs. just
     a milestone in that one project — see the `add-milestone` skill) before creating
     one, since initiatives are for cross-project work.
2. Check `list_initiatives` for a name collision (case-insensitive). If one already
   exists, tell the user and stop rather than creating a duplicate.
3. Create the initiative (`save_initiative`, `name: <name>`, and `description` covering
   the goal — include any specific milestones named in the request, per the constraint
   above).
4. For each spanned project, attach the initiative via `save_project`,
   `addInitiatives: [<initiative name>]`. `save_project`'s `id` field only accepts an
   actual project ID (UUID), not the project name — look the ID up first with
   `list_projects` (`query: <project name>`) or `get_project`, then pass that as `id`.
5. Confirm what was created: the initiative name/URL, the projects attached, and any
   milestones noted in its description.

## Notes

- Don't create a new Linear project or milestone from this skill — only initiatives, and
  only linking to the 5 existing projects.
