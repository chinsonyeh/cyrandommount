# GitHub Actions 工作流程

此目錄包含 CYRandomMount 插件的自動化工作流程。

## 發佈工作流程

`release.yml` 工作流程會在您推送版本標籤時，自動發佈到 GitHub 和 CurseForge。

### 設定步驟

1. **取得 CurseForge API Token**
   - 前往 [CurseForge API Tokens](https://authors.curseforge.com/account/api-tokens)
   - 產生一個具有「Upload」權限的新 token
   - 複製 token

2. **在 GitHub 新增 Secrets**
   - 前往您的 GitHub repository
   - 導覽至 Settings → Secrets and variables → Actions
   - 點擊「New repository secret」
   - 新增以下 secret：
     - Name: `CF_API_TOKEN`
     - Value: 您的 CurseForge API token

3. **設定專案 ID**
   - 開啟 `.github/workflows/release.yml`
   - 將 `YOUR_PROJECT_ID` 替換為您實際的 CurseForge 專案 ID
   - 您可以在 CurseForge 專案的 URL 中找到此 ID

4. **遊戲版本（自動）**
   - 工作流程會自動從 `CYRandomMount.toc` 提取 Interface 版本
   - 無需手動設定 - 它會讀取 `## Interface: 120000` 這一行
   - 提取的版本會直接用於 CurseForge 的 `game_versions`

### 使用方式

1. **進行變更並提交**
   ```bash
   git add .
   git commit -m "feat: your changes"
   ```

2. **更新版本號**
   - 更新 `CYRandomMount.toc` (## Version)
   - 在 `ReleaseNotes.md` 中新增版本條目

3. **建立並推送版本標籤**
   ```bash
   git tag v2.4.0
   git push origin v2.4.0
   ```

4. **自動發佈**
   - GitHub Actions 會自動：
     - 建立發佈套件
     - 在 GitHub 建立 Release 並附上 zip 檔案
     - 上傳到 CurseForge 並包含更新日誌

### 工作流程詳細說明

工作流程執行以下步驟：

1. **Checkout code**: 取得 repository 程式碼
2. **Extract version**: 從標籤中提取版本號
3. **Extract Interface version**: 從 TOC 檔案讀取 Interface 版本，用於 CurseForge 相容性
4. **Create package**: 建立只包含必要插件檔案的 zip 檔案
5. **GitHub Release**: 在 GitHub 上建立包含套件的 release
6. **CurseForge Upload**: 上傳套件到 CurseForge，並自動偵測遊戲版本

### 套件中包含的檔案

以下檔案會被打包進行發佈：
- `CYRandomMount.lua`
- `CYRandomMount.toc`
- `CYRandomMountOptions.lua`
- `ReleaseNotes.md`

排除的檔案（透過打包設定）：
- 開發腳本（`.ps1` 檔案）
- Git 設定（`.git`、`.gitignore`）
- IDE 設定（`.vscode`）
- GitHub 工作流程（`.github`）
- 本地規格和測試檔案

### 故障排除

**如果工作流程失敗：**

1. 檢查您 GitHub repository 的 Actions 標籤以查看錯誤詳情
2. 驗證您的 `CF_API_TOKEN` secret 設定正確
3. 確保專案 ID 正確
4. 檢查遊戲版本 ID 對當前 WoW 資料片是否有效

**常見問題：**

- **「Invalid API token」**: 重新產生您的 CurseForge API token
- **「Invalid project ID」**: 驗證您的 CurseForge 專案 ID
- **「Game version not found」**: 以當前 WoW 版本 ID 更新 `game_versions` 欄位

### 手動發佈（備用方案）

如果您需要手動發佈：

1. 在本地建立套件：
   ```bash
   mkdir -p release/CYRandomMount
   cp CYRandomMount.lua CYRandomMount.toc CYRandomMountOptions.lua release/CYRandomMount/
   cd release
   zip -r CYRandomMount-v2.4.0.zip CYRandomMount/
   ```

2. 透過網站手動上傳到 CurseForge
3. 手動在 GitHub 建立 Release 並附上 zip 檔案
