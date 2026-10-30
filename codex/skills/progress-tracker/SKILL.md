---
name: progress-tracker
description: >
  Create or update a PROGRESS.md file that captures the current state of a
  working session. Use this skill whenever the user asks to "update progress",
  "log what we've done", "save our status", "write a progress file", or "track
  next steps". Also trigger proactively when a session appears to be wrapping
  up or reaching a natural checkpoint and no PROGRESS.md exists yet. Always use
  this skill instead of writing a progress/status markdown file from scratch.
---

# Progress Tracker Skill

Write or overwrite a `PROGRESS.md` file in the current working directory that
gives anyone, including a future AI session, an instant snapshot of where things
stand.

## File Structure

The file must follow this exact top-to-bottom order:

```markdown
# Progress

_Last updated: <ISO 8601 datetime>_

## Next Steps
<!-- Ordered list. Most immediate action first. -->
1. ...

## Current Obstacles
<!-- Omit this section entirely if there are none. -->
- ...

## What We've Done
<!-- Reverse-chronological. Most recent item first. -->
- ...

## Notes / Context
<!-- Optional. Background, decisions made, links, file paths, etc. -->
```

## Rules

1. Keep `Next Steps` first after the title. A reader should see what to do next
   without scrolling.
2. Include `Current Obstacles` only when there are actual blockers. Do not write
   `None` or leave the section empty.
3. Treat `What We've Done` as a summary, not a transcript. Capture outcomes and
   decisions, not every back-and-forth exchange.
4. Infer from context. Read the full conversation to populate completed work,
   decisions, open questions, blockers, and logical next actions. Ask the user
   only when something critical is genuinely ambiguous.
5. Overwrite rather than append. Each run produces a clean, current file.
6. Confirm before writing if running non-interactively or if an existing
   `PROGRESS.md` is detected and the session context is unclear.

## Steps

1. Review the conversation and relevant repo context.
2. Draft each section following the required structure.
3. Write or overwrite `PROGRESS.md` in the project root or the user's current
   working directory.
4. Print a short confirmation with the file path and a one-line summary of the
   next step.

## Example Output

```markdown
# Progress

_Last updated: 2025-03-14T10:32:00Z_

## Next Steps
1. Wire the `/api/upload` endpoint to the new S3 bucket.
2. Add error handling for oversized files over 10 MB.
3. Write integration tests for the upload flow.

## Current Obstacles
- AWS credentials are not yet provisioned for the staging environment.

## What We've Done
- Scaffolded the Express API with route stubs.
- Decided to use S3 and pre-signed URLs instead of direct server uploads.
- Set up the project repo and installed dependencies.

## Notes / Context
- Repo: `github.com/acme/upload-service`
- Target deploy: Heroku for staging, AWS for production.
```
