local function ManageUnconsciousRecover(character, instigator, amount, handle)
    if HasActiveStatus(character, "UNCONSCIOUS") == 0 then return end
	-- A character recover from unconscious if it gains 40% of its max HP
	local threshold = GetVarInteger(character, "SRP_Unconscious_Recover_Threshold")
	local previousHeal = GetVarInteger(character, "SRP_Unconscious_Heal")
	local currentHeal = previousHeal + amount
	print("Threshold: "..threshold)
	print("Current Heal: "..currentHeal)
	if currentHeal >= threshold then
		RemoveStatus(character, "UNCONSCIOUS")
	else
		SetVarInteger(character, "SRP_Unconscious_Heal", currentHeal)
	end
end

Ext.RegisterOsirisListener("NRD_OnHeal", 4, "before", ManageUnconsciousRecover)

local deathTag = {}

local function ManageCharacterDeath(character, status, handle, instigator)
	if status ~= "DYING" then return end
	if HasActiveStatus(character, "UNCONSCIOUS") == 1 then return end
	Ext.Print("DEATH!")
	-- Manage death saving throw
	local endurance = CustomStatSystem:GetStatByID("Endurance", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
	local willpower = CustomStatSystem:GetStatByID("Willpower", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
	local body = CustomStatSystem:GetStatByID("Body", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(character)
    local resistChance = endurance*2 + willpower + body
    local tagged = deathTag[character]
    if tagged == "SRP_AVOIDDEATH" then
        resistChance = resistChance + 50
    elseif tagged == "SRP_CAREFULBLOWS" then
        resistChance = 999
    end
    Ext.Print("Resist chance: "..resistChance)
    --Roll your fate !
    local roll = math.random(1, 100)
    if HasActiveStatus(character, "SRP_PLOTARMOR") == 1 then roll = -999 end
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