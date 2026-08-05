# PR Description Command

Create or update PR description by analyzing commits in current branch.

## Options

Arguments passed to the command: `$ARGUMENTS`

- `--no-checklist` — omit the `## Checklist` section. The checklist is included by default; this
  opts out of it. Also honour the intent stated in plain words ("skip the checklist", "no checklist").
  Applies to the default structure only — a repo PR template's own checklist is always preserved.

## Rule Zero: Only What Is Absolutely Necessary

This overrides every other instruction here. The reader is a busy human skimming before a
context switch — often on a phone. They want to know **what changed and why** in one glance,
then go read the diff. The description is a signpost, not a report.

**The test for every word:** is this *absolutely necessary* for the reviewer to know before they
open the diff? If not, it goes. Be ruthless — the default answer is no. There is no word or bullet
quota to hit; the description is exactly as long as the necessary content, and not one line longer.

| Section | Shape |
|---|---|
| Summary | what changed, and why. One sentence, or a few bullets if it covers several things. |
| Changes | short fragments, one per distinct change, grouped by area. No sub-bullets. |
| Checklist | on by default, one line per item, no commentary |
| Everything else | omit unless it says something the diff can't |

**Prefer lists to prose — including in the Summary.** A skimming reader finds a bullet instantly and
loses a paragraph. Default to a list; write a paragraph only where the content genuinely needs
connected reasoning.
- Bullets for anything enumerable — changes, affected areas, follow-ups, references.
- A numbered list when order matters: migration steps, a deploy sequence, reproduction steps.
- One idea per bullet. If a bullet needs a "because" clause it's usually two bullets, or it belongs
  in the one place a paragraph is warranted: explaining a genuine tradeoff.
- The Summary is a list too whenever it covers more than one thing. A single sentence is right for a
  single-purpose PR; two or three bullets beat one sentence strung together with "and" and "also".
- Never a wall of text: if a passage runs past a few lines, it's either a list in disguise or
  padding — split it or cut it.

**Cut on sight:**
- File-by-file narration of the diff (`Added handleFoo to foo.ts`) — the diff already shows this.
- Filler openers: "This PR", "In order to", "As part of this work", "It's worth noting".
- Any fact already stated in another section.
- Test prose about how tests were run or how many passed. One line on what's covered, or nothing.
- Sections padded with boilerplate or "N/A" — except the `## Checklist` and any section a repo
  template demands, which stay.
- Hedging and self-congratulation ("comprehensive refactor", "robust solution", "cleanly handles").

**Style:** plain language, active voice, present tense, no jargon the team wouldn't say out loud.
A short description that lands beats a long one that's merely complete. If the change is one line,
the description is one line.

**How to cut:** drop whole points, never shave words off the ones you keep. Every sentence that
survives should read as if written that way from the start — complete and natural, no dropped
articles or clipped clauses. Ruthless means fewer things said, each said properly. A genuinely
complex PR that needs a real explanation gets one; ruthlessness applies to what you include, never
to how readably you write it.

## Rule One: Link Every Reference

A reviewer should never have to go searching for context the description already alludes to. Every
external thing it mentions becomes a link.

This serves Rule Zero rather than competing with it: one link carries a paragraph of context at the
cost of a few words. A necessary fact delivered as a link always beats the same fact explained.

**Link these whenever they exist:**
- The ticket driving the work — Jira, Linear, GitHub issue.
- Design docs, RFCs, ADRs, Confluence pages, Google Docs, Notion pages.
- Figma designs the UI implements, and Miro boards holding the diagram or plan.
- Slack threads where the decision was made or the bug was reported.
- Dashboards, error reports, failing builds (Datadog, Buildkite, Sentry).
- Related PRs — upstream, downstream, the one this reverts, the one this follows.
- Release notes or changelog entries for dependency bumps, and upstream docs for a new API.
- Prior art: the commit or PR that introduced the code being changed.

**This session is usually the richest source — mine it first.** By the time a PR is ready, the
conversation that produced the work has normally accumulated exactly these references, and they are
already verified: they arrived from a real tool result or from the user, so nothing was constructed.
Look back through the session for:
- The ticket that started the work — a key the user typed, or one fetched via `/jira-task-workflow`,
  `acli`, the Atlassian/Linear tools, or one of the `add-issue` / `add-milestone` skills.
