---
name: review-paper
description: "Comprehensive manuscript review with three modes: single-pass, adversarial critic-fixer, and simulated peer review with an editor and two dispositioned referees calibrated to a target journal. Use for manuscript critique, pre-submission review, journal-fit simulation, R&R continuation, or hostile-editor stress testing."
---

# Manuscript Review

Produce a thorough, constructive review of an academic manuscript — the kind of report a top-journal referee would write.

> **Which review skill do I want?**
>
> - **`$review-paper`** (this skill) — single comprehensive report, optional `--adversarial` critic-fixer loop, or `--peer <journal>` simulated peer-review pipeline. Best for **most drafts**.
> - **`$strategic-revision`** — if you already have referee comments and need a dependency-mapped revision plan, not another review.

**Input:** the user's request — path to a paper (`.tex`, `.pdf`, or `.qmd`), or a filename in `master_supporting_docs/`. Optional flags:

- `--adversarial` — critic-fixer loop (max 5 rounds).
- `--peer <JOURNAL>` — simulated peer review pipeline calibrated to `<JOURNAL>` (see `~/.codex/references/journal-profiles.md` for available short names).
- `--r2` / `--r3` — R&R continuation mode (requires `--peer`). Reloads prior round, classifies concerns Resolved / Partial / Not addressed.
- `--stress` — hostile-editor stress test (requires `--peer`). Forces SKEPTIC dispositions, doubles critical peeves.
- `--no-novelty-check` — skip editor's web search novelty probe (default is ON).

> **Already received referee comments?** Use [`$strategic-revision`](../strategic-revision/SKILL.md) instead. That skill builds a dependency-mapped revision plan from the referee reports, with a validated DAG and critical-path analysis.

---

## Modes

### Default mode (single-pass)

One comprehensive review report. Fast, low token cost, suitable for early drafts where the author wants feedback and will iterate manually.

### Adversarial mode (`--adversarial`)

Iterative critic-fixer loop. The critic identifies issues, the fixer proposes and applies edits (with user approval), and the critic re-audits. Loops until APPROVED or max 5 rounds.

Use when: preparing a pre-submission draft, responding to a journal-desk rejection with substantive revisions, or after your own major rewrite. Costs more tokens but produces a manuscript the critic has signed off on.

### Peer-review mode (`--peer <JOURNAL>`)

Simulated editorial pipeline: **editor desk review → referee selection → 2 blind referees with different dispositions → editorial synthesis**. Calibrated to a target journal from `~/.codex/references/journal-profiles.md`. Use when: pre-submission dress rehearsal, choosing between target journals, R&R planning.

This mode is materially different from `--adversarial`: adversarial runs the same critic 5× with fresh context; `--peer` runs **different personas** (editor + 2 dispositioned referees drawn from 6-way taxonomy: STRUCTURAL / CREDIBILITY / MEASUREMENT / POLICY / THEORY / SKEPTIC) whose priors are *deliberately different* and who are blind to each other.

