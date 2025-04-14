#_sdf1 Demo - Python Automation
#_ver 0.3
#_class 0,user,demo script,python,HiSurfAdvisory,2,onscreen

from sys import argv
from json import loads

## If you only want to import parts of MACROSS' valkyrie module, remember to also import these critical
## values if you need them: MPOD (so you can decrypt from the config.conf file using the getThis function), 
## PROTOCULTURE (if your script can be called via the collab function), along with HELP and CALLER
## so you can display the help screen, or determine the calling script.
from valkyrie import w,psc,slp,getThis,availableTypes,collab,screenResults,\
    pyCross,PROTOCULTURE,HELP,CALLER

L: int = len(argv)
spiritia = False  ## "spiritia" is used as an alt arg/param in addition to, or instead of, PROTOCULTURE.

## MACROSS can send a single optional arg, if your script is coded to accept one; powershell defines this
## optional arg as $spiritia, so I keep it the same in python
if L == 2:
    spiritia = argv[1]
    

## The valkyrie.psc() function uses different subfunctions of python's "os.system()"
## Using arg "cc" executes commands (like I'm doing here to just clear the screen), while 
## using "cr=" will return any results as usable data.
psc(cc='cls')  

## If the user selected this script with the "help" option, the valkyrie module will set the
## HELP value to True so that your help/description message can be displayed.
if HELP:
    print("""
    This is a simple python script to demonstrate how MACROSS calls powershell and python 
    tools interchangeably.
    
    1. Running MISA by itself will demonstrate reading
        MACROSS' default values into your script and using them
        to import the custom 'valkyrie' python library.
    
    2. If you run the HIKARU demo script, it will demonstrate
        sending parameters/arguments to MISA, which will process
        and format HIKARU's query, using it to get info from
        another script called GUBABA and return the results that
        HIKARU needed.
        
    Hit ENTER to continue.""")
    input()
    exit()


def splashPage(alt=False) -> None:
    b = "ICAgICAgICDilojilojilojilZcgICDilojilojilojilZfilojilojilZfilojilojilojilojilojil\
        ojilojilZcg4paI4paI4paI4paI4paI4pWXIAogICAgICAgIOKWiOKWiOKWiOKWiOKVlyDilojilojiloj\
        ilojilZHilojilojilZHilojilojilZTilZDilZDilZDilZDilZ3ilojilojilZTilZDilZDilojilojil\
        ZcKICAgICAgICDilojilojilZTilojilojilojilojilZTilojilojilZHilojilojilZHilojilojiloj\
        ilojilojilojilojilZfilojilojilojilojilojilojilojilZEKICAgICAgICDilojilojilZHilZril\
        ojilojilZTilZ3ilojilojilZHilojilojilZHilZrilZDilZDilZDilZDilojilojilZHilojilojilZT\
        ilZDilZDilojilojilZEKICAgICAgICDilojilojilZEg4pWa4pWQ4pWdIOKWiOKWiOKVkeKWiOKWiOKVk\
        eKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkeKWiOKWiOKVkSAg4paI4paI4pWRCiAgICAgICAg4pWa4pWQ4pW\
        dICAgICDilZrilZDilZ3ilZrilZDilZ3ilZrilZDilZDilZDilZDilZDilZDilZ3ilZrilZDilZ0gIOKVm\
        uKVkOKVnQo="
    STR = getThis(b)
    print("\n")
    if alt:
        ## The valkyrie module's w() function, like the powershell version, is a quick and easy
        ## way to display formatted text onscreen.
        w(STR,"m")
    else:
        w(STR,"y")
    print("\n\n")


