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
ModVersion = "1.9.0"
DebugMode = true
IsModEnabled = true

LogInfo("Starting mod initialization")
require("Features")
require("CommandsManager") -- Executes CommandsManager functions
local SettingsManager = require("SettingsManager")
SettingsManager.LoadFromFile()

-- Main loop
LoopAsync(250, function()
    ExecuteInGameThread(function() 
        local myPlayer = AFUtils.GetMyPlayer()
        if myPlayer then
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
            Invisible(myPlayer)
            NoFallDamage(myPlayer)
            NoClip(myPlayer)
            NoRecoil(myPlayer)
            NoSway(myPlayer)
            MasterKey(myPlayer)
            Speedhack(myPlayer)
            PlayerGravityScale(myPlayer)
            SetLeyakCooldown()
            DistantShore(myPlayer)
        end
    end)
    SettingsManager.AutoSaveOnChange()
    return false
end)

-- if DebugMode then
--     LogCommandsAsMarkdownTable()
--     LogCommandsAsBBCode()
-- end

LogInfo("Mod loaded successfully")
