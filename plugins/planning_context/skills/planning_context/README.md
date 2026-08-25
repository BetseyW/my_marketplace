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
| `/plan-attest` | Lock the current `task_plan.md` with a SHA-256 attestation; hooks reject injection if the file diverges. |
| `/plan-goal [clauses]` | Compose Claude Code's `/goal` with a "all phases complete" termination condition. |
| `/plan-loop [interval] [prompt]` | Compose Claude Code's `/loop` with a planning-aware default tick. |

## Trigger keywords

Chinese: 规划 / 拆分 / 复盘 / 交接 / 上下文记录 / 进度日志 / 会话归档
English: planning / breaking down / retrospective / handoff / context logging / progress log / session archival
Automatic: any task expected to span more than 5 tool calls, or resumption after `/clear`.

## Modes

- **Legacy** (default) — full plan injected every turn and every tool call.
- **`--autonomous`** — drops PreToolUse recitation; adds structured ledger summary + default SHA-256 attestation. For strong models on long tasks.
- **`--gated`** — autonomous plus Stop-hook completion gate (5-guard decision table with runaway caps).

Init via `sh scripts/init-session.sh [--autonomous|--gated] "Task name"`. Parallel plans live under `.context/<date>-<slug>/`; switch with `set-active-plan.sh` or pin with `PLAN_ID` env var.

## Further reading

- [SKILL.md](SKILL.md) — full skill definition, Critical Rules, mode contracts.
- [references/reference.md](references/reference.md) — Manus principles.
- [references/examples.md](references/examples.md) — worked walkthroughs.
- [references/planning-context-SKILL-cn.md](references/planning-context-SKILL-cn.md) — earlier Chinese SKILL authoring, kept as translator reference.
