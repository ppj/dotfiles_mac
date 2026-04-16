---
name: prepare-pr
description: Prepare a branch for PR submission by running cleanup, documentation updates, and PR description generation in sequence. Use this skill when the user wants to create a PR, open a PR, submit a PR, ship a branch, wrap up a branch, finish a branch, merge their work, or says things like "ready to merge", "let's ship this", "prepare this for review", or "I'm done with this feature". Even if the user just says "create a PR" without mentioning cleanup or docs, use this skill — it ensures the branch is properly prepared before the PR is created.
---

# Prepare PR

Orchestrate branch wrap-up by running three steps in sequence, pausing for user review between each. This skill delegates to existing slash commands rather than duplicating their logic.

## Prerequisites

Before starting, verify you're on a feature branch with commits ahead of main:

```bash
git branch --show-current
git log main..HEAD --oneline
```

If on `main` or no commits ahead, tell the user and stop.

## Step 1: Cleanup

Run the `/cleanup` command. This analyzes the branch diff for unused code, redundant comments, magic numbers, and other cleanup opportunities.

After cleanup completes, present the findings to the user. If there are issues to fix, apply them after user approval. If cleanup finds nothing, report "No cleanup issues found" and move on.

**Checkpoint:** Wait for the user to review and confirm before proceeding. Ask: "Cleanup done. Ready to move on to documentation updates?"

## Step 2: Update Documentation

Run the `/updatedocs` command. This analyzes code changes and identifies which documentation files need updating.

After analysis completes, present the documentation changes needed. If there are updates to make, apply them after user approval. If no docs need updating, report "Documentation is already up to date" and move on.

**Checkpoint:** Wait for the user to review and confirm before proceeding. Ask: "Documentation updates done. Ready to create the PR?"

## Step 3: PR Description

Run the `/pr-description` command. This generates or updates the PR description by analyzing commits and the overall diff. It tracks commits via hidden HTML comments for rebase detection on future runs.

This step handles both creating new PRs and updating existing ones.

After completion, share the PR URL with the user.

## Notes

- Each step always runs and reports its findings, even if there's nothing to do.
- The slash commands use Gemini CLI for analysis where available. If Gemini CLI is unavailable, complete the step using the current tool (Claude Code, OpenCode, etc.) directly instead — do not stop or wait for user confirmation about the fallback.
- If the user wants to skip a step, that's fine — just move to the next one.
