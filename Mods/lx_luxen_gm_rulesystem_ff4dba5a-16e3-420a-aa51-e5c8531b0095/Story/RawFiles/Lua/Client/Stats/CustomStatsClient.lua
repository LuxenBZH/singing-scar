CustomStatSystem = Mods.LeaderLib.CustomStatSystem

CustomStatSystem:RegisterCanAddPointsHandler("Soul", function(id, stat, character, current, availablePoints, canAdd)
    return false
end)

local devCosts = {
    AptitudeDevelopment = 4,
    SocialDevelopment = 3,
    KnowledgeDevelopment = 2
}
for cStat,cost in pairs(devCosts) do
    CustomStatSystem:RegisterCanAddPointsHandler(cStat, function(id, stat, character, current, availablePoints, canAdd)
        local soul = CustomStatSystem:GetStatByID("Soul", "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
        local aptitudeDev = CustomStatSystem:GetStatByID(cStat, "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
        -- local hasAvailablePoints = CustomStatSystem:GetAvailablePointsForStat(aptitudeDev, character)
        local baseAptitudes = CustomStatSystem:GetStatByID("AptitudesBase", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
        local baseSocial = CustomStatSystem:GetStatByID("SocialBase", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
        local baseKnowledge = CustomStatSystem:GetStatByID("KnowledgeBase", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
        return ((soul:GetValue(character) > cost-1) and (baseAptitudes == 0 and baseSocial == 0 and baseKnowledge == 0))
    end)
end

local capAptitudes = {
    Endurance = "AptitudesBase",
    Mind = "AptitudesBase",
    Agility = "AptitudesBase"
}

local aptitudesReference = {
    Endurance = {"Strength", "Constitution"},
    Mind = {"Intelligence", "Memory"},
    Agility = {"Finesse", "Wits"}
}

for cStat,base in pairs(capAptitudes) do
    CustomStatSystem:RegisterCanAddPointsHandler(cStat, function(id, stat, character, current, availablePoints, canAdd)
        local statData = CustomStatSystem:GetStatByID(cStat, "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
        local hasAvailablePoints = CustomStatSystem:GetAvailablePointsForStat(statData, character)
        local baseData = CustomStatSystem:GetStatByID(base, "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
        local cap = 8 + math.floor((character.Stats["Base"..aptitudesReference[cStat][1]] + character.Stats["Base"..aptitudesReference[cStat][2]] - 2*Ext.ExtraData.AttributeBaseValue)/2)
        return ((statData:GetValue(character) < cap and hasAvailablePoints > 0) or (baseData:GetValue(character) > 0 and statData:GetValue(character) < 8))
    end)
end

local cap10 = {
    Charisma = "SocialBase",
    Insight = "SocialBase",
    Intimidation = "SocialBase",
    Intuition = "SocialBase",
    Manipulation = "SocialBase",
    Suasion = "SocialBase",
    Academics = "KnowledgeBase",
    Alchemist = "KnowledgeBase",
    Blacksmith = "KnowledgeBase",
    Tailoring = "KnowledgeBase",
    Enchanter = "KnowledgeBase",
    Survivalist = "KnowledgeBase",
    Medicine = "KnowledgeBase",
    Magic = "KnowledgeBase",
}

for cStat, base in pairs(cap10) do
    CustomStatSystem:RegisterCanAddPointsHandler(cStat, function(id, stat, character, current, availablePoints, canAdd)
        local statData = CustomStatSystem:GetStatByID(cStat, "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
        local hasAvailablePoints = CustomStatSystem:GetAvailablePointsForStat(statData, character)
        local baseData = CustomStatSystem:GetStatByID(base, "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
        return ((statData:GetValue(character) < 10 and hasAvailablePoints > 0) or (baseData:GetValue(character) > 0 and statData:GetValue(character) < 5))
    end)
end
