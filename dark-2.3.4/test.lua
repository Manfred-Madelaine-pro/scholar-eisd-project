local tst = {}

-- Création d'un pipeline pour DARK
local main = dark.pipeline()
main:basic()


-- importation d'un module
local seq_pocess = require 'seqProcessing'
local eva = require 'eva'
--local bot = require 'main'


-- Tag names
month = "MONTH"
place = "lieu"
temps = "temps"
ppn = "pnominal" -- pronom personel nominal


file = "data/"


-- Chargement du modèle statistique entraîné sur le français 
main:model("model-2.3.0/postag-fr")

-- Création d'un lexique ou chargement d'un lexique existant
main:lexicon("#DIGIT", {"un","deux","trois","quatre","cinq","six","sept","huit","neuf","dix"})
main:lexicon("#JOURS", {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"})

main:lexicon("#monument", {"Tour Eiffel", "Notre Dame"})
main:lexicon("#unite",    {"metre"})
main:pattern("[#valeur #d]")
main:pattern("[#mesure #valeur #unite]")

main:pattern("[#hauteur #monument 'mesure' #mesure]")
main:pattern('[#year /^%d%d%d%d$/]')

-- Renvoie un tag
function get_tag(tag)
	return "#"..tag
end


-- Cree un lexique
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


-- Création de patterns en LUA, soit sur plusieurs lignes pour gagner
-- en visibilité, soit sur une seule ligne. La capture se fait avec
-- les crochets, l'étiquette à afficher est précédée de # : #word

-- Pattern avec expressions régulières 
main:pattern('[#PONCT /%p/ ]')
main:pattern('[#YEAR /^%d%d%d%d$/]')
main:pattern("[#DUREE ( #DIGIT | /%d+/ )  /"..get_tag(temps).."s?/  ]")


--[[ TAGS
les tags commencent par le caractère '#' et sont composés de caractères
alphanumériques, du trait d'union, du tiret bas et du symbole d'égalitée.
]]

-- Pattern pour une date
-- A optimiser !!
main:pattern([[
	[#DATE 
		( #JOURS ) ( #DIGIT | /%d+/ ) ( #MONTH ) #YEAR |
		( #JOURS ) ( #DIGIT | /%d+/ ) ( #MONTH ) |
		( #DIGIT | /%d+/ ) ( #MONTH )  #YEAR |
		( #DIGIT | /%d+/ ) ( #MONTH ) |
		( #JOURS ) /%d+/ |
		( #MONTH )  #YEAR
		/%d+/ "/" /%d+/ "/" /%d+/
		#d "/" #d "/" #d
	]
]])



-- Date de naissance
main:pattern(' "né" .*? "le" [#BIRTH #DATE]')

-- Lieu de naissance
main:pattern(' "né" .*? "à" [#BIRTHPLACE '..get_tag(place)..']')

-- Reconnaitre un nom
main:pattern('[#NAME '..get_tag(ppn)..' .{,2}? ( #POS=NNP+ | #W )+]')


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


--[[
	black, red, green, yellow, blue, magenta, cyan, white
]]-- 

--[[
local tags = {
	--["#MONTH"] = "red",
	["#BIRTH"] = "red",
	["#NAME"] = "blue",
	[get_tag(temps)] = "yellow",
	[get_tag(place)] = "red",
	--[get_tag(ppn)] = "red",
	--["#DUREE"] = "magenta",
	["#DATE"] = "magenta",
	--["#POS=VRB"] = "green",
	["#BIRTHPLACE"] = "green",
	["#FILIATION"] = "green",
}]]


local tags = {
	["#monument"] = "red",
	["#unite"]    = "red",
	--["#valeur"]   = "red",
	["#mesure"]   = "green",
	["#hauteur"]  = "yellow",
	--["#year"] = "magenta",
	["#BIRTH"] = "red",
	["#NAME"] = "blue",
	["#temps"] = "yellow",
	--["#lieu"] = "red",
	--["#DATE"] = "magenta",
	["#BIRTHPLACE"] = "green",
	["#DUREE"] = "green",
	["#FILIATION"] = "green",
}


function process(sen, db)
	-- ajouter un espace de part et d'autre d'une ponctuation
	sen = sen:gsub("%p", " %0 ")

	local seq = dark.sequence(sen)
	main(seq)
	print(seq:tostring(tags))
	--eva.t2(seq, db, "#hauteur")
	--eva.t3(seq, db, "#NAME")
	return seq_pocess.analyse_seq(seq)	
end

-- faire une fonction de normalisation pour:
-- heuteur, date 
-- afin de pouvoir faire des conersions
--conversion ides données pour rentrer dans la db et avoir un unique type
-- conversion pour afficher comme ce que l'utilisateur veut

function split_sentence(line, db)
	for sen in line:gmatch("(.-[.?!])") do
		process(sen, db)
	end
end


-- Lecture des fichiers du corpus
function read_corpus(corpus_path, db)
	for f in os.dir(corpus_path) do
		for line in io.lines(corpus_path.."/"..f) do
			if line ~= "" then
				split_sentence(line, db)
			end
		end
	end
end


-- Analyse la phrase du l'utilisateur
function sentence_processing()
	-- Traitement des lignes du fichier
	for line in io.lines() do
		-- tokenization
		line = line:gsub("%p", " %1 ")
		print(main(line):tostring(tags))
	end
end



-- Analyse la phrase du l'utilisateur
function tst.sentence_processing(line)
	-- Traitement des lignes du fichier
	line = line:gsub("%p", " %1 ")
	local seq = dark.sequence(line)
	print(main(seq):tostring(tags))
	split_sentence(line, {})
	print(main(line))
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

--read_corpus(f_test, db)
--sentence_processing()
--bot.main()
--save_db( db )


return tst
