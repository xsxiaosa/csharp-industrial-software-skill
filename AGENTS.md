# AGENTS.md

## 角色定位

这是用于 **C# 系列工业软件 / 上位机 / 视觉复检 / 设备通信 / 本地服务** 的 Codex 项目指令。

你需要默认把本仓库当作工业现场软件来处理：稳定性、可维护性、可诊断性、可恢复性优先于“炫技式重构”。

## 默认技术栈

除非仓库已有明确选择，否则按以下默认值设计：

- 语言/运行时：C#，优先稳定 LTS；现有项目默认 `.NET 8`。
- 桌面端：
  - 老项目：WPF + CommunityToolkit.Mvvm。
  - 新模板：Avalonia + CommunityToolkit.Mvvm。
  - 现代 Avalonia UI：可选 Semi.Avalonia + Ursa.Avalonia。
- 服务端：ASP.NET Core，自托管 Kestrel，可部署 Windows Service / systemd / Docker。
- 依赖注入：Microsoft.Extensions.DependencyInjection。
- 日志：NLog；关键设备通信、触发、落盘、判定、上传、状态切换必须有结构化日志。
- 数据库：
  - 本地默认 SQLite + FreeSql。
  - 服务端/生产默认 PostgreSQL。
- 网络请求：
  - 项目已有 RestSharp 时沿用。
  - 新代码优先 HttpClientFactory + 超时 + 重试/熔断策略。
- 对象存储：MinIO / S3 / Cloudflare R2。
- 工业通信：OPC UA、Modbus TCP、Omron FINS、TCP/串口扫码枪、海康工业相机 SDK。
- 部署环境：Windows 10/11/Server、Ubuntu/Debian、Docker Compose。

## 工作方式

1. 修改前先快速识别：
   - 解决方案结构：`*.sln`、`src/`、`tests/`、`Directory.Build.props`、`Directory.Packages.props`、`global.json`。
   - 项目类型：WPF、Avalonia、ASP.NET Core、Worker Service、类库、设备 SDK 包装库。
   - 现有依赖：不要重复引入功能相近的库。
2. 代码变更要小而清晰：
   - 优先局部修复，不做无关大重构。
   - 不能删除业务逻辑、设备协议字段、现场状态码，除非用户明确要求。
   - 修改公共接口时同步更新调用方、测试、文档。
3. 给出可执行结果：
   - 代码要能复制运行。
   - 同时给出 `dotnet restore/build/test/run` 命令。
   - 脚本需求优先给纯脚本，不要夹杂长解释。
4. 工业现场安全默认：
   - UI 线程不能做设备 I/O、图像处理、数据库写入、网络上传。
   - 设备通信必须有超时、取消、重连、心跳、状态机、日志。
   - 相机、PLC、扫码枪、机器人通信必须可模拟，方便无硬件开发与测试。
   - 关键流程必须幂等，避免重复触发、重复上传、重复判定。
5. 用户偏好：
   - 回答直接、实用、命令完整。
   - 少引入商业授权库。
   - 新模板尽量用开源、可长期维护的库。
   - 中文说明优先；代码、类名、接口名使用英文。

## 常用命令

```bash
dotnet --info
dotnet restore
dotnet build -c Release
dotnet test -c Release
dotnet format
```

运行单个项目：

```bash
dotnet run --project src/<ProjectName>/<ProjectName>.csproj
```

发布 Windows 自包含：

```bash
dotnet publish src/<ProjectName>/<ProjectName>.csproj -c Release -r win-x64 --self-contained true -o publish/win-x64
```

发布 Linux Docker 前检查：

```bash
dotnet test -c Release
docker compose config
docker compose build
```

## 代码风格

- 启用 nullable：`<Nullable>enable</Nullable>`。
- 使用 file-scoped namespace。
- 使用 `async/await`，避免 `.Result` / `.Wait()`。
- 长生命周期服务实现 `IHostedService` / `BackgroundService`。
- 所有循环、设备读写、队列消费都支持 `CancellationToken`。
- Options 模式集中配置设备 IP、端口、超时、存储路径、数据库连接字符串。
- 不在代码中硬编码密码、Token、MinIO Key、数据库密码。

## 架构默认分层

推荐结构：

```text
src/
  App.Desktop/              # WPF/Avalonia UI
  App.Server/               # ASP.NET Core API
  App.Agent/                # 工位 Agent / Worker
  App.Application/          # 用例、服务、DTO、接口
  App.Domain/               # 领域模型、枚举、状态机
  App.Infrastructure/       # DB、S3、Kafka、Redis、HTTP
  App.Devices/              # 相机/PLC/扫码枪/机器人抽象
  App.Vision/               # 图像、AI 推理、复检算法
  App.Shared/               # 通用工具、结果类型、错误码
tests/
  App.Tests/
  App.IntegrationTests/
docs/
  architecture.md
  deployment.md
  device-protocols.md
```

## 设备与图像处理规则

- 相机 SDK 包装在独立类库，不要让 UI 或业务层直接引用 SDK 全局对象。
- 图像采集、落盘、AI 判定、上传、UI 显示必须解耦为队列/流水线。
- 20MB 级别图像必须注意内存释放、背压、缩略图、异步落盘。
- WPF 显示优先 WriteableBitmap；Avalonia 显示注意 UI 线程调度。
- 海康相机触发、曝光、取流异常必须记录：设备 ID、触发号、TaskKey、耗时、错误码。
- 扫码枪同时支持：
  - 主动触发：上位机发送触发命令。
  - 被动接收：扫码枪主动推送结果。
- PLC/机器人通信必须有清晰握手：Trigger / Ack / Done / Error / Heartbeat。

## 数据规则

- 本地缓存默认 SQLite。
- 复检/审计/服务端默认 PostgreSQL。
- 大图不要进数据库；数据库只存路径、对象存储 Key、元数据、判定结果。
- 图片任务建议：
  - `TaskKey = yyyyMMddHHmmssfff`
  - `Pending/Archive` 目录
  - `task.json` 记录 identifier、locationId、typeNo、overallResult、items。
- 需要迁移数据库且迁移期间有新数据时，优先：
  1. 记录时间点 T0。
  2. 全量备份恢复。
  3. 同步 `CreatedAt > T0` 的增量数据。
  4. 如果存在 update/delete，再设计 CDC 或双写。

## 测试与验证

修改后尽量运行：

```bash
dotnet restore
dotnet build -c Release
dotnet test -c Release
```

如果无法运行测试，说明原因，并至少做静态检查：

```bash
dotnet build
```

设备相关代码要优先提供 Fake/Simulator：

- `FakeCamera`
- `FakeScanner`
- `FakePlcClient`
- `FakeObjectStorage`
- `InMemoryTaskQueue`

## 禁止事项

- 不要把设备 SDK 调用直接写在 ViewModel。
- 不要在 UI 线程执行阻塞 IO。
- 不要无理由引入商业授权库。
- 不要把连接字符串、密钥、IP 白名单硬编码到源码。
- 不要把日志只写到控制台；现场软件必须可落盘。
- 不要吞异常；异常必须带上下文日志。
- 不要在未理解协议/状态机前改动设备握手字段。
