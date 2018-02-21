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
local turn = 0
local POS_KEY = 3
local dialog  = {}
local reponse = {}
local enable_hist = true


-- Main
function bot.start(lst_attributs)
	l_attributs = lst_attributs

	db = dofile("database.lua")

	print(mode)
	io.write("> ")
	line = ""
	while(line ~= "1" or line ~= "2" ) do
		line = "2"
		--io.read()
		if(line == "1")	then
			tool.init(txt.pick_mdl(start))
			chat_loop()
			break
		elseif (line == "2") then
			tool.init(txt.pick_mdl(start))
			test_fonctionnel()
			break
		else print("réponse non valide") end
	end
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


function test_fonctionnel()
	local t_fini = {
		"Lieu de naissance ?","sep",
		"Mélenchon ?",
		"ou","sep",
		"qui sont tes createurs ?",	"sep",
		"qui sont mes createurs ?",	"sep",
		"Melenchon quel parti",
		"bye", "sep",
		"qui est le createurs de melu",	"sep",
		"$help",
		"sep",
		"Quel est la réponse à la grande question sur la vie, l'univers et le reste",
		"sep",
		"Lieu de naissance et date de naissance de melu", "sep",
		"Mélenchon et toi ?", "sep",
		"affiche l'historique",
		"date de naissance et lieu de naissance de Melenchon et lieu de naissance de Macron ?",
		"Lieu de naissance de melu et qui sont tes créateurs ?",
		"sep",
		"ou Macron et melu ?",
		"qui sont les créateurs de Macron et melu ?",
		"sep",
		"melu et Macron ?",
		"qui sont les createurs ",
		"qui sont mes createurs ",
		"sep",
	}
	
	local t_simple = {
		"quand Macron a-t-il eu son Baccalauréat ?",
		"melu f",
		"affiche l'historique",
		"sep",
		"Lieu de naissance et date de naissance de melu",
		"date de naissance et lieu de naissance de Melenchon et lieu de naissance de Macron ?",
		"ok",
		"sep",
		-- ne répéter 2 fois la m réponse sur 2 lignes
		-- sur une ligne

		--"(Melenchon ou sa f et naissance). (f et non ou tu)",
	}
	local t_cmplx = {
		"sep",
		"Quelle est la date de naissance de Mélenchon ?",
		"sep",
		"Lieu de naissance et date de naissance de Mélenchon ?",
		
		-- TODO : Tester la subtitution par il : mélenchon pui ou

		--"melu ou f",
		--"bonjour",
		--"tu ou f",
		--"quelle est la date de naissance de Melenchon ? et sa formation ?"
		--"bye",
		--"qui suis-je ?",
	}

	for i, line in pairs(t_simple) do	
		init_rep()
		print("> "..line)

		bot_processing(line)

		--pause
		io.write("\n--- Appuyez sur une touche pour continuer ---\n ")
		io.read()		
	end
end


-- Traitement d'une ligne de texte par le systeme de dialogue
function bot_processing(line)
	dialog.quest = "quest = "..line

	-- traitement de la ligne de texte
	seq = lp.process(line)
	print(seq:tostring(tags))

	return contextual_analysis(seq)
end


function contextual_analysis(question)
	if not cas_complexe(question) then
		-- on commence par recuperer les donnees hors contexte
		dialog.hckey   = find_elm(question, l_sujets, true)
		dialog.hctypes = find_elm(question, l_attributs, false)
		te = find_elm(question, att_secondaires, false, true)

		-- puis on fait le lien entre hors contexte et en contexte
		dialog.eckey, dialog.ectype = hc_to_ec(dialog.eckey, dialog.ectype, dialog.hckey, dialog.hctypes)
		
		-- on definie le paterne de la reponse 
		analyse_elm(dialog.ectype, dialog.eckey, true)

		-- on rempli le paterne choisi et l'affiche a l'ecran
		create_answer(reponse)
	end
	return check_exit()
end


