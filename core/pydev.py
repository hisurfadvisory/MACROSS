#_sdf1 Open a MACROSS python test session
#_ver 1
#_class user,debugging,python,HiSurfAdvisory,0,none

import sys
MCDEF = sys.argv[6]
sys.path.insert(0,MCDEF)
import mcdefs as mc


IN = None
mc.w('''
    The MACROSS mcdefs library has been imported as "mc" and all the standard MACROSS
    globals have been populated (sys.argv 0 - 7).
''','g')
while IN != 'q':
    IN = input('Enter your test commands, or "q" to quit: ')
    if IN != 'q':
        try:
            exec(IN)
        except:
            mc.w('no good!','r')


exit()