**Agents used** (all reimplemented in this template; adapted from [Hugo Sant'Anna's clo-author](https://github.com/hugosantanna/clo-author) with permission):

- `~/.codex/agents/editor.toml` — editor (desk review, referee selection, synthesis).
- `~/.codex/agents/domain-referee.toml` — substance referee.
- `~/.codex/agents/methods-referee.toml` — methodology referee (paper-type-aware).

**Sub-flags:**

- `--r2` / `--r3` — R&R mode. Skips fresh desk review; reloads prior round's reports; same referees + dispositions + peeves; classifies each prior concern as Resolved / Partial / Not addressed. Hard cap at `--r3` (no round 4+).
- `--stress` — Hostile editor. Forces both referees to SKEPTIC disposition, doubles critical peeves, framing: "you are looking for reasons to reject this paper." Output is a concern-list gauntlet, not a decision letter.
- `--no-novelty-check` — Disables the editor's web search novelty probes (default is ON). Use in offline or hallucination-sensitive contexts. **Novelty-check caveat (document this to users):** web search can return hallucinated citations or miss paywalled recent work. Always surface novelty-probe results as flags for manual verification, not verdicts.

---


## Steps (both modes)

1. **Locate and read the manuscript.** First strip flags from the user's request to get the bare manuscript path. Check:
   - Direct path (bare path from step 1)
   - the bare filename under `master_supporting_docs/supporting_papers/`
   - Search filenames for partial matches

2. **Read the full paper** end-to-end. For long PDFs, read in chunks (5 pages at a time).

3. **Evaluate across 6 dimensions** (see below).

4. **Generate 3–5 "referee objections"** — the tough questions a top referee would ask.

5. **Produce the review report.**

6. **Save to** `quality_reports/paper_review_[sanitized_name]_round[N].md` (N=1 in default mode; N increments in adversarial mode).

7. **If `--adversarial` is in the user's request:** invoke the critic-fixer loop defined in the next section. Otherwise stop here.

---

## Review Dimensions

### 1. Argument Structure
- Is the research question clearly stated?
- Does the introduction motivate the question effectively?
- Is the logical flow sound (question → method → results → conclusion)?
- Are the conclusions supported by the evidence?
- Are limitations acknowledged?

### 2. Identification Strategy
- Is the causal claim credible?
- What are the key identifying assumptions? Are they stated explicitly?
- Are there threats to identification (omitted variables, reverse causality, measurement error)?
- Are robustness checks adequate?
- Is the estimator appropriate for the research design?

### 3. Econometric Specification
- Correct standard errors (clustered? robust? bootstrap?)?
- Appropriate functional form?
- Sample selection issues?
- Multiple testing concerns?
- Are point estimates economically meaningful (not just statistically significant)?

### 4. Literature Positioning
- Are the key papers cited?
- Is prior work characterized accurately?
- Is the contribution clearly differentiated from existing work?
- Any missing citations that a referee would flag?

### 5. Writing Quality
- Clarity and concision
- Academic tone
- Consistent notation throughout
- Abstract effectively summarizes the paper
- Tables and figures are self-contained (clear labels, notes, sources)

### 6. Presentation
- Are tables and figures well-designed?
- Is notation consistent throughout?
- Are there any typos, grammatical errors, or formatting issues?
- Is the paper the right length for the contribution?

---

## Output Format

```markdown
# Manuscript Review: [Paper Title]

**Date:** [YYYY-MM-DD]
**Reviewer:** review-paper skill
**File:** [path to manuscript]

## Summary Assessment

**Overall recommendation:** [Strong Accept / Accept / Revise & Resubmit / Reject]

[2-3 paragraph summary: main contribution, strengths, and key concerns]

## Strengths

1. [Strength 1]
2. [Strength 2]
3. [Strength 3]

## Major Concerns

### MC1: [Title]
- **Dimension:** [Identification / Econometrics / Argument / Literature / Writing / Presentation]
- **Issue:** [Specific description]
- **Suggestion:** [How to address it]
- **Location:** [Section/page/table if applicable]

[Repeat for each major concern]

## Minor Concerns

### mc1: [Title]
- **Issue:** [Description]
- **Suggestion:** [Fix]

[Repeat]

## Referee Objections

These are the tough questions a top referee would likely raise:

### RO1: [Question]
**Why it matters:** [Why this could be fatal]
**How to address it:** [Suggested response or additional analysis]

[Repeat for 3-5 objections]

## Specific Comments

[Line-by-line or section-by-section comments, if any]

## Summary Statistics

| Dimension | Rating (1-5) |
|-----------|-------------|
| Argument Structure | [N] |
| Identification | [N] |
| Econometrics | [N] |
| Literature | [N] |
| Writing | [N] |
| Presentation | [N] |
| **Overall** | **[N]** |
```

---

## Principles

- **Be constructive.** Every criticism should come with a suggestion.
- **Be specific.** Reference exact sections, equations, tables.
- **Think like a referee at a top-5 journal.** What would make them reject?
- **Distinguish fatal flaws from minor issues.** Not everything is equally important.
- **Acknowledge what's done well.** Good research deserves recognition.
- **Do NOT fabricate details.** If you can't read a section clearly, say so.

---

## Adversarial Mode — Critic-Fixer Loop

**Only runs if `--adversarial` is in the user's request.**

This critic-fixer pattern is used because the single-pass review otherwise leaves authors doing manual fix-and-resubmit cycles.

### Flow

```
Phase 0: Pre-flight
  │
  ├─ Verify the manuscript compiles (xelatex / quarto render) if applicable
  ├─ Snapshot the pre-review version: git stash OR copy to a .review-backup/
  │
Phase 1: Critic audit (round N=1,2,3,...)
  │
  ├─ Run the default review above, producing a round-N report
  ├─ If the report has ZERO Major Concerns and ZERO Referee Objections
  │  rated "fatal":
  │     → VERDICT = APPROVED. Stop the loop. Write final summary.
  │  Else: continue.
  │
Phase 2: Fixer
  │
  ├─ For each Major Concern in the round-N report, produce a concrete
  │  proposed edit (diff or new text block).
  ├─ Present proposed edits to the user grouped by severity (Critical →
  │  Major → Minor). Ask for approval: "apply all", "apply critical+major
  │  only", "review each", or "abort".
  ├─ Apply only the edits the user approved.
  ├─ If the manuscript is a compile target (`.tex` / `.qmd`), re-compile
  │  and verify it still builds.
  │
Phase 3: Re-audit
  │
  └─ Spawn a fresh GPT-5.6 Terra subagent at high effort to re-read
     the paper and produce a round-(N+1)
     report. Fresh context prevents anchoring bias — the new reviewer
     sees the edited paper, not the diff.
     → Jump back to Phase 1.
```

### Iteration limits

- **Max 5 rounds.** After round 5, halt regardless of verdict.
- **Fix round limits:** if the same Concern label appears in rounds N and N+2, flag as "author disagreement" and let the user decide (keep-as-is with rationale vs. another fix attempt).
- **Budget escape:** if token cost across all rounds exceeds ~200k, warn and let the user cap further rounds.

### Stopping criteria

| Condition | Action |
|---|---|
| Zero Major Concerns, zero fatal Referee Objections | APPROVED — final summary |
| Max 5 rounds reached | HALTED — list remaining concerns, user decides |
| User approves zero fixes in a round | HALTED — user signals "I disagree with this review" |
| Compile fails after applied fixes | ROLLED BACK to pre-round-N snapshot, report compile error, user decides |

### Final report

After the loop ends, write `quality_reports/paper_review_[sanitized_name]_FINAL.md`:

```markdown
# Final Review: [Paper Title]

**Rounds:** N
**Verdict:** APPROVED | HALTED (max rounds) | HALTED (user override) | ROLLED BACK
**Token cost estimate:** ~XXk

## Round Summary
| Round | Major Concerns | Fatal Objections | Status |
|---|---|---|---|
| 1 | 7 | 2 | Fixed 5, deferred 2 |
| 2 | 3 | 1 | ...              |
| ... | ... | ... | ...         |
| N | 0 | 0 | APPROVED        |

## Changes Applied
[link to git diff between the pre-round-1 snapshot and HEAD]

## Remaining Concerns (if HALTED)
[list with severity + rationale]

## Next Steps
[recommended action: submit / one more pass / substantial revision]
```

### When NOT to use adversarial mode

- Early exploratory drafts (the loop forces premature polish on ideas still being shaped)
- Papers you don't yet have compilable source for (can't verify edits)
- When you'd rather get ONE opinion and decide for yourself (adversarial-mode enforces "critic signed off" semantics — that's sometimes the wrong frame)

