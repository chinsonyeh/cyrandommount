# 實作任務清單：CYRandomMount 基礎功能

**功能分支**: `1-baseline`  
**建立日期**: 2025-11-23  
**狀態**: 已完成  

## 任務分類說明

- **[CORE]**: 核心功能，必須完成
- **[UI]**: 使用者介面相關
- **[DATA]**: 資料管理與持久化
- **[PERF]**: 效能優化
- **[I18N]**: 國際化與多語言
- **[TEST]**: 測試與品質保證
- **[DOC]**: 文件撰寫

## 已完成任務

### 階段 1: 基礎架構建立
- [x] **[CORE] T-001**: 建立 TOC 檔案定義插件元資料
  - 設定 Interface 版本為 110205（WoW 11.0.2.5）
  - 宣告 SavedVariables: CYRandomMountDB
  - 定義檔案載入順序（Options → Main）
  - 完成日期: 初始版本

- [x] **[CORE] T-002**: 實作雙重事件初始化系統
  - 監聽 ADDON_LOADED 事件（arg1 == "CYRandomMount"）
  - 監聽 PLAYER_LOGIN 事件
  - 實作 TryLoadOptions() 確保兩個事件都觸發後才初始化
  - 完成日期: 初始版本

- [x] **[DATA] T-003**: 設計 CYRandomMountDB 資料結構
  - Default: 帳號共用的預設設定檔，包含共用坐騎清單
    - FlyingMounts: array（飛行坐騎 ID 列表）
    - GroundMounts: array（地面坐騎 ID 列表）
    - availableMountsCount: number（可用坐騎總數）
  - <角色唯一識別碼>: 每個角色獨立的設定
    - macroName: string（巨集名稱）
    - RefreshTime: number（刷新時間，5-30 秒）
    - UpdateMacroMode: number（更新模式，1 或 2）
    - ListMode: number（清單模式，1=角色獨立清單，2=使用共用清單，預設 1）
    - FlyingMounts: array（飛行坐騎 ID 列表）
    - GroundMounts: array（地面坐騎 ID 列表）
    - availableMountsCount: number（可用坐騎總數）
  - 完成日期: 初始版本

### 階段 2: 巨集管理系統
- [x] **[CORE] T-004**: 實作 CreateMountMacro() 函式
  - 檢查巨集是否已存在（遍歷 GetNumMacros()）
  - 檢查巨集數量限制（MAX_ACCOUNT_MACROS = 120）
  - 使用預設坐騎 ID 1589（Renewed Proto-Drake）建立初始巨集
  - 處理坐騎不可用情況的備用方案
  - 完成日期: v1.0.0

- [x] **[CORE] T-005**: 實作 SafeEditMacro() 錯誤處理包裝器
  - 使用 pcall 捕捉 EditMacro API 錯誤
  - 顯示友善的錯誤訊息給玩家
  - 完成日期: v1.1.0

- [x] **[CORE] T-006**: 實作 UpdateMountMacroByZone() 核心邏輯
  - 檢查玩家是否正在編輯巨集（MacroFrame:IsShown()）
  - 取得當前區域 ID（C_Map.GetBestMapForUnit）
  - 判斷是否為特殊區域（如 Undermine 2346）
  - 檢查是否在室內（IsIndoors()）
  - 判斷區域是否可飛行（IsFlyableArea()）
  - 根據區域類型選擇坐騎並更新巨集
  - 完成日期: v1.0.0

- [x] **[CORE] T-007**: 實作巨集內容動態生成（更新：支援排程下一座騎）
  - 行 1: `#showtooltip`
  - 行 2: `/run if IsMounted() then Dismount() else C_MountJournal.SummonByID(<currentMountID>) end`
  - 行 3: `/run CYRandomMount_InstantUpdate()`（無條件排程並改寫巨集為下一座騎）
  - 確保召喚被中斷時巨集仍已更新（使用者故事 4 新增驗收）
  - 完成日期: v2.0.0

