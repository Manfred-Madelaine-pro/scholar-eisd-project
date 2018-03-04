local tst = {}
local tool = require 'tool'
local lp = require 'line_processing'


main = dark.pipeline()
main:basic()
main:model("postag-fr")


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

function couvertureTotale()
	local datab = dofile("databaseFinal.lua")

	local outfile = io.open("couverture.lua", "w")
	outfile:write("Couverture\n")
	
	local wr = ""

	local i = 0
	local name = 0
	local firstname = 0
	local birth = 0
	local birthplace = 0
	local particule = 0

	local famille = 0
	local parti = 0
	local formation = 0
	local profession = 0

	local nomFam = 0
	local prenomFam = 0
	local statut = 0
	local professionFam = 0
	local nbMembreF = 0

	local nbParti = 0
	local nomParti = 0
	local acronyme = 0
	local dateDebP = 0
	local dateFinP = 0

	local nbProf = 0
	local intitule = 0
	local dateDep = 0
	local dateAd = 0

	local nbForm = 0
	local nomForm = 0
	local dateOb = 0
	local lieu = 0
	local sujet = 0
	for k, v in pairs(datab) do
		i = i + 1
		if(v.name ~= nil and v.name ~= "") then
			name = name + 1
		end
		if(v.firstname ~= nil and v.firstname ~= "") then
			firstname = firstname + 1
		end
		if(v.birth ~= nil and v.birth ~= "") then
			birth = birth + 1
		end
		if(v.birthplace ~= nil and v.birthplace ~= "") then
			birthplace = birthplace + 1
		end
		if(v.particule ~= nil and v.particule ~= "") then
			particule = particule + 1
		end

		if(v.famille ~= nil and #v.famille ~= 0) then
			famille = famille + 1
			for k2, v2 in pairs(v.famille) do
				nbMembreF = nbMembreF + 1
				if(v2.nom ~= nil and v2.nom ~= "") then
					nomFam = nomFam + 1
				end
				if(v2.prenom ~= nil and v2.prenom ~= "") then
					prenomFam = prenomFam + 1
				end
				if(v2.statut ~= nil and v2.statut ~= "") then
					statut = statut + 1
				end
				if(v2.profession ~= nil and v2.profession ~= "") then
					professionFam = professionFam + 1
				end
			end
		end
		if(v.parti ~= nil and #v.parti ~= 0) then
			parti = parti + 1
			for k2, v2 in pairs(v.parti) do
				nbParti = nbParti + 1
				if(v2.nom ~= nil and v2.nom ~= "") then
					nomParti = nomParti + 1
				end
				if(v2.acronyme ~= nil and v2.acronyme ~= "") then
					acronyme = acronyme + 1
				end
				if(v2.date_deb ~= nil and v2.date_deb ~= "") then
					dateDebP = dateDebP + 1
				end
				if(v2.date_fin ~= nil and v2.date_fin ~= "") then
					dateFinP = dateFinP + 1
				end
			end
		end
		if(v.profession ~= nil and #v.profession ~= 0) then
			profession = profession + 1
			for k2, v2 in pairs(v.profession) do
				nbProf = nbProf + 1
				if(v2.intitule ~= nil and v2.intitule ~= "") then
					intitule = intitule + 1
				end
				if(v2.date_adhesion ~= nil and v2.date_adhesion ~= "") then
					dateAd = dateAd + 1
				end
				if(v2.date_depart ~= nil and v2.date_depart ~= "") then
					dateDep = dateDep + 1
				end
			end
		end
		if(v.formation ~= nil and #v.formation ~= 0) then
			formation = formation + 1
			for k2, v2 in pairs(v.formation) do
				nbForm = nbForm + 1
				if(v2.name ~= nil and v2.name ~= "") then
					nomForm = nomForm + 1
				end
				if(v2.sujet ~= nil and v2.sujet ~= "") then
					sujet = sujet + 1
				end
				if(v2.lieu ~= nil and v2.lieu ~= "") then
					lieu = lieu + 1
				end
				if(v2.date ~= nil and v2.date ~= "") then
					dateOb = dateOb + 1
				end
			end
		end
		
	end

	wr = wr .. "Nombre de personnalités politiques : " .. tostring(i) .. "\n"
	.. "name : " .. tostring(name) .. " couverture : " .. tostring((name / i) * 100) .. "%\n"
	.. "firstname : " .. tostring(firstname) .. " couverture : " .. tostring((firstname / i) * 100) .. "%\n"
	.. "birth : " .. tostring(birth) .. " couverture : " .. tostring((birth / i) * 100) .. "%\n"
	.. "birthplace : " .. tostring(birthplace) .. " couverture : " .. tostring((birthplace / i) * 100) .. "%\n"
	.. "particule : " .. tostring(particule) .. " couverture : " .. tostring((particule / i) * 100) .. "%\n"

	.. "famille : " .. tostring(famille) .. " couverture : " .. tostring((famille / i) * 100) .. "%\n"
	.. "\t Nombre total de membres de famille : " .. tostring(nbMembreF) .. "\n"
	.. "\t Nom : " .. tostring(nomFam) .. " couverture : " .. tostring((nomFam / nbMembreF) * 100) .. "%\n"
	.. "\t Prénom : " .. tostring(prenomFam) .. " couverture : " .. tostring((prenomFam / nbMembreF) * 100) .. "%\n"
	.. "\t Statut : " .. tostring(statut) .. " couverture : " .. tostring((statut / nbMembreF) * 100) .. "%\n"
	.. "\t Métier : " .. tostring(professionFam) .. " couverture : " .. tostring((professionFam / nbMembreF) * 100) .. "%\n"

	.. "parti : " .. tostring(parti) .. " couverture : " .. tostring((parti / i) * 100) .. "%\n"
	.. "\t Nombre total de partis : " .. tostring(nbParti) .. "\n"
	.. "\t Nom : " .. tostring(nomParti) .. " couverture : " .. tostring((nomParti / nbParti) * 100) .. "%\n"
	.. "\t Acronyme : " .. tostring(acronyme) .. " couverture : " .. tostring((acronyme / nbParti) * 100) .. "%\n"
	.. "\t Date adhésion : " .. tostring(dateDebP) .. " couverture : " .. tostring((dateDebP / nbParti) * 100) .. "%\n"
	.. "\t Date départ : " .. tostring(dateFinP) .. " couverture : " .. tostring((dateFinP / nbParti) * 100) .. "%\n"
	
	.. "profession : " .. tostring(profession) .. " couverture : " .. tostring((profession / i) * 100) .. "%\n"
	.. "\t Nombre total de professions : " .. tostring(nbProf) .. "%\n"
	.. "\t Nom : " .. tostring(intitule) .. " couverture : " .. tostring((intitule / nbProf) * 100) .. "%\n"
	.. "\t Date adhésion : " .. tostring(dateAd) .. " couverture : " .. tostring((dateAd / nbProf) * 100) .. "%\n"
	.. "\t Date départ : " .. tostring(dateDep) .. " couverture : " .. tostring((dateDep / nbProf) * 100) .. "%\n"

	.. "formation : " .. tostring(formation) .. " couverture : " .. tostring((formation / i) * 100) .. "%\n"
	.. "\t Nombre total de formations : " .. tostring(nbForm) .. "\n"
	.. "\t Nom : " .. tostring(nomForm) .. " couverture : " .. tostring((nomForm / nbForm) * 100) .. "%\n"
	.. "\t Sujet : " .. tostring(sujet) .. " couverture : " .. tostring((sujet / nbForm) * 100) .. "%\n"
	.. "\t Lieu : " .. tostring(lieu) .. " couverture : " .. tostring((lieu / nbForm) * 100) .. "%\n"
	.. "\t Date obtention : " .. tostring(dateOb) .. " couverture : " .. tostring((dateOb / nbForm) * 100) .. "%\n"
	
	outfile:write(wr)
	outfile.close()
	print(wr)
end


main:lexicon("#mois", {"janvier", "fevrier", "mars", "avril", "mai", "juin", "juillet", "aout", "septembre", "octobre", "novembre", "decembre"})

main:pattern('"PRETAG" [#prenomDef .*?] "PRETAG"')
main:pattern('"NOMTAG" [#nomDef .*?] "NOMTAG"')

main:pattern('[#annee /^%d%d%d%d$/]')

main:pattern('[#date (#d)? #mois #annee]')

main:pattern('("né"|"née"|"nait") .*? "le" [#dateNaissance #date]')
main:pattern('("né"|"née"|"nait") .*? ("à"|"au") [#lieuNaissance #POS=NNP+]')

main:pattern('[#femme "est" .*? "femme" "politique"]')


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


main:pattern('[#intervalDate (#annee ("-"|"–"|"depuis")) #annee]')
main:pattern('[#raccourcis "(" [#acc #W] ")"]')
main:pattern('"PART" [#parti [#nom .*] "PART" #raccourcis? #intervalDate?]')


main:pattern('"NOMF" [#nomFonc .*?] ([#dateFonc #annee ("-"|"–") #annee])? ("(" .*? ")")? "NOMF"')
main:pattern('"NOMF" [#dateFonc #annee ("-"|"–") #annee]')
main:pattern('"NOMF" (("en"|"En") "fonction")? [#depuis ("depuis")?] ("le")? [#dateD #date] ("-"|"–")? [#dateF (#date)?]')
main:pattern('"SEP2" [#fonc [#arg .*?] "rel" [#val .*?]] "SEP3"')


main:pattern('[#bac ("baccalauréat"|"bac")]')
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
	["#bac"] = "blue",
	["#licence"] = "blue",
	
}

db = {
	
}

nomC = ""
prenomC = ""
aLic = 0
aBac = 0

function traitement(seq)

	if havetag(seq, "#nomDef") then
		aLic = 0
		aBac = 0
		nomC = tagstr2(seq, "#nomDef"):gsub(" %p ", "-")
	end

	if havetag(seq, "#prenomDef") then
		prenomC = tagstr2(seq, "#prenomDef"):gsub(" %p ", "-")
	end

	local fichierCourant = lp.gen_key(nomC, prenomC)

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
		if aBac == 0 then
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
			aBac = 1
		end
	end

	if havetag(seq, "#licence") then
		if aLic == 0 then
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
			aLic = 1
		end
	end
	

end


local corpus = "../extraction/corpus/wikipedia/"
--lp.read_corpus(corpus)
couvertureTotale()

local outfile = io.open("databaseTemp.lua", "w")
outfile:write("return ")
outfile:write(serialize(db))
outfile.close()


--print(serialize(db))
return tst











