# Projet d'EISD sur les Personalités Politiques


## Auteurs
Projet d'EISD realisé par les etudiants:

- Manfred Madelaine :+1:
- Cédrick Ribet     :100:
- Hugo Bommart      :fire:
- Léo Galmant       :nose:

## Description :book:
Projet d'une durée de 3 mois visant au développement d'un système de dialogue axé sur les Personnalités Politiques Françaises. 
Ce système de dialogue doit permettre à l'utilisateur de poser des questions sur un politicien tel que sa date ou lieu de naissance, les partis auquels il a adhéré ou encore sa formation (c.f. détail des questions possibles dans le rapport) tout en gardant une certaine cohérence dans l'échange.
Le système de dialogue doit tendre vers des dialogues les plus naturels possible.

## Mise en Place et Utilisation Rapide :rocket:

### A- Création du Corpus
La création des données à partir du Wikipédia des politiciens se fait de la façon suivante : 
1. Se placer dans le Répertoire __extraction__

2. Entrer la commande __python extractionWiki.py__

3. Les fichiers composant le corpus sont créés !


### B- Extraction des données du Corpus
1. Se placer dans le Répertoire __systeme_de_dialogue__

2. Entrer la commande __./dark make_db.lua__

3. La base de données utilisée par le Système de Dialogue est générée !


### C- Lancement du Système de Dialogue
1. Se placer dans le Répertoire __systeme_de_dialogue__

2. Entrer la commande __./dark main.lua__

3. Choisisser un mode :
	1. Mode Interactif
	2. Mode Test Fonctionnel 

4. Le programme est lancé !


## Langages utilisés

* _Extraction des donnée de Wikipedia_ en **Python**

* _Système de dialogue_ en **Lua**


## Remerciements 

Un grand merci aux personnes ayant rempli le questionnaire visant à enrichir les réponses du système et les rendre plus naturelles.
