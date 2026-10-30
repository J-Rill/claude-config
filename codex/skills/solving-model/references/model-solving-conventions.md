# Model-Solving Conventions

*LaTeX templates for the solving-model workflow. Every phase reads this file for the format it should write. The templates here are the source of truth; `example-walkthrough.md` shows them filled in on a concrete model (two-period firm with a collateral constraint). Keep the two consistent.*

The `.tex` files each phase writes are **fragments** — no `\documentclass`, no `\begin{document}`. Only `full_model.tex` (the skeleton at the bottom of this file) is standalone-compilable; it `\input{}`s the fragments.

---

## Model Setup template (Phase 1 → `model_setup.tex`)

A setup fragment has six parts, in this order. Every variable used in any equation must appear in the notation table first; every functional form must be stated as a numbered assumption.

```latex
\subsection{Environment}
% One prose paragraph: who the agents are, what they choose, the economic setting.

\subsection{Primitives}
\begin{itemize}
  \item \textbf{Technology}: [production/cost function form]
  \item \textbf{Preferences}: [utility form, discount factor, risk aversion] % omit if no consumers
  \item \textbf{Timing}: [discrete/continuous, horizon, number of periods]
  \item \textbf{Market structure}: [competition, monopoly, bargaining]
  \item \textbf{Information}: [full info, private info, timing of shock realization] % omit if trivial
  \item \textbf{Agents}: [list of decision-makers]
\end{itemize}

\subsection{Timing}
% For dynamic models. A simple itemize is fine for two-period models:
\begin{itemize}
  \item \textbf{Period 1}: [what is chosen / realized]
  \item \textbf{Period 2}: [what is chosen / realized]
\end{itemize}

\subsection{Assumptions}
\paragraph{Assumption A1:} [functional-form or parameter-restriction statement].
\paragraph{Assumption A2:} [...].
% Number sequentially A1, A2, ... so derivation steps can cite them by number.

\subsection{Notation}
\begin{table}[h]
\caption{Model Notation}
\begin{tabular}{llll}
\toprule
Symbol & Name & Type & Domain \\
\midrule
$k$ & Capital & Choice & $\mathbb{R}_+$ \\
% Type is one of: Choice / Parameter / Multiplier / Endogenous
% Every symbol appearing below in any equation must have a row here.
\bottomrule
\end{tabular}
\end{table}

\subsection{Optimization Problem}
\begin{align}
  \max_{[choice vars]} \quad & [objective] \label{eq:objective} \\
  \text{s.t.} \quad & [constraint 1] \label{eq:budget} \\
  & [constraint 2] \label{eq:collateral} \\
  & [non-negativity] \notag
\end{align}
```

**Why this order:** notation before equations means the reader never meets an undefined symbol; numbered assumptions give the derivation something to cite ("by A1"); labeled `align` lines let later steps reference constraints with `\eqref{}`.

---

## Derivation Step Format (Phase 2 → `derivation.tex`)

One algebraic operation per step. Each step is a `\paragraph{Step N:}` header, an `\textit{Operation:}` line stating what is being done and citing its sources, display math in `align`, and an **optional** `\textit{Simplification:}` block when the raw result needs collecting/rearranging.

```latex
\paragraph{Step N: [short description of the operation]} % VERIFY  <- add marker only if non-trivial
\textit{Operation: [what you are doing, citing sources by step/equation number, e.g. "Differentiate \eqref{eq:lagrangian} w.r.t. $k$ and set to zero."]}

\begin{align}
  [the result of this one operation] \label{eq:foc-k}
\end{align}

\textit{Simplification: [what algebra is being applied, e.g. "Collect $\mu$ terms: $-\mu + \mu\theta = -\mu(1-\theta)$."]}

\begin{align}
  [the simplified result] \label{eq:euler}
\end{align}
```

Rules:
- **Reference every substitution** by source: "Substitute $\lambda$ from Step 3 \eqref{eq:lambda}", never a bare "substitute $\lambda$".
- **Substeps** (Step 4a, 4b, ...) when one operation needs more than a single line of algebra.
- Append `% VERIFY` to the `\paragraph` line for any step matching the non-trivial categories in `phase-2-derivation.md` (sign claims, theorem applications, multi-step simplifications, case analysis, limits, existence/uniqueness). The weasel-word scan in `verification-protocol.md` can add more.

---

## Verification Log Format (Phase 3 → `verification_log.tex`)

One block per flagged step, with **all four rows always shown**. Steps not sent to the verifier subagent use `NOT SELECTED` in the Verifier row — the row is never omitted, so the reader can see coverage at a glance.

```latex
\paragraph{Verification: Step N}
\begin{itemize}
  \item \textbf{Dimensional}: PASS / FAIL --- [units(LHS) vs units(RHS); which primitives supplied the units]
  \item \textbf{Limiting cases}: PASS / FAIL --- [boundary values tried and whether they match economic intuition]
  \item \textbf{Numerical}: PASS / FAIL --- [parameters used; residual from the python3 check]
  \item \textbf{Verifier}: AGREE / DISAGREE / NOT SELECTED --- [if AGREE, note any implicit assumptions the verifier used; if DISAGREE, this triggered the HALT protocol]
\end{itemize}
```

The four rows correspond one-to-one to Check A (Dimensional), Check B (Limiting cases), Check C (Numerical) in `verification-protocol.md`, plus the independent re-derivation by the `model_verifier` subagent (Verifier).

The checkpoint summary table has one row per step:

```
Step | Dimensional | Limiting | Numerical | Verifier | Overall
```

---

## Comparative Statics table format (Phase 4 → `comparative_statics.tex`)

Each comparative static is derived in the Derivation Step Format above (with `% VERIFY` on the sign), then all pairs are collected into one summary table. Include every parameter-variable pair, including sign $=0$ cases (e.g., first-best variables that do not depend on a friction parameter).

```latex
\begin{table}[h]
\caption{Comparative Statics Summary}
\begin{tabular}{llclp{6cm}}
\toprule
Parameter & Variable & Sign & Condition & Intuition \\
\midrule
$\theta$ $\uparrow$ & $k$ & $+$ & Constrained & More pledgeable capital $\to$ more borrowing $\to$ more investment \\
$\theta$ $\uparrow$ & $k$ & $0$ & Unconstrained & First-best set by $r+\delta$, not $\theta$ \\
\bottomrule
\end{tabular}
\end{table}
```

Wrap in `\resizebox{1\linewidth}{!}{}` only if the table is too wide (many columns or long intuition strings).

---

## `full_model.tex` skeleton (Phase 5)

The only compilable file. It `\input{}`s the four phase fragments in order. Compile with `cd "$WORKING_DIR" && xelatex full_model.tex` (three passes for the table of contents / cross-references), because the `\input{}` paths are relative to the working directory.

```latex
\documentclass[12pt]{article}
\usepackage{amsmath,amssymb,amsthm,booktabs,graphicx,hyperref}
% See latex-research.md for the macro block and any extra packages.

\title{Model: [Model Name] \\ \large Derivation and Verification Document}
\author{[User Name] \\ \small Generated with Codex + independent verifier subagent}
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
% Table: Parameter | Value | Source, for every value used in Phase 3 spot-checks.

\section{Verifier Session Summaries}
% For each verifier dispatch: what was sent (setup review / N claims / N sign claims)
% and the overall verdict (all AGREE / N disagreements resolved).

\end{document}
```
