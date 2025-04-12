'''
 MACROSS automatically sets this module path in $env:PYTHONPATH so you can import
 it in your script without any hassle.

 The valkyrie module will automatically set several MACROSS values for you, including:

    valkyrie.PROTOCULTURE         -> if there is an active $PROTOCULTURE value
    valkyrie.USR                  -> your Windows account name
    valkyrie.DTOP                 -> the desktop path set by MACROSS
    valkyrie.N_                   -> the $N_ list of mathing obfuscation numbers
    valkyrie.TOOLSROOT            -> the MACROSS root folder path
    valkyrie.TOOLSDIR             -> the modules\\ folder path
    valkyrie.GBIO                 -> the garbage_io\\ folder path
    valkyrie.MPOD                 -> a python dictionary of $vf19_MPOD**
    valkyrie.LOG                  -> the location of MACROSS' log files
    valkyrie.ROBOTECH             -> True if powershell $vf19_ROBOTECH is $true (default False)
    valkyrie.HELP                 -> True if powershell $HELP is $true (default False)

If you import this module without MACROSS, these values are all set to False, and
the following functions will not return any responses:
          
    valkyrie.availableTypes()
    valkyrie.collab()
    valkyrie.errLog()

 ** Use valkyrie.getThis() to decrypt the values you set in MACROSS' config.conf
 file. The valkyrie.MPOD dictionary contains the same key-value pairs as the
 $vf19_MPOD hashtable in powershell. Example to read from the resources folder
 location that you configured:

 resource_folder = valkyrie.getThis(valkyrie.MPOD['enr'])

 Note that some valkyrie functions operate differently than their powershell
 counterparts! For example, unlike the powershell getThis function, 
 valkyrie.getThis() does not write to vf19_READ, it just returns your results.

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

 '''
import base64 as b64
from datetime import datetime as dt
from os import chdir,path,getenv,environ,system,popen,remove
#from os import getcwd as pwd
from json import dumps,load
from time import sleep as ts
from tkinter import Tk
from tkinter.filedialog import askopenfilename as aof
from math import ceil
import socket
from re import search,sub


class macross:
    """ Create attribute properties for tracking and launching MACROSS tools.
    """
    def __init__(self,name,access,priv,valtype,lang,author,evalmax,rtype,ver,fname):
        self.name = name
        self.access = access
        self.priv = priv
        self.valtype = valtype
        self.lang = lang
        self.author = author
        self.evalmax = evalmax
        self.rtype = rtype
        self.ver = ver
        self.fname = fname

    def __str__(self):
        atts: dict = {
            "Name":self.name,
            "Access":self.access,
            "Privilege":self.priv,
            "Evaluates":self.valtype,
            "Language":self.lang,
            "Author":self.author,
            "Max Args":self.evalmax,
            "Response":self.rtype,
            "Version":self.ver,
            "Fullname":self.fname
        }
        attrs: list = []
        labels: int = len(max(atts.keys(),key=len))
        for A in atts.keys():
            attrs.append(f"{A: <{labels}}: {atts[A]}")
        return "\n".join(attrs)
    
    def __repr__(self):
        return_string: list = [
            f"name={self.name}",
            f"access={self.access}",
            f"priv={self.priv}",
            f"valtype={self.valtype}",
            f"lan={self.lang}",
            f"author={self.author}",
            f"evalmax={self.evalmax}",
            f"rtype={self.rtype}",
            f"ver={self.ver}",
            f"fname={self.fname}"
        ]
        return f"macross({', '.join(return_string)})"


################################################################
## Set default MACROSS values:
## var names will be the same as their powershell versions,
## but **without** the "vf19_" or "dyrl_" prefixes.
################################################################
global PROTOCULTURE,CALLER,HELP,USR,GBIO,RSRC,DTOP,TOOLSROOT,TOOLSDIR,LOGS,M_,N_,LATTS,ROBOTECH,MPOD
PROTOCULTURE,CALLER,HELP,USR,GBIO,RSRC,DTOP,TOOLSROOT,TOOLSDIR,LOGS,M_,N_,LATTS,ROBOTECH,MPOD = [False] * 15
if getenv('PROTOCULTURE'):
    PROTOCULTURE = getenv('PROTOCULTURE')

if getenv('CALLER'):
    CALLER = getenv('CALLER')

if getenv('HELP'):
    HELP = True

if getenv('MACROSS'):
    M = getenv('MACROSS').split(';')
    TOOLSROOT = M[0]
    DTOP = M[1]
    RSRC = M[2]
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

