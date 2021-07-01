local customBonuses = {
    Agility = {Sight = 50},
    Perception = {Sight = 20},
    Vision = {Sight = 100}
}

--- @param character EsvCharacter
function SRP_SyncAttributeBonuses(char)
    if ObjectExists(char) == 0 then return end
    char = Ext.GetCharacter(char)
    if char == nil then return end
    for attribute, bonuses in pairs(customBonuses) do
        local charAttr = CustomStatSystem:GetStatByID(attribute, "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(char)
        local statusName = "SRP_"..attribute.."_"..charAttr
        if NRD_StatExists(statusName) then
            ApplyStatus(char.MyGuid, statusName, -1, 1)
        else
            local newPotion = Ext.CreateStat("SRP_Potion_"..attribute.."_"..charAttr, "Potion", "SRP_Potion_Base")
            for bonus,value in pairs(bonuses) do
                newPotion[bonus] = charAttr * value
            end
            Ext.SyncStat(newPotion.Name, false)
            local newStatus = Ext.CreateStat("SRP_"..attribute.."_"..charAttr, "StatusData", "SRP_BASE")
            newStatus["StatsId"] = newPotion.Name
            newStatus["StackId"] = "SRP_"..attribute
            Ext.SyncStat(newStatus.Name, false)
            ApplyStatus(char.MyGuid, statusName, -1)
        end
    end
end

for cStat, j in pairs(customBonuses) do
    CustomStatSystem:RegisterStatValueChangedListener(cStat, function(id, stat, character, previousPoints, currentPoints)
        SRP_SyncAttributeBonuses(character.MyGuid)
    end)
end

local function SRP_ReloadStats(level, isEditor)
    CharacterLaunchOsirisOnlyIterator("SRP_ApplyCustomStatuses")
end

Ext.RegisterOsirisListener("GameStarted", 2, "before", SRP_ReloadStats)

local function SRP_CheckStats(character, event)
    if event ~= "SRP_ApplyCustomStatuses" then return end
    SRP_SyncAttributeBonuses(character)
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", SRP_CheckStats)

Ext.RegisterOsirisListener("CharacterJoinedParty", 1, "after", function(characterGUID)
    local owner = CharacterGetOwner(characterGUID)
    if owner == nil or owner == "" then return end
    local char = Ext.GetCharacter(characterGUID)
    local sight = Ext.GetStat(char.RootTemplate.Stats).Sight
    if sight ~= nil and tonumber(sight) < 6 then
        NRD_CharacterSetPermanentBoostInt(characterGUID, "Sight", 600)
        CharacterAddAttribute(characterGUID, "Dummy", 0)
    end
end)

Ext.RegisterOsirisListener("CharacterLeftParty", 1, "after", function(characterGUID)
    local char = Ext.GetCharacter(characterGUID)
    local sight = Ext.GetStat(char.RootTemplate.Stats).Sight
    if sight ~= nil then
        if tonumber(sight) < 6 then
            NRD_CharacterSetPermanentBoostInt(characterGUID, "Sight", 0)
            CharacterAddAttribute(characterGUID, "Dummy", 0)
        end
    end
end)