- URLs the user pasted while explaining the task, reviewing, or giving feedback.
- URLs returned by tool calls: Confluence pages read, Jira issues fetched, Miro boards, Figma files
  and node links, Slack permalinks, Buildkite builds, Datadog dashboards, GitHub PRs and issues.
- A plan, handoff, or PRD written earlier in the session, and whatever it cited.

Two conditions on session-sourced links: the reference must actually relate to *this* change — a
session often carries links from unrelated detours — and it must be something the reviewer is meant
to see. Copy such URLs verbatim; do not reconstruct one from memory of having seen it.

**Formatting:**
- Same-repo issues and PRs: bare `#123` — GitHub auto-links it. Cross-repo: `org/repo#456`.
- Everything else: `[TCP-1234](https://…/browse/TCP-1234)`. Never a naked URL sitting in prose, and
  never `click here` — the link text is the natural noun in the sentence.
- Commits and files: permalink pinned to a SHA, not a branch, so it still points at the right lines
  after the branch moves on.
- Figma: the node/frame URL for the screen implemented, not the whole file, when the session has it.
- Miro/Confluence: link the specific board or page, and name it — `[the migration plan](…)` beats
  `[Confluence](…)`, which tells the reviewer nothing about where they're being sent.
- `Fixes #123` / `Closes #123` only when merging genuinely closes it; otherwise `Related to #123`.

**Never invent a URL.** Link only what you can verify — a URL that appeared in the branch name,
a commit message, the existing PR body, the repo itself, or this conversation, or one built from a
base URL confirmed by precedent in Phase 1. If you have an identifier but no confirmed base URL,
write the bare identifier unlinked and say nothing more. A wrong link sends the reviewer somewhere
false and costs more trust than a missing one; guessing at a plausible-looking URL is never
acceptable.

When something obviously wants a link but you couldn't resolve one — a ticket key in the branch name
with no base URL anywhere in the repo's history — post the description with it unlinked, then say so
when reporting back, so the user can paste the URL in.

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

# Reference discovery (Rule One) — ticket keys and URLs already recorded in the branch
git log main..HEAD --format="%s%n%b"  # commit bodies/trailers: ticket keys, URLs, 'Refs:' lines
# Branch name often carries the ticket key, e.g. feat/TCP-1234-token-refresh

# Confirm the org's link conventions from precedent — the ONLY sanctioned way to learn a base URL
gh pr list --state merged --limit 20 --json body --jq '.[].body' 2>/dev/null \
  | grep -oE 'https?://[^ )>"]+' | sort -u
grep -rIohE 'https?://[^ )>"]+' --include='*.md' . 2>/dev/null | sort -u | head -30

# Check for PR template (search common locations)
for tmpl in .github/PULL_REQUEST_TEMPLATE.md .github/pull_request_template.md PULL_REQUEST_TEMPLATE.md pull_request_template.md; do
  [ -f "$tmpl" ] && echo "PR_TEMPLATE: $tmpl" && break