## Load the missile pod
if getenv('MPOD'):
    MPOD = {}
    for missile in getenv('MPOD').split(';'):
        payload = missile.split(':')[0]
        fuel = missile.split(':')[1]
        MPOD[payload] = fuel
    del missile,payload,fuel

## Convert powershell's [macross] objects to python macross class
if GBIO:
    attfile = GBIO + '\\\\LATTS.eod'
    if path.isfile(attfile):
        LATTS = {}
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
        del ATT,pa,i,K,V,tool,attfile,af



## Enable colorized terminal in Windows
system('color')
fcolor = {
    'g':'\033[92m',
    'c':'\033[96m',
    'm':'\033[95m',
    'y':'\033[93m',
    'b':'\033[94m',
    'r':'\033[91m',
    'k':'\033[30m',
    'ul':'\033[4m',
    'w':'\033[97m',
    'rs':'\033[0m'      ## Reset formatting to default
}
bcolor = {
    'k':'\033[40m',
    'r':'\033[101m',
    'g':'\033[102m',
    'y':'\033[103m',
    'b':'\033[104m',
    'm':'\033[105m',
    'c':'\033[106m',
    'w':'\033[107m'
}



################################################################
###############  FUNCTION DEFINITIONS  #########################
################################################################
def drfl(check,method = 'e') -> bool:
    ''' Check if a path exists. Send "file" or "dir" as the second argument
 to specify files vs. folders (optional). Usage:

    drfl(path_to_check,<"file"|"dir">)
    '''
    if method == 'file':
        a = path.isfile(check)
    elif method == 'dir':
        a = path.isdir(check)
    elif method == 'e':
        a = path.exists(check)

    return a


## Alias to write colorized text to screen
def w(TEXT,C1='rs',C2=None,i=False,u=False) -> None:
    ''' Pass this function your text/string as arg 1, and the first letter of the
 color you want as arg2 ("k" for black). Send a second color to highlight 
 the text.
 
 Setting u=True will underline the text. Setting i=True for "inline" will write 
 the next block of text on the same line as the last.

 Colors: (c)yan, (g)reen, (y)ellow, (r)ed, (m)agenta, blac(k), (b)lue
 (default is (w)hite)

 USAGE:

 For green text underlined:
    valkyrie.w(text,'g',u=True)

 For yellow text followed by white text highlighted in red on the same line:
    valkyrie.w(text,'y',i=True)
    valkyrie.w(text,'w','r')

    '''
    lead = fcolor[C1]
    tail = fcolor['rs']
    if u:
        lead = fcolor['ul'] + lead
    if i == True:
        if C2 != None:
            print(lead + bcolor[C2] + TEXT + tail,end="")
        else:
            print(lead + TEXT + tail,end="")
    else:
        if C2 != None:
            print(lead + bcolor[C2] + TEXT + tail)
        else:
            print(lead + TEXT + tail)

## Sleep function for pausing scripts when needed
def slp(s) -> None:
    """ The 'slp' function will pause your script for the number of seconds you
 pass to it. Usage:

    valkyrie.slp(3)
    ^^ Will pause your script for 3 seconds
    """
    ts(s)


## Write MACROSS message logs
def errLog(forward=False,*fields) -> None:
    ''' You can use this to write messages to MACROSS' log files. Timestamps are
 automatically added. The first arg *must* be True or False to tell the function
 whether or not to forward your log message to an external log collector (this
 requires that you define the url of the log collector in MACROSS' $vf19_MPOD
 list as 'elc'). If you forward logs, the timestamp will be converted to UTC.
 
 Message fields get written in the order they are passed.

 **This function only works when launched within MACROSS.

 USAGE:
    Create a local log with no forwarding:
    valkyrie.errLog(False,"A single-field log message")

    Create a local log and forward it to a log collector:
    valkyrie.errLog(True,"ERROR","The quick brown fox","jumped over the lazy dog")

    '''

    ## If logging is enabled, there should already be a logfile present;
    ## otherwise logging will be ignored
    if LOG and drfl(LOG,'file'):
        df = dt.now().strftime("%Y-%m-%d")
        fd: str = 'Get-Date -f "yyyy/MM/dd` hh:mm:ss:ms"'
        UT = psc(cr='powershell.exe -command "(Get-Date).toUniversalTime()|"'+fd).rstrip()
        LT = str(dt.now().strftime("%Y-%m-%d %H:%M:%S"))

        if fields:
            try:
                F: list = []
                for field in fields:
                    F.append(f"{field}")
                F = "\t".join(F).rstrip()
                ewrite = str(getThis(f"{LT}\t{F}",'eb'))

                with open(LOG,'a') as L:
                    L.write(str(f"{ewrite}\n"))

                if forward and MPOD['elc']:
                    logserver = getThis(MPOD['elc'])
                    s = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
                    s.sendto(f"{UT}\t{F}",(logserver,514))
                    s.close()

            except Exception as e:
                w(f"ERROR: Could not write to logfile {LOG}!","y")
                w(f"{e}\n")


