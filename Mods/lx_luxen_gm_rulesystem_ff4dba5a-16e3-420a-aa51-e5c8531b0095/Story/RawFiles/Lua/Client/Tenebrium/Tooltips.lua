---@param str string
local function SubstituteString(str, ...)
    local args = {...}
    local result = str

    for k, v in pairs(args) do
        if v == math.floor(v) then v = math.floor(v) end -- Formatting integers to not show .0
        result = result:gsub("%["..tostring(k).."%]", v)
    end
    return result
end

---@param dynamicKey string
function GetDynamicTranslationString(dynamicKey, ...)
    local args = {...}
    
    local handle = dynamicTooltips[dynamicKey]
    if handle == nil then return nil end

    local str = Ext.GetTranslatedString(handle, "Handle Error!")
    str = SubstituteString(str, table.unpack(args))
    return str
end

---@param character EsvCharacter
---@param skill any
---@param tooltip TooltipData
local function TenebriumSkillDisplayRequirement(character, skill, tooltip)
    skill = Ext.GetStat(skill)
    if skill.Ability ~= "Source" then return end
    local requirementMet = true
    for i,element in pairs(tooltip:GetElements("SkillRequiredEquipment")) do
        local _,_,amount = string.find(element.Label, "tag SRP_TE(%d+)")
        if amount ~= nil then
            -- Ext.Print("Requirement not met")
            requirementMet = false
            element.Label = SubstituteString(Ext.GetTranslatedStringFromKey("TE_Cost"), amount)
        end
        
    end
    -- Ext.Dump(tooltip)
    -- Ext.Print(requirementMet)
    if not requirementMet then return end
    for i, requirement in pairs(skill.Requirements) do
        if requirement.Requirement == "Tag" then
            local _,_,amount = string.find(requirement.Param, "SRP_TE(%d+)") --Ty LaughingLeader
            if amount ~= nil then
                local element = {
                    Label = SubstituteString(Ext.GetTranslatedStringFromKey("TE_Cost"), amount),
                    RequirementMet = true,
                    Type = "SkillRequiredEquipment"
                }
                tooltip:AppendElementAfter(element, "SkillRequiredEquipment")
            end
        end
    end
end

local function SRP_InitTenebriumClientListeners()
    Game.Tooltip.RegisterListener("Skill", nil, TenebriumSkillDisplayRequirement)
end

Ext.RegisterListener("SessionLoaded", SRP_InitTenebriumClientListeners)

local isTenebriumInfusionTooltip
local isTenebriumEnergyTooltip
--Captures when the characterSheet Light Resistance tooltip is trying to be served to the client and serves the FireResistance tooltip instead.
---@param ui UIObject
---@param call string
---@param statId number
local function ShowTenebriumInfusionTooltip(ui, call, statId, arg, x, y, ...)
    if statId == 101.0 then
        isTenebriumEnergyTooltip = true
        ui:ExternalInterfaceCall("showStatTooltip", 33.0, arg+30, 1500, 500, ...)
    end
    if statId == 102.0 then
        isTenebriumInfusionTooltip = true
        ui:ExternalInterfaceCall("showStatTooltip", 33.0, arg+30, 1500, 500, ...)
    end
end

---@param character EsvCharacter
---@param skill string
---@param tooltip TooltipData
local function OnStatTooltip(character, stat, tooltip)
    -- Ext.Print("tooltip", isTenebriumInfusionTooltip)
    if tooltip == nil then return end
    -- Ext.Dump(tooltip:GetElement("StatName"))
    local stat = tooltip:GetElement("StatName").Label
    local statsDescription = tooltip:GetElement("StatsDescription")

    if stat == "UNKNOWN STAT" and isTenebriumInfusionTooltip then
        tooltip:GetElement("StatName").Label = "Tenebrium Infusion"
        statsDescription.Label = "How tainted your Source is. The more tainted you are, the more side effects you will encounter."
        local ti = RetrieveCharacterCustomStatValue(character, "SRP_TenebriumInfusion_")
        tooltip:AppendElement({
            Type = "StatsPercentageBonus",
            Label = "Shadow damages are increased by "..math.floor(ti/1.5).."%"
        })
        local malus1 ={
            Type = "StatsPercentageMalus",
            Label = ""
        }
        if ti >= 20 then
            malus1.Label = "If Tenebrium Energy is above your infusion value:<br>  •(20) you receive Shadow damage at the end of your turn."
            tooltip:AppendElement(malus1)
            tooltip:AppendElement({
                Type = "StatsPercentageMalus",
                Label = "(20) Sleeping rolls receive a penalty of 2"
            })
        end
        if ti >= 40 then
            malus1.Label = malus1.Label.."<br>  •(40) 10% of damage and healings done are reflected back to you as Shadow damage."
            tooltip:AppendElement({
                Type = "StatsPercentageMalus",
                Label = "(40) Obscura and Aurora +1"
            })
        end
        if ti >= 60 then
            malus1.Label = malus1.Label.."<br>  •(60) you can critically fail skills"
            tooltip:AppendElement({
                Type = "StatsPercentageMalus",
                Label = "(60) You cannot use fortune points"
            })
        end
        if ti >= 80 then
            malus1.Label = malus1.Label.."<br>  •(80) at the end of your turn, you receive Mad for 1 turn"
            tooltip:AppendElement({
                Type = "StatsPercentageMalus",
                Label = "(80) You sometimes lose control of your actions"
            })
        end
        isTenebriumInfusionTooltip = false
    elseif stat == "UNKNOWN STAT" and isTenebriumEnergyTooltip then
        tooltip:GetElement("StatName").Label = "Tenebrium Energy"
        statsDescription.Label = "How active is the Tenebrium Infusion. Increase with missed and resisted attacks, by receiving a critical hit or when being incapacitated. The stronger the infusion is, the more energy it will generate. If you leave a combat while your energy value is above your infusion value, the infusion might increase."
        isTenebriumEnergyTooltip = false
    end
end

local function SRP_Tooltips_Init()
    local charSheet = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
    Ext.RegisterUICall(charSheet, "showStatTooltip", ShowTenebriumInfusionTooltip)
    Game.Tooltip.RegisterListener("Stat", nil, OnStatTooltip)
end

Ext.RegisterListener("SessionLoaded", SRP_Tooltips_Init)
