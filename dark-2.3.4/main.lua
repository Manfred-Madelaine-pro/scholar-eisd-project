local tst = {}

-- Création d'un pipeline pour DARK
main = dark.pipeline()
main:basic()

-- Chargement du modèle statistique entraîné sur le français 
main:model("model-2.3.0/postag-fr")

-- importation d'un module
local bot = require 'bot'
local tool = require 'tool'
local lp = require 'line_processing'

local f_data = "data/"
local f_bios = "../eisd-bios"
local f_test = "../test-bios"


-- Tag names
fin = "fin"
place = "lieu"
month = "month"
temps = "temps"
ppn = "pnominal" -- pronom personel nominal


-- Création d'un lexique ou chargement d'un lexique existant
main:lexicon("#day", {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"})
tool.create_lex(f_data)


-- Pattern avec expressions régulières 
main:pattern('[#year /^%d%d%d%d$/]')

-- Pattern pour une date   A optimiser !!
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
main:pattern(' "ne" .*? "a" [#birthplace '..tool.get_tag(place)..']')

-- Reconnaitre un nom
main:pattern('[#name '..tool.get_tag(ppn)..' .{,2}? ( #POS=NNP+ | #W )+]')

-- Reconnaitre une question
main:pattern('[#quest .*? "?"]')

-- Reconnaitre une affirmation
main:pattern('[#affirm .*? "!"]')

-- Reconnaitre fin de discussion
main:pattern('[#end '..tool.get_tag(fin)..' ]')

tags = {
	["#birth"] = "red",
	["#name"] = "blue",
	--["#lieu"] = "red",
	--["#date"] = "magenta",
	["#birthplace"] = "green",
}


--lp.read_corpus(f_test)
bot.main()
--tool.save_db(db, "database")


return tst


--lien entre un politicien et ses param
--[[
	main:pattern('[#hauteur #monument 'mesure #mesure']')

	> #POS=NNP ) #W
	"de"? présent ou non
	. token poubelle
	.*? lasy prendre le truc le plus petit possible 
	.{0,2}? limiter le nb (.{,2}?)
	regarder 2 choses sur un mot
	look after sur le token qui est avant : >( #POS=NNP ) #W
	look aroud pas très utile look before #pos=nnp <( #W )



	
txt = "le mardi 2 janvier \n\
le mardi 2 \n\
le mardi 2 janvier 1993 \n\
le deux janvier \n\
en mai 1995 \n\
né le 01/01/1995 \n\
né le 01 / 01 / 1995 \n\
le 12 août 1995 \n\
le 1er janvier \n\
le premier janvier \
\n"
]]
