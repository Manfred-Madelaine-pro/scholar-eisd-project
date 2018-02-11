--[[
	Natural Language Understanding

	Gère les lexiques et les paternes
]]--


local tool = require 'tool'


-- Tag names
fin = "fin"
exit = "end"
place = "lieu"
month = "month"
quest = "quest"
temps = "temps"
ppn = "pnominal" -- pronom personel nom inal

-- Tags pour les questions
q_lieu = "Qlieu"
q_birth = "Qbirth"
q_formation = "Qformation"

-- ttributs d'un Politicien
pol_name = "name"
pol_birth = "birth"
pol_death = "death"
pol_fname = "firstname"
pol_formation = "formation"
pol_birthplace = "birthplace"


local f_data = "data/"


function main:lexicon(...)
	return self:add(dark.lexicon(...))
end


-- Création d'un lexique ou chargement d'un lexique existant
tool.create_lex(f_data)
main:lexicon("#day", {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"})
main:lexicon("#dateN", {"date de naissance", "naissance"})
main:lexicon("#lieuN", {"lieu de naissance", "où", "ou"})
main:lexicon("#formation", {"formation"})


-- Paterne avec expressions régulières 
main:pattern('[#year /^%d%d%d%d$/]')

-- Paterne pour une date   A optimiser !!
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

-- Reconnaitre une question (pas utile vu que l'utilisateur n'utilise pas de ponct)
main:pattern('['..tool.get_tag(quest)..' .*? "?"]')

-- Reconnaitre fin de discussion
main:pattern('['..tool.get_tag(exit)..tool.get_tag(fin)..' ]')


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
	[#Qlieu 
		"ou" #pnominal #POS=VRB .*? "ne" |
		"ou" #POS=VRB "ne" #pnominal .*? |
		#lieuN
	]
]])

-- Qestion sur la formation
main:pattern([[
	[#Qformation 
		"quelle" "formation" #pnominal #POS=VRB .*? |
		"quelle" "formation" #POS=VRB .*? #pnominal |
		#formation
	]
]])


--main:pattern('[#Qbirth "quand" '..tool.get_tag(ppn)..' #POS=VRB .*? "ne" ]')
--main:pattern('[#Qbirth "quand" #POS=VRB "ne" '..tool.get_tag(ppn)..' .*? ]')

tags = {
	["#birth"] = "red",
	["#Qbirth"] = "yellow",
	["#Qlieu"] = "green",
	["#name"] = "blue",
	[tool.get_tag(exit)] = "yellow",
	--["#lieu"] = "red",
	["#date"] = "magenta",
	[tool.get_tag(quest)] = "magenta",
	["#birthplace"] = "green",
}