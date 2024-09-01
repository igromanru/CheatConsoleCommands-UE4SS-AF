
local AFUtils = require("AFUtils.AFUtils")

local PlayersManager = {}

---@return string[] PlayerNames
function PlayersManager.GetPlayerNames()
    local playerList = {}

    local gameState = AFUtils.GetSurvivalGameState()
    if gameState and gameState.PlayerArray then
        for i = 1, #gameState.PlayerArray, 1 do
            local playerState = gameState.PlayerArray[i]
            if playerState:IsValid() then
                table.insert(playerList, playerState.PlayerNamePrivate:ToString())
            end
        end
    end

    return playerList
end

---@param Name string Full or part of player's name
---@return AAbiotic_PlayerCharacter_C?, string # Player and player name
function PlayersManager.GetPlayerByName(Name)
    local gameState = AFUtils.GetSurvivalGameState()
    if gameState and gameState.PlayerArray then
        for i = 1, #gameState.PlayerArray, 1 do
            local playerState = gameState.PlayerArray[i]
            if playerState:IsValid() and playerState.PawnPrivate:IsValid() then
                local playerName = playerState.PlayerNamePrivate:ToString()
                local startIndex = string.find(string.lower(playerName), string.lower(Name))
                if startIndex and startIndex > 0 then
                    return playerState.PawnPrivate, playerName
                end
            end
        end
    end
    return nil, ""
end

---@param index integer # Lua array index. Can't be smaller than 1
---@return AAbiotic_PlayerCharacter_C?, string # Player and player name
function PlayersManager.GetPlayerByIndex(index)
    if type(index) ~="number" or index < 1 then return nil end

    local gameState = AFUtils.GetSurvivalGameState()
    if gameState and gameState.PlayerArray and index <= #gameState.PlayerArray then
        local playerState = gameState.PlayerArray[index]
        if playerState:IsValid() and playerState.PawnPrivate:IsValid() then
            return playerState.PawnPrivate, playerState.PlayerNamePrivate:ToString()
        end
    end
    return nil, ""
end

return PlayersManager