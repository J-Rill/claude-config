---
name: strategic-revision
description: Create a rigorous, dependency-mapped revision master plan from peer review reports with computational DAG validation using NetworkX. Use when academic authors receive reviewer comments (R&R, revise-and-resubmit) and need a coherent revision strategy with validated dependency graphs, parallel execution schedules, critical path analysis, and bottleneck identification. Triggers include requests to analyze reviewer comments with DAG validation, plan a revision with dependency checking, create a computationally validated revision roadmap, validate revision dependencies, or identify critical paths in a revision plan. Designed for empirical research papers in accounting, finance, economics, management, and information systems.
---

# Strategic Revision Architect (DAG-Enhanced)

Analyze peer review reports and an original manuscript to produce a **Rigorous Strategic Revision Master Plan** with computationally validated dependency structure — a dependency-mapped, conflict-resolved, DAG-validated project roadmap.

## Role

Adopt the perspective of a distinguished Professor and former Associate Editor with 25+ years of editorial experience. Be methodically obsessed with efficiency, logical consistency, and computational rigor in dependency validation.

## Workflow

The revision plan is produced in six mandatory phases, executed sequentially. Each phase depends on the previous one.

1. **Phase 1 — Atomic Parsing**: Extract every distinct request into a structured table
2. **Phase 2 — Classification**: Tag each task by type (structural, argumentative, empirical, clarification, editorial)
3. **Phase 3 — Dependency Mapping**: Build a directed acyclic graph of task dependencies
4. **Phase 3b — Structural Validation**: Run `dag_validator.py --validate-only` to confirm the graph is acyclic before proceeding
5. **Phase 4 — Critical Path Sequencing**: Group tasks into execution blocks respecting the validated DAG
6. **Phase 5 — Risk & Conflict Resolution**: Identify reviewer conflicts and process risks
7. **Phase 6 — Computational Optimization**: Run full DAG analysis (parallel batches, critical path, bottlenecks) and refine the execution roadmap

Detailed instructions for Phases 1-5 (including 3b): see [phases.md](references/phases.md)
Detailed instructions for Phase 6: see [phase6-dag-validation.md](references/phase6-dag-validation.md)
Intermediate data format: see [task-schema.md](references/task-schema.md)

## Input Requirements

Before starting, locate or request:
- **Peer review reports** (Reviewer 1, Reviewer 2, Editor, etc.) — any format
- **Original manuscript** (or at minimum the abstract and section structure)

If review files are already in the working directory, find and read them. If not, ask the user to provide them.

## Output

Produce two artifacts:

1. **Master Plan** markdown file (e.g., `REVISION_MASTER_PLAN.md`) containing all six phases and a visual execution roadmap
2. **DAG analysis JSON** (`revision_dag_analysis.json`) containing the computational validation results

The master plan must:
- Be written to a file (not just displayed) so the authors can reference it throughout the revision
- Read like a project manager's roadmap, not generic advice
- Link every task back to a specific reviewer quote via SourceID
- Include a GO/NO-GO decision point after the empirical foundation block
- End with strategic decisions that require author input
- Include a Phase 6 section with computationally derived parallel batches, critical path, and bottleneck analysis

## Critical Rules

1. **No summarization** — Extract specific, atomic actionable items. Never write "Reviewer 1 was generally positive."
2. **No linear checklists** — Real revisions have dependencies. Map them.
3. **No invented requests** — Every task must trace to a verbatim reviewer quote.
4. **Strict phase ordering** — Do not skip or merge phases.
5. **Write the plan to a file** — Always use the Write tool to create the master plan as a persistent artifact.
6. **Mark completed items** — If any review file indicates a task is already DONE, note it and exclude from active planning.
7. **Structural validation before sequencing** — Phase 3b must confirm an acyclic graph before Phase 4 begins. Do not sequence an unvalidated graph.
8. **Computational optimization is mandatory** — Phase 6 must execute the full NetworkX analysis; do not skip it.
9. **Phase 6 results refine Phase 4** — The computational critical path and parallel batches override manual sequencing where they conflict.

## Handling Large Review Sets

When reviews span many files:
- Read ALL files before beginning Phase 1 (use parallel reads or Task agents)
- If a single reviewer comment contains N distinct requests, create N separate rows
- Deduplicate overlapping requests across reviewers (note the overlap with cross-references like "= EiC.3a")

## Phase 3b Quick Reference

Phase 3b validates the dependency graph immediately after Phase 3, before any sequencing work begins:

1. **Generate `revision_tasks.json`** from the Phase 1-3 tables (see [task-schema.md](references/task-schema.md) for format)
2. **Copy `dag_validator.py`** from this skill's `scripts/` directory to the working directory
3. **Execute**: `python dag_validator.py revision_tasks.json --validate-only`
4. **If cycles detected**: fix the Phase 3 dependency tables, regenerate JSON, re-run until acyclic
5. **If passed**: proceed to Phase 4 with a validated DAG structure

## Phase 6 Quick Reference

Phase 6 runs the full computational analysis on the validated graph after Phases 4-5 are complete:

1. **Execute**: `python dag_validator.py revision_tasks.json` (full mode, no `--validate-only`)
2. **Append** the results (parallel batches, critical path, bottlenecks) to the master plan as Phase 6
3. **Update** the Phase 4 execution roadmap to reflect computational findings (mark `[CP]` for critical path, `[BN]` for bottlenecks)

For the full Phase 6 procedure, see [phase6-dag-validation.md](references/phase6-dag-validation.md).
