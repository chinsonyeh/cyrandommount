-- CYRandomMount Options Panel

-- Localization table
local L = {}
local selectedLocale = "auto"

local languages = {
    {code = "auto", name = "Auto (Game Language)"},
    {code = "zhTW", name = "繁體中文"},
    {code = "zhCN", name = "简体中文"},
    {code = "enUS", name = "English"},
    {code = "jaJP", name = "日本語"},
    {code = "koKR", name = "한국어"},
    {code = "frFR", name = "Français"},
    {code = "deDE", name = "Deutsch"},
    {code = "esES", name = "Español"},
    {code = "ptBR", name = "Português"},
    {code = "ruRU", name = "Русский"},
}

local function SetLocalization(loc)
    selectedLocale = loc
    local actualLoc = loc
    if loc == "auto" then
        actualLoc = GetLocale()
    end
    L = {}
    
    -- English (default)
    L["CYRANDOMMOUNT_TITLE"] = "CYRandomMount"
    L["RESET_MACRO_LABEL"] = "Reset Macro:"
    L["RESET_MACRO_BUTTON"] = "Press"
    L["REFRESH_TIME_TITLE"] = "Refresh Time (sec):"
    L["MACRO_UPDATE_TITLE"] = "Macro update timing:"
    L["UPDATE_IMMEDIATE"] = "Update macro immediately (Recommended)"
    L["UPDATE_PERIODIC"] = "Update macro every RefreshTime seconds (Legacy)"
    L["LIST_MODE_TITLE"] = "Mount List Mode:"
    L["CHARACTER_SPECIFIC"] = "Character Specific List"
    L["ACCOUNT_SHARED"] = "Account Shared List"
    L["FLYING_MOUNTS_TITLE"] = "Flying Mounts"
    L["GROUND_MOUNTS_TITLE"] = "Ground Mounts"
    L["LANGUAGE_TITLE"] = "Language:"
    L["DRAG_MACRO_TOOLTIP"] = "Drag this macro to your action bar."
    L["SELECT_ALL"] = "Select All"
    L["DESELECT_ALL"] = "Deselect All"
    L["SEARCH_MOUNT"] = "Search Mount..."
    
    -- Traditional Chinese
    if actualLoc == "zhTW" then
        L["CYRANDOMMOUNT_TITLE"] = "CYRandomMount"
        L["RESET_MACRO_LABEL"] = "重置巨集:"
        L["RESET_MACRO_BUTTON"] = "按下"
        L["REFRESH_TIME_TITLE"] = "刷新時間 (秒):"
        L["MACRO_UPDATE_TITLE"] = "巨集更新時機:"
        L["UPDATE_IMMEDIATE"] = "立即更新巨集 (推薦)"
        L["UPDATE_PERIODIC"] = "每隔 RefreshTime 秒更新巨集 (舊版)"
        L["LIST_MODE_TITLE"] = "坐騎清單模式:"
        L["CHARACTER_SPECIFIC"] = "角色獨立清單"
        L["ACCOUNT_SHARED"] = "帳號共用清單"
        L["FLYING_MOUNTS_TITLE"] = "飛行坐騎"
        L["GROUND_MOUNTS_TITLE"] = "地面坐騎"
        L["LANGUAGE_TITLE"] = "語言:"
        L["DRAG_MACRO_TOOLTIP"] = "將此巨集拖曳至快捷列。"
        L["SELECT_ALL"] = "全選"
        L["DESELECT_ALL"] = "全不選"
        L["SEARCH_MOUNT"] = "搜尋座騎..."
    -- Simplified Chinese
    elseif actualLoc == "zhCN" then
        L["CYRANDOMMOUNT_TITLE"] = "CYRandomMount"
        L["RESET_MACRO_LABEL"] = "重置宏:"
        L["RESET_MACRO_BUTTON"] = "按下"
        L["REFRESH_TIME_TITLE"] = "刷新时间 (秒):"
        L["MACRO_UPDATE_TITLE"] = "宏更新时机:"
        L["UPDATE_IMMEDIATE"] = "立即更新宏 (推荐)"
        L["UPDATE_PERIODIC"] = "每隔 RefreshTime 秒更新宏 (旧版)"
        L["LIST_MODE_TITLE"] = "坐骑列表模式:"
        L["CHARACTER_SPECIFIC"] = "角色独立列表"
        L["ACCOUNT_SHARED"] = "账号共享列表"
        L["FLYING_MOUNTS_TITLE"] = "飞行坐骑"
        L["GROUND_MOUNTS_TITLE"] = "地面坐骑"
        L["LANGUAGE_TITLE"] = "语言:"
        L["DRAG_MACRO_TOOLTIP"] = "将此宏拖动到动作条。"
        L["SELECT_ALL"] = "全选"
        L["DESELECT_ALL"] = "全不选"
        L["SEARCH_MOUNT"] = "搜索坐骑..."
    -- French
    elseif actualLoc == "frFR" then
        L["CYRANDOMMOUNT_TITLE"] = "CYRandomMount"
        L["RESET_MACRO_LABEL"] = "Réinitialiser la macro:"
        L["RESET_MACRO_BUTTON"] = "Appuyer"
        L["REFRESH_TIME_TITLE"] = "Temps de rafraîchissement (sec):"
        L["MACRO_UPDATE_TITLE"] = "Calendrier de mise à jour de la macro:"
        L["UPDATE_IMMEDIATE"] = "Mettre à jour la macro immédiatement (Recommandé)"
        L["UPDATE_PERIODIC"] = "Mettre à jour la macro toutes les RefreshTime secondes (Héritage)"
        L["LIST_MODE_TITLE"] = "Mode de liste de montures:"
        L["CHARACTER_SPECIFIC"] = "Liste spécifique au personnage"
        L["ACCOUNT_SHARED"] = "Liste partagée du compte"
        L["FLYING_MOUNTS_TITLE"] = "Montures volantes"
        L["GROUND_MOUNTS_TITLE"] = "Montures terrestres"
        L["LANGUAGE_TITLE"] = "Langue:"
        L["DRAG_MACRO_TOOLTIP"] = "Faites glisser cette macro sur votre barre d'action."
        L["SELECT_ALL"] = "Tout sélectionner"
        L["DESELECT_ALL"] = "Tout désélectionner"
        L["SEARCH_MOUNT"] = "Rechercher une monture..."
    -- German
    elseif actualLoc == "deDE" then
        L["CYRANDOMMOUNT_TITLE"] = "CYRandomMount"
        L["RESET_MACRO_LABEL"] = "Makro zurücksetzen:"
        L["RESET_MACRO_BUTTON"] = "Drücken"
        L["REFRESH_TIME_TITLE"] = "Aktualisierungszeit (Sek):"
        L["MACRO_UPDATE_TITLE"] = "Makro-Aktualisierungszeitpunkt:"
        L["UPDATE_IMMEDIATE"] = "Makro sofort aktualisieren (Empfohlen)"
        L["UPDATE_PERIODIC"] = "Makro alle RefreshTime Sekunden aktualisieren (Legacy)"
        L["LIST_MODE_TITLE"] = "Mount-Listenmodus:"
        L["CHARACTER_SPECIFIC"] = "Charakterspezifische Liste"
        L["ACCOUNT_SHARED"] = "Kontoübergreifende Liste"
        L["FLYING_MOUNTS_TITLE"] = "Fliegende Mounts"
        L["GROUND_MOUNTS_TITLE"] = "Boden-Mounts"
        L["LANGUAGE_TITLE"] = "Sprache:"
        L["DRAG_MACRO_TOOLTIP"] = "Zieh dieses Makro in deine Aktionsleiste."
        L["SELECT_ALL"] = "Alle auswählen"
        L["DESELECT_ALL"] = "Alle abwählen"
        L["SEARCH_MOUNT"] = "Reittier suchen..."
    -- Spanish
    elseif actualLoc == "esES" or actualLoc == "esMX" then
        L["CYRANDOMMOUNT_TITLE"] = "CYRandomMount"
        L["RESET_MACRO_LABEL"] = "Restablecer macro:"
        L["RESET_MACRO_BUTTON"] = "Presionar"
        L["REFRESH_TIME_TITLE"] = "Tiempo de actualización (seg):"
        L["MACRO_UPDATE_TITLE"] = "Programación de actualización de macro:"
        L["UPDATE_IMMEDIATE"] = "Actualizar macro inmediatamente (Recomendado)"
        L["UPDATE_PERIODIC"] = "Actualizar macro cada RefreshTime segundos (Legacy)"
        L["LIST_MODE_TITLE"] = "Modo de lista de monturas:"
        L["CHARACTER_SPECIFIC"] = "Lista específica del personaje"
        L["ACCOUNT_SHARED"] = "Lista compartida de la cuenta"
        L["FLYING_MOUNTS_TITLE"] = "Monturas voladoras"
        L["GROUND_MOUNTS_TITLE"] = "Monturas terrestres"
        L["LANGUAGE_TITLE"] = "Idioma:"
        L["DRAG_MACRO_TOOLTIP"] = "Arrastra este macro a tu barra de acción."
        L["SELECT_ALL"] = "Seleccionar todo"
        L["DESELECT_ALL"] = "Deseleccionar todo"
        L["SEARCH_MOUNT"] = "Buscar montura..."
    -- Portuguese
    elseif actualLoc == "ptBR" then
        L["CYRANDOMMOUNT_TITLE"] = "CYRandomMount"
        L["RESET_MACRO_LABEL"] = "Redefinir macro:"
        L["RESET_MACRO_BUTTON"] = "Pressionar"
        L["REFRESH_TIME_TITLE"] = "Tempo de atualização (seg):"
        L["MACRO_UPDATE_TITLE"] = "Cronograma de atualização da macro:"
        L["UPDATE_IMMEDIATE"] = "Atualizar macro imediatamente (Recomendado)"
        L["UPDATE_PERIODIC"] = "Atualizar macro a cada RefreshTime segundos (Legacy)"
        L["LIST_MODE_TITLE"] = "Modo de lista de montarias:"
        L["CHARACTER_SPECIFIC"] = "Lista específica do personagem"
        L["ACCOUNT_SHARED"] = "Lista compartilhada da conta"
        L["FLYING_MOUNTS_TITLE"] = "Montarias voadoras"
        L["GROUND_MOUNTS_TITLE"] = "Montarias terrestres"
        L["LANGUAGE_TITLE"] = "Idioma:"
        L["DRAG_MACRO_TOOLTIP"] = "Arraste este macro para a sua barra de ação."
        L["SELECT_ALL"] = "Selecionar tudo"
        L["DESELECT_ALL"] = "Desselecionar tudo"
        L["SEARCH_MOUNT"] = "Buscar montaria..."
    -- Russian
    elseif actualLoc == "ruRU" then
        L["CYRANDOMMOUNT_TITLE"] = "CYRandomMount"
        L["RESET_MACRO_LABEL"] = "Сбросить макрос:"
        L["RESET_MACRO_BUTTON"] = "Нажать"
        L["REFRESH_TIME_TITLE"] = "Время обновления (сек):"
        L["MACRO_UPDATE_TITLE"] = "Время обновления макроса:"
        L["UPDATE_IMMEDIATE"] = "Обновить макрос немедленно (Рекомендуется)"
        L["UPDATE_PERIODIC"] = "Обновлять макрос каждые RefreshTime секунд (Устаревшее)"
        L["LIST_MODE_TITLE"] = "Режим списка транспорта:"
        L["CHARACTER_SPECIFIC"] = "Список конкретного персонажа"
        L["ACCOUNT_SHARED"] = "Общий список аккаунта"
        L["FLYING_MOUNTS_TITLE"] = "Летающий транспорт"
        L["GROUND_MOUNTS_TITLE"] = "Наземный транспорт"
        L["LANGUAGE_TITLE"] = "Язык:"
        L["DRAG_MACRO_TOOLTIP"] = "Перетащите этот макрос на вашу панель действий."
        L["SELECT_ALL"] = "Выбрать все"
        L["DESELECT_ALL"] = "Снять все"
        L["SEARCH_MOUNT"] = "Поиск транспорта..."
    -- Korean
    elseif actualLoc == "koKR" then
        L["CYRANDOMMOUNT_TITLE"] = "CYRandomMount"
        L["RESET_MACRO_LABEL"] = "매크로 재설정:"
        L["RESET_MACRO_BUTTON"] = "누르기"
        L["REFRESH_TIME_TITLE"] = "새로고침 시간 (초):"
        L["MACRO_UPDATE_TITLE"] = "매크로 업데이트 시기:"
        L["UPDATE_IMMEDIATE"] = "매크로 즉시 업데이트 (권장)"
        L["UPDATE_PERIODIC"] = "RefreshTime초마다 매크로 업데이트 (레거시)"
        L["LIST_MODE_TITLE"] = "탈것 목록 모드:"
        L["CHARACTER_SPECIFIC"] = "캐릭터별 목록"
        L["ACCOUNT_SHARED"] = "계정 공유 목록"
        L["FLYING_MOUNTS_TITLE"] = "비행 탈것"
        L["GROUND_MOUNTS_TITLE"] = "지상 탈것"
        L["LANGUAGE_TITLE"] = "언어:"
        L["DRAG_MACRO_TOOLTIP"] = "이 매크로를 행동 단축바로 끌어다 놓으세요."
        L["SELECT_ALL"] = "모두 선택"
        L["DESELECT_ALL"] = "모두 선택 해제"
        L["SEARCH_MOUNT"] = "탈것 검색..."
    -- Japanese
    elseif actualLoc == "jaJP" then
        L["CYRANDOMMOUNT_TITLE"] = "CYRandomMount"
        L["RESET_MACRO_LABEL"] = "マクロをリセット:"
        L["RESET_MACRO_BUTTON"] = "押す"
        L["REFRESH_TIME_TITLE"] = "更新時間 (秒):"
        L["MACRO_UPDATE_TITLE"] = "マクロ更新タイミング:"
        L["UPDATE_IMMEDIATE"] = "マクロを即座に更新 (推奨)"
        L["UPDATE_PERIODIC"] = "RefreshTime秒ごとにマクロを更新 (レガシー)"
        L["LIST_MODE_TITLE"] = "マウントリストモード:"
        L["CHARACTER_SPECIFIC"] = "キャラクター固有リスト"
        L["ACCOUNT_SHARED"] = "アカウント共有リスト"
        L["FLYING_MOUNTS_TITLE"] = "飛行マウント"
        L["GROUND_MOUNTS_TITLE"] = "地上マウント"
        L["LANGUAGE_TITLE"] = "言語:"
        L["DRAG_MACRO_TOOLTIP"] = "このマクロをアクションバーにドラッグしてください。"
        L["SELECT_ALL"] = "すべて選択"
        L["DESELECT_ALL"] = "すべて選択解除"
        L["SEARCH_MOUNT"] = "マウントを検索..."
    end