def delF(d) -> None:
    ''' Delete files.\n\n USAGE:\n\n\tvalkyrie.delF(path_to_file)'''
    confirm = input(f'''
    Are you sure you want to delete {d}?''')
    if search("^y",confirm):
        remove(d)


def rgx(pattern,string,replace = None) -> str:
    ''' Perform pattern matching/replacement (re.search and re.sub)
 USAGE:
    Search a string:
    valkyrie.rgx(pattern,string)

    Replace a string:
    valkyrie.rgx(pattern,string,replace)
 '''
    if replace == None:
        r = search(pattern,string)
    else:
        r = sub(pattern,replace,string)

    return r


def psc(cc=None,cr=None):
    """ The psc function uses subfunctions of os.system() and os.popen() to   
 execute any Windows commands that you might require. Send your arg as "cc" 
 to simply execute a task; use "cr" instead if you need to save the result 
 from the task.
 
 USAGE:

    valkyrie.psc(cc='powershell.exe "filepath\\myscript.ps1" "argument 1"')
    ^^ Will launch a powershell script with args, but not save any outputs
    
    result = valkyrie.psc(cr='powershell.exe "get-aduser -filter *"')
    ^^ Will return your AD enumeration as a usable object"""
    if cc:
        system(cc)
    if cr:
        TASK = popen(cr)
        return TASK.read()


def availableTypes(val,la=".*",ea=".*",ra=".*",exact=False) -> list | None:
    """ Use this function to search for tools with matching MACROSS
 attributes. Matching tools are returned in a list that you can
 forward to the collab function.

 **This function only works when launched within MACROSS.

 USAGE: 

    tools = valkyrie.availableTypes(val,language,maxArguments,responseType,exactmatch)

 The first arg is the tool's MACROSS valType, and is the only required
 arg. If you want to specify exact matches for the valType, send exact=True
    """

    ## The library is likely being used without MACROSS if LATTS is "False"
    if not LATTS:
        return None

    res: list = []
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


