# Task Plan
<!--
  按 Phase → Session 组织的路线图；多步任务开始前必建，每轮更新。
  ⚠️ `## Overall Goal` **只放总目标**（north star，稳定）；阶段目标写进 Phase 标题（`### Phase N: <purpose>`），绝不写这里。
  Roadmap organised by Phase → Session. Overall Goal = north star; phase-level goals live in each Phase heading.
-->

## Overall Goal
<!--
  一段（或一句）描述整个任务的终态。**只放总目标**，阶段目标写到对应 Phase 标题。

  首次写入：用户给出 → 抄录并去口语；没给 → agent 从对话总结，下一轮确认。

  后续变化：
    · 根本性替换（新目标与原目标完全不同）→ 顶部前置新 `**Current**`，加 `[goal updated-YYYY-MM-DD]`；
      旧 Current 降级为 `**Superseded**` 向下顺移。历史条目永不删改。
    · 只是精化 / 加约束 → 就地微调，不新增条目。判据："仍是同一 north star" → 微调；不是 → 走更新流程。
    · 任何更新都要在 progress.md 记一笔 "goal updated: <old> → <new> (reason)"。

  Only records the north star. Fundamental change → prepend new Current, demote old to Superseded. Refinement → edit in place.
-->

**Current** — [YYYY-MM-DD initial | goal updated-YYYY-MM-DD]
[One-paragraph end-state description — filled by user at first invocation, or summarised by agent from conversation.]

<!--
  Superseded 目标按"新在上、旧在下"顺移；不删除，不改写。格式：
    **Superseded** — [goal updated-YYYY-MM-DD]
    [previous overall goal, verbatim]
-->


---

## Update Protocol (每轮更新必读)
<!-- Agent-facing rules — 每轮更新本文件时严格执行。 -->

1. **Locate or create Phase.** 新一轮先决定归属哪个 Phase；不合适就新建（追加到末尾）。Phase 的 `Status:` (pending / in_progress / complete) 本轮变了就更新。

2. **Undone → `#### Pending`（无 session 标签）。** 未做的 = agent 规划的下一步 + 用户"稍后处理"的任务。**无标签即"未做"**，允许多条。

3. **Done → Session 子小节（带 session 标签）。** 本轮完成的追加到 `### [Session YYYY-MM-DD - 摘要]`；Pending 里对应条目 → 迁移（不复制）。标签在子小节标题上，条目本身不重复带。

4. **计划与现实冲突 → 覆写 Pending。** Pending 说 `api1`、实际用 `api2` → 直接把 Pending 里 `api1` 相关条目改写成 `api2`；历史 session 子小节永不重写。改动理由记 progress.md。

5. **Session 命名。** `### [Session YYYY-MM-DD - 一句摘要]`（≤ 20 字，动词开头）。同一天多轮 → 用不同摘要区分（如 "上午 bootstrap" / "下午定制"）。

6. **完成一个 Phase。** 所有 Pending 清空 + 至少一条 Session 子小节 → `Status: complete`。新目标不属于任何现有 Phase → 新建 Phase，别硬塞进已完成的。

---

## Phases

### Phase 1: [一句话说清这个阶段要达成什么 / one-line phase goal]
<!--
  标题即目的：`### Phase N: <purpose>`。本轮改变了状态就更新 `Status`。
  Heading = purpose. Update `Status` when it changes.
-->
- **Status:** pending

#### Pending
<!--
  无 `[Session ...]` 标签 = 未做。来源：agent 规划的下一步 + 用户"稍后处理"。计划变化时就地覆写（见 Update Protocol #4）。
  Untagged bullets = not yet done; rewrite in place when reality overrides.
-->
- [ ] [item]

#### [Session YYYY-MM-DD - 一句摘要]
<!--
  本轮完成的条目放这里；标签在子小节标题上，条目本身不重复带。
  Done items for this round; session tag is on the heading, not per-item.
-->
- [x] [what was done, one line each]

<!--
  下一轮继续做 Phase 1 → 追加一个新的 `#### [Session ...]`，不覆盖历史。
  Next round: append another `#### [Session ...]`; never overwrite prior sessions.
-->

### Phase 2: [一句话说清这个阶段要达成什么]
- **Status:** pending

#### Pending
- [ ] [item]

---

## Decisions
<!--
  跨 Phase / 跨 session 的关键技术/方向决策 + 理由；agent + 用户都要记。`By` 列区分：agent / user
  Cross-phase/session decisions with rationale — both agent- and user-picked. `By`: agent = re-negotiable, user = red line.
-->
| Session | Decision | By | Rationale |
|---------|----------|----|-----------|
|         |          | agent / user |    |

## Errors Encountered
<!--
  真实错误 + 尝试次数 + 最终解法；防止下一 session 重犯。
  Real errors with attempt count and resolution — prevents repeats next session.
-->
| Session | Error | Attempt | Resolution |
|---------|-------|---------|------------|

---

## Reminders
- 每轮开始：先看 **Overall Goal** 一眼，再看当前进入的 **Phase Pending**。
- 每轮结束：Pending 里被本轮完成的条目要迁移到该 Phase 的 `#### [Session ...]` 子小节；未完成但已确认要做的 → 补进 Pending。
- **无 session 标签 = 未做；有 session 子小节归属 = 已做**。这是本文件唯一的 done/undone 判据。
- 计划与现实冲突时，改 Pending，不改历史 session。理由写到 progress.md。
