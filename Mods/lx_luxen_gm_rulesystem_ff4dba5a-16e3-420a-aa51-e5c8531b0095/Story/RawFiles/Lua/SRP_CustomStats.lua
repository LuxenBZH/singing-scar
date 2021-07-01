-- local function StartCheck(level, editorMode)
--     CheckStatsPresence()
--     TimerLaunch("LX_Check_Custom_Stats", 10000)
-- end

-- Ext.RegisterOsirisListener("GameStarted", 2, "before", StartCheck)

-- local function PeriodicStatCheck(timerName)
--     if timerName ~= "LX_Check_Custom_Stats" then return end
--     local players = Osi.DB_IsPlayer:Get(nil)
--     for i,player in pairs(players) do
--         CharacterLaunchIteratorAroundObject(player, 30.0, "LX_Put_Custom_Stats_Bonus")
--     end
--     TimerLaunch("LX_Check_Custom_Stats", 10000)
-- end

-- Ext.RegisterOsirisListener("TimerFinished", 1, "before", PeriodicStatCheck)

-- local function PutCustomStatsBonuses(char, event)
--     if event ~= "LX_Put_Custom_Stats_Bonus" then return end
--     if StatsHasChanged(char) then
--         SRP_ManageCharacterCustomBonus(char)
--     end
-- end

-- Ext.RegisterOsirisListener("StoryEvent", 2, "before", PutCustomStatsBonuses)

local function TriggerDeathManagement(char, status, handle, instigator)
    Ext.Print("TRIGGER")
    if status ~= "DYING" then return end
    if HasActiveStatus(char, "UNCONSCIOUS") == 0 then
        ManageCharacterDeath(char, handle, instigator)
    end
end

Ext.RegisterOsirisListener("NRD_OnStatusAttempt", 4, "before", TriggerDeathManagement)

deathTag = {}
carefulBlows = {}

local function WatchPlotArmorCarefulBlows(target, instigator, damage, handle)
    if (ObjectIsCharacter(target) == 0 or ObjectIsCharacter(instigator) == 0) then return end
    if HasActiveStatus(instigator, "SRP_AVOIDDEATH") == 1 then deathTag[target] = instigator end
    if HasActiveStatus(instigator, "SRP_CAREFULBLOWS") == 1 then carefulBlows[target] = instigator end
end

Ext.RegisterOsirisListener("NRD_OnHit", 4, "before", WatchPlotArmorCarefulBlows)

local function CleanDeathTagCarefulBlow(char)
    if deathTag[char] ~= nil then deathTag[char] = nil end
    if carefulBlows[char] ~= nil then carefulBlows[char] = nil end
end

Ext.RegisterOsirisListener("ObjectTurnEnded", 1, "before", CleanDeathTagCarefulBlow)

local function UnconsciousRecoveryListener(target, instigator, amount, handle)
    if HasActiveStatus(target, "UNCONSCIOUS", 1) then
        ManageUnconsciousRecover(target, amount)
    end
end

Ext.RegisterOsirisListener("NRD_OnHeal", 4, "before", UnconsciousRecoveryListener)

local function AttemptScanValues(combatID)
    ManageIdentification(combatID)
end

statCheck = {}
-- local function CustomStatRefreshTimer(char, event)
--     if event ~= "SRP_CustomStatCheckTimerStart" then return end
--     table.insert(statCheck, char)
--     TimerLaunch("SRP_CustomStatCheckTimerOver", 350)
-- end

-- Ext.RegisterOsirisListener("StoryEvent", 2, "before", CustomStatRefreshTimer)

-- local function MakeStatCheckOnTaggedChar(timer)
--     if timer ~= "SRP_CustomStatCheckTimerOver" then return end
--     for i,char in pairs(statCheck) do
--         CustomStatCheck(char)
--         statCheck[i] = nil
--     end
-- end

-- Ext.RegisterOsirisListener("TimerFinished", 1, "before", MakeStatCheckOnTaggedChar)

local function SRP_EXIMSaveLoad(char, event)
    if event == "LX_Save_Character" then
        Osi.LX_EXT_SaveCustomStats(char)
    elseif event == "LX_Load_Character" then
        Osi.LX_EXT_LoadCustomStats(char)
    end
end

Ext.RegisterOsirisListener("StoryEvent", 2, "before", SRP_EXIMSaveLoad)