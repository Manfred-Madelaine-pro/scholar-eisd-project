local corr = {}

function corr.corrector(word, l_filename)
	corr = word
	if word == "melu" then corr = "Melenchon" end
	
	for _, e in pairs(l_filename) do
		-- ouvrir le fichier contenant la liste de mots
		-- comparer "word" avec les mot contenu dans le fichier
		-- save la distance minimum trouvee et le mot associe
		-- si distance < seuil alors accepter la modification
		--si non renvoyer "word"
	end
	
	return corr
end


return corr