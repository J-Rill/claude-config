# Phase 4: Comparative Statics

**Goal:** Derive and sign key comparative statics with independent verification.

## Prerequisites

- Read `references/model-solving-conventions.md` for table format.
- Read `references/verification-protocol.md` for numerical checks.

## Inputs

- `$MODEL_NAME` — the model name
- `$WORKING_DIR` — path to `solving_models/[name]/`
- `$WORKING_DIR/model_setup.tex` — the model setup
- `$WORKING_DIR/derivation.tex` — the derivation (for equilibrium equations)

## Step 1: Identify parameters of interest

Read `model_setup.tex` and `derivation.tex` to identify the equilibrium equations and the parameters that appear in them.

Suggest the obvious comparative statics based on the model. For example:
- Borrowing constraint models: θ (pledgeability), w (wealth)
- Trade models: τ (trade cost), f_x (fixed export cost)
- Investment models: A (productivity), r (interest rate), δ (depreciation)

Ask using ask the user directly:

> "Which parameters do you want comparative statics for? Suggested: [list]. You can add or remove from this list."

## Step 2: Derive and sign

For each parameter-variable pair, follow the same transparency rules as Phase 2:

1. **Derive the partial derivative** using the implicit function theorem or direct differentiation. Show every algebraic step. Reference the equilibrium equation by step number.

2. **Sign the derivative.** This typically requires:
   - Determining signs of all components
   - Using second-order conditions or concavity assumptions
   - Stating conditions under which the sign holds

3. **Flag sign claims with `% VERIFY`** on the paragraph line.

4. **State the economic intuition** in one sentence.

Format each comparative static as:

```latex
\paragraph{Comparative static: $\partial [variable] / \partial [parameter]$} % VERIFY
\textit{Operation: Differentiate [equilibrium equation from Step N] with respect to [parameter].}

\begin{align}
  \frac{\partial [variable]}{\partial [parameter]} = [expression] [sign] 0
\end{align}

\textit{Condition:} [When does this sign hold? Always, or only when constrained, or under a parameter restriction?]

\textit{Intuition:} [One sentence explaining the economic mechanism.]
```

## Step 3: Write `comparative_statics.tex`

Write the derivations and the summary table to `$WORKING_DIR/comparative_statics.tex`.

Back up before overwriting:
```bash
cp "$WORKING_DIR/comparative_statics.tex" "$WORKING_DIR/comparative_statics.tex.bak" 2>/dev/null
```

## Step 4: Verifier sign verification

Read the **Comparative Statics Verification** template from `references/verifier-prompts.md`.

1. **Construct the equilibrium equations context.** Read `derivation.tex` and extract the final equilibrium conditions (typically the last few steps or any step labeled "equilibrium characterization"). Format them as a numbered list of equations with their step references. This becomes the `[KEY_EQUILIBRIUM_EQUATIONS]` placeholder in the verifier template — it is pasted into the prompt so the verifier does not need `derivation.tex`.

2. Collect all sign claims into a numbered list. Format each as:
   ```
   Claim N: d(variable)/d(parameter) [sign] 0 [condition], because [brief derivation summary].
   ```

3. **Max 5 claims per verifier dispatch.** If more than 5 sign claims, split into multiple dispatches. Example: 18 claims → 4 dispatches of 5, 5, 5, 3.

4. Dispatch the verifier using the template's **Dispatch** block. Read `~/.codex/agents/model-verifier.toml`, then spawn `model_verifier` with GPT-5.6 Sol at xhigh effort and no inherited conversation turns (`fork_turns="none"` when available). Pass the constructed Mode C prompt, with the equilibrium equations pasted in, and `model_setup.tex`.

5. For each claim where the verifier returns **DISAGREE**: follow the HALT protocol from `verification-protocol.md`. Present both sign derivations side-by-side.

6. For each claim where the verifier returns **AMBIGUOUS**: present the verifier's analysis. The sign may genuinely depend on parameter values — ask the user whether to:
   - Add a sufficient condition (parameter restriction) under which the sign is determinate
   - Report the sign as ambiguous in the summary table

7. If the verifier subagent errors or returns nothing: inform the user, offer retry or skip. Note in the summary table: "Verifier: SKIPPED."

## Step 5: Build summary table

Use the comparative statics table format from `model-solving-conventions.md`:

```latex
\begin{table}[h]
\caption{Comparative Statics Summary}
\begin{tabular}{llclp{6cm}}
\toprule
Parameter & Variable & Sign & Condition & Intuition \\
\midrule
... \\
\bottomrule
\end{tabular}
\end{table}
```

Wrap in `\resizebox{1\linewidth}{!}{}` only if the table has many columns or is too wide.

Include all parameter-variable pairs, including those with sign = 0 (e.g., first-best variables that don't depend on friction parameters).

## Step 6: CHECKPOINT

Display the summary table.

Ask using ask the user directly:

> "Approve comparative statics and proceed to final compilation? (y/n)"

**Do NOT proceed without explicit user approval.**

## Output

- `$WORKING_DIR/comparative_statics.tex` — derivations and summary table
- Return control to the orchestrator with status: `APPROVED` or `NEEDS_REVISION`
