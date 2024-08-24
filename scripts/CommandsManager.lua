

require("Settings")
local AFUtils = require("AFUtils.AFUtils")

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

local function StructCommand(CommandNames, FeatureName, Description, Parameters)
    if type(CommandNames) == "string" then
        CommandNames = { CommandNames }
    end
    if type(CommandNames) ~= "table" then
        error('StructCommand: Invalid "CommandNames" parameter')
    end
    if not FeatureName then
        error('StructCommand: Invalid "FeatureName" parameter')
    end
    Description = Description or ""
    Parameters = Parameters or ""
    return {
        Aliases = CommandNames,
        Name = FeatureName,
        Description = Description,
        Parameters = Parameters
    }
end

local Commands = {
    Help = StructCommand("help", "Help", "Shows mod details and possible commands"),
    -- GodMode = StructCommand({"god", "godmode"}, "God Mode", "Makes the player invincible and keeps all his stats at maximum (Health, Stamina, Hunger, Thirst, Fatigue, Continence)"),
    Heal = StructCommand({"heal"}, "Heal", "Player gets fully healed"),
    InfiniteHealth = StructCommand({"health", "hp", "infhp", "infhealth"}, "Infinite Health", "Player gets fully healed and becomes invincible"),
    InfiniteStamina = StructCommand({"stamina", "sp", "infsp", "infstamina"}, "Infinite Stamina", "Player won't consume stamina"),
    NoHunger = StructCommand({"hunger", "nohunger", "eat"}, "No Hunger", "Player won't be hungry"),
    NoThirst = StructCommand({"thirst", "nothirst", "drink"}, "No Thirst", "Player won't be Ttirsty"),
    NoFatigue = StructCommand({"fat", "nofat", "fatigue", "nofatigue", "sleep"}, "No Fatigue", "Player won't be tired"),
    NoContinence = StructCommand({"con", "nocon", "continence", "nocontinence", "wc"}, "No Continence", "Player won't need to go to the toilet"),
    Money = StructCommand({"money"}, "Set Money", "Set money to desired value", "value"),
    FreeCrafting = StructCommand({"freecraft", "freecrafting", "crafting", "craft"}, "Free Crafting", "Allows player to craft all items and for free. (Warning: You will have to rejoin the game after disabling!)"),
    NoFallDamage = StructCommand({"falldmg", "falldamage", "nofall", "nofalldmg", "nofalldamage"}, "No Fall Damage", "Prevets player from taking fall damage"),
    NoClip = StructCommand({"noclip", "ghost"}, "No Clip", "Disables player's collision and makes him fly"),
}

function PrintCommansAaMarkdownTable()
    local function GetCommandAlias(Command)
        local result = ""
        for i, alias in ipairs(Command.Aliases) do
           if i > 1 then
            result = result .. " \\| "
           end 
           result = result .. alias
        end
        return result
    end

    print("------- Markdown Table -----------")
    print("Command | Aliases | Parameters | Description")
    print("------- | ------- | ---------- | -----------")
    for _, command in pairs(Commands) do
        print(string.format("%s | %s | %s | %s", command.Name, GetCommandAlias(command), command.Parameters, command.Description))
    end
    print("----------------------------------")
end

local function RegisterConsoleCommand(Command, Callback)
    if type(Command) == "table" and Command.Aliases and type(Callback) == "function" then
        for _, commandName in ipairs(Command.Aliases) do
            if type(commandName) == "string" then
                RegisterConsoleCommandGlobalHandler (commandName, Callback)
                LogDebug("RegisterConsoleCommand: Registered command: " .. commandName)
            end
        end 
    else
        LogError("RegisterConsoleCommand: Failed to register: " .. Command.Name)
    end
end 

---
---@param State boolean
---@param CommandName string
---@param OutputDevice FOutputDevice
local function PrintCommandState(State, CommandName, OutputDevice)
    local stateText = CommandName .. " "
    if State then
        stateText = stateText .. "Enabled"
    else
        stateText = stateText .. "Disabled"
    end
    WriteToConsoleDebug(OutputDevice, stateText)
end

-- Help Command
local function HelpCommand(FullCommand, Parameters, OutputDevice)
    local function GetCommandAlias(Command)
        local result = ""
        for i, alias in ipairs(Command.Aliases) do
           if i > 1 then
            result = result .. " | "
           end 
           result = result .. alias
        end
        return result
    end
    WriteToConsole(OutputDevice, ModName .. " list:")
    for _, command in pairs(Commands) do
        WriteToConsole(OutputDevice, "------------------------------")
        WriteToConsole(OutputDevice, "Command: " .. command.Name)
        WriteToConsole(OutputDevice, "Aliases: " .. GetCommandAlias(command))
        if command.Parameters and command.Parameters ~= "" then
            WriteToConsole(OutputDevice, "Parameters: " .. command.Parameters)
        end
        WriteToConsole(OutputDevice, "Description: " .. command.Description)
    end
    WriteToConsole(OutputDevice, "------------------------------")

    return true
end
RegisterConsoleCommand(Commands.Help, HelpCommand)

