local tst = {}
local tool = require 'tool'
local lp = require 'line_processing'


main = dark.pipeline()
main:basic()

-- Tag names
place = "lieu"
ppn = "pnominal"
parti = "partis"
ecole = "ecole"

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
--tool.new_lex(ecole, f_data)

main:pattern('[#annee /^%d%d%d%d$/]')

main:pattern('[#date #d #mois #annee]')

main:pattern('("ne"|"nee"|"nait") .*? "le" [#dateNaissance #date]')
main:pattern('("ne"|"nee"|"nait") .*? "a" [#lieuNaissance' ..tool.tag(place).. ']')

main:pattern('[#prenom'..tool.tag(ppn)..'] [#nom .{,2}? ( #POS=NNP+ | #W )+]')

--main:pattern('[#prenomDef #prenom] #prenom*')

--main:pattern('("fils"|"fille") .*? "de" [#prenomParent1 #prenom] [#nomParent1 #nom]?')
--main:pattern('#prenomParent1 .*? "et" "de" [#prenomParent2 #prenom] [#nomParent2 #nom]?')
main:pattern('[#parent1 ("fils"|"fille") .*? "de" #prenom #nom? ("," [#metier .*?] ",")?]')
main:pattern('#parent1 .*? "et" "de" [#parent2 #prenom #nom? ("," [#metier .*?] ",")?]')
main:pattern('("compagne"|"femme") [#femme #prenom #nom?]')

--main:pattern('[#parti'..tool.get_tag(parti)..']')
main:pattern('[#intervalDate (#annee "-"|"depuis") #annee]')
main:pattern('[#raccourcis "(" [#acc .{,4}] ")"]')
main:pattern('[#parti [#nom .*?] #raccourcis #intervalDate]')


main:pattern('"NOMF" [#nomFonc .*?] "NOMF"')
main:pattern('"NOMF" [#dateFonc ("En" "fonction" "depuis" "le" #date|#date "–" #date|#date)]')
main:pattern('"SEP2" [#fonc [#arg .*?] "REL" [#val .*?]] "SEP2"')

main:pattern('[#bac ("Il"|"Elle")? ("obtient"|"reçoit"|"decroche") .*? ("baccalaureat"|"bac") .*? ("en" [#anneeObtention #annee])?]')

main:pattern('[#fac "faculte" "de" [#sujet .*?] "de" [#lieuF .*? "universite" .*?] ("en" [#anneeObtention #annee])]')
main:pattern('[#fac "faculte" "de" [#sujet .*?] "de" [#lieuF .*? "universite" .*?] ("en" [#anneeObtention #annee])?]')

--main:pattern('"NEW" [#fonc .*?] "SEP"')



tags = {
	["#dateNaissance"] = "yellow",
	["#lieuNaissance"] = "green",
	["#parent1"] = "red",
	["#parent2"] = "red",
	["#metier"] = "green",
	["#arg"] = "green",
	["#val"] = "green",
	["#fonc"] = "red",
	["#nomFonc"] = "yellow",
	["#dateFonc"] = "yellow",
	["#bac"] = "blue",
	["#fac"] = "blue",
	["#sujet"] = "blue",
	["#lieuF"] = "blue",
	["#anneeObtention"] = "blue",
	["#femme"] = "red",
	
}

db = {
	["JLM"] = {
		nom = "Mélenchon",
		prenom = "Jean-Luc",
		famille = {
		},
		parti = {
		},
		fonctions = {
		},
		formation = {
		},
	}
}

function traitement(seq)
	if havetag(seq, "#dateNaissance") then
		local date = tagstr2(seq, "#dateNaissance")
		db["JLM"].dateNaissance = date
	end

	if havetag(seq, "#lieuNaissance") then
		local lieu = tagstr2(seq, "#lieuNaissance")
		db["JLM"].lieuNaissance = lieu
	end

	if havetag(seq, "#parent1") then
		local prenomP = GetValueInLink(seq, "#prenom", "#parent1")
		local nomP = GetValueInLink(seq, "#nom", "#parent1")
		local met = GetValueInLink(seq, "#metier", "#parent1")
		db["JLM"].famille["Parent1"] = {
			prenom = prenomP,
			nom = nomP,
			profession = met,
		}
	end

	if havetag(seq, "#parent2") then
		local prenomP = GetValueInLink(seq, "#prenom", "#parent2")
		local nomP = GetValueInLink(seq, "#nom", "#parent2")
		local met = GetValueInLink(seq, "#metier", "#parent2")
		db["JLM"].famille["Parent2"] = {
			prenom = prenomP,
			nom = nomP,
			profession = met,
		}
	end

	if havetag(seq, "#parti") then
		local nomPa = GetValueInLink(seq, "#nom", "#parti")
		local racc = GetValueInLink(seq, "#acc", "#parti")
		local int = GetValueInLink(seq, "#intervalDate", "#parti")
		db["JLM"].parti[#db["JLM"].parti + 1] = {
			nom = nomPa,
			acronyme = racc,
			dates = int,
		}
	end

	if havetag(seq, "#nomFonc") then
		tab = {}
		tab["nom"] = tagstr2(seq, "#nomFonc")
		tab["date"] = tagstr2(seq, "#dateFonc")
		local foncs = tagstr(seq, "#arg")
		local gg = tagstr(seq, "#val")
		for i, v in ipairs(foncs) do
			tab[v] = gg[i]
		end
		db["JLM"].fonctions[#db["JLM"].fonctions + 1] = tab
	end

	if havetag(seq, "#bac") then
		local ann = GetValueInLink(seq, "#anneeObtention", "#bac")
		db["JLM"].formation["Baccalaureat"] = {
			annee = ann,
			lieu = "",
		}
	end

	if havetag(seq, "#fac") then
		local ann = GetValueInLink(seq, "#anneeObtention", "#fac")
		local suj = GetValueInLink(seq, "#sujet", "#fac")
		local li = GetValueInLink(seq, "#lieuF", "#fac")
		db["JLM"].formation["Faculte"] = {
			annee = ann,
			sujet = suj,
		}
	end


end


local f_test = "../test"
lp.read_corpus(f_test)

print(serialize(db))
return tst











