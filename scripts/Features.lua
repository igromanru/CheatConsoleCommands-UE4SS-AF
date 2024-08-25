
local Settings = require("Settings")
local AFUtils = require("AFUtils.AFUtils")
require("AFUtils.AFUtilsDebug")

local function HealAllLimbs(playerCharacter)
    for i = 1, 6, 1 do
        local outSuccess = {}
        playerCharacter:Server_HealRandomLimb(100.0, outSuccess)
    end
end

local GodModeWasEnabled = false
function GodMode(myPlayer)
    -- if not myPlayer then return end

    -- if Settings.GodMode then
    --     if not myPlayer.Invincible then
    --         GodModeWasEnabled = true
    --         myPlayer.Invincible = true
    --         LogDebug("Invincible: " .. tostring(myPlayer.Invincible))
    --     end
    -- elseif GodModeWasEnabled then
    --     GodModeWasEnabled = false
    --     myPlayer.Invincible = false
    --     LogDebug("Invincible: " .. tostring(myPlayer.Invincible))
    -- end
end

function Heal(myPlayer)
    if not myPlayer then return end

    if Settings.Heal then
        HealAllLimbs(myPlayer)
        Settings.Heal = false
        AFUtils.ClientDisplayWarningMessage("All Limbs were healed", AFUtils.CriticalityLevels.Green)
    end
end

local InfiniteHealthWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function InfiniteHealth(myPlayer)
    if not myPlayer then return end

    if Settings.InfiniteHealth then
        if not myPlayer.Invincible then
            myPlayer.Invincible = true
            HealAllLimbs(myPlayer)
            -- LogDebug("Invincible: " .. tostring(myPlayer.Invincible))
            -- LogDebug("CurrentHealth_Head: " .. tostring(myPlayer.CurrentHealth_Head))
            -- LogDebug("CurrentHealth_Torso: " .. tostring(myPlayer.CurrentHealth_Torso))
            -- LogDebug("CurrentHealth_LeftArm: " .. tostring(myPlayer.CurrentHealth_LeftArm))
            -- LogDebug("CurrentHealth_RightArm: " .. tostring(myPlayer.CurrentHealth_RightArm))
            -- LogDebug("CurrentHealth_LeftLeg: " .. tostring(myPlayer.CurrentHealth_LeftLeg))
            -- LogDebug("CurrentHealth_RightLeg: " .. tostring(myPlayer.CurrentHealth_RightLeg))
        end
        if not InfiniteHealthWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Invincibility activated", AFUtils.CriticalityLevels.Green)
            InfiniteHealthWasEnabled = true
        end
    elseif InfiniteHealthWasEnabled then
        InfiniteHealthWasEnabled = false
        myPlayer.Invincible = false
        LogDebug("Invincible: " .. tostring(myPlayer.Invincible))
        AFUtils.ClientDisplayWarningMessage("Invincibility deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local InfiniteStaminaWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function InfiniteStamina(myPlayer)
    if not myPlayer then return end

    if Settings.InfiniteStamina then
        if not myPlayer.InfiniteStamina then
            myPlayer.InfiniteStamina = true
            myPlayer.CurrentStamina = myPlayer.MaxStamina
            LogDebug("InfiniteStamina: " .. tostring(myPlayer.InfiniteStamina))
            LogDebug("CurrentStamina: " .. tostring(myPlayer.CurrentStamina))
            LogDebug("MaxStamina: " .. tostring(myPlayer.MaxStamina))
        end
        if not InfiniteStaminaWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Infinite Stamina activated", AFUtils.CriticalityLevels.Green)
            InfiniteStaminaWasEnabled = true
        end
    elseif InfiniteStaminaWasEnabled then
        InfiniteStaminaWasEnabled = false
        myPlayer.InfiniteStamina = false
        LogDebug("InfiniteStamina: " .. tostring(myPlayer.InfiniteStamina))
        AFUtils.ClientDisplayWarningMessage("Infinite Stamina deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local InfiniteDurabilityWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function InfiniteDurability(myPlayer)
    if not myPlayer then return end

    if Settings.InfiniteDurability then
        local inventoryItemSlot = AFUtils.GetSelectedHotbarInventoryItemSlot(myPlayer)
        if inventoryItemSlot then
            inventoryItemSlot.ChangeableData_12_2B90E1F74F648135579D39A49F5A2313.CurrentItemDurability_4_24B4D0E64E496B43FB8D3CA2B9D161C8 = inventoryItemSlot.ChangeableData_12_2B90E1F74F648135579D39A49F5A2313.MaxItemDurability_6_F5D5F0D64D4D6050CCCDE4869785012B
            LogDebug("CurrentItemDurability: " .. inventoryItemSlot.ChangeableData_12_2B90E1F74F648135579D39A49F5A2313.CurrentItemDurability_4_24B4D0E64E496B43FB8D3CA2B9D161C8)
            LogDebug("MaxItemDurability: " .. inventoryItemSlot.ChangeableData_12_2B90E1F74F648135579D39A49F5A2313.MaxItemDurability_6_F5D5F0D64D4D6050CCCDE4869785012B)
        end
        if not InfiniteDurabilityWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Infinite Durability activated", AFUtils.CriticalityLevels.Green)
            InfiniteDurabilityWasEnabled = true
        end
    elseif InfiniteDurabilityWasEnabled then
        InfiniteDurabilityWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Infinite Durability deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local InfiniteEnergyWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function InfiniteEnergy(myPlayer)
    if not myPlayer then return end

    if Settings.InfiniteEnergy then
        AFUtils.FillHeldItemWithEnergy(myPlayer)
        if not InfiniteEnergyWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Infinite Energy activated", AFUtils.CriticalityLevels.Green)
        end
        InfiniteEnergyWasEnabled = true
    elseif InfiniteEnergyWasEnabled then
        InfiniteEnergyWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Infinite Energy deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoHungerWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
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
        if not NoHungerWasEnabled then
            AFUtils.ClientDisplayWarningMessage("No Hunger activated", AFUtils.CriticalityLevels.Green)
            NoHungerWasEnabled = true
        end
    elseif NoHungerWasEnabled then
        NoHungerWasEnabled = false
        myPlayer.HasHunger = true
        LogDebug("HasHunger: " .. tostring(myPlayer.HasHunger))
        AFUtils.ClientDisplayWarningMessage("No Hunger deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoThirstWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function NoThirst(myPlayer)
    if not myPlayer then return end

    if Settings.NoThirst then
        if myPlayer.HasThirst == true then
            myPlayer.HasThirst = false
            myPlayer.CurrentThirst = myPlayer.MaxThirst
            myPlayer:OnRep_CurrentThirst()
            LogDebug("HasThirst: " .. tostring(myPlayer.HasThirst))
            LogDebug("CurrentThirst: " .. tostring(myPlayer.CurrentThirst))
            LogDebug("MaxThirst: " .. tostring(myPlayer.MaxThirst))
        end
        if not NoThirstWasEnabled then
            AFUtils.ClientDisplayWarningMessage("No Thirst activated", AFUtils.CriticalityLevels.Green)
            NoThirstWasEnabled = true
        end
    elseif NoThirstWasEnabled then
        NoThirstWasEnabled = false
        myPlayer.HasThirst = true
        LogDebug("HasThirst: " .. tostring(myPlayer.HasThirst))
        AFUtils.ClientDisplayWarningMessage("No Thirst deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoFatigueWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function NoFatigue(myPlayer)
    if not myPlayer then return end

    if Settings.NoFatigue then
        if myPlayer.HasFatigue == true then
            myPlayer.HasFatigue = false
            myPlayer.CurrentFatigue = 0.0
            myPlayer:OnRep_CurrentFatigue()
            LogDebug("HasFatigue: " .. tostring(myPlayer.HasFatigue))
            LogDebug("CurrentFatigue: " .. tostring(myPlayer.CurrentFatigue))
            LogDebug("MaxFatigue: " .. tostring(myPlayer.MaxFatigue))
        end
        if not NoFatigueWasEnabled then
            AFUtils.ClientDisplayWarningMessage("No Fatigue activated", AFUtils.CriticalityLevels.Green)
            NoFatigueWasEnabled = true
        end
    elseif NoFatigueWasEnabled then
        NoFatigueWasEnabled = false
        myPlayer.HasFatigue = true
        LogDebug("HasFatigue: " .. tostring(myPlayer.HasFatigue))
        AFUtils.ClientDisplayWarningMessage("No Fatigue deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoContinenceWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function NoContinence(myPlayer)
    if not myPlayer then return end

    if Settings.NoContinence then
        if myPlayer.HasContinence == true then
            myPlayer.HasContinence = false
            myPlayer.CurrentContinence = myPlayer.MaxContinence
            myPlayer:OnRep_CurrentContinence()
            LogDebug("HasContinence: " .. tostring(myPlayer.HasContinence))
            LogDebug("CurrentContinence: " .. tostring(myPlayer.CurrentContinence))
            LogDebug("MaxContinence: " .. tostring(myPlayer.MaxContinence))
        end
        if not NoContinenceWasEnabled then
            AFUtils.ClientDisplayWarningMessage("No Continence activated", AFUtils.CriticalityLevels.Green)
            NoContinenceWasEnabled = true
        end
    elseif NoContinenceWasEnabled then
        NoContinenceWasEnabled = false
        myPlayer.HasContinence = true
        LogDebug("HasContinence: " .. tostring(myPlayer.HasContinence))
        AFUtils.ClientDisplayWarningMessage("No Continence deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoRadiationWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function NoRadiation(myPlayer)
    if not myPlayer then return end

    if Settings.NoRadiation then
        if myPlayer.CanReceiveRadiation == true then
            myPlayer.CanReceiveRadiation = false
            myPlayer.CurrentRadiation = 0.0
            myPlayer:OnRep_CurrentContinence()
            LogDebug("CanReceiveRadiation: " .. tostring(myPlayer.CanReceiveRadiation))
            LogDebug("CurrentRadiation: " .. tostring(myPlayer.CurrentRadiation))
            LogDebug("MaxRadiation: " .. tostring(myPlayer.MaxRadiation))
        end
        if not NoRadiationWasEnabled then
            AFUtils.ClientDisplayWarningMessage("No Radiation activated", AFUtils.CriticalityLevels.Green)
            NoRadiationWasEnabled = true
        end
    elseif NoRadiationWasEnabled then
        NoRadiationWasEnabled = false
        myPlayer.CanReceiveRadiation = true
        LogDebug("CanReceiveRadiation: " .. tostring(myPlayer.CanReceiveRadiation))
        AFUtils.ClientDisplayWarningMessage("No Radiation deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local FreeCraftingWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function FreeCrafting(myPlayer)
    if not myPlayer then return end

    if Settings.FreeCrafting then
        if not myPlayer.Debug_FreeCrafting then
            myPlayer.Debug_FreeCrafting = true
            LogDebug("Debug_FreeCrafting: " .. tostring(myPlayer.Debug_FreeCrafting))
        end
        if not FreeCraftingWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Free Crafting activated", AFUtils.CriticalityLevels.Green)
            FreeCraftingWasEnabled = true
        end
    elseif FreeCraftingWasEnabled then
        FreeCraftingWasEnabled = false
        myPlayer.Debug_FreeCrafting = false
        LogDebug("Debug_FreeCrafting: " .. tostring(myPlayer.Debug_FreeCrafting))
        AFUtils.ClientDisplayWarningMessage("Free Crafting deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoFallDamageWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function NoFallDamage(myPlayer)
    if not myPlayer then return end

    if Settings.NoFallDamage then
        if myPlayer.TakeFallDamage == true then
            myPlayer.TakeFallDamage = false
            LogDebug("TakeFallDamage: " .. tostring(myPlayer.TakeFallDamage))
        end
        if not NoFallDamageWasEnabled then
            AFUtils.ClientDisplayWarningMessage("No Fall Damage activated", AFUtils.CriticalityLevels.Green)
            NoFallDamageWasEnabled = true
        end
    elseif NoFallDamageWasEnabled then
        NoFallDamageWasEnabled = false
        myPlayer.TakeFallDamage = true
        LogDebug("TakeFallDamage: " .. tostring(myPlayer.TakeFallDamage))
        AFUtils.ClientDisplayWarningMessage("No Fall Damage activated", AFUtils.CriticalityLevels.Red)
    end
end

local NoClipWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function NoClip(myPlayer)
    if not myPlayer then return end

    if Settings.NoClip then
        if not myPlayer.Noclip_On then
            myPlayer.Noclip_On = true
            myPlayer:OnRep_Noclip_On()
            LogDebug("Noclip_On: " .. tostring(myPlayer.Noclip_On))
        end
        if not NoClipWasEnabled then
            AFUtils.ClientDisplayWarningMessage("No Clip activated", AFUtils.CriticalityLevels.Green)
            NoClipWasEnabled = true
        end
    elseif NoClipWasEnabled then
        NoClipWasEnabled = false
        myPlayer.Noclip_On = false
        myPlayer:OnRep_Noclip_On()
        LogDebug("Noclip_On: " .. tostring(myPlayer.Noclip_On))
        AFUtils.ClientDisplayWarningMessage("No Clip deactivated", AFUtils.CriticalityLevels.Red)
    end
end

---@param myPlayer AAbiotic_PlayerCharacter_C
function SetMoney(myPlayer)
    if not myPlayer then return end

    if Settings.SetMoney and Settings.MoneyValue > -1 then
        if Settings.MoneyValue ~= myPlayer.CurrentMoney then
            myPlayer.CurrentMoney = Settings.MoneyValue
            myPlayer:OnRep_CurrentMoney()
            LogDebug("CurrentMoney: " .. tostring(myPlayer.CurrentMoney))
            AFUtils.ClientDisplayWarningMessage("Money set to " .. myPlayer.CurrentMoney, AFUtils.CriticalityLevels.Green)
            Settings.SetMoney = false
            Settings.MoneyValue = -1
        end
    end
end