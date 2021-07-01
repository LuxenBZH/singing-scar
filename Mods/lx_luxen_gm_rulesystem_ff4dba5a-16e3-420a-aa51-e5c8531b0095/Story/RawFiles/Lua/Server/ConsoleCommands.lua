------ Console commands -----
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
		CustomStatSystem:GetStatByID(aptitudes[rngList[i]], SScarID):SetValue(character, roll)
		base = base - roll
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
		CustomStatSystem:GetStatByID(social[rngList[i]], SScarID):SetValue(character, roll)
		base = base - roll
	end
	--print("remaining for social: "..base)
	if base > 0 then
		for i=1,6,1 do
			local basePoints = GetCustomStatPoints(character.MyGuid, social[rngList[i]])
			local roll = math.random(0, hardCap-baseCap)
			if roll > base then roll = base end
			base = base - roll
			CustomStatSystem:GetStatByID(social[rngList[i]], SScarID):SetValue(character, basePoints + roll)
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
		CustomStatSystem:GetStatByID(knowledge[rngList[i]], SScarID):SetValue(character, roll)
		base = base - roll
	end
	if base > 0 then
		for i=1,6,1 do
			local basePoints = GetCustomStatPoints(character.MyGuid, knowledge[rngList[i]])
			local roll = math.random(0, hardCap-baseCap)
			if roll > base then roll = base end
			CustomStatSystem:GetStatByID(knowledge[rngList[i]], SScarID):SetValue(character, basePoints + roll)
		end
	end
	print("Rolled stats for "..character.MyGuid)
end

local function SetCustomStat(stat, amount)
	local cstat = CustomStatSystem:GetStatByID(stat, SScarID)
	if cstat == nil or amount == nil then return end
	local selected = Osi.DB_GM_Selection:Get(nil)
	for i,char in pairs(selected) do
        cstat:SetValue(char[1], tonumber(amount))
		-- SRP_SyncAttributeBonuses(char[1])
	end
end

local function GenerateRandomStats()
	local char = Osi.DB_GM_Selection:Get(nil)
	for i,unit in pairs(char) do
        RollCustomStats(unit[1])
    end
end

local function AddToCustomStat(stat, amount)
	Ext.Print(stat)
	local cstat = CustomStatSystem:GetStatByID(stat, SScarID)
	if cstat == nil or amount == nil then return end
	local selected = Osi.DB_GM_Selection:Get(nil)
	for i,char in pairs(selected) do
		local base = cstat:GetValue(char[1])
		cstat:SetValue(char[1], tonumber(base+amount))
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
		-- PersistentVars.tEnergyServer[Ext.GetCharacter(char[1]).MyGuid] = tonumber(value)
		local oldValue = CustomStatSystem:GetStatByID("TenebriumEnergy", SScarID):GetValue(char[1])
		SetVarInteger(char[1], "SRP_TEnergy", value - oldValue)
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
		-- local previousValue = CustomStatSystem:GetStatByID("TenebriumEnergy", SScarID):GetValue(char[1])
		-- CustomStatSystem:GetStatByID("TenebriumEnergy", SScarID):SetValue(char[1], previousValue + tonumber(value))
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

local function PrintStatsRef()
    for i,stat in pairs(SScarStats) do
        local data = CustomStatSystem:GetStatByID(SScarStatsTranslated[stat], SScarID)
        local spacing = ""
        local length = string.len(stat)
		-- if length < 5 then spacing = spacing.."\t" end
        if length < 9 then spacing = spacing.."\t" end
		if length < 13 then spacing = spacing.."\t" end
        print(spacing..stat.."\t|\t"..data.DisplayName)
    end
end

local allCommands = {
    srp_statroll = {"Roll custom stats for the selected character(s).", handle = function(params) GenerateRandomStats() end},
    srp_statadd = {"Add to the specified custom stat (by ID).", handle = function(params) AddToCustomStat(FindCustomStat(params[1]), params[2]) end},
    srp_statset = {"Set the custom stat value (by ID)", handle = function(params) SetCustomStat(FindCustomStat(params[1]), params[2]) end},
    srp_plotarmor = {"Toggle plot armor (character will always fall unconscious)", handle = function(params) TogglePlotArmor() end},
    srp_careful = {"Toggle careful blows (character blows will never kill but put unconscious)", handle = function(params) NeverKill() end},
    srp_addte = {"Add to T-energy.", handle = function(params) AddTE(params[1]) end},
    srp_sette = {"Set T-energy value.", handle = function(params) SetTE(params[1]) end},
    -- srp_statref = {"Show the IDs of all stats to their translated name.", handle = function(params) PrintStatsRef() end}
}

local function SRP_DisplayHelp(category)
    print("-------------- Singing Scar help --------------")
    for command, desc in pairs(allCommands) do
        local desc = allCommands[command]
        local length = string.len(command)
        local spacing = "\t"
        if length < 5 then spacing = spacing.."\t" end
        if length < 13 then spacing = spacing.."\t" end
        print(" - "..command..spacing..desc[1])
    end
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
    for command,desc in pairs(allCommands) do
        if cmd == command then desc.handle(params) end
    end
    if cmd == "Help" then SRP_DisplayHelp(params[1]) end
end

-- Create console commands
for command,desc in pairs(allCommands) do
    Ext.RegisterConsoleCommand(command, SRP_consoleCmd)
end
Ext.RegisterConsoleCommand("Help", SRP_consoleCmd)
