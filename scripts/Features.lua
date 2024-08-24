
local Settings = require("Settings")

local function HealAllLimbs(playerCharacter)
    for i = 1, 6, 1 do
        local outSuccess = {}
        playerCharacter:Server_HealRandomLimb(100.0, outSuccess)
    end
end

local GodModeWasEnabled = false
function GodMode(myPlayer)
    if not myPlayer then return end

    if Settings.GodMode then
        if myPlayer.Invincible then
            GodModeWasEnabled = true
            myPlayer.Invincible = true
            LogDebug("Invincible: " .. tostring(myPlayer.Invincible))
        end
    elseif GodModeWasEnabled then
        GodModeWasEnabled = false
        myPlayer.Invincible = false
        LogDebug("Invincible: " .. tostring(myPlayer.Invincible))
    end
end

function Heal(myPlayer)
    if not myPlayer then return end

    if Settings.Heal then
        HealAllLimbs(myPlayer)
        Settings.Heal = false
    end
end


local InfiniteHealthWasEnabled = false
function InfiniteHealth(myPlayer)
    if not myPlayer then return end

    if Settings.InfiniteHealth then
        InfiniteHealthWasEnabled = true
        if not myPlayer.Invincible then
            myPlayer.Invincible = true
            HealAllLimbs(myPlayer)
            LogDebug("Invincible: " .. tostring(myPlayer.Invincible))
            LogDebug("CurrentHealth_Head: " .. tostring(myPlayer.CurrentHealth_Head))
            LogDebug("CurrentHealth_Torso: " .. tostring(myPlayer.CurrentHealth_Torso))
            LogDebug("CurrentHealth_LeftArm: " .. tostring(myPlayer.CurrentHealth_LeftArm))
            LogDebug("CurrentHealth_RightArm: " .. tostring(myPlayer.CurrentHealth_RightArm))
            LogDebug("CurrentHealth_LeftLeg: " .. tostring(myPlayer.CurrentHealth_LeftLeg))
            LogDebug("CurrentHealth_RightLeg: " .. tostring(myPlayer.CurrentHealth_RightLeg))
        end
    elseif InfiniteHealthWasEnabled then
        InfiniteHealthWasEnabled = false
        myPlayer.Invincible = false
        LogDebug("Invincible: " .. tostring(myPlayer.Invincible))
    end
end

local InfiniteStaminaWasEnabled = false
function InfiniteStamina(myPlayer)
    if not myPlayer then return end

    if Settings.InfiniteStamina then
        InfiniteStaminaWasEnabled = true
        if not myPlayer.InfiniteStamina then
            myPlayer.InfiniteStamina = true
            myPlayer.CurrentStamina = myPlayer.MaxStamina
            LogDebug("InfiniteStamina: " .. tostring(myPlayer.InfiniteStamina))
            LogDebug("CurrentStamina: " .. tostring(myPlayer.CurrentStamina))
            LogDebug("MaxStamina: " .. tostring(myPlayer.MaxStamina))
        end
    elseif InfiniteStaminaWasEnabled then
        InfiniteStaminaWasEnabled = false
        myPlayer.InfiniteStamina = false
        LogDebug("InfiniteStamina: " .. tostring(myPlayer.InfiniteStamina))
    end
end

local NoHungerWasEnabled = false
function NoHunger(myPlayer)
    if not myPlayer then return end

    if Settings.NoHunger then
        NoHungerWasEnabled = true
        if myPlayer.HasHunger == true then
            myPlayer.HasHunger = false
            myPlayer.CurrentHunger = myPlayer.MaxHunger
            myPlayer:OnRep_CurrentHunger()
            LogDebug("HasHunger: " .. tostring(myPlayer.HasHunger))
            LogDebug("CurrentHunger: " .. tostring(myPlayer.CurrentHunger))
            LogDebug("MaxHunger: " .. tostring(myPlayer.MaxHunger))
        end
    elseif NoHungerWasEnabled then
        NoHungerWasEnabled = false
        myPlayer.HasHunger = true
        LogDebug("HasHunger: " .. tostring(myPlayer.HasHunger))
    end
end

local NoThirstWasEnabled = false
function NoThirst(myPlayer)
    if not myPlayer then return end

    if Settings.NoThirst then
        NoThirstWasEnabled = true
        if myPlayer.HasThirst == true then
            myPlayer.HasThirst = false
            myPlayer.CurrentThirst = myPlayer.MaxThirst
            myPlayer:OnRep_CurrentThirst()
            LogDebug("HasThirst: " .. tostring(myPlayer.HasThirst))
            LogDebug("CurrentThirst: " .. tostring(myPlayer.CurrentThirst))
            LogDebug("MaxThirst: " .. tostring(myPlayer.MaxThirst))
        end
    elseif NoThirstWasEnabled then
        NoThirstWasEnabled = false
        myPlayer.HasThirst = true
        LogDebug("HasThirst: " .. tostring(myPlayer.HasThirst))
    end
end

