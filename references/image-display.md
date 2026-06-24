# Industrial Image Display Reference

Use these rules for industrial images, especially 20MB-level camera frames.

## Memory and lifetime

- Avoid keeping many full-size images in memory.
- Generate thumbnails for list/grid display.
- Dispose SDK image buffers explicitly when the SDK requires manual release.
- Keep UI-bound image objects lightweight and cache-aware.

## Pipeline separation

Split the image workflow into stages:

```text
capture -> save raw image -> AI infer -> result merge -> UI update -> upload -> archive
```

Rules:

- Do not block image capture while waiting for AI or upload when throughput matters.
- Use bounded queues for backpressure.
- Include `TaskKey`, camera id, position, and station id in logs.
- Prefer file/object storage for large images; store only metadata and paths in the database.

## UI thread rule

Decode, resize, save, upload, and AI infer off the UI thread. Marshal only final UI-bound state changes back to the UI thread.