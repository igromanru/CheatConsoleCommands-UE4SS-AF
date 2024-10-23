
local AFUtils = require("AFUtils.AFUtils")
local UEHelpers = require("UEHelpers")

---@class TraitInfo
---@field FName FName
---@field Description string
---@field Buff boolean
local TraitInfo = {}

---@class TraitStruct
---@field Id string
---@field Info TraitInfo
local TraitStruct = {}

---@class Traits
local Traits = {
    TraitsArray = {}, ---@type TraitStruct[]
    TraitsMap = {}, ---@type { [string]: TraitStruct }
}
---@param Id string
---@param Info { Description: string, Buff: boolean }
---@return TraitStruct?
local function CreateTrait(Id, Info)
    local fname = UEHelpers.FindFName(Id)
    if fname == NAME_None then return nil end

    ---@type TraitStruct
    local trait = {
        Id = Id,
        Info = {
            FName = fname,
            Description = Info.Description,
            Buff = Info.Buff
        }
    }
    table.insert(Traits.TraitsArray, trait)
    Traits.TraitsMap[Id] = trait

    return trait
end

local function InitTraits()
    for key, value in pairs(AFUtils.Traits) do
        CreateTrait(key, value)
    end
end

InitTraits()


return Traits