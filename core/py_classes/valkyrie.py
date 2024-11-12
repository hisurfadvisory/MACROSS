"""The valkyrie library is a set of MACROSS functions converted from powershell to python."""


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
from datetime import datetime as dt
from subprocess import run as srun
from os import chdir,path,getenv,environ
from os import system as osys
from os import popen as osop
from os import getcwd as pwd
from os import remove as osrm
from json import dumps,load
from time import sleep as ts
from tkinter import Tk
from tkinter.filedialog import askopenfilename as aof
import math
from re import search,sub


################################################################
## Set default MACROSS values:
## var names will be the same as their powershell versions,
## but **without** the "vf19_" or "dyrl_" prefixes.
################################################################
global PROTOCULTURE,CALLER,HELP
if getenv('PROTOCULTURE'):
    PROTOCULTURE = getenv('PROTOCULTURE')
else:
    PROTOCULTURE = False

if getenv('CALLER'):
    CALLER = getenv('CALLER')
else:
    CALLER = False

if getenv('HELP'):
    HELP = True
else:
    HELP = False

if getenv('MACROSS'):
    global USR,GBIO,TABLES,DTOP,TOOLSROOT,TOOLSDIR,LOGS,M_,N_,ROBOTECH
    M = getenv('MACROSS').split(';')
    TOOLSROOT = M[0]
    DTOP = M[1]
    TABLES = M[2]
    LOG = M[3]
    N_ = [int(M[4])]
    n_ = [int(d) for d in str(M[4])]
    for n in n_:
        N_.append(n)
    del n,n_
    USR = M[5]
    CALLER = M[6]
    if M[7] == 'T':
        ROBOTECH = True
    GBIO = TOOLSROOT + '\\\\core\\\\macross_py\\\\garbage_io'
    TOOLSDIR = TOOLSROOT + '\\\\modules'
    environ['MACROSS'] = getenv('MACROSS')
    
if getenv('MPOD'):
    global MPOD; MPOD = {}
    for missile in getenv('MPOD').split(';'):
        payload = missile.split(':')[0]
        fuel = missile.split(':')[1]
        MPOD[payload] = fuel
    del missile,payload,fuel
    environ['MPOD'] = getenv('MPOD')


## Enable colorized terminal
osys('color')
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
####################   CLASS DEFINITIONS   #####################
################################################################
class macross:
	def __init__(self,n,ac,p,vt,l,au,e,r,vr,f):
		self.name = n
		self.access = ac
		self.priv = p
		self.valtype = vt
		self.lang = l
		self.author = au
		self.evalmax = e
		self.rtype = r
		self.ver = vr
		self.fname = f

################################################################
###############  FUNCTION DEFINITIONS  #########################
################################################################
def help():
    print('''
 MACROSS automatically sets this module path in $env:PYTHONPATH so you can import
 it in your script without any hassle.

 The valkyrie module will automatically set several MACROSS values for you, including:

    valkyrie.PROTOCULTURE         -> if there is an active $PROTOCULTURE value
    valkyrie.USR                  -> your Windows account name
    valkyrie.DTOP                 -> your desktop path
    valkyrie.N_                   -> the $N_ list of mathing obfuscation numbers
    valkyrie.TOOLSROOT            -> the MACROSS root folder path
    valkyrie.TOOLSDIR             -> the modules\ folder path
    valkyrie.GBIO                 -> the garbage_io\ folder path
    valkyrie.MPOD                 -> a python dictionary of $vf19_MPOD**
    valkyrie.LOG                  -> the location of MACROSS' log files
    valkyrie.ROBOTECH             -> True if powershell $vf19_ROBOTECH is $true
    valkyrie.HELP                 -> True if powershell $HELP is $true

 ** Use valkyrie.getThis() to decrypt the values you set in MACROSS' config.conf
 file. The valkyrie.MPOD dictionary contains the same key-value pairs as the
 $vf19_MPOD hashtable in powershell. Example to read from the resources folder
 location that you configured:

 resource_folder = valkyrie.getThis(valkyrie.MPOD['enr'])

 Note that some valkyrie functions operate differently than their powershell
 counterparts! For example, unlike the powershell collab function, valkyrie.collab
 does not write to vf19_READ, it just returns your results.

 Additionally, to aid in sharing query results back and forth between powershell
 and python, the valkyrie folder contains a subfolder called 'garbage_io'. MACROSS
 scripts can write their outputs into this directory, using ".eod" files. When
 python is assigning or reading PROTOCULTURE values for powershell, that value is
 stored in the PROTOCULTURE.eod file.

 See the collab() function down below, as well as the pyCross() function in utility.p1
 for more details. MACROSS typically handles everything to do with .eod files in the
 background, but you can create your own for specific scripts if necessary.

 MACROSS powershell scripts already know the location of this folder as $vf19_PYG[0]. 
 In python it is referenced with the variable GBIO.

 All .eod files in the garbage_io folder are automatically deleted when MACROSS exits 
 or starts up.

 ''')

