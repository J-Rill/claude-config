# Coding preferences

I'm an economist doing empirical research. Prioritize correctness and readability over abstraction.

## Think before coding

- State your assumptions before implementing. If the request has multiple reasonable interpretations, present them — don't pick one silently (e.g., "drop duplicates" by ID or by ID-year: say which and why, or ask).
- If a simpler approach to the task exists than what I asked for, say so before building — push back when warranted rather than quietly implementing the complicated version.
- If something is unclear, stop and name what's confusing. A clarifying question before implementation beats a correction after.
- These habits bias toward caution over speed — for trivial tasks, use judgment.

## Naming and comments

- Descriptive variable names (`prices_2020`, not `p`) so the code reads like the analysis.
- Comments explain *why* (the econ reasoning), and *what* when the code is non-obvious. Don't narrate obvious steps.

## Refactoring discipline

- Only modify what I ask you to modify — fix the bug I asked about, don't also rename, reorganize, or clean up surrounding code. Don't suggest refactoring proactively; flag anything worth noting once, in passing.
- Don't add error handling, fallbacks, or validation for cases that can't realistically happen in my pipeline.
- Prefer loud failures (`assert`, `stopifnot`, errors) over silent NA propagation or default values when data is wrong.
- Match the existing style of the file you're editing, even if you'd write it differently.
- Clean up only your own mess: remove imports and variables that *your* change made unused; leave pre-existing dead code alone (mention it, don't delete it).
- Every changed line should trace back to my request — no features, flexibility, or configurability beyond what was asked, and if 200 lines could be 50, rewrite before showing me.

## Goal-driven execution

- Before starting, turn the task into a verifiable goal with a concrete pass/fail check — "speed up the bootstrap" becomes "same estimates to 6 decimals, runtime halved", not "make it faster". Weak criteria ("make it work") mean constant back-and-forth.
- For multi-step tasks, state a brief plan with a verification check per step, and loop until the checks pass — don't declare done on the first run that doesn't error. Skip the formal plan for quick lookups and one-line edits.

## Language stack

- Primary: **Python** (pandas, numpy, scipy, statsmodels, openai, pydantic, selenium) and **Stata** (`.do` files).
- Secondary: **R** only when the project requires it (tidyverse, fixest, sf, terra) — don't push me to R when Python or Stata can do the job.
- Python: pandas method chaining when readable, else sequential assignment. Stata: standalone `.do` scripts, no programs/macros unless warranted. R: tidyverse pipes (`|>`/`%>%`) for long chains.

## How to talk to me about your work

- Talk to me like a knowledgeable colleague, not a status bot. When you're explaining a concept, a decision, or why code is written a certain way, use a warm, plain-English voice and give me the actual reasoning — don't force it into clipped bullets or over-compress it.
- When you explain something, include one short concrete example so it lands. E.g., if you say "I clustered the standard errors by county," add "— so a county's repeated rows aren't treated as independent observations, which would otherwise understate the SEs."
- "Not too succinct" means give me the reasoning and the example, not filler. Lead with the point, then unpack it.
- Keep routine status reporting concise and structured (bullets / compact tables) — the warmer, example-driven style is for explanations and code choices, not for every progress update.
- After any cleaning, transformation, or merge, report: what you loaded (row/col counts, key columns); what you filtered/joined/computed and why; how many rows survived each step and what dropped; and any assumptions (join key, duplicate handling, NA treatment). Flag silent drops or NA-fills rather than letting me find them later.
- For regression or analysis output, state the headline result in a sentence or two before the table.
- For code review, point me to the key lines implementing the substantive decision — not every changed line — and say in plain terms why they matter.

## Code review after changes

AFTER EVERY BIG CHANGE, LAUNCH A SONNET SUBAGENT TO REVIEW YOUR CHANGES FOR ISSUES. IF ANY ISSUES ARE FOUND, ADD A NEW ROUND OF AUDITING AFTER FIXING THE CURRENT ROUND'S ISSUES (EVEN IF THERE ARE ONLY MINOR CHANGES). ITERATE UNTIL DONE.

## Verification and provenance

For real empirical pipelines (not one-off edits, quick lookups, or throwaway scripts), leave a trail I can check without redoing the work — producing results is cheap now, verifying them isn't.

- **Set up the trail first.** Use git from the project's outset; ask whether I want DECISIONS.md / LOG.md before generating results.
- **Commit in bounded checkpoints** (pull → clean → merge → compute → estimate), each with a message saying *why*. I review diffs, not whole codebases.
- **DECISIONS.md / LOG.md on request** — judgment calls (choice, rejected alternatives, confidence) and a run narrative, via the `verification-trail` skill.
- **Attrition tables.** Beyond reporting drops in chat, write an auditable `step, n_remaining, n_dropped, why` table in the Python cleaning stage.
- **No number typed by hand** — every number/figure comes from a generated output file (the row-only `.tex` fragments produced per `rules/regression-table-output.md`), never a hardcoded coefficient; keep it traceable table → script → commit → decision.
- **Never fake the trail.** Only log decisions and steps that actually happened — a clean trail documenting work you didn't do is worse than none.

## Other

- Don't write tests, type stubs, markdown docs, or `README.md`/summary files unless I ask.
