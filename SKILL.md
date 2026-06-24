---
name: csharp-industrial-software
description: C#/.NET industrial upper-computer, HMI/SCADA, machine vision, WPF/Avalonia MVVM, ASP.NET Core, device communication, Hikvision camera, PLC/OPC UA/Modbus/FINS, scanner, FreeSql, SQLite/PostgreSQL, MinIO/S3, Docker deployment. Use when designing, coding, refactoring, reviewing, or debugging C#/.NET industrial software.
---

# C# Industrial Software Skill

## Purpose

Use this skill when the task involves C#/.NET software for:

- 工业上位机、HMI、SCADA、设备控制。
- WPF / Avalonia 桌面程序。
- CommunityToolkit.Mvvm ViewModel 开发。
- ASP.NET Core 自托管服务、工位 Agent、复检平台。
- 海康工业相机、扫码枪、PLC、OPC UA、Modbus TCP、Omron FINS、机器人通信。
- 图像采集、AI 判定、人工复检、任务队列、对象存储。
- FreeSql / SQLite / PostgreSQL / MinIO / Kafka / Redis。
- Docker Compose、Windows Service、Linux systemd 部署。

The user prefers practical, complete, directly runnable answers in Chinese. Code identifiers should remain English.

## References and scripts

This skill ships supporting files. Load them on demand — read a reference only when the task touches its topic; do not preload all of them at once.

Reference documents:

- [`references/csharp-solution-architecture.md`](references/csharp-solution-architecture.md) — recommended solution layout and per-project responsibilities (Domain / Application / Infrastructure / Devices / Vision / Presentation).
- [`references/industrial-device-abstractions.md`](references/industrial-device-abstractions.md) — full device interfaces, `DeviceConnectionState` enum, `ScanResult` / `CameraFrame` records, and the PLC handshake signal set.
- [`references/testing-and-review.md`](references/testing-and-review.md) — default `dotnet` validation commands, recommended test categories, the hardware-test env-var gate, and the review checklist.
- [`references/wpf-avalonia-mvvm.md`](references/wpf-avalonia-mvvm.md) — CommunityToolkit.Mvvm ViewModel patterns: three property-writing styles, command naming, CanExecute/Notify linkage, `ObservableValidator` form validation, `WeakReferenceMessenger`, DI registration, WPF vs Avalonia differences, pitfalls checklist, and a copyable industrial ViewModel template.

Environment-check script — run once at the start of a task to inspect the local .NET SDK and scan the repo for `*.sln` / `*.csproj` / `Directory.*.props` / `global.json` / `docker-compose*.yml`, then restore and build:

- Windows (PowerShell): `scripts/check-dotnet-env.ps1`
- Linux / macOS (bash): `bash scripts/check-dotnet-env.sh`

In Claude Code these paths resolve under `${CLAUDE_SKILL_DIR}`; in Codex use the path relative to the skill folder. If no `*.sln` is found, run from the repository root or pass a project path manually.

## Activation behavior

When this skill is active:

1. Check the .NET environment and scan the repo by running the environment-check script above (`check-dotnet-env.ps1` on Windows, `check-dotnet-env.sh` on Linux/macOS). Skip if the SDK is clearly already known or the user asked for a dry plan only.
2. First classify the project:
   - `Desktop`: WPF / Avalonia.
   - `Server`: ASP.NET Core API.
   - `Agent`: 工位采集、上传、设备通信 Worker。
   - `Library`: SDK 包装、协议、算法、基础设施。
   - `Template`: 新建解决方案模板。
3. Inspect existing conventions before writing code:
   - `*.sln`
   - `*.csproj`
   - `Directory.Build.props`
   - `Directory.Packages.props`
   - `global.json`
   - `appsettings*.json`
   - `docker-compose*.yml`
   - `README.md`
4. Preserve existing architecture unless the user asks for a redesign.
5. Prefer small, reviewable changes.
6. Always include build/test/run commands for generated or changed code.
7. Read the relevant reference only when the task touches its topic (see "References and scripts" above).

## Default design principles

### Stability first

Industrial software must be diagnosable and recoverable:

- Every device operation has timeout, cancellation, reconnect, and structured logging.
- Every long-running loop accepts `CancellationToken`.
- Every external dependency has an interface and a fake implementation.
- Every important state transition is logged.
- Every hardware protocol has a clear handshake and error path.
- Avoid UI-thread blocking.

