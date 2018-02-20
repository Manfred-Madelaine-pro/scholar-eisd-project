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
help = "help"


-- attributs d'un Politicien dans la bdd
db_name   = "name"
db_parti  = "parti"
db_birth  = "birth"
db_death  = "death"
db_fname  = "firstname"
db_forma  = "formation"
db_birthp = "birthplace"

-- hors de la bdd
hdb_status = "statut"
hdb_createurs = "createurs"

-- grammaire
gram_sen = "gram_sen"
gram_doubleQ = "question_double"

-- Liste d'elements
l_sujets = {ppn, user, tutoiement, fin, tool.qtag(help)}
l_attributs = {db_birth, db_birthp, db_forma, hdb_status, hdb_createurs, db_parti}
l_et = {"et", "ainsi que"}
l_confirm = {"oui", "exact", "bien", "confirme"}
l_infirm = {"non", "pas"}

l_tutoiement = {"tu", "te", "t'", "tes", "ton", "toi"}
l_user = {"je", "moi", "m'", "mes", "mon"}
l_dev = {"Manfred MadlnT", "Cedrick RibeT", "Hugo BommarT", "Laos GalmnT"}
l_fin = {"bye", "au revoir", "quit","ciao", "adieu","bye-bye", "à une prochaine fois"}

local f_data = "data/"



function main:lexicon(...)
	return self:add(dark.lexicon(...))
end


-- Création d'un lexique ou chargement d'un lexique existant
tool.create_lex(f_data)

main:lexicon("#day", {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"})

main:lexicon("#dateN", {"date de naissance"})
main:lexicon("#lieuN", {"lieu de naissance", "Lieu de naissance", "où", "ou"})
main:lexicon("#formation", {"formation"})
main:lexicon(tool.tag(tutoiement), l_tutoiement)
main:lexicon(tool.tag(user), l_user)
main:lexicon("#AND", l_et)
main:lexicon("#SEP", {".",";", "!", "?"})
-- vouvoiement ?
main:lexicon("#question", {"qui", "quelle", "quoi", "comment", "ou", "quand"})
main:lexicon("#neg", {"non","no","ne","n'","pas","sauf","excepte","sans"})


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



	----- Analyse d'une question -----

-- Reconnaitre fin de discussion

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
main:pattern('[#Qparti /quels?/ .{,3}? /partis?/]')

main:pattern('['..tool.tag(tool.qtag(help))..' "$" "help" ]')

-- Reconnaissance de la grammaire dans une question
main:pattern('[#gram_sujet '..tool.list_tags(l_sujets)..']')
main:pattern('[#gram_info '..tool.list_tags(l_attributs, true)..']')
main:pattern('[#gram_elm #neg | #gram_sujet | #gram_info ]')
main:pattern('['..tool.tag(gram_sen)..' "(" .*? ")"  ]')

main:pattern('['..tool.tag(gram_doubleQ)..' "(" .*? ")"  ]')

--main:pattern('[#gram_quest #gram_quest #AND #gram_sen | #gram_sen ]')



m_tag = {
	["#Qbirthplace"] = "green",
	["#Qbirth"] = "green",
	["#Qstatut"] = "green",
	["#Qformation"] = "green",
	["#Qcreateurs"] = "green",
	["#Qhelp"] = "green",
	["#Qparti"] = "red",
	
	["#negation"] = "red",

	["#name"] = "blue",
	--["#lieu"] = "red",
	["#date"] = "magenta",
	["#birthplace"] = "green",

}

test = {
	
	["#neg"] = "green",

	--["#gram_info"] = "magenta",
	--["#gram_sujet"] = "blue",
	--["#gram_elm"] = "green",
	--["#gram_quest"] = "green",
	[tool.tag(gram_sen)] = "red",
	["#AND"] = "yellow",

	--["#lieu"] = "red",
}

tags = m_tag