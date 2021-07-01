local deathTag = {}

local function ManageCharacterDeath(character, status, handle, instigator)
	if status ~= "DYING" then return end
	if HasActiveStatus(character, "UNCONSCIOUS") == 1 then return end
	Ext.Print("DEATH!")
	-- Manage death saving throw
	local endurance = GetCustomStatPoints(character, "Endurance")
	local willpower = GetCustomStatPoints(character, "Willpower")
	local body = GetCustomStatPoints(character, "Body")
	if total ~= 0 then
		local resistChance = endurance*2 + willpower + body
		local tagged = deathTag[character]
		-- local tagged = Osi.DB_SRP_TaggedDeathResist:Get(nil, character)
		-- local cheatTagged = Osi.DB_SRP_TaggedCheatDeathResist:Get(nil, character)
		-- if tagged[1] ~= nil then
		-- 	resistChance = resistChance + 33
		-- end
		-- if cheatTagged[1] ~= nil then
		-- 	resistChance = 999
        -- end
        if tagged == "SRP_AVOIDDEATH" then
            resistChance = resistChance + 50
        elseif tagged == "SRP_CAREFULBLOWS" then
            resistChance = 999
        end
		Ext.Print("Resist chance: "..resistChance)
		--Roll your fate !
		local roll = math.random(1, 100)
		if HasActiveStatus(character, "SRP_PLOTARMOR") == 1 then roll = -1 end
		Ext.Print("Roll: "..roll)
		if roll < resistChance then
			-- Lucky you !
			ApplyStatus(character, "UNCONSCIOUS", -1.0, 1)
			PlayEffect(character, "RS3_FX_Overhead_Dice_Green", "Dummy_OverheadFX")
			NRD_StatusPreventApply(character, handle, 1)
			local maxVitality = NRD_CharacterGetStatInt(character, "MaxVitality")
			NRD_CharacterSetStatInt(character, "CurrentVitality", 0.35*maxVitality)
			SetVarInteger(character, "SRP_Unconscious_Recover_Threshold", 0.40*maxVitality)
			SetVarInteger(character, "SRP_Unconscious_Heal", 0)
		end
	end
end

Ext.RegisterOsirisListener("NRD_OnStatusAttempt", 4, "before", ManageCharacterDeath)

--Ext.NewCall(ManageCharacterDeath, "LX_EXT_ManageDeath", "(CHARACTERGUID)_Character, (INTEGER64)_StatusHandle, (CHARACTERGUID)_Instigator");

local function DeathTagCharacter(target, instigator, damage, handle)
    if ObjectIsCharacter(target) == 1 and ObjectIsCharacter(instigator) == 1 then
        if HasActiveStatus(instigator, "SRP_AVOIDDEATH") == 1 then
            deathTag[target] = "SRP_AVOIDDEATH"
            ApplyStatus(target, "SRP_DEATHTAG", 1.0, 1)
        elseif HasActiveStatus(instigator, "SRP_CAREFULBLOWS") == 1 then
            deathTag[target] = "SRP_CAREFULBLOWS"
            ApplyStatus(target, "SRP_DEATHTAG", 1.0, 1)
        end
    end
end
Ext.RegisterOsirisListener("NRD_OnHit", 4, "before", DeathTagCharacter)

local function CleanDeathTag(character, status, event)
    if status ~= "SRP_DEATHTAG" then return end
    for char, condition in pairs(deathTag) do
        deathTag[char] = nil
    end
end

Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", CleanDeathTag)