local NoFatigueWasEnabled = false
function NoFatigue(myPlayer)
    if not myPlayer then return end

    if Settings.NoFatigue then
        NoFatigueWasEnabled = true
        if myPlayer.HasFatigue == true then
            myPlayer.HasFatigue = false
            myPlayer.CurrentFatigue = 0.0
            myPlayer:OnRep_CurrentFatigue()
            LogDebug("HasFatigue: " .. tostring(myPlayer.HasFatigue))
            LogDebug("CurrentFatigue: " .. tostring(myPlayer.CurrentFatigue))
            LogDebug("MaxFatigue: " .. tostring(myPlayer.MaxFatigue))
        end
    elseif NoFatigueWasEnabled then
        NoFatigueWasEnabled = false
        myPlayer.HasFatigue = true
        LogDebug("HasFatigue: " .. tostring(myPlayer.HasFatigue))
    end
end

local NoContinenceWasEnabled = false
function NoContinence(myPlayer)
    if not myPlayer then return end

    if Settings.NoContinence then
        NoContinenceWasEnabled = true
        if myPlayer.HasContinence == true then
            myPlayer.HasContinence = false
            myPlayer.CurrentContinence = myPlayer.MaxContinence
            myPlayer:OnRep_CurrentContinence()
            LogDebug("HasContinence: " .. tostring(myPlayer.HasContinence))
            LogDebug("CurrentContinence: " .. tostring(myPlayer.CurrentContinence))
            LogDebug("MaxContinence: " .. tostring(myPlayer.MaxContinence))
        end
    elseif NoContinenceWasEnabled then
        NoContinenceWasEnabled = false
        myPlayer.HasContinence = true
        LogDebug("HasContinence: " .. tostring(myPlayer.HasContinence))
    end
end

local NoRadiationWasEnabled = false
function NoRadiation(myPlayer)
    if not myPlayer then return end

    if Settings.NoRadiation then
        NoRadiationWasEnabled = true
        if myPlayer.CanReceiveRadiation == true then
            myPlayer.CanReceiveRadiation = false
            myPlayer.CurrentRadiation = 0.0
            myPlayer:OnRep_CurrentContinence()
            LogDebug("CanReceiveRadiation: " .. tostring(myPlayer.CanReceiveRadiation))
            LogDebug("CurrentRadiation: " .. tostring(myPlayer.CurrentRadiation))
            LogDebug("MaxRadiation: " .. tostring(myPlayer.MaxRadiation))
        end
    elseif NoRadiationWasEnabled then
        NoRadiationWasEnabled = false
        myPlayer.CanReceiveRadiation = true
        LogDebug("CanReceiveRadiation: " .. tostring(myPlayer.CanReceiveRadiation))
    end
end

local FreeCraftingWasEnabled = false
function FreeCrafting(myPlayer)
    if not myPlayer then return end

    if Settings.FreeCrafting then
        FreeCraftingWasEnabled = true
        if not myPlayer.Debug_FreeCrafting then
            myPlayer.Debug_FreeCrafting = true
            LogDebug("Debug_FreeCrafting: " .. tostring(myPlayer.Debug_FreeCrafting))
        end
    elseif FreeCraftingWasEnabled then
        FreeCraftingWasEnabled = false
        myPlayer.Debug_FreeCrafting = false
        LogDebug("Debug_FreeCrafting: " .. tostring(myPlayer.Debug_FreeCrafting))
    end
end

local NoFallDamageWasEnabled = false
function NoFallDamage(myPlayer)
    if not myPlayer then return end

    if Settings.NoFallDamage then
        NoFallDamageWasEnabled = true
        if myPlayer.TakeFallDamage == true then
            myPlayer.TakeFallDamage = false
            LogDebug("TakeFallDamage: " .. tostring(myPlayer.TakeFallDamage))
        end
    elseif NoFallDamageWasEnabled then
        NoFallDamageWasEnabled = false
        myPlayer.TakeFallDamage = true
        LogDebug("TakeFallDamage: " .. tostring(myPlayer.TakeFallDamage))
    end
end

local NoClipWasEnabled = false
function NoClip(myPlayer)
    if not myPlayer then return end

    if Settings.NoClip then
        NoClipWasEnabled = true
        if not myPlayer.Noclip_On then
            myPlayer.Noclip_On = true
            myPlayer:OnRep_Noclip_On()
            LogDebug("Noclip_On: " .. tostring(myPlayer.Noclip_On))
        end
    elseif NoClipWasEnabled then
        NoClipWasEnabled = false
        myPlayer.Noclip_On = false
        myPlayer:OnRep_Noclip_On()
        LogDebug("Noclip_On: " .. tostring(myPlayer.Noclip_On))
    end
end

function SetMoney(myPlayer)
    if not myPlayer then return end

    if Settings.SetMoney and Settings.MoneyValue > -1 then
        if Settings.MoneyValue ~= myPlayer.CurrentMoney then
            myPlayer.CurrentMoney = Settings.MoneyValue
            myPlayer:OnRep_CurrentMoney()
            LogDebug("CurrentMoney: " .. tostring(myPlayer.CurrentMoney))
            Settings.SetMoney = false
            Settings.MoneyValue = -1
        end
    end
end