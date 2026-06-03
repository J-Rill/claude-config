# Claude Code configuration for empirical research

This repository is my personal [Claude Code](https://docs.claude.com/en/docs/claude-code) configuration, organized around the workflow of an empirical economist: ideating projects, reviewing literature, cleaning and analyzing data, writing and compiling papers, and reviewing drafts before submission.

It is a versioned snapshot of my `~/.claude/` directory — the *skills*, *agents*, *commands*, and *rules* that I have accumulated, plus my global coding preferences (`CLAUDE.md`) and editor settings (`settings.json`). Keeping it under version control means the setup is reproducible across machines and the changes I make over time are tracked.

> **What is a "skill"?** In Claude Code, a skill is a self-contained Markdown instruction set (with optional helper scripts) that the agent loads on demand when a task matches its description. Think of each one as a documented, reusable procedure — e.g. "do a literature review" or "compile this LaTeX document" — rather than a one-off prompt.

## Layout

```
.
├── CLAUDE.md        # Global coding preferences (applied to every project)
├── settings.json    # Claude Code editor/runtime settings
├── skills/          # Task procedures, loaded on demand (one folder each)
├── agents/          # Sub-agents that skills can delegate to
├── commands/        # Slash commands
└── rules/           # Standing conventions injected into context
```

This mirrors the structure of `~/.claude/`, so installation is essentially "put these files where Claude Code expects them" (see [Installation](#installation)).

## Skills

Grouped by stage of the research process.

### Research design

| Skill | What it does |
|---|---|
| `research-ideation` | Generates research questions, testable hypotheses, and candidate empirical strategies from a topic or dataset. |
| `solving-model` | Sets up, solves, and verifies an economic model with step-by-step derivations and cross-checking. |

### Literature

| Skill | What it does |
|---|---|
| `lit-review` | Structured literature search and synthesis with citation extraction, thematic clustering, and gap identification. Produces a written review with BibTeX-ready citations. |
| `pdf-chunker` | Reliable chunked extraction for reading, summarizing, or analyzing PDFs of any size. |

### Data analysis

| Skill | What it does |
|---|---|
| `data-analysis` | End-to-end Python pipeline — exploration → cleaning → regression → publication-ready tables and figures. |
| `spot-check` | Randomly samples rows from a script's output and fans out independent sub-agents to verify each result against the input data. |

### Writing and typesetting

| Skill | What it does |
|---|---|
| `compile-latex` | Compiles LaTeX via the `xelatex → bibtex → xelatex → xelatex` pipeline. |
| `overleaf` | Syncs a local clone of an Overleaf project over Git (pull/push). |
| `proofread` | Read-only proofreading pass over `.tex`/`.qmd` files — grammar, typos, overflow, terminology, academic style. |

### Review and verification

| Skill | What it does |
|---|---|
| `review-paper` | Manuscript review with single-pass, adversarial critic–fixer, and simulated peer-review (editor + referees) modes. |
| `review-plan` / `review-plan-auto` | Stress-tests a plan with expert critique; the `-auto` variant iterates until no critical issues remain. |
| `verify-claims` | Runs Chain-of-Verification on a draft in a fresh context, flagging claims as supported, contradicted, or unverifiable. |
| `double-check` | Critical self-review of recent edits — re-reads changed files and verifies referenced symbols, paths, and APIs exist. |
| `strategic-revision` | Builds a dependency-mapped revision plan from referee reports, with a validated DAG and critical-path analysis. |

### Session and workflow utilities

| Skill | What it does |
|---|---|
| `progress-tracker` | Creates/updates a `PROGRESS.md` capturing the state of a working session. |
| `restart` | Writes a structured snapshot before clearing context, so work resumes cleanly in a fresh conversation. |
| `prompt` / `prompt-only` | Reformats an informal request into a structured prompt (and optionally executes it). |
| `skill-creator` | Creates, edits, and benchmarks skills. |
| `import-codex-skills` | Imports skills from a Codex install (`~/.codex/skills/`) into Claude Code. |

## Agents

| Agent | Role |
|---|---|
| `claim-verifier` | Fresh-context fact-checker for citations and numerical claims (used by `verify-claims`). |
| `r-reviewer` | Reviews R scripts for correctness, reproducibility, and convention compliance. |

## Commands

| Command | Role |
|---|---|
| `check-merge` | Reviews the most recent merge/join in a script for correctness. |

## Rules

Standing conventions kept short and injected into context: `content-invariants`, `post-flight-verification`, and `r-code-conventions`.

## Installation

Clone the repository, then make Claude Code's config directory point at it. The simplest approach is to symlink each piece into `~/.claude/` so updates here propagate automatically:

```bash
git clone https://github.com/<your-username>/claude-config.git
cd claude-config

# Back up anything you already have, then link these in:
for item in skills agents commands rules CLAUDE.md settings.json; do
  ln -sfn "$(pwd)/$item" "$HOME/.claude/$item"
done
```

Prefer to copy instead of symlink (so local edits don't touch the repo)? Replace the `ln -sfn` line with `cp -R`. Either way, **back up your existing `~/.claude/` first** if you already have a configuration you care about — these names will overwrite same-named files.

`settings.local.json` is intentionally git-ignored: it holds machine-specific overrides that should not be shared.

## License

Personal configuration shared as-is, with no warranty. Reuse anything you find useful.
