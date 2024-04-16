"""The mcdefs library is a set of MACROSS functions converted from powershell to python."""
# Put your custom MACROSS-specific classes at the bottom of this file (or anywhere in the py_classes
# folder)
'''
    When you import this module to your MACROSS python script, keep in mind it is
    expecting that your python scripts are receiving MACROSS values as sys
    arguments **in this order**
    
        [1] $USR -- the logged in user
        [2] $pyATTS -- The macross class .name and .valtype attributes from
                all of the scripts in the "modules" folder
        [3] $vf19_DEFAULTPATH -- the user's desktop
        [4] $vf19_PYPOD -- The base64 encoded defaults contained
                in $vf19_MPOD, but reformatted so python doesn't complain
        [5] $vf19_numchk -- MACROSS' mathing integer
        [6] $vf19_pylib -- the path to the mcdefs.py file
        [7] $vf19_TOOLSROOT -- the path to MACROSS' root folder
        
    No need to make this 'mcdefs' library part of your default python env,
    you can simply make use of the $vf19_pylib argument in your scripts
    to temporarily add the import path.
    
    By default it should always be the 6th argument sent by the "collab" or
    "availableMods" functions in the validation.ps1 file:
    
        import sys
        MCDEF = sys.argv[6]
        sys.path.insert(0,MCDEF)
        import mcdefs
    
    ^^ If that gets set properly, you can now import MACROSS's python library
    for use in your automation, and you don't have to contaminate your python
    environment with my janky code! :p
    
    $vf19_TOOLSROOT will contain the modules folder where your scripts are
    kept... and is also where the "py_classes" folder is located, where you can
    add your own custom MACROSS-related python resources:
    
        MACROOT = sys.argv[7]             -> set the MACROSS root folder location
        TOOLS = MACROOT + '\\modules'       -> set the location of the scripts
        RSRCS = MACROOT + '\\resources'   -> set the location of the resources folder*
        PYLIB = MACROOT + '\\py_classes'  -> set the location of your python stuff
        
        * You may want to keep the resources folder somewhere other than the MACROSS root
        folder. In that case, you can set its location using...
        
                    mcdefs.getDefaults(<your index>)
                    
        ...provided you've set it up properly in the MACROSS temp_config.txt file.
        
    Additionally, to aid in sharing query results back and forth between powershell and
    python, the py_classes folder contains a subfolder called 'garbage_io'. MACROSS
    scripts can write their outputs into this directory, using *.eod files, (there is a 
    built-in utility called "pyCross" in the utility.ps1 file specifically to do this). 
    These are plaintext files that you can read() and split() to collect results that 
    might need to be stored for later in a session.
    
    MACROSS powershell scripts already know the location of this folder as $vf19_GBIO. 
    You can set the location in python using the sys library, set as
    
                    vf19_GBIO = sys.argv[6] + '\\core\\py_classes\\garbage_io'
                    
    The garbage_io folder is automatically cleaned up when MACROSS exits.
    
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
from os import path
from os import remove as osrm
from json import dumps as jdmp
from time import sleep as ts
from tkinter import Tk
from tkinter.filedialog import askopenfilename as peek
import math
from re import search,sub


## Enable terminal colors for w() function
##
osys('color')   ## Colorize the terminal
tcolo = {
'g':'\033[92m',
'c':'\033[96m',
'm':'\033[95m',
'y':'\033[93m',
'b':'\033[94m',
'r':'\033[91m',
'bl':'\033[30m',
'ul':'\033[4m',
'rs':'\033[0m'
}

################################################################
###############  FUNCTION DEFINITIONS  #########################
################################################################

## Alias to write colorized text to screen
def w(TEXT,C1 = 'rs',C2 = None):
    ''' Pass this function your text/string as arg 1 and the first letter of the color you\n want ("bl" for black). You can pass "ul" as a second option to underline the text.\n\n Usage: mcdefs.w(text,text_color,'ul')'''
    if C2 != None:
        print(tcolo[C1] + tcolo[C2] + TEXT + tcolo['rs'])
    else:
        print(tcolo[C1] + TEXT + tcolo['rs'])


## Sleep function for pausing scripts when needed
def slp(s):
    """The 'slp' function will pause your script for the number of seconds you pass to it.\n\n Usage:  mcdefs.slp(3)\n ^^ Will pause your script for 3 seconds\n"""
    ts(s)


## This function can generate the equivalent of MACROSS' $vf19_M value
def makeM(n):
    """ Passing a large integer to makeM will split it into an array of single-digit integers for mathing.\n\n Usage: var = mcdefs.makeM(123456)\n ^^ becomes  var == [1,2,3,4,5,6]"""
    a = [int(i) for i in str(n)]
    return a


## Call this function with a filepath (d) to delete a file
def dS(d):
    ''' Delete files. Usage:\n dS(path_to_file)'''
    confirm = input('''
    Are you sure you want to delete''',d)
    if search("^y",confirm):
        osrm(d)

## Regex is your friend
## Since I needed to import re anyway, might as well make it available to other scripts.
## Pass in a replacement string as a third arg to do basic string edits
def rgx(pattern,string,replace = None):
    if replace == None:
        r = search(pattern,string)
    else:
        r = sub(pattern,replace,string)

    return r


##  Run windows commands when needed using os lib
##  Typically, I call this function with one arg -- a powershell command to launch
##  one of the MACROSS *.ps1 scripts and whatever parameters that powershell script requires.
##  If you need to collect values from the script, or from a quick command like "hostname" or 
##  "ping", call mcdefs.psc() with an empty value as the first arg, and your command as the second:

##          var = mcdefs.psc('','ping 192.168.1.1')

##  Feel free to modify this however you need; you might even need to import the entire os library--
##  everyone has different use-cases, especially with python-based APIs! Just make sure to enact your
##  changes across ALL of the MACROSS functions and scripts!
def psc(c,cc = None):
    """ The psc function performs os.system() commands that you pass in. If you pass your command\n as the *second* arg, the ouput\nwill be read using os.read().\n\n Usage:  mcdefs.psc('powershell.exe "filepath\\myscript.ps1" "argument 1"')\n ^^ Will launch your powershell script with args\n\n mcdefs.psc('','powershell.exe "filepath\\myscript.ps1" "argument 1"')\n ^^ Will return the results of your powershell script as usable strings"""
    if cc == None:
        osys(c)
    else:
        TASK = osop(cc)
        return TASK.read()


## Also from the os library, *path* has lots of common uses for MACROSS
## Verify the existence of a path, file or directory.
## Send what you're looking to verify as arg 1, and its type ("dir" vs. "file") as optional arg 2
## This function returns true/false
def drfl(check,method = 'e'):
    ''' Check if a path exists. Send "file" or "dir" as the second argument (optional).\n Usage: drfl(path_to_check,optional)'''
    if method == 'file':
        a = path.isfile(check)
    elif method == 'dir':
        a = path.isdir(check)
    elif method == 'e':
        a = path.exists(check)

    return a


## This function is just subprocess.run(p)
## For when the os lib doesn't have what you need
def psp(p):
    """The psp function is simply 'subprocess.run' made readily available to MACROSS python scripts.\n\nUsage:  mcdefs.psp('powershell.exe "filepath\\myscript.ps1" "argument 1"')\n^^ Will launch your powershell script with args\n"""
    srun(p)
 

## Must pass your argv[7] value (the $vf19_TOOLSROOT path) + the tool you're calling, and the name of your calling script.
## Have to use the GBIO folder because this opens a new powershell session that won't have all the $vf19_LATTS data.
def collab(TOOL,CALLER,PROTOCULTURE,extra = None):
    ''' The python "collab" function writes your PROTOCULTURE value to a dictionary .eod file\n in the GBIO folder for the powershell script to read and write its results to. Make sure to\n add your "sys.argv[7] + \\\\modules" directory to the "tool" argument! USAGE:\n\n        collab(TOOL,CALLER,PROTOCULTURE,optional_value)\n
    '''
    gbio = rgx("modules.+",TOOL,'core\\\\py_classes\\\\garbage_io\\\\PROTOCULTURE.eod')
    proto = {CALLER:{'target':PROTOCULTURE,'result':''}}
    with open(gbio, 'w') as convert_file: 
        convert_file.write(jdmp(proto))
        
    call = 'powershell.exe ' + TOOL + ' py' + CALLER
    if extra != None:
        call = call + ' ' + extra
    psc(call)


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
 

## Same as MACROSS' screenResults function, with minor differences.
##
## For each arg, begin with the first letter of a powershell-compatible color
## ("bl" for black, "b" for blue, and no purple but "m" for magenta) and a "~"
## char.  Example:  screenResults("c~My output is written to screen in cyan.")
##
## Pass in up to three values, each of which will be type-wrapped into its
## own column on screen. Call this function WITHOUT any values to write
## the closing row of "≡≡≡" characters.
##
## Your mileage may vary depending on the strings that get passed in; I sometimes
## get a display with broken columns. It usually works pretty well, though.
def screenResults(A = 'endr',B = None,C = None):
    '''Usage: screenResults(value1,value2,value3)\n\nEach value is optional, and will be written to screen in separate rows & columns.\nYou can send the first letter of a color ("bl" for black) and "~" to colorize text,\nfor example "c~Value" to write "Value" in cyan.\nColors:(c)yan, (bl)ack, (b)lue, (r)ed, (y)ellow, (w)hite, (m)agenta, and (ul) for underline.\nTo finish your outputs, call the function again without any values to write the closing row boundary.'''
    atc = btc = ctc = None      ## Default text color
    c = chr(8214)
    RC = chr(8801)
    r = c + RC
    for rr in range(1,98):      ## 98 char length
        r = r + RC
    r = r + c
    del(rr)
    
    
    if A == 'endr':
        w(r,'g')

    else:
        
        ## Write text to screen without newlines
        def csep(text,tc=None):
            if tc != None:
                print(tcolo[tc] + text + tcolo['rs'], end = ' ')
            else:
                print(text, end = ' ')

        ## Take the input and wrap it to fit within the specified column width, OR
        ## if the input is smaller, add whitespace to increase its length.
        def genBlocks(outputs,min,max):
            o1 = []
            o2 = []
            o3 = len(outputs)
            MAX = max + 1
            if o3 > MAX:
                SPACE = outputs.count(' ')
                if SPACE > 0:
                    outputs = rgx('(\s\s+|\t|`n)',outputs,' ')  ## Remove tabs/newlines from string
                    #outputs = rgx('\\',outputs,'\\\\')          ## Escape backslash chars
                    P = outputs.split(' ')                      ## Create an array with each word as a value
                    WIDE = 0
                else:
                    P = None
                    CUT = MAX + 1
                    o2.append(outputs[0:MAX])
                    o2.append(outputs[MAX:])

            elif o3 < min:
                P = None
                while o3 != min:
                    outputs = outputs + ' '
                    o3 += 1
                o2.append(outputs)
            else:
                P = None

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
        
        ## Check for highlight tags
        if rgx("^[a-z]{1,2}~",A):
            atc = rgx("~.+",A,'')
            A = rgx("^[a-z]{1,2}~",A,'')
        if B != None and rgx("^[a-z]{1,2}~",B):
            btc = rgx("~.+",B,'')
            B = rgx("^[a-z]{1,2}~",B,'')
        if C != None and rgx("^[a-z]{1,2}~",C):
            ctc = rgx("~.+",C,'')
            C = rgx("^[a-z]{1,2}~",C,'')
            
        WIDE1 = len(A)

        
        if B != None:
            WIDE2 = len(B)
            BLOCK1 = genBlocks(A,25,24)
            if C != None:
                WIDE3 = len(C)
                BLOCK2 = genBlocks(B,35,33)
                BLOCK3 = genBlocks(C,30,28)
                CT3 = len(BLOCK3)
            else:
                CT3 = None
                BLOCK2 = genBlocks(B,68,65)
                
            CT2 = len(BLOCK2)

        else:
            CT3 = None
            CT2 = None
            BLOCK1 = genBlocks(A,93,91)

        CT1 = len(BLOCK1)

        ## Generate empty lines based on how many columns are needed
        def makeEmpty(ii):
            ee = ' '
            for i in range(1,ii):
                ee = ee + ' '
            return ee
            
        EMPTY1 = makeEmpty(25)              ## 25 empty char length 1st column
        if CT3 != None:
            EMPTY2 = makeEmpty(35)          ## 35 empty char length 2nd column with 3rd column
            EMPTY3 = makeEmpty(28)          ## 28 empty char length  3rd column
        elif CT2 != None:
            EMPTY2 = makeEmpty(64)          ## 64 empty char length 2nd column without 3rd column
        

        ## Iterate through each column block for strings
        INDEX1 = 0
        INDEX2 = 0
        INDEX3 = 0
        LINENUM = 0

        w(r,'g')

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
                csep(c,'g')
                if CT1 != 0:
                    csep(BLOCK1[INDEX1],atc)
                    CT1 = CT1 - 1
                    INDEX1 += 1
                    COUNTDOWN = COUNTDOWN - 1
                else:
                    csep(EMPTY1)

                csep(c,'g')
                if CT2 != 0:
                    csep(BLOCK2[INDEX2],btc)
                    CT2 = CT2 - 1
                    INDEX2 += 1
                    COUNTDOWN = COUNTDOWN - 1
                else:
                    csep(EMPTY2)

                csep(c,'g')
                if CT3 != 0:
                    csep(BLOCK3[INDEX3],ctc)
                    CT3 = CT3 - 1
                    INDEX3 += 1
                    COUNTDOWN = COUNTDOWN - 1
                else:
                    csep(EMPTY3)

                w(c,'g')
    
        elif CT2 != None:
            if CT1 > CT2 and CT2 != 0:
                if CT2 == 1:
                    MIDDLE = math.ceil((CT1/2) - 1)
                else:
                    MIDDLE = math.ceil((CT1/CT2) - 1)

                for Block in BLOCK1:
                    if LINENUM < MIDDLE:
                        csep(c,'g')
                        csep(Block,atc)
                        csep(c,'g')
                        csep(EMPTY2)
                        w(c,'g')
                        LINENUM += 1
                    else:
                        csep(c,'g')
                        csep(Block,atc)
                        csep(c,'g')
                        if CT2 != 0:
                            csep(BLOCK2[INDEX2],btc)
                            w(c,'g')
                            INDEX2 += 1
                            CT2 = CT2 - 1
                        else:
                            LINENUM = -1
                            csep(EMPTY2)
                            w(c,'g')
            elif CT2 > CT1 and CT1 != 0:
                if CT1 == 1:
                    MIDDLE = math.ceil((CT2/2) - 1)
                else:
                    MIDDLE = math.ceil((CT2/CT1) - 1)

                for Block in BLOCK2:
                    csep(c,'g')
                    if LINENUM < MIDDLE:
                        csep(EMPTY1)
                        LINENUM += 1
                    else:
                        if CT1 != 0 and INDEX1 < CT1:
                            csep(BLOCK1[INDEX1],atc)
                            csep(c,'g')
                            INDEX1 += 1
                        else:
                            LINENUM = -1
                            csep(EMPTY1)
                    csep(c,'g')
                    if CT2 != 0:
                        csep(Block,btc)
                    w(c,'g')
            else:
                for Block in BLOCK2:
                    csep(c,'g')
                    if INDEX1 < CT1:
                        csep(BLOCK1[INDEX1],atc)
                        INDEX1 += 1
                        csep(c,'g')
                    if CT2 != 0:
                        csep(Block,btc)
                    w(c,'g')
        else:
            for Block in BLOCK1:
                csep(c,'g')
                csep(Block,atc)
                w(c,'g')
            



## Same as MACROSS's "getThis" function, decodes B64 and hex values.
## !!! However, it returns the decoded value to your request, it does NOT write to "vf19_READ" !!!
## 'd' is the value to decode;
## 'e' is the encoding:
##        0 = decode base64
##        1 = decode hexadecimal (Your hex can contain whitespace and/or '0x', this function will strip them out)
##        2 = encode plaintext to base64
##        3 = encode plaintext to hexadecimal
##
##  You can pass an optional 3rd arg to specify the out-encoding
##  (ascii, ANSI, etc, default is UTF-8).
##
##      MYVAR = mcdefs.getThis('base64 string',0)
##      MYVAR = mcdefs.getThis('hex string',1,'ascii')
##
def getThis(d,e,ee = 'utf8'):
    """This is the same as MACROSS' powershell function 'getThis'. Your first argument is the\nencoded string you want to decode, and your second arg will be:\n(0) if decoding base64,\nor (1) if decoding hexadecimal,\nor (2) if encoding to base64,\nor (3) if encoding to hex.\n\nUsage:  var = mcdefs.getThis('base64string',0)\n                OR\nvar = mcdefs.getThis('hexstring',1)"""
    if e == 0:
        newval = b64.b64decode(d)
        newval = newval.decode(ee)
    elif e == 1:
        if search('0x',d):
            d = sub('0x','',d)
        if search(' ',d):
            d = sub(' ','',d)
        newval = bytes.fromhex(d).decode(ee)
    elif e == 2:
        newval = b64.b64encode(d)
    elif e == 3:
        newval = ''
        for b in d:
            hb = '0x' + "{0:02x}".format(ord(b))
            newval = newval + hb
        
    return newval




##    MACROSS calls all python scripts with at least 7 args (8, if you count
##    the script itself being called via python). The fourth arg is always
##    $vf19_PYOPT, a string that the getDefaults function can use to create a
##    dictionary that lets your python scripts share the same default
##    directories/values as MACROSS' $vf19_MPOD hashtable.
##    
##    Declare a new dictionary by calling this function with sys.argv[3] as
##    your first argument (x), and 0 as your second argument (y). After you have
##    your dictionary, you can decode its indexes at any time by calling
##    this function again with a specific index, and no second arg.
##    
##    EXAMPLES:
##
##
##        vf19_PYPOD = mcdefs.getDefaults(sys.argv[3],0)
##        ^^ This is your dictionary, containing any indexed values you supplied in the
##        temp_config.txt file as described in the README files.
##        
##        repo = mcdefs.getDefaults(vf19_PYPOD['nre'])
##        ^^If you set your master repo location with 'nre' as its index, then calling
##        getDefaults again will decode that filepath for you to use anytime in
##        your python scripts.
##
##
def getDefaults(x,y = 1):
    """This function is solely for splitting and decoding MACROSS' $vf19_PYPOD list\ninto the encoded default strings your scripts may need to use. To create your\ninitial dictionary, call this function with a (0) for the second arg. After that,\ncall with the specific index needed from your dictionary with a (1) as the second arg.\n\n    Usage:  vf19_PYPOD = mcdefs.getDefaults(sys.argv[3],0)\nNow let's say vf19_PYPOD contains an index 'tbl' with the filepath to some JSON files:\n    JSONdir = mcdefs.getDefaults(vf19_PYPOD['tbl'],1)"""
    if y == 0:
        newlist = {}
        w = x.split(',')
        for line in w:
            kkey = line[0:3]
            kval = sub("^.{3}",'',line)
            kdct = {kkey:kval}
            newlist.update(kdct)
        return newlist
    elif y == 1:
        DECVAL = getThis(x,0)
        return DECVAL

## Similar to getDefaults above, but replicates MACROSS' $vf19_LATTS hashtable so that python
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
    
