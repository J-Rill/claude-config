---
name: review-plan-auto
description: Automated iterative plan review with convergence detection. Runs the review-plan critique loop automatically until the plan has no critical issues, with safeguards against deterioration and circular changes. Surfaces upstream issues that plan revision cannot fix. Use instead of manually running /review-plan multiple times. Trigger when the user mentions iterative review, auto-review, reviewing a plan thoroughly, or wants multiple review passes without manual approval.
argument-hint: "[file:path] [role:\"...\"] [focus:dimension] [depth:quick|standard|deep] [max:N] [dryrun] [help]"
allowed-tools: ["Read", "Glob", "Grep", "Write", "Edit", "Bash", "Agent", "WebSearch", "WebFetch"]
---
# Automated Plan Review

*v1.0 — Iterative plan review with convergence-based stopping, deterioration detection, and upstream-fix classification*

Runs the structured plan critique loop automatically (up to N passes) until the plan has no critical issues. Each pass uses a fresh-context subagent to avoid planner bias. Detects circular changes and surfaces issues that belong upstream rather than in the plan.

## Instructions

### Step 0: Pre-checks

Parse `$ARGUMENTS` for flags. **If `$ARGUMENTS` is `help`, print the table below and stop.**

| Flag | Syntax | Default | Purpose |
|------|--------|---------|---------|
| Help | `help` | — | Show this options table and stop |
| File path | `file:path` | Auto-detect | Explicit plan location |
| Expert role | `role:"..."` | Auto-detect | Override persona |
| Focus area | `focus:dimension` | All dimensions | Weight one dimension (e.g. `focus:feasibility`) |
| Depth | `depth:quick/standard/deep` | `standard` | Web research intensity |
| Quick | `quick` | Off | Shorthand for `depth:quick` |
| Max passes | `max:N` | `4` | Hard cap on automated passes |
| Dry run | `dryrun` | Off | Show role + research plan only |

### Step 1: Locate and Read the Plan

Four-tier priority:
1. **Explicit file** — `file:path/to/plan.md` argument
2. **Project-local plans** — search for `plan*.md` files in the current project's `notes/`, `plans/`, or `pap/` subdirectories (including additional working directories). Prefer the most recently modified match.
3. **Plan-mode file** — most recent file in `~/.claude/plans/`
4. **Conversation history** — scan the current session for the plan

If no plan found:
> "No plan found. Usage: `/review-plan-auto` (after plan mode) or `/review-plan-auto file:path/to/plan.md`"

Record the plan source (file path or "conversation") for the final summary.

### Step 2: Assign Expert Role

Infer the domain from plan content:

| Domain signals | Assigned role |
|---------------|---------------|
| skill, command, agent, MCP, Claude Code | AI engineering and skill design specialist |
| proposal, grant, funder, budget | Grant strategy and research funding specialist |
| paper, manuscript, identification, regression | Academic research methodology specialist |
| project management, tracker, workflow, dashboard | Operations and project management specialist |
| data, analysis, pipeline, code, replication | Data science and reproducibility specialist |
| Default (no strong signal) | Strategic planning and implementation specialist |

If `role:"..."` is provided, use that instead.

**Announce:** "**Reviewing as:** Meticulous [role]. (Override with `role:"your role"` if this doesn't fit.)"

### Step 3: Research Best Practices

Extract the plan's primary domain and approach. Build web search queries:
- Query A: "[approach] best practices [year]"
- Query B: "[domain] common pitfalls"
- Query C (deep only): "[specific methodology] implementation guide"

| Depth | Web searches |
|-------|-------------|
| `quick` | 0 — skip entirely |
| `standard` | 2 (queries A + B) |
| `deep` | 3-4 (all queries) |

Distill into 3-5 key principles relevant to this plan. These are reused across all passes (no repeat research).

### Step 4: Automated Review Loop

**Announce:** "Running up to [max] automated review passes. Will stop earlier if no critical issues remain or if diminishing returns are detected."

