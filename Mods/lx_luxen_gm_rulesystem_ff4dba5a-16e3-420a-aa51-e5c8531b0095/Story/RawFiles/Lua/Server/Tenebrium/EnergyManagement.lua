-- Ext.Require("SRP_ShadowPowerShared.lua")
-- Ext.Require("SRP_ShadowPowerSkills.lua")
-- Ext.Require("SRP_Helpers.lua")

---- UI bar management
local function CatchGMPossession(character)
    -- Ext.Print("char made player")
    local char = Ext.GetCharacter(character)
    -- Ext.Print(char.IsPossessed)
    if char.IsPossessed then
        Ext.PostMessageToClient(character, "SRP_UIGMPossess", tostring(char.NetID))
    end
end

Ext.RegisterOsirisListener("CharacterMadePlayer", 1, "after", CatchGMPossession)

-- local function SendCharacterTEInformation(channel, netID)
--     local char = Ext.GetCharacter(tonumber(netID))
--     if CharacterGetReservedUserID(char.MyGuid) == -65536 then return end
--     local tEnergy = PersistentVars.tEnergyServer[char.MyGuid]
--     if tEnergy == nil then tEnergy = 0 end
--     Ext.PostMessageToClient(char.MyGuid, "SRP_UICharacterTE", tEnergy)
-- end

-- Ext.RegisterNetListener("SRP_UIRequestCharacterTE", SendCharacterTEInformation)

-- local function SendSheetTEInformation(channel, netID)
--     local char = Ext.GetCharacter(tonumber(netID))
--     local tEnergy = PersistentVars.tEnergyServer[char.MyGuid]
--     if tEnergy == nil then tEnergy = 0 end
--     Ext.PostMessageToClient(char.MyGuid, "SRP_UISheetCharacterTE", tEnergy)
-- end

-- Ext.RegisterNetListener("SRP_UIRequestSheetCharacterTE", SendSheetTEInformation)



local tEnergyArray = {
    ["5"] = "SRP_TE5",
    ["10"] = "SRP_TE10",
    ["15"] = "SRP_TE15",
    ["20"] = "SRP_TE20",
    ["25"] = "SRP_TE25",
    ["30"] = "SRP_TE30",
    ["35"] = "SRP_TE35",
    ["50"] = "SRP_TE50",
    ["75"] = "SRP_TE75"
}

function GetTenebriumEnergy(character)
    return PersistentVars.tEnergyServer[Ext.GetCharacter(character).MyGuid] or 0
end

local function UpdateTETag(character, newValue)
    -- Ext.Print(newValue)
    for value, tag in pairs(tEnergyArray) do
        if tonumber(newValue) >= tonumber(value) then
            SetTag(character, tag)
            -- Ext.Print("Set", character, tag)
        else
            ClearTag(character, tag)
            -- Ext.Print("Cleared", character, tag)
        end
    end
    if Mods.LeaderLib ~= nil and CharacterGetReservedUserID(character) ~= -65536 then
        Mods.LeaderLib.GameHelpers.UI.RefreshSkillBar(character)
    end
end

local function UpdateTE(character, event)
    if event ~= "SRP_UpdateTE" then return end
    -- Mods have to set SRP_TEnergy integer var of the character before calling this event
    local char = Ext.GetCharacter(character)
    local newValue = tonumber(GetVarInteger(character, "SRP_TEnergy"))
    if newValue == nil then return end
    if newValue > 0 and HasActiveStatus(character, "TEN_CHANNEL") == 1 then return end
    if CharacterIsInCombat(character) == 0 and IsTagged(character, "SRP_TEIgnoreCombat") == 0 then return end
    
    ClearTag(character, "SRP_TEIgnoreCombat")
    -- if PersistentVars.tEnergyServer[char.MyGuid] == nil then PersistentVars.tEnergyServer[char.MyGuid] = 0 end
    -- newValue = PersistentVars.tEnergyServer[char.MyGuid] + newValue
    local oldValue = CustomStatSystem:GetStatByID("TenebriumEnergy", SScarID):GetValue(character)
    newValue = oldValue + newValue
    local ti = CustomStatSystem:GetStatByID("TenebriumInfusion", SScarID):GetValue(character)
    if newValue > 100 then newValue = 100 end
    -- Overcharge lock if it's not your turn
    if IsTagged(character, "SRP_InCombatTurn") == 0 then
        if oldValue < ti and newValue > ti then
            newValue = ti
        end
    end
    if newValue < 0 then newValue = 0 end
    CustomStatSystem:GetStatByID("TenebriumEnergy", SScarID):SetValue(character, newValue)
    -- PersistentVars.tEnergy[char.NetID] = newValue
    -- SetCharacterCustomStatTag(char, "SRP_TenebriumEnergy_", newValue)
    -- NRD_CharacterSetPermanentBoostInt(char.MyGuid, "CustomResistance", newValue)
    -- CharacterAddAttribute(char.MyGuid, "Dummy", 0)
    -- PersistentVars.tEnergyServer[char.MyGuid] = newValue
    -- Ext.Print("Updating TE", newValue)
    UpdateTETag(character, newValue)
    -- SendCharacterTEInformation(nil, char.NetID)
    Ext.PostMessageToClient(character, "SRP_UICharacterTE", "")
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", UpdateTE)

