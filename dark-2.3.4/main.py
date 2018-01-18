# -*- coding: utf-8 -*-

import os

cmd = "echo \"\
le mardi 2 janvier \n\
le mardi 2 \n\
le mardi 2 janvier 1993 \n\
le deux janvier \n\
en mai 1995 \n\
le 12 août 1995 \n\
le 1er janvier \n\
le premier janvier \n\
\" | ./dark test.lua"

os.system(cmd) 