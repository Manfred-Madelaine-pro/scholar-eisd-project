--[[
			CHAT BOT
	
	Projet d'EISD realise par les etudiants:
		@Manfred MadelaT
		@Cedrick RibeT
		@Hugo BommarT
		@Leo GalmanT

	-- Janvier 2018 --
]]--

local bot = {}

-- importation d'un module
local struct = require 'structure'
local tst = require 'test'


-- Variables globamles
BOT_NAME = "ni2goch_ni2dwatt"
exit_answer_list = {"bye", "au revoir", "q", "quit"}


--[[
	Lance le chat bot
]]--
function start_chatbot()
	s = " ---- "
	txt = "Bienvenu dans le Chatbot de CDK, MFD, LAO & UGO"
	print("\n\t"..s..txt..s.."\n")
	bot_answer("Bonjour !")
end


--[[
	Reponse du chat bot
]]--
function bot_answer(answer)
	print(BOT_NAME.." : "..answer.."\n")
end


--[[
	Fonction d'exhange entre l'utilisateur et le chat bot
]]--
function chat_loop()
	user_line = ""

	while in_liste(user_line, exit_answer_list) == false do
		io.write("> ")
		user_line = io.read()
		bot_processing(user_line)
	end
end


--[[
	Traitement d'une ligne de texte por le chat bot
]]--
function bot_processing(line)

	-- traitement de la ligne de texte : retirer les accents et la majuscules ?

	if in_liste(line, exit_answer_list) then
		bot_answer("au revoir !")
	else
		bot_answer("haha, t'as dit : "..line)
		tst.sentence_processing(line)
	end
end


--[[
	Cherche un element dans une liste
	Renvoie true si l'element est dans la liste, false sinon
]]--
function in_liste(elem, liste)
	for index, valeur in ipairs(liste) do
    	if elem == valeur then
    		return true
    	end
    end

    return false
end


--[[
	Main
]]--
function bot.main()
	start_chatbot()
	chat_loop()
	--struct.foo()
end


bot.main()

return bot