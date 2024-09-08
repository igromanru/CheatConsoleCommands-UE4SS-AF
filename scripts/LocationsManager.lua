
local AFUtils = require("AFUtils.AFUtils")
require("Settings")

local LocationsManager = {}

---@param Location LocationStruct
---@return string
function LocationToString(Location)
    if not Location or not Location.Name then return "" end
    
    local result = Location.Name .. ": Coordinates " .. VectorToString(Location.Location) .. ", Rotation: " .. RotatorToString(Location.Rotation)
    if Location.LevelName then
        result = result .. ", LevelName: " .. Location.LevelName
    end
    return result
end

---@param Name string
---@param LevelName string
---@param Location FVector
---@param Rotation FRotator
---@return LocationStruct? # Returns created or update LocationStruct or nil if failed
local function UpdateOrCreateLocation(Name, LevelName, Location, Rotation)
    if type(Name) ~= "string" or Name == "" then return nil end

    local lowerName = string.lower(Name)
    for _, location in ipairs(Settings.Locations) do
        if string.lower(location.Name) == lowerName then
            location.Location = Location
            location.Rotation = Rotation
            return location
        end
    end

    local locationStruct = LocationStruct(Name, LevelName, Location, Rotation)
    table.insert(Settings.Locations, locationStruct)
    if DebugMode then
        LogDebug("New Settings.Locations:")
        for _, location in ipairs(Settings.Locations) do
            LogDebug(LocationToString(location))
        end
    end
    return locationStruct
end

---@param Name string
---@return LocationStruct?
function LocationsManager.GetLocationByName(Name)
    if type(Name) ~= "string" or Name == "" then return nil end

    local lowerName = string.lower(Name)
    for _, location in ipairs(Settings.Locations) do
        if string.lower(location.Name) == lowerName then
            return location
        end
    end

    return nil
end

---@param Name string
---@return LocationStruct?
function LocationsManager.SaveCurrentLocation(Name)
    local myPlayer = AFUtils.GetMyPlayer()
    local myPlayerController = AFUtils.GetMyPlayerController()
    if myPlayer and myPlayerController then
        local acotrLocation = myPlayer:K2_GetActorLocation()
        acotrLocation.Z = acotrLocation.Z + 20 -- Increase Z to not get stuck
        
        return UpdateOrCreateLocation(Name, myPlayerController.ActiveLevelName:ToString(), acotrLocation, AFUtils.GetControlRotation())
    end
    return nil
end

---@param Name string
---@return boolean Success
function LocationsManager.LoadLocation(Name)
    local location = LocationsManager.GetLocationByName(Name)
    if location and not IsEmptyVector(location.Location) then
        local myPlayer = AFUtils.GetMyPlayer()
        if myPlayer then
            if location.LevelName then
                local myPlayerController = AFUtils.GetMyPlayerController()
                if myPlayerController and myPlayerController.ActiveLevelName:ToString() ~= location.LevelName then
                    LogDebug("LoadLocation: ActiveLevelName: " .. myPlayerController.ActiveLevelName:ToString())
                    local outSuccess = { bSuccess = false }
                    local outNotLoaded = { bNotLoaded = false }
                    LogDebug("LoadLocation: LoadStreamLevel with name: " .. location.LevelName)
                    local steamLevel = AFUtils.GetLevelStreamingCustom():LoadStreamLevel(myPlayerController:GetWorld(), location.LevelName, false, false, outSuccess, outNotLoaded)
                    LogDebug("LoadLocation: LoadStreamLevel Success: ", outSuccess.bSuccess)
                    LogDebug("LoadLocation: LoadStreamLevel NotLoaded: ", outNotLoaded.bNotLoaded)
                    if not outSuccess or not outSuccess.bSuccess then
                        LogError("LoadLocation: Failed to LoadStreamLevel, LevelName: " .. location.LevelName)
                    end
                else
                    LogDebug("LoadLocation: Skip LoadStreamLevel, ActiveLevelName and location LevelName are the same")
                end
            else
                LogInfo("LoadLocation: Warning! Loading a Location wtihout a LevelName!")
            end
            LogDebug("LoadLocation: TeleportPlayer to: " .. VectorToString(location.Location))
            local success = myPlayer:TeleportPlayer(location.Location, location.Rotation)
            if success then
                AFUtils.SetControlRotation(location.Rotation)
            end
            return success
        end
    else
        LogError("LoadLocation: Couldn't find location with name: " .. Name)
    end

    return false
end

---@return string[]
function LocationsManager.ToStringArray()
    local locations = {}
    for _, location in ipairs(Settings.Locations) do
        table.insert(locations, LocationToString(location))
    end
    return locations
end

return LocationsManager