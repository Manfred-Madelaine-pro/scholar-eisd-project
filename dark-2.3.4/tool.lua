local tool = {}

-- Renvoie un tag
function tool.get_tag(tag)

	return "#"..tag
end

-- Cree l'ensemble des lexiques
function tool.create_lex(main)
	local function new_lex(tag)
		main:lexicon(tool.get_tag(tag), file..tag..".txt")
	end
	new_lex(place)
	new_lex(temps)
	new_lex(month)
	new_lex(ppn)
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