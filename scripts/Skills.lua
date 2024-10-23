
local AFUtils = require("AFUtils.AFUtils")

---@class SkillStruct
---@field Id CharacterSkills|integer
---@field Name string
---@field Aliases table<string>
---@field Description string?
local SkillStruct = {}

---@class Skills
local Skills = {
    SkillsArray = {}, ---@type SkillStruct[]
    SkillsMap = {}, ---@type { [string]: SkillStruct }
}

local SkillIdToIndexMap = {} ---@type { [CharacterSkills]: integer }

---@param CharacterSkillId CharacterSkills|integer
---@param SkillName string
---@param Aliases table<string>|string
---@param Description string?
---@return SkillStruct # Returns created skill
local function CreateSkill(CharacterSkillId, SkillName, Aliases, Description)
    if not CharacterSkillId then
        error("CharacterSkillId has to be set!")
    end
    if not Aliases then
        error("Aliases have to be set!")
    end

    if type(Aliases) == "string" then
        Aliases = { Aliases }
    end
    ---@type SkillStruct
    local skill = {
        Id = CharacterSkillId,
        Name = SkillName,
        Aliases = Aliases,
        Description = Description
    }
    table.insert(Skills.SkillsArray, skill)
    Skills.SkillsMap[SkillName] = skill
    for i, value in ipairs(Aliases) do
        Skills.SkillsMap[value] = skill
    end

    return skill
end

CreateSkill(AFUtils.CharacterSkills.Sprinting, "Sprinting", {"sprinting", "sprint", "spr", "stamina", "sp"})
CreateSkill(AFUtils.CharacterSkills.Strength, "Strength", {"strength", "str", "weight"})
CreateSkill(AFUtils.CharacterSkills.Throwing, "Throwing", {"throwing", "throw", "thr"})
CreateSkill(AFUtils.CharacterSkills.Sneaking, "Sneaking", {"sneaking", "sneak", "stealth", "snk"})
CreateSkill(AFUtils.CharacterSkills.BluntMelee, "Blunt Melee", {"bluntmelee", "blunt"})
CreateSkill(AFUtils.CharacterSkills.SharpMeele, "Sharp Meele", {"sharpmeele", "sharp"})
CreateSkill(AFUtils.CharacterSkills.Accuracy, "Accuracy", {"accuracy", "acc", "aim"})
CreateSkill(AFUtils.CharacterSkills.Reloading, "Reloading", {"reloading", "reload", "magazine"})
CreateSkill(AFUtils.CharacterSkills.Fortitude, "Fortitude", {"fortitude", "fort", "tough", "health", "hp"})
CreateSkill(AFUtils.CharacterSkills.Crafting, "Crafting", {"crafting", "craft", "bench"})
CreateSkill(AFUtils.CharacterSkills.Construction, "Construction", {"construction", "const", "cons", "build"})
CreateSkill(AFUtils.CharacterSkills.FirstAid, "First Aid", {"firstaid", "aid", "healing", "heal", "wound"})
CreateSkill(AFUtils.CharacterSkills.Cooking, "Cooking", {"cooking", "cook", "heisenberg"})
CreateSkill(AFUtils.CharacterSkills.Agriculture, "Agriculture", {"agriculture", "agr", "grow", "plant", "plants"})
CreateSkill(AFUtils.CharacterSkills.Fishing, "Fishing", {"fishing", "fish"})


function Skills.GetSkillByAlias(Alias)
    if type(Alias) ~= "string" then return nil end

    return Skills.SkillsMap[Alias]
end

function Skills.GetSkillsAsStrings()
    local skills = {}
    for _, v in ipairs(Skills.SkillsArray) do
        local desc = v.Name .. ": "
        for j, alias in ipairs(v.Aliases) do
            if j > 1 then
                desc = desc .. " | "
            end
            desc = desc .. alias
        end
        table.insert(skills, desc)
    end
    return skills
end

---@param CharacterSkillId CharacterSkills|integer
---@return integer
local function GetArrayIndexBySkillId(CharacterSkillId)
    if not SkillIdToIndexMap or #SkillIdToIndexMap < 1 then
        SkillIdToIndexMap = {}
        local progressionComponent =  AFUtils.GetMyCharacterProgressionComponent()
        if IsValid(progressionComponent) and progressionComponent.CharacterSkills_Keys then
           for i = 1, #progressionComponent.CharacterSkills_Keys, 1 do
                local skillId = progressionComponent.CharacterSkills_Keys[i]
                SkillIdToIndexMap[skillId] = i
           end 
        end
    end

    return SkillIdToIndexMap[CharacterSkillId]
end


---@param Player AAbiotic_PlayerCharacter_C?
---@param CharacterSkillId CharacterSkills|integer
---@return FAbiotic_CharacterSkill_Struct?
function Skills.GetCharacterSkillStructById(Player, CharacterSkillId)
    if not Player or not Player:IsValid() or not Player.CharacterProgressionComponent:IsValid() then return nil end

    local index = GetArrayIndexBySkillId(CharacterSkillId)
    local progressionComponent =  Player.CharacterProgressionComponent
    if IsValid(progressionComponent) and #progressionComponent.CharacterSkills_Values >= index then
        return progressionComponent.CharacterSkills_Values[index]
    end

    return nil
end

---@param CharacterSkillId CharacterSkills|integer
---@return FAbiotic_CharacterSkill_Struct?
function Skills.GetMyCharacterSkillStructById(CharacterSkillId)
    return Skills.GetCharacterSkillStructById(AFUtils.GetMyPlayer(), CharacterSkillId)
end

---@param Player AAbiotic_PlayerCharacter_C?
---@param CharacterSkillId CharacterSkills|integer
---@param Amount integer
---@return boolean Success
function Skills.AddXp(Player, CharacterSkillId, Amount)
    if not Player or not Player:IsValid() or not Player.CharacterProgressionComponent:IsValid() then return false end

    local outSuccess = {  Success = false }
    Player.CharacterProgressionComponent:Server_AddXPToSkill(CharacterSkillId, Amount, true, outSuccess)
    return outSuccess and outSuccess.Success
end

---@param CharacterSkillId CharacterSkills|integer
---@param Amount integer
---@return boolean Success
function Skills.AddXpToMyPlayer(CharacterSkillId, Amount)
    return Skills.AddXp(AFUtils.GetMyPlayer(), CharacterSkillId, Amount)
end

---@param Player AAbiotic_PlayerCharacter_C?
---@param CharacterSkillId CharacterSkills|integer
---@return boolean Success
function Skills.RemoveXp(Player, CharacterSkillId)
    if not Player or not Player:IsValid() or not Player.CharacterProgressionComponent:IsValid() then return false end

    Player.CharacterProgressionComponent:Server_RemoveAllXPFromSkill(CharacterSkillId)
    return true
end

---@param CharacterSkillId CharacterSkills|integer
---@return boolean Success
function Skills.RemoveXpFromMyPlayer(CharacterSkillId)
    return Skills.RemoveXp(AFUtils.GetMyPlayer(), CharacterSkillId)
end

return Skills