#_superdimensionfortress Demo - Python integration
#_ver 0.2
#_class User,demo script,Python 3,HiSurfAdvisory,2

# By default, MACROSS always passes these vars to any python scripts it loads from the menu:
# $USR, $pyATTS, $vf19_DEFAULTPATH, $vf19_PYPOD, $vf19_numchk, $vf19_pylib, $vf19_TOOLSROOT
# Python will also see the script name as sys.argv[0], so $USR will *ALWAYS* be sys.argv[1] 


## Interacting with MACROSS requires the sys library
import sys
L = len(sys.argv)



# If the user selected this script with the "h" option set, MACROSS sets the sys.argv[1] value
# as "HELP" because they want to view the help-description page.
if L > 2:
    USR = sys.argv[1]
    if USR == 'HELP':
        print("""
    This is a simple python script to demonstrate how
    MACROSS calls powershell and python tools inter-
    changeably.
    
    1. Running MINMAY by itself will demonstrate reading
        MACROSS' default values into your script and using them
        to import the custom 'mcdefs' python library.
    
    2. If you run the HIKARU demo script, it will demonstrate
        sending parameters/arguments to MINMAY, which will process
        and format HIKARU's query, using it to get info from
        another script called KÖNIG and return the results that
        HIKARU needed.
    Hit ENTER to continue.""")
        input()
        exit()
else:
    USR = 'HELP'  ## If less than 8 arguments were passed, something went wrong. Set the 1st arg as HELP to act as an error msg


    
# MACROSS sends 7 args by default; the 6th is always the filepath to the mcdefs library
if L >= 8:
    if 'py_classes' in sys.argv[6]:
        npath = sys.argv[6]
        sys.path.insert(0,npath)  ## modify the sys path to include the py_classes folder
        import mcdefs as mc

        ## The other 5 args can be used or ignored as you like. For this demo I'll assign
        ##  each of the arguments for you, named the same way that MACROSS names them.
        ##  In order, they are:
        USR = sys.argv[1]               ## The logged-in user
        atts = sys.argv[2]              ## The $vf19_ATTS hashtable attributes .name and .valtype for each script
        vf19_ATTS = mc.getATTS(atts)    ## mcdefs.getATTS() can automatically create the dictionary for you   
        vf19_DEFAULTPATH = sys.argv[3]  ## USR's desktop filepath
        vf19_PYPOD = sys.argv[4]        ## The encoded array of filepaths/URLs generated from extras.ps1
        vf19_numchk = sys.argv[5]       ## The integer MACROSS uses for common math functions in all the scripts
        vf19_M = mc.makeM(vf19_numchk)  ## This function splits the numchk value into 6 digits you can use for mathing
        vf19_TOOLSROOT = sys.argv[7]    ## The path to the MACROSS folder
        GBG = sys.argv[6] + '\\garbage_io'  ## Path to the garbage I/O folder
        
        ## The psc function will pipe system commands into your powershell session
        mc.psc('cls')

# Scripts can call each other with any arguments you like; but passing them as the framework
# dictates allows scripts to share resources/values across python and powershell. I also
# add 2 more arguments here -- the name of any scripts that call this one (CALLER), and the thing
# they want evaluated (PROTOCULTURE).
if L == 10:
    CALLER = sys.argv[9]
    PROTOCULTURE = sys.argv[10]
else:
    PROTOCULTURE = None
    CALLER = None


def next(e):
    k = ''
    if e == 0:
        while k != 'c':
            print('''
    Type "c" to continue!''')
            k = input('    ')
    else:
        if e == 1:
            e = 'continue!'
        else:
            e = 'exit!'
            
        print('''
    Hit ENTER to''',e)
        input()

def splashPage():
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
    STR = mc.getThisPy(b,0)
    print('''
    ''')
    print(STR)



