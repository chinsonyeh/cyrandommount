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

# Read version from ReleaseNotes.md
# Support multiple formats, e.g.:
#   ## [1.2.5]
#   v1.2.5
#   1.2.5

# Try to find a markdown header like: ## [1.2.5]
$rnMatch = Select-String -Path $releaseNotesPath -Pattern '^\s*##\s*\[v?(\d+\.\d+\.\d+)\]' | Select-Object -First 1
if ($rnMatch) {
    $releaseNotesVersion = $rnMatch.Matches[0].Groups[1].Value
} else {
    # Fallback: take the first non-empty line and extract a semver-like version
    $firstLine = Get-Content $releaseNotesPath | Where-Object { $_.Trim() -ne '' } | Select-Object -First 1
    $m = [regex]::Match($firstLine, 'v?(\d+\.\d+\.\d+)')
    if ($m.Success) {
        $releaseNotesVersion = $m.Groups[1].Value
    } else {
        Write-Host "Unable to parse version from $releaseNotesPath"
        exit 1
    }
}

if ($tocVersion -ne $version) {
    Write-Host "CYRandomMount.toc version ($tocVersion) does not match tag version ($version)"
    exit 1
}
if ($releaseNotesVersion -ne $version) {
    Write-Host "ReleaseNotes.md version ($releaseNotesVersion) does not match tag version ($version)"
    exit 1
}

Write-Host "Version check passed: $version"