------ Console commands -----
-- Console commands have to be used with NPC control tools. It will apply to characters that are selected.
function GenerateRandomnumberList(length, min, max)
	local rolled = {}
	local list = {}
	for i=1, length, 1 do
		::restart::
		local number = math.random(min, max)
		if rolled[number] then goto restart end
		rolled[number] = number
		list[i] = number
	end
	return list
end

function GetAptitudesCaps(character)
	local stats = character.Stats
	local attributes = {
		str = stats.BaseStrength,
		fin = stats.BaseFinesse,
		int = stats.BaseIntelligence,
		con = stats.BaseConstitution,
		mem = stats.BaseMemory,
		wit = stats.BaseWits
	}
	local aptitudes = {
		Endurance = 0,
		Agility = 0,
		Mind = 0
	}
	for stat, value in pairs(aptitudes) do
		aptitudes.Endurance = Ext.ExtraData.SRP_AptitudeBaseCap + math.floor((attributes.str+attributes.con-2*Ext.ExtraData.AttributeBaseValue)/2)
		aptitudes.Agility = Ext.ExtraData.SRP_AptitudeBaseCap + math.floor((attributes.fin+attributes.wit-2*Ext.ExtraData.AttributeBaseValue)/2)
		aptitudes.Mind = Ext.ExtraData.SRP_AptitudeBaseCap + math.floor((attributes.int+attributes.mem-2*Ext.ExtraData.AttributeBaseValue)/2)
	end
	-- print(aptitudes.Endurance)
	-- print(aptitudes.Agility)
	-- print(aptitudes.Mind)
	return aptitudes
end

function RollCustomStats(character)
	character = Ext.GetCharacter(character)
	-- Aptitudes
	local aptitudes = {
		"Endurance",
		"Agility",
		"Mind"
	}
	local base = Ext.ExtraData.SRP_AptitudeBasePoints + character.Stats.Level
	local caps = GetAptitudesCaps(character)
	local rngList = GenerateRandomnumberList(3, 1, 3)
	for i=1,3,1  do
		local roll = math.random(0, caps[aptitudes[rngList[i]]])
		if roll > base then roll = base end
		base = base - roll
		SetCustomStatPoints(character.MyGuid, aptitudes[rngList[i]], roll)
	end
	-- Social
	local social = {
		"Charisma",
		"Manipulation",
		"Suasion",
		"Intimidation",
		"Insight",
		"Intuition"
	}
	base = Ext.ExtraData.SRP_SocialBasePoints + character.Stats.Level
	local baseCap = Ext.ExtraData.SRP_SocialBaseCap
	local hardCap = Ext.ExtraData.SRP_SocialHardCap
	rngList = GenerateRandomnumberList(6, 1, 6)
	for i=1,6,1 do
		local roll = math.random(0, baseCap)
		if roll > base then roll = base end
		SetCustomStatPoints(character.MyGuid, social[rngList[i]], roll)
		base = base - roll
	end
	--print("remaining for social: "..base)
	if base > 0 then
		for i=1,6,1 do
			local basePoints = GetCustomStatPoints(character.MyGuid, social[rngList[i]])
			local roll = math.random(0, hardCap-baseCap)
			if roll > base then roll = base end
			base = base - roll
			SetCustomStatPoints(character.MyGuid, social[rngList[i]], basePoints + roll)
		end
	end
	---- Knowledge ----
	local knowledge = {
		"Alchemist",
		"Blacksmith",
		"Tailoring",
		"Enchanter",
		"Survivalist",
		"Academics",
		"Magic",
		"Medicine"
	}
	base = Ext.ExtraData.SRP_KnowledgeBasePoints + character.Stats.Level
	baseCap = Ext.ExtraData.SRP_KnowledgeBaseCap
	hardCap = Ext.ExtraData.SRP_KnowledgeHardCap
	rngList = GenerateRandomnumberList(6, 1, 6)
	for i=1,6,1 do
		local roll = math.random(0, baseCap)
		if roll > base then roll = base end
		SetCustomStatPoints(character.MyGuid, knowledge[rngList[i]], roll)
		base = base - roll
	end
	if base > 0 then
		for i=1,6,1 do
			local basePoints = GetCustomStatPoints(character.MyGuid, knowledge[rngList[i]])
			local roll = math.random(0, hardCap-baseCap)
			if roll > base then roll = base end
			SetCustomStatPoints(character.MyGuid, knowledge[rngList[i]], basePoints + roll)
		end
	end
	print("Rolled stats for "..character.MyGuid)
