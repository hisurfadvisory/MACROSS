#_sdf1 Open a MACROSS python test session
#_ver 1
#_class user,debugging,python,HiSurfAdvisory,0,none

import sys
#MCDEF = sys.argv[6]
MCDEF = sys.argv[1]
sys.path.insert(0,MCDEF)
import mcdefs as mc
import json

EOD = MCDEF + "\\garbage_io\\LATTS.eod"
with open(EOD) as E:
    LATT = json.load(E)

IN = None
mc.w('''
    The MACROSS mcdefs library has been imported as "mc", all the standard MACROSS
    globals have been populated (sys.argv 0 - 7), and the LATTS.eod file can be
    referenced using the array LATT.
     
    Just type "q" to quit back to the MACROSS menu.
''','g')
while True:
    mc.w('MACROSS> ','g',i=True)
    Z = input()
    if Z == 'q':
        exit()
    else:
        exec(Z)

