---
description: "Close the active (or named) side-task and merge its key results back into main-line. Agent drafts a one-line summary and one-line key finding, gets user confirmation, then invokes close-plan.sh which appends to main-line progress.md + findings.md and archives the side-task directory."
disable-model-invocation: true
allowed-tools: "Bash Read Edit"
---

Close a side-task and merge its essentials into main-line.

Steps:

1. **Resolve the side-task slug:**
   - If the user passed a slug as argument, use it.
   - Else read `.context/.active_plan`; if it names a live side-task dir, use that.
   - Else refuse and list available side-tasks under `.context/`.
2. **Refuse if the target is main-line.** Main-line lives at `.context/` root and cannot be "closed" this way — it is the parent, not a branch.
3. **Draft the two required strings by reading the side-task files:**
   - Read `.context/<slug>/task_plan.md` (Overall Goal, phase list, Done items).
   - Read `.context/<slug>/findings.md` (six buckets, especially Decisions).
   - Read `.context/<slug>/progress.md` (Did log).
   - Compose a **one-line `--summary`** (≤ 25 words) capturing what the side-task did.
   - Compose a **one-line `--finding`** (≤ 30 words) capturing the single most important decision or lesson the main-line needs to remember.
4. **Show both drafts to the user and ask for confirmation or edits.** Do not proceed until the user has explicitly approved the wording. This step is non-negotiable — the merge is append-only and re-running duplicates the entry.
5. **Invoke:**
   ```
   sh ${CLAUDE_PLUGIN_ROOT}/skills/planning-context/scripts/close-plan.sh <slug> \
       --summary "<confirmed summary>" \
       --finding "<confirmed finding>"
   ```
   By default this archives `.context/<slug>/` → `.context/.archived/<slug>/`. Pass `--keep` if the user wants the side-task directory to remain in place for later reference.
6. **Update main-line `handoff.md` Active Side-Tasks table** — flip the row for this slug from `open` to `closed YYYY-MM-DD`, or delete the row if the user prefers a clean handoff.
7. Report to the user: which files were appended (`.context/progress.md`, `.context/findings.md`), what happened to the side-task directory (archived / kept), and confirm that main-line is now active again.

Why this exists:

`close-plan.sh` is deliberately unopinionated — it only takes the two confirmed strings and appends. This command wraps the *drafting + confirmation* contract that the agent must uphold before invoking the merge, so nothing is written to main-line without user approval.

Notes:

- The merge is append-only. Running `/plan-close` twice with different wording produces two entries; the script does not dedupe.
- Main-line `handoff.md` is NOT auto-edited by `close-plan.sh` (its overwrite template is agent-owned). Update the Active Side-Tasks row manually in step 6.
- If the side-task never truly branched off (e.g., you spun it up by mistake and did no real work), consider deleting `.context/<slug>/` directly rather than closing — a merge writes a permanent record.
