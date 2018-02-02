local eva = {}


function havetag(seq, tag)
	return #seq[tag] ~= 0
end

function tagstr(seq, tag, lim_debut, lim_fin)
	lim_debut = lim_debut or 1
	lim_fin   = lim_fin   or #seq
	if not havetag(seq, tag) then
		return nil
	end
	local list = seq[tag]
	for i, position in ipairs(list) do
		local debut, fin = position[1], position[2]
		if debut >= lim_debut and fin <= lim_fin then
			local tokens = {}
			for i = debut, fin do
				tokens[#tokens + 1] = seq[i].token
			end
			return table.concat(tokens, " ")
		end
	end
	return nil
end

function GetValueInLink(seq, entity, link)
	for i, pos in ipairs(seq[link]) do
		local res = tagstr(seq, entity, pos[1], pos[2])
		if res then
			return res
		end
	end
	return nil
end


function eva.t2(seq, db, tag)
	if havetag(seq, tag) then
		local monu = GetValueInLink(seq, "#monument", tag)
		local val  = GetValueInLink(seq, "#valeur",   tag)
		local unit = GetValueInLink(seq, "#unite",    tag)
		val = tonumber(val)
		if val < 0.1 or val > 2000 then
			-- ...
		else
			db[monu] = db[monu] or {}
			db[monu].hauteur = {
				valeur = val,
				unite  = unit,
			}
		end
	end
end

return eva
