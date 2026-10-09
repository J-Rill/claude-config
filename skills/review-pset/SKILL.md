---
name: review-pset
description: Check a problem set's answers for mistakes. Launches one Codex (GPT 5.6 Sol) reviewer per problem to flag MAJOR / BORDERLINE / MINOR issues, then Claude independently verifies every MAJOR and BORDERLINE flag before reporting. Use when the user says "review my pset", "check my problem set", "/review-pset", or asks to find mistakes in homework answers.
argument-hint: "[pset number | answers:path] [assignment:path] [problems:1,3] [effort:medium|high]"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "Agent"]
---
# Review Pset

*v1.0 — Codex reviews each problem; Claude verifies the serious flags*

## Step 0: Parse arguments

| Arg | Example | Default |
|---|---|---|
| pset number | `3` | ask if nothing else identifies the pset |
| `answers:` | `answers:"pset_answers/PS3 Micro.pdf"` or image paths | `pset_answers/PS{N}*.pdf` |
| `assignment:` | `assignment:"psets/ECON 5500 Assignment 3.pdf"` | `psets/*Assignment {N}*.pdf` |
| `problems:` | `problems:1,3` | all problems |
| `effort:` | `effort:high` | `medium` (Codex config default) |

If either file can't be found or several match, ask the user which one to use. Don't guess.

## Step 1: Prepare inputs (in the session scratchpad)

1. Extract problem statements: `pdftotext -layout "<assignment>" -`. Split them into problems using the assignment's own headings (e.g. "Problem 3."). Keep the sub-parts together with their problem.
2. Render the answers: `pdftoppm -png -r 150 "<answers>" <scratch>/ans`. If the answers are already images, use them directly.
3. Map pages to problems: look at each page (Read the PNG, or a low-res `-r 50` render for large files) and note which problem(s) it covers. A page that spans two problems goes to both. If a page can't be placed, give it to every reviewer.
4. Show the user the map (problem → pages) in one compact line per problem, then continue. Don't wait for confirmation.

## Step 2: Launch one Codex reviewer per problem, in parallel

**2a. Write one prompt file per problem.** Create `prompt_<id>.txt` in the scratchpad for each problem before launching anything, using this template:

```
You are grading a first-year PhD student's handwritten answer to one problem-set question.
Review ONLY Problem <id>. The exact problem statement is:
<<<
<verbatim problem text, including all sub-parts>
>>>
The attached images are the student's answer pages (they may contain other problems; ignore those).

Check every sub-part for correctness and completeness against the question as worded. That means
the math, the logic of each proof step, whether each property the question asks for is actually
shown, notation and definitions, and arithmetic.

Classify each issue:
- MAJOR: wrong result, invalid or missing proof step, a sub-part not answered, or the wrong object
  answered (e.g. a claim about the utility function when the question asks about the preference).
  Would lose substantial credit.
- BORDERLINE: a justification that is incomplete or hand-wavy, an unstated assumption, or something
  that may or may not lose credit.
- MINOR: typos, notation slips, or arithmetic that doesn't change the conclusion.

Output exactly this, and nothing else:
## Problem <id>
For each issue, one line:
[MAJOR|BORDERLINE|MINOR] (<sub-part>, <image filename, e.g. ans-05.png>, <where on the page, quoting the student's text>) <what is wrong> — <why, in 1-2 sentences>
If a sub-part has no issues, write: (<sub-part>) no issues.
Do not write out a full corrected solution.
```

**2b. Launch the reviewers.** Only after every prompt file exists. Use the binary at `/Users/jr2794/.local/bin/codex` (fall back to `which codex`). Launch all problems in one Bash call so they run concurrently. Each review can take several minutes, so run that call with `run_in_background: true` and wait for its completion notification (don't use the default 2-minute timeout). Known gotchas: append `< /dev/null` or the command hangs, pass `--skip-git-repo-check`, put the prompt BEFORE the `-i` flags, and in zsh build the `-i` list as an array.

```bash
cd "<scratch>"
run_review() {  # $1 = problem id, remaining args = page PNGs
  local pid="$1"; shift
  local args=(); for f in "$@"; do args+=(-i "$f"); done
  /Users/jr2794/.local/bin/codex exec --skip-git-repo-check --sandbox read-only --ephemeral \
    -c model_reasoning_effort="<effort>" \
    -o "review_${pid}.md" "$(cat "prompt_${pid}.txt")" "${args[@]}" < /dev/null > "log_${pid}.txt" 2>&1
}
# use the exact names from `ls ans*.png`: pdftoppm pads page numbers only to the width of the total page count
run_review 1 ans-1.png ans-2.png &
run_review 2 ans-3.png &
wait
```

Once the batch has finished, read each `review_<id>.md`. If a run failed or the file is empty, check `log_<id>.txt`, rerun that one problem once, and tell the user if it fails again.

## Step 3: Verify every MAJOR and BORDERLINE flag yourself

Codex flags are claims, not findings. For each MAJOR or BORDERLINE flag:

1. Reread the exact problem wording from Step 1, not from memory. Check which object each requested property applies to.
2. Look at the student's page image yourself and find the quoted text.
3. Redo the relevant math or logic independently.
4. Give the flag one verdict:
   - **Confirmed MAJOR** / **Confirmed BORDERLINE**: the issue is real at that severity.
   - **Downgraded** (e.g. MAJOR → BORDERLINE or MINOR) or **Upgraded**: the issue is real, but the severity is wrong. Say why.
   - **False positive**: the answer is actually correct, or Codex misread the handwriting. Say what Codex got wrong.

Report MINOR flags as given and mark them unverified. Don't spend verification effort on them.

## Step 4: Report

For each problem:

| # | Verdict | Sub-part | Page | Issue | Why / hint |
|---|---|---|---|---|---|

- **Page** is the page number in the answers PDF where the error appears (`ans-05.png` → p. 5); use a range like "pp. 14–15" if it spans pages, and "—" for something missing entirely (e.g. an unanswered sub-part). For MAJOR/BORDERLINE flags, confirm the page when you look at the image in Step 3 — don't copy Codex's page blindly.
- List confirmed MAJOR first, then BORDERLINE, then downgraded, then unverified MINOR.
- Put false positives in a separate short list, so the user can see what was checked and cleared.
- End with a summary: how many flags there were, how many were confirmed, and the 1-3 things to fix first.
- Describe each error and give a hint toward the fix. Don't write out full corrected solutions unless the user asks, and follow any tutoring rules in the project's CLAUDE.md.
- Follow the project's math-formatting rules for any equations in the report.
