---
name: teach
description: "Pedagogical HTML lesson that teaches the user a topic they name — a concept, method, tool, theorem, or paper — optionally grounded in resources they provide (PDFs, papers, code, notes, URLs). Use whenever the user says \"teach me X\", \"I want to learn X\", \"help me understand X\", \"make a lesson on X\", \"explain how X works\" (about a topic, not about work just completed in this session — that's the walkthrough skill), \"teach me X from this paper/these notes\", or invokes /teach. Produces a single self-contained teaching page (motivation, big-picture map, core ideas in dependency order, one worked example, misconceptions, self-check) — NOT a reference dump, textbook summary, or list of bullet points. For a quick factual question, answer in chat instead."
argument-hint: "[topic] [optional: file paths or URLs to base the teaching on]"
allowed-tools: ["Read", "Grep", "Glob", "WebFetch", "WebSearch", "Write", "Artifact", "Skill"]
---

# Teach — build understanding, don't summarize

Build one self-contained HTML page that teaches the user a topic they named, as if you were a good lecturer preparing a lesson for one specific student — not a textbook author writing for everyone. The test of success: after reading, the user could explain the topic to a colleague, apply it to a problem of their own, and recognize when it's being misused.

**Input:** `$ARGUMENTS` — a topic, optionally followed by resources (file paths, URLs). Examples: `/teach instrumental variables with weak instruments`, `/teach the method in this paper ~/Downloads/chetty2018.pdf`.

**Skip condition:** if the ask is really a quick factual question ("what does HC3 mean?"), answer in chat — don't build a page for something a paragraph can teach.

---

## Step 1: Establish the source of truth

Two modes, depending on whether the user provided resources:

**Resources mode** (files or URLs given): Read every resource fully before writing a word of the lesson — files via Read (Glob/Grep to enumerate and navigate a directory of notes), URLs via WebFetch. The resources define the canon — teach *their* version of the topic, with their notation, their examples, their emphasis. Where you supplement from your own knowledge (context the resource assumes, an example it lacks), that's welcome, but keep it distinguishable: the reader should be able to tell "this is what the paper says" from "this is background Claude added." If a resource contradicts what you believe to be true, teach the resource's claim and flag the tension explicitly — don't silently correct it, and don't silently adopt it.

**Knowledge mode** (topic only): teach from your own knowledge. For fast-moving or citation-heavy topics (a literature, a software API, anything post-cutoff), verify the load-bearing facts with WebSearch/WebFetch before asserting them. Never fabricate a citation or attribute a result to a paper you haven't confirmed says it; if a claim is from memory and unverified, either verify it or present it as such.

## Step 2: Calibrate to this learner

You are teaching one person, not an audience. Use what you know about the user — their CLAUDE.md, the project you're in, the conversation — to pick the starting point and the examples:

- Start from what they already know and build the bridge from there. For an economist, teach gradient descent as "hill-climbing on a likelihood"; don't re-derive calculus.
- Choose examples from their world when possible — a lesson on merge conflicts lands better with two versions of a cleaning script than with `foo.txt`.
- Pitch the level honestly: skip what they plainly know, but never skip a genuine prerequisite. If the topic needs a prerequisite they may lack, teach the minimum viable version of it inline rather than assuming or omitting.

## Step 3: Plan the pedagogical arc

- Order sections by **logical dependency**: what must be understood first, not what the textbook chapter order happens to be.
- Pick **one concrete running example** and thread it through the whole lesson — introduce it early, develop it as each idea arrives, and use it for the worked example. One example carried all the way teaches more than five examples used once.
- Decide what to leave out. Scoping is teaching: a lesson on IV that covers everything about IV teaches nothing about IV. Name what you're excluding so the reader knows the map has edges ("we won't cover judge-leniency designs here").
- Identify the 1–3 places learners predictably go wrong (the misconception, the off-by-one, the abused assumption) and plan to confront them head-on rather than hoping the reader avoids them.

## Page structure

