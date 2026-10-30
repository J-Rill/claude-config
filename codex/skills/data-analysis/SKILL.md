---
name: data-analysis
description: "Python data exploration + cleaning pipeline — load → explore → clean → analysis-ready dataset, diagnostics, and figures. Use when user says \"analyze this dataset\", \"explore this CSV\", \"clean this data\", \"get me summary stats\", \"prep this for regression\", or points at a `.csv`/`.parquet`/`.dta` and asks for empirical prep. Regression estimation and publication tables are done in Stata (see below). Produces numbered Python scripts in `scripts/python/` and outputs to `scripts/python/_outputs/`."
---

# Data Analysis Workflow

Run the Python half of the standard workflow: load, explore, and clean a dataset,
produce diagnostics and figures, and write an **analysis-ready dataset** for
estimation. Per the usual workflow here, **regression estimation and regression
tables happen in Stata**, not Python — this skill hands off a clean `.dta` (plus a
parquet copy) and stops there. Quick `statsmodels` OLS is fine for exploratory
sanity checks, but the reported regressions and their `.tex` tables are produced in
Stata.

**Input:** the user's request — a dataset path (e.g., `data/county_panel.csv`) or a
description of the prep goal (e.g., "clean the CPS extract and build a
state-year panel ready to regress wages on education").

---

## Constraints

- **Follow the code conventions** in `~/.codex/rules/researcher-code-conventions.md`
  (straight-line numbered scripts, no premature helpers).
- **Save all scripts** to `scripts/python/` with descriptive numbered names
  (`01_load.py`, `02_clean.py`, ...).
- **Save all outputs** (figures, tables, pickled objects, parquet/dta) to
  `scripts/python/_outputs/`.
- **Pickle every key object** (summary tables, processed DataFrames). For large
  DataFrames prefer parquet; for the analysis-ready dataset also write `.dta` for
  Stata.
- **Run the `$double-check` skill** on the generated script before presenting
  results.
- **Fail loud.** Prefer `assert`/errors over silent NA propagation when the data
  is wrong (matches the global preferences).

---

## Workflow Phases

### Phase 0: Pre-Flight Report

**Before writing any analysis code, produce a Pre-Flight Report** showing you read
the inputs. This prevents the common failure mode where the agent hallucinates
variable names or skips project conventions.

Output block (in your response to the user, before Phase 1):

```markdown
## Pre-Flight Report

**Dataset:** [path]
- Variables found: [list from df.columns.tolist()]
- Rows: [len(df)]
- Key dtypes: [e.g., "outcome=float64, treatment=int8, state=category"]
- Missing-data summary: [% missing per key var via df.isna().mean()]

**Conventions read:**
- `~/.codex/rules/researcher-code-conventions.md` — [one-line summary, if relevant]

**Task interpretation:** [one sentence restating what the user asked for]

**Plan:** [3-5 bullet outline of the Python script structure]
```

If any input cannot be read (missing file, unreadable format), stop and ask the
user before proceeding.

### Phase 1: Setup and Data Loading

1. Create the Python script with a docstring header (title, author, purpose, inputs, outputs)
2. Imports at top, grouped (stdlib → third-party → local), one import per line
3. Set a seed once at top in YYYYMMDD format, e.g. `np.random.seed(20260415)`
4. Load and inspect the dataset (`df.info()`, `df.head()`, `df.describe(include="all")`)

### Phase 2: Exploratory Data Analysis

Generate diagnostic outputs:
- **Summary statistics:** `df.describe(include="all")`, missingness rates per column, dtype check
- **Distributions:** Histograms for key continuous variables (`matplotlib` / `seaborn`)
- **Relationships:** Scatter plots, correlation matrices (`df.corr(numeric_only=True)`)
- **Time patterns:** If panel data, plot trends over time per group
- **Group comparisons:** If treatment/control, compare pre-treatment means and balance tables

Save all diagnostic figures to `scripts/python/_outputs/diagnostics/`.

### Phase 3: Cleaning and Analysis-Ready Dataset

This is the core of the Python half. Build the dataset the Stata estimation will run on:

- **Clean:** fix dtypes, recode, handle missing values explicitly (never silently),
  construct derived variables, apply sample restrictions with module-level constants.
- **Walk through every step.** After each clean/merge/filter, print `len(df)` and a
  quick `df.head()` or value-count so the user can see exactly what survived. Log any
  rows dropped and why (an attrition table: `step, n_remaining, n_dropped, why`).
- **Exploratory estimation (optional):** a quick `statsmodels.formula.api.ols` fit is
  fine to eyeball a relationship — but this is a sanity check, not the reported result.
  Print `len(df)` before/after any fit so silently-dropped incomplete cases are visible.
- **Hand off to Stata:** write the analysis-ready dataset with `df.to_stata(...)` (and a
  parquet copy). The reported regressions + row-only `.tex` tables are produced in a
  Stata `.do` script following `~/.codex/rules/regression-table-output.md`.

### Phase 4: Figures

- Use `matplotlib` (with `seaborn` for higher-level wrappers when helpful)
- Include proper axis labels (sentence case, units)
- Set figure size explicitly: `fig, ax = plt.subplots(figsize=(X, Y))`
- Save as both `.pdf` and `.png`:
  ```python
  for ext in ("pdf", "png"):
      fig.savefig(OUT / f"figure_name.{ext}", bbox_inches="tight", dpi=200)
  ```

Regression *tables* are not produced here — they come out of Stata as row-only
`.tex` fragments (see `~/.codex/rules/regression-table-output.md`).

### Phase 5: Save and Review

1. Pickle (or parquet for DataFrames) every key object: summary tables, processed data.
   - `df_clean.to_parquet(OUT / "df_clean.parquet")`
   - `df_clean.to_stata(OUT / "analysis.dta")`  # for Stata estimation
2. Create `scripts/python/_outputs/` subdirectories as needed:
   `Path("scripts/python/_outputs/diagnostics").mkdir(parents=True, exist_ok=True)`.
3. Run the `$double-check` skill on the generated script.
4. Address any Critical or High issues from the review.

---

## Script Structure

Follow this template:

```python
"""
[Descriptive Title]

Author: [from project context]
Purpose: [What this script does]
Inputs:  [Data files]
Outputs: [Figures, tables, parquet/dta files]
"""

# ============================================================
# 0. Setup
# ============================================================
from pathlib import Path
import pickle

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import statsmodels.formula.api as smf  # only for exploratory OLS sanity checks

np.random.seed(20260415)  # YYYYMMDD

OUT = Path("scripts/python/_outputs")
OUT.mkdir(parents=True, exist_ok=True)

# ============================================================
# 1. Data Loading
# ============================================================
# [Load data]

# ============================================================
# 2. Exploratory Analysis
# ============================================================
# [Summary stats, diagnostic plots]

# ============================================================
# 3. Cleaning + analysis-ready dataset
# ============================================================
# [Clean, restrict, derive; log attrition; write .dta for Stata]

# ============================================================
# 4. Figures
# ============================================================
# [matplotlib figures]

# ============================================================
# 5. Export
# ============================================================
# [parquet/dta objects, savefig figures]
```

---

## Important

- **Reproduce, don't guess.** If the user specifies a variable or sample restriction, apply exactly that.
- **Show your work.** Print summary statistics before building anything — `print(df.describe())`, sample sizes, balance tables.
- **Check for issues.** Look for multicollinearity, outliers, and especially **silently dropped NAs** (`statsmodels` drops incomplete cases by default — log how many).
- **Use relative paths.** All paths relative to repository root (use `pathlib.Path`).
- **No hardcoded values inside the body.** Use module-level constants for sample restrictions, date ranges, cluster vars, etc.
- **Walk through every data step.** After each clean/merge/filter, print `len(df)` and a quick `df.head()` or value-count, so the user can see exactly what survived.

## Long-running steps

For heavy cleans, merges, or simulations that take more than a couple of minutes, launch a background terminal and stream its stdout through the available terminal polling or wait capability. Pattern:

1. Launch `python scripts/python/02_clean.py` in a background terminal and retain the returned session identifier.
2. Poll or wait on that session in intervals no longer than 60 seconds until a milestone fires (for example, `Analysis dataset written`) or the process exits.
3. Continue or course-correct based on what the stream reveals.

This avoids the polling-loop anti-pattern (`sleep 30; check; sleep 30; check`) and avoids burning cache on idle waits.
