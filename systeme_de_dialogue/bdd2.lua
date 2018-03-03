local tst = {}
local tool = require 'tool'
local lp = require 'line_processing'
local c = require 'clean'


main = dark.pipeline()
main:basic()

-- Tag names
place = "lieu"
ppn = "pnominal"
prenomsMasculins = "prenomM"
prenomsFeminins = "prenomF"
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
--tool.new_lex(prenomsMasculins, f_data)
--tool.new_lex(prenomsFeminins, f_data)
main:pattern('"PRETAG" [#prenomDef .*?] "PRETAG"')
main:pattern('"NOMTAG" [#nomDef .*?] "NOMTAG"')

main:pattern('[#annee /^%d%d%d%d$/]')

main:pattern('[#date #d #mois #annee]')

main:pattern('("ne"|"nee"|"nait") .*? "le" [#dateNaissance #date]')
main:pattern('("ne"|"nee"|"nait") .*? "a"|"au" [#lieuNaissance #POS=NNP+]')

main:pattern('[#femme "est" .*? "femme" "politique"]')

--main:pattern('[#prenom'..tool.tag(ppn)..'] [#nom .{,2}? ( #POS=NNP+ | #W )+]')


main:pattern('[#parent1 ("fils"|"fille") .*? "de" #prenom #nom? ("," [#metier .*?] ",")?]')
main:pattern('#parent1 .*? "et" "de" [#parent2 #prenom #nom? ("," [#metier .*?] ",")?]')
main:pattern('("compagne"|"femme") [#femme #prenom #nom?]')
main:pattern('/[I|i]l/|"Elle" .*? "mère"|"père" "de" [#enfant [#prenom #POS=NNP+] [#nom #POS=NNP+]?]')
main:pattern('"sa" "fille" [#fille [#prenom #POS=NNP+] [#nom #POS=NNP+]?]')
main:pattern('"son" "fils" [#fils [#prenom #POS=NNP+] [#nom #POS=NNP+]?]')
main:pattern('"son" "frère" [#frere [#prenom #POS=NNP+] [#nom #POS=NNP+]?]')
main:pattern('"sa" "soeur" [#soeur [#prenom #POS=NNP+] [#nom #POS=NNP+]?]')
--main:pattern('/[I|i]l/|"Elle" .*? "mère"|"père" "de" [#fille [#prenom ' ..tool.tag(prenomsFeminins).. '] [#nom #POS=NNP+]?]')


main:pattern('[#intervalDate (#annee "-"|"depuis") #annee]')
main:pattern('[#raccourcis "(" [#acc .{,4}] ")"]')
main:pattern('"PART" [#parti [#nom .*] "PART" #raccourcis? #intervalDate?]')


main:pattern('"NOMF" [#nomFonc .*?] "NOMF"')
main:pattern('"NOMF" [#dateFonc ("En" "fonction" "depuis" "le" #date|#date "–" #date|#date)] ("(" .*? ")")?')
main:pattern('"SEP2" [#fonc [#arg .*?] "REL" [#val .*?]] "SEP3"')


main:pattern('[#bac ("Il"|"Elle")? ("obtient"|"reçoit"|"decroche") .*? ("baccalaureat"|"bac") .*? ("en" [#anneeObtention #annee])?]')

main:pattern('[#fac "faculte" "de" [#sujet .*?] "de" [#lieuF .*? "universite" .*?] ("en" [#anneeObtention #annee])]')
main:pattern('[#fac "faculte" "de" [#sujet .*?] "de" [#lieuF .*? "universite" .*?] ("en" [#anneeObtention #annee])?]')



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
	["#parti"] = "red",
	["#nom"] = "red",
	["#raccourcis"] = "red",	
	["#intervalDate"] = "red",
	["#prenomDef"] = "red",
	["#nomDef"] = "red",
	["#femme"] = "red",
	
}

db = {
	["JLM"] = {

	}
}

nomC = ""
prenomC = ""

