local AFUtils = require("AFUtils.AFUtils")
local LinearColors = require("AFUtils.BaseUtils.LinearColors")
require("Settings")
local SettingsManager = require("SettingsManager")
local Skills = require("Skills")
local LocationsManager = require("LocationsManager")
local WeatherManager = require("WeatherManager")
local PlayersManager = require("PlayersManager")

local IsDedicatedServer = AFUtils.IsDedicatedServer()
LogDebug("IsDedicatedServer",IsDedicatedServer)

---Write to lua console and the OutputDevice
---@param OutputDevice FOutputDevice
---@param Message string
local function WriteToConsole(OutputDevice, Message)
    LogInfo(Message)
    if OutputDevice then
        OutputDevice:Log(Message)
    end
end

---Calls WriteToConsole with orefix "[Error] "
---@param OutputDevice FOutputDevice
---@param Message string
local function WriteErrorToConsole(OutputDevice, Message)
    if type(Message) ~= "string" then
        error("Invalid type of parameter \"Message\", it has to be a string")
    end

    WriteToConsole(OutputDevice, "[Error] " .. Message)
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

---Returns true if IsDedicatedServer and error was printed
---@param OutputDevice any
---@return boolean IsDedicatedServer
local function CheckAndLogDedicatedServerCommandSupport(OutputDevice)
    if IsDedicatedServer then
        WriteErrorToConsole(OutputDevice, "The command is not supported on Dedicated Server!")
        return true
    end
    return false
end

---@alias CommandFunction fun(self: CommandStruct, OutputDevice: FOutputDevice, Parameters: table): boolean

---@class CommandParam
---@field Name string
---@field ValidType string # Type name, see: https://www.lua.org/pil/2.html
---@field Description string?
---@field Required boolean
---@field ValidValues string[]?
local CommandParam = {}

---@class CommandStruct
---@field Aliases table<string>|string
---@field Name string
---@field Description string
---@field Parameters CommandParam[]|nil
---@field Function CommandFunction?
---@field SettingName string?
local CommandStruct = {}

---@type CommandStruct[]
local CommandsArray = {}

---@type { [string]: CommandStruct }
local CommandsMap = {}

---@param Name string # Name or alias
---@param Command CommandStruct
local function MapCommand(Name, Command)
    CommandsMap[string.lower(Name)] = Command
end

---@param Name string # Name or alias
---@return CommandStruct?
local function GetCommand(Name)
    return CommandsMap[string.lower(Name)]
end

---Debug logs all infomations about a CommandParam
---@param Param CommandParam
---@param Prefix string?
local function LogDebugCommandParam(Param, Prefix)
    if not Param or not Param.ValidType then return end
    Prefix = Prefix or ""

    LogDebug(Prefix .. "Parameter: Name: " .. Param.Name .. ", Required: " .. tostring(Param.Required) .. ", ValidType: " .. Param.ValidType .. ", Description: " .. tostring(Param.Description) .. ", ValidValues: " .. ArrayToString(Param.ValidValues))
end


---Debug logs all infomations about a CommandStruct
---@param Command CommandStruct
---@param Prefix string?
local function LogDebugCommandStruct(Command, Prefix)
    if not Command or not Command.Name then return end
    Prefix = Prefix or ""

    LogDebug(Prefix .."LogDebugCommandStruct:")
    LogDebug("Name: " .. Command.Name .. ", Aliases: " .. ArrayToString(Command.Aliases) .. ", Description: " .. Command.Description .. ", Parameters type: " .. type(Command.Parameters) .. ", Function type: " .. type(Command.Function))
    if Command.Parameters then
        for index, value in ipairs(Command.Parameters) do
            LogDebugCommandParam(value, "  " .. index .. ": ")
        end
    end
    LogDebug("---")
end

---@param StringArray string[]|string
---@param Seperator string? # Default: " | "
---@param WrapperLeft string? # Default: ""
---@param WrapperRight string? # Default: ""
---@return string
local function ArrayToString(StringArray, Seperator, WrapperLeft, WrapperRight)
    Seperator = Seperator or " | "
    WrapperLeft = WrapperLeft or ""
    WrapperRight = WrapperRight or ""
    if type(StringArray) == "string" then
        return StringArray
    end

    if type(StringArray) ~= "table" then
        return ""
    end

    local result = ""
    for _, value in ipairs(StringArray) do
        if result ~= "" then
            result = result .. Seperator
        end
        result = result .. WrapperLeft .. value .. WrapperRight
    end
    return result
end

---@param Parameters CommandParam[]
---@param Seperator string? # Default: " | "
---@param WrapperLeft string? # Default: ""
---@param WrapperRight string? # Default: ""
---@return string
local function ParametersToReadableList(Parameters, Seperator, WrapperLeft, WrapperRight)
    if not Parameters then return "" end
    Seperator = Seperator or " "
    WrapperLeft = WrapperLeft or "<"
    WrapperRight = WrapperRight or ">"

    local parameters = ""
    for i, param in ipairs(Parameters) do
        if i > 1 then
            parameters = parameters .. Seperator
        end
        parameters = parameters .. WrapperLeft .. param.Name .. WrapperRight
    end
    return parameters
end

---@param Name string
---@param ValidType string # Type name, see: https://www.lua.org/pil/2.html
---@param Description string?
---@param Required boolean? # Default: false
---@param ValidValues string|string[]|nil
---@return CommandParam
local function CreateCommandParam(Name, ValidType, Description, Required, ValidValues)
    if not Name or Name == "" then
        error('CreateCommandParam: Invalid parameter "Name". Name must be a valid string and can\'t be empty')
    end
    if not ValidType or ValidType == "" then
        error('CreateCommandParam: Invalid parameter "ValidType". ValidType must be a valid type string and can\'t be empty')
    end
    if not Name and type(Name) ~= "table" then
        error('CreateCommandParam: Invalid parameter "ValidValues". ValidValues must be nil or an array of strings')
    end
    Required = Required or false
    if type(ValidValues) == "string" then
        ValidValues = { ValidValues }
    end

    return {
        Name = Name,
        ValidType = ValidType,
        Description = Description,
        Required = Required,
        ValidValues = ValidValues,
    }
end

---Creats a new CommandStruct out of parameters
---@param Aliases table<string>|string
---@param CommandName string
---@param Description string?
---@param Parameters CommandParam|CommandParam[]|nil
---@param Callback CommandFunction?
---@param SettingName string?
---@return CommandStruct # Returns created command
local function CreateCommand(Aliases, CommandName, Description, Parameters, Callback, SettingName)
    Description = Description or ""
    if type(Aliases) == "string" then
        Aliases = { Aliases }
    end
    if type(Aliases) ~= "table" then
        error('CreateCommand: Invalid "CommandNames" parameter')
    end
    if not CommandName then
        error('CreateCommand: Invalid "FeatureName" parameter')
    end
    -- Check if Parameters is an array of tables or a single CommandParam
    if Parameters and Parameters.Name then
        Parameters = { Parameters }
    end

    -- LogDebug("CreateCommand: Name: " .. CommandName .. ", Aliases: " .. ArrayToString(Aliases) .. ", Description: " .. Description .. ", Parameters type: " .. type(Parameters))
    -- if DebugMode and type(Parameters) == "table" then
    --     for index, value in ipairs(Parameters) do
    --         LogDebug(index .. ": " .. value.Name .. ", Required: " .. tostring(value.Required))
    --     end
    -- end

    local commandObject = {
        Aliases = Aliases,
        Name = CommandName,
        Description = Description,
        Parameters = Parameters,
        Function = Callback,
        SettingName = SettingName
    }

    table.insert(CommandsArray, commandObject)
    MapCommand(CommandName, commandObject)
    for i, alias in ipairs(Aliases) do
        MapCommand(alias, commandObject)
    end

    return commandObject
end

---@param Alias string
---@return CommandStruct?
local function GetCommandByAlias(Alias)
    if type(Alias) ~= "string" then return nil end

    return GetCommand(Alias)
end

