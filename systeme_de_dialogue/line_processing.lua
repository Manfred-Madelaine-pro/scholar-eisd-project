local lp = {}

local t = require 'tool'
local c = require 'clean'

local fichierCourant = ""
local prenom = ""
local MAX_INFO_TOPRINT = 1


-- Analyse d'un bout de phrase
function lp.process(sen)
	sen = sen:gsub("%p", " %0 ")
	--sen = lp.formatage(sen)
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
		print(main(seq):tostring(tags))
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
	local l_pol = get_list_pol(key)

	-- choix parmi ces politiciens (si 1 seul next)
	if (#l_pol > 1) then
		-- demander a l'utilisateurde choisir 
		found = choose_pol(l_pol)

	elseif (#l_pol == 1) then
		found = lp.gen_key(l_pol[1].name, l_pol[1].firstname)
	end

	return found
end


function get_list_pol(key)
	local res = {}
	t.print_table(key)
	if(type(key) == "table") then
		key = key[1]:gsub(" ", "")
	else key = key:gsub(" ", "") end

	for u_key, pol in pairs(db) do
		-- cas particuloier Jean-François de Fillon
		local l_name = lp.split(lp.formatage(pol.name), " ")
		local l_fname = lp.split(lp.formatage(pol.firstname), " ")

		if t.in_list(key, l_name) or t.in_list(key, l_fname) then
			res[#res+1] = { name = pol.name, firstname = pol.firstname}
		end
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

	-- TODO réduire l'affichage et afficher plus s'il le demande	

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
