---
name: prompt
description: Format an informal, conversational request into a structured prompt, then execute it. Use when user invokes /prompt with a task description.
argument-hint: "[informal request text] [depth:light|standard|deep]"
allowed-tools: ["Read", "Glob", "Grep", "Write", "Edit", "Bash", "Agent"]
---
# /prompt — Format and Execute

*v3.0 — Two-phase skill: format first, execute second*

Format an informal request into a structured prompt, then execute it.

## Reference Files
@./references/formatting-core.md
@./references/roles.md

## Input
$ARGUMENTS

## Why This Skill Exists

Users often dictate informal, rambling requests. This skill adds value by *reformulating* those requests into clear, structured prompts before acting on them. If you skip the reformulation and jump straight to doing the task, the skill has added zero value — the user could have just typed the request directly. The formatted prompt is the product of Phase 1. Treat it like a deliverable, not a mental note.

## Phase 1: Format (produce visible output)

Your first job is to produce a formatted prompt and display it. Nothing else. Do not begin working on the underlying task yet.

1. **Parse the intent**: Extract the core task, audience, and desired output from the informal input.

2. **Auto-select role**: Check the request against the trigger signals in roles.md. If a role matches, include it. If none fits or the task is trivial, omit.

3. **Calibrate depth** using the heuristic in formatting-core.md:
   - **Light** (default): Format only. No depth injection.
   - **Standard**: Format + append assumptions/rationale block.
   - **Deep**: Format + append research/compare/verify block.
   - User can override with `depth:light`, `depth:standard`, or `depth:deep`.

4. **Format into a structured prompt** using the formatting elements in formatting-core.md. Match formatting complexity to task complexity — a 1-sentence ask doesn't need a 20-line prompt.

5. **Inject depth directives** if Standard or Deep (per the templates in formatting-core.md). For Light, skip.

6. **Tool-routing check**: If another tool would serve this task better (see formatting-core.md), add a brief note.

7. **Output the formatted prompt in a fenced code block.** This is the deliverable of Phase 1. It looks like this:

```
📋 Formatted prompt:
```
[your formatted prompt here]
```
```

Phase 1 ends here. You have now produced visible output that the user can see and review.

---

## Phase 2: Execute

Now — and only now — execute the formatted prompt as if the user had typed it directly. Use Claude Code tools (MCP, file access, search) as needed.

**Exception — plan mode**: If plan mode is active, do Phase 1 only. Show the formatted prompt, design the plan, and wait for user approval. Do not execute.

**Exception — hold**: If the user says "hold", "don't run", or "just format", do Phase 1 only.

## Clarification

Ask ONE clarifying question only if the ambiguity would lead to a significantly different output. Otherwise, make reasonable assumptions and proceed through both phases.
