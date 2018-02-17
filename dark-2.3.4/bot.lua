--[[
			SYSTEME DE DIALOGUE
	
	Projet d'EISD realise par les etudiants:
		@Manfred MadlnT
		@Cedrick RibeT
		@Hugo BommarT
		@Laos GalmnT

	-- Janvier 2018 --
]]--

local bot = {}


-- importation d'un module
local tool = require 'tool'
local txt  = require 'phrases'
local corr = require 'corrector'
local lp   = require 'line_processing'


-- Variables globales
local enable_hist = false
local turn = 0
local dialog = {}
local reponse = {}


-- Main
function bot.start(lst_attributs, hist)
	l_attributs = lst_attributs
	enable_hist = hist or false

	db = dofile("database.lua")

	tool.init(txt.pick_mdl(start))
	chat_loop()
	--test_fonctionnel()
end


-- Fonction d'echange entre l'utilisateur et le systeme de dialogue
function chat_loop()
	local loop = true
	
	while loop do
		init_rep()
		io.write("> ")
		line = io.read()
		loop = bot_processing(line)
	end
end


--[[ TODO 
		Pattern pour 2 Q
		Analyser Q1, gen rep
		Na Q2, gen Rep

		Aff fusion de R1 é R2
]]--
function test_fonctionnel()
	local test_ok = {
		"Lieu de naissance ?",
		"sep",
		"Mélenchon ?",
		"sep",
	}
	
	local t_simple = {
		-- TODO : voulez-vous une/CES information ?
		"Lieu de naissance et date de naissance ?",
		"Mélenchon et toi ?",
		"Quelle est la date de naissance de Mélenchon ?",
		"Lieu de naissance et date de naissance de Mélenchon ?",
	}
	local t_cmplx = {
		
		-- TODO : Tester le il : mélenchon pui ou

		--"qui sont tes createurs ?",
		"melu ou f",
		--"bonjour",
		--"tu ou f",
		--"quelle est la date de naissance de Melenchon ? et sa formation ?"
		--"bye",
		--"qui suis-je ?",
	}

	for i, line in pairs(t_simple) do	
		init_rep()
		print("> "..line)

		--pause
		io.write("\n--- Entree pour continuer ---\n ")
		io.read()
		
		bot_processing(line)
	end
end


-- Traitement d'une ligne de texte par le systeme de dialogue
function bot_processing(line)
	-- traitement de la ligne de texte
	seq = lp.process(line)
	print(seq:tostring(tags))

	-- analyse de la sequence
	choice = contextual_analysis(seq)
	return choose_answer(choice)
end


function contextual_analysis(question)
	-- TODO : gérer cette varialbe
	quit = 0
	-- on commence par recuperer hors contexte
	dialog.hckey = find_keys(question)

	-- TODO : ne plus Quitter la discussion comme ça
	for i, att in ipairs(dialog.hckey) do	
		if (att == -1) then quit = -1 end
	end

	dialog.hctypes = find_types(question)
	
	-- lien entre hors contexte et en contexte
	hc_to_ec()
	
	set_answer()
	-- rempli le paterne choisi
	create_answer(reponse)
	update_history()
	affichage()
	return quit
end


