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
local t 	= require 'tool'
local txt	= require 'phrases'
local corr	= require 'corrector'
local lp	= require 'line_processing'


-- Variables globales
local turn = 0
local POS_KEY = 3
local dialog  = {}
local reponse = {}
local prev_key = nil
local enable_hist = true
local print_analyse = true

local data_version = {"databaseFinal", "databaseBeta"}


-- Main
function bot.start(lst_attributs)
	l_attributs = lst_attributs

	db = dofile(data_version[2]..".lua")

	line = ""

	while(line ~= "1" or line ~= "2" or line ~= "q" ) do
		print(mode)
		io.write("> ")
		line = "2"
		--io.read()
		if(line == "1")	then
			t.init(txt.pick_mdl(start))
			chat_loop()
		elseif (line == "2") then
			t.init(txt.pick_mdl(start))
			test_fonctionnel()
		elseif (line == "q") then
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
		"$help", "sep",

			--- Cas Simple & Normal --- 
		-- un element
		"LIEU DE NAISSANCE ?","sep", --nettoyage basique des questions
		"Parlons de Laguiller s'il te plait.",
		-- substitution du sujet
		"quelle est sa date de naissance ?","sep",
		-- Elements multiples 
		"Laguiller et toi ?", "sep", -- plusieurs cle
		-- croisement clé attribut 
		"de quel bord politique sont melenchon et macron ?",
		"quelle est la date de naissance de Melenchon ? et sa formation ?", "sep",
		


			--- Cas Spécial --- 
		"qui sont les createurs d'ugoBot ?",
		"et les miens ?", "sep",
		-- réponse double fusionnée
		"qui sont les créateurs de Macron et Mélenchon ?",
		-- Small talk
		"Quelle est la réponse à la grande question sur la vie, l'univers et tout le reste ?",
		--historique
		"affiche moi l'historique", "sep",
		

		
			--- Cas Complexe --- 
		"Lieu de naissance de Mélenchon et qui sont tes créateurs ?","sep",
		"la date de naissance et le lieu de naissance de Melenchon ainsi que lieu de naissance de Macron ?",
		"quels sont les partis auquels Melenchon et Macron ont été membre ?",		
		-- chercher une information secondaire
		"quand Macron et melenchon ont-ils eu leur Baccalauréat ?",



			--- Cas Limites du systèle de dialogue ---
		-- clef icorrecte
		"quelle est la date de naissance de Dominique ?",
		-- attribut incorrect
		"quand glotin a-t-il eu sa Licence ?",


		-- exit
		"au revoir et merci de votre attention ! :) ",
	}
	
	local t_preuve = {
		-- gestion des pronoms 
		--"fillon date de naissance et ou ?", "sep",
		"jean -luc melenchon profession ?", 
		"jean - francois de fillon date de naissance ?", "sep",
		"laguiller date de naissance?", 
		"melenchon profession ?", 
		"emmanuel macron formation?", 
		" ou ?", 
		"formation ?", 
		"ou ?", "sep", 

		-- Fillon troll
		"Quelle est la formation de Fillon ? et ses professions ?", "sep",

		--"quels sont les partis auquels Melenchon et Macron ont été membre ?",	
		"quand melenchon est-il mort ?", "sep",
		"quand laguiller est-elle morte ?", 

		-- s'adresser au S de D de différentes façon 
		"qui sont tes createurs ?",
		"quelles sont les professions de macron et quelle est la formation de melenchon ?",
		"jean-luc formation ?",
		"melenchon parti politique ?",
		"laguiller parti politique ?",
		"jean-francois formation ?",
		"fillon parti politique ?",
		"fillon bord ?",
		"fillon professions ?",
		"la date de naissance et le lieu de naissance de Melenchon ainsi que lieu de naissance de Macron ?",
		--bugg corrigé
		"fillon date de naissance et fillon ou ?", "ou", "ou",	
		"macron date de naissance et melu ou ?", "ou", "ou",	
	}

	local t_simple = {	
		--bug
		"Lieu de naissance de Mélenchon et qui sont tes créateurs et les miens ainsi que la date de naissance de melenchon ?","sep",
		"Lieu de naissance de Mélenchon et qui sont tes créateurs et les miens ainsi que la date de naissance de melenchon et la formation de macron ?","sep",

	}

	for i, line in pairs(t_preuve) do	
		init_rep()
		print("> "..line)

		bot_processing(line)
		io.read()		
	end