if DebugMode then
    function PrintCommandsAsMarkdownTable()
        print("------- Markdown Table -----------")
        print("Command | Aliases | Parameters | Description")
        print("------- | ------- | ---------- | -----------")
        for _, command in ipairs(CommandsArray) do
            if command.Function then
                print(string.format("%s | %s | %s | %s", command.Name, ArrayToString(command.Aliases, " \\| "),
                    ParametersToReadableList(command.Parameters, " ", "{", "}"), command.Description))
            end
        end
        print("----------------------------------")
    end

    function PrintCommandsAsBBCode()
        print("-- BBCode --")
        for _, command in ipairs(CommandsArray) do
            if command.Function then
                local parameters = ""
                if command.Parameters and #command.Parameters > 0 then
                    parameters = string.format(" %s ", ParametersToReadableList(command.Parameters))
                end
                print(string.format("[b]%s[/b] [ %s ] {%s} - [font=Georgia]%s[/font]", command.Name,
                    ArrayToString(command.Aliases, " | ", "[font=Arial]", "[/font]"), parameters, command.Description))
            end
        end
        print("----------------------------------")
    end

    function LogCommandsAsMarkdownTable()
        local file = io.open("CommandsAsMarkdown.md", "w")
        if file then
            local content = "Command | Aliases | Parameters | Description\n"
            content = content .. "------- | ------- | ---------- | -----------\n"
            for _, command in ipairs(CommandsArray) do
                if command.Function then
                    content = content .. string.format("%s | %s | %s | %s\n", command.Name, ArrayToString(command.Aliases, " \\| "), ParametersToReadableList(command.Parameters, " ", "{", "}"), command.Description)
                end
            end
            file:write(content)
            return file:close()
        end
    end

    function LogCommandsAsBBCode()
        local file = io.open("CommandsAsBBCode.txt", "w")
        if file then
            local content = ""
            for _, command in ipairs(CommandsArray) do
                if command.Function then
                    local parameters = ""
                    if command.Parameters and #command.Parameters > 0 then
                        parameters = string.format(" %s ", ParametersToReadableList(command.Parameters))
                    end
                    content = content .. string.format("[b]%s[/b] [ %s ] {%s} - [font=Georgia]%s[/font]\n", command.Name, ArrayToString(command.Aliases, " | ", "[font=Arial]", "[/font]"), parameters, command.Description)
                end
            end
            file:write(content)
            return file:close()
        end
    end
end

---
---@param State boolean
---@param CommandName string
---@param OutputDevice FOutputDevice
---@return string StateText
local function PrintCommandState(State, CommandName, OutputDevice)
    local stateText = CommandName .. " "
    if State then
        stateText = stateText .. "Enabled"
    else
        stateText = stateText .. "Disabled"
    end
    WriteToConsole(OutputDevice, stateText)
    return stateText
end

---@param Parameters CommandParam[]
---@return string
local function ParametersToString(Parameters)
    if not Parameters then return "" end

    local parameters = ""
    for _, param in ipairs(Parameters) do
        if parameters ~= "" then
            parameters = parameters .. " "
        end
        parameters = parameters .. "<" .. param.Name .. ">"
        if not param.Required then
            parameters = parameters .. "?"
        end
    end
    return parameters
end

---@param OutputDevice FOutputDevice
---@param Parameters CommandParam[]
local function WriteParametersToConsole(OutputDevice, Parameters)
    if not OutputDevice or not Parameters then return end

    WriteToConsole(OutputDevice, "Parameters breakdown:")
    for i, param in ipairs(Parameters) do
        local name = '"' .. param.Name .. '"'
        if not param.Required then
            name = name .. " (optional)"
        end
        WriteToConsole(OutputDevice, " | Parameter: " .. name)
        WriteToConsole(OutputDevice, "   Type: " .. param.ValidType)
        if param.Description then
            WriteToConsole(OutputDevice, "   Description: " .. param.Description)
        end
        if param.ValidValues then
            WriteToConsole(OutputDevice, "   Valid values:")
            for _, validValue in ipairs(param.ValidValues) do
                WriteToConsole(OutputDevice, "   →" .. validValue)
            end
        end
    end
end

---@param OutputDevice FOutputDevice
---@param Command CommandStruct?
local function WriteCommandToConsole(OutputDevice, Command)
    if not OutputDevice or not Command or not Command.Function then return end

    WriteToConsole(OutputDevice, "Command: " .. Command.Name)
    WriteToConsole(OutputDevice, "Aliases: " .. ArrayToString(Command.Aliases))
    if Command.Description then
        WriteToConsole(OutputDevice, "Description: " .. Command.Description)
    end
    if type(Command.Parameters) == "table" then
        WriteToConsole(OutputDevice, "Parameters: " .. ParametersToString(Command.Parameters))
        WriteParametersToConsole(OutputDevice, Command.Parameters)
    end
    WriteToConsole(OutputDevice, "------------------------------")
end

---@param OutputDevice FOutputDevice
---@param NameOrIndex string|integer
---@return AAbiotic_PlayerCharacter_C? player, string playerName
local function GetPlayerByNameOrIndex(OutputDevice, NameOrIndex)
    local playerIndex = tonumber(NameOrIndex)
    local player = nil
    local playerName = ""
    if playerIndex then
        if playerIndex < 1 then
            WriteErrorToConsole(OutputDevice, "Player's index can't be smaller than 1!")
            return nil, ""
        end
        player, playerName = PlayersManager.GetPlayerByIndex(playerIndex)
        if not player then
            WriteErrorToConsole(OutputDevice, "Couldn't find a player with index " .. playerIndex)
            return nil, ""
        end
    else
        ---@cast NameOrIndex string
        player, playerName = PlayersManager.GetPlayerByName(NameOrIndex)
        if not player then
            WriteErrorToConsole(OutputDevice, "Couldn't find a player with name \"" .. NameOrIndex .. '"')
            return nil, ""
        end
    end
    return player, playerName
end

---@param Parameters string[]
---@param StartIndex integer?
---@return string
local function CombineParameters(Parameters, StartIndex)
    StartIndex = StartIndex or 1
    local locationName = ""
    for i = StartIndex, #Parameters, 1 do
        if i > 1 then
            locationName = locationName .. " "
        end
        locationName = locationName .. Parameters[i]
    end
    return locationName
end

-- Help Command
CreateCommand("help", "Help", "Prints a list of all commands or info about a single one",
    CreateCommandParam("command alias", "string", "Shows help for the specified command based on its alias."),
    function(self, OutputDevice, Parameters)
        local command = nil ---@type CommandStruct?
        if Parameters and #Parameters > 0 then
            command = GetCommandByAlias(Parameters[1])
        end
        if command then
            WriteCommandToConsole(OutputDevice, command)
        else
            if #Parameters > 0 then
                WriteToConsole(OutputDevice, "There is no command with the alias \"" .. Parameters[1] .. "\"")
            else
                WriteToConsole(OutputDevice, ModName .. " list:")
                for _, command in ipairs(CommandsArray) do
                    if command.Function then
                        WriteCommandToConsole(OutputDevice, command)
                    end
                end
            end
        end

        return true
    end)

-- Status Command
CreateCommand({"status", "state", "settings"}, "Status", "Prints status of the mod, which commands are active with which values", nil,
    function(self, OutputDevice, Parameters)
        for _, command in ipairs(CommandsArray) do
            if command and type(command.SettingName) == "string" then
                local settingValue = Settings[command.SettingName]
                local valueType = type(settingValue)
                if valueType ~= "table" then
                    local status = "Disabled"
                    if settingValue == true then
                        status = "Enabled"
                    elseif valueType == "number" and settingValue > 0 then
                        status = tostring(settingValue)
                    end
                    WriteToConsole(OutputDevice, "  " .. command.Name .. ": " .. status)
                end
            end
        end

        return true
    end)

-- Disable All Command
CreateCommand({"disableall", "alloff"}, "Disable All", "Disables all commands", nil,
    function(self, OutputDevice, Parameters)
        WriteToConsole(OutputDevice, "Disabling all features.")
        local disabledCount = 0
        for _, command in ipairs(CommandsArray) do
            if command and type(command.SettingName) == "string" then
                local settingValue = Settings[command.SettingName]
                if settingValue == true then
                    Settings[command.SettingName] = false
                    WriteToConsole(OutputDevice, "  Disable " .. command.Name)
                    disabledCount = disabledCount + 1
                end
            end
        end
        if disabledCount < 1 then
            WriteToConsole(OutputDevice, "There is nothing to disable.")
        end
        return true
    end)

