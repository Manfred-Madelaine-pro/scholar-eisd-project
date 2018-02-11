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
local BOT_NAME = "ugoBot"

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
	choice = contextual_analysis(seq)
	response = choose_answer(choice)

	return response
end


function find_key(question)
	res = ""
	-- on commence par recuperer hors contexte
	if (#question[tool.get_tag(ppn)]) ~= 0 then
		res = question:tag2str(tool.get_tag(ppn))[1]
	
	elseif (#question[tool.get_tag(exit)]) ~= 0 then
		res = -1
	else
		res = nil
	end
	return res
end

-- naiisance ET lieu de naissance : à gérer
function find_type(question)
	res = ""
	if (#question[tool.get_tag(q_birth)]) ~= 0 then
		res = q_birth
	elseif (#question[tool.get_tag(q_lieu)]) ~= 0 then
		res = q_lieu
	elseif (#question[tool.get_tag(q_formation)]) ~= 0 then
		res = q_formation
	else
		res = nil
	end

	return res
end


function hc_to_ec()
	-- lien Hors context vesr En context sur les clés
	if (dialog_state.hckey) then
		dialog_state.eckey = dialog_state.hckey
	elseif (dialog_state.hctypes) then
		dialog_state.eckey = dialog_state.eckey
	else
		dialog_state.eckey = nil
	end


	-- lien Hors context vesr En context sur les types
	if (dialog_state.hctypes) then
		dialog_state.ectypes = dialog_state.hctypes
	elseif (dialog_state.hckey) then
		dialog_state.ectypes = dialog_state.ectypes
	else
		dialog_state.ectypes = nil
	end
end


function reponse_bot()
	if dialog_state.eckey then
		if dialog_state.ectypes == nil then
			bot_answer("Que souhaitez vous savoir sur "..dialog_state.eckey.." ?")
		else	
			q1 = search_tag(q_birth, pol_birth, "est né le")
			q2 = search_tag(q_lieu, pol_birthplace, "est né à")
			q3 = search_tag(q_formation, pol_formation, "formation : ")

			if (q1 == -1 and q2 == -1 and q3 == -1) then 
				bot_answer("Cette information n'est pas encore gérée par le système.")
			end
		end
	elseif dialog_state.ectypes then
		bot_answer("Sur quel politicien voulez-vous une information ?")
		dialog_state.gen = "answer = quel politicien"
	end
end


function search_tag(q_tag, pol_tag, txt)
	if dialog_state.ectypes == q_tag then

		keyValue = tool.distance_mot(dialog_state.eckey)
		typesValue = pol_tag

		local res = getFromDB(keyValue, typesValue)
		local name = getFromDB(keyValue, pol_name)
		local firstname = getFromDB(keyValue, pol_fname)
		
		if res == 0 then
			bot_answer("Désolé, je n'ai pas cette information")
			dialog_state.gen = "answer = pas_info"
		elseif res == -1 then
			bot_answer("Désolé, je n'ai pas ".. keyValue.." dans ma base d'auteurs.")
			dialog_state.gen = "answer = pas "..keyValue
		else
			gen_answer(firstname.." "..name.." "..txt, res)
		end
		return 0
	end

	return -1
end

function gen_answer(txt, res)
	if type(res) == "table" then
		print ("tbleau !")
		dialog_state.gen = "answer = formation"
	else
		bot_answer(txt.." "..res)
		dialog_state.gen = "answer = "..res
	end
end


function contextual_analysis(question)
	-- on commence par recuperer hors contexte
	dialog_state.hckey = find_key(question)

	-- Quitter la discussion
	if (dialog_state.hckey == -1) then
		return -1
	end

	dialog_state.hctypes = find_type(question)
	
	-- lien entre hors contexte et en contexte
	hc_to_ec()


	turn = turn + 1
	table.insert(dialog_state, turn)
	table.insert(dialog_state, dialog_state.ectypes)
	table.insert(dialog_state, dialog_state.eckey)
	table.insert(dialog_state, dialog_state.gen)

	affichange()

	dialog_state.gen = {}

	reponse_bot()
end


function affichange()
		
	print("Clé & type :", dialog_state.eckey, dialog_state.ectypes)
	print("taille :", #dialog_state, "\nTableau :")
	for index,value in pairs(dialog_state) do
		print(index, value)
	end
	print()
end

function choose_answer( choice )
	if (choice == -1) then
		bot_answer("Au revoir !")
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