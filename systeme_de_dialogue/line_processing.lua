local lp = {}

local t = require 'tool'
local c = require 'clean'

local MAX_INFO_TOPRINT = 1

local fichierCourant = ""
local prenom = ""

lp.prev_key = ""
local prev_ukey = ""


-- Analyse d'un bout de phrase
function lp.process(sen)
	sen = sen:gsub("%p", " %0 ")
	local seq = dark.sequence(sen)
	main(seq)
	return seq 
end


function lp.split(inputstr, sep)
        if sep == nil then sep = "%s" end

        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
        end
        return t
end


function lp.split_sentence(line)
	-- Decoupage de la phrase en plusieurs segments selon la ponctuation
	for sen in line:gmatch("(.-[.?!])") do
		seq = lp.process(sen)
		--print(main(seq):tostring(tags))
		traitement(seq)
	end
end


-- Lecture des fichiers du corpus
function lp.read_corpus(corpus_path)
	local fic = ""
	for f in os.dir(corpus_path) do
		--fic = lp.split(f, ".")[1]
		--prenom = lp.split(fic, "_")[1]
		--fichierCourant = lp.split(fic, "_")[2]
		print(f)
		for line in io.lines(corpus_path.."/"..f) do
			if line ~= "" then
				lp.split_sentence(line)
			end
		end
	end
end


-- Generation de la cle unique a partir du nom & prenom d'un politicien
function lp.gen_key(name, firstname)
	local u_key = lp.formatage(firstname.."_"..name)
	local txt = u_key:gsub(" ", "_")

	if (txt ~= u_key) then u_key = txt end
	return u_key
end


function lp.formatage(line)
	return string.lower(c.cleaner(line))
end


-- Cherche sur quel politicien l'utilisateur souhaite avoir des infos   
function lp.search_pol(key)
	local found = -1

	-- liste des politiciens contenant cette cle dans leur nom ou prenom
	local l_pol = {}
	if (key ~= lp.prev_key and prev_ukey ~= -1) then 
		l_pol = get_list_pol(key) 
	else found = prev_ukey end

	-- choix parmi ces politiciens (si 1 seul next)
	if (#l_pol > 1) then
		-- demander a l'utilisateurde choisir 
		found = choose_pol(l_pol)

	elseif (#l_pol == 1) then
		found = lp.gen_key(l_pol[1].name, l_pol[1].firstname)
	end

	lp.prev_key, prev_ukey = key, found 

	return found
end


function get_list_pol(key)
	local res, nb_nom = {}, 2

	if(type(key) == "table") then key = key[1] end

	key = key:gsub(" %p ", "-")
	local count, max_nom = #lp.split(key), 1
	local l_part = {"de", "le", "la"}

	for i, particule in ipairs(l_part) do
		if t.in_list(particule, lp.split(key, " ")) then max_nom = max_nom+1 end
	end

	for u_key, pol in pairs(db) do
		-- si on ne trouve pas de nom ni prénom pour le politicien
		if (not pol.name or not pol.firstname) then goto continue end

		local l_name = lp.split(lp.formatage(pol.name), " ")
		local l_fname = lp.split(lp.formatage(pol.firstname), " ")

		if (count > max_nom) then
			if type(key) ~= "table" then key = lp.split(key, " ") end
			-- on cherche un match exact entre nom & prenom du politicien
			-- et les 2 chaines de caracteres recuperees en cle
			if (t.in_list(key[1], l_fname) and t.in_list(key[2], l_name)) then
				res[#res+1] = { name = pol.name, firstname = pol.firstname}
			end
		
		elseif t.in_list(key, l_name) or t.in_list(key, l_fname) then
			res[#res+1] = { name = pol.name, firstname = pol.firstname}
		
		elseif (#lp.split(key) > 1) then 
			local temp = {}
			if type(key) ~= "table" then temp = lp.split(key, " ") end

			for i, nom in ipairs(temp) do
				if (not t.in_list(nom, l_part)) and (t.in_list(nom, l_name) or t.in_list(nom, l_fname)) then
					res[#res+1] = { name = pol.name, firstname = pol.firstname}
				end
			end
		end

		::continue::
	end

	return res
end


function choose_pol(l_pol)
	local res = ""
	for i, politicien in ipairs(l_pol) do
		res = res.."\n\t"..i..". "..politicien.firstname.." "..politicien.name
	end

	-- afficher les choix
	t.bot_answer("De qui parlez-vous exactement ? (q pour ne pas répondre)"..res)

	-- petites fonctions d'aide
	local f_helper = function(name, fname) return lp.gen_key(name, fname) end
	local quit = function(...) return -1 end
	
	local l_funct = {}
	for i=1, #l_pol do l_funct[tostring(i)] = f_helper end
	l_funct["q"] = quit

	-- boucle d'affichage & de choix
	return lp.pick_a_point(l_pol, l_funct)
end


function lp.pick_a_point(l_pol, l_func)
	local rep, nb_choice = "", #l_pol
	local l_point, r = {}, -1
	
	for i=1, nb_choice do l_point[#l_point+1] = tostring(i) end
	l_point[#l_point+1] = "q"

	while(not t.in_list(rep, l_point)) do
		io.write("> ")
		rep = io.read()
		
		-- appel de la fonction
		if(t.in_list(rep, l_point)) then 
			local i, name, fname = tonumber(rep), "", ""

			if i then name, fname = l_pol[i].name, l_pol[i].firstname end
			r = l_func[rep](name, fname)

			return r	

		else print("réponse non valide\n") end
	end
end


return lp
