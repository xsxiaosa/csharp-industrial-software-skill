#!/usr/bin/env bash
set -euo pipefail

echo "== .NET info =="
dotnet --info

echo
echo "== Repository scan =="
find . -maxdepth 3 \( -name "*.sln" -o -name "*.csproj" -o -name "Directory.Build.props" -o -name "Directory.Packages.props" -o -name "global.json" -o -name "docker-compose*.yml" \) -print | sort

echo
if find . -maxdepth 3 -name "*.sln" | grep -q .; then
  echo "== Restore =="
  dotnet restore
  echo
  echo "== Build =="
  dotnet build -c Release --no-restore
else
  echo "No .sln found. Run from repository root or pass project path manually."
fi
