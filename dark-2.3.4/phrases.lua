local txt = {}

local tool = require 'tool'


local sjt = "sjt"
local res  = "res"
local vrb  = "vrb"

local balises = {sjt, res, vrb}

BOT_NAME     = "ugoBot"

bvn = "Bienvenu dans le système de dialogue  de CDK, MFD, LAO & UGO"

start = {
	"Bonjour ! Je suis "..BOT_NAME..", l'As des Politiciens Français. Comment puis-je vous aider ?",
	"Bonjour, je m'appelle "..BOT_NAME..", que puis-je faire pour vous ?",
	"Rebonjour ;)",
	"Salut ! :)",
	"cc cv ? ASVB stp ;)"
}

mode = "Choissez un mode :\n\z
	\t 1 - Mode Interactif\n\z
	\t 2 - Mode Test\n\z
"


-- Models
mdl_birth = {
	tool.bls(sjt).."est né le "..tool.bls(res)..".",
}
mdl_birthp = {
	tool.bls(sjt).."est né à "..tool.bls(res)..".",
	tool.bls(sjt).."est originaire de "..tool.bls(res)..".",
}
mdl_forma = {tool.bls(sjt).."a pour formation: "..tool.bls(res).."."}
mdl_Qparti = {tool.bls(sjt).."a été membre "..tool.bls(res).."."}

mdl_Qtype = {"Que souhaitez vous savoir sur "..tool.bls(sjt).." ?"}

mdl_Qinfo = {
	"Sur quel politicien voulez-vous "..tool.bls(sjt).." ?",
	"Sur qui voulez-vous "..tool.bls(sjt).." ?",
}

mdl_idk = {
	"veuillez m'excuser, mais je n'arrive pas à comprendre votre question. Pouvez-vous la reformuler ?",
	"Il semblerait que je n'arrive pas à comprendre votre question :/. Pouvez-vous la reformuler ?",
	"Je ne vois vraiment pas quoi vous répondre :(",
	"Error 404 incorrect sentence, sorry...",
	"Comment puis-je répondre à cela ?",
	"Nani ?",
}


mdl_life = {
	"La puissance de calcul de cet ordinateur n'est pas assez grande pour me permettre de résoudre ce problème...",
	"Hum, laissez-moi réfléchir… 42 !",
}

mdl_help = {
	"Vous pouvez poser une question sur :\n\z
		\tun politicien français\n\z
		\tle systeme de dialogue, c-à-d moi "..BOT_NAME.."\n\z
		\tl'utilisateur, c-à-d vous\n\z
		\tou sur plusieurs des individus cités ci-dessus\n\n\z

	Les informations que vous pouvez demander sont les suivantes :\n\z
		\tla date et/ou le lieu de naissance\n\z
		\tla formation\n\z
		\tles créateurs (développeurs du système de dialogue ou parents)\n\z
		\tles partis politiques auxquel le politicien a adhéré\n\n\z
	
	Vous pouvez également quiter le dialogue en disant me 'au revoir'.\z	
	"
}

mdl_no_rep = {
	"Je ne répondrai pas à cette question, vous êtes trop indiscret !",
	"Comme si j'allais répondre à ça...",
	"Eh ! non mais... ça ne se pose pas comme question !",
	"Cette information sur moi est confidentielle, je ne peux pas la révéler :("
}

mdl_creatr_b = {"Mes vénérables créateurs sont "..tool.bls(res).."\n\nJe les remercie sincèrement de m'avoir donné vie."}
mdl_creatr_u = {
	"Vos créateurs sont vos parents bien sûr !",
	"Et bien ma foi, ce sont vos parents je présume.",
}

mdl_t_err = {"Désolé, je n'ai pas d'information sur "..tool.bls(sjt).."."}
mdl_k_err = {"Désolé, je n'ai pas ".. tool.bls(sjt).." dans ma base de politiciens."}

mdl_basic = {tool.bls(sjt).." -> "..tool.bls(res).."."}

mdl_hist = {"Voici l'historique de notre conversation : \n"..tool.bls(sjt)}

mdl_exit = {"Bye :P !", "à la prochaine :D !", "au revoir ;)", "ciao :3 !", "adieu T.T","bye-bye ^^", "à une prochaine fois :> "}


-- Remplace la balise passee en parametre par sa valeur
function txt.fill_mdl(model, balise, valeur)
	txt = ""
	for i, b in ipairs(balises) do
		if (b == balise) then
			txt = model:gsub(tool.bls(balise), valeur)
		end
	end
	if txt ~= model then
		return txt
	end
	return nil
end


-- Choisi de façon aleatoire un element de la liste
function txt.pick_mdl(tab_sen)
	math.randomseed(os.time())
	val = math.random(1, #tab_sen)
	return tab_sen[val]
end


function txt.get_mdl(nom)
	mdl = mdl_basic
	if (nom == "birthplace") then
		mdl = mdl_birthp
	elseif (nom == "birth") then
		mdl = mdl_birth
	elseif (nom == mdl_forma) then
		mdl = mdl_birth
	elseif (nom == "parti") then
		mdl = mdl_Qparti
	elseif (nom == "profession") then
		mdl = mdl_basic
	end
	return mdl
end


return txt