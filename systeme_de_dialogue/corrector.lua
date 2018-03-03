local corr = {}

local c = require 'clean'

-- TODO delet l_filename
function corr.corrector(word, l_filename)
	corr = word

	if word == "melu" then corr = "melenchon" end
	
	--for _, e in pairs(l_filename) do
		-- ouvrir le fichier contenant la liste de mots
		-- comparer "word" avec les mot contenu dans le fichier
		-- save la distance minimum trouvee et le mot associe
		-- si distance < seuil alors accepter la modification
		--si non renvoyer "word"
	--end
	
	return corr
end


function corr.get_key(word)
	--[[
		parcourir DB
		if word == nom or word == prenom
			ajouter nom + prenom à liste politiciens

		if #liste pol == 1 return make_key(nom, prenom)
		else return choose_pol(liste_pol)

		choose_pol(liste_pol) renvoie le nom + prénom de pol selec ou -1
		if -1 quit : on ne veut personne 
	]]
end


return corr