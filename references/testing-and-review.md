# Testing and Review Reference

## Default validation commands

```bash
dotnet restore
dotnet build -c Release
dotnet test -c Release
```

## Recommended test categories

- State machine tests.
- Parser tests for PLC/scanner protocol.
- Fake device tests.
- Queue/backpressure tests.
- Repository tests against SQLite.
- API endpoint tests with WebApplicationFactory.
- Hardware integration tests gated by environment variables.

## Hardware test gate

```bash
RUN_HARDWARE_TESTS=1 dotnet test -c Release --filter Category=Hardware
```

## Review checklist

- Build passes.
- No UI-thread blocking.
- No `.Result` / `.Wait()` in async path.
- All loops have `CancellationToken`.
- Device operations have timeout.
- SDK errors are logged.
- Large images are disposed or released.
- No secrets are committed.
- No unexpected commercial dependencies.
