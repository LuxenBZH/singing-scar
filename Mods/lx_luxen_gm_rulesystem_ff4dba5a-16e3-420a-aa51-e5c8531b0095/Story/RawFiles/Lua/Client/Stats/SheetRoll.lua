UI = Mods.LeaderLib.UI

local function OpenRollMessageBox(rollType, stat, characterNetID)
    local ui = Ext.GetBuiltinUI("Public/Game/GUI/msgBox.swf")
    if ui and stat then
        ui:Hide()
        local root = ui:GetRoot()
        --root.addButton(3, LocalizedText.UI.Close.Value, "", "")
        root.setPopupType(1)
        -- root.setText("Roll for "..stat.ID.."<br>".."Enter a modifier (e.g. 5 for +5, -2 for -2)<br>")
        --ui:Invoke("setAnchor", 0)
        --ui:Invoke("setPos", 50.0, 50.0)
        -- ui:Invoke("setText", "Roll for "..stat.Name.."<br>".."Enter a modifier (e.g. 5 for +5, -2 for -2)<br>")
        ui:Invoke("removeButtons")
        ui:Invoke("addButton", 1845, "Roll", "", "")
        ui:Invoke("addBlueButton", 1846, "Cancel")

        --ui:Invoke("addYesButton", 1)
        -- ui:Invoke("showWin")
        -- ui:Invoke("fadeIn")
        --ui:Invoke("setWaiting", true)
        -- ui:Invoke("setPopupType", 2)
        ui:Invoke("setInputEnabled", true)
        -- ui:Invoke("setTooltip", 0, stat.ID)
        local infos = {
            character = characterNetID,
            stat = stat.ID,
            type = rollType
        }
        ui:Invoke("setTooltip", 1, Ext.JsonStringify(infos))
        -- root.currentDevice = characterNetID
        ui:Invoke("showPopup", "Roll your fate!", "Roll for "..Ext.GetTranslatedStringFromKey(stat.DisplayName).."<br>".."Enter a modifier (e.g. 5 for +5, -2 for -2)<br>")
        -- root.showMsgbox()
        ui:Show()
        -- specialMessageBoxOpen = true
    end
end

local function ManageAnswer(ui, call, buttonID, device)
    -- Ext.Print(buttonID, ui:GetRoot().popup_mc.input_mc.copy_mc.tooltip)
    local ui = Ext.GetBuiltinUI("Public/Game/GUI/msgBox.swf")
    if buttonID == 1845.0 then
        local input = ui:GetRoot().popup_mc.input_mc.input_txt.htmlText
        local mod = tonumber(input)
        -- Ext.Print(input, mod)
        if mod == nil then return end
        local infos = Ext.JsonParse(ui:GetRoot().popup_mc.input_mc.copy_mc.tooltip)
        infos["mod"] = mod
        Ext.PostMessageToServer("SRP_Roll", Ext.JsonStringify(infos))
        ui:Hide()
    elseif buttonID == 1846.0 then
        ui:Hide()
    end
end

UI.ContextMenu.Register.ShouldOpenListener(function(contextMenu, x, y)
    if Game.Tooltip.LastRequestTypeEquals("CustomStat") and Game.Tooltip.IsOpen() then
        -- or if Game.Tooltip.RequestTypeEquals("CustomStat")
        return true
    end
end)

UI.ContextMenu.Register.OpeningListener(function(contextMenu, x, y)
    if Game.Tooltip.RequestTypeEquals("CustomStat") and Game.Tooltip.IsOpen() then
        ---@type TooltipCustomStatRequest
        local request = Game.Tooltip.GetCurrentOrLastRequest()
        local characterId = request.Character.NetID
        local modId = nil
        local statId = request.Stat
        local statData = request.StatData
        if request.StatData then
            modId = request.StatData.Mod
            statId = request.StatData.ID
        end
        contextMenu:AddEntry("RollCustomStat", function(cMenu, ui, id, actionID, handle)
            -- CustomStatSystem:RequestStatChange(statId, characterId, Ext.Random(1,10), modId)
            OpenRollMessageBox("RollNormal", statData, characterId)
        end, "<font color='#33AA33'>Roll</font>")
    end
end)

local function RegisterUIListeners_SheetRoll()
    local msgBox = Ext.GetBuiltinUI("Public/Game/GUI/msgBox.swf")
    Ext.RegisterUICall(msgBox, "ButtonPressed", ManageAnswer)
end

Ext.RegisterListener("SessionLoaded", RegisterUIListeners_SheetRoll)

-- CombatLog = Mods.LeaderLib.CombatLog
-- Ext.RegisterListener("SessionLoaded", function()
--     local rollingText = Ext.GetTranslatedString("he38e2e7bg72dbg4477g86f9ga1fedc4f6750", "Dice Rolls")
--     CombatLog:AddFilter("Rolls", rollingText.Value, nil, 3)
-- end)