-- GodMode Command
-- local function GodModeCommand(FullCommand, Parameters, OutputDevice)
--     Settings.GodMode = not Settings.GodMode
--     PrintCommandState(Settings.GodMode, Commands.GodMode.Name, OutputDevice)
--     return true
-- end
-- RegisterConsoleCommand(Commands.GodMode, GodModeCommand)

-- Heal Command
local function HealCommand(FullCommand, Parameters, OutputDevice)
    Settings.Heal = true
    WriteToConsole(OutputDevice, "Healing player")
    return true
end
RegisterConsoleCommand(Commands.Heal, HealCommand)

-- InfiniteHealth Command
local function InfiniteHealthCommand(FullCommand, Parameters, OutputDevice)
    Settings.InfiniteHealth = not Settings.InfiniteHealth
    PrintCommandState(Settings.InfiniteHealth, Commands.InfiniteHealth.Name, OutputDevice)
    return true
end
RegisterConsoleCommand(Commands.InfiniteHealth, InfiniteHealthCommand)

-- InfiniteStamina Command
local function InfiniteStaminaCommand(FullCommand, Parameters, OutputDevice)
    Settings.InfiniteStamina = not Settings.InfiniteStamina
    PrintCommandState(Settings.InfiniteStamina, Commands.InfiniteStamina.Name, OutputDevice)
    return true
end
RegisterConsoleCommand(Commands.InfiniteStamina, InfiniteStaminaCommand)

-- NoHunger Command
local function NoHungerCommand(FullCommand, Parameters, OutputDevice)
    Settings.NoHunger = not Settings.NoHunger
    PrintCommandState(Settings.NoHunger, Commands.NoHunger.Name, OutputDevice)
    return true
end
RegisterConsoleCommand(Commands.NoHunger, NoHungerCommand)

-- NoThirst Command
local function NoThirstCommand(FullCommand, Parameters, OutputDevice)
    Settings.NoThirst = not Settings.NoThirst
    PrintCommandState(Settings.NoThirst, Commands.NoThirst.Name, OutputDevice)
    return true
end
RegisterConsoleCommand(Commands.NoThirst, NoThirstCommand)

-- NoFatigue Command
local function NoFatigueCommand(FullCommand, Parameters, OutputDevice)
    Settings.NoFatigue = not Settings.NoFatigue
    PrintCommandState(Settings.NoFatigue, Commands.NoFatigue.Name, OutputDevice)
    return true
end
RegisterConsoleCommand(Commands.NoFatigue, NoFatigueCommand)

-- NoContinence Command
local function NoContinenceCommand(FullCommand, Parameters, OutputDevice)
    Settings.NoContinence = not Settings.NoContinence
    PrintCommandState(Settings.NoContinence, Commands.NoContinence.Name, OutputDevice)
    return true
end
RegisterConsoleCommand(Commands.NoContinence, NoContinenceCommand)

-- FreeCrafting Command
local function FreeCraftingCommand(FullCommand, Parameters, OutputDevice)
    Settings.FreeCrafting = not Settings.FreeCrafting
    PrintCommandState(Settings.FreeCrafting, Commands.FreeCrafting.Name, OutputDevice)
    return true
end
RegisterConsoleCommand(Commands.FreeCrafting, FreeCraftingCommand)

-- NoFallDamage Command
local function NoFallDamageCommand(FullCommand, Parameters, OutputDevice)
    Settings.NoFallDamage = not Settings.NoFallDamage
    PrintCommandState(Settings.NoFallDamage, Commands.NoFallDamage.Name, OutputDevice)
    return true
end
RegisterConsoleCommand(Commands.NoFallDamage, NoFallDamageCommand)

-- NoClip Command
local function NoClipCommand(FullCommand, Parameters, OutputDevice)
    Settings.NoClip = not Settings.NoClip
    PrintCommandState(Settings.NoClip, Commands.NoClip.Name, OutputDevice)
    return true
end
RegisterConsoleCommand(Commands.NoClip, NoClipCommand)

-- Set Money Command
local function MoneyCommand(FullCommand, Parameters, OutputDevice)
    local moneyValue = nil
    if #Parameters > 0 then
        moneyValue = tonumber(Parameters[1])
    end
    if type(moneyValue) ~= "number" then
        WriteToConsole(OutputDevice, Commands.Money.Name..": Missing parameter")
        WriteToConsole(OutputDevice, Commands.Money.Name..': It must be: "money {value}"')
        return true
    end
    local intMax = 2147483647
    if moneyValue < 0 or moneyValue >= intMax then
        WriteToConsole(OutputDevice, Commands.Money.Name..": Invalid money value!")
        WriteToConsole(OutputDevice, Commands.Money.Name..': The value must be between 0 and "' .. intMax)
        return true
    end

    Settings.SetMoney = true
    Settings.MoneyValue = moneyValue
    WriteToConsole(OutputDevice, "Execute " .. Commands.Money.Name .. " command with value: " .. Settings.MoneyValue)
    return true
end
RegisterConsoleCommand(Commands.Money, MoneyCommand)