end

local function SetCustomStat(stat, amount)
	local cstat = NRD_GetCustomStat(stat)
	if cstat == nil or amount == nil then return end
	local selected = Osi.DB_GM_Selection:Get(nil)
	for i,char in pairs(selected) do
		NRD_CharacterSetCustomStat(char[1], cstat, tonumber(amount))
		SRP_SyncAttributeBonuses(char[1])
	end
end

local function GenerateRandomStats()
	local char = Osi.DB_GM_Selection:Get(nil)
	for i,unit in pairs(char) do
        RollCustomStats(unit[1])
    end
end

local function AddToCustomStat(stat, amount)
	local cstat = NRD_GetCustomStat(stat)
	if cstat == nil or amount == nil then return end
	local selected = Osi.DB_GM_Selection:Get(nil)
	for i,char in pairs(selected) do
		local base = GetCustomStatPoints(char[1], stat)
		NRD_CharacterSetCustomStat(char[1], cstat, tonumber(base+amount))
	end
end

local function TogglePlotArmor()
	local selected = Osi.DB_GM_Selection:Get(nil)
	for i,char in pairs(selected) do
		if HasActiveStatus(char[1], "SRP_PLOTARMOR") == 1 then 
			RemoveStatus(char[1], "SRP_PLOTARMOR")
			print("Plot armor deactivated for "..char[1])
		else
			ApplyStatus(char[1], "SRP_PLOTARMOR", -1.0, 1)
			print("Plot armor activated for "..char[1])
		end
	end
end

local function NeverKill()
	local selected = Osi.DB_GM_Selection:Get(nil)
	for i,char in pairs(selected) do
		if HasActiveStatus(char[1], "SRP_CAREFULBLOWS") == 1 then 
			RemoveStatus(char[1], "SRP_CAREFULBLOWS")
			print("Careful blows deactivated for "..char[1])
		else
			ApplyStatus(char[1], "SRP_CAREFULBLOWS", -1.0, 1)
			print("Careful blows activated for "..char[1])
		end 
	end
end

local function SetSightBoost(value)
	value = tonumber(value)
	local selected = Osi.DB_GM_Selection:Get(nil)
	for i,char in pairs(selected) do
		local currentBoost = NRD_CharacterGetPermanentBoostInt(char[1], "Sight")
		print("Current Sight boost: "..currentBoost)
		NRD_CharacterSetPermanentBoostInt(char[1], "Sight", currentBoost+value)
		print("New Sight boost: "..currentBoost+value)
	end
end

local function ShowSight()
	local selected = Osi.DB_GM_Selection:Get(nil)
	for i,char in pairs(selected) do
		print(NRD_CharacterGetComputedStat(char[1], "Sight", 0))
	end
end

local function ToggleNightVision()
	CharacterLaunchOsirisOnlyIterator("SRP_ToggleNightVision")
end

local function NightVisionStatus(character, event)
	if event ~= "SRP_ToggleNightVision" then return end
	if character == "NULL_00000000-0000-0000-0000-000000000000" then return end
	if HasActiveStatus(character, "SRP_NIGHTVISION") == 1 then
		RemoveStatus(character, "SRP_NIGHTVISION")
	else
		ApplyStatus(character, "SRP_NIGHTVISION", -1.0, 1)
	end
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", NightVisionStatus)

local function SetTE(value)
	local selected = Osi.DB_GM_Selection:Get(nil)
	for i,char in pairs(selected) do
		PersistentVars.tEnergyServer[Ext.GetCharacter(char[1]).MyGuid] = tonumber(value)
		SetVarInteger(char[1], "SRP_TEnergy", 0)
		SetTag(char[1], "SRP_TEIgnoreCombat")
    	SetStoryEvent(char[1], "SRP_UpdateTE")
	end
end

