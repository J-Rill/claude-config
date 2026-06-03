# Example Walkthrough: Two-Period Firm with Collateral Constraint

*This file shows the expected output of each phase for a simple model. Read it on first invocation to understand the concrete output pattern. For subsequent invocations, follow `model-solving-conventions.md` templates directly.*

---

## Phase 1 Output: `model_setup.tex`

```latex
\subsection{Environment}

A firm lives for two periods. In period 1, it has initial wealth $w$ and chooses capital $k$ for production in period 2. It can borrow $b$ at exogenous interest rate $r$, subject to a collateral constraint: at most fraction $\theta$ of capital can be pledged.

\subsection{Primitives}

\begin{itemize}
  \item \textbf{Technology}: $f(k) = Ak^\alpha$, $\alpha \in (0,1)$
  \item \textbf{Timing}: Two periods, no intra-period discounting
  \item \textbf{Market structure}: Firm is a price-taker; $r$ exogenous
  \item \textbf{Agents}: Single representative firm
\end{itemize}

\subsection{Assumptions}

\paragraph{Assumption A1:} Production is Cobb-Douglas: $f(k) = Ak^\alpha$, $\alpha \in (0,1)$.

\paragraph{Assumption A2:} The firm can pledge at most fraction $\theta \in [0,1]$ of capital as collateral: $b \leq \theta k$.

\paragraph{Assumption A3:} Capital depreciates at rate $\delta \in [0,1]$ between periods.

\paragraph{Assumption A4:} The interest rate $r > 0$ is exogenous (small open economy or partial equilibrium).

\subsection{Notation}

\begin{table}[h]
\caption{Model Notation}
\begin{tabular}{llll}
\toprule
Symbol & Name & Type & Domain \\
\midrule
$k$ & Capital & Choice & $\mathbb{R}_+$ \\
$b$ & Borrowing & Choice & $\mathbb{R}_+$ \\
$w$ & Initial wealth & Parameter & $\mathbb{R}_{++}$ \\
$\theta$ & Pledgeability & Parameter & $[0,1]$ \\
$r$ & Interest rate & Parameter & $\mathbb{R}_{+}$ \\
$A$ & Productivity & Parameter & $\mathbb{R}_{++}$ \\
$\alpha$ & Capital share & Parameter & $(0,1)$ \\
$\delta$ & Depreciation & Parameter & $[0,1]$ \\
$\lambda$ & Shadow price of budget & Multiplier & $\mathbb{R}_+$ \\
$\mu$ & Shadow price of collateral & Multiplier & $\mathbb{R}_+$ \\
\bottomrule
\end{tabular}
\end{table}

\subsection{Optimization Problem}

\begin{align}
  \max_{k, b} \quad & \pi = Ak^\alpha + (1-\delta)k - (1+r)b \label{eq:objective} \\
  \text{s.t.} \quad & k = w + b \label{eq:budget} \\
  & b \leq \theta k \label{eq:collateral} \\
  & k \geq 0, \; b \geq 0 \notag
\end{align}
```

**Why this format:** Every variable appears in the notation table before it's used in equations. Assumptions are numbered so derivation steps can reference them. The optimization problem uses labeled `align` for cross-referencing.

---

## Phase 2 Output: `derivation.tex`

