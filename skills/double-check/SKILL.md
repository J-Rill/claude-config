---
name: double-check
description: "Critical self-review of recent work. Re-reads files just edited or created, verifies referenced symbols/paths/APIs actually exist, runs available static checks, and stress-tests logic against edge cases. Use when the user says \"double check\", \"review your work\", \"are you sure\", \"sanity check this\", or after finishing any non-trivial code change. Reports findings inline as a severity-ranked checklist — does NOT rewrite or refactor without permission."
---

# Double-Check Workflow

Critically review the work you just completed. The goal is to catch what you missed the first time — not to defend what you wrote. Approach this as an adversarial reviewer who assumes the code is wrong until proven otherwise.

**Input:** `$ARGUMENTS` — optional scope hint (e.g., a file path, "the last commit", "the IUCN script"). If empty, target whatever files you edited or created most recently in this conversation.

---

## Core Principles

- **Trust nothing from memory.** Re-read the actual files on disk. Your recollection of what you wrote is unreliable — the file is the source of truth.
- **Verify, don't assume.** If you referenced a function, column, path, flag, or API, prove it exists before declaring the code correct.
- **Be specific, not generic.** "Could have edge cases" is useless. "Line 234 will divide by zero when `n_obs == 0`, which happens for empty Poelen plant batches" is useful.
- **Don't rewrite.** This skill REPORTS findings. Only fix things if the user asks after seeing the report. Premature fixes hide the diagnosis.
- **Report severity honestly.** Don't pad the list with nits to look thorough, and don't downgrade real bugs to look confident.

---

## Workflow

### Phase 1: Scope

State in one line what you're reviewing and why.

- If `$ARGUMENTS` names a target, use that.
- Otherwise, list the files you edited or created in this conversation (check tool history, not memory).
- If nothing is in scope, say so and stop — don't manufacture work.

### Phase 2: Verify recent edits

For each file in scope:

1. **Re-read the full file from disk** (don't rely on the diff or your memory of the edit).
2. Confirm the edit you intended is actually present and complete — no half-applied edits, no leftover stubs, no duplicate blocks from a botched replace.
3. Check that the change matches what the user asked for, not a nearby task you drifted into.

### Phase 3: Hunt hallucinations

For every external reference in the changed code, verify it exists:

- **File paths**: `ls` or `Read` them.
- **Function/class names from other files**: `grep` for the definition.
- **Column names in DataFrames**: confirm against the actual CSV/parquet schema (read the header, or check upstream code).
- **CLI flags / library APIs / env vars**: `--help`, official docs, or grep the library source.
- **Imports**: confirm the module exports what you imported.

Be especially suspicious of:
- APIs you "remember" from training data — version drift is common.
- Magic constants (file paths, IDs, batch numbers) you wrote without checking a source.
- Renamed-but-not-renamed-everywhere variables.

### Phase 4: Run static checks

Run whatever's cheap and available on changed files:

- **Python**: `python -m py_compile <file>`, `ruff check <file>`, `pyright <file>` or `mypy <file>` if configured.
- **R**: `Rscript -e 'parse(file=...)'`, `lintr::lint(...)` if installed.
- **Stata**: no good static checker; instead grep for common typos (`gen` vs `egen`, missing `, replace` on saves).
- **Shell**: `shellcheck` if available.
- **JSON/YAML/TOML**: parse with the appropriate tool.

If a checker isn't installed, say so — don't pretend it passed.

Report each finding with the **exact** line number and error text, not a paraphrase.

### Phase 5: Stress-test logic

Walk through the code with adversarial inputs. For each non-trivial branch ask:

- **Empty inputs**: zero rows, empty string, None, empty list, empty set.
- **Missing data**: NA / NaN / NULL in columns you read.
- **Off-by-one**: loop bounds, slice ends, `range(n)` vs `range(n+1)`, `<` vs `<=`.
- **Type coercion**: int vs str keys, float vs int comparisons, pandas dtype surprises (especially after parquet round-trips).
- **Duplicates**: many-to-many joins, duplicate keys in `set_index`, repeated rows in concatenation.
- **Ordering assumptions**: code that depends on dict/set iteration order or unsorted DataFrame order.
- **Exception paths**: what happens if the API call fails mid-loop? Is partial state written?
- **Concurrency / I/O**: file written and read in the same script — is the order guaranteed?
- **Resource exhaustion**: unbounded growth, memory, API rate limits.

For each issue, write the **specific input that triggers it** and **the line(s) where it fails**.

### Phase 6: Report

Output a single inline checklist, grouped by severity. No file written. Format:

```markdown
## Double-check: <one-line scope>

### Critical (will fail or produce wrong results)
- `path/to/file.py:123` — <specific bug>. Trigger: <input that exposes it>.

### High (likely problem, needs decision)
- `path/to/file.py:45` — <issue>. <Why it's bad / what it costs>.

### Medium (defensible but worth flagging)
- ...

### Nit (style, dead code, minor inconsistency)
- ...

### Verified clean
- <Things you checked that are actually fine — keep this section short, only mention non-obvious checks>
```

If there are zero findings in a section, omit the section.

End the report with one sentence: what (if anything) you'd recommend fixing first. Do **not** start fixing without being asked.

---

## Anti-patterns to avoid

- Don't recap what the code does — the user can read it.
- Don't claim "tested" if you only re-read. Say "static review" or "ran py_compile" — be precise about what verification you actually performed.
- Don't manufacture severity. If everything's fine, the report can be three lines.
- Don't redo Phase 5 if the change is one-line cosmetic — match depth to risk.
- Don't open background tasks or long-running tests unless the user asks. Reviews should be cheap.
