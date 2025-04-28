--[[
    Author: Igromanru
    Date: 23.08.2024
    Mod Name: Cheat Console Commands
]]

------------------------------
-- Don't change code below --
------------------------------
local AFUtils = require("AFUtils.AFUtils")
local UEHelpers = require("UEHelpers")

ModName = "CheatConsoleCommands"
ModVersion = "1.24.0"
DebugMode = true
IsModEnabled = true

-- ToDo
-- No Spore command
-- Item vacuum command

LogInfo("Starting mod initialization")
require("Features")
require("CommandsManager") -- Executes CommandsManager functions
local SettingsManager = require("SettingsManager")
SettingsManager.LoadFromFile()

if not IsModEnabled then
    LogInfo("Disabled with IsModEnabled")
    return
end

local function RemapConsoleKeys()
    local inputSettings = GetDefaultInputSettings()
    if IsValid(inputSettings) then
        local consoleKeys = inputSettings.ConsoleKeys
        local f10Name = UEHelpers.FindFName("F10")
        if f10Name ~= NAME_None then
            consoleKeys[1].KeyName = f10Name
        end
        local tildeName = UEHelpers.FindFName("Tilde")
        if tildeName ~= NAME_None then
            consoleKeys[2].KeyName = tildeName
        end
        if DebugMode then
            LogDebug("ConsoleKeys (" .. #consoleKeys .. "):")
            for i = 1, #consoleKeys do
                LogDebug(i .. ": " .. consoleKeys[i].KeyName:ToString())
            end
        end
    end
end
RemapConsoleKeys()

-- Main loop
LoopAsync(250, function()
    ExecuteInGameThread(function() 
        local myPlayer = AFUtils.GetMyPlayer()
        local isHost = IsHost()
        if IsValid(myPlayer) then
            local hasAuthority = myPlayer:HasAuthority()
            InfiniteHealth(myPlayer)
            HealthRegeneration(myPlayer)
            InfiniteStamina(myPlayer)
            InfiniteDurability(myPlayer)
            InfiniteEnergy(myPlayer, hasAuthority)
            NoOverheat(myPlayer, hasAuthority)
            InfiniteMaxWeight(myPlayer)
            NoHunger(myPlayer)
            NoThirst(myPlayer)
            NoFatigue(myPlayer)
            InfiniteContinence(myPlayer)
            LowContinence(myPlayer)
            NoRadiation(myPlayer)
            PerfectTemperature(myPlayer)
            InfiniteOxygen(myPlayer)
            FreeCrafting(myPlayer)
            InstantCrafting()
            Invisible(myPlayer, hasAuthority)
            NoFallDamage(myPlayer, hasAuthority)
            NoClip(myPlayer, hasAuthority)
            InfiniteAmmo(myPlayer)
            NoRecoil(myPlayer)
            NoSway(myPlayer)
            MasterKey(myPlayer)
            Speedhack(myPlayer, hasAuthority)
            PlayerGravityScale(myPlayer)
            InstantToilet(myPlayer)
            JournalEntryUnlocker()
            InstantFishing()
        end
        SetLeyakCooldown(isHost)
        InfiniteCrouchRoll()
        InstantPlantGrowth(isHost)
        InfiniteTraitPoints(isHost)
    end)
    SettingsManager.AutoSaveOnChange()
    return false
end)

-- if DebugMode then
--     LogCommandsAsMarkdownTable()
--     LogCommandsAsBBCode()
-- end

LogInfo("Mod loaded successfully")