-- -- God Mode Command
CreateCommand({ "god", "godmode" }, "God Mode",
    "Activates all health, stamina and status related features at once. (You will have to disable god mode to be able to toggle them seperatly)",
    nil,
    function(self, OutputDevice, Parameters)
        Settings.GodMode = not Settings.GodMode
        PrintCommandState(Settings.GodMode, self.Name, OutputDevice)
        if Settings.GodMode then
            Settings.InfiniteHealth = false
            Settings.InfiniteStamina = false
            Settings.NoHunger = false
            Settings.NoThirst = false
            Settings.NoFatigue = false
            Settings.InfiniteContinence = false
            Settings.NoRadiation = false
            Settings.PerfectTemperature = false
            Settings.InfiniteOxygen = false
        end
        return true
    end,
    "GodMode")

-- Heal Command
CreateCommand({ "heal" }, "Heal", "Player gets fully healed once (host only)", nil,
    function(self, OutputDevice, Parameters)
        local myPlayer = AFUtils.GetMyPlayer()
        if IsValid(myPlayer) then
            WriteToConsole(OutputDevice, "Healing player")
            AFUtils.HealAllLimbs(myPlayer)
            AFUtils.ClientDisplayWarningMessage("All Limbs were healed", AFUtils.CriticalityLevels.Green)
            return true
        end
        return false
    end)

-- Infinite Health Command
CreateCommand({ "health", "hp", "infhp", "infhealth" }, "Infinite Health",
    "Player gets fully healed and becomes invincible (host only)", nil,
    function(self, OutputDevice, Parameters)
        if Settings.GodMode then
            WriteToConsole(OutputDevice, self.Name .. " can't be activated while God Mode is enabled!")
            return true
        end
        Settings.InfiniteHealth = not Settings.InfiniteHealth
        PrintCommandState(Settings.InfiniteHealth, self.Name, OutputDevice)
        return true
    end,
    "InfiniteHealth")

-- Infinite Stamina Command
CreateCommand({ "stamina", "sp", "infsp", "infstamina" }, "Infinite Stamina",
    "Player won't consume stamina (works partial as guest)", nil,
    function(self, OutputDevice, Parameters)
        if Settings.GodMode then
            WriteToConsole(OutputDevice, self.Name .. " can't be activated while God Mode is enabled!")
            return true
        end
        Settings.InfiniteStamina = not Settings.InfiniteStamina
        PrintCommandState(Settings.InfiniteStamina, self.Name, OutputDevice)
        return true
    end,
    "InfiniteStamina")

-- Infinite Durability Command
CreateCommand({ "durability", "infdurability", "infdur" }, "Infinite Durability",
    "Keeps player's gear and hotbar items durability at maximum (works as guest)", nil,
    function(self, OutputDevice, Parameters)
        Settings.InfiniteDurability = not Settings.InfiniteDurability
        PrintCommandState(Settings.InfiniteDurability, self.Name, OutputDevice)
        return true
    end,
    "InfiniteDurability")

-- Infinite Energy Command
CreateCommand({ "energy", "infenergy" }, "Infinite Energy",
    "Keeps player's gear and held item charge/energy at maximum (host only)", nil,
    function(self, OutputDevice, Parameters)
        Settings.InfiniteEnergy = not Settings.InfiniteEnergy
        PrintCommandState(Settings.InfiniteEnergy, self.Name, OutputDevice)
        return true
    end,
    "InfiniteEnergy")

-- No Overheat Command
CreateCommand({ "nooverheat", "overheat" }, "No Overheat",
    "Prevents items from overheating (currently only the Jetpack) (host only)", nil,
    function(self, OutputDevice, Parameters)
        Settings.NoOverheat = not Settings.NoOverheat
        PrintCommandState(Settings.NoOverheat, self.Name, OutputDevice)
        return true
    end,
    "NoOverheat")

-- Infinite Max Weight Command
CreateCommand({ "infweight", "carryweight", "maxweight", "noweight", "infcarry" }, "Infinite Max Weight",
    "Increases maximum carry weight. (To refresh overweight status drop heavy items then pick them up again) (host only)", nil,
    function(self, OutputDevice, Parameters)
        Settings.InfiniteMaxWeight = not Settings.InfiniteMaxWeight
        PrintCommandState(Settings.InfiniteMaxWeight, self.Name, OutputDevice)
        return true
    end,
    "InfiniteMaxWeight")

-- NoHunger Command
CreateCommand({ "hunger", "nohunger", "eat" }, "No Hunger", "Player won't be hungry (works partial as guest)", nil,
    function(self, OutputDevice, Parameters)
        if Settings.GodMode then
            WriteToConsole(OutputDevice, self.Name .. " can't be activated while God Mode is enabled!")
            return true
        end
        Settings.NoHunger = not Settings.NoHunger
        PrintCommandState(Settings.NoHunger, self.Name, OutputDevice)
        return true
    end,
    "NoHunger")

-- No Thirst Command
CreateCommand({ "thirst", "nothirst", "drink" }, "No Thirst", "Player won't be thirsty (works partial as guest)", nil,
    function(self, OutputDevice, Parameters)
        if Settings.GodMode then
            WriteToConsole(OutputDevice, self.Name .. " can't be activated while God Mode is enabled!")
            return true
        end
        Settings.NoThirst = not Settings.NoThirst
        PrintCommandState(Settings.InfiniteAmmo, self.Name, OutputDevice)
        return true
    end,
    "NoThirst")

-- No Fatigue Command
CreateCommand({ "fat", "nofat", "fatigue", "nofatigue", "tired" }, "No Fatigue",
    "Player won't be tired (works partial as guest)", nil,
    function(self, OutputDevice, Parameters)
        if Settings.GodMode then
            WriteToConsole(OutputDevice, self.Name .. " can't be activated while God Mode is enabled!")
            return true
        end
        Settings.NoFatigue = not Settings.NoFatigue
        PrintCommandState(Settings.NoFatigue, self.Name, OutputDevice)
        return true
    end,
    "NoFatigue")

-- Infinite Continence Command
CreateCommand({ "con", "infcon", "InfiniteContinence", "noneed", "constipation" }, "Infinite Continence",
    "Player won't need to go to the toilet (works partial as guest)", nil,
    function(self, OutputDevice, Parameters)
        if Settings.GodMode then
            WriteToConsole(OutputDevice, self.Name .. " can't be activated while God Mode is enabled!")
            return true
        end
        Settings.InfiniteContinence = not Settings.InfiniteContinence
        PrintCommandState(Settings.InfiniteContinence, self.Name, OutputDevice)
        if Settings.InfiniteContinence then
            Settings.LowContinence = false
        end
        return true
    end,
    "InfiniteContinence")

-- Low Continence Command
CreateCommand({ "lowcon", "lowcontinence", "nocon", "nocontinence", "laxative" }, "Low Continence", "Freezes the need to go to the toilet at low value. (Each time you seat down on Portal WC you have 1% change to trigger it) (host only)", nil,
    function(self, OutputDevice, Parameters)
        Settings.LowContinence = not Settings.LowContinence
        PrintCommandState(Settings.LowContinence, self.Name, OutputDevice)
        if Settings.LowContinence then
            Settings.InfiniteContinence = false
        end
        return true
    end,
    "LowContinence")

-- No Radiation Command
CreateCommand({ "rad", "norad", "radiation", "noradiation" }, "No Radiation",
    "Player can't receive radiation (works partial as guest)", nil,
    function(self, OutputDevice, Parameters)
        if Settings.GodMode then
            WriteToConsole(OutputDevice, self.Name .. " can't be activated while God Mode is enabled!")
            return true
        end
        Settings.NoRadiation = not Settings.NoRadiation
        PrintCommandState(Settings.NoRadiation, self.Name, OutputDevice)
        return true
    end,
    "NoRadiation")

-- Perfect Temperature Command
CreateCommand({ "nocold", "nohot", "temperature", "temp", "perfecttemp"  }, "Perfect Temperature", "Makes player temperature resistant. (host only)", nil,
    function(self, OutputDevice, Parameters)
        if Settings.GodMode then
            WriteToConsole(OutputDevice, self.Name .. " can't be activated while God Mode is enabled!")
            return true
        end
        Settings.PerfectTemperature = not Settings.PerfectTemperature
        PrintCommandState(Settings.PerfectTemperature, self.Name, OutputDevice)
        return true
    end,
    "PerfectTemperature")

