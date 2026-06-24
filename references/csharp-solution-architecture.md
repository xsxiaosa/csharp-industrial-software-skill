# C# Industrial Solution Architecture Reference

## Recommended solution layout

```text
src/
  App.Desktop/
  App.Server/
  App.Agent/
  App.Application/
  App.Domain/
  App.Infrastructure/
  App.Devices/
  App.Vision/
  App.Shared/
tests/
  App.Tests/
  App.IntegrationTests/
docs/
  architecture.md
  deployment.md
  device-protocols.md
```

## Project responsibilities

### Domain

Contains pure business concepts:

- audit task status
- image result
- device state
- station/location code
- task lifecycle
- error code

No references to UI, DB, network, SDK, file system, or object storage.

### Application

Contains use cases:

- create capture task
- handle scan result
- process AI result
- upload image metadata
- claim audit task
- timeout recycle
- sync local pending data

Defines interfaces for infrastructure and devices.

### Infrastructure

Implements:

- FreeSql repositories
- SQLite/PostgreSQL connection
- MinIO/S3 object storage
- Kafka producer/consumer
- Redis lock/cache
- HTTP clients

### Devices

Implements:

- Hikvision camera adapter
- TCP scanner
- serial scanner
- Modbus TCP client wrapper
- OPC UA client wrapper
- Omron FINS wrapper
- robot socket client
- fake/simulator devices

### Presentation

Implements:

- WPF/Avalonia views
- ViewModels
- value converters
- UI services
- dialogs/navigation
- image/thumbnail display

For ViewModel patterns (CommunityToolkit.Mvvm, [ObservableProperty], [RelayCommand], validation, messenger), see [`wpf-avalonia-mvvm.md`](wpf-avalonia-mvvm.md).
