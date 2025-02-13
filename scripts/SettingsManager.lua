
local BaseUtils = require("AFUtils.BaseUtils.BaseUtils")
require("Settings")
local JsonLua = require("json")

local FileName = ModName .. ".json"

local SettingsManager = {}

---Returns path to mod's root directory
---@return string?
local function GetModPath()
    local info = debug.getinfo(1, "S")
    if info and info.source then
        return info.source:match("@(.+\\)Scripts")
    end
    return nil
end

local SettingsFilePath = nil
---Returns full path to the Settings file in mod's root directory
---@return string?
function SettingsManager.GetSettingsFilePath()
    if type(SettingsFilePath) == "string" and SettingsFilePath ~= "" then
        return SettingsFilePath
    end
    LogDebug("GetSettingsPath: File path isn't valid, getting a new one")

    local modPath = GetModPath()
    if modPath then
        LogDebug("GetSettingsPath: Mod Path: " .. modPath)
        SettingsFilePath = modPath .. FileName
        LogDebug("GetSettingsPath: SettingsFilePath: " .. SettingsFilePath)
    end
    return SettingsFilePath
end

function SettingsManager.SaveToFile()
    local settingsFilePath = SettingsManager.GetSettingsFilePath()
    if not settingsFilePath then return false end

    local file = io.open(settingsFilePath, "w")
    if file then
        LogDebug("Opened file \"" .. FileName .. "\" for writing")
        local json = JsonLua.encode(Settings)
        LogDebug("Write JSON to File: " .. json)
        file:write(json)
        return file:close()
    else
        LogDebug("SaveToFile: Failed to open file: " .. settingsFilePath)
    end
    return false
end

function SettingsManager.LoadFromFile()
    local settingsFilePath = SettingsManager.GetSettingsFilePath()
    if not settingsFilePath then return false end

    local file = io.open(settingsFilePath, "r")
    if file then
        LogDebug("Opened file \"" .. FileName .. "\" for reading")
        local content = file:read("*all")
        LogDebug("File content: " .. content)
        local status, settingsFromFile = pcall(JsonLua.decode, content) ---@type boolean, Settings
        if status and settingsFromFile then
            LogDebug("Settings file version: " .. tostring(settingsFromFile.Version) .. ", Settings object version: " .. Settings.Version)
            if settingsFromFile.Version ~= Settings.Version then
                LogDebug("Settings version doesn't match, loading only specified settings from file")
                Settings.SpeedhackMultiplier = settingsFromFile.SpeedhackMultiplier
                Settings.PlayerGravityScale = settingsFromFile.PlayerGravityScale
                Settings.Locations = settingsFromFile.Locations
                Settings.LeyakCooldown = settingsFromFile.LeyakCooldown
                if Settings.LeyakCooldown == DefaultLeyakCooldown then
                    Settings.LeyakCooldown = 0
                end
            else
                Settings = settingsFromFile
            end
        else
            LogError("Failed to decode json settings from file, status:", status)
        end

        --Overwrite values that shouldn't reapply
        Settings.NoClip = false
        Settings.DistantShore = false
        return file:close()
    else
        LogDebug("LoadFromFile: Failed to open file: " .. settingsFilePath)
    end
    return false
end

