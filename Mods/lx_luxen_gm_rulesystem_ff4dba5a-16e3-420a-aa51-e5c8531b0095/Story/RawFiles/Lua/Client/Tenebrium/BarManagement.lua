-- Ext.Require("SRP_ShadowPowerShared.lua")
Ext.AddPathOverride("Public/Game/GUI/statusConsole.swf", "Public/lx_luxen_gm_rulesystem_ff4dba5a-16e3-420a-aa51-e5c8531b0095/Game/GUI/statusConsole - Copie.swf")

local function SetOverchargeAnimation(root, enable, minAlpha, maxAlpha, time)
    Ext.Print(enable, root.console_mc.enableBlink)
    if enable and not root.console_mc.enableBlink then
        root.console_mc.enableBlink = true
        root.console_mc.appearBegin = minAlpha
        root.console_mc.appearEnd = maxAlpha
        root.console_mc.disappearBegin = maxAlpha
        root.console_mc.disappearEnd = minAlpha
        root.console_mc.blinkTime = time
        root.console_mc.blink()
    elseif not enable and root.console_mc.enableBlink then
        root.console_mc.enableBlink = false
        -- root.console_mc.blink()
    end
end

local function SetShadowBarAmount(ui, call, ...)
    local sheet = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
    local character
    local args = {...}
    if call == "setPlayerHandle" then
        character = Ext.GetCharacter(Ext.DoubleToHandle(args[1]))
    else
        character = Ext.GetCharacter(Ext.DoubleToHandle(sheet:GetValue("charHandle", "number")))
    end
    local amount = CustomStatSystem:GetStatByID("TenebriumEnergy", SScarID):GetValue(character)
    local statusConsole = Ext.GetBuiltinUI("Public/Game/GUI/statusConsole.swf")
    local text = "T-Energy:"..amount.."/100"
    statusConsole:GetRoot().console_mc.sbHolder_mc.bg_mc.gotoAndStop(3)
    statusConsole:GetRoot().console_mc.sbHolder2_mc.bg_mc.gotoAndStop(4)
    statusConsole:GetRoot().console_mc.sbHolder_mc.setBar(amount/100, 1)
    statusConsole:GetRoot().console_mc.sbHolder2_mc.setBar(amount/100, 1)
    local ti = CustomStatSystem:GetStatByID("TenebriumInfusion", SScarID):GetValue(character)
    if amount > ti then
        SetOverchargeAnimation(statusConsole:GetRoot(), true, 0, 0.6, 0.8)
    else
        SetOverchargeAnimation(statusConsole:GetRoot(), false, 0, 0.6, 0.8)
    end
    -- statusConsole:GetRoot().console_mc.sbTxt_mc.y = -21
    -- statusConsole:GetRoot().console_mc.sbTxt_mc.scaleX = 0.75
    -- statusConsole:GetRoot().console_mc.sbTxt_mc.scaleY = 0.75
    -- statusConsole:GetRoot().console_mc.sbTxt_mc.x = -168
    statusConsole:GetRoot().console_mc.sbTxt_mc.htmlText = text
end

Ext.RegisterNetListener("SRP_UICharacterTE", SetShadowBarAmount)

function AskServerForTE(netID)
    Ext.PostMessageToServer("SRP_UIRequestCharacterTE", tostring(netID))
end

function AskServerForSheetTE(netID)
    Ext.PostMessageToServer("SRP_UIRequestSheetCharacterTE", tostring(netID))
end

local function ShowShadowBarPossess(call, payload)
    -- local shadowBar = Ext.GetUI("shadowBar")
    -- if shadowBar == nil then shadowBar = CreateShadowBar() end
    AskServerForTE(Ext.GetCharacter(tonumber(payload)).NetID)
end

Ext.RegisterNetListener("SRP_UIGMPossess", ShowShadowBarPossess)

local function InitShadowBarValue()
    local state = Ext.GetGameState()
    if state == "Running" then
        Ext.PostMessageToServer("SRP_UIShadowBarInitValue", "")
    end
end

Ext.RegisterListener("GameStateChanged", InitShadowBarValue)

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

local function AddCustomInfo(ui, ...)
    -- Ext.Print("updateArraySystem")
    local sheet = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
    local hotbar = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
    -- sheet:ExternalInterfaceCall("updateArraySystem")
    local charHandle = hotbar:GetRoot().hotbar_mc.characterHandle
    local char = Ext.GetCharacter(Ext.DoubleToHandle(charHandle))
    local te = CustomStatSystem:GetStatByID("TenebriumEnergy", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(char)
    local ti = CustomStatSystem:GetStatByID("TenebriumInfusion", "ff4dba5a-16e3-420a-aa51-e5c8531b0095"):GetValue(char)
    AddToSecStatArray(sheet:GetRoot().secStat_array, 0, "T. Energy", tostring(te).."/100", "", 4, 33)
    AddToSecStatArray(sheet:GetRoot().secStat_array, 4, "", "", "", 0, 99)
    AddToSecStatArray(sheet:GetRoot().secStat_array, 0, "T. Infusion", tostring(ti).."%", "", 0, 101)
end

local function TEN_SetupUI()
    local charSheet = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
    local statusConsole = Ext.GetBuiltinUI("Public/Game/GUI/statusConsole.swf")
    local hotbar = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
    statusConsole:GetRoot().console_mc.sourceHolder_mc.y = -53
    -- Ext.Print("statusconsole", statusConsole.GetTypeId(statusConsole))
    -- Ext.RegisterUICall(charSheet, "plusCustomStat", CustomStatChanged)
    -- Ext.RegisterUICall(charSheet, "minusCustomStat", CustomStatChanged)
    -- Ext.RegisterUIInvokeListener(charSheet, "updateArraySystem", AddCustomInfo)
    Ext.RegisterUICall(statusConsole, "statusConsoleRollOver", DisplayTEInfo)
    Ext.RegisterUICall(statusConsole, "statusConsoleRollOut", DisplayTEInfo)
    Ext.RegisterUIInvokeListener(charSheet, "updateArraySystem", AddCustomInfo)
    -- Ext.RegisterUICall(statusConsole, "BackToGMPressed", SwitchShadowBarDisplay)
    -- Ext.RegisterUINameCall("possess", TestTooltip4, "After")
    -- Ext.RegisterUITypeCall(32, "charSel", UpdateShadowBarValue)
    -- Ext.RegisterUITypeCall(119, "selectCharacter", UpdateShadowBarValue)
    -- Ext.RegisterUITypeCall(119, "centerCamOnCharacter", UpdateShadowBarValue)
    Ext.RegisterUIInvokeListener(hotbar, "setPlayerHandle", SetShadowBarAmount)
    Ext.RegisterUIInvokeListener(hotbar, "setPlayerHandle", AddCustomInfo)
    -- Ext.RegisterUICall(charSheet, "showCustomStatTooltip", ShowTenebriumInfusionTooltip)
    Ext.Print("Registered UI listeners")
end

Ext.RegisterListener("SessionLoaded", TEN_SetupUI)