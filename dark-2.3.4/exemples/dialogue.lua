
dark = require("dark")

dofile("nlu.lua")
dofile("fonctions.lua")

-- Fonction pour récupérer la question de l'utilisateur
function getInput()
print("Bonjour !\n")
dialog_state = {}
turn = 0
print("Je connais tout sur les auteurs. Que voulez vous savoir? (ou appuyer q pour quitter)\n")
while true do
	question = io.read()
	if question == "q" or question == "Q"  then
		break;
	end
	question = question:gsub("(%p)", " %1 ")
	question = dark.sequence(question)
	pipe(question)
	print(pipe(question))
	-- contextual understanding
	-- on commence par recuperer hors contexte
	if (#question["#nomAuteur"]) ~= 0 then
		dialog_state.hckey = question:tag2str("#nomAuteur")[1]
	else
		dialog_state.hckey = nil
	end

	if (#question["#Qdate"]) ~= 0 then
		dialog_state.hctypes = "Qdate"
	elseif (#question["#Qauteur"]) ~= 0 then
		dialog_state.hctypes = "Qauteur"
	elseif (#question["#Qtitre"]) ~= 0 then
		dialog_state.hctypes = "Qtitre"
	else
		dialog_state.hctypes = nil
	end

	-- en contexte on veut rÃ©cupÃ©rer ssi on a au moins un Ã©lÃ©ment
	-- d'une autre classe (key ou types)
	if (dialog_state.hckey) then
		dialog_state.eckey = dialog_state.hckey
	elseif (dialog_state.hctypes) then
		-- on conserve la key prÃ©cÃ©dente
		dialog_state.eckey = dialog_state.eckey
	else
		dialog_state.eckey = nil
	end

	if (dialog_state.hctypes) then
		dialog_state.ectypes = dialog_state.hctypes
	elseif (dialog_state.hckey) then
		-- on conserve la key prÃ©cÃ©dente
		dialog_state.ectypes = dialog_state.ectypes
	else
		dialog_state.ectypes = nil
	end

	print(dialog_state.eckey, dialog_state.ectypes)
	turn = turn + 1
	table.insert(dialog_state, turn)
	table.insert(dialog_state, dialog_state.ectypes)
	table.insert(dialog_state, dialog_state.eckey)
	table.insert(dialog_state, dialog_state.gen)
	print(#dialog_state)
	for index,value in pairs(dialog_state) do
		print(index, value)
	end
		dialog_state.gen = {}
	-- on commence le dialogue
	if dialog_state.eckey then
		if dialog_state.ectypes == "Qdate" then
			keyValue = dialog_state.eckey
			typesValue = "birthdate"
			local res = getFromDB(keyValue, typesValue)
			local firstname = getFromDB(keyValue, "firstname")
				if res == 0 then
					print("DÃ©solÃ©, je n'ai pas cette information")
					dialog_state.gen = "ans = pas_info"
				elseif res == -1 then
					print("DÃ©solÃ©, je n'ai pas ".. keyValue.." dans ma base d'auteurs.")
					dialog_state.gen = "ans = pas "..keyValue
				else
					print(firstname, keyValue, "est nÃ© le ", res)
					dialog_state.gen = "ans = "..res
				end
			end
			if dialog_state.ectypes == "Qtitre" then
				keyValue = dialog_state.eckey
				typesValue = "livres"
				local res = getFromDB(keyValue, typesValue)
				local firstname = getFromDB(keyValue, "firstname")
				if res == 0 then
					print("DÃ©solÃ©, je n'ai pas cette information")
					dialog_state.gen = "ans = pas_info"
				elseif res == -1 then
					print("DÃ©solÃ©, je n'ai pas ".. keyValue.."dans ma base")
					dialog_state.gen = "ans = pas "..keyValue
				else
					print(firstname, keyValue, "a Ã©crit ".. #res .." romans :")
					dialog_state.gen = "ans = "..res
					-- c'est une table
					for i,elem in ipairs(res) do
						print(elem)
					end
				end
			end
		end
		if dialog_state.ectypes and not dialog_state.eckey then
			print("Sur quel auteur voulez-vous une information ?")
			dialog_state.gen = "ans = quel auteur"
		end
	end
end
getInput()

-- key = nomAuteur
-- types = Qauteur Qtitre Qdate
