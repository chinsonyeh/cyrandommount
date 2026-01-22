-- WoW 11.0+ Settings API implementation
local DefaultMacroName = "CYRandomMount"

-- State flags
local isAddonLoaded = false
local isPlayerLoggedIn = false
local optionsLoaded = false

local ShowDebug = false -- Set to true to enable debug messages

local function GetCharacterKey()
    return UnitName("player") .. "-" .. GetRealmName()
end

local function TryLoadOptions()
    if isAddonLoaded and isPlayerLoggedIn and not optionsLoaded then
        -- The main DB initialization is now in CYRandomMountOptions.lua
        -- This function ensures the options panel is created, which triggers the init.
        
        -- Handle potential macro name migration from old versions
        local db = _G.CYRandomMountDB
        if db and db.Default and db.Default.macroName and db.Default.macroName ~= DefaultMacroName then
            if ShowDebug then
                print("CYRandomMount: Migrating macro from '" .. db.Default.macroName .. "' to '" .. DefaultMacroName .. "'")
            end
            local oldMacroIndex = GetMacroIndexByName(db.Default.macroName)
            if oldMacroIndex then
                local success, err = pcall(DeleteMacro, oldMacroIndex)
                if ShowDebug then
                    if success then
                        print("CYRandomMount: Old macro deleted successfully")
                    else
                        print("CYRandomMount: Failed to delete old macro: " .. tostring(err))
                    end
                end
            elseif ShowDebug then
                print("CYRandomMount: Old macro not found, skipping deletion")
            end
            db.Default.macroName = DefaultMacroName
            if ShowDebug then
                print("CYRandomMount: Stored macro name reset to default")
            end
        end

        if ShowDebug then
            print("CYRandomMount: Addon and player are loaded, creating options panel...")
        end
        if CYRandomMountOptions and CYRandomMountOptions.CreateOptionsPanel then
            -- This call will also initialize the database via InitCYRandomMountDB()
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
local macroName = DefaultMacroName
local macroIcon = "INV_Misc_QuestionMark"

MAX_ACCOUNT_MACROS = MAX_ACCOUNT_MACROS or 120

local function CreateMountMacro(force)
    -- Check if macro already exists
    for i = 1, GetNumMacros(false) do
        local name = GetMacroInfo(i)
        if name == macroName then
            if ShowDebug then print("CYRandomMount: Macro '" .. macroName .. "' already exists.") end
            return
        end
    end
    -- Create new macro
    if GetNumMacros(false) < MAX_ACCOUNT_MACROS then
        local defaultMountID = 1589 -- Renewed Proto-Drake
        -- C_MountJournal.GetMountInfoByID returns: name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID, isForDragonriding
        local name, spellID, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(defaultMountID)
        if isUsable then
            local macroBodyStr = "#showtooltip\n/run if IsMounted() then Dismount() else C_MountJournal.SummonByID(1589) end\n/run CYRandomMount_InstantUpdate()\n"
            local macroIndex = CreateMacro(macroName, icon or macroIcon, macroBodyStr, false)
            if not macroIndex or macroIndex == 0 then
                print("CYRandomMount: Failed to create macro '" .. macroName .. "'.")
            elseif ShowDebug then
                print("CYRandomMount: Macro '" .. macroName .. "' created successfully.")
            end
        else
            -- Fallback
            local macroBodyStr = "#showtooltip\n/dismount [mounted]\n/cast [nomounted] CYRandomMount\n/run CYRandomMount_InstantUpdate()\n"
            CreateMacro(macroName, macroIcon, macroBodyStr, false)
        end
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event)
    CreateMountMacro()
end)

local function GetCurrentMountIDFromMacro()
    local macroIndex = GetMacroIndexByName(macroName)
    if not macroIndex then return nil end
    
    local _, _, body = GetMacroInfo(macroIndex)
    if body then
        -- Extract mountID from pattern: C_MountJournal.SummonByID(<number>)
        local mountID = body:match("C_MountJournal%.SummonByID%((%d+)%)")
        if mountID then
            return tonumber(mountID)
        end
    end
    return nil
end

