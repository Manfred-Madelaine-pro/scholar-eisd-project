-- Création d'un pipeline pour DARK
local main = dark.pipeline()
main:basic()


-- importation d'un module
local struct = require 'structure'


-- Chargement du modèle statistique entraîné sur le français 
main:model("model-2.3.0/postag-fr")


-- Création d'un lexique ou chargement d'un lexique existant
main:lexicon("#FIRSTNAME", {"Jean - Luc", "Alain", "Nicolas", "Dominique", "Jacqueline","Léandre","Lucas","Lucinde","Martine","Perrin","Sganarelle","Thibaut","Valère"})
main:lexicon("#DIGIT", {"un","deux","trois","quatre","cinq","six","sept","huit","neuf","dix"})
main:lexicon("#JOURS", {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"})

main:lexicon("#FAMILY", "famille.txt")
main:lexicon("#MONTH", "mois.txt")
main:lexicon("#PLACE", "lieu.txt")

-- Création de patterns en LUA, soit sur plusieurs lignes pour gagner
-- en visibilité, soit sur une seule ligne. La capture se fait avec
-- les crochets, l'étiquette à afficher est précédée de # : #word

-- Pattern avec expressions régulières (pas de coordination possible)
main:pattern('[#PONCT /%p/ ]')
main:pattern('[#YEAR /^%d%d%d%d$/]')

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


-- Reconnaitre une filliation
main:pattern([[
	[#FILIATION
		#FAMILY #FIRSTNAME
	]
]])

-- Reconnaitre le lieu de naissance
--[[
main:pattern([[
	[#BIRTHPLACE
		 "né" .*? "à" #PLACE
	]
]]
--)

-- Date de naissance
main:pattern(' "né" .*? "le" [#BIRTH #DATE]')

-- Lieu de naissance
main:pattern(' "né" .*? "à" [#BIRTHPLACE #PLACE]')

-- Reconnaitre un nom
main:pattern([[
	[#NAME
		#FIRSTNAME .{,2}? ( #POS=NNP+ | #W )+
	]
]])

--		>( #POS=NNP ) #W
-- "de"? présent ou non
-- . token poubelle
-- ? 
-- .*? lasy prendre le truc le^plus petit possible 
-- .{0,2}? limiter le nb (.{,2}?)
-- regarder 2 choses sur un mot
-- look after sur le token qui est avant : >( #POS=NNP ) #W
-- look aroud pas très utile look before #pos=nnp <( #W )


main:pattern("[#DUREE ( #DIGIT | /%d+/ ) ( /mois%p?/ | /jours%p?/ ) ]")


--[[
	black, red, green, yellow, blue, magenta, cyan, white
]]-- 

local tags = {
	--["#MONTH"] = "red",
	--["#DIGIT"] = "red",
	["#BIRTH"] = "red",
	["#NAME"] = "blue",
	--["#PLACE"] = "red",
	--["#FAMILY"] = "yellow",
	--["#DUREE"] = "magenta",
	--["#DATE"] = "magenta",
	--["#POS=VRB"] = "green",
	["#BIRTHPLACE"] = "green",
	["#FILIATION"] = "green",
}


function process(sen)
	-- ajouter un espace de part et d'autre d'une ponctuation
	sen = sen:gsub("%p", " %0 ")

	local seq = dark.sequence(sen)
	main(seq)
	print(seq:tostring(tags))

	analyse_seq(seq)	
end


function analyse_seq(seq)
	--seq:dump()
	s = seq:tag2str("#NAME")
	if s[1] ~= nil then
		name = get_elem(seq, "#NAME", "#FIRSTNAME")
		lastname = get_elem(seq, "#NAME", "#POS=NNP")
		birth = get_elem(seq, "#BIRTH", nil)
		death = get_elem(seq, "#DEATH", nil)
		birthplace = get_elem(seq, "#BIRTHPLACE", nil)
		pers = struct.Personne(name, lastname, birth, death, birthplace)
		struct.print_struct(pers)

	else
		print("no")
	end
	--[[
	for index, valeur in ipairs(seq) do
    	print(index, valeur)
    end
    ]]
end


function get_elem(seq, tag_containing, tag_contained)
	if( tag_contained == nil ) then
		return seq:tag2str(tag_containing)[1]
	else 
		return seq:tag2str(tag_containing, tag_contained)[1]
	end
end

function split_sentence(line)
	for sen in line:gmatch("(.-[.?!])") do
		process(sen)
	end
end


-- Lecture des fichiers du corpus
function read_corpus(corpus_path)
	for f in os.dir(corpus_path) do
		for line in io.lines(corpus_path.."/"..f) do
			if line ~= "" then
				split_sentence(line)
			end
		end
	end
end


--[[
	Analyse la phrase du l'utilisateur
]]--
function sentence_processing()
	-- Traitement des lignes du fichier
	for line in io.lines() do
			-- tokenization
		line = line:gsub("%p", " %1 ")
	        
	        -- Toutes les étiquettes
		--print(main(line))
		
	        -- Uniquement les étiquettes voulues
		print(main(line):tostring(tags))
	end
end



f_bios = "../eisd-bios"
f_test = "../test-bios"

read_corpus(f_test)
--sentence_processing()