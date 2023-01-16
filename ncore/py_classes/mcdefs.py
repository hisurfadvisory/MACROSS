"""The mcdefs library is a set of MACROSS functions converted from powershell to python."""
# Put your custom MACROSS-specific classes here (or anywhere in the py_classes
# folder)
'''
    When you import this module to your MACROSS py script, keep in mind it is
    expecting that your python scripts are receiving MACROSS values as sys
    arguments **in this order**
        1: $USR -- the logged in user
        2: $vf19_DEFAULTPATH -- the user's desktop
        3: $vf19_PYOPT -- The base64 encoded defaults contained
            in $vf19_MPOD, but reformatted so python doesn't complain
        4: $vf19_numchk -- MACROSS' mathing integer
        5: $vf19_pylib -- the path to the mcdefs.py file
        6: $vf19_TOOLSROOT -- the path to MACROSS' root folder

    Unless you make this 'mcdefs' library part of your default python env,
    you can simply make use of the $vf19_pylib argument in your scripts
    to temporarily add the import path. This method works well enough for me.
    
    By default it should always be the 5th argument:
        import sys
        NPATH = sys.argv[5]
        sys.path.insert(0,NPATH)
        import mcdefs
    
    ^^ If that gets set properly, you can now import MACROSS's python library
    for use in your automation, and you don't have to contaminate your python
    environment with my janky code! :p
    
    $vf19_TOOLSROOT will contain the nmods folder where your scripts are
    kept... and is also where the "py_classes" folder is located, where you can
    add your own custom MACROSS-related python resources:
        MACROOT = sys.argv[6]             -> set the root folder location
        TOOLS = MACROOT + '\\nmods'       -> set the location of the scripts
        RSRCS = MACROOT + '\\resources'   -> set the location of the resources folder*
        PYLIB = MACROOT + '\\py_classes'  -> set the location of your python stuff

        * You may want to keep the resources folder somewhere other than the MACROSS root
        folder. In that case, you can set its location using...

                    mcdefs.getDefaults(<your index>)

        ...provided you've set it up properly in the MACROSS extras.ps1 file.



    Additionally, to aid in sharing query results back and forth between powershell and
    python, the py_classes folder contains a subfolder called 'garbage_io'. MACROSS
    powershell scripts can write their outputs into this directory, using *.eod files,
    whenever they get called from python. These are plaintext files that you can read() and
    split() to collect things like file locations and the number of successful results from
    powershell (python can't see the default MACROSS globals $RESULTFILE or $HOWMANY... just
    have powershell write these values to an eod).

    MACROSS powershell scripts already know the location of this folder as $vf19_GBIO. You
    can set the location in python using the sys library, set as

                    vf19_GBIO = sys.argv[6] + '\\ncore\\py_classes\\garbage_io'

    These eod files are automatically deleted when MACROSS closes.

    
    
'''

## Trying to only load what we need to start with for common use in a given MACROSS session.
## We don't want to consume a bunch of memory for nothing.
import base64 as b64
import array as arr
from subprocess import run as srun
from os import system as osys
from os import popen as osop
from os import remove as osrm
from time import sleep as ts
from tkinter import Tk
from tkinter.filedialog import askopenfilename as peek
import sys
import re



## Sleep function for pausing scripts when needed
def slp(s):
    """The 'slp' function will pause your script for the number of seconds you pass to it.\n\nUsage:  mcdefs.slp(3)  << Will pause your script for 3 seconds"""
    ts(s)


## This function can generate the equivalent of MACROSS' $vf19_M value
def makeM(n):
    """Passing a large integer to makeM will split it into an array of single-digit integers for mathing.\n\nUsage: var = mcdefs.makeM(123456)  becomes  var == [1,2,3,4,5,6]"""
    a = [int(i) for i in str(n)]
    return a



## Call this function with a filepath (d) to delete a file
def delStuff(d):
    confirm = input('''
    Are you sure you want to delete''',d)
    if re.search("^y",confirm):
        osrm(cc)



##  Run windows commands when needed using os lib
##  Typically, you will call this function with one arg -- a powershell command to launch
##  one of the MACROSS *.ps1 scripts and whatever parameters that powershell script requires.
##  However, if you just need to collect values from a quick command like "hostname" or "ping",
##  call mcdefs.psc() with an empty value as the first arg, and your command as the second:

##          var = mcdefs.psc('','ping 192.168.1.1')

##  Feel free to modify this however you need; you might even need to import the entire os library--
##  everyone has different use-cases, especially with python-based APIs! Just make sure to enact your
##  changes across ALL of the MACROSS functions and scripts!
def psc(c,cc = None):
    """The psc function performs os.system() commands that you pass in. If you pass your command as the *second* arg, the ouput\nwill be read usingos.read().\n\nUsage:  mcdefs.psc('powershell.exe "filepath\\myscript.ps1" "argument 1"') << Will launch your powershell script with args\n         mcdefs.psc('','powershell.exe "filepath\\myscript.ps1" "argument 1"') << Will return the results of your powershell script as usable strings"""
    if cc == None:
        osys(c)
    else:
        TASK = osop(cc)
        return TASK.read()