local function AddTE(value)
	local selected = Osi.DB_GM_Selection:Get(nil)
	for i,char in pairs(selected) do
		SetVarInteger(char[1], "SRP_TEnergy", tonumber(value))
		SetTag(char[1], "SRP_TEIgnoreCombat")
    	SetStoryEvent(char[1], "SRP_UpdateTE")
	end
end

local function GetTE()
	local selected = Osi.DB_GM_Selection:Get(nil)
	for i,char in pairs(selected) do
		print(GetTenebriumEnergy(char[1]))
	end
end

local function ClearServerTE()
	PersistentVars.tEnergyServer = nil
end

local function DisplayHelp()
	print("")
    print("---------- Commands for Singing Scar System ----------")
    print("Note : the commands noted with a star (*) require to use NPC Control tool selection to select at least one character.")
	print("* SetCustomStat <stat name> <value>  	#Set the custom stat of the selected character(s) to the value")
	print("* AddToCustomStat <stat name> <value>	#Add the specified amount of points to the stat")
	print("* RollCustomStats			#Randomize the custom stats of the selected character. The amount is scaled with level.")
	print("* TogglePlotArmor			#Cannot be seen in-game. A character with plot armor will always fall unconscious instead of dying, whatever is their death saving throw chances")
	print("* ToggleCarefulBlows			#Cannot be seen in-game. A character with careful blows will always put enemies unconscious instead of killing them, whatever is their death saving throw chances")
	print("* SetSightBoost <value>		#Change the sight boost of the character. Additive to the sight boost given by Agility and Perception. Can be negative.")
	print("* ToggleNightVision			#Toggle night vision, which reduce the vision cone of everyone by 10 meters.")
	print("* SetTE <value> 				#Set the Tenebrium Energy of a character to the specified value.")
	print("* GetTE 						#Print the current Tenebrium Energy of a character.")
	print("* AddTE <value> 				#Add the specified value to the T-energy pool of the selected character(s)")
end

local function SRP_consoleCmd(cmd, ...)
	local params = {...}
	for i=1,10,1 do
		local par = params[i]
		if par == nil then break end
		if type(par) == "string" then
			par = par:gsub("&", " ")
			par = par:gsub("\\ ", "&")
			params[i] = par
		end
	end
    if cmd == "SetCustomStat" then SetCustomStat(params[1], params[2]) end
	if cmd == "RollCustomStats" then GenerateRandomStats() end
	if cmd == "AddToCustomStat" then AddToCustomStat(params[1], params[2]) end
	if cmd == "TogglePlotArmor" then TogglePlotArmor() end
	if cmd == "ToggleCarefulBlows" then NeverKill() end
	if cmd == "SetSightBoost" then SetSightBoost(params[1]) end
	if cmd == "ShowSight" then ShowSight() end
	if cmd == "Help" then DisplayHelp() end
	if cmd == "SetTE" then SetTE(params[1]) end
	if cmd == "GetTE" then GetTE() end
	if cmd == "AddTE" then AddTE(params[1]) end
	if cmd == "ToggleNightVision" then ToggleNightVision() end
	if cmd == "ClearServerTE" then ClearServerTETable() end 
	
end

-- Ext.RegisterConsoleCommand("SetCustomStat", SRP_consoleCmd)
-- Ext.RegisterConsoleCommand("AddToCustomStat", SRP_consoleCmd)
-- Ext.RegisterConsoleCommand("RollCustomStats", SRP_consoleCmd)
-- Ext.RegisterConsoleCommand("TogglePlotArmor", SRP_consoleCmd)
-- Ext.RegisterConsoleCommand("ToggleCarefulBlows", SRP_consoleCmd)
-- Ext.RegisterConsoleCommand("SetSightBoost", SRP_consoleCmd)
-- --Ext.RegisterConsoleCommand("ShowSight", SRP_consoleCmd)
-- Ext.RegisterConsoleCommand("Help", SRP_consoleCmd)
-- Ext.RegisterConsoleCommand("ToggleNightVision", SRP_consoleCmd)
-- Ext.RegisterConsoleCommand("SetTE", SRP_consoleCmd)
-- Ext.RegisterConsoleCommand("GetTE", SRP_consoleCmd)
-- Ext.RegisterConsoleCommand("AddTE", SRP_consoleCmd)
-- Ext.RegisterConsoleCommand("ClearServerTE", SRP_consoleCmd)