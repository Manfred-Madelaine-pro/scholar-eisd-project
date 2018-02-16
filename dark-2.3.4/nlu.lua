--[[
	Natural Language Understanding

	Gère les lexiques et les paternes
]]--


-- importation des modules
local tool = require 'tool'


main = dark.pipeline()
main:basic()

-- Chargement du modèle statistique entraîné sur le français 
main:model("model-2.3.0/postag-fr")


-- Tag's name
neg   = "neg"
fin   = "fin"
exit  = "end"
user = "user"
place = "lieu"
month = "month"
quest = "quest"
temps = "temps"
ppn   = "pnominal" -- pronom personel nom inal
tutoiement = "tutoiement"


-- attributs d'un Politicien dans la bdd
db_name   = "name"
db_birth  = "birth"
db_death  = "death"
db_fname  = "firstname"
db_forma  = "formation"
db_birthp = "birthplace"

-- hors de la bdd
hdb_status = "statut"
hdb_createurs = "createurs"

-- Liste d'elements
l_attributs = {db_birth, db_birthp, db_forma, hdb_status, hdb_createurs}
l_tutoiement = {"tu", "te", "t'", "tes", "ton"}
l_user = {"je", "moi", "m'", "mes", "mon"}
l_dev = {"Manfred MadlnT", "Cedrick RibeT", "Hugo BommarT", "Laos GalmnT"}

local f_data = "data/"



function main:lexicon(...)
	return self:add(dark.lexicon(...))
end


-- Création d'un lexique ou chargement d'un lexique existant
tool.create_lex(f_data)

main:lexicon("#day", {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"})

main:lexicon("#dateN", {"date de naissance", "naissance"})
main:lexicon("#lieuN", {"lieu de naissance", "où", "ou"})
main:lexicon("#formation", {"formation"})
main:lexicon(tool.tag(tutoiement), l_tutoiement)
main:lexicon(tool.tag(user), l_user)
-- vouvoiement ?
main:lexicon("#question", {"qui", "quelle", "quoi", "comment", "ou", "quand"})



-- Paterne avec expressions régulières 
main:pattern('[#year /^%d%d%d%d$/]')

-- Paterne pour une date   A optimiser !!
main:pattern([[
	[#date 
		#day /%d+/ #month #year |
		#day /%d+/ #month |
		/%d+/ #month  #year |
		/%d+/ #month |
		#day /%d+/ |
		#month #year |
		/%d+/ "/" /%d+/ "/" /%d+/ |
		#d "/" #d "/" #d
	]
]])

-- Date de naissance
main:pattern(' "ne" .*? "le" [#birth #date]')

-- Lieu de naissance
main:pattern(' "ne" .*? "a" [#birthplace '..tool.tag(place)..']')

-- Reconnaitre un nom
main:pattern('[#name '..tool.tag(ppn)..' .{,2}? ( #POS=NNP+ | #W )+]')

-- Reconnaitre une question (pas utile vu que l'utilisateur n'utilise pas de ponct)
main:pattern('['..tool.tag(quest)..' (#question)? .*? "?"?]')

-- Reconnaitre fin de discussion
main:pattern('['..tool.tag(exit)..tool.tag(fin)..' ]')

-- Qestion sur la Date de naissance
main:pattern([[
	[#Qbirth 
		"quand" #pnominal #POS=VRB .*? "ne" |
		"quand" #POS=VRB "ne" #pnominal .*? |
		#dateN
	]
]])

-- Qestion sur le lieu de naissance
main:pattern([[
	[#Qbirthplace 
		"ou" #pnominal #POS=VRB .*? "ne" |
		"ou" #POS=VRB "ne" #pnominal .*? |
		#lieuN
	]
]])

-- Qestion sur la formation
main:pattern([[
	[#Qformation 
		"quelle" "formation" #pnominal #POS=VRB .*? |
		"quelle" "formation" #POS=VRB .*? #pnominal |
		#formation |
		"f"
	]
]])

main:pattern('[#Qstatut "qui" #POS=VRB '..tool.tag(ppn)..' ]')

main:pattern('[#negation '..tool.tag(neg)..' .{,3}? "pas"]')
main:pattern('[#Qcreateurs "qui" .{,3}? /createurs?/]')


tags = {
	["#Qbirthplace"] = "green",
	["#Qbirth"] = "green",
	["#Qstatut"] = "green",
	["#Qformation"] = "green",
	["#Qcreateurs"] = "green",
	
	["#negation"] = "red",
	["#birth"] = "red",
	["#name"] = "blue",
	--["#lieu"] = "red",
	["#date"] = "magenta",
	["#birthplace"] = "green",

	[tool.tag(exit)] = "yellow",
	[tool.tag(quest)] = "magenta",
}