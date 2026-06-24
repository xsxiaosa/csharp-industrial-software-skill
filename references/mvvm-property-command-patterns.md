# MVVM Property and Command Patterns

## Property styles

Use the style already present in the repository unless creating a new project.

### Field style for .NET 8 / older projects

```csharp
using CommunityToolkit.Mvvm.ComponentModel;

public partial class MainViewModel : ObservableObject
{
    [ObservableProperty]
    private string _title = string.Empty;
}
```

The generator creates a public `Title` property from `_title`.

### Partial property style for newer projects

```csharp
using CommunityToolkit.Mvvm.ComponentModel;

public partial class MainViewModel : ObservableObject
{
    [ObservableProperty]
    public partial string Title { get; set; } = string.Empty;
}
```

Use this only when the project SDK, C# language version, and `CommunityToolkit.Mvvm` version support it.

## Required namespaces

```csharp
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using CommunityToolkit.Mvvm.Messaging;
```

## Command naming

`[RelayCommand]` generates a command property from the method name.

| Method | Generated command |
|---|---|
| `ConnectAsync` | `ConnectCommand` |
| `DisconnectAsync` | `DisconnectCommand` |
| `TriggerAsync` | `TriggerCommand` |
| `Save` | `SaveCommand` |

```csharp
[RelayCommand]
private async Task ConnectAsync()
{
    await ConnectDeviceAsync(CancellationToken.None);
}
```

## CanExecute pattern

```csharp
[ObservableProperty]
[NotifyCanExecuteChangedFor(nameof(ConnectCommand))]
[NotifyCanExecuteChangedFor(nameof(DisconnectCommand))]
public partial bool IsConnected { get; set; }

[ObservableProperty]
[NotifyCanExecuteChangedFor(nameof(ConnectCommand))]
[NotifyCanExecuteChangedFor(nameof(DisconnectCommand))]
public partial bool IsBusy { get; set; }

private bool CanConnect => !IsBusy && !IsConnected;

private bool CanDisconnect => !IsBusy && IsConnected;

[RelayCommand(CanExecute = nameof(CanConnect))]
private async Task ConnectAsync()
{
    await RunBusyAsync(ConnectCoreAsync);
}
```

## Busy guard pattern

```csharp
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
    finally
    {
        IsBusy = false;
    }
}
```

## Property linkage

```csharp
[ObservableProperty]
[NotifyPropertyChangedFor(nameof(DisplayName))]
public partial string StationCode { get; set; } = string.Empty;

public string DisplayName => $"工位 {StationCode}";
```

## Change callback

```csharp
partial void OnSelectedCameraChanged(CameraInfo? value)
{
    StatusText = value is null ? "未选择相机" : $"已选择 {value.Name}";
}
```