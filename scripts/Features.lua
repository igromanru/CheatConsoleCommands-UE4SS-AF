
require("Settings")
local AFUtils = require("AFUtils.AFUtils")
local LinearColors = require("AFUtils.BaseUtils.LinearColors")
local NoClipMod = require("AFUtils.BaseUtils.NoClip")

local InfiniteHealthWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function InfiniteHealth(myPlayer)
    if Settings.GodMode or Settings.InfiniteHealth then
        if not myPlayer.Invincible then
            myPlayer.Invincible = true
            AFUtils.HealFullAllLimbs(myPlayer)
            LogDebug("Invincible: " .. tostring(myPlayer.Invincible))
            LogDebug("CurrentHealth_Head: " .. tostring(myPlayer.CurrentHealth_Head))
            LogDebug("CurrentHealth_Torso: " .. tostring(myPlayer.CurrentHealth_Torso))
            LogDebug("CurrentHealth_LeftArm: " .. tostring(myPlayer.CurrentHealth_LeftArm))
            LogDebug("CurrentHealth_RightArm: " .. tostring(myPlayer.CurrentHealth_RightArm))
            LogDebug("CurrentHealth_LeftLeg: " .. tostring(myPlayer.CurrentHealth_LeftLeg))
            LogDebug("CurrentHealth_RightLeg: " .. tostring(myPlayer.CurrentHealth_RightLeg))
            LogDebug("TotalCombinedHealth: " .. tostring(myPlayer.TotalCombinedHealth))
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