```latex
\paragraph{Step 1: Form the Lagrangian}
\textit{Operation: Write the Lagrangian with multiplier $\lambda$ on the budget constraint \eqref{eq:budget} and $\mu$ on the collateral constraint \eqref{eq:collateral}.}

\begin{align}
  \mathcal{L} = Ak^\alpha + (1-\delta)k - (1+r)b
    + \lambda(w + b - k) + \mu(\theta k - b) \label{eq:lagrangian}
\end{align}

\paragraph{Step 2: FOC with respect to $k$} % VERIFY
\textit{Operation: Differentiate \eqref{eq:lagrangian} with respect to $k$ and set equal to zero.}

\begin{align}
  \frac{\partial \mathcal{L}}{\partial k} = \alpha A k^{\alpha-1}
    + (1-\delta) - \lambda + \mu\theta = 0 \label{eq:foc-k}
\end{align}

\paragraph{Step 3: FOC with respect to $b$}
\textit{Operation: Differentiate \eqref{eq:lagrangian} with respect to $b$ and set equal to zero.}

\begin{align}
  \frac{\partial \mathcal{L}}{\partial b} = -(1+r) + \lambda - \mu = 0 \label{eq:foc-b}
\end{align}

\textit{Simplification: Solve for $\lambda$.}

\begin{align}
  \lambda = (1+r) + \mu \label{eq:lambda}
\end{align}

\paragraph{Step 4: Substitute $\lambda$ into capital FOC} % VERIFY
\textit{Operation: Substitute $\lambda = (1+r) + \mu$ from Step 3 \eqref{eq:lambda} into Step 2 \eqref{eq:foc-k}.}

\begin{align}
  \alpha A k^{\alpha-1} + (1-\delta) - (1+r) - \mu + \mu\theta = 0
\end{align}

\textit{Simplification: Rearrange and collect $\mu$ terms: $(1-\delta) - (1+r) = -(r+\delta)$ and $-\mu + \mu\theta = -\mu(1-\theta)$.}

\begin{align}
  \alpha A k^{\alpha-1} = (r + \delta) + \mu(1-\theta) \label{eq:euler}
\end{align}

\paragraph{Step 5: Case analysis on the collateral constraint} % VERIFY
\textit{Operation: Apply complementary slackness: either $\mu = 0$ (not binding) or $b = \theta k$ (binding).}

\textit{Case (a): Constraint not binding ($\mu = 0$).}

\begin{align}
  \alpha A k^{*\alpha-1} = r + \delta \label{eq:first-best}
\end{align}

This is the frictionless first-best: MPK equals user cost of capital (by A1, A4).

\begin{align}
  k^* = \left(\frac{\alpha A}{r + \delta}\right)^{\frac{1}{1-\alpha}} \label{eq:kstar}
\end{align}

\textit{Case (b): Constraint binding ($\mu > 0$, $b = \theta k$).}

From budget constraint \eqref{eq:budget}: $k = w + b = w + \theta k$, so:

\begin{align}
  k^c = \frac{w}{1-\theta} \label{eq:kconstrained}
\end{align}

The firm is constrained iff $k^c < k^*$, i.e., $\frac{w}{1-\theta} < \left(\frac{\alpha A}{r+\delta}\right)^{1/(1-\alpha)}$.
```

**Why `% VERIFY` on Steps 2, 4, 5:** Step 2 is a differentiation (sign-sensitive). Step 4 is a multi-term substitution and simplification. Step 5 involves a sign determination ($\mu > 0$ implies undercapitalization) and a claim about the first-best benchmark.

---

## Phase 3 Output: `verification_log.tex` (excerpt)

### Complete verification for Step 2 (FOC w.r.t. $k$):

```latex
\paragraph{Verification: Step 2}
\begin{itemize}
  \item \textbf{Dimensional check}: PASS
    \begin{itemize}
      \item $\alpha A k^{\alpha-1}$: [dimensionless] $\times$ [$G$] $\times$ [$G^{\alpha-1}$] = [$G^\alpha / G^{1-\alpha}$]... Since $f(k) = Ak^\alpha$ maps $[G] \to [G]$ and $\alpha$ is dimensionless, $f'(k)$ has units $[G/G]$ = [dimensionless]. \checkmark
      \item $(1-\delta)$: [dimensionless]. \checkmark
      \item $\lambda$: shadow price of budget constraint in goods = [utils/$G$], but in a risk-neutral profit-max problem, utils = $G$, so $\lambda$ is [dimensionless]. \checkmark
      \item $\mu\theta$: $\mu$ is shadow price of collateral constraint (same units as $\lambda$) $\times$ $\theta$ [dimensionless] = [dimensionless]. \checkmark
      \item All terms dimensionless. LHS = RHS. PASS.
    \end{itemize}
  \item \textbf{Limiting cases}: PASS
    \begin{itemize}
      \item $\theta \to 0$: Collateral constraint becomes $b \leq 0$, so $b = 0$, $k = w$. FOC reduces to $\alpha A k^{\alpha-1} + (1-\delta) - \lambda = 0$. Consistent: with no borrowing, $\lambda$ adjusts. \checkmark
      \item $\theta \to 1$: Full pledgeability. Constraint $b \leq k$ is slack for most $w$ (firm can borrow up to $k$). FOC unchanged in form. \checkmark
    \end{itemize}
  \item \textbf{Numerical spot-check}: PASS
    \begin{itemize}
      \item Parameters: $A=1, \alpha=0.33, \delta=0.1, r=0.04$. At unconstrained optimum ($\mu=0$): $k^* = (0.33/0.14)^{1/0.67}$.
      \item Python verification:
      \begin{verbatim}
python3 -c "
import math
a=0.33; A=1; r=0.04; d=0.1
kstar = (a*A/(r+d))**(1/(1-a))
foc = a*A*kstar**(a-1) + (1-d) - (1+r)
print(f'kstar={kstar:.6f} FOC_residual={foc:.2e}')
"
      \end{verbatim}
      Output: \texttt{kstar=3.420578 FOC\_residual=0.00e+00}. PASS.
    \end{itemize}
  \item \textbf{Oracle re-derivation}: AGREE --- Oracle independently derived the same FOC from the Lagrangian. No implicit assumptions beyond A1--A4.
\end{itemize}
```

