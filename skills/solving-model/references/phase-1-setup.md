# Phase 1: Model Setup

**Goal:** Translate an informal economic idea into a complete mathematical environment.

## Prerequisites

- Read `~/.claude/preferences/model-solving-conventions.md` before writing any LaTeX.
- On first invocation, also read `references/example-walkthrough.md` for a concrete output pattern.

## Inputs

- `$MODEL_NAME` — the model name (used for working directory and Oracle slugs)
- `$WORKING_DIR` — path to `solving_models/[name]/`
- `$INPUT_TYPE` — one of: `verbal`, `pdf`, `latex`
- `$INPUT_CONTENT` — the user's description, file path, or LaTeX content

## Step 1: Parse input

- If `$INPUT_TYPE` is `verbal`: proceed directly to elicitation
- If `$INPUT_TYPE` is `pdf`: invoke the `pdf-chunker` skill to extract text, then read the extracted output and identify the model section.
- If `$INPUT_TYPE` is `latex`: read the file and identify what's already formalized vs. what's missing

## Step 2: Structured elicitation

Ask the user to confirm or fill in each element. Use AskUserQuestion, **one question at a time**:

1. **Agents**: Who are the decision-makers? (firms, households, banks, government)
2. **Timing**: Discrete/continuous? Finite/infinite horizon? How many periods?
3. **Technology**: Production function form? Returns to scale?
4. **Preferences**: Utility function? Discount factor? Risk aversion parameter?
5. **Market structure**: Perfect competition, monopolistic competition, bargaining?
6. **Constraints**: Budget constraint, borrowing constraint, participation constraint?
7. **Shocks**: What is stochastic? Distribution? Timing of realization?
8. **Equilibrium concept**: Competitive equilibrium, Nash, Walrasian?

For each element the user leaves blank, suggest a standard choice from the literature with a brief justification. Example: "For capital share, Cobb-Douglas with α ∈ (0,1) is standard (Gollin 2002)."

Skip elements that are clearly irrelevant to the model (e.g., don't ask about shocks for a deterministic model).

## Step 3: Write `model_setup.tex`

Follow the templates in `model-solving-conventions.md`. The file must include:

1. **Environment description** — prose paragraph describing the economic setting
2. **Timing diagram** — if the model is dynamic (can be a simple itemize for two-period models)
3. **Primitives list** — preferences, technology, endowments, market structure, information
4. **Numbered assumptions** — A1, A2, ... using `\paragraph{Assumption AN:}` format
5. **Notation table** — using the tabular template (Symbol | Name | Type | Domain)
6. **Optimization problem(s)** — in labeled `align` environments with equation references

Every variable that appears in any equation must appear in the notation table. Every functional form must be stated in a numbered assumption.

**Before overwriting:** If `model_setup.tex` already exists, copy to `model_setup.tex.bak`:
```bash
cp "$WORKING_DIR/model_setup.tex" "$WORKING_DIR/model_setup.tex.bak" 2>/dev/null
```

## Step 4: Oracle setup review

Read the **Setup Review** template from `references/oracle-prompts.md`.

1. Construct the prompt by inserting the contents of `model_setup.tex` into the `[MODEL_SETUP_CONTENTS]` placeholder.
2. Run Oracle:
   ```bash
   npx -y @steipete/oracle --engine browser --model gpt-5.4-pro \
     --slug "$MODEL_NAME-setup-review" \
     -p "[constructed prompt]" \
     --file "$WORKING_DIR/model_setup.tex"
   ```
3. Present Oracle feedback to the user, organized by severity (CRITICAL → WARNING → SUGGESTION).
4. For each CRITICAL or WARNING issue, ask the user to decide: fix it, defer it, or dismiss it.
5. Apply agreed-upon fixes to `model_setup.tex`.

If Oracle times out or fails: inform the user, offer to retry or continue without Oracle review. Note that setup review is valuable but not blocking — the user can proceed and rely on Phase 3 verification.

## Step 5: CHECKPOINT

Display a summary of the model setup:
- Number of agents, timing, key assumptions
- List of choice variables and parameters
- The optimization problem(s)

Ask using AskUserQuestion:

> "Approve setup and proceed to derivation? (y/n)"

**Do NOT proceed without explicit user approval.** If the user wants changes, go back to the relevant step.

## Output

- `$WORKING_DIR/model_setup.tex` — the complete model setup
- Return control to the orchestrator with status: `APPROVED` or `NEEDS_REVISION`