def theGoodStuff(Z1 = '',Z2 = None):
    splashPage()
    print('''
    Now, as of MACROSS version 3, the mcdefs python library (covered in a bit) doesn't
    have a smart way to share goodies like the powershell "collab" function does (because
    my creator is lazy and not too bright).''')
    if Z1 != '':
        print('''
    I got your value --
                               ''',Z1,'''
                               
    -- as easy as getting an email, and I can sort-of make requests back to MACROSS just
    as easily; in fact I'm about to do just that by forwarding your filename to KÖNIG.
    But I will be sending my response to HIKARU's original query via snail-mail, so-to-
    speak.''')
        print('''
    Sometimes scripts will perform tasks that can't just return a simple variable, so we'll
    have to build functions for our analysts to send your python values to powershell, and
    then somehow get the results back in a way we can use them.
    ''')
        next(1)
        mc.psc('cls')
    elif Z1 == '':
        print('''
    So we'll go through how data gets passed between me and MACROSS. First, let's get some
    input from you. Give me a keyword to search for filenames with, preferably something
    you know can be found in your home folders (and it can just be a partial filename).''')
        while Z1 == '':
            Z1 = input('''
    Keyword: ''')
        Z1 = '\'' + Z1 + '\''
        
    print('''
    Let's continue with building a query to get KÖNIG on the launchpad:
    
            konig = vf19_TOOLSROOT + '\\nmods\\KONIG.ps1'
            konig = 'powershell.exe ' + konig
            
    I've already set that "vf19_TOOLSROOT" value in the background. Remember all
    those params/args that powershell sends over by default? This arg (the MACROSS
    root folder location) was stored in sys.argv[7]. So now python knows how to
    find KÖNIG. Now we can add the input you gave me to search for:
    
                    konig = konig + ''',Z1,'''
    
    If you read KÖNIG's documentation, you'll see it needs several parameters passed
    to it if you try to call it without MACROSS, the first param being the value you
    supplied. Next it needs the name of the script calling it. If it's a python script
    (I am!), the name needs to begin with "py" so that KÖNIG loads some extra functions:
    
                    konig = konig + 'pyMINMAY'
    
    Adding a simple "py" here is much easier than trying to recreate all the [macross]
    powershell objects in their entirety everytime a python script runs.
    ''')
    next(1)
    mc.psc('cls')
    print('''
    Finally, let's finish up by adding in the rest of KÖNIG's requirements: the location
    to search (I'm just going to set it to your local home folders):
        
                usrhome = 'C:\\Users\\' + USR      ## USR was sent to me in sys.argv[1]
                konig = konig + usrhome
                
    ...the location of the garbage_io folder (we'll cover that more in a bit):
    
            ## garbage_io is located in the same folder as the mcdefs library
                gbg = sys.argv[6] + '\\garbage_io' 
                konig = konig + gbg
                
    ...and the location that MACROSS knows as "$vf19_DEFAULTPATH", and sent to me as
    sys.argv[3] (the current user's desktop, where KÖNIG writes its findings to):
    
                konig = konig + vf19_DEFAULTPATH + '-ErrorAction SilentlyContinue'
                
    I also added the "ErrorAction" option at the end, because KÖNIG expects certain
    resources from MACROSS that it won't get from me, and we don't want to see all
    those error messages. Adding "py" to my name forces KÖNIG to make some adjustments
    to its functions. You can use another method in your scripts if you want.
    
    Now, previously I left notes saying "more on that later"-- one for the mcdefs library,
    and another for MACROSS' garbage_io folder. The provided python library, mcdefs, is
    just a basic collection of other library resources that are used to offer some of the
    same common functions as MACROSS' utility.ps1 and display.ps1 scripts.
    
    For this demo, I'm using the "psc" function in mcdefs to execute a powershell
    script with the command I just finished building with your $PROTOCULTURE:
    
                mcdefs.psc(konig)
                
    After KÖNIG finishes its mission and returns to python, I'll explain the "garbage_io".''')
    input('''
    Hit ENTER to launch KÖNIG!''')
    gbg = vf19_TOOLSROOT + '\\ncore\\py_classes\\garbage_io'
    usrhome = 'C:\\Users\\' + USR
    usrhome = ' "' + usrhome + '" '
    konig = vf19_TOOLSROOT + '\\nmods\\KONIG.ps1 '
    konig = 'powershell.exe ' + konig + Z1 + ' "pyMINMAY" ' + usrhome
    konig = konig + '"' + gbg + '" '
    konig = konig + '"' + vf19_DEFAULTPATH + '"' + ' -ErrorAction SilentlyContinue'
    mc.psc(konig)

    mc.psc('cls')
    splashPage()
    print('''
    Okay, welcome back to MINMAY! Let's see if KÖNIG hit your target. Normally, MACROSS is
    able to share everything without much fuss, but only within powershell. That's where
    the garbage_io folder comes in. The mcdefs library will eventually have the ability to
    read results in straight from powershell to save you the hassle of coding it into every
    python script, but for now, if the powershell response can't be given in a simple variable,
    MACROSS uses a text file.
    
    Within the MACROSS root folder, inside the "ncore\py_classes" folder, there is a folder
    called garbage_io. It's not really for garbage, though. Its contents are very valuable!
    
    Part of the MACROSS framework is to build-in checks for your powershell scripts so that
    if they get called by a python script and have a huge output, they send their results to
    MACROSS' pyCross function. This will write whatever data python needed to get, into
    an "eod" file that will be put in garbage_io.
    
    If KÖNIG found anything for you, it should have written the location of its $RESULTFILE
    report, along with the number of results it got, to "konig.eod". The 'pyCross' function
    can write all that automatically for you. See the utility.ps1 and KONIG.ps1 scripts to see
    how it works.
    
    The garbage_io location should still be valid as our variable "gbg" so, let's check using
    the mcdefs.dirfile() function...
    
                konfile = gbg + '\\konig.eod'
                if mcdefs.dirfile(konfile,'isfile'):
                    chkresults = open(konfile,encoding='utf-8')
                    konhits = chkresults.read()
                    print(konhits)
                    chkresults.close()   
    ''')

    next(1)
    mc.psc('cls')
    konfile = gbg + '\\konig.eod'
    if mc.dirfile(konfile,'isfile'):
        chkresults = open(konfile,encoding='utf-8')
        konhits = chkresults.read()
        print('''
    Hey! It looks like we got the path to KÖNIG's $RESULTFILE, and the total hits for your search!
    The mcdefs library has a monochrome version of MACROSS' "screenResults" function, I'll use it
    to write your results out in columns:
            ''')
        i = 0
        mc.screenResults('FILE/LINE','CONTENTS')
        for line in konhits.split():
            i = i + 1
            ii = '    konig.eod line ' + str(i) + ': '
            mc.screenResults(ii,line)
        mc.screenResults()
        chkresults.close()
        
    else:
        print('''
    Hm, bummer, looks like we got no hits.''')
        
    print('''
    You can always launch KÖNIG on its own and play with its settings, but that pretty
    much wraps up this version 0.1 demo. If you already have APIs or automations in your
    SOC, it shouldn't take too much effort to modify them for use in the MACROSS frame-
    work. It's no replacement for manually searching your security tools, but it can be a
    handy little utility to grab quick one-offs when deciding whether an event warrants
    deeper dives, or supplementing a smaller network that has less resources available for
    cybersecurity beyond Active Directory cmdlets and/or a few system logs.''')
    if Z2 != None:
        Z2 = Z2 + '!'
        print('''
    Hit ENTER to jump back to''',Z2)
        input()
        exit()
    else:
        print('''
    Thanks for taking MACROSS for a spin!''')    
        next(2)
        exit()




