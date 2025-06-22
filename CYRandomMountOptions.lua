-- CYRandomMount 設定面板

local panel, refreshTimeSlider, refreshTimeText, flyingBox, groundBox
local RefreshTime = 10

-- 讓主程式可以取得這些變數
CYRandomMountOptions = {}
CYRandomMountOptions.panel = function() return panel end
CYRandomMountOptions.flyingBox = function() return flyingBox end
CYRandomMountOptions.groundBox = function() return groundBox end
CYRandomMountOptions.refreshTimeSlider = function() return refreshTimeSlider end
CYRandomMountOptions.refreshTimeText = function() return refreshTimeText end
CYRandomMountOptions.RefreshTime = function() return RefreshTime end
CYRandomMountOptions.SetRefreshTime = function(v) RefreshTime = v end

local function InitCYRandomMountDB()
    if not CYRandomMountDB then
        CYRandomMountDB = {}
    end
end

local function SaveSelectedMounts()
    CYRandomMountDB.FlyingMounts = {}
    CYRandomMountDB.GroundMounts = {}
    if flyingBox and flyingBox.checks then
        for _, check in ipairs(flyingBox.checks) do
            if check:GetChecked() then
                table.insert(CYRandomMountDB.FlyingMounts, check.mountID)
            end
        end
    end
    if groundBox and groundBox.checks then
        for _, check in ipairs(groundBox.checks) do
            if check:GetChecked() then
                table.insert(CYRandomMountDB.GroundMounts, check.mountID)
            end
        end
    end
end

local function LoadSettings()
    if not refreshTimeSlider or not flyingBox or not groundBox then return end
    if CYRandomMountDB.RefreshTime then
        RefreshTime = CYRandomMountDB.RefreshTime
        refreshTimeSlider:SetValue(RefreshTime)
        refreshTimeText:SetText(tostring(RefreshTime))
    end
    if CYRandomMountDB.FlyingMounts and flyingBox and flyingBox.checks then
        local selected = {}
        for _, id in ipairs(CYRandomMountDB.FlyingMounts) do selected[id] = true end
        for _, check in ipairs(flyingBox.checks) do
            check:SetChecked(selected[check.mountID] or false)
        end
    end
    if CYRandomMountDB.GroundMounts and groundBox and groundBox.checks then
        local selected = {}
        for _, id in ipairs(CYRandomMountDB.GroundMounts) do selected[id] = true end
        for _, check in ipairs(groundBox.checks) do
            check:SetChecked(selected[check.mountID] or false)
        end
    end
end

