# Coding preferences

I'm an economist doing empirical research. Prioritize correctness and readability over abstraction.

## Script structure and abstractions

- Prefer straight-line, top-to-bottom scripts; organize long ones with numbered section headers (`# ---- 1. Load data ----`), not functions.
- Don't extract a helper unless the logic is reused 3+ times or a block exceeds ~30 lines; inline short operations.
- Numbered top-level scripts (`1-build.do`, `2-clean.py`, `3-analyze.py`) are good — don't restructure them into modules or packages.
- Default to functions over classes, but use classes where they fit (Pydantic / structured-output schemas for LLM responses, dataclasses for grouped state).
- Don't introduce design patterns (factories, decorators, dependency injection, registries) unless I ask.

## Naming and comments

- Descriptive variable names (`prices_2020`, not `p`) so the code reads like the analysis.
- Comments explain *why* (the econ reasoning), and *what* when the code is non-obvious. Don't narrate obvious steps.

## Refactoring discipline

- Only modify what I ask you to modify — fix the bug I asked about, don't also rename, reorganize, or clean up surrounding code. Don't suggest refactoring proactively; flag anything worth noting once, in passing.
- Don't add error handling, fallbacks, or validation for cases that can't realistically happen in my pipeline.
- Prefer loud failures (`assert`, `stopifnot`, errors) over silent NA propagation or default values when data is wrong.

## Language stack

- Primary: **Python** (pandas, numpy, scipy, statsmodels, openai, pydantic, selenium) and **Stata** (`.do` files).
- Secondary: **R** only when the project requires it (tidyverse, fixest, sf, terra) — don't push me to R when Python or Stata can do the job.
- Python: pandas method chaining when readable, else sequential assignment. Stata: standalone `.do` scripts, no programs/macros unless warranted. R: tidyverse pipes (`|>`/`%>%`) for long chains.

## How to talk to me about your work

- Keep walkthroughs tight — bullets or compact tables, not paragraphs.
- After any cleaning, transformation, or merge, report: what you loaded (row/col counts, key columns); what you filtered/joined/computed and why; how many rows survived each step and what dropped; and any assumptions (join key, duplicate handling, NA treatment). Flag silent drops or NA-fills rather than letting me find them later.
- For regression or analysis output, state the headline result in a sentence or two before the table.
- For code review, point me to the key lines implementing the substantive decision, not every changed line.

## Regression / table output format

- For tables I'll drop into LaTeX, export **rows only** — no column headers, rules, or panel titles. I add those in the `.tex` wrapper via `\ExpandableInput{...}` inside a `tabular*` environment.
- Each row: row label, then `&`-separated cells, ending in `\\`. Example:
  ```
  Time FE             &         1.8&           3\\
  Individual FE       &        47.2&        52.3\\
  Time + Individual FE&        47.8&          54\\
  Unique Respondents  &       15443&       15458\\
  ```
- Write to a plain `.tex` fragment (e.g. `tables/<name>.tex`) — just the rows. Keep numeric formatting consistent within a table (don't mix `0.472` and `47.2%` in one column). Standard errors in parentheses on the row below the coefficient, same format.

## Code review after changes

AFTER EVERY BIG CHANGE, LAUNCH A SONNET SUBAGENT TO REVIEW YOUR CHANGES FOR ISSUES. IF ANY ISSUES ARE FOUND, ADD A NEW ROUND OF AUDITING AFTER FIXING THE CURRENT ROUND'S ISSUES (EVEN IF THERE ARE ONLY MINOR CHANGES). ITERATE UNTIL DONE.

## Verification and provenance

For real empirical pipelines (not one-off edits, quick lookups, or throwaway scripts), leave a trail I can check without redoing the work — producing results is cheap now, verifying them isn't.

- **Set up the trail first.** Use git from the project's outset; ask whether I want DECISIONS.md / LOG.md before generating results.
- **Commit in bounded checkpoints** (pull → clean → merge → compute → estimate), each with a message saying *why*. I review diffs, not whole codebases.
- **DECISIONS.md / LOG.md on request** — judgment calls (choice, rejected alternatives, confidence) and a run narrative, via the `verification-trail` skill.
- **Attrition tables.** Beyond reporting drops in chat, write an auditable `step, n_remaining, n_dropped, why` table in the Python cleaning stage.
- **No number typed by hand** — every number/figure comes from a generated output file (the row-only `.tex` fragments above), never a hardcoded coefficient; keep it traceable table → script → commit → decision.
- **Never fake the trail.** Only log decisions and steps that actually happened — a clean trail documenting work you didn't do is worse than none.

## Other

- Don't write tests, type stubs, markdown docs, or `README.md`/summary files unless I ask.
