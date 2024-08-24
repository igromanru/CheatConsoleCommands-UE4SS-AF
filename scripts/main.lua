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

-- Main loop
LoopAsync(1000, function()
    GodMode()
    NoClip()
end)

LogInfo("Mod loaded successfully")