def collab(Tool=None,Caller=None,Protoculture=None,ap=None):
    """
######################################################################################
####   PYTHON COLLAB ~~~~~~~~~~~IMPORTANT!!!!!!~~~~~~~~~~~~~~~  ######################
######################################################################################
## If you want your MACROSS powershell scripts to be able to respond to python requests,
## you **MUST** include this parameter check at the start of your powershell script to 
## ensure it can run as expected:
##
##          param( [string]$pythonsrc=$null )     ## You can also include any other params needed
##          if( $pythonsrc -ne $null ){
##              foreach( $core in gci "$PSScriptRoot\..\core\*.ps1" ){ . $core.fullname }
##              restoreMacross
##          }
##
## The "restoreMacross" powershell function will load all of the required resources
## in a new, temporary session outside of your current MACROSS session.
######################################################################################

 The python "collab" function writes your PROTOCULTURE value to an ".eod"
 file in the GBIO folder for the powershell script to read and write its results to.

 **This function only works when launched within MACROSS.

 USAGE:
 If the PROTOCULTURE.eod file's "result" field is "PS_", the "target" field is meant
 to be python's PROTOCULTURE value. You can retrieve a dict of the file's contents by 
 calling the function without any arguments:

        c = collab()
        c['target']
        c['result']  ## If "PS_", set 'target' as your PROTOCULTURE, otherwise 'result'
                     ## should be PROTOCULTURE

 And after processing the PROTOCULTURE, write your results:

        collab(Protoculture=<script results>)

 If you want to pass values to powershell tools:

        collab(Tool,Caller,Protoculture,ap)
        
 where Tool is the powershell script you're calling (no extension), Caller is the name of 
 your python script, and PROTOCULTURE is the value you need powershell to evaluate. You can  
 also send an additional parameter (ap) if the powershell script accepts one.

 "core\\macross_py\\garbage_io\\PROTOCULTURE.eod" is a json file that contains the key-values
 Caller.target (the PROTOCULTURE value) and Caller.result. If the powershell script has a 
 response for your python script, it will be written to the Caller.result field of 
 PROTOCULTURE.eod, where this function will retrieve it and forward it to your script.

 The PROTOCULTURE.eod file will remain the default PROTOCULTURE value in MACROSS until
 you delete it from the menu or exit MACROSS.
 """
    
    ## The library is likely being used without MACROSS if GBIO is "False"
    if not GBIO:
        return None
    
    protofile = f"{GBIO}\\\\PROTOCULTURE.eod"

    def getProto(pf) -> list | str:
        if not drfl(pf,"file"):
            return f"{pf} does not exist!"
        
        target_pairs: dict = {}
        with open(pf) as d:
            read_proto = load(d)

        for rp in read_proto:
            target_pairs["target"] = read_proto[rp]["target"]
            target_pairs["result"] = read_proto[rp]["result"]

        return target_pairs
    
    if not Protoculture:
        return getProto(protofile)
    else:
        Tool = LATTS[Tool].fname
        chdir(TOOLSROOT)
        fullpath = f"{TOOLSDIR}\\\\{Tool}"
        empty = "WAITING"
        pr: list = []

        ## MOD SECTION ##
        # If your Protoculture value is a huge dictionary, this function may not do a good job
        # of passing it back to powershell. Tweak it however you need to.
        if type(Protoculture) == list:
            for P in Protoculture:
                pr.append(f"[{P}]")
        elif type(Protoculture) == dict:
            for P in Protoculture.keys():
                pr.append("{\""+f"{P}\":\"{Protoculture[P]}\""+"}")
        else:
            del pr
            pr = str(Protoculture)

        if type(pr) != str:
            ",".join(pr)

        proto = {Caller:{"target":pr,"result":empty}}

        if getenv("MPOD"):
            environ["MPOD"] = getenv("MPOD")
        if getenv("MACROSS"):
            environ["MACROSS"] = getenv("MACROSS")

        with open(protofile,"w") as outf: 
            outf.write(dumps(proto))

        call = f"powershell.exe {fullpath} -pythonsrc {Caller}"
        if ap != None:
            call = ap + "~" + call
        psc(cc=call)

        with open(protofile) as r:
            res = load(r)

        if res[Caller]["result"] and res[Caller]["result"] != empty:
            return res[Caller]["result"]
        else:
            return False


def getFile(opendir="C:\\",filter='all') -> str:
    """ The getFile() function opens a dialog window for users to select a file. You
 can pass in optional arguments opendir= to set the default location for the dialog,
 and filter= to limit the selection by filetype. 

 TYPES:
    'all' = All filetypes (default)
    'csv' = Comma-separated value format
    'doc' = pdf, doc, docx, rtf files
    'dox' = Microsoft Word formats
    'exe' = Executables
    'msg' = Saved email messages
    'mso' = All common Microsoft Office formats
    'pdf' = pdf files
    'ppt' = Microsoft Powerpoint formats
    'scr' = Common script types
    'txt' = Plaintext .txt files
    'web' = htm, html, css, js, json, aspx, php files
    'xls' = Microsoft Excel formats
    'zip' = zip, gz, 7z, rar files

 USAGE: 

    PDFDOC = getFile(opendir='directory\\to\\file',filter='pdf')
    ZIPFILE = getFile(filter='zip')
    
    """
    ft = {
        'all':(("All files", "*.*"),("All files", "*.*")),
        'exe':(("Executables", "*.exe"),("All files", "*.exe")),
        'txt':(("Text files", "*.txt"),("Text files", "*.txt")),
        'msg':(("Email message", "*.msg"),("Email message", "*.msg")),
        'mso':(("Microsoft Office", "*.doc"),("Microsoft Office", "*.docx"),("Microsoft Office", "*.xls"),("Microsoft Office", "*.xlsx"),\
               ("Microsoft Office", "*.one"),("Microsoft Office", "*.ppt"),("Microsoft Office", "*.pptx"),("Microsoft Office", "*.accdb"),
               ("Microsoft Office", "*.accde"),("Microsoft Office", "*.ost"),("Microsoft Office", "*.pst")),
        'dox':(("MS Word Doc", "*.docx"),("MS Word Doc", "*.doc")),
        'scr':(("Script files", "*.ps1"),("Script files", "*.psm"),("Script files", "*.py"),("Script files", "*.pyc"),("Script files", "*.pyd"),\
               ("Script files", "*.bat"),("Script files", "*.lua"),("Script files", "*.js")),
        'ppt':(("MS Powerpoint", "*.pptx"),("MS Powerpoint", "*.ppt")),
        'xls':(("Excel Spreadsheet", "*.xlsx"),("Excel Spreadsheet", "*.xls")),
        'pdf':(("Acrobat Portable Document", "*.pdf"),("Acrobat Portable Document", "*.pdf")),
        'csv':(("Comma-Separated Document", "*.csv"),("Comma-Separated Document", "*.csv")),
        'web':(("Web Files", "*.html"),("Web Files", "*.htm"),("Web Files", "*.css"),("Web Files", "*.js"),("Web Files", "*.aspx"),\
               ("Web Files", "*.php"),("Web Files", "*.json")),
        'zip':(("Compressed", "*.zip"),("Compressed", "*.rar"),("Compressed", "*.7z"),("Compressed", "*.tar"),("Compressed", "*.gz")),
        'doc':(("Document Types", "*.docx"),("Document Types", "*.doc"),("Document Types", "*.rtf"),("Document Types", "*.pdf"),\
               ("Document Types", "*.xls"),("Document Types", "*.xlsx")),
    }
    Tk().withdraw()
    if filter:
        chooser = aof(initialdir=opendir,filetypes=ft[filter])
        
    return chooser
 

