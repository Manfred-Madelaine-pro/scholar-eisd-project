local txt = {}

local tool = require 'tool'


BOT_NAME = "ugoBot"

local sjt = "sjt"
local res  = "res"
local vrb  = "vrb"

local balises = {sjt, res, vrb}


bvn = "Bienvenue dans le système de dialogue de CDK, MFD, LAO & UGO"

start = {
	"La route vers un dialogue naturel est droite.. mais la pente est forte ! \z
		Jessayerai donc de répondre au mieux à vos questions mais épargnez mes maladresses.",
	"Bonjour ! Je suis "..BOT_NAME..", l'As des Politiciens Français. Comment puis-je vous aider ?",
	"Qu'est-ce qu'un pléonasme me demanderez-vous ? He bien c'est dire d'un Macroniste qu'il est de droite !",
	"Il n'y a rien de plus terrible pour un soldat déjà anonyme que de mourir inconnu. - F. Hollande.",
	"Le pouvoir d'achat des Français s’est amélioré même s'ils ne s’en rendent pas compte. - M. Sapin",
	"Voici un Jeune et Beau projet Disruptif et Dynamique ! "..BOT_NAME.." se met En Marche !",
	"Pourquoi démissionner quand on est innocent ? - L'innocence, par J. Cahuzac.",
	"Bonjour, je m'appelle "..BOT_NAME..", que puis-je faire pour vous ?",
	"Je vous ai compris !! Que puis-je faire pour vous, habitant de Gaulle ?",
	"Salut ! :)",
}

mode = "Choisissez un mode : (q pour quitter)\n\z
	\t 1 - Mode Interactif\n\z
	\t 2 - Mode Test Fonctionnel\n\z
"


	-- Models --

mdl_birthp = {
	tool.bls(sjt).." est né à "..tool.bls(res)..".",
	tool.bls(sjt).." est originaire de "..tool.bls(res)..".",
}

mdl_Qinfo = {
	"Sur qui voulez-vous "..tool.bls(sjt).." ?",
	"Sur quel politicien voulez-vous "..tool.bls(sjt).." ?",
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
	"Hum, laissez-moi réfléchir… 42 !",
	"La puissance de calcul de cet ordinateur n'est pas assez grande pour me permettre de résoudre ce problème...",
}

mdl_help = {
	"Vous pouvez poser une question sur :\n\z
		\tun politicien français\n\z
		\tle systeme de dialogue, c-à-d moi "..BOT_NAME.."\n\z
		\tl'utilisateur, c-à-d vous\n\z
		\tou sur plusieurs des individus cités ci-dessus\n\n\z

	Les informations que vous pouvez demander sont les suivantes :\n\z
		\tla date et/ou le lieu de naissance\n\z
		\tla formation et/ou le bord politique\n\z
		\tles créateurs (développeurs du système de dialogue ou parents)\n\z
		\tles partis politiques auxquel le politicien a adhéré\n\z
		\tles professions d'un politicien\n\n\z
	
	Vous pouvez également quiter le dialogue en me disant 'au revoir'.\z	
	"
}

mdl_exit = {
	"à une prochaine fois :> ",
	"au revoir ;)", "ciao :3 !", 
	"adieu T.T",	"bye-bye ^^", 
	"Bye :P !", "à la prochaine :D !", 
}

mdl_no_rep = {
	"Comme si j'allais répondre à ça...",
	"Eh ! non mais... ça ne se pose pas comme question !",
	"Je ne répondrai pas à cette question, vous êtes trop indiscret !",
	"Cette information sur moi est confidentielle, je ne peux pas la révéler :("
}

mdl_creatr_u = {
	"Vos créateurs sont vos parents bien sûr !",
	"Et bien ma foi, ce sont vos parents je présume.",
}

mdl_bord = {
	tool.bls(sjt).." a pour bord : "..tool.bls(res)..".",
	tool.bls(sjt).." se situe du côté "..tool.bls(res)..".",
	tool.bls(sjt).." est du bord politique de "..tool.bls(res)..".",
}

mdl_forma = {
	tool.bls(sjt).." a pour formation "..tool.bls(res)..".",
	"La formation de "..tool.bls(sjt).." est "..tool.bls(res)..".",
	tool.bls(sjt).." a eu "..tool.bls(vrb).." à savoir, "..tool.bls(res)..".",
}

mdl_prof = {
	tool.bls(sjt).." a eu "..tool.bls(vrb).." à savoir, "..tool.bls(res)..".",
	"Les différentes professions que "..tool.bls(sjt).." a eu sont "..tool.bls(res)..".",
}

mdl_alive = {
	tool.bls(sjt).." est toujours vivant !", 
	tool.bls(sjt).." a encore de beaux jours à vivres voyez-vous !", 
	"Comment dire... "..tool.bls(sjt).." est toujours vivant en fait ^^'.", 
	"N'enterrez pas "..tool.bls(sjt).." trop tôt, "..tool.bls(res).." est encore en vie.", 
	"C'est-à-dire que "..tool.bls(sjt).." est encore en vie, pour le meilleur... et pour le pire !",
	"Figurez-vous que "..tool.bls(sjt).." n'est pas mort, "..tool.bls(res).." est bel et bien vivant !", 
}


mdl_no_gere = {"cette information n'est pas gérée."}

mdl_basic = {tool.bls(sjt).." -> "..tool.bls(res).."."}

mdl_bac = {tool.bls(sjt).." a eu son "..tool.bls(res).."."}

mdl_birth = {tool.bls(sjt).." est né le "..tool.bls(res).."."}

mdl_death = {tool.bls(sjt).." est mort le "..tool.bls(res).."."}

mdl_Qatt = {"Que souhaitez-vous savoir sur "..tool.bls(sjt).." ?"}

mdl_t_err = {"Désolé, je n'ai pas d'information sur "..tool.bls(sjt).."."}

mdl_hist = {"Voici l'historique de notre conversation :\n"..tool.bls(sjt)}

mdl_k_err = {"Désolé, je n'ai pas ".. tool.bls(sjt).." dans ma base de politiciens."}

mdl_Qparti = {tool.bls(sjt).." a été membre de "..tool.bls(vrb).." à savoir, "..tool.bls(res).."."}

mdl_creatr_b = {"Mes vénérables créateurs sont "..tool.bls(res).."\n\nJe les remercie sincèrement de m'avoir donné vie."}


local table_mdl = {
	["bac"] = mdl_bac,
	["bord"] = mdl_bord,
	["birth"] = mdl_birth,
	["death"] = mdl_death,
	["parti"] = mdl_Qparti,
	["profession"]= mdl_prof,
	["formation"] = mdl_forma,
	["birthplace"] = mdl_birthp,
}

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
	for att, model in pairs(table_mdl) do
		if (nom == att) then return model end
	end

	return mdl_basic
end


return txt