function CYRandomMountOptions.CreateOptionsPanel()
    InitCYRandomMountDB()
    if Settings and Settings.RegisterCanvasLayoutCategory then
        panel = CreateFrame("Frame", nil, nil)
        panel.name = "CYRandomMount"
        local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 16, -16)
        title:SetText("CYRandomMount Settings")
        
        local refreshTimeTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        refreshTimeTitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
        refreshTimeTitle:SetText("Refresh Time:")

        refreshTimeSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
        refreshTimeSlider:SetOrientation("HORIZONTAL")
        refreshTimeSlider:SetMinMaxValues(5, 30)
        refreshTimeSlider:SetValueStep(1)
        refreshTimeSlider:SetValue(RefreshTime)
        refreshTimeSlider:SetWidth(200)
        refreshTimeSlider:SetPoint("LEFT", refreshTimeTitle, "RIGHT", 8, 0)
        refreshTimeSlider:SetObeyStepOnDrag(true)
        refreshTimeText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        refreshTimeText:SetPoint("LEFT", refreshTimeSlider, "RIGHT", 12, 0)
        refreshTimeText:SetText(tostring(RefreshTime))
        refreshTimeSlider:HookScript("OnValueChanged", function(self, value)
            value = math.floor(value + 0.5)
            RefreshTime = value
            refreshTimeText:SetText(tostring(value))
            CYRandomMountDB.RefreshTime = value
        end)

        local availableMounts = {}
        local mountIDs = C_MountJournal.GetMountIDs()
        for i = 1, #mountIDs do
            local mountID = mountIDs[i]
            local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountID)
            if isCollected and isFavorite and name and icon and (not hideOnChar) and isUsable then
                table.insert(availableMounts, {mountID = mountID, name = name, icon = icon})
            end
        end

        local flyingMounts, groundMounts = {}, {}
        for _, mount in ipairs(availableMounts) do
            local mountTypeID = select(5, C_MountJournal.GetMountInfoExtraByID(mount.mountID))
            if mountTypeID == 424 or mountTypeID == 241 or mountTypeID == 402 or mountTypeID == 269 then
                table.insert(flyingMounts, mount)
            else
                table.insert(groundMounts, mount)
            end
        end

        flyingBox = CreateFrame("Frame", nil, panel)
        flyingBox:SetPoint("TOPLEFT", refreshTimeTitle, "BOTTOMLEFT", 0, -36)
        flyingBox:SetSize(220, math.max(32, #flyingMounts * 24))
        flyingBox.bg = flyingBox:CreateTexture(nil, "BACKGROUND")
        flyingBox.bg:SetAllPoints()
        flyingBox.bg:SetColorTexture(0,0,0,0.2)
        local flyingTitle = flyingBox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        flyingTitle:SetPoint("TOPLEFT", 4, -4)
        flyingTitle:SetText("Flying Mounts")
        flyingBox.checks = {}
        for i, mount in ipairs(flyingMounts) do
            local check = CreateFrame("CheckButton", nil, flyingBox, "ChatConfigCheckButtonTemplate")
            check:SetPoint("TOPLEFT", 8, -((i-1)*24)-24)
            check.mountID = mount.mountID
            flyingBox.checks[#flyingBox.checks+1] = check
            check.icon = flyingBox:CreateTexture(nil, "ARTWORK")
            check.icon:SetSize(18,18)
            check.icon:SetPoint("LEFT", check, "RIGHT", 4, 0)
            check.icon:SetTexture(mount.icon)
            check.textLabel = flyingBox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            check.textLabel:SetPoint("LEFT", check.icon, "RIGHT", 4, 0)
            check.textLabel:SetText(mount.name)
            check.textLabel:SetJustifyH("LEFT")
            check.textLabel:SetWidth(150)
            check.textLabel:SetHeight(18)
            check:SetScript("OnClick", SaveSelectedMounts)
        end

        groundBox = CreateFrame("Frame", nil, panel)
        groundBox:SetPoint("TOPLEFT", flyingBox, "TOPRIGHT", 32, 0)
        groundBox:SetSize(220, math.max(32, #groundMounts * 24))
        groundBox.bg = groundBox:CreateTexture(nil, "BACKGROUND")
        groundBox.bg:SetAllPoints()
        groundBox.bg:SetColorTexture(0,0,0,0.2)
        local groundTitle = groundBox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        groundTitle:SetPoint("TOPLEFT", 4, -4)
        groundTitle:SetText("Ground Mounts")
        groundBox.checks = {}
        for i, mount in ipairs(groundMounts) do
            local check = CreateFrame("CheckButton", nil, groundBox, "ChatConfigCheckButtonTemplate")
            check:SetPoint("TOPLEFT", 8, -((i-1)*24)-24)
            check.mountID = mount.mountID
            groundBox.checks[#groundBox.checks+1] = check
            check.icon = groundBox:CreateTexture(nil, "ARTWORK")
            check.icon:SetSize(18,18)
            check.icon:SetPoint("LEFT", check, "RIGHT", 4, 0)
            check.icon:SetTexture(mount.icon)
            check.textLabel = groundBox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            check.textLabel:SetPoint("LEFT", check.icon, "RIGHT", 4, 0)
            check.textLabel:SetText(mount.name)
            check.textLabel:SetJustifyH("LEFT")
            check.textLabel:SetWidth(150)
            check.textLabel:SetHeight(18)
            check:SetScript("OnClick", SaveSelectedMounts)
        end

        local category = Settings.RegisterCanvasLayoutCategory(panel, "CYRandomMount")
        Settings.RegisterAddOnCategory(category)

        SLASH_CYRandomMount1 = "/cyrandommount"
        SlashCmdList["CYRandomMount"] = function()
            Settings.OpenToCategory("CYRandomMount")
        end

        LoadSettings()
        panel:HookScript("OnShow", LoadSettings)
        panel:HookScript("OnHide", SaveSelectedMounts)
    else
        panel = CreateFrame("Frame", "cyrandommountOptionsPanel", UIParent)
        panel.name = "CYRandomMount"
        local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 16, -16)
        title:SetText("Settings")
        InterfaceOptions_AddCategory(panel)
        SLASH_CYRandomMount1 = "/cyrandommount"
        SlashCmdList["CYRandomMount"] = function()
            InterfaceOptionsFrame_OpenToCategory(panel)
            LoadSettings()
        end
    end
end