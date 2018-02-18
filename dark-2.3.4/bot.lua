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
local enable_hist = true
local turn = 0
local dialog = {}
local reponse = {}


-- Main
function bot.start(lst_attributs)
	l_attributs = lst_attributs

	db = dofile("database.lua")

	tool.init(txt.pick_mdl(start))
	--chat_loop()
	test_fonctionnel()
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
	local t_fini = {
		"Lieu de naissance ?",
		"sep",
		"Mélenchon ?",
		"sep",
		"qui sont tes createurs ?",
		"sep",
		"ou ?",
		"qui sont mes createurs ?",
	}
	
	local t_simple = {
		"(non moi et (tu Melenchon ou) et f naissance) et f ou et f non tu et moi",
		-- TODO : voulez-vous une/CES information ?
	}
	local t_cmplx = {
		"sep",
		"tu",
		"sep",
		"Lieu de naissance et date de naissance ?",
		"Mélenchon et toi ?",
		"Quelle est la date de naissance de Mélenchon ?",
		"Lieu de naissance et date de naissance de Mélenchon ?",
		
		-- TODO : Tester le il : mélenchon pui ou

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
		io.write("\n--- Appuyez sur une touche pour continuer ---\n ")
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
	return contextual_analysis(seq)
end


function contextual_analysis(question)
	-- on commence par recuperer les donnees hors contexte
	dialog.hckey   = find_elm(question, l_sujets, true)
	dialog.hctypes = find_elm(question, l_attributs, false)
	
	-- puis on fait le lien entre hors contexte et en contexte
	hc_to_ec()
	
	-- on definie le paterne de la reponse 
	set_answer()

	-- on rempli le paterne choisi et l'affiche a l'ecran
	create_answer(reponse)
	update_history()

	return check_exit()
end


-- TDOD		fill_response(mdl_exit, "exit")


function find_elm(question, l_elm, is_key)
	local res = {}

	-- On cherche les sujets dans la phrase ou les questions posees
	for i, att in pairs(l_elm) do	
		-- sujets
		if is_key then
			if (#question[tool.tag(att)]) ~= 0 then
				res[#res+1] = question:tag2str(tool.tag(att))[1]
			end
		-- questions
		else
			if (#question[tool.tag(tool.qtag(att))]) ~= 0 then
				res[#res+1] = att
			end
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


-- Fixe la reponse du Systeme de Dialogue en fonction element de la question
function set_answer()
	tab = dialog.eckey
	att = dialog.ectype
	
	-- analyse des clefs
	analyse_elm(att, tab, true)
end


function create_answer(reponse)
	dialog.gen = "answer = "..reponse.gen
	local res = {}
	for _, mdl in pairs(reponse.model) do
		for balise, v in pairs(reponse) do
			-- TODO essayer sans cette condition
			if (balise ~= "gen" and balise ~= "model") then
				modifie = txt.fill_mdl(mdl, balise, reponse[balise])
				
				-- on actualise le modele uniquement s'il y a du nouveau
				if (modifie) then mdl = modifie end
			end
		end

		-- on ajoute le modele rempli au resultat final
		res[#res+1] = mdl
	end

	tool.rm_doublon(res)	
	rep = ""

	for i, v in pairs(res) do 
		rep = rep..v 

		-- TODO : améliorer la transition entre 2 réponses
		rep = rep.."\n" 
	end
	print("generique")
	bot_answer(rep)
end


function analyse_elm(att, tab, is_key)
	if(tab) then
		for i, elm in pairs(tab) do	
			get_pattern(elm, att, is_key)
		end

	else get_pattern(nil, att, is_key) end
end


function get_pattern(elm, att, is_key)
	-- analyse des types
	if is_key and elm then analyse_elm(elm, att, not is_key)

	-- choix du paterne
	elseif cas_special(att, elm) then 
		print("cas spécial !")
	elseif elm then
		search_pattern(att, elm)
	elseif att then
		fill_response(mdl_Qinfo, "quel politicien")
	else
		fill_response(mdl_idk, "idk")
	end
end


function cas_simple()
	-- la question est composee d'un unique element
end


function cas_normal()
	-- la question est composee de deux elements ou plus
end


function cas_complexe()
	-- la question est composee de deux questions ou plus
end



-- Rempli les attributs necessaires a la generation de la reponse
function fill_response(mdl, gen, sjt, res)
		reponse.model[#reponse.model + 1] = txt.pick_mdl(mdl)
		reponse.gen = gen 
		reponse.sjt = sjt
		reponse.res = res
end


function cas_special(key, typ)
	local m_tutoie, m_user = false, false

	if tool.in_list(key, l_tutoiement) then m_tutoie = true
	elseif tool.in_list(key, l_user) then m_user = true end

--[[
	if not typ then
		if m_tutoie then m_key = "moi" end

		fill_response(mdl_Qtype, "quelle_information", m_key)

	-- Question sur les createurs 
	elseif typ == hdb_createurs and ( m_tutoie or m_user) then
		tab, res = "\n\t", ""
		
		if m_tutoie then
			m_mdl = mdl_creatr_b
			for i, att in pairs(l_dev) do
				res = res..tab..att
			end
		else
			m_mdl = mdl_creatr_u
		end
		fill_response(m_mdl, "createurs", "", res)
	
	else
		local q_found = false
		if(not m_tutoie and not m_user) then
			-- On cherche les questions posees dans la phrase
			for i, att in pairs(l_attributs) do	
				q_found = search_tag(key, typ, att)
				if (q_found) then break end
			end
		end

		if (not q_found) then 
			if m_tutoie then 
				m_mdl = mdl_no_rep
			else
				m_mdl = mdl_no_gere
			end

			fill_response(m_mdl, "non_gere")
		end
	end
]]
	if(m_tutoie or m_user) then	return true end
	return false
end

function search_pattern(key, typ)
	
	if not typ then
		fill_response(mdl_Qtype, "quelle_information", key)

	else
		local q_found = false
		
		-- On cherche les questions posees dans la phrase
		for i, att in pairs(l_attributs) do	
			q_found = search_tag(key, typ, att)
			if (q_found) then break end
		end		

		if (not q_found) then 
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
			if tool.key_is_used(dialog[#dialog-2], key) then
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
	table.insert(dialog, reponse.model)	
	--TODO : rep bot

	historique()
end


function init_rep()

	reponse = {model= {}, sjt= "", res= "", gen= ""}
end


function check_exit()
	for i, e in pairs(dialog.hckey) do
		if tool.in_list(e, l_fin) then
			return false
		end
	end
	return true
end


function historique()
	if not enable_hist then return -1 end

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