local function GetRandomMountFromList(mountList, excludeMountID)
    local usableMounts = {}
    if mountList and #mountList > 0 then
        for _, mountID in ipairs(mountList) do
            -- C_MountJournal.GetMountInfoByID returns: name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID, isForDragonriding
            local name, spellID, icon, isActive, isUsable = C_MountJournal.GetMountInfoByID(mountID)
            if isUsable then
                table.insert(usableMounts, mountID)
            elseif ShowDebug then
                print("CYRandomMount: Mount ID " .. tostring(mountID) .. " is not usable.")
            end
        end
    end
    
    -- If more than 1 usable mount, exclude current mount to ensure variety
    if #usableMounts > 1 and excludeMountID then
        local filtered = {}
        for _, mountID in ipairs(usableMounts) do
            if mountID ~= excludeMountID then
                table.insert(filtered, mountID)
            end
        end
        if #filtered > 0 then
            usableMounts = filtered
            if ShowDebug then
                print("CYRandomMount: Excluded current mount ID " .. tostring(excludeMountID) .. ", " .. #usableMounts .. " mounts remaining")
            end
        end
    end
    
    if #usableMounts > 0 then
        return usableMounts[math.random(#usableMounts)]
    end
    return nil
end

local function GetRandomSelectedFlyingMount(excludeMountID)
    local charKey = GetCharacterKey()
    if not CYRandomMountDB or not CYRandomMountDB[charKey] then return nil end
    
    local profile = (CYRandomMountDB[charKey].ListMode == 2) and CYRandomMountDB.Default or CYRandomMountDB[charKey]
    return GetRandomMountFromList(profile.FlyingMounts, excludeMountID)
end

local function GetRandomSelectedGroundMount(excludeMountID)
    local charKey = GetCharacterKey()
    if not CYRandomMountDB or not CYRandomMountDB[charKey] then return nil end

    local profile = (CYRandomMountDB[charKey].ListMode == 2) and CYRandomMountDB.Default or CYRandomMountDB[charKey]
    return GetRandomMountFromList(profile.GroundMounts, excludeMountID)
end

local function SafeEditMacro(...)
    local ok, err = pcall(EditMacro, ...)
    if not ok then
        print("CYRandomMount: EditMacro failed: " .. tostring(err))
    end
end

local function UpdateMountMacroByZone()
    if MacroFrame and MacroFrame:IsShown() then return end

    local zoneID = C_Map.GetBestMapForUnit("player")
    if zoneID == 2346 then -- Undermine
        local locale = GetLocale()
        local mountName = "G-99 Breakneck" -- Default
        if locale == "zhTW" then mountName = "斷頸者G-99"
        elseif locale == "zhCN" then mountName = "G-99疾飙飞车"
        -- Other locales can be added here
        end
        
        local macroBodyStr = "#showtooltip\n/dismount [mounted]\n/cast [nomounted] "..mountName.."\n/run CYRandomMount_InstantUpdate()\n"
        local macroIndex = GetMacroIndexByName(macroName)
        if macroIndex then
            SafeEditMacro(macroIndex, macroName, macroIcon, macroBodyStr, false)
        end
        return
    end

    -- Use C_Map API instead of deprecated IsIndoors
    local isIndoors = IsPlayerIndoors()
    if isIndoors then
        if ShowDebug then print("CYRandomMount: Indoors, skipping macro update.") end
        return
    end

    local macroIndex = GetMacroIndexByName(macroName)
    if not macroIndex then return end

    -- Get current mount ID to exclude it from next selection
    local currentMountID = GetCurrentMountIDFromMacro()
    if ShowDebug and currentMountID then
        print("CYRandomMount: Current mount ID: " .. tostring(currentMountID))
    end

    -- Use C_Map.CanPlayerUseFlyingMount() instead of deprecated IsFlyableArea()
    local isFlyable = C_Map.CanPlayerUseFlyingMount() or false
    local mountID
    
    if isFlyable then
        if ShowDebug then print("CYRandomMount: Zone is flyable, getting flying mount.") end
        mountID = GetRandomSelectedFlyingMount(currentMountID)
    else
        if ShowDebug then print("CYRandomMount: Zone is not flyable, getting ground mount.") end
        mountID = GetRandomSelectedGroundMount(currentMountID)
    end

    if not mountID then -- Fallback if no mount is selected/usable
        mountID = GetRandomSelectedFlyingMount(currentMountID) -- Try a flying one as they can run on the ground
        if not mountID then 
            if ShowDebug then print("CYRandomMount: No usable selected mounts found.") end
            return 
        end
    end

    -- C_MountJournal.GetMountInfoByID returns: name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID, isForDragonriding
    local name, spellID, icon = C_MountJournal.GetMountInfoByID(mountID)
    if name then
        local macroBodyStr = "#showtooltip\n/run if IsMounted() then Dismount() else C_MountJournal.SummonByID("..mountID..") end\n/run CYRandomMount_InstantUpdate()\n"
        SafeEditMacro(macroIndex, macroName, icon or macroIcon, macroBodyStr, false)
        if ShowDebug then
            print("CYRandomMount: Updated macro with mount ID: " .. tostring(mountID))
        end
    end
end


function CYRandomMount_InstantUpdate()
    local charKey = GetCharacterKey()
    if not CYRandomMountDB or not CYRandomMountDB[charKey] then return end
    
    -- Only execute if in instant update mode (mode 1)
    if CYRandomMountDB[charKey].UpdateMacroMode ~= 1 then return end
    
    -- Only update if not mounted (don't update when dismounting)
    if not IsMounted() then
        -- Schedule next mount update
        UpdateMountMacroByZone()
    end
end

local zoneUpdateFrame = CreateFrame("Frame")
zoneUpdateFrame:RegisterEvent("ZONE_CHANGED")
zoneUpdateFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
zoneUpdateFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
zoneUpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
zoneUpdateFrame:SetScript("OnEvent", function(self, event, ...)
    if ShowDebug then print("CYRandomMount: zone event fired:", tostring(event)) end
    -- Delay 1 second to let zone APIs settle
    C_Timer.After(1, function()
        if ShowDebug then print("CYRandomMount: running UpdateMountMacroByZone after event:", tostring(event)) end
        UpdateMountMacroByZone()
    end)
end)

local timer = CreateFrame("Frame")
timer.elapsed = 0
timer:SetScript("OnUpdate", function(self, elapsed)
    if not isPlayerLoggedIn then return end

    local charKey = GetCharacterKey()
    if not CYRandomMountDB or not CYRandomMountDB[charKey] then return end

    local updateMode = CYRandomMountDB[charKey].UpdateMacroMode
    if updateMode ~= 2 then return end
    
    local refreshTime = CYRandomMountDB[charKey].RefreshTime
    if type(refreshTime) ~= "number" or refreshTime <= 0 then return end
    
    self.elapsed = self.elapsed + elapsed
    if self.elapsed >= refreshTime then
        UpdateMountMacroByZone()
        self.elapsed = 0
    end
end)