if USR == 'HELP':
    splashPage()
    print('''
    This is a python demo that has you input a filename to search for using the KONIG
    powershell script. It breaks down how the MACROSS framework makes it easy to have
    powershell and python tools work together seamlessly.
    
    Running this script by itself explains how python scripts receive default information
    from MACROSS, and what those defaults are.
    
    If you run the HIKARU demo script, it demonstrates how powershell and python tools
    can interact with each other and pass values back and forth.
    
    Hit ENTER to return.
    ''')
    input()
    exit()




splashPage()




if PROTOCULTURE:
    print(
    """
    Hello! I'm a python script that is written within the MACROSS framework to play nice
    with powershell. Why bother, you ask? This framework is aimed at adding one more tool
    to your SOC team's toolkit. Not everyone starts out knowing how to use commandline
    tools, but *everybody* benefits from the amount of info you can quickly gather from
    them.
    
    Okay, let me see... you have sent me exactly""",L - 1,"""arguments.
    
    MACROSS will *always* send at least 7 args by default -- I used #6 to automatically import
    the MACROSS python library (and if you launch me from the MACROSS menu I talk a little
    bit more about that). But MACROSS has a built-in function called "collab" for powershell
    scripts, and it is designed to pass the additional values of $CALLER and $PROTOCULTURE,
    along with one additional argument if needed.
    
    Because of that default behavior, your python scripts will always need the sys library
    (or at least its argv functionality) to be able to recognize all the values MACROSS sends
    over. In keeping with the framework's guidelines, I make a habit of keeping the same
    variable names. It's not really necessary, but it makes things easier to track. If you
    see me referencing "vf19_" variables later, it's because I converted a "$vf19_" variable
    from MACROSS using sys.argv.
    
    Now, I'll use the 9th arg passed to me, which in MACROSS is $PROTOCULTURE, to ask a
    powershell script if it can find
    
    """,PROTOCULTURE,"""
    
    in any other directories, as a demonstration of using tools written in powershell asking
    for data from python and vice-versa. 
    """
    )

    next(0)
    mc.psc('cls')
    
    splashPage()
    print("""
    Pretend I'm an automation tool that scans threat reports for IOCs, and the value you 
    passed me is a commonly seen filename for some trojanized documents. My next step is
    going to be to remove any filepaths or URLS attached to the filename, then pass it
    to another automation that can scan for filenames. The MACROSS "mcdefs" library contains
    a basic regex function via the "re" library, so let's take a look at that PROTOCULTURE
    value:
    
    """,PROTOCULTURE,"""
    """)
    Z1 = mc.rgx("^.*\\\\",PROTOCULTURE,'')
    Z2 = CALLER
    print("""
    I'll just use some regex magic to strip out the filepath  via "mcdefs.rgx":
                                            """,Z1)
    next(1)
    mc.psc('cls')
    theGoodStuff(Z1,Z2)
