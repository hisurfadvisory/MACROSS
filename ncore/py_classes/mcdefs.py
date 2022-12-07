"""The mcdefs library is a set of MACROSS functions converted from powershell to python."""
# Put your custom MACROSS-specific classes here (or anywhere in the py_classes
# folder)
'''
    When you import this module to your MACROSS py script, keep in
    mind it is expecting that your python scripts are receiving
    MACROSS values as sys arguments **in this order**
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
    
    $vf19_TOOLSROOT will contain the nmods folder where your scripts are
    kept... and is also where the "py_classes" folder is located, where you can
    add your own custom MACROSS-related python resources.
    
    By default it should always be the 6th argument:

        import sys
        MACROOT = sys.argv[6]
        NPATH = MACROOT + '\\nmods\\py_classes'
        sys.path.insert(0,NPATH)
        import mcdefs

    ^^ If that gets set properly, you can now import MACROSS's python library
    for use in your automation, and you don't have to contaminate your python
    environment with my janky code! :p
    
    Further, you can continue using MACROOT to locate other scripts you may
    want to launch, or if you leave the resources folder within root:

        TOOLS = MACROOT + '\\nmods'
        RSRCS = MACROOT + '\\resources'
    
'''

import base64 as b64
import array as arr
from subprocess import run as srun
from os import system as osys
from time import sleep as t
import sys
import re



## Sleep function for pausing scripts when needed
def s(s):
    """The 's' function will pause your script for the number of seconds you pass to it.\n\nUsage:  mcdefs.s(3)  << Will pause your script for 3 seconds"""
    t.sleep(s)


def makeM(n):
    """Passing a large integer to makeM will split it into an array of single-digit integers for mathing.\n\nUsage: var = mcdefs.makeM(123456)  becomes  var == [1,2,3,4,5,6]"""
    a = [int(i) for i in str(n)]
    return a

## Run windows commands when needed using os lib
##  The 2nd arg is used for telling python where MACROSS and its powershell/python
##  scripts are; set to '1' to get the nmods folder path, then call psc again
##  with your nmods filepath as the 1st arg, and '2' as the second arg to find the
##  MACROSS folder path
def psc(c,subf = None):
    """The psc function performs os.system() commands that you pass in, if you don't want to use the psp function instead.\n\nUsage:  mcdefs.psc('powershell.exe "filepath\\myscript.ps1" "argument 1"') << Will launch your powershell script with args"""
    if subf == None:
        osys(c)
        


def psp(p):
    """The psp function is simply 'subprocess.run()' made readily available to MACROSS python scripts.\n\nUsage:  mcdefs.psp('powershell.exe "filepath\\myscript.ps1" "argument 1"') << Will launch your powershell script with args"""
    srun(p)
    

'''
    Same as MACROSS's "getThis" function
    'd' is the value to decode;
    'e' is the encoding -- call with 0 to decode base64, or
        1 to decode hex. Your hex can contain whitespace and/
        or '0x', this function will strip them out.

        MYVAR = ncdefs.getThisPy('base64 string',0)
        MYVAR = ncdefs.getThisPy('hex string',1)
        
'''
def getThisPy(d,e):
    """This is the same as MACROSS' powershell function 'getThis'. Your first argument is the\nencoded string you want to decode, and your second arg will be (0) if decoding base64,\nor (1) if decoding hexadecimal.\n\nUsage:  var = mcdefs.getThisPy('base64string',0)\n                OR\nvar = mcdefs.getThisPy('hexstring',1)"""
    if e == 0:
        decval = b64.b64decode(d)
        decval = decval.decode('ascii')
    elif e == 1:
        if re.search('0x',d):
            d = re.sub('0x','',d)
        if re.search(' ',d):
            d = re.sub(' ','',d)
        decval = bytes.fromhex(d).decode('ascii')
        
    return decval



'''
    MACROSS calls all python scripts with at least 6 args. The third arg
    is always $dash_PYOPT, a string that the getDefaults function can
    use to create a dictionary that lets your python scripts share the
    same default directories/values as MACROSS' $vf19_MPOD hashtable.
    
    Declare a new dictionary by calling this function with sys.argv[3] as
    your first argument, and (0) as your second argument. After you have
    your dictionary, you can decode its indexes at any time by calling
    this function again with that index, and (1) as the second arg.
    
    EXAMPLE:
        vf19_PYOPT = mcdefs.getDefaults(sys.argv[3],0)
        ^^ This is your dictionary, containing any indexed values you supplied in the
        extras.ps1 file as described in the README files.
        
        repo = mcdefs.getDefaults(vf19_PYOPT['nre'],1)
        ^^If you set your master repo location with 'nre' as its index, then calling
        getDefaults again will decode that filepath for you to use anytime in
        your python scripts. Make sure to set (1) as the second arg!
        
'''
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
