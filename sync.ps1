$source = Split-Path -Parent $MyInvocation.MyCommand.Definition
$destination = 'your_path\World of Warcraft\_retail_\Interface\AddOns\CYRandomMount'

# Check if $destination exists
if (-not (Test-Path $destination)) {
    Write-Host "Destination folder does not exist. Creating: $destination"
    New-Item -ItemType Directory -Path $destination | Out-Null
}

# Sync only specific files
$filesToSync = @(
    'CYRandomMount.lua',
    'CYRandomMount.toc',
    'CYRandomMountOptions.lua'
)

foreach ($file in $filesToSync) {
    $sourcePath = Join-Path $source $file
    if (Test-Path $sourcePath) {
        Copy-Item $sourcePath -Destination $destination -Force
        Write-Host $file
    } else {
        Write-Host "Warning: $file not found in source" -ForegroundColor Yellow
    }
}
