
local AFUtils = require("AFUtils.AFUtils")
require("Settings")

local LocationsManager = {}

---comment
---@param Location LocationStruct
---@return string
function LocationToString(Location)
    if not Location or not Location.Name then return "" end
    
    return Location.Name .. ": Coordinates " .. VectorToString(Location.Location) .. ", Rotation: " .. RotatorToString(Location.Rotation)
end

---@param Name string
---@param Location FVector
---@param Rotation FRotator
---@return LocationStruct? # Returns created or update LocationStruct or nil if failed
local function UpdateOrCreateLocation(Name, Location, Rotation)
    if type(Name) ~= "string" or Name == "" then return nil end

    local lowerName = string.lower(Name)
    for _, location in ipairs(Settings.Locations) do
        if string.lower(location.Name) == lowerName then
            location.Location = Location
            location.Rotation = Rotation
            return location
        end
    end

    local locationStruct = LocationStruct(Name, Location, Rotation)
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
    if myPlayer then
        local acotrLocation = myPlayer:K2_GetActorLocation()
        local acotrRotation = myPlayer:K2_GetActorRotation()
        acotrLocation.Z = acotrLocation.Z + 20 -- Increase Z to not get stuck
        
        return UpdateOrCreateLocation(Name, acotrLocation, acotrRotation)
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
            LogDebug("LoadLocation: TeleportPlayer to: " .. VectorToString(location.Location))
            return myPlayer:TeleportPlayer(location.Location, location.Rotation)
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