-- la question est elle meme composee de deux questions ou plus
function cas_complexe(question)
	if (#question[tool.tag(gram_Qdouble)]) ~= 0 then
		local l_questions = tool.tagstr(question, tool.tag(gram_sous_quest))
		dialog.hckey, dialog.hctypes, dialog.eckey, dialog.ectype = {}, {}, {}, {}

		for i, quest in ipairs(l_questions) do
			quest = lp.process(quest)

			dialog.hckey  [#dialog.hckey  +1] = find_elm(quest, l_sujets, true)
			dialog.hctypes[#dialog.hctypes+1] = find_elm(quest, l_attributs, false)	

			-- puis on fait le lien entre hors contexte et en contexte
			dialog.eckey[i], dialog.ectype[i] = hc_to_ec(dialog.eckey[i], dialog.ectype[i], dialog.hckey[i], dialog.hctypes[i])
			
			-- on definie le paterne de la reponse 
			analyse_elm(dialog.ectype[i], dialog.eckey[i], true)
		end
		create_answer(reponse)
	else return false end
	return true
end


function find_elm(question, l_elm, is_key, is_secondaire)
	local res = {}

	-- On cherche les sujets dans la phrase ou les questions posees
	for i, att in pairs(l_elm) do	
		-- sujets
		if is_key then
			if (#question[tool.tag(att)]) ~= 0 then
				for i,v in ipairs(question[tool.tag(att)]) do
					res[#res+1] = question:tag2str(tool.tag(att))[i]
				end
			end
		-- questions
		elseif is_secondaire then
			print("eioss", att)
			if (#question[tool.tag(att)]) ~= 0 then
				for i,v in ipairs(question[tool.tag(att)]) do
					res[#res+1] = question:tag2str(tool.tag(att))[i]
				end
			end
			--TODO
			--table.insert(res, tool.ee(question, att))
		else
			if (#question[tool.tag(tool.qtag(att))]) ~= 0 then
				--TODO verif si ca marche
				--[[print("verif")
				for i,v in ipairs(question[tool.tag(tool.qtag(att))]) do
					res[#res+1] = question:tag2str(tool.tag(tool.qtag(att)))[i]
					print("eee", res[#res])
				end]]
				res[#res+1] = att
			end
		end
	end
	return res
end


function hc_to_ec(eckey, ectype, hckey, hctypes)
	-- lien Hors context vesr En context sur les clés
	eckey = update_context(hckey, hctypes, eckey)

	-- lien Hors context vesr En context sur les types
	ectype = update_context(hctypes, hckey, ectype)
	return eckey, ectype
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


function create_answer(reponse)
	local res = "answer = "
	for i,v in ipairs(reponse.gen) do
		res = res..v..","
	end
	dialog.gen = res
	
	res = {}

	for i, mdl in pairs(reponse.model) do
		for balise, v in pairs(reponse) do
			if (balise ~= "gen" and balise ~= "model") then
				if (reponse[balise][i]) then
					modifie = txt.fill_mdl(mdl, balise, reponse[balise][i])
				else
					modifie = txt.fill_mdl(mdl, balise, "NUL")
				end

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
		if i == #res-1 then
			rep = rep.."\nEt, " 
		else rep = rep.."\n" end 
	end

	tool.bot_answer(rep)
	update_history()
end


function analyse_elm(l_types, l_keys, is_key)
	if(l_keys) then
		for i, key in pairs(l_keys) do
			get_pattern(key, l_types, is_key)
		end

	else get_pattern(nil, l_types, is_key) end
end


function get_pattern(key, typ, is_key)
	-- analyse des types
	--TODO delet
	print(key, typ)
	if is_key and key and typ then analyse_elm(key, typ, not is_key)

	-- choix du paterne
	elseif is_special(typ) then
		cas_special(typ, key) 
	elseif is_special(key) then
		cas_special(key, typ) 
	elseif q_fermee(typ, key) then 
		print("question fermee !")
	elseif key and typ == nil then
		search_pattern(key, nil)
	elseif key then
		search_pattern(typ, key)
	elseif typ then
		res = "cette information"
		if(#typ > 1) then res = "ces informations" end

		fill_response(mdl_Qinfo, "quel politicien", res)
	else
		fill_response(mdl_idk, "idk")
	end
end


-- Rempli les attributs necessaires a la generation de la reponse
function fill_response(mdl, gen, sjt, res)
		reponse.model[#reponse.model + 1] = txt.pick_mdl(mdl)
		reponse.sjt[#reponse.sjt + 1] = sjt
		reponse.res[#reponse.res + 1] = res
		reponse.gen[#reponse.gen + 1] = gen 
end


--deprec
function q_fermee(key, typ)
	if tool.in_list(key, l_confirm) then
		print("yes")
		
	elseif tool.in_list(key, l_infirm) then
		print("no")
	
	else return false end
	
	return true
end


function is_special(elem)
	local res = false 
	local tab = {l_tutoiement, l_user, l_life, l_hist, l_fin}
	
	for i, att in pairs(tab) do
		if tool.in_list(elem, att) then
			res=true
			break
		end
	end
	if elem == "$ help" then res = true end
	--TODO
	--if elem == hdb_createurs then res = true end
	
	return res
end


function cas_special(key, typ)
	local m_key = key
	local m_mdl = ""
	local m_tutoie, m_user = false, false

	if tool.in_list(key, l_tutoiement) then m_tutoie = true
	elseif tool.in_list(key, l_user) then m_user = true
	elseif tool.in_list(key, l_fin) then 
		fill_response(mdl_exit, "exit")
		return true
	elseif tool.in_list(key, l_hist) then 
		sjt = historique()
		fill_response(mdl_hist, key, sjt)
		return true
	elseif tool.in_list(key, l_life) then 
		fill_response(mdl_life, "life")
		return true
	elseif key == "$ help" then
		fill_response(mdl_help, "help")
		return true
	else return false end

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
		if m_tutoie then 
			m_mdl = mdl_no_rep
		else
			m_mdl = mdl_no_gere
		end

		fill_response(m_mdl, "non_gere")
	end
	return true
end


function search_pattern(key, typ)	
	if not typ then
		fill_response(mdl_Qtype, "quelle_information", key)

	else
		-- On cherche les questions posees dans la phrase
		for i, att in pairs(l_attributs) do	
			if search_tag(key, typ, att) then break end
		end		
	end
end


function search_tag(key, typ, q_tag)
	if typ ~= q_tag then return false end

	local key_value = corr.corrector(key, l_sujets)
	local typ_value = corr.corrector(q_tag, l_attributs)
	local typ_value2 = q_tag

	local res       = search_in_db(db, key_value, typ_value)
	local name      = search_in_db(db, key_value, db_name)
	local firstname = search_in_db(db, key_value, db_fname)
	
	if res == 0 then
		-- type error
		fill_response(mdl_t_err, "type_error", typ_value)
	elseif res == -1 then
		-- key error
		fill_response(mdl_k_err, "key_error : "..key_value, key_value)
	else
		-- Choix du pronom à utiliser
		if tool.key_is_used(dialog[#dialog-POS_KEY], key) then
			local s = search_in_db(db, key_value, "gender")
			pronoun = "Il/Elle "
			if (s == "F") then pronoun = "Elle "
			elseif (s == "M") then pronoun = "Il " end
			
			gen_answer(pronoun, res, typ_value)

		else gen_answer(firstname.." "..name.." ", res, typ_value) end
	end

	return true
end


-- Genere une reponse a partir d'un tableau ou d'un string
function gen_answer(sjt, res, type_val)
	if type(res) == "table" then
		rep = ""

		-- Recherche de la formation
		for i = 1, #res do
			if (type_val == db_forma) then
				rep = rep.." un(e) "..get_forma(res, i)
				if i == #res-1 then rep = rep.." et"
				elseif i< #res then rep = rep.."," end
			else
				-- parti
				rep = rep.."du "..res[i]
				if i == #res-1 then rep = rep.." et " 
				elseif i < #res then rep = rep..", "end
			end
		end
		fill_response(txt.get_mdl(type_val), type_val, sjt, rep)
		
	else
		fill_response(txt.get_mdl(type_val), res, sjt, res)
	end
end


-- réponse pas assez humaine
function get_forma(res, i)
	local  date = search_in_db(res, i, "date")
	local  name = search_in_db(res, i, "name")

	t = ""

	if (name ~= -1) then t = t..name.." " end
	if (date ~= -1) then t = t.."en "..date end
	
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
	table.insert(dialog, dialog.quest)
	table.insert(dialog, ec_gen)	

	if enable_hist then print(historique()) end
end


function init_rep()

	reponse = {model= {}, sjt= {}, res= {}, gen= {}}
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
	local h = ""
	for index,value in pairs(dialog) do
		res = ""
		if type(value) == "table" then
			for i, v in pairs(value) do
				res = res..v..", "
			end
		else res = value end

		h = h..index.."\t"..res.."\n"

		if index == #dialog then h = h.."\n" end
	end
	return h.."\n"
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