---- T-energy overcharge
Ext.RegisterOsirisListener("ObjectTurnEnded", 1, "before", function(object)
    if ObjectIsCharacter(object) == 0 then return end
    local character = Ext.GetCharacter(object)
    -- local te = CustomStatSystem:GetStatByID("TenebriumEnergy", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(object)
    -- local ti =  CustomStatSystem:GetStatByID("TenebriumInfusion", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(object)
    local te = character:GetCustomStat(StatTE.Id)
    local ti = character:GetCustomStat(StatTI.Id)
    local isOvercharged = te > ti
    if isOvercharged and GetOverchargeStep(object) > 0 then
        local hit = NRD_HitPrepare(object, object)
        local dmg = Game.Math.GetAverageLevelDamage(character.Stats.Level) * 0.3
        NRD_HitAddDamage(hit, "Shadow", dmg)
        NRD_HitSetInt(hit, "SimulateHit", 1)
        NRD_HitSetInt(hit, "HitType", 5)
        NRD_HitSetInt(hit, "CriticalRoll", 2)
        NRD_HitExecute(hit)
        CharacterStatusText(object, "<font color='#990099'>Tenebrium Overcharge !</font>")
    end
end)

---- 2nd step infusion
--- @param target string GUID
--- @param instigator string GUID
--- @param amount integer
--- @param handle double StatusHandle
Ext.RegisterOsirisListener("NRD_OnHeal", 4, "before", function(target, instigator, amount, handle)
    -- Ext.Print(instigator, handle)
    local heal = Ext.GetStatus(target, handle) ---@type EsvStatusHeal
    if GetOverchargeStep(target) > 2 and isOvercharged(target) then
        heal.HealAmount = 0
    end
end)

Ext.RegisterOsirisListener("NRD_OnStatusAttempt", 4, "before", function(target, statusId, handle, instigator)
    -- Ext.Print(statusId, NRD_StatExists(statusId), Ext.GetStat(statusId).StatusType)
    if statusId == "HEAL" or (NRD_StatExists(statusId) and Ext.GetStat(statusId).StatusType == "HEAL") then
        local heal = Ext.GetStatus(target, handle) ---@type EsvStatusHeal
        local amount = heal.HealAmount
        --- 3rd step infusion
        if GetOverchargeStep(target) > 2 and isOvercharged(target) and heal.HealType ~= "Vitality" then
            heal.HealAmount = -9999
            amount = 0
            CharacterStatusText(target, "<font color='#990099'>0!</font>")
        end
        --- 4th step infusion
        if GetOverchargeStep(target) > 3 and isOvercharged(target) and heal.HealType == "Vitality" then
            heal.HealAmount = -9999
            amount = 0
            CharacterStatusText(target, "<font color='#990099'>0!</font>")
        end
        if instigator ~= "NULL_00000000-0000-0000-0000-000000000000" then
            --- 2nd step infusion
            if GetOverchargeStep(instigator) > 1 and isOvercharged(instigator) then
                local hit = NRD_HitPrepare(instigator, instigator)
                NRD_HitAddDamage(hit, "Shadow", amount*0.1)
                NRD_HitSetInt(hit, "SimulateHit", 1)
                NRD_HitSetInt(hit, "HitType", 5)
                NRD_HitSetInt(hit, "CriticalRoll", 2)
                NRD_HitExecute(hit)
            end
            --- 3rd step infusion
            if GetOverchargeStep(instigator) > 2 and isOvercharged(instigator) and heal.HealType == "Vitality" then
                local target = Ext.GetCharacter(target)
                target.Stats.CurrentArmor = target.Stats.CurrentArmor + math.floor(amount*0.15)
                target.Stats.CurrentMagicArmor = target.Stats.CurrentMagicArmor + math.floor(amount*0.15)
            end
        end
    end
end)

---- 4th step infusion
Ext.RegisterOsirisListener("CharacterVitalityChanged", 2, "before", function(character, perc)
    if HasActiveStatus(character, "DEATH_RESIST") == 1 and isOvercharged(character) then
        if Ext.GetCharacter(character).Stats.CurrentVitality == 1 then
            RemoveStatus(character, "DEATH_RESIST")
        end
    end
end)