# LaTeX Conventions for Research Write-ups

*General formatting conventions for the assembled `full_model.tex` (Phase 5). Generic and minimal — this is for an economist who writes LaTeX occasionally, not a house style. No institutional palette, no Beamer/slide specifics.*

## Packages

A small standard set covers everything the workflow produces:

```latex
\usepackage{amsmath,amssymb,amsthm}   % align, \mathbb, theorem environments
\usepackage{booktabs}                  % \toprule / \midrule / \bottomrule
\usepackage{graphicx}                  % \resizebox for wide tables, figures
\usepackage{hyperref}                  % \autoref, clickable cross-references
```

Add a package only when a compile error asks for it (e.g., `siunitx` for aligned numeric columns). Do not preload packages you are not using.

## Macros for common operators

Define these once in the preamble so notation is consistent and equations read cleanly. Keep the set small — only macros the document actually uses:

```latex
\newcommand{\E}{\mathbb{E}}                       % expectation
\newcommand{\R}{\mathbb{R}}                        % reals
\newcommand{\diff}[2]{\frac{\partial #1}{\partial #2}}  % \diff{k}{\theta}
\newcommand{\Lag}{\mathcal{L}}                     % Lagrangian
\DeclareMathOperator*{\argmax}{arg\,max}
\DeclareMathOperator*{\argmin}{arg\,min}
```

Use a macro wherever the operator recurs — do not hand-write `\frac{\partial ...}{\partial ...}` in some places and `\diff{}{}` in others.

## Equation numbering and labels

- Use `align` for multi-line derivations; number the lines that later steps or the text refer to, and `\notag` the purely intermediate ones.
- Label with a typed prefix: `\label{eq:...}`, `\label{tab:...}`, `\label{fig:...}`. Reference with `\autoref{}` (it prints "Equation 3", "Table 2" automatically) rather than a bare `\ref{}`.
- For long multi-line derivations, `\allowdisplaybreaks` in the preamble lets `align` blocks break across pages.

## Notation consistency

- A symbol means one thing throughout — do not reuse a letter for two objects. The notation table in `model_setup.tex` is the single source of truth; every symbol in the document should match it.
- Keep decorations consistent: if equilibrium capital is $k^*$ once, it is $k^*$ everywhere (not $k^{*}$ vs $\hat{k}$).

## Figures and tables

- `booktabs` rules only — `\toprule`, `\midrule`, `\bottomrule`. No vertical rules, no `\hline`.
- Wrap a table in `\resizebox{1\linewidth}{!}{...}` only when it genuinely overflows the text width (many columns or long text cells); do not shrink tables that already fit.
- Give every float a `\caption{}` and a `\label{}`, and refer to it by `\autoref{}` in the text so the reader is told where to look.