else:
    Z1 = ''
    Z2 = None
    print("""
    This is an example python integration to explain how the MACROSS framework enables
    seamlessly loading python and powershell scripts to share and evaluate whatever an
    analyst may be investigating. (Named after Lynn Minmay from my favorite anime series,
    Macross).
    
    At startup, MACROSS reads the Windows registry to see if Python3 is installed. If it
    is, the console will pull any .py files it finds in the nmods folder into the menu
    and make them available for use. If Python3 isn't installed, python scripts are ignored.
    By default, MACROSS always passes seven arguments (in this order) to any python script it
    loads straight from the main menu:
    
        [1] $USR = the logged in user
        [2] $pyATTS = a simplified list of MACROSS' $vf19_ATTS hashtable; the [macross]
            objects are stringified for python to use as a dictionary (see the "mcdefs.py" file)
        [3] $vf19_DEFAULTPATH = the user's desktop path
        [4] $vf19_PYPOD = the list of Base64 encoded defaults, which in MACROSS
            is called $vf19_MPOD
        [5] $vf19_numchk = the hardcoded integer MACROSS uses for math functions
        [6] $vf19_pylib = the filepath to the 'mcdefs.py' file, which is the
            MACROSS python library (more on that later)
        [7] $vf19_TOOLSROOT = the MACROSS root folder, which contains the subfolders
            'nmods', 'resources' & 'ncore'
    """)
    next(1)
    mc.psc('cls')
    splashPage()
    
    print('''
    To begin this demo, we're going to launch a mission in the KÖNIG Monster powershell script.
    If you're not an anime geek, the KÖNIG Monster is a massive space shuttle-type craft that
    transforms into both a land-based rail-gun artillery monstrosity as well as a giant freaking
    robot(!!!) I loved using KÖNIG Monster in the old playstion Macross games.
    
    Anyway, my KÖNIG is a filesearch tool. Feed it a location and a search filter, and it will
    scan however much of your enterprise you give it access to (although its intended purpose is
    narrowly-targeted searches, not full-network scans). If it finds anything matching your search
    filters, it can automatically send those filepaths to the ELINTS script, which will scan each
    file for keywords you specify!
    
    Being a cooperative part of MACROSS, KÖNIG can also accept requests from other scripts -- for
    example, MYLENE.ps1 is a tool that looks up Active-Directory information, especially focusing
    on newly-created accounts. Whenever MYLENE has a list of brand new user accounts, it forwards
    that list to KÖNIG which will automatically report on any and all files in those users' roaming
    profiles.
    
    This python script is going to simulate you running some automated tool that found a filename
    of interest. Let's go!
    ''')
    next(1)
    mc.psc('cls')
    theGoodStuff()

