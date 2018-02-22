# -*- coding: utf-8 -*-
from bs4 import BeautifulSoup
import requests
import re
import os.path

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
		return
	prenom = tab[0]
	if(tab[1] == "de"):
		prenom += "_de"
		nom = tab[2]
	else:
		nom = tab[1]
		
	print(prenom + "_" + nom)
	nomFich = "./corpus/wiki/" + prenom + "_" + nom + ".txt"
	if(os.path.isfile(nomFich) == False):
		text = "PRETAG " + prenom + ".\n"
		text += "NOMTAG " + nom + ".\n"

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
				if(regg.search(part.text) or hasattr(part, "title") == False):
					break
				if(part.next_sibling == None or part.next_sibling.next_sibling == None or hasattr(part.next_sibling.next_sibling, "text") == False):
					parText += "PART " + part['title'].replace(" (France)", "").replace(" (parti français)", "") + " (" + part.text + ")" + ".\n"
				else:
					parText += "PART " + part['title'].replace(" (France)", "").replace(" (parti français)", "") + " (" + part.text + ")" + " " + part.next_sibling.next_sibling.text.replace("(", "").replace(")", "") + ".\n"
					
			text += parText


		cadre = soup.find('table')

		if(cadre != None):
			foncText = "FONCTIONNORM\n"
			reg = re.compile('(Président|Député|Ministre|Sénateur|Conseiller|Présidente|Députée|Ministre|Sénateure|Conseillère)')
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
				foncText += next.text.replace("\n", "") + " SEP2 "
				next = fonc.parent.next_sibling.next_sibling
				
				boole = 0
				while(boole == 0):
					#foncText += fonc.text + "\t" + fonc.parent.next_sibling.next_sibling.text + "\n"
					#foncText += next.text + "\t"
					#print(next.text)
					if(reg.search(next.text) != None):
						
						boole = 1
					else:
						if(next.th != None and next.td != None):
							foncText += next.th.text.replace("\n", "") + " REL " + next.td.text.replace("\n", "") + " SEP2 "
						next = next.next_sibling.next_sibling
						if(next == None):
							boole = 1
						
				foncText = foncText[:-6] + "."
					
			text += foncText	
		
		
		fichier = open("./corpus/wikiTemp/" + prenom + "_" + nom + ".txt", "wb")
		fichier.write((text).encode('utf8'))
	
def fonc(url, l):
	quote_page = "https://fr.wikipedia.org" + url
	response = requests.get(quote_page)
	
	soup = BeautifulSoup(response.content, 'html.parser')

	for a in soup.select('.mw-content-ltr .mw-category a'):
		if("Utilisateur:" not in a.get('href')):
			l.append(a.get('href'))
		else:
			print("AH")


quote_page = 'https://fr.wikipedia.org/wiki/Cat%C3%A9gorie:Personnalit%C3%A9_politique_fran%C3%A7aise_par_parti'
response = requests.get(quote_page)


soup = BeautifulSoup(response.content, 'html.parser')

#cadre = soup.find('div', attrs = {'class': 'infobox_v3'})
#cadre = soup.find('div')

list = []

i = 0
for a in soup.select('.mw-content-ltr .mw-category a'):
	if(i > 3):
		list.append(a.get('href'))
	i += 1

#print(list)
liste = []
for fic in list:
	fonc(fic, liste)
#print(liste)
#print(len(liste))
i=1
for fic in liste:
	print(i)
	extraction(fic)
	i += 1
	

#fichier.write((cadre.text.strip()).encode('utf8'))





