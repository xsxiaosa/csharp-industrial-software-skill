# WPF / Avalonia MVVM Reference

## Overview

`CommunityToolkit.Mvvm` 是轻量、跨 UI 框架的 MVVM 工具库，适用于 WPF、Avalonia、MAUI、WinUI。本 skill 同时支持 WPF 与 Avalonia，View Model 代码在两者间可移植。

**工业上位机视角：** ViewModel 只负责界面状态调度，设备 SDK 调用、协议解析全部进 `Devices`/`Infrastructure` 层，通过 `ICameraService`、`IPlcClient`、`IScannerDevice` 等接口注入 ViewModel，不直接持有 SDK 对象。

---

## Three property-writing styles

CommunityToolkit.Mvvm 支持三种写法，推荐新项目优先使用 Style C（partial property）。

### Style A — 传统手写（仅历史代码）

```csharp
public class MainViewModel : INotifyPropertyChanged
{
    private string _title = string.Empty;

    public string Title
    {
        get => _title;
        set
        {
            if (_title != value)
            {
                _title = value;
                OnPropertyChanged(nameof(Title));
            }
        }
    }

    public event PropertyChangedEventHandler? PropertyChanged;

    protected void OnPropertyChanged(string propertyName) =>
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
}
```

**适用场景：** 遗留代码维护，或无法使用源生成器的环境。

### Style B — 字段 + `[ObservableProperty]`（8.x 通用）

```csharp
using CommunityToolkit.Mvvm.ComponentModel;

public partial class MainViewModel : ObservableObject
{
    [ObservableProperty]
    private string _title = string.Empty;
}
```

源生成器自动生成：
```csharp
public string Title
{
    get => _title;
    set => SetProperty(ref _title, value);
}
```

**字段命名约定：** 下划线 + camelCase（`_title`），源生成器去下划线并首字母大写 → `Title`。  
**适用场景：** .NET 8 / C# 12 及更老项目，或无法使用 partial property 的项目。

### Style C — partial property + `[ObservableProperty]`（推荐）

```csharp
using CommunityToolkit.Mvvm.ComponentModel;

public partial class MainViewModel : ObservableObject
{
    [ObservableProperty]
    public partial string Title { get; set; } = string.Empty;
}
```

**版本 / SDK 要求：**
- .NET 9 / C# 13+
- `CommunityToolkit.Mvvm` 8.x 新版（8.3+）
- `.csproj` 设 `<LangVersion>latest</LangVersion>` 或 `<LangVersion>13.0</LangVersion>`

**推荐场景：** 新项目、新 ViewModel，优先使用此写法。

### 三种写法对比

| 写法 | 版本要求 | 字段约定 | 代码量 | 推荐场景 |
|---|---|---|---|---|
| Style A 手写 | 无 | `_camelCase` | 多 | 遗留代码维护 |
| Style B 字段 | .NET 6+ / C# 10+ | `_camelCase` | 少 | 老项目、无法用 partial property |
| Style C partial property | .NET 9 / C# 13+ | 无需手写字段 | 最少 | **新项目优先** |

---

## Required using & partial class

```csharp
using CommunityToolkit.Mvvm.ComponentModel;   // ObservableObject, [ObservableProperty]
using CommunityToolkit.Mvvm.Input;               // [RelayCommand], IRelayCommand
using CommunityToolkit.Mvvm.Messaging;            // WeakReferenceMessenger（按需）
```

