# 技術實作計劃：CYRandomMount 基礎功能

**功能分支**: `1-baseline`  
**建立日期**: 2025-11-23  
**狀態**: 已實作  

## 架構概覽


CYRandomMount 採用雙檔案架構，分離核心邏輯與設定介面，並以「每個角色獨立儲存坐騎清單」為設計基礎：

```
CYRandomMount/
├── CYRandomMount.lua         # 核心巨集管理與坐騎選擇邏輯
├── CYRandomMountOptions.lua  # 設定面板與 UI 元件
├── CYRandomMount.toc         # 插件元資料檔案
└── CYRandomMountDB           # SavedVariable（由 WoW 客戶端管理，每個角色一份設定）
```

### 職責分離

**CYRandomMount.lua** 負責：
- 巨集建立與更新邏輯
- 區域偵測與坐騎類型判斷
- 隨機坐騎選擇演算法
- 事件監聽與計時器管理
- 全域函式 `CYRandomMount_InstantUpdate()` 暴露

**CYRandomMountOptions.lua** 負責：
- 設定面板 UI 建構
- 坐騎清單顯示與複選框管理（每個角色獨立）
- 角色設定的讀取與儲存（依據角色唯一識別碼）
- Settings API / InterfaceOptions API 相容層
- 透過閉包函式暴露 UI 元件給主程式（`CYRandomMountOptions.flyingBox()` 等，皆為角色專屬）

## 技術元件

### 1. 插件初始化系統

**目的**: 確保插件在正確的時機初始化，避免 API 尚未就緒導致錯誤

**實作方式**:
```lua
-- 狀態標記
local isAddonLoaded = false
local isPlayerLoggedIn = false
local optionsLoaded = false

-- 雙重事件檢查
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "CYRandomMount" then
        isAddonLoaded = true
        TryLoadOptions()
    elseif event == "PLAYER_LOGIN" then
        isPlayerLoggedIn = true
        TryLoadOptions()
    end
end)
```

**關鍵決策**: 使用 `TryLoadOptions()` 確保兩個事件都觸發後才載入設定面板，避免 API 依賴問題

### 2. 巨集管理系統

**目的**: 自動建立、更新和管理 CYRandomMount 巨集

**核心函式**:
- `CreateMountMacro(force)`: 建立巨集（檢查重複、處理巨集限制）
- `UpdateMountMacroByZone()`: 根據區域更新巨集內容
- `SafeEditMacro(...)`: 使用 pcall 包裝 EditMacro API 避免錯誤

**巨集內容結構（更新後：支援即時更新模式，僅在召喚時切換座騎）**:
```lua
-- 每次按下巨集：
-- 1. 若已騎乘則下馬（不切換座騎）
-- 2. 若未騎乘則召喚當前巨集中 mountID 指向的坐騎
-- 3. 之後呼叫 CYRandomMount_InstantUpdate()，僅在未騎乘狀態時排程『下一個』坐騎並改寫巨集
--    即使召喚引導被中斷，下一個坐騎已經寫入巨集（符合使用者故事 4 驗收場景）

-- 建立或更新巨集時：
local macroBody = "#showtooltip\n" ..
    "/run if IsMounted() then Dismount() else C_MountJournal.SummonByID(" .. mountID .. ") end\n" ..
    "/run CYRandomMount_InstantUpdate()\n"
```

**即時更新模式邏輯調整**:
`CYRandomMount_InstantUpdate()` 每次巨集執行後都會被呼叫，但只在未騎乘狀態時更新座騎，職責：
1. 檢查是否為騎乘狀態，若已騎乘則不執行更新（避免下馬時切換座騎）。
2. 若未騎乘，依區域與可飛行狀態決定下一個坐騎類型（含特殊區域判斷）。
2. 取得下一個隨機可用坐騎 ID（與本次召喚可能不同）。
3. 使用 `SafeEditMacro()` 改寫巨集內容，使下次按下巨集時直接使用排程後的坐騎。
4. 若本次召喚被打斷（玩家移動/中斷引導），巨集仍已更新，不需補救。