def screenResults(A='endr',B=None,C=None) -> None:
    """ Each string value is optional, and will be written to screen in separate
 rows & columns.

 You can send the first letter of a color ("k" for black) and "~" to colorize
 text, for example "c~Value" to write "Value" in cyan.

 Formatting options: (c)yan, blac(k), (b)lue, (r)ed, (y)ellow, (w)hite, (m)agenta, and
 (ul) for underline.

 To finish your outputs, call the function again without any values to
 write the closing row boundary.

 ** Your mileage may vary depending on the strings that get passed in; I sometimes
 get a display with broken columns. It usually works pretty well, though.

 EXAMPLE: Write 3 columns, with the second column in green:

    valkyrie.screenResults(string1,f"g~{string2}",string3)
    valkyrie.screenResults()

"""
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
                print(fcolor[tc] + text + fcolor['rs'], end = ' ')
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
                    outputs = rgx('(\\s\\s+|\\t|`n)',outputs,' ')  ## Remove tabs/newlines from string
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
                        BLOCK = rgx('\\s{2,}',BLOCK,' ')  ## Remove multi-spaced chars
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
            BLOCK1 = genBlocks(A,88,87) #genBlocks(A,96,95)

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
                    MIDDLE = ceil((CT1/2) - 1)
                else:
                    MIDDLE = ceil((CT1/CT2) - 1)

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
                    MIDDLE = ceil((CT2/2) - 1)
                else:
                    MIDDLE = ceil((CT2/CT1) - 1)

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
            


def getThis(v,e='b',encd='utf8') -> str:
    """ This is the same as MACROSS' powershell function 'getThis'. Your
 first argument is the encoded string you want to de/encode, and your
 second arg will be:

    'b'' if decoding base64 (default action), or
    'h' if decoding hexadecimal, or
    'eb' if encoding to base64, or
    'eh' if encoding to hexadecimal.

 Unlike the powershell function, this function does NOT write to
 "vf19_READ", it just returns your processed string.

 You can pass an optional arg encd= to specify the out-encoding (ascii,
 ANSI, etc, default is UTF-8).

 Usage:
    PLAINTEXTASCII = valkyrie.getThis(base64string,encd='ascii')
    PLAINTEXT = valkyrie.getThis(hexstring,'h')
    HEX = valkyrie.getThis('plaintext','eh')
    BASE64 = valkyrie.getThis('plaintext','eb')

    """
    if e == 'b':
        newval = b64.b64decode(v)
        newval = newval.decode(encd)
    elif e == 'h':
        if search('0x',v):
            v = sub('0x','',v)
        if search(' ',v):
            v = sub(' ','',v)
        newval = bytes.fromhex(v).decode(encd)
    elif e == 'eb':
        newval = str(b64.b64encode(v.encode()).decode())
    elif e == 'eh':
        newval = ''
        for b in v:
            hb = "{0:02x}".format(ord(b)).upper()
            newval = newval + hb
        
    return newval

