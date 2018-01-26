local sp = {}

-- importation d'un module
local struct = require 'structure'


function sp.analyse_seq(seq)
	--seq:dump()
	pers = struct.Personne()
	s = seq:tag2str("#NAME")
	if s[1] ~= nil then
		pers = sp.create_pers(seq)
		struct.print_struct(pers)
	end
	return pers
end


function sp.create_pers(seq)
		name = sp.get_elem(seq, "#NAME", "#FIRSTNAME")
		lastname = sp.get_elem(seq, "#NAME", "#POS=NNP")
		birth = sp.get_elem(seq, "#BIRTH")
		death = sp.get_elem(seq, "#DEATH")
		birthplace = sp.get_elem(seq, "#BIRTHPLACE")
		return struct.Personne(name, lastname, birth, death, birthplace)
end


function sp.get_elem(seq, tag_containing, tag_contained)
	return seq:tag2str(tag_containing, tag_contained)[1]
end


return sp