**关键约束：**
- ViewModel 类必须为 `partial class`（源生成器需要在编译时生成另一部分代码）。
- Style C（partial property）的属性也必须为 `partial`。
- Style B 的字段无此要求（字段不需要 partial）。

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
}
```

---

## Commands and naming convention

`[RelayCommand]` 标记的方法会自动生成一个 `ICommand` / `IRelayCommand` / `IAsyncRelayCommand` 属性。

```csharp
[RelayCommand]
private async Task ConnectAsync()
{
    // ...
}
```

生成：
```csharp
public IAsyncRelayCommand ConnectCommand { get; }
```

### 命名规则

| 方法名 | 生成的命令属性名 |
|---|---|
| `ConnectAsync` | `ConnectCommand` |
| `DisconnectAsync` | `DisconnectCommand` |
| `TriggerAsync` | `TriggerCommand` |
| `Save` | `SaveCommand` |
| `LoadDataAsync` | `LoadDataCommand` |

规则：方法名去掉 `Async` 后缀 → 追加 `Command`。

**XAML 绑定：**
```xml
<Button Command="{Binding ConnectCommand}" Content="连接" />
```

**异步命令规范：**
- 异步方法返回 `Task`，Toolkit 自动生成 `IAsyncRelayCommand`。
- **不要**写 `async void`。

---

## CanExecute + `[NotifyCanExecuteChangedFor]`

使用 `[RelayCommand(CanExecute = nameof(CanConnect))]` 控制命令可用性。

```csharp
[RelayCommand(CanExecute = nameof(CanConnect))]
private async Task ConnectAsync()
{
    // ...
}

private bool CanConnect => !IsBusy && !IsConnected;
```

### 自动刷新命令状态

当依赖属性变化时需要刷新命令状态，在属性上标注 `[NotifyCanExecuteChangedFor]`。

```csharp
[ObservableProperty]
[NotifyCanExecuteChangedFor(nameof(ConnectCommand))]
[NotifyCanExecuteChangedFor(nameof(DisconnectCommand))]
[NotifyCanExecuteChangedFor(nameof(TriggerCommand))]
public partial bool IsConnected { get; set; }

[ObservableProperty]
[NotifyCanExecuteChangedFor(nameof(ConnectCommand))]
[NotifyCanExecuteChangedFor(nameof(DisconnectCommand))]
[NotifyCanExecuteChangedFor(nameof(TriggerCommand))]
public partial bool IsBusy { get; set; }
```

`IsConnected` 或 `IsBusy` 变化时，三个命令自动刷新 `CanExecute`。

### 工业模式：RunBusyAsync

```csharp
/// <summary>在 IsBusy 保护下异步执行操作，自动处理 isBusy 状态与异常。</summary>
private async Task RunBusyAsync(Func<Task> action)
{
    if (IsBusy) return;

    try
    {
        IsBusy = true;
        await action();
    }
    catch (Exception ex)
    {
        // 异常写回 StatusText，界面绑定即可显示
        StatusText = $"操作异常：{ex.Message}";
    }
    finally
    {
        IsBusy = false;
    }
}
```

使用时只需要：
```csharp
[RelayCommand(CanExecute = nameof(CanConnect))]
private async Task ConnectAsync()
{
    await RunBusyAsync(async () =>
    {
        StatusText = "正在连接...";
        await _cameraService.ConnectAsync(CancellationToken.None);
        IsConnected = true;
        StatusText = "已连接";
    });
}
```

---

## Property linkage `[NotifyPropertyChangedFor]`

当属性 A 变化时需要通知派生属性 B 刷新界面。

```csharp
[ObservableProperty]
[NotifyPropertyChangedFor(nameof(DeviceEndpoint))]
public partial string DeviceIp { get; set; } = "192.168.1.100";

[ObservableProperty]
[NotifyPropertyChangedFor(nameof(DeviceEndpoint))]
public partial int DevicePort { get; set; } = 502;

/// <summary>由 DeviceIp 和 DevicePort 拼接的设备端点。</summary>
public string DeviceEndpoint => $"{DeviceIp}:{DevicePort}";
```

**工业场景：** IP + 端口 → 连接字符串；站号 + 通道号 → 完整地址。

---

## Property change callbacks

当属性变化需要执行额外逻辑时，使用 `partial void OnXxxChanged`，**不要手写 setter**。

```csharp
[ObservableProperty]
public partial CameraInfo? SelectedCamera { get; set; }