**關鍵技術點（更新後）**:
- 在巨集尾段呼叫 `CYRandomMount_InstantUpdate()`，但僅在未騎乘時排程下一個坐騎。
- 下馬時不切換座騎，保持當前巨集內容不變。
- 使用 mountID 而非名稱，避免多語言問題；區域特殊坐騎仍於邏輯層轉名稱時處理。
- `#showtooltip` 反映巨集中儲存的「下一個」坐騎（與當前召喚可能不同）。
- 確保新驗收場景：「未騎乘→召喚→寫入下一個」與「騎乘→下馬→不更新」。

### 3. 區域與坐騎類型偵測

**目的**: 根據當前區域特性選擇正確類型的坐騎

**實作邏輯**:
```lua
-- 1. 檢查特殊區域（Undermine）
local zoneID = C_Map.GetBestMapForUnit("player")
if zoneID == 2346 then
    -- 使用專屬坐騎，根據語言選擇名稱
    local Locale = GetLocale()
    local mountName = (Locale == "zhTW") and "斷頸者G-99" or "G-99 Breakneck"
    -- ...
end

-- 2. 檢查是否在室內（不可召喚坐騎）
if IsIndoors() then return end

-- 3. 檢查是否可飛行
local isFlyable = IsFlyableArea()
```

**坐騎類型判斷**:
```lua
local mountTypeID = select(5, C_MountJournal.GetMountInfoExtraByID(mountID))
-- 402: 龍騎術飛行坐騎
-- 269: 一般飛行坐騎
-- 241: TBC 飛行坐騎
-- 424: 另一種飛行坐騎類型
-- 其他: 地面坐騎
```

### 4. 隨機坐騎選擇演算法（含下一座騎排程機制）

**目的**: 從「當前角色」選定的坐騎清單中隨機選擇一個可用坐騎

**實作函式**:
```lua
local function GetRandomSelectedFlyingMount()
    local key = UnitName("player").."-"..GetRealmName()
    local db = CYRandomMountDB[key] or {}
    local listMode = db.ListMode or 1
    
    -- 根據清單模式決定讀取來源
    local sourceKey = (listMode == 2) and "Default" or key
    local sourceDB = CYRandomMountDB[sourceKey] or {}
    
    local selected = {}
    for _, mountID in ipairs(sourceDB.FlyingMounts or {}) do
        local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
        if isUsable then
            table.insert(selected, mountID)
        end
    end
    
    if #selected > 0 then
        return selected[math.random(#selected)]
    end
    return nil
end
```

**關鍵決策（更新）**:
- 每次都檢查 `isUsable` 過濾不可用坐騎。
- 使用 `math.random()` 均勻分佈。
- 無可用坐騎回傳 nil 避免錯誤。
- 根據 `ListMode` 決定來源（角色 / Default）。
- 『下一座騎排程』與『本次召喚』分離：巨集執行時使用當前巨集中的 mountID；執行後僅在未騎乘時排程並寫入下次 mountID。

**下一座騎排程核心流程（示意）**:
```lua
function CYRandomMount_InstantUpdate()
    -- 只在未騎乘狀態時更新座騎（避免下馬時切換）
    if not IsMounted() then
        local nextMountID = DetermineNextMountID() -- 內部整合可飛行/特殊區域判斷
        if nextMountID then
            local body = "#showtooltip\n" ..
                "/run if IsMounted() then Dismount() else C_MountJournal.SummonByID(" .. nextMountID .. ") end\n" ..
                "/run CYRandomMount_InstantUpdate()\n"
            SafeEditMacro(macroIndex, "CYRandomMount", nil, body)
        end
    end
end
```

### 5. 事件驅動更新機制

**目的**: 在區域變更時自動更新巨集內容

**監聽事件**:
```lua
zoneUpdateFrame:RegisterEvent("ZONE_CHANGED")
zoneUpdateFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
zoneUpdateFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
zoneUpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
zoneUpdateFrame:SetScript("OnEvent", function()
    C_Timer.After(1, function()
        UpdateMountMacroByZone()
    end)
end)
```

**關鍵決策**: 延遲 1 秒執行更新，因為區域 API（如 IsFlyableArea）在事件觸發瞬間可能尚未就緒

### FR-013：計算與估算（區域變更後延遲 1 秒更新巨集）

