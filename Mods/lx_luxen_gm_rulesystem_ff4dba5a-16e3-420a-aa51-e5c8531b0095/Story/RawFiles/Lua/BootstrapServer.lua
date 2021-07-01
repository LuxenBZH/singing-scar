Ext.Require("BootstrapShared.lua")
-- Ext.Require("SRP_EXIMSupport.lua")
-- Ext.Require("SRP_MindIdentification.lua")
-- Ext.Require("SRP_ConsoleCommands.lua")
-- Ext.Require("SRP_StatsPatching.lua")
-- Ext.Require("SRP_CustomStats.lua")
-- Ext.Require("SRP_CustomBonuses.lua")
-- Ext.Require("SRP_ManageDeath.lua")
-- Ext.Require("SRP_ShadowPower_Server.lua")
-- Ext.Require("Stats/Server/CustomStats.lua")

Ext.Require("Server/_InitServer.lua")


PersistentVars = {}

------ Main ------
---- General Functions ----
-- function CheckStatsPresence()
	-- local customStats = {
	-- "---- Aptitudes ----",
	-- "Endurance",
	-- "Willpower",
	-- "Mind",
	-- "Perception",
	-- "Agility",
	-- "Body",
	-- "Might",
	-- "---- Social ----",
	-- "Charisma",
	-- "Manipulation",
	-- "Suasion",
	-- "Intimidation",
	-- "Insight",
	-- "Intuition",
	-- "---- Knowledge ----",
	-- "Alchemist",
	-- "Blacksmith",
	-- "Tailoring",
	-- "Enchanter",
	-- "Survivalist",
	-- "Academics",
	-- "Medicine",
	-- "Magic",
	-- "---- Misc ----",
	-- "Soul points",
	-- "Fortune point",
	-- "Body condition",
	-- "Tenebrium infusion"
	-- }
	
	-- for i,stat in pairs(customStats) do
	-- 	local exists = NRD_GetCustomStat(stat)
	-- 	if exists == nil then
	-- 		local statID = NRD_CreateCustomStat(stat, "")
	-- 	end
	-- end
-- end

-- Ext.NewCall(SRP_ManageCharacterCustomBonus, "LX_EXT_ManageCustomStatsBonus", "(GUIDSTRING)_Character");
-- Ext.NewCall(ManageUnconsciousRecover, "LX_EXT_ManageUnconsciousRecover", "(CHARACTERGUID)_Character, (INTEGER)_Amount");
-- Ext.NewCall(CheckStatsPresence, "LX_EXT_CheckStatsPresence", "");
-- Ext.NewQuery(StatsHasChanged, "LX_EXT_StatsChangeCheck", "(CHARACTERGUID)_Character");

------ Helpers ------
function GetCustomStatPoints(character, statName)
	if type(character) == "userdata" then
		character = character.MyGuid
	elseif type(character) == "nil" then
		return nil
	end
	local statID = NRD_GetCustomStat(statName)
	if statID == nil then print("Error when fetching "..statName..", its nil!"); return 0 end
	local charStat = NRD_CharacterGetCustomStat(character, statID)
	if charStat == nil then charStat=0 end
	return charStat
end

function SetCustomStatPoints(character, statName, value)
	local statID = NRD_GetCustomStat(statName)
	if statID == nil then print("Error when fetching "..statName..", its nil!"); return 0 end
	NRD_CharacterSetCustomStat(character, statID, value)
end

function CalculateMight(character)
	local aptitudes = {
		"Endurance",
		"Willpower",
		"Mind",
		"Perception",
		"Agility",
		"Body"
	}
	local points = 0
	for i,apt in pairs(aptitudes) do
		points = points + GetCustomStatPoints(character, apt)
	end
	return points
end

------ Net Message management -----
-- function CustomStatCheck(char)
	-- local Endurance = GetCustomStatPoints(char, "Endurance")
	-- local Agility = GetCustomStatPoints(char, "Agility")
	-- local Mind = GetCustomStatPoints(char, "Mind")
    -- local sAptitudes = {
    --     Body = {Endurance, Agility},
    --     Willpower = {Mind, Endurance},
    --     Perception = {Agility, Mind}
    -- }
	-- for sapt,mapt in pairs(sAptitudes) do
	-- 	local statID = NRD_GetCustomStat(sapt)
	-- 	NRD_CharacterSetCustomStat(char, statID, math.floor((mapt[1]+mapt[2])/2))
	-- end
	-- NRD_CharacterSetCustomStat(char, NRD_GetCustomStat("Might"), math.floor((Endurance+Agility+Mind)*2))
	-- SRP_SyncAttributeBonuses(char)
-- end

-- local function StartCustomStatCheck(call, netID)
-- 	local char = Ext.GetCharacter(tonumber(netID))
-- 	SetStoryEvent(char.MyGuid, "SRP_CustomStatCheckTimerStart")
-- end

-- Ext.NewCall(CustomStatCheck, "LX_EXT_MakeStatCheck", "(CHARACTERGUID)_Character")
-- Ext.RegisterNetListener("SRP_MakeCustomStatCheck", StartCustomStatCheck)

--- @param character EsvCharacter
--- @param tagPrefix string
function SetCharacterCustomStatTag(character, tagPrefix, value)
    ClearCharacterCustomStatTag(character, tagPrefix)
    SetTag(character.MyGuid, tagPrefix..value)
end

Ext.RegisterNetListener("SetCharacterTenebriumInfusionTag", function(call, text)
	local netID = string.gsub(text, "_.*$", "")
	local character = Ext.GetCharacter(tonumber(netID))
	local value = string.gsub(text, ".*_", "")
	SetCharacterCustomStatTag(character, "SRP_TenebriumInfusion_", value)
	-- CharacterAddAttribute(character.MyGuid, "Dummy", 0)
end)