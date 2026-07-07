---
paths:
  - "**/*.py"
  - "**/*.do"
  - "**/*.R"
---

# Script structure and abstractions

Conventions for analysis code (Python, Stata, R). Prioritize correctness and
readability over abstraction.

- Prefer straight-line, top-to-bottom scripts; organize long ones with numbered
  section headers (`# ---- 1. Load data ----`), not functions.
- Don't extract a helper unless the logic is reused 3+ times or a block exceeds
  ~30 lines; inline short operations.
- Numbered top-level scripts (`1-build.do`, `2-clean.py`, `3-analyze.py`) are
  good — don't restructure them into modules or packages.
- Default to functions over classes, but use classes where they fit (Pydantic /
  structured-output schemas for LLM responses, dataclasses for grouped state).
- Don't introduce design patterns (factories, decorators, dependency injection,
  registries) unless asked.
