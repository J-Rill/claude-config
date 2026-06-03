---
name: overleaf
description: Sync local Overleaf project via Git. Use when the user says "overleaf pull", "overleaf push", "pull from overleaf", "push to overleaf", "sync overleaf", or wants to sync a local Overleaf clone.
argument-hint: "pull | push [optional commit message]"
allowed-tools: ["Bash", "Read"]
---

# Overleaf Git Sync

Sync a local clone of an Overleaf project. Overleaf is the Git remote (not GitHub).

`$ARGUMENTS` determines the mode.

## Guard

Before anything, verify this is a git repository:

```bash
git rev-parse --show-toplevel
```

If this fails, report: "Not a git repository. Navigate to your local Overleaf project folder first." and stop.

## Mode: pull

Parse `$ARGUMENTS` — if the first word is `pull`:

1. Check for uncommitted changes:
   ```bash
   git status --porcelain
   ```
2. If output is non-empty, stash first:
   ```bash
   git stash
   ```
3. Pull with rebase (avoids merge commits that Overleaf can't display well):
   ```bash
   git pull --rebase
   ```
   Use a 30-second timeout on this command. If it hangs, report: "Pull timed out — your Overleaf Git authentication token may have expired. Re-generate it at overleaf.com > Account > Git Integration."
4. If changes were stashed in step 2, pop the stash:
   ```bash
   git stash pop
   ```
   If the pop fails (conflict), report the conflict and stop. The user must resolve manually.
5. Report what was pulled (files updated, already up to date, etc.).

## Mode: push

Parse `$ARGUMENTS` — if the first word is `push`:

1. Check for changes:
   ```bash
   git status
   ```
   If the working tree is clean and there is nothing to commit, report "Nothing to push — working tree is clean." and stop.

2. Summarize what will be pushed:
   ```bash
   git diff --stat
   ```

3. Determine commit message:
   - If the user provided text after `push` (e.g., `/overleaf push revised intro`), use that text as the commit message.
   - Otherwise, auto-generate a brief message from the diff stat. Examples: "Update intro and bibliography", "Revise section 3", "Add new figures".

4. Stage all changes. NOTE: `git add -A` is intentional here — Overleaf repos contain only LaTeX project files (no secrets, no node_modules). This overrides the global preference for specific file staging.
   ```bash
   git add -A
   ```

5. Commit with the message:
   ```bash
   git commit -m "$(cat <<'EOF'
   <commit message here>
   EOF
   )"
   ```

6. Push to Overleaf. Use a 30-second timeout to catch authentication hangs:
   ```bash
   git push
   ```
   - On success: report "Pushed to Overleaf successfully." with a summary of what was committed.
   - On rejection (remote has newer commits): automatically pull and retry:
     ```bash
     git pull --rebase
     git push
     ```
     If the retry succeeds, report success. If it fails again, report the error and stop.
   - On timeout: report "Push timed out — your Overleaf Git authentication token may have expired. Your changes are committed locally. Re-generate your token at overleaf.com > Account > Git Integration, then run `/overleaf push` again."
   - On other failure: report "Push failed — changes are committed locally but not pushed. Check the error above and retry with `/overleaf push`."

## No argument or unrecognized

If `$ARGUMENTS` is empty or does not start with `pull` or `push`, show:

```
Usage:
  /overleaf pull              — Pull latest from Overleaf
  /overleaf push [message]    — Stage, commit, and push to Overleaf
```

## Important

- Do NOT warn about committing to master. Overleaf uses a single `master` branch — this is normal.
- Do NOT create branches, remotes, or new repos.
- Do NOT assume GitHub is involved. The remote is Overleaf's Git server.
