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
local corr = require 'corrector'
local sp   = require 'seq_processing'
local lp   = require 'line_processing'


-- Variables globales
local turn         = 0
local BOT_NAME     = "ugoBot"
local dialog_state = {}


-- Lancer le chat bot
function init()
	local s = " ---- "
	local txt = "Bienvenu dans le Chatbot de CDK, MFD, LAO & UGO"
	print("\n\t"..s..txt..s.."\n")
	bot_answer("Bonjour ! Je suis l'As des Politiciens Français. Comment puis-je vous aider ?")
end


-- Reponse du chat bot
function bot_answer(answer)
	print(BOT_NAME.." : "..answer.."\n")
end


-- Fonction d'exhange entre l'utilisateur et le chat bot
function chat_loop()
	local line = ""
	local loop = true
	
	while loop do
		io.write("> ")
		line = io.read()
		loop = bot_processing(line)
	end
end


-- Traitement d'une ligne de texte por le chat bot
function bot_processing(line)
	-- traitement de la ligne de texte
	seq = lp.process(line)
	print(seq:tostring(tags))

	-- analyser la sequence
	choice = contextual_analysis(seq)
	return choose_answer(choice)
end


function find_key(question)
	local res = ""
	-- on commence par recuperer hors contexte
	if (#question[tool.get_tag(ppn)]) ~= 0 then
		res = question:tag2str(tool.get_tag(ppn))[1]
	elseif (#question[tool.get_tag(exit)]) ~= 0 then
		res = -1

	else res = nil end

	return res
end

-- naiisance ET lieu de naissance : à gérer
function find_type(question)
	local res = ""

	if (#question[tool.get_tag(q_birth)]) ~= 0 then
		res = q_birth
	elseif (#question[tool.get_tag(q_lieu)]) ~= 0 then
		res = q_lieu
	elseif (#question[tool.get_tag(q_forma)]) ~= 0 then
		res = q_forma
	elseif (#question[tool.get_tag(q_statut)]) ~= 0 then
		res = q_statut
	
	else res = nil end

	return res
end


function hc_to_ec()
	-- lien Hors context vesr En context sur les clés
	if (dialog_state.hckey) then
		dialog_state.eckey = dialog_state.hckey
	elseif (dialog_state.hctypes) then
		dialog_state.eckey = dialog_state.eckey
	else dialog_state.eckey = nil end


	-- lien Hors context vesr En context sur les types
	if (dialog_state.hctypes) then
		dialog_state.ectype = dialog_state.hctypes
	elseif (dialog_state.hckey) then
		dialog_state.ectype = dialog_state.ectype
	else dialog_state.ectype = nil end
end


function reponse_bot()
	if dialog_state.eckey then
		if dialog_state.ectype == nil then
			bot_answer("Que souhaitez vous savoir sur "..dialog_state.eckey.." ?")
			dialog_state.gen = "answer = quelle information"

		else	
			local q1 = search_tag(q_birth, pol_birth, "est né le")
			local q2 = search_tag(q_lieu, pol_birthp, "est né à")
			local q3 = search_tag(q_forma, pol_forma, "a comme formation : ")

			if (not q1 and not q2 and not q3) then 
				bot_answer("Cette information n'est pas encore gérée par le système.")
			end
		end
	elseif dialog_state.ectype then
		bot_answer("Sur quel politicien voulez-vous une information ?")
		dialog_state.gen = "answer = quel politicien"
	end
end


function search_tag(q_tag, pol_tag, txt)
	if dialog_state.ectype == q_tag then

		key_value = corr.corrector(dialog_state.eckey)
		typ_value = pol_tag

		local res       = search_in_db(db, key_value, typ_value)
		local name      = search_in_db(db, key_value, pol_name)
		local firstname = search_in_db(db, key_value, pol_fname)
		
		if res == 0 then
			bot_answer("Désolé, je n'ai pas cette information")
			dialog_state.gen = "answer = pas_info"
		
		elseif res == -1 then
			bot_answer("Désolé, je n'ai pas ".. key_value.." dans ma base de politiciens.")
			dialog_state.gen = "answer = pas "..key_value
		
		else
			if dialog_state.eckey == dialog_state[#dialog_state-2] then
				local s = search_in_db(db, key_value, "gender")
				pronoun = "Elle "
				if (s == "M") then pronoun = "Il " end
				gen_answer(pronoun..txt, res, typ_value)

			else gen_answer(firstname.." "..name.." "..txt, res, typ_value) end
		end
		return true
	end

	return false
end


function gen_answer(txt, res, type_val)
	if type(res) == "table" then
		rep = txt.."\n"

		for i = 1, #res do
			-- Recherche de la formation
			if (type_val == pol_forma) then
				rep = rep.."\n\t"..get_forma(res, i)
			end
		end

		bot_answer(rep..".")
		dialog_state.gen = "answer = "..type_val
	else
		bot_answer(txt.." "..res..".")
		dialog_state.gen = "answer = "..res
	end
end


function get_forma(res, i)
	local  date = search_in_db(res, i, "date")
	local  name = search_in_db(res, i, "name")
	local  lieu = search_in_db(res, i, "lieu")

	t = ""

	if (name ~= -1) then t = t..name.." " end
	if (date ~= -1) then t = t.."en "..date.." " end
	if (lieu ~= -1) then t = t.."à "..lieu.." " end
	
	return t
end


-- deprecated
function parcourir_table(res)
	if type(res) == "table" then
		for index,value in pairs(res) do
			if type(value) == "table" then
				print("table "..index)
				parcourir_table(value)
				print()
			else
				print(index, value)
			end
		end
	else
		print(res)
	end
end


function contextual_analysis(question)
	-- on commence par recuperer hors contexte
	dialog_state.hckey = find_key(question)

	-- Quitter la discussion
	if (dialog_state.hckey == -1) then return -1 end

	dialog_state.hctypes = find_type(question)
	
	-- lien entre hors contexte et en contexte
	hc_to_ec()

	turn = turn + 1
	
	reponse_bot()
	update_history()
	affichage()
	return 0
end

function update_history()
	local ec_gen = dialog_state.gen    or "no ans"
	local ec_key = dialog_state.eckey  or "no key"
	local ec_typ = dialog_state.ectype or "no typ"

	table.insert(dialog_state, turn)
	table.insert(dialog_state, ec_key)
	table.insert(dialog_state, ec_typ)
	table.insert(dialog_state, ec_gen)	
end


function affichage()	
	print("Clé & type :", dialog_state.eckey, dialog_state.ectype)
	print("Historique :")
	for index,value in pairs(dialog_state) do
		print(index, value)

		if index == #dialog_state then print() end
	end
	print()
end

function choose_answer( choice )
	if (choice == -1) then
		bot_answer("Au revoir !")
		return false
	end
	return true
end


--Fonction pour récupérer les informations
function search_in_db(db, politicien, ...)
  local b = 0
  local arg = {...}

  for k,v in pairs(db) do
    if (k == politicien) then
		b, tab = 1, v

		-- parcours en profondeur
		for i,champ in ipairs(arg) do
			tab = tab[champ]
		end

      -- On a detecte des elements
		if (tab ~= nil) then return tab
	   
	   -- "Désolé, je n'ai pas cette information"
		else return 0 end
    end
  end

  -- "Désolé, je ne comprends pas de quel pays vous parlez"
  if (b == 0) then return -1 end

end


-- Main
function bot.start()
	db = dofile("database.lua")
	init()
	chat_loop()
end


return bot