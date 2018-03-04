local tst = {}
local tool = require 'tool'
local lp = require 'line_processing'


main = dark.pipeline()
main:basic()
main:model("postag-fr")

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

--tool.new_lex(prenomsMasculins, f_data)
--tool.new_lex(prenomsFeminins, f_data)
main:pattern('"PRETAG" [#prenomDef .*?] "PRETAG"')
main:pattern('"NOMTAG" [#nomDef .*?] "NOMTAG"')

main:pattern('[#annee /^%d%d%d%d$/]')

main:pattern('[#date (#d)? #mois #annee]')

main:pattern('("né"|"née"|"nait") .*? "le" [#dateNaissance #date]')
main:pattern('("né"|"née"|"nait") .*? ("à"|"au") [#lieuNaissance #POS=NNP+]')

main:pattern('[#femme "est" .*? "femme" "politique"]')

--main:pattern('[#prenom'..tool.tag(ppn)..'] [#nom .{,2}? ( #POS=NNP+ | #W )+]')


main:pattern('[#pre #POS=NNP]')

main:pattern('[#parent1 ("fils"|"fille") .*? "de" [#prenom #POS=NNP] [#nom #POS=NNP+]? ("," [#metier .*?] ",")?]')
main:pattern('#parent1 .*? "et" "de"? [#parent2 [#prenom #POS=NNP] [#nom #POS=NNP+]? ("," [#metier .*?] ",")?]')
main:pattern('("mère"|"père") "de" [#enfant [#prenom #POS=NNP] [#nom #POS=NNP]?]')
main:pattern('"sa" "fille" [#fille [#prenom #POS=NNP] [#nom #POS=NNP+]?]')
main:pattern('"son" "fils" [#fils [#prenom #POS=NNP] [#nom #POS=NNP+]?]')
main:pattern('"son" "frère" [#frere [#prenom #POS=NNP] [#nom #POS=NNP+]?]')
main:pattern('"sa" "soeur" [#soeur [#prenom #POS=NNP] [#nom #POS=NNP+]?]')
main:pattern('"est" ("le"|"la") ("fille"|"fils") ("de"|"du") .*? [#parent [#prenom #POS=NNP] [#nom #POS=NNP+]?]')
main:pattern('("est"|"était") ("marié"|"mariée"|"divorcé"|"divorcée") ("de"|"à") [#conjoint [#prenom #POS=NNP] [#nom #POS=NNP+]?]')
--main:pattern('/[I|i]l/|"Elle" .*? "mère"|"père" "de" [#fille [#prenom ' ..tool.tag(prenomsFeminins).. '] [#nom #POS=NNP+]?]')


main:pattern('[#intervalDate (#annee ("-"|"–"|"depuis")) #annee]')
main:pattern('[#raccourcis "(" [#acc #W] ")"]')
main:pattern('"PART" [#parti [#nom .*] "PART" #raccourcis? #intervalDate?]')


main:pattern('"NOMF" [#nomFonc .*?] ([#dateFonc #annee ("-"|"–") #annee])? ("(" .*? ")")? "NOMF"')
main:pattern('"NOMF" [#dateFonc #annee ("-"|"–") #annee]')
--main:pattern('"NOMF" [#dateFonc ("En" "fonction" "depuis" "le" #date|#date "–" #date|#date)] ("(" .*? ")")?')
main:pattern('"NOMF" ("en" "fonction")? [#depuis ("depuis")?] ("le")? [#dateD #date] ("-"|"–")? [#dateF (#date)?]')
main:pattern('"SEP2" [#fonc [#arg .*?] "rel" [#val .*?]] "SEP3"')


main:pattern('[#bac ("Il"|"Elle")? ("obtient"|"reçoit"|"décroche") .*? ("baccalauréat"|"bac")]')
main:pattern('#bac .*? "en" [#anneeObtention #annee]')
main:pattern('#bac .*? ("à"|"au") [#lieuF #POS=NNP]')

