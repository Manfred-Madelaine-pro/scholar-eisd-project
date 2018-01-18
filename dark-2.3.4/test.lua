-- Création d'un pipeline pour DARK
local main = dark.pipeline()

-- Chargement du modèle statistique entraîné sur le français 
main:model("model-2.3.0/postag-fr")


-- Création d'un lexique ou chargement d'un lexique existant
main:lexicon("#PERSONNE", {"Géronte","Jacqueline","Léandre","Lucas","Lucinde","Martine","Perrin","Sganarelle","Thibaut","Valère"})
main:lexicon("#CHIFFRES", {"un","deux","trois","quatre","cinq","six","sept","huit","neuf","dix"})
main:lexicon("#JOURS", {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"})

main:lexicon("#FAMILLE", "famille.txt")
main:lexicon("#METIER", "metiers.txt")
main:lexicon("#MOIS", "mois.txt")
main:lexicon("#LIEU", "lieu.txt")

-- Création de patterns en LUA, soit sur plusieurs lignes pour gagner
-- en visibilité, soit sur une seule ligne. La capture se fait avec
-- les crochets, l'étiquette à afficher est précédée de # : #word

-- Pattern avec expressions régulières (pas de coordination possible)
main:pattern('[#WORD /^%a+$/ ]')
main:pattern('[#PONCT /%p/ ]')

-- Pattern avec patron de séquence
main:pattern([[
	[#FILIATION
		#FAMILLE #PERSONNE
	]
]])

-- Pattern pour une date
main:pattern([[
	[#DATE 
		( #JOURS ) ( #CHIFFRES | /%d+/ ) ( #MOIS ) ( /%d+/ ) |
		( #JOURS ) ( #CHIFFRES | /%d+/ ) ( #MOIS ) |
		( #CHIFFRES | /%d+/ ) ( #MOIS ) ( /%d+/ ) |
		( #CHIFFRES | /%d+/ ) ( #MOIS ) |
		( #MOIS ) ( #CHIFFRES | /%d+/ ) |
		( #JOURS ) ( #CHIFFRES | /%d+/ )
	]
]])


main:pattern("[#DUREE ( #CHIFFRES | /%d+/ ) ( /mois%p?/ | /jours%p?/ ) ]")

main:pattern('#POS=PRO #POS=VRB pris [#CHEMICAL /%a/]')

-- Sélection des étiquettes voulues, attribution d'une couleur (black,
-- blue, cyan, green, magenta, red, white, yellow) pour affichage sur
-- le terminal ou valeur "true" si redirection vers un fichier de
-- sortie (obligatoire pour éviter de copier les caractères de
-- contrôle)

local tags = {
	["#METIER"] = "red",
	--["#MOIS"] = "red",
	--["#CHIFFRES"] = "red",
	["#PERSONNE"] = "blue",
	["#FAMILLE"] = "yellow",
	["#DUREE"] = "magenta",
	["#DATE"] = "magenta",
	["#POS=VRB"] = "green",
	["#FILIATION"] = "green"
}


-- Traitement des lignes du fichier
for line in io.lines() do
		-- tokenization
	line = line:gsub("%p", " %1 ")
        
        -- Toutes les étiquettes
	--print(main(line))
        -- Uniquement les étiquettes voulues
	print(main(line):tostring(tags))
end
