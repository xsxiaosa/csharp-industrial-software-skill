# ASP.NET Core Service Reference

Use these rules for ASP.NET Core APIs, station services, and self-hosted Kestrel applications.

## Structure

- Use the minimal hosting model.
- Keep controllers/endpoints thin.
- Put business logic in Application services.
- Use DTOs for API contracts; do not expose persistence entities when mapping is non-trivial.

## Operations

- Add health checks for database, object storage, queues, and downstream services.
- Use structured logs and request correlation id.
- Avoid returning internal exception details to clients.
- Put long-running work in a background queue or worker service; do not block HTTP requests.

## Reliability

- Configure HTTP client timeouts.
- Use retry or circuit-breaker behavior only when the operation is idempotent or safely deduplicated.
- Log downstream failures with URL/service name, elapsed time, status code, and business identifier.