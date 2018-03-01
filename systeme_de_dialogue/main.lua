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


-- Création des paternes et des lexiques
dofile("nlu.lua")

-- Lancer une conversation avec le bot
bot.start(l_attributs)