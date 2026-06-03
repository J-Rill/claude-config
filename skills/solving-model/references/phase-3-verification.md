# Phase 3: Verification

**Goal:** Independently verify every flagged derivation step using multiple methods.

## Prerequisites

- Read `~/.claude/preferences/verification-protocol.md` before running any checks.
- Read `~/.claude/preferences/model-solving-conventions.md` for verification log format.

## Inputs

- `$MODEL_NAME` — the model name
- `$WORKING_DIR` — path to `solving_models/[name]/`
- `$WORKING_DIR/model_setup.tex` — the model setup
- `$WORKING_DIR/derivation.tex` — the derivation with `% VERIFY` markers

## "Verify Existing" Entry (`--from=3` or `--verify`)

If entering at Phase 3 via normal `--from=3` (where `derivation.tex` was produced by Phase 2 and already has `\paragraph{Step N:}` labels), skip this section entirely and go straight to Step 1.

If entering at Phase 3 with an external file (not produced by Phase 2):

1. **PDF input:** Invoke the `pdf-chunker` skill to extract text.

2. **Read the LaTeX or extracted text.**

3. **Parse step boundaries:**
   - Recognize equation environments: `equation`, `align`, `align*`, `gather`, `multline`, `eqnarray`
   - If `\paragraph{Step N:}` labels exist, use them directly
   - If no step labels exist: infer step boundaries at each equation environment boundary and number them sequentially

4. **Present numbered step candidates** to the user. Display each step with its equation(s).

5. **User confirms step boundaries:** The user can:
   - Accept the proposed boundaries
   - Re-label steps (change numbers or descriptions)
   - Merge adjacent steps into one
   - Split a step into substeps
   - Manually flag steps with `% VERIFY`

6. **Write the parsed result** as `$WORKING_DIR/derivation.tex`.

7. **If no `model_setup.tex` exists:** Extract the model setup section from the input (variables, assumptions, optimization problem) and write it as `$WORKING_DIR/model_setup.tex`. Ask the user to confirm completeness.

Then proceed to Step 1 below.

## Step 1: Collect flagged steps

Grep `derivation.tex` for `% VERIFY`:

```bash
grep -n "% VERIFY" "$WORKING_DIR/derivation.tex"
```

Build a verification task list with step number, description, and equation(s).

## Step 2: User selects Oracle steps

Present the flagged step list to the user. Ask using AskUserQuestion:

> "Which flagged steps should Oracle re-derive independently? Select 3-5 critical steps. Flagged steps: [list with numbers and descriptions]"

## Step 3: Run local checks on ALL flagged steps

For each flagged step, run all three checks from `verification-protocol.md` at **per-operation granularity** — each substep (4a, 4b, ...) gets its own verification row.

### Context window for each check

Do NOT read the entire `derivation.tex` for each check. Instead, load:
1. `model_setup.tex` in full (notation table, assumptions, optimization problem)
2. The flagged step itself
3. All steps referenced by number within the flagged step
4. 2 steps of surrounding context (the step before and after)

### Checks A, B, C

Follow the full procedures in `verification-protocol.md`:
- **Check A — Dimensional consistency:** Assign units from `model_setup.tex`, verify units(LHS) = units(RHS).
- **Check B — Limiting cases:** Evaluate at boundary parameter values, verify against economic intuition.
- **Check C — Numerical spot-check:** Use parameter tables from `verification-protocol.md`. **Execute via Python** (`python3 -c "..."`), never in-context arithmetic. For FOCs, solve for consistent endogenous values first.

Use the output formats specified in `verification-protocol.md` for each check.

### HALT protocol — on ANY check failure

Follow the **HALT Protocol** in `verification-protocol.md`. In brief: stop immediately, present the original derivation and failing check side-by-side, wait for user adjudication. If the user identifies an error, back up `derivation.tex` to `.bak`, correct it, and re-run all three checks on the corrected step before continuing.

## Step 4: Oracle re-derivation for selected steps

Read the **Blind Re-derivation** template from `references/oracle-prompts.md`.

1. Construct the claims list from the user-selected steps. Format each claim as:
   ```
   Claim N: Starting from [source equations], applying [operation], the result is:
     [equation from the derivation step]
   ```

2. **Max 5 claims per Oracle call.** If the user selected more, split into multiple calls.

3. Run Oracle:
   ```bash
   npx -y @steipete/oracle --engine browser --model gpt-5.4-pro \
     --slug "$MODEL_NAME-rederivation" \
     -p "[constructed prompt]" \
     --file "$WORKING_DIR/model_setup.tex"
   ```

4. **CRITICAL: Do NOT include `derivation.tex` in the Oracle call.** The entire point is blind re-derivation. Oracle receives only `model_setup.tex`.

5. If Oracle returns **DISAGREE** on any claim: follow the HALT protocol above, presenting the Oracle's derivation alongside the original.

6. If Oracle returns **AGREE with implicit assumptions**: note these in the verification log. Ask the user whether the implicit assumptions are acceptable.

## Step 5: Write `verification_log.tex`

Use the **Verification Log Format** template from `model-solving-conventions.md`. Always show all 4 rows (Dimensional, Limiting cases, Numerical, Oracle). Steps not sent to Oracle use "NOT SELECTED."

Back up before overwriting:
```bash
cp "$WORKING_DIR/verification_log.tex" "$WORKING_DIR/verification_log.tex.bak" 2>/dev/null
```

## Step 6: CHECKPOINT

Display a verification summary table: Step | Dimensional | Limiting | Numerical | Oracle | Overall.

**If any Oracle check was skipped** (timeout, error, or user chose to skip):

> "WARNING: Oracle verification incomplete — N critical steps unverified by independent model. Re-run with `/solving-model --from=3 --name=$MODEL_NAME` when Oracle is available."

Ask using AskUserQuestion:

> "All verifications [passed / had N issues]. Proceed to comparative statics? (y/n)"

**Do NOT proceed without explicit user approval.**

## Output

- `$WORKING_DIR/verification_log.tex` — complete verification log
- Return control to the orchestrator with status: `ALL_PASSED`, `ISSUES_RESOLVED`, or `NEEDS_REVISION`
