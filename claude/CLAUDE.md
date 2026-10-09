# CLAUDE.md (user level)

Personal instructions that apply to every project on this machine. Project-level
`CLAUDE.md` files take precedence over anything here.

## Communication

- Be concise and direct. Skip preamble, flattery, and summaries of what you just did
  unless the outcome is non-obvious.
- Lead with the answer, then the reasoning if it's needed.
- When something is uncertain, say so plainly rather than hedging throughout.
- Write literally. No metaphors, analogies, idioms, or figurative language, and no
  personification of code or tools ("the function wants", "the test complains").
  Say the plain thing instead ("the function requires", "the test fails"), even if
  it takes a few more words. Figurative wording forces the reader to translate
  before they can act, and it is easy to misread.
- Prefer short, plain sentences. One idea per sentence. Prefer the common word over
  the clever one. Before sending, reread and rewrite any sentence that could be
  misunderstood on a quick skim.
- Any text for humans, including your replies to me (PR descriptions, Slack, Jira,
  review replies, chat answers):
  draft, shorten, then read it back and shorten again. Keep only what is absolutely
  necessary. Cut whole points rather than trimming words. Format as bullets or
  numbered points for ease of consumption. Use accepted, plain language; no invented
  terms or wording that could confuse the reader.

## Formatting & language

Applies to prose written for people: Jira, Slack, PR titles and descriptions, code
review comments, Confluence, commit messages, and markdown docs. Code is exempt.

- No em-dash. Use a comma, colon, or full stop instead.
- Keep punctuation to the standard ASCII keyboard: no en-dash, curly quotes,
  ellipsis character, or arrows. This covers punctuation only. Proper nouns,
  currencies, and units keep their correct characters (Zoë, £50, 25°C).
- Emoji are the exception to the above, and fine in Slack and other casual
  channels. Not in Jira, PRs, or Confluence.
- UK/AU spelling in prose. US spelling in code for identifiers, API fields, and
  filenames, matching what libraries and languages use (`color`, `serialize`).
  User-facing strings in a product follow that product's locale.

## Code

- Match the surrounding code's style, naming, and comment density instead of
  importing conventions from elsewhere.
- Comments explain *why*, not *what*. Don't narrate rejected approaches.
- Prefer editing existing files over creating new ones; don't leave dead code behind.
- No new dependencies without asking.

## Working style

- Read before you write: check how a thing is already done in the repo first.
- Run the project's own tests/linters after changes rather than assuming they pass.
- Report failures with the actual output. Never claim something works unverified.

## Git

- Commit or push only when asked. Never force-push or rewrite shared history
  without explicit instruction.
- Keep commit subjects imperative and under ~72 characters; explain the *why* in
  the body ONLY when it isn't obvious.
