# Working with me

I'm an economist doing empirical research in Python and Stata (R only when a project requires it). Prioritize correctness and readability over abstraction.

## Before starting
- I often dictate long, loose requests. For anything longer than a few sentences, restate the task and your key assumptions in 2–3 lines before starting.
- If a request has more than one reasonable reading that changes the result, say which you're taking and why, or ask (e.g., "drop duplicates" by ID vs. ID-year).
- If there's a simpler approach than what I asked for, say so before building.
- For multi-step work, set a concrete pass/fail check up front ("same estimates to 6 decimals, runtime halved") and don't call it done until it passes.

## Editing code
- Change only what I asked for. Flag other issues once, in passing.
- Match the file's existing style. Remove what your change made unused; mention pre-existing dead code rather than deleting it.
- No error handling for cases that can't happen in my pipeline. Prefer loud failures (`assert`, `stopifnot`) over silent NAs or defaults.
- Descriptive names (`prices_2020`, not `p`). Comments explain the econ reasoning, not obvious steps.
- Keep diffs small: if 200 lines could be 50, rewrite first.
- Python: method chaining when readable. Stata: standalone `.do` files. R: pipes.
- No tests, docs, or README files unless asked.

## Talking to me
- Explanations: plain-English colleague voice. Lead with the point, give the reasoning, and include one short concrete example (e.g., "clustered by county, so a county's repeated rows aren't treated as independent, which would understate SEs").
- Routine status: short bullets or a compact table.
- After any cleaning or merge: rows loaded, rows surviving each step and why, join keys, duplicate/NA handling. Flag silent drops.
- Analysis output: state the headline result in a sentence before the table.
- Code review: point me to the lines that carry the substantive decision.

## Review (scaled to stakes)
- Pipeline code (cleaning, merges, estimation): when done, get one independent review with `codex exec --sandbox read-only` on the diff. A cross-model reviewer doesn't share your blind spots. Fix real issues and re-review once if the fixes were substantive. Stop after 2 rounds or once only nits remain. If `codex` isn't on PATH, try `~/.nvm/versions/node/*/bin/codex`. If it's unavailable, say so and use a Sonnet subagent instead.
- Small edits and one-off scripts: no automatic review.

## Verification trail (empirical pipelines only)
- Use git from the start. Commit at checkpoints (pull → clean → merge → compute → estimate) with messages that say why.
- Before generating results, ask whether I want DECISIONS.md / LOG.md (`verification-trail` skill).
- Write an attrition table (`step, n_remaining, n_dropped, why`) in the cleaning stage.
- No hand-typed numbers. Every reported number comes from a generated file (format: `rules/regression-table-output.md`).
- Log only what actually happened.
