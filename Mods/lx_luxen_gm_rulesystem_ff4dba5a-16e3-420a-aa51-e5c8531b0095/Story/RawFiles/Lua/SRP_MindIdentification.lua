function ManageIdentification(combatID)
    local combat = Ext.GetCombat(combatID)
    local teams = combat:GetAllTeams()
    for i,team1 in pairs(teams) do
        local idScore = CalculateIdentificationScore(team1.Character.MyGuid)
        Ext.Print(CharacterGetDisplayName(team1.Character.MyGuid), "ID Score:",idScore)
        for j,team2 in pairs(teams) do
            if CharacterIsEnemy(team1.Character.MyGuid, team2.Character.MyGuid) == 1 then
                local roll = math.random(1, 100)
                if roll < idScore then 
                    ApplyStatus(team2.Character.MyGuid, "LX_DISPLAYALL", -1.0, 1)
                    PlayEffect(team2.Character.MyGuid, "RS3_FX_Identification", "Dummy_Root")
                end
            end
        end
    end
end

Ext.NewCall(ManageIdentification, "LX_EXT_ManageValueIdentification", "(INTEGER)_CombatID")

function CalculateIdentificationScore(char)
    local mind = GetCustomStatPoints(char, "Mind")
    local willpower = GetCustomStatPoints(char, "Willpower")
    local perception = GetCustomStatPoints(char, "Perception")
    return math.floor(mind*3 + perception)
end