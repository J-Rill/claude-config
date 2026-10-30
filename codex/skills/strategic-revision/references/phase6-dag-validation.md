# Phase 6: Computational DAG Optimization

Run the full computational analysis on the validated dependency graph, then use the results to refine the execution roadmap from Phase 4.

> **Note**: Acyclicity validation is handled by Phase 3b (`--validate-only` mode) before Phases 4-5. By the time Phase 6 runs, the graph is already confirmed acyclic. Phase 6 focuses on scheduling optimization: parallel batches, critical path, and bottleneck identification.

## Prerequisites

- Phases 1-5 (including 3b) must be complete
- `revision_tasks.json` must exist with updated `block` fields from Phase 4
- Python and NetworkX must be available (`pip install networkx` if missing)

---

## Step 6.1: Update `revision_tasks.json` with Block Assignments

The `revision_tasks.json` file was first generated in Phase 3b with `"block": "?"` placeholders. Now that Phase 4 has assigned execution blocks, update the `block` field for each task to its assigned letter (A, B, C, D, E).

The `depends_on` and `collateral_risks` fields should remain unchanged from Phase 3b — only `block` values need updating.

---

## Step 6.2: Execute the Full Analysis

Run the script in full mode (without `--validate-only`):

```
python dag_validator.py revision_tasks.json
```

Or with a custom output path:

```
python dag_validator.py revision_tasks.json --output my_analysis.json
```

The script produces:
- **Console output**: structured summary (task count, batches, critical path, bottlenecks, block analysis)
- **JSON file**: `revision_dag_analysis.json` with complete analysis data including `impact_details` for high-impact tasks

### If the Script Fails

- **File not found**: Verify `revision_tasks.json` exists in the working directory
- **Invalid JSON**: Check for syntax errors (trailing commas, unquoted keys)
- **Unknown task in depends_on**: A task references a dependency that does not exist as a key — fix the task ID or add the missing task
- **Cycle detected**: This should not occur if Phase 3b passed. If it does, a Phase 4 edit introduced a new dependency. Return to Phase 3b and re-validate.

---

## Step 6.3: Integrate Results into the Master Plan

Read `revision_dag_analysis.json` and add a Phase 6 section to the master plan with the following subsections.

### 6.3.1 Parallel Execution Schedule

From the `parallel_batches` field. Format as:

```markdown
### Parallel Execution Schedule (Computationally Derived)

**Batch 1** (N tasks — no prerequisites, can begin immediately):
- task_id_1: description [Block X] CATEGORY
- task_id_2: description [Block X] CATEGORY

**Batch 2** (N tasks — requires Batch 1 completion):
- task_id_3: description [Block X] CATEGORY
...
```

Compare with Phase 4 block assignments. If the computational batches show that tasks from different blocks can run in parallel, note this as an optimization opportunity.

### 6.3.2 Critical Path

From the `critical_path` field. Format as:

```markdown
### Critical Path (Computationally Derived)

Length: N sequential tasks (minimum revision timeline)

1. task_id_1 — description
2. task_id_2 — description
   ...
N. task_id_N — description

Any delay on these tasks delays the entire revision. Prioritize accordingly.
```

If the computational critical path differs from the Phase 4 manually identified sequence, note the discrepancy and recommend following the computational result.

### 6.3.3 Bottleneck Tasks

From the `bottlenecks` field. Format as:

```markdown
### Bottleneck Tasks (High Downstream Impact)

| Task | Block | Direct Dependents | Total Downstream | Description |
|------|-------|-------------------|------------------|-------------|
```

Cross-reference with Phase 5 process risks. Bottleneck tasks that also appear in the risk table carry compounded risk and deserve explicit mitigation strategies.

### 6.3.4 Block Validation

From the `block_analysis` field. For each block, report:
- Number of tasks and internal edges
- Whether any tasks have external dependencies on later blocks (which would indicate a block ordering problem)

If the block analysis reveals that a Block C task depends on a Block D task, flag this as a block ordering issue that must be resolved.

---

## Step 6.4: Update the Phase 4 Execution Roadmap

After integrating Phase 6 results, revise the Phase 4 ASCII execution roadmap:

1. **Annotate critical path tasks** with `[CP]` marker
2. **Annotate bottleneck tasks** with `[BN]` marker
3. **Add parallel execution notes** where batches show tasks from different blocks can run simultaneously
4. **Adjust block boundaries** if computational analysis reveals that the manual block assignments create unnecessary sequential constraints

### Example Updated Roadmap

```
BLOCK A ─── Empirical Foundation ──────────────────────► GO/NO-GO
  A1: Size control [CP][BN]                                  │
  A2: Analyst coverage [BN]                                  │
  A3: Institutional ownership                                │
  A4: NB/Poisson robustness            ← parallel with A1-A3 │
  A5: Comment letter control                                 │
                                                             ▼
BLOCK B ─── Sub-Analyses & Robustness ─────────────────► New Tables
  B1: Pre/post textual similarity      ← parallel with B2-B6 │
  ...
```

The updated roadmap should reflect both the domain-driven block logic (Phase 4) and the computational optimization (Phase 6). Where they agree, confidence is high. Where they disagree, the computational result takes precedence for scheduling purposes, while the domain logic may still be relevant for narrative coherence.
