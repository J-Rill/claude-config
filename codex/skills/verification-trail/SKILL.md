---
name: verification-trail
description: >
  Create or update a project's verification trail so a coauthor (or you in six
  months) can check the work without rerunning it. Maintains DECISIONS.md
  (methodological choices, rejected alternatives, confidence) and LOG.md (a
  plain-language narrative of what each stage actually did). Use when the user
  says "log this decision", "record why we chose", "update DECISIONS.md", "add a
  decision", "update the log", "log this stage", "add a LOG.md entry", "checkpoint
  this", "update the trail", or after a non-obvious methodological choice / a data
  step worth narrating in an empirical pipeline. Records ONLY what actually happened — never
  fabricates. Distinct from PROGRESS.md (progress-tracker skill — transient
  session state and next steps) and restart.md (restart skill — context handoff
  before /clear); those are ephemeral, this is the durable research record.
---

# verification-trail

Maintain the two durable documents that make an AI-assisted analysis verifiable:
**DECISIONS.md** (the *why* behind each judgment call) and **LOG.md** (the *what
happened* narrative). Modeled on Paul Goldsmith-Pinkham's `ipo-bump` workflow.

**Input:** the user's request — an optional hint at what to log (a decision, a stage, or
"the trail"). If empty, infer from the recent conversation what just happened that
is worth recording, and confirm with the user if it is ambiguous.

## Why this exists

AI collapsed the cost of *doing* empirical work but not the cost of *verifying* it
("verification debt"). A reviewer should be able to see *why* a choice was made and
*what* the pipeline did without re-deriving it. DECISIONS.md and LOG.md are how the
work stays checkable one bounded piece at a time.

## Routing — which file to touch

- Request is about a **choice / tradeoff / "why"** ("log this decision", "record why
  we chose X over Y") → **DECISIONS.md**.
- Request is about **what a stage/script did** ("log this stage", "add a LOG.md
  entry", "update the log") → **LOG.md**.
- Request says **"the trail" / "checkpoint this"** → update **both** (a decision
  entry if a judgment call was made, and a stage entry for the run).

Both files live at the **project root**. Read the existing file first (if any) so
you append rather than overwrite, and so DECISIONS.md continues the `Dn` numbering.

## DECISIONS.md format

Numbered entries `## D0`, `## D1`, … Each entry has four bold fields. Flag anything
you are unsure about with ⚠️. Confidence is High / Medium / Low with a phrase of
justification. No dates here (dates live in LOG.md).

```
# DECISIONS.md — methodological log

Every choice below is deliberate. Format: **Choice / Alternatives rejected /
Rationale / Confidence**. Anything I am unsure about is flagged ⚠️.

## D0. <short title of the choice>
- **Choice:** what was decided, concretely (formula, threshold, variable, sample rule).
- **Alternatives rejected:** the real options not taken, and why each was rejected.
  Mark ⚠️ on the alternative most likely to change the result.
- **Rationale:** the econ / statistical reasoning for the choice.
- **Confidence:** High / Medium / Low — with a phrase saying why.
```

When you add an entry: open DECISIONS.md, find the highest existing `Dn`, and append
`D(n+1)`. If the file does not exist, create it with the header block above starting
at `D0`.

## LOG.md format

Chronological stage sections, bullets, concrete numbers a coauthor can follow. Put
the real date on the section header (get it with `date +%F` if unsure). Record
gotchas you fixed inline. Close the file with an "Open questions" section.

```
# LOG.md — running narrative a coauthor could follow

## Stage N — <title> (YYYY-MM-DD)
- What ran and what came out, with real counts / paths
  (e.g. "loaded 16,030 Ritter rows; 14,084 after valid offer date").
- Any bug found and fixed during the build, stated plainly.
- Pointer to the attrition table / output file this stage wrote.

## Open questions / things I'd check with more time
- The choices most likely to move the result; sensitivity checks not yet run.
```

When you add a stage: append the new `## Stage N` section above the "Open questions"
block (keep that block last), or create the file with the header if it does not exist.

## The honesty rule — non-negotiable

Only log decisions, runs, and results that **actually happened**. PGP caught this
tool logging a robustness check (cumulative abnormal returns) that was never run — a
clean-looking trail that documents work you didn't do is worse than no trail, because
it launders unchecked results as verified.

- If you are unsure whether a step ran or a number is real, **verify it** (read the
  output file, rerun the step) or **ask** — do not write it as done.
- Numbers in LOG.md must come from actual output; never estimate or round-trip a
  remembered figure into the log.
- Confidence in DECISIONS.md reflects genuine uncertainty, not optimism.

## Attrition tables (pipelines)

When the work is a real data pipeline, don't just narrate drops — write an auditable
attrition table (`step, n_remaining, n_dropped, why`) so every dropped observation is
accounted for. A ready-made Python helper ships with this skill at
`references/attrition.py`; copy it into the project (e.g. `src/attrition.py`) and use:

```python
from attrition import Attrition
att = Attrition("sample")
att.step("raw Ritter events", len(df))
df = df[df["price"] >= 5]
att.step("drop penny stocks", len(df), why="offer price < $5")
att.write("output/attrition.csv")
```

Then reference the CSV from the relevant LOG.md stage. Keep the provenance chain
unbroken from cleaning through to the draft — no number in the draft is typed by
hand: it flows from a generated output file into whatever writes the final table
(typically a Stata `.do` file emitting row-only `\ExpandableInput` `.tex` fragments,
or statsmodels when the whole pipeline stays in Python).

## Anti-patterns

- A decision entry with no rejected alternatives, or vague "seemed best" rationale.
- Missing or absent confidence rating; no ⚠️ on the genuinely risky call.
- Back-dating or inventing stage entries; logging a run that didn't happen.
- Overwriting the file instead of appending / continuing the `Dn` numbering.
- Duplicating PROGRESS.md's transient session state here — this file is durable.
- Prose walls in LOG.md with no concrete counts; a coauthor can't verify adjectives.
