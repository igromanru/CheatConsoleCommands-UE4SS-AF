

require("Settings")
local AFUtils = require("AFUtils.AFUtils")

local MainCommand = "cheat"

---Write to lua console and the OutputDevice
---@param OutputDevice FOutputDevice
---@param Message string
function WriteToConsole(OutputDevice, Message)
    LogInfo(Message)
    if OutputDevice then
        OutputDevice:Log(Message)
    end
end

---Write to lua console and the OutputDevice only in DebugMode
---@param OutputDevice FOutputDevice
---@param Message string
function WriteToConsoleDebug(OutputDevice, Message)
    if DebugMode then
        LogInfo(Message)
        if OutputDevice then
            OutputDevice:Log(Message)
        end
    end
end

local function StructCommand(CommandNames, FeatureName, Description)
    if type(CommandNames) == "string" then
        CommandNames = { CommandNames }
    end
    return {
        CommandNames = CommandNames,
        Name = FeatureName,
        Description = Description
    }
end

local Commands = {
    Help = StructCommand("help", "Help", "Shows mod details and possible commands"),
    God = StructCommand({"god", "godmode"}, "God Mode", "Makes the player invincible and keeps all his stats at maximum (Health, Stamina, Hunger, Thirst, Fatigue, Continence)"),
    InfiniteHealth = StructCommand({"health", "infhp", "infhealth"}, "Infinite Health", "Infinite Health"),
    InfiniteStamina = StructCommand({"stamina", "infsp", "infstamina"}, "Infinite Stamina", "Infinite Stamina"),
    NoHunger = StructCommand({"hunger", "nohunger"}, "No Hunger", "No Hunger"),
    NoThirst = StructCommand({"thirst", "nothirst"}, "No Thirst", "No Thirst"),
    NoFatigue = StructCommand({"fat", "fatigue", "nofatigue"}, "No Fatigue", "No Fatigue"),
    NoContinence = StructCommand({"con", "continence", "nocontinence"}, "No Continence", "No Continence"),
    Money = StructCommand({"money"}, "Set Money"),
    FreeCrafting = StructCommand({"freecraft", "freecrafting", "crafting"}, "Free Crafting", "Free Crafting"),
    NoFallDamage = StructCommand({"falldmg", "falldamage", "nofall", "nofalldmg", "nofalldamage"}, "No Fall Damage", "No Fall Damage"),
    NoClip = StructCommand({"noclip"}, "No Clip", "Disables player's collision and makes him fly"),
}

local function RegisterConsoleCommand(Command, Callback)
    if type(Command) == "table" and Command.CommandNames and type(Callback) == "function" then
        for _, commandName in ipairs(Command.CommandNames) do
            if type(commandName) == "string" then
                RegisterConsoleCommandHandler(commandName, Callback)
                LogDebug("RegisterConsoleCommand: Registered command: "..commandName)
            end
        end 
    else
        LogError("RegisterConsoleCommand: Failed to register: "..Command)
    end
end 

---comment
---@param State boolean
---@param CommandName string
---@param OutputDevice FOutputDevice
local function PrintCommandState(State, CommandName, OutputDevice)
    local stateText = CommandName .. " was "
    if State then
        stateText = stateText .. "Enabled"
    else
        stateText = stateText .. "Disabled"
    end
    LogDebug(stateText)
    OutputDevice:Log(stateText)
end

local function MatchCommand(Command, Parameters)
    local parameter = Parameters[1]
    for i, value in ipairs(Command.CommandNames) do
        if parameter == value then
            return true
        end
    end
    return false
end

-- Help Command
local function HelpCommand(Parameters, OutputDevice)
    if MatchCommand(Commands.Help, Parameters) then
        WriteToConsoleDebug("Help called", OutputDevice)
        return true
    end
    return false
end

-- NoClip Command
local function NoClipCommand(Parameters, OutputDevice)
    if MatchCommand(Commands.NoClip, Parameters) then
        Settings.NoClip = not Settings.NoClip
        WriteToConsoleDebug("NoClip: " .. tostring(Settings.NoClip), OutputDevice)
        return true
    end
    return false
end


-- RegisterConsoleCommandGlobalHandler("god", function(FullCommand, Parameters, OutputDevice)
--     LogDebug("[ConsoleCommandGlobalHandler] god:")
--     LogDebug("FullCommand: " .. FullCommand)
--     LogDebug("Parameters count: " .. #Parameters)
--     for i, value in ipairs(Parameters) do
--         LogDebug(i .. ": " .. value)
--     end
--     LogDebug("OutputDevice: " .. OutputDevice:type())
--     LogDebug("------------------------------")

--     return true
-- end)

-- RegisterConsoleCommandHandler(Settings.ModCommand, function(FullCommand, Parameters, OutputDevice)
--     if #Parameters < 1 then return false end

--     WriteToConsoleDebug("FullCommand: " .. FullCommand, OutputDevice)
--     WriteToConsoleDebug("Parameters count: " .. #Parameters, OutputDevice)
--     for i, value in ipairs(Parameters) do
--         LogDebug(i .. ": " .. value)
--     end
--     if HelpCommand(Parameters, OutputDevice) then
--     elseif NoClipCommand(Parameters, OutputDevice) then
--     end

--     return true
-- end)
