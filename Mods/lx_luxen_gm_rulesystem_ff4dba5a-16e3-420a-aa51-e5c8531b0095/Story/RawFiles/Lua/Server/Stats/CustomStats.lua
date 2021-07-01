CustomStatSystem = Mods.LeaderLib.CustomStatSystem

local aptitudeDevStats = {
    AptitudeDevelopment = "Endurance",
    SocialDevelopment = "Charisma",
    KnowledgeDevelopment = "Academics"
}

local costs = {
    AptitudeDevelopment = 4,
    SocialDevelopment = 3,
    KnowledgeDevelopment = 2
}

for cStat,pool in pairs(aptitudeDevStats) do
    CustomStatSystem:RegisterStatValueChangedListener(cStat, function(id, stat, character, previousPoints, currentPoints)
        if currentPoints - previousPoints == 1 then
            local soul = CustomStatSystem:GetStatByID("Soul", "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
            local soulPoints = soul:GetValue(character.NetID)
            if soulPoints < costs[cStat]-1 then
                soul:SetValue(character.NetID, 0)
            else
                soul:SetValue(character.NetID, soulPoints - costs[cStat])
            end
            -- CustomStatSystem:AddAvailablePoints(character, cStat, 1, "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
            CustomStatSystem:AddAvailablePoints(character, pool, 1, "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
        end
    end)
end


-- CustomStatSystem:RegisterStatValueChangedListener("Soul", function(id, stat, character, previousPoints, currentPoints)
--     -- Ext.Print(currentPoints - previousPoints)
--     CustomStatSystem:AddAvailablePoints(character, "Development", currentPoints - previousPoints, "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
-- end)

local aptitudesAverage = {
    Endurance = {Body = "Agility", Willpower = "Mind"},
    Mind = {Willpower = "Endurance", Perception = "Agility"},
    Agility = {Body = "Endurance", Perception = "Mind"}
}

local function CalculateMight(character)
    local endurance = CustomStatSystem:GetStatByID("Endurance", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
    local mind = CustomStatSystem:GetStatByID("Mind", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
    local agility = CustomStatSystem:GetStatByID("Agility", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
    CustomStatSystem:GetStatByID("Might", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):SetValue(character, endurance+mind+agility)
end

for cStat, subStats in pairs(aptitudesAverage) do
    CustomStatSystem:RegisterStatValueChangedListener(cStat, function(id, stat, character, previousPoints, currentPoints)
        local subAptitudes = aptitudesAverage[id]
        for target, ref in pairs(subAptitudes) do 
            local average = GetStatAverage(character, id, ref)
            Ext.Print(target, ref, average)
            CustomStatSystem:GetStatByID(target, "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):SetValue(character, average)
        end
        CalculateMight(character)
    end)
end


local statToBase = {
    Endurance = "AptitudesBase",
    Mind = "AptitudesBase",
    Agility = "AptitudesBase",
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

for cStat, base in pairs(statToBase) do
    CustomStatSystem:RegisterStatValueChangedListener(cStat, function(id, stat, character, previousPoints, currentPoints)
        local baseData = CustomStatSystem:GetStatByID(base, "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
        local basePoints = baseData:GetValue(character)
        if basePoints > 0 then
            baseData:SetValue(character.NetID, basePoints - (currentPoints - previousPoints))
        end
    end)
end

local function ColourModifier(mod, lowerIsBetter)
    local good = "<font color=#33cc33>"
    local bad = "<font color=#ff0000>" 
    if lowerIsBetter then
        good = "<font color=#ff0000>"
        bad = "<font color=#33cc33>"
    end
    if mod > 0 then
        return good.."+"..tostring(mod).."</font>"
    else
        return bad..tostring(mod).."</font>"
    end
end

Ext.RegisterNetListener("SRP_Roll", function(channel, payload, ...)
    local infos = Ext.JsonParse(payload)
    local character = Ext.GetCharacter(tonumber(infos.character))
    local stat = CustomStatSystem:GetStatByID(infos.stat, SScarID)
    if infos.type == "RollNormal" then
        local tn = GetTargetNumber(character, stat)
        local text = "Rolling "..Ext.GetTranslatedStringFromKey(stat.DisplayName)
        if infos.mod ~= 0 then
            text = text.."<br>Modifier: "..ColourModifier(infos.mod, true)
        end
        local result = math.random(1,100) + tonumber(infos.mod)
        CharacterStatusText(character.MyGuid, text)
        -- PersistentVars.CurrentRolls[#PersistentVars.CurrentRolls + 1] = {character.MyGuid, tn, result, success}
        Timer.StartOneshot("SRP_RollStat", 2000, function()
            -- Ext.Print(result, tn)
            if result < tn then
                CharacterStatusText(character.MyGuid, "<font color=#33cc33>Success!</font><br>You rolled: "..tostring(result))
                CombatLog.AddTextToHost("Rolls", character.DisplayName.." rolled "..result.." ("..Ext.GetTranslatedStringFromKey(stat.DisplayName)..") and succeeded.")
                CombatLog.AddTextToAllPlayers("Rolls", character.DisplayName.." rolled "..result.." ("..Ext.GetTranslatedStringFromKey(stat.DisplayName)..") and succeeded.")
                PlayEffect(character.MyGuid, "RS3_FX_Overhead_Dice_Green", "Dummy_OverheadFX")
            else
                CharacterStatusText(character.MyGuid, "<font color=#ff0000>Failure!</font><br>You rolled: "..tostring(result))
                CombatLog.AddTextToHost("Rolls", character.DisplayName.." rolled "..result.." ("..Ext.GetTranslatedStringFromKey(stat.DisplayName)..") and failed.")
                CombatLog.AddTextToAllPlayers("Rolls", character.DisplayName.." rolled "..result.." ("..Ext.GetTranslatedStringFromKey(stat.DisplayName)..") and succeeded.")
                PlayEffect(character.MyGuid, "RS3_FX_Overhead_Dice_Red", "Dummy_OverheadFX")
            end
        end)
    end
end)