## Alias to write colorized text to screen
def w(TEXT,C1 = 'rs',C2 = None,i = False):
    ''' Pass this function your text/string as arg 1 and the first letter of the
 color you want ("bl" for black). You can pass "ul" as a second option to
 underline the text. Set i to True to write the next line of your text on the
 same line as the last.

 Colors: (c)yan, (g)reen, (y)ellow, (r)ed, (m)agenta, (bl)ack, (b)lue
 (default is white)

 Usage:

 For green text underlined:
    valkyrie.w(text,'g','ul')

 For yellow text followed by white text on the same line:
    valkyrie.w(text,'y',i=True)
    valkyrie.w(text,'w')

    '''
    if i == True:
        if C2 != None:
            print(tcolo[C1] + tcolo[C2] + TEXT + tcolo['rs'],end="")
        else:
            print(tcolo[C1] + TEXT + tcolo['rs'],end="")
    else:
        if C2 != None:
            print(tcolo[C1] + tcolo[C2] + TEXT + tcolo['rs'])
        else:
            print(tcolo[C1] + TEXT + tcolo['rs'])

## Sleep function for pausing scripts when needed
def slp(s):
    """ The 'slp' function will pause your script for the number of seconds you
 pass to it. Usage:

    valkyrie.slp(3)
    ^^ Will pause your script for 3 seconds\n"""
    ts(s)

## Write MACROSS message logs
def errLog(msg,field1=None,field2=None):
    ''' You can use this to write messages to MACROSS' log files. Timestamps are
 automatically added. Message fields get written in the order they are passed (at 
 least one arg is required, but up to three are accepted).

 USAGE:

    valkyrie.errLog("A single-field log message")
    valkyrie.errLog("ERROR","The quick brown fox","jumped over the lazy dog")

    '''
    write = dt.now().strftime('%Y-%m-%d %H:%M:%S') + "\t" + msg
    if field2 != None:
        write = write + "\t" + field1 + "\t" + field2
    elif field1 != None:
        write = write + "\t" + field1
    with open(LOG,'a') as L:
        L.write(str(write) + "\n")
    L.close()

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
##  Typically, I call this function with one arg -- a powershell command to launch one of
##  the MACROSS *.ps1 scripts and whatever parameters that powershell script requires.
##  If you need to collect values from the script, or from a quick command like "hostname" or 
##  "ping", call valkyrie.psc() with an empty value as the first arg, and your command as the second:

##          var = valkyrie.psc('','ping 192.168.1.1')

##  Feel free to modify this however you need; you might even need to import the entire os library--
##  everyone has different use-cases, especially with python-based APIs! Just make sure to enact your
##  changes across ALL of the MACROSS functions and scripts!
def psc(c,cc = None):
    """ The psc function performs os.system() commands that you pass in. If
 you pass your command as the *second* arg, the ouput\nwill be read
 using os.read(). Usage:

    valkyrie.psc('powershell.exe "filepath\\myscript.ps1" "argument 1"')
    ^^ Will launch your powershell script with args
    
    valkyrie.psc('','powershell.exe "filepath\\myscript.ps1" "argument 1"')
    ^^ Will return the results of your powershell script as usable strings"""
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
    ''' Check if a path exists. Send "file" or "dir" as the second argument
 (optional). Usage:

    drfl(path_to_check,optional)
    '''
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
    """ The psp function is simply 'subprocess.run' made readily available 
 to MACROSS python scripts. Usage:

    valkyrie.psp('powershell.exe "filepath\\myscript.ps1" "argument 1"')
    ^^ Will launch your powershell script with args
    """
    srun(p)