end


-- Traitement d'une ligne de texte par le systeme de dialogue
function bot_processing(line)
	dialog.quest = "quest  = "..line

	-- traitement de la ligne de texte
	line = lp.formatage(line)
	seq = lp.process(line)
	if(print_analyse) then print(seq:tostring(tags)) end

	return contextual_analysis(seq)
end


function contextual_analysis(question)
	if not cas_complexe(question) then
		-- on commence par recuperer les donnees hors contexte
		dialog.hckey   = find_elm(question, l_sujets, true)
		dialog.hctypes = find_elm(question, l_attributs, false)

		dialog.eckey, dialog.ectype = dialogue(dialog.eckey, dialog.ectype, dialog.hckey, dialog.hctypes)

		-- on rempli le paterne choisi et l'affiche a l'ecran
		create_answer(reponse)
	end
	return check_exit()
end


-- la question est elle meme composee de deux questions ou plus
function cas_complexe(question)
	if (#question[t.tag(gram_Qdouble)]) == 0 then return false end

	local l_questions = t.tagstr(question, t.tag(gram_sous_quest))
	dialog.hckey, dialog.hctypes, dialog.eckey, dialog.ectype = {}, {}, {}, {}

	for i, quest in ipairs(l_questions) do
		quest = lp.process(quest)

		dialog.hckey  [#dialog.hckey  +1] = find_elm(quest, l_sujets, true)
		dialog.hctypes[#dialog.hctypes+1] = find_elm(quest, l_attributs, false)	

		dialog.eckey[i], dialog.ectype[i] = dialogue(dialog.eckey[i], dialog.ectype[i], dialog.hckey[i], dialog.hctypes[i])
	end

	create_answer(reponse)
	return true
end


function dialogue(eckey, ectype, hckey, hctypes)
	-- on fait le lien entre hors contexte et en contexte
	eckey, ectype = hc_to_ec(eckey, ectype, hckey, hctypes)

	-- on definie le paterne de la reponse 
	analyse_elm(ectype, eckey, true)
	
	-- gere le changement de sujet par il pour une double phrase
	update_prev_key(eckey)
	return eckey, ectype
end


-- garde en memoire la precedente clef utilisee
function update_prev_key(current_key)
	if (current_key and #current_key == 1) then
		prev_key = current_key[#current_key]
	elseif (current_key and type(current_key ~= "table")) then
		prev_key = current_key
	else prev_key = nil end
end


function find_elm(question, l_elm, is_key)
	local res = {}
	-- On cherche les sujets dans la phrase ou les questions posees
	for i, att in pairs(l_elm) do	
		-- sujets
		if is_key then
			if (#question[t.tag(att)]) ~= 0 then
				for i,v in ipairs(question[t.tag(att)]) do
					res[#res+1] = question:tag2str(t.tag(att))[i]
				end
			end
		-- questions
		else
			if (#question[t.tag(t.qtag(att))]) ~= 0 then
				res[#res+1] = att
			end
		end
	end
	return res
end


function hc_to_ec(eckey, ectype, hckey, hctypes)
	-- lien Hors context vers En context sur les clés
	eckey = update_context(hckey, hctypes, eckey)

	-- lien Hors context vers En context sur les types
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

-- TODO
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
					--TODO
					local vrb = "NUUUL"
					if(#reponse[balise] >= 1) then
						vrb = reponse[balise][#reponse[balise]]
					end
					modifie = txt.fill_mdl(mdl, balise, vrb)
				end

				-- on actualise le modele uniquement s'il y a du nouveau
				if (modifie) then mdl = modifie end
			end
		end
		-- on ajoute le modele rempli au resultat final
		res[#res+1] = mdl
	end

	t.rm_doublon(res)	
	rep = ""

	for i, v in pairs(res) do 
		rep = rep..v 

		-- TODO : améliorer la transition entre 2 réponses
		if i == #res-1 then
			rep = rep.."\nEt, " 
		else rep = rep.."\n" end 
	end

	t.bot_answer(rep)
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
	local current_key = key
	-- analyse des types
	if is_key and key and typ then analyse_elm(key, typ, not is_key)

	-- choix du paterne
	elseif is_special(typ) then
		cas_special(typ, key) 
		current_key = typ

	elseif is_special(key) then cas_special(key, typ) 

	elseif key and typ == nil then search_pattern(key, nil)

	elseif key then
		search_pattern(typ, key)
		current_key = typ

	elseif typ then
		res = "cette information"
		if(#typ > 1) then res = "ces informations" end

		fill_response(mdl_Qinfo, "quel politicien", res)

	else fill_response(mdl_idk, "idk") end

	update_prev_key(current_key)	
end


-- Rempli les attributs necessaires a la generation de la reponse
function fill_response(mdl, gen, sjt, res, vrb)
	reponse.model[#reponse.model + 1] = txt.pick_mdl(mdl)
	reponse.sjt[#reponse.sjt + 1] = sjt
	reponse.res[#reponse.res + 1] = res
	reponse.gen[#reponse.gen + 1] = gen 
	reponse.vrb[#reponse.vrb + 1] = vrb 
end


function is_special(elem)
	local res = false 
	local tab = {l_tutoiement, l_user, l_life, l_hist, l_fin}
	
	for i, att in pairs(tab) do
		if t.in_list(elem, att) then
			res = true
			break
		end
	end
	if (elem == "$ help") then res = true end
	
	return res
end


function cas_special(key, att)
	local m_key = key
	local m_mdl = ""
	local m_tutoie, m_user = false, false

	-- vérifications 
	if t.in_list(key, l_tutoiement) then m_tutoie = true
	elseif t.in_list(key, l_user) then m_user = true
	elseif t.in_list(key, l_fin) then 
		fill_response(mdl_exit, "exit")
		return true
	elseif t.in_list(key, l_hist) then 
		sjt = historique()
		fill_response(mdl_hist, key, sjt)
		return true
	elseif t.in_list(key, l_life) then 
		fill_response(mdl_life, "life")
		return true
	elseif key == "$ help" then
		fill_response(mdl_help, "help")
		return true
	else return false end

	-- traitement
	if not att then
		if m_tutoie then m_key = "moi" end
		fill_response(mdl_Qatt, "quelle information", m_key)

	-- Question sur les createurs 
	elseif att == hdb_createurs and ( m_tutoie or m_user) then
		tab, res = "\n\t", ""
		
		if m_tutoie then
			m_mdl = mdl_creatr_b
			for i, att in pairs(l_dev) do
				res = res..tab..att
			end
		else m_mdl = mdl_creatr_u end

		fill_response(m_mdl, "createurs", "", res)
		
	else
		if m_tutoie then m_mdl = mdl_no_rep
		else m_mdl = mdl_no_gere end

		fill_response(m_mdl, "non_gere")
	end
	return true
end


function search_pattern(key, att)	
	if not att then
		fill_response(mdl_Qatt, "quelle_information", key)

	--Attribut secondaire
	elseif t.in_list(att, att_secondaires) then
		search_tag_sec(key, att)
	else
		-- On cherche les questions posees dans la phrase
		for i, m_att in pairs(l_attributs) do	
			if search_tag(key, m_att, att) then break end
		end		
	end
end


function search_tag(key, att, q_tag)
	if att ~= q_tag then return false end

	local res, part, name, firstname = -1, "", "", ""

	local key_value =  lp.search_pol(corr.corrector(key))
	local att_value = corr.corrector(q_tag)

	if (key_value == -1) then key_value = corr.corrector(key)
	else
		res       = search_in_db(db, key_value, att_value)
		part      = get_particule(db, key_value, "Il/Elle")
		name      = search_in_db(db, key_value, db_name)
		firstname = search_in_db(db, key_value, db_fname)
	end

	if res == 0 then
		if(att_value == db_death) then
			fill_response(mdl_alive, "vivant", name, part)
		else
			fill_response(mdl_t_err, "att_error ", att_value)
		end
	elseif res == -1 then
		if type(key_value) == "table" then key_value = key_value[1] end
		fill_response(mdl_k_err, "key_error : "..key_value, key_value)
	else
		-- Choix du pronom à utiliser
		if key == prev_key then	gen_answer(part, res, att_value)

		else gen_answer(firstname.." "..name, res, att_value) end
	end

	return true
end


-- recherche d'attribut secondaire
function search_tag_sec(key, att)
	if att ~= date_sec then return false end

	local res, part, name, firstname = -1, "", "", ""

	local key_value =  lp.search_pol(corr.corrector(key))
	local att_value = "formation"

	if (key_value == -1) then key_value = corr.corrector(key)
	else
		res       = search_in_db(db, key_value, att_value)
		name      = search_in_db(db, key_value, db_name)
		part      = get_particule(db, key_value, "Il/Elle")
		firstname = search_in_db(db, key_value, db_fname)
	end

	if res == 0 then
		fill_response(mdl_t_err, "att_error : ", att_value)
	elseif res == -1 then
		fill_response(mdl_k_err, "key_error : "..key_value, key_value)
	else
		att_value = "bac"
		local pos = t.get_pos(res, att, "Baccalaureat")
		if pos > 0 then
			res = att_value.." en "..search_in_db(res, pos, "date")
		else res = "non" end
		
		-- TODO test Choix du pronom à utiliser
		if key == prev_key then	gen_answer(part, res, att_value)

		else gen_answer(firstname.." "..name, res, att_value) end
	end
end


-- Genere une reponse a partir d'un tableau ou d'un string
function gen_answer(sjt, res, attribut_val)
	if type(res) == "table" then
		rep = ""
		vrb = #res.." "..attribut_val.."(s)"

		local l_func = {
			[db_forma] = get_forma,
			[db_parti] = get_parti,
			[db_prof] = get_prof,
			[db_bord] = get_bord,
		}

		-- Recherche de la formation
		for i = 1, #res do
			for att, get_func in pairs(l_func) do
				if (attribut_val == att) then
					rep = rep..get_func(res, i)
				end
			end

			if i == #res-1 then rep = rep.." et " 
			elseif i < #res then rep = rep..", "end
		end
		fill_response(txt.get_mdl(attribut_val), attribut_val, sjt, rep, vrb)
		
	else
		fill_response(txt.get_mdl(attribut_val), res, sjt, res)
	end
end


-- Récupère les informations sur la profession
function get_prof(res, i)
	local inti = search_in_db(res, i, "intitule")
	local date_f = search_in_db(res, i, "date_fin")

	local t = ""

	if (no_err(inti)) then t = t..inti.."" end
	if (date_f == 0) then t = t.." (toujours en fonction)" end
	
	return t
end


-- Récupère les informations sur la formation
function get_forma(res, i)
	local date = search_in_db(res, i, "date")
	local name = search_in_db(res, i, "name")
	local part = get_particule(res, i, "un(e)")

	local t = ""

	if (no_err(name)) then t = t..part.." "..name end
	if (no_err(date)) then t = t.." obtenu(e) en "..date end
	
	return t
end


-- Récupère les informations sur la formation
function get_parti(res, i)
	local name = search_in_db(res, i, "nom")
	local acc = search_in_db(res, i, "acronyme")
	local part = get_particule(res, i, "le/la")

	local t = ""
	if (no_err(name)) then t = t..part.." "..name end
	if (no_err(acc)) then t = t.." ("..acc..")" end
	
	return t
end


function get_bord(res, i)
	local name = search_in_db(res, i, "name")
	local part = get_particule(res, i, "")

	local t = ""
	if (no_err(name)) then t = t..part.." "..name end
	
	return t
end


function get_particule(res, i, ecrit_inclu)
	local  part = search_in_db(res, i, "particule")
	if (not no_err(part)) then part = ecrit_inclu end
	return part
end


function no_err( va )
	return va ~= -1 and va ~= 0
end


function update_history()
	local ec_gen = dialog.gen    or "no ans"
	local ec_key = dialog.eckey  or "no key"
	local ec_att = dialog.ectype or "no att"
	turn = turn+1

	table.insert(dialog, turn)
	table.insert(dialog, ec_key)
	table.insert(dialog, ec_att)
	table.insert(dialog, dialog.quest)
	table.insert(dialog, ec_gen)	

	if enable_hist then print(historique()) end
end


function init_rep()

	reponse = {model= {}, sjt= {}, res= {}, gen= {}, vrb= {}}
end


function check_exit()
	for i, e in pairs(dialog.hckey) do
		if t.in_list(e, l_fin) then return false end
	end
	return true
end


function historique()
	local h = ""
	for index,value in pairs(dialog) do
		res = recursive_loop(value)
		h = h..index.."\t"..res.."\n"

		if index == #dialog then h = h.."\n" end
	end
	return h.."\n"
end


function recursive_loop(value)
	res = ""
	if type(value) == "table" then
		for i, v in pairs(value) do
			res = res..recursive_loop(v)..", "
		end
	else res = value end
	return res
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