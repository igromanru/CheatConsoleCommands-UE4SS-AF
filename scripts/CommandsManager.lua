

local AFUtils = require("AFUtils.AFUtils")
local Settings = require("Settings")

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

---@alias CommandFunction fun(self: CommandStruct, OutputDevice: FOutputDevice, Parameters: table): boolean

---@class CommandStruct
---@field Aliases table<string>|string
---@field Name string
---@field Description string
---@field Parameters table<string>|string|nil
---@field Function CommandFunction?
local CommandStruct = {}

---@type table<CommandStruct>
local CommandsArray = {}

---@type { [string]: CommandStruct }
local CommandsMap = {}

---Creats a new CommandStruct out of parameters
---@param CommandNames table<string>|string
---@param FeatureName string
---@param Description string?
---@param Parameters table<string>|string|nil
---@param Callback CommandFunction?
local function CreateCommand(CommandNames, FeatureName, Description, Parameters, Callback)
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
    if type(Parameters) == "string" then
        Parameters = { Parameters }
    end
    local commandObject = {
        Aliases = CommandNames,
        Name = FeatureName,
        Description = Description,
        Parameters = Parameters,
        Function = Callback
    }
    table.insert(CommandsArray, commandObject)
    CommandsMap[FeatureName] = commandObject
end

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
    for _, command in ipairs(CommandsArray) do
        if command.Function then
            print(string.format("%s | %s | %s | %s", command.Name, GetCommandAliasForTable(command), command.Parameters, command.Description))
        end
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
           result = result .. "[font=Arial]" .. alias .. "[/font]"
        end
        return result
    end


    print("-- BBCode --")
    for _, command in ipairs(CommandsArray) do
        if command.Function then
            local parameters = ""
            if command.Parameters ~= "" then
                parameters = string.format(" %s ", command.Parameters)
            end
            print(string.format("[b]%s[/b] [ %s ] {%s} - [font=Georgia]%s[/font]", command.Name, GetCommandAliasForTable(command), parameters, command.Description))
        end
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
CreateCommand("help", "Help", "Shows mod details and possible commands", nil, function (self, OutputDevice, Parameters)
    WriteToConsole(OutputDevice, ModName .. " list:")
    for _, command in ipairs(CommandsArray) do
        if command.Function then
            WriteToConsole(OutputDevice, "------------------------------")
            WriteToConsole(OutputDevice, "Command: " .. command.Name)
            WriteToConsole(OutputDevice, "Aliases: " .. GetCommandAlias(command))
            if command.Parameters and type(command.Parameters) == "table" then
                for index, value in ipairs(Parameters) do
                    WriteToConsole(OutputDevice, "Parameter["..index.."]: "..value)
                end
            end
            WriteToConsole(OutputDevice, "Description: " .. command.Description)
        end
    end
    WriteToConsole(OutputDevice, "------------------------------")
    return true
end)

-- -- God Mode Command
CreateCommand({"god", "godmode"}, "God Mode", "Makes the player invincible and keeps all his stats at maximum (Health, Stamina, Hunger, Thirst, Fatigue, Continence)", nil,
function(self, OutputDevice, Parameters)
    WriteToConsole(OutputDevice, "God Mode is currently not implemented, use Infinite Health instead")
    return true
end)

-- Heal Command
CreateCommand({"heal"}, "Heal", "Player gets fully healed once (host only)", nil,
function(self, OutputDevice, Parameters)
    Settings.Heal = true
    WriteToConsole(OutputDevice, "Healing player")
    return true
end)

-- Infinite Health Command
CreateCommand({"health", "hp", "inv", "infhp", "infhealth"}, "Infinite Health", "Player gets fully healed and becomes invincible (host only)", nil,
function (self, OutputDevice, Parameters)
    Settings.InfiniteHealth = not Settings.InfiniteHealth
    PrintCommandState(Settings.InfiniteHealth, self.Name, OutputDevice)
    return true
end)

-- Infinite Stamina Command
CreateCommand({"stamina", "sp", "infsp", "infstamina"}, "Infinite Stamina", "Player won't consume stamina (works partial as guest)", nil,
function (self, OutputDevice, Parameters)
    Settings.InfiniteStamina = not Settings.InfiniteStamina
    PrintCommandState(Settings.InfiniteStamina, self.Name, OutputDevice)
    return true
end)

