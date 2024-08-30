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
ModVersion = "1.3.0"
DebugMode = true
IsModEnabled = true

LogInfo("Starting mod initialization")
require("Features")
require("CommandsManager") -- Executes CommandsManager functions

-- Main loop
LoopAsync(250, function()
    ExecuteInGameThread(function() 
        local myPlayer = AFUtils.GetMyPlayer()
        if myPlayer then
            Heal(myPlayer)
            InfiniteHealth(myPlayer)
            InfiniteStamina(myPlayer)
            InfiniteDurability(myPlayer)
            InfiniteEnergy(myPlayer)
            InfiniteAmmo(myPlayer)
            NoHunger(myPlayer)
            NoThirst(myPlayer)
            NoFatigue(myPlayer)
            InfiniteContinence(myPlayer)
            LowContinence(myPlayer)
            NoRadiation(myPlayer)
            FreeCrafting(myPlayer)
            NoFallDamage(myPlayer)
            NoClip(myPlayer)
            NoRecoil(myPlayer)
            NoSway(myPlayer)
        end
    end)
    return false
end)

-- if DebugMode then
--     PrintCommansAaMarkdownTable()
--     PrintCommansAaBBCode()
-- end

LogInfo("Mod loaded successfully")