Include these sections (rename freely; arrange to match the arc from Step 3; drop a section when it's genuinely empty for this topic):

1. **Why this matters** — 3–5 sentences: what the topic is, what it lets you do, and when the reader will actually reach for it. A reader who stops here should know whether to keep reading.
2. **The big picture** — a diagram or map showing the moving parts and how they relate, built with plain HTML/CSS (boxes + arrows via flexbox), so it renders identically in a browser and as an Artifact. One diagram, not four.
3. **The core ideas** — the lesson body, in dependency order. For each idea: the intuition in plain English first, then the formalism (notation, code, math) if the topic has one, then the running example advanced one step. Small sections with honest headings beat one long scroll.
4. **One worked example** — the running example carried end-to-end with real values at every stage: the setup, each step's input → output, and the interpretation of the result. If the topic is a method, this is a complete application; if a concept, a complete instance.
5. **Where it breaks** — the misconceptions and failure modes from Step 3, each stated as the tempting-but-wrong version first, then why it fails, with a concrete case. This is often the highest-value section.
6. **Check your understanding** — 3–5 questions the reader can answer to test themselves, from "restate the intuition" to "apply it to a new case." Put the answers in a `<details>` block so they can genuinely try first.
7. **Sources and further reading** — resources mode: what was taught from which resource (page, section, or file/line pointers — whatever the resource type allows), and where you supplemented. Knowledge mode: only references you verified or are confident exist; a short honest list beats a long padded one.
8. **Glossary** — only jargon the page actually uses, one line each. Skip if the page needed none.

## Writing rules

- Plain English first, formalism second — every equation or code block is preceded by what it says in words and followed by what it buys you.
- Every abstract claim gets a concrete instance immediately after it. "Weak instruments bias 2SLS toward OLS" is followed by numbers showing it.
- Define every acronym and term of art at first use, even ones the user probably knows — a definition costs one line; a gap costs the lesson.
- Anticipate the reader's "wait, but…" moments and answer them where they occur, not in a FAQ at the end.
- Numbers carry units and denominators; derivations show the step where the work happens rather than "it can be shown."
- No filler enthusiasm ("Let's dive in!"), no narrating the lesson's own structure ("In this section we will…"). The structure should be visible from the headings, not announced.

## HTML craft rules

- One file, fully self-contained: inline CSS, no external scripts, fonts, or images (data: URIs only). It must render from a plain `file://` open and survive an Artifact's strict CSP.
- No `<!DOCTYPE>`, `<html>`, `<head>`, or `<body>` wrapper tags — start the file directly with a concise `<title>`, then `<style>`, then the body markup. Browsers auto-promote this into a valid document on a `file://` open, and the Artifact tool supplies its own wrapper (double-wrapping breaks its theme toggle).
- Math: prefer HTML/Unicode notation (`β̂`, `x²`, `∑`) styled with CSS for inline math; for display equations too complex for that, a `<pre>`-style block with clear plain-text notation is better than broken pseudo-LaTeX. No external math renderers (CSP blocks them).
- Readable defaults: body text in a centered column (~70ch max-width), 1.5–1.6 line height, real headings, generous whitespace.
- Support light and dark themes: `@media (prefers-color-scheme: dark)` as the base signal, plus explicit `:root[data-theme="dark"]` AND `:root[data-theme="light"]` overrides so an Artifact viewer's theme toggle wins in both directions.
- Progressive disclosure: deep-dive material (full derivations, long code listings, proofs) goes inside `<details>` blocks so the main read stays linear and short.
- Code blocks and wide tables scroll horizontally inside their own container; the page body never scrolls sideways.

## Delivery

1. Write the file to the session scratchpad as `teach_<topic>_<yyyy-mm-dd>.html`.
2. If the Artifact tool is available, publish it (loading the `artifact-design` skill first, per that tool's contract) and give the user the private URL **and** the file path. Otherwise give the file path alone.
3. If the user asks to keep it, copy it to a location they name — don't drop HTML into a repo unprompted.
4. Close with a 2–3 sentence chat summary: what the lesson covers, the one thing to remember, and where it lives — don't duplicate the page's content in chat.

## Calibration

Scale the page to the topic: a full method (IV, event studies, a paper's identification strategy) earns the full structure (~1,000–2,500 words plus diagram and worked example); a contained concept earns a short page (why it matters, core idea, one example, where it breaks). Never pad a small topic into a big document — length signals importance, and false signals mis-teach.
