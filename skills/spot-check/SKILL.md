---
name: spot-check
description: Randomly sample a few rows from a script's results and fan out parallel subagents that independently verify whether each result makes sense given the input data. Use when user says "spot-check the X output", "do these classifications look right", "sample a few rows and tell me if they're correct", "sanity-check the regressions", "are these labels reasonable", or after any pipeline that produces a labelled/scored output table. Each subagent runs in fresh context (no cross-sample confirmation bias) and returns PASS / FAIL / QUESTIONABLE with one-line evidence. Use `/verify-claims` instead if the spot-check is specifically about citations in a written draft.
argument-hint: "<path-to-results-file> [free-text describing what to check] [n:<int>] [seed:<int>]"
allowed-tools: ["Read", "Bash", "Glob", "Grep", "Task"]
---

# /spot-check — Random-sample audit of a script's results

Sample a few rows from a results file, fan out independent verification subagents in parallel, and aggregate their verdicts.

**Input:** `$ARGUMENTS` — a path to the results file plus an optional free-text description of what "makes sense" means for this output. Optional flags:

- `n:<int>` — number of rows to sample (default 5).
- `seed:<int>` — random seed for the sample (default 42).

If no path is given, ask the user which file to spot-check before doing anything else.

---

## When to pick this skill

- **`/spot-check`** (this skill) — random-sample audit of any labelled / scored / classified table the user just generated. Domain-agnostic — works for LLM classifications, regression outputs, data-cleaning decisions, etc.
- **`/verify-claims`** — citations / factual assertions in a written draft. Different mandate (Chain-of-Verification on text), uses the `claim-verifier` agent.
- **`/proofread`** — grammar / style, not correctness.
- **`/review-paper`** — full-manuscript review, not a sample audit.

---

## Steps

### Phase 1 — Sample

1. **Locate the results file.** If `$ARGUMENTS` includes a path, use it. Otherwise ask the user. Accept CSV, parquet, JSON, .dta.
2. **Pick N rows uniformly at random** using the seed (default 5 rows, seed 42). Use pandas via the Bash tool — keep the snippet short:
   ```bash
   python -c "import pandas as pd; df = pd.read_csv('PATH'); print(df.sample(n=N, random_state=SEED).to_csv(index=False))"
   ```
   (Substitute `read_parquet` / `read_json` as appropriate.)
3. **Show the sampled rows to the user** in a compact table before spawning agents. The user can interrupt if the sample looks wrong or the wrong columns are being inspected.

### Phase 2 — Design the verification mandate

4. **Identify input vs output columns.** Inputs are what the script was given (e.g., a species name + Wikipedia/IUCN context); outputs are what the script produced (e.g., the assigned ecosystem-function bucket plus justification). Surface this distinction clearly in the prompt to each subagent — it must know which fields it is checking *against* and which fields it is checking.
5. **Weave the user's free-text description into the per-agent mandate verbatim** — do not paraphrase or "improve" it. Example: if the user said "check whether the assigned primary bucket matches the species' actual diet", that exact sentence goes into every sub-agent's prompt.
6. **Default verdict schema:** PASS / FAIL / QUESTIONABLE plus one sentence of evidence. PASS = the result is consistent with the input given reasonable domain expectations. FAIL = the result contradicts the input or is clearly wrong. QUESTIONABLE = ambiguous, could go either way, evidence is mixed.

### Phase 3 — Fan out subagents IN PARALLEL

