# -*- coding: utf-8 -*-

import os


txt = "le mardi 2 janvier \n\
le mardi 2 \n\
le mardi 2 janvier 1993 \n\
le deux janvier \n\
en mai 1995 \n\
le 12 août 1995 \n\
le 1er janvier \n\
le premier janvier \
\n"


txt2 = "à Tanger Maroc \
 j ai pris seretide des années \
\n"

cmd = "echo \"" + txt2 + "\" | ./dark test.lua"

os.system(cmd) 