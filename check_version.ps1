param(
    [string]$tag
)

# Show usage and exit if -tag parameter is not provided
if (-not $tag) {
    Write-Host "Usage: .\check_version.ps1 -tag v1.1.4"
    exit 1
}

# Remove leading 'v' if present
if (![string]::IsNullOrEmpty($tag) -and $tag.StartsWith("v")) {
    $version = $tag.Substring(1)
} else {
    $version = $tag
}

# Set file paths
$tocPath = "CYRandomMount.toc"
$releaseNotesPath = "ReleaseNotes.md"

# Check if files exist
if (!(Test-Path $tocPath)) {
    Write-Host "File not found: $tocPath"
    exit 1
}
if (!(Test-Path $releaseNotesPath)) {
    Write-Host "File not found: $releaseNotesPath"
    exit 1
}

# Read version from CYRandomMount.toc
$tocVersion = Select-String -Path $tocPath -Pattern "^## Version:\s*(.+)$" | ForEach-Object {
    $_.Matches[0].Groups[1].Value.Trim()
}

# Read version from ReleaseNotes.md (assume first line is vX.Y.Z or X.Y.Z)
$releaseNotesVersion = (Get-Content $releaseNotesPath | Select-Object -First 1) -replace "^v", ""

if ($tocVersion -ne $version) {
    Write-Host "CYRandomMount.toc version ($tocVersion) does not match tag version ($version)"
    exit 1
}
if ($releaseNotesVersion -ne $version) {
    Write-Host "ReleaseNotes.md version ($releaseNotesVersion) does not match tag version ($version)"
    exit 1
}

Write-Host "Version check passed: $version"