7. **Spawn N `general-purpose` subagents in a single assistant message** (multiple Task tool calls in parallel). Each subagent receives:
   - The single sampled row (NOT the others — fresh-context independence is the whole point).
   - A clear description of what the row represents, which columns are inputs, which are outputs.
   - The verification mandate verbatim (the user's free-text + the PASS/FAIL/QUESTIONABLE schema).
   - Permission to use WebSearch / WebFetch / Read / Grep / Bash as needed to fact-check.
   - A 200-word response budget.
   - Instructions to return a single structured line: `VERDICT — one-sentence evidence`.

**Why fresh context per sample.** If one subagent saw the other samples, it would anchor on patterns across them ("4 of 5 are predators, this 5th one must be too"). Independent forking forces each verdict to stand on its own evidence.

### Phase 4 — Aggregate

8. **Collect verdicts** into a markdown table:
   ```
   | # | Sampled row (1-line identifier) | Verdict | Evidence |
   |---|---|---|---|
   | 1 | ... | PASS | ... |
   | 2 | ... | FAIL | ... |
   ```
9. **Headline line** at the top: e.g. `4/5 PASS, 1/5 FAIL — flagged row #3 (Species X) where the assigned 'Biological control' label conflicts with the IUCN description of obligate frugivory`.
10. **If any verdict is FAIL**, suggest the user (a) inspect that specific row in the source data, or (b) re-run the upstream script with adjusted parameters. **Do NOT auto-fix** the underlying script — that's outside the scope of a spot check.
11. **If all verdicts are PASS**, note explicitly that this is *evidence the script is working*, not a proof — a 5-row sample can still miss systematic edge-case errors. Suggest re-running with a different seed or a larger N if the user wants stronger confidence.

---

## Worked example — LLM ecosystem-function classifications

**User invocation:**

```
/spot-check data/raw/classification_evaluation/iucn_random_5000/iucn_random_5000_predictions.csv "Does the assigned primary ecosystem function bucket match what we'd expect from this species' diet and ecology?"
```

**Phase 1.** Read the file, sample 5 rows with seed 42, display:

| # | species | taxonomic_class | primary | secondary | tertiary | justification (truncated) |
|---|---|---|---|---|---|---|
| 1 | Eidolon helvum | Mammalia | Seed dispersal | Pollination | Habitat creation | "Frugivorous fruit bat..." |
| 2 | Vampyrum spectrum | Mammalia | Biological control | Nutrient cycling | Habitat creation | "Apex predator..." |
| 3 | ... | ... | ... | ... | ... | ... |

**Phase 2-3.** Spawn 5 subagents in parallel. Each gets:

> You are a fresh-context verifier. One sampled row from an LLM-classification pipeline is below.
>
> Row: species=Eidolon helvum, taxonomic_class=Mammalia, primary=Seed dispersal, secondary=Pollination, tertiary=Habitat creation, justification="Frugivorous fruit bat..."
>
> Inputs the classifier saw: species name + Wikipedia summary + IUCN habitat/use-trade text.
> Output the classifier produced: primary / secondary / tertiary bucket + justification.
>
> Verification mandate (user's words, verbatim): "Does the assigned primary ecosystem function bucket match what we'd expect from this species' diet and ecology?"
>
> Use WebSearch / WebFetch / your own knowledge to verify. Return a single line in the format:
> `VERDICT — one-sentence evidence`
> where VERDICT is PASS, FAIL, or QUESTIONABLE. Under 200 words total.

**Phase 4.** Aggregated output:

```
**5/5 PASS** — no flags raised in this sample.

| # | species               | primary             | Verdict | Evidence |
|---|-----------------------|---------------------|---------|----------|
| 1 | Eidolon helvum        | Seed dispersal      | PASS    | Straw-coloured fruit bat; long-distance frugivory and gut-passage seed transport are its defining ecological role. |
| 2 | Vampyrum spectrum     | Biological control  | PASS    | False vampire bat; apex carnivorous predator of small vertebrates — predation is the primary function. |
| 3 | Castor fiber          | Habitat creation    | PASS    | Eurasian beaver; dam-building physically creates wetland habitat. |
| 4 | Helianthus annuus     | Pollination         | PASS    | Sunflower; conspicuous floral display attracts bees, primary direct interaction is animal pollination. |
| 5 | Alnus glutinosa       | Nutrient cycling    | PASS    | Common alder; actinorhizal N-fixation via Frankia is the canonical species-level mechanism. |

5/5 PASS on this sample is evidence the classifier is working on the species mix it was given — not proof of overall accuracy. If you want stronger confidence, re-run with `n:20 seed:1` or any other seed.
```

---

## Format constraints when returning the final report

- Markdown table for verdicts. One row per sampled item.
- Headline summary above the table.
- One-line evidence per verdict — no paragraphs.
- Do not include subagent transcripts; just their final verdicts.

## Skip / abort conditions

- **File doesn't exist or can't be read** → say so, ask the user for the right path.
- **File has fewer than N rows** → use all rows and note it explicitly.
- **User's free-text mandate is missing AND the file's columns aren't self-explanatory** → ask one clarifying question before sampling.

## Cost

N subagent calls + their internal WebSearch/Read tool use. Default N=5 keeps the spot-check cheap (~30 seconds). Raise N if you want a larger sample.