/// <summary>选中相机变化时加载该相机参数。</summary>
partial void OnSelectedCameraChanged(CameraInfo? value)
{
    if (value is null) return;

    // 加载该相机的曝光、增益等参数
    StatusText = $"已选择相机：{value.Name}";
    LoadCameraConfig(value);
}
```

也可同时获取旧值和新值：

```csharp
partial void OnSelectedCameraChanged(CameraInfo? oldValue, CameraInfo? newValue)
{
    // oldValue：之前选中的相机
    // newValue：新选中的相机
}
```

**不要在 `[ObservableProperty]` 上写 setter 实现：**

```csharp
// ❌ 错误：源生成器会自动生成 setter，不要手写
[ObservableProperty]
public partial string Title
{
    get => _title;
    set => _title = value;
}

// ✅ 正确：用 partial method
[ObservableProperty]
public partial string Title { get; set; }
partial void OnTitleChanged(string value) { }
```

---

## Form validation with `ObservableValidator`

表单校验场景（设备参数配置、配方编辑、登录）使用 `ObservableValidator` 替代 `ObservableObject`。

```csharp
using System.ComponentModel.DataAnnotations;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

/// <summary>相机参数配置 ViewModel。</summary>
public partial class CameraConfigViewModel : ObservableValidator
{
    /// <summary>设备 IP 地址。</summary>
    [ObservableProperty]
    [Required(ErrorMessage = "IP 地址不能为空")]
    [RegularExpression(@"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$",
        ErrorMessage = "IP 地址格式不正确")]
    [NotifyDataErrorInfo]
    public partial string DeviceIp { get; set; } = "192.168.1.100";

    /// <summary>曝光时间（微秒）。</summary>
    [ObservableProperty]
    [Range(0, 100000, ErrorMessage = "曝光范围 0-100000 µs")]
    [NotifyDataErrorInfo]
    public partial int ExposureUs { get; set; } = 5000;

    /// <summary>图像增益（dB）。</summary>
    [ObservableProperty]
    [Range(0, 48, ErrorMessage = "增益范围 0-48 dB")]
    [NotifyDataErrorInfo]
    public partial double Gain { get; set; } = 12.0;

    [RelayCommand]
    private void Save()
    {
        ValidateAllProperties();
        if (HasErrors) return;

        // 保存参数到配置文件或数据库
    }
}
```

**XAML 绑定：**

```xml
<!-- WPF -->
<TextBox Text="{Binding DeviceIp, UpdateSourceTrigger=PropertyChanged,
                ValidatesOnNotifyDataErrorInfo=True}" />

<!-- Avalonia（写法相同） -->
<TextBox Text="{Binding DeviceIp, UpdateSourceTrigger=PropertyChanged,
                ValidatesOnNotifyDataErrorInfo=True}" />
```

**注意：** `[NotifyDataErrorInfo]` 让源生成器自动实现 `INotifyDataErrorInfo`，XAML 校验模板无需额外代码。

---

## Messenger for decoupled communication

`WeakReferenceMessenger` 实现 ViewModel 之间的解耦通信。适合广播设备连接状态、任务完成通知等场景。

### 定义消息

```csharp
/// <summary>相机连接状态变更消息。</summary>
public sealed record CameraConnectionChangedMessage(string CameraId, bool IsConnected);
```

### 发送消息

```csharp
using CommunityToolkit.Mvvm.Messaging;

// 在设备 Service 或 ViewModel 中发送
WeakReferenceMessenger.Default.Send(
    new CameraConnectionChangedMessage("Camera01", true));