---

## `--peer [journal]` workflow detail

**Novelty-probe verification.** The editor's novelty probe uses `web search` to check whether the paper's contribution has been made before. web search results can be hallucinated — fabricated prior work, misattributed findings, wrong years. Before the editor's desk review incorporates novelty-probe claims into its decision, those claims must pass Chain-of-Verification (see [`$verify-claims`](../verify-claims/SKILL.md)):

1. The editor collects novelty-probe claims (e.g., "Smith 2022 already showed this exact result").
2. Read `~/.codex/agents/claim-verifier.toml`, then spawn `claim_verifier` with GPT-5.6 Terra at high effort and no inherited conversation turns. Pass the claims, verification questions, and candidate source URLs, but not the draft.
3. Only verified claims are allowed into the desk-review narrative. Unverified claims are surfaced separately as "editor could not verify — manual check recommended" rather than presented as established prior work.

Opt-out: `--no-novelty-check` already skips the probe entirely. If the probe runs, Post-Flight is mandatory.

**Pre-Flight Report (required before Phase 1).** Before spawning the editor, output a Pre-Flight Report so the user can verify the inputs are read correctly:

```markdown
## Pre-Flight Report — $review-paper --peer

**Manuscript:** [path] — [page count, last modified]
**Target journal:** [JOURNAL_SHORT] → [full name from `~/.codex/references/journal-profiles.md`]
**Journal profile loaded:** [yes/no; resolved from `~/.codex/references/journal-profiles.md`; key adjustments: e.g., "Identification 35 → 40"]
**Round:** [fresh / r2 / r3 / stress]
```

