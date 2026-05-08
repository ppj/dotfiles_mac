# Cleanup Command

Analyze code cleanup for changes in current branch only (vs main).

## Phase 1: Get Changes & Analyze

```bash
git branch --show-current  # Check branch
git diff main...HEAD  # Get actual diff
```

If on `main` or no changes, ask user if they want full codebase analysis.

**Use Gemini CLI for analysis:**
```bash
gemini --prompt "Analyze this code diff for cleanup issues:

[INSERT GIT DIFF]

Identify in changed code only:
1. Unused: imports, variables, functions, dead code, commented-out code
2. Comment issues:
   - Redundant: restates what the code already says (e.g. '# increment counter' above 'counter += 1')
   - Stale-risk: describes implementation details likely to drift from code over time (e.g. listing specific steps, values, or field names)
   - Ticket references: JIRA/issue-tracker keys in code comments — these go stale quickly and belong in git history/PR descriptions, not code (flag unless the comment provides essential context that can't live elsewhere)
   - Verbose/narrating: describes WHAT the code does rather than WHY — candidates for better naming or extract method
   - Obvious annotations: comments that just restate type signatures or parameter names
3. Quality: magic numbers/strings, TODOs, non-idiomatic patterns

For each: file:line, severity (SAFE_TO_REMOVE/NEEDS_REVIEW/REFACTOR_SUGGESTION), brief explanation.
Keep comments explaining algorithms/business logic/non-obvious decisions."
```

## Phase 2: Lint & Report

Run project-specific lint commands if available (check for lint scripts in package.json, Makefile, or build files).

**Organize findings:**
1. **Unused Code (Safe to Remove):** List with file:line
2. **Comment Issues:**
   - Safe to remove: redundant, obvious, ticket references
   - Stale-risk: implementation-detail comments — suggest removing or rewriting to explain *why*
   - Refactor candidates: verbose/narrating comments indicating need for better naming or extraction
3. **Quality Issues:** Magic numbers, TODOs, commented code
4. **Lint Issues:** Summarize key findings
5. **Tool Recommendations:** Suggest linters if not configured

## Phase 3: Action Plan

"Found [X] issues. Fix: (1) All safe-to-remove, (2) Specific categories, (3) Review only?"

**After user confirms:**
- Use Edit tool (not Gemini) for changes
- Run project tests after changes

**Notes:** Focus on actual diff only (no scope creep). Gemini CLI for analysis, Claude tools for operations. Non-destructive by default.
