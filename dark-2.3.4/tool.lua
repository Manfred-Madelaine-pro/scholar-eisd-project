local tool = {}


-- Renvoie un tag
function tool.get_tag(tag)
	return "#"..tag
end


-- Cree l'ensemble des lexiques
function tool.create_lex(f_data)
	tool.new_lex(place, f_data)
	tool.new_lex(temps, f_data)
	tool.new_lex(month, f_data)
	tool.new_lex(ppn, f_data)
	tool.new_lex(fin, f_data)
end


function tool.new_lex(tag, f_data)
	main:lexicon(tool.get_tag(tag), f_data..tag..".txt")
end


function tool.save_db(db, filename)
	local out_file = io.open(filename..".lua", "w")
	out_file:write("return ")
	out_file:write(serialize(db))
	out_file:close()
end


function tool.load_db(filename)
	local db = dofile(filename..".lua")

	print(serialize(db))
	return db
end


return tool