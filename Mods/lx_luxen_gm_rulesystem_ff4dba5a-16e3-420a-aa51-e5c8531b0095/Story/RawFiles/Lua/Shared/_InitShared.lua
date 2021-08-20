Ext.Require("Shared/Helpers.lua")

Ext.Require("Shared/Stats/Effects.lua")
Ext.Require("Shared/Stats/TranslatedStrings.lua")
Ext.Require("Shared/Stats/StatsPatching.lua")

Ext.Require("Shared/Tenebrium/Init.lua")

-- CustomStatSystem = Mods.LeaderLib.CustomStatSystem
-- Timer = Mods.LeaderLib.Timer
-- CombatLog = Mods.LeaderLib.CombatLog

Mods.LeaderLib.EnableFeature("CustomStatSystem")
-- RegisterSkillListener = Mods.LeaderLib.RegisterSkillListener
-- SKILL_STATE = Mods.LeaderLib.SKILL_STATE
-- GameHelpers = Mods.LeaderLib.GameHelpers

Mods.LeaderLib.Import(Mods.SingingScar)
ExplodeSkill = Mods.LeaderLib.ExplodeSkill