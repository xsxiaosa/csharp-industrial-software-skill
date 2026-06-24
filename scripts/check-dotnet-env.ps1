$ErrorActionPreference = "Stop"

Write-Host "== .NET info =="
dotnet --info

Write-Host ""
Write-Host "== Repository scan =="
Get-ChildItem -Recurse -Depth 3 -Include *.sln,*.csproj,Directory.Build.props,Directory.Packages.props,global.json,docker-compose*.yml |
    Sort-Object FullName |
    ForEach-Object { $_.FullName }

$solution = Get-ChildItem -Recurse -Depth 3 -Filter *.sln | Select-Object -First 1
if ($solution) {
    Write-Host ""
    Write-Host "== Restore =="
    dotnet restore $solution.FullName

    Write-Host ""
    Write-Host "== Build =="
    dotnet build $solution.FullName -c Release --no-restore
}
else {
    Write-Host "No .sln found. Run from repository root or pass project path manually."
}
