# MVVM Validation, Messenger, and DI Patterns

## ObservableValidator

Use `ObservableValidator` for form-like ViewModels that need validation errors exposed to XAML.

```csharp
using CommunityToolkit.Mvvm.ComponentModel;
using System.ComponentModel.DataAnnotations;

public partial class LoginViewModel : ObservableValidator
{
    [ObservableProperty]
    [Required(ErrorMessage = "用户名不能为空")]
    [NotifyDataErrorInfo]
    public partial string UserName { get; set; } = string.Empty;
}
```

WPF binding example:

```xml
<TextBox Text="{Binding UserName, UpdateSourceTrigger=PropertyChanged, ValidatesOnNotifyDataErrors=True}" />
```

## WeakReferenceMessenger

Use messenger for decoupled same-process notifications such as device state changes or task completion.

```csharp
public sealed record DeviceStateChangedMessage(string DeviceName, DeviceConnectionState State);
```

```csharp
WeakReferenceMessenger.Default.Send(new DeviceStateChangedMessage("Camera1", DeviceConnectionState.Connected));
```

```csharp
WeakReferenceMessenger.Default.Register<DeviceStateChangedMessage>(this, (_, message) =>
{
    StatusText = $"{message.DeviceName}: {message.State}";
});
```

Rules:

- Do not use messenger as a hidden service locator.
- Unregister when the recipient has a shorter lifecycle than the app.
- Prefer direct constructor injection for required dependencies.

## DI registration

```csharp
services.AddSingleton<ICameraService, CameraService>();
services.AddTransient<CameraPanelViewModel>();
services.AddTransient<CameraPanelView>();
```

Window/View construction should resolve the ViewModel from DI and assign it to `DataContext`.

## ObservableCollection rule

Only mutate `ObservableCollection<T>` on the UI thread.

WPF:

```csharp
await Application.Current.Dispatcher.InvokeAsync(() => Items.Add(item));
```

Avalonia:

```csharp
await Dispatcher.UIThread.InvokeAsync(() => Items.Add(item));
```

## Pitfalls checklist

- No SDK object stored directly in a ViewModel.
- No protocol parsing in code-behind.
- No `.Result` or `.Wait()` in UI paths.
- No unbounded `Task.Run` per image.
- No background mutation of UI-bound collections.