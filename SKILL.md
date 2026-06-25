---
name: csharp-industrial-software
description: C#/.NET industrial upper-computer, HMI/SCADA, machine vision, WPF/Avalonia MVVM, ASP.NET Core, device communication, Hikvision camera, PLC/OPC UA/Modbus/FINS, scanner, FreeSql, SQLite/PostgreSQL, MinIO/S3, Docker deployment. Use when designing, coding, refactoring, reviewing, or debugging C#/.NET industrial software.
---

# C# Industrial Software Skill

## Purpose

Use this skill for C#/.NET industrial software work:

- HMI, SCADA, upper-computer, local device-control software.
- WPF or Avalonia desktop applications.
- ASP.NET Core self-hosted services, station agents, review platforms.
- Hikvision cameras, scanners, PLC, OPC UA, Modbus TCP, Omron FINS, robot communication.
- Image capture, AI judgment, manual review, queues, object storage.
- FreeSql, SQLite, PostgreSQL, MinIO/S3, Kafka, Redis.
- Windows Service, Linux systemd, Docker Compose deployment.

Prefer direct, practical Chinese answers. Keep code identifiers in English.

## Activation Workflow

When this skill is active:

1. Classify the project first:
   - `Desktop`: WPF or Avalonia.
   - `Server`: ASP.NET Core API or self-hosted service.
   - `Agent`: station capture, upload, device worker.
   - `Library`: SDK wrapper, protocol, algorithm, infrastructure.
   - `Template`: new reusable solution template.
2. Inspect existing conventions before changing code:
   - `*.sln`
   - `*.csproj`
   - `Directory.Build.props`
   - `Directory.Packages.props`
   - `global.json`
   - `appsettings*.json`
   - `docker-compose*.yml`
   - `README.md`
3. Run the environment check unless the SDK is already known or the user asks for a dry plan:
   - Windows: `scripts/check-dotnet-env.ps1`
   - Linux/macOS: `bash scripts/check-dotnet-env.sh`
4. Preserve existing architecture unless the user asks for redesign.
5. Prefer small, reviewable changes.
6. Include build/test/run commands when generating or changing code.
7. Read only the reference files that match the current task.

## Reference Routing

Load references on demand. Do not preload all references.

| Task topic | Read |
|---|---|
| Solution layout, project boundaries, dependency direction | `references/csharp-solution-architecture.md` |
| Preferred packages and default technology choices | `references/preferred-libraries.md` |
| WPF/Avalonia MVVM, commands, validation, messenger, DI (core rules) | `references/wpf-avalonia-mvvm.md` → loads `mvvm-property-command-patterns.md` / `mvvm-validation-messenger-di.md` on demand |
| Industrial image display and 20MB-level image handling | `references/image-display.md` |
| Device interfaces, states, scanner/camera records, PLC handshake | `references/industrial-device-abstractions.md` |
| Camera/PLC/scanner/robot communication checklist | `references/device-communication-checklist.md` |
| Vision/AI task pipeline and file metadata rules | `references/vision-ai-pipeline.md` |
| SQLite/PostgreSQL rules and live migration strategy | `references/database-and-migration.md` |
| ASP.NET Core service rules | `references/aspnetcore-service.md` |
| Windows/Linux/Docker deployment rules | `references/deployment.md` |
| Validation commands and review checklist | `references/testing-and-review.md` |
| Common response shapes for plans, code, scripts, debugging | `references/response-formats.md` |
| Installing this skill into Claude Code / Codex / opencode | `references/install-guide.md` |
| Copyable ViewModel template | `references/code-templates/camera-panel-viewmodel.md` |
| Copyable device interface template | `references/code-templates/industrial-device-interfaces.md` |
| Copyable Docker healthcheck template | `references/code-templates/docker-compose-healthcheck.md` |

## Hard Rules

- Do not run device I/O, image processing, database writes, or network uploads on the UI thread.
- Device operations must have timeout, cancellation, reconnect behavior, state reporting, and contextual logs.
- Long-running loops and queue consumers must accept `CancellationToken`.
- Camera, PLC, scanner, and robot integrations must be interface-based and support fake/simulator implementations.
- Do not expose SDK global objects directly to ViewModels or business services.
- Do not hardcode passwords, tokens, MinIO keys, database passwords, or production-only IPs.
- Do not swallow exceptions in background services; log enough context to diagnose the station, device, task, and protocol step.
- Do not change PLC bits, robot fields, HTTP contracts, status codes, protocol enums, or device handshake semantics without explicit user approval.
- Large images belong in file/object storage; databases should store paths, keys, metadata, and results.
- Avoid commercial dependencies unless the user explicitly accepts them.

## Default Architecture

Use existing repo structure first. For new or unclear projects, default to:

```text
Presentation -> Application -> Domain
Infrastructure -> Application
Devices -> Application
Vision -> Application
```

`Domain` must not reference UI, database, SDK, network, file system, or object storage libraries.

For the full project layout and per-project responsibilities, read `references/csharp-solution-architecture.md`.

## Default Validation

Prefer these commands after code changes when the project supports them:

```bash
dotnet restore
dotnet build -c Release
dotnet test -c Release
```

If hardware is required, keep hardware tests gated by environment variables and run non-hardware tests by default.