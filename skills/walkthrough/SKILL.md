---
name: walkthrough
description: "Pedagogical HTML explanation of major work just completed — a single self-contained page that walks the user through everything that was done, optimized for human understanding. Use after a substantial implementation, pipeline build, or analysis, when the user says \"walk me through what you did\", \"explain what you did / what happened here\", \"help me understand this change\", or invokes /walkthrough. For small changes, a chat explanation serves better than this skill. Produces a teaching document (goal, big-picture map, step-by-step whys, one worked example, how to verify), NOT a changelog or commit narrative."
---

# Walkthrough — teach the work, don't log it

Build one self-contained HTML page that teaches a knowledgeable colleague what was just done and why, as if they stepped away during the work and need to genuinely understand it — not skim a summary of it. The test of success: after reading, they could explain the work to someone else and check it themselves.

**Input:** `$ARGUMENTS` — optional scope (e.g., "the citation sweep", a commit range, a script name). If empty, cover the major work of the current session.

**Skip condition:** if there is no substantial work in scope (a one-line fix, a lookup, a config tweak), say so and explain in chat instead — don't build a page for a trivial change.

---

## Step 1: Reconstruct from ground truth, not memory

Before writing a word of HTML, re-establish what actually happened:

- Re-read the files you created or changed **as they exist on disk now**; for committed work, use `git log`/`git diff` over the relevant range.
- Collect the real numbers (row counts, runtimes, hit rates, coefficients) from output files or logs — never from memory, never invented. Every number on the page must be reproducible from an artifact you can name.
- Note the dead ends and mid-course corrections that shaped the result (a rejected approach is often the most instructive part).
- If part of the work can't be verified from disk (e.g., a one-off query whose output wasn't saved), say so on the page rather than reconstructing it confidently.

## Step 2: Plan the pedagogical arc

Order sections by **logical dependency, not chronology** — what the reader must understand first, not what you happened to do first. Pick the single most illuminating concrete case in the work and plan to trace it end-to-end; one fully-worked example teaches more than three summarized ones.

## Page structure

Include these sections (rename freely; numbered for reference, not as a mandated order — arrange them to match the logical arc from Step 2). Drop a section when it's genuinely empty for this work, or when Calibration says the work doesn't warrant it:

1. **TL;DR** — 3–5 sentences: what was built/found, the headline numbers, what the reader should do with it. A reader who stops here should not be misled.
2. **The goal** — what was asked, and why it mattered in the project's terms.
3. **The big picture** — a diagram of the pipeline/architecture showing where each piece fits, built with plain HTML/CSS (boxes + arrows via flexbox), so it renders identically in a browser and as an Artifact. One diagram, not four.
4. **The walkthrough** — numbered steps. For each: *what* was done, *why* (the reasoning, including what would have gone wrong otherwise), *what it produced* (file path, row/col counts), and a one-line concrete example of the transformation (input → output).
5. **Key decisions** — for each judgment call: the decision, the alternatives actually considered, why this one won, and how confident to be. This is where the reader learns to disagree intelligently.
6. **One worked example** — the chosen concrete case traced through every step, with real values at each stage.
7. **What changed on disk** — inventory table: path, new/modified, role, and which section of the page explains it.
8. **How to verify** — the commands or spot-checks the reader can run to confirm the headline claims without redoing the work.
9. **Caveats and open questions** — assumptions, known fragilities, anything unverified. Honest and specific ("X was checked only on post-2010 docs"), not boilerplate.
10. **Glossary** — only the jargon the page actually uses, one line each. Skip if the page needed no jargon.

## Writing rules

- Audience: a smart colleague in the user's field who did **not** watch the session and may not be a programmer. Plain English first; code and regexes shown, then said in words.
- Define every acronym and project-specific codename at first use. Never reference the session ("as discussed above", "the earlier scan").
- Every abstract claim gets a concrete instance from the actual work immediately after it.
- Numbers carry denominators and units ("87 of 582,556 docs", not "87 docs").
- Failures and surprises are content, not embarrassments — include what didn't work and what it taught.
- No self-congratulation, no padding, no narration of tool mechanics ("then I ran grep…"). Teach the *work*, not the *session*.

## HTML craft rules

- One file, fully self-contained: inline CSS, no external scripts, fonts, or images (data: URIs only). It must render from a plain `file://` open and survive an Artifact's strict CSP.
- No `<!DOCTYPE>`, `<html>`, `<head>`, or `<body>` wrapper tags — start the file directly with a concise `<title>`, then `<style>`, then the body markup. Browsers auto-promote this into a valid document on a `file://` open, and the Artifact tool supplies its own wrapper (double-wrapping breaks its theme toggle).
- Readable defaults: body text in a centered column (~70ch max-width), 1.5–1.6 line height, real headings, generous whitespace.
- Support light and dark themes: `@media (prefers-color-scheme: dark)` as the base signal, plus explicit `:root[data-theme="dark"]` AND `:root[data-theme="light"]` overrides so an Artifact viewer's theme toggle wins in both directions.
- Progressive disclosure: deep-dive material (full code listings, long tables, the complete decision log) goes inside `<details>` blocks so the main read stays linear and short.
- Code blocks and wide tables scroll horizontally inside their own container; the page body never scrolls sideways.

## Delivery

1. Write the file to the session scratchpad as `walkthrough_<topic>_<yyyy-mm-dd>.html`.
2. If the Artifact tool is available, publish it (loading the `artifact-design` skill first, per that tool's contract) and give the user the private URL **and** the file path. Otherwise give the file path alone.
3. If the user asks to keep it, copy it into the project at a location they name — don't drop HTML into a repo unprompted.
4. Close with a 2–3 sentence chat summary of what the page covers and where it lives — don't duplicate the page's content in chat.

## Calibration

Scale the page to the work: a multi-day pipeline earns the full structure (~1,000–2,500 words plus diagram and tables); a contained change earns a short page (TL;DR, brief walkthrough, verify, caveats). Never pad a small change into a big document — a padded walkthrough hides the signal exactly like a padded changelog.