function find_keys(question)
	local res = {}
	
	-- on cherche les sujets dans la phrase
	for i, att in pairs(l_sujets) do	
		print(att)
		if (#question[tool.tag(att)]) ~= 0 then
			res[#res+1] = question:tag2str(tool.tag(att))[1]
			print("res", res[#res])
		elseif (#question[tool.tag(exit)]) ~= 0 then
			res[#res+1] = -1
		end
	end
	return res
end


function find_types(question)
	local res = {}

	-- On cherche les questions poses dans la phrase
	for i, att in pairs(l_attributs) do	
		if (#question[tool.tag(tool.qtag(att))]) ~= 0 then
			res[#res+1] = att
		end
	end
	return res
end


function hc_to_ec()
	-- lien Hors context vesr En context sur les clés
	dialog.eckey = update_context(dialog.hckey, dialog.hctypes, dialog.eckey)

	-- lien Hors context vesr En context sur les types
	dialog.ectype = update_context(dialog.hctypes, dialog.hckey, dialog.ectype)
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


-- Fixe la reponse du Syst de D en fonction element de la question
function set_answer()
	is_key = true
	tab = dialog.eckey
	att = dialog.ectype

	use_types(att, tab, is_key)
end


function create_answer(reponse)
	dialog.gen = "answer = "..reponse.gen
	local res = {}
	for _, mdl in pairs(reponse.model) do
		for balise, v in pairs(reponse) do
			if (balise ~= "gen" and balise ~= "model") then
				modifie = txt.fill_mdl(mdl, balise, reponse[balise])
				
				-- on actualise le modele uniquement s'il y a du nouveau
				if (modifie) then mdl = modifie end
			end
		end

		-- on ajoute le modele rempli au resultat final
		res[#res+1] = mdl
	end
	print("mdl", #reponse.model)
	print("res avt",# res)
	rm_doublon(res)	
	print("res apr",# res)

	rep = ""

	for i, v in pairs(res) do 
		rep = rep..v 

		-- TODO : améliorer la transition entre 2 réponses
		rep = rep.."\n" 
	end
	print("generique")
	bot_answer(rep)
end


function reponse_bot(key, typ)
	if key then
		if tool.in_list(key, l_tutoiement) then
			q_bot(key, typ)
		elseif tool.in_list(key, l_user) then
			-- TODO : 
			print("user !")
		else
			q_politicien(key, typ)
		end
	elseif typ then
		fill_response(mdl_Qinfo, "quel politicien")
	else
		fill_response(mdl_idk, "idk")
	end
end


-- Rempli les attributs necessaires a la generation de la reponse
function fill_response(mdl, gen, sjt, res)
		reponse.model[#reponse.model + 1] = txt.pick_mdl(mdl)
		reponse.gen = gen 
		reponse.sjt = sjt
		reponse.res = res
		-- TODO : ajouter la rep du bot opas ici !
end


function q_bot(key, typ)
	if not typ then
		fill_response(mdl_Qsjt, "quelle information", "moi")

	elseif typ == hdb_createurs then
		tab = "\n\t"
		res = ""
		for i, att in pairs(l_dev) do
			res = res..tab..att
		end
		fill_response(mdl_creatr, "mes_createurs", "", res)
	else
		fill_response(mdl_no_rep, "non_gere", "", res)
	end
end


function q_politicien(key, typ)
	-- question sur un politicien
	if not typ then
		fill_response(mdl_Qtype, "quelle_information", key)
	else
		local bool = false
		-- On cherche les questions poses dans la phrase
		for i, att in pairs(l_attributs) do	
			bool = search_tag(key, typ, att)
			if (bool) then break end
		end

		if (not bool) then 
			fill_response(mdl_no_gere, "non_gere")
		end
	end
end


function search_tag(key, typ, q_tag)
	if typ == q_tag then

		key_value = corr.corrector(key)
		typ_value = q_tag

		local res       = search_in_db(db, key_value, typ_value)
		local name      = search_in_db(db, key_value, db_name)
		local firstname = search_in_db(db, key_value, db_fname)
		
		if res == 0 then
			-- type error
			fill_response(mdl_t_err, "type_error")
		elseif res == -1 then
			-- key error
			fill_response(mdl_k_err, "key_error : "..key_value, key_value)
		else
			key_is_used()
			key_is_used(dialog[#dialog-2], key)
			if key_is_used(dialog[#dialog-2], key) then
				local s = search_in_db(db, key_value, "gender")
				-- TODO : mettre écriture inclusive a la place
				pronoun = "Il "
				if (s == "F") then pronoun = "Elle " end
				
				gen_answer(pronoun, res, typ_value)

			else gen_answer(firstname.." "..name.." ", res, typ_value) end
		end
		return true
	end

	return false
end


-- Genere une reponse a partir d'un tableau ou d'un string
function gen_answer(sjt, res, type_val)
	if type(res) == "table" then
		rep = ""

		-- Recherche de la formation
		if (type_val == db_forma) then
			for i = 1, #res do
				rep = rep.."\n\t"..get_forma(res, i)
			end
			fill_response(mdl_forma, type_val, sjt, rep)
		end
	else
		print("res", res)
		fill_response(txt.get_mdl(type_val), res, sjt, res)
	end
end


function choose_answer( choice )
	if (choice == -1) then
		fill_response(mdl_exit, "exit")
		return false
	end
	return true
end


-- réponse pas assez humaine
function get_forma(res, i)
	local  date = search_in_db(res, i, "date")
	local  name = search_in_db(res, i, "name")
	local  lieu = search_in_db(res, i, "lieu")

	t = ""

	if (name ~= -1) then t = t..name.." " end
	if (date ~= -1) then t = t.."en "..date.." " end
	--if (lieu ~= -1) then t = t.."à "..lieu.." " end
	
	return t
end


function update_history()
	local ec_gen = dialog.gen    or "no ans"
	local ec_key = dialog.eckey  or "no key"
	local ec_typ = dialog.ectype or "no typ"
	turn = turn+1

	table.insert(dialog, turn)
	table.insert(dialog, ec_key)
	table.insert(dialog, ec_typ)
	table.insert(dialog, ec_gen)	
	--TODO : rep bot
end


function aff_typ(k)
	if(dialog.ectype) then
		for j, t in pairs(dialog.ectype) do
			print(k, t)
		end
	else				
		print(k, nil)
	end
end

-- deprec
function affichage()
	--key_n_type()
	if(enable_hist) then historique() end	
end

-- deprecated
function key_n_type()
	print("-Clé-", "-Type-")
	if(#dialog.eckey >= 1) then
		for i, k in pairs(dialog.eckey) do
			aff_typ(k)
			--print(k, dialog.ectype)
		end
	else
		aff_typ(nil)
		--print(nil, dialog.ectype)
	end
end


function init_rep()

	reponse = {model= {}, sjt= "", res= "", gen= ""}
end


function historique()
	print("\nhistorique :")
	for index,value in pairs(dialog) do
		res = ""
		if type(value) == "table" then
			for i, v in pairs(value) do
				res = res..v..", "
			end
		else
			res = value
		end
		print(index, res)

		if index == #dialog then print() end
	end
	print()
end


function key_is_used(tab, key)
	if(type(tab) == "table") then
		for i, att in pairs(tab or {}) do	
			if (key == att) then return true end
		end
	end
	return false
end


-- deprecated
function rm_doublon(tab)
	if #tab < 2 then return false end

	for i = #tab, 1, -1 do
		for j = i-1, 1, -1 do
			if tab[i] == tab[j] then
				table.remove(tab, j)
				i = i-1
				break
			end
		end
	end

	return tab
end


-- rename
function use_types(att, tab, is_key)
	if(tab) then
		for i, elm in pairs(tab) do	
			mini_f(elm, att, is_key)
		end

	else mini_f(nil, att, is_key) end
end


-- renam
function mini_f(elm, att, is_key)
	if is_key then use_types(elm, att, not is_key)

	else reponse_bot(att, elm) end
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
	   
		else return 0 end
    end
  end

  if (b == 0) then return -1 end
end


return bot