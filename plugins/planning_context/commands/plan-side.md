---
description: "Open a side-task under .context/<slug>/. Side-tasks are less-important branches off the main-line plan; they inherit main-line context (handoff auto-injected) and merge back via /plan-close. Main-line always lives at .context/ root — never touched by this command."
disable-model-invocation: true
allowed-tools: "Bash Read"
---

Open a new side-task branching off the current main-line plan.

Steps:

1. **Verify main-line exists.** If `.context/task_plan.md` does not exist, refuse — direct the user to run `init-session.sh` first to establish main-line.
2. **Nesting guard.** If `.context/.active_plan` already points at a live side-task directory, refuse. Tell the user to close it (`/plan-close`) or return to main-line (`set-active-plan.sh main`) before opening another.
3. **Confirm with the user before creating.** Show the proposed slug and confirm it should be a *side-task*, not a new phase on main-line. Never auto-create.
4. **Parse args:** everything after `/plan-side` is the side-task name (may be multiple words). If empty, ask the user for a name.
5. **Invoke** `sh ${CLAUDE_PLUGIN_ROOT}/skills/planning_context/scripts/init-session.sh "<name>"`. This:
   - creates `.context/YYYY-MM-DD-<slug>/{task_plan,findings,progress,handoff}.md`,
   - writes `.context/.active_plan = <slug>` so the side-task becomes active,
   - inherits main-line context via `inject-plan.sh`, which auto-injects `.context/handoff.md` (main-line) alongside the side-task's own files on every UserPromptSubmit.
6. **Update main-line handoff** — append a row to the "Active Side-Tasks" table in `.context/handoff.md` (status = open, one-line note = why this side-task was spun up). This is the pointer the next main-line resume relies on.
7. Report to the user: the new slug, its path, that it's now the active plan, and that `/plan-close <slug>` merges results back.

Why this exists:

The core planning-context contract distinguishes *adding a phase* (a same-line continuation) from *opening a side-task* (a less-important branch that shouldn't clutter main-line). Under the "ask before init" rule, the agent must never quietly create a new plan directory; `/plan-side` is the explicit user-approved entry.

Notes:

- Main-line always lives at `.context/` root. `/plan-side` never modifies main-line's four files (except appending one row to `handoff.md`'s Active Side-Tasks section).
- Side-tasks inherit main-line context automatically via the hook — the agent does not need to manually copy anything. Main-line `findings.md` and `task_plan.md` are readable on demand from `.context/`; only `handoff.md` is auto-injected each turn.
- Nested side-tasks (`.context/side-a/side-b/`) are forbidden. The hook rejects them and `init-session.sh` refuses when `.active_plan` already points somewhere.
