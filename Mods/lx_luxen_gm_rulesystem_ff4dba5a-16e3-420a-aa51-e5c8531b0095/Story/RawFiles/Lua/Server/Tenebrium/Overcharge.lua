---- T-energy overcharge
Ext.RegisterOsirisListener("ObjectTurnStarted", 1, "before", function(object)
if ObjectIsCharacter(object) == 0 then return end
local te = CustomStatSystem:GetStatByID("TenebriumEnergy", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(object)
local ti =  CustomStatSystem:GetStatByID("TenebriumInfusion", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(object)
if ti > 19 and te > ti then
    local hit = NRD_HitPrepare(object, object)
    local dmg = math.floor(Ext.GetCharacter(object).Stats.MaxVitality*0.08)
    NRD_HitAddDamage(hit, "Shadow", dmg)
    NRD_HitSetInt(hit, "SimulateHit", 1)
    NRD_HitSetInt(hit, "HitType", 5)
    NRD_HitSetInt(hit, "CriticalRoll", 2)
    NRD_HitExecute(hit)
    CharacterStatusText(object, "<font color='#990099'>Tenebrium Overcharge !</font>")
end
-- if ti > 10 and te > ti then
--     local percDamage = te - ti
--     if percDamage > 15 then percDamage = 15 end
--     local hit = NRD_HitPrepare(object, object)
--     local dmg = math.floor(Ext.GetCharacter(object).Stats.MaxVitality*(percDamage/100))
--     NRD_HitAddDamage(hit, "Shadow", dmg)
--     NRD_HitSetInt(hit, "SimulateHit", 1)
--     NRD_HitExecute(hit)
-- end
end)