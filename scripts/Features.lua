
require("Settings")

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


local InfiniteHealthWasEnabled = false
function InfiniteHealth(myPlayer)
    if not myPlayer then return end

    if Settings.InfiniteHealth then
        if not myPlayer.Invincible then
            InfiniteHealthWasEnabled = true
            myPlayer.Invincible = true
            for i = 1, 6, 1 do
                local outSuccess = {}
                myPlayer:Server_HealRandomLimb(100.0, outSuccess)
            end
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
        if not myPlayer.InfiniteStamina then
            InfiniteStaminaWasEnabled = true
            myPlayer.InfiniteStamina = true
            LogDebug("InfiniteStamina: " .. tostring(myPlayer.InfiniteStamina))
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
        if myPlayer.HasHunger == true then
            NoHungerWasEnabled = true
            myPlayer.HasHunger = false
            LogDebug("HasHunger: " .. tostring(myPlayer.HasHunger))
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
        if myPlayer.HasThirst == true then
            NoThirstWasEnabled = true
            myPlayer.HasThirst = false
            LogDebug("HasThirst: " .. tostring(myPlayer.HasThirst))
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
        if myPlayer.HasFatigue == true then
            NoFatigueWasEnabled = true
            myPlayer.HasFatigue = false
            LogDebug("HasFatigue: " .. tostring(myPlayer.HasFatigue))
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
        if myPlayer.HasContinence == true then
            NoContinenceWasEnabled = true
            myPlayer.HasContinence = false
            LogDebug("HasContinence: " .. tostring(myPlayer.HasContinence))
        end
    elseif NoContinenceWasEnabled then
        NoContinenceWasEnabled = false
        myPlayer.HasContinence = true
        LogDebug("HasContinence: " .. tostring(myPlayer.HasContinence))
    end
end

local FreeCraftingWasEnabled = false
function FreeCrafting(myPlayer)
    if not myPlayer then return end

    if Settings.FreeCrafting then
        if not myPlayer.Debug_FreeCrafting then
            FreeCraftingWasEnabled = true
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
        if myPlayer.TakeFallDamage == true then
            NoFallDamageWasEnabled = true
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
        if not myPlayer.Noclip_On then
            NoClipWasEnabled = true
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