-- Infinite Durability Command
CreateCommand({"durability", "infdurability", "infdur"}, "Infinite Durability", "Keeps player's gear and hotbar items durability at maximum (works as guest)", nil,
function (self, OutputDevice, Parameters)
    Settings.InfiniteDurability = not Settings.InfiniteDurability
    PrintCommandState(Settings.InfiniteDurability, self.Name, OutputDevice)
    return true
end)

-- Infinite Energy Command
CreateCommand({"energy", "infenergy"}, "Infinite Energy", "Keeps player's gear and held item charge/energy at maximum (host only)", nil,
function (self, OutputDevice, Parameters)
    Settings.InfiniteEnergy = not Settings.InfiniteEnergy
    PrintCommandState(Settings.InfiniteEnergy, self.Name, OutputDevice)
    return true
end)

-- NoHunger Command
CreateCommand({"hunger", "nohunger", "eat"}, "No Hunger", "Player won't be hungry (works partial as guest)", nil,
function (self, OutputDevice, Parameters)
    Settings.NoHunger = not Settings.NoHunger
    PrintCommandState(Settings.NoHunger, self.Name, OutputDevice)
    return true
end)

-- No Thirst Command
CreateCommand({"thirst", "nothirst", "drink"}, "No Thirst", "Player won't be thirsty (works partial as guest)", nil,
function (self, OutputDevice, Parameters)
    Settings.NoThirst = not Settings.NoThirst
    PrintCommandState(Settings.InfiniteAmmo, self.Name, OutputDevice)
    return true
end)

-- No Fatigue Command
CreateCommand({"fat", "nofat", "fatigue", "nofatigue", "tired"}, "No Fatigue", "Player won't be tired (works partial as guest)", nil,
function(self, OutputDevice, Parameters)
    Settings.NoFatigue = not Settings.NoFatigue
    PrintCommandState(Settings.NoFatigue, self.Name, OutputDevice)
    return true
end)

-- Infinite Continence Command
CreateCommand({"con", "infcon", "InfiniteContinence", "noneed", "constipation"}, "Infinite Continence", "Player won't need to go to the toilet (works partial as guest)", nil,
function(self, OutputDevice, Parameters)
    Settings.InfiniteContinence = not Settings.InfiniteContinence
    PrintCommandState(Settings.InfiniteContinence, self.Name, OutputDevice)
    return true
end)

-- Low Continence Command
CreateCommand({"lowcon", "lowcontinence", "nocon", "nocontinence", "portalwc", "laxative"}, "Low Continence", "Freezes the need to go to the toilet at low value (host only)", nil,
function(self, OutputDevice, Parameters)
    Settings.LowContinence = not Settings.LowContinence
    PrintCommandState(Settings.LowContinence, self.Name, OutputDevice)
    return true
end)

-- No Radiation Command
CreateCommand({"rad", "norad", "radiation", "noradiation"}, "No Radiation", "Player can't receive radiation (works partial as guest)", nil,
function(self, OutputDevice, Parameters)
    Settings.NoRadiation = not Settings.NoRadiation
    PrintCommandState(Settings.NoRadiation, self.Name, OutputDevice)
    return true
end)

-- No Fall Damage Command
CreateCommand({"falldmg", "falldamage", "nofall", "nofalldmg", "nofalldamage"}, "No Fall Damage", "Prevents player from taking fall damage (host only)", nil,
function(self, OutputDevice, Parameters)
    Settings.NoFallDamage = not Settings.NoFallDamage
    PrintCommandState(Settings.NoFallDamage, self.Name, OutputDevice)
    return true
end)

-- FreeCrafting Command
CreateCommand({"freecraft", "freecrafting", "crafting", "craft"}, "Free Crafting", "Allows player to craft all recipes and simulates possession of all items. (Warning: You may need to restart the game to deactivate it completely!) (host only)", nil,
function(self, OutputDevice, Parameters)
    Settings.FreeCrafting = not Settings.FreeCrafting
    PrintCommandState(Settings.FreeCrafting, self.Name, OutputDevice)
    return true
end)

-- Set Money Command
CreateCommand({"money"}, "Set Money", "Set money to desired value (works as guest)", "value",
function(self, OutputDevice, Parameters)
    local moneyValue = nil
    if Parameters and #Parameters > 0 then
        moneyValue = tonumber(Parameters[1])
    end
    if type(moneyValue) ~= "number" then
        WriteToConsole(OutputDevice, self.Name..": Missing parameter")
        WriteToConsole(OutputDevice, self.Name..': It must be: "money {value}"')
        return true
    end
    if moneyValue < 0 or moneyValue >= 2147483647 then
        WriteToConsole(OutputDevice, self.Name..": Invalid money value!")
        WriteToConsole(OutputDevice, self.Name..': The value must be between 0 and 2147483647')
        return true
    end

    Settings.SetMoney = true
    Settings.MoneyValue = moneyValue
    WriteToConsole(OutputDevice, "Execute " .. self.Name .. " command with value: " .. Settings.MoneyValue)
    return true
end)

