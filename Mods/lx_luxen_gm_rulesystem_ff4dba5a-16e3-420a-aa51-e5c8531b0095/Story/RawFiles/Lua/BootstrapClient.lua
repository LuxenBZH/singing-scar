--Ext.AddPathOverride("Public/Game/GUI/characterSheet.swf", "Public/lx_luxen_gm_rulesystem_ff4dba5a-16e3-420a-aa51-e5c8531b0095/Game/GUI/characterSheet.swf")
-- Ext.Require("SRP_StatsPatching.lua")
-- Ext.Require("SRP_ShadowPower_Client.lua")
Ext.Require("BootstrapShared.lua")
-- Ext.Require("Stats/Client/CustomStatsClient.lua")
-- Ext.Require("Stats/Client/CustomStatsTooltips.lua")

Ext.Require("Client/_InitClient.lua")

tEnergy = 0

local function SRP_GetCharacter()
    local sheet = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
    local charHandle = sheet:GetValue("charHandle", "number")
    local char = Ext.GetCharacter(Ext.DoubleToHandle(charHandle))
    return char
end

local function SendCharacterMessage(message, ...)
    local char = SRP_GetCharacter()
    -- ALWAYS make sure to cast the netID into number server-side
    Ext.PostMessageToServer(message, tostring(char.NetID), ...)
end

local function CustomStatChanged(ui, call, ...)
    SendCharacterMessage("SRP_MakeCustomStatCheck")
end

local function TNCFormat(tn, cap)
    local string = ""
    if tn ~= nil then
        string = "<font color=#604020>["..tn.."]</font>"
    end
    if cap ~= nil then
        string = string.."<font color=#000066>("..cap..")<font>"
    end
    return string
end

local function DisplayTNandCap(ui, ctatList, indexList, character)
    local stats = character.Stats
    local mAptitudes = {
        Endurance = {"BaseStrength", "BaseConstitution", "#ff0000"},
        Mind = {"BaseMemory", "BaseIntelligence", "#0000ff"},
        Agility = {"BaseWits", "BaseFinesse", "#00802b"}
    }
    local sAptitudes = {
        Willpower = {"Endurance", "Mind"},
        Perception = {"Mind", "Agility"},
        Body = {"Endurance", "Agility"}
    }
    local social = {
        Charisma = "Endurance",
        Manipulation = "Agility",
        Suasion = "Mind",
        Intimidation = "Might",
        Insight = "Perception",
        Intuition = "Willpower"
    }
    local knowledge = {
        Alchemist = 8,
        Blacksmith = 8,
        Tailoring = 8,
        Enchanter = 8,
        Survivalist = 8,
        Magic = 8,
        Medicine = 8,
        Academics = 8
    }
    local misc = {
        ['Soul points'] = 0,
        ['Fortune point'] = 1,
        ['Body condition'] = 5,
        ['Tenebrium infusion'] = 100
    }
    for i=0,300,1 do
        local ctat = indexList[i]
        if ctat ~= nil then
            for ctat2, cont in pairs(mAptitudes) do
                if ctat == ctat2 then
                    local amount = ctatList[ctat][2]
                    if amount ~= nil then
                        local tn = math.floor(4 * amount)
                        local cap = math.min(10 + math.floor((stats[cont[1]] + stats[cont[2]] - Ext.ExtraData.AttributeBaseValue*2)/2), 20)
                        ui:SetValue("customStats_array", "<font color="..cont[3]..">"..ctat.."</font> "..TNCFormat(tn, cap), ctatList[ctat][1])
                    end
                end
            end
            for ctat2, cont in pairs(sAptitudes) do
                if ctat == ctat2 then
                    local amount = ctatList[cont[1]][2] + ctatList[cont[2]][2]
                    amount = math.floor(amount/2)
                    local tn = math.floor(4 * amount)
                    ctatList[ctat][2] = amount
                    ui:SetValue("customStats_array", ctat.." "..TNCFormat(tn), ctatList[ctat][1])
                    ui:SetValue("customStats_array", amount, ctatList[ctat][1]+1)
                end
            end
            if ctat == "Might" then
                local amount = math.floor((ctatList["Endurance"][2] + ctatList["Mind"][2] + ctatList["Agility"][2])*2)
                ctatList[ctat][2] = amount
                ui:SetValue("customStats_array", ctat.." "..TNCFormat(amount), ctatList[ctat][1])
                ui:SetValue("customStats_array", amount, ctatList[ctat][1]+1)
            end
            for ctat2, cont in pairs(social) do
                if ctat == ctat2 then
                    local fromApt = ctatList[cont][2]
                    if cont == "Might" then fromApt = fromApt/4 end
                    local tn = math.floor(fromApt * 2 + ctatList[ctat][2] * 4)
                    local cap = 10
                    ui:SetValue("customStats_array", ctat.." "..TNCFormat(tn, cap), ctatList[ctat][1])
                end
            end
            for ctat2, cont in pairs(knowledge) do
                if ctat == ctat2 then
                    local amount = ctatList[ctat][2]
                    local tn = math.floor(cont*amount + 1*ctatList["Mind"][2])
                    local cap = 10
                    ui:SetValue("customStats_array", ctat.." "..TNCFormat(tn, cap), ctatList[ctat][1])
                end
            end
            for ctat2,cont in pairs(misc) do
                if ctat == ctat2 then
                    local cap = cont
                    if cont > 0 then
                        ui:SetValue("customStats_array", ctat.." "..TNCFormat(tn, cap), ctatList[ctat][1])
                    end
                end
                if ctat == "Tenebrium infusion" then
                    -- Ext.Print(tostring(character.NetID).."_"..ctatList[ctat][2])
                    Ext.PostMessageToServer("SetCharacterTenebriumInfusionTag", tostring(character.NetID).."_"..ctatList[ctat][2])
                    -- SetCharacterCustomStatTag(character, "SRP_TenebriumInfusion_", ctatList[ctat][2])
                end
            end
        end
    end
