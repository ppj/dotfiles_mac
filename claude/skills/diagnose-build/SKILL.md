---
name: diagnose-build
description: Diagnose a failing Buildkite build by fetching build details, reading error logs from failed jobs, and entering plan mode with a structured fix strategy. Use this skill whenever the user mentions a build number and wants to understand why it failed, or says things like "diagnose build", "what's wrong with build", "fix build", "build failed", "check build failures", "analyze build", "why is build failing", "build errors", "CI is red", or "check CI". Accepts an optional Buildkite build number — if omitted, automatically finds the latest build for the current git branch.
---

# Diagnose Build

Investigate a failing Buildkite build and produce a structured plan to fix the errors.

## Prerequisites

This skill requires the **Buildkite MCP server** to be configured in `~/.claude/settings.json`:

```json
"mcpServers": {
  "buildkite": {
    "type": "http",
    "url": "https://mcp.buildkite.com/mcp"
  }
}
```

This is already set up in the dotfiles `claude/settings.json`. If the tools are unavailable, verify the server is connected via `claude mcp list`.

## Arguments

**Optional:**
- `<build-number>`: The Buildkite build number (e.g., `1234`)

If no build number is provided, automatically find the latest build for the current git branch:

1. Get the current branch: `git branch --show-current`
2. Use `mcp__buildkite__list_builds` to find the latest build for that branch:

```
mcp__buildkite__list_builds(
  org_slug=<org>,
  pipeline_slug=<pipeline>,
  branch=<current-branch>,
  per_page=1
)
```

3. Use the build number from the first result. If no builds are found for the branch, tell the user: "No Buildkite builds found for branch `<branch>`. You can provide a build number directly: /diagnose-build <build-number>"

## Detecting the Pipeline

Before fetching anything, figure out which Buildkite org and pipeline this repo belongs to. Check for a `.buildkite/pipeline.yaml` or `.buildkite/pipeline.yml` in the repo root. Also check the README or any CI badge URLs for the org/pipeline slug.

The org slug is typically `culture-amp`. The pipeline slug usually matches the repo directory name. Confirm by looking at any Buildkite badge URLs in the README, e.g.:
```
https://buildkite.com/culture-amp/perform-core-insights
```

Store these for use in all subsequent MCP calls:
- `org_slug` (e.g., `culture-amp`)
- `pipeline_slug` (e.g., `perform-core-insights`)

## Workflow

### Phase 1: Fetch Build Overview

Use `mcp__buildkite__get_build` to get the build details:

```
mcp__buildkite__get_build(
  org_slug=<org>,
  pipeline_slug=<pipeline>,
  build_number=<number>,
  job_state="failed,broken,timed_out"
)
```

This returns all failed/broken jobs. Note down:
- The build branch and commit
- Each failed job's `id`, `name`, and `state`
- The overall build state

If no jobs are failed, also check for `canceled` or `waiting` states — the build may have been blocked or manually stopped.

If the build has no failures at all, tell the user: "Build #<number> has no failed jobs. All steps passed."

### Phase 2: Check Annotations

Buildkite annotations often contain pre-formatted error summaries. Fetch them in parallel with the logs:

```
mcp__buildkite__list_annotations(
  org_slug=<org>,
  pipeline_slug=<pipeline>,
  build_number=<number>
)
```

Annotations with `style: "error"` or `style: "warning"` are especially useful — they often contain test failure summaries, coverage reports, or security scan results that are more readable than raw logs.

### Phase 3: Read Error Logs

For each failed job, fetch the tail of the logs. Tail is best for failure diagnosis since errors appear at the end. Fetch logs for all failed jobs **in parallel** using multiple tool calls in a single message.

```
mcp__buildkite__tail_logs(
  org_slug=<org>,
  pipeline_slug=<pipeline>,
  build_number=<number>,
  job_id=<job_id>,
  tail=200
)
```

If the tail doesn't contain enough context (e.g., the error references a line much earlier), use `search_logs` to find the relevant section:

```
mcp__buildkite__search_logs(
  org_slug=<org>,
  pipeline_slug=<pipeline>,
  build_number=<number>,
  job_id=<job_id>,
  pattern="error|Error|FAILED|failed|exception|Exception",
  limit=30,
  context=5
)
```

### Phase 4: Analyze and Categorize Errors

Read through the logs and annotations and categorize each failure. Common categories for this project:

| Category | Signals | Examples |
|----------|---------|----------|
| **Test failures** | `rspec`, `FAILED`, `expected ... got`, `Failure/Error` | RSpec test failures, assertion errors |
| **Lint errors** | `standardrb`, `rubocop`, `Lint/`, `Style/` | Ruby style violations |
| **Type errors** | `TypeError`, `NoMethodError`, `NameError` | Ruby type/method errors |
| **Build failures** | `docker`, `build failed`, `exit status`, `Bundler` | Docker build failures, gem install issues |
| **Coverage failures** | `coverage`, `threshold`, `below minimum` | Test coverage below threshold |
| **Dependency issues** | `Bundler`, `could not find`, `version conflict` | Gem resolution failures |
| **Infrastructure/flaky** | `timeout`, `connection refused`, `503`, `ECR` | Transient infra issues |
| **CDK failures** | `cdk`, `CloudFormation`, `synthesis`, `tsc` | CDK build/lint/test failures |
| **Security audit** | `audit`, `vulnerability`, `CVE` | Dependency security issues |

For each failed job, extract:
1. The **error category** from the table above
2. The **specific error messages** (copy the key lines)
3. **Files and line numbers** mentioned in the errors
4. Whether it looks **fixable locally** vs. an infrastructure/flaky issue

### Phase 5: Search the Codebase

For errors that reference specific files, classes, or methods — search the local codebase to find the relevant code. This gives the plan concrete file paths to work with.

Use Grep and Glob to find:
- Files mentioned in stack traces or error messages
- Test files that failed
- Configuration files related to the failure (e.g., `.rubocop.yml` for lint errors, `Gemfile` for dependency issues)

Don't go overboard — focus on the files directly involved in the errors, not an exhaustive search.

### Phase 6: Enter Plan Mode

After gathering all the information, enter plan mode using the `EnterPlanMode` tool. Then present a structured plan with:

**Build Diagnosis Summary:**
- Build number, branch, commit
- Number of failed jobs out of total
- Quick one-line summary of what went wrong

**For each failed job, in priority order** (most impactful / blocking first):

1. **Job name and error category**
2. **What went wrong** — the specific errors, with key log lines quoted
3. **Root cause** — your best assessment of why this failed
4. **Files involved** — paths in the codebase that need changes
5. **Suggested fix** — concrete steps to resolve the issue

**Overall fix strategy:**
- Order of operations (what to fix first, what depends on what)
- Whether any failures look like flaky/infra issues that just need a retry
- Any risks or things to watch out for

The plan should be actionable — someone reading it should know exactly what files to edit and what changes to make. If you're unsure about a fix, say so and suggest investigation steps instead.
