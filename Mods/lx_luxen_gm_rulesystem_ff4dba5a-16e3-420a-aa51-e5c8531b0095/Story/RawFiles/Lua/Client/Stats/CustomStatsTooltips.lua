local aptitudesScaling = {
    ["1"] = 6,
    ["2"] = 6,
    ["3"] = 6,
    ["4"] = 6,
    ["5"] = 5,
    ["6"] = 5,
    ["7"] = 5,
    ["8"] = 5,
    ["9"] = 4,
    ["10"] = 4,
    ["11"] = 4,
    ["12"] = 4,
    ["13"] = 3,
    ["14"] = 3,
    ["15"] = 3,
    ["16"] = 3,
    ["17"] = 2,
    ["18"] = 2,
    ["19"] = 2,
    ["20"] = 2,
}

local socialScaling = {
    ["1"] = 8,
    ["2"] = 8,
    ["3"] = 7,
    ["4"] = 7,
    ["5"] = 6,
    ["6"] = 6,
    ["7"] = 5,
    ["8"] = 5,
    ["9"] = 4,
    ["10"] = 4,
}

local tnCalc = {
    -- Aptitudes
    Endurance = {Endurance = aptitudesScaling},
    Mind = {Mind = aptitudesScaling},
    Agility = {Agility = aptitudesScaling},
    Body = {Body = aptitudesScaling},
    Willpower = {Willpower = aptitudesScaling},
    Perception = {Perception = aptitudesScaling},
    -- Social
    Charisma = {Charisma = socialScaling, Endurance = 1},
    Insight = {Insight = socialScaling, Perception = 1},
    Intuition = {Intuition = socialScaling, Willpower = 1},
    Intimidation = {Intimidation = socialScaling, Might = 0.34},
    Manipulation = {Manipulation = socialScaling, Agility = 1},
    Suasion = {Suasion = socialScaling, Mind = 1},
    -- Knowledge
    Academics = {Academics = 8},
    Alchemist = {Alchemist = 8},
    Magic = {Magic = 8},
    Blacksmith = {Blacksmith = 8},
    Enchanter = {Enchanter = 8},
    Blacksmith = {Blacksmith = 8},
    Enchanter = {Enchanter = 8},
    Medicine = {Medicine = 8},
    Survivalist = {Survivalist = 8},
    Tailoring = {Tailoring = 8},
}


---@param character EclCharacter
---@param stat CustomStatData
---@param tooltip TooltipData
local function OnStatTooltip(character, stat, tooltip)
    -- Ext.Dump(stat)
    -- Ext.Dump(tooltip)
    local el = tooltip:GetElement("StatsDescription")
    if stat.PointID == "Aptitudes" then
        if stat.ID == "Endurance" then
            el.Label = SubstituteString(el.Label, GetDeathSavingChance(character), GetAptitudeCap(character, stat.ID))
        elseif stat.ID == "Mind" then
            el.Label = SubstituteString(el.Label, GetIdentificationChance(character), GetAptitudeCap(character, stat.ID))
        elseif stat.ID == "Agility" then
            el.Label = SubstituteString(el.Label, math.floor(character.Stats.Sight/100)+GetSightBonusRange(character), GetAptitudeCap(character, stat.ID))
        end
        local base = CustomStatSystem:GetStatByID("AptitudesBase", "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
        local value = base:GetValue(character)
        if value > 0 then
            el.Label = el.Label.."<br><font color='#00bfff'>You have "..value.." Aptitude base points left. The cap for base points is 8.</font>"
        end
    elseif stat.PointID == "Social" then
        local base = CustomStatSystem:GetStatByID("SocialBase", "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
        local value = base:GetValue(character)
        if value > 0 then
            el.Label = el.Label.."<br><font color='#00bfff'>You have "..value.." Social base points left. The cap for base points is 5.</font>"
        end
    elseif stat.PointID == "Knowledge" then
        local base = CustomStatSystem:GetStatByID("KnowledgeBase", "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
        local value = base:GetValue(character)
        if value > 0 then
            el.Label = el.Label.."<br><font color='#00bfff'>You have "..value.." Knowledge base points left. The cap for base points is 5.</font>"
        end
    end
    if tnCalc[stat.ID] ~= nil then
        local tn = 0
        for source, scaling in pairs(tnCalc[stat.ID]) do
            if type(scaling) == "number" then
                tn = tn + math.floor(scaling * CustomStatSystem:GetStatByID(source):GetValue(character))
            else
                for x=1,CustomStatSystem:GetStatByID(source):GetValue(character),1 do
                    tn = tn + scaling[tostring(x)]
                end
            end
        end
        if stat.PointID == "Social" then
            tn = tn + 2*character.Stats.BasePersuasion
        elseif stat.PointID == "Knowledge" then
            tn = tn + 2*character.Stats.BaseTelekinesis + 2*character.Stats.BaseLoremaster
        end
        el.Label = "<font color=#c68c53>Target Number : "..tostring(tn).."</font><br>"..el.Label
    end
end

local function SRP_RegisterTooltips()
    Game.Tooltip.RegisterListener("CustomStat", nil, OnStatTooltip)
end

Ext.RegisterListener("SessionLoaded", SRP_RegisterTooltips)