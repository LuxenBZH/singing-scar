Ext.RegisterOsirisListener("CharacterUsedSkill", 4, "after", function(char, skill, skillType, skillElement)
    if skill == "Shout_TEN_Channel" then
        -- local currentTE = PersistentVars.tEnergyServer[char]
        SetVarInteger(char, "SRP_TEnergy", -30)
        SetTag(char, "SRP_TEIgnoreCombat")
        SetStoryEvent(char, "SRP_UpdateTE")
    elseif skill == "Shout_TEN_Unleash" then
        local te = CustomStatSystem:GetStatByID("TenebriumEnergy", SScarID):GetValue(char)
        local ti = CustomStatSystem:GetStatByID("TenebriumInfusion", SScarID):GetValue(char)
        if te == ti then
            SetVarInteger(char, "SRP_TEnergy", 30)
        else
            SetVarInteger(char, "SRP_TEnergy", 15)
        end
        SetStoryEvent(char, "SRP_UpdateTE")
    end
end)