**目標摘要**：在區域變更或進入世界時延遲 1 秒呼叫 `UpdateMountMacroByZone()`，確保環境 API（如 `IsFlyableArea()`）穩定可用，並避免在 Macro 編輯時進行改寫。

**估算（粗略）**:
- 開發與本地驗證：2.0 小時
- 單元/手動測試編寫與執行：1.0 小時
- 文件與任務更新：0.5 小時
- 總計（含 buffer）：約 3.5 小時

**複雜度評級**：中等（Medium）
- 理由：牽涉到事件時機處理、延遲調度、邊界條件判斷（MacroFrame、室內、不可召喚區域）與安全的 API 呼叫（pcall 包裝）。

**技術成本與變更範圍**：
- 目標檔案：`CYRandomMount.lua`（事件處理、`UpdateMountMacroByZone()`、`CYRandomMount_InstantUpdate()`）
- 預期新增/變更行數：30~120 行（依現有函式抽象化程度而異）
- 依賴：`C_Timer`、`C_Map.GetBestMapForUnit`、`IsFlyableArea`、`MacroFrame`、`EditMacro`（透過 `SafeEditMacro`）

**風險評估**：
- 低/中：若已使用 `SafeEditMacro` 和 `C_Timer.After`，主要風險為在快速頻繁的區域事件下可能造成重複編輯；建議以簡單去抖（debounce）或檢查 MacroFrame 顯示狀態來緩解。

**效能影響**：
- 幾乎可忽略：事件驅動且以 1 秒延遲執行，只有在區域變更時觸發；對 CPU 與記憶體影響微小。OnUpdate 計時器仍保留作為週期性更新模式的替代方案。

**驗收準則（對應 FR-013）**：
- 在區域變更或 `PLAYER_ENTERING_WORLD` 後約 1 秒，`UpdateMountMacroByZone()` 被呼叫。
- 若 `MacroFrame:IsShown()`，則不執行編輯。
- 在室內或不可召喚狀態應跳過更新。
- 在特殊區域（例如 zoneID == 2346）使用預期的專屬坐騎。
- 快速連續的區域事件不會造成過度重複的 `EditMacro` 呼叫（基礎去抖或判斷）。

**測試範例（手動）**：
1. 進入飛行區域 → 等待 1 秒 → 驗證巨集內容指向可用飛行坐騎。
2. 進入地面區域 → 等待 1 秒 → 驗證巨集內容指向地面坐騎。
3. 進入 Undermine（zoneID=2346）→ 等待 1 秒 → 驗證使用專屬坐騎名稱/ID。
4. 開啟 Macro 編輯介面後切換區域 → 驗證不會編輯巨集。
5. 快速切換多個分區 → 驗證系統只在合理頻率下執行編輯（無暴增的 EditMacro 呼叫）。

若要進一步降低風險，可在此計畫內加入額外的去抖實作（例如 0.5s window）或統計級別的記錄用於追蹤生產環境的事件頻率。

### 6. 週期更新計時器

**目的**: 在週期更新模式下定期更新巨集

**實作方式**:
```lua
local timer = CreateFrame("Frame")
timer.elapsed = 0
timer:SetScript("OnUpdate", function(self, elapsed)
    local updateMode = CYRandomMountOptions.UpdateMacroMode() or 1
    local RefreshTime = CYRandomMountDB.RefreshTime or 10
    
    -- 只在週期更新模式(2)下運作
    if updateMode ~= 2 then return end
    
    self.elapsed = self.elapsed + elapsed
    if isAddonLoaded and self.elapsed >= RefreshTime then
        UpdateMountMacroByZone()
        self.elapsed = 0
    end
end)
```

**效能考量**: OnUpdate 每幀都會觸發，因此必須盡早 return 避免不必要的運算

### 7. 設定面板系統

**目的**: 提供友善的圖形化介面讓玩家管理坐騎偏好

**架構設計**:
```lua
-- Settings API (WoW 11.0+) 架構
panel = CreateFrame("Frame")
local category = Settings.RegisterCanvasLayoutCategory(panel, "CYRandomMount")
Settings.RegisterAddOnCategory(category)

-- Slash 指令註冊
SLASH_CYRandomMount1 = "/cyrandommount"
SlashCmdList["CYRandomMount"] = function()
    Settings.OpenToCategory(category:GetID())
end
```

