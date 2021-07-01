Ext.RegisterOsirisListener("CharacterUsedSkill", 4, "after", function(char, skill, skillType, skillElement)
    if skill ~= "Shout_TEN_Channel" then return end
    -- local currentTE = PersistentVars.tEnergyServer[char]
    SetVarInteger(char, "SRP_TEnergy", -30)
    SetTag(char, "SRP_TEIgnoreCombat")
    SetStoryEvent(char, "SRP_UpdateTE")
end)