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
        CYRandomMountOptions.CreateOptionsPanel()
        optionsLoaded = true
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


local function CreateMountMacro()
    -- Check if macro already exists
    for i = 1, GetNumMacros() do
        local name = GetMacroInfo(i)
        if name == macroName then
            return -- Already exists, do not create again
        end
    end
    -- Create new macro
    if GetNumMacros() < MAX_ACCOUNT_MACROS then
        -- Only run CYRandomMount_InstantUpdate() when mounted
        local macroBody = "#showtooltip\n/run CYRandomMount_InstantUpdate()\n/cast CYRandomMount"
        CreateMacro(macroName, macroIcon, macroBody, false)
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
    flyingBox = CYRandomMountOptions.flyingBox() -- Get flyingBox from options panel
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
    groundBox = CYRandomMountOptions.groundBox() -- Get groundBox from options panel
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

local lastZoneType = nil
local lastIsFlyable = nil
local function UpdateMountMacroByZone()
    -- Pause auto-update if player is editing macro
    if MacroFrame and MacroFrame:IsShown() then
        return
    end

    -- Check if area is flyable
    local isFlyable = IsFlyableArea and IsFlyableArea() or false
    lastIsFlyable = isFlyable
    local macroIndex = nil
    for i = 1, GetNumMacros() do
        local name = GetMacroInfo(i)
        if name == macroName then
            macroIndex = i
            break
        end
    end
    -- print("Update macro: " .. macroName .. ", isFlyable: " .. tostring(isFlyable) .. ", macroIndex: " .. tostring(macroIndex))
    if macroIndex then
        -- Only run CYRandomMount_InstantUpdate() when mounted
        local macroPrefix = "#showtooltip\n/run if IsMounted() then CYRandomMount_InstantUpdate() end\n"
        local macroBody = nil
        if isFlyable then
            -- print("Flyable area, using flying mount")
            local mountID = GetRandomSelectedFlyingMount()
            -- print("mountID: " .. tostring(mountID))
            if mountID then
                local name, _, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(mountID)
                name = SanitizeMacroName(name)
                if isUsable then
                    macroBody = macroPrefix.."/dismount [mounted]\n/cast [nomounted] "..name
                    EditMacro(macroIndex, macroName, icon or macroIcon, macroBody)
                else
                    macroBody = macroPrefix.."/dismount [mounted]\n/cast [nomounted] Flying Mount"
                    EditMacro(macroIndex, macroName, macroIcon, macroBody)
                end
            else
                macroBody = macroPrefix.."/dismount [mounted]\n/cast [nomounted] Flying Mount"
                EditMacro(macroIndex, macroName, macroIcon, macroBody)
            end
        else
            -- print("Not flyable area, using ground mount")
            -- Use ground mount if not flyable
            local mountID = GetRandomSelectedGroundMount()
            -- print("mountID: " .. tostring(mountID))
            if mountID then
                local name, _, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(mountID)
                name = SanitizeMacroName(name)
                if isUsable then
                    macroBody = macroPrefix.."/dismount [mounted]\n/cast [nomounted] "..name
                    EditMacro(macroIndex, macroName, icon or macroIcon, macroBody)
                else
                    macroBody = macroPrefix.."/dismount [mounted]\n/cast [nomounted] Ground Mount"
                    EditMacro(macroIndex, macroName, macroIcon, macroBody)
                end
            else
                macroBody = macroPrefix.."/dismount [mounted]\n/cast [nomounted] Ground Mount"
                EditMacro(macroIndex, macroName, macroIcon, macroBody)
            end            
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
    C_Timer.After(1, function()  -- Delay 1 second to ensure zone change is complete
        -- print("Zone changed, updating macro")
        UpdateMountMacroByZone()
    end)
end)

local timer = CreateFrame("Frame")
timer.elapsed = 0
timer:SetScript("OnUpdate", function(self, elapsed)
    RefreshTime = CYRandomMountDB.RefreshTime or 10
    if type(RefreshTime) ~= "number" or RefreshTime <= 0 or CYRandomMountOptions.UpdateMacroMode() == 1 then return end
    self.elapsed = self.elapsed + elapsed
    -- print("isAddonLoaded: " .. tostring(isAddonLoaded) .. ", elapsed: " .. tostring(self.elapsed) .. ", RefreshTime: " .. tostring(RefreshTime))
    if isAddonLoaded and self.elapsed >= RefreshTime then
        UpdateMountMacroByZone()
        self.elapsed = 0
    end
end)


