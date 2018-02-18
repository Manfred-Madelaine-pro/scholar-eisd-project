local tool = {}


-- Renvoie un tag
function tool.tag(tag)
	return "#"..tag
end

-- Renvoie le tag d'une question
function tool.qtag(tag)
	return "Q"..tag
end


-- Renvoie la balise d'un
function tool.bls(tag)
	return "<"..tag..">"
end

-- Lancer le systeme de dialogue
function tool.init(txt)
	local s = " ---- "
	print("\n\t"..s..bvn..s.."\n")
	bot_answer(txt)
end


-- Reponse du systeme de dialogue
function bot_answer(answer)
	print(BOT_NAME.." : "..answer.."\n")
end



-- Cree l'ensemble des lexiques
function tool.create_lex(f_data)
	tool.new_lex(place, f_data)
	tool.new_lex(temps, f_data)
	tool.new_lex(month, f_data)
	tool.new_lex(ppn, f_data)
	tool.new_lex(neg, f_data)
	tool.new_lex(fin, f_data)
end


function tool.new_lex(tag, f_data)
	main:lexicon(tool.tag(tag), f_data..tag..".txt")
end


function tool.list_tags(l_tags, is_quest)
	res = ""
	for i, tag in pairs(l_tags) do
		if is_quest then
			tag = tool.qtag(tag)
		end
		res = res..tool.tag(tag)
		if i < #l_tags then res = res.." | " end
	end
	return res
end


function tool.save_db(db, filename)
	local out_file = io.open(filename..".lua", "w")
	out_file:write("return ")
	out_file:write(serialize(db))
	out_file:close()
end


function tool.in_list(elm, list)
	for i, e in pairs(list) do	
		if e == elm then return true end
	end
	return false
end


function tool.key_is_used(tab, key)
	if(type(tab) == "table") then
		for i, att in pairs(tab or {}) do	
			if (key == att) then return true end
		end
	end
	return false
end


-- deprecated
function tool.rm_doublon(tab)
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


function tool.print_table(res)
	if type(res) == "table" then
		for index,value in pairs(res) do
			if type(value) == "table" then
				print("table "..index)
				print_table(value)
				print()
			else
				print(index, value)
			end
		end
	else
		print(res)
	end
end


-- Redéfiniton de la fonction de dark pour permettre l'utilisation de regex dans les fichiers de lexique
function dark.lexicon(tag, list)
	-- Vérifier que les arguments sont valides et si un fichier est fourni à la place d'une table, charger son contenu
	if type(tag) ~= "string" or not tag:match("^%#[%w%=%-]+$") then
		error("missing or invalid tag name", 2)
	end
	if type(list) == "string" then
		local tmp = {}
		for line in io.lines(list) do
			tmp[#tmp + 1] = line
		end
		list = tmp
	elseif type(list) ~= "table" then
		error("invalid argument to lexicon", 2)
	end
	-- Convertir les éléments dans la liste en une séquence de tokens qui correspond à la construction d'un pattern
	local pat = {}
	for id, seq in ipairs(list) do
		seq = seq:match("^%s*(.-)%s*$")
		if seq ~= "" then
			seq = seq:gsub('/', '//'):gsub('%s+', '/ /')
			pat[#pat + 1] = '/^'..seq..'$/'
		end
	end
	-- Création du pattern afin de remplacer la liste de token
	if #pat == 0 then
		return function(seq) return seq end
	end
	pat = dark.pattern("["..tag.." "..table.concat(pat, " | ").."]")
	return function(seq)
		return pat(seq)
	end
end


return tool