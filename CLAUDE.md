# Coding preferences

I'm an economist doing empirical research. Prioritize correctness and readability over abstraction.

## Script structure

- Prefer straight-line, top-to-bottom scripts over heavy function decomposition.
- Don't extract helper functions unless the logic is reused 3+ times or a block exceeds ~30 lines.
- Inline short operations rather than wrapping them in single-use functions.
- For long scripts, organize with numbered section header comments (e.g. `# ---- 1. Load data ----`, `# ---- 2. Clean ----`), not with functions.
- Numbered top-level scripts (`1-build.do`, `2-clean.py`, `3-analyze.py`) are good. Don't restructure them into modules or packages.

## Naming and comments

- Variable names should be descriptive (`prices_2020`, not `p`) so the code reads like the analysis.
- Comments primarily explain *why* (the econ reasoning), but also explain *what* when the code is non-obvious or complex.
- Don't narrate obvious steps in comments.

## Abstractions

- Avoid premature generalization — concrete code I read top-to-bottom beats clever abstractions.
- Default to functions over classes, but use classes where they're the right tool: Pydantic / structured-output schemas for constraining LLM responses (OpenAI API), dataclasses for grouped state, etc.
- Don't introduce design patterns (factories, decorators, dependency injection, registries) unless I ask.

## Refactoring discipline

- Only modify what I explicitly ask you to modify. Do not refactor, rename, or reorganize unless I specifically request it.
- When I ask for a bug fix, fix the bug. Don't also rename, reorganize, or "clean up" surrounding code.
- Don't add error handling, fallbacks, or input validation for cases that can't realistically happen in my data pipeline.
- Prefer loud failures (errors, `assert`, `stopifnot`) over silent NA propagation or default values when data is wrong.
- Don't suggest refactoring proactively. If you spot something worth flagging, mention it once in passing — don't make it the focus of the response.

## Language stack

- Primary: **Python** (pandas, numpy, scipy, statsmodels, openai, pydantic, selenium) and **Stata** (`.do` files).
- Secondary: **R** — only used when the project requires it (tidyverse, fixest, sf, terra). Don't push me toward R when Python or Stata can do the job.
- Python: prefer pandas method chaining when it stays readable; otherwise sequential assignment is fine.
- Stata: `.do` files are standalone scripts; don't add programs/macros unless really warranted.
- R (when needed): tidyverse-style pipes (`|>` or `%>%`) for long data-manipulation chains.

## How to talk to me about your work

- Walk me through data work, but keep it tight — I want to understand what you did without wading through paragraphs.
- After any data cleaning, transformation, or merge step, give me a short walkthrough covering:
  - What you loaded (row/col counts, key columns)
  - What you filtered, joined, or computed, and why
  - How many rows survived each step, and whether anything dropped that I should know about
  - Any assumptions you made (which column was the join key? which observations were treated as duplicates? what did you do with NAs?)
- Prefer bullet points or compact tables to long prose when reporting these.
- For regression/analysis output, summarize the headline result in one or two sentences before showing the table.
- For code I should review, point me to the key lines that implement the substantive decision, not just every line you changed.
- Surface silent transformations clearly — I'd rather you flag a quiet drop or NA-fill than have me discover it later.

## Regression / table output format

- When you produce regression or summary tables that I'll drop into LaTeX, export **rows only** — **no column headers, no top/midrule, no panel titles**. I add those in the `.tex` wrapper via `\ExpandableInput{...}` inside a `tabular*` environment.
- Each row should be: row label, then `&`-separated cell values, ending in `\\`. Example of the expected output style:
  ```
  Time FE             &         1.8&           3\\
  Individual FE       &        47.2&        52.3\\
  Time + Individual FE&        47.8&          54\\
  Unique Respondents  &       15443&       15458\\
  ```
- Write to a plain `.tex` fragment (e.g. `tables/<name>.tex`) — no `\begin{tabular}`, no `\toprule`, no `\caption`. Just the rows.
- Keep numeric formatting consistent within a table (e.g. all percentages to one decimal, counts as integers). Don't mix `0.472` and `47.2%` in the same column.
- If I need standard errors, put them in parentheses on the row below the coefficient, same `&`-separated format.

## Code review after changes

AFTER EVERY BIG CHANGE, LAUNCH A SONNET SUBAGENT TO REVIEW YOUR CHANGES FOR ISSUES. IF ANY ISSUES ARE FOUND, ADD A NEW ROUND OF AUDITING AFTER FIXING THE CURRENT ROUND'S ISSUES (EVEN IF THERE ARE ONLY MINOR CHANGES). ITERATE UNTIL DONE.

## Verification and provenance

For real empirical pipelines (multi-step cleaning, analysis that produces numbers or figures I'll use), leave a trail I can check without redoing the work — AI has made producing results cheap, but verifying them is still expensive. Scope this to actual pipelines, not one-off edits, quick lookups, or throwaway scripts.

- **Set up the trail before the work.** For a new analysis project, use git from the outset (not retroactively). Ask whether I want DECISIONS.md / LOG.md before generating results, not after.
- **Commit in bounded checkpoints.** One logical step per commit at meaningful points (pull → clean → merge → compute → estimate), with a message saying *why*, not just *what*. I review diffs, not whole codebases.
- **DECISIONS.md and LOG.md on request.** Record judgment calls (choice, rejected alternatives, confidence) and a plain-language run narrative when I ask — use the `verification-trail` skill so the format stays consistent.
- **Make attrition auditable.** After every filter, merge, or drop, report N before → after and why. In a pipeline, write it to an attrition table (`step, n_remaining, n_dropped, why`) in the Python cleaning stage, don't just mention it in chat.
- **No number typed by hand.** Every number and figure in a draft comes from a script-generated output file — typically Python cleaning → Stata regressions writing the row-only `\ExpandableInput` `.tex` fragments (or statsmodels when a project stays entirely in Python). Text ingests generated outputs; it never hardcodes a coefficient.
- **Keep provenance traceable.** I should be able to trace any reported number back through table → script → commit → logged decision, across whatever cleaning → regression handoff the project uses.
- **Never fake the trail.** Only log decisions and steps that actually happened. Don't record a robustness check, run, or result that wasn't performed — a clean-looking trail documenting work you didn't do is worse than no trail.

## Other

- Don't write tests, type stubs, or markdown documentation files unless I ask.
- Don't create `README.md` or summary files just because a task is done.
