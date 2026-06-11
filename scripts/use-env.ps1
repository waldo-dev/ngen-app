# Switch Flutter app environment by copying the matching settings file.
# Usage: .\scripts\use-env.ps1 local
#        .\scripts\use-env.ps1 prod
# Then stop the app and Run again (hot reload does not reload assets).

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("local", "prod", "production")]
    [string]$Env
)

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$target = Join-Path $root "assets\cfg\settings.json"

switch ($Env) {
    "local" { $source = Join-Path $root "assets\cfg\settings.local.json" }
    default { $source = Join-Path $root "assets\cfg\settings.production.json" }
}

if (-not (Test-Path $source)) {
    Write-Error "Missing $source"
    exit 1
}

Copy-Item -Path $source -Destination $target -Force
Write-Host "OK: settings.json <- $(Split-Path $source -Leaf)"
Write-Host "Restart the app (Stop + Run). For a phone on USB, edit host in settings.local.json to your PC LAN IP."
