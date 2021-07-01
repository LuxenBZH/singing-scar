-- Ext.Require("Stats/Shared/Effects.lua")
Ext.Require("Shared/_InitShared.lua")

SScarID = "ff4dba5a-16e3-420a-aa51-e5c8531b0095"
CustomStatSystem = Mods.LeaderLib.CustomStatSystem
ts = Mods.LeaderLib.Classes.TranslatedString

--- function to retrieve custom stat set through tags
--- Stat tags shall be in the following format : PREFIX_Stat_Value
--- @param character EclCharacter
--- @param tagPrefix string
function RetrieveCharacterCustomStatValue(character, tagPrefix)
    local tags = character:GetTags()
    local value
    for i,tag in pairs(tags) do
        if tag:match(tagPrefix) ~= nil then
            value = tag:gsub(".*_", "")
        end
    end
    if value ~= nil then
        return tonumber(value)
    else
        return 0
    end
end

--- @param character EclCharacter
--- @param tagPrefix string
function ClearCharacterCustomStatTag(character, tagPrefix)
    local tags = character:GetTags()
    local value
    for i,tag in pairs(tags) do
        if tag:match(tagPrefix) ~= nil then
            ClearTag(character.MyGuid, tag)
        end
    end
end

---@param str string
function SubstituteString(str, ...)
    local args = {...}
    local result = str

    for k, v in pairs(args) do
        if type(v) == "number" then
            if v == math.floor(v) then v = math.floor(v) end -- Formatting integers to not show .0
            result = result:gsub("%["..tostring(k).."%]", v)
        else
            result = result:gsub("%["..tostring(k).."%]", v)
        end
    end
    return result
end