-- Infinite Oxygen Command
CreateCommand({ "oxygen", "info2", "o2", "infoxygen"  }, "Infinite Oxygen", "Makes player breath under water. (host only)", nil,
    function(self, OutputDevice, Parameters)
        if Settings.GodMode then
            WriteToConsole(OutputDevice, self.Name .. " can't be activated while God Mode is enabled!")
            return true
        end
        Settings.InfiniteOxygen = not Settings.InfiniteOxygen
        PrintCommandState(Settings.InfiniteOxygen, self.Name, OutputDevice)
        return true
    end,
    "InfiniteOxygen")

-- Invisible Command
CreateCommand({ "inv", "invisible", "invis", "invisibility", "untargetable" }, "Invisible", "Makes player invisible/untargetable by enemy NPCs (host only)", nil,
    function(self, OutputDevice, Parameters)
        Settings.Invisible = not Settings.Invisible
        PrintCommandState(Settings.Invisible, self.Name, OutputDevice)
        return true
    end,
    "Invisible")

-- No Fall Damage Command
CreateCommand({ "falldmg", "falldamage", "nofall", "nofalldmg", "nofalldamage" }, "No Fall Damage",
    "Prevents player from taking fall damage (host only)", nil,
    function(self, OutputDevice, Parameters)
        Settings.NoFallDamage = not Settings.NoFallDamage
        PrintCommandState(Settings.NoFallDamage, self.Name, OutputDevice)
        return true
    end,
    "NoFallDamage")

-- Free Crafting Command
CreateCommand({ "freecraft", "freecrafting", "crafting", "craft" }, "Free Crafting (Debug function)",
    "Allows player to craft ALL recipes, upgrade the Crafting Bench, instantly build furnitue and unlock chests without keys. (Warning: You may need to restart the game to deactivate it completely!) (host only)",
    nil,
    function(self, OutputDevice, Parameters)
        Settings.FreeCrafting = not Settings.FreeCrafting
        PrintCommandState(Settings.FreeCrafting, self.Name, OutputDevice)
        return true
    end,
    "FreeCrafting")

-- Instant Crafting Command
CreateCommand({ "InstantCrafting", "instacraft", "instantcraft", "instcraft" }, "Instant Crafting",
    "Reduces crafting duration for all recipes to minimum (works as guest)", nil,
    function(self, OutputDevice, Parameters)
        Settings.InstantCrafting = not Settings.InstantCrafting
        PrintCommandState(Settings.InstantCrafting, self.Name, OutputDevice)
        return true
    end,
    "InstantCrafting")

-- Set Money Command
CreateCommand({ "money" }, "Set Money", "Set money to desired value (works as guest)",
    CreateCommandParam("value", "number", "Money value to set"),
    function(self, OutputDevice, Parameters)
        local moneyValue = nil
        if Parameters and #Parameters > 0 then
            moneyValue = tonumber(Parameters[1])
        end
        if type(moneyValue) ~= "number" then
            local myPlayer = AFUtils.GetMyPlayer()
            if IsValid(myPlayer) then
                WriteToConsole(OutputDevice, self.Name .. ": Current money value: " .. myPlayer.CurrentMoney)
            else
                WriteToConsole(OutputDevice, "Error: Player character not found. Are you ingame?")
            end
            WriteToConsole(OutputDevice, self.Name .. ': To change it write: "money (value here)"')
            return true
        end
        if moneyValue < 0 or moneyValue >= 2147483647 then
            WriteToConsole(OutputDevice, self.Name .. ": Invalid money value!")
            WriteToConsole(OutputDevice, self.Name .. ': The value must be between 0 and 2147483647')
            return true
        end
        WriteToConsole(OutputDevice, "Execute " .. self.Name .. " command with value: " .. moneyValue)
        local myPlayer = AFUtils.GetMyPlayer()
        if IsValid(myPlayer) then
            myPlayer:Request_ModifyMoney(moneyValue - myPlayer.CurrentMoney)
            myPlayer.CurrentMoney = moneyValue
            LogDebug("CurrentMoney: " .. tostring(myPlayer.CurrentMoney))
            AFUtils.ClientDisplayWarningMessage("Money set to " .. myPlayer.CurrentMoney, AFUtils.CriticalityLevels.Green)
        else
            WriteToConsole(OutputDevice, "Error: Player character not found. Are you ingame?")
        end
        return true
    end)

-- Infinite Ammo Command
CreateCommand({ "infammo", "ammo", "infiniteammo" }, "Infinite Ammo",
    "Keeps ammo of ranged weapons replenished (as guest works somehow, but is bugged)", nil,
    function(self, OutputDevice, Parameters)
        Settings.InfiniteAmmo = not Settings.InfiniteAmmo
        PrintCommandState(Settings.InfiniteAmmo, self.Name, OutputDevice)
        return true
    end,
    "InfiniteAmmo")

-- No Recoil Command
CreateCommand({ "norecoil", "recoil", "weaponnorecoil" }, "No Recoil",
    "Reduces weapon's fire recoil to minimum (haven't found a way to remove completely yet) (works as guest)", nil,
    function(self, OutputDevice, Parameters)
        Settings.NoRecoil = not Settings.NoRecoil
        PrintCommandState(Settings.NoRecoil, self.Name, OutputDevice)
        return true
    end,
    "NoRecoil")

-- No Sway Command
CreateCommand({ "nosway", "sway", "noweaponsway" }, "No Sway", "Removes weapon's sway  (works as guest)", nil,
    function(self, OutputDevice, Parameters)
        Settings.NoSway = not Settings.NoSway
        PrintCommandState(Settings.NoSway, self.Name, OutputDevice)
        return true
    end,
    "NoSway")

-- Set Leyak Cooldown Command
CreateCommand({ "leyakcd", "leyakcooldown", "cdleyak" }, "Leyak Cooldown",
    "Changes Leyak's spawn cooldown in minutes (Default: 15min). The cooldown will be reapplied by the mod automatically each time you start the game. (To disable the command set value to 0 or 15) (host only)",
    CreateCommandParam("minutes", "number", "Amount a minutes between each Leyak spawn"),
    function(self, OutputDevice, Parameters)
        local cooldownInMin = nil
        if Parameters and #Parameters > 0 then
            cooldownInMin = tonumber(Parameters[1])
        end
        if type(cooldownInMin) ~= "number" then
            local aiDirector = AFUtils.GetAIDirector()
            if aiDirector then
                WriteToConsole(OutputDevice,
                    self.Name .. ": Current cooldown: " .. (aiDirector.LeyakCooldown / 60) .. " minutes")
            end
            WriteToConsole(OutputDevice, self.Name .. ': To change it write: "leyakcd (cooldown value in minutes here)"')
            return true
        end

        if cooldownInMin >= 525600000 then
            WriteErrorToConsole(OutputDevice, self.Name .. ": Invalid cooldown value!")
            WriteErrorToConsole(OutputDevice, self.Name .. ': The value must be lower than 525600000 (minutes)')
            return true
        end
        if cooldownInMin > 0  then
            WriteToConsole(OutputDevice, "Execute " .. self.Name .. " command with value: " .. cooldownInMin)
            Settings.LeyakCooldown = cooldownInMin * 60
        else
            WriteToConsole(OutputDevice, self.Name .. " disabled, set back to default value.")
            Settings.LeyakCooldown = 0
        end

        return true
    end,
    "LeyakCooldown")

