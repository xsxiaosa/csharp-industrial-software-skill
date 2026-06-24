# Industrial Device Abstraction Reference

## Device state enum

```csharp
public enum DeviceConnectionState
{
    Disconnected = 0,
    Connecting = 1,
    Connected = 2,
    Reconnecting = 3,
    Faulted = 4
}
```

## Standard device interface

```csharp
public interface IIndustrialDevice : IAsyncDisposable
{
    string Name { get; }
    DeviceConnectionState State { get; }

    Task ConnectAsync(CancellationToken cancellationToken);
    Task DisconnectAsync(CancellationToken cancellationToken);
}
```

## Scanner result

```csharp
public sealed record ScanResult(
    string DeviceName,
    string Code,
    DateTimeOffset Timestamp,
    bool IsValid,
    string? RawText = null,
    string? ErrorMessage = null);
```

## Camera frame

```csharp
public sealed record CameraFrame(
    string CameraId,
    string TaskKey,
    DateTimeOffset CapturedAt,
    int Width,
    int Height,
    string PixelFormat,
    byte[] Buffer);
```

## PLC handshake pattern

Recommended logical signals:

```text
PC -> PLC: Trigger_Ack
PC -> PLC: Query_Result_Ready
PC -> PLC: Heartbeat
PLC -> PC: Trigger_Upload
PLC -> PC: Trigger_Query
PLC -> PC: Reset
PC -> PLC: ErrorCode
```

Rules:

- Every trigger has an ack.
- Every result has a sequence number or TaskKey.
- Repeated trigger with same TaskKey must be idempotent.
- Heartbeat loss must transition to degraded/faulted state.
