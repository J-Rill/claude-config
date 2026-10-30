---
name: prose-revision
description: Revise unpolished draft prose by finding the best structure for the ideas the writer already wants to express — idea flow first, wording second. Diagnoses ordering, emphasis, sentence boundaries, transitions, and paragraph shape before smoothing language, and preserves the substantive claims. Distinct from proofreading (final copyediting of a near-done draft). Use when user says "revise this", "improve the flow", "restructure this paragraph", "tighten this", "make this read better", "this paragraph is awkward", or hands over rough draft prose to reshape.
---

<!-- Source: prose-revision skill by Anthony Lee Zhang. -->

# Prose Revision

## Purpose

Revise draft prose by finding the best structure for the ideas the user already wants to express. The goal is clear logical movement supported by natural, elegant language: idea flow first, linguistic flow second.

Prose revision is different from proofreading. Prose revision takes a relatively unpolished draft and gets the prose into good shape. Proofreading takes a close-to-done draft and catches mistakes, typos, obvious phrasing problems, and final copyediting issues. Proofreading may flag passages that need prose revision, but prose revision logically comes first.

## Default Stance

Assume the user usually has the right set of ideas and wants help discovering the best structure for those ideas. Be willing to revise aggressively at the level of order, emphasis, sentence boundaries, transitions, and paragraph shape, while preserving the substantive claims.

Do not add or subtract ideas by default. Add a missing idea, remove an idea, or move an idea out of the paragraph only when it is clearly necessary for the paragraph to work. When doing so, make that intervention explicit.

Treat awkward sentences as evidence of a possible idea-flow problem, not merely a bad-English problem. A sentence is often awkward because it is trying to do two jobs at once, because the previous sentence did not prepare it, or because the paragraph's logical order is not yet right.

## Workflow

1. Read the target prose and enough context to understand the local argument.
2. Identify the paragraph's intended job: the claim, contrast, mechanism, qualification, implication, or transition it needs to deliver.
3. Diagnose idea flow before wording. Look for ideas in the wrong order, overloaded sentences, missing connective tissue, premature qualifications, buried main claims, or a final sentence that belongs earlier.
4. If the idea structure prevents good flow, explain that structural problem first. Do not try to solve structural confusion with surface-level polish.
5. Rearrange and repack the existing ideas into a clearer logical sequence. Then make the language smoother, cleaner, and more elegant.
6. Offer revised versions that make different tradeoffs when useful: conservative, moderate, or more polished. Keep explanations concise and focused on why the structure works.
7. If the user asks to apply edits, edit the source file rather than generated outputs, and preserve notation, citations, labels, author notes, and technical claims unless the user explicitly asks to change them.

## What To Improve

Prioritize changes that improve the reader's path through the ideas:

- Put the main point where it can organize the rest of the paragraph.
- Split sentences that are doing multiple logical jobs.
- Combine sentences when separation makes the logic choppy.
- Move qualifications after the claim they qualify, unless the qualification must come first for accuracy.
- Add transitions only after the underlying relation between ideas is clear.
- Replace vague connective language with the actual logical relation: contrast, mechanism, implication, caveat, example, or consequence.
- Prefer precise, economical wording once the idea structure is sound.

## Output Style

For short interactive requests, usually provide:

1. A brief diagnosis of what is limiting the flow.
2. Two or three revised versions, if alternatives would help.
3. A short note on the tradeoff among versions.

For longer documents, provide a structured revision report unless the user asks for direct edits.

Keep line-level proofreading comments out of prose-revision responses unless they materially affect flow or clarity.