-- Trap Leyak Command
CreateCommand({ "trapleyak", "containleyak" }, "Trap Leyak", "Trap's Leyak in the next possible Containment Unit. (host only)", nil,
    function(self, OutputDevice, Parameters)
        local leyakContainments = FindAllOf("Deployed_LeyakContainment_C") ---@cast leyakContainments ADeployed_LeyakContainment_C[]?
        if leyakContainments then
            LogDebug("Trap Leyak Command: leyakContainments:",#leyakContainments)
            -- Check if Leyak is already trapped
            for _, leyakContainment in ipairs(leyakContainments) do
                if IsValid(leyakContainment) and not leyakContainment.DeployableDestroyed and leyakContainment.ContainsLeyak then
                    WriteErrorToConsole(OutputDevice, "Leyak is already trapped")
                    return false
                end
            end
            for _, leyakContainment in ipairs(leyakContainments) do
                if IsValid(leyakContainment) and not leyakContainment.DeployableDestroyed then
                    if AFUtils.TrapLeyak(leyakContainment) then
                        WriteToConsole(OutputDevice, "Leyak was trapped successfully.")
                        return true
                    else
                        WriteErrorToConsole(OutputDevice, "Failed to trap Leyak.")
                        return false
                    end
                end
            end
        end
        WriteErrorToConsole(OutputDevice, "Couldn't find a deployed Containment Unit. Have you built one?")
        return false
    end)

-- Free Leyak Command
CreateCommand({ "freeleyak" }, "Free Leyak", "Free Leyak from a Containment Unit. (host only)", nil,
    function(self, OutputDevice, Parameters)
        local leyakContainments = FindAllOf("Deployed_LeyakContainment_C") ---@cast leyakContainments ADeployed_LeyakContainment_C[]?
        if leyakContainments then
            LogDebug("Free Leyak Command: leyakContainments:", #leyakContainments)
            -- Check if Leyak is already trapped
            for _, leyakContainment in ipairs(leyakContainments) do
                if IsValid(leyakContainment) and not leyakContainment.DeployableDestroyed and leyakContainment.ContainsLeyak then
                    if AFUtils.FreeLeyak(leyakContainment) then
                        WriteToConsole(OutputDevice, "Leyak was freed successfully")
                        return true
                    else
                        WriteErrorToConsole(OutputDevice, "Failed to free Leyak")
                        return false
                    end
                end
            end
            WriteErrorToConsole(OutputDevice, "None of deployed Containment Units contain Leyak")
            return false
        end
        WriteErrorToConsole(OutputDevice, "Couldn't find a deployed Containment Unit.")
        return false
    end)

-- No Clip Command
CreateCommand({ "noclip", "clip", "ghost" }, "No Clip", "Disables player's collision and makes him fly (host only)", nil,
    function(self, OutputDevice, Parameters)
        Settings.NoClip = not Settings.NoClip
        PrintCommandState(Settings.NoClip, self.Name, OutputDevice)
        return true
    end,
    "NoClip")

-- Add Skill Experience
CreateCommand({ "addxp", "addexp", "xpadd", "skillxp", "skillexp", "skill", "skillxp" }, "Add Skill Experience",
    "Adds XP to specified Skill (host only)",
    { CreateCommandParam("skill alias", "string", "Skill's alias", true, Skills.GetSkillsAsStrings()),
    CreateCommandParam("XP value", "number", "Amount of XP added to the skill.") },
    function(self, OutputDevice, Parameters)
        local skill = nil ---@type SkillStruct?
        local xpToAdd = nil ---@type integer?
        if #Parameters > 0 then
            skill = Skills.GetSkillByAlias(Parameters[1])
        end
        if #Parameters > 1 then
            xpToAdd = tonumber(Parameters[2])
        end
        if not skill then
            WriteErrorToConsole(OutputDevice, 'Invalid skill alias. Use command "help addxp" to see all valid skill parameters')
            return false
        end
        if xpToAdd then
            if Skills.AddXpToMyPlayer(skill.Id, xpToAdd) then
                local message = tostring(xpToAdd) .. " XP added to " .. skill.Name
                WriteToConsole(OutputDevice, message)
                AFUtils.DisplayWarningMessage(message, AFUtils.CriticalityLevels.Green)
            else
                WriteToConsole(OutputDevice, "Failed to add " .. tostring(xpToAdd) .. " XP to \"" .. skill.Name .. '"')
                WriteToConsole(OutputDevice, "The reason might be that the XP is maxed out.")
                return false
            end
        else
            local skillStruct = Skills.GetMyCharacterSkillStructById(skill.Id)
            if skillStruct then
                WriteToConsole(OutputDevice, "Skill: " .. skill.Name .. ", Current value: " .. math.ceil(skillStruct.CurrentSkillXP_20_8F7934CD4A4542F036AE5C9649362556))
            else
                WriteErrorToConsole(OutputDevice, "Couldn't get values for Character Skill: " .. skill.Id)
                return false
            end
        end

        return true
    end)

-- Remove All Skill Experience
CreateCommand({ "removexp", "removeexp", "resetxp", "resetexp", "resetskill", "resetlevel", "resetlvl" },
    "Remove Skill Experience", "Removes All XP from specified Skill (host only)",
    CreateCommandParam("skill alias", "string", "Skill's alias", true, Skills.GetSkillsAsStrings()),
    function(self, OutputDevice, Parameters)
        local skill = nil ---@type SkillStruct?
        if #Parameters > 0 then
            skill = Skills.GetSkillByAlias(Parameters[1])
        end
        if not skill then
            WriteErrorToConsole(OutputDevice, 'Invalid skill alias. Use command "help removexp" to see all valid skill parameters')
            return false
        end
        if Skills.RemoveXpFromMyPlayer(skill.Id) then
            local message = "Removed all XP from " .. skill.Name
            WriteToConsole(OutputDevice, message)
            AFUtils.DisplayWarningMessage(message, AFUtils.CriticalityLevels.Red)
            return true
        else
            WriteErrorToConsole(OutputDevice, "Couldn't find character progress component")
        end

        return false
    end)

-- Reset All Skills
CreateCommand({ "resetallskills", "resetallskill", "resetallxp", "resetallexp", "resetalllvl" }, "Reset All Skills",
    "Resets all character skills! (works as guest)", nil,
    function(self, OutputDevice, Parameters)
        local progressionComponen = AFUtils.GetMyCharacterProgressionComponent()
        if IsValid(progressionComponen) then
            progressionComponen:Request_ResetAllSkills()
            local message = "All skills were reset"
            WriteToConsole(OutputDevice, message)
            AFUtils.ClientDisplayWarningMessage(message, AFUtils.CriticalityLevels.Red)
            return true
        else
            WriteErrorToConsole(OutputDevice, "Failed to get character progress component. Are you ingame?")
        end
        return false
    end)

-- Show Traits
CreateCommand({ "traits" }, "Show Traits", "Show player's Traits.", nil,
    function(self, OutputDevice, Parameters)
        local progressionComponen = AFUtils.GetMyCharacterProgressionComponent()
        if IsValid(progressionComponen) then
            WriteToConsole(OutputDevice, "Your Traits (" .. #progressionComponen.Traits .. "):")
            for i = 1, #progressionComponen.Traits do
                local trait = progressionComponen.Traits[i]
                local traitName = trait:ToString()
                local traitDesc = AFUtils.Traits[traitName]
                local output = "  " .. traitName .. " -> "
                if traitDesc then
                    output = output .. traitDesc
                else
                    output = output .. "Unknown Trait"
                end
                WriteToConsole(OutputDevice, output)
            end
            return true
        end
        return false
    end)

-- Master Key Command
CreateCommand({ "masterkey", "key", "keys", "opendoor", "opendoors" }, "Master Key",
    "Allows to open all doors (host only)", nil,
    function(self, OutputDevice, Parameters)
        Settings.MasterKey = not Settings.MasterKey
        PrintCommandState(Settings.MasterKey, self.Name, OutputDevice)
        return true
    end,
    "MasterKey")

-- Set Next Weather Command
CreateCommand({ "setweather", "nextweather", "weatherevent", "weather" }, "Weather Event",
    "Sets weather event for the next day (host only)",
    CreateCommandParam("weather", "string", "", false, { "None", "Fog", "RadLeak", "Spores" }),
    function(self, OutputDevice, Parameters)
        if not Parameters or #Parameters < 1 then
            local weatherNames = ""
            for i, rowName in ipairs(WeatherManager.GetAllWeatherEventNames()) do
                if i > 1 then
                    weatherNames = weatherNames .. ", "
                end
                weatherNames = weatherNames .. rowName
            end
            WriteToConsole(OutputDevice, "Posible weather events: " .. weatherNames)
            return false
        end

        local weather = WeatherManager.SetNextWeatherEvent(Parameters[1])
        if weather then
            local message = "Set weather for the next day to " .. weather
            WriteToConsole(OutputDevice, message)
            AFUtils.ClientDisplayWarningMessage(message, AFUtils.CriticalityLevels.Green)
        else
            WriteErrorToConsole(OutputDevice, "Couldn't find any weather events with name: " .. Parameters[1])
        end

        return true
    end)

-- Reset Portal Worlds Command
CreateCommand({ "resetportals", "resetportal", "resetworlds", "resetportalworlds", "resetvignettes" }, "Reset Portal Worlds", "Resets Portal Worlds (host only)", nil,
    function(self, OutputDevice, Parameters)
        local gameInstance = AFUtils.GetGameInstance()
        if IsValid(gameInstance) then
            gameInstance:ResetVignettes()
            local message = "Reset Portal Worlds"
            WriteToConsole(OutputDevice, message)
            AFUtils.ClientDisplayWarningMessage(message, AFUtils.CriticalityLevels.Green)
        else
            WriteErrorToConsole(OutputDevice, "Couldn't get game instance object")
        end

        return true
    end)

-- Set Time
CreateCommand({ "settime" }, "Set Time", "Set game's time in 24-hour format (0-23:0-59). (host only)", nil,
    function(self, OutputDevice, Parameters)
        local hours = nil
        local minutes = nil
        if Parameters and #Parameters > 0 then
            hours, minutes = string.match(Parameters[1], "(%d+):(%d+)")
            hours = tonumber(hours)
            minutes = tonumber(minutes)
        end
        if not hours or not minutes or hours < 0 or hours > 23 or minutes < 0 or minutes >= 60 then
            WriteErrorToConsole(OutputDevice, 'Invalid parameter. The command requires a parameter which represents time in 24h format.')
            WriteErrorToConsole(OutputDevice, 'Time format: "0-23:0-59" -> Example: "settime 18:30" (6:30 PM).')
            return false
        end

        if AFUtils.SetGameTime(hours, minutes) then
            WriteToConsole(OutputDevice, 'Time set to ' .. hours .. ":" .. minutes)
        else
            WriteErrorToConsole(OutputDevice, 'Failed to set time. Are you in the game and the host?')
            return false
        end

        return true
    end)

-- Kill All Enemies Command
CreateCommand({ "killall", "killnpc", "killnpcs", "killallnpc", "killallnpcs", "killallenemies", "killenemies" }, "Kill All Enemies", "Kill all enemy NPCs in your vicinity. (host only)", nil,
    function(self, OutputDevice, Parameters)
        local npcs = FindAllOf("NPC_Base_ParentBP_C") ---@type ANPC_Base_ParentBP_C[]?
        if npcs and #npcs > 0 then
            local killCount = 0
            for _, npc in ipairs(npcs) do
                if not npc.IsDead then
                    npc.IsDead = true
                    npc:OnRep_IsDead()
                    npc:DropLoot()
                    killCount = killCount + 1
                end
            end
            WriteToConsole(OutputDevice, killCount .. " NPCs were put to sleep.")
        else
            WriteToConsole(OutputDevice, "No hostile NPCs found in your vicinity.")
        end

        return true
    end)

-- Spawn All Enemies Command
CreateCommand({ "spawnall", "spawnnpc", "spawnnpcs", "spawnallnpc", "spawnallnpcs", "spawnallenemies", "spawnenemies" }, "Spawn All Enemies", "Respawn all enemy NPCs in your vicinity. (host only)", nil,
    function(self, OutputDevice, Parameters)
        local npcSpawns = FindAllOf("Abiotic_NPCSpawn_ParentBP_C") ---@type AAbiotic_NPCSpawn_ParentBP_C[]?
        if npcSpawns and #npcSpawns > 0 then
            local spawnCount = 0
            for _, spawn in ipairs(npcSpawns) do
                local isNight = spawn.AllowableSpawnHours == 2 and true or false
                local outSuccess = { Success = false }
                spawn:TrySpawnNPCNew(isNight, true, false, outSuccess, {}, {}, {})
                if outSuccess.Success == true then
                    spawnCount = spawnCount + 1
                end
            end
            WriteToConsole(OutputDevice, spawnCount .. " NPCs were spawned.")
        else
            WriteToConsole(OutputDevice, "No NPC Spawns found in your vicinity.")
        end

        return true
    end)

-- Set Inventory Size Command
-- CreateCommand({ "invsize", "inventorysize", "invslotcount", "backpacksize", "bpsize", "bpslotcount" }, "Set Inventory Size", "Changes inventory size / slots count.\nWarning! Each time you load into the game the game restores the slot count and all items in extra slots will be dropped on the ground.", 
--     CreateCommandParam("slot count", "number", "Size / Slot count", false, "Between -1 and 100 (-1 will disable the feature)"),
--     function(self, OutputDevice, Parameters)
--         if not Parameters or #Parameters < 1 then
--             local myInventoryComponent = AFUtils.GetMyInventoryComponent()
--             if myInventoryComponent then
--                 WriteToConsole(OutputDevice, "Current inventory slot count: " .. myInventoryComponent.MaxSlots)
--                 WriteToConsole(OutputDevice, "Type \"invsize 42\" to change the inventory size to 42.")
--                 WriteToConsole(OutputDevice, "Type \"invsize -1\" to disable the feature!")
--             else
--                 WriteErrorToConsole(OutputDevice, "Couldn't get current inventory component!")
--             end
--             return true
--         end

--         local slotCount = tonumber(Parameters[1])
--         if slotCount and slotCount <= 100 then
--             if slotCount < 1 then
--                 Settings.InventorySlotCount = -1
--                 local message = "Inventory Size Disabled"
--                 LogDebug(message)
--                 AFUtils.ClientDisplayWarningMessage(message, AFUtils.CriticalityLevels.Red)
--             else
--                 Settings.InventorySlotCount = slotCount
--             end
--         else
--             WriteErrorToConsole(OutputDevice, "The \"slout count\" parameter has to be a number between -1 and 100!")
--         end

--         return true
--     end)

-- List Locations Command
CreateCommand({ "locations", "showloc", "showlocations", "loc", "locs" }, "List Locations", "Shows all saved locations",
    nil,
    function(self, OutputDevice, Parameters)
        local locations = LocationsManager.ToStringArray()
        WriteToConsole(OutputDevice, "Saved locations:")
        for _, value in ipairs(locations) do
            WriteToConsole(OutputDevice, value)
        end
        WriteToConsole(OutputDevice, "--------------------")
        return true
    end,
    "Locations")

-- Save Location Command
CreateCommand({ "savelocation", "saveloc", "setloc", "wp", "savewp", "setwp", "waypoint", "setwaypoint", "savewaypoint" },
    "Save Location", "Saves your current position and rotation under an assigned name",
    CreateCommandParam("name", "string", "Name of the location"),
    function(self, OutputDevice, Parameters)
        if not Parameters or #Parameters < 1 then
            WriteErrorToConsole(OutputDevice, "Invalid number of parameters!")
            WriteToConsole(OutputDevice, "The command requires a \"name\" paramter. e.g. 'saveloc Cafeteria'")
            return false
        end
        
        local locationName = CombineParameters(Parameters)
        local location = LocationsManager.SaveCurrentLocation(locationName)
        if location then
            SettingsManager.SaveToFile()
            WriteToConsole(OutputDevice, "Location saved: " .. LocationToString(location))
        else
            WriteErrorToConsole(OutputDevice, "Failed to save location")
        end
        return true
    end)

-- Load Location Command
CreateCommand({ "loadlocation", "loadloc", "loadwp", "tp", "goto", "loadwaypoint", "teleport" }, "Load Location",
    "Teleports you to a named location that was previously saved (host only)",
    CreateCommandParam("name", "string", "Name of the location"),
    function(self, OutputDevice, Parameters)
        if not Parameters or #Parameters < 1 then
            WriteErrorToConsole(OutputDevice, "Invalid number of parameters!")
            WriteToConsole(OutputDevice, "The command requires a \"name\" paramter. e.g. 'loadloc Cafeteria'")
            return false
        end

        local locationName = CombineParameters(Parameters)
        if not LocationsManager.LoadLocation(locationName) then
            WriteErrorToConsole(OutputDevice, "Failed to load location")
        end
        return true
    end)

-- List Player Command
CreateCommand({ "playerlist", "listplayers", "players" }, "Player List",
    "Prints a list of all players in the game. Format: (index): (player name)", nil,
    function(self, OutputDevice, Parameters)
        local playerNames = PlayersManager.GetPlayerNames()
        if playerNames and #playerNames > 0 then
            WriteToConsole(OutputDevice, string.format("-- Players (%d) --", #playerNames))
            for index, name in ipairs(playerNames) do
                WriteToConsole(OutputDevice, string.format(" %d: %s", index, name))
            end
        end

        return true
    end)

-- Teleport To Player Command
CreateCommand({ "toplayer", "teleportto", "tpto" }, "Teleport To Player", "Teleports to a player based on their name or index (host only)",
    CreateCommandParam("name/index", "string", "Name or index of a player"),
    function(self, OutputDevice, Parameters)
        if not Parameters or #Parameters < 1 then
            WriteErrorToConsole(OutputDevice, "Invalid number of parameters!")
            WriteToConsole(OutputDevice, "The command requires part of player's name or his index. e.g. 'tpto igromanru'")
            WriteToConsole(OutputDevice, "Use the player list command to get a list of all players in the lobby. e.g. 'players'")
            return true
        end
        
        local player, playerName = GetPlayerByNameOrIndex(OutputDevice, Parameters[1])
        if player then
            local myPlayer = AFUtils.GetMyPlayer()
            WriteToConsole(OutputDevice, "Teleporting to \"" .. playerName .. '"')
            if not AFUtils.TeleportPlayerToPlayer(myPlayer, player, true) then
                WriteErrorToConsole(OutputDevice, "Teleportation failed, are you the host?")
            end
        end

        return true
    end)

-- Teleport To Me Command
CreateCommand({ "tome", "teleporttome", "pull" }, "Teleport To Me",
    "Teleports a player to yourself based on their name or index (host only)",
    CreateCommandParam("name/index", "string", "Name or index of a player"),
    function(self, OutputDevice, Parameters)
        if not Parameters or #Parameters < 1 then
            WriteErrorToConsole(OutputDevice, "Invalid number of parameters!")
            WriteToConsole(OutputDevice, "The command requires part of player's name or his index. e.g. 'tome igromanru'")
            return false
        end
        local player, playerName = GetPlayerByNameOrIndex(OutputDevice, Parameters[1])
        if player then
            local myPlayer = AFUtils.GetMyPlayer()
            WriteToConsole(OutputDevice, "Teleporting \"" .. playerName .. '" to you')
            if not AFUtils.TeleportPlayerToPlayer(player, myPlayer) then
                WriteErrorToConsole(OutputDevice, "Teleportation failed, are you the host?")
            end
        end

        return true
    end)

-- Kill Player Command
CreateCommand({ "smite", "kill", "execute" }, "Kill Player", "Kills a player based on their name or index (host only)",
    CreateCommandParam("name/index", "string", "Name or index of a player"),
    function(self, OutputDevice, Parameters)
        if not Parameters or #Parameters < 1 then
            WriteErrorToConsole(OutputDevice, "Invalid number of parameters!")
            WriteToConsole(OutputDevice, "The command requires part of player's name or his index. e.g. 'smite igromanru'")
            return false
        end
        local player, playerName = GetPlayerByNameOrIndex(OutputDevice, Parameters[1])
        if player then
            WriteToConsole(OutputDevice, "Killing \"" .. playerName .. "\".")
            player.IsDead = true
            player:OnRep_IsDead()
        end

        return true
    end)

-- Revive Player Command
CreateCommand({ "revive", "res", "resurrect" }, "Revive Player", "Revive a dead palyer (host only)",
    CreateCommandParam("name/index", "string", "Name or index of a player"),
    function(self, OutputDevice, Parameters)
        if not Parameters or #Parameters < 1 then
            WriteErrorToConsole(OutputDevice, "Invalid number of parameters!")
            WriteToConsole(OutputDevice, "The command requires part of player's name or his index. e.g. 'revive igromanru'")
            return false
        end
        local player, playerName = GetPlayerByNameOrIndex(OutputDevice, Parameters[1])
        if player then
            if player.IsDead then
                WriteToConsole(OutputDevice, "Reviving \"" .. playerName .. "\".")
                player.IsDead = false
                player:OnRep_IsDead()
            else
                WriteToConsole(OutputDevice, "Player \"" .. playerName .. "\" is not dead.")
            end
        end

        return true
    end)

-- Give Skill Experience to a Player
CreateCommand({ "givexp" }, "Give Skill Experience to Player", "Gives Skill XP to a player (host only)",
    {
        CreateCommandParam("name/index", "string", "Name or index of a player"),
        CreateCommandParam("skill alias", "string", "Skill's alias", true, Skills.GetSkillsAsStrings()),
        CreateCommandParam("XP value", "number", "Amount of XP added to the skill.")
    },
    function(self, OutputDevice, Parameters)
        if not Parameters or #Parameters < 2 then
            WriteErrorToConsole(OutputDevice, "Invalid number of parameters!")
            WriteToConsole(OutputDevice, "The command requires part of player's name or his index, skill's alias and amount of XP to add. e.g. 'givexp igromanru stealth 1000'")
            WriteToConsole(OutputDevice, "Use the player list command to get a list of all players in the lobby. e.g. 'players'")
            return true
        end
        local skill = Skills.GetSkillByAlias(Parameters[2])
        if not skill then
            WriteErrorToConsole(OutputDevice, 'Invalid skill alias. Use command "help givexp" to see all valid skill parameters')
            return true
        end

        local player, playerName = GetPlayerByNameOrIndex(OutputDevice, Parameters[1])
        if player then
            local xpToAdd = nil
            if #Parameters > 2 then
                xpToAdd = tonumber(Parameters[3])
            end
            if xpToAdd then
                if Skills.AddXp(player, skill.Id, xpToAdd) then
                    local message = skill.Name .. " " .. tostring(xpToAdd) .. " XP added to " .. playerName
                    WriteToConsole(OutputDevice, message)
                    AFUtils.DisplayWarningMessage(message, AFUtils.CriticalityLevels.Green)
                else
                    WriteToConsole(OutputDevice, "Failed to add " .. skill.Name .. " " .. tostring(xpToAdd) .. " XP to " .. playerName)
                    WriteToConsole(OutputDevice, "The reason might be that the XP is maxed out.")
                end
            else
                local skillStruct = Skills.GetCharacterSkillStructById(player, skill.Id)
                if skillStruct then
                    WriteToConsole(OutputDevice, playerName .. "'s Skill: " .. skill.Name .. ", Current value: " .. math.ceil(skillStruct.CurrentSkillXP_20_8F7934CD4A4542F036AE5C9649362556))
                else
                    WriteErrorToConsole(OutputDevice, "Couldn't get values for " .. playerName .. "'s Skill: " .. skill.Id)
                end
            end
        else
            WriteErrorToConsole(OutputDevice, "Couldn't find the palyer")
        end

        return true
    end)

-- Remove All Skill XP from a player
CreateCommand({ "takexp" }, "Remove Skill Experience from Player", "Remove All Skill XP from a player (host only)",
    {
        CreateCommandParam("name/index", "string", "Name or index of a player"),
        CreateCommandParam("skill alias", "string", "Skill's alias", true, Skills.GetSkillsAsStrings())
    },
    function(self, OutputDevice, Parameters)
        if not Parameters or #Parameters < 2 then
            WriteErrorToConsole(OutputDevice, "Invalid number of parameters!")
            WriteToConsole(OutputDevice, "The command requires part of player's name or his index and skill's alias. e.g. 'takexp igromanru stealth'")
            WriteToConsole(OutputDevice, "Use the player list command to get a list of all players in the lobby. e.g. 'players'")
            return true
        end
        local skill = Skills.GetSkillByAlias(Parameters[2])
        if not skill then
            WriteErrorToConsole(OutputDevice, 'Invalid skill alias. Use command "help takexp" to see all valid skill parameters')
            return true
        end

        local player, playerName = GetPlayerByNameOrIndex(OutputDevice, Parameters[1])
        if player then
            if Skills.RemoveXp(player, skill.Id) then
                local message = "Removed all " .. skill.Name .. " XP from " .. playerName
                WriteToConsole(OutputDevice, message)
                AFUtils.DisplayWarningMessage(message, AFUtils.CriticalityLevels.Red)
            else
                WriteErrorToConsole(OutputDevice, "Couldn't find character progress component")
            end
        else
            WriteErrorToConsole(OutputDevice, "Couldn't find the palyer")
        end

        return true
    end)

-- Speedhack Command
CreateCommand({ "speedhack", "speedmulti", "speedscale" }, "Speedhack", "Sets a speed multiplier for your character's Walk and Sprint speed. (Default speed: 1.0) (host only)",
CreateCommandParam("multiplier/scale", "number", "Speed scale/multiplier. A float value between 0.1 and 10.0"),
function(self, OutputDevice, Parameters)
    if not Parameters or #Parameters < 1 then
        WriteToConsole(OutputDevice, "Current multiplier is set to: " .. Settings.SpeedhackMultiplier)
        WriteToConsole(OutputDevice, "The command requires a value by which the speed will be multiplied. e.g. 'speedhack 1.5'")
        return true
    end
    local multiplier = tonumber(Parameters[1])
    if not multiplier or multiplier < 0.1 or multiplier > 10  then
        WriteErrorToConsole(OutputDevice, "The required paramter must be a float value between 0.1 and 10")
        WriteToConsole(OutputDevice, "The command requires a value by which the speed will be multiplied. e.g. 'speedhack 1.5'")
        return true
    end
    Settings.SpeedhackMultiplier = multiplier
    WriteToConsole(OutputDevice, "Execute " .. self.Name .. " command with value: " .. multiplier)
    return true
end,
"SpeedhackMultiplier")

-- Player Gravity Scale Command
CreateCommand({ "playergravity", "playergrav", "pg", "setpg" }, "Player Gravity Scale", "Sets player's gravity scale. (Default scale: 1.0) (host only)",
CreateCommandParam("scale", "number", "Gravity scale/multiplier. A float value between 0.1 and 2.0"),
function(self, OutputDevice, Parameters)
    if not Parameters or #Parameters < 1 then
        WriteToConsole(OutputDevice, "Current scale is set to: " .. Settings.PlayerGravityScale)
        WriteToConsole(OutputDevice, "The command requires a value by which the gravity will be multiplied. e.g. 'pg 0.5'")
        return true
    end
    local multiplier = tonumber(Parameters[1])
    if not multiplier or multiplier < 0.1 or multiplier > 2  then
        WriteErrorToConsole(OutputDevice, "The required paramter must be a float value between 0.1 and 2")
        WriteToConsole(OutputDevice, "The command requires a value by which the gravity will be multiplied. e.g. 'pg 0.5'")
        return true
    end
    Settings.PlayerGravityScale = multiplier
    WriteToConsole(OutputDevice, "Execute " .. self.Name .. " command with value: " .. multiplier)
    return true
end,
"PlayerGravityScale")

-- Send to Distant Shore Command
CreateCommand({ "DistantShore", "dshore", "portalwc" }, "Send to Distant Shore", "Sends player to Distant Shore if [REDACTED] is deployed/placed. (host only)", nil,
    function(self, OutputDevice, Parameters)
        Settings.DistantShore = not Settings.DistantShore
        AFUtils.DisplayWarningMessage(PrintCommandState(Settings.DistantShore, self.Name, OutputDevice), AFUtils.CriticalityLevels.Green)
        return true
    end,
    "DistantShore")

-- Delete Object Trace Command
CreateCommand({ "deleteobject", "removeobject" }, "Delete Object Trace", "Deletes an object in front of you (up to 10 meters). (Aim carefully, the object will be gone for good) (host only)", nil,
    function(self, OutputDevice, Parameters)
        if CheckAndLogDedicatedServerCommandSupport(OutputDevice) then
            return false
        end

        local hitActor = ForwardLineTraceByChannel(3, 10)
        if hitActor:IsValid() then
            local actor = nil ---@type AActor
            LogDebug("HitActor: " .. hitActor:GetFullName())
            LogDebug("ClassName: " .. hitActor:GetClass():GetFullName())
            
            if hitActor:IsA(GetStaticClassActor()) or hitActor:IsA(GetStaticClassSkeletalMeshActor()) then
                ---@cast hitActor AActor
                actor = hitActor
            end
            if hitActor:IsA(GetStaticClassStaticMeshComponent()) or hitActor:IsA(GetStaticClassSkeletalMeshComponent()) then
                ---@cast hitActor UMeshComponent
                actor = hitActor:GetOwner()
            end
            if actor and actor:IsValid() then
                WriteToConsole(OutputDevice, "Deleting actor: " .. actor:GetFullName())
                WriteToConsole(OutputDevice, "Actor's class: " .. actor:GetClass():GetFullName())
                actor:K2_DestroyActor()
            end
        end
        return true
    end)

RegisterProcessConsoleExecPreHook(function(Context, Command, Parameters, OutputDevice, Executor)
    local context = Context:get()
    -- local executor = Executor:get()
    
    -- if DebugMode then
    --     LogDebug("[ProcessConsoleExec]:")
    --     LogDebug("Context: " .. context:GetFullName())
    --     LogDebug("Context.Class: " .. context:GetClass():GetFullName())
    --     LogDebug("Command: " .. Command)
    --     LogDebug("Parameters: " .. #Parameters)
    --     for i = 1, #Parameters, 1 do
    --         LogDebug("  " .. i .. ": " .. Parameters[i])
    --     end
    --     -- if executor:IsValid() then
    --     --     LogDebug("Executor: " .. executor:GetClass():GetFullName())
    --     -- end
    -- end

    -- local IsDedicatedServer = AFUtils.IsDedicatedServer()
    if (IsDedicatedServer and not context:IsA(AFUtils.GetClassAbiotic_Survival_GameMode_C())) or (not IsDedicatedServer and not context:IsA(AFUtils.GetClassAbioticGameViewportClient()))  then
        return nil
    end

    local command = string.match(Command, "^%S+")
    if #Parameters > 0 and Parameters[1] == command then
        table.remove(Parameters, 1)
    end

    -- Special handling of default commands
    if not IsDedicatedServer and (command == "god" or command == "ghost" or command == "fly" or command == "teleport") then
        LogDebug("Default command, skip")
        return nil
    end

    local commandObj = GetCommandByAlias(command)
    if commandObj then
        if commandObj.Function ~= nil then
            commandObj.Function(commandObj, OutputDevice, Parameters)
            OutputDevice:Log("-- Ignore the message below, it comes from UE:")
        end
        return true
    end
    -- LogDebug("------------------------")

    return nil
end)

-- Overwriting default UE commands (most aren't made for the game and causes issues)
------------------------------------------------------------
if not AFUtils.IsDedicatedServer() then
    RegisterConsoleCommandGlobalHandler("god", function(FullCommand, Parameters, OutputDevice)
        local godMode = GetCommandByAlias("God Mode")
        if godMode and godMode.Function then
            godMode.Function(godMode, OutputDevice, Parameters)
        end
        return true
    end)
    
    RegisterConsoleCommandGlobalHandler("ghost", function(FullCommand, Parameters, OutputDevice)
        local noClip = GetCommandByAlias("No Clip")
        if noClip and noClip.Function then
            noClip.Function(noClip, OutputDevice, Parameters)
        end
        return true
    end)
    
    RegisterConsoleCommandGlobalHandler("fly", function(FullCommand, Parameters, OutputDevice)
        local noClip = GetCommandByAlias("No Clip")
        if noClip and noClip.Function then
            noClip.Function(noClip, OutputDevice, Parameters)
        end
        return true
    end)
    
    RegisterConsoleCommandGlobalHandler("teleport", function(FullCommand, Parameters, OutputDevice)
        local loadLocation = GetCommandByAlias("Load Location")
        if loadLocation and loadLocation.Function then
            loadLocation.Function(loadLocation, OutputDevice, Parameters)
        end
        return true
    end)
end

-- if DebugMode then
--     LogDebug(string.format("-- CommandsArray (%d) --", #CommandsArray))
--     for index, value in ipairs(CommandsArray) do
--         LogDebugCommandStruct(value, index .. ": ")
--     end
--     LogDebug("-- CommandsMap --")
--     local count = 1
--     for key, value in pairs(CommandsMap) do
--         LogDebugCommandStruct(value, key .. ": ")
--         count = count + 1
--     end
--     LogDebug(string.format("-- CommandsMap Count: %d --", count))
-- end
