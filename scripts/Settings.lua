
local BaseUtils = require("AFUtils.BaseUtils.BaseUtils")

---@class LocationStruct
---@field Name string
---@field LevelName string
---@field Location FVector
---@field Rotation FRotator

---@param Name string
---@field LevelName string
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
    InfiniteAmmo = false,
    NoHunger = false,
    NoThirst = false,
    NoFatigue = false,
    InfiniteContinence = false,
    LowContinence = false,
    NoRadiation = false,
    FreeCrafting = false,
    NoFallDamage = false,
    NoClip = false,
    NoRecoil = false,
    NoSway = false,
    MasterKey = false,
    LeyakCooldown = DefaultLeyakCooldown,
    SpeedhackMultiplier = 1.0,
    PlayerGravityScale = 1.0,
    InventorySlotCount = -1,
    DistantShore = false,
    Locations = {
        -- LocationStruct("Cafeteria", FVector(12529, 128, -15377)),
        -- LocationStruct("Flathill", FVector(335956, 1294, 6203)),
    }, ---@type LocationStruct[]
}

return Settings