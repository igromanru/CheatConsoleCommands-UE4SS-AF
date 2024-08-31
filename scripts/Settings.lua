
require("AFUtils.BaseUtils.MathUtils")

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
    LeyakCooldown = 900, -- 15min
    Locations = {
        LocationStruct("Cafeteria", FVector(12529, 128, -15377)),
        LocationStruct("Flathill", FVector(335956, 1294, 6203)),
    }, ---@type LocationStruct[]
}

return Settings