

local AFUtils = require("AFUtils.AFUtils")
local Settings = require("Settings")

---@class CommandStruct
---@field Aliases {}
---@field Name string
---@field Description string
---@field Parameters string
local CommandStruct = {}

---Write to lua console and the OutputDevice
---@param OutputDevice FOutputDevice
---@param Message string
local function WriteToConsole(OutputDevice, Message)
    LogInfo(Message)
    if OutputDevice then
        OutputDevice:Log(Message)
    end
end

---Write to lua console and the OutputDevice only in DebugMode
---@param OutputDevice FOutputDevice
---@param Message string
local function WriteToConsoleDebug(OutputDevice, Message)
    if DebugMode then
        LogInfo(Message)
        if OutputDevice then
            OutputDevice:Log(Message)
        end
    end
end

local function AliasToString(Alias)
    if type(Alias) == "string" then
        return Alias
    end

    if type(Alias) ~= "table" then
        return "ERROR"
    end

    local result = ""
    for _, alias in ipairs(Alias) do
       if result ~= "" then
        result = result .. " | "
       end 
       result = result .. alias
    end
    return result
end

local function GetCommandAlias(Command)
    return AliasToString(Command.Aliases)
end

---Creats a new CommandStruct out of parameters
---@param CommandNames string|array
---@param FeatureName string
---@param Description string?
---@param Parameters string?
---@return CommandStruct
local function CreateCommand(CommandNames, FeatureName, Description, Parameters)
    if type(CommandNames) == "string" then
        CommandNames = { CommandNames }
    end
    if type(CommandNames) ~= "table" then
        error('CreateCommand: Invalid "CommandNames" parameter')
    end
    if not FeatureName then
        error('CreateCommand: Invalid "FeatureName" parameter')
    end
    Description = Description or ""
    Parameters = Parameters or ""
    LogDebug("CreateCommand: Aliases type: " .. AliasToString(CommandNames) .. ", Name: " .. FeatureName .. ", Description: " .. Description .. ", Parameters: " .. Parameters)
    return {
        Aliases = CommandNames,
        Name = FeatureName,
        Description = Description,
        Parameters = Parameters
    }
end

local Commands = {
    Help = CreateCommand("help", "Help", "Shows mod details and possible commands"),
    -- GodMode = StructCommand({"god", "godmode"}, "God Mode", "Makes the player invincible and keeps all his stats at maximum (Health, Stamina, Hunger, Thirst, Fatigue, Continence)"),
    Heal = CreateCommand({"heal"}, "Heal", "Player gets fully healed once"),
    InfiniteHealth = CreateCommand({"health", "hp", "inv", "infhp", "infhealth"}, "Infinite Health", "Player gets fully healed and becomes invincible"),
    InfiniteStamina = CreateCommand({"stamina", "sp", "infsp", "infstamina"}, "Infinite Stamina", "Player won't consume stamina"),
    InfiniteDurability = CreateCommand({"durability", "infdur"}, "Infinite Durability", "Player's Held Item won't lose durability"),
    InfiniteEnergy = CreateCommand({"energy", "infenergy"}, "Infinite Energy", "Player's Held Item won't lose charge"),
    NoHunger = CreateCommand({"hunger", "nohunger", "eat"}, "No Hunger", "Player won't be hungry"),
    NoThirst = CreateCommand({"thirst", "nothirst", "drink"}, "No Thirst", "Player won't be Ttirsty"),
    NoFatigue = CreateCommand({"nofat", "fatigue", "nofatigue", "tired"}, "No Fatigue", "Player won't be tired"),
    NoContinence = CreateCommand({"nocon", "continence", "nocontinence", "wc"}, "No Continence", "Player won't need to go to the toilet"),
    NoRadiation = CreateCommand({"rad", "norad", "radiation", "noradiation"}, "No Radiation", "Player can't receive radiation"),
    Money = CreateCommand({"money"}, "Set Money", "Set money to desired value", "value"),
    FreeCrafting = CreateCommand({"freecraft", "freecrafting", "crafting", "craft"}, "Free Crafting", "Allows player to craft all items and for free. (Warning: Might require to rejoin the game to disable completly!)"),
    NoFallDamage = CreateCommand({"falldmg", "falldamage", "nofall", "nofalldmg", "nofalldamage"}, "No Fall Damage", "Prevets player from taking fall damage"),
    NoClip = CreateCommand({"noclip", "ghost"}, "No Clip", "Disables player's collision and makes him fly"),
}

function PrintCommansAaMarkdownTable()
    local function GetCommandAliasForTable(Command)
        local result = ""
        for _, alias in ipairs(Command.Aliases) do
           if result ~= "" then
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
        print(string.format("%s | %s | %s | %s", command.Name, GetCommandAliasForTable(command), command.Parameters, command.Description))
    end
    print("----------------------------------")
end

local ConsoleCommandRegistrationsCount = 0
---Registers a ConsoleCommandGlobalHandler for each alias of a command
---@param Command CommandStruct
---@param Callback function
local function RegisterConsoleCommand(Command, Callback)
    if type(Command) == "table" and type(Command.Aliases) == "table" and type(Callback) == "function" then
        -- LogDebug('RegisterConsoleCommand: ' .. Command.Name .. ' command, aliases to register: ' .. AliasToString(Command.Aliases))
        local aliases = ""
        for _, commandName in ipairs(Command.Aliases) do
            if type(commandName) == "string" then
                RegisterConsoleCommandGlobalHandler(commandName, Callback)
                -- RegisterConsoleCommandHandler(commandName, Callback)
                ConsoleCommandRegistrationsCount = ConsoleCommandRegistrationsCount + 1
                if aliases ~= nil then
                    aliases = aliases .. ", "
                end
                aliases = aliases .. commandName
            else
                error("RegisterConsoleCommand: alias has the wrong type: " .. type(commandName))
            end
        end 
        LogInfo('Registered command "' .. Command.Name .. '" with aliases: ' .. aliases)
    else
        error("RegisterConsoleCommand: Failed to register command: " .. Command.Name)
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
    WriteToConsole(OutputDevice, stateText)
end

-- Help Command
local function HelpCommand(FullCommand, Parameters, OutputDevice)
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

-- InfiniteDurability Command
local function InfiniteDurabilityCommand(FullCommand, Parameters, OutputDevice)
    Settings.InfiniteDurability = not Settings.InfiniteDurability
    PrintCommandState(Settings.InfiniteDurability, Commands.InfiniteDurability.Name, OutputDevice)
    return true
end
RegisterConsoleCommand(Commands.InfiniteDurability, InfiniteDurabilityCommand)

-- InfiniteEnergy Command
local function InfiniteEnergyCommand(FullCommand, Parameters, OutputDevice)
    Settings.InfiniteEnergy = not Settings.InfiniteEnergy
    PrintCommandState(Settings.InfiniteEnergy, Commands.InfiniteEnergy.Name, OutputDevice)
    return true
end
RegisterConsoleCommand(Commands.InfiniteEnergy, InfiniteEnergyCommand)

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

-- NoRadiation Command
local function NoRadiationCommand(FullCommand, Parameters, OutputDevice)
    Settings.NoRadiation = not Settings.NoRadiation
    PrintCommandState(Settings.NoRadiation, Commands.NoRadiation.Name, OutputDevice)
    return true
end
RegisterConsoleCommand(Commands.NoRadiation, NoRadiationCommand)

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

LogDebug("Console Command Registrations Count: " .. ConsoleCommandRegistrationsCount)
