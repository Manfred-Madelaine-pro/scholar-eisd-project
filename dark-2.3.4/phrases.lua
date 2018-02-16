local txt = {}

local sujet = "<sujet>"
local date  = "<date>"

local liste_phrases = {sujet.." est né le "..date}
local balises = {sujet, date}

BOT_NAME     = "ugoBot"

bvn = "Bienvenu dans le Chatbot de CDK, MFD, LAO & UGO"

start = {
	"Bonjour ! Je suis l'As des Politiciens Français. Comment puis-je vous aider ?",
	"Bonjour, je m'appelle "..BOT_NAME..", que puis-je faire pour vous ?",
	"Rebonjour ;)",
	"Salut ! :)",
}

function change(sen, ...)
	local arg = {...}
	for i, champ in ipairs(arg) do
		sen = sen:gsub(balises[i], champ)
	end
	print(sen)
end

function txt.exec()
	for i, phrase in pairs(liste_phrases or {}) do	
		if phrase ~= "" then
			change(phrase, "Manfred", "01/08")
		end
	end
end


-- Choisi de façon aleatoire un element de la liste
function txt.pick_sen(tab_sen)
	math.randomseed(os.time())
	val = math.random(1, #tab_sen)
	return tab_sen[val]
end


return txt