#_sdf1 Open a MACROSS python test session
#_ver 1
#_class user,debugging,python,HiSurfAdvisory,0,none

import valkyrie as vk


IN = None
vk.screenResults("y~UTILITIES LIST","availableTypes, screenResults, collab, dS, drfl, errLog, getFile, getThis, help, osrm, osys, psc, psp, rgx, slp, ts, w")
vk.screenResults('Type "vk.help()" for valkyrie descriptions, or help() with any of the above valkyrie functions to view their help messages. Example: help(vk.collab)')
vk.screenResults()
vk.w('''
    The MACROSS valkyrie module has been imported as "vk", and all the standard 
    MACROSS globals have been populated. The powershell hashtable $vf19_LATTS
    has been converted into the python dictionary vk.LATTS, so you can test the 
    vk.availableTypes() and vk.collab() functions.
     
    Just type "q" to quit back to the MACROSS menu.
''','g')
while True:
    vk.w('MACROSS> ','g',i=True)
    Z = input()
    if Z == 'q':
        exit()
    else:
        try:
            exec(Z)
        except Exception as e:
            print(e)

