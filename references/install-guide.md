# Installation Guide

本 skill 同时兼容多个支持 SKILL.md / AGENTS.md 规范的 AI 编码工具。下面分别给出在 Claude Code、Codex、opencode 等工具中的安装方式。

skill 目录结构（以下步骤均假设你已取得本目录）：

```text
csharp-industrial-software-skill/
├── SKILL.md              # Claude Code / opencode 等读取的入口
├── AGENTS.md             # Codex 读取的项目指令入口
├── references/           # 按需加载的参考文档
├── scripts/              # .NET 环境检查脚本
└── agents/               # Codex/OpenAI 接口元数据
```

---

## 1. Claude Code

Claude Code 通过 `SKILL.md` 顶部 frontmatter（`name` / `description`）识别 skill。

### 用户级安装（所有项目可用）

把整个 skill 目录复制到 Claude Code 的 skills 目录下：

```bash
# Linux / macOS
mkdir -p ~/.claude/skills
cp -r csharp-industrial-software-skill ~/.claude/skills/

# Windows (PowerShell)
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills"
Copy-Item -Recurse csharp-industrial-software-skill "$env:USERPROFILE\.claude\skills\"
```

### 项目级安装（仅当前仓库可用）

把 skill 目录放到仓库的 `.claude/skills/` 下：

```text
<your-repo>/.claude/skills/csharp-industrial-software-skill/
```

### 路径解析

skill 内的引用脚本与 references 在 Claude Code 中相对于 `${CLAUDE_SKILL_DIR}` 解析，无需手动改路径。

---

## 2. Codex

Codex 通过仓库根目录的 `AGENTS.md` 读取项目指令，通过 `.agents/skills/` 加载 skill。

### 仓库级安装

把本包内容放入仓库根：

```text
<your-repo>/
├── AGENTS.md
└── .agents/skills/csharp-industrial-software-skill/
    ├── SKILL.md
    ├── references/
    ├── scripts/
    └── agents/
```

其中 `AGENTS.md` 即本包根目录的 `AGENTS.md`，`csharp-industrial-software-skill/` 目录放 `SKILL.md` 及子目录。然后从仓库根或任意子目录启动 Codex。

### 用户级安装

```bash
mkdir -p ~/.agents/skills
cp -r csharp-industrial-software-skill ~/.agents/skills/
```

可选的全局指令：

```bash
mkdir -p ~/.codex
cp AGENTS.md ~/.codex/AGENTS.md
```

---

## 3. opencode 及其他兼容工具

任何遵循 `SKILL.md` frontmatter 规范（顶层 `name`、`description` 字段）的工具均可加载本 skill。请按所用工具的文档，将本 skill 目录放到其约定的 skills 加载路径下；frontmatter 与目录结构无需修改。

---

## 验证

安装后，用一句自然语言提问确认 skill 已被识别。例如：

```text
使用 csharp-industrial-software skill，帮我生成一个 Avalonia + MVVM Toolkit + FreeSql + NLog 的上位机模板。
```

或直接询问工具加载到的内容：

```text
列出你加载到的 C# 工业软件相关指令和 skills。
```

若工具按本 skill 的分层、设备抽象、MVVM 规则给出回复，说明安装成功。

---

## 备注

- 示例中的项目名 `App.Desktop` / `App.Server` / `App.Agent` 等为占位符，请按实际产品命名替换。
- 海康等硬件 SDK 的使用需遵守对应厂商的授权协议；本 skill 不包含任何 SDK 二进制。
