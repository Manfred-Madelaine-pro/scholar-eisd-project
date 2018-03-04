# -*- coding: utf-8 -*-

''' 
---------------------------------------------
Creation du fichier contenant la liste de nom
     et prenom des politiciens francais     
---------------------------------------------
'''

import time
from operator import itemgetter, attrgetter, methodcaller

PRECISION = 7

if __name__ == '__main__':
	fname = "fichierNom.txt"
	l_nom, count = [], 0
	start = time.time()

	with open(fname, 'r') as f:
		for line in f:
			count += 1
			tupl = (line, len(line))
			if (tupl not in l_nom):
				l_nom.append(tupl)

	print(count, '->', len(l_nom))

	# rangement de l_nom par la longueur de ses elements
	l_nom = sorted(l_nom,  key=itemgetter(1, 0), reverse=True)
	
	with open('pnominal.txt', 'w') as f:
		for tupl in l_nom:
			f.write(tupl[0])

	exec_time = round(time.time() - start, PRECISION)
	print("Temps d'execution :", exec_time)
