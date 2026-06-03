# Oracle Prompt Templates for solving-model

*Read this file before making any Oracle call in the solving-model workflow. Each template uses a standardized structure: role preamble, MODEL SETUP section, TASK section, OUTPUT FORMAT section. Placeholders use `[ALL_CAPS_WITH_UNDERSCORES]`.*

---


## 1. Setup Review (Phase 1)

**When to use:** After writing `model_setup.tex`, before the Phase 1 checkpoint.

**Prompt:**

```
You are a mathematical economist reviewing the formal setup of an economic model. Your role is to find errors, gaps, and insufficient assumptions — not to rewrite the model.

--- MODEL SETUP ---
[MODEL_SETUP_CONTENTS]

--- TASK ---
1. Check internal consistency: Are all variables defined before use? Are constraints compatible with the choice set? Is the timing coherent across agents?
2. Check completeness: Are there missing market-clearing conditions? Missing budget constraints? Undefined prices or quantities? Variables that appear in equations but not in the notation table?
3. Check sufficient conditions: Are the functional-form assumptions sufficient for existence and uniqueness of equilibrium? If not, state precisely what additional assumption is needed.
4. Suggest standard simplifications from the literature that the author may want to consider, but do not impose them.

--- OUTPUT FORMAT ---
For each issue found, state:
- ISSUE [number]: [one-line summary]
- Location: [equation/assumption number]
- Severity: CRITICAL (blocks derivation) / WARNING (may cause problems) / SUGGESTION (optional improvement)
- Details: [explanation]

If no issues are found, state: "NO ISSUES FOUND — setup is internally consistent and complete."
```

**Oracle CLI invocation:**

```bash
npx -y @steipete/oracle --engine browser --model gpt-5.4-pro \
  --browser-manual-login --browser-input-timeout 300s \
  --slug "[MODEL_NAME]-setup-review" \
  -p "[PROMPT_TEXT]" \
  --file "[PATH_TO_MODEL_SETUP_TEX]"
```

---

## 2. Blind Re-derivation (Phase 3)

**When to use:** For user-selected critical steps during verification. Oracle receives the model setup but **NOT** the derivation — it must derive independently.

**Prompt:**

```
You are independently verifying mathematical derivations in an economic model. You have NOT seen the author's derivation. You must derive each result yourself from first principles.

--- MODEL SETUP ---
[MODEL_SETUP_CONTENTS]

--- TASK ---
For each claim below, independently derive the result starting ONLY from the model setup above. Show every algebraic step — one operation per line. Do not skip steps or write "it follows that."

[CLAIMS_LIST]

For each claim:
1. Derive the result independently. Show every step with the operation described in words.
2. State: AGREE or DISAGREE.
3. If DISAGREE: identify the exact step where your derivation diverges from the claim. Present both paths side by side.
4. If AGREE: note any implicit assumptions you used that are not in the model setup.

--- OUTPUT FORMAT ---
For each claim:
CLAIM [N]: [one-line restatement]
DERIVATION:
  Step 1: [operation] → [result]
  Step 2: [operation] → [result]
  ...
VERDICT: AGREE / DISAGREE
[If DISAGREE]:
  DIVERGENCE POINT: Step [X]
  AUTHOR'S PATH: [expression]
  MY PATH: [expression]
  EXPLANATION: [why they differ]
[If AGREE]:
  IMPLICIT ASSUMPTIONS: [list, or "None beyond stated assumptions"]
```

**Oracle CLI invocation:**

```bash
npx -y @steipete/oracle --engine browser --model gpt-5.4-pro \
  --browser-manual-login --browser-input-timeout 300s \
  --slug "[MODEL_NAME]-rederivation" \
  -p "[PROMPT_TEXT]" \
  --file "[PATH_TO_MODEL_SETUP_TEX]"
```

**Important:** Do NOT attach or include `derivation.tex`. The entire point is blind re-derivation.

**Claims list format** (max 5 per call; split into multiple calls if needed):

```
Claim 1: Starting from the Lagrangian (Assumption A1, A2), the FOC w.r.t. k yields:
  [equation from Step N]

Claim 2: Substituting the FOC w.r.t. b (Step 3) into the FOC w.r.t. k (Step 2) yields:
  [equation from Step M]
```

---

## 3. Comparative Statics Verification (Phase 4)

**When to use:** After deriving comparative statics, before the Phase 4 checkpoint. Batch all sign claims into one call (max 5 per call; split if more).

**Prompt:**

```
You are verifying comparative statics claims for an economic model. Independently derive and sign each partial derivative.

--- MODEL SETUP ---
[MODEL_SETUP_CONTENTS]

--- EQUILIBRIUM CONDITIONS ---
[KEY_EQUILIBRIUM_EQUATIONS]

--- TASK ---
For each sign claim below, independently:
1. Derive the partial derivative using the implicit function theorem or direct differentiation. Show every step.
2. Determine the sign. State all conditions required for the sign to hold.
3. State: AGREE or DISAGREE with the claimed sign.
4. If the sign is AMBIGUOUS (depends on parameter values), say so explicitly — the author may have missed a condition.

[SIGN_CLAIMS_LIST]

--- OUTPUT FORMAT ---
For each claim:
CLAIM [N]: [restatement]
DERIVATION:
  [step-by-step derivation of the partial derivative]
SIGN: [+/-/0/AMBIGUOUS]
CONDITIONS: [conditions required for this sign]
VERDICT: AGREE / DISAGREE
[If DISAGREE or AMBIGUOUS]:
  EXPLANATION: [details]
```

**Oracle CLI invocation:**

```bash
npx -y @steipete/oracle --engine browser --model gpt-5.4-pro \
  --browser-manual-login --browser-input-timeout 300s \
  --slug "[MODEL_NAME]-comp-statics" \
  -p "[PROMPT_TEXT]" \
  --file "[PATH_TO_MODEL_SETUP_TEX]"
```

**Sign claims list format** (max 5 per call):

```
Claim 1: d(k)/d(theta) > 0 when the collateral constraint binds, because
  k = w/(1-theta) so dk/dtheta = w/(1-theta)^2 > 0.

Claim 2: d(k)/d(w) = 1/(1-theta) > 1 for theta > 0 when constrained.
```

If more than 5 sign claims, split into multiple Oracle calls. Budget 3-6 Oracle sessions total per model run.