local SettingsMonitor = {}
function SettingsManager.AutoSaveOnChange()
    if SettingsMonitor.GodMode ~= Settings.GodMode
        or SettingsMonitor.InfiniteHealth ~= Settings.InfiniteHealth
        or SettingsMonitor.InfiniteStamina ~= Settings.InfiniteStamina
        or SettingsMonitor.InfiniteDurability ~= Settings.InfiniteDurability
        or SettingsMonitor.InfiniteEnergy ~= Settings.InfiniteEnergy
        or SettingsMonitor.NoOverheat ~= Settings.NoOverheat
        or SettingsMonitor.InfiniteAmmo ~= Settings.InfiniteAmmo
        or SettingsMonitor.NoHunger ~= Settings.NoHunger
        or SettingsMonitor.NoThirst ~= Settings.NoThirst
        or SettingsMonitor.NoFatigue ~= Settings.NoFatigue
        or SettingsMonitor.InfiniteContinence ~= Settings.InfiniteContinence
        or SettingsMonitor.LowContinence ~= Settings.LowContinence
        or SettingsMonitor.NoRadiation ~= Settings.NoRadiation
        or SettingsMonitor.PerfectTemperature ~= Settings.PerfectTemperature
        or SettingsMonitor.InfiniteOxygen ~= Settings.InfiniteOxygen
        or SettingsMonitor.FreeCrafting ~= Settings.FreeCrafting
        or SettingsMonitor.InstantCrafting ~= Settings.InstantCrafting
        or SettingsMonitor.Invisible ~= Settings.Invisible
        or SettingsMonitor.NoFallDamage ~= Settings.NoFallDamage
        or SettingsMonitor.NoClip ~= Settings.NoClip
        or SettingsMonitor.NoRecoil ~= Settings.NoRecoil
        or SettingsMonitor.NoSway ~= Settings.NoSway
        or SettingsMonitor.MasterKey ~= Settings.MasterKey
        or SettingsMonitor.LeyakCooldown ~= Settings.LeyakCooldown
        or SettingsMonitor.SpeedhackMultiplier ~= Settings.SpeedhackMultiplier
        or SettingsMonitor.PlayerGravityScale ~= Settings.PlayerGravityScale
        or SettingsMonitor.InfiniteCrouchRoll ~= Settings.InfiniteCrouchRoll
        or (Settings.Locations and SettingsMonitor.LocationsCount ~= #Settings.Locations) 
    then
        LogDebug("AutoSaveOnChange: Changes detected")
        SettingsMonitor.GodMode = Settings.GodMode
        SettingsMonitor.InfiniteHealth = Settings.InfiniteHealth
        SettingsMonitor.InfiniteStamina = Settings.InfiniteStamina
        SettingsMonitor.InfiniteDurability = Settings.InfiniteDurability
        SettingsMonitor.InfiniteEnergy = Settings.InfiniteEnergy
        SettingsMonitor.NoOverheat = Settings.NoOverheat
        SettingsMonitor.InfiniteAmmo = Settings.InfiniteAmmo
        SettingsMonitor.NoHunger = Settings.NoHunger
        SettingsMonitor.NoThirst = Settings.NoThirst
        SettingsMonitor.NoFatigue = Settings.NoFatigue
        SettingsMonitor.InfiniteContinence = Settings.InfiniteContinence
        SettingsMonitor.LowContinence = Settings.LowContinence
        SettingsMonitor.NoRadiation = Settings.NoRadiation
        SettingsMonitor.PerfectTemperature = Settings.PerfectTemperature
        SettingsMonitor.InfiniteOxygen = Settings.InfiniteOxygen
        SettingsMonitor.FreeCrafting = Settings.FreeCrafting
        SettingsMonitor.InstantCrafting = Settings.InstantCrafting
        SettingsMonitor.Invisible = Settings.Invisible
        SettingsMonitor.NoFallDamage = Settings.NoFallDamage
        SettingsMonitor.NoClip = Settings.NoClip
        SettingsMonitor.NoRecoil = Settings.NoRecoil
        SettingsMonitor.NoSway = Settings.NoSway
        SettingsMonitor.MasterKey = Settings.MasterKey
        SettingsMonitor.LeyakCooldown = Settings.LeyakCooldown
        SettingsMonitor.SpeedhackMultiplier = Settings.SpeedhackMultiplier
        SettingsMonitor.PlayerGravityScale = Settings.PlayerGravityScale
        SettingsMonitor.InfiniteCrouchRoll = Settings.InfiniteCrouchRoll
        SettingsMonitor.LocationsCount = Settings.Locations and #Settings.Locations or 0
        SettingsManager.SaveToFile()
    end
end

return SettingsManager