```

### 接收消息

```csharp
/// <summary>状态栏 ViewModel，监听设备连接状态变化。</summary>
public partial class StatusBarViewModel : ObservableObject,
    IRecipient<CameraConnectionChangedMessage>
{
    [ObservableProperty]
    public partial string StatusText { get; set; } = string.Empty;

    public StatusBarViewModel()
    {
        // 注册消息接收
        WeakReferenceMessenger.Default.Register<CameraConnectionChangedMessage>(this);
    }

    /// <summary>处理相机连接状态变更消息。</summary>
    public void Receive(CameraConnectionChangedMessage message)
    {
        StatusText = message.IsConnected
            ? $"{message.CameraId} 已连接"
            : $"{message.CameraId} 已断开";
    }

    /// <summary>清理时取消注册。</summary>
    public void Cleanup()
    {
        WeakReferenceMessenger.Default.Unregister<CameraConnectionChangedMessage>(this);
    }
}
```

### 滥用警告

- 同进程内使用，**不要**用 Messenger 跨进程通信。
- **不要**用 Messenger 替代 DI 注入的服务调用（如 "A ViewModel 调 B ViewModel 的方法"）。
- 注册后必须在合适的时机 `Unregister`，避免内存泄漏（可在 View `OnUnloaded` 或 `Dispose` 时清理）。
- 不适合高频数据流（如实时图像帧），高频场景应使用更轻量的回调或数据流。

---

## DI registration and Window injection

ViewModel 通过构造函数注入服务，不直接 new Service。

### 服务接口示例

```csharp
/// <summary>相机服务接口。</summary>
public interface ICameraService
{
    /// <summary>连接相机。</summary>
    Task ConnectAsync(CancellationToken cancellationToken);

    /// <summary>断开相机。</summary>
    Task DisconnectAsync(CancellationToken cancellationToken);

    /// <summary>触发拍照。</summary>
    Task<CameraFrame> TriggerAsync(CancellationToken cancellationToken);
}
```

### App.xaml.cs 注册

```csharp
using Microsoft.Extensions.DependencyInjection;
using System.Windows;

/// <summary>WPF 应用入口。</summary>
public partial class App : Application
{
    /// <summary>全局 DI 容器。</summary>
    public static IServiceProvider Services { get; private set; } = default!;

    protected override void OnStartup(StartupEventArgs e)
    {
        var services = new ServiceCollection();

        // 注册设备服务
        services.AddSingleton<ICameraService, HikvisionCameraService>();

        // 注册 ViewModel（Transient 或 Singleton 按需要）
        services.AddTransient<CameraPanelViewModel>();

        // 注册窗口
        services.AddTransient<MainWindow>();

        Services = services.BuildServiceProvider();

        var window = Services.GetRequiredService<MainWindow>();
        window.Show();

        base.OnStartup(e);
    }
}
```

### MainWindow 注入 ViewModel

```csharp
/// <summary>主窗口。</summary>
public partial class MainWindow : Window
{
    /// <summary>通过 DI 注入 ViewModel 并设为 DataContext。</summary>
    public MainWindow(CameraPanelViewModel viewModel)
    {
        InitializeComponent();
        DataContext = viewModel;  // ViewModel 绑定为数据上下文
    }
}
```

### Avalonia 差异

Avalonia 使用 `Program.cs` + `App.axaml.cs`：

```csharp
// Program.cs
public static void Main(string[] args) =>
    BuildAvaloniaApp().StartWithClassicDesktopLifetime(args);

public static AppBuilder BuildAvaloniaApp() =>
    AppBuilder.Configure<App>()
        .UsePlatformDetect()
        .LogToTrace();
```

Service 注册在 `App.axaml.cs` 中，方式与 WPF `App.xaml.cs` 相同。`Window` 构造函数注入 ViewModel 的写法与 WPF 一致。

---

## `ObservableCollection<T>` list binding

列表绑定使用 `ObservableCollection<T>`，且增删操作**只在 UI 线程**执行。

```csharp
using System.Collections.ObjectModel;
using CommunityToolkit.Mvvm.ComponentModel;

/// <summary>相机图像列表 ViewModel。</summary>
public partial class CameraGalleryViewModel : ObservableObject
{
    /// <summary>缩略图列表（只绑定缩略图，不绑定原始图像 buffer）。</summary>
    public ObservableCollection<CameraFrameThumbnail> Thumbnails { get; } = new();
}
```

### 后台事件 marshal 到 UI 线程

设备事件在后台线程触发，更新集合前必须切换到 UI 线程：

```csharp
// WPF：使用 Application.Current.Dispatcher
Application.Current.Dispatcher.Invoke(() =>
{
    Thumbnails.Add(thumbnail);
});

