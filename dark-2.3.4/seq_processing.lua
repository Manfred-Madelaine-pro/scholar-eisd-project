local sp = {}

-- importation d'un module
local tool = require 'tool'


function sp.analyse_seq(seq)
	-- analyser seq pour sortir
	if(check_exit(seq)) then
		return -1
	elseif check_question(seq) then
		return 1
	else
		return 0
	end	
end


-- Verifie si la  sequence contient un token d'exit
function check_exit(seq)
	if get_elem(seq, tool.get_tag(fin)) then
		return true
	end
	return false
end


-- Verifie si la seqence contient un token de question
function check_question(seq)
	if get_elem(seq, tool.get_tag(quest)) then
		return true
	end
	return false
end


function get_elem(seq, tag_containing, tag_contained)
	return seq:tag2str(tag_containing, tag_contained)[1]
end


return sp


--[[
function sp.create_pers(seq)
		name = sp.get_elem(seq, "#NAME", "#pnominal")
		lastname = sp.get_elem(seq, "#NAME", "#POS=NNP")
		birth = sp.get_elem(seq, "#BIRTH")
		death = sp.get_elem(seq, "#DEATH")
		birthplace = sp.get_elem(seq, "#BIRTHPLACE")
		return struct.Personne(name, lastname, birth, death, birthplace)
end


function write_file(file, db)
	local out_file = io.open(file..".lua", "w")
	out_file:write("return ")
	out_file:write(serialize(db))
	out_file:close()

end


function load_file(file)
	local db = dofile(file..".lua")
end


pers = struct.Personne()
	s = seq:tag2str("#NAME")
	print(s)
	if s[1] ~= nil then
		pers = sp.create_pers(seq)
		struct.print_struct(pers)
	end
	return pers
]]