### 階段 3: 坐騎選擇系統
- [x] **[CORE] T-008**: 實作 GetRandomSelectedFlyingMount() 函式
  - 取得當前角色的 ListMode 設定
  - 根據 ListMode 決定讀取來源（角色專屬或 Default 共用清單）
  - 從對應來源的 FlyingMounts 陣列讀取坐騎 ID
  - 驗證坐騎可用性（C_MountJournal.GetMountInfoByID → isUsable）
  - 過濾不可用坐騎
  - 使用 math.random() 隨機選擇
  - 完成日期: v1.0.0

- [x] **[CORE] T-009**: 實作 GetRandomSelectedGroundMount() 函式
  - 解析 mountTypeID（C_MountJournal.GetMountInfoExtraByID 第 5 個回傳值）
  - 402/269 判定為龍騎術飛行坐騎
  - 241/424 判定為一般飛行坐騎
  - 其他判定為地面坐騎
  - 飛行坐騎也加入地面坐騎清單
  - 完成日期: v1.0.0

### 階段 4: 事件與計時器系統
- [ ] **[CORE] T-011**: 實作區域變更事件監聽
  - 註冊 ZONE_CHANGED 事件
  - 註冊 ZONE_CHANGED_INDOORS 事件
  - 註冊 ZONE_CHANGED_NEW_AREA 事件
  - 註冊 PLAYER_ENTERING_WORLD 事件
  - 使用 `C_Timer.After(1, ...)` 延遲執行更新（原因：API 在事件觸發瞬間可能尚未就緒）
  - Acceptance: 事件觸發後會在 ~1 秒後呼叫 `UpdateMountMacroByZone()`，且任何在 Macro 編輯畫面開啟時不會進行 EditMacro
  - Estimate: 0.5h
  - 完成日期: v1.0.0

- [x] **[CORE] T-012**: 實作 OnUpdate 週期更新計時器
  - 建立 Frame 並設定 OnUpdate script
  - 累積 elapsed 時間
  - 檢查 UpdateMacroMode 是否為 2（週期更新）
  - 達到 RefreshTime 時觸發 UpdateMountMacroByZone()
  - 重置 elapsed 計數器
  - 完成日期: v1.0.0

- [x] **[CORE] T-013**: 實作 CYRandomMount_InstantUpdate() 全域函式（重新定義）
  - 每次巨集執行後都會被呼叫，但僅在未騎乘狀態時更新座騎
  - 檢查 IsMounted() 狀態，若已騎乘則不執行更新（避免下馬時切換座騎）
  - 若未騎乘，取得下一個區域適用的隨機坐騎 ID（可飛行/地面/特殊區域）
  - 使用 SafeEditMacro() 改寫巨集內容為下一座騎
  - 若玩家中斷本次召喚，引導失敗 → 巨集仍已更新（排程不受影響）
  - 完成日期: v2.0.0

### 階段 5: 設定面板 UI
- [x] **[UI] T-014**: 實作 Settings API (11.0+) 設定面板架構
  - 建立主 Frame（panel）
  - 使用 Settings.RegisterCanvasLayoutCategory() 註冊分類
  - 使用 Settings.RegisterAddOnCategory() 加入插件列表
  - 建立標題文字（GameFontNormalLarge）
  - 完成日期: v1.0.0

- [x] **[UI] T-015**: 實作 RefreshTime 滑桿元件
  - 建立 Slider（OptionsSliderTemplate）
  - 設定範圍 5-30 秒
  - 實作 OnValueChanged 回調更新文字顯示
  - 即時儲存到 CYRandomMountDB.RefreshTime
  - 完成日期: v1.0.0

- [x] **[UI] T-016**: 實作巨集更新模式單選按鈕
  - 建立兩個 RadioButton（UIRadioButtonTemplate）
  - 選項 1: 即時更新（推薦）
  - 選項 2: 週期更新（遺留）
  - 實作互斥邏輯（點擊一個取消另一個）
  - 儲存到 CYRandomMountDB[角色key].UpdateMacroMode
  - 完成日期: v1.2.0

