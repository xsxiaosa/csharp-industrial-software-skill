# Camera Panel ViewModel Template

Use this template when creating a new WPF/Avalonia ViewModel with `CommunityToolkit.Mvvm` partial properties.

```csharp
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

/// <summary>
/// 相机面板 ViewModel，负责相机连接、断开、触发和界面状态展示。
/// </summary>
public partial class CameraPanelViewModel : ObservableObject
{
    private readonly ICameraService _cameraService;

    /// <summary>
    /// 初始化相机面板 ViewModel。
    /// </summary>
    /// <param name="cameraService">相机服务，用于执行连接、断开和触发采集。</param>
    public CameraPanelViewModel(ICameraService cameraService)
    {
        _cameraService = cameraService;
    }

    /// <summary>
    /// 获取或设置相机是否已连接。
    /// </summary>
    [ObservableProperty]
    [NotifyCanExecuteChangedFor(nameof(ConnectCommand))]
    [NotifyCanExecuteChangedFor(nameof(DisconnectCommand))]
    [NotifyCanExecuteChangedFor(nameof(TriggerCommand))]
    public partial bool IsConnected { get; set; }

    /// <summary>
    /// 获取或设置当前是否正在执行相机操作。
    /// </summary>
    [ObservableProperty]
    [NotifyCanExecuteChangedFor(nameof(ConnectCommand))]
    [NotifyCanExecuteChangedFor(nameof(DisconnectCommand))]
    [NotifyCanExecuteChangedFor(nameof(TriggerCommand))]
    public partial bool IsBusy { get; set; }

    /// <summary>
    /// 获取或设置界面状态文本。
    /// </summary>
    [ObservableProperty]
    public partial string StatusText { get; set; } = string.Empty;

    private bool CanConnect => !IsBusy && !IsConnected;

    private bool CanDisconnect => !IsBusy && IsConnected;

    private bool CanTrigger => !IsBusy && IsConnected;

    /// <summary>
    /// 异步连接相机。
    /// </summary>
    /// <returns>表示异步连接操作的任务。</returns>
    [RelayCommand(CanExecute = nameof(CanConnect))]
    private async Task ConnectAsync()
    {
        await RunBusyAsync(async () =>
        {
            await _cameraService.ConnectAsync(CancellationToken.None);
            IsConnected = true;
            StatusText = "已连接";
        });
    }

    /// <summary>
    /// 在忙碌状态保护下执行异步操作，并把异常写入界面状态。
    /// </summary>
    /// <param name="action">需要在忙碌状态保护下执行的异步操作。</param>
    /// <returns>表示异步执行过程的任务。</returns>
    private async Task RunBusyAsync(Func<Task> action)
    {
        if (IsBusy)
        {
            return;
        }

        try
        {
            IsBusy = true;
            await action();
        }
        catch (Exception ex)
        {
            StatusText = $"操作异常: {ex.Message}";
        }
        finally
        {
            IsBusy = false;
        }
    }
}
```