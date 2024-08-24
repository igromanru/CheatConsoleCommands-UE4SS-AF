--[[
    Author: Igromanru
    Date: 23.08.2024
    Mod Name: Cheat Console Commands
]]

------------------------------
-- Don't change code below --
------------------------------
local AFUtils = require("AFUtils.AFUtils")

ModName = "CheatConsoleCommands"
ModVersion = "1.0.0"
DebugMode = true

LogInfo("Starting mod initialization")
require("Settings")
require("Features")
require("CommandsManager") -- Execute CommandsManager functions

local function IsAnyFeatureEnabled()
    if type(Settings) == "table" then
        for _, value in pairs(Settings) do
            if value == true then
                return true
            end
        end
    end

    return false
end

-- Main loop
LoopAsync(1000, function()
    if IsAnyFeatureEnabled() then
        ExecuteInGameThread(function() 
            local myPlayer = AFUtils.GetMyPlayer()
            if myPlayer then
                GodMode(myPlayer)
                InfiniteHealth(myPlayer)
                InfiniteStamina(myPlayer)
                NoHunger(myPlayer)
                NoThirst(myPlayer)
                NoFatigue(myPlayer)
                NoContinence(myPlayer)
                FreeCrafting(myPlayer)
                NoFallDamage(myPlayer)
                NoClip(myPlayer)
                SetMoney(myPlayer)
            end
        end)
    end
end)

if DebugMode then
    PrintCommansAaMarkdownTable()
end

LogInfo("Mod loaded successfully")