- [x] **[UI] T-016a**: 實作清單模式單選按鈕
  - 建立兩個 RadioButton（UIRadioButtonTemplate）
  - 選項 1: 角色獨立清單（預設）
  - 選項 2: 帳號共用清單
  - 實作互斥邏輯和切換時 UI 刷新
  - 儲存到 CYRandomMountDB[角色key].ListMode
  - OnClick 時重新載入對應清單的勾選狀態
  - **當切換至「角色獨立清單」時，若該角色的獨立列表為空，需將當前「帳號共用清單」的坐騎列表複製到該角色的獨立列表，並過濾不可用坐騎。**
  - 完成日期: v2.0.0

- [x] **[UI] T-017**: 實作 Reset Macro 按鈕
  - 建立 Button（UIPanelButtonTemplate）
  - OnClick 呼叫 CYRandomMount_InstantUpdate()
  - 顯示確認訊息「Macro has been reset.」
  - 完成日期: v1.2.3

- [x] **[UI] T-018**: 實作 CreateMountBox() 動態坐騎清單
  - 判斷坐騎數量決定是否使用 ScrollFrame（> 20 個）
  - 建立 ScrollFrame 和 ScrollChild（支援大量坐騎）
  - 動態生成 CheckButton（ChatConfigCheckButtonTemplate）
  - 顯示坐騎圖示（18x18 材質）
  - 顯示坐騎名稱（GameFontNormal，寬度 150）
  - 完成日期: v1.0.0

- [x] **[UI] T-019**: 實作飛行坐騎和地面坐騎兩個清單
  - 呼叫 CreateMountBox() 建立 flyingBox
  - 呼叫 CreateMountBox() 建立 groundBox
  - 設定兩個清單並排顯示（間隔 32 像素）
  - 完成日期: v1.0.0

- [x] **[UI] T-020**: 實作 UpdateMountListAndSettings() 刷新邏輯
  - 取得所有坐騎 ID（C_MountJournal.GetMountIDs()）
  - 過濾已收藏且未隱藏的坐騎
  - 依據 mountTypeID 分類為飛行/地面
  - 重建 flyingBox 和 groundBox
  - Hook 到 panel:OnShow 實現開啟時刷新
  - 完成日期: v1.0.0

### 階段 6: 資料持久化
- [x] **[DATA] T-021**: 實作 InitCYRandomMountDB() 初始化函式
  - 檢查 CYRandomMountDB 是否存在
  - 初始化 Default 設定檔（帳號共用）
  - 初始化當前角色的設定（以角色唯一識別碼為 key）
  - 若角色設定不存在，從 Default 複製並過濾當前角色無法使用的坐騎
  - **確保新角色初始化時，`ListMode` 預設為 `2` (使用帳號共用清單) 而非 `1`**
  - 處理舊版扁平格式轉換為 Default 設定檔
  - 處理 macroName 的遷移邏輯
  - 完成日期: v2.0.0

- [x] **[DATA] T-022**: 實作 SaveSelectedFlyingMounts() 儲存函式
  - 取得當前角色的 ListMode 設定
  - 根據 ListMode 決定儲存目標（角色專屬 key 或 Default）
  - 清空目標的 FlyingMounts 陣列
  - 遍歷 flyingBox.checks 複選框
  - 將勾選的坐騎 ID 插入陣列
  - OnClick 回調自動觸發儲存
  - 完成日期: v1.0.0

- [x] **[DATA] T-023**: 實作 SaveSelectedGroundMounts() 儲存函式
  - 與 T-022 邏輯相同，但針對 groundBox 和 GroundMounts
  - 完成日期: v1.0.0

- [x] **[DATA] T-024**: 實作 LoadSettings() 載入函式
  - 取得當前角色的設定
  - 從 CYRandomMountDB[角色key] 讀取 RefreshTime 並設定滑桿
  - 讀取 UpdateMacroMode 並設定單選按鈕
  - 讀取 ListMode 並設定清單模式單選按鈕
  - 根據 ListMode 決定讀取來源（角色專屬或 Default）
  - 讀取對應來源的 FlyingMounts/GroundMounts 並勾選對應複選框
  - 在設定面板建立後呼叫此函式
  - 完成日期: v1.0.0

