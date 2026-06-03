---
name: check-merge
description: Review the most recent merge/join in a script for correctness.
argument-hint: "[path to script]"
allowed-tools: ["Read", "Bash", "Grep"]
---

Review the most recent merge/join in the script at $ARGUMENTS (or the current script if no path is given).

Detect the language from the file extension and adapt accordingly:
- **Stata** (`.do`): `merge`, `joinby`, `append` — inspect `_merge` tabulation.
- **Python** (`.py`): `pd.merge`, `df.merge`, `df.join`, `pd.concat` — inspect `indicator=True` / `validate=` if used, else suggest adding them.
- **R** (`.R`, `.Rmd`, `.qmd`): `left_join`, `right_join`, `inner_join`, `full_join`, `merge()`, `bind_rows` — check `relationship` / `multiple` args in dplyr ≥1.1.

Check:
1. **Merge keys** — are the key columns/variables actually present in both datasets, and do their types match? (Read both source files / look at the upstream code that constructs them.)
2. **Match rates** — how many observations matched vs. unmatched? Run or describe how to tabulate (`_merge` in Stata, `indicator` column in pandas, anti-joins in dplyr).
3. **Row count change** — did the merge change N unexpectedly (blow-up from many-to-many, or silent drops from inner join)?
4. **Duplicate keys** — are there duplicate keys on either side that could cause an unintended many-to-many merge? Suggest a `validate=` (pandas), `relationship=` (dplyr), or `assert` / duplicate-check (Stata) to lock down the expected cardinality.
5. **NA / missing keys** — are NAs in the key column being silently dropped or matched to each other?

Report findings as a short bulleted list and flag anything suspicious. If something can't be verified statically, say so and suggest the one-line check the user should run.
