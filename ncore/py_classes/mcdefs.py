"""The mcdefs library is a set of MACROSS functions converted from powershell to python."""
# Put your custom MACROSS-specific classes at the bottom of this file (or anywhere in the py_classes
# folder)
'''
    When you import this module to your MACROSS python script, keep in mind it is
    expecting that your python scripts are receiving MACROSS values as sys
    arguments **in this order**
    
        [1] $USR -- the logged in user
        [2] $pyATTS -- The macross class .name and .valtype attributes from
                all of the scripts in the "nmods" folder
        [3] $vf19_DEFAULTPATH -- the user's desktop
        [4] $vf19_PYOPT -- The base64 encoded defaults contained
                in $vf19_MPOD, but reformatted so python doesn't complain
        [5] $vf19_numchk -- MACROSS' mathing integer
        [6] $vf19_pylib -- the path to the mcdefs.py file
        [7] $vf19_TOOLSROOT -- the path to MACROSS' root folder
        
    Unless you make this 'mcdefs' library part of your default python env,
    you can simply make use of the $vf19_pylib argument in your scripts
    to temporarily add the import path. This method works well enough for me.
    
    By default it should always be the 6th argument sent by the "collab" or
    "availableMods" functions in the validation.ps1 file:
    
        import sys
        MCDEF = sys.argv[6]
        sys.path.insert(0,MCDEF)
        import mcdefs
    
    ^^ If that gets set properly, you can now import MACROSS's python library
    for use in your automation, and you don't have to contaminate your python
    environment with my janky code! :p
    
    $vf19_TOOLSROOT will contain the nmods folder where your scripts are
    kept... and is also where the "py_classes" folder is located, where you can
    add your own custom MACROSS-related python resources:
    
        MACROOT = sys.argv[7]             -> set the MACROSS root folder location
        TOOLS = MACROOT + '\\nmods'       -> set the location of the scripts
        RSRCS = MACROOT + '\\resources'   -> set the location of the resources folder*
        PYLIB = MACROOT + '\\py_classes'  -> set the location of your python stuff
        
        * You may want to keep the resources folder somewhere other than the MACROSS root
        folder. In that case, you can set its location using...
        
                    mcdefs.getDefaults(<your index>)
                    
        ...provided you've set it up properly in the MACROSS utility.ps1 file.
        
    Additionally, to aid in sharing query results back and forth between powershell and
    python, the py_classes folder contains a subfolder called 'garbage_io'. MACROSS
    powershell scripts can write their outputs into this directory, using *.eod files,
    whenever they get called from python (there is a built-in utility called "pyCross" in
    the utility.ps1 file specifically to do this). These are plaintext files that you can
    read() and split() to collect results that might be too large or complex to receive as
    a simple variable.
    
    MACROSS powershell scripts already know the location of this folder as $vf19_GBIO. You
    can set the location in python using the sys library, set as
    
                    vf19_GBIO = sys.argv[6] + '\\ncore\\py_classes\\garbage_io'
                    
    These eod files are automatically deleted when MACROSS exits cleanly, or
    when MACROSS starts after a crash where it did not get to delete them when
    expected.
    
'''

################################################################
###################    IMPORT SECTION    #######################
################################################################
## Trying to only load what we need to start with for common use in a given MACROSS session.
## We don't want to consume a bunch of memory for nothing, and we also don't want to assume
## that we can just pip install whatever we want to. Hopefully most organizations have some
## sort of controls in place to restrict who can install stuff. Modify and add functions or
## classes here as necessary for your environment (classes go at the very bottom).
import base64 as b64
import array as arr
from subprocess import run as srun
from os import system as osys
from os import popen as osop
from os import path as path
from os import remove as osrm
from time import sleep as ts
from tkinter import Tk
from tkinter.filedialog import askopenfilename as peek
import math
import sys
import re




################################################################
###############  FUNCTION DEFINITIONS  #########################
################################################################


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
        osrm(d)

## Regex is your friend
## Since I needed to import re anyway, might as well make it available to other scripts.
## Pass in a replacement string as a third arg to do basic string edits
def rgx(pattern,string,replace = None):
    if replace == None:
        r = re.search(pattern,string)
    else:
        r = re.sub(pattern,replace,string)

    return r


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


## Also from the os library, *path* has lots of common uses for MACROSS
## Verify the existence of a path, file or directory.
## "check" is what you're looking to verify, "method" is its type
## This function returns true/false
def dirfile(check,method = 'exists'):
    if method == 'exists':
        a = path.exists(check)
    elif method == 'isfile':
        a = path.isfile(check)
    elif method == 'isdir':
        a = path.isdir(check)

    return a


