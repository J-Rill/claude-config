# Phase 5: Documentation & Compilation

**Goal:** Assemble all phase outputs into a single compilable LaTeX document.

## Prerequisites

- Read `~/.claude/preferences/model-solving-conventions.md` for the `full_model.tex` skeleton.
- Read `~/.claude/preferences/latex-research.md` for formatting conventions.

## Inputs

- `$MODEL_NAME` — the model name
- `$WORKING_DIR` — path to `solving_models/[name]/`
- `$WORKING_DIR/model_setup.tex` — Phase 1 output
- `$WORKING_DIR/derivation.tex` — Phase 2 output
- `$WORKING_DIR/verification_log.tex` — Phase 3 output
- `$WORKING_DIR/comparative_statics.tex` — Phase 4 output

## Step 1: Assemble `full_model.tex`

Use the skeleton from `model-solving-conventions.md`:

```latex
\documentclass[12pt]{article}
\usepackage{amsmath,amssymb,amsthm,booktabs,graphicx,hyperref}

\title{Model: [Model Name] \\ \large Derivation and Verification Document}
\author{[User Name] \\ \small Generated with Claude Code + Oracle verification}
\date{\today}

\begin{document}
\maketitle
\tableofcontents

\section{Model Environment}
\input{model_setup.tex}

\section{Derivation}
\input{derivation.tex}

\section{Verification Log}
\input{verification_log.tex}

\section{Comparative Statics}
\input{comparative_statics.tex}

\appendix
\section{Parameter Values Used in Numerical Checks}
[Table of all parameter values used in spot-checks, with sources]

\section{Oracle Session Transcripts}
[Summary of each Oracle call: slug, what was sent, verdict summary]

\end{document}
```

Fill in:
- `[Model Name]` from `$MODEL_NAME`
- `[User Name]` — use the user's name if known, otherwise "Author"
- **Parameter appendix:** Collect all parameter values used in Phase 3 numerical checks. Present as a table with Parameter | Value | Source columns.
- **Oracle appendix:** For each Oracle call, summarize: (1) the slug/session ID, (2) what was sent (setup review / N claims for re-derivation / N sign claims), (3) overall verdict (all agreed / N disagreements resolved).

## Step 2: Apply formatting conventions

Read `~/.claude/preferences/latex-research.md` and apply:

- **Wide tables:** Wrap in `\resizebox{1\linewidth}{!}{}` (only when needed — comparative statics table with many columns, or parameter table with long source strings)
- **Table style:** `booktabs` throughout (`\toprule`, `\midrule`, `\bottomrule`)
- **Cross-references:** Use `\autoref{}` for figures, tables, and sections (e.g., `\autoref{eq:euler}`, `\autoref{tab:comp-statics}`)
- **Labels:** Ensure all equations have `\label{eq:...}` and all tables have `\label{tab:...}`

## Step 3: Compile

**Must `cd` to the working directory** before compiling, because `\input{}` paths are relative:

```bash
cd "$WORKING_DIR" && xelatex full_model.tex && xelatex full_model.tex && xelatex full_model.tex
```

If the document contains citations (`\cite{}`), use the full pipeline:
```bash
cd "$WORKING_DIR" && xelatex full_model.tex && bibtex full_model && xelatex full_model.tex && xelatex full_model.tex
```

**Only compile `full_model.tex`.** The per-phase `.tex` files are fragments without `\documentclass` and are not standalone-compilable.

### Handling compilation errors

- **Missing package:** Add the missing `\usepackage{}` to `full_model.tex` and retry.
- **Undefined reference:** Check that all `\label{}` and `\ref{}`/`\autoref{}` match. Fix and retry.
- **Overfull hbox:** Usually from wide equations. Consider adding `\allowdisplaybreaks` or splitting long equations.
- **Persistent errors:** Show the error log to the user and ask for guidance.

## Step 4: Present final document

Show the user:
1. The path to the compiled PDF: `$WORKING_DIR/full_model.pdf`
2. A brief summary of what the document contains:
   - Number of assumptions
   - Number of derivation steps (total and flagged)
   - Verification results (N checks run, all passed / N issues resolved)
   - Number of comparative statics derived

## Output

- `$WORKING_DIR/full_model.tex` — the assembled document
- `$WORKING_DIR/full_model.pdf` — the compiled PDF
- Return control to the orchestrator with status: `COMPILED` or `COMPILATION_FAILED`