**Initialize state:**
- `pass_number = 1`
- `pass_history = []` (list of {pass, score, red_labels, yellow_labels, fixed, new})
- `upstream_items = []` (accumulated across passes)
- `current_plan = <plan text from Step 1>`

---

**Loop body — repeat until exit condition:**

#### 4a. Launch fresh-context critique

Use the Agent tool with `subagent_type="general-purpose"` and a prompt containing:

1. The full `current_plan` text
2. The 3-5 best practices from Step 3
3. The 6 review dimensions (listed below)
4. The upstream/plan-fixable classification instruction
5. Prior-pass issue summary (compact: labels + statuses only, not full critique text)
6. Required output format

**The 6 review dimensions:**

1. **Pre-mortem** — "It's 3 months later and this plan failed. What were the top 3 causes?"
2. **Completeness** — What's missing that a domain expert would expect?
3. **Feasibility** — Are there steps that depend on unconfirmed resources or approvals?
4. **Best-practice alignment** — How does this compare to standards from the research?
5. **Sequencing** — Are there hidden blockers? Would reordering reduce risk?
6. **Specificity** — Could someone unfamiliar execute each step?

**Upstream/plan-fixable classification instruction (include in subagent prompt):**

> For each issue found, classify its **fixability** alongside its severity:
> - **[Plan-fixable]** — The plan text can be revised to address this (add a step, clarify a section, reorder, add a contingency).
> - **[Upstream]** — This issue originates outside the plan: inconsistent naming conventions across project files, input data format mismatches, tool configuration problems, missing upstream decisions, or infrastructure constraints. Revising the plan cannot fix the root cause; it must be addressed elsewhere. Do NOT generate fix recommendations for upstream issues.
>
> Examples of upstream issues: folder names use mixed conventions (backslash vs underscore vs space), input data arrives in inconsistent formats, a dependency has not been configured yet, a decision by another team is pending.
> Examples of plan-fixable issues: a step is missing, instructions are vague, sequencing creates a hidden blocker, no contingency for a known risk.

**Required subagent output format:**

> Return your review in this exact structure:
>
> STRENGTHS
> 1. [Label] — [Explanation]
>
> WEAKNESSES & GAPS
> [Red] [Plan-fixable] [Short-Label] — [Issue] → Fix: [Recommendation]
> [Yellow] [Upstream] [Short-Label] — [Issue] → Root cause: [Explanation]
> [Green] [Plan-fixable] [Short-Label] — [Issue] → Fix: [Recommendation]
> (Use consistent short labels across passes so issues can be tracked.)
>
> VERDICT
> APPROVE — [Rationale]
>   OR
> REVISE — [Rationale]. See revised plan below.
>
> REVISED PLAN (only if REVISE)
> [Complete revised plan text with [CHANGED] and [NEW] markers on modified/added sections]

**Subagent fallback:** If the subagent fails (timeout, error), perform the review inline using this critic stance:
> You are now the critic, not the planner. Do not rationalize. Your job is to find what's missing, what will break, and what's wishful thinking.

#### 4b. Parse results

From the subagent output, extract:
- Red plan-fixable items (with labels)
- Yellow plan-fixable items (with labels)
- Green items (noted but not scored)
- Upstream items (with labels and root causes)
- Verdict (APPROVE or REVISE)
- Revised plan text (if REVISE)

#### 4c. Compute convergence score

`score = -(3 * count(Red_plan_fixable) + 1 * count(Yellow_plan_fixable))`

Upstream items are excluded from the score. They cannot be fixed by plan revision and should not drive iteration.

#### 4d. Accumulate upstream items

Add any new upstream items to the running list. Deduplicate by semantic similarity against existing items (same root cause = same item, even if worded differently).

#### 4e. Record pass

Add to `pass_history`:
```
{
  pass: N,
  score: <computed>,
  red_labels: [...],
  yellow_labels: [...],
  fixed_from_prev: [...],  // labels present in pass N-1 but absent now
  new_issues: [...],        // labels absent in pass N-1 but present now
  verdict: APPROVE|REVISE
}
```

