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
	local line, loop = "", true
	
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
	local res = nil
	local liste_sujet = {ppn, tutoiement}
	
	-- on commence par recuperer hors contexte
	for i, att in pairs(liste_sujet) do	
		if (#question[tool.tag(att)]) ~= 0 then
			res = question:tag2str(tool.tag(att))[1]
		elseif (#question[tool.tag(exit)]) ~= 0 then
			res = -1
		end
	end

	return res
end

function find_keys(question)
	local res = {}
	local liste_sujet = {ppn, tutoiement}
	
	-- on cherche les sujets dans la phrase
	for i, att in pairs(liste_sujet) do	
		if (#question[tool.tag(att)]) ~= 0 then
			res[#res+1] = question:tag2str(tool.tag(att))[1]
		elseif (#question[tool.tag(exit)]) ~= 0 then
			res[#res+1] = -1
		end
	end
	return res
end


-- naiisance ET lieu de naissance : à gérer
function find_type(question)
	local res = nil

	-- liste des attributs à chercher
	local liste_attributs = {q_birth, q_lieu, q_forma, q_statut}
	for i, att in pairs(liste_attributs) do	
		if (#question[tool.tag(att)]) ~= 0 then
			res = att
			
			--parcourir_table(tool.tagstrs(question[tool.tag(att)], att))
			break 
		end
	end

	return res
end

-- naiisance ET lieu de naissance : à gérer
function find_types(question)
	local res = {}
	local liste_attributs = {q_birth, q_lieu, q_forma, q_statut}

	-- On cherche les questions poses dans la phrase
	for i, att in pairs(liste_attributs) do	
		if (#question[tool.tag(att)]) ~= 0 then
			res[#res+1] = att
		end
	end
	return res
end


function hc_to_ec()
	-- lien Hors context vesr En context sur les clés
	dialog_state.eckey = update_context(dialog_state.hckey, dialog_state.hctypes, dialog_state.eckey)

	-- lien Hors context vesr En context sur les types
	dialog_state.ectype = update_context(dialog_state.hctypes, dialog_state.hckey, dialog_state.ectype)

end


function update_context(cond1, cond2, val)
	var = nil 
	if (#cond1 >= 1) then
		var = cond1
	elseif (#cond2 >= 1) then
		var = val
	end
	return var
end


function use_keys()
	for i, key in pairs(dialog_state.eckey or {}) do	
		for j, typ in pairs(dialog_state.ectype or {}) do	
			reponse_bot(key, typ)
		end
	end
end


function reponse_bot(key, typ)
	print("key", key)
	print("typ", typ)
	if key then
		if typ == nil then
			bot_answer("Que souhaitez vous savoir sur "..key.." ?")
			dialog_state.gen = "answer = quelle information"

		else	
			local q1 = search_tag(key, typ, q_birth, pol_birth, "est né le")
			local q2 = search_tag(key, typ, q_lieu, pol_birthp, "est né à")
			local q3 = search_tag(key, typ, q_forma, pol_forma, "a comme formation : ")

			if (not q1 and not q2 and not q3) then 
				bot_answer("Cette information n'est pas encore gérée par le système.")
			end
		end
	elseif typ then
		bot_answer("Sur quel politicien voulez-vous une information ?")
		dialog_state.gen = "answer = quel politicien"
	end
end


function search_tag(key, typ, q_tag, pol_tag, txt)
	if typ == q_tag then

		key_value = corr.corrector(key)
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
			if key == dialog_state[#dialog_state-2] then
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
		rep = txt

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
	dialog_state.hckey = find_keys(question)

	-- Quitter la discussion
	for i, att in pairs(dialog_state.hckey) do	
		if (att == -1) then return -1 end
	end

	dialog_state.hctypes = find_types(question)
	
	-- lien entre hors contexte et en contexte
	hc_to_ec()

	turn = turn + 1
	
	use_keys()
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


function aff_typ(k)
	if(dialog_state.ectype) then
		for j, t in pairs(dialog_state.ectype) do
			print(k, t)
		end
	else				
		print(k, nil)
	end
end


function affichage()	
	--key_n_type()

	print("\nHistorique :")
	for index,value in pairs(dialog_state) do
		res = ""
		if type(value) == "table" then
			for i, v in pairs(value) do
				res = res..v..", "
			end
		else
			res = value
		end
		print(index, res)

		if index == #dialog_state then print() end
	end
	print()
end

function key_n_type()
	print("-Clé-", "-Type-")
	if(#dialog_state.eckey >= 1) then
		for i, k in pairs(dialog_state.eckey) do
			aff_typ(k)
			--print(k, dialog_state.ectype)
		end
	else
		aff_typ(nil)
		--print(nil, dialog_state.ectype)
	end
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