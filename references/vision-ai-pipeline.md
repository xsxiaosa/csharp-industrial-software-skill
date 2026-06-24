# Vision and AI Pipeline Reference

Default pipeline:

```text
Trigger received
  -> create TaskKey
  -> capture image(s)
  -> save raw image to Pending
  -> enqueue AI inference
  -> write result json
  -> update UI thumbnail/result
  -> upload image/metadata
  -> archive or mark failed
```

Rules:

- Do not block capture while waiting for AI when throughput matters.
- Use bounded queues for backpressure.
- File names should include `TaskKey`, camera/position, and OK/NG when available.
- Large images go to file/object storage, not database.
- Store metadata in DB: path/key, product id, type no, position, AI result, manual result, timestamps.
- Logs must include `TaskKey`, identifier, camera id, and station id.
- Make retries idempotent; repeated uploads should not duplicate final business records.

Suggested task key format:

```text
yyyyMMddHHmmssfff
```

Suggested local directories:

```text
Pending/
Archive/
Failed/
```

Suggested sidecar metadata:

```json
{
  "taskKey": "20260624153045123",
  "identifier": "string",
  "locationId": "string",
  "typeNo": "string",
  "overallResult": "OK",
  "items": []
}
```