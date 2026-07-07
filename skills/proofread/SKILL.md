---
name: proofread
description: Read-only proofreading pass over paper manuscript files (`.tex`, `.md`). Checks grammar, typos, overflow, terminology consistency, and academic writing quality; produces a report without editing. Use when user says "proofread", "check for typos", "look for grammar issues", "copy-edit this", "any writing errors?", or before a paper submission.
argument-hint: "[filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Proofread Manuscript Files

Run the proofreading protocol on paper manuscript files. This produces a report of all issues found WITHOUT editing any source files.

## Steps

1. **Identify files to review:**
   - If `$ARGUMENTS` is a specific filename: review that file only
   - If `$ARGUMENTS` is "all": review all manuscript files (`.tex`, `.md`) in the project

2. **For each file, run a proofreading pass** (optionally via a fresh-context subagent) checking for:

   **GRAMMAR:** Subject-verb agreement, articles (a/an/the), prepositions, tense consistency
   **TYPOS:** Misspellings, search-and-replace artifacts, duplicated words
   **OVERFLOW:** Overfull hbox (LaTeX), lines or tables exceeding page/margin boundaries
   **CONSISTENCY:** Citation format, notation, terminology
   **ACADEMIC QUALITY:** Informal language, missing words, awkward constructions

3. **Produce a detailed report** for each file listing every finding with:
   - Location (line number or slide title)
   - Current text (what's wrong)
   - Proposed fix (what it should be)
   - Category and severity

4. **Save each report** to `quality_reports/`:
   - `quality_reports/FILENAME_report.md`

5. **IMPORTANT: Do NOT edit any source files.**
   Only produce the report. Fixes are applied separately after user review.

6. **Present summary** to the user:
   - Total issues found per file
   - Breakdown by category
   - Most critical issues highlighted
