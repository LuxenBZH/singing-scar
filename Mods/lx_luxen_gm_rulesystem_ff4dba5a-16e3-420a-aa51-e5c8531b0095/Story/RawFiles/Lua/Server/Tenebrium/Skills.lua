local powerhit = {}
local foulwind = {}
local rotatingChar = {}

Ext.RegisterOsirisListener("CharacterUsedSkill", 4, "after", function(char, skill, skillType, skillElement)
    -- Ext.Print(char,skill)
    if skill == "Shout_TEN_Channel" then
        -- local currentTE = PersistentVars.tEnergyServer[char]
        SetVarInteger(char, "SRP_TEnergy", -30)
        SetTag(char, "SRP_TEIgnoreCombat")
        SetStoryEvent(char, "SRP_UpdateTE")
    elseif skill == "Shout_TEN_Unleash" then
        -- local te = CustomStatSystem:GetStatByID("TenebriumEnergy", SScarID):GetValue(char)
        -- local ti = CustomStatSystem:GetStatByID("TenebriumInfusion", SScarID):GetValue(char)
        local te = character:GetCustomStat(StatTE.Id)
        local ti = character:GetCustomStat(StatTI.Id)
        if te == ti then
            SetVarInteger(char, "SRP_TEnergy", 30)
        else
            SetVarInteger(char, "SRP_TEnergy", 15)
        end
        SetStoryEvent(char, "SRP_UpdateTE")
    end
end)


-------- REGION Foul Winds
local function GetPlaneDistanceCheck(x, y, x2, y2)
    return math.abs(math.sqrt((x2 - x) * (x2 - x) + (y2 - y) * (y2 - y)))
end