done
# Also check for template directory (multiple templates)
ls .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null
```

**If a PR template is found**, use it as the structure for the description instead of the default structure below. Preserve the template's headings, checkboxes, and formatting; fill each section from the diff and commits. Rule Zero still applies to the prose you write — keep the template's scaffolding intact, but write only what's absolutely necessary into it. Still append the `<!-- pr-commits -->` tracking block at the end.

**Gather the references** before drafting, building one list of verified URLs from three sources:

1. **This session** — start here, it usually has the most and the best (see Rule One). Scan back
   through the conversation for the ticket that kicked the work off, URLs the user pasted, and URLs
   returned by tool calls: Jira/Linear issues, Confluence pages, Miro boards, Figma files and nodes,
   Slack permalinks, GitHub PRs and issues, Buildkite builds, Datadog dashboards. Copy each verbatim
   from where it appears; keep only the ones about *this* change.
2. **The branch** — ticket key in the branch name, URLs and `Refs:` trailers in commit bodies, links
   already present in the existing PR body.
3. **Repo precedent** — base URLs confirmed by the greps above, used only to resolve an identifier
   found in 1 or 2.

Anything you cannot resolve to a verified URL stays an unlinked identifier — see Rule One. If the
session is thin (a fresh session picking up someone else's branch, or one compacted past the point
where the links were mentioned), say so when reporting back rather than filling the gap by guessing.

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
Verified references: [the Phase 1 list — ticket, design docs, Figma, Miro, Confluence, Slack threads, related PRs; give each as 'what it is: URL']
PR Template: [TEMPLATE CONTENTS]

Fill in each section of the template based on the changes. Preserve the template's headings, checkboxes, and formatting exactly. If a section is not applicable, write 'N/A' rather than removing it.

Use the verified references above as markdown links wherever the description mentions the thing they point to — ticket, doc, Slack thread, related PR. Same-repo issues/PRs as bare '#123'. Link text is the natural noun, never a naked URL or 'click here'. Use ONLY the URLs supplied above; never construct, guess, or complete a URL that is not in that list. If something has no URL there, mention it as a plain unlinked identifier.

Be ruthless about including only what is absolutely necessary for a reviewer to know before they open the diff — the reader is a busy human skimming before a context switch. Keep each section to the few lines its content actually needs. Get there by leaving points out, never by clipping the ones you keep: every line must read as a complete, natural sentence or fragment. Prefer bullet lists to paragraphs, in every section including the summary — a skimming reader finds a bullet and loses a paragraph. One idea per bullet. Use a numbered list where order matters (migration or deploy steps). A single sentence is fine for a summary with one point; use bullets as soon as it covers several. Reserve paragraphs for genuinely explaining a tradeoff, and never write a wall of text. Never narrate the diff file by file. No filler openers ('This PR', 'In order to'), no repetition across sections, no padding. For verification/testing sections, state WHAT is covered (e.g. 'Unit tests for token refresh'), not HOW it was run or pass/fail counts."
```

**For NEW PR (no template):**
If no template was found, use this default structure:
```bash
gemini --prompt "Create PR description from git changes:
Branch: [NAME], Base: main
Files: [git diff --stat]
Diff: [git diff]
Commits: [git log] (reference only, focus on overall diff)
Verified references: [the Phase 1 list — ticket, design docs, Figma, Miro, Confluence, Slack threads, related PRs; give each as 'what it is: URL']

Structure — Summary and Checklist are always present; drop any other section that adds nothing:
## Summary: what changed, and why. One sentence if the PR has a single purpose; bullets if it covers several things.
## Changes: short fragments, one per distinct change, grouped by area. OMIT when the summary already covers it.
## Technical Details: ONLY a non-obvious decision or tradeoff a reviewer would otherwise question. OMIT by default.
## Testing: ONE line naming what is covered. OMIT if obvious.
## Related Issues: linked ticket and any related PR/doc/Slack thread. 'Fixes #123' only if merging closes it, else 'Related to #123'. OMIT if there are none.
## Checklist: [INCLUDE unless --no-checklist] markdown task list, one line each, no commentary:
- [ ] Follows code conventions
- [ ] Tests added/updated
- [ ] Docs updated
- [ ] Tested on device

At the very end, emit ALL commits in a hidden HTML comment block (NOT a visible section):
<!-- pr-commits
<full-SHA>: <message>
<full-SHA>: <message>
-->

Be ruthless about including only what is absolutely necessary for a reviewer to know before they
open the diff — the reader is a busy human skimming before a context switch and wants what/why in
one glance. There is no length to hit: the description runs exactly as long as the necessary content
and not one line longer. Get there by leaving points out, not by clipping the ones you keep — every
sentence must read as complete and natural.

Prefer bullet lists to paragraphs in every section, the Summary included — a skimming reader finds a
bullet and loses a paragraph. One idea per bullet. Use a numbered list where order matters (migration
or deploy steps, reproduction steps). A single sentence is right for a Summary with one point; use
bullets as soon as it covers several, rather than stringing them together with 'and' and 'also'.
Paragraphs are only for genuinely explaining a tradeoff in Technical Details. Never a wall of text.

Never narrate the diff file by file; the diff already shows that. No filler openers ('This PR',
'In order to'), no repetition across sections, no hedging or self-praise ('comprehensive',
'robust'). Omitting a prose section always beats padding it. The Checklist is fixed structure —
reproduce it verbatim and add no commentary around it. Focus WHAT/WHY, never HOW.

Turn the verified references above into markdown links wherever the description mentions what they
point to — ticket, design doc, Slack thread, related PR, upstream release notes. A link is the
cheapest way to give context, so linking is never padding. Same-repo issues/PRs as bare '#123',
cross-repo as 'org/repo#456'. Link text is the natural noun in the sentence, never a naked URL and
never 'click here'. Use ONLY the URLs supplied above — never construct, guess, or complete one. If
something has no URL in that list, mention it as a plain unlinked identifier."
```

