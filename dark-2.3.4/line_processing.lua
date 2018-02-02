local lp = {}

local c = require 'clean'
local seq_pocess = require 'seq_processing'


-- Analyse la phrase du l'utilisateur
function sentence_processing()
	line = line:gsub("%p", " %1 ")
	print(main(line):tostring(tags))
	
end


function process(main, sen, tags)
	-- ajouter un espace de part et d'autre d'une ponctuation
	sen = sen:gsub("%p", " %0 ")

	local seq = dark.sequence(sen)
	main(seq)
	--eva.t2(seq, "#hauteur")
	--eva.t3(seq, "#NAME")
	--seq_pocess.analyse_seq(seq)	
	return seq 
end


function lp.split_sentence(main, line, tags)
	for sen in line:gmatch("(.-[.?!])") do
		seq = process(main, sen, tags)
		print(main(seq):tostring(tags))
	end
end




return lp

-- faire une fonction de normalisation pour:
-- heuteur, date 
-- afin de pouvoir faire des conersions
--conversion ides données pour rentrer dans la db et avoir un unique type
-- conversion pour afficher comme ce que l'utilisateur veut
