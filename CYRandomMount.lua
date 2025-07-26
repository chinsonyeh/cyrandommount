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

local ShowDebug = false -- Set to true to enable debug messages

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
-- local macroBody = "#showtooltip Renewed Proto-Drake\n/cast Renewed Proto-Drake"

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
        local defaultMountID = 1589 -- Renewed Proto-Drake
        local macroPrefix = "#showtooltip\n/run if IsMounted() then CYRandomMount_InstantUpdate() end\n"
        local name, _, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(defaultMountID)
        if isUsable then
            if ShowDebug then
                print("CYRandomMount: Creating macro with default mount ID: " .. tostring(defaultMountID))
            end
            local macroBodyStr = macroPrefix.."/run if IsMounted() then Dismount() else C_MountJournal.SummonByID(1589) end\n')"
            CreateMacro(macroName, icon or macroIcon, macroBodyStr, false)
        else
            if ShowDebug then
                print("CYRandomMount: Default mount ID " .. tostring(defaultMountID) .. " is not usable.")
            end
            -- Fallback to a generic macro body
            local macroBodyStr = macroPrefix.."/dismount [mounted]\n/cast [nomounted] CYRandomMount"
            CreateMacro(macroName, icon or macroIcon, macroBodyStr, false)
        end
    end
end

if ShowDebug then
    print("CYRandomMount: Creating PLAYER_LOGIN event...")
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
                if C_MountJournal and C_MountJournal.GetMountInfoByID then
                    local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(check.mountID)
                    if isUsable then
                        table.insert(selected, check.mountID)
                    else
                        if ShowDebug then
                            print("CYRandomMount: Flying mount ID " .. tostring(check.mountID) .. " is not usable.")
                        end
                    end
                end
                -- print("CYRandomMount: Flying mount name = ", check.mountName, " ID = ", check.mountID)
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
                if C_MountJournal and C_MountJournal.GetMountInfoByID then
                    local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(check.mountID)
                    if isUsable then
                        table.insert(selected, check.mountID)
                    else
                        if ShowDebug then
                            print("CYRandomMount: Ground mount ID " .. tostring(check.mountID) .. " is not usable.")
                        end
                    end
                end
                -- print("CYRandomMount: ground mount name = ", check.mountName, " ID = ", check.mountID)
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

if ShowDebug then
    print("CYRandomMount: Creating UpdateMountMacroByZone function...")
end

local function UpdateMountMacroByZone()
    if ShowDebug then
        print("CYRandomMount: Updating mount macro by zone...")
    end
    -- Pause auto-update if player is editing macro
    if MacroFrame and MacroFrame:IsShown() then
        return
    end

    -- Get zone ID
    local zoneID = C_Map.GetBestMapForUnit("player")
    if ShowDebug then
        print("CYRandomMount: Current zone ID:", zoneID)
    end

    -- If zone ID is 2346 (Undermine), use specific mount
    if zoneID == 2346 then
        local Locale = GetLocale()
        local mountName = "G-99 Breakneck"
        -- Set mountName based on locale
        if Locale == "zhTW" then
            mountName = "斷頸者G-99" -- Traditional Chinese
        elseif Locale == "zhCN" then
            mountName = "G-99疾飙飞车" -- Simplified Chinese
        elseif Locale == "enUS" or Locale == "enGB" then
            mountName = "G-99 Breakneck" -- English (example)
        elseif Locale == "frFR" then
            mountName = "G-99 Ventraterre" -- French (example)
        elseif Locale == "koKR" then
            mountName = "G-99 광폭질주차" -- Korean (example)
        elseif Locale == "deDE" then
            mountName = "99-G-Genickbrecher" -- German (example)
        elseif Locale == "esES" or Locale == "esMX" then
            mountName = "Rompecuellos G-99" -- Spanish (example)
        elseif Locale == "ptBR" then
            mountName = "Pé-na-Tábua G-99" -- Brazilian Portuguese (example)
        elseif Locale == "ruRU" then
            mountName = "Стремглав G-99" -- Russian (example)
        else
            mountName = "斷頸者G-99" -- Default fallback
        end
        if ShowDebug then
            print("CYRandomMount: In Undermine, using specific mount...")
            print("Current WoW locale:", Locale)
            print("CYRandomMount: Using mount:", mountName)
        end

        local macroPrefix = "#showtooltip\n/run if IsMounted() then CYRandomMount_InstantUpdate() end\n"
        local macroBodyStr = macroPrefix.."/dismount [mounted]\n/cast [nomounted] "..mountName
        local macroIndex = GetMacroIndexByName(macroName)
        if macroIndex then
            SafeEditMacro(macroIndex, macroName, macroIcon, macroBodyStr, false)
            return
        end
    end

    -- Check if the area is mountable; if not, do not update macro
    -- Note: There is no CanPlayerMount API, so we use IsIndoors() and IsResting() as fallback
    -- Some outdoor areas still do not allow mounting (e.g. certain battlegrounds, special zones)
    if (IsIndoors and IsIndoors()) or (IsInInstance and IsInInstance()) then
        if ShowDebug then
            print("CYRandomMount: IsIndoors() = ", IsIndoors and IsIndoors())
            print("CYRandomMount: IsInInstance() = ", IsInInstance and IsInInstance())
            print("CYRandomMount: Area is not mountable (indoors, resting, or instance), skipping macro update.")
        end
        return
    end

    -- Check if area is flyable
    local isFlyable = IsFlyableArea and IsFlyableArea() or false
    -- print("CYRandomMount: isFlyable = ", isFlyable)
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
            if ShowDebug then
                print("CYRandomMount: Current zone is not flyable, using ground mount...")
            end
            local mountID = GetRandomSelectedGroundMount()
            if mountID and C_MountJournal and C_MountJournal.GetMountInfoByID then
                local name, _, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(mountID)
                if isUsable == true then
                    -- Use /cast [nomounted] <mountID> for macro
                    if ShowDebug then
                        print("CYRandomMount: Updated macro with ground mount ID: " .. tostring(mountID))
                    end
                    macroBodyStr = macroPrefix.."/run if IsMounted() then Dismount() else C_MountJournal.SummonByID("..mountID..") end\n"
                    SafeEditMacro(macroIndex, macroName, icon or macroIcon, macroBodyStr, false)
                    return
                else
                    if ShowDebug then
                        print("CYRandomMount: Ground mount ID " .. tostring(mountID) .. " is not usable.")  
                    end
                end
            end
        else
            if ShowDebug then
                print("CYRandomMount: Current zone is flyable, using flying mount...")
            end
        end

        local mountID = GetRandomSelectedFlyingMount()
        if mountID and C_MountJournal and C_MountJournal.GetMountInfoByID then
            local name, _, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(mountID)
            -- Use /cast [nomounted] <mountID> for macro
            macroBodyStr = macroPrefix.."/run if IsMounted() then Dismount() else C_MountJournal.SummonByID("..mountID..") end\n"
            SafeEditMacro(macroIndex, macroName, icon or macroIcon, macroBodyStr, false)
            if ShowDebug then
                print("CYRandomMount: Updated macro with flying mount ID: " .. tostring(mountID))
            end
            return
        end     
        -- Fallback: No available flying mount
        -- macroBodyStr = macroPrefix.."/run if IsMounted() then Dismount() else C_MountJournal.SummonByID(1589) end\n/script print('CYRandomMount: No available selected flying mount, use default one !')"
        -- SafeEditMacro(macroIndex, macroName, macroIcon, macroBodyStr, false)
        return                  

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