**For UPDATE (new commits):**
```bash
gemini --prompt "Update PR with new commits:
Existing: [PR BODY]
New commits: [LIST with SHA]
New diff: [git diff <last-SHA>..HEAD]
Verified references: [any NEW references since the last update — ticket, docs, Figma, Miro, Slack, related PRs; give each as 'what it is: URL']

Preserve every existing markdown link in the body exactly as it is. Link any new reference above the
same way the body already links things. Use ONLY the URLs supplied; never construct or guess one.

Keep Summary (update only if the change is now fundamentally different). MERGE the new work into
Changes rather than appending a parallel list — rewrite bullets so the section reads as one
description of the final state, and delete bullets the new commits made obsolete. Update
Technical Details/Testing only if needed; keep Related Issues and the Checklist exactly as they are
(never re-tick or un-tick checklist boxes — the author owns those).

An update must not make the description bloat over time. Re-apply the necessity test to the whole
merged result, not just the new material: anything no longer absolutely necessary comes out. Delete
whole bullets rather than shortening the ones you keep, and never leave a half-finished sentence
behind a deletion. Do not
add changelog-style '**Update:**' markers or per-round history; reviewers read the current state,
and git history covers the rest.

At the very end, replace the existing <!-- pr-commits --> block with an updated one containing ALL commits (old + new):
<!-- pr-commits
<full-SHA>: <message>
-->

Stay concise."
```

## Phase 3: Trim Pass (do not skip)

Gemini's draft is a first draft. Before posting, read it back as the reviewer and cut:

1. Take each bullet and sentence in turn and ask: **is this absolutely necessary before opening the
   diff?** Anything that isn't comes out whole. Remove entire bullets, sentences, or sections; never
   truncate one mid-thought or compress it into telegraphese. Whatever stays must read as a
   complete, natural sentence or fragment.
2. Delete any bullet that restates a filename, function name, or line the diff already shows.
3. Delete any sentence whose removal loses no information a reviewer needs before reading the diff.
4. Drop whole sections that survived as scaffolding (`Technical Details` with nothing noteworthy,
   `Testing` restating "tests pass", `Related Issues: None`). Never drop the `## Checklist` unless
   `--no-checklist` was passed, and never drop a section the repo template requires.
5. Strip filler openers, hedges, and self-praise flagged in Rule Zero.
6. Find every paragraph, the Summary's included. If it enumerates things, convert it to bullets; if
   it's a sequence, to a numbered list; if it strings points together with "and"/"also", split it.
   The only paragraph that survives this step is one explaining a genuine tradeoff — anything else
   is a list in disguise or padding.
7. **Check the links** (Rule One). Every reference the description names — ticket, doc, Figma, Miro,
   Slack thread, related PR — is either a link or an identifier you genuinely could not resolve.
   Then verify each URL character by character against where you took it from: Gemini will happily
   invent a plausible ticket or Confluence URL, and a URL half-remembered from earlier in the
   session is just as wrong. Any URL not traceable to the Phase 1 list gets unlinked, not guessed at.
   Last, check the reverse direction: did anything in the Phase 1 list get dropped that the
   description should be pointing at?
8. Reread the Summary alone: does it answer what changed and why, without the rest? If not, fix
   the Summary first — it's the only part many reviewers read.

Post the trimmed version, not the draft.

Once everything remaining is genuinely load-bearing, stop — however long or short that leaves it. A
large PR touching real complexity earns its length; a one-line fix earns one line. Ruthlessness is
about what survives the necessity test, never about squeezing what does.

## Phase 4: Create/Update PR

```bash
# Create new:
gh pr create --draft --title "[TITLE]" --body "$(cat <<'EOF'
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

**Notes:** Always include `<!-- pr-commits -->` HTML comment block (full SHA + message) for tracking rebases — invisible in rendered PR. Focus overall diff for new PRs. Detect rebases by SHA comparison. When in doubt about whether something belongs in the description, leave it out — Rule Zero wins. When in doubt about a URL, leave it unlinked — Rule One never permits a guess.
