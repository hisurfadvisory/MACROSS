#_sdf1 Demo - Python Automation
#_ver 0.2
#_class 0,user,demo script,python,HiSurfAdvisory,2,onscreen

from sys import argv
from json import loads
import valkyrie as vk
L = len(argv)
spiritia = False  ## "spiritia" is used as an alt arg/param in addition to or instead of PROTOCULTURE.
    
## MACROSS can send a single optional arg, if your script is coded to accept one
if L == 2:
    spiritia = argv[1]
    

## The valkyrie.psc() function is just "os.system()"
vk.psc('cls')  

## If the user selected this script with the "help" option, the valkyrie module will set the
## HELP value to T so that your help/description message can be displayed.
if vk.HELP:
    print("""
    This is a simple python script to demonstrate how MACROSS calls powershell and python 
    tools interchangeably.
    
    1. Running MINMAY by itself will demonstrate reading
        MACROSS' default values into your script and using them
        to import the custom 'valkyrie' python library.
    
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
    STR = vk.getThis(b)
    print("\n")
    if alt:
        vk.w(STR,'m')
    else:
        vk.w(STR,'y')
    print("\n\n")



## Use availableTypes() to generate lists of relevant scripts, regardless of files
## being added/removed from your core folder
TOOL = vk.availableTypes('event id',la='powershell')[0]

## The standard rule for MACROSS scripts is that they automatically act on the
## global value PROTOCULTURE, if it exists.
if vk.PROTOCULTURE:
    ## In this section, MINMAY is looking at the CALLER script's MACROSS class,
    ## specifically the ".valtype" value. Using the MACROSS class attributes lets 
    ## you write your tools to respond appropriately no matter which script is 
    ## calling yours. MINMAY will only reply to queries from scripts with the .valtype 
    ## "demo script" and the .lang "powershell".
    if vk.CALLER:
        vtype = vk.LATTS[vk.CALLER].valtype
        vlang = vk.LATTS[vk.CALLER].lang
        if vtype == 'demo script' and vlang == 'powershell':
            splashPage(alt=True)
            vk.w('CALLER: ','g',i=True); vk.w(vk.CALLER,'y')
        else:
            exit()
    
    vk.w('PROTOCULTURE: ','g',i=True); vk.w(vk.PROTOCULTURE,'y')
    print("\n\n")
    vk.w(vk.CALLER+" used the collab function to send your value to MINMAY.\n",'m')
    test = vk.collab(TOOL,vk.CALLER,vk.PROTOCULTURE)
    vk.slp(2)
else:
    splashPage()
    vk.w('''Enter a search term or ID related to Windows events to see if GUBABA 
can find it: ''','g',i=True)
    Z = input()
    test = vk.collab(TOOL,'MINMAY',Z)

if test:
    vk.w("MINMAY has processed your search via "+TOOL+".\n\n",'g')

    
    ## The powershell GUBABA script responds with hashtables; MACROSS has a powershell function called
    ## pyCross that writes the $PROTOCULTURE value to the PROTOCULTURE.eod file within the core\macross_py\
    ## garbage_io folder. The valkyrie.collab() function reads/writes this file to send and retrieve
    ## PROTOCULTURE values for your scripts.
    for i in test.keys():
        t = str(test[i][0])
        v = str(test[i][1])
        ## Both the powershell and python modules contain useful utilities you can use, such as
        ## screenResults(), which formats large blocks of text into columns
        vk.screenResults('y~'+t+'-'+'ID '+i,v)
    vk.screenResults()
    if vk.CALLER:
        vk.w("\nHit ENTER to return to "+vk.CALLER,'g')
    else:
        vk.w("\nHit ENTER to quit back to the menu.",'g')
else:
    if vk.CALLER:
        vk.w("\nHit ENTER to return to "+vk.CALLER,'g')
    else:
        vk.w("\nNo results. Hit ENTER to quit back to the menu.",'c')




input()