// Avalonia：使用 Dispatcher.UIThread
Dispatcher.UIThread.Post(() =>
{
    Thumbnails.Add(thumbnail);
});
```

**工业图像注意：** 列表只绑定缩略图（`CameraFrameThumbnail` 等轻量对象），避免将全尺寸图像 buffer 放入 `ObservableCollection<T>`（参见 SKILL.md Image display 小节）。

---

## WPF vs Avalonia differences

MVVM Toolkit **代码层面完全相同**，差异主要在 UI 框架层。

| 方面 | WPF | Avalonia |
|---|---|---|
| XAML 文件扩展名 | `.xaml` | `.axaml` |
| Dispatcher | `Application.Current.Dispatcher.Invoke(...)` | `Dispatcher.UIThread.Post(...)` / `InvokeAsync(...)` |
| DataContext 设置 | `DataContext = viewModel;` | 同上 |
| 样式引擎 | 原生 XAML 样式 | 类似 CSS 的选择器 + 样式键 |
| 启动入口 | `App.xaml.cs` OnStartup | `Program.cs` + `App.axaml.cs` |
| 验证绑定 | `ValidatesOnNotifyDataErrorInfo=True` | 同上 |
| NuGet 包 | `CommunityToolkit.Mvvm` | 同上 |

```csharp
// MVVM Toolkit 代码在 WPF 与 Avalonia 间完全可移植
// ❌ 不需要写 #if WPF / #if AVALONIA
public partial class CameraPanelViewModel : ObservableObject
{
    // 这段代码 WPF 和 Avalonia 都能用
}
```

---

## Layering reminder

ViewModel **不直接调用设备 SDK**，通过服务接口间接调用：

```text
ViewModel (调度界面状态)
    ↓ 调用
Service / Device Adapter (设备连接、协议解析、SDK 封装)
    ↓
Infrastructure / Devices Layer (TCP、串口、SDK 原生 API)
```

**规则：**
- ViewModel 不写 TCP 连接、协议解析、SDK 异常码处理。
- ViewModel 不持有 WPF/Avalonia 控件引用（如 `TextBox`、`Image`）。
- ViewModel 只绑定数据属性、调度命令、管理界面状态。
- 复杂映射使用 DTO 与 DB 实体分离（SKILL.md 第 136 行）。

参见 [`csharp-solution-architecture.md`](csharp-solution-architecture.md) Presentation 层职责。

---

## Pitfalls checklist

1. **类必须 `partial`，新写法属性也必须 `partial`** — 源生成器需要编译时生成代码。
2. **不要手写 `[ObservableProperty]` 属性的 setter 实现** — 用 `partial void OnXxxChanged`。
3. **不要和生成的属性/命令重名** — 如有了 `Title` 又写 `_title` 字段（风格 B 下冲突）。
4. **命令刷新用 `[NotifyCanExecuteChangedFor]`** — 不在多处手动调 `Command.NotifyCanExecuteChanged()`。
5. **异步命令不要 `async void`** — 返回 `Task`，Toolkit 自动生成 `IAsyncRelayCommand`。
6. **不要把 WPF/Avalonia 控件实例传进 ViewModel** — 破坏 MVVM 分离与可测试性。
7. **列表绑定用 `ObservableCollection<T>`** — 且只在 UI 线程增删。
8. **Messenger 注册要 `Unregister`** — 避免内存泄漏。
9. **partial property 需要 .NET 9 / C# 13 + 新版 Toolkit** — 老项目降级到 Style B 字段写法，不要强行升级 SDK。
10. **`[NotifyDataErrorInfo]` 与 `ValidateAllProperties()` 二选一** — 前者自动触发，后者手动触发，不要混用导致重复校验。
11. **设备回调先 marshal 到 UI 线程** — 再改属性 / 集合。

---

## Recommended ViewModel template

以下是完整的工业风 ViewModel 模板（Style C partial property 写法），可直接复制使用。

```csharp
using System.Collections.ObjectModel;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using Microsoft.Extensions.Logging;

