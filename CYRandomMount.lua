-- WoW 11.0+ Settings API implementation
local panel
local refreshTimeSlider
local refreshTimeText
local flyingBox
local groundBox
local RefreshTime = 10

-- 載入設定面板
local optionsLoaded = false
local function LoadOptions()
    if not optionsLoaded then
        -- 載入設定檔案
        -- 若已在 TOC 加入 CYRandomMountOptions.lua 可省略
        -- dofile("Interface\\AddOns\\CYRandomMount\\CYRandomMountOptions.lua")
        CYRandomMountOptions.CreateOptionsPanel()
        optionsLoaded = true
    end
end

local isAddonLoaded = false
local function OnAddonLoaded()
    LoadOptions()
    -- 之後取得設定面板的變數可用 CYRandomMountOptions.flyingBox() 等
end

local addonInitFrame = CreateFrame("Frame")
addonInitFrame:RegisterEvent("ADDON_LOADED")
addonInitFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "CYRandomMount" then
        isAddonLoaded = true
        OnAddonLoaded()
        self:UnregisterEvent("ADDON_LOADED")
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
        if isFlyable then
            -- print("Flyable area, using flying mount")
            local mountID = GetRandomSelectedFlyingMount()
            -- print("mountID: " .. tostring(mountID))
            if mountID then
                local name, _, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(mountID)
                name = SanitizeMacroName(name)
                if isUsable then
                    EditMacro(macroIndex, macroName, icon or macroIcon, "#showtooltip "..name.."\n/dismount [mounted]\n/cast "..name)
                else
                    EditMacro(macroIndex, macroName, macroIcon, "#showtooltip Flying Mount\n/dismount [mounted]\n/cast Flying Mount")
                end
            else
                EditMacro(macroIndex, macroName, macroIcon, "#showtooltip Flying Mount\n/dismount [mounted]\n/cast Flying Mount")
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
                    EditMacro(macroIndex, macroName, icon or macroIcon, "#showtooltip "..name.."\n/dismount [mounted]\n/cast "..name)
                else
                    EditMacro(macroIndex, macroName, macroIcon, "#showtooltip Ground Mount\n/dismount [mounted]\n/cast Ground Mount")
                end
            else
                EditMacro(macroIndex, macroName, macroIcon, "#showtooltip Ground Mount\n/dismount [mounted]\n/cast Ground Mount")
            end            
        end
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
    if type(RefreshTime) ~= "number" or RefreshTime <= 0 then return end
    self.elapsed = self.elapsed + elapsed
    -- print("isAddonLoaded: " .. tostring(isAddonLoaded) .. ", elapsed: " .. tostring(self.elapsed) .. ", RefreshTime: " .. tostring(RefreshTime))
    if isAddonLoaded and self.elapsed >= RefreshTime then
        UpdateMountMacroByZone()
        self.elapsed = 0
    end
end)


