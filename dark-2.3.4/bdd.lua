local tst = {}
local tool = require 'tool'
local lp = require 'line_processing'


local main = dark.pipeline()
main:basic()

ppn = "pnominal"
place = "lieu"

file = "data/"


main:lexicon("#mois", {"janvier", "fevrier", "mars", "avril", "mai", "juin", "juillet", "aout", "septembre", "octobre", "novembre", "decembre"})
tool.create_lex(main)

main:pattern('[#annee /^%d%d%d%d$/]')

main:pattern('[#date #d #mois #annee]')

main:pattern('("ne"|"nee"|"nait") .*? "le" [#dateNaissance #date]')
main:pattern('("ne"|"nee"|"nait") .*? "a" [#lieuNaissance' ..tool.get_tag(place).. ']')

main:pattern('[#prenom'..tool.get_tag(ppn)..'] [#nom .{,2}? ( #POS=NNP+ | #W )+]')

main:pattern('("fils"|"fille") .*? "de" [#prenomPere #prenom] [#nomPere #nom]')

local tags = {
	["#dateNaissance"] = "yellow",
	["#lieuNaissance"] = "green",
	["#nom"] = "blue",
	["#prenom"] = "blue",
	["#prenomPere"] = "red",
}

f_test = "../test"
lp.read_corpus(main, f_test, tags)

return tst
