-- WoW 11.0+ Settings API implementation
local panel
local refreshTimeSlider
local refreshTimeText
local flyingBox
local groundBox
local RefreshTime = 10

-- State flags
local isAddonLoaded = false
local isPlayerLoggedIn = false
local optionsLoaded = false

local function TryLoadOptions()
    if isAddonLoaded and isPlayerLoggedIn and not optionsLoaded then
        if CYRandomMountOptions and CYRandomMountOptions.CreateOptionsPanel then
            CYRandomMountOptions.CreateOptionsPanel()
            optionsLoaded = true
        end
    end
end

local eventFrame = CreateFrame("Frame")
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

-- Auto create CYRandomMount macro
local macroName = "CYRandomMount"
local macroIcon = "INV_Misc_QuestionMark"
local macroBody = "#showtooltip Renewed Proto-Drake\n/cast Renewed Proto-Drake"

-- Ensure MAX_ACCOUNT_MACROS has a value (do not add local)
MAX_ACCOUNT_MACROS = MAX_ACCOUNT_MACROS or 120

local function CreateMountMacro()
    -- Check if macro already exists
    for i = 1, GetNumMacros(false) do
        local name = GetMacroInfo(i)
        if name == macroName then
            return -- Already exists, do not create again
        end
    end
    -- Create new macro
    if GetNumMacros(false) < MAX_ACCOUNT_MACROS then
        -- Only run CYRandomMount_InstantUpdate() when mounted
        local macroBodyStr = "#showtooltip\n/run CYRandomMount_InstantUpdate()\n/cast CYRandomMount"
        CreateMacro(macroName, macroIcon, macroBodyStr, false)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event)
    CreateMountMacro()
end)

-- Sanitize macro name
local function SanitizeMacroName(name)
    if not name then return "" end
    name = name:gsub('"', ''):gsub("'", ""):gsub("\\", ""):gsub("\n", " ")
    return name
end

local function GetRandomSelectedFlyingMount()
    local selected = {}
    if not CYRandomMountOptions or not CYRandomMountOptions.flyingBox then return nil end
    flyingBox = CYRandomMountOptions.flyingBox()
    if flyingBox and flyingBox.checks then
        for _, check in ipairs(flyingBox.checks) do
            if check:GetChecked() then
                table.insert(selected, check.mountID)
            end
        end
    end
    if #selected > 0 then
        return selected[math.random(#selected)]
    end
    return nil
end

local function GetRandomSelectedGroundMount()
    local selected = {}
    if not CYRandomMountOptions or not CYRandomMountOptions.groundBox then return nil end
    groundBox = CYRandomMountOptions.groundBox()
    if groundBox and groundBox.checks then
        for _, check in ipairs(groundBox.checks) do
            if check:GetChecked() then
                table.insert(selected, check.mountID)
            end
        end
    end
    if #selected > 0 then
        return selected[math.random(#selected)]
    end
    return nil
end

local function SafeEditMacro(...)
    local ok = pcall(EditMacro, ...)
    if not ok then
        print("CYRandomMount: EditMacro failed. Please check if the macro exists or if the content is too long.")
    end
end

local function UpdateMountMacroByZone()
    -- print("CYRandomMount: Updating mount macro by zone...")
    -- Pause auto-update if player is editing macro
    if MacroFrame and MacroFrame:IsShown() then
        return
    end

    -- Check if area is flyable
    local isFlyable = IsFlyableArea and IsFlyableArea() or false
    print("CYRandomMount: isFlyable = ", isFlyable)
    local macroIndex = nil
    for i = 1, GetNumMacros(false) do
        local name = GetMacroInfo(i)
        if name == macroName then
            macroIndex = i
            break
        end
    end
    if macroIndex then
        -- Only run CYRandomMount_InstantUpdate() when mounted
        local macroPrefix = "#showtooltip\n/run if IsMounted() then CYRandomMount_InstantUpdate() end\n"
        local macroBodyStr = nil
        if isFlyable == false then
            local mountID = GetRandomSelectedGroundMount()
            if mountID and C_MountJournal and C_MountJournal.GetMountInfoByID then
                local name, _, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(mountID)
                if isUsable == true then
                    name = SanitizeMacroName(name)
                    macroBodyStr = macroPrefix.."/dismount [mounted]\n/cast [nomounted] "..name
                    SafeEditMacro(macroIndex, macroName, icon or macroIcon, macroBodyStr, false)
                    return
                end
            end
            -- Fallback: 沒有可用地面坐騎
            macroBodyStr = macroPrefix.."-- No available ground mount\n/script print('CYRandomMount: No available ground mount!')"
            SafeEditMacro(macroIndex, macroName, macroIcon, macroBodyStr, false)
            return
        else
            local mountID = GetRandomSelectedFlyingMount()
            if mountID and C_MountJournal and C_MountJournal.GetMountInfoByID then
                local name, _, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(mountID)
                name = SanitizeMacroName(name)
                macroBodyStr = macroPrefix.."/dismount [mounted]\n/cast [nomounted] "..name
                SafeEditMacro(macroIndex, macroName, icon or macroIcon, macroBodyStr, false)
                return
            end     
            -- Fallback: 沒有可用飛行坐騎
            macroBodyStr = macroPrefix.."-- No available flying mount\n/script print('CYRandomMount: No available flying mount!')"
            SafeEditMacro(macroIndex, macroName, macroIcon, macroBodyStr, false)
            return                  
        end

    end
end

-- Add: instant macro update function
function CYRandomMount_InstantUpdate()
    if CYRandomMountOptions and CYRandomMountOptions.UpdateMacroMode and CYRandomMountOptions.UpdateMacroMode() == 1 then
        UpdateMountMacroByZone()
    end
end

-- Update macro after zone change (after loading new zone)
local zoneUpdateFrame = CreateFrame("Frame")
zoneUpdateFrame:RegisterEvent("ZONE_CHANGED")
zoneUpdateFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
zoneUpdateFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
zoneUpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
zoneUpdateFrame:SetScript("OnEvent", function()
    C_Timer.After(1, function()
        UpdateMountMacroByZone()
    end)
end)

local timer = CreateFrame("Frame")
timer.elapsed = 0
timer:SetScript("OnUpdate", function(self, elapsed)
    local db = _G.CYRandomMountDB
    local updateMode = (CYRandomMountOptions and CYRandomMountOptions.UpdateMacroMode and CYRandomMountOptions.UpdateMacroMode()) or 1
    RefreshTime = (db and db.RefreshTime) or 10
    -- Fix: Ensure RefreshTime is a valid number and only enable timer update when UpdateMacroMode is 2
    if type(RefreshTime) ~= "number" or RefreshTime <= 0 then return end
    if updateMode ~= 2 then return end
    self.elapsed = self.elapsed + elapsed
    if isAddonLoaded and self.elapsed >= RefreshTime then
        UpdateMountMacroByZone()
        self.elapsed = 0
    end
end)