end

-- Initialize localization
SetLocalization(selectedLocale)

-- Localization function
local function GetLocalizedText(key)
    return L[key] or key
end

local panel, refreshTimeSlider, refreshTimeText, flyingBox, groundBox
local RefreshTime = 10
local UpdateMacroMode = 1 -- 1: Update each time call dismount, 2: Update periodly
local ListMode = 1 -- 1: Character specific list, 2: Use shared list
local ShowDebug = false -- Set to true to enable debug messages
local macroName = "CYRandomMount"

-- Expose variables to main program
CYRandomMountOptions = {}
CYRandomMountOptions.panel = function() return panel end
CYRandomMountOptions.flyingBox = function() return flyingBox end
CYRandomMountOptions.groundBox = function() return groundBox end
CYRandomMountOptions.refreshTimeSlider = function() return refreshTimeSlider end
CYRandomMountOptions.refreshTimeText = function() return refreshTimeText end
CYRandomMountOptions.RefreshTime = function() return RefreshTime end
CYRandomMountOptions.SetRefreshTime = function(v) RefreshTime = v end
CYRandomMountOptions.UpdateMacroMode = function() return UpdateMacroMode end
CYRandomMountOptions.SetUpdateMacroMode = function(v) UpdateMacroMode = v end
CYRandomMountOptions.ListMode = function() return ListMode end
CYRandomMountOptions.SetListMode = function(v) ListMode = v end