-- Infinite Ammo Command
CreateCommand({"infammo", "ammo", "infiniteammo"}, "Infinite Ammo", "Keeps ammo of ranged weapons replenished (works as guest)", nil,
function(self, OutputDevice, Parameters)
    Settings.InfiniteAmmo = not Settings.InfiniteAmmo
    PrintCommandState(Settings.InfiniteAmmo, self.Name, OutputDevice)
    return true
end)

-- No Recoil Command
CreateCommand({"norecoil", "recoil", "weaponnorecoil"}, "No Recoil", "Reduces weapon's fire recoil to minimum (haven't found a way to remove completely yet) (works as guest)", nil,
function(self, OutputDevice, Parameters)
    Settings.NoRecoil = not Settings.NoRecoil
    PrintCommandState(Settings.NoRecoil, self.Name, OutputDevice)
    return true
end)

-- No Sway Command
CreateCommand({"nosway", "sway", "noweaponsway"}, "No Sway", "Removes weapon's sway  (works as guest)", nil,
function(self, OutputDevice, Parameters)
    Settings.NoSway = not Settings.NoSway
    PrintCommandState(Settings.NoSway, self.Name, OutputDevice)
    return true
end)

-- Set Leyak Cooldown Command
CreateCommand({"leyakcd", "leyakcooldown", "cdleyak"}, "Leyak Cooldown", "Changes Leyak's spawn cooldown in minutes (Default: 15min). The cooldown resets each time you reload/rehost the game, but the previous cooldown will be in effect until the next Leyak spawns. (host only)", "minutes",
function(self, OutputDevice, Parameters)
    local cooldown = nil
    if Parameters and #Parameters > 0 then
        cooldown = tonumber(Parameters[1])
    end
    if type(cooldown) ~= "number" then
        WriteToConsole(OutputDevice, self.Name..": Missing parameter")
        WriteToConsole(OutputDevice, self.Name..': It must be: "leyakcd {cooldown}"')
        return true
    end
    
    if cooldown < 0.1 or cooldown >= 525600000 then
        WriteToConsole(OutputDevice, self.Name..": Invalid cooldown value!")
        WriteToConsole(OutputDevice, self.Name..': The value must be between 0.1 and 525600000 (minutes)')
        return true
    end

    Settings.LeyakCooldownInMin = cooldown
    WriteToConsole(OutputDevice, "Execute " .. self.Name .. " command with value: " .. Settings.LeyakCooldownInMin)
    return true
end)

-- No Clip Command
CreateCommand({"noclip", "clip", "ghost"}, "No Clip", "Disables player's collision and makes him fly (host only)", nil,
function(self, OutputDevice, Parameters)
    Settings.NoClip = not Settings.NoClip
    PrintCommandState(Settings.NoClip, self.Name, OutputDevice)
    return true
end)

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

    for _, commandObj in pairs(CommandsArray) do
        ---@cast commandObj CommandStruct
        if MatchCommand(command, commandObj.Aliases) then
            -- LogDebug("Found match: " .. command .. ", Command.Name: " .. commandObj.Name)
            if context:IsA(GetClassAbioticGameViewportClient()) and commandObj.Function then
                return commandObj.Function(commandObj, OutputDevice, Parameters)
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
    local godMode = CommandsMap["God Mode"]
    if godMode and godMode.Function then
        godMode.Function(godMode, OutputDevice, Parameters)
    end
    return true
end)

RegisterConsoleCommandGlobalHandler("ghost", function(FullCommand, Parameters, OutputDevice)
    local noClip = CommandsMap["No Clip"]
    if noClip and noClip.Function then
        noClip.Function(noClip, OutputDevice, Parameters)
    end
    return true
end)

RegisterConsoleCommandGlobalHandler("fly", function(FullCommand, Parameters, OutputDevice)
    local noClip = CommandsMap["No Clip"]
    if noClip and noClip.Function then
        noClip.Function(noClip, OutputDevice, Parameters)
    end
    return true
end)

RegisterConsoleCommandGlobalHandler("changesize", function(FullCommand, Parameters, OutputDevice)
    WriteToConsoleDebug(OutputDevice, 'Use "noclip", if you\'re stuck')
    return false
end)