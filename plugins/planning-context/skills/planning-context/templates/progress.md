# Progress Log
<!--
  以 Session 为单位记录每轮发生了什么、下一步做什么；时间轴粒度 = 一个 Session（date + 摘要），**Session 内不打 HH:MM**。
  刷新时机：每轮工作结束 / 出错 / Phase 收尾 / 用户显式要求更新 / 会话即将结束或 /clear。
  文件分工：task_plan.md 结构层；progress.md 每 session 发生了什么 + Did/Next；findings.md 分类知识；handoff.md 跨断点交接快照。
  Per-session log — one round per heading, no intra-session timestamps.
-->

## Session YYYY-MM-DD - 一句摘要
<!--
  与 task_plan.md 的 `#### [Session YYYY-MM-DD - 摘要]` 同款命名，两文件互相对回；同一天多轮用不同摘要区分。
  Match task_plan.md's session heading so entries cross-reference cleanly.
-->

- **Status:** in_progress
  <!-- pending / in_progress / complete，仅表本 Session 状态。 -->

- **Log:**
  <!--
    action / error / test 混着写，一条一行，**无 HH:MM**（Session 标题即时间轴刻度）。
    需要归属某 Phase → 前缀 `[Phase N]`，不需要就省。files 不记（走 git diff）；一次性 tmp 文件登记到文件末的 Tmp 段。
    Actions / errors / tests all here, one line each. Files → git diff; tmp files → bottom Tmp section.

    示例：
      - [Phase 1] 复制 planning-with-files → plugins/planning-context/，标识全改
      - Edit 报 "File not read yet" → 先 Read 再 Edit，解决
      - `python3 -m json.tool` 通过 marketplace.json / plugin.json / _meta.json
  -->
  - [what happened, one line each]

- **Handoff:**
  <!--
    每 session 常态收尾（不等到跨 agent 交接才写）。真正跨 agent 交接 → handoff.md。
      Did:  本 session 一句话总结（比 Log 粒度更粗）
      Next: 下一 session 的下一步
  -->
  - Did:  [本 session 一句话总结]
  - Next: [下一 session 的下一步]

## Session YYYY-MM-DD - 另一个摘要
- **Status:** pending
- **Log:**
  -
- **Handoff:**
  - Did:
  - Next:

---

## 5-Question Reboot Check
<!--
  五问自检：能全部回答 = 上下文可靠，能有效续跑。常用于长时间未碰 / /clear 后 / 上下文压缩后。
  Reboot test — answering all 5 means context is solid.
-->
| Question | Answer |
|----------|--------|
| Where am I? | Phase X |
| Where am I going? | Remaining phases |
| What's the goal? | [goal statement] |
| What have I learned? | See findings.md |
| What have I done? | See above |
| Is handoff current? | See handoff.md (per-session Handoff.Next in each Session block) |

---

## Tmp / Scratch Files (可删清单)
<!--
  本任务过程中"顺手做出来、跑通就没用"的 tmp / scratch 文件（临时脚本 / 验证 JSON / 调试 dump / mock 假数据…），方便收尾统一清理。
  写出即 append，别拖到最后；真正交付物不进这里。
  Append: `- [ ] path/to/file — 用途 / 何时可删 [Session YYYY-MM-DD]`；清理时勾 `[x]` 并附 "deleted YYYY-MM-DD"。
-->
- [ ] `path/to/tmp_file` — purpose / when-safe-to-delete [Session YYYY-MM-DD]

---
<!--
  Session 层即时间轴；
  Log 混写 action / error / test，一条一行；files 走 git diff，tmp 文件走底部 Tmp 段。
  每 Session 必须有 `Handoff: Did / Next`（常态，不是仅交接才写）；真正跨 agent 交接看 handoff.md。
-->
*Session 层即时间轴；每 Session 至少要有 Log + Handoff (Did/Next)。Tmp 文件登记到"可删清单"。*
