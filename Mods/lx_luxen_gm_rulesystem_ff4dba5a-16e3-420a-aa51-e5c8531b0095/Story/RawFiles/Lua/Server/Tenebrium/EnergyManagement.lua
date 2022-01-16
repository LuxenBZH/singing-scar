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
    [5] = "SRP_TE5",
    [10] = "SRP_TE10",
    [15] = "SRP_TE15",
    [20] = "SRP_TE20",
    [25] = "SRP_TE25",
    [30] = "SRP_TE30",
    [35] = "SRP_TE35",
    [40] = "SRP_TE40",
    [50] = "SRP_TE50",
    [75] = "SRP_TE75"
}

local ocThresholds = {
    [1] = "TEN_OVERCHARGE1",
    [2] = "TEN_OVERCHARGE2",
    [3] = "TEN_OVERCHARGE3",
    [4] = "TEN_OVERCHARGE4",
}

local function UpdateOvercharge(character, te)
    -- local ti = CustomStatSystem:GetStatByID("TenebriumInfusion", SScarID):GetValue(character)
    local ti = Ext.GetCharacter(character):GetCustomStat(StatTI.Id)
    if te > ti then
        local step = ocThresholds[GetOverchargeStep(character)]
        Ext.Print(step)
        if step then
            ApplyStatus(character, step, -1, 1)
            SetStoryEvent(character, "SRP_Overcharging")
        end
    else
        for threshold, status in pairs(ocThresholds) do
            if HasActiveStatus(character, status) == 1 then
                RemoveStatus(character, status)
                SetStoryEvent(character, "SRP_OverchargeLoss")
            end
        end
    end
end

local function UpdateTETag(character, newValue)
    -- Ext.Print(newValue)
    for value, tag in pairs(tEnergyArray) do
        if tonumber(newValue) >= value then
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
    UpdateOvercharge(character, newValue)
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
    -- local oldValue = CustomStatSystem:GetStatByID("TenebriumEnergy", SScarID):GetValue(character)
    local oldValue = char:GetCustomStat(StatTE.Id)
    newValue = oldValue + newValue
    -- local ti = CustomStatSystem:GetStatByID("TenebriumInfusion", SScarID):GetValue(character)
    local ti = char:GetCustomStat(StatTI.Id)
    if newValue > 100 then newValue = 100 end
    -- Overcharge lock if it's not your turn
    if IsTagged(character, "SRP_InCombatTurn") == 0 then
        if oldValue < ti and newValue > ti then
            newValue = ti
        end
    else
    end
    if newValue < 0 then newValue = 0 end
    -- CustomStatSystem:GetStatByID("TenebriumEnergy", SScarID):SetValue(character, newValue)
    char:SetCustomStat(StatTE.Id, newValue)
    UpdateTETag(character, newValue)
    if newValue - oldValue > 0 then
        IncreaseInfusionProgress(character, newValue - oldValue)
    end
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


-- CustomStatSystem:RegisterStatValueChangedListener("TenebriumEnergy", function(id, stat, character, previousPoints, currentPoints)
--     if CharacterIsInCombat(character.MyGuid) == 0 and IsTagged(character.MyGuid, "SRP_TEIgnoreCombat") == 0 then
--         UpdateTETag(character.MyGuid, currentPoints)
--         Ext.PostMessageToClient(character.MyGuid, "SRP_UICharacterTE", "")
--     else
--         UpdateTE(character.MyGuid, "SRP_UpdateTE")
--     end
-- end)