namespace YourApp.ViewModels;

/// <summary>
/// 相机面板 ViewModel。负责相机连接、触发拍照、状态显示。
/// 设备 SDK 操作通过 ICameraService 委托给 Devices 层。
/// </summary>
public partial class CameraPanelViewModel : ObservableObject
{
    private readonly ICameraService _cameraService;
    private readonly ILogger<CameraPanelViewModel> _logger;

    /// <summary>构造函数注入相机服务和日志。</summary>
    /// <param name="cameraService">相机服务接口。</param>
    /// <param name="logger">日志记录器。</param>
    public CameraPanelViewModel(ICameraService cameraService, ILogger<CameraPanelViewModel> logger)
    {
        _cameraService = cameraService;
        _logger = logger;
    }

    // ===== 可绑定属性 =====

    /// <summary>相机连接状态。</summary>
    [ObservableProperty]
    [NotifyCanExecuteChangedFor(nameof(ConnectCommand))]
    [NotifyCanExecuteChangedFor(nameof(DisconnectCommand))]
    [NotifyCanExecuteChangedFor(nameof(TriggerCommand))]
    public partial bool IsConnected { get; set; }

    /// <summary>操作忙状态（连接、断开、拍照期间为 true）。</summary>
    [ObservableProperty]
    [NotifyCanExecuteChangedFor(nameof(ConnectCommand))]
    [NotifyCanExecuteChangedFor(nameof(DisconnectCommand))]
    [NotifyCanExecuteChangedFor(nameof(TriggerCommand))]
    public partial bool IsBusy { get; set; }

    /// <summary>状态文本，显示当前操作状态或异常信息。</summary>
    [ObservableProperty]
    public partial string StatusText { get; set; } = "未连接";

    /// <summary>相机名称。</summary>
    [ObservableProperty]
    public partial string CameraName { get; set; } = "Hik Camera";

    /// <summary>最后拍摄的缩略图列表（轻量对象，不含原始 buffer）。</summary>
    public ObservableCollection<CameraFrameThumbnail> Thumbnails { get; } = new();

    // ===== 命令可用性 =====

    private bool CanConnect => !IsBusy && !IsConnected;
    private bool CanDisconnect => !IsBusy && IsConnected;
    private bool CanTrigger => !IsBusy && IsConnected;

    // ===== 命令 =====

    /// <summary>连接相机。</summary>
    [RelayCommand(CanExecute = nameof(CanConnect))]
    private async Task ConnectAsync()
    {
        await RunBusyAsync(async () =>
        {
            _logger.LogInformation("正在连接相机...");
            StatusText = "正在连接...";

            await _cameraService.ConnectAsync(CancellationToken.None);

            IsConnected = true;
            StatusText = "已连接";
            _logger.LogInformation("相机连接成功");
        });
    }

    /// <summary>断开相机。</summary>
    [RelayCommand(CanExecute = nameof(CanDisconnect))]
    private async Task DisconnectAsync()
    {
        await RunBusyAsync(async () =>
        {
            _logger.LogInformation("正在断开相机...");
            StatusText = "正在断开...";

            await _cameraService.DisconnectAsync(CancellationToken.None);

            IsConnected = false;
            StatusText = "已断开";
            _logger.LogInformation("相机已断开");
        });
    }

    /// <summary>触发拍照。</summary>
    [RelayCommand(CanExecute = nameof(CanTrigger))]
    private async Task TriggerAsync()
    {
        await RunBusyAsync(async () =>
        {
            _logger.LogInformation("正在拍照...");
            StatusText = "正在拍照...";

            var frame = await _cameraService.TriggerAsync(CancellationToken.None);

            // 生成缩略图加入列表（此处在 UI 线程上，可直接操作 ObservableCollection）
            var thumbnail = new CameraFrameThumbnail(frame);
            Thumbnails.Add(thumbnail);

            StatusText = $"拍照完成 ({Thumbnails.Count} 张)";
            _logger.LogInformation("拍照完成，帧大小: {Size}", frame.Data.Length);
        });
    }