function traitement(seq)
	--local fichierCourant = string.lower(c.cleaner(nom))
	--if(db[fichierCourant] == nil) then
	--	db[fichierCourant] = {
	--		nom = nom,
	--		prenom = prenomm,
	--	}
	--end
	--print("\n\n " .. fichierCourant .. "\n\n")

	if havetag(seq, "#nomDef") then
		nomC = tagstr2(seq, "#nomDef")
	end

	if havetag(seq, "#prenomDef") then
		prenomC = tagstr2(seq, "#prenomDef")
	end

	local fichierCourant = lp.gen_key(nomC, prenomC)

	if(db[fichierCourant] == nil) then
		db[fichierCourant] = {
			prenom = prenomC,
			nom = nomC,
			particule = "Il",
		}
	end

	if havetag(seq, "#femme") then
		db[fichierCourant].particule = "Elle"
	end
	
	if havetag(seq, "#dateNaissance") then
		local date = tagstr2(seq, "#dateNaissance")
		db[fichierCourant].dateNaissance = date
	end

	if havetag(seq, "#lieuNaissance") then
		local lieu = tagstr2(seq, "#lieuNaissance")
		db[fichierCourant].lieuNaissance = lieu
	end

	if havetag(seq, "#parent1") then
		local prenomP = GetValueInLink(seq, "#prenom", "#parent1")
		local nomP = GetValueInLink(seq, "#nom", "#parent1")
		local met = GetValueInLink(seq, "#metier", "#parent1")
		db[fichierCourant].famille["Parent1"] = {
			prenom = prenomP,
			nom = nomP,
			profession = met,
		}
	end

	if havetag(seq, "#parent2") then
		local prenomP = GetValueInLink(seq, "#prenom", "#parent2")
		local nomP = GetValueInLink(seq, "#nom", "#parent2")
		local met = GetValueInLink(seq, "#metier", "#parent2")
		db[fichierCourant].famille["Parent2"] = {
			prenom = prenomP,
			nom = nomP,
			profession = met,
		}
	end
	
	if havetag(seq, "#parti") then
		local dateDeb = nil
		local dateFin = nil
		local nomPa = GetValueInLink(seq, "#nom", "#parti")
		local racc = GetValueInLink(seq, "#acc", "#parti")
		local int = GetValueInLink(seq, "#intervalDate", "#parti")
		if(int ~= nil) then
			dateDeb = lp.split(int, " - ")[1]
			if(dateDeb == "Depuis" or dateDeb == "depuis") then
				dateDeb = lp.split(int, " - ")[2]
				dateFin = ""
			else
				dateFin = lp.split(int, " - ")[3]
			end
			
		end
			
		if(db[fichierCourant].parti == nil) then
			db[fichierCourant].parti = {}
		end
		db[fichierCourant].parti[#db[fichierCourant].parti + 1] = {
			nom = nomPa,
			acronyme = racc,
			date_deb = dateDeb,
			date_fin = dateFin,
		}
	end
	
	if havetag(seq, "#nomFonc") then
		tab = {}
		tab["nom"] = tagstr2(seq, "#nomFonc")
		
		tab["date"] = tagstr2(seq, "#dateFonc")

		if havetag(seq, "#arg") then
			local foncs = tagstr(seq, "#arg")
			local gg = tagstr(seq, "#val")
		
			for i, v in ipairs(foncs) do
				tab[v] = gg[i]
			end
		end
		if(db[fichierCourant].fonctions == nil) then
			db[fichierCourant].fonctions = {}
		end
		db[fichierCourant].fonctions[#db[fichierCourant].fonctions + 1] = tab
	end
	
	if havetag(seq, "#bac") then
		local ann = GetValueInLink(seq, "#anneeObtention", "#bac")
		if(db[fichierCourant].formation == nil) then
			db[fichierCourant].formation = {}
		end
		db[fichierCourant].formation["Baccalaureat"] = {
			annee = ann,
			lieu = "",
		}
	end

	if havetag(seq, "#fac") then
		local ann = GetValueInLink(seq, "#anneeObtention", "#fac")
		local suj = GetValueInLink(seq, "#sujet", "#fac")
		local li = GetValueInLink(seq, "#lieuF", "#fac")
		if(db[fichierCourant].formation == nil) then
			db[fichierCourant].formation = {}
		end
		db[fichierCourant].formation["Faculte"] = {
			annee = ann,
			sujet = suj,
		}
	end
	

end


local f_test = "../extraction/corpus/wikipedia"
--local f_test = "../test"
lp.read_corpus(f_test)

local outfile = io.open("databaseTemp.lua", "w")
outfile:write("return ")
outfile:write(serialize(db))
outfile.close()


--print(serialize(db))
return tst











