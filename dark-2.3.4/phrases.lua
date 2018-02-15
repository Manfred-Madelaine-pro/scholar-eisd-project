local txt = {}

local sujet = "<sujet>"
local date  = "<date>"

local ne = {sujet.." est né le "..date}

function change(sen, ...)
	local arg = {...}
	for i,champ in ipairs(arg) do
		sen = sen:gsub(sujet, s)

	end
	

end


return txt