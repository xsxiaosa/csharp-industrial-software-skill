# C# Industrial Software Skill

一个面向 **C#/.NET 工业软件** 开发的 AI 编码助手 Skill，覆盖工业上位机、HMI/SCADA、机器视觉复检、设备通信、本地/服务器服务的统一开发规范。

适用于 Claude Code、Codex、opencode 等兼容 `SKILL.md` / `AGENTS.md` 规范的 AI 编码工具。

---

## 这是什么

工业现场软件对稳定性、可维护性、可诊断性、可恢复性的要求远高于普通业务系统。本 Skill 把这些工业场景下的最佳实践固化为一份可直接加载的规范，让 AI 编码助手在面对以下任务时给出一致、可靠、可运行的方案：

- 工业上位机、HMI、SCADA、设备控制桌面程序（WPF / Avalonia）。
- `CommunityToolkit.Mvvm` 的 MVVM 开发（属性、命令、校验、消息）。
- ASP.NET Core 自托管服务、工位 Agent、复检平台。
- 海康工业相机、扫码枪、PLC、OPC UA、Modbus TCP、Omron FINS、机器人通信。
- 图像采集、AI 判定、人工复检、任务队列、对象存储流水线。
- FreeSql / SQLite / PostgreSQL / MinIO(S3) / Kafka / Redis。
- Docker Compose、Windows Service、Linux systemd 部署。

核心原则：**稳定性优先**——每个设备操作都有超时、取消、重连、结构化日志；每个长循环接受 `CancellationToken`；每个外部依赖有接口和 Fake 实现。

---

## 适用平台

| 工具 | 入口文件 | 说明 |
|---|---|---|
| Claude Code | `SKILL.md` | 通过 frontmatter `name`/`description` 识别 |
| Codex | `AGENTS.md` + `.agents/skills/` | 项目指令 + skill 目录 |
| opencode 等 | `SKILL.md` | 兼容 frontmatter 规范的工具均可 |

详细安装步骤见 [`references/install-guide.md`](references/install-guide.md)。

---

## 目录结构

```text
csharp-industrial-software-skill/
├── README.md                                  # 本文件
├── LICENSE                                    # MIT
├── SKILL.md                                   # Skill 入口与默认规范（Claude Code / opencode）
├── AGENTS.md                                  # Codex 项目指令入口
├── references/                                # 按需加载的参考文档
│   ├── csharp-solution-architecture.md        # 推荐解决方案分层
│   ├── industrial-device-abstractions.md      # 设备接口、状态枚举、PLC 握手信号
│   ├── install-guide.md                       # 多平台安装指南
│   ├── testing-and-review.md                  # 验证命令、测试分类、审查清单
│   └── wpf-avalonia-mvvm.md                   # CommunityToolkit.Mvvm 完整模式与模板
├── scripts/
│   ├── check-dotnet-env.ps1                   # Windows 环境检查
│   └── check-dotnet-env.sh                    # Linux/macOS 环境检查
└── agents/
    └── openai.yaml                            # Codex/OpenAI 接口元数据
```

参考文档按需加载：只在任务触及某主题时才阅读对应文档，不要一次性全部预读。

---

## 安装（摘要）

### Claude Code

```bash
mkdir -p ~/.claude/skills
cp -r csharp-industrial-software-skill ~/.claude/skills/
```

### Codex

把 `AGENTS.md` 放仓库根，skill 目录放入 `.agents/skills/`，或复制到 `~/.agents/skills/` 用户级目录。

### opencode 等

按所用工具的 skills 加载路径放入即可，frontmatter 无需修改。

完整步骤与验证方法见 [`references/install-guide.md`](references/install-guide.md)。

---

## 快速使用

安装后，直接用自然语言描述任务即可触发，例如：

```text
使用 csharp-industrial-software skill，帮我设计一个带海康相机触发、PLC 握手、
图像落盘 + AI 判定 + 上传 MinIO 的工位采集服务，给出分层结构和关键接口。
```

```text
用 CommunityToolkit.Mvvm 写一个相机面板 ViewModel，要求连接/断开/拍照命令带 CanExecute，
后台设备事件 marshal 到 UI 线程。
```

Skill 激活后会先检查 .NET 环境并扫描仓库结构，再按规范给出方案与可运行命令。

---

## 技术栈概览

| 领域 | 默认选型 |
|---|---|
| MVVM | `CommunityToolkit.Mvvm` 8.x（partial property 需 .NET 9 / C# 13+） |
| 依赖注入 | `Microsoft.Extensions.DependencyInjection` |
| 配置 | `Microsoft.Extensions.Options` |
| 日志 | `NLog` |
| 本地数据库 | `FreeSql` + SQLite |
| 服务端数据库 | PostgreSQL |
| HTTP | `HttpClientFactory`（已有 `RestSharp` 可沿用） |
| 条码 | `ZXing` / `IronBarcode` |
| 对象存储 | S3 兼容（MinIO / R2） |
| 桌面 UI | WPF（老项目）/ Avalonia（新跨平台模板） |
| Avalonia 样式 | Semi.Avalonia + Ursa.Avalonia |
| 工业通信 | OPC UA、Modbus TCP、Omron FINS、TCP/串口扫码枪、海康相机 SDK |

避免引入商业授权库，除非用户明确接受。

---

## License

MIT，见 [`LICENSE`](LICENSE)。

## 免责与说明

- 文档中的项目示例名 `App.Desktop` / `App.Server` / `App.Agent` 等为**占位符**，请按实际产品命名替换。
- 本 Skill 仅包含规范文档与脚本，不含任何第三方硬件 SDK（如海康 MVS）二进制；使用对应 SDK 需遵守各厂商授权协议。
- Skill 内容不针对任何特定公司或个人产品，可自由用于个人与商业项目。
