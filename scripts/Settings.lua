
local BaseUtils = require("AFUtils.BaseUtils.BaseUtils")

---@class LocationStruct
---@field Name string
---@field Location FVector
---@field Rotation FRotator

---@param Name string
---@param Location FVector
---@param Rotation FRotator?
---@return LocationStruct
function LocationStruct(Name, Location, Rotation)
    Rotation = Rotation or FRotator(0.0, 0.0, 0.0)
    return {
        Name = Name,
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
    MoveSpeed = -1,
    CrouchSpeed = -1,
    PlayerGravityScale = 1.0,
    LeyakCooldown = DefaultLeyakCooldown,
    InventorySlotCount = -1,
    Locations = {
        LocationStruct("Cafeteria", FVector(12529, 128, -15377)),
        LocationStruct("Flathill", FVector(335956, 1294, 6203)),
    }, ---@type LocationStruct[]
}

return Settings