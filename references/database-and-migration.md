# Database and Migration Reference

## Local agent

Use SQLite for local resilience:

- Pending tasks.
- Upload retry queue.
- Device snapshots.
- Minimal audit/cache data.

## Server

Use PostgreSQL for central audit/review platforms:

- `audit_task`
- `audit_image`
- user/role/permission tables
- assignment/claim/timeout recycle tables
- status/version fields for concurrency

## Image data rule

Do not store large images in the database. Store paths, object-storage keys, metadata, and judgment results.

## Migration with live inserts

If new data arrives during migration and data is insert-only:

1. Record time point `T0`.
2. Run full backup.
3. Restore full backup.
4. Sync rows with `CreatedAt > T0`.
5. Verify counts and max timestamps.
6. Switch traffic.

If updates or deletes exist, do not rely only on `CreatedAt`. Propose CDC, logical replication, dual-write, or an application-level change log.