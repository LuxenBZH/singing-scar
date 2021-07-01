local function GetParent(entry, attribute)
	local stat = Ext.GetStat(entry)
	local value = Ext.StatGetAttribute(entry, attribute)
	if value == nil then
		GetParent(stat.Using, attribute)
	end
	return value
end

local function OverrideDefaultSight()
	Ext.Print("Overriding Sight stats")
	for i,char in pairs(Ext.GetStatEntries("Character")) do
		if Ext.GetStat(char).Using == "_Hero" then
			Ext.StatSetAttribute(char, "Sight", "6")
		else
			local currentSight = tonumber(Ext.StatGetAttribute(char, "Sight"))
			if currentSight == nil then currentSight = tonumber(GetParent(char, "Sight")) end
			if currentSight == nil then currentSight = 0 end
			if currentSight - 2 > -2 then
				Ext.StatSetAttribute(char, "Sight", tostring(Ext.Round(currentSight-2)))
			end
		end
	end 
end

Ext.RegisterListener("StatsLoaded", OverrideDefaultSight)