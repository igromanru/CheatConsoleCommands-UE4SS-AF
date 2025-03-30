
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

---@class Settings
Settings = {
    Version = ModVersion,
    GodMode = false,
    InfiniteHealth = false,
    InfiniteStamina = false,
    InfiniteDurability = false,
    InfiniteEnergy = false,
    NoOverheat = false,
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
    InstantCrafting = false,
    InfiniteAmmo = false,
    NoClip = false,
    NoRecoil = false,
    NoSway = false,
    MasterKey = false,
    LeyakCooldown = 0, -- 0 disable command
    SpeedhackMultiplier = 1.0,
    PlayerGravityScale = 1.0,
    DistantShore = false,
    InfiniteCrouchRoll = false,
    InstantToilet = false,
    InstantPlantGrowth = false,
    InfiniteTraitPoints = false,
    JournalEntryUnlocker = false,
    AutoSaveInterval = 0,
    Locations = {
        LocationStruct("Cafeteria", "Facility_Office1", FVector(-15314, 12532, 128), FRotator(0, 359, 0)),
        LocationStruct("Manufacturing", "Facility_MFWest", FVector(-10393, 35181, 128), FRotator(356, 46, 0)),
        LocationStruct("Far Garden", "V_Anteverse_A", FVector(119042, 330694, 2385), FRotator(348, 109, 0)),
        LocationStruct("Flathill", "V_FOG", FVector(6275, 337158, 1294), FRotator(358, 268, 0)),
        LocationStruct("Train", "V_Train", FVector(333744, 12772, 988), FRotator(353, 90, 0)),
        LocationStruct("Store", "Vignette_FurnitureWarehouse", FVector(343302, -119069, 118), FRotator(359, 90, 0)),
        LocationStruct("Mycofields", "V_Anteverse_B", FVector(324726, 329753, 2162), FRotator(2, 189, 0)),
        LocationStruct("Night Realm", "V_NIGHT", FVector(324726, 329753, 2162), FRotator(2, 189, 0)),
        LocationStruct("Distant Shore", "V_DistantShore", FVector(5442, 31087, -237874), FRotator(358, 135, 0)),
    }, ---@type LocationStruct[]
}
