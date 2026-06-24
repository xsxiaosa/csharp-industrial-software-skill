# Preferred Libraries Reference

Use existing project dependencies first. For new code or new templates, default to these choices unless the repository already standardizes on another stack.

| Area | Preferred choice |
|---|---|
| MVVM | `CommunityToolkit.Mvvm` 8.x |
| DI | `Microsoft.Extensions.DependencyInjection` |
| Config | `Microsoft.Extensions.Options` |
| Logging | `NLog` |
| Local DB | `FreeSql` + SQLite |
| Server DB | PostgreSQL |
| HTTP | `HttpClientFactory`; keep `RestSharp` if already used |
| Barcode | Existing `ZXing` / `IronBarcode` usage |
| Object storage | S3-compatible MinIO/R2 client |
| Desktop UI | WPF for existing projects; Avalonia for new cross-platform templates |
| Avalonia style | Semi.Avalonia + Ursa.Avalonia when modern UI is requested |

Notes:

- Partial property syntax in `CommunityToolkit.Mvvm` requires newer C# / SDK support. Verify the repo SDK before using it.
- Avoid commercial dependencies unless the user explicitly accepts them.
- Do not introduce a new package manager, UI framework, logging stack, or ORM without a clear project-level reason.