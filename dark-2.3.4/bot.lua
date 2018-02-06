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
local sp = require 'seq_processing'
local lp = require 'line_processing'


-- Variables globamles
local BOT_NAME = "ni2goch_ni2dwatt"
exit_answer_list = {"au revoir", "q", "quit"}


-- Lancer le chat bot
function start_chatbot()
	s = " ---- "
	txt = "Bienvenu dans le Chatbot de CDK, MFD, LAO & UGO"
	print("\n\t"..s..txt..s.."\n")
	bot_answer("Bonjour !")
end


-- Reponse du chat bot
function bot_answer(answer)
	print(BOT_NAME.." : "..answer.."\n")
end


-- Fonction d'exhange entre l'utilisateur et le chat bot
function chat_loop()
	user_line = ""
	loop = true
	-- in_liste(user_line, exit_answer_list) == false
	while loop do
		io.write("> ")
		user_line = io.read()
		loop = bot_processing(user_line)
	end
end


-- Traitement d'une ligne de texte por le chat bot
function bot_processing(line)

	-- traitement de la ligne de texte
	seq = lp.process(line)
	print(seq:tostring(tags))
	
	-- analyser la sequence
	choice = sp.analyse_seq(seq)
	
	response = choose_answer( choice )

	return response
end


function choose_answer( choice )
	if (choice == -1) then
		bot_answer("Au revoir !")
		return false
	elseif (choice == 1) then
		bot_answer("Vous avez posé une question")
	else
		bot_answer("Je ne sais pas !")
	end
	return true
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


-- Main
function bot.main()
	start_chatbot()
	chat_loop()
end


return bot