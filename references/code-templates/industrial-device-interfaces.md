# Industrial Device Interfaces Template

Use this template when introducing device abstractions before SDK implementations.

```csharp
/// <summary>
/// 表示工业设备连接状态。
/// </summary>
public enum DeviceConnectionState
{
    Disconnected = 0,
    Connecting = 1,
    Connected = 2,
    Reconnecting = 3,
    Faulted = 4
}

/// <summary>
/// 定义工业设备的基础生命周期接口。
/// </summary>
public interface IIndustrialDevice : IAsyncDisposable
{
    /// <summary>
    /// 获取设备名称。
    /// </summary>
    string Name { get; }

    /// <summary>
    /// 获取当前设备连接状态。
    /// </summary>
    DeviceConnectionState State { get; }

    /// <summary>
    /// 异步连接设备。
    /// </summary>
    /// <param name="cancellationToken">用于取消连接操作的令牌。</param>
    /// <returns>表示异步连接过程的任务。</returns>
    Task ConnectAsync(CancellationToken cancellationToken);

    /// <summary>
    /// 异步断开设备连接。
    /// </summary>
    /// <param name="cancellationToken">用于取消断开操作的令牌。</param>
    /// <returns>表示异步断开过程的任务。</returns>
    Task DisconnectAsync(CancellationToken cancellationToken);
}

/// <summary>
/// 定义工业相机设备接口。
/// </summary>
public interface ICameraDevice : IIndustrialDevice
{
    /// <summary>
    /// 按指定触发请求采集一帧图像。
    /// </summary>
    /// <param name="request">相机触发请求，包含任务号、位置和采集参数。</param>
    /// <param name="cancellationToken">用于取消采集操作的令牌。</param>
    /// <returns>相机采集到的图像帧。</returns>
    Task<CameraFrame> TriggerAsync(CameraTriggerRequest request, CancellationToken cancellationToken);
}

/// <summary>
/// 定义扫码枪设备接口。
/// </summary>
public interface IScannerDevice : IIndustrialDevice
{
    /// <summary>
    /// 异步读取扫码结果流。
    /// </summary>
    /// <param name="cancellationToken">用于停止读取结果流的令牌。</param>
    /// <returns>扫码结果异步序列。</returns>
    IAsyncEnumerable<ScanResult> ReadResultsAsync(CancellationToken cancellationToken);

    /// <summary>
    /// 主动触发扫码。
    /// </summary>
    /// <param name="cancellationToken">用于取消触发操作的令牌。</param>
    /// <returns>表示异步触发过程的任务。</returns>
    Task TriggerAsync(CancellationToken cancellationToken);
}

/// <summary>
/// 定义 PLC 客户端接口。
/// </summary>
public interface IPlcClient : IAsyncDisposable
{
    /// <summary>
    /// 异步连接 PLC。
    /// </summary>
    /// <param name="cancellationToken">用于取消连接操作的令牌。</param>
    /// <returns>表示异步连接过程的任务。</returns>
    Task ConnectAsync(CancellationToken cancellationToken);

    /// <summary>
    /// 从指定地址异步读取 PLC 数据。
    /// </summary>
    /// <typeparam name="T">PLC 数据的目标类型。</typeparam>
    /// <param name="address">PLC 地址。</param>
    /// <param name="cancellationToken">用于取消读取操作的令牌。</param>
    /// <returns>PLC 读取结果。</returns>
    Task<PlcReadResult<T>> ReadAsync<T>(string address, CancellationToken cancellationToken);

    /// <summary>
    /// 向指定地址异步写入 PLC 数据。
    /// </summary>
    /// <typeparam name="T">PLC 数据的源类型。</typeparam>
    /// <param name="address">PLC 地址。</param>
    /// <param name="value">需要写入 PLC 的值。</param>
    /// <param name="cancellationToken">用于取消写入操作的令牌。</param>
    /// <returns>表示异步写入过程的任务。</returns>
    Task WriteAsync<T>(string address, T value, CancellationToken cancellationToken);
}
```