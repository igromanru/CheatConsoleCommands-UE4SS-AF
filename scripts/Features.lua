
require("Settings")
local AFUtils = require("AFUtils.AFUtils")

local GodModeWasEnabled = false
function GodMode()
    if Settings.GodMode then
        GodModeWasEnabled = true
        local myPlayer = AFUtils.GetMyPlayer()
        if myPlayer and not myPlayer.Invincible then
            myPlayer.Invincible = true
            LogDebug("Invincible: " .. tostring(myPlayer.Invincible))
        end
    elseif GodModeWasEnabled then
        GodModeWasEnabled = false
        local myPlayer = AFUtils.GetMyPlayer()
        if myPlayer then
            myPlayer.Invincible = false
            LogDebug("Invincible: " .. tostring(myPlayer.Invincible))
        end
    end
end

local NoClipWasEnabled = false
function NoClip()
    if Settings.NoClip then
        NoClipWasEnabled = true
        local myPlayer = AFUtils.GetMyPlayer()
        if myPlayer and not myPlayer.Noclip_On then
            myPlayer.Noclip_On = true
            myPlayer:OnRep_Noclip_On()
            LogDebug("Noclip_On: " .. tostring(myPlayer.Noclip_On))
        end
    elseif NoClipWasEnabled then
        NoClipWasEnabled = false
        local myPlayer = AFUtils.GetMyPlayer()
        if myPlayer then
            myPlayer.Noclip_On = false
            myPlayer:OnRep_Noclip_On()
            LogDebug("Noclip_On: " .. tostring(myPlayer.Noclip_On))
        end
    end
end