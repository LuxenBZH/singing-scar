local state = {
    [20] = 1,
    [40] = 2,
    [60] = 3,
    [80] = 4
}

setmetatable(state, {
    __index = function(table, key)
    local curState = 0
    for i,val in pairs(table) do
        if key > i then
            curState = val
        end
    end
    return curState
end})

local memoryBonus = {
    [0] = 0,
    [1] = 1,
    [2] = 3,
    [3] = 5,
    [4] = 8
}

-- CustomStatSystem:RegisterStatValueChangedListener("TenebriumInfusion", function(id, stat, character, prev, cur, isClient)
--     local curState = state[cur]
--     local prevState = state[prev]
--     if curState ~= prevState then
--         local memoryBoost = memoryBonus[curState] - memoryBonus[prevState]
--         local currentBoost = NRD_CharacterGetPermanentBoostInt(character.MyGuid, "Memory")
--         NRD_CharacterSetPermanentBoostInt(character.MyGuid, "Memory", currentBoost + memoryBoost)
--         CharacterAddAttribute(character.MyGuid, "Dummy", 0)
--     end
-- end)

function ManageInfusionMemoryBonus(character, prev, cur)
    local curState = state[cur]
    local prevState = state[prev]
    if curState ~= prevState then
        local memoryBoost = memoryBonus[curState] - memoryBonus[prevState]
        local currentBoost = NRD_CharacterGetPermanentBoostInt(character.MyGuid, "Memory")
        NRD_CharacterSetPermanentBoostInt(character.MyGuid, "Memory", currentBoost + memoryBoost)
        CharacterAddAttribute(character.MyGuid, "Dummy", 0)
    end
end

Ext.RegisterNetListener("SRP_CStatsChanged", function(call, payload)
    local infos = Ext.JsonParse(payload)
    local char = Ext.GetCharacter(infos.Character)
    local prev = GetVarInteger(char.MyGuid, "SRP_TInfusion") or char:GetCustomStat(StatTI.Id)
    local new = char:GetCustomStat(StatTI.Id)
    SetVarInteger(char.MyGuid, "SRP_TInfusion", new)
    if prev == new then return end
    ManageInfusionMemoryBonus(char, prev, new)
end)

---- Infusion Progress
function IncreaseInfusionProgress(character, value)
    character = Ext.GetCharacter(character)
    if CharacterIsInCombat(character.MyGuid) == 0 then return end
    local ip = GetVarInteger(character.MyGuid, "SRP_InfusionProgress") or 0
    local ti = character:GetCustomStat(StatTI.Id)
    if ip + value > ti*5 then
        local roll = math.random(1, 3)
        character:SetCustomStat(StatTI.Id, ti + roll)
        ManageInfusionMemoryBonus(character, ti, ti + roll)
        SetVarInteger(character.MyGuid, "SRP_InfusionProgress", 0)
    else
        SetVarInteger(character.MyGuid, "SRP_InfusionProgress", ip + value)
    end
end
-- CustomStatSystem:RegisterStatValueChangedListener("TenebriumEnergy", SScarID, function(id, stat, character, prev, cur, isClient)
--     if CharacterIsInCombat(character.MyGuid) == 1 and cur-prev > 0 then
--         local ip = CustomStatSystem:GetStatValueForCharacter(character, "SRP_InfusionProgress", SScarID)
--         CustomStatSystem:SetStat(character, "SRP_InfusionProgress", ip + cur-prev)
--     end
-- end)

Ext.RegisterOsirisListener("StoryEvent", 2, "before", function(character, event)
    if event == "SRP_Overcharging" and CharacterIsInCombat(character) == 1 then
        local character = Ext.GetCharacter(character)
        local ip = GetVarInteger(character.MyGuid, "SRP_InfusionProgress")
        local ti = character:GetCustomStat(StatTI.Id)
        -- local ip = CustomStatSystem:GetStatValueForCharacter(character, "SRP_InfusionProgress", SScarID)
        -- local ti = CustomStatSystem:GetStatValueForCharacter(character, "TenebriumInfusion", SScarID)
        -- CustomStatSystem:SetStat(character, "SRP_InfusionProgress", ip + math.floor(ti*5/8))
        IncreaseInfusionProgress(character.MyGuid, math.floor(ti*5/8))
    end
end)

-- CustomStatSystem:RegisterStatValueChangedListener("SRP_InfusionProgress", SScarID, function(id, stat, character, prev, cur, isClient)
--     local ti = CustomStatSystem:GetStatValueForCharacter(character, "TenebriumInfusion", SScarID)*5
--     if cur > ti*5 then
--         local roll = math.random(1,3)
--         CustomStatSystem:SetStat(character, "TenebriumInfusion", ti+roll, SScarID)
--         CustomStatSystem:SetStat(character, "SRP_InfusionProgress", 0, SScarID)
--         CharacterStatusText(character, "Tenebrium Infusion +"..tostring(roll).." !")
--     end
-- end)