## This function is just subprocess.run(p)
## For when the os lib doesn't have what you need
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
 

## Same as MACROSS' screenResults function, but without color options
## Too bad colorama isn't part of the standard lib... but feel free to
## install it and modify this function if your org allows it.
##
## Pass in up to three values, each of which will be type-wrapped into its
## own column on screen. Call this function without any values to write
## the closing row of "≡≡≡" characters.
def screenResults(A = 'endr',B = None,C = None):
    '''Usage: screenResults(value1,value2,value3)\nEach value is optional, and will be written to screen in separate rows & columns. To finish your outputs,\ncall the function again without any values to write the closing row boundary.'''
    r = '‖≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡‖' ## 98 char length
    c = '‖'

    if A == 'endr':
        print(r)

    else:
        
        ## Write text to screen without newlines
        def csep(text):
            print(text, end = ' ')

            
        def genBlocks(outputs,min,max):
            o1 = []
            o2 = []
            o3 = len(outputs)
            MAX = max + 1
            if o3 > MAX:
                SPACE = outputs.count(' ')
                if SPACE > 0:
                    outputs = rgx('(\s\s+|\t|`n)',outputs,' ')
                    P = outputs.split(' ')
                    WIDE = 0
                else:
                    P = None
                    CUT = MAX + 1
                    o2.append(outputs[0:MAX])
                    o2.append(outputs[MAX:])

            else:
                P = None
                while o3 != max:
                    outputs = outputs + ' '
                    o3 += 1
                o2.append(outputs)

            if P != None:
                for WORD in P:
                    L = len(WORD)
                    WIDE = WIDE + (L + 1)

                    if WIDE < min:
                        Word = WORD + ' '
                        o1.append(Word)
                    else:
                        BLOCK = ' '.join(o1)
                        BLOCK = rgx('\s{2,}',BLOCK,' ')  ## Remove multi-spaced chars
                        BL = len(BLOCK)
                        if BL > MAX:                     ## Cut extra long strings without whitespace
                            CUT = MAX + 1
                            o2.append(WORD[0:MAX])
                            o2.append(WORD[CUT:])
                        else:
                            if BL < MAX:
                                while BL != MAX:
                                    BLOCK = BLOCK + ' ' ## Add space if the line is < MAX
                                    BL += 1

                            o2.append(BLOCK)
                                
                        o1 = []               ## Reset the list
                        Word = WORD + ' '
                        o1.append(Word)       ## Add the current word to the list
                        WIDE = L + 1          ## Reset the line length

                    ## If the current o1 item is the last one from outputs, add it to
                    ## the o2 response
                    if WORD == P[-1]:
                        LAST = ' '.join(o1)
                        L = len(LAST)
                        if L > MAX:
                            CUT = MAX + 1
                            o2.append(LAST[0:MAX])
                            o2.append(LAST[CUT:])
                        else:
                            if L < MAX:
                                while L != MAX:
                                    LAST = LAST + ' '
                                    L += 1
                            
                            o2.append(LAST)

                    
            return o2
        ## End genBlocks nested function

        WIDE1 = len(A)

        
        if B != None:
            WIDE2 = len(B)
            BLOCK1 = genBlocks(A,23,22)
            if C != None:
                WIDE3 = len(C)
                BLOCK2 = genBlocks(B,34,32)
                BLOCK3 = genBlocks(C,30,28)
                CT3 = len(BLOCK3)
            else:
                CT3 = None
                BLOCK2 = genBlocks(B,69,67)
                
            CT2 = len(BLOCK2)

        else:
            CT3 = None
            CT2 = None
            BLOCK1 = genBlocks(A,93,91)

        CT1 = len(BLOCK1)

        EMPTY1 = '                      '                     ## 22 char length 1st column
        if CT3 != None:
            EMPTY2 = '                                 '      ## 33 char length  2nd column with 3rd
            EMPTY3 = '                             '          ## 28 char length  3rd column
        elif CT2 != None:                                     ## 65 char length 2nd column without 3rd
            EMPTY2 = '                                                                 '


        ## Iterate through each column block for strings
        INDEX1 = 0
        INDEX2 = 0
        INDEX3 = 0
        LINENUM = 0

        print(r)

        '''
        Outputs will get formatted to screen based on:
            -how many values got passed in (1, 2, or 3)
            -how many words are in each output
            -which outputs have the most words in them
            -I hate math
        '''
        if CT3 != None:
            COUNTDOWN = CT1 + CT2 + CT3
            while COUNTDOWN != 0:
                csep(c)
                if CT1 != 0:
                    csep(BLOCK1[INDEX1])
                    CT1 = CT1 - 1
                    INDEX1 += 1
                    COUNTDOWN = COUNTDOWN - 1
                else:
                    csep(EMPTY1)

                csep(c)
                if CT2 != 0:
                    csep(BLOCK2[INDEX2])
                    CT2 = CT2 - 1
                    INDEX2 += 1
                    COUNTDOWN = COUNTDOWN - 1
                else:
                    csep(EMPTY2)

                csep(c)
                if CT3 != 0:
                    csep(BLOCK3[INDEX3])
                    CT3 = CT3 - 1
                    INDEX3 += 1
                    COUNTDOWN = COUNTDOWN - 1
                else:
                    csep(EMPTY3)

                print(c)
    
        elif CT2 != None:
            if CT1 > CT2:
                if CT2 == 1:
                    MIDDLE = math.ceil((CT1/2) - 1)
                else:
                    MIDDLE = math.ceil((CT1/CT2) - 1)

                for Block in BLOCK1:
                    if LINENUM < MIDDLE:
                        csep(c)
                        csep(Block)
                        csep(c)
                        csep(EMPTY2)
                        print(c)
                        LINENUM += 1
                    else:
                        csep(c)
                        csep(Block)
                        csep(c)
                        if CT2 != 0:
                            csep(BLOCK2[INDEX2])
                            print(c)
                            INDEX2 += 1
                            CT2 = CT2 - 1
                        else:
                            LINENUM = -1
                            csep(EMPTY2)
                            print(c)
            elif CT2 > CT1:
                if CT1 == 1:
                    MIDDLE = math.ceil((CT2/2) - 1)
                else:
                    MIDDLE = math.ceil((CT2/CT1) - 1)

                for Block in BLOCK2:
                    csep(c)
                    if LINENUM < MIDDLE:
                        csep(EMPTY1)
                        LINENUM += 1
                    else:
                        if CT1 != 0:
                            csep(BLOCK1[INDEX1])
                            csep(c)
                            INDEX1 += 1
                        else:
                            LINENUM = -1
                            csep(EMPTY1)
                    csep(c)
                    if CT2 != 0:
                        csep(Block)
                    print(c)
            else:
                for Block in BLOCK2:
                    csep(c)
                    csep(BLOCK1[INDEX1])
                    INDEX1 += 1
                    csep(c)
                    if CT2 != 0:
                        csep(Block)
                    print(c)
        else:
            for Block in BLOCK1:
                csep(c)
                csep(Block)
                print(c)
            



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