main:pattern('[#licence [#nom ("licence"|"master"|"Licence"|"Master") #d?] "de" [#sujet #POS=NNC] .*? [#lieuF ("faculté"|"université"|"fac") .*?] ("en" [#anneeObtention #annee])? ","]')
main:pattern('[#licence [#nom ("licence"|"master"|"Licence"|"Master") #d?] ("de"|"en") [#sujet #POS=NNC]]')



tags = {
	--["#pre"] = "green",
	["#dateNaissance"] = "yellow",
	["#lieuNaissance"] = "green",
	["#enfant"] = "red",
	["#frere"] = "red",
	["#soeur"] = "red",
	["#conjoint"] = "red",
	["#parent"] = "red",
	["#fille"] = "red",
	["#fils"] = "red",
	["#parent1"] = "red",
	["#parent2"] = "red",
	["#metier"] = "green",
	["#arg"] = "green",
	["#val"] = "green",
	["#fonc"] = "red",
	["#nomFonc"] = "yellow",
	["#dateFonc"] = "yellow",
	["#bac"] = "blue",
	["#licence"] = "blue",
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
	["#date"] = "red",
	["#dateD"] = "red",
	["#dateF"] = "red",
	["#depuis"] = "red",
	
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
	--print("\n\n " .. fichierCourant .. "\n\n")–

	if havetag(seq, "#nomDef") then
		nomC = tagstr2(seq, "#nomDef"):gsub(" %p ", "-")
	end

	if havetag(seq, "#prenomDef") then
		prenomC = tagstr2(seq, "#prenomDef"):gsub(" %p ", "-")
	end

	local fichierCourant = lp.gen_key(nomC, prenomC)

	--print(fichierCourant)

	if(db[fichierCourant] == nil) then
		db[fichierCourant] = {
			firstname = prenomC,
			name = nomC,
			particule = "Il",
		}
	end

	if havetag(seq, "#femme") then
		db[fichierCourant].particule = "Elle"
	end
	
	if havetag(seq, "#dateNaissance") then
		local date = tagstr2(seq, "#dateNaissance")
		db[fichierCourant].birth = date
	end

	if havetag(seq, "#lieuNaissance") then
		local lieu = tagstr2(seq, "#lieuNaissance")
		db[fichierCourant].birthplace = lieu
	end

	if(db[fichierCourant].famille == nil) then
		db[fichierCourant].famille = {}
	end

	if havetag(seq, "#parent") then
		local prenom = GetValueInLink(seq, "#prenom", "#parent")
		if havetag(seq, "#nom") then
			local nom = GetValueInLink(seq, "#nom", "#parent")
		else
			local nom = ""
		end

		db[fichierCourant].famille[#db[fichierCourant].famille + 1] = {
			statut = "parent",
			prenom = prenom,
			nom = nom,
		}
	end
	
	if havetag(seq, "#fille") then
		local prenom = GetValueInLink(seq, "#prenom", "#fille")
		if havetag(seq, "#nom") then
			local nom = GetValueInLink(seq, "#nom", "#fille")
		else
			local nom = ""
		end

		db[fichierCourant].famille[#db[fichierCourant].famille + 1] = {
			statut = "fille",
			prenom = prenom,
			nom = nom,
		}
	end

	if havetag(seq, "#fils") then
		local prenom = GetValueInLink(seq, "#prenom", "#fils")
		if havetag(seq, "#nom") then
			local nom = GetValueInLink(seq, "#nom", "#fils")
		else
			local nom = ""
		end

		db[fichierCourant].famille[#db[fichierCourant].famille + 1] = {
			statut = "fils",
			prenom = prenom,
			nom = nom,
		}
	end

	if havetag(seq, "#frere") then
		local prenom = GetValueInLink(seq, "#prenom", "#frere")
		if havetag(seq, "#nom") then
			local nom = GetValueInLink(seq, "#nom", "#frere")
		else
			local nom = ""
		end

		db[fichierCourant].famille[#db[fichierCourant].famille + 1] = {
			statut = "frere",
			prenom = prenom,
			nom = nom,
		}
	end

	if havetag(seq, "#soeur") then
		local prenom = GetValueInLink(seq, "#prenom", "#soeur")
		if havetag(seq, "#nom") then
			local nom = GetValueInLink(seq, "#nom", "#soeur")
		else
			local nom = ""
		end

		db[fichierCourant].famille[#db[fichierCourant].famille + 1] = {
			statut = "soeur",
			prenom = prenom,
			nom = nom,
		}
	end

	if havetag(seq, "#conjoint") then
		local prenom = GetValueInLink(seq, "#prenom", "#conjoint")
		if havetag(seq, "#nom") then
			local nom = GetValueInLink(seq, "#nom", "#conjoint")
		else
			local nom = ""
		end

		db[fichierCourant].famille[#db[fichierCourant].famille + 1] = {
			statut = "conjoint",
			prenom = prenom,
			nom = nom,
		}
	end

	if havetag(seq, "#parent1") then
		local prenomP = GetValueInLink(seq, "#prenom", "#parent1")
		local nomP = GetValueInLink(seq, "#nom", "#parent1")
		local met = GetValueInLink(seq, "#metier", "#parent1")
		db[fichierCourant].famille[#db[fichierCourant].famille + 1] = {
			statut = "parent",
			prenom = prenomP,
			nom = nomP,
			profession = met,
		}
	end

	if havetag(seq, "#parent2") then
		local prenomP = GetValueInLink(seq, "#prenom", "#parent2")
		local nomP = GetValueInLink(seq, "#nom", "#parent2")
		local met = GetValueInLink(seq, "#metier", "#parent2")
		db[fichierCourant].famille[#db[fichierCourant].famille + 1] = {
			statut = "parent",
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
		local tab = {}
		tab["intitule"] = tagstr2(seq, "#nomFonc")
		
		local int = ""
		local dateDeb = ""
		local dateFin = ""
		
		if havetag(seq, "#dateD") then
			dateDeb = tagstr2(seq, "#dateD")
		end

		if havetag(seq, "#dateF") then
			dateFin = tagstr2(seq, "#dateF")
		end

		if havetag(seq, "#dateFonc") then
			int = tagstr2(seq, "#dateFonc")
			if(int ~= nil) then
				dateDeb = lp.split(int, " - ")[1]
				if(dateDeb == "Depuis" or dateDeb == "depuis") then
					dateDeb = lp.split(int, " - ")[2]
					dateFin = ""
				else
					dateFin = lp.split(int, " - ")[3]
				end
			
			end
		end

		
		
		tab["date_adhesion"] = dateDeb
		tab["date_depart"] = dateFin

		if havetag(seq, "#arg") then
			local foncs = tagstr(seq, "#arg")
			local gg = tagstr(seq, "#val")
		
			for i, v in ipairs(foncs) do
				tab[v] = gg[i]
			end
		end
		if(db[fichierCourant].profession == nil) then
			db[fichierCourant].profession = {}
		end
		db[fichierCourant].profession[#db[fichierCourant].profession + 1] = tab
	end
	
	if havetag(seq, "#bac") then
		local ann = tagstr2(seq, "#anneeObtention")
		local lieuF = tagstr2(seq, "#lieuF")
		if(db[fichierCourant].formation == nil) then
			db[fichierCourant].formation = {}
		end
		db[fichierCourant].formation[#db[fichierCourant].formation + 1] = {
			name = "Baccalauréat",
			date = ann,
			lieu = lieuF,
		}
	end

	if havetag(seq, "#licence") then
		local ann = GetValueInLink(seq, "#anneeObtention", "#licence")
		local li = GetValueInLink(seq, "#lieuF", "#licence")
		local suj = GetValueInLink(seq, "#sujet", "#licence")
		local no = GetValueInLink(seq, "#nom", "#licence")
		if(db[fichierCourant].formation == nil) then
			db[fichierCourant].formation = {}
		end
		db[fichierCourant].formation[#db[fichierCourant].formation + 1] = {
			date = ann,
			name = no,
			lieu = li,
			sujet = suj
		}
	end
	

end


local f_test = "../extraction/corpus/wikipedia/"
--local f_test = "../test"
lp.read_corpus(f_test)

local outfile = io.open("databaseTemp.lua", "w")
outfile:write("return ")
outfile:write(serialize(db))
outfile.close()


--print(serialize(db))
return tst











