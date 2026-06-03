---
name: data-analysis
description: "End-to-end Python data analysis pipeline — exploration → cleaning → regression → publication-ready tables and figures. Use when user says \"analyze this dataset\", \"run a regression on X\", \"explore this CSV\", \"full analysis workflow\", \"get me summary stats and a regression\", or points at a `.csv`/`.parquet`/`.dta` and asks for empirical results. Produces numbered Python scripts in `scripts/python/` and outputs to `scripts/python/_outputs/`."
---

# Data Analysis Workflow

Run an end-to-end data analysis in Python: load, explore, analyze, and produce publication-ready output.

**Input:** `$ARGUMENTS` — a dataset path (e.g., `data/county_panel.csv`) or a description of the analysis goal (e.g., "regress wages on education with state fixed effects using CPS data").

---

## Constraints

- **Follow Python code conventions** in `.claude/rules/python-code-conventions.md` if present
- **Save all scripts** to `scripts/python/` with descriptive numbered names (`01_load.py`, `02_clean.py`, ...)
- **Save all outputs** (figures, tables, pickled objects, parquet) to `output/`
- **Pickle every key object** (regression results, summary tables, processed DataFrames) — downstream notebooks or slides may need them. For large DataFrames prefer parquet.
- **Use project theme** for all figures (check for custom matplotlib rcParams in `.claude/rules/`)
- **Run the `/double-check` skill** on the generated script before presenting results

---

## Workflow Phases

### Phase 0: Pre-Flight Report

**Before writing any analysis code, produce a Pre-Flight Report** showing you read the inputs. This prevents the common failure mode where the agent hallucinates variable names or skips project conventions.

Output block (in your response to the user, before Phase 1):

```markdown
## Pre-Flight Report

**Dataset:** [path]
- Variables found: [list from df.columns.tolist()]
- Rows: [len(df)]
- Key dtypes: [e.g., "outcome=float64, treatment=int8, state=category"]
- Missing-data summary: [% missing per key var via df.isna().mean()]

**Project conventions read:**
- `.claude/rules/python-code-conventions.md` — [one-line summary of most relevant rule, if file exists]
- `.claude/rules/content-invariants.md` — [INV-9, INV-10, INV-11, INV-12 applicable, if file exists]

**Task interpretation:** [one sentence restating what the user asked for]

**Plan:** [3-5 bullet outline of the Python script structure]
```

If any input cannot be read (missing file, unreadable format), stop and ask the user before proceeding.

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

Save all diagnostic figures to `output/diagnostics/`.

### Phase 3: Main Analysis

Based on the research question:
- **OLS / GLM:** `statsmodels.formula.api.ols` (formula syntax) or `statsmodels.api.OLS` (array interface)
- **Fixed effects / panel:** `pyfixest.feols` (Python port of R `fixest`, supports clustering, IV, multiway FEs) — preferred for any spec with `|` fixed effects. `linearmodels.PanelOLS` is the alternative.
- **Standard errors:** Cluster at the appropriate level (document why).
  - statsmodels: `.fit(cov_type="cluster", cov_kwds={"groups": df["cluster_var"]})`
  - pyfixest: `vcov={"CRV1": "cluster_var"}`
- **Multiple specifications:** Start simple, progressively add controls. Pyfixest's stepwise sugar (`csw(.)` / `sw(.)`) is helpful.
- **Effect sizes:** Report standardized effects alongside raw coefficients.

### Phase 4: Publication-Ready Output

**Tables:**
- Use `pyfixest.etable()` for regression tables (preferred when models are pyfixest objects) or `stargazer` (Python package) for statsmodels output
- Include all standard elements: coefficients, SEs, significance stars, N, R-squared
- Export as `.tex` for LaTeX inclusion and `.html` for quick viewing

**Figures:**
- Use `matplotlib` (with `seaborn` for higher-level wrappers when helpful)
- Pass `transparent=True` to `plt.savefig` for Beamer compatibility
- Include proper axis labels (sentence case, units)
- Set figure size explicitly: `fig, ax = plt.subplots(figsize=(X, Y))`
- Save as both `.pdf` and `.png`:
  ```python
  for ext in ("pdf", "png"):
      fig.savefig(OUT / f"figure_name.{ext}", bbox_inches="tight", transparent=True, dpi=200)
  ```

### Phase 5: Save and Review

1. Pickle (or parquet for DataFrames) every key object: regression results, summary tables, processed data.
   - `with open(OUT / "model_results.pkl", "wb") as f: pickle.dump(results, f)`
   - `df_clean.to_parquet(OUT / "df_clean.parquet")`
2. Create `output/` subdirectories as needed: `Path("output/analysis").mkdir(parents=True, exist_ok=True)`.
3. Run the `/double-check` skill on the generated script.
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
Outputs: [Figures, tables, pickle/parquet files]
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
import statsmodels.formula.api as smf
import pyfixest as pf  # only if using FE / panel specs
from stargazer.stargazer import Stargazer  # only if using statsmodels tables

np.random.seed(20260415)  # YYYYMMDD

OUT = Path("output/analysis")
OUT.mkdir(parents=True, exist_ok=True)

# ============================================================
# 1. Data Loading
# ============================================================
# [Load and clean data]

# ============================================================
# 2. Exploratory Analysis
# ============================================================
# [Summary stats, diagnostic plots]

# ============================================================
# 3. Main Analysis
# ============================================================
# [Regressions, estimation]

# ============================================================
# 4. Tables and Figures
# ============================================================
# [Publication-ready output]

# ============================================================
# 5. Export
# ============================================================
# [pickle/parquet objects, savefig figures]
```

---

## Important

- **Reproduce, don't guess.** If the user specifies a regression, run exactly that.
- **Show your work.** Print summary statistics before jumping to regression — `print(df.describe())`, sample sizes, balance tables.
- **Check for issues.** Look for multicollinearity, outliers, perfect prediction, and especially **silently dropped NAs** (pyfixest and statsmodels both drop incomplete cases by default — log how many).
- **Use relative paths.** All paths relative to repository root (use `pathlib.Path`).
- **No hardcoded values inside the body.** Use module-level constants for sample restrictions, date ranges, cluster vars, etc.
- **Walk through every data step.** After each clean/merge/filter, print `len(df)` and a quick `df.head()` or value-count, so the user can see exactly what survived.

## Long-running fits: use the Monitor tool

For regressions, simulations, or bootstrap loops that take more than a couple of minutes, launch via Bash with `run_in_background: true` and then use Anthropic's **Monitor tool** to stream Python stdout into the conversation in real time. Pattern:

1. Background-launch: `python scripts/python/03_analyze.py` with `run_in_background: true`. Capture the `bash_id`.
2. Use Monitor on the `bash_id` until a milestone fires (e.g., `Coefficients table written`, or process exit).
3. Continue or course-correct based on what the stream reveals.

This avoids the polling-loop anti-pattern (`sleep 30; check; sleep 30; check`) and avoids burning cache on idle waits.
