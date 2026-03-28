# install.ps1 — Bootstrap installer for alloy-host (Windows)
#
# Usage (run from a saved copy of this script, recommended):
#   powershell -ExecutionPolicy Bypass -File .\install.ps1
#
# Pinned version:
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 -Version 0.3.0
#
# Parameters / environment:
#   -Version / ALLOY_HOST_VERSION   Exact version, e.g. "0.3.0" (optional; default = latest)
#   -InstallDir                    Install directory (default: %LOCALAPPDATA%\alloy-host)
#   -SkipPath                      Do not append InstallDir to the user PATH
#
# Linux and macOS: use scripts/install.sh instead.

[CmdletBinding()]
param(
    [string] $Version = $env:ALLOY_HOST_VERSION,
    [string] $InstallDir = "",
    [switch] $SkipPath
)

$ErrorActionPreference = "Stop"

$Repo = "alloy-it/alloy-host-releases"
$BinaryName = "alloy-host.exe"

function Write-Info($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "OK  $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "warn: $msg" -ForegroundColor Yellow }
function Die($msg) {
    Write-Host "error: $msg" -ForegroundColor Red
    exit 1
}

# Architecture: amd64 vs arm64 (Windows 11 ARM)
$procArch = $env:PROCESSOR_ARCHITECTURE
if ($procArch -eq "ARM64") {
    $Arch = "arm64"
} elseif ($procArch -eq "AMD64") {
    $Arch = "amd64"
} else {
    Die "Unsupported processor architecture: $procArch (only amd64 and arm64 Windows builds are published)."
}

if ([string]::IsNullOrWhiteSpace($InstallDir)) {
    $InstallDir = Join-Path $env:LOCALAPPDATA "alloy-host"
}

$verTrim = if ($Version) { $Version.Trim().TrimStart("v") } else { "" }

if ($verTrim) {
    $Tag = "v$verTrim"
    $ZipFilename = "alloy-host_${verTrim}_windows_${Arch}.zip"
} else {
    $Tag = "latest"
    $ZipFilename = "alloy-host_latest_windows_${Arch}.zip"
}

$BaseUrl = "https://github.com/$Repo/releases/download/$Tag"
$Url = "$BaseUrl/$ZipFilename"

Write-Host ""
Write-Host "alloy-host installer" -ForegroundColor White
Write-Host "  Binary : $BinaryName"
Write-Host "  Version: $(if ($verTrim) { $verTrim } else { 'latest' })"
Write-Host "  Arch   : windows/$Arch"
Write-Host "  Install: $InstallDir"
Write-Host ""

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {
    # PowerShell Core uses TLS 1.2+ by default
}

$tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("alloy-host-install-" + [Guid]::NewGuid().ToString("n"))
New-Item -ItemType Directory -Path $tmpRoot -Force | Out-Null

try {
    $zipPath = Join-Path $tmpRoot $ZipFilename
    Write-Info "Downloading $ZipFilename…"
    try {
        Invoke-WebRequest -Uri $Url -OutFile $zipPath -UseBasicParsing
    } catch {
        Die "Failed to download ${Url}: $_"
    }

    $extractDir = Join-Path $tmpRoot "extract"
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
    Write-Info "Extracting archive…"
    Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

    $exePath = Join-Path $extractDir $BinaryName
    if (-not (Test-Path -LiteralPath $exePath)) {
        Die "Binary '$BinaryName' not found after extraction."
    }

    if (-not (Test-Path -LiteralPath $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }

    $destExe = Join-Path $InstallDir $BinaryName
    Write-Info "Installing to $InstallDir…"
    Copy-Item -LiteralPath $exePath -Destination $destExe -Force

    if (-not $SkipPath) {
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ([string]::IsNullOrEmpty($userPath)) {
            $userPath = ""
        }
        $parts = $userPath -split ";" | Where-Object { $_ -ne "" }
        $normInstall = $InstallDir.TrimEnd("\")
        $already = $false
        foreach ($p in $parts) {
            if ($p.TrimEnd("\") -ieq $normInstall) {
                $already = $true
                break
            }
        }
        if (-not $already) {
            if ($userPath -and -not $userPath.EndsWith(";")) {
                $userPath += ";"
            }
            $userPath += $InstallDir
            [Environment]::SetEnvironmentVariable("Path", $userPath, "User")
            Write-Ok "Added $InstallDir to your user PATH (open a new terminal to use alloy-host)."
        }
    }

    Write-Host ""
    Write-Host "Installation complete!" -ForegroundColor Green
    Write-Ok "Binary : $destExe"
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $verOut = & $destExe --version 2>&1
        if ($verOut) {
            Write-Ok "Version: $verOut"
        }
    } finally {
        $ErrorActionPreference = $prevEap
    }

    Write-Host ""
    Write-Host "Get started:" -ForegroundColor Cyan
    Write-Host "  alloy-host check-health"
    Write-Host ""
    if (-not $SkipPath) {
        Write-Warn "If 'alloy-host' is not found, close and reopen your terminal (PATH is refreshed for new processes)."
    }
} finally {
    Remove-Item -LiteralPath $tmpRoot -Recurse -Force -ErrorAction SilentlyContinue
}