local function OverchargeLock(character)
    SetTag(character, "SRP_InCombatTurn")
end

Ext.RegisterOsirisListener("ObjectTurnStarted", 1, "before", OverchargeLock)

local function OverchargeUnlock(character)
    ClearTag(character, "SRP_InCombatTurn")
end

Ext.RegisterOsirisListener("ObjectTurnEnded", 1, "before", OverchargeUnlock)

-- local function EnableTEnergy()
--     if PersistentVars.tEnergyServer == nil then
--         PersistentVars.tEnergyServer = {}
--     end
--     PersistentVars.tEnergy = {}
-- end

-- Ext.RegisterListener("SessionLoaded", EnableTEnergy)

-- local function RestoreTEnergy(level, editor)
    -- PersistentVars.tEnergy = {}
    -- if PersistentVars.tEnergyServer ~= nil then
    --     for char,te in pairs(PersistentVars.tEnergyServer) do
    --         if ObjectExists(char) == 1 then
                -- PersistentVars.tEnergy[Ext.GetCharacter(char).NetID] = te
                -- NRD_CharacterSetPermanentBoostInt(char, "CustomResistance", te)
                -- CharacterAddAttribute(char, "Dummy", 0)
                -- SetCharacterCustomStatTag(Ext.GetCharacter(char), "SRP_TenebriumEnergy_", te)
                -- SetVarInteger(char, "SRP_TEnergy", te)
    --             UpdateTETag(char, te)
    --             if CharacterGetReservedUserID(char) ~= -65536 then
    --                 Ext.PostMessageToClient(char, "SRP_UICharacterTE", te)
    --             end
    --         end
    --     end
    -- end
-- end

-- Ext.RegisterOsirisListener("GameStarted", 2, "after", RestoreTEnergy)



-- local function InitShadowBarValueServer()
--     local playerCharacters = Osi.DB_IsPlayer:Get(nil)
--     for i,row in pairs(playerCharacters) do
--         local char = Ext.GetCharacter(row[1])
--         SendCharacterTEInformation(nil, char.NetID)
--     end
-- end

-- Ext.RegisterNetListener("SRP_UIShadowBarInitValue", InitShadowBarValueServer)

-- if Mods.LeaderLib ~= nil then
--     Mods.LeaderLib.AbilityManager.EnableAbility("Sourcery", "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
-- end

local function ConsumeTEfromTag(character, skill, skillType, skillElement)
    local skill = Ext.GetStat(skill)
    if skill.Ability ~= "Source" then return end
    for i, requirement in pairs(skill.Requirements) do
        if requirement.Requirement == "Tag" then
            local _,_,amount = string.find(requirement.Param, "SRP_TE(%d+)") --Ty LaughingLeader
            if amount ~= nil then
                SetVarInteger(character, "SRP_TEnergy", -amount)
            end
            SetTag(character, "SRP_TEIgnoreCombat")
            UpdateTE(character, "SRP_UpdateTE")
        end
    end
end

Ext.RegisterOsirisListener("CharacterUsedSkill", 4, "before", ConsumeTEfromTag)


CustomStatSystem:RegisterStatValueChangedListener("TenebriumEnergy", function(id, stat, character, previousPoints, currentPoints)
    if CharacterIsInCombat(character.MyGuid) == 0 and IsTagged(character.MyGuid, "SRP_TEIgnoreCombat") == 0 then
        UpdateTETag(character.MyGuid, currentPoints)
        Ext.PostMessageToClient(character.MyGuid, "SRP_UICharacterTE", "")
    else
        UpdateTE(character.MyGuid, "SRP_UpdateTE")
    end
end)