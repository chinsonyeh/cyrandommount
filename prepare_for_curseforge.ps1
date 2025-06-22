# Replace these variables with your values
$githubRepo = "chinsonyeh/cyrandommount"
$githubTag = "v1.0.0"

# 確認 tag
Write-Host "Current tag is: $githubTag"
$confirm = Read-Host "Is this tag correct? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    $githubTag = Read-Host "Please enter the correct tag name"
}

# 直接組成公開下載網址
$zipUrl = "https://github.com/$githubRepo/archive/refs/tags/$githubTag.zip"
$zipFile = "$githubTag.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile

# 解壓縮到暫存資料夾
$tempDir = Join-Path $PWD "temp_extract"
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
Expand-Archive -Path $zipFile -DestinationPath $tempDir

# 找到 cyrandommount-* 目錄
$srcDir = Get-ChildItem -Path $tempDir -Directory | Where-Object { $_.Name -like "cyrandommount-*" } | Select-Object -First 1

if ($null -eq $srcDir) {
    Write-Host "Source directory not found."
    exit 1
}

# 建立 $destDir 名稱為 CYRandomMount
$destDir = Join-Path $PWD "CYRandomMount"
if (Test-Path $destDir) { Remove-Item $destDir -Recurse -Force }
if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }  

# 複製檔案到 $destDir，排除 .gitignore 和 sync.ps1
Get-ChildItem -Path $srcDir.FullName -Recurse -File | Where-Object {
    $_.Name -notin @('.gitignore', 'sync.ps1')
} | ForEach-Object {
    $targetPath = Join-Path $destDir $_.FullName.Substring($srcDir.FullName.Length + 1)
    $targetDir = Split-Path $targetPath -Parent
    if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir | Out-Null }
    Copy-Item $_.FullName -Destination $targetPath -Force
    Write-Host "Copied: $($_.Name)"
}

# 刪除暫存資料夾
Remove-Item $tempDir -Recurse -Force

# 刪除原始 zip 檔案
Remove-Item $zipFile -Force

# 將CYRandomMount資料夾壓縮成 zip
$zipOutput = "$destDir.zip"
if (Test-Path $zipOutput) { Remove-Item $zipOutput -Force }
Compress-Archive -Path $destDir/* -DestinationPath $zipOutput
Write-Host "Created: $(Split-Path $zipOutput -Leaf)"

# 刪除 CYRandomMount 資料夾
Remove-Item $destDir -Recurse -Force