def availableTypes(val,la=".*",ea=".*",ra=".*",exact=False):
    """ Use this function to search for tools with matching MACROSS
 attributes. Matching tools are returned in a list that you can
 forward to the collab function.

 USAGE: 

    tools = valkyrie.availableTypes(val,language,maxArguments,responseType,exact)

 The first arg is the tool's MACROSS valType, and is the only required
 arg. If you want to specify exact matches for the valType, send exact=True
    """
    res = []
    for t in LATTS:
        L = str(LATTS[t].lang)
        E = str(LATTS[t].evalmax)
        R = str(LATTS[t].rtype)
        N = str(LATTS[t].name)
        V = str(LATTS[t].valtype)
        ml = rgx(la,L); me = rgx(str(ea),E); mr = rgx(ra,R)
        if ml and me and mr:
            if exact == True:
                if val == V:
                    res.append(N)
            elif rgx(val,V):
                res.append(N)

    return res

######################################################################################
####   PYTHON COLLAB ~~~~~~~~~~~IMPORTANT!!!!!!~~~~~~~~~~~~~~~  ######################
######################################################################################
## If you want your MACROSS powershell scripts to be able to respond to python requests,
## you **MUST** include these parameter checks to ensure your powershell script can run
## as expected:
##
##          param($pythonsrc=$null)
##          if($pythonsrc -ne $null){
##              foreach($core in gci "$PSScriptRoot\..\core\*.ps1"){ . $core.fullname }
##              restoreMacross
##          }
##
## The restoreMacross() powershell function will reload all of the resources that get
## lost when you launch python.
######################################################################################
def collab(Tool,Caller,Protoculture,ap = None):
    ''' The python "collab" function writes your PROTOCULTURE value to an ".eod"
 file in the GBIO folder for the powershell script to read and write its results to.

 USAGE:
 If the PROTOCULTURE.eod file's "result" field is "PS_", the "target" field is meant
 to be python's PROTOCULTURE value. You can check it with:

        collab()

 And after processing the PROTOCULTURE, write your results:

        collab(PROTOCULTURE=<script results>)

 If you want to pass values to powershell tools:

        collab(Tool,Caller,Protoculture,ap)
        
 where Tool is the powershell script you're calling (no extension), Caller is the name of 
 your python script, and PROTOCULTURE is the value you need powershell to evaluate. You can  
 also send an additional parameter (ap) if the powershell script accepts one.

 "core\macross_py\garbage_io\PROTOCULTURE.eod" is a json file that contains the key-values
 Caller.target (the PROTOCULTURE value) and Caller.result. If the powershell script has a 
 response for your python script, it will be written to the Caller.result field of 
 PROTOCULTURE.eod, where this function will retrieve it and forward it to your script.

 The PROTOCULTURE.eod file will remain the default PROTOCULTURE value in MACROSS until
 you delete it from the menu or exit MACROSS.
 '''
    
    protofile = GBIO + '\\\\PROTOCULTURE.eod'
    '''
    with open(protofile) as d:
        readproto = load(d)
    d.close()
    for rp in readproto:
        if readproto[rp]['result'] == 'PS_':
            if not Protoculture:
                PROTOCULTURE = readproto[rp]['target']
            else:
                readproto[rp]['result'] = Protoculture
                with open(protofile, 'w') as dd:
                    d.write(readproto)
                dd.close()
            return
            '''

    Tool = LATTS[Tool].fname
    chdir(TOOLSROOT)
    fullpath = TOOLSDIR + '\\\\' + Tool
    empty = 'WAITING'
    proto = {Caller:{'target':Protoculture,'result':empty}}

    with open(protofile, 'w') as outf: 
        outf.write(dumps(proto))
            
    outf.close()

    call = 'powershell.exe ' + fullpath + ' -pythonsrc ' + Caller
    if ap != None:
        call = ap + '~' + call
    psc(call)

    with open(protofile) as r:
        res = load(r)

    if res[Caller]['result'] and res[Caller]['result'] != empty:
        return res[Caller]['result']
    else:
        return False


