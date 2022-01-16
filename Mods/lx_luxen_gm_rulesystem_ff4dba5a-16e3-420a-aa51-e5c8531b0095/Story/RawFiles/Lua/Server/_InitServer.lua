function InitCstats()
    CStats = {
    Endurance = Ext.GetCustomStatByName("Endurance"),
    Body = Ext.GetCustomStatByName("Body"),
    Willpower = Ext.GetCustomStatByName("Willpower"),
    Mind = Ext.GetCustomStatByName("Mind"),
    Agility = Ext.GetCustomStatByName("Agility"),
    Perception = Ext.GetCustomStatByName("Perception"),
    ["Tenebrium Infusion"] = Ext.GetCustomStatByName("Tenebrium Infusion"),
    ["Tenebrium Energy"] = Ext.GetCustomStatByName("Tenebrium Energy")
}

    StatTI = Ext.GetCustomStatByName("Tenebrium Infusion")
    StatTE = Ext.GetCustomStatByName("Tenebrium Energy")
end

Ext.RegisterListener("SessionLoaded", InitCstats)

Ext.Require("Server/ConsoleCommands.lua")

-- Ext.Require("Server/Stats/CustomStats.lua")
Ext.Require("Server/Stats/DeathSaving.lua")
Ext.Require("Server/Stats/MindIdentification.lua")
Ext.Require("Server/Stats/Bonuses.lua")

Ext.Require("Server/Tenebrium/EnergyCalc.lua")
Ext.Require("Server/Tenebrium/Skills.lua")
Ext.Require("Server/Tenebrium/EnergyManagement.lua")
Ext.Require("Server/Tenebrium/Overcharge.lua")
Ext.Require("Server/Tenebrium/Infusion.lua")

-- CustomStatSystem = Mods.LeaderLib.CustomStatSystem

Ext.RegisterNetListener("SRP_ClientReady", function(channel, payload, user)
    Ext.PostMessageToUser(user, "SRP_CustomStatsInfos", Ext.JsonStringify(CStats))
end)

-- Ext.RegisterOsirisListener("UserConnected", 3, "before", function(userID, userName, userProfileID)
--     Ext.PostMessageToUser(userID, "SRP_CustomStatsInfos", Ext.JsonStringify(CStats))
-- end)