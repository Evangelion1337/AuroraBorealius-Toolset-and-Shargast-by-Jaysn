param(
    [string]$BinaryPath = "",
    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host @"
Aurora Borealis Toolset — Windows Launcher Wrapper

Usage:
    .\run_windows.ps1                      # Auto-detect and launch
    .\run_windows.ps1 -BinaryPath "C:\path\to\aurora-borealis.exe"

Auto-detection order for NWN installation:
    1. NWN environment variable
    2. Steam: C:\Program Files (x86)\Steam\steamapps\common\Neverwinter Nights
    3. GOG:   C:\GOG Games\Neverwinter Nights
    4. Custom registry key (HKLM:\SOFTWARE\WOW6432Node\BioWare\NWN)
"@
    exit 0
}

# --- Auto-detect NWN install path ---
$nwnRoot = $env:NWN
if (-not $nwnRoot) {
    $steamPath = "C:\Program Files (x86)\Steam\steamapps\common\Neverwinter Nights"
    $gogPath   = "C:\GOG Games\Neverwinter Nights"

    if (Test-Path "$steamPath\bin\win32\nwmain.exe") {
        $nwnRoot = $steamPath
        Write-Host "[INFO] Detected NWN via Steam: $nwnRoot"
    } elseif (Test-Path "$gogPath\bin\win32\nwmain.exe") {
        $nwnRoot = $gogPath
        Write-Host "[INFO] Detected NWN via GOG: $nwnRoot"
    } else {
        # Try registry
        $regPath = "HKLM:\SOFTWARE\WOW6432Node\BioWare\NWN"
        try {
            $regVal = Get-ItemProperty -Path $regPath -ErrorAction Stop
            if ($regVal.NWN) {
                $nwnRoot = $regVal.NWN
                Write-Host "[INFO] Detected NWN via registry: $nwnRoot"
            }
        } catch { }
    }

    if (-not $nwnRoot) {
        Write-Warning "[WARN] Could not auto-detect NWN installation."
        Write-Warning "Set the NWN environment variable or pass -BinaryPath manually."
        Write-Warning "Game data (tilesets, models, textures) may not load correctly."
    }
}
$env:NWN = $nwnRoot

# --- Resolve NWN user directory ---
$userDocs = [Environment]::GetFolderPath("MyDocuments")
$nwnUserDir = "$userDocs\Neverwinter Nights"
if (-not (Test-Path $nwnUserDir)) {
    Write-Host "[INFO] NWN user dir not found, creating: $nwnUserDir"
    New-Item -ItemType Directory -Path $nwnUserDir -Force | Out-Null
}
Write-Host "[INFO] NWN user directory: $nwnUserDir"

# --- Map HOME for the toolset (used for Documents/Neverwinter Nights/modules lookup) ---
$env:HOME = $userDocs

# --- Locate the binary ---
if (-not $BinaryPath) {
    $candidates = @(
        ".\target\release\aurora-borealis.exe",
        ".\target\debug\aurora-borealis.exe",
        ".\aurora-borealis.exe",
        "..\aurora-borealis.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) {
            $BinaryPath = $c
            break
        }
    }
}

if (-not $BinaryPath -or -not (Test-Path $BinaryPath)) {
    Write-Error "Could not find aurora-borealis.exe. Build it first or pass -BinaryPath."
    exit 1
}

Write-Host "[INFO] Launching: $BinaryPath"
Write-Host "[INFO] NWN root: $nwnRoot"
Write-Host ""

# Launch — stdout/stderr passthrough
& $BinaryPath @args
exit $LASTEXITCODE
