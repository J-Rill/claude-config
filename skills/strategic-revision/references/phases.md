# Phase Instructions

Detailed instructions for Phases 1-5 (including 3b) of the Strategic Revision Master Plan.

## Phase 1: Atomic Parsing ("Raw Data")

Read every sentence of every review file. Extract every distinct request — no matter how small — as a separate row.

### Output Format

Markdown table with columns:

| SourceID | Quote | Atomic Task |
|----------|-------|-------------|
| R1.3 | "verbatim or abbreviated quote" | Imperative action verb + specific deliverable |

### Rules

- **SourceID convention**: `{Reviewer}.{CommentNumber}{SubLetter}` — e.g., `R1.a1`, `EiC.2b`, `R2.d3`
- If a single paragraph contains 3 distinct requests, create 3 rows
- Use the reviewer's own words in the Quote column (abbreviated if long, but preserve meaning)
- Restate every task in imperative form: "Add…", "Rewrite…", "Run…", "Justify…", "Create…"
- If a task is marked DONE in the review file, note it and exclude from active planning
- Cross-reference duplicate requests across reviewers (e.g., "= EiC.3a")

## Phase 2: Classification ("Taxonomy")

Tag each Atomic Task from Phase 1 with exactly one category.

### Categories

| Tag | Category | Description | Examples |
|-----|----------|-------------|----------|
| 🔴 | STRUCTURAL | Moving sections, cutting text, reorganizing | Relocate interviews to intro; cut tangential material |
| 🟠 | ARGUMENTATIVE | Changing theory, narrative, logical framing, contribution | Reframe contribution; integrate disclosure theory; strengthen motivation |
| 🟡 | EMPIRICAL | New regressions, data work, robustness tests, variables | Add control variable; run sub-sample analysis; test alternative model |
| 🟢 | CLARIFICATION | Definitions, explaining confusing text, justifications | Define "cybersecurity governance"; justify measure choice; explain null finding |
| 🔵 | EDITORIAL | Formatting, typos, figure labels, terminology consistency | Fix Figure 2 labels; standardize terminology; add table notes |

### Output Format

Markdown table with columns: `Task ID`, `Category`, `Atomic Task (short)`.

Include a summary count table at the end.

## Phase 3: Dependency Mapping ("DAG")

Identify relationships between tasks. Treat this as building a Directed Acyclic Graph.

### Relationship Types

1. **Upstream Blocker**: "I cannot do Task B until Task A is finished."
   - Example: Cannot rewrite Discussion until new regressions are done
   - Example: Cannot create measure-mapping table until each measure is conceptually justified
   - Example: Cannot tighten front-end until decisions about what moves in/out are made

2. **Collateral Risk**: "If I do Task A, it might make Task B irrelevant or contradictory."
   - Example: Adding a new control variable may change coefficient significance, invalidating current interpretations
   - Example: Pre/post textual similarity may show firms just relocated text, undermining contribution

### Output Format

**Table 1: Upstream Blockers**

| Downstream Task | Blocked By (Upstream) | Impact / Rationale |
|-----------------|-----------------------|--------------------|

**Table 2: Collateral Risks**

| If You Do This Task… | It May Affect… | Risk Description |
|-----------------------|----------------|------------------|

### Common Dependency Patterns in Empirical Papers

- New control variables → re-run regressions → re-interpret results → rewrite discussion
- Theory reframing → rewrite introduction → rewrite conclusion
- New sub-analyses → inform alternative explanations → revise discussion
- Structural moves (relocate sections) → tighten other sections → final narrative pass
- The overall narrative reframe is ALWAYS the final capstone task

## Phase 3b: Structural Validation ("Gate Check")

Validate the Phase 3 dependency graph computationally before investing effort in sequencing. This is a fail-fast gate: if the graph contains cycles, Phase 4 work would be built on a broken foundation.

### Procedure

