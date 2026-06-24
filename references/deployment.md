# Deployment Reference

## Windows

- Desktop app: provide publish command and config file layout.
- Service: use Worker Service + Windows Service integration.
- Logs should live under a configurable directory.
- Do not hardcode production paths or secrets.

Example publish command:

```bash
dotnet publish src/<ProjectName>/<ProjectName>.csproj -c Release -r win-x64 --self-contained true -o publish/win-x64
```

## Linux and Docker

- Prefer Docker Compose for server components.
- Include health checks.
- Separate app config from the image.
- Do not bake secrets into Dockerfile.
- For no-downtime update, use blue/green deployment or a reverse proxy with two app instances.

See `references/code-templates/docker-compose-healthcheck.md` for a copyable healthcheck template.