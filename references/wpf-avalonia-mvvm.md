# WPF / Avalonia MVVM Reference

Use this file as the lightweight routing entry for desktop MVVM work. Load the deeper references only when the task needs them.

## Core Rules

- ViewModels use `ObservableObject`, `[ObservableProperty]`, and `[RelayCommand]` from `CommunityToolkit.Mvvm`.
- ViewModel classes must be `partial` when using source generators.
- Use existing repo style first: field-style properties for older projects, partial properties only when the SDK and Toolkit version support them.
- Async commands return `Task`; do not use `async void`.
- Use `[RelayCommand(CanExecute = nameof(...))]` with `[NotifyCanExecuteChangedFor]` for command availability.
- Avoid code-behind business logic.
- Inject services into ViewModels through constructors.
- Do not expose device SDK objects directly to ViewModels.
- Marshal background device events to the UI thread before mutating UI-bound collections or properties.
- Keep database entities separate from DTO/ViewModel models when mapping is non-trivial.

## Read More On Demand

| Need | Read |
|---|---|
| Property styles, command naming, CanExecute, callbacks | `mvvm-property-command-patterns.md` |
| Validation, messenger, DI, window injection, WPF/Avalonia differences | `mvvm-validation-messenger-di.md` |
| Copyable camera panel ViewModel | `code-templates/camera-panel-viewmodel.md` |

## WPF vs Avalonia UI Dispatch

Use the framework dispatcher only at the boundary where UI-bound state is changed:

- WPF: `Application.Current.Dispatcher.Invoke(...)` or `InvokeAsync(...)`.
- Avalonia: `Dispatcher.UIThread.Post(...)` or `InvokeAsync(...)`.

Device callbacks, image decode, file I/O, database writes, and uploads must stay off the UI thread.

## Layering Reminder

```text
View -> ViewModel -> Application service -> Devices/Infrastructure
```

ViewModels should coordinate UI state. Protocol parsing, SDK calls, retry logic, and storage logic belong outside the ViewModel.