1. **Generate `revision_tasks.json`** from the Phase 1-3 tables using the schema in [task-schema.md](task-schema.md). Block assignments are not yet needed — use `"block": "?"` as placeholder.
2. **Run**: `python dag_validator.py revision_tasks.json --validate-only`
3. **Interpret the output**:
   - **PASSED**: The graph is acyclic. Proceed to Phase 4.
   - **FAILED**: A cycle exists. The output shows the cycle path (e.g., `A -> B -> C -> A`).

### If Cycles Are Detected

Return to the Phase 3 tables and resolve:

| Common Cause | Fix |
|-------------|-----|
| Collateral risk encoded as hard dependency | Move from `depends_on` to `collateral_risks` — risks are informational, not structural |
| Bidirectional dependency (A blocks B AND B blocks A) | Determine which task truly must come first; remove the reverse edge |
| Transitive chain through merged tasks | Split the merged task into two sequential tasks, or remove the redundant edge |
| Copy-paste error in task IDs | Verify IDs match exactly between `depends_on` references and task keys |

After fixing, regenerate `revision_tasks.json` and re-run `--validate-only`. Repeat until the graph passes.

### Output

Add a brief validation confirmation to the master plan after Phase 3:

```markdown
### Phase 3b: Structural Validation

DAG validated: N tasks, M dependencies, no circular dependencies detected.
Proceed to Phase 4.
```

## Phase 4: Critical Path Sequencing ("Schedule")

Group tasks into sequential Execution Blocks based on the DAG. Violations of the critical path are not permitted.

### Standard Block Sequence

| Block | Name | Contents | Gate |
|-------|------|----------|------|
| **A** | Empirical Foundation | Core variable changes, new controls, re-estimation of main regressions | **GO/NO-GO**: If key conclusions change, escalate to authors before proceeding |
| **B** | Sub-Analyses & Robustness | Cross-sectional tests, sub-samples, alternative specifications, robustness checks | Results feed into Block C interpretations |
| **C** | Theoretical Reframing | Theory integration, contribution restatement, measure justifications, null-finding explanations | Must incorporate Block A & B results |
| **D** | Narrative Construction | Structural reorganization, section moves, rewriting Intro/Discussion/Conclusion | Depends on settled theory (C) and stable results (A, B) |
| **E** | Polish | Figures, tables, formatting, terminology audit | Last |

### Output Format

For each block, list tasks in priority order:

| Priority | Task ID(s) | Action | Rationale |
|----------|-----------|--------|-----------|

End with an ASCII execution roadmap showing the block flow.

### Adaptation

The standard sequence works for most empirical papers. Adapt when:
- The paper has no empirical component → skip Block A, start at C
- Theory is the primary concern → expand Block C, potentially merge A+B
- The paper is primarily editorial in nature → compress to Blocks D+E

## Phase 5: Risk & Conflict Resolution ("Strategy")

### 5.1 Reviewer Conflicts

Identify direct conflicts between reviewers (e.g., R1 says "Expand section," R2 says "Cut section").

| Conflict ID | R1 Position | R2 Position | Resolution Strategy |
|-------------|-------------|-------------|---------------------|

Resolution strategies:
- **Cut-and-replace**: Remove what R2 dislikes, add what R1 wants (net-neutral length)
- **Appendix**: Move detailed material to appendix (satisfies both)
- **Strategic choice + defend**: Pick one direction, explain in response letter why
- **Reframe**: Find a framing that satisfies both without contradiction

### 5.2 Process Risks

Identify risks that could derail the revision.

| Risk ID | Description | Likelihood | Impact | Mitigation |
|---------|-------------|-----------|--------|------------|

Common process risks in empirical paper revisions:
- New control variable changes main results
- Sub-sample analysis has insufficient power
- Data for requested variable is unavailable
- Excluding observations reduces sample substantially
- Alternative model produces divergent results
- Paper length increases beyond journal limits

### 5.3 Strategic Decisions

Identify decisions that require author input (not autonomous resolution).

| Decision | Options | Recommendation |
|----------|---------|----------------|

Always provide a clear recommendation with rationale, but flag these for the authors rather than deciding unilaterally.