local LastHealthRegeneration = 0.0
---@param myPlayer AAbiotic_PlayerCharacter_C
function HealthRegeneration(myPlayer)
    if Settings.HealthRegeneration > 0 and not Settings.GodMode then
        -- The loop runs each 250ms, we divide the health regeneration by 4 to get the correct value for 1s
        local healthRegeneration = Settings.HealthRegeneration / 4
        myPlayer:Server_HealRandomLimb(healthRegeneration, {})
        myPlayer:OnRep_CurrentHealth()
        if LastHealthRegeneration ~= Settings.HealthRegeneration then
            LastHealthRegeneration = Settings.HealthRegeneration
            LogDebug("HealthRegeneration:", LastHealthRegeneration)
            AFUtils.ClientDisplayWarningMessage("Health Regeneration " .. LastHealthRegeneration .. "hp/s", AFUtils.CriticalityLevels.Green)
        end
    elseif LastHealthRegeneration > 0 and Settings.HealthRegeneration <= 0 then
        LastHealthRegeneration = 0.0
        Settings.HealthRegeneration = 0.0
        AFUtils.ClientDisplayWarningMessage("Health Regeneration deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local InfiniteStaminaWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function InfiniteStamina(myPlayer)
    if Settings.GodMode or Settings.InfiniteStamina then
        if not myPlayer.InfiniteStamina then
            myPlayer.InfiniteStamina = true
            myPlayer.CurrentStamina = myPlayer.MaxStamina
            myPlayer:OnRep_CurrentStamina()
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
    if Settings.InfiniteDurability then
        AFUtils.RepairAllItemsInInvetory(myPlayer, myPlayer.CharacterEquipSlotInventory)
        AFUtils.RepairAllItemsInInvetory(myPlayer, myPlayer.CharacterHotbarInventory)
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
---@param hasAuthority boolean?
function InfiniteEnergy(myPlayer, hasAuthority)
    if Settings.InfiniteEnergy then
        AFUtils.FixHeldItemLiquid(myPlayer)
        AFUtils.FillHeldItemWithEnergy(myPlayer)
        AFUtils.FillAllEquippedItemsWithEnergy(myPlayer)
        if not InfiniteEnergyWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Infinite Energy activated", AFUtils.CriticalityLevels.Green)
            InfiniteEnergyWasEnabled = true
        end
    elseif InfiniteEnergyWasEnabled then
        InfiniteEnergyWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Infinite Energy deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoOverheatWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
---@param hasAuthority boolean?
function NoOverheat(myPlayer, hasAuthority)
    if Settings.NoOverheat and hasAuthority then
        local jetpack = myPlayer.Gear_BackpackBP ---@cast jetpack AGear_Jetpack_BP_C
        if IsValid(jetpack) and jetpack.CurrentOverheatLevel then
            jetpack.CurrentOverheatLevel = 0
        end
        if not NoOverheatWasEnabled then
            AFUtils.ClientDisplayWarningMessage("No Overheat activated", AFUtils.CriticalityLevels.Green)
            NoOverheatWasEnabled = true
        end
    elseif NoOverheatWasEnabled then
        NoOverheatWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("No Overheat deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local MaxInventoryWeight = 999999.0
local LastMaxCarryWeight = 0
local InfiniteMaxWeightWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function InfiniteMaxWeight(myPlayer)
    if Settings.InfiniteMaxWeight then
        if myPlayer.MaxInventoryWeight < MaxInventoryWeight then
            LastMaxCarryWeight = myPlayer.MaxInventoryWeight
            myPlayer.MaxInventoryWeight = MaxInventoryWeight
            myPlayer:OnRep_MaxInventoryWeight()
            LogDebug("MaxInventoryWeight: " .. tostring(myPlayer.MaxInventoryWeight))
        end
        if not InfiniteMaxWeightWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Infinite Max Weight activated", AFUtils.CriticalityLevels.Green)
            InfiniteMaxWeightWasEnabled = true
        end
    elseif InfiniteMaxWeightWasEnabled then
        InfiniteMaxWeightWasEnabled = false
        if LastMaxCarryWeight < myPlayer.DefaultMaxInventoryWeight then
            myPlayer.MaxInventoryWeight = myPlayer.DefaultMaxInventoryWeight
        else
            myPlayer.MaxInventoryWeight = LastMaxCarryWeight
        end
        myPlayer:OnRep_MaxInventoryWeight()
        LogDebug("MaxInventoryWeight: " .. tostring(myPlayer.MaxInventoryWeight))
        LastMaxCarryWeight = 0
        AFUtils.ClientDisplayWarningMessage("Infinite Max Weight deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local InfiniteAmmoWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function InfiniteAmmo(myPlayer)
    if Settings.InfiniteAmmo then
        local weapon = AFUtils.GetCurrentWeapon(myPlayer)
        if weapon then
            if AFUtils.FillHeldWeaponWithAmmo(myPlayer) then
                weapon.ConsumeAmmoOnFire = false
            end
        end
        if not InfiniteAmmoWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Infinite Ammo activated", AFUtils.CriticalityLevels.Green)
            InfiniteAmmoWasEnabled = true
        end
    elseif InfiniteAmmoWasEnabled then
        local weapon = AFUtils.GetCurrentWeapon(myPlayer)
        if weapon then
            if AFUtils.FillHeldWeaponWithAmmo(myPlayer) then
                weapon.ConsumeAmmoOnFire = true
            end
        end
        InfiniteAmmoWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Infinite Ammo deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoHungerWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function NoHunger(myPlayer)
    if Settings.GodMode or Settings.NoHunger then
        if myPlayer.HasHunger then
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
    if Settings.GodMode or Settings.NoThirst then
        if myPlayer.HasThirst then
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
    if Settings.GodMode or Settings.NoFatigue then
        if myPlayer.HasFatigue then
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

local InfiniteContinenceWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function InfiniteContinence(myPlayer)
    if Settings.GodMode or Settings.InfiniteContinence then
        if myPlayer.HasContinence then
            myPlayer.HasContinence = false
            myPlayer.CurrentContinence = myPlayer.MaxContinence
            myPlayer:OnRep_CurrentContinence()
            LogDebug("InfiniteContinence: HasContinence: " .. tostring(myPlayer.HasContinence))
            LogDebug("InfiniteContinence: CurrentContinence: " .. tostring(myPlayer.CurrentContinence))
            LogDebug("InfiniteContinence: MaxContinence: " .. tostring(myPlayer.MaxContinence))
        end
        if not InfiniteContinenceWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Infinite Continence activated", AFUtils.CriticalityLevels.Green)
            InfiniteContinenceWasEnabled = true
        end
    elseif InfiniteContinenceWasEnabled then
        InfiniteContinenceWasEnabled = false
        myPlayer.HasContinence = true
        LogDebug("InfiniteContinence: HasContinence: " .. tostring(myPlayer.HasContinence))
        AFUtils.ClientDisplayWarningMessage("Infinite Continence deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local LowContinenceWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function LowContinence(myPlayer)
    if Settings.LowContinence then
        local fraction = myPlayer.MaxContinence * 0.10
        if myPlayer.CurrentContinence > fraction then
            myPlayer.HasContinence = true
            myPlayer.CurrentContinence = fraction
            myPlayer:OnRep_CurrentContinence()
            LogDebug("LowContinence: HasContinence: " .. tostring(myPlayer.HasContinence))
            LogDebug("LowContinence: CurrentContinence: " .. tostring(myPlayer.CurrentContinence))
            LogDebug("LowContinence: MaxContinence: " .. tostring(myPlayer.MaxContinence))
        end
        
        if not LowContinenceWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Low Continence activated", AFUtils.CriticalityLevels.Green)
            LowContinenceWasEnabled = true
        end
    elseif LowContinenceWasEnabled then
        LowContinenceWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Low Continence deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local InstantToiletWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function InstantToilet(myPlayer)
    if Settings.InstantToilet then
        local myPlayerController = myPlayer.MyPlayerController
        if IsValid(myPlayerController) and myPlayerController.ContinenceMinigameActive then
            LogDebug("InstantToilet: HasContinence: " .. tostring(myPlayer.HasContinence))
            LogDebug("InstantToilet: CurrentContinence: " .. tostring(myPlayer.CurrentContinence))
            myPlayer.HasContinence = true
            if myPlayer.CurrentContinence < myPlayer.MaxContinence - 1 then
                myPlayer.CurrentContinence = myPlayer.MaxContinence - 1
                myPlayer:OnRep_CurrentContinence()
            end
            myPlayerController:Request_ContinenceReduction(AFUtils.CriticalityLevels.Green)
        end

        if not InstantToiletWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Instant Toilet activated", AFUtils.CriticalityLevels.Green)
            InstantToiletWasEnabled = true
        end
    elseif InstantToiletWasEnabled then
        InstantToiletWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Instant Toilet deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoRadiationWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function NoRadiation(myPlayer)
    if Settings.GodMode or Settings.NoRadiation then
        if  myPlayer.CanReceiveRadiation then
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

local PerfectTemperatureWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function PerfectTemperature(myPlayer)
    if Settings.GodMode or Settings.PerfectTemperature then
        if myPlayer.HasBodyTemperature then
            myPlayer.HasBodyTemperature = false
            myPlayer.CurrentBodyTemperature = myPlayer.PreferredBodyTemperature
            myPlayer:OnRep_CurrentBodyTemperature()
            LogDebug("HasBodyTemperature: " .. tostring(myPlayer.HasBodyTemperature))
            LogDebug("CurrentBodyTemperature: " .. tostring(myPlayer.CurrentBodyTemperature))
            LogDebug("PreferredBodyTemperature: " .. tostring(myPlayer.PreferredBodyTemperature))
        end
        if not PerfectTemperatureWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Perfect Temperature activated", AFUtils.CriticalityLevels.Green)
            PerfectTemperatureWasEnabled = true
        end
    elseif PerfectTemperatureWasEnabled then
        PerfectTemperatureWasEnabled = false
        myPlayer.HasBodyTemperature = true
        LogDebug("HasBodyTemperature: " .. tostring(myPlayer.HasBodyTemperature))
        AFUtils.ClientDisplayWarningMessage("Perfect Temperature deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local InfiniteOxygenWasEnabled = false
local InfiniteDrownTime = 999999.0
local DrownTimeBackUp = InfiniteDrownTime
---@param myPlayer AAbiotic_PlayerCharacter_C
function InfiniteOxygen(myPlayer)
    if Settings.GodMode or Settings.InfiniteOxygen then
        if myPlayer.DrownTime ~= InfiniteDrownTime then
            if DrownTimeBackUp == InfiniteDrownTime then
                DrownTimeBackUp = myPlayer.DrownTime
            end
            myPlayer.DrownTime = InfiniteDrownTime
            LogDebug("DrownTime: " .. tostring(myPlayer.DrownTime))
        end
        if not InfiniteOxygenWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Infinite Oxygen activated", AFUtils.CriticalityLevels.Green)
            InfiniteOxygenWasEnabled = true
        end
    elseif InfiniteOxygenWasEnabled then
        InfiniteOxygenWasEnabled = false
        myPlayer.DrownTime = DrownTimeBackUp
        DrownTimeBackUp = InfiniteDrownTime
        LogDebug("DrownTime: " .. tostring(myPlayer.DrownTime))
        AFUtils.ClientDisplayWarningMessage("Infinite Oxygen deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local UserConstructionScriptPreId, UserConstructionScriptPostId = nil, nil
local function InitFreeCraftingHooks()
    if not UserConstructionScriptPreId then
        UserConstructionScriptPreId, UserConstructionScriptPostId = RegisterHook("/Game/Blueprints/DeployedObjects/Furniture/AbioticDeployed_Furniture_ParentBP.AbioticDeployed_Furniture_ParentBP_C:UserConstructionScript", function(Context)
            local furnitureParentBP = Context:get()

            if furnitureParentBP.RequiresConstruction == true then
                local myPlayer = AFUtils.GetMyPlayer()
                if myPlayer and myPlayer.Debug_FreeCrafting == true then
                    furnitureParentBP.RequiresConstruction = false
                end
            end
        end)
        LogDebug("UserConstructionScriptPreId:",UserConstructionScriptPreId)
        LogDebug("UserConstructionScriptPostId:",UserConstructionScriptPostId)
    end
end

local FreeCraftingWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function FreeCrafting(myPlayer)
    if Settings.FreeCrafting then
        if not myPlayer.Debug_FreeCrafting then
            myPlayer.Debug_FreeCrafting = true
            LogDebug("Debug_FreeCrafting: " .. tostring(myPlayer.Debug_FreeCrafting))
        end
        if not FreeCraftingWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Free Crafting activated", AFUtils.CriticalityLevels.Green)
            FreeCraftingWasEnabled = true
        end
        InitFreeCraftingHooks()
    elseif FreeCraftingWasEnabled then
        FreeCraftingWasEnabled = false
        myPlayer.Debug_FreeCrafting = false
        LogDebug("Debug_FreeCrafting: " .. tostring(myPlayer.Debug_FreeCrafting))
        AFUtils.ClientDisplayWarningMessage("Free Crafting deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local InstantCraftingWasEnabled = false
function InstantCrafting()
    if Settings.InstantCrafting then
        local craftingArea = AFUtils.GetMyInventoryCraftingArea()
        if craftingArea and craftingArea.SelectedRecipe then
            craftingArea.SelectedRecipe.CraftDuration_13_BFC1ED4A429775D36D12E683816868D6 = 0.01
        end
        if not InstantCraftingWasEnabled then
            InstantCraftingWasEnabled = true
            AFUtils.ClientDisplayWarningMessage("Instant Crafting activated", AFUtils.CriticalityLevels.Green)
        end
    elseif InstantCraftingWasEnabled then
        InstantCraftingWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Instant Crafting deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local InvisibleWasEnabled = false
---comment
---@param myPlayer AAbiotic_PlayerCharacter_C
---@param hasAuthority boolean?
function Invisible(myPlayer, hasAuthority)
    if Settings.Invisible and hasAuthority then
        if myPlayer.NPC_Targetable == true then
            myPlayer.NPC_Targetable = false
            LogDebug("NPC_Targetable:", myPlayer.NPC_Targetable)
        end
        if not InvisibleWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Invisibility activated", AFUtils.CriticalityLevels.Green)
            InvisibleWasEnabled = true
        end
    elseif InvisibleWasEnabled then
        InvisibleWasEnabled = false
        myPlayer.NPC_Targetable = true
        LogDebug("NPC_Targetable:", myPlayer.NPC_Targetable)
        AFUtils.ClientDisplayWarningMessage("Invisibility deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoFallDamageWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
---@param hasAuthority boolean?
function NoFallDamage(myPlayer, hasAuthority)
    if Settings.NoFallDamage and hasAuthority then
        if myPlayer.TakeFallDamage then
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
        AFUtils.ClientDisplayWarningMessage("No Fall Damage deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoClipWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
---@param hasAuthority boolean?
function NoClip(myPlayer, hasAuthority)
    if Settings.NoClip and hasAuthority then
        if not IsValid(myPlayer.CharacterMovement) then return end

        if not myPlayer.CharacterMovement.bCheatFlying or myPlayer.CharacterMovement.MovementMode ~= 5 then
            if not NoClipMod.Enable() then
                AFUtils.ClientDisplayWarningMessage("No Clip Error", AFUtils.CriticalityLevels.Red)
                return
            end
        end

        if not NoClipWasEnabled then
            AFUtils.ClientDisplayWarningMessage("No Clip activated", AFUtils.CriticalityLevels.Green)
            NoClipWasEnabled = true
        end
    elseif NoClipWasEnabled then
        NoClipWasEnabled = false
        NoClipMod.Disable() 
        AFUtils.ClientDisplayWarningMessage("No Clip deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoRecoilWasEnabled = false
local RecoilTimelineLengthBackUp = 0.0
---@param myPlayer AAbiotic_PlayerCharacter_C
function NoRecoil(myPlayer)
    if Settings.NoRecoil then
        if IsValid(myPlayer.ControllerRecoilTimeline) then
            if myPlayer.ControllerRecoilTimeline.TheTimeline.Length > 0 then
                RecoilTimelineLengthBackUp = myPlayer.ControllerRecoilTimeline.TheTimeline.Length
            end
            myPlayer.ControllerRecoilTimeline.TheTimeline.Length = 0.0
        end
        if not NoRecoilWasEnabled then
            AFUtils.ClientDisplayWarningMessage("No Recoil activated", AFUtils.CriticalityLevels.Green)
            NoRecoilWasEnabled = true
        end
    elseif NoRecoilWasEnabled then
        if IsValid(myPlayer.ControllerRecoilTimeline) and RecoilTimelineLengthBackUp > 0 then
            myPlayer.ControllerRecoilTimeline.TheTimeline.Length = RecoilTimelineLengthBackUp
        end
        RecoilTimelineLengthBackUp = 0.0
        NoRecoilWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("No Recoil deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local NoSwayWasEnabled = false
local ScopeSwaySpeedBackUp = 0.0
---@param myPlayer AAbiotic_PlayerCharacter_C
function NoSway(myPlayer)
    if Settings.NoSway then
        myPlayer.BaseGunSway_Multiplier = 0.0
        if myPlayer.ScopeSwaySpeed > 0 then
            ScopeSwaySpeedBackUp = myPlayer.ScopeSwaySpeed
            myPlayer.ScopeSwaySpeed = 0
        end
        if not NoSwayWasEnabled then
            AFUtils.ClientDisplayWarningMessage("No Sway activated", AFUtils.CriticalityLevels.Green)
            NoSwayWasEnabled = true
        end
    elseif NoSwayWasEnabled then
        myPlayer.BaseGunSway_Multiplier = 1.0
        if ScopeSwaySpeedBackUp > 0 then
            myPlayer.ScopeSwaySpeed = ScopeSwaySpeedBackUp
        end
        NoSwayWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("No Sway deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local PreInstantPlantGrowthId, PostInstantPlantGrowthId = nil, nil
local InstantPlantGrowthWasEnabled = false
---@param hasAuthority boolean?
function InstantPlantGrowth(hasAuthority)
    if Settings.InstantPlantGrowth and hasAuthority then
        if not PreInstantPlantGrowthId and not PostInstantPlantGrowthId then
            LoadAsset("/Game/Blueprints/DeployedObjects/Farming/FarmingPlot_BP.FarmingPlot_BP_C")
            _, PreInstantPlantGrowthId, PostInstantPlantGrowthId = pcall(RegisterHook, "/Game/Blueprints/DeployedObjects/Farming/FarmingPlot_BP.FarmingPlot_BP_C:GrowthTick", function(Context)
                local farmingPlot = Context:get() ---@type AFarmingPlot_BP_C
                farmingPlot:SetCurrentGrowthProgress(farmingPlot.PlantGrowthStageMax)
                farmingPlot:SetCurrentGrowthStage(4, false) -- EPlantGrowthStage.Grown = 4
                if DebugMode then
                    LogDebug("-- [GrowthTick] --")
                    LogDebug("GrowthAmountPerTick:", farmingPlot.GrowthAmountPerTick)
                    LogDebug("PlantGrowthStageMax:", farmingPlot.PlantGrowthStageMax)
                    LogDebug("GetCurrentGrowthProgress:", farmingPlot:GetCurrentGrowthProgress())
                end
            end)
            LogDebug("PreInstantPlantGrowthId:", PreInstantPlantGrowthId)
            LogDebug("PostInstantPlantGrowthId:", PostInstantPlantGrowthId)
        end
        if not InstantPlantGrowthWasEnabled and PreInstantPlantGrowthId and PostInstantPlantGrowthId then
            AFUtils.ClientDisplayWarningMessage("Instant Plant Growth activated", AFUtils.CriticalityLevels.Green)
            InstantPlantGrowthWasEnabled = true
        end
    elseif InstantPlantGrowthWasEnabled then
        if PreInstantPlantGrowthId and PostInstantPlantGrowthId then
            pcall(UnregisterHook, "/Game/Blueprints/DeployedObjects/Farming/FarmingPlot_BP.FarmingPlot_BP_C:GrowthTick", PreInstantPlantGrowthId, PostInstantPlantGrowthId)
            PreInstantPlantGrowthId, PostInstantPlantGrowthId = nil, nil
        end
        InstantPlantGrowthWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Instant Plant Growth deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local PreInfiniteTraitPointsId, PostInfiniteTraitPointsId = nil, nil
local InfiniteTraitPointsWasEnabled = false
---@param hasAuthority boolean?
function InfiniteTraitPoints(hasAuthority)
    if Settings.InfiniteTraitPoints and hasAuthority then
        if not PreInfiniteTraitPointsId and not PostInfiniteTraitPointsId then
            LoadAsset("/Game/Blueprints/Widgets/TraitSelect/W_Character_Trait_Selection.W_Character_Trait_Selection_C")
            _, PreInfiniteTraitPointsId, PostInfiniteTraitPointsId = pcall(RegisterHook, "/Game/Blueprints/Widgets/TraitSelect/W_Character_Trait_Selection.W_Character_Trait_Selection_C:CalculatePointsAvailable", function(Context)
                local trait_Selection = Context:get() ---@type UW_Character_Trait_Selection_C
                LogDebug("TraitsAndPoints.Num:", #trait_Selection.TraitsAndPoints)
                trait_Selection.TraitsAndPoints:ForEach(function (key, value)
                    value:set(20)
                end)
            end)
            LogDebug("PreInfiniteTraitPointsId:", PreInfiniteTraitPointsId)
            LogDebug("PostInfiniteTraitPointsId:", PostInfiniteTraitPointsId)
        end
        if not InfiniteTraitPointsWasEnabled and PreInfiniteTraitPointsId and PostInfiniteTraitPointsId then
            AFUtils.ClientDisplayWarningMessage("Infinite Trait Points activated", AFUtils.CriticalityLevels.Green)
            InfiniteTraitPointsWasEnabled = true
        end
    elseif InfiniteTraitPointsWasEnabled then
        if PreInfiniteTraitPointsId and PostInfiniteTraitPointsId then
            pcall(UnregisterHook, "/Game/Blueprints/Widgets/TraitSelect/W_Character_Trait_Selection.W_Character_Trait_Selection_C:CalculatePointsAvailable", PreInfiniteTraitPointsId, PostInfiniteTraitPointsId)
            PreInfiniteTraitPointsId, PostInfiniteTraitPointsId = nil, nil
        end
        InfiniteTraitPointsWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Infinite Trait Points deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local PreInstantFishingId, PostInstantFishingId = nil, nil
local InstantFishingWasEnabled = false
function InstantFishing()
    if Settings.InstantFishing then
        if not PreInstantFishingId and not PostInstantFishingId then
            LoadAsset("/Game/Blueprints/Items/Weapons/Guns/Weapon_FishingRod.Weapon_FishingRod_C")
            _, PreInstantFishingId, PostInstantFishingId = pcall(RegisterHook, "/Game/Blueprints/Items/Weapons/Guns/Weapon_FishingRod.Weapon_FishingRod_C:Start Fishing Minigame", function(Context)
                local fishingRod = Context:get() ---@type AWeapon_FishingRod_C
                fishingRod:Request_TriggerBaitUsage()
                fishingRod:FishingSuccess()
            end)
            LogDebug("PreInstantFishingId:", PreInstantFishingId)
            LogDebug("PostInstantFishingId:", PostInstantFishingId)
        end
        if not InstantFishingWasEnabled and PreInstantFishingId and PostInstantFishingId then
            AFUtils.ClientDisplayWarningMessage("Instant Fishing activated", AFUtils.CriticalityLevels.Green)
            InstantFishingWasEnabled = true
        end
    elseif InstantFishingWasEnabled then
        if PreInstantFishingId and PostInstantFishingId then
            pcall(UnregisterHook, "/Game/Blueprints/Items/Weapons/Guns/Weapon_FishingRod.Weapon_FishingRod_C:Start Fishing Minigame", PreInstantFishingId, PostInstantFishingId)
            PreInstantFishingId, PostInstantFishingId = nil, nil
        end
        InstantFishingWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Instant Fishing deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local MasterKeyWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function MasterKey(myPlayer)
    if Settings.MasterKey then
        if not myPlayer.HasMasterKey then
            myPlayer.HasMasterKey = true
            LogDebug("HasMasterKey: " .. tostring(myPlayer.HasMasterKey))
        end
        if not MasterKeyWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Master Key activated", AFUtils.CriticalityLevels.Green)
            MasterKeyWasEnabled = true
        end
    elseif MasterKeyWasEnabled then
        MasterKeyWasEnabled = false
        myPlayer.HasMasterKey = false
        LogDebug("Master Key: " .. tostring(myPlayer.HasMasterKey))
        AFUtils.ClientDisplayWarningMessage("Master Key deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local BaseWalkSpeedBackUp = 500.0
local BaseSprintSpeedBackUp =  685.0
local LastSpeedhackMultiplier = 1.0
---@param myPlayer AAbiotic_PlayerCharacter_C
---@param hasAuthority boolean?
function Speedhack(myPlayer, hasAuthority)
    local newBaseWalkSpeed = BaseWalkSpeedBackUp * Settings.SpeedhackMultiplier
    local newBaseSprintSpeed = BaseSprintSpeedBackUp * Settings.SpeedhackMultiplier
    if hasAuthority then
        if myPlayer.BaseWalkSpeed == newBaseWalkSpeed and myPlayer.BaseSprintSpeed == newBaseSprintSpeed then
            return
        end
    elseif myPlayer.CustomTimeDilation == Settings.SpeedhackMultiplier then
        return
    end

    if LastSpeedhackMultiplier == 1.0 then
        BaseWalkSpeedBackUp = myPlayer.BaseWalkSpeed
        BaseSprintSpeedBackUp = myPlayer.BaseSprintSpeed
        LogDebug("Speedhack: Back up original values: ")
        LogDebug("Speedhack: BaseWalkSpeedBackUp: ", BaseWalkSpeedBackUp)
        LogDebug("Speedhack: BaseSprintSpeedBackUp: ", BaseSprintSpeedBackUp)
    end
    
    if hasAuthority then
        myPlayer.BaseWalkSpeed = newBaseWalkSpeed
        myPlayer.BaseSprintSpeed = newBaseSprintSpeed
        myPlayer.CustomTimeDilation = 1.0
    else
        myPlayer.BaseWalkSpeed = BaseWalkSpeedBackUp
        myPlayer.BaseSprintSpeed = BaseSprintSpeedBackUp
        myPlayer.CustomTimeDilation = Settings.SpeedhackMultiplier
    end
    if Settings.SpeedhackMultiplier ~= LastSpeedhackMultiplier then
        LastSpeedhackMultiplier = Settings.SpeedhackMultiplier
        LogDebug("Speedhack multiplier:", LastSpeedhackMultiplier)
        AFUtils.ClientDisplayWarningMessage("Speed x" .. LastSpeedhackMultiplier, AFUtils.CriticalityLevels.Green)
    end
end

local PlayerGravityScaleLastValue = nil
---@param myPlayer AAbiotic_PlayerCharacter_C
---@param hasAuthority boolean?
function PlayerGravityScale(myPlayer, hasAuthority)
    if not hasAuthority or IsNotValid(myPlayer) or IsNotValid(myPlayer.CharacterMovement) then return end

    if myPlayer.CharacterMovement.GravityScale > 0 and not NearlyEqual(Settings.PlayerGravityScale, myPlayer.CharacterMovement.GravityScale) then
        LogDebug("DefaultGravityScale was: ", myPlayer.DefaultGravityScale)
        LogDebug("CharacterMovement.GravityScale was: ", myPlayer.CharacterMovement.GravityScale)
        myPlayer.DefaultGravityScale = Settings.PlayerGravityScale
        myPlayer.CharacterMovement.GravityScale = Settings.PlayerGravityScale
        myPlayer:OnRep_ReplicateMovement()
        if PlayerGravityScaleLastValue ~= Settings.PlayerGravityScale then
            PlayerGravityScaleLastValue = Settings.PlayerGravityScale
            LogInfo("Player's Gravity x" .. myPlayer.CharacterMovement.GravityScale)
            AFUtils.ClientDisplayWarningMessage("Player's Gravity x" .. Settings.PlayerGravityScale, AFUtils.CriticalityLevels.Green)
        end
    end
end

local PreviosLeyakCooldown = 0
---@param hasAuthority boolean?
function SetLeyakCooldown(hasAuthority)
    if hasAuthority and Settings.LeyakCooldown and Settings.LeyakCooldown ~= PreviosLeyakCooldown then
        local aiDirector = AFUtils.GetAIDirector()
        if IsValid(aiDirector) and aiDirector.LeyakCooldown ~= Settings.LeyakCooldown then
            if Settings.LeyakCooldown <= 0 or Settings.LeyakCooldown == DefaultLeyakCooldown then
                Settings.LeyakCooldown = 0
                aiDirector.LeyakCooldown = DefaultLeyakCooldown
            else
                aiDirector.LeyakCooldown = Settings.LeyakCooldown
            end
            aiDirector:SetLeyakOnCooldown(1.0)
            local cooldownInMin = aiDirector.LeyakCooldown / 60
            local message = "Leyak's cooldown was set to " .. aiDirector.LeyakCooldown .. " (" .. cooldownInMin .. "min)"
            LogDebug(message)
            AFUtils.ClientDisplayWarningMessage(message, AFUtils.CriticalityLevels.Green)
            AFUtils.DisplayTextChatMessage(message, "", LinearColors.Green)
            PreviosLeyakCooldown = Settings.LeyakCooldown
        end
    end
end

-- local PreviosAutoSaveInterval = 0
-- ---@param hasAuthority boolean?
-- function SetAutoSaveInterval(hasAuthority)
--     if hasAuthority and Settings.AutoSaveInterval and Settings.AutoSaveInterval ~= PreviosAutoSaveInterval then
--         local gameInstance = AFUtils.GetGameInstance()
--         if gameInstance and gameInstance.AutosaveInterval ~= Settings.AutosaveInterval then
            
--         end
--     end
-- end

local CanCrouchRollPreId, CanCrouchRollPostId = nil, nil
local function InitCanCrouchRollHooks()
    if not CanCrouchRollPreId then
        CanCrouchRollPreId, CanCrouchRollPostId = RegisterHook("/Game/Blueprints/Characters/Abiotic_PlayerCharacter.Abiotic_PlayerCharacter_C:CanCrouchRoll?", function(Context, CanRoll)
            if Settings.InfiniteCrouchRoll then
                CanRoll:set(true)
            end
        end)
        LogDebug("CanCrouchRollPreId:", CanCrouchRollPreId)
        LogDebug("CanCrouchRollPostId:", CanCrouchRollPostId)
    end
end

local InfiniteCrouchRollWasEnabled = false
function InfiniteCrouchRoll()
    if Settings.InfiniteCrouchRoll then
        if not InfiniteCrouchRollWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Infinite Crouch Roll activated", AFUtils.CriticalityLevels.Green)
            InfiniteCrouchRollWasEnabled = true
        end
        InitCanCrouchRollHooks()
    elseif InfiniteCrouchRollWasEnabled then
        InfiniteCrouchRollWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Infinite Crouch Roll deactivated", AFUtils.CriticalityLevels.Red)
    end
end

local SetLockedContentTextPreId, SetLockedContentTextPostId = nil, nil
local function InitSetLockedContentTextHooks()
    if not SetLockedContentTextPreId then
        LoadAsset("/Game/Blueprints/Widgets/Journal/W_Compendium_Section.W_Compendium_Section_C")
        SetLockedContentTextPreId, SetLockedContentTextPostId = RegisterHook("/Game/Blueprints/Widgets/Journal/W_Compendium_Section.W_Compendium_Section_C:SetLockedContentText", function(Context)
            local context = Context:get() ---@type UW_Compendium_Section_C
            if Settings.JournalEntryUnlocker and not context.Unlocked then
                local progressComponent = AFUtils.GetMyCharacterProgressionComponent()
                if IsValid(progressComponent) then
                    if DebugMode then
                        LogInfo("Unlocking:", context.CompendiumRow.RowName:ToString())
                        LogInfo("SectionType:", context.SectionType)
                    end
                    progressComponent:Request_UnlockCompendiumSection(context.CompendiumRow.RowName, context.SectionType)
                end
            end
        end)
        LogDebug("SetLockedContentTextPreId:", SetLockedContentTextPreId)
        LogDebug("SetLockedContentTextPostId:", SetLockedContentTextPostId)
    end
end

local JournalEntryUnlockerWasEnabled = false
function JournalEntryUnlocker()
    if Settings.JournalEntryUnlocker then
        if not JournalEntryUnlockerWasEnabled then
            AFUtils.ClientDisplayWarningMessage("Journal Entry Unlocker activated", AFUtils.CriticalityLevels.Green)
            JournalEntryUnlockerWasEnabled = true
        end
        InitSetLockedContentTextHooks()
    elseif JournalEntryUnlockerWasEnabled then
        JournalEntryUnlockerWasEnabled = false
        AFUtils.ClientDisplayWarningMessage("Journal Entry Unlocker deactivated", AFUtils.CriticalityLevels.Red)
    end
end

-- function SetInventorySlotCount()
--     if Settings.InventorySlotCount and Settings.InventorySlotCount > 0 then
--         local myInventoryComponent = AFUtils.GetMyInventoryComponent()
--         if myInventoryComponent and myInventoryComponent.MaxSlots ~= Settings.InventorySlotCount then
--             myInventoryComponent.MaxSlots = Settings.InventorySlotCount
--             myInventoryComponent:UpdateInventorySlotCount(Settings.InventorySlotCount)
--             local message = "Inventory Size set to " .. myInventoryComponent.MaxSlots
--             LogDebug(message)
--             AFUtils.ClientDisplayWarningMessage(message, AFUtils.CriticalityLevels.Green)
--         end
--     end
-- end

-- ---@param myPlayer AAbiotic_PlayerCharacter_C
-- function DistantShore(myPlayer)
--     if Settings.DistantShore then
--         local deployedToiletPortal = FindFirstOf("Deployed_Toilet_Portal_C") ---@cast deployedToiletPortal ADeployed_Toilet_Portal_C
--         if IsValid(deployedToiletPortal) and deployedToiletPortal.DeployedByPlayer then
--             Settings.DistantShore = false
--             local message = "Sending to Distant Shore"
--             LogDebug(message)
--             AFUtils.ClientDisplayWarningMessage(message, AFUtils.CriticalityLevels.Green)
--             LogDebug("DistantShore: SendToDistantShore")
--             pcall(deployedToiletPortal.InteractTeleportUpdate, deployedToiletPortal, myPlayer, true, true)
--             AFUtils.ClientDisplayWarningMessage("Send to Distant Shore Disabled", AFUtils.CriticalityLevels.Red)
--         end
--     end
-- end