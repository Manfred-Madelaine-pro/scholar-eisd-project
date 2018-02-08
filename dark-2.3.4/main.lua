local tst = {}

-- importation des modules
local bot = require 'bot'
local lp = require 'line_processing'


main = dark.pipeline()
main:basic()

-- Chargement du modèle statistique entraîné sur le français 
main:model("model-2.3.0/postag-fr")

-- Création des paternes et des lexiques
dofile("nlu.lua")


local f_test = "../test"


lp.read_corpus(f_test)
--bot.main()
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
