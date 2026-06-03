# Phase 2: Derivation

**Goal:** Solve the model step-by-step with full transparency.

## Prerequisites

- Read `~/.claude/preferences/model-solving-conventions.md` before writing any LaTeX.
- Read `$WORKING_DIR/model_setup.tex` to understand the model.

## Inputs

- `$MODEL_NAME` — the model name
- `$WORKING_DIR` — path to `solving_models/[name]/`
- `$WORKING_DIR/model_setup.tex` — the model setup from Phase 1

## Step 1: Identify derivation targets

Based on `model_setup.tex`, determine what needs to be derived:

- First-order conditions (FOCs) for each agent's optimization problem
- Envelope conditions (if dynamic / multi-period)
- Market-clearing conditions (if general equilibrium)
- Equilibrium characterization (reduced-form equations linking endogenous variables)
- Closed-form solutions (if obtainable)

Present this list to the user for approval before starting. The user may add or remove targets.

## Step 2: Derive sequentially

Follow the **Derivation Step Format** template in `model-solving-conventions.md` exactly. Each step uses a `\paragraph{Step N:}` header, an `\textit{Operation:}` line, display math in `align`, and an optional `\textit{Simplification:}` block.

### Strict rules

- **One algebraic operation per step.** Never combine two manipulations in one step.
- **Substeps for complex steps.** If a step requires more than one line of algebra, break it into substeps: Step 4a, Step 4b, etc.
- **Reference every substitution.** "Substitute λ from Step 3" — never "substitute λ" without the source.
- **No shortcuts.** Never write:
  - "it can be shown that..."
  - "by inspection..."
  - "clearly..." / "trivially..." / "obviously..."
  - "straightforward algebra yields..."
  - Any phrase that hides work.

### What to flag with `% VERIFY`

Place the marker at the end of the `\paragraph` line:
```latex
\paragraph{Step 4: Substitute λ into capital FOC} % VERIFY
```

Flag any step involving:
- Sign determinations or inequality claims
- Multi-step simplifications (more than collecting like terms)
- Theorem applications (envelope theorem, implicit function theorem, Leibniz rule, Kuhn-Tucker)
- Concavity/convexity claims
- Existence/uniqueness arguments
- Limit or L'Hopital applications
- Case analysis with economic interpretation (e.g., binding vs. non-binding constraint)

## Step 3: Write `derivation.tex`

Write steps incrementally to `$WORKING_DIR/derivation.tex`.

**Before overwriting:** If the file already exists:
```bash
cp "$WORKING_DIR/derivation.tex" "$WORKING_DIR/derivation.tex.bak" 2>/dev/null
```

## Step 4: Weasel word scan

After writing the complete derivation, scan the entire `derivation.tex` for the weasel phrases listed in the **Weasel Word List** section of `verification-protocol.md`.

**Any step containing these phrases must be flagged with `% VERIFY`** regardless of whether it matches the standard non-trivial categories above. If you find yourself writing one of these phrases, that is a signal to break the step into smaller substeps instead.

## Step 5: Consistency check

While deriving, if you discover that the model setup is incomplete or inconsistent:

- A variable appears that is not in the notation table
- A constraint is missing (e.g., non-negativity, transversality)
- Two assumptions contradict each other
- A market-clearing condition is needed but not stated

**HALT immediately.** Explain the specific issue. Offer two options:
1. Return to Phase 1 to amend `model_setup.tex`
2. Add the missing element inline with a clear note (if the fix is minor, e.g., adding a non-negativity constraint)

## Step 6: CHECKPOINT

Display the full derivation. Highlight all `% VERIFY`-flagged steps (show step numbers and descriptions).

Ask using AskUserQuestion:

> "Approve derivation and proceed to verification? Flagged steps: [N1: description, N2: description, ...]"

**Do NOT proceed without explicit user approval.**

## Output

- `$WORKING_DIR/derivation.tex` — the complete step-by-step derivation
- List of `% VERIFY`-flagged step numbers
- Return control to the orchestrator with status: `APPROVED` or `NEEDS_REVISION`
