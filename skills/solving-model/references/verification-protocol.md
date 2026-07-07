# Verification Protocol

*The check procedures the solving-model workflow runs on every `% VERIFY`-flagged step (Phase 3) and every signed comparative static (Phase 4). Three local checks (A, B, C) run on all flagged steps; the independent `model-verifier` subagent re-derives a user-selected subset. This file defines the three checks, their output formats, the weasel-word scan, and the HALT protocol.*

**Golden rule for numerics:** every arithmetic evaluation runs via `python3 -c "..."`. Never do multi-step arithmetic in-context — LLM mental math is exactly the failure mode this protocol exists to catch.

---

## Check A — Dimensional analysis

Assign each symbol a dimension from the notation table and primitives in `model_setup.tex` (e.g., capital $k$ in goods $[G]$, a rate $r$ dimensionless, a shadow price $\lambda$ in whatever the objective is measured in). Then verify `units(LHS) = units(RHS)` term by term.

- A dimensionless argument to a nonlinear function (exponent, log) must itself be dimensionless.
- Shadow prices inherit units from the constraint they multiply divided by the objective's units; in a risk-neutral profit problem where utils $= [G]$, multipliers on goods-denominated constraints are dimensionless.
- Any additive mismatch (adding a $[G]$ term to a dimensionless term) is a FAIL.

**Output format:**

```
Check A (Dimensional) — Step N: PASS / FAIL
  term 1: [units] ...
  term 2: [units] ...
  LHS units = [...], RHS units = [...] → match / MISMATCH at [term]
```

---

## Check B — Limiting cases

Evaluate the step's result at boundary parameter values and confirm it matches economic intuition. Standard limits to try (pick those meaningful for the model):

- A friction parameter $\to 0$ (constraint vanishes) and $\to$ its upper bound (constraint maximally tight).
- A cost/rate $\to 0$ and $\to \infty$.
- A curvature parameter at the linear boundary (e.g., $\alpha \to 1$ or $\alpha \to 0$ in Cobb-Douglas).

For each limit, state what the expression collapses to and whether that is the economically expected behavior. A limit that produces a nonsensical sign or a blow-up where intuition says finite is a FAIL.

**Output format:**

```
Check B (Limiting cases) — Step N: PASS / FAIL
  [param] → [value]: expression → [collapsed form]; expected [intuition] → match / MISMATCH
  ...
```

---

## Check C — Numerical spot-check

Substitute an admissible parameter vector and confirm both sides of the step's equation agree to machine precision. For an FOC or equilibrium condition, first solve for the consistent endogenous values, then check the residual is ~0.

**Run it in Python — never in-context.** Template:

```bash
python3 -c "
import math
# parameters from the table below
a=0.33; A=1.0; r=0.04; d=0.10
kstar = (a*A/(r+d))**(1/(1-a))          # solve endogenous value first
residual = a*A*kstar**(a-1) - (r+d)     # LHS - RHS of the checked equation
print(f'kstar={kstar:.6f} residual={residual:.2e}')
"
```

PASS if `|residual|` is at the level of floating-point noise (say `< 1e-8`); FAIL otherwise (that is the HALT trigger).

**Output format:**

```
Check C (Numerical) — Step N: PASS / FAIL
  parameters: [the vector used]
  endogenous: [solved values]
  residual: [value] → PASS / FAIL
```

### Example parameter tables for spot-checks

Pick a vector from the row matching the model family, or set your own admissible values (respect every domain in the notation table). These are illustrative starting points, not the only valid choices.

| Model family | Parameters |
|---|---|
| Cobb-Douglas production / investment | $A=1$, $\alpha=0.33$, $\delta=0.10$, $r=0.04$ |
| Collateral / borrowing constraint | above, plus $w=1$, $\theta=0.5$ |
| CRRA consumption-savings | $\beta=0.96$, $\sigma=2$, $r=0.03$, $y=1$ |
| Monopoly / CES demand | elasticity $\varepsilon=3$, marginal cost $c=1$, $A=1$ |
| Trade (fixed export cost) | $\tau=1.2$, $f_x=0.1$, $\sigma=4$, $L=1$ |

Record the exact vector used so it can go into the Phase 5 parameter appendix.

---

## Weasel Word List

Scan the full derivation for phrases that hide an algebra step. Any step containing one of these must be flagged `% VERIFY` regardless of category — and it is a signal to break the step into smaller substeps instead of asserting the result:

- "it follows that"
- "it can be shown"
- "clearly"
- "obviously"
- "trivially"
- "by inspection"
- "straightforward algebra yields" / "after some algebra"
- "evidently" / "as is well known"

Finding one of these is not itself an error, but it means the work was skipped in the write-up — expand it so a checker can follow every operation.

---

## HALT Protocol

Triggered by **any** failure: a FAIL on Check A/B/C, or a **DISAGREE** from the `model-verifier` subagent.

1. **Stop immediately.** Do not run further checks or advance to the next step.
2. **Present side by side** — the original derivation step and the failing check (or the verifier's divergent derivation), so the discrepancy is visible in one view:

   ```
   VERIFICATION FAILURE --- Step N

   ORIGINAL DERIVATION:
   [the step's equation as written]

   FAILING CHECK ([which check]):
   [the failing computation / the verifier's divergent result]
   [parameters or units involved]

   Please adjudicate: Is the original derivation correct, or does it need correction?
   ```

3. **Wait for user adjudication.** The user decides whether the original step or the check is wrong. Do not guess and silently "fix".
4. **If the step is wrong:** back up `derivation.tex` to `derivation.tex.bak` (or `comparative_statics.tex.bak` in Phase 4), apply the correction, and **re-run all three local checks (A, B, C) on the corrected step** before continuing. If the failure was a verifier DISAGREE, also re-dispatch that claim.
5. **If the check is wrong** (e.g., a bad limiting-case intuition or an inadmissible parameter vector): note it, fix the check, and continue — the derivation stands.

Only after all checks pass on the corrected step does the workflow resume.
