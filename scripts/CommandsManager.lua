

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
    Help = CreateCommand("help", "Help", "Shows mod details and possible commands (host only)"),
    GodMode = CreateCommand({"god", "godmode"}, "God Mode", "Makes the player invincible and keeps all his stats at maximum (Health, Stamina, Hunger, Thirst, Fatigue, Continence)"),
    Heal = CreateCommand({"heal"}, "Heal", "Player gets fully healed once (host only)"),
    InfiniteHealth = CreateCommand({"health", "hp", "inv", "infhp", "infhealth"}, "Infinite Health", "Player gets fully healed and becomes invincible (host only)"),
    InfiniteStamina = CreateCommand({"stamina", "sp", "infsp", "infstamina"}, "Infinite Stamina", "Player won't consume stamina (host only)"),
    InfiniteDurability = CreateCommand({"durability", "infdurability", "infdur"}, "Infinite Durability", "Keeps player's gear and hotbar items durability at maximum (works as guest)"),
    InfiniteEnergy = CreateCommand({"energy", "infenergy"}, "Infinite Energy", "Keeps player's gear and held item charge/energy at maximum (host only)"),
    InfiniteAmmo = CreateCommand({"infammo", "ammo", "infiniteammo"}, "Infinite Ammo", "Keeps ammo of ranged weapons replenished (works as guest)"),
    NoHunger = CreateCommand({"hunger", "nohunger", "eat"}, "No Hunger", "Player won't be hungry (host only)"),
    NoThirst = CreateCommand({"thirst", "nothirst", "drink"}, "No Thirst", "Player won't be Thirsty (host only)"),
    NoFatigue = CreateCommand({"fat", "nofat", "fatigue", "nofatigue", "tired"}, "No Fatigue", "Player won't be tired (host only)"),
    InfiniteContinence = CreateCommand({"con", "infcon", "nocon", "continence", "nocontinence", "wc", "noneed", "constipation"}, "Infinite Continence", "Player won't need to go to the toilet (host only)"),
    NoRadiation = CreateCommand({"rad", "norad", "radiation", "noradiation"}, "No Radiation", "Player can't receive radiation (host only)"),
    Money = CreateCommand({"money"}, "Set Money", "Set money to desired value (works as guest)", "value"),
    FreeCrafting = CreateCommand({"freecraft", "freecrafting", "crafting", "craft"}, "Free Crafting", "Allows player to craft all items for free. (Warning: You may need to restart the game to deactivate it completely!) (host only)"),
    NoFallDamage = CreateCommand({"falldmg", "falldamage", "nofall", "nofalldmg", "nofalldamage"}, "No Fall Damage", "Prevents player from taking fall damage (host only)"),
    NoClip = CreateCommand({"noclip", "clip", "ghost"}, "No Clip", "Disables player's collision and makes him fly (host only)"),
    NoRecoil = CreateCommand({"norecoil", "recoil", "weaponnorecoil"}, "No Recoil", "Reduces weapon's fire recoil to minimum (haven't found a way to remove completely yet) (works as guest)"),
    NoSway = CreateCommand({"nosway", "sway", "noweaponsway"}, "No Sway", "Removes weapon's sway  (works as guest)"),
    LeyakCooldown = CreateCommand({"leyakcd", "leyakcooldown", "cdleyak"}, "Leyak Cooldown", "Changes Leyak's spawn cooldown in minutes (Default: 15min). The cooldown resets each time you reload/rehost the game, but the previous cooldown will be in effect until the next Leyak spawns. (host only)", "minutes")
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

function PrintCommansAaBBCode()
    local function GetCommandAliasForTable(Command)
        local result = ""
        for _, alias in ipairs(Command.Aliases) do
           if result ~= "" then
            result = result .. " | "
           end 
           result = result .. alias
        end
        return result
    end


    print("Command | Aliases | Parameters | Description")
    for _, command in pairs(Commands) do
        local parameters = ""
        if command.Parameters ~= "" then
            parameters = string.format(" %s ", command.Parameters)
        end
        print(string.format("[b]%s[/b] [ %s ] {%s} - [u]%s[/u]", command.Name, GetCommandAliasForTable(command), parameters, command.Description))
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
    WriteToConsole(OutputDevice, "God Mode is currently not implemented, use Infinite Health instead")
    -- Settings.GodMode = not Settings.GodMode
    -- PrintCommandState(Settings.GodMode, Commands.GodMode.Name, OutputDevice)
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
    return true
end

-- InfiniteAmmo Command
Commands.InfiniteAmmo.Function = function(Parameters, OutputDevice)
    Settings.InfiniteAmmo = not Settings.InfiniteAmmo
    PrintCommandState(Settings.InfiniteAmmo, Commands.InfiniteAmmo.Name, OutputDevice)
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

-- InfiniteContinence Command
Commands.InfiniteContinence.Function = function(Parameters, OutputDevice)
    Settings.InfiniteContinence = not Settings.InfiniteContinence
    PrintCommandState(Settings.InfiniteContinence, Commands.InfiniteContinence.Name, OutputDevice)
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

-- NoRecoil Command
Commands.NoRecoil.Function = function(Parameters, OutputDevice)
    Settings.NoRecoil = not Settings.NoRecoil
    PrintCommandState(Settings.NoRecoil, Commands.NoRecoil.Name, OutputDevice)
    return true
end

-- NoSway Command
Commands.NoSway.Function = function(Parameters, OutputDevice)
    Settings.NoSway = not Settings.NoSway
    PrintCommandState(Settings.NoSway, Commands.NoSway.Name, OutputDevice)
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
    if moneyValue < 0 or moneyValue >= 2147483647 then
        WriteToConsole(OutputDevice, Commands.Money.Name..": Invalid money value!")
        WriteToConsole(OutputDevice, Commands.Money.Name..': The value must be between 0 and 2147483647')
        return true
    end

    Settings.SetMoney = true
    Settings.MoneyValue = moneyValue
    WriteToConsole(OutputDevice, "Execute " .. Commands.Money.Name .. " command with value: " .. Settings.MoneyValue)
    return true
end

-- Set Leyak Cooldown Command
Commands.LeyakCooldown.Function = function(Parameters, OutputDevice)
    local cooldown = nil
    if #Parameters > 0 then
        cooldown = tonumber(Parameters[1])
    end
    if type(cooldown) ~= "number" then
        WriteToConsole(OutputDevice, Commands.LeyakCooldown.Name..": Missing parameter")
        WriteToConsole(OutputDevice, Commands.LeyakCooldown.Name..': It must be: "leyakcd {cooldown}"')
        return true
    end
    
    if cooldown < 0.1 or cooldown >= 525600000 then
        WriteToConsole(OutputDevice, Commands.LeyakCooldown.Name..": Invalid cooldown value!")
        WriteToConsole(OutputDevice, Commands.LeyakCooldown.Name..': The value must be between 0.1 and 525600000 (minutes)')
        return true
    end

    Settings.LeyakCooldownInMin = cooldown
    WriteToConsole(OutputDevice, "Execute " .. Commands.LeyakCooldown.Name .. " command with value: " .. Settings.LeyakCooldownInMin)
    return true
end

local function MatchCommand(Command, Aliases)
    if type(Aliases) == "string" then
        Aliases = { Aliases }
    end
    for _, alias in ipairs(Aliases) do
        if string.lower(alias) == string.lower(Command) then
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
                    return commandObj.Function(Parameters, OutputDevice)
                end
            end
            return true
        end
    end
    -- LogDebug("------------------------")

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