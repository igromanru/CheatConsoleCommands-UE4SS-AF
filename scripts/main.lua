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
DebugMode = false

LogInfo("Starting mod initialization")
require("Features")
require("CommandsManager") -- Executes CommandsManager functions

-- Main loop
LoopAsync(500, function()
    ExecuteInGameThread(function() 
        local myPlayer = AFUtils.GetMyPlayer()
        if myPlayer then
            Heal(myPlayer)
            InfiniteHealth(myPlayer)
            InfiniteStamina(myPlayer)
            InfiniteDurability(myPlayer)
            InfiniteEnergy(myPlayer)
            NoHunger(myPlayer)
            NoThirst(myPlayer)
            NoFatigue(myPlayer)
            NoContinence(myPlayer)
            NoRadiation(myPlayer)
            FreeCrafting(myPlayer)
            NoFallDamage(myPlayer)
            NoClip(myPlayer)
            SetMoney(myPlayer)
            NoRecoil(myPlayer)
            NoSway(myPlayer)
            SetLeyakCooldown()
        end
    end)
    return false
end)

-- if DebugMode then
--     -- PrintCommansAaMarkdownTable()
--     PrintCommansAaBBCode()
-- end

LogInfo("Mod loaded successfully")
