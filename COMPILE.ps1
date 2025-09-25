# PowerShell script to zip src folder using Blender manifest ID and version
# Usage: bziptheme

param(
    [string]$SourceDir = "src",
    [string]$ManifestFile = "src\blender_manifest.toml"
)

Write-Host "Blender Theme Zip Creator" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory (has src folder)
if (-not (Test-Path $SourceDir)) {
    Write-Error "Source directory '$SourceDir' not found in current location: $(Get-Location)"
    Write-Host "Please run this script from a directory that contains a 'src' folder." -ForegroundColor Red
    exit 1
}

# Check if manifest file exists
if (-not (Test-Path $ManifestFile)) {
    Write-Error "Manifest file not found: $ManifestFile"
    Write-Host "Please ensure the blender_manifest.toml file exists in the src directory." -ForegroundColor Red
    exit 1
}

Write-Host "Reading manifest file: $ManifestFile" -ForegroundColor Yellow

# Parse TOML file to extract ID and version
try {
    $manifestContent = Get-Content $ManifestFile -Raw
    
    # Extract ID using regex
    if ($manifestContent -match 'id\s*=\s*["]([^"]+)["]') {
        $extensionId = $matches[1]
        Write-Host "Found extension ID: $extensionId" -ForegroundColor Green
    } else {
        Write-Error "Could not find 'id' field in manifest file"
        exit 1
    }
    
    # Extract version using regex (exclude schema_version)
    if ($manifestContent -match '(?<!schema_)version\s*=\s*["]([^"]+)["]') {
        $version = $matches[1]
        Write-Host "Found version: $version" -ForegroundColor Green
    } else {
        Write-Error "Could not find 'version' field in manifest file"
        exit 1
    }
} catch {
    Write-Error "Failed to read manifest file: $($_.Exception.Message)"
    exit 1
}

# Create dist directory if it doesn't exist
$distDir = Join-Path (Get-Location) "dist"
if (-not (Test-Path $distDir)) {
    Write-Host "Creating dist directory..." -ForegroundColor Green
    New-Item -ItemType Directory -Path $distDir -Force | Out-Null
}

# Create zip filename
$zipFileName = "${extensionId}_${version}.zip"
$zipPath = Join-Path $distDir $zipFileName

Write-Host ""
Write-Host "Creating zip file: $zipFileName" -ForegroundColor Yellow
Write-Host "Output directory: dist\" -ForegroundColor Gray

# Remove existing zip file if it exists
if (Test-Path $zipPath) {
    Write-Host "Removing existing zip file..." -ForegroundColor Orange
    Remove-Item $zipPath -Force
}

# Create the zip file
try {
    # Get all items in src directory
    $sourceItems = Get-ChildItem -Path $SourceDir -Recurse
    
    if ($sourceItems.Count -eq 0) {
        Write-Warning "No files found in source directory."
        exit 0
    }
    
    Write-Host "Compressing $($sourceItems.Count) items..." -ForegroundColor Gray
    
    # Use .NET compression to create zip
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory(
        (Resolve-Path $SourceDir).Path,
        $zipPath,
        [System.IO.Compression.CompressionLevel]::Optimal,
        $false  # Don't include base directory in zip
    )
    
    $zipInfo = Get-Item $zipPath
    $fileSizeMB = [math]::Round($zipInfo.Length / 1MB, 2)
    
    Write-Host ""
    Write-Host "✓ Zip file created successfully!" -ForegroundColor Green
    Write-Host "File: $zipFileName" -ForegroundColor Yellow
    Write-Host "Size: $fileSizeMB MB" -ForegroundColor Yellow
    Write-Host "Location: dist\$zipFileName" -ForegroundColor Gray
    
} catch {
    Write-Error "Failed to create zip file: $($_.Exception.Message)"
    exit 1
}

Write-Host ""
Write-Host "Zip creation completed!" -ForegroundColor Green