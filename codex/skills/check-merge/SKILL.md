---
name: check-merge
description: Review the most recent merge or join in a Python, Stata, or R script for key validity, cardinality, match rates, row loss or expansion, duplicate keys, and missing-key behavior. Use when the user asks to check a merge, join, append, concat, or recent data combination step.
---

# Check a merge or join

Review the most recent merge or join in the script named by the user. If no path is given, use the script currently in scope; ask only if the target cannot be inferred.

Detect the language from the extension:

- Stata (`.do`): inspect `merge`, `joinby`, and `append`, including `_merge` tabulation.
- Python (`.py`): inspect `pd.merge`, `DataFrame.merge`, `DataFrame.join`, and `pd.concat`, including `indicator=` and `validate=`.
- R (`.R`, `.Rmd`, `.qmd`): inspect `left_join`, `right_join`, `inner_join`, `full_join`, `merge()`, and `bind_rows`, including `relationship=` and `multiple=` in dplyr 1.1+.

Check:

1. Confirm the key fields exist on both sides and have compatible types. Trace upstream construction when necessary.
2. Quantify matched and unmatched observations, or give the exact one-line diagnostic when execution is unavailable.
3. Compare row counts before and after and identify unexpected expansion or silent loss.
4. Check duplicate keys on both sides and infer the intended cardinality. Recommend or add a locking assertion only when the user asked for a change.
5. Check how missing keys behave, including whether missing values are dropped or matched to each other.

Return a short severity-ranked findings list. For anything suspicious, cite the file and line and give a concrete failure scenario. Clearly distinguish verified facts from diagnostics the user still needs to run.
