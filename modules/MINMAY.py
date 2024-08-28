#_sdf1 Demo - Python integration
#_ver 0.2
#_class 0,user,demo script,python,HiSurfAdvisory,2,onscreen

# By default, MACROSS always passes these vars to any python scripts it loads from the menu:
# $USR, $pyATTS, $vf19_DTOP, $vf19_PYPOD, $vf19_numchk, $vf19_pylib, $vf19_TOOLSROOT
# Python will also see the script name as sys.argv[0], so $USR will *ALWAYS* be sys.argv[1]
# See lines 46-62 for the values in these variables.


## Interacting with MACROSS requires the sys library's argv and path functions
from sys import argv,path
L = len(argv)

    
# MACROSS sends 7 args by default; the 6th is always the filepath to the mcdefs library
if L >= 2:
    mpath = argv[1]
    path.insert(0,mpath)  ## modify the sys path to include the py_classes folder
    import mcdefs as mc
    mc.psc('cls')

## When called via the collab() function, python scripts can receive a second arg if a value
## other than PROTOCULTURE is needed.
if L == 3:
    OPT = argv[2]

## If the user selected this script with the "help" option, the mcdefs library will set the
## HELP value to T so that your help/description message can be displayed.
if mc.HELP == 'T':
    print("""
    This is a simple python script to demonstrate how MACROSS calls powershell and python 
    tools interchangeably.
    
    1. Running MINMAY by itself will demonstrate reading
        MACROSS' default values into your script and using them
        to import the custom 'mcdefs' python library.
    
    2. If you run the HIKARU demo script, it will demonstrate
        sending parameters/arguments to MINMAY, which will process
        and format HIKARU's query, using it to get info from
        another script called GUBABA and return the results that
        HIKARU needed.
        
    Hit ENTER to continue.""")
    input()
    exit()


def splashPage(alt=False):
    b = 'ICAgICAgIOKWiOKWiOKWiOKVlyAgIOKWiOKWiOKWiOKVl+KWiOKWiOKVl+KWiOKWiOKWiOKVlyAgIOKWiO\
KWiOKVl+KWiOKWiOKWiOKVlyAgIOKWiOKWiOKWiOKVlyDilojilojilojilojilojilZcg4paI4paI4pWXICAg4paI4p\
aI4pWXCiAgICAgICDilojilojilojilojilZcg4paI4paI4paI4paI4pWR4paI4paI4pWR4paI4paI4paI4paI4pWXIC\
DilojilojilZHilojilojilojilojilZcg4paI4paI4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4pWa4p\
aI4paI4pWXIOKWiOKWiOKVlOKVnQogICAgICAg4paI4paI4pWU4paI4paI4paI4paI4pWU4paI4paI4pWR4paI4paI4pW\
R4paI4paI4pWU4paI4paI4pWXIOKWiOKWiOKVkeKWiOKWiOKVlOKWiOKWiOKWiOKWiOKVlOKWiOKWiOKVkeKWiOKWiOKW\
iOKWiOKWiOKWiOKWiOKVkSDilZrilojilojilojilojilZTilZ0gCiAgICAgICDilojilojilZHilZrilojilojilZTilZ\
3ilojilojilZHilojilojilZHilojilojilZHilZrilojilojilZfilojilojilZHilojilojilZHilZrilojilojilZTi\
lZ3ilojilojilZHilojilojilZTilZDilZDilojilojilZEgIOKVmuKWiOKWiOKVlOKVnSAKICAgICAgIOKWiOKWiOKVkSD\
ilZrilZDilZ0g4paI4paI4pWR4paI4paI4pWR4paI4paI4pWRIOKVmuKWiOKWiOKWiOKWiOKVkeKWiOKWiOKVkSDilZrilZ\
DilZ0g4paI4paI4pWR4paI4paI4pWRICDilojilojilZEgICDilojilojilZEgCiAgICAgICDilZrilZDilZ0gICAgIOKVm\
uKVkOKVneKVmuKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWdICAgICDilZrilZDilZ3ilZrilZDil\
Z0gIOKVmuKVkOKVnSAgIOKVmuKVkOKVnSA='
    STR = mc.getThis(b)
    print("\n")
    if alt:
        mc.w(STR,'m')
    else:
        mc.w(STR,'y')
    print("\n\n")

test = False

## This script knows ahead of time which script it might need to call
TOOL = "GUBABA.ps1"

if mc.PROTOCULTURE != 'None':
    splashPage(alt=True)
    CALLER = mc.CALLER
    mc.w('CALLER: ','g',i=True); mc.w(CALLER,'y')
    mc.w('PROTOCULTURE: ','g',i=True); mc.w(mc.PROTOCULTURE,'y')
    mc.w("\n\nHIKARU used the collab function to send your value to MINMAY.\n",'m')
    test = mc.collab(TOOL,'MINMAY',mc.PROTOCULTURE)
    mc.slp(2)
else:
    splashPage()
    CALLER = False
    mc.w('Enter a search term or ID related to Windows events to see if GUBABA can find it: ','g',i=True)
    Z = input()
    test = mc.collab(TOOL,'MINMAY',Z)


if test != False:
    if CALLER != False:
        mc.w("MINMAY has processed your search via GUBABA.\n\n",'m')
        exit()
    
    ## The powershell GUBABA script responds with hashtables; MACROSS has a powershell function called
    ## pyCross that writes the $PROTOCULTURE value to the PROTOCULTURE.eod file within the core\py_classes\
    ## garbage_io folder. The pyCross function automatically converts hashtables and lists into strings for 
    ## python that you will need to convert & parse in your tools.
    demoDict = {}
    demoList = test.split("@@")
    for i in demoList:
        kv = i.split(':')[0]
        vk = i.split(':')[1] + ': ' + i.split(':')[2]
        demoDict[kv] = vk

    ## The mcdefs library contains many of MACROSS' powershell functions, including  w() and screenResults() 
    ## that you can use to format your outputs onscreen.
    mc.w('GUBABA RESULTS USING w()','m')
    for d in demoDict:
        mc.w(d + ': ','g',i=True); mc.w(demoDict[d],'y')
    print("""
    """)
    del d
    input("""Hit ENTER to continue.
    """)

    
    mc.w('GUBABA RESULTS USING screenResults()','m')
    for d in demoDict:
        cc = "c~" + d
        dd = demoDict[d]
        mc.screenResults(cc,dd)
    mc.screenResults()
    print("""
    """)

    mc.w("\nHit ENTER to quit back to the menu.",'g')
else:
    mc.w("\nNo results. Hit ENTER to quit back to the menu.",'c')




input()
