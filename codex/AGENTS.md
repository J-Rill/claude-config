# Working with me

I'm an economist doing empirical research. Prioritize correctness and readability over abstraction.

## Think before coding

- State assumptions before implementing. If a request has multiple reasonable interpretations, present them instead of silently choosing one.
- If a simpler approach would meet the goal, explain it before building the more complicated version.
- If a consequential detail is unclear and cannot be resolved from the project, ask before implementing. Use judgment for trivial tasks.

## Naming and comments

- Use descriptive variable names (`prices_2020`, not `p`) so code reads like the analysis.
- Comments explain the economic or methodological reason, and explain what happens only when the code is non-obvious. Do not narrate obvious operations.

## Refactoring discipline

- Modify only what was requested. Do not rename, reorganize, or clean surrounding code unless the task requires it.
- Do not add validation, fallbacks, or error handling for cases that cannot realistically occur in the pipeline.
- Prefer loud failures (`assert`, `stopifnot`, explicit errors) over silent NA propagation or default values when data is wrong.
- Match the existing file style.
- Remove imports and variables made unused by your change, but leave pre-existing dead code alone and mention it once if relevant.
- Every changed line should trace to the request. If 200 lines could be 50, simplify before handoff.

## Goal-driven execution

- Turn non-trivial tasks into a verifiable goal with concrete pass/fail checks before starting.
- For multi-step work, state a brief plan with a verification check per step and keep iterating until the checks pass. Skip a formal plan for quick lookups and one-line edits.

## Language stack

- Primary: Python (`pandas`, `numpy`, `scipy`, `statsmodels`, `openai`, `pydantic`, `selenium`) and Stata (`.do`).
- Secondary: R only when the project requires it (`tidyverse`, `fixest`, `sf`, `terra`). Do not push work to R when Python or Stata is the natural fit.
- Python: use pandas method chaining when readable, otherwise sequential assignment.
- Stata: prefer standalone `.do` scripts; avoid programs and macros unless warranted.
- R: use tidyverse pipes (`|>` or `%>%`) for long chains.

## Communication

- Write like a knowledgeable colleague: warm, plain English with the reasoning behind substantive choices.
- When explaining a concept or decision, include one short concrete example.
- Keep routine progress updates concise and structured.
- After cleaning, transforming, or merging data, report what was loaded (row and column counts, key columns), what changed and why, attrition at each step, and assumptions about keys, duplicates, and missing values. Flag silent drops and fills.
- Lead regression or analysis output with the headline result before tables.
- In code review, point to the lines implementing substantive choices and explain why they matter.

## Code review after changes

- After every big change, spawn a fresh `gpt-5.6-terra` subagent at high reasoning effort to review the actual diff and changed files. Ask for concrete correctness issues, not general suggestions.
- If the reviewer finds issues, fix them and launch another fresh audit. Continue until a full pass finds no issues.
- For substantive empirical pipelines, explicitly ask the reviewer to audit merge cardinality, silent row loss, NA propagation, sample selection, econometric logic, and provenance. The Terra review is the independent second-model pass; do not shell out to another `codex exec` recursively.

## Code review priorities

- Merge and join correctness: silently dropped or duplicated rows, wrong keys, and unintended many-to-many matches.
- Silent data corruption: NA propagation, default fills, type coercion, and off-by-one date or panel logic.
- Econometric logic: clustering level, cleaning-induced sample selection, look-ahead bias, and incorrectly absorbed fixed effects.
- Provenance: no hand-typed analytical results; every coefficient and figure must trace to generated output.
- Rank findings by severity. Cite the file and line and give a concrete failure scenario. Skip style-only nits unless asked.

## Verification and provenance

- For real empirical pipelines, leave a trail that can be checked without rerunning everything.
- Use git from the outset. Ask whether the user wants `DECISIONS.md` and `LOG.md` before generating results.
- Commit in bounded checkpoints only when the user has authorized commits. Messages should say why the checkpoint exists.
- Use the `verification-trail` skill for requested decision and run logs.
- In Python cleaning stages, write an auditable `step, n_remaining, n_dropped, why` attrition table.
- Never type coefficients or figures by hand. Generate them from scripts and keep the chain table → script → commit → decision traceable.
- Record only work and decisions that actually occurred.

## Shared Codex resources

- Research code conventions: `~/.codex/rules/researcher-code-conventions.md`.
- Regression table conventions: `~/.codex/rules/regression-table-output.md`.
- Journal profiles: `~/.codex/references/journal-profiles.md`.
- Custom review agents: `~/.codex/agents/`.

## Do not do these unless asked

- Do not write tests, type stubs, Markdown documentation, or README files.
- Do not refactor or add adjacent features.
- Do not pad reviews with style nits.
