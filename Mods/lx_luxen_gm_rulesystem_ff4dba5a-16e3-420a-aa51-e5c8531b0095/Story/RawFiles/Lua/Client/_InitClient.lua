CStats = {}
StatTE = nil
StatTI = nil

Ext.RegisterNetListener("SRP_CustomStatsInfos", function(call, payload)
    CStats = Ext.JsonParse(payload)
    StatTE = CStats["Tenebrium Energy"]
    StatTI = CStats["Tenebrium Infusion"]
    Ext.Print("Received custom stats infos")
end)

Ext.RegisterListener("SessionLoaded", function()
    Ext.PostMessageToServer("SRP_ClientReady", "")
end)
-- Ext.Require("Client/Stats/CustomStatsClient.lua")
-- Ext.Require("Client/Stats/CustomStatsTooltips.lua")
-- Ext.Require("Client/Stats/SheetRoll.lua")
Ext.Require("Client/Tenebrium/Overhead.lua")

Ext.Require("Client/Tenebrium/BarManagement.lua")
Ext.Require("Client/Tenebrium/Tooltips.lua")

-- CustomStatSystem = Mods.LeaderLib.CustomStatSystem

local cStats_ids = {}

Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", function(ui, call, ...)
    i = 0
    local cstats_array = ui:GetRoot().customStats_array
    local cstats = {}
    if not cstats_array[1] then
        return
    else
        local index = 1
        local lastStat = 0
        while cstats_array[index] do
            cstats[cstats_array[index]] = cstats_array[index+1]
            cStats_ids[cstats_array[index-1]] = cstats_array[index]
            -- Ext.Print(cstats_array[index+1], Ext.GetCharacter(ui:GetPlayerHandle()):GetCustomStat(CStats[cstats_array[index]].Id))
            index = index + 3
        end
    end
    local infos = {
        Character = Ext.GetCharacter(ui:GetPlayerHandle()).NetID,
        Stats = cstats
    }
    Ext.PostMessageToServer("SRP_CStatsChanged", Ext.JsonStringify(infos))
end)

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "plusCustomStat", function(ui, call, stat)
    -- if cStats_ids[stat] == "Tenebrium Infusion" then

    -- end
end)