def main() -> None:
    ## Use valkyrie.availableTypes() to generate lists of relevant scripts you can forward 
    ## data to, regardless of scripts being added/removed from your modules folder. If you
    ## look at GUBABA's .valtype, it is "windows event id lookup". You can search for exact 
    ## (using exact=True) or partial-matching valtypes. The "la" arg is specifying which 
    ## language we require from potential collab scripts.

    ## valkyrie.availableTypes() returns lists, and in this demo I know Gubaba is going to 
    ## be the first and only item even without setting exact=True... unless you have added
    ## more scripts with the words "event id" in their .valtype!
    TOOL: list = availableTypes(val="event id",la="powershell")[0]

    ## The standard rule for MACROSS scripts is that they automatically act on the
    ## global value PROTOCULTURE, if it is not null/empty.
    if PROTOCULTURE:
        ## In this section, MISA is using availableTypes() to view the CALLER script's macross
        ## class, specifically the ".valtype" value. Using the macross class attributes lets 
        ## you write your tools to respond appropriately no matter which script is 
        ## calling yours. MISA will only reply to queries from scripts with the .valtype 
        ## "demo script". You can also do this manually if you've imported valkyrie's LATTS 
        ## dictionary, for example:
        ##      vtype = valkyrie.LATTS[CALLER].valtype; vlang = valkyrie.LATTS[CALLER].lang

        if CALLER:
           
            filter: list = availableTypes(val="demo script",exact=True)
            if CALLER in filter:
                splashPage(alt=True)
                w("CALLER: ","g",i=True); w(CALLER,"y")
            else:
                exit()

            # Somewhere in this area is where you would do whatever needs
            # to be done with the forwarded PROTOCULTURE value.

            w("PROTOCULTURE: ","g",i=True)
            w(PROTOCULTURE,"y")
            print("\n\n")
            w(f"{CALLER} used the collab function to send your search query to MISA.\n","m")

            # Here, we check to see if the CALLER is a python script
            if CALLER in availableTypes("",la="python"):

                # MISA was called by another python script (CALLER) using collab, but
                # we're going to be using the collab function again to demo jumping
                # from one script another and back. The reason you want to rewrite 
                # CALLER with your script's name is so that the next script you
                # collab with can view your .valtype, .rtype and other attributes
                # to tailor its responses correctly.
                # Now we use collab to get results from the GUBABA tool...
                id_list = collab(Tool=TOOL,Caller="MISA",Protoculture=PROTOCULTURE)
                
                # Since collab was already used to call MISA, we need to use the pyCross
                # function to update the PROTOCULTURE.eod file that the original script
                # will read to get MISA's response. That script will be looking for its 
                # own name in the CALLER field, so we need to use the original_caller
                # variable. You can use collab as often as you want, but just make sure
                # you're keeping track of the original CALLER so that it can get the
                # data it needs!
                pyCross(Caller=CALLER,res=id_list)
                return
        
            else:
                # Using python collab for a powershell script is much the same as it is
                # for python; the powershell version of collab has an easier time
                # of tracking things in the background.
                id_list = collab(Tool=TOOL,Caller="MISA",Protoculture=PROTOCULTURE)
                pyCross(Caller=CALLER,res=id_list)
        
        # The valkyrie library's slp() function can pause your scripts
        slp(2)

    else:
        splashPage()
        w("""" Enter a search term or ID related to Windows events to see if GUBABA 
    can find it: ""","g",i=True)
        Z: str = input()
        id_list = collab(TOOL,"MISA",Z)

    rtext: str = f"\nHit ENTER to return to {CALLER}"



    if id_list:
        w(f"MISA has processed your search via {TOOL}.\n\n","g")

        
        ## The powershell GUBABA script responds with hashtables; MACROSS has a function called
        ## pyCross that your scripts can use to write a $PROTOCULTURE value to the PROTOCULTURE.eod file 
        ## within the core\macross_py\garbage_io folder. The python valkyrie.collab() function uses this 
        ## file to send and retrieve PROTOCULTURE values back and forth between python and powershell.
        for i in id_list.keys():
            t = str(id_list[i][0])
            v = str(id_list[i])
            ## Both the powershell and python modules contain useful utilities you can use, such as
            ## screenResults(), which formats large blocks of text into columns
            screenResults(f"y~{t}-ID {i}",v)
        screenResults()
        if CALLER:
            w(rtext,"g")
        else:
            w("\nHit ENTER to quit back to the menu.","g")
    else:
        if CALLER:
            w(rtext,"g")
        else:
            w("\nNo results. Hit ENTER to quit back to the menu.","c")

    input()


if __name__ == "__main__":
    main()
