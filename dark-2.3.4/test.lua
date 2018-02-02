local tst = {}

-- Création d'un pipeline pour DARK
local main = dark.pipeline()
main:basic()

-- Chargement du modèle statistique entraîné sur le français 
main:model("model-2.3.0/postag-fr")

-- importation d'un module
local tool = require 'tool'
local lp = require 'line_processing'


-- Tag names
month = "month"
place = "lieu"
temps = "temps"
ppn = "pnominal" -- pronom personel nominal

file = "data/"

-- Création d'un lexique ou chargement d'un lexique existant
main:lexicon("#day", {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"})
tool.create_lex(main)


-- Pattern avec expressions régulières 
main:pattern('[#year /^%d%d%d%d$/]')

-- Pattern pour une date   A optimiser !!
main:pattern([[
	[#DATE 
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
main:pattern(' "ne" .*? "le" [#BIRTH #DATE]')

-- Lieu de naissance
main:pattern(' "ne" .*? "a" [#BIRTHPLACE '..tool.get_tag(place)..']')

-- Reconnaitre un nom
main:pattern('[#NAME '..tool.get_tag(ppn)..' .{,2}? ( #POS=NNP+ | #W )+]')

local tags = {
	["#BIRTH"] = "red",
	["#NAME"] = "blue",
	--["#lieu"] = "red",
	--["#DATE"] = "magenta",
	["#BIRTHPLACE"] = "green",
}

f_bios = "../eisd-bios"
f_test = "../test-bios"

local db = {}

lp.read_corpus(main, f_test, tags)
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
]]