**UI 元件**:
- **RefreshTime Slider**: 5-30 秒範圍滑桿，控制週期更新間隔
- **Update Mode Radio Buttons**: 兩個單選按鈕選擇更新模式
- **List Mode Radio Buttons**: 兩個單選按鈕選擇清單模式
  - 選項 1: 使用角色獨立清單（預設）
  - 選項 2: 使用帳號共用清單（編輯 Default 設定檔）
- **Reset Macro Button**: 手動觸發巨集更新
- **Flying/Ground Mount CheckBoxes**: 捲軸面板顯示坐騎清單（支援 200+ 坐騎）
  - 根據清單模式選擇，編輯目標為角色專屬清單或 Default 共用清單

**動態清單生成**:
```lua
local function CreateMountBox(mounts, parent, label)
    -- 判斷是否需要捲軸（超過 20 個坐騎）
    if #mounts > 20 then
        scrollFrame = CreateFrame("ScrollFrame", nil, box, "UIPanelScrollFrameTemplate")
        scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetSize(200, #mounts * 24 + 8)
        scrollFrame:SetScrollChild(scrollChild)
    end
    
    -- 動態建立複選框
    for i, mount in ipairs(mounts) do
        local check = CreateFrame("CheckButton", nil, parentFrame, "ChatConfigCheckButtonTemplate")
        check.mountID = mount.mountID
        -- 顯示圖示和名稱
        check.icon:SetTexture(mount.icon)
        check.textLabel:SetText(mount.name)
        -- 儲存變更
        check:SetScript("OnClick", function()
            SaveSelectedFlyingMounts() -- or SaveSelectedGroundMounts()
        end)
    end
end
```

### 8. 資料持久化系統

**目的**: 儲存和載入每個角色的獨立設定

**SavedVariable 結構**:
```lua
CYRandomMountDB = {
    ["Default"] = {
        macroName = "CYRandomMount",
        RefreshTime = 10,
        UpdateMacroMode = 1,
        ListMode = 2,  -- 1: 角色獨立清單, 2: 使用共用清單
        FlyingMounts = {1589, 1234, 5678, ...},  -- mountID 陣列
        GroundMounts = {2345, 6789, ...},
        availableMountsCount = 150  -- 用於偵測坐騎收藏變化
    },
    ["角色唯一識別碼"] = {
        macroName = "CYRandomMount",
        RefreshTime = 10,
        UpdateMacroMode = 1,
        ListMode = 1,  -- 1: 角色獨立清單, 2: 使用共用清單
        FlyingMounts = {1589, 1234, 5678, ...},
        GroundMounts = {2345, 6789, ...},
        availableMountsCount = 150
    },
    ...
}
```

**角色唯一識別碼**:
- 格式為 `角色名稱-伺服器名稱`，如 `MyChar-TWServer`。
- 取得方式：`local key = UnitName("player").."-"..GetRealmName()`
- **Default**: 作為帳號共用的預設設定檔，所有角色首次登入時會從此複製並過濾

**儲存流程**:
```lua
local function SaveSelectedFlyingMounts()
    local key = UnitName("player").."-)..GetRealmName()"
    local db = CYRandomMountDB[key] or {}
    local listMode = db.ListMode or 1
    
    -- 根據清單模式決定儲存目標
    local targetKey = (listMode == 2) and "Default" or key
    CYRandomMountDB[targetKey] = CYRandomMountDB[targetKey] or {}
    CYRandomMountDB[targetKey].FlyingMounts = {}
    
    for _, check in ipairs(flyingBox.checks) do
        if check:GetChecked() then
            table.insert(CYRandomMountDB[targetKey].FlyingMounts, check.mountID)
        end
    end
end
```