    // ===== 属性变化回调 =====

    /// <summary>IsConnected 变化时的额外逻辑。</summary>
    partial void OnIsConnectedChanged(bool value)
    {
        // 可在连接状态变化时触发其他操作，如更新菜单项
    }

    // ===== 辅助方法 =====

    /// <summary>
    /// 在 IsBusy 保护下执行异步操作。
    /// 自动管理 IsBusy 状态、异常处理与日志。
    /// </summary>
    private async Task RunBusyAsync(Func<Task> action)
    {
        // 已在忙则跳过（防重复点击）
        if (IsBusy) return;

        try
        {
            IsBusy = true;
            await action();
        }
        catch (Exception ex)
        {
            // 将异常显示到界面
            StatusText = $"异常: {ex.Message}";
            _logger.LogError(ex, "操作异常");
        }
        finally
        {
            // 确保无论成功或异常都释放忙状态
            IsBusy = false;
        }
    }
}

/// <summary>相机帧缩略图（轻量对象，用于列表显示）。</summary>
public class CameraFrameThumbnail
{
    /// <summary>缩略图字节数据。</summary>
    public byte[] Data { get; }

    /// <summary>图像宽度（像素）。</summary>
    public int Width { get; }

    /// <summary>图像高度（像素）。</summary>
    public int Height { get; }

    /// <summary>缩略图标识。</summary>
    public string Label { get; }

    /// <summary>从原始帧创建缩略图。</summary>
    public CameraFrameThumbnail(CameraFrame frame)
    {
        Width = frame.Width;
        Height = frame.Height;
        Label = $"{frame.Width}x{frame.Height} @ {DateTime.Now:HH:mm:ss}";
        Data = GenerateThumbnail(frame);   // 生成缩略图，不保留原始大图 buffer
    }

    private static byte[] GenerateThumbnail(CameraFrame frame)
    {
        // 实际项目中在此处将原始帧缩放到缩略图尺寸
        return Array.Empty<byte>();
    }
}
```

### XAML 绑定示例（WPF）

```xml
<Window x:Class="YourApp.Views.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="相机面板" Width="600" Height="400">

    <Grid Margin="16">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto" />
            <RowDefinition Height="Auto" />
            <RowDefinition Height="Auto" />
            <RowDefinition Height="*" />
        </Grid.RowDefinitions>

        <TextBlock Text="{Binding CameraName}"
                   FontSize="20" FontWeight="Bold" />

        <TextBlock Grid.Row="1" Margin="0,8,0,0"
                   Text="{Binding StatusText}" />

        <StackPanel Grid.Row="2" Margin="0,16,0,0"
                    Orientation="Horizontal">

            <Button Width="100" Height="32"
                    Content="连接"
                    Command="{Binding ConnectCommand}" />

            <Button Width="100" Height="32" Margin="12,0,0,0"
                    Content="断开"
                    Command="{Binding DisconnectCommand}" />

            <Button Width="100" Height="32" Margin="12,0,0,0"
                    Content="拍照"
                    Command="{Binding TriggerCommand}" />
        </StackPanel>

        <ListBox Grid.Row="3" Margin="0,16,0,0"
                 ItemsSource="{Binding Thumbnails}" />
    </Grid>
</Window>
```

Avalonia 版本只需将 `Window` 改为 `Window`（命名空间一致），XAML 扩展名改为 `.axaml`，绑定语法相同。

### 推荐 ViewModel 基础组合

```
ObservableObject
  + ObservableValidator（需要表单校验时）
  + [ObservableProperty]           — 属性通知
  + [RelayCommand]                 — 命令生成
  + [NotifyPropertyChangedFor]     — 属性联动
  + [NotifyCanExecuteChangedFor]   — 命令状态刷新
  + WeakReferenceMessenger         — ViewModel 解耦通信（按需）
```