##    MACROSS calls all python scripts with at least 7 args (8, if you count
##    the script itself being called via python). The fourth arg is always
##    $vf19_PYPOD, a string that the getDefaults function can use to create a
##    dictionary that lets your python scripts share the same default
##    directories/values as MACROSS' $vf19_MPOD hashtable.
##    
##    Declare a new dictionary by calling this function with sys.argv[4] as
##    your first argument (x), and 0 as your second argument (y). After you have
##    your dictionary, you can decode its indexes at any time by calling
##    this function again with a specific index, and (1) as the second arg.
##    
##    EXAMPLES:
##
##
##        vf19_PYOPT = mcdefs.getDefaults(sys.argv[4],0)
##        ^^ This is your dictionary, containing any indexed values you supplied in the
##        utility.ps1 file as described in the README files.
##        
##        repo = mcdefs.getDefaults(vf19_PYOPT['nre'],1)
##        ^^If you set your master repo location with 'nre' as its index, then calling
##        getDefaults again will decode that filepath for you to use anytime in
##        your python scripts. Make sure to set (1) as the second arg!
##
##
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

## Similar to getDefaults above, but replicates MACROSS' $vf19_ATTS hashtable so that python
## scripts can read the [macross].name and [macross].valtype attributes of other scripts.
def getATTS(l):
    """MACROSS passes the .name and .valtype attributes from its $vf19_ATTS hashtable via sys.argv[2]\nevery time it calls a python script. Send that value to this function, and you will get a pythonized\n$vf19_ATTS dictionary to do macross attribute evals in your python scripts."""
    ls = l.split(',') ## separate each script entry
    dict0 = {}
    for atts in ls:
        vals = atts.split('=')
        dict0[vals[0]] = vals[1]
       
    return dict0
    
    
    

################################################################
####################  CLASSES SECTION  #########################
################################################################
#class macross():
    
