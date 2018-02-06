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

local f_data = "data/"

-- Création d'un lexique ou chargement d'un lexique existant
main:lexicon("#day", {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"})
tool.create_lex(f_data)


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

-- Reconnaitre une question
main:pattern('['..tool.get_tag(quest)..' .*? "?"]')

-- Reconnaitre une affirmation
main:pattern('[#affirm .*? "!"]')

-- Reconnaitre fin de discussion
main:pattern('['..tool.get_tag(exit)..tool.get_tag(fin)..' ]')



-- Paternes reconnaissance question


tags = {
	["#birth"] = "red",
	["#name"] = "blue",
	[tool.get_tag(exit)] = "yellow",
	--["#lieu"] = "red",
	["#date"] = "magenta",
	[tool.get_tag(quest)] = "magenta",
	["#birthplace"] = "green",
	["#affirm"] = "green",
}