## Same as MACROSS' getFile function; if you do not provide an initial directory,
## it will will be set to the C: drive, which you can change via the first
## argument (opendir). The second optional arg (filter) can limit by file
## extensions; default is to list all files. This arg has to be passed as a list.
def getFile(opendir = 'C:\\',filter = (('All files', '*.*'),('All files', '*.*'))):
    """The getFile function opens a dialog window for users to select a file. You
can pass in optional arguments 1) to set the default location for the dialog,
and 2) limit the selection\nby file extension. Usage: 

    FILE = getFile('your\\directory\\to\\file',(('Adobe Acrobat Document', '*.pdf'),('All files', '*.*')))
    
    """
    Tk().withdraw()
    if filter:
        chooser = aof(initialdir=opendir,filetypes=filter)
        
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
    '''(Usage example) Write 3 columns, with the second column in green:

    valkyrie.screenResults(string1,'g~'+string2,string3)

Each string value is optional, and will be written to screen in separate
rows & columns.\nYou can send the first letter of a color ("bl" for black)
and "~" to colorize text, for example "c~Value" to write "Value" in cyan.

Colors:(c)yan, (bl)ack, (b)lue, (r)ed, (y)ellow, (w)hite, (m)agenta, and
(ul) for underline.

To finish your outputs, call the function again without any values to
write the closing row boundary.'''
    atc = btc = ctc = None      ## Default text color
    c = chr(8214)
    RC = chr(8801)
    r = c + RC
    for rr in range(1,90):      ## 98 char length
        r = r + RC
    r = r + c
    del(rr)
    
    
    if A == 'endr':
        w(r,'g')

    else:
        
        ## Write text to a block without newlines
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
                    ## Track the number of char spaces we can fit in a column
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
                    ## the o2 collection
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
            BLOCK1 = genBlocks(A,23,23)
            if C != None:
                WIDE3 = len(C)
                BLOCK2 = genBlocks(B,32,30) #genBlocks(B,34,32)
                BLOCK3 = genBlocks(C,28,26) #genBlocks(C,28,25)
                CT3 = len(BLOCK3)
            else:
                CT3 = None
                BLOCK2 = genBlocks(B,62,59) #genBlocks(B,64,62)
                
            CT2 = len(BLOCK2)

        else:
            CT3 = None
            CT2 = None
            BLOCK1 = genBlocks(A,89,87) #genBlocks(A,96,95)

        CT1 = len(BLOCK1)

        ## Generate empty lines based on how many columns are needed
        def makeEmpty(ii):
            ee = ' '
            for i in range(1,ii):
                ee = ee + ' '
            return ee

        EMPTY1 = makeEmpty(25)              ## 25 empty char length 1st column
        if CT3 != None:
            EMPTY2 = makeEmpty(31)          ## 36 empty char length 2nd column *with* 3rd column
            EMPTY3 = makeEmpty(27)          ## 29 empty char length 3rd column
        elif CT2 != None:
            EMPTY2 = makeEmpty(61)          ## 65 empty char length 2nd column *without* 3rd column


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
            


def getThis(d,e = 0,ee = 'utf8'):
    """ This is the same as MACROSS' powershell function 'getThis'. Your
 first argument is the encoded string you want to decode, and your
 second arg will be:

    (0) if decoding base64 (default action), or
    (1) if decoding hexadecimal, or
    (2) if encoding to base64, or
    (3) if encoding to hexadecimal.

 Unlike the powershell function, this function does NOT write to
"vf19_READ", it just returns your decoded plaintext.

 You can pass an optional 3rd arg to specify the out-encoding (ascii,
 ANSI, etc, default is UTF-8).

 Usage:
    PLAINTEXTASCII = valkyrie.getThis(base64string,0,'ascii')
    PLAINTEXT = valkyrie.getThis(hexstring,1)
    HEX = valkyrie.getThis('plaintext',1)
    BASE64 = valkyrie.getThis('plaintext',0)

    """
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


################################################################
## Convert powershell's [macross] objects to python macross class
################################################################
attfile = GBIO + '\\\\LATTS.eod'
if drfl(attfile,method='file'):
    global LATTS; LATTS = {}
    with open(attfile) as af:
        pa = load(af)
        for tool in pa:
            l = []
            K = tool
            V = pa[tool]
            for i in V:
                l.append(str(i))
            ATT = macross(l[0],l[1],l[2],l[3],l[4],l[5],l[6],l[7],l[8],l[9])
            LATTS.update({K:ATT})
    af.close()
    del pa,i,K,V,tool,attfile,af


