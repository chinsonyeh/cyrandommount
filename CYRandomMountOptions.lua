-- CYRandomMount Options Panel

local panel, refreshTimeSlider, refreshTimeText, flyingBox, groundBox
local RefreshTime = 10
local UpdateMacroMode = 1 -- 1: Update each time call dismount, 2: Update periodly
local ListMode = 1 -- 1: Character specific list, 2: Use shared list
local ShowDebug = false -- Set to true to enable debug messages

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
                availableMountsCount = oldData.availableMountsCount or 0
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
    end
    if currentProfile.GroundMounts and groundBox and groundBox.checks then
        local selected = {}
        for _, id in ipairs(currentProfile.GroundMounts) do selected[id] = true end
        for _, check in ipairs(groundBox.checks) do
            check:SetChecked(selected[check.mountID] or false)
        end
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
        
        -- Create a label for "Reset Macro:"
        local resetMacroLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        resetMacroLabel:SetPoint("TOPLEFT", 16, -16)
        resetMacroLabel:SetText("Reset Macro:")

        -- Create a "Press" button to the right of the label
        local resetMacroButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        resetMacroButton:SetSize(60, 22)
        resetMacroButton:SetPoint("LEFT", resetMacroLabel, "RIGHT", 8, 0)
        resetMacroButton:SetText("Press")
        resetMacroButton:SetScript("OnClick", function()
            CYRandomMount_InstantUpdate()
            print("CYRandomMount: Macro has been reset.")
        end)

        local refreshTimeTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        refreshTimeTitle:SetPoint("TOPLEFT", resetMacroLabel, "BOTTOMLEFT", 0, -16)
        refreshTimeTitle:SetText("Refresh Time (sec):")

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
        updateMacroTitle:SetPoint("TOPLEFT", refreshTimeTitle, "BOTTOMLEFT", 0, -32)
        updateMacroTitle:SetText("Macro update timing:")

        updateMacroRadio1 = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
        updateMacroRadio1:SetPoint("TOPLEFT", updateMacroTitle, "BOTTOMLEFT", 0, -4)
        updateMacroRadio1.text = updateMacroRadio1:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        updateMacroRadio1.text:SetPoint("LEFT", updateMacroRadio1, "RIGHT", 4, 0)
        updateMacroRadio1.text:SetText("Update macro immediately (Recommended)")
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
        updateMacroRadio2.text:SetText("Update macro every RefreshTime seconds (Legacy)")
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
        listModeTitle:SetPoint("TOPLEFT", updateMacroRadio2, "BOTTOMLEFT", 0, -16)
        listModeTitle:SetText("Mount List Mode:")

        listModeRadio1 = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
        listModeRadio1:SetPoint("TOPLEFT", listModeTitle, "BOTTOMLEFT", 0, -4)
        listModeRadio1.text = listModeRadio1:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        listModeRadio1.text:SetPoint("LEFT", listModeRadio1, "RIGHT", 4, 0)
        listModeRadio1.text:SetText("Character Specific List")
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
                        local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
                        if isUsable then
                            table.insert(charProfile.FlyingMounts, mountID)
                        end
                    end
                    -- Filter and copy ground mounts
                    charProfile.GroundMounts = {}
                    for _, mountID in ipairs(defaultProfile.GroundMounts or {}) do
                        local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
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
        listModeRadio2.text:SetText("Account Wide List (Default Profile)")
        listModeRadio2:SetScript("OnClick", function()
            listModeRadio1:SetChecked(false)
            ListMode = 2
            local charKey = GetCharacterKey()
            CYRandomMountDB[charKey].ListMode = ListMode
            LoadSettings() -- Reload to show correct lists
        end)

        panel.listModeRadio1 = listModeRadio1
        panel.listModeRadio2 = listModeRadio2

        local function CreateMountBox(mounts, parent, label)
            local box, scrollFrame, scrollChild, title
            box = CreateFrame("Frame", nil, parent)
            local boxHeight = (#mounts > 15) and 360 or math.max(56, #mounts * 24 + 24)
            box:SetSize(280, boxHeight)
            title = box:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            title:SetPoint("TOPLEFT", 4, -4)
            title:SetText(label)

            if #mounts > 14 then
                scrollFrame = CreateFrame("ScrollFrame", nil, box, "UIPanelScrollFrameTemplate")
                scrollFrame:SetPoint("TOPLEFT", box, "TOPLEFT", 0, -24)
                scrollFrame:SetSize(280, 336)
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
                    if label:find("Flying") then
                        SaveSelectedFlyingMounts()
                    else
                        SaveSelectedGroundMounts()
                    end
                end)
            end
            return box
        end

        local function UpdateMountListAndSettings()
            InitCYRandomMountDB()
            
            local availableMounts = {}
            local mountIDs = C_MountJournal.GetMountIDs()
            if #mountIDs == 0 then return end
            
            CYRandomMountDB.Default.availableMountsCount = #mountIDs
            for _, mountID in ipairs(mountIDs) do
                local name, _, icon, _, isUsable, _, _, _, _, hideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountID)
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
            flyingBox = CreateMountBox(flyingMounts, panel, "Mounts for Flying area")
            flyingBox:SetPoint("TOPLEFT", listModeRadio2, "BOTTOMLEFT", -20, -16)

            groundBox = CreateMountBox(groundMounts, panel, "Mounts for Ground only area")
            groundBox:SetPoint("TOPLEFT", flyingBox, "TOPRIGHT", 16, 0)
            
            LoadSettings()
        end

        local category = Settings.RegisterCanvasLayoutCategory(panel, "CYRandomMount")
        Settings.RegisterAddOnCategory(category)

        SLASH_CYRandomMount1 = "/cyrandommount"
        SlashCmdList["CYRandomMount"] = function()
            Settings.OpenToCategory(category:GetID())
        end

        panel:HookScript("OnShow", UpdateMountListAndSettings)

    else
        -- Fallback for older WoW versions
        panel = CreateFrame("Frame", "cyrandommountOptionsPanel", UIParent)
        panel.name = "CYRandomMount"
        InterfaceOptions_AddCategory(panel)
        -- ... fallback UI creation would go here ...
    end
end