**角色設定初始化與載入流程**:
```lua
local function InitAndLoadSettings()
    local key = UnitName("player").."-"..GetRealmName()
    
    -- 1. 若角色設定不存在，嘗試從 Default 複製或轉換舊版扁平格式
    if not CYRandomMountDB[key] then
        -- 1-1. 檢查是否有 Default 設定檔
        if CYRandomMountDB["Default"] then
            local src = CYRandomMountDB["Default"]
            local dst = {}
            for k, v in pairs(src) do
                if type(v) == "table" then
                    dst[k] = {table.unpack(v)}
                else
                    dst[k] = v
                end
            end
            -- 過濾清單中當前角色無法使用的坐騎
            local function filterUsable(mountList)
                local usable = {}
                for _, id in ipairs(mountList or {}) do
                    local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(id)
                    if isUsable then table.insert(usable, id) end
                end
                return usable
            }
            dst.FlyingMounts = filterUsable(dst.FlyingMounts)
            dst.GroundMounts = filterUsable(dst.GroundMounts)
            CYRandomMountDB[key] = dst
        else
            -- 1-2. 相容舊版扁平共用格式（頂層直接有 macroName、FlyingMounts 等）
            local hasLegacy = CYRandomMountDB["macroName"] or CYRandomMountDB["FlyingMounts"] or CYRandomMountDB["GroundMounts"]
            if hasLegacy then
                -- 將舊版扁平格式轉換為 Default 設定檔
                local defaultProfile = {}
                for _, field in ipairs({"macroName", "RefreshTime", "UpdateMacroMode", "FlyingMounts", "GroundMounts", "availableMountsCount"}) do
                    local v = CYRandomMountDB[field]
                    if type(v) == "table" then
                        defaultProfile[field] = {table.unpack(v)}
                    elseif v ~= nil then
                        defaultProfile[field] = v
                    end
                end
                CYRandomMountDB["Default"] = defaultProfile
                
                -- 複製給當前角色並過濾
                local dst = {}
                for k, v in pairs(defaultProfile) do
                    if type(v) == "table" then
                        dst[k] = {table.unpack(v)}
                    else
                        dst[k] = v
                    end
                }
                local function filterUsable(mountList)
                    local usable = {}
                    for _, id in ipairs(mountList or {}) do
                        local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(id)
                        if isUsable then table.insert(usable, id) end
                    end
                    return usable
                }
                dst.FlyingMounts = filterUsable(dst.FlyingMounts)
                dst.GroundMounts = filterUsable(dst.GroundMounts)
                CYRandomMountDB[key] = dst
                
                -- 清理舊格式，避免未來誤判
                for _, field in ipairs({"macroName", "RefreshTime", "UpdateMacroMode", "FlyingMounts", "GroundMounts", "availableMountsCount"}) do
                    CYRandomMountDB[field] = nil
                end
            end
        end
    }
    
    local db = CYRandomMountDB[key] or {}
    local listMode = db.ListMode or 1
    
    -- 載入滑桿設定
    refreshTimeSlider:SetValue(db.RefreshTime or 10)
    -- 載入單選按鈕狀態
    panel.updateMacroRadio1:SetChecked((db.UpdateMacroMode or 1) == 1)
    panel.listModeRadio1:SetChecked(listMode == 1)
    panel.listModeRadio2:SetChecked(listMode == 2)
    
    -- 根據清單模式決定載入來源
    local sourceKey = (listMode == 2) and "Default" or key
    local sourceDB = CYRandomMountDB[sourceKey] or {}
    
    -- 載入坐騎勾選狀態
    local selected = {}
    for _, id in ipairs(sourceDB.FlyingMounts or {}) do
        selected[id] = true
    end
    for _, check in ipairs(flyingBox.checks) do
        check:SetChecked(selected[check.mountID] or false)
    end
end
```
說明：
- 若角色設定不存在，優先從 CYRandomMountDB["Default"] 複製設定檔，並過濾當前角色無法使用的坐騎。
- 若 Default 不存在但偵測到舊版扁平格式（macroName、FlyingMounts 等在頂層），則先將舊格式轉換為 Default 設定檔，再複製給角色並過濾，最後清理舊格式。
- 每個角色都有 ListMode 設定（預設為 1：角色獨立清單），可在 UI 切換為 2（使用共用清單）。
- UI 根據 ListMode 動態載入/儲存對應的清單（角色專屬或 Default 共用）。
- 隨機坐騎選擇演算法也會根據 ListMode 讀取對應來源的坐騎清單。

