# PowerShell script to copy files from Blender interface theme presets to retrieve directory
# Source: Blender interface theme presets directory  
# Destination: retrieve directory in current workspace
# Usage: btheme

param(
    [switch]$WhatIf
)

# Define source and destination paths
$SourcePath = "C:\Users\M\AppData\Roaming\Blender Foundation\Blender\4.5\scripts\presets\interface_theme"
$RetrieveDir = Join-Path (Get-Location) "retrieve"

Write-Host "Requin Blue Theme File Copy Script" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Source: $SourcePath" -ForegroundColor Yellow
Write-Host "Destination: $RetrieveDir" -ForegroundColor Yellow
Write-Host ""

# Check if current directory has retrieve folder
if (-not (Test-Path $RetrieveDir)) {
    Write-Error "No 'retrieve' directory found in current location: $(Get-Location)"
    Write-Host "Please run this script from a directory that contains a 'retrieve' folder." -ForegroundColor Red
    exit 1
}

# Check if source directory exists
if (-not (Test-Path $SourcePath)) {
    Write-Error "Source directory does not exist: $SourcePath"
    Write-Host "Please verify that Blender is installed and interface themes exist in the presets directory." -ForegroundColor Red
    exit 1
}

# Get all files from source directory
$SourceFiles = @(Get-ChildItem -Path $SourcePath -Recurse -File)

if ($SourceFiles.Count -eq 0) {
    Write-Warning "No files found in source directory."
    exit 0
}

Write-Host "Found $($SourceFiles.Count) files to copy:" -ForegroundColor Green

# Copy files while preserving directory structure
foreach ($File in $SourceFiles) {
    # Calculate relative path from source root
    $RelativePath = $File.FullName.Substring($SourcePath.Length + 1)
    $DestinationFile = Join-Path $RetrieveDir $RelativePath
    $DestinationDir = Split-Path $DestinationFile -Parent
    
    Write-Host "  $RelativePath" -ForegroundColor Gray
    
    if ($WhatIf) {
        Write-Host "    WHAT-IF: Would copy to $DestinationFile" -ForegroundColor Magenta
        continue
    }
    
    # Create destination subdirectory if needed
    if (-not (Test-Path $DestinationDir)) {
        New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null
    }
    
    try {
        Copy-Item -Path $File.FullName -Destination $DestinationFile -Force
        Write-Host "    ✓ Copied successfully (overwrite enabled)" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to copy $($File.FullName): $($_.Exception.Message)"
    }
}

if (-not $WhatIf) {
    Write-Host ""
    Write-Host "Copy operation completed!" -ForegroundColor Green
    Write-Host "Files copied to: $RetrieveDir" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "This was a preview (WhatIf mode). Run without -WhatIf to actually copy files." -ForegroundColor Magenta
}

# Usage examples
Write-Host ""
Write-Host "Usage examples:" -ForegroundColor Cyan
Write-Host "  btheme           # Copy files with force overwrite"
Write-Host "  btheme -WhatIf   # Preview what would be copied"