## This function is just subprocess.run(p)  ---
## I haven't had to use this very often... you may find a better way to utilize/modify it
def psp(p):
    """The psp function is simply 'subprocess.run' made readily available to MACROSS python scripts.\n\nUsage:  mcdefs.psp('powershell.exe "filepath\\myscript.ps1" "argument 1"') << Will launch your powershell script with args"""
    srun(p)
 


## Same as MACROSS' getFile function; if you do not provide an initial directory,
## it will will be set to the C: drive, which you can change via the first
## argument (opendir). The second optional arg (filter) can limit by file
## extensions; default is to list all files. This arg has to be passed as a list.
def getFile(opendir = 'C:\\',filter = (('All files', '*.*'),('All files', '*.*'))):
    """The getFile function opens a dialog window for users to select a file. You can\npass in optional arguments 1) to set the default location for the dialog, and 2) limit the selection\nby file extension.\n\nUsage:  VAR = getFile('your\\directory\\to\\file',(('Adobe Acrobat Document', '*.pdf'),('All files', '*.*'))) """
    Tk().withdraw()
    if filter:
        chooser = peek(initialdir=opendir,filetypes=filter)
        
    return chooser
 


## Same as MACROSS's "getThis" function
## 'd' is the value to decode;
## 'e' is the encoding -- call with 0 to decode base64, or
##  1 to decode hex. Your hex can contain whitespace and/
##  or '0x', this function will strip them out.
##
##  You can pass an optional 3rd arg to specify the out-encoding
##  (ascii, ANSI, etc, default is UTF-8).
##
##      MYVAR = mcdefs.getThisPy('base64 string',0)
##      MYVAR = mcdefs.getThisPy('hex string',1,'ascii')
def getThisPy(d,e,ee = 'utf8'):
    """This is the same as MACROSS' powershell function 'getThis'. Your first argument is the\nencoded string you want to decode, and your second arg will be (0) if decoding base64,\nor (1) if decoding hexadecimal.\n\nUsage:  var = mcdefs.getThisPy('base64string',0)\n                OR\nvar = mcdefs.getThisPy('hexstring',1)"""
    if e == 0:
        decval = b64.b64decode(d)
        decval = decval.decode(ee)
    elif e == 1:
        if re.search('0x',d):
            d = re.sub('0x','',d)
        if re.search(' ',d):
            d = re.sub(' ','',d)
        decval = bytes.fromhex(d).decode(ee)
        
    return decval




##    MACROSS calls all python scripts with at least 6 args (7, if you count
##    the script itself being called via python). The third arg is always
##    $dash_PYOPT, a string that the getDefaults function can use to create a
##    dictionary that lets your python scripts share the same default
##    directories/values as MACROSS' $vf19_MPOD hashtable.
##    
##    Declare a new dictionary by calling this function with sys.argv[3] as
##    your first argument (x), and 0 as your second argument (y). After you have
##    your dictionary, you can decode its indexes at any time by calling
##    this function again with a specific index, and (1) as the second arg.
##    
##    EXAMPLES:
##
##
##        vf19_PYOPT = mcdefs.getDefaults(sys.argv[3],0)
##        ^^ This is your dictionary, containing any indexed values you supplied in the
##        extras.ps1 file as described in the README files.
##        
##        repo = mcdefs.getDefaults(vf19_PYOPT['nre'],1)
##        ^^If you set your master repo location with 'nre' as its index, then calling
##        getDefaults again will decode that filepath for you to use anytime in
##        your python scripts. Make sure to set (1) as the second arg!
def getDefaults(x,y):
    """This function is solely for splitting and decoding MACROSS' $vf19_PYOPT list\ninto the encoded default strings your scripts may need to use. To create your\ninitial dictionary, call this function with a (0) for the second arg. After that,\ncall with the specific index needed from your dictionary with a (1) as the second arg.\n\n    Usage:  vf19_PYOPT = mcdefs.getDefaults(sys.argv[3],0)\nNow let's say vf19_PYOPT contains an index 'tbl' with the filepath to some JSON files:\n    JSONdir = mcdefs.getDefaults(vf19_PYOPT['tbl'],1)"""
    if y == 0:
        newlist = {}
        w = x.split(',')
        for line in w:
            kkey = line[0:3]
            kval = re.sub("^.{3}",'',line)
            kdct = {kkey:kval}
            newlist.update(kdct)
        return newlist
    elif y == 1:
        DECVAL = getThisPy(x,0)
        return DECVAL
