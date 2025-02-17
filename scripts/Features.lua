
require("Settings")
local AFUtils = require("AFUtils.AFUtils")
local LinearColors = require("AFUtils.BaseUtils.LinearColors")

local InfiniteHealthWasEnabled = false
---@param myPlayer AAbiotic_PlayerCharacter_C
function InfiniteHealth(myPlayer)
    if Settings.GodMode or Settings.InfiniteHealth then
        if not myPlayer.Invincible then
            myPlayer.Invincible = true
            AFUtils.HealAllLimbs(myPlayer)
            myPlayer:OnRep_CurrentHealth()
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
function InfiniteEnergy(myPlayer)
    if Settings.InfiniteEnergy then
        -- AFUtils.FixHeldItemLiquid(myPlayer)
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
function NoOverheat(myPlayer)
    if Settings.NoOverheat then
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
function Invisible(myPlayer)
    if Settings.Invisible then
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
function NoFallDamage(myPlayer)
    if Settings.NoFallDamage then
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
function NoClip(myPlayer)
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
local LastSpeedhackMultiplier = Settings.SpeedhackMultiplier
---@param myPlayer AAbiotic_PlayerCharacter_C
function Speedhack(myPlayer)
    if Settings.SpeedhackMultiplier ~= LastSpeedhackMultiplier then
        if LastSpeedhackMultiplier == 1.0 then
            BaseWalkSpeedBackUp = myPlayer.BaseWalkSpeed
            BaseSprintSpeedBackUp = myPlayer.BaseSprintSpeed
            LogDebug("Speedhack: Back up original values: ")
            LogDebug("Speedhack: BaseWalkSpeedBackUp: ", BaseWalkSpeedBackUp)
            LogDebug("Speedhack: BaseSprintSpeedBackUp: ", BaseSprintSpeedBackUp)
        end
        LastSpeedhackMultiplier = Settings.SpeedhackMultiplier
        myPlayer.BaseWalkSpeed = BaseWalkSpeedBackUp * LastSpeedhackMultiplier
        myPlayer.BaseSprintSpeed = BaseSprintSpeedBackUp * LastSpeedhackMultiplier
        AFUtils.ClientDisplayWarningMessage("Speed x" .. LastSpeedhackMultiplier, AFUtils.CriticalityLevels.Green)
    end
end

---@param myPlayer AAbiotic_PlayerCharacter_C
function PlayerGravityScale(myPlayer)
    if IsNotValid(myPlayer) or IsNotValid(myPlayer.CharacterMovement) then return end

    if myPlayer.CharacterMovement.GravityScale > 0 and not NearlyEqual(Settings.PlayerGravityScale, myPlayer.CharacterMovement.GravityScale) then
        LogDebug("DefaultGravityScale was: ", myPlayer.DefaultGravityScale)
        LogDebug("CharacterMovement.GravityScale was: ", myPlayer.CharacterMovement.GravityScale)
        myPlayer.DefaultGravityScale = Settings.PlayerGravityScale
        myPlayer.CharacterMovement.GravityScale = Settings.PlayerGravityScale
        myPlayer:OnRep_ReplicateMovement()
        LogInfo("Player's Gravity x" .. myPlayer.CharacterMovement.GravityScale)
        AFUtils.ClientDisplayWarningMessage("Player's Gravity x" .. Settings.PlayerGravityScale, AFUtils.CriticalityLevels.Green)
    end
end

local PreviosLeyakCooldown = 0
function SetLeyakCooldown()
    if Settings.LeyakCooldown and Settings.LeyakCooldown ~= PreviosLeyakCooldown then
        local aiDirector = AFUtils.GetAIDirector()
        if aiDirector and aiDirector.LeyakCooldown ~= Settings.LeyakCooldown then
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