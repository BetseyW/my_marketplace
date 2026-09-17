# planning-context

Personalised planning + context-recording skill derived from `planning-with-files`.
Treats planning and progress-logging as equal peers: the context window is volatile
RAM, the filesystem is persistent disk, so **anything important gets written to disk**.

## Four-file planning set

| File | Role |
|------|------|
| `task_plan.md` | Overall Goal + Phase → Session hierarchy; Pending / Done split; Decisions & Errors tables. Single source of truth for phase status. |
| `findings.md` | Task Inputs plus six accumulated buckets (Research / Decisions / Issues / Dead Ends / Resources / Multimodal). Append-only across sessions. |
| `progress.md` | Per-session Log with Did / Next entries and a trailing Tmp cleanup list. Chronological, append-only. |
| `handoff.md` | Overwrite snapshot (nine-section template). The fastest resume-entry point after `/clear` or compaction. |

## What the hooks do

- **UserPromptSubmit** — re-injects task_plan head + handoff head + progress tail so the agent stays oriented every turn.
- **PreToolUse** — injects task_plan head before each tool call (legacy mode only; autonomous / gated mode drops recitation).
- **PostToolUse** — after every Write / Edit, reminds the agent to update ALL FOUR planning files.
- **Stop** — runs `check-complete.sh` (advisory in legacy / autonomous, blocking in gated) plus handoff-freshness advisory.
- **PreCompact** — before `/compact` or autocompact, requires updating ALL FOUR planning files so on-disk state is the source of truth after compaction.

## Slash commands

| Command | Purpose |
|---------|---------|
| `/plan-side [name]` | Open a side-task under `.context/<slug>/`. Inherits main-line handoff automatically; agent must ASK before invoking. |
| `/plan-close [slug]` | Close a side-task: agent drafts one-line summary + finding, user confirms, then merges into main-line progress/findings and archives. |
| `/plan-attest` | Lock the current `task_plan.md` with a SHA-256 attestation; hooks reject injection if the file diverges. |
| `/plan-goal [clauses]` | Compose Claude Code's `/goal` with a "all phases complete" termination condition. |
| `/plan-loop [interval] [prompt]` | Compose Claude Code's `/loop` with a planning-aware default tick. |

## Main-line and side-tasks (v1.2.0)

- Main-line always lives at `.context/`. Side-tasks (less-important branches, opened only after user confirmation) live flat at `.context/<slug>/`. No nesting.
- When a side-task is active (`.context/.active_plan` points at its slug), the hook auto-injects the main-line `handoff.md` head alongside the side-task's own files, so the side-task retains main-line memory. Main-line `task_plan.md` and `findings.md` are read on demand.
- Resolution order: `$PLAN_ID` env → `.context/.active_plan` → main-line `.context/`. No newest-mtime fallback.
- Closing merges the side-task's key summary + finding back into main-line `progress.md` / `findings.md` (tagged `[from side: <slug>]`) and archives `.context/<slug>/` to `.context/.archived/<slug>/`.
- SKILL Rule 8 requires the agent to ASK before running `init-session.sh` or appending a structural phase — "add phase" vs "open side-task" is never auto-decided.

## Trigger keywords

Chinese: 规划 / 拆分 / 复盘 / 交接 / 上下文记录 / 进度日志 / 会话归档
English: planning / breaking down / retrospective / handoff / context logging / progress log / session archival
Automatic: any task expected to span more than 5 tool calls, or resumption after `/clear`.

## Modes

- **Legacy** (default) — full plan injected every turn and every tool call.
- **`--autonomous`** — drops PreToolUse recitation; adds structured ledger summary + default SHA-256 attestation. For strong models on long tasks.
- **`--gated`** — autonomous plus Stop-hook completion gate (5-guard decision table with runaway caps).

Init via `sh scripts/init-session.sh [--autonomous|--gated] [Side-task name]`. No name → main-line at `.context/`. Named → side-task at `.context/<date>-<slug>/`. Switch with `set-active-plan.sh <slug>` or `set-active-plan.sh main` (return to main-line); pin a terminal with `PLAN_ID` env var.

## Further reading

- [SKILL.md](SKILL.md) — full skill definition, Critical Rules, mode contracts.
- [references/reference.md](references/reference.md) — Manus principles.
- [references/examples.md](references/examples.md) — worked walkthroughs.
- [references/planning-context-SKILL-cn.md](references/planning-context-SKILL-cn.md) — earlier Chinese SKILL authoring, kept as translator reference.