local function GetCharacterKey()
    return UnitName("player") .. "-" .. GetRealmName()
end

-- Function to get the current profile based on ListMode
local function GetCurrentProfile()
    local charKey = GetCharacterKey()
    if not CYRandomMountDB[charKey] then
        -- If character profile doesn't exist, create it by copying from Default
        CYRandomMountDB[charKey] = {}
        for k, v in pairs(CYRandomMountDB.Default) do
            CYRandomMountDB[charKey][k] = v
        end
    end

    if CYRandomMountDB[charKey].ListMode == 2 then
        return CYRandomMountDB.Default
    else
        return CYRandomMountDB[charKey]
    end
end

local function InitCYRandomMountDB()
    -- Check for old structure and migrate
    if type(CYRandomMountDB) ~= "table" or not CYRandomMountDB.Default then
        local oldData = CYRandomMountDB or {}
        CYRandomMountDB = {
            Default = {
                macroName = oldData.macroName or "CYRandomMount",
                RefreshTime = oldData.RefreshTime or 10,
                UpdateMacroMode = oldData.UpdateMacroMode or 1,
                ListMode = 1, -- Default to character-specific
                FlyingMounts = oldData.FlyingMounts or {},
                GroundMounts = oldData.GroundMounts or {},
                availableMountsCount = oldData.availableMountsCount or 0,
                SelectedLocale = "auto"
            }
        }
    end

    local charKey = GetCharacterKey()
    if not CYRandomMountDB[charKey] then
        CYRandomMountDB[charKey] = {}
        -- Copy settings from Default, but keep lists empty for character-specific
        for k, v in pairs(CYRandomMountDB.Default) do
            if k == "FlyingMounts" or k == "GroundMounts" then
                CYRandomMountDB[charKey][k] = {}
            else
                CYRandomMountDB[charKey][k] = v
            end
        end
        -- New characters default to shared list (ListMode = 2)
        CYRandomMountDB[charKey].ListMode = 2
    end