- [x] **[DATA] T-025**: 實作舊版巨集名稱遷移邏輯
  - 檢查 CYRandomMountDB.macroName 是否與預設不同
  - 使用 GetMacroIndexByName() 查找舊巨集
  - 呼叫 DeleteMacro() 刪除舊巨集
  - 更新 macroName 為預設值 "CYRandomMount"
  - 使用 pcall 處理刪除錯誤
  - 完成日期: v1.1.0

### 階段 7: 特殊區域與多語言
- [x] **[I18N] T-026**: 實作 Undermine 特殊區域支援
  - 檢測區域 ID 2346（地底城）
  - 取得客戶端語言（GetLocale()）
  - 根據語言選擇坐騎名稱（斷頸者 G-99 / G-99 Breakneck 等）
  - 生成使用坐騎名稱的巨集內容（而非 ID）
  - 完成日期: v1.2.0

- [x] **[I18N] T-027**: 實作多語言坐騎名稱映射表
  - 支援語言：zhTW, zhCN, enUS, enGB, frFR, koKR, deDE, esES, esMX, ptBR, ruRU
  - 為每個語言提供正確的「斷頸者 G-99」翻譯
  - 預設使用繁體中文作為 fallback
  - 完成日期: v1.2.0

- [x] **[CORE] T-028**: 實作 SanitizeMacroName() 清理函式
  - 移除雙引號、單引號、反斜線
  - 將換行符號替換為空格
  - 防止巨集名稱注入攻擊
  - 完成日期: v1.0.0

### 階段 8: 錯誤處理與除錯
- [x] **[CORE] T-029**: 實作 ShowDebug 除錯開關
  - 定義全域變數 ShowDebug = false
  - 在關鍵操作加入條件式 print 訊息
  - 記錄區域 ID、飛行狀態、坐騎選擇等資訊
  - 完成日期: 初始版本

- [x] **[CORE] T-030**: 實作所有 API 呼叫的錯誤處理
  - EditMacro 使用 SafeEditMacro() 包裝
  - DeleteMacro 使用 pcall 包裝
  - CreateMacro 檢查回傳值是否為 0（失敗）
  - 設定 macroName 時使用 pcall
  - 完成日期: v1.1.0

- [x] **[CORE] T-031**: 實作巨集編輯暫停機制
  - 在 UpdateMountMacroByZone() 開頭檢查 MacroFrame:IsShown()
  - 若巨集視窗開啟則提前 return，不更新巨集
  - 避免干擾玩家手動編輯
  - 完成日期: v1.0.0

### 階段 9: Slash 指令與介面整合
- [x] **[UI] T-032**: 實作 /cyrandommount 指令
  - 註冊 SLASH_CYRandomMount1
  - 實作 SlashCmdList["CYRandomMount"] 回調
  - 呼叫 Settings.OpenToCategory() 開啟設定面板
  - 使用 C_Timer.After(0.1, ...) 確保延遲執行
  - 完成日期: v1.0.0

- [x] **[UI] T-033**: 實作 InterfaceOptions API 向下相容
  - 檢查 Settings API 是否存在
  - 若不存在則使用 InterfaceOptions_AddCategory()
  - 確保舊版本 WoW 客戶端也能使用
  - 完成日期: v1.0.0

### 階段 10: 效能優化與測試
- [x] **[PERF] T-034**: 優化 OnUpdate 計時器效能
  - 在函式開頭檢查 UpdateMacroMode 並盡早 return
  - 檢查 RefreshTime 合法性（type == "number" 且 > 0）
  - 避免不必要的運算和 API 呼叫
  - 完成日期: v1.0.0

- [x] **[PERF] T-035**: 實作 UI 元件快取
  - 將 flyingBox 和 groundBox 儲存為模組層級變數
  - 透過閉包函式暴露給主程式（CYRandomMountOptions.flyingBox()）
  - 避免重複建立 UI 元件
  - 完成日期: v1.0.0

