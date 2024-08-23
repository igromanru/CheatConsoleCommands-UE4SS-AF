
local function StructCommand(CommandNames, Description)
    if type(CommandNames) == "string" then
        CommandNames = { CommandNames }
    end
    return {
        Names = CommandNames,
        Description = Description
    }
end

local Commands = {
    Help = StructCommand("help", "Shows mod details and possible commands"),
    God = StructCommand({"god", "godmode"}, "God Mode: Makes the player invincible and keeps all his stats at maximum (Health, Stamina, Hunger, Thirst, Fatigue, Continence)"),
    InfiniteHealth = StructCommand({"health", "infhp", "infhealth"}, "Infinite Health"),
    InfiniteStamina = StructCommand({"stamina", "infsp", "infstamina"}, "Infinite Stamina"),
    NoHunger = StructCommand({"hunger", "nohunger"}, "No Hunger"),
    NoThirst = StructCommand({"thirst", "nothirst"}, "No Thirst"),
    NoFatigue = StructCommand({"fat", "fatigue", "nofatigue"}, "No Fatigue"),
    NoContinence = StructCommand({"con", "continence", "nocontinence"}, "No Continence"),
}

local function RegisterConsoleCommand(Command, Callback)
    if type(Command) == "table" and Command.Names and type(Callback) == "function" then
        for _, commandName in ipairs(Command.Names) do
            if type(commandName) == "string" then
                RegisterConsoleCommandGlobalHandler(commandName, Callback)
            end
        end 
    end
end 


-- Help Command
RegisterConsoleCommand(Commands.Help, function(FullCommand, Parameters, OutputDevice)
    return true
end)

-- God Mode Command
RegisterConsoleCommand(Commands.God, function(FullCommand, Parameters, OutputDevice)
    return true
end)

-- Infinite Health Command
RegisterConsoleCommand(Commands.InfiniteHealth, function(FullCommand, Parameters, OutputDevice)
    return true
end)

-- Infinite Stamina Command
RegisterConsoleCommand(Commands.InfiniteStamina, function(FullCommand, Parameters, OutputDevice)
    return true
end)

-- No Hunger Command
RegisterConsoleCommand(Commands.NoHunger, function(FullCommand, Parameters, OutputDevice)
    return true
end)

-- No Thirst Command
RegisterConsoleCommand(Commands.NoThirst, function(FullCommand, Parameters, OutputDevice)
    return true
end)

-- No Fatigue Command
RegisterConsoleCommand(Commands.NoFatigue, function(FullCommand, Parameters, OutputDevice)
    return true
end)

-- No Continence Command
RegisterConsoleCommand(Commands.NoContinence, function(FullCommand, Parameters, OutputDevice)
    return true
end)