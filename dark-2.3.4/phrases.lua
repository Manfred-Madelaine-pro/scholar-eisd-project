local txt = {}

local tool = require 'tool'


local sjt = "sjt"
local res  = "res"
local vrb  = "vrb"

local liste_phrases = {tool.bls(sjt).." est né le "..tool.bls(res)}
local balises = {sjt, res, vrb}

BOT_NAME     = "ugoBot"

bvn = "Bienvenu dans le systeme de dialogue  de CDK, MFD, LAO & UGO"

start = {
	"Bonjour ! Je suis l'As des Politiciens Français. Comment puis-je vous aider ?",
	"Bonjour, je m'appelle "..BOT_NAME..", que puis-je faire pour vous ?",
	"Rebonjour ;)",
	"Salut ! :)",
}


-- Models
mdl_birth = {tool.bls(sjt).." est né le "..tool.bls(res)}
mdl_birthp = {tool.bls(sjt).." est né à "..tool.bls(res)}
mdl_forma = {tool.bls(sjt).." a pour formation: "..tool.bls(res)}
mdl_Qsjt = {"Que souhaitez vous savoir sur "..tool.bls(sjt).." ?"}

mdl_Qinfo = {"Sur quel politicien voulez-vous une information ?"}

mdl_idk = {
	"Je ne vois vraiment pas quoi vous répondre :(",
	"Comment puis répondre à cela ?",
	"Nani ?",
}

mdl_no_rep = {
	"Je ne répondrai pas à cette question, vous êtes trop indiscret !",
	"Comme si j'allais répondre à ça...",
	"Eh ! non mais... ça ne se pose pas comme question !"
}

mdl_creatr = {"Mes vénérables créateurs sont: "..tool.bls(res).."\n\nJe les remercie sincèrement de m'avoir donné vie."}

mdl_Qtype = {"Que souhaitez vous savoir sur "..tool.bls(sjt).." ?"}


mdl_no_gere = {
	"Cette information n'est pas encore gérée par le système.",
	"404 not found, sorry..."
}

mdl_t_err = {"Désolé, je n'ai pas cette information"}
mdl_k_err = {"Désolé, je n'ai pas ".. tool.bls(sjt).." dans ma base de politiciens."}

mdl_basic = {tool.bls(sjt).." : "..tool.bls(res)}

-- deprecated
function change(sen, ...)
	local arg = {...}
	for i, champ in ipairs(arg) do
		sen = sen:gsub(tool.bls(balises[i]), champ)
	end
	return sen
end


function txt.fill_mdl(model, bal, val)
	for i, b in ipairs(balises) do
		if (b == bal) then
			return model:gsub(tool.bls(bal), val)
		end
	end
	return model
end


-- deprecated
function txt.exec()
	for i, phrase in pairs(liste_phrases or {}) do	
		if phrase ~= "" then
			phrase = change(phrase, "Manfred", "01/08")
			print(phrase)
		end
	end
end
 

-- Choisi de façon aleatoire un element de la liste
function txt.pick_mdl(tab_sen)
	math.randomseed(os.time())
	val = math.random(1, #tab_sen)
	return tab_sen[val]
end


return txt