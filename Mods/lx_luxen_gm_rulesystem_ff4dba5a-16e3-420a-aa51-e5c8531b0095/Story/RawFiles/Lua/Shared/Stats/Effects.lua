---@param character EclCharacter
---@return integer
function GetDeathSavingChance(character)
    local endurance = CustomStatSystem:GetStatByID("Endurance", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character) * 2
    local body = CustomStatSystem:GetStatByID("Body", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
    local willpower = CustomStatSystem:GetStatByID("Willpower", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
    return endurance + body + willpower
end

---@param character EclCharacter
---@param stat string
function GetAptitudeCap(character, stat)
    local aptitudesReference = {
        Endurance = {"Strength", "Constitution"},
        Mind = {"Intelligence", "Memory"},
        Agility = {"Finesse", "Wits"}
    }
    return 8 + math.floor((character.Stats["Base"..aptitudesReference[stat][1]] + character.Stats["Base"..aptitudesReference[stat][2]] - 2*Ext.ExtraData.AttributeBaseValue)/2)
end

function GetIdentificationChance(character)
    local mind = CustomStatSystem:GetStatByID("Mind", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character) * 3
    local perception = CustomStatSystem:GetStatByID("Perception", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
    return mind + perception
end

function GetSightBonusRange(character)
    local agility = CustomStatSystem:GetStatByID("Agility", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character) * 0.5
    local perception = CustomStatSystem:GetStatByID("Perception", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character) * 0.2
    return agility+perception
end

function GetStatAverage(character, stat1, stat2)
    local stat1Points = CustomStatSystem:GetStatByID(stat1, "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
    local stat2Points = CustomStatSystem:GetStatByID(stat2, "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
    return math.floor((stat1Points+stat2Points)/2)
end