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
local tool = require 'tool'
local sp = require 'seq_processing'
local lp = require 'line_processing'


-- Variables globamles
local BOT_NAME = "ni2goch_ni2dwatt"

dialog_state = {}

turn = 0

-- Lancer le chat bot
function start_chatbot()
	s = " ---- "
	txt = "Bienvenu dans le Chatbot de CDK, MFD, LAO & UGO"
	print("\n\t"..s..txt..s.."\n")
	bot_answer("Bonjour ! Je suis l'as des Politiciens Français. Comment puis-je vous aider ?")
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
	contextual_analysis( seq )

	return response
end


function contextual_analysis( question )
	-- on commence par recuperer hors contexte
	if (#question[tool.get_tag(ppn)]) ~= 0 then
		print("\n\t\tNom reconnu")
		dialog_state.hckey = question:tag2str("#pnominal")[1]
	else
		dialog_state.hckey = nil
	end

	if (#question["#Qbirth"]) ~= 0 then
		dialog_state.hctypes = "Qbirth"
	elseif (#question["#Qlieu"]) ~= 0 then
		dialog_state.hctypes = "Qlieu"
	end


	-- en contexte on veut rÃ©cupÃ©rer ssi on a au moins un Ã©lÃ©ment
	-- d'une autre classe (key ou types)
	-- lien Hors context vesr En context sur les clés
	if (dialog_state.hckey) then
		dialog_state.eckey = dialog_state.hckey
	elseif (dialog_state.hctypes) then
		-- on conserve la key prÃ©cÃ©dente
		-- inutile
		dialog_state.eckey = dialog_state.eckey
	else
		dialog_state.eckey = nil
	end


	-- lien Hors context vesr En context sur les types
	if (dialog_state.hctypes) then
		dialog_state.ectypes = dialog_state.hctypes
	elseif (dialog_state.hckey) then
		-- on conserve la key prÃ©cÃ©dente
		dialog_state.ectypes = dialog_state.ectypes
	else
		dialog_state.ectypes = nil
	end


	print("Clé & type :", dialog_state.eckey, dialog_state.ectypes)

	turn = turn + 1
	table.insert(dialog_state, turn)
	table.insert(dialog_state, dialog_state.ectypes)
	table.insert(dialog_state, dialog_state.eckey)
	table.insert(dialog_state, dialog_state.gen)
	print("taille :", #dialog_state, "\nTableau :")
	for index,value in pairs(dialog_state) do
		print(index, value)
	end
	print()

	dialog_state.gen = {}

	-- on commence le dialogue
	if dialog_state.eckey then
		print("dialogue 1:")
		if dialog_state.ectypes == "Qbirth" then
			keyValue = dialog_state.eckey
			typesValue = "naissance"
			local res = getFromDB(keyValue, typesValue)
			local firstname = getFromDB(keyValue, "nom")
			if res == 0 then
				print("Désolé, je n'ai pas cette information")
				dialog_state.gen = "ans = pas_info"
			elseif res == -1 then
				print("Désolé, je n'ai pas ".. keyValue.." dans ma base d'auteurs.")
				dialog_state.gen = "ans = pas "..keyValue
			else
				print(firstname, keyValue, "est né le ", res)
				dialog_state.gen = "ans = "..res
			end
		end
	end
	if dialog_state.ectypes and not dialog_state.eckey then
		print("dialogue 2:")
		print("Sur quel auteur voulez-vous une information ?")
		dialog_state.gen = "ans = quel auteur"
	end
end
--end

function choose_answer( choice )
	if (choice == -1) then
		--bot_answer("Au revoir !")
		return false
	elseif (choice == 1) then
		--bot_answer("Vous avez posé une question")
	else
		--bot_answer("Je ne sais pas !")
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



--Fonction pour récupérer les informations
function getFromDB(politicien, ...)
  b=0
  local arg = {...}
  for k,v in pairs(db) do
    if(k == politicien) then
      b=1
      tab = v
      --parcours en profondeur
      for i,champ in ipairs(arg) do
        tab = tab[champ]
      end
      --On a detecte des elements
      if(tab ~= nil) then
	      return tab
	    else
	  	  return 0 --"Désolé, je n'ai pas cette information"
	    end
    end
  end

  if b==0 then
  	return -1 --"Désolé, je ne comprends pas de quel pays vous parlez"
  end

end


-- Main
function bot.main()
	db = dofile("database.lua")
	start_chatbot()
	chat_loop()
end


return bot