### Verification for Step 4 (not selected for Oracle):

```latex
\paragraph{Verification: Step 4}
\begin{itemize}
  \item \textbf{Dimensional check}: PASS --- All terms dimensionless (same units as Step 2).
  \item \textbf{Limiting cases}: PASS --- As $\mu \to 0$: reduces to $\alpha A k^{\alpha-1} = r + \delta$ (first-best). As $\theta \to 1$: wedge $\mu(1-\theta) \to 0$, constraint becomes non-distortionary. Both match intuition.
  \item \textbf{Numerical spot-check}: PASS --- At $k=3.42, \mu=0$: LHS $= 0.33 \times 3.42^{-0.67} = 0.140$. RHS $= 0.04 + 0.10 + 0 = 0.140$. Diff $= 0.00\text{e+00}$.
  \item \textbf{Oracle re-derivation}: NOT SELECTED
\end{itemize}
```

### HALT protocol example (hypothetical failure):

If a numerical check had failed, the output would be:

```
  VERIFICATION FAILURE --- Step 4

  ORIGINAL DERIVATION:
  alpha * A * k^{alpha-1} = (r + delta) + mu*(1 - theta)

  FAILING CHECK (Numerical spot-check):
  LHS = 0.140000, RHS = 0.150000, DIFF = 1.00e-02
  Parameters: A=1, alpha=0.33, k=3.42, r=0.04, delta=0.1, mu=0.01, theta=0.5

  Please adjudicate: Is the original derivation correct, or does it need correction?
```

The workflow stops here and waits for user input.

---

## Phase 4 Output: `comparative_statics.tex` (excerpt)

```latex
\paragraph{Comparative static: $\partial k / \partial \theta$ when constrained}
\textit{Operation: Differentiate $k^c = w/(1-\theta)$ from \eqref{eq:kconstrained} with respect to $\theta$.}

\begin{align}
  \frac{\partial k^c}{\partial \theta} = \frac{w}{(1-\theta)^2} > 0
\end{align}

\textit{Intuition:} Higher pledgeability allows more borrowing against each unit of capital, increasing total investment.

\paragraph{Comparative static: $\partial k / \partial w$ when constrained}
\textit{Operation: Differentiate $k^c = w/(1-\theta)$ from \eqref{eq:kconstrained} with respect to $w$.}

\begin{align}
  \frac{\partial k^c}{\partial w} = \frac{1}{1-\theta} > 1 \quad \text{for } \theta > 0
\end{align}

\textit{Intuition:} The collateral multiplier --- each dollar of wealth supports $1/(1-\theta)$ dollars of capital.

\begin{table}[h]
\caption{Comparative Statics Summary}
\begin{tabular}{llclp{6cm}}
\toprule
Parameter & Variable & Sign & Condition & Intuition \\
\midrule
$\theta$ $\uparrow$ & $k$ & $+$ & Constrained & More pledgeable capital $\to$ more borrowing $\to$ more investment \\
$\theta$ $\uparrow$ & $k$ & $0$ & Unconstrained & First-best determined by $r+\delta$, not $\theta$ \\
$w$ $\uparrow$ & $k$ & $+$ ($>1$) & Constrained & Wealth relaxes constraint with leverage \\
$w$ $\uparrow$ & $k$ & $0$ & Unconstrained & First-best determined by $r+\delta$, not $w$ \\
$A$ $\uparrow$ & $k^*$ & $+$ & Unconstrained & Higher productivity raises optimal scale \\
$r$ $\uparrow$ & $k^*$ & $-$ & Unconstrained & Higher cost of capital reduces optimal scale \\
\bottomrule
\end{tabular}
\end{table}
```
