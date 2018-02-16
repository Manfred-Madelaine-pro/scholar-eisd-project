local tst = {}
local tool = require 'tool'
local lp = require 'line_processing'


main = dark.pipeline()
main:basic()

-- Tag names
place = "lieu"
ppn = "pnominal"
parti = "partis"

local f_data = "data/"

function tagstr(s, tag, lim_debut, lim_fin)
	lim_debut = lim_debut or 1
	lim_fin   = lim_fin   or #s
	if not havetag(s, tag) then
		return nil
	end
	local list = s[tag]
	local tab = {}
	for i, position in ipairs(list) do
		local debut, fin = position[1], position[2]
		if debut >= lim_debut and fin <= lim_fin then
			local tokens = {}
			for i = debut, fin do
				tokens[#tokens + 1] = s[i].token
			end
			tab[#tab + 1] = table.concat(tokens, " ")
		end
	end
	return tab
end

function tagstr2(s, tag, lim_debut, lim_fin)
	lim_debut = lim_debut or 1
	lim_fin   = lim_fin   or #s
	if not havetag(s, tag) then
		return nil
	end
	local list = s[tag]
	for i, position in ipairs(list) do
		local debut, fin = position[1], position[2]
		if debut >= lim_debut and fin <= lim_fin then
			local tokens = {}
			for i = debut, fin do
				tokens[#tokens + 1] = s[i].token
			end
			return table.concat(tokens, " ")
		end
	end
	return nil
end

function havetag(s, tag)
	return #s[tag] ~= 0
end

function GetValuesInLink(seq, entity, link)
	for i, pos in ipairs(seq[link]) do
		local res = tagstr(seq, entity, pos[1], pos[2])
		if res then
			return res
		end
	end
	return nil
end

function GetValueInLink(seq, entity, link)
	for i, pos in ipairs(seq[link]) do
		local res = tagstr2(seq, entity, pos[1], pos[2])
		if res then
			return res
		end
	end
	return nil
end


main:lexicon("#mois", {"janvier", "fevrier", "mars", "avril", "mai", "juin", "juillet", "aout", "septembre", "octobre", "novembre", "decembre"})
tool.new_lex(ppn, f_data)
tool.new_lex(place, f_data)
tool.new_lex(parti, f_data)

main:pattern('[#annee /^%d%d%d%d$/]')

main:pattern('[#date #d #mois #annee]')

main:pattern('("ne"|"nee"|"nait") .*? "le" [#dateNaissance #date]')
main:pattern('("ne"|"nee"|"nait") .*? "a" [#lieuNaissance' ..tool.get_tag(place).. ']')

main:pattern('[#prenom'..tool.get_tag(ppn)..'] [#nom .{,2}? ( #POS=NNP+ | #W )+]')

--main:pattern('[#prenomDef #prenom] #prenom*')

--main:pattern('("fils"|"fille") .*? "de" [#prenomParent1 #prenom] [#nomParent1 #nom]?')
--main:pattern('#prenomParent1 .*? "et" "de" [#prenomParent2 #prenom] [#nomParent2 #nom]?')
main:pattern('[#parent1 ("fils"|"fille") .*? "de" #prenom #nom? ("," [#metier .*?] ",")?]')
main:pattern('#parent1 .*? "et" "de" [#parent2 #prenom #nom? ("," [#metier .*?] ",")?]')

main:pattern('[#parti'..tool.get_tag(parti)..']')



tags = {
	["#dateNaissance"] = "yellow",
	["#lieuNaissance"] = "green",
	["#nom"] = "blue",
	["#prenom"] = "blue",
	["#parent1"] = "red",
	["#parent2"] = "red",
	["#metier"] = "green",
	["#parti"] = "white",
}

db = {
	["JLM"] = {
		nom = "Méluch",
		famille = {
		},
	}
}

function traitement(seq)
	if havetag(seq, "#parent1") then
		local prenomP = GetValueInLink(seq, "#prenom", "#parent1")
		local nomP = GetValueInLink(seq, "#nom", "#parent1")
		db["JLM"].famille["Parent1"] = {
			prenom = prenomP,
			nom = nomP,
		}
	end

	if havetag(seq, "#parent2") then
		local prenomP = GetValueInLink(seq, "#prenom", "#parent2")
		local nomP = GetValueInLink(seq, "#nom", "#parent2")
		db["JLM"].famille["Parent2"] = {
			prenom = prenomP,
			nom = nomP,
		}
	end
end


local f_test = "../test"
lp.read_corpus(f_test)

print(serialize(db))
return tst