end


local function SaveSelectedFlyingMounts()
    local profile = GetCurrentProfile()
    profile.FlyingMounts = {}
    if flyingBox and flyingBox.checks then
        for _, check in ipairs(flyingBox.checks) do
            if check:GetChecked() then
                table.insert(profile.FlyingMounts, check.mountID)
            end
        end
    end
    if ShowDebug then
        print("CYRandomMount: Saved " .. #profile.FlyingMounts .. " flying mounts")
    end
end

local function SaveSelectedGroundMounts()
    local profile = GetCurrentProfile()
    profile.GroundMounts = {}
    if groundBox and groundBox.checks then
        for _, check in ipairs(groundBox.checks) do
            if check:GetChecked() then
                table.insert(profile.GroundMounts, check.mountID)
            end
        end
    end
    if ShowDebug then
        print("CYRandomMount: Saved " .. #profile.GroundMounts .. " ground mounts")
    end
end

local function LoadSettings()
    if not refreshTimeSlider or not flyingBox or not groundBox then return end
    
    local charKey = GetCharacterKey()
    local charProfile = CYRandomMountDB[charKey]
    local currentProfile = GetCurrentProfile()
    
    -- Load global settings from character profile
    RefreshTime = charProfile.RefreshTime
    UpdateMacroMode = charProfile.UpdateMacroMode
    ListMode = charProfile.ListMode

    refreshTimeSlider:SetValue(RefreshTime)
    refreshTimeText:SetText(tostring(RefreshTime))

    if panel.updateMacroRadio1 then panel.updateMacroRadio1:SetChecked(UpdateMacroMode == 1) end
    if panel.updateMacroRadio2 then panel.updateMacroRadio2:SetChecked(UpdateMacroMode == 2) end

    if panel.listModeRadio1 then panel.listModeRadio1:SetChecked(ListMode == 1) end
    if panel.listModeRadio2 then panel.listModeRadio2:SetChecked(ListMode == 2) end

    -- Load mount lists from the active profile (character or default)
    if currentProfile.FlyingMounts and flyingBox and flyingBox.checks then
        local selected = {}
        for _, id in ipairs(currentProfile.FlyingMounts) do selected[id] = true end
        for _, check in ipairs(flyingBox.checks) do
            check:SetChecked(selected[check.mountID] or false)
        end
        if ShowDebug then
            print("CYRandomMount: Loaded " .. #currentProfile.FlyingMounts .. " flying mounts")
        end
    end
    if currentProfile.GroundMounts and groundBox and groundBox.checks then
        local selected = {}
        for _, id in ipairs(currentProfile.GroundMounts) do selected[id] = true end
        for _, check in ipairs(groundBox.checks) do
            check:SetChecked(selected[check.mountID] or false)
        end
        if ShowDebug then
            print("CYRandomMount: Loaded " .. #currentProfile.GroundMounts .. " ground mounts")
        end
    end
end

-- 假設 ns 是一個你的插件會用到的全域或命名空間表格
-- 如果沒有，你可以直接宣告 local ns = {}
local ns = ns or {}
ns.redesignedButtons = ns.redesignedButtons or {} -- 用來存放已改造的按鈕

---
-- 為指定的按鈕重新設計外觀，加上自訂外框和圖示。
-- @param button 要重新設計的按鈕物件 (例如 dragMacroButton)
--
local function RedesignMacroButton(button)
    -- We're redesigning the button itself, not creating an overlay
    if not button.customBorder then
        button:SetBackdrop({
            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
            edgeSize = 16,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        button:SetBackdropBorderColor(0.8, 0.8, 0.8, 1.0)

        -- We use a custom property to mark it as redesigned
        button.customBorder = true -- Just a flag now

        local icon = button:CreateTexture(nil, "OVERLAY")
        icon:SetSize(24, 24)
        icon:SetPoint("TOPRIGHT", 0, 0)
        icon:SetTexture("Interface\Icons\Ability_Hunter_MarkedForDeath")
        button.customIcon = icon

        ns.redesignedButtons[button] = true
    end

    -- 確保覆蓋層的層級總是比按鈕高
    if button.customIcon and button.customIcon:GetParent() then
        button.customIcon:GetParent():SetFrameLevel(button:GetFrameLevel() + 1)
    end
end

function CYRandomMountOptions.CreateOptionsPanel()
    InitCYRandomMountDB()
    local updateMacroRadio1, updateMacroRadio2, listModeRadio1, listModeRadio2
    
    if Settings and Settings.RegisterCanvasLayoutCategory then
        if ShowDebug then
            print("CYRandomMount: Creating options panel with Settings API...")
        end

        panel = CreateFrame("Frame", nil, nil)
        panel.name = "CYRandomMount"
        
        -- Create a container frame for the button and its border
        local buttonContainer = CreateFrame("Frame", nil, panel)
        buttonContainer:SetSize(54, 54)
        buttonContainer:SetPoint("TOPRIGHT", -16, -16)

        -- Create a draggable macro button
        local dragMacroButton = CreateFrame("Button", "CYRandomMountDragButton", buttonContainer, "BackdropTemplate")
        dragMacroButton:SetAllPoints(true)
        RedesignMacroButton(dragMacroButton)

        -- Icon Texture
        dragMacroButton.icon = dragMacroButton:CreateTexture(nil, "BACKGROUND")
        dragMacroButton.icon:SetPoint("TOPLEFT", 2, -2)
        dragMacroButton.icon:SetPoint("BOTTOMRIGHT", -2, 2)
        dragMacroButton.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        
        dragMacroButton:RegisterForDrag("LeftButton")

        local function UpdateDragButtonIcon()
            local _, icon = GetMacroInfo(macroName)
            if not icon or icon == "" then
                icon = "Interface\\Icons\\INV_Misc_QuestionMark"
            end
            dragMacroButton.icon:SetTexture(icon)
        end
        
        dragMacroButton:SetScript("OnDragStart", function()
            if InCombatLockdown() then return end
            PickupMacro(macroName)
        end)

        dragMacroButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(GetLocalizedText("DRAG_MACRO_TOOLTIP"), nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)

        dragMacroButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- Create a label for "Reset Macro:"
        local resetMacroLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        resetMacroLabel:SetPoint("TOPLEFT", 16, -40)
        resetMacroLabel:SetText(GetLocalizedText("RESET_MACRO_LABEL"))

        -- Create a "Press" button to the right of the label
        local resetMacroButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        resetMacroButton:SetSize(60, 22)
        resetMacroButton:SetPoint("LEFT", resetMacroLabel, "RIGHT", 8, 0)
        resetMacroButton:SetText(GetLocalizedText("RESET_MACRO_BUTTON"))
        resetMacroButton:SetScript("OnClick", function()
            CYRandomMount_InstantUpdate()
            print("CYRandomMount: Macro has been reset.")
        end)

        -- Add a reference to the button for the update function
        panel.dragMacroButton = dragMacroButton
        panel.UpdateDragButtonIcon = UpdateDragButtonIcon

        -- Add Language dropdown to the right of reset button (only when debug is enabled)
        local languageDropdown
        if ShowDebug then
            languageDropdown = CreateFrame("Frame", nil, panel, "UIDropDownMenuTemplate")
            languageDropdown:SetPoint("LEFT", resetMacroButton, "RIGHT", 16, 0)
            UIDropDownMenu_SetWidth(languageDropdown, 230)
        end

        local refreshTimeTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        refreshTimeTitle:SetPoint("TOPLEFT", resetMacroLabel, "BOTTOMLEFT", 0, -16)
        refreshTimeTitle:SetText(GetLocalizedText("REFRESH_TIME_TITLE"))

        refreshTimeSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
        refreshTimeSlider:SetOrientation("HORIZONTAL")
        refreshTimeSlider:SetMinMaxValues(5, 30)
        refreshTimeSlider:SetValueStep(1)
        refreshTimeSlider:SetWidth(180)
        refreshTimeSlider:SetPoint("LEFT", refreshTimeTitle, "RIGHT", 8, 0)
        refreshTimeSlider:SetObeyStepOnDrag(true)
        refreshTimeText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        refreshTimeText:SetPoint("LEFT", refreshTimeSlider, "RIGHT", 12, 0)
        
        refreshTimeSlider:HookScript("OnValueChanged", function(self, value)
            value = math.floor(value + 0.5)
            RefreshTime = value
            refreshTimeText:SetText(tostring(value))
            local charKey = GetCharacterKey()
            CYRandomMountDB[charKey].RefreshTime = value
        end)
        
        -- Add macro update timing option
        local updateMacroTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        updateMacroTitle:SetPoint("TOPLEFT", refreshTimeTitle, "BOTTOMLEFT", 0, -24)
        updateMacroTitle:SetText(GetLocalizedText("MACRO_UPDATE_TITLE"))

        updateMacroRadio1 = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
        updateMacroRadio1:SetPoint("TOPLEFT", updateMacroTitle, "BOTTOMLEFT", 0, -4)
        updateMacroRadio1.text = updateMacroRadio1:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        updateMacroRadio1.text:SetPoint("LEFT", updateMacroRadio1, "RIGHT", 4, 0)
        updateMacroRadio1.text:SetText(GetLocalizedText("UPDATE_IMMEDIATE"))
        updateMacroRadio1:SetScript("OnClick", function()
            updateMacroRadio2:SetChecked(false)
            UpdateMacroMode = 1
            local charKey = GetCharacterKey()
            CYRandomMountDB[charKey].UpdateMacroMode = UpdateMacroMode
        end)

        updateMacroRadio2 = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
        updateMacroRadio2:SetPoint("TOPLEFT", updateMacroRadio1, "BOTTOMLEFT", 0, -4)
        updateMacroRadio2.text = updateMacroRadio2:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        updateMacroRadio2.text:SetPoint("LEFT", updateMacroRadio2, "RIGHT", 4, 0)
        updateMacroRadio2.text:SetText(GetLocalizedText("UPDATE_PERIODIC"))
        updateMacroRadio2:SetScript("OnClick", function()
            updateMacroRadio1:SetChecked(false)
            UpdateMacroMode = 2
            local charKey = GetCharacterKey()
            CYRandomMountDB[charKey].UpdateMacroMode = UpdateMacroMode
        end)

        panel.updateMacroRadio1 = updateMacroRadio1
        panel.updateMacroRadio2 = updateMacroRadio2
        
        -- Add List Mode option
        local listModeTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        listModeTitle:SetPoint("TOPLEFT", updateMacroTitle, "BOTTOMLEFT", 0, -48)
        listModeTitle:SetText(GetLocalizedText("LIST_MODE_TITLE"))

        listModeRadio1 = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
        listModeRadio1:SetPoint("TOPLEFT", listModeTitle, "BOTTOMLEFT", 0, -4)
        listModeRadio1.text = listModeRadio1:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        listModeRadio1.text:SetPoint("LEFT", listModeRadio1, "RIGHT", 4, 0)
        listModeRadio1.text:SetText(GetLocalizedText("CHARACTER_SPECIFIC"))
        listModeRadio1:SetScript("OnClick", function()
            listModeRadio2:SetChecked(false)
            ListMode = 1
            local charKey = GetCharacterKey()
            CYRandomMountDB[charKey].ListMode = ListMode
            
            -- If switching to character-specific and the list is empty, copy from Default and filter
            local charProfile = CYRandomMountDB[charKey]
            if (not charProfile.FlyingMounts or #charProfile.FlyingMounts == 0) and 
               (not charProfile.GroundMounts or #charProfile.GroundMounts == 0) then
                local defaultProfile = CYRandomMountDB.Default
                if defaultProfile then
                    -- Filter and copy flying mounts
                    charProfile.FlyingMounts = {}
                    for _, mountID in ipairs(defaultProfile.FlyingMounts or {}) do
                        -- C_MountJournal.GetMountInfoByID returns: name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID, isForDragonriding
                        local name, spellID, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(mountID)
                        if isUsable then
                            table.insert(charProfile.FlyingMounts, mountID)
                        end
                    end
                    -- Filter and copy ground mounts
                    charProfile.GroundMounts = {}
                    for _, mountID in ipairs(defaultProfile.GroundMounts or {}) do
                        -- C_MountJournal.GetMountInfoByID returns: name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID, isForDragonriding
                        local name, spellID, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(mountID)
                        if isUsable then
                            table.insert(charProfile.GroundMounts, mountID)
                        end
                    end
                end
            end
            
            LoadSettings() -- Reload to show correct lists
        end)

        listModeRadio2 = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
        listModeRadio2:SetPoint("TOPLEFT", listModeRadio1, "BOTTOMLEFT", 0, -4)
        listModeRadio2.text = listModeRadio2:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        listModeRadio2.text:SetPoint("LEFT", listModeRadio2, "RIGHT", 4, 0)
        listModeRadio2.text:SetText(GetLocalizedText("ACCOUNT_SHARED"))
        listModeRadio2:SetScript("OnClick", function()
            listModeRadio1:SetChecked(false)
            ListMode = 2
            local charKey = GetCharacterKey()
            CYRandomMountDB[charKey].ListMode = ListMode
            LoadSettings() -- Reload to show correct lists
        end)

        panel.listModeRadio1 = listModeRadio1
        panel.listModeRadio2 = listModeRadio2

        local function UpdateTexts()
            if resetMacroLabel then resetMacroLabel:SetText(GetLocalizedText("RESET_MACRO_LABEL")) end
            if resetMacroButton then resetMacroButton:SetText(GetLocalizedText("RESET_MACRO_BUTTON")) end
            if refreshTimeTitle then refreshTimeTitle:SetText(GetLocalizedText("REFRESH_TIME_TITLE")) end
            if updateMacroTitle then updateMacroTitle:SetText(GetLocalizedText("MACRO_UPDATE_TITLE")) end
            if updateMacroRadio1 and updateMacroRadio1.text then updateMacroRadio1.text:SetText(GetLocalizedText("UPDATE_IMMEDIATE")) end
            if updateMacroRadio2 and updateMacroRadio2.text then updateMacroRadio2.text:SetText(GetLocalizedText("UPDATE_PERIODIC")) end
            if listModeTitle then listModeTitle:SetText(GetLocalizedText("LIST_MODE_TITLE")) end
            if listModeRadio1 and listModeRadio1.text then listModeRadio1.text:SetText(GetLocalizedText("CHARACTER_SPECIFIC")) end
            if listModeRadio2 and listModeRadio2.text then listModeRadio2.text:SetText(GetLocalizedText("ACCOUNT_SHARED")) end
            if flyingBox and flyingBox.title then flyingBox.title:SetText(GetLocalizedText("FLYING_MOUNTS_TITLE")) end
            if groundBox and groundBox.title then groundBox.title:SetText(GetLocalizedText("GROUND_MOUNTS_TITLE")) end
            if flyingBox and flyingBox.searchBox then flyingBox.searchBox:SetText("") end
            if groundBox and groundBox.searchBox then groundBox.searchBox:SetText("") end
        end
        
        -- Set initial value
        local charKey = GetCharacterKey()
        if CYRandomMountDB[charKey] and CYRandomMountDB[charKey].SelectedLocale then
            selectedLocale = CYRandomMountDB[charKey].SelectedLocale
            SetLocalization(selectedLocale)
        end
        
        if ShowDebug and languageDropdown then
            UIDropDownMenu_Initialize(languageDropdown, function(self, level, menuList)
                for _, lang in ipairs(languages) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = lang.name
                    info.value = lang.code
                    info.checked = (selectedLocale == lang.code)
                    info.func = function(self)
                        SetLocalization(self.value)
                        UpdateTexts()
                        UIDropDownMenu_SetSelectedValue(languageDropdown, self.value)
                        -- Save to settings
                        local charKey = GetCharacterKey()
                        CYRandomMountDB[charKey].SelectedLocale = self.value
                    end
                    UIDropDownMenu_AddButton(info)
                end
            end)
            
            UIDropDownMenu_SetSelectedValue(languageDropdown, selectedLocale)
            for _, lang in ipairs(languages) do
                if lang.code == selectedLocale then
                    UIDropDownMenu_SetText(languageDropdown, lang.name)
                    break
                end
            end
        end

        local function CreateMountBox(mounts, parent, label, isFlying)
            local box, scrollFrame, scrollChild, title
            box = CreateFrame("Frame", nil, parent)
            local boxHeight = (#mounts > 15) and 360 or math.max(56, #mounts * 24 + 24)
            box:SetSize(280, boxHeight)
            title = box:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            title:SetPoint("TOPLEFT", 4, -4)
            title:SetText(label)
            box.title = title

            -- Create "Select All" button
            local selectAllBtn = CreateFrame("Button", nil, box, "UIPanelButtonTemplate")
            selectAllBtn:SetSize(60, 20)
            selectAllBtn:SetPoint("TOPRIGHT", box, "TOPRIGHT", -70, -2)
            selectAllBtn:SetText(GetLocalizedText("SELECT_ALL"))
            selectAllBtn:SetScript("OnClick", function()
                if box.checks then
                    for _, check in ipairs(box.checks) do
                        if check:IsShown() then
                            check:SetChecked(true)
                        end
                    end
                    if isFlying then
                        SaveSelectedFlyingMounts()
                    else
                        SaveSelectedGroundMounts()
                    end
                end
            end)

            -- Create "Deselect All" button
            local deselectAllBtn = CreateFrame("Button", nil, box, "UIPanelButtonTemplate")
            deselectAllBtn:SetSize(60, 20)
            deselectAllBtn:SetPoint("RIGHT", selectAllBtn, "LEFT", -4, 0)
            deselectAllBtn:SetText(GetLocalizedText("DESELECT_ALL"))
            deselectAllBtn:SetScript("OnClick", function()
                if box.checks then
                    for _, check in ipairs(box.checks) do
                        if check:IsShown() then
                            check:SetChecked(false)
                        end
                    end
                    if isFlying then
                        SaveSelectedFlyingMounts()
                    else
                        SaveSelectedGroundMounts()
                    end
                end
            end)

            if #mounts > 14 then
                scrollFrame = CreateFrame("ScrollFrame", nil, box, "UIPanelScrollFrameTemplate")
                scrollFrame:SetPoint("TOPLEFT", box, "TOPLEFT", 0, -24)
                scrollFrame:SetSize(280, 310)
                scrollChild = CreateFrame("Frame", nil, scrollFrame)
                scrollChild:SetSize(260, #mounts * 24 + 8)
                scrollFrame:SetScrollChild(scrollChild)
            end

            box.bg = box:CreateTexture(nil, "BACKGROUND")
            box.bg:SetAllPoints()
            box.bg:SetColorTexture(0,0,0,0.2)

            if box.checks then
                for _, check in ipairs(box.checks) do
                    check:Hide()
                end
            end
            box.checks = box.checks or {}

            for i, mount in ipairs(mounts) do
                local parentFrame = scrollChild or box
                local yOffset = (#mounts > 14) and -((i-1)*24) or -((i-1)*24)-24
                
                local check = box.checks[i]
                if not check then
                    check = CreateFrame("CheckButton", nil, parentFrame, "ChatConfigCheckButtonTemplate")
                    check.icon = parentFrame:CreateTexture(nil, "ARTWORK")
                    check.textLabel = parentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
                    box.checks[i] = check
                end
                check:Show()
                check:SetPoint("TOPLEFT", 8, yOffset)
                check.mountID = mount.mountID
                
                check.icon:SetSize(18,18)
                check.icon:SetPoint("LEFT", check, "RIGHT", 4, 0)
                check.icon:SetTexture(mount.icon)
                
                check.textLabel:SetPoint("LEFT", check.icon, "RIGHT", 4, 0)
                check.textLabel:SetText(mount.name)
                check.textLabel:SetJustifyH("LEFT")
                check.textLabel:SetWidth(200)

                check:SetScript("OnClick", function()
                    if isFlying then
                        SaveSelectedFlyingMounts()
                    else
                        SaveSelectedGroundMounts()
                    end
                end)
            end

            -- Create search box below the mount list
            local searchBox = CreateFrame("EditBox", nil, box, "InputBoxTemplate")
            searchBox:SetSize(260, 20)
            if #mounts > 14 then
                searchBox:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 4, -8)
            else
                searchBox:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 4, 8)
            end
            searchBox:SetAutoFocus(false)
            searchBox:SetMaxLetters(50)
            searchBox:SetFontObject("ChatFontNormal")
            
            -- Add placeholder text
            local placeholderText = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
            placeholderText:SetPoint("LEFT", searchBox, "LEFT", 0, 0)
            placeholderText:SetText(GetLocalizedText("SEARCH_MOUNT"))
            searchBox.placeholderText = placeholderText
            
            -- Function to filter mounts based on search text
            local function FilterMounts(searchText)
                searchText = string.lower(searchText or "")
                for i, check in ipairs(box.checks) do
                    if searchText == "" then
                        check:Enable()
                        check.textLabel:SetTextColor(1, 1, 1)
                        check.icon:SetDesaturated(false)
                        check.icon:SetAlpha(1.0)
                    else
                        local mountName = string.lower(check.textLabel:GetText() or "")
                        if string.find(mountName, searchText, 1, true) then
                            check:Enable()
                            check.textLabel:SetTextColor(1, 1, 1)
                            check.icon:SetDesaturated(false)
                            check.icon:SetAlpha(1.0)
                        else
                            check:Disable()
                            check.textLabel:SetTextColor(0.5, 0.5, 0.5)
                            check.icon:SetDesaturated(true)
                            check.icon:SetAlpha(0.5)
                        end
                    end
                end
            end
            
            searchBox:SetScript("OnTextChanged", function(self)
                local text = self:GetText()
                if text == "" then
                    placeholderText:Show()
                else
                    placeholderText:Hide()
                end
                FilterMounts(text)
            end)
            
            searchBox:SetScript("OnEditFocusGained", function(self)
                placeholderText:Hide()
            end)
            
            searchBox:SetScript("OnEditFocusLost", function(self)
                if self:GetText() == "" then
                    placeholderText:Show()
                end
            end)
            
            searchBox:SetScript("OnEscapePressed", function(self)
                self:ClearFocus()
            end)
            
            box.searchBox = searchBox
            return box
        end

        local function UpdateMountListAndSettings()
            InitCYRandomMountDB()
            
            local availableMounts = {}
            local mountIDs = C_MountJournal.GetMountIDs()
            if #mountIDs == 0 then return end
            
            CYRandomMountDB.Default.availableMountsCount = #mountIDs
            for _, mountID in ipairs(mountIDs) do
                -- C_MountJournal.GetMountInfoByID returns: name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID, isForDragonriding
                local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                if isCollected and name and icon and not hideOnChar and isUsable then
                    table.insert(availableMounts, {mountID = mountID, name = name, icon = icon})
                end
            end
            
            local flyingMounts, groundMounts = {}, {}
            for _, mount in ipairs(availableMounts) do
                local mountTypeID = select(5, C_MountJournal.GetMountInfoExtraByID(mount.mountID))
                if mountTypeID == 402 or mountTypeID == 269 or mountTypeID == 241 or mountTypeID == 424 then
                    table.insert(flyingMounts, mount)
                else
                    table.insert(groundMounts, mount)
                end
            end
            
            for _, mount in ipairs(flyingMounts) do
                local found = false
                for _, gmount in ipairs(groundMounts) do
                    if gmount.mountID == mount.mountID then found = true break end
                end
                if not found then table.insert(groundMounts, mount) end
            end

            -- Remove old boxes if they exist
            if flyingBox then
                if flyingBox.checks then
                    for _, check in ipairs(flyingBox.checks) do
                        check:SetScript("OnClick", nil)
                        check:Hide()
                    end
                end
                flyingBox:Hide()
                flyingBox = nil
            end
            if groundBox then
                if groundBox.checks then
                    for _, check in ipairs(groundBox.checks) do
                        check:SetScript("OnClick", nil)
                        check:Hide()
                    end
                end
                groundBox:Hide()
                groundBox = nil
            end
            
            -- Create new boxes with current mount list
            flyingBox = CreateMountBox(flyingMounts, panel, GetLocalizedText("FLYING_MOUNTS_TITLE"), true)
            flyingBox:SetPoint("TOPLEFT", listModeRadio2, "BOTTOMLEFT", -20, -16)

            groundBox = CreateMountBox(groundMounts, panel, GetLocalizedText("GROUND_MOUNTS_TITLE"), false)
            groundBox:SetPoint("TOPLEFT", flyingBox, "TOPRIGHT", 16, 0)
            
            LoadSettings()
        end

        local category = Settings.RegisterCanvasLayoutCategory(panel, "CYRandomMount")
        Settings.RegisterAddOnCategory(category)

        SLASH_CYRandomMount1 = "/cyrandommount"
        SLASH_CYRandomMount2 = "/cyrm"
        SlashCmdList["CYRandomMount"] = function()
            Settings.OpenToCategory(category:GetID())
        end

        panel:HookScript("OnShow", function()
            UpdateMountListAndSettings()
            if panel.UpdateDragButtonIcon then
                panel.UpdateDragButtonIcon()
            end
        end)

    else
        -- Fallback for older WoW versions
        panel = CreateFrame("Frame", "cyrandommountOptionsPanel", UIParent)
        panel.name = "CYRandomMount"
        InterfaceOptions_AddCategory(panel)
        -- ... fallback UI creation would go here ...
    end
end
