---
name: add-task
description: "Add, pin, or update a task in the user's own Tasks app (the local task-manager-app from github.com/J-Rill/task-manager-app, launched from ~/Desktop/Tasks.app, served at http://localhost:3000). Use whenever the user says \"add this to my to-do list\", \"add to my tasks\", \"put this in my tasks app\", \"remind me to do X by Friday\", \"pin it\", \"mark X done\", or invokes /add-task. Not for Google Calendar events or claude.ai artifact pins unless the user asks for those."
argument-hint: "[what to add] [optional: due date, category, pin]"
allowed-tools: ["Bash"]
---

# Add a task to the user's Tasks app

The user's to-do list is their own local app. The source is `~/Desktop/side_quests/task-manager-app` (GitHub: J-Rill/task-manager-app), and it's launched from `~/Desktop/Tasks.app`. The server listens on `http://localhost:3000`. There's no connector: talk to its JSON API with `curl`.

**Input:** `$ARGUMENTS`, or the task described in the conversation (for example, "add this practice page to my to-do list, due Friday, pinned").

## 1. Make sure the server is up

```bash
curl -s -m 3 -o /dev/null -w '%{http_code}' http://localhost:3000/api/state
```

If that isn't `200`, start the app with `open ~/Desktop/Tasks.app`, wait a few seconds, and retry once or twice. If it still doesn't answer, tell the user and stop. Don't edit `data/db.json` by hand: the live server holds the real data and would overwrite the file.

## 2. Read the categories. Never guess an id.

```bash
curl -s http://localhost:3000/api/state | python3 -c "import json,sys; d=json.load(sys.stdin); [print(c['id'], '|', c['name'], '| archived' if c.get('archived') else '') for c in d['categories']]"
```

Pick the category that matches the task. For example, ECON 5500 / micro coursework goes to "Micro" and macro coursework to "Macro". Skip archived categories. If nothing fits, use "Other". If two categories fit about equally, ask the user.

Before adding, check whether a task with a near-identical title already exists and is still open. If it does, update that task (step 4) instead of creating a duplicate.

## 3. Create the task

Resolve relative dates with the system clock, so you never compute a weekday in your head:

```bash
python3 -c "import datetime as d; t=d.date.today(); print(t + d.timedelta(days=(4 - t.weekday()) % 7 or 7))"  # next Friday, as YYYY-MM-DD
```

Adjust the weekday index (Mon=0 … Sun=6). If today is that weekday, the command above picks next week's; say which date you chose.

```bash
curl -s -X POST http://localhost:3000/api/tasks -H 'Content-Type: application/json' -d '{
  "title": "…",
  "categoryId": "cat_…",
  "dueDate": "YYYY-MM-DD",
  "dueTime": null,
  "pinned": false,
  "priority": "normal",
  "notes": "…"
}'
```

Field notes:
- `title`: short and actionable, in the user's words where possible.
- `dueDate`: `YYYY-MM-DD` or `null`. `dueTime` (`HH:MM`) only when the user gives a time.
- `pinned`: `true` only when the user says to pin it. Pinned tasks show at the top of the app, the menu bar, and the daily digest.
- `notes`: put any artifact URL, local file path, or other context the user will need when doing the task.
- Build the JSON with `python3 -c 'import json; print(json.dumps({...}))'` when the title or notes contain quotes or apostrophes, so the shell doesn't break the payload.

## 4. Update an existing task

```bash
curl -s -X PATCH http://localhost:3000/api/tasks/<id> -H 'Content-Type: application/json' -d '{"pinned": true}'
```

`PATCH` accepts any of `title`, `categoryId`, `dueDate`, `dueTime`, `notes`, `priority`, `started`, `pinned`, `done`. Find the id with `GET /api/state`. Only delete a task (`DELETE /api/tasks/<id>`) when the user explicitly asks.

## 5. Confirm

Check the server's JSON response and reply in one or two lines: the title, category, due date with weekday, and whether it's pinned. For example: "Added 'Micro practice: Finding a Bernoulli Index' to Micro, due Fri Oct 2, pinned."