- [x] **[TEST] T-036**: 測試不同區域類型的坐騎選擇
  - 測試飛行區域（如暴風城外）→ 使用飛行坐騎
  - 測試地面專屬區域（如副本入口）→ 使用地面坐騎
  - 測試特殊區域（Undermine 2346）→ 使用專屬坐騎
  - 測試室內區域 → 不更新巨集
  - 完成日期: v1.2.0

- [x] **[TEST] T-037**: 測試資料持久化
  - 設定偏好坐騎並登出
  - 重新登入檢查設定是否保留
  - 測試刷新時間和更新模式是否保留
  - 完成日期: v1.0.0

- [x] **[TEST] T-038**: 測試多語言客戶端
  - 測試繁體中文客戶端的 Undermine 坐騎名稱
  - 測試英文客戶端的坐騎名稱
  - 測試簡體中文客戶端
  - 完成日期: v1.2.0

- [x] **[TEST] T-039**: 測試大量坐騎的設定面板效能
  - 測試 100+ 坐騎的清單生成速度
  - 測試 ScrollFrame 捲動流暢度
  - 測試勾選/取消勾選的回應速度
  - 完成日期: v1.0.0

- [x] **[TEST] T-040**: 測試巨集更新模式（調整包含新即時更新行為）
  - 即時更新模式：未騎乘按下 → 召喚坐騎 + 巨集內容改寫為下一座騎
  - 即時更新模式：已騎乘按下 → 下馬 + 巨集內容不變（不切換座騎）
  - 即時更新模式：召喚引導被玩家中斷 → 巨集內容仍更新
  - 週期更新模式：維持原有每 N 秒改寫邏輯，巨集內容不需排程下一座騎
  - 模式切換：從週期→即時後，巨集尾段需出現 CYRandomMount_InstantUpdate 呼叫
  - 完成日期: v2.0.0

- [x] **[TEST] T-040a**: 測試清單模式切換
  - 測試從角色獨立清單切換到共用清單，UI 顯示正確更新
  - 測試從共用清單切換回獨立清單，UI 顯示正確更新
  - 測試切換時勾選狀態立即刷新
  - 優先級: 高
  - 完成日期: v2.0.0

- [x] **[TEST] T-040b**: 測試多角色清單狀態獨立性
  - 測試角色 A 使用獨立清單、角色 B 使用共用清單，互不影響
  - 測試多個角色同時使用共用清單，修改後所有角色同步
  - 測試切換角色後清單模式設定正確保留
  - 優先級: 高
  - 完成日期: v2.0.0

### 階段 11: 文件與發布準備
- [x] **[DOC] T-041**: 撰寫 README.md
  - 功能介紹（自動坐騎選擇、設定面板、更新模式）
  - 安裝說明
  - 使用指南（/cyrandommount 指令）
  - 完成日期: v1.0.0

- [x] **[DOC] T-042**: 撰寫 ReleaseNotes.md
  - 記錄每個版本的變更內容
  - 記錄新增功能、錯誤修復、優化
  - 完成日期: 每個版本發布時

- [x] **[DOC] T-043**: 建立 prepare_for_curseforge.ps1 發布腳本
  - 打包插件檔案（排除開發檔案）
  - 生成版本號命名的 ZIP 檔案
  - 完成日期: v1.0.0

- [x] **[DOC] T-044**: 建立 pkgmeta.yaml CurseForge 設定
  - 定義需要包含的檔案
  - 定義需要排除的檔案（如 .git, .vscode）
  - 完成日期: v1.0.0

## 技術債務與未來改進

### 待優化項目
- [ ] **[DEBT] T-045**: 重構硬編碼區域 ID
  - 將 2346（Undermine）移至設定檔
  - 支援未來新增更多特殊區域
  - 優先級: 中

- [ ] **[DEBT] T-046**: 獨立多語言坐騎名稱表
  - 將 if-elseif 語言判斷改為查表方式
  - 建立獨立的 Localization.lua 檔案
  - 優先級: 低

