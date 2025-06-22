$source = Split-Path -Parent $MyInvocation.MyCommand.Definition
$destination = 'your_path\World of Warcraft\_retail_\Interface\AddOns\CYRandomMount'

# Check if $destination exists
if (-not (Test-Path $destination)) {
    Write-Host "Destination folder does not exist. Creating: $destination"
    New-Item -ItemType Directory -Path $destination | Out-Null
}

# Copy all files and folders except .git and sync.ps1
Get-ChildItem -Path $source -Exclude '.git', 'sync.ps1' -Force | ForEach-Object {
    $target = Join-Path $destination $_.Name
    if ($_.PSIsContainer) {
        Copy-Item $_.FullName -Destination $target -Recurse -Force
        Write-Host $_.Name
    } else {
        Copy-Item $_.FullName -Destination $destination -Force
        Write-Host $_.Name
    }
}