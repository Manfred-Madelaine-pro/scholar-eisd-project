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


-- deprecated
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