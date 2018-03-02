local lp = {}

local c = require 'clean'

fichierCourant = ""
prenom = ""


-- Analyse d'un bout de phrase
function lp.process(sen)
	sen = sen:gsub("%p", " %0 ")
	sen = c.cleaner(sen)
	local seq = dark.sequence(sen)
	main(seq)
	return seq 
end

function lp.split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
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
		traitement(seq, fichierCourant, prenom)
	end
end


-- Lecture des fichiers du corpus
function lp.read_corpus(corpus_path)
	local fic = ""
	for f in os.dir(corpus_path) do
		fic = lp.split(f, ".")[1]
		prenom = lp.split(fic, "_")[1]
		fichierCourant = lp.split(fic, "_")[2]
		print(f)
		for line in io.lines(corpus_path.."/"..f) do
			if line ~= "" then
				lp.split_sentence(line)
			end
		end
	end
end


return lp
