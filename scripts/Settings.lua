
local BaseUtils = require("AFUtils.BaseUtils.BaseUtils")

---@class LocationStruct
---@field Name string
---@field LevelName string
---@field Location FVector
---@field Rotation FRotator

---@param Name string
---@param LevelName string
---@param Location FVector
---@param Rotation FRotator?
---@return LocationStruct
function LocationStruct(Name, LevelName, Location, Rotation)
    Rotation = Rotation or FRotator(0.0, 0.0, 0.0)
    return {
        Name = Name,
        LevelName =  LevelName,
        Location = Location,
        Rotation = Rotation
    }
end

DefaultLeyakCooldown = 900 -- 15min

Settings = {
    Version = ModVersion,
    GodMode = false,
    InfiniteHealth = false,
    InfiniteStamina = false,
    InfiniteDurability = false,
    InfiniteEnergy = false,
    InfiniteMaxWeight = false,
    NoHunger = false,
    NoThirst = false,
    NoFatigue = false,
    InfiniteContinence = false,
    LowContinence = false,
    NoRadiation = false,
    PerfectTemperature = false,
    InfiniteOxygen = false,
    Invisible = false,
    NoFallDamage = false,
    FreeCrafting = false,
    InfiniteAmmo = false,
    NoClip = false,
    NoRecoil = false,
    NoSway = false,
    MasterKey = false,
    LeyakCooldown = 0, -- 0 disable command
    SpeedhackMultiplier = 1.0,
    PlayerGravityScale = 1.0,
    DistantShore = false,
    Locations = {
        LocationStruct("Cafeteria", "Facility_Office1", FVector(-15314, 12532, 128), FRotator(0, 359, 0)),
        LocationStruct("Flathill", "V_FOG", FVector(6275, 337158, 1294), FRotator(358, 268, 0)),
        LocationStruct("Distant Shore", "V_DistantShore", FVector(331428, -334214, 908), FRotator(1, 3, 0)),
    }, ---@type LocationStruct[]
}
