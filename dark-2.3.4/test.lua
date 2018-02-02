local tst = {}

-- Création d'un pipeline pour DARK
local main = dark.pipeline()
main:basic()

-- Chargement du modèle statistique entraîné sur le français 
main:model("model-2.3.0/postag-fr")

-- importation d'un module
local lp = require 'line_processing'


-- Tag names
month = "month"
place = "lieu"
temps = "temps"
ppn = "pnominal" -- pronom personel nominal

file = "data/"

-- Création d'un lexique ou chargement d'un lexique existant
main:lexicon("#JOURS", {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"})

-- Renvoie un tag
function get_tag(tag)

	return "#"..tag
end

-- Cree l'ensemble des lexiques
function create_lex()
	local function new_lex(tag)
		main:lexicon(get_tag(tag), file..tag..".txt")
	end
	new_lex(place)
	new_lex(temps)
	new_lex(month)
	new_lex(ppn)
end

create_lex()


-- Pattern avec expressions régulières 
main:pattern('[#PONCT /%p/ ]')
main:pattern('[#YEAR /^%d%d%d%d$/]')
--main:pattern("[#DUREE /%d+/  /"..get_tag(temps).."s?/  ]")


-- Pattern pour une date   A optimiser !!
main:pattern([[
	[#DATE 
		#JOURS /%d+/ #month #YEAR |
		#JOURS /%d+/ #month |
		/%d+/ #month  #YEAR |
		/%d+/ #month |
		#JOURS /%d+/ |
		#month #YEAR |
		/%d+/ "/" /%d+/ "/" /%d+/ |
		#d "/" #d "/" #d
	]
]])


-- Date de naissance
main:pattern(' "né" .*? "le" [#BIRTH #DATE]')

-- Lieu de naissance
main:pattern(' "né" .*? "à" [#BIRTHPLACE '..get_tag(place)..']')

-- Reconnaitre un nom
main:pattern('[#NAME '..get_tag(ppn)..' .{,2}? ( #POS=NNP+ | #W )+]')


--[[
	black, red, green, yellow, blue, magenta, cyan, white
]]-- 

local tags = {
	["#BIRTH"] = "red",
	["#NAME"] = "blue",
	--["#lieu"] = "red",
	["#DATE"] = "magenta",
	["#BIRTHPLACE"] = "green",
}


-- Lecture des fichiers du corpus
function read_corpus(main, corpus_path, tags)
	for f in os.dir(corpus_path) do
		for line in io.lines(corpus_path.."/"..f) do
			if line ~= "" then
				lp.split_sentence(main, line, tags)
			end
		end
	end
end

function save_db( db )

	local out_file = io.open("database.lua", "w")
	out_file:write("return ")
	out_file:write(serialize(db))
	out_file:close()


	local db2 = dofile("database.lua")

	print(serialize(db2))
end


f_bios = "../eisd-bios"
f_test = "../test-bios"

local db = {}

read_corpus(main, f_test, tags)
--save_db( db )


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