If the manuscript path doesn't exist or the target journal isn't in `~/.codex/references/journal-profiles.md`, stop and surface the issue before proceeding.

### Phase 1: Editor desk review

Read `~/.codex/agents/editor.toml`, then spawn the `editor` custom agent with the manuscript path and `--peer <JOURNAL>` context. Give it no inherited conversation turns when available. The editor:
- Reads journal profile from `~/.codex/references/journal-profiles.md` → states "Calibrated to: [journal]".
- Reads abstract + intro + methods overview + headline results.
- Runs novelty probes (unless `--no-novelty-check`).
- Either **DESK REJECT** (pipeline terminates with rejection letter) or **SEND OUT**.

Report: `quality_reports/peer_review_[paper]/desk_review.md`.

### Phase 1b: Referee selection (inside editor)

Editor draws 2 DIFFERENT dispositions from journal's Referee-pool weights and assigns each referee 1 critical + 1 constructive peeve (stress mode: 2 critical + 1 constructive). Appended to `desk_review.md`.

### Phase 2: Two parallel referees, blind to each other

Read the corresponding TOML files and spawn in parallel:
- Fresh `domain_referee` subagent with disposition D1 and peeves P1 → `referee_domain.md`.
- Fresh `methods_referee` subagent with disposition D2 and peeves P2 → `referee_methods.md`.

Each referee must include "What would change my mind: [specific ask]" on every MAJOR concern.

### Phase 3: Editor synthesis

Read both referee reports. Classify each MAJOR concern as FATAL / ADDRESSABLE / TASTE. Produce the editorial decision using the decision-rule table in `~/.codex/agents/editor.toml`.

Report: `quality_reports/peer_review_[paper]/editorial_decision.md`.

### Phase 4: Summary

Tell the user:
- Final decision (Accept / Minor / Major / Reject / Desk Reject)
- Token usage + wall-clock time
- Paths to all 4 reports (desk_review, referee_domain, referee_methods, editorial_decision)

---

## Output layout for `--peer` mode

```
quality_reports/
  peer_review_[sanitized_paper_name]/
    desk_review.md                       # Phase 1 + Phase 1b
    referee_domain.md                    # Phase 2 (parallel)
    referee_methods.md                   # Phase 2 (parallel)
    editorial_decision.md                # Phase 3
    (R&R rounds: desk_review_r2.md, referee_domain_r2.md, ...)
```

---

## Field adaptation

The shipped `journal-profiles.md` covers 8 journals: 5 economics (AER, QJE, JPE, ECMA, ReStud) and 3 political science (APSR, AJPS, JOP). For other fields (finance, biology, CS, etc.), copy `~/.codex/references/journal-profile-template.md` into a new section of `journal-profiles.md` and fill in the schema. See the "Field adaptation" section at the end of `journal-profiles.md` for detailed guidance. The pipeline itself is field-agnostic; only the calibration data changes.

For non-econ paper types in `~/.codex/agents/methods-referee.toml`, extend the paper-type list (e.g., biology: `observational / experimental / computational / review`).
