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


-- nom des tags
neg   = "neg"
fin   = "fin"
exit  = "end"
user  = "user"
help  = "help"
life  = "life"
place = "lieu"
ppn   = "pnominal" -- pronom personel nominal
hist  = "historique"
tutoiement = "tutoiement"

date_sec = "date_sec"

-- attributs d'un Politicien dans la bdd
db_bord   = "bord"
db_name   = "name"
db_parti  = "parti"
db_birth  = "birth"
db_death  = "death"
db_fname  = "firstname"
db_forma  = "formation"
db_prof   = "profession"
db_birthp = "birthplace"

-- attributs secondaires d'un Politicien dans la bdd
nd_forma = "secondaire"

-- hors de la bdd
hdb_createurs = "createurs"

-- grammaire
gram_sous_quest = "Xquestion"
gram_Qdouble = "question_double"


-- Liste d'elements
l_sujets = {
	ppn, user, tutoiement, fin, 
	tool.qtag(help), life, hist, 
}

l_attributs = {
	db_birth, db_birthp, db_forma, 
	hdb_createurs, db_parti, 
	db_bord, db_prof, date_sec
}

att_secondaires = {
	date_sec,
}


l_hist = { "historique"}
l_et   = {"et", "ainsi que"}
l_bord = {"bord politique", "bord"}
l_prof = {"profession", "professions"}
l_user = {"je", "m'", "mes", "mon", "miens"}
l_life = {"univers","vie", "la grande question sur"}
l_bac  = { "bac", "baccalaureat", "diplome", "licence"}
l_fin  = {"bye", "au revoir", "quit", "ciao", "adieu","bye-bye"}
l_dev  = {"Manfred MadlnT", "Cedrick RibeT", "Hugo BommarT", "Laos GalmnT"}

l_tutoiement = {
	"tu", "t'", "tes", "ton", "toi", 
	"chatbot", "systeme de dialogue", string.lower(BOT_NAME)
}


local f_data = "data/"


function main:lexicon(...)
	return self:add(dark.lexicon(...))
end


-- Création d'un lexique ou chargement d'un lexique existant
tool.create_lex(f_data)

main:lexicon("#AND", l_et)
main:lexicon("#42", l_life)
main:lexicon(tool.tag(fin), l_fin)
main:lexicon(tool.tag(hist), l_hist)
main:lexicon(tool.tag(user), l_user)
main:lexicon(tool.tag(nd_forma), l_bac)
main:lexicon(tool.tag(tutoiement), l_tutoiement)
main:lexicon(tool.tag(tool.qtag(db_bord)), l_bord)
main:lexicon(tool.tag(tool.qtag(db_prof)), l_prof)

main:lexicon("#neg", {"non","no","ne","n'","pas","sauf","excepte","sans"})
main:lexicon("#lieuN", {"lieu de naissance", "ou"})
main:lexicon("#dateN", {"date de naissance"})
main:lexicon("#formation", {"formation", "formations"})


	----- Analyse d'une question -----

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
		/quelles?/ /formations?/ #pnominal #POS=VRB .*? |
		/quelles?/ /formations?/ #POS=VRB .*? #pnominal |
		#formation |
		"f"
	]
]])

main:pattern('"quelle" .{,3}? "reponse" .{,3}? ['..tool.tag(life)..' #42 ]')

main:pattern('['..tool.tag(tool.qtag(help))..' "$" "help" ]')

main:pattern('[#negation '..tool.tag(neg)..' .{,3}? "pas"]')

main:pattern(' "quand" .{,8}? '..'['..tool.tag(tool.qtag(date_sec))..tool.tag(nd_forma)..' ]')

main:pattern('"qui" .{,3}? [#Qcreateurs /createurs?/ ]')

main:pattern('[#Qparti /quels?/ .{,3}? /partis?/ ]')


	---- Reconnaissance de la grammaire dans une question ----

main:pattern('[#gram_info '..tool.list_tags(l_attributs, true)..']')

main:pattern('[#gram_sujet '..tool.list_tags(l_sujets)..']')

main:pattern('[#gram_elm #neg | #gram_sujet | #gram_info ]')


-- Qestions multiples
main:pattern([[
	[]]..tool.tag(gram_Qdouble)..[[ 
		[]]..tool.tag(gram_sous_quest)..[[  
			((.{,4}? #gram_sujet .{,4}? )+ | (.{,4}? #gram_info .{,4}? )+ ){2,4} 
		] 
		#AND 
		[]]..tool.tag(gram_sous_quest)..[[  
			((.{,4}? #gram_sujet .{,4}? )+ | (.{,4}? #gram_info .{,4}? )+ ){2,4} 
		]
	]
]])


tags = {
	["#Qparti"] = "red",
	["#Qhelp"] = "green",
	["#Qbirth"] = "green",
	["#Qstatut"] = "green",
	["#Qformation"]="green",
	["#Qcreateurs"]= "green",
	["#Qbirthplace"]= "green",

	["#AND"] = "yellow",
	["#negation"] = "red",
	[tool.tag(life)]= "red",
	[tool.tag(user)]= "red",
	[tool.tag(hist)]="magenta",
	--[tool.tag(nd_forma)] = "red",
	[tool.tag(gram_Qdouble)] = "red",
	[tool.tag(gram_sous_quest)]="magenta",
	[tool.tag(tool.qtag(db_bord))] = "red",
	[tool.tag(tool.qtag(db_prof))] = "red",
	[tool.tag(tool.qtag(date_sec))]="magenta",
}