### Layering

Use this default layering unless the repo already has its own pattern:

```text
Domain          # entities, value objects, enums, state machines
Application     # use cases, services, DTOs, ports/interfaces
Infrastructure  # database, object storage, Kafka, Redis, HTTP, file system
Devices         # camera, PLC, scanner, robot abstractions and SDK adapters
Vision          # image processing, AI inference, region drawing, result merging
Presentation    # WPF/Avalonia views and viewmodels
```

Dependency direction:

```text
Presentation -> Application -> Domain
Infrastructure -> Application
Devices -> Application
Vision -> Application
```

`Domain` should not reference UI, database, SDK, or network libraries.

For the full recommended `src/` layout and per-project responsibilities, see [`references/csharp-solution-architecture.md`](references/csharp-solution-architecture.md).

## Preferred libraries

Use existing project libraries first. For new code, default to:

| Area | Preferred choice |
|---|---|
| MVVM | `CommunityToolkit.Mvvm` 8.x (partial property syntax needs .NET 9 / C# 13+) |
| DI | `Microsoft.Extensions.DependencyInjection` |
| Config | `Microsoft.Extensions.Options` |
| Logging | `NLog` |
| Local DB | `FreeSql` + SQLite |
| Server DB | PostgreSQL |
| HTTP | `HttpClientFactory`; keep `RestSharp` if already used |
| Barcode | Existing `ZXing` / `IronBarcode` usage |
| Object storage | S3-compatible MinIO/R2 client |
| Desktop UI | WPF for existing projects; Avalonia for new cross-platform templates |
| Avalonia style | Semi.Avalonia + Ursa.Avalonia when modern UI is requested |

Avoid commercial dependencies unless the user explicitly accepts them.

## Desktop application rules

### WPF / Avalonia MVVM

Core rules:

- ViewModel uses `ObservableObject`, `[ObservableProperty]`, `[RelayCommand]` from `CommunityToolkit.Mvvm` (`using CommunityToolkit.Mvvm.ComponentModel;` / `Input;` / `Messaging;`).
- ViewModel class must be `partial` (source generator requirement). For the new partial property style, the property must also be `partial`.
- New projects prefer the partial property style: `[ObservableProperty] public partial string Title { get; set; } = "";`. Requires .NET 9 / C# 13+ and recent `CommunityToolkit.Mvvm` 8.x. Legacy projects use the field style: `[ObservableProperty] private string _title = "";` (field convention: `_camelCase`, generator produces the `Title` property).
- Command naming: `[RelayCommand]` on a method generates `<MethodName>Command`, dropping the `Async` suffix — `ConnectAsync` → `ConnectCommand`, `Save` → `SaveCommand`. Async commands return `Task`; never use `async void`.
- CanExecute: `[RelayCommand(CanExecute = nameof(CanConnect))]` plus `[NotifyCanExecuteChangedFor(nameof(ConnectCommand))]` on the driving properties.
- Property linkage and callbacks: `[NotifyPropertyChangedFor(nameof(DisplayName))]` for derived properties; `partial void OnXxxChanged(T value)` (or `(T oldValue, T newValue)`) for side effects — do not hand-write setter logic.
- Form validation: derive from `ObservableValidator`, annotate with `[Required]` / `[Range]` / `[MinLength]`, and use `[NotifyDataErrorInfo]` for automatic XAML validation binding (`ValidatesOnNotifyDataErrorInfo=True`).
- ViewModel-to-ViewModel communication uses `WeakReferenceMessenger`; do not abuse it (same-process only, unregister on teardown).
- Avoid code-behind business logic.
- Use DI to create ViewModels and services (constructor-inject `ICameraService` / `IPlcClient` / `IScannerDevice`).
- Use `ObservableCollection<T>` only on UI thread. For background device events, marshal to UI thread before mutating properties or collections:
  - WPF: `Application.Current.Dispatcher.Invoke(...)`.
  - Avalonia: `Dispatcher.UIThread.Post(...)`.
- Do not expose SDK objects directly to ViewModel; keep protocol parsing in `Devices` / `Application` layers (see Common pitfalls).
- Use DTO/ViewModel models separate from database entities when mapping is non-trivial.

Minimal industrial ViewModel skeleton (partial property style):

```csharp
/// <summary>相机面板 ViewModel。</summary>
public partial class CameraPanelViewModel : ObservableObject
{
    private readonly ICameraService _cameraService;

    /// <summary>构造函数注入相机服务。</summary>
    public CameraPanelViewModel(ICameraService cameraService)
    {
        _cameraService = cameraService;
    }

    [ObservableProperty]
    [NotifyCanExecuteChangedFor(nameof(ConnectCommand))]
    [NotifyCanExecuteChangedFor(nameof(DisconnectCommand))]
    public partial bool IsConnected { get; set; }

    [ObservableProperty]
    [NotifyCanExecuteChangedFor(nameof(ConnectCommand))]
    [NotifyCanExecuteChangedFor(nameof(TriggerCommand))]
    public partial bool IsBusy { get; set; }

    [ObservableProperty]
    public partial string StatusText { get; set; } = string.Empty;

    private bool CanConnect => !IsBusy && !IsConnected;
    private bool CanDisconnect => !IsBusy && IsConnected;
    private bool CanTrigger => !IsBusy && IsConnected;

    /// <summary>连接相机。</summary>
    [RelayCommand(CanExecute = nameof(CanConnect))]
    private async Task ConnectAsync()
    {
        // try/finally 确保 IsBusy 在异常时也能正确重置
        IsBusy = true;
        try
        {
            await _cameraService.ConnectAsync(CancellationToken.None);
            IsConnected = true;
            StatusText = "已连接";
        }
        catch (Exception ex)
        {
            StatusText = $"连接失败: {ex.Message}";
        }
        finally
        {
            IsBusy = false;
        }
    }

    // DisconnectAsync / TriggerAsync 同理
}
```

For the full property-style comparison, command/CanExecute/linkage patterns, `ObservableValidator` form validation, `WeakReferenceMessenger`, DI registration in `App.xaml.cs`, WPF-vs-Avalonia differences, the pitfalls checklist, and a copyable industrial ViewModel template, see [`references/wpf-avalonia-mvvm.md`](references/wpf-avalonia-mvvm.md).

### Image display

For 20MB-level industrial images:

- Avoid keeping too many full-size images in memory.
- Generate thumbnails for list/grid display.
- Dispose image buffers explicitly when SDK requires it.
- UI should show current image and thumbnails from cached/decoded lightweight objects.
- Image capture, save, AI infer, and upload run as separate pipeline stages.

## Device abstraction rules

Always introduce interfaces before SDK implementations.

Example shape:

```csharp
public interface IIndustrialDevice : IAsyncDisposable
{
    string Name { get; }
    DeviceConnectionState State { get; }
    Task ConnectAsync(CancellationToken cancellationToken);
    Task DisconnectAsync(CancellationToken cancellationToken);
}
```

Camera:

```csharp
public interface ICameraDevice : IIndustrialDevice
{
    Task<CameraFrame> TriggerAsync(CameraTriggerRequest request, CancellationToken cancellationToken);
}
```

Scanner:

```csharp
public interface IScannerDevice : IIndustrialDevice
{
    IAsyncEnumerable<ScanResult> ReadResultsAsync(CancellationToken cancellationToken);
    Task TriggerAsync(CancellationToken cancellationToken);
}
```

PLC:

```csharp
public interface IPlcClient : IAsyncDisposable
{
    Task ConnectAsync(CancellationToken cancellationToken);
    Task<PlcReadResult<T>> ReadAsync<T>(string address, CancellationToken cancellationToken);
    Task WriteAsync<T>(string address, T value, CancellationToken cancellationToken);
}
```

For the canonical `DeviceConnectionState` enum, the `ScanResult` / `CameraFrame` records, and the PLC handshake signal set, see [`references/industrial-device-abstractions.md`](references/industrial-device-abstractions.md).

## Device communication checklist

For each camera / PLC / scanner / robot integration, ensure:

- Configurable IP, port, timeout, retry count.
- Connection state: `Disconnected`, `Connecting`, `Connected`, `Reconnecting`, `Faulted`.
- Heartbeat when the protocol supports it.
- Idempotent trigger handling.
- Ack/Done/Error state clearly represented.
- All raw protocol errors mapped to business-level error codes.
- Fake/simulator implementation for development without hardware.
- Integration tests are disabled by default unless environment variables enable them.

## Vision / AI pipeline

Default pipeline:

```text
Trigger received
  -> create TaskKey
  -> capture image(s)
  -> save raw image to Pending
  -> enqueue AI inference
  -> write result json
  -> update UI thumbnail/result
  -> upload image/metadata
  -> archive or mark failed
```

Rules:

- Do not block capture while waiting for AI when throughput matters.
- Use bounded queues for backpressure.
- File names should include TaskKey, camera/position, and OK/NG when available.
- Large images go to file/object storage, not database.
- Store metadata in DB: path/key, product id, type no, position, AI result, manual result, timestamps.
- Logs must include TaskKey / identifier / camera id / station id.

## Database rules

### Local agent

Use SQLite for local resilience:

- Pending tasks.
- Upload retry queue.
- Device snapshots.
- Minimal audit/cache data.

### Server

Use PostgreSQL for central audit/review platform:

- `audit_task`
- `audit_image`
- user/role/permission
- assignment/claim/timeout recycle
- status/version fields for concurrency

### Migration with live inserts

If the user says new data arrives during migration and data is insert-only:

1. Record `T0`.
2. Run full backup.
3. Restore full backup.
4. Sync rows with `CreatedAt > T0`.
5. Verify counts and max timestamps.
6. Switch traffic.

If updates/deletes exist, do not rely only on `CreatedAt`; propose CDC, logical replication, dual-write, or application-level change log.

## ASP.NET Core rules

- Use minimal hosting model.
- Keep controllers/endpoints thin.
- Put business logic in Application services.
- Use health checks for DB, object storage, queue, and downstream services.
- Use structured logs and request correlation id.
- Avoid returning internal exception details to clients.
- Long-running work should use background queue or worker service, not block HTTP request.

## Deployment rules

### Windows

- Desktop app: provide publish command and config file layout.
- Service: use Worker Service + Windows Service integration.
- Logs under configurable directory.

### Linux / Docker

- Prefer Docker Compose for server components.
- Include healthchecks.
- Separate app config from image.
- Do not bake secrets into Dockerfile.
- For no-downtime update, use blue/green or reverse proxy with two app instances.

### Example compose expectations

```yaml
services:
  app:
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 3s
      retries: 3
```

## Testing strategy

Use tests that fit hardware-heavy projects:

- Unit tests for state machines, DTO mapping, parsing, queue behavior.
- Fake device tests for trigger and reconnection.
- Integration tests behind environment variables:
  - `RUN_HARDWARE_TESTS=1`
  - `PLC_IP=...`
  - `CAMERA_SERIAL=...`
- Snapshot tests for generated JSON if useful.
- Avoid tests that require real devices by default.

For the default `dotnet restore / build / test` commands, the recommended test categories, and the hardware-test env-var gate, see [`references/testing-and-review.md`](references/testing-and-review.md).

## Code review checklist

When reviewing or modifying code, check:

- Does it build?
- Are all async paths cancellable?
- Is there UI-thread blocking?
- Are device errors logged with enough context?
- Are timeouts configurable?
- Is there a fake/simulator?
- Are image buffers disposed?
- Are database writes idempotent where retries exist?
- Are secrets absent from source?
- Are public interfaces documented enough?
- Did the change introduce a commercial dependency?
- Did the change alter a field used by PLC/robot/server protocol?

The condensed review checklist (build, no UI-thread blocking, no `.Result`/`.Wait()`, `CancellationToken` on all loops, etc.) is in [`references/testing-and-review.md`](references/testing-and-review.md).

## Response format for common tasks

### When asked for a plan

Return:

1. Architecture choice.
2. Project structure.
3. Key interfaces/classes.
4. Data flow.
5. Error/retry strategy.
6. Build/run/deploy commands.

### When asked for code

Return:

1. File path.
2. Full code block.
3. Required package references.
4. Registration in DI.
5. Example usage.
6. Test or simulator if applicable.

### When asked for a script

Return the pure script first. Add short notes only after the script.

### When asked to debug

Return:

1. Likely root cause.
2. Verification command/log to check.
3. Minimal fix.
4. Prevention rule.

## Common pitfalls to avoid

- Do not place protocol parsing directly in ViewModel.
- Do not make camera callback update UI directly.
- Do not let image processing allocate unbounded memory.
- Do not use unbounded `Task.Run` for every image.
- Do not ignore SDK error codes.
- Do not swallow exceptions in background services.
- Do not assume all devices use the same endianness/register layout.
- Do not assume `CreatedAt` solves migration if updates/deletes exist.
- Do not introduce new package managers or frameworks unless the benefit is clear.
