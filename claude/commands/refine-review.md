# Refine Review

Rework the code review findings above into draft PR comments. Apply these rules:

## 1. Do not post anything
- Do not post comments, reviews, or approvals to the PR. Use `gh` for reads only. Do not use `--comment`.
- Show the drafts here only. The user decides what to post.

## 2. Skip what is already said
- Fetch existing comments: `gh pr view <PR> --comments` (conversation) and `gh api repos/{owner}/{repo}/pulls/<PR>/comments` (inline).
- Drop a finding if an existing comment already covers it.
- If an existing comment covers it only in part, draft a reply to that comment with only the new point. Give the link to the comment you are replying to.

## 3. Raw markdown, ready to paste
- Put each comment in its own fenced block. Use a 4-backtick outer fence (````markdown) so inner ``` blocks survive.
- Above each block, give the location as `path/to/file.ext:LINE` (or a line range).

## 4. Label every comment
Start each comment with a `####` heading that gives its type:
- `#### Blocking`: must be fixed before merge (bug, security, data loss).
- `#### Non-blocking`: worth changing, author's call.
- `#### Nit`: style or wording.
- `#### Question`: you need information from the author.
- `#### FYI`: informational, no action needed.

## 5. Add a suggestion block when the fix is concrete
If the fix is a direct replacement of the commented lines, add:

```suggestion
<replacement lines>
```

Leave it out when the fix spans other files or is not a line-for-line replacement.

## 6. Keep it short and clear (most important)
- 1 to 3 sentences: the problem, then the fix. No preamble, no praise, no restating the code.
- Write for the author and other reviewers, who may have no context.
- Plain words, one idea per sentence.
- If the problem is not obvious, add a minimal example (input -> wrong result).
- Drop findings that do not survive this bar. Merge duplicates.

## Output order
Blocking first, then Non-blocking, Question, Nit, FYI. End with a one-line count per label, plus how many findings were skipped because existing comments cover them.
