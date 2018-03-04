--[[
	Natural Language Understanding

	Gère les lexiques et les paternes
]]--


-- importation des modules
local t = require 'tool'


main = dark.pipeline()
main:basic()

-- Chargement du modèle statistique entraîné sur le français 
main:model("postag-fr")


-- nom des tags
neg   = "neg"
fin   = "fin"
exit  = "end"
user  = "user"
help  = "help"
life  = "life"
name  = "name"
place = "lieu"
ppn   = "pnominal" -- pronom personel nominal
hist  = "historique"
date_sec = "date_sec"
tutoiement = "tutoiement"


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

-- attribut hors de la bdd
hdb_createurs = "createurs"

-- grammaire
gram_sous_quest = "Xquestion"
gram_Qdouble    = "question_double"
gram_Qmult  	= "question_multiple"


-- Liste d'elements
l_sujets = {
	name, user, tutoiement, fin, 
	t.qtag(help), life, hist, 
}

l_attributs = {
	db_birth, db_birthp, db_forma, 
	hdb_createurs, db_parti, 
	db_bord, db_prof, date_sec, 
	db_death
}

att_secondaires = {	date_sec}


l_hist = { "historique"}
l_forma= {"formations?"}
l_prof = {"professions?"}
-- TODO add les ponctuations
l_et   = {"et", "ainsi que"}
l_birth= {"date de naissance"}
l_bord = {"bord politique", "bord"}
l_place= {"lieu de naissance", "ou"}
l_user = {"je", "m'", "mes", "mon", "miens"}
l_life = {"univers", "vie", "la grande question sur"}
l_bac  = { "bac", "baccalaureat", "diplome", "licence"}
l_neg  = {"non","no","ne","n'","pas","sauf","excepte","sans"}
l_fin  = {"bye", "au revoir", "quit", "ciao", "adieu","bye-bye"}
l_death= {"morte?", "decedee?", "vivante?", "meurt", "date de deces"}
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
t.new_lex(ppn, f_data)


main:lexicon("#AND", l_et)
main:lexicon("#neg", l_neg)
main:lexicon("#42",  l_life)
main:lexicon("#dateN", l_birth)
main:lexicon("#lieuN",  l_place)
main:lexicon("#formation", l_forma)

main:lexicon(t.tag(fin), l_fin)
main:lexicon(t.tag(hist), l_hist)
main:lexicon(t.tag(user), l_user)
main:lexicon(t.tag(nd_forma), l_bac)
main:lexicon(t.tag(t.qtag(db_bord)), l_bord)
main:lexicon(t.tag(t.qtag(db_prof)), l_prof)
main:lexicon(t.tag(tutoiement), l_tutoiement)
main:lexicon(t.tag(t.qtag(db_death)), l_death)


	----- Analyse d'une question -----

-- Qestion sur la Date de naissance
main:pattern([[
	[]]..t.tag(t.qtag(db_birth))..[[ 
		"quand" #pnominal #POS=VRB .*? "ne" |
		"quand" #POS=VRB "ne" #pnominal .*? |
		#dateN
	]
]])

-- Qestion sur le lieu de naissance
main:pattern([[
	[]]..t.tag(t.qtag(db_birthp))..[[ 
		"ou" #pnominal #POS=VRB .*? "ne" |
		"ou" #POS=VRB "ne" #pnominal .*? |
		#lieuN
	]
]])

-- Qestion sur la formation
main:pattern([[
	[]]..t.tag(name)..[[ 
		]]..t.tag(ppn)..[[ ]]..t.tag(ppn)..[[ |
		]]..t.tag(ppn)..[[
	]
]])

-- Qestion sur la formation
main:pattern([[
	[]]..t.tag(t.qtag(db_forma))..[[ 
		/quelles?/ /formations?/ #pnominal #POS=VRB .*? |
		/quelles?/ /formations?/ #POS=VRB .*? #pnominal |
		#formation |
	]
]])

main:pattern('['..t.tag(t.qtag(help))..' "$" "help" ]')

main:pattern('[#negation '..t.tag(neg)..' .{,3}? "pas"]')

--main:pattern('['..t.tag(name)..' '..t.tag(ppn)..' '..t.tag(ppn)..' | '..t.tag(ppn)..'  ]')

main:pattern('"quelle" .{,3}? "reponse" .{,3}? ['..t.tag(life)..' #42 ]')

main:pattern('['..t.tag(t.qtag(db_parti))..' /quels?/ .{,3}? /partis?/ ]')

main:pattern('"qui" .{,3}? ['..t.tag(t.qtag(hdb_createurs))..' /createurs?/ ]')

main:pattern(' "quand" .{,8}? '..'['..t.tag(t.qtag(date_sec))..t.tag(nd_forma)..' ]')


	---- Reconnaissance de la grammaire dans une question ----

main:pattern('[#gram_sujet '..t.list_tags(l_sujets)..']')

main:pattern('[#gram_info '..t.list_tags(l_attributs, true)..']')

main:pattern('[#gram_elm #neg | #gram_sujet | #gram_info ]')


-- Qestions multiples
main:pattern([[
	[]]..t.tag(gram_Qdouble)..[[ 
		[]]..t.tag(gram_sous_quest)..[[  
			((.{,4}? #gram_elm .{,4}? )+ ){2,4} 
		] 
		(#AND 
		[]]..t.tag(gram_sous_quest)..[[  
			((.{,4}? #gram_elm .{,4}? )+ ){2,4} 
		] )+
	]
]])

-- non operationnel
main:pattern('['..t.tag(gram_Qmult)..' ('..t.tag(gram_Qdouble)..'){2,4} ]')



tags = {
	["#Qparti"] = "red",
	["#Qhelp"] = "green",
	["#Qbirth"] = "green",
	["#Qdeath"] = "green",
	["#Qstatut"] = "green",
	["#Qformation"]="green",
	["#Qcreateurs"]= "green",
	["#Qbirthplace"]= "green",

	["#AND"] = "yellow",
	["#negation"]= "red",
	[t.tag(name)]= "red",
	[t.tag(life)]= "red",
	[t.tag(user)]= "red",
	[t.tag(hist)]= "red",
	[t.tag(gram_Qdouble)] = "cyan",
	--TODO
	[t.tag(gram_Qmult)] = "cyan",
	[t.tag(t.qtag(db_bord))] = "red",
	[t.tag(t.qtag(db_prof))] = "red",
	[t.tag(gram_sous_quest)]="magenta",
	[t.tag(t.qtag(date_sec))]="magenta",
}