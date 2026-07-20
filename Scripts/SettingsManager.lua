
local BaseUtils = require("AFUtils.BaseUtils.BaseUtils")
local SettingsPair = require("Settings")
local JsonLua = require("json")

local FileName = ModName .. ".json"

local SettingsManager = {}

---Returns path to mod's root directory
---@return string?
local function GetModPath()
    local info = debug.getinfo(1, "S")
    LogDebug("GetModPath: info:", info)
    if info and info.source then
        local src = info.source
        LogDebug("GetModPath: info.source:", src)
        local modPath = src:match("^@(.*/)[Ss]cripts/")
        modPath = modPath or ".."
        LogDebug("GetModPath: modPath:", modPath)
        return modPath
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
        local json = JsonLua.encode(SettingsPair.SettingsData)
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

    local result = false

    local file = io.open(settingsFilePath, "r")
    if file then
        LogDebug("Opened file \"" .. FileName .. "\" for reading")
        local content = file:read("*all")
        file:close()
        LogDebug("File content: " .. content)
        local result, settingsFromFile = pcall(JsonLua.decode, content) ---@type boolean, SettingsData
        if result and settingsFromFile then
            LogDebug("Settings file version: " .. tostring(settingsFromFile.Version) .. ", Settings object version: " .. SettingsPair.SettingsData.Version)
            result = MergeSettingsFromFile(settingsFromFile)
        else
            LogError("Failed to decode json settings from file, status:", status)
        end
    else
        LogDebug("LoadFromFile: Failed to open file: " .. settingsFilePath)
    end

    Settings.Dirty = true

    return result
end

function SettingsManager.AutoSaveOnChange()
    if Settings.Dirty then
        LogDebug("AutoSaveOnChange: Changes detected")
        
        Settings.Dirty = false
        
        SettingsManager.SaveToFile()
    end
end

return SettingsManager