-- Ext.RegisterOsirisListener("CharacterUsedSkillAtPosition", 7, "before", function(char, x, y, z, skill, skillType, skillElement)
--     if skill == "Target_TEN_FoulWinds" then
--         local instigator = Ext.GetCharacter(char)
--         local tornado = CreateItemTemplateAtPosition("5b15fddd-5d41-47c2-90ba-b3e04dd86a93", x, y, z)
--         local characters = {}
--         for i,v in pairs(Ext.GetAllCharacters()) do
--             local xv, yv, zv = GetPosition(v)
--             if GetPlaneDistanceCheck(x, z, xv, zv) <= 5.0 and math.abs(y - yv) <= 10 then
--                 characters[#characters+1] = v
--             end
--         end
--         -- local characters = Ext.GetCharactersAroundPosition(x, y, z, 5)
--         foulwind[tornado] = {instigator = nil, characters = {}}
--         foulwind[tornado].instigator = char
--         foulwind[tornado].ticksLeft = 12
--         Ext.Print(x, y, z, #characters)
--         for i,character in pairs(characters) do
--             table.insert(foulwind[tornado].characters, character)
--         end
--         TimerLaunch("TEN_FoulWind_Loop", 250)
--     end
-- end)

RegisterSkillListener("Summon_TEN_FoulWinds", function(skill, char, state, data)
    if state == SKILL_STATE.CAST then
        local instigator = Ext.GetCharacter(char)
        local pos = data:GetSkillTargetPosition()
        local characters = {}
        local tornado = CreateItemTemplateAtPosition("5b15fddd-5d41-47c2-90ba-b3e04dd86a93", pos[1], pos[2], pos[3])
        GameHelpers.Skill.Explode(tornado, "Projectile_TEN_FoulWind_SurfaceClear", instigator)
        -- Ext.ExecuteSkillPropertiesOnPosition("Projectile_ThrowDust", instigator, pos, 5, "Target", false)
        for i,v in pairs(Ext.GetAllCharacters()) do
            local xv, yv, zv = GetPosition(v)
            local character = Ext.GetCharacter(v)
            if GetPlaneDistanceCheck(pos[1], pos[3], xv, zv) <= 5.0 and math.abs(pos[2] - yv) <= 10 and character.RootTemplate.Id ~= "8837bd64-0ba8-4f80-8e24-184ffdf16f08" then
                characters[#characters+1] = v
            end
        end
        -- local characters = Ext.GetCharactersAroundPosition(x, y, z, 5)
        foulwind[tornado] = {instigator = nil, characters = {}}
        foulwind[tornado].instigator = char
        foulwind[tornado].ticksLeft = 12
        -- Ext.Print(pos[1], pos[2], pos[3], #characters)
        for i,character in pairs(characters) do
            table.insert(foulwind[tornado].characters, character)
        end
        TimerLaunch("TEN_FoulWind_Loop", 250) 
    end
end)

local function RotateCoordinatesAroundPos(radius, angleIncrease, x, y, xt, yt)
    local x_diff = xt - x
    local y_diff = yt - y
    local angle = math.deg(math.atan(yt - y, xt- x))
    -- Ext.Print(angle)
    angle = angle + angleIncrease
    local new_x = x + radius * math.cos(math.rad(angle))
    local new_y = y + radius * math.sin(math.rad(angle))
    -- Ext.Print(new_x, new_y)
    return new_x, new_y
end

Ext.RegisterOsirisListener("TimerFinished", 1, "before", function(timer)
    if timer == "TEN_FoulWind_Loop" then
        Ext.Print("Foulwind loop")
        local loop = true
        for tornado, infos in pairs(foulwind) do
            if ObjectExists(tornado) == 1 then
                foulwind[tornado].ticksLeft = foulwind[tornado].ticksLeft - 1
                Ext.Print("Ticks left:", foulwind[tornado].ticksLeft)
                local tornadoPos = Ext.GetItem(tornado).WorldPos
                for i, character in pairs(infos.characters) do
                    local victim = Ext.GetCharacter(character)
                    local x, y, z
                    GameHelpers.Skill.Explode(character, "Projectile_TEN_FoulWind_Tick", infos.instigator)
                    if not victim:GetStatus("FORTIFIED") and not victim:GetStatus("DEACTIVATED") and not victim:GetStatus("PETRIFIED") and not victim:GetStatus("DYING") and not victim.Totem and not victim.Stats.Grounded and not victim.IsHuge and not victim.Stats.ThrownImmunity then
                        if foulwind[tornado].ticksLeft > 0 then
                            x, y = RotateCoordinatesAroundPos(3, math.random(50,120), tornadoPos[1], tornadoPos[3], victim.WorldPos[1], victim.WorldPos[3])
                            z = tornadoPos[2] + 3 + math.random(0, 20) / 10
                        else
                            GameHelpers.ClearActionQueue(character)
                            x, y = RotateCoordinatesAroundPos(math.random(20,100)/10, math.random(50,120), tornadoPos[1], tornadoPos[3], victim.WorldPos[1], victim.WorldPos[3])
                            z = Ext.GetAiGrid():GetHeight(x, y)
                            local xv, yv, zv = FindValidPosition(x, z, y, 5, character)
                            local angle = 0
                            local tries = 0
                            local los = true
                            local block
                            if xv then
                                block = CreateItemTemplateAtPosition("5b229b34-16e4-4f4e-bd77-910fa9af26dd", xv, yv, zv)
                                los = HasLineOfSight(character, block)
                                ItemRemove(block)
                            end
                            while (xv == nil or not los) and tries < 37 and los do
                                x, y = RotateCoordinatesAroundPos(math.random(0,50)/10, angle, tornadoPos[1], tornadoPos[3], victim.WorldPos[1], victim.WorldPos[3])
                                z = Ext.GetAiGrid():GetHeight(x, y)
                                xv, yv, zv = FindValidPosition(x, z, y, 5, character)
                                angle = angle + 10
                                block = CreateItemTemplateAtPosition("5b229b34-16e4-4f4e-bd77-910fa9af26dd", xv, yv, zv)
                                los = HasLineOfSight(character, block)
                                ItemRemove(block)
                                tries = tries + 1
                            end
                            if tries > 36 then
                                x = tornadoPos[1]
                                y = tornadoPos[3]
                            end
                        end
                        NRD_CreateGameObjectMove(victim.MyGuid, x, z, y, "Cone_RadialBlowback", victim.MyGuid)
                    end
                end
            end
            if foulwind[tornado].ticksLeft == 0 then
                ItemDestroy(tornado)
                foulwind[tornado] = nil
            end
            if loop then
                TimerLaunch("TEN_FoulWind_Loop", 400)
                loop = false
            end
        end
        
    end
end)
-------- END Foul Winds

local function ReverseSign(value)
    if value > 0 then
        return 1
    else
        return -1
    end
end

-------- REGION Power Hit
RegisterSkillListener({"Target_TEN_PowerHit", "Rush_TEN_PowerHit", "Projectile_TEN_PowerHit_Hit"}, function(skill, char, state, data)
    if skill == "Target_TEN_PowerHit" then
        if state == SKILL_STATE.CAST then
            local target = data:GetSkillTargetPosition()
            if target then
                GameHelpers.ClearActionQueue(char, true)
                local x,y,z = table.unpack(target)
                local ox, oy, oz = GetPosition(char)
                local fx, fy, fz
                if GetDistanceToPosition(char, x, y, z) > 1.0 then
                    local angle = math.atan(z - oz, x - ox)
                    fx = x - 1.5 * math.cos(angle)
                    fz = z - 1.5 * math.sin(angle)
                    fy = Ext.GetAiGrid():GetHeight(fx, fz)
                else
                    local angle = math.atan(z - oz, x - ox)
                    fx = x - 0.5 * math.cos(angle)
                    fz = z - 0.5  * math.sin(angle)
                    fy = Ext.GetAiGrid():GetHeight(fx, fz)
                end
                CharacterUseSkillAtPosition(char, "Rush_TEN_PowerHit", fx, fy, fz, 0, 1)
            end
        end
    elseif skill == "Rush_TEN_PowerHit" then
        if state == SKILL_STATE.CAST then
            local maxRange = Ext.StatGetAttribute(skill, "TargetRadius")
            local x,y,z = table.unpack(data.TargetPositions[1])
			local dist = GetDistanceToPosition(char, x,y,z)
			local delay = GameHelpers.Math.ScaleToRange(dist, 0, maxRange, 240, 600)
			-- print(maxRange, delay, dist)
			Timer.Start("TEN_RushPowerHitFinished", delay, char, data.Target)
        end
    end
end)

Timer.RegisterListener("TEN_RushPowerHitFinished", function(_, char)
	local pos = GameHelpers.Math.ExtendPositionWithForwardDirection(char, 1)
    print(char.DisplayName)
    pos[2] = pos[2]+0.25
    GameHelpers.Skill.Explode(pos, "Projectile_TEN_PowerHit_Hit", char, nil, true)
    GameHelpers.Skill.Explode(pos, "Projectile_TEN_PowerHit_Blast", char, nil, true)
    -- PlayEffectAtPosition("RS3_FX_Skills_Tenebrium_PowerHit_Impact_01", pos[1], pos[2], pos[3])
end, true)
-------- END Power Hit
