# Handoff
<!--
  断点续跑（/clear / auto-compact / "继续" / 跨 agent 接管）的入口简报——一眼看清"现在在哪、下一步做什么"。
  **覆写式快照，非累积**；历史流水 → progress.md，累积知识 → findings.md，结构层 → task_plan.md。
  刷新时机：会话结束 / /clear 前 / 压缩前 / 阶段切换 / 重大决策后 / 用户显式要求 / 交接前。
  Fast context-recovery brief for any resume scenario. Overwrite snapshot, not a log.
-->

## Snapshot

- **Date:** [YYYY-MM-DD]
- **Overall goal:** [总目标：从 task_plan.md 顶部的 `Current` 条目抄录 / 浓缩得来；必要时可再精简一句]
- **Story so far:** [1-3 句浓缩描述——从任务建立到现在整体做过哪些事的一段脉络，让续跑者立刻有全景感]
- **Current objective:** [one sentence — 眼下这一小段的目标]
- **Current phase:** [Phase X — 简写即可；**详见 task_plan.md**]
- **Status:** [in_progress | blocked | ready_for_validation | complete]
- **Branch:** [branch name or unknown]
- **Working tree:** [clean | dirty | unknown; summarize important modified/untracked files]

## User Intent / Constraints
<!--
  当前仍在生效的用户偏好 / 硬约束；findings.md 对应段是累积历史，本节是浓缩快照。
  Current-in-force preferences and constraints; findings.md holds the accumulated history.
-->
-

## What Happened Since Last Refresh
<!--
  自上次刷新以来的浓缩要点；Done = 已落地不用重做，Unconfirmed / Undone = 续跑者第一步大概率要处理的入口。
  流水看 progress.md，全部待办看 task_plan.md 的 Pending。
  Since last refresh: Done = landed; Unconfirmed / Undone = likely next-step entry points.
-->

### Done
-

### Unconfirmed / Undone
-

## Key Files

| Path | Why it matters | Current state |
|------|----------------|---------------|
|      |                |               |

## Decisions Made
<!--
  当前仍在生效的关键决策；agent + 用户都要记，`By` 列区分：agent = 可再讨论，user = 红线。历史累积看 findings.md #2。
  Current-in-force decisions — both agent- and user-picked. `By`: agent = re-negotiable, user = red line. History → findings.md #2.
-->

| Decision | By | Reason | Consequence |
|----------|----|--------|-------------|
|          | agent / user |    |    |

## Failed / Avoided Approaches
<!--
  当前仍需避开的失败尝试 / 被否方案（含"软失败"：慢命令、被否设计、依赖冲突等）；只列 top 几条，别抄整份历史。
  `Red line?`: Y = 硬红线绝不再碰，N = 只是不推荐。历史累积看 findings.md #4。
  Current-in-force do-not-touch list. `Red line?`: Y = hard no, N = merely not preferred. History → findings.md #4.
-->

| Attempt / Approach | Result | Red line? | Do Not Repeat Because |
|--------------------|--------|-----------|-----------------------|
|                    |        | Y / N     |                       |

## Known Issues / Blockers / Open Questions
<!--
  值得挂在续跑者眼前的 issues（含已解决 + 未解决）；`Status`: Resolved = 一句话防重踩，Open = 第一步大概率要处理。
  完整历史看 findings.md #3。
  Watch list — both resolved and open. `Status`: Resolved = reminder to prevent re-tripping, Open = handle first. Full history → findings.md #3.
-->

| Issue | Status | One-line summary / current state |
|-------|--------|----------------------------------|
|       | Resolved / Open |                        |

## Next Best Step
<!--
  上一次收尾时 agent 判断的下一步候选（1-3 条），**不等于"必须照做"**。续跑时：
    · 交互模式（默认）：agent 再分析全局 → 向用户确认后再动手，下面几条只作参考。
    · 自动模式：按 agent 自己判断走，下面作起手参考。
  Interactive (default): re-analyse and confirm before acting. Autonomous: proceed on agent judgment; list is a reference.
-->

1.
2.
3.

## Validation
<!--
  续跑加载完 handoff、动手之前的自检——验证快照是否与现实一致（覆写式快照易被外部变动搞过期）。
  典型条目：关键命令（git status / build / test）、关键文件是否存在且一致、外部依赖是否可用、手动确认项。
  全部通过 → 按 Next Best Step 推进；任一失败 → 先用真实状态覆盖 Snapshot / What Happened 再动手。
  Sanity checks before acting; any failure → handoff is stale, realign before proceeding.
-->

- [ ] [command / check]
- [ ] [command / check]
- [ ] [manual review / check]

## Links to Details
<!-- 一句关键词说清"该翻哪一份"，避免续跑者盲翻。 -->

- **`task_plan.md`** — Overall Goal · Phases · Pending/Done Sessions
- **`findings.md`** — Requirements · Constraints · Lessons & Knowledge
- **`progress.md`** — Detailed progress Log
