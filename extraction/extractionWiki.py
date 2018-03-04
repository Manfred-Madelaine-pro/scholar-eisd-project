# -*- coding: utf-8 -*-
from bs4 import BeautifulSoup
import requests
import re
import os.path
import unicodedata

def remove_accents(input_str):
    nfkd_form = unicodedata.normalize('NFKD', input_str)
    only_ascii = nfkd_form.encode('ASCII', 'ignore')
    return only_ascii

def addTag(ids, s):
	texte = ""
	if(s.find(id=ids) == None):
		return ""
	div = s.find(id=ids).parent.next_sibling.next_sibling

	while(True):
		if(div == None):
			break
		if(div.name == "p" or div.name == "ul" or div.name == "h3"):
			texte += div.text.replace("[modifier | modifier le code]", ".") + "\n"
			div = div.next_sibling.next_sibling
		else:
			break
	return texte

def extraction(url):
	quote_page = 'https://fr.wikipedia.org' + url
	response = requests.get(quote_page)

	soup = BeautifulSoup(response.content, 'html.parser')

	titre = soup.find('h1').text
	tab = titre.split(" ")
		
	if(len(tab) < 2 or ":" in tab[0]):
		return ""
	prenom = tab[0]
	nom = ""
	if(tab[1] == "de" or tab[1] == "De"):
		nom += "de"
		if(tab[2] == "la" or tab[2] == "La"):
			nom += "_la_"
			nom += tab[3]
		else:
			nom += "_" + tab[2]
	elif(tab[1] == "le" or tab[1] == "Le"):
		nom += "le"
		nom += "_" + tab[2]
	elif(tab[1] == "des" or tab[1] == "Des"):
		nom += "des"
		nom += "_" + tab[2]
	else:
		nom += tab[1]
		
	print(prenom + "_" + nom)
	nomFich = "./corpus/wiki/" + prenom + "_" + nom + ".txt"
	if(True):
		text = "PRETAG " + prenom.replace("_", " ") + " PRETAG " + "NOMTAG " + nom.replace("_", " ") + " NOMTAG " +".\n"
		#text += "NOMTAG " + nom.replace("-", " ").replace("_", " ") + ".\n"

		div = None
		divs = soup.find("div", {"class": "mw-parser-output"}).children
		for divt in divs:
			if(divt.name == "p"):
				div = divt
				break

		while(True):
			if(div == None):
				break
			if(div.name == "p"):
				text += div.text + "\n"
				div = div.next_sibling.next_sibling
			else:
				break
				
		text += addTag("Vie_privée", soup) + "\n"
		text += addTag("Parcours_politique", soup) + "\n"
		text += addTag("Biographie", soup) + "\n"
		text += addTag("Détail_des_fonctions_et_des_mandats", soup) + "\n"
		text += addTag("Formation", soup) + "\n"
		text += addTag("Carrière_professionnelle", soup) + "\n"
		text += addTag("Famille", soup) + "\n"
		text += addTag("Parcours_professionnel", soup) + "\n"
		text += addTag("Positionnement_politique", soup) + "\n"

		if(soup.find("th", text = "Parti politique") != None):
			parti = soup.find("th", text = "Parti politique").next_sibling.next_sibling
			parText = "PARTISNORM\n"
			regg = re.compile('\[.*\]')
			for part in parti.select("a"):
				if(regg.search(part.text) == True or hasattr(part, "title") == False or "#" in part["href"]):
					break
				else:
					#if(part['title'].isdigit() == False):
					if(True):
						if(part.next_sibling == None or part.next_sibling.next_sibling == None or hasattr(part.next_sibling.next_sibling, "text") == False):
							parText += "PART " + part['title'].replace(" (France)", "").replace(" (parti français)", "") + " PART " + " (" + part.text + ")" + ".\n"
						else:
							parText += "PART " + part['title'].replace(" (France)", "").replace(" (parti français)", "") + " PART " + " (" + part.text + ")" + " " + part.next_sibling.next_sibling.text.replace("(", "").replace(")", "") + ".\n"
					
			text += parText


		cadre = soup.find('table')

		if(cadre != None):
			foncText = "FONCTIONNORM\n"
			reg = re.compile('(Président|Député|Ministre|Sénateur|Conseiller|Présidente|Députée|Ministre|Sénateure|Conseillère)')
			reg2 = re.compile('(Président|Député|Ministre|Sénateur|Conseiller|Présidente|Députée|Ministre|Sénateure|Conseillère|Biographie)')
			#fonctions = cadre.findAll('th', text = reg)

			fonctions = []

			fonctionsT = cadre.findAll('th')
			for fonc in fonctionsT:
				if(reg.search(fonc.text)):
					fonctions.append(fonc)

			boole = 0
			for fonc in fonctions:
				foncText += "\nNOMF " + fonc.text.replace("\n", "") + " NOMF "
				next = fonc.parent.next_sibling.next_sibling
				if(next == None):
					break
				foncText += next.text.replace("\n", "")
				next = fonc.parent.next_sibling.next_sibling
				
				boole = 0
				while(boole == 0):
					if(reg2.search(next.text) != None):
						
						boole = 1
					else:
						if(next.th != None and next.td != None):
							foncText += " SEP2 " + next.th.text.replace("\n", "") + " REL " + next.td.text.replace("\n", "") + " SEP3 "
						next = next.next_sibling.next_sibling
						if(next == None):
							boole = 1
						
				foncText = foncText + "."
					
			text += foncText	
		
		
		fichier = open("./corpus/wikipedia/" + prenom.replace("é", "e").replace("è", "e").replace("û", "u").replace("ê", "e").replace("ë", "e").replace("ô", "o").replace("ö", "o").replace("â", "a").replace("ç", "c") + "_" + nom.replace("é", "e").replace("è", "e").replace("ê", "e").replace("ë", "e").replace("ç", "c").replace("ô", "o").replace("ö", "o").replace("â", "a").replace("ï", "i").replace("û", "u") + ".txt", "wb")
		fichier.write((text).encode('utf8'))
		return prenom.lower().replace("é", "e").replace("î", "i").replace("ï", "i").replace("û", "u").replace("è", "e").replace("ê", "e").replace("ë", "e").replace("ô", "o").replace("ö", "o").replace("â", "a").replace("ï", "i").replace("ç", "c").replace("_", " ").replace("-", " - ").replace("'", " ' ") + "\n" + nom.lower().replace("é", "e").replace("è", "e").replace("ê", "e").replace("ë", "e").replace("ô", "o").replace("ö", "o").replace("ï", "i").replace("û", "u").replace("â", "a").replace("î", "i").replace("ï", "i").replace("ç", "c").replace("_", " ").replace("-", " - ").replace("'", " ' ") + "\n"
	
def fonc(url, l, lis):
	quote_page = "https://fr.wikipedia.org" + url
	response = requests.get(quote_page)
	
	soup = BeautifulSoup(response.content, 'html.parser')

	for a in soup.select('.mw-content-ltr .mw-category a'):
		if("Utilisateur:" not in a.get('href')):
			l.append(a.get('href'))
	if(soup.find("a", text = "page suivante") != None):
		lis.append(soup.find("a", text = "page suivante").get('href'))


quote_page = 'https://fr.wikipedia.org/wiki/Cat%C3%A9gorie:Personnalit%C3%A9_politique_fran%C3%A7aise_par_parti'
response = requests.get(quote_page)


soup = BeautifulSoup(response.content, 'html.parser')

list = []

i = 0
for a in soup.select('.mw-content-ltr .mw-category a'):
	if(i > 3):
		list.append(a.get('href'))
	i += 1

liste = []
for fic in list:
	fonc(fic, liste, list)

i=1
fichierNom = ""
for fic in liste:
	print(i)
	fichierNom += extraction(fic)
	i += 1
	
f = open("fichierNom.txt", "wb")
f.write((fichierNom).encode('utf8'))
f.close()