#### 4f. Check exit conditions (evaluate in this order)

| # | Condition | Trigger | Exit reason |
|---|-----------|---------|-------------|
| 1 | Clean exit | `count(Red_plan_fixable) == 0` | No critical issues remain |
| 2 | Subagent approves | Verdict = APPROVE | Reviewer sees no issues |
| 3 | Deterioration (churn) | Any issue label that was present in pass K, absent in pass K+1, and present again now | Circular changes detected |
| 4 | Score regression | `pass > 1` and `score` worsened by 3+ points vs. previous pass | Plan getting worse |
| 5 | Marginal improvement | `pass > 1` AND `count(Red_plan_fixable) == 0` AND score improved by 0 or 1 point | Diminishing returns |
| 6 | Hard cap | `pass_number == max` | Safety limit reached |

Marginal improvement only fires when Red == 0. If Red items persist, the loop continues until the hard cap, deterioration, or Red items are resolved. This prevents premature stops while critical issues remain.

If an exit condition is met, proceed to Step 5.

#### 4g. Apply revision and loop

If no exit condition is met and the verdict is REVISE:
1. Take the subagent's complete REVISED PLAN output
2. Replace `current_plan` wholesale (no selective merge)
3. If NOT in plan mode and the plan source is a file, write the updated plan to the file
4. Increment `pass_number`
5. Return to 4a

If the verdict is APPROVE but Red items remain (the subagent missed them), override the verdict and continue the loop. Trust the score over the subagent's verdict when they disagree.

#### Budget warning

At pass `max - 1`, if convergence has not been reached, emit:
> "WARNING: Pass [N] of [max] completed. Score: [score] ([R] Red, [Y] Yellow remaining). One pass remains before hard cap."

### Step 5: Generate Final Summary

**Plan-mode behavior:** When in plan mode, write only the final revised plan to the plan file. Display the convergence trajectory and upstream issues inline (not written to any file).

**Normal mode:** If the plan source is a file, write the final plan to the file.

Output the summary in this format:

```
AUTOMATED PLAN REVIEW — [Plan Title]

Reviewing as: Meticulous [role]
Plan source: [file path / plan mode / conversation]
Depth: [quick / standard / deep]
Passes completed: [N] / [max]
Exit reason: [Clean exit | Subagent approves | Deterioration detected | Score regression | Marginal improvement | Hard cap reached]

BEST PRACTICES CONTEXT
[3-5 key principles from Step 3 research]

CONVERGENCE TRAJECTORY
| Pass | Score | Red | Yellow | Fixed | New |
|------|-------|-----|--------|-------|-----|
| 1    | -7    | 2   | 1      | --    | --  |
| 2    | -4    | 1   | 1      | 2     | 1   |
| 3    | -1    | 0   | 1      | 1     | 0   |

ISSUE LOG
- [Label]: [Status across passes]
  Pass 1: [Red] [Description]
  Pass 2: Fixed — [what changed]
- [Label]: persists
  Pass 1: [Yellow] [Description]
  Pass 3: [Yellow] [Still present]

UPSTREAM ISSUES (not fixable by plan revision)
1. [Label] — [Description]. Root cause: [explanation]. Recommended action: [what to change upstream].

FINAL PLAN
[The plan as revised after the last pass, with [CHANGED] and [NEW] markers preserved]
```

If the exit reason is "Deterioration detected," add a DETERIORATION REPORT section:
```
DETERIORATION REPORT
The following issue(s) were fixed in a previous pass but reintroduced:
- [Label] (present in pass [K], fixed in pass [K+1], reintroduced in pass [N])
This suggests revision churn. The plan has been rolled back to the version from pass [K+1] (before the reintroduction).
```

## Examples

```
/review-plan-auto
/review-plan-auto file:~/Documents/project-plan.md
/review-plan-auto max:3
/review-plan-auto depth:deep max:5 focus:feasibility
/review-plan-auto quick max:2
/review-plan-auto role:"clinical trial design specialist" file:~/project/trial-plan.md
```
