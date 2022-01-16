---- Activate Sourcery ability if LeaderLib is activated
-- if Mods.LeaderLib ~= nil then
--     Mods.LeaderLib.AbilityManager.EnableAbility("Sourcery", "ff4dba5a-16e3-420a-aa51-e5c8531b0095")
-- end

Game.Math.DamageBoostTable["Shadow"] = function(character) return math.floor(RetrieveCharacterCustomStatValue(character.Character, "SRP_TenebriumInfusion_") / 1.5) end