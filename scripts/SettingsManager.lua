
local BaseUtils = require("AFUtils.BaseUtils.BaseUtils")
local Settings = require("Settings")
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
    LogDebug("GetSettingsPath: FIle path isn't valid, getting a new one")

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
        Settings = JsonLua.decode(content)
        LogDebug("Parsed JSON to Settings")
        return file:close()
    else
        LogDebug("LoadFromFile: Failed to open file: " .. settingsFilePath)
    end
    return false
end

return SettingsManager