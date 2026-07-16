# my_marketplace

Personal skill marketplace for Claude Code.

## Install

Add the marketplace:

```bash
/plugin marketplace add BetseyW/my_marketplace
```

Install a plugin:

```bash
/plugin install <plugin-name>@my-skills
```

## Plugins

| Plugin | Description |
|--------|-------------|
| manim-draw | Create diagrams and architecture figures using ManimCE with reusable TextBox/NestedTextBox building blocks |
| manimce-best-practices | Best practices for Manim Community Edition - Scene, animations, LaTeX, 3D, styling, CLI |
| tech-note | 整理、精炼技术笔记（伪代码、算法描述等），保留原文增量整理 |
| install-zsh | 安装 zsh、oh-my-zsh 及推荐插件，国内镜像加速 |
| mermaid-draw | Convert Markdown flow descriptions into styled Mermaid flowcharts and rendered PNG/SVG images |
| note-organize | 将分散的技术笔记串联成结构化文档，支持自动归并和大纲引导两种模式 |
| manim-flowchart-draw | Create ManimCE flowchart diagrams for simple linear processes with snake wrapping and CJK/Latin typography |
| answer-no-run | 强制 agent 只回答问题不执行，适用于理解思路和权衡的场景 |
| arxiv-download | 使用国内镜像快速下载 arXiv 论文 PDF |
| wiki | Generate DeepWiki-style repository understanding reports with dependency graphs and reading order |
| review-no-run | 强制 agent 仅展示计划等待审批，同意前绝不执行 |
| planning-with-files | Manus-style file-based planning with task_plan.md, findings.md, progress.md, and handoff.md |

## Structure

```
.claude-plugin/marketplace.json   ← marketplace manifest
plugins/
  <plugin-name>/
    .claude-plugin/plugin.json    ← plugin manifest
    skills/<plugin-name>/SKILL.md ← skill definition
```