### 待改進的資料初始化與切換邏輯 (待處理)

目前在資料初始化與清單模式切換的邏輯上，存在以下兩點與預期不符的行為：

1.  **新角色預設行為不符**：
    *   **預期**：當插件升級後，首次登入的未建立獨立設定檔的角色，應預設使用「帳號共用清單」（即 `ListMode = 2`），以繼承帳號級的坐騎選擇。
    *   **現狀**：程式碼 `InitCYRandomMountDB` 在為新角色建立設定檔時，會將其 `ListMode` 預設設定為 `1`（角色獨立清單），並且 `FlyingMounts` 和 `GroundMounts` 列表為空。這導致新角色登入後，即便帳號通用清單有設定，該角色仍會從一個空的獨立清單開始。

    **解決方案**：
    *   修改 `InitCYRandomMountDB` 中新角色設定檔的初始化邏輯，將 `CYRandomMountDB[charKey].ListMode` 預設值改為 `2`。

2.  **從共用清單切換到獨立清單時未複製內容**：
    *   **預期**：當角色從使用「帳號共用清單」(`ListMode = 2`) 切換到「角色獨立清單」(`ListMode = 1`) 時，若該角色的獨立清單尚為空，應將當前帳號共用清單的坐騎列表複製一份，作為其獨立清單的初始內容。這確保了使用者在切換模式時不會突然失去所有坐騎選擇。
    *   **現狀**：在 `CYRandomMountOptions.lua` 的 `listModeRadio1` (角色獨立清單選項) `OnClick` 處理函式中，僅將 `ListMode` 設定為 `1` 並呼叫 `LoadSettings()`。如果角色本身的獨立清單是空的，UI 將直接顯示一個空的清單，而不會從帳號共用清單複製。

    **解決方案**：
    *   修改 `listModeRadio1` 的 `OnClick` 處理函式。在將 `ListMode` 設定為 `1` 之前，檢查 `CYRandomMountDB[charKey].FlyingMounts` 和 `CYRandomMountDB[charKey].GroundMounts` 是否為空。若為空，則將 `CYRandomMountDB.Default` 中的坐騎列表複製到 `CYRandomMountDB[charKey]` 對應的列表中，並過濾掉不可用的坐騎。複製後，再呼叫 `LoadSettings()` 更新 UI。

### 9. 錯誤處理與除錯系統

**目的**: 提供穩健的錯誤處理和開發時的除錯資訊

**SafeEditMacro 包裝器**:
```lua
local function SafeEditMacro(...)
    local ok = pcall(EditMacro, ...)
    if not ok then
        print("CYRandomMount: EditMacro failed. Please check if the macro exists or if the content is too long.")
    end
end
```

**除錯訊息系統**:
```lua
local ShowDebug = false  -- 開發時設為 true

if ShowDebug then
    print("CYRandomMount: Current zone ID:", zoneID)
    print("CYRandomMount: isFlyable = ", isFlyable)
end
```

### 10. 多語言支援系統

**目的**: 在不同語言客戶端中正確處理坐騎名稱

**實作方式**:
```lua
local Locale = GetLocale()
local mountName = "G-99 Breakneck"  -- 預設英文

if Locale == "zhTW" then
    mountName = "斷頸者G-99"
elseif Locale == "zhCN" then
    mountName = "G-99疾飙飞车"
elseif Locale == "frFR" then
    mountName = "G-99 Ventraterre"
-- ... 其他語言
end
```

**關鍵決策**: 只在需要使用名稱的地方（Undermine 特殊區域）才進行語言判斷，其他地方都使用 mountID 避免多語言問題

## 資料流程圖

