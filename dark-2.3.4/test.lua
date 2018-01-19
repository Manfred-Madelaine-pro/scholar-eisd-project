-- Création d'un pipeline pour DARK
local main = dark.pipeline()
main:basic()


-- Chargement du modèle statistique entraîné sur le français 
main:model("model-2.3.0/postag-fr")


-- Création d'un lexique ou chargement d'un lexique existant
main:lexicon("#PRENOM", {"Géronte", "Alain", "Nicolas", "Dominique", "Jacqueline","Léandre","Lucas","Lucinde","Martine","Perrin","Sganarelle","Thibaut","Valère"})
main:lexicon("#CHIFFRES", {"un","deux","trois","quatre","cinq","six","sept","huit","neuf","dix"})
main:lexicon("#JOURS", {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"})

main:lexicon("#FAMILLE", "famille.txt")
main:lexicon("#MOIS", "mois.txt")
main:lexicon("#LIEU", "lieu.txt")

-- Création de patterns en LUA, soit sur plusieurs lignes pour gagner
-- en visibilité, soit sur une seule ligne. La capture se fait avec
-- les crochets, l'étiquette à afficher est précédée de # : #word

-- Pattern avec expressions régulières (pas de coordination possible)
main:pattern('[#WORD /^%a+$/ ]')
main:pattern('[#PONCT /%p/ ]')
main:pattern('[#ANNEE /^%d%d%d%d$/]')

-- Pattern avec patron de séquence
main:pattern([[
	[#FILIATION
		#FAMILLE #PRENOM
	]
]])

main:pattern([[
	[#NAME
		#PRENOM .{,2}? ( #POS=NNP+ | #W )+
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

-- Pattern pour une date
main:pattern([[
	[#DATE 
		( #JOURS ) ( #CHIFFRES | /%d+/ ) ( #MOIS ) #ANNEE |
		( #JOURS ) ( #CHIFFRES | /%d+/ ) ( #MOIS ) |
		( #CHIFFRES | /%d+/ ) ( #MOIS )  #ANNEE |
		( #CHIFFRES | /%d+/ ) ( #MOIS ) |
		( #JOURS ) /%d+/ |
		( #MOIS )  #ANNEE
		/%d+/ "/" /%d+/ "/" /%d+/
	]
]])


main:pattern("[#DUREE ( #CHIFFRES | /%d+/ ) ( /mois%p?/ | /jours%p?/ ) ]")


--[[
	Sélection des étiquettes voulues, attribution d'une couleur (black,
	blue, cyan, green, magenta, red, white, yellow) pour affichage sur
	le terminal ou valeur "true" si redirection vers un fichier de
	sortie (obligatoire pour éviter de copier les caractères de contrôle)
]]-- 

local tags = {
	--["#MOIS"] = "red",
	--["#CHIFFRES"] = "red",
	["#NAME"] = "blue",
	["#LIEU"] = "red",
	["#FAMILLE"] = "yellow",
	--["#DUREE"] = "magenta",
	["#DATE"] = "magenta",
	--["#POS=VRB"] = "green",
	["#FILIATION"] = "green"
}


function process(sen)
	sen = sen:gsub("%p", " %0 ")
	local seq = dark.sequence(sen)
	main(seq)
	print(seq:tostring(tags))
end


function split_en(line)
	for sen in line:gmatch("(.-[.?!])") do
		process(sen)
	end
end


-- Lecture du fichier
function read_corpus(corpus_path)
	for f in os.dir(corpus_path) do
		for line in io.lines(corpus_path.."/"..f) do
			if line ~= "" then
				split_en(line)
			end
		end
	end
end


function process_answer()
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