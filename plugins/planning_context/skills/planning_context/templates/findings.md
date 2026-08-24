# Findings & Decisions
<!--
  WHAT: Cross-session knowledge base organised BY CATEGORY, not by session.
        Every entry lives under a fixed category and is tagged with the session it came from.
  WHY: Task work spans multiple rounds. Category-first bucketing lets you jump straight to
       "what decisions did we make?" or "what dead ends did we hit?" without re-reading everything.
  WHEN: Update after ANY discovery, especially after 2 view/browser/search operations (2-Action Rule).

  中文导览：
    - 用途：跨会话的分类知识库；按"类"归档，不按"会话"归档。
    - 每一轮工作先在下方 "Sessions Index" 追加一行本轮摘要；之后每条 finding 追加到对应类别下，
      并用 [Session YYYY-MM-DD] 标签指明来源会话。
    - 每 2 次浏览/查看/搜索操作后立即更新（2-Action 规则）。
-->

## Sessions Index
<!--
  Every round of work: append ONE line here first. All entries below reference these via [Session YYYY-MM-DD].
  每一轮对话/任务开始时先在这里追加一行；之后所有分类条目通过 [Session YYYY-MM-DD] 反向引用。
  Format: - [YYYY-MM-DD] one-sentence session summary (goal or topic of this round)
-->

---

## Task Inputs
<!--
  Not findings — these are user-supplied inputs that stay stable across sessions.
  这里不是"发现"，而是用户直接提供、跨会话稳定的输入。
-->

### Requirements
<!--
  拆解自用户请求的可勾选功能需求。/ Functional requirements broken down from the user request.
  Append style: `- [Session YYYY-MM-DD] requirement`
-->

### User Constraints & Preferences
<!--
  用户明确的偏好、硬约束、非目标。/ Explicit preferences, hard constraints, non-goals.
  Append style: `- [Session YYYY-MM-DD] constraint or preference`
-->

---

## Findings by Category

> 每一轮工作只为以下 6 类中**实际出现**的内容追加条目；本轮没有触及的类别就留空，不塞占位符。
> Only append entries for categories that actually occurred this round. Leave the rest empty — no placeholder rows.
> Every entry MUST carry a `[Session YYYY-MM-DD]` tag pointing back to Sessions Index.

### 1. Research
<!--
  WHAT: 文档/网页/代码探索得到的事实性发现（视觉/浏览器多模态见第 6 类）。
  Factual discoveries from docs, code exploration, or text search output.
  Append style: `- [Session YYYY-MM-DD] finding`
-->

### 2. Decisions
<!--
  技术/架构/实现的关键决策 + 理由；agent 拍板 + 用户拍板都要记。`By` 列区分：agent / user
  Key decisions with rationale — both agent- and user-picked. `By`: agent = re-negotiable, user = red line.
-->
| Session | Decision | By | Rationale |
|---------|----------|----|-----------|
|         |          | agent / user |    |

### 3. Issues
<!--
  WHAT: 已解决的问题（比代码 error 更宽，含设计/流程层面的坑）。
  Problems that were actually solved (broader than raw errors; include design/process issues).
-->
| Session | Issue | Resolution |
|---------|-------|------------|

### 4. Dead Ends
<!--
  WHAT: 试过但放弃 / 用户否掉 / 走不通的方向，避免重蹈覆辙。
  Attempts abandoned, designs the user rejected, dead ends future agents must not repeat.
-->
| Session | Attempt / Approach | Result | Do Not Repeat Because |
|---------|--------------------|--------|-----------------------|

### 5. Resources
<!--
  WHAT: 有用的 URL / 文件路径 / API 文档链接。
  Useful URLs, file paths, or API references worth revisiting later.
  Append style: `- [Session YYYY-MM-DD] label — url_or_path`
-->

### 6. Multimodal
<!--
  WHAT: 视觉/浏览器结果转成文字（截图、PDF、渲染网页）。多模态易失，必须立刻落盘。
  CRITICAL — multimodal content evaporates on context reset; capture as text immediately.
  Append style: `- [Session YYYY-MM-DD] what the image/page showed`
-->

---
<!--
  REMINDER — 2-Action Rule + per-round protocol
  1. Every round: append ONE line to `## Sessions Index` before adding entries below.
  2. Every entry under a category MUST carry `[Session YYYY-MM-DD]`, referencing the index.
  3. After every 2 view/browser/search operations, flush pending findings to disk.

  中文提醒：
  - 每轮开始先在 Sessions Index 追加一行本轮摘要
  - 所有分类条目都必须标 [Session YYYY-MM-DD]，指向 Sessions Index 中的会话
  - 每 2 次浏览/查看/搜索操作后必须落盘一次
-->
*Update this file after every 2 view/browser/search operations.*
*每一轮工作先在 Sessions Index 追加一行；之后条目按类别 append，前缀 `[Session YYYY-MM-DD]`。*