end

local function AddToSecStatArray(array, location, label, value, suffix, icon, statID)
    local length = #array
    if length > 0 then
        array[length + 1] = location
        array[length + 2] = label
        array[length + 3] = tostring(value)..suffix
        array[length + 4] = statID
        array[length + 5] = icon
        array[length + 6] = value
        -- array[length + 7] = ""
    end
end

-- local function SetTEAmount(message, amount)
--     amount = tonumber(amount)
--     tEnergy = amount
--     local sheet = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
--     sheet:GetRoot().updateArraySystem()
--     Ext.Print("TEST")
-- end

-- Ext.RegisterNetListener("SRP_UISheetCharacterTE", SetTEAmount)

local function DisplayTEInfo(ui, call, ...)
    local statusConsole = Ext.GetBuiltinUI("Public/Game/GUI/statusConsole.swf")
    local hotbar = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
    if statusConsole ~= nil then
        if call == "statusConsoleRollOver" then
            statusConsole:GetRoot().console_mc.sbTxt_mc.visible = true
        elseif call == "statusConsoleRollOut" then
            statusConsole:GetRoot().console_mc.sbTxt_mc.visible = false
        end
    end
end

-- function CreateShadowBar()
--     return Ext.CreateUI("shadowBar", "Public/lx_luxen_gm_rulesystem_ff4dba5a-16e3-420a-aa51-e5c8531b0095/Game/GUI/shadowBar.swf", 3)
-- end

-- local function SwitchShadowBarDisplay(ui, call, ...)
--     local shadowBar = Ext.GetUI("shadowBar")
--     if shadowBar == nil then shadowBar = CreateShadowBar() end
--     if call == "BackToGMPressed" then
--         shadowBar.Hide(shadowBar)
--     end
-- end

local function UpdateShadowBarValue(ui, call, handle)
    local statusConsole = Ext.GetBuiltinUI("Public/Game/GUI/statusConsole.swf")
    statusConsole:GetRoot().console_mc.sbHolder_mc.bg_mc.gotoAndStop(3)
    local char = Ext.GetCharacter(Ext.DoubleToHandle(handle))
    Ext.PostMessageToServer("SRP_UIRequestCharacterTE", tostring(char.NetID))
end

local function ShowTenebriumInfusionTooltip(ui, call, ...)
    Ext.Dump({...})
end

local function SRP_SetupUI()
    local charSheet = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
    local statusConsole = Ext.GetBuiltinUI("Public/Game/GUI/statusConsole.swf")
    local hotbar = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
    statusConsole:GetRoot().console_mc.sourceHolder_mc.y = -53
    -- Ext.Print("statusconsole", statusConsole.GetTypeId(statusConsole))
    -- Ext.RegisterUICall(charSheet, "plusCustomStat", CustomStatChanged)
    -- Ext.RegisterUICall(charSheet, "minusCustomStat", CustomStatChanged)
    
    Ext.RegisterUICall(statusConsole, "statusConsoleRollOver", DisplayTEInfo)
    Ext.RegisterUICall(statusConsole, "statusConsoleRollOut", DisplayTEInfo)
    -- Ext.RegisterUICall(statusConsole, "BackToGMPressed", SwitchShadowBarDisplay)
    -- Ext.RegisterUINameCall("possess", TestTooltip4, "After")
    -- Ext.RegisterUITypeCall(32, "charSel", UpdateShadowBarValue)
    -- Ext.RegisterUITypeCall(119, "selectCharacter", UpdateShadowBarValue)
    -- Ext.RegisterUITypeCall(119, "centerCamOnCharacter", UpdateShadowBarValue)
    Ext.RegisterUIInvokeListener(hotbar, "setPlayerHandle", UpdateShadowBarValue)
    -- Ext.RegisterUICall(charSheet, "showCustomStatTooltip", ShowTenebriumInfusionTooltip)
    Ext.Print("Registered UI listeners")
end

-- Ext.RegisterListener("SessionLoaded", SRP_SetupUI)
