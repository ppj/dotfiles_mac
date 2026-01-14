# Update Documentation Command

Update project documentation based on code changes in current branch (vs main).

## Phase 1: Get Changes

```bash
git branch --show-current
git diff main...HEAD --stat
git diff main...HEAD
```

If on `main` or no changes, exit.

## Phase 2: Analyze with Gemini

```bash
gemini --prompt "Analyze git diff and identify documentation updates needed:

Diff: [INSERT DIFF]
Files: [STAT]

Check common documentation files (README.md, CLAUDE.md, CONTRIBUTING.md, docs/, etc.) and identify:
1. User-facing: features, usage changes, setup/build changes
2. Developer-facing: architecture changes, new components, testing changes, build commands, dependencies
3. API docs: endpoint changes, parameter changes

For each: section to update, what changed, proposed new content (preserve style/tone).
Ignore trivial changes (typos, formatting). Focus on substantial changes only."
```

## Phase 3: Review & Apply

**Present findings:**
1. **README updates:** [sections and changes]
2. **Developer doc updates:** [sections and changes]
3. **Other docs:** [if applicable]

Ask: "Update: (1) All, (2) Specific docs, (3) Skip?"

**After confirmation:**
- Read each doc file
- Use Gemini to draft specific section updates (preserve existing style)
- Use Edit tool to apply updates
- Show diff of changes

## Error Handling

- No changes → "No code changes to document"
- No doc updates needed → "Documentation already up to date"
- On `main` → Ask which branch

**Notes:** Focus on substantial changes affecting docs. Use Gemini for analysis/drafting, Claude tools for file operations. Preserve existing style/structure. No rewrites unless necessary.
