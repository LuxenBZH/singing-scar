-- CustomStatSystem = Mods.LeaderLib.CustomStatSystem

damageTypes = {
    "Physical",
    "Piercing",
    "Fire",
    "Air",
    "Water",
    "Earth",
    "Poison",
    "Shadow",
    "Corrosive",
    "Magic"
}

magicDamageTypes = {
    "Fire",
    "Air",
    "Water",
    "Earth",
    "Poison",
    "Magic"
}

physicalDamageTypes = {
    "Physical",
    "Corrosive"
}

--- @param hit HitRequest
function HitGetMagicDamage(hit)
    local total = 0
    for i,dmgType in pairs(magicDamageTypes) do
        total = total + hit.DamageList:GetByType(dmgType)
    end
    return total
end

--- @param hit HitRequest
function HitGetPhysicalDamage(hit)
    local total = 0
    for i,dmgType in pairs(physicalDamageTypes) do
        total = total + hit.DamageList:GetByType(dmgType)
    end
    return total
end

--- @param hit HitRequest
function HitGetTotalDamage(hit)
    local total = 0
    for i,dmgType in pairs(damageTypes) do
        total = total + hit.DamageList:GetByType(dmgType)
    end
    return total
end

--- @param hit HitRequest
--- @param target EsvCharacter
function HitRecalculateAbsorb(hit, target)
    if getmetatable(target) == "esv::Character" then
        local physDmg = HitGetPhysicalDamage(hit)
        local magicDmg = HitGetMagicDamage(hit)
        local pArmourAbsorb = math.min(target.Stats.CurrentArmor, physDmg)
        local mArmourAbsorb = math.min(target.Stats.CurrentMagicArmor, magicDmg)
        hit.ArmorAbsorption = math.min(pArmourAbsorb + mArmourAbsorb, hit.TotalDamageDone)
    end
end

--- @param hit HitRequest
--- @param target EsvCharacter
--- @param instigator EsvCharacter
function HitRecalculateLifesteal(hit, instigator)
    if (hit.EffectFlags & Game.Math.HitFlag.DoT) == Game.Math.HitFlag.DoT or (hit.EffectFlags & Game.Math.HitFlag.Surface) == Game.Math.HitFlag.Surface then return end
    hit.LifeSteal = math.floor(Ext.Round((instigator.Stats.LifeSteal / 100) * (hit.TotalDamageDone - hit.ArmorAbsorption)))
end

--- @param hit HitRequest
--- @param target EsvCharacter
--- @param damageType string
--- @param amount integer
function HitAddDamage(hit, target, instigator, damageType, amount)
    hit.TotalDamageDone = math.ceil(hit.TotalDamageDone + amount)
    hit.DamageList:Add(damageType, amount)
    HitRecalculateAbsorb(hit, target)
    if instigator ~= nil then
        HitRecalculateLifesteal(hit, instigator)
    end
end

--- @param hit HitRequest
--- @param target EsvCharacter
function HitMultiplyDamage(hit, target, instigator, multiplier)
    hit.DamageList:Multiply(multiplier)
    hit.TotalDamageDone = HitGetTotalDamage(hit)
    HitRecalculateAbsorb(hit, target)
    if instigator ~= nil then
        HitRecalculateLifesteal(hit, instigator)
    end
end

SScarStats = {
    "Endurance",
    "Mind",
    "Agility",
    "Body",
    "Willpower",
    "Perception",
    -- Social
    "Charisma",
    "Insight",
    "Intuition",
    "Intimidation",
    "Manipulation",
    "Suasion",
    -- Knowledge
    "Academics",
    "Alchemist",
    "Magic",
    "Blacksmith",
    "Enchanter",
    "Blacksmith",
    "Enchanter",
    "Medicine",
    "Survivalist",
    "Tailoring",
    -- Misc
    "TenebriumEnergy",
    "TenebriumInfusion",
    "Fortune",
    -- Development
    "Soul",
    "AptitudeDevelopment",
    "SocialDevelopment",
    "KnowledgeDevelopment",
    "AptitudesBase",
    "SocialBase",
    "KnowledgeBase",
    "Vision",
}

-- SScarStatsTranslated = {}
-- Mods.LeaderLib.RegisterListener("Initialized", function()
--     for i,stat in pairs(SScarStats) do
--         local data = CustomStatSystem:GetStatByID(stat, SScarID)
--         Ext.Dump(data)
--         if data ~= nil then
--             SScarStatsTranslated[Ext.GetTranslatedStringFromKey(data.DisplayName)] = stat
--         end
--     end
--     Ext.Dump(SScarStatsTranslated)
-- end)

local statCache = {}

-- function FindCustomStat(name)
--     if statCache[name] then
--         return statCache[name]
--     end
--     for stat in CustomStatSystem:GetAllStats(false, false, true) do
-- 		local cleanName = string.gsub(Ext.GetTranslatedStringFromKey(stat.DisplayName), "</.*>", "")
-- 		cleanName = string.gsub(cleanName, "<.*>", "")
--         if cleanName == name or stat:GetDisplayName() == name then
--             statCache[name] = stat.ID
--             return stat.ID
--         end
--     end
-- end

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

tnCalc = {
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

-- function GetTargetNumber(character, stat)
--     local tn = 0
--     if tnCalc[stat.ID] ~= nil then
--         tn = 0
--         for source, scaling in pairs(tnCalc[stat.ID]) do
--             if type(scaling) == "number" then
--                 tn = tn + math.floor(scaling * CustomStatSystem:GetStatByID(source):GetValue(character))
--             else
--                 for x=1,CustomStatSystem:GetStatByID(source):GetValue(character),1 do
--                     tn = tn + scaling[tostring(x)]
--                 end
--             end
--         end
--         if stat.PointID == "Social" then
--             tn = tn + 2*character.Stats.BasePersuasion
--         elseif stat.PointID == "Knowledge" then
--             tn = tn + 2*character.Stats.BaseTelekinesis + 2*character.Stats.BaseLoremaster
--         end
--     end
--     return tn
-- end

function ShiftTable(t)
    local temp = CopyTable(t)
    for i,content in pairs(t) do
        local j = i+1
        if j > GetTableSize(t) then j = 1 end
        t[i] = temp[j]
    end
    return t
end

function GetOverchargeStep(character)
    -- local ti = CustomStatSystem:GetStatByID("TenebriumInfusion", SScarID):GetValue(character)
    local ti = Ext.GetCharacter(character):GetCustomStat(StatTI.Id)
    if ti > 80 then return 4
    elseif ti > 60 then return 3
    elseif ti > 40 then return 2
    elseif ti > 20 then return 1
    else return 0
    end
end

function isOvercharged(character)
    -- return CustomStatSystem:GetStatByID("TenebriumEnergy", SScarID):GetValue(character) > CustomStatSystem:GetStatByID("TenebriumInfusion", SScarID):GetValue(character)
    character = Ext.GetCharacter(character)
    return character:GetCustomStat(StatTE.Id) > character:GetCustomStat(StatTI.Id)
end

function GetTotalDamage(target ,hitHandle)
    local totalDmg = 0
    for i, dmgType in pairs(damageTypes) do
        local dmg = NRD_HitStatusGetDamage(target, hitHandle, dmgType)
        totalDmg = totalDmg + dmg
    end
    return totalDmg
end

function ClearActionQueue(character, purge)
    if purge then
        CharacterPurgeQueue(character)
    else
        CharacterFlushQueue(character)
    end
    CharacterMoveTo(character, character, 1, "", 1)
    CharacterSetStill(character)
end