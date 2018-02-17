--[[
			SYSTEME DE DIALOGUE
	
	Projet d'EISD realise par les etudiants:
		@Manfred MadlnT
		@Cedrick RibeT
		@Hugo BommarT
		@Laos GalmnT

	-- Janvier 2018 --
]]--


-- importation des modules
local bot = require 'bot'
local lp = require 'line_processing'


-- Création des paternes et des lexiques
dofile("nlu.lua")


--local f_test = "../test"
--lp.read_corpus(f_test)

-- Lancer une conversation avec le bot
bot.start(l_attributs, true)