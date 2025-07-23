param(
    [string]$tag
)

# Replace these variables with your values
$githubRepo = "chinsonyeh/cyrandommount"

# Check if -tag parameter is provided
if (-not $tag) {
    Write-Host "Usage: .\prepare_for_curseforge.ps1 -tag v1.1.4"
    exit 1
}

$githubTag = $tag

# Confirm tag
Write-Host "Current tag is: $githubTag"
$confirm = Read-Host "Is this tag correct? (Y/N) [Y]"
if ($confirm -and $confirm -ne "Y" -and $confirm -ne "y") {
    $githubTag = Read-Host "Please enter the correct tag name"
}

# Directly compose the public download URL
$zipUrl = "https://github.com/$githubRepo/archive/refs/tags/$githubTag.zip"
$zipFile = "$githubTag.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile

# Extract to temporary folder
$tempDir = Join-Path $PWD "temp_extract"
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
Expand-Archive -Path $zipFile -DestinationPath $tempDir

# Find cyrandommount-* directory
$srcDir = Get-ChildItem -Path $tempDir -Directory | Where-Object { $_.Name -like "cyrandommount-*" } | Select-Object -First 1

if ($null -eq $srcDir) {
    Write-Host "Source directory not found."
    exit 1
}

# Create $destDir named CYRandomMount
$destDir = Join-Path $PWD "CYRandomMount"
if (Test-Path $destDir) { Remove-Item $destDir -Recurse -Force }
if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }  

# Copy files to $destDir, excluding .gitignore and sync.ps1
Get-ChildItem -Path $srcDir.FullName -Recurse -File | Where-Object {
    $_.Name -notin @('.gitignore', 'sync.ps1', 'prepare_for_curseforge.ps1', 'check_version.ps1') -and $_.FullName -notmatch '\.github(\\|\/|$)'
} | ForEach-Object {
    $targetPath = Join-Path $destDir $_.FullName.Substring($srcDir.FullName.Length + 1)
    $targetDir = Split-Path $targetPath -Parent
    if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir | Out-Null }
    Copy-Item $_.FullName -Destination $targetPath -Force
    Write-Host "Copied: $($_.Name)"
}

# Delete temporary folder
Remove-Item $tempDir -Recurse -Force

# Delete original zip file
Remove-Item $zipFile -Force

# Compress CYRandomMount folder into zip, filename includes version
$zipOutput = "CYRandomMount-$githubTag.zip"
if (Test-Path $zipOutput) { Remove-Item $zipOutput -Force }
Compress-Archive -Path $destDir -DestinationPath $zipOutput
Write-Host "Created: $(Split-Path $zipOutput -Leaf)"

# Delete CYRandomMount folder
Remove-Item $destDir -Recurse -Force


