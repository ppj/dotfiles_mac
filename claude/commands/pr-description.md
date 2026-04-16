# PR Description Command

Create or update PR description by analyzing commits in current branch.

## Phase 1: Gather Info & Determine Strategy

```bash
git branch --show-current  # Current branch

# Check for unpushed commits
git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "No upstream"
git log @{upstream}..HEAD --oneline 2>/dev/null  # List unpushed commits

# If unpushed commits exist, push first
# If no upstream, push with: git push -u origin <branch>

gh pr view --json number,title,body,baseRefName 2>/dev/null || echo "No PR"  # Check if PR exists
git log main..HEAD --format="%H %s"  # All commits (SHA + message)
git diff main...HEAD --stat  # Stats
git diff main...HEAD  # Full diff

# Check for PR template (search common locations)
for tmpl in .github/PULL_REQUEST_TEMPLATE.md .github/pull_request_template.md PULL_REQUEST_TEMPLATE.md pull_request_template.md; do
  [ -f "$tmpl" ] && echo "PR_TEMPLATE: $tmpl" && break
done
# Also check for template directory (multiple templates)
ls .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null
```

**If a PR template is found**, use it as the structure for the description instead of the default structure below. Fill in each section of the template based on the diff and commit analysis. Preserve the template's headings, checkboxes, and formatting. Still append the `<!-- pr-commits -->` tracking block at the end.

**Strategy:**
- **No PR:** Create new from overall diff (commits are implementation details)
- **PR exists:** Parse SHAs from `<!-- pr-commits ... -->` HTML comment in PR body:
  - SHAs changed (rebase/amend) → Regenerate from scratch
  - Only new commits → Update with new changes only (`git diff <last-SHA>..HEAD`)
  - No new commits → Exit (up to date)

## Phase 2: Analyze with Gemini

**For NEW PR (with template):**
If a PR template was found, use it as the structure:
```bash
gemini --prompt "Create PR description from git changes using the repo's PR template:
Branch: [NAME], Base: main
Files: [git diff --stat]
Diff: [git diff]
Commits: [git log] (reference only, focus on overall diff)
PR Template: [TEMPLATE CONTENTS]

Fill in each section of the template based on the changes. Preserve the template's headings, checkboxes, and formatting exactly. If a section is not applicable, write 'N/A' rather than removing it.
```

**For NEW PR (no template):**
If no template was found, use this default structure:
```bash
gemini --prompt "Create PR description from git changes:
Branch: [NAME], Base: main
Files: [git diff --stat]
Diff: [git diff]
Commits: [git log] (reference only, focus on overall diff)

Structure:
## Summary: 1-2 sentences
## Changes: 5-7 bullets (one line each, group by area)
## Technical Details: Only if noteworthy architectural decisions (otherwise OMIT)
## Testing: One line (e.g., 'Unit tests added', 'Tested on Pixel 6')
## Related Issues: 'Fixes #123' or 'None'
## Checklist: Code conventions, tests, docs, device testing

At the very end, emit ALL commits in a hidden HTML comment block (NOT a visible section):
<!-- pr-commits
<full-SHA>: <message>
<full-SHA>: <message>
-->

Be concise, scannable, focus on WHAT/WHY not HOW."
```

**For UPDATE (new commits):**
```bash
gemini --prompt "Update PR with new commits:
Existing: [PR BODY]
New commits: [LIST with SHA]
New diff: [git diff <last-SHA>..HEAD]

Keep Summary (update if fundamental change). APPEND to Changes (one-line bullets). Update Technical Details/Testing if needed. Keep Issues/Checklist. Mark new: '**Update:** <brief>'.

At the very end, replace the existing <!-- pr-commits --> block with an updated one containing ALL commits (old + new):
<!-- pr-commits
<full-SHA>: <message>
-->

Stay concise."
```

## Phase 3: Create/Update PR

```bash
# Create new:
gh pr create --title "[TITLE]" --body "$(cat <<'EOF'
[DESCRIPTION]
Generated with [Claude Code](https://claude.com/claude-code)
EOF
)" --base main

# Update existing:
gh pr edit [NUM] --body "$(cat <<'EOF'
[UPDATED DESCRIPTION]
Updated with [Claude Code](https://claude.com/claude-code)
EOF
)"

# Display:
gh pr view --web
```

**Error handling:**
- No commits → "Make commits first"
- On `main` → Ask which branch
- Not authenticated → `gh auth login`
- Unpushed commits → Push first with `git push -u origin <branch>`
- PR missing `<!-- pr-commits -->` block → Regenerate from scratch
- No new commits → Exit (no change needed)

**Notes:** Always include `<!-- pr-commits -->` HTML comment block (full SHA + message) for tracking rebases — invisible in rendered PR. Focus overall diff for new PRs. Detect rebases by SHA comparison. Keep descriptions scannable (short bullets, omit fluff).