- [ ] **[DEBT] T-047**: 實作巨集損壞自動恢復
  - 偵測巨集內容異常（如被其他插件修改）
  - 提供一鍵重建功能
  - 優先級: 低

- [ ] **[DEBT] T-048**: 新增坐騎類型的自動偵測測試
  - 定期檢查 WoW 新增的 mountTypeID
  - 自動提示開發者更新分類邏輯
  - 優先級: 中

### 功能擴充建議
- [ ] **[FEAT] T-049**: 支援坐騎收藏夾過濾
  - 只顯示標記為「最愛」的坐騎
  - 減少清單長度提升效能
  - 優先級: 中

- [ ] **[FEAT] T-050**: 支援坐騎權重系統
  - 允許玩家設定某些坐騎出現機率較高
  - 實作加權隨機選擇演算法
  - 優先級: 低

- [ ] **[FEAT] T-051**: 支援按區域儲存坐騎偏好
  - 不同區域可設定不同的坐騎選擇池
  - 例如：暴風城用 A 組坐騎，奧格瑪用 B 組
  - 優先級: 低

- [ ] **[FEAT] T-052**: 支援坐騎換膚功能整合
  - 與 MountDynamizer 等換膚插件整合
  - 隨機選擇坐騎外觀
  - 優先級: 極低

- [ ] **[FEAT] T-053**: 支援角色間複製清單設定
  - 允許將某個角色的清單設定複製到另一個角色
  - 提供 UI 選擇來源角色和目標角色
  - 自動過濾目標角色無法使用的坐騎
  - 優先級: 中

## 版本歷程

### v1.0.0 (初始發布)
- 完成任務: T-001 ~ T-024, T-028 ~ T-035
- 核心功能：自動坐騎選擇、設定面板、週期更新

### v1.1.0
- 完成任務: T-005, T-025, T-030
- 改進：錯誤處理、舊巨集遷移

### v1.2.0
- 完成任務: T-007, T-013, T-026, T-027, T-036, T-038, T-040
- 新增功能：即時更新模式、Undermine 特殊區域支援

### v1.2.3
- 完成任務: T-017
- 新增功能：Reset Macro 按鈕

### v1.2.5 (當前版本)
- 完成任務: T-041 ~ T-044
- 改進：文件完善、發布流程建立

### v2.0.0 (已完成)
- 完成任務: T-003, T-007, T-008, T-009, T-013, T-016a, T-021, T-022, T-023, T-024, T-040, T-040a, T-040b
- 新增功能：清單模式切換（角色獨立/帳號共用）
- 資料結構更新：支援每個角色獨立設定和 Default 共用設定檔
- 巨集更新機制改進：僅在召喚時排程下一個坐騎，支援中斷召喚後仍更新，下馬時不切換座騎
- 新角色預設使用帳號共用清單(ListMode=2)
- UI 優化：移除重疊列表問題、調整列表高度、移除標題節省空間

## 任務統計

- **總任務數**: 56
- **已完成**: 48
- **計劃中**: 0
- **技術債務**: 4
- **功能擴充建議**: 5
- **完成率**: 85.7%

## 相依性圖

```
T-001 (TOC 檔案) ──┬──→ T-002 (事件初始化)
                   └──→ T-003 (資料結構)
                   
T-002 ──→ T-021 (初始化 DB) ──→ T-025 (巨集遷移)

T-004 (建立巨集) ──→ T-005 (錯誤處理) ──→ T-006 (更新巨集)
                                         ↓
T-008 (隨機飛行) ──┬──────────────────────┘
T-009 (隨機地面) ──┘

T-014 (設定面板) ──→ T-015 ~ T-020 (UI 元件)
                  ↓
T-020 (刷新清單) ──→ T-010 (坐騎分類)

T-022 (儲存飛行) ──┬──→ T-024 (載入設定)
T-023 (儲存地面) ──┘

T-011 (區域事件) ──→ T-006 (更新巨集)
T-012 (計時器) ────→ T-006 (更新巨集)
T-013 (即時更新) ──→ T-006 (更新巨集)

T-026 (特殊區域) ──→ T-027 (多語言)
```
