---- T-energy overcharge
Ext.RegisterOsirisListener("ObjectTurnEnded", 1, "before", function(object)
    if ObjectIsCharacter(object) == 0 then return end
    local character = Ext.GetCharacter(object)
    local te = CustomStatSystem:GetStatByID("TenebriumEnergy", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(object)
    local ti =  CustomStatSystem:GetStatByID("TenebriumInfusion", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(object)
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