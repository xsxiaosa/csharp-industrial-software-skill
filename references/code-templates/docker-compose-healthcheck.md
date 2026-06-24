# Docker Compose Healthcheck Template

Use this template for Docker Compose services that expose an HTTP health endpoint.

```yaml
services:
  app:
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 3s
      retries: 3
```