local tst = {}
local tool = require 'tool'
local lp = require 'line_processing'


main = dark.pipeline()
main:basic()

-- Tag names
place = "lieu"
ppn = "pnominal"

local f_data = "data/"


main:lexicon("#mois", {"janvier", "fevrier", "mars", "avril", "mai", "juin", "juillet", "aout", "septembre", "octobre", "novembre", "decembre"})
tool.new_lex(ppn, f_data)
tool.new_lex(place, f_data)

main:pattern('[#annee /^%d%d%d%d$/]')

main:pattern('[#date #d #mois #annee]')

main:pattern('("ne"|"nee"|"nait") .*? "le" [#dateNaissance #date]')
main:pattern('("ne"|"nee"|"nait") .*? "a" [#lieuNaissance' ..tool.get_tag(place).. ']')

main:pattern('[#prenom'..tool.get_tag(ppn)..'] [#nom .{,2}? ( #POS=NNP+ | #W )+]')

main:pattern('("fils"|"fille") .{,2}? "de" [#prenomPere #prenom] [#nomPere #nom]')

tags = {
	["#dateNaissance"] = "yellow",
	["#lieuNaissance"] = "green",
	["#nom"] = "blue",
	["#prenom"] = "blue",
	["#prenomPere"] = "red",
}


local f_test = "../test"
lp.read_corpus(f_test)

return tst
