
local AFUtils = require("AFUtils.AFUtils")

local WeatherManager = {}

local WeatherEventNames = { AFUtils.WeatherEvents.None }
---@return string[]
function WeatherManager.GetAllWeatherEventNames()
    if WeatherEventNames and #WeatherEventNames > 1 then
        return WeatherEventNames
    end

    local outRowNames = {} ---@type FName[]
    AFUtils.GetWeatherEventHandleFunctionLibrary():GetAllWeatherEventRowNames(outRowNames)
    LogDebug("GetAllWeatherEventNames: RowNames.Num: " .. #outRowNames)
    for i = 1, #outRowNames, 1 do
        local eventName = outRowNames[i]:get():ToString()
        LogDebug(i .. ": " .. eventName)
        table.insert(WeatherEventNames, eventName)
    end
    return WeatherEventNames
end

---@param Substr string
---@return string?
function WeatherManager.GetWeatherBySubstring(Substr)
    if type(Substr) ~= "string" or Substr == "" then return nil end

    if string.lower(Substr) == "none" then
        return AFUtils.WeatherEvents.None
    end

    for i, eventName in ipairs(WeatherManager.GetAllWeatherEventNames()) do
        LogDebug("GetWeatherBySubstring: EventName: " .. eventName .. ", to find: " .. Substr)
        local startIndex = string.find(string.lower(eventName), string.lower(Substr))
        LogDebug("GetWeatherBySubstring: startIndex: " .. tostring(startIndex))
        if startIndex and startIndex > 0 then
            return eventName
        end
    end
    return nil
end

---@param Substr string
---@return string?
function WeatherManager.TriggerWeatherEvent(Substr)
    local weather = WeatherManager.GetWeatherBySubstring(Substr)
    if weather and AFUtils.TriggerWeatherEvent(weather) then
        return weather
    end
    return nil
end

---@param Substr string
---@return string?
function WeatherManager.SetNextWeatherEvent(Substr)
    local weather = WeatherManager.GetWeatherBySubstring(Substr)
    if weather and AFUtils.SetNextWeatherEvent(weather) then
        return weather
    end
    return nil
end

return WeatherManager