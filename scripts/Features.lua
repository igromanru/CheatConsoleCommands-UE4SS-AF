
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
            AFUtils.ClientDisplayWarningMessage("Invincibility activated", AFUtils.CriticalityLevels.Green)
        end
    elseif InfiniteHealthWasEnabled then
        InfiniteHealthWasEnabled = false
        myPlayer.Invincible = false
        LogDebug("Invincible: " .. tostring(myPlayer.Invincible))
        AFUtils.ClientDisplayWarningMessage("Invincibility deactivated", AFUtils.CriticalityLevels.Red)
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
            AFUtils.ClientDisplayWarningMessage("Infinite Stamina activated", AFUtils.CriticalityLevels.Green)
        end
    elseif InfiniteStaminaWasEnabled then
        InfiniteStaminaWasEnabled = false
        myPlayer.InfiniteStamina = false
        LogDebug("InfiniteStamina: " .. tostring(myPlayer.InfiniteStamina))
        AFUtils.ClientDisplayWarningMessage("Infinite Stamina deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local InfiniteDurabilityWasEnabled = false
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
        end
        InfiniteDurabilityWasEnabled = true
    elseif InfiniteDurabilityWasEnabled then
        InfiniteDurabilityWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Infinite Durability deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local InfiniteEnergyWasEnabled = false
local ItemDataCashe = {
    AssetId = "-1",
    MaxLiquid = -1
}
function InfiniteEnergy(myPlayer)
    if not myPlayer then return end

    if Settings.InfiniteEnergy then
        -- local itemSlotStrcut, inventory, slotIndex = AFUtils.GetSelectedHotbarInventoryItemSlot(myPlayer)
        -- if itemSlotStrcut and inventory and slotIndex then
        --     local changeableData = itemSlotStrcut.ChangeableData_12_2B90E1F74F648135579D39A49F5A2313
        --     local assetId = changeableData.AssetID_25_06DB7A12469849D19D5FC3BA6BEDEEAB:ToString()
        --     if assetId ~= "-1" and ItemDataCashe.AssetId ~= assetId then
        --         ItemDataCashe.AssetId = assetId
        --         local outSuccess = {}
        --         local outSlotData = {}
        --         local outItemData = {}
        --         inventory:GetItemInSlot(slotIndex, outSuccess, outSlotData, outItemData)
        --         if outSuccess.Success then
        --             LogDebug("GetItemInSlot Success")
        --             AFUtils.LogInventoryItemStruct(outItemData.ItemData, "ItemData.")
        --             ItemDataCashe.MaxLiquid = outItemData.ItemData.LiquidData_110_4D07F09C483C1E65B39024ABC7032FA0.MaxLiquid_16_80D4968B4CACEDD3D4018E87DA67E8B4
        --         end
        --     end

        --     if changeableData.CurrentLiquid_19_3E1652F448223AAE5F405FB510838109 == AFUtils.LiquidType.Power then
        --         LogDebug("LiquidLevel: " .. changeableData.LiquidLevel_46_D6414A6E49082BC020AADC89CC29E35A)
        --     end
        -- end
        -- if not InfiniteEnergyWasEnabled then
        --     AFUtils.ClientDisplayWarningMessage("Infinite Energy activated", AFUtils.CriticalityLevels.Green)
        -- end
        -- InfiniteEnergyWasEnabled = true
    elseif InfiniteEnergyWasEnabled then
        InfiniteEnergyWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Infinite Energy deactivated", AFUtils.CriticalityLevels.Red)
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
            AFUtils.ClientDisplayWarningMessage("No Hunger activated", AFUtils.CriticalityLevels.Green)
        end
    elseif NoHungerWasEnabled then
        NoHungerWasEnabled = false
        myPlayer.HasHunger = true
        LogDebug("HasHunger: " .. tostring(myPlayer.HasHunger))
        AFUtils.ClientDisplayWarningMessage("No Hunger deactivated", AFUtils.CriticalityLevels.Red)
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
            AFUtils.ClientDisplayWarningMessage("No Thirst activated", AFUtils.CriticalityLevels.Green)
        end
    elseif NoThirstWasEnabled then
        NoThirstWasEnabled = false
        myPlayer.HasThirst = true
        LogDebug("HasThirst: " .. tostring(myPlayer.HasThirst))
        AFUtils.ClientDisplayWarningMessage("No Thirst deactivated", AFUtils.CriticalityLevels.Red)
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
            AFUtils.ClientDisplayWarningMessage("No Fatigue activated", AFUtils.CriticalityLevels.Green)
        end
    elseif NoFatigueWasEnabled then
        NoFatigueWasEnabled = false
        myPlayer.HasFatigue = true
        LogDebug("HasFatigue: " .. tostring(myPlayer.HasFatigue))
        AFUtils.ClientDisplayWarningMessage("No Fatigue deactivated", AFUtils.CriticalityLevels.Red)
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
            AFUtils.ClientDisplayWarningMessage("No Continence activated", AFUtils.CriticalityLevels.Green)
        end
    elseif NoContinenceWasEnabled then
        NoContinenceWasEnabled = false
        myPlayer.HasContinence = true
        LogDebug("HasContinence: " .. tostring(myPlayer.HasContinence))
        AFUtils.ClientDisplayWarningMessage("No Continence deactivated", AFUtils.CriticalityLevels.Red)
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
            AFUtils.ClientDisplayWarningMessage("No Radiation activated", AFUtils.CriticalityLevels.Green)
        end
    elseif NoRadiationWasEnabled then
        NoRadiationWasEnabled = false
        myPlayer.CanReceiveRadiation = true
        LogDebug("CanReceiveRadiation: " .. tostring(myPlayer.CanReceiveRadiation))
        AFUtils.ClientDisplayWarningMessage("No Radiation deactivated", AFUtils.CriticalityLevels.Red)
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
            AFUtils.ClientDisplayWarningMessage("Free Crafting activated", AFUtils.CriticalityLevels.Green)
        end
    elseif FreeCraftingWasEnabled then
        FreeCraftingWasEnabled = false
        myPlayer.Debug_FreeCrafting = false
        LogDebug("Debug_FreeCrafting: " .. tostring(myPlayer.Debug_FreeCrafting))
        AFUtils.ClientDisplayWarningMessage("Free Crafting deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoFallDamageWasEnabled = false
function NoFallDamage(myPlayer)
    if not myPlayer then return end

    if Settings.NoFallDamage then
        if myPlayer.TakeFallDamage == true then
            myPlayer.TakeFallDamage = false
            LogDebug("TakeFallDamage: " .. tostring(myPlayer.TakeFallDamage))
            if not NoFallDamageWasEnabled then
                AFUtils.ClientDisplayWarningMessage("No Fall Damage activated", AFUtils.CriticalityLevels.Green)
            end
        end
        NoFallDamageWasEnabled = true
    elseif NoFallDamageWasEnabled then
        NoFallDamageWasEnabled = false
        myPlayer.TakeFallDamage = true
        LogDebug("TakeFallDamage: " .. tostring(myPlayer.TakeFallDamage))
        AFUtils.ClientDisplayWarningMessage("No Fall Damage activated", AFUtils.CriticalityLevels.Red)
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
            AFUtils.ClientDisplayWarningMessage("No Clip activated", AFUtils.CriticalityLevels.Green)
        end
    elseif NoClipWasEnabled then
        NoClipWasEnabled = false
        myPlayer.Noclip_On = false
        myPlayer:OnRep_Noclip_On()
        LogDebug("Noclip_On: " .. tostring(myPlayer.Noclip_On))
        AFUtils.ClientDisplayWarningMessage("No Clip deactivated", AFUtils.CriticalityLevels.Red)
    end
end

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