---
paths:
  - "**/*.do"
  - "**/*.tex"
  - "**/*.py"
  - "**/*.R"
---

# Regression / table output format

Applies whenever generating regression or summary tables destined for LaTeX
(Stata `esttab`/`estout`, Python exports, or a hand-written `.tex` fragment).

- For tables that get dropped into LaTeX, export **rows only** — no column
  headers, rules, or panel titles. Those live in the `.tex` wrapper, added via
  `\ExpandableInput{...}` inside a `tabular*` environment.
- Each row: row label, then `&`-separated cells, ending in `\\`. Example:
  ```
  Time FE             &         1.8&           3\\
  Individual FE       &        47.2&        52.3\\
  Time + Individual FE&        47.8&          54\\
  Unique Respondents  &       15443&       15458\\
  ```
- Write to a plain `.tex` fragment (e.g. `tables/<name>.tex`) — just the rows.
- Keep numeric formatting consistent within a table (don't mix `0.472` and
  `47.2%` in one column).
- Standard errors in parentheses on the row below the coefficient, same format.
- Every number comes from a generated output file — never hand-type a coefficient
  into the `.tex`.