```
玩家登入
    ↓
PLAYER_LOGIN 事件觸發
    ↓
CreateMountMacro() ──→ 檢查巨集是否存在 ──→ 不存在則建立預設巨集
    ↓
TryLoadOptions() ──→ 載入設定面板 ──→ LoadSettings() 讀取 CYRandomMountDB
    ↓
玩家移動到新區域
    ↓
ZONE_CHANGED* 事件觸發 ──→ 延遲 1 秒 ──→ UpdateMountMacroByZone()
    ↓
偵測區域特性（特殊區域?室內?可飛行?）
    ↓
    ├─ 特殊區域(2346) ──→ 使用專屬坐騎名稱（根據語言）
    ├─ 室內 ──→ 跳過更新
    ├─ 可飛行 ──→ GetRandomSelectedFlyingMount()
    └─ 僅地面 ──→ GetRandomSelectedGroundMount()
    ↓
過濾可用坐騎（isUsable == true）
    ↓
math.random() 隨機選擇一個 mountID
    ↓
SafeEditMacro() 更新巨集內容
    ↓
玩家按下巨集
    ↓
    ├─ 已騎乘? ──→ 下馬
    └─ 未騎乘? ──→ C_MountJournal.SummonByID(mountID)
    ↓
CYRandomMount_InstantUpdate()（排程並寫入下一個隨機坐騎；即使召喚被中斷亦已更新）
```

## 效能考量

### 記憶體管理
- 設定面板只在開啟時建立元件，不使用時不佔用記憶體
- 坐騎清單使用輕量級的複選框，每個坐騎約 1KB 記憶體

### CPU 效能
- OnUpdate 計時器盡早 return，避免不必要的運算
- 隨機選擇演算法時間複雜度 O(n)，n 為選定坐騎數量（通常 < 50）
- 使用事件驅動而非輪詢，減少 CPU 負擔

### API 呼叫優化
- 快取 flyingBox 和 groundBox 參考，避免重複函式呼叫
- 只在區域變更時更新巨集，而非持續更新
- 使用延遲執行避免在 API 尚未就緒時呼叫

## 相依性管理

### 外部 API
- **WoW Settings API** (11.0+): 設定面板架構
- **InterfaceOptions API** (舊版): 向下相容
- **C_MountJournal API**: 取得坐騎資訊
- **C_Map API**: 取得區域 ID
- **C_Timer API**: 延遲執行

### 事件依賴
- 必須等待 ADDON_LOADED + PLAYER_LOGIN 雙重確認
- 區域變更後延遲 1 秒確保 API 就緒
- 設定面板開啟時刷新坐騎清單（OnShow hook）

## 已知限制與權衡

### 技術限制
1. **無法直接偵測可召喚坐騎區域**: 使用 IsIndoors() 作為替代，但某些戶外區域仍無法召喚坐騎
2. **巨集字元數限制 255**: 限制了可加入的額外邏輯
3. **週期更新精確度**: OnUpdate 依賴幀率，低幀率情況下可能有輕微延遲

### 設計權衡
1. **飛行坐騎加入地面清單**: 雖然增加清單長度，但確保地面區域也有足夠選擇
2. **延遲更新**: 犧牲即時性換取穩定性（避免 API 未就緒錯誤）
3. **巨集編輯暫停機制**: 犧牲自動更新換取不干擾玩家操作

## 測試策略

### 單元測試（手動）
- 測試各種區域類型（飛行、地面、室內、特殊區域）
- 測試不同語言客戶端的坐騎名稱
- 測試邊界條件（無坐騎、單一坐騎、大量坐騎）

### 整合測試
- 測試跨區域移動的巨集更新連續性
- 測試每個角色設定儲存與載入的完整性（切換角色、登出登入）
- 測試與其他插件的相容性（巨集衝突）

### 壓力測試
- 200+ 坐騎的設定面板效能
- 快速切換區域的更新穩定性
- 長時間運行的記憶體洩漏檢測

## 維護與演進

### 版本相容性
- 監控 WoW API 變更（每個大版本）
- 維護 Settings API 和 InterfaceOptions API 雙重支援
- 追蹤新增的坐騎類型（mountTypeID）

### 擴充性考量
- 模組化設計允許未來新增更多巨集更新模式
- 設定系統可輕易擴充新的玩家偏好選項
- 區域特殊規則可透過查表方式擴充

### 技術債務
- 考慮將硬編碼的區域 ID (2346) 改為設定檔驅動
- 考慮將多語言坐騎名稱表獨立成資料檔案
- 考慮實作更完善的錯誤恢復機制（如巨集損壞時自動重建）
