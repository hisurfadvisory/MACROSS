#_wut Demo - uses MINMAY to import MACROSS python lib
#_ver 0.1

## Temporarily add my custom import to syspath
import sys
L = len(sys.argv)

def splashPage():
    print("""

        ███╗   ███╗██╗██╗     ██╗ █████╗
        ████╗ ████║██║██║     ██║██╔══██╗
        ██╔████╔██║██║██║     ██║███████║
        ██║╚██╔╝██║██║██║     ██║██╔══██║
        ██║ ╚═╝ ██║██║███████╗██║██║  ██║
        ╚═╝     ╚═╝╚═╝╚══════╝╚═╝╚═╝  ╚═╝
    ==========================================
    """)

'''
The 3rd arg should always be the $vf19_TOOLSDIR variable; the filepath to
the nmods folder where the py_classes subfolder is located
'''
if L == 2:
    USR = sys.argv[1]
if L >= 7:  
    npath = sys.argv[5]  ## finish creating the filepath
    sys.path.insert(0,npath)  ## modify the sys path to include the py_classes folder
    USR = sys.argv[1]
    vf19_DEFAULTPATH = sys.argv[2]
else:
    npath = None

if L > 7:
    CALLER = sys.argv[7]
else:
    CALLER = None
if L > 8:
    PROTOCULTURE = sys.argv[8]
else:
    PROTOCULTURE = None


if USR == 'HELP':
    splashPage()
    print('''

    This is a python script that runs through the steps of importing MACROSS'
    default values for use in your python automations. If you want your python
    scripts to share resources from MACROSS, you'll need to import the sys
    library and process all of the args that MACROSS sends (they're always in
    order).

    Hit ENTER to return.
    ''')
    input()
    exit()



## Make use of MACROSS's default variables
if npath:
    import mcdefs as mc # Can't import if we never got the filepath from MACROSS
    splashPage()

    if CALLER == None:
        print("""
    This is a demo python script launched by MACROSS. In this framework, powershell ALWAYS
    passes 6 default arguments to python, so if you're writing python scripts to work with
    MACROSS, you'll always need the sys library at a minimum to use MACROSS' defaults:
        arg 1 = the logged-in user
        arg 2 = the user's desktop filepath
        arg 3 = MACROSS' encoded default URL/IP filepath hashtable ($vf19_MPOD), sent as a
            comma-separated string for python to split into a dictionary
        arg 4 = MACROSS' numchk integer value for any mathing you want to make common
            across all the scripts
        arg 5 = the filepath to the MACROSS python library
        arg 6 = the filepath to the MACROSS root directory""")
    else:
        print("""
    This python script was called from the""",CALLER,"""powershell script.""")
        
    print("""
    I'm using the fifth argument passed to me, $vf19_pylib, to tell python where
    the MACROSS library is so I can import it:""")

    print("""
    I create the filepath with:

            n1 = sys.argv[5]""")
    print("""
    Then temporarily jam it into the sys path and import the library:

            sys.path.insert(0,n1)
            import mcdefs

    Hit ENTER to continue!""")
    input()

    
    ''' ============================================================
        The 3rd argument sent by MACROSS is always the $vf19_PYOPT variable, which is
        the Base64-encoded filepaths to things like the MACROSS resources folder, the
        master REPO, and anything else that your scripts will be using regularly.

        The mcdefs library contains MACROSS's deobfuscation functions rewritten for
        python so that you can decode these filepaths and store them as global vars
        whenever you need to.
        ============================================================'''

    
    a = sys.argv[3]  ## 3rd arg from MACROSS should always be $dash_PYOPT
    mc.psc('cls')    ## Clear the screen via os.system
    print("""
    Now that I have the library's resources, I can call one of its functions, 'getDefaults',
    to make use of MACROSS' default values stored in $vf19_PYOPT (this powershell variable
    is a string-ified conversion of MACROSS' $vf19_MPOD hashtable). It should ALWAYS be the
    3rd arg passed from MACROSS or its powershell scripts:

            n2 = sys.argv[3]""")
    print("""
    Now I can use 'getDefaults' to build my vf19_MPOD dictionary by setting the second param
    to '0':

            vf19_MPOD = mcdefs.getDefaults(n2,0)

    The variable naming style (vf19_) is meant to keep things uniform in MACROSS. (And
    Nekki Basara's VF-19 Fire Valkyrie is the coolest valkyrie in any Macross series, IMHO).
    You don't have to follow this convention, but it is HIGHLY recommended. Using the same
    prefix for shared core variables in MACROSS allows managing when/if they get cleared out as
    needed.
    
    Let's see what vf19_MPOD contains after using 'getDefaults'! Hit ENTER:""")
    input()
    mc.psc('cls')
    vf19_MPOD = mc.getDefaults(a,0)  ## This splits the $vf19_PYOPT string into an indexed dictionary
    print('''
    ''')
    for i in vf19_MPOD:
        print('   ',i,'=',vf19_MPOD[i])  ## This is to display the result of the last function

    print("""
    ^^This is our dictionary created from MACROSS' $vf19_PYOPT string variable; it looks just
    like MACROSS' $vf19_MPOD hashtable, and can be used the exact same way!""")
    
    print("""
    Okay, so what if I need to use one of these encoded values in my script? (Right now, these
    are all unused placeholders). We'll call the same 'getDefaults' function again, but this time
    using the index it created for us, and sending '1' as the second parameter/argument. 
    """)
    Z = input('''
        Choose one of the three-letter index keys shown above >  ''')

    ZZ = '\'' + Z + '\''
    print("""
    Okay, using your index choice we'll call the 'getDefaults' function again for
    """,Z,"""like so:

            FPATH = mc.getDefaults(vf19_MPOD[""",ZZ,"""],1)""")
    input('''
    Hit ENTER.
    ''')
    mc.psc('cls')
    Z1 = mc.getDefaults(vf19_MPOD[Z],1)
    print('''

    Voila -- the value for''',Z,'''has been decoded, and the var FPATH is set to:

          FPATH ==''',Z1)
    input('''
    Hit ENTER...''')


    mc.psc('cls')
    print("""
        There are other default functions to take advantage of by importing mcdefs; mostly
        basic stuff but it's made commonly available to all MACROSS python tools automatically
        so that you can just import sys and mcdefs, which then makes libraries like subprocess,
        array and others available at the same time. So make sure to review the
        
                nmods\\py_classes\\mcdefs.py
        
        file for all the notes! Hit ENTER to jump back to MACROSS.


        """)
    input()
    
else:
    print('''
    ERROR! Could not import mcdefs!! This script is meant to use data
    sent over from powershell; calling it by itself just gives you this
    useless message.

    Hit ENTER to continue.''')
    input()



