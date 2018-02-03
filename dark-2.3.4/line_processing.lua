local lp = {}

local c = require 'clean'
local seq_pocess = require 'seq_processing'


-- Analyse d'un bout de phrase
function lp.process(main, sen, tags)
	sen = sen:gsub("%p", " %0 ")
	local seq = dark.sequence(sen)
	main(seq)
	return seq 
end


function lp.split_sentence(main, line, tags)
	-- Nettoyage des accents
	line = c.cleaner(line)
	-- Decoupage de la phrase en plusieurs segments selon la ponctuation
	for sen in line:gmatch("(.-[.?!])") do
		seq = lp.process(main, sen, tags)
		print(main(seq):tostring(tags))
	end
end

-- Lecture des fichiers du corpus
function lp.read_corpus(main, corpus_path, tags)
	for f in os.dir(corpus_path) do
		for line in io.lines(corpus_path.."/"..f) do
			if line ~= "" then
				lp.split_sentence(main, line, tags)
			end
		end
	end
end


return lp

-- faire une fonction de normalisation pour:
-- heuteur, date 
-- afin de pouvoir faire des conersions
--conversion ides données pour rentrer dans la db et avoir un unique type
-- conversion pour afficher comme ce que l'utilisateur veut
