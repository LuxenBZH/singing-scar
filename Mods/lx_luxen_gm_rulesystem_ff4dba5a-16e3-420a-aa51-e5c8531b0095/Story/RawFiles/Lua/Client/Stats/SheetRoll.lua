UI = Mods.LeaderLib.UI

local function OpenRollMessageBox(rollType, stat, characterNetID, title, message)
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
            rollType = rollType
        }
        ui:Invoke("setTooltip", 1, Ext.JsonStringify(infos))
        -- root.currentDevice = characterNetID
        ui:Invoke("showPopup", title, message.."<br>".."Enter a modifier (e.g. 5 for +5, -2 for -2)<br>")
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
    local request = Game.Tooltip.GetCurrentOrLastRequest()
    -- Ext.Dump(request)
    if Game.Tooltip.LastRequestTypeEquals("CustomStat") and Game.Tooltip.IsOpen() and tnCalc[request.StatData.ID] then
        -- or if Game.Tooltip.RequestTypeEquals("CustomStat")
        return true
    elseif Game.Tooltip.LastRequestTypeEquals("Stat") and Game.Tooltip.IsOpen() and request.Stat == 102.0 then
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
        if tnCalc[statId] then
            contextMenu:AddEntry("RollCustomStat", function(cMenu, ui, id, actionID, handle)
                OpenRollMessageBox("RollNormal", statData, characterId, "Roll your fate!", "Roll for "..Ext.GetTranslatedStringFromKey(statData.DisplayName).." (d100, lower the better)")
            end, "Roll")
        end
        if statId == "Blacksmith" or statId == "Tailoring" or statId == "Enchanter" then
            if CustomStatSystem:GetStatByID(statId):GetValue(characterId) > 0 then
                contextMenu:AddEntry("RollCraft", function(cMenu, ui, id, actionID, handle)
                    OpenRollMessageBox("RollCraft", statData, characterId, "Crafting roll", "Roll to craft (d20, higher the better)")
                end, "<font color='#b3e6ff'>Craft</font>")
            end
        end
        if statId == "Survivalist" then
            contextMenu:AddEntry("RollSleep", function(cMenu, ui, id, actionID, handle)
                OpenRollMessageBox("RollSleep", statData, characterId, "Resting roll", "Roll for rest (d20, higher the better)")
            end, "<font color='#33AA33'>Rest</font>")
        elseif statId == "Alchemist" and CustomStatSystem:GetStatByID(statId):GetValue(characterId) > 0 then
            contextMenu:AddEntry("RollAlchemist", function(cMenu, ui, id, actionID, handle)
                OpenRollMessageBox("RollAlchemist", statData, characterId, "Look for ingredients", "Roll to search ingredients (d100)")
            end, "<font color='#33AA33'>Look for ingredients</font>")
        end
    elseif Game.Tooltip.RequestTypeEquals("Stat") and Game.Tooltip.IsOpen() then
        local request = Game.Tooltip.GetCurrentOrLastRequest()
        local statID = request.Stat
        local characterId = request.Character.NetID
        local statData = {
            ID = "TenebriumInfusion"
        }
        if statID == 102.0 then
            contextMenu:AddEntry("RollNormal", function(cMenu, ui, id, actionID, handle)
                OpenRollMessageBox("RollNormal", statData, characterId, "Roll against the Tenebrium!", "Roll for Tenebrium Infusion (d100, lower the better)")
            end, "Roll")
            contextMenu:AddEntry("RollObscura", function(cMenu, ui, id, actionID, handle)
                OpenRollMessageBox("RollObscura", statData, characterId, "Use the Obscura...", "Roll for Obscura (d6, result is added to Tenebrium Infusion)")
            end, "<font color=#cc00cc>Obscura</font>")
        end
    end
end)

local function RegisterUIListeners_SheetRoll()
    local msgBox = Ext.GetBuiltinUI("Public/Game/GUI/msgBox.swf")
    Ext.RegisterUICall(msgBox, "ButtonPressed", ManageAnswer)
end

Ext.RegisterListener("SessionLoaded", RegisterUIListeners_SheetRoll)

CombatLog = Mods.LeaderLib.CombatLog
Ext.RegisterListener("SessionLoaded", function()
    local rollingText = "Singing Scar rolls"
    CombatLog.AddFilter("SSRolls", rollingText, Ext.IsDeveloperMode() or nil, 3)
end)

if Ext.IsDeveloperMode() then
    Mods.LeaderLib.RegisterListener("BeforeLuaReset", function()
        CombatLog.RemoveFilter("SSRolls")
    end)
end