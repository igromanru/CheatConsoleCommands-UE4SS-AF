

local AFUtils = require("AFUtils.AFUtils")
local Settings = require("Settings")

---@class CommandStruct
---@field Aliases table
---@field Name string
---@field Description string
---@field Parameters string
---@field Function function
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
        Parameters = Parameters,
        Function = nil
    }
end

local Commands = {
    Help = CreateCommand("help", "Help", "Shows mod details and possible commands"),
    GodMode = CreateCommand({"god", "godmode"}, "God Mode", "Makes the player invincible and keeps all his stats at maximum (Health, Stamina, Hunger, Thirst, Fatigue, Continence)"),
    Heal = CreateCommand({"heal"}, "Heal", "Player gets fully healed once"),
    InfiniteHealth = CreateCommand({"health", "hp", "inv", "infhp", "infhealth"}, "Infinite Health", "Player gets fully healed and becomes invincible"),
    InfiniteStamina = CreateCommand({"stamina", "sp", "infsp", "infstamina"}, "Infinite Stamina", "Player won't consume stamina"),
    InfiniteDurability = CreateCommand({"durability", "infdur"}, "Infinite Durability", "Player's Held Item won't lose durability"),
    InfiniteEnergy = CreateCommand({"energy", "infenergy"}, "Infinite Energy", "Player's Held Item won't lose charge"),
    NoHunger = CreateCommand({"hunger", "nohunger", "eat"}, "No Hunger", "Player won't be hungry"),
    NoThirst = CreateCommand({"thirst", "nothirst", "drink"}, "No Thirst", "Player won't be Ttirsty"),
    NoFatigue = CreateCommand({"fat", "nofat", "fatigue", "nofatigue", "tired"}, "No Fatigue", "Player won't be tired"),
    NoContinence = CreateCommand({"con", "nocon", "continence", "nocontinence", "wc"}, "No Continence", "Player won't need to go to the toilet"),
    NoRadiation = CreateCommand({"rad", "norad", "radiation", "noradiation"}, "No Radiation", "Player can't receive radiation"),
    Money = CreateCommand({"money"}, "Set Money", "Set money to desired value", "value"),
    FreeCrafting = CreateCommand({"freecraft", "freecrafting", "crafting", "craft"}, "Free Crafting", "Allows player to craft all items and for free. (Warning: Might require to rejoin the game to disable completly!)"),
    NoFallDamage = CreateCommand({"falldmg", "falldamage", "nofall", "nofalldmg", "nofalldamage"}, "No Fall Damage", "Prevets player from taking fall damage"),
    NoClip = CreateCommand({"noclip", "clip", "ghost"}, "No Clip", "Disables player's collision and makes him fly"),
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
Commands.Help.Function = function(Parameters, OutputDevice)
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

-- GodMode Command
Commands.GodMode.Function = function(Parameters, OutputDevice)
    Settings.GodMode = not Settings.GodMode
    PrintCommandState(Settings.GodMode, Commands.GodMode.Name, OutputDevice)
    return true
end

-- Heal Command
Commands.Heal.Function = function(Parameters, OutputDevice)
    Settings.Heal = true
    WriteToConsole(OutputDevice, "Healing player")
    return true
end

-- InfiniteHealth Command
Commands.InfiniteHealth.Function = function(Parameters, OutputDevice)
    Settings.InfiniteHealth = not Settings.InfiniteHealth
    PrintCommandState(Settings.InfiniteHealth, Commands.InfiniteHealth.Name, OutputDevice)
    return true
end

-- InfiniteStamina Command
Commands.InfiniteStamina.Function = function(Parameters, OutputDevice)
    Settings.InfiniteStamina = not Settings.InfiniteStamina
    PrintCommandState(Settings.InfiniteStamina, Commands.InfiniteStamina.Name, OutputDevice)
    return true
end

-- InfiniteDurability Command
Commands.InfiniteDurability.Function = function(Parameters, OutputDevice)
    Settings.InfiniteDurability = not Settings.InfiniteDurability
    PrintCommandState(Settings.InfiniteDurability, Commands.InfiniteDurability.Name, OutputDevice)
    return true
end

-- InfiniteEnergy Command
Commands.InfiniteEnergy.Function = function(Parameters, OutputDevice)
    Settings.InfiniteEnergy = not Settings.InfiniteEnergy
    PrintCommandState(Settings.InfiniteEnergy, Commands.InfiniteEnergy.Name, OutputDevice)
    if Settings.InfiniteEnergy then
        WriteToConsole(OutputDevice, "Hint: When selecting a drained item, switch between it and something else once to fix it")
    end
    return true
end

-- NoHunger Command
Commands.NoHunger.Function = function(Parameters, OutputDevice)
    Settings.NoHunger = not Settings.NoHunger
    PrintCommandState(Settings.NoHunger, Commands.NoHunger.Name, OutputDevice)
    return true
end

-- NoThirst Command
Commands.NoThirst.Function = function(Parameters, OutputDevice)
    Settings.NoThirst = not Settings.NoThirst
    PrintCommandState(Settings.NoThirst, Commands.NoThirst.Name, OutputDevice)
    return true
end

-- NoFatigue Command
Commands.NoFatigue.Function = function(Parameters, OutputDevice)
    Settings.NoFatigue = not Settings.NoFatigue
    PrintCommandState(Settings.NoFatigue, Commands.NoFatigue.Name, OutputDevice)
    return true
end

-- NoContinence Command
Commands.NoContinence.Function = function(Parameters, OutputDevice)
    Settings.NoContinence = not Settings.NoContinence
    PrintCommandState(Settings.NoContinence, Commands.NoContinence.Name, OutputDevice)
    return true
end

-- NoRadiation Command
Commands.NoRadiation.Function = function(Parameters, OutputDevice)
    Settings.NoRadiation = not Settings.NoRadiation
    PrintCommandState(Settings.NoRadiation, Commands.NoRadiation.Name, OutputDevice)
    return true
end

-- FreeCrafting Command
Commands.FreeCrafting.Function = function(Parameters, OutputDevice)
    Settings.FreeCrafting = not Settings.FreeCrafting
    PrintCommandState(Settings.FreeCrafting, Commands.FreeCrafting.Name, OutputDevice)
    return true
end

-- NoFallDamage Command
Commands.NoFallDamage.Function = function(Parameters, OutputDevice)
    Settings.NoFallDamage = not Settings.NoFallDamage
    PrintCommandState(Settings.NoFallDamage, Commands.NoFallDamage.Name, OutputDevice)
    return true
end

-- NoClip Command
Commands.NoClip.Function = function(Parameters, OutputDevice)
    Settings.NoClip = not Settings.NoClip
    PrintCommandState(Settings.NoClip, Commands.NoClip.Name, OutputDevice)
    return true
end

-- Set Money Command
Commands.Money.Function = function(Parameters, OutputDevice)
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

local function MatchCommand(Command, Aliases)
    if type(Aliases) == "string" then
        Aliases = { Aliases }
    end
    for _, alias in ipairs(Aliases) do
        if alias == Command then
            return true
        end
    end
    return false
end

local AbioticGameViewportClientClass = nil
local function GetClassAbioticGameViewportClient()
    if not AbioticGameViewportClientClass then
        AbioticGameViewportClientClass = StaticFindObject("/Script/AbioticFactor.AbioticGameViewportClient")
    end
    return AbioticGameViewportClientClass
end

RegisterProcessConsoleExecPreHook(function(Context, Command, Parameters, OutputDevice, Executor)
    local context = Context:get()
    local executor = Executor:get()

    local command = string.match(Command, "^%S+")
    -- if DebugMode then
    --     LogDebug("[ProcessConsoleExec]:")
    --     LogDebug("Context: " .. context:GetFullName())
    --     LogDebug("Context.Class: " .. context:GetClass():GetFullName())
    --     LogDebug("Command: " .. Command)
    --     LogDebug("Parameters: " .. #Parameters)
    --     if executor:IsValid() then
    --         LogDebug("Executor: " .. executor:GetClass():GetFullName())
    --     end
    -- end

    -- Special handling of default commands
    if Command == "god" or Command == "ghost" or Command == "fly" then
        LogDebug("Default command, skipping")
        return nil
    end

    for _, commandObj in pairs(Commands) do
        if MatchCommand(command, commandObj.Aliases) then
            -- LogDebug("Found match: " .. command .. ", Command.Name: " .. commandObj.Name)
            if context:IsA(GetClassAbioticGameViewportClient()) then
                if commandObj.Function then
                    LogDebug("Executing " .. commandObj.Name .. "'s function")
                    return commandObj.Function(Parameters, OutputDevice)
                end
            end
            return true
        end
    end
    LogDebug("------------------------")

    return nil
end)

-- Overwriting default UE commands (most aren't made for the game and causes issues)
------------------------------------------------------------
RegisterConsoleCommandGlobalHandler("god", function(FullCommand, Parameters, OutputDevice)
    if Commands.GodMode.Function then
        Commands.GodMode.Function(Parameters, OutputDevice)
    end
    return true
end)

RegisterConsoleCommandGlobalHandler("ghost", function(FullCommand, Parameters, OutputDevice)
    if Commands.NoClip.Function then
        Commands.NoClip.Function(Parameters, OutputDevice)
    end
    return true
end)

RegisterConsoleCommandGlobalHandler("fly", function(FullCommand, Parameters, OutputDevice)
    if Commands.NoClip.Function then
        Commands.NoClip.Function(Parameters, OutputDevice)
    end
    return true
end)

RegisterConsoleCommandGlobalHandler("changesize", function(FullCommand, Parameters, OutputDevice)
    WriteToConsoleDebug(OutputDevice, 'Use "noclip", if you\'re stuck')
    return false
end)