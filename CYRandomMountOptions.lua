-- CYRandomMount Options Panel

local panel, refreshTimeSlider, refreshTimeText, flyingBox, groundBox
local RefreshTime = 10
local UpdateMacroMode = 1 -- 1: Update each time call dismount, 2: Update periodly

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

local function InitCYRandomMountDB()
    if not CYRandomMountDB then
        CYRandomMountDB = {}
    end
    if not CYRandomMountDB.FlyingMounts then
        CYRandomMountDB.FlyingMounts = {}
    end
    if not CYRandomMountDB.GroundMounts then
        CYRandomMountDB.GroundMounts = {}
    end
    -- print("CYRandomMountDB:", #CYRandomMountDB.FlyingMounts, #CYRandomMountDB.GroundMounts, CYRandomMountDB.RefreshTime)
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
    CYRandomMountDB.UpdateMacroMode = UpdateMacroMode
end

local function LoadSettings()
    if not refreshTimeSlider or not flyingBox or not groundBox then return end
    if CYRandomMountDB.RefreshTime then
        RefreshTime = CYRandomMountDB.RefreshTime
        refreshTimeSlider:SetValue(RefreshTime)
        refreshTimeText:SetText(tostring(RefreshTime))
    end
    if CYRandomMountDB.UpdateMacroMode then
        UpdateMacroMode = CYRandomMountDB.UpdateMacroMode
        if updateMacroRadio1 then updateMacroRadio1:SetChecked(UpdateMacroMode == 1) end
        if updateMacroRadio2 then updateMacroRadio2:SetChecked(UpdateMacroMode == 2) end
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
        refreshTimeTitle:SetText("Refresh Time (sec):")

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

        -- Add macro update timing option
        local updateMacroTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        updateMacroTitle:SetPoint("TOPLEFT", refreshTimeTitle, "BOTTOMLEFT", 0, -32)
        updateMacroTitle:SetText("Macro update timing:")

        updateMacroRadio1 = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
        updateMacroRadio1:SetPoint("TOPLEFT", updateMacroTitle, "BOTTOMLEFT", 0, -4)
        updateMacroRadio1.text = updateMacroRadio1:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        updateMacroRadio1.text:SetPoint("LEFT", updateMacroRadio1, "RIGHT", 4, 0)
        updateMacroRadio1.text:SetText("Update macro immediately when random mount is called")
        updateMacroRadio1:SetScript("OnClick", function()
            updateMacroRadio1:SetChecked(true)
            updateMacroRadio2:SetChecked(false)
            UpdateMacroMode = 1
            SaveSelectedMounts()
        end)

        updateMacroRadio2 = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
        updateMacroRadio2:SetPoint("TOPLEFT", updateMacroRadio1, "BOTTOMLEFT", 0, -4)
        updateMacroRadio2.text = updateMacroRadio2:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        updateMacroRadio2.text:SetPoint("LEFT", updateMacroRadio2, "RIGHT", 4, 0)
        updateMacroRadio2.text:SetText("Only update macro every RefreshTime seconds")
        updateMacroRadio2:SetScript("OnClick", function()
            updateMacroRadio1:SetChecked(false)
            updateMacroRadio2:SetChecked(true)
            UpdateMacroMode = 2
            SaveSelectedMounts()
        end)

        -- Decide if ScrollFrame is needed
        local function CreateMountBox(mounts, parent, label)
            local box, scrollFrame, scrollChild, title
            box = CreateFrame("Frame", nil, parent)
            box:SetSize(220, (#mounts > 20) and 360 or math.max(32, #mounts * 24))
            title = box:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            title:SetPoint("TOPLEFT", 4, -4)
            title:SetText(label)
            if #mounts > 20 then
                scrollFrame = CreateFrame("ScrollFrame", nil, box, "UIPanelScrollFrameTemplate")
                scrollFrame:SetPoint("TOPLEFT", box, "TOPLEFT", 0, -24)
                scrollFrame:SetSize(220, 336)
                scrollChild = CreateFrame("Frame", nil, scrollFrame)
                scrollChild:SetSize(200, #mounts * 24 + 8)
                scrollFrame:SetScrollChild(scrollChild)
            end
            box.bg = box:CreateTexture(nil, "BACKGROUND")
            box.bg:SetAllPoints()
            box.bg:SetColorTexture(0,0,0,0.2)
            box.checks = {}
            for i, mount in ipairs(mounts) do
                local parentFrame = scrollChild or box
                local yOffset = (#mounts > 20) and -((i-1)*24) or -((i-1)*24)-24
                local check = CreateFrame("CheckButton", nil, parentFrame, "ChatConfigCheckButtonTemplate")
                check:SetPoint("TOPLEFT", 8, yOffset)
                check.mountID = mount.mountID
                box.checks[#box.checks+1] = check
                check.icon = parentFrame:CreateTexture(nil, "ARTWORK")
                check.icon:SetSize(18,18)
                check.icon:SetPoint("LEFT", check, "RIGHT", 4, 0)
                check.icon:SetTexture(mount.icon)
                check.textLabel = parentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
                check.textLabel:SetPoint("LEFT", check.icon, "RIGHT", 4, 0)
                check.textLabel:SetText(mount.name)
                check.textLabel:SetJustifyH("LEFT")
                check.textLabel:SetWidth(150)
                check.textLabel:SetHeight(18)
                check:SetScript("OnClick", SaveSelectedMounts)
            end
            return box
        end

        local function UpdateMountListAndSettings()
            -- Refresh available mounts
            local availableMounts = {}
            local mountIDs = C_MountJournal.GetMountIDs()
            for i = 1, #mountIDs do
                local mountID = mountIDs[i]
                local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                if isCollected and name and icon and (not hideOnChar) and isUsable then
                    table.insert(availableMounts, {mountID = mountID, name = name, icon = icon})
                end
            end
            local flyingMounts, groundMounts = {}, {}
            for _, mount in ipairs(availableMounts) do
                local mountTypeID = select(5, C_MountJournal.GetMountInfoExtraByID(mount.mountID))
                if mountTypeID == 402 or mountTypeID == 269 then
                    table.insert(flyingMounts, mount)
                elseif mountTypeID == 241 or mountTypeID == 424  then
                    table.insert(flyingMounts, mount)
                else
                    table.insert(groundMounts, mount)
                end
            end
            -- Add flying mounts that are not in ground mounts
            for _, mount in ipairs(flyingMounts) do
                local found = false
                for _, gmount in ipairs(groundMounts) do
                    if gmount.mountID == mount.mountID then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(groundMounts, mount)
                end
            end
            -- Rebuild option buttons
            if flyingBox then flyingBox:Hide() end
            if groundBox then groundBox:Hide() end
            flyingBox = CreateMountBox(flyingMounts, panel, "Mounts for Flying area")
            flyingBox:SetPoint("TOPLEFT", updateMacroRadio2, "BOTTOMLEFT", 0, -24)
            groundBox = CreateMountBox(groundMounts, panel, "Mounts for Ground only area")
            groundBox:SetPoint("TOPLEFT", flyingBox, "TOPRIGHT", 32, 0)
            LoadSettings()
        end


        local category = Settings.RegisterCanvasLayoutCategory(panel, "CYRandomMount")
        Settings.RegisterAddOnCategory(category)

        SLASH_CYRandomMount1 = "/cyrandommount"
        SlashCmdList["CYRandomMount"] = function()
            Settings.OpenToCategory("CYRandomMount")
        end

        UpdateMountListAndSettings()
        LoadSettings()

        panel:HookScript("OnShow", UpdateMountListAndSettings)
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
