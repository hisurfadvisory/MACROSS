"""
    The macross library is a set of MACROSS functions converted from powershell to python.

    IMPORTANT:
    To facilitate your powershell diamonds being able to respond to python queries, you
    need to include this check at the start of your **powershell** code in the modules
    folder:

    param( $pythonsrc = $null )
    if( $pythonsrc ){
        $Global:CALLER = $pythonsrc
        foreach( $core in (gci "$(($env:SN -Split ';')[0])\\corefuncs\\*.ps1" |
        ?{$core.name -ne 'configurations.ps1'})){ . $core.fullname }
        spaceFold
    }

    The above will load MACROSS' core functions in a unique session, then execute the
    spaceFold function to restore all of MACROSS' default configs in that session
    so that the powershell diamond will have all the resources it might require.

    Additionally, to aid in sharing query results back and forth between powershell and
    python, the pycross folder contains a subfolder called 'garbage_io'. MACROSS powershell
    diamonds can write their outputs into this directory, using *.mac7 files, whenever they 
    get called from python (there is a built-in powershell utility called "pyCross" specifically 
    to do this). These are plaintext json files that facilitate sharing data between python
    and powershell.

    When using the macross.valkyrie() function, your investigation value gets written to the
    file PROTOCULTURE.mac7; the tool you call with valkyrie will read the PROTOCULTURE value from 
    the mac7 file, then writes its response to that file. Finally, the valkyrie function will read  
    and return the response to your python diamond.

    IMPORTANT: line 726 in the valkyrie() function is commented out; it runs an execution policy
    bypass in powershell to make sure the called powershell diamond will run. However, this may
    violate your organization's policy and trip security alerts. Only uncomment this line if 
    you are experiencing issue with valkyrie() and you will not be violating policy!

    All mac7 files are automatically deleted when MACROSS exits cleanly, or when MACROSS
    starts after a crash where it did not get to delete them when expected.

    ** The tkinter library was removed from this library as it no longer functions with
    the portable python environment. This has made the getFile() function a little buggy.
    The tkinter-reliant code is left in place in case I figure out how to make it work again.

    
"""


################################################################
###################    IMPORT SECTION    #######################
################################################################
from datetime import datetime as dt
from os import chdir,path,getenv,environ,system,popen,remove
from json import dumps,load,loads
from time import sleep as ts
from math import ceil
from random import randint
import base64 as b64
import ctypes
from ctypes import *
from ctypes import wintypes
from re import match,search,sub

## tkinter library makes the getFile function a lot smoother;
## using a portable exe breaks it, though.
nokinter = False
try:
    from tkinter import Tk
    from tkinter.filedialog import askopenfilename as aof
    from tkinter.filedialog import askdirectory as aod
except:
    nokinter = True


## Default values for use in MACROSS python diamonds
global TEMPENV,PROTOCULTURE,CALLER,CONTENT,HELP,LATTS,MACROOT,MODS,DESKTOP,\
LOGS,N_,OPT1,USR,TMP,GBIO,ROBOTECH,CONF,proto_file,PLUGINS,RESOURCES,OUTFILES,PSVER
TEMPENV,PROTOCULTURE,CALLER,CONTENT,HELP,LATTS,MACROOT,MODS,DESKTOP,\
LOGS,N_,OPT1,USR,TMP,GBIO,ROBOTECH,CONF,PLUGINS,RESOURCES,OUTFILES,PSVER = [False] * 21



## Set all default MACROSS values to keep python diamonds from trippin'
if getenv("HELP"):
    HELP: bool = True
if getenv("LOCALAPPDATA"):
    LAD = getenv('LOCALAPPDATA')
    TMP: str = f"{LAD}\\Temp\\MACROSS"

if getenv("MACROSS"):
    environ["TEMPENV"] = getenv("MACROSS")
    TEMPENV = [getenv("MACROSS")]
    snet = getenv("MACROSS").split(";")
    MACROOT: str = snet[0]
    MODS: str = f"{MACROOT}\\diamonds"
    PLUGINS: str = f"{MACROOT}\\corefuncs\\plugins"
    RESOURCES: str = f"{MACROOT}\\corefuncs\\resources"
    OUTFILES: str = f"{MACROOT.replace("\\macross_core","")}\\outputs"
    if len(snet) > 1:
        DESKTOP: str = snet[1]
        CONTENT: str = snet[2]
        LOGS: str = snet[3]
        n1: int = int(snet[4].split(",")[0])
        n2: list[int] = [int(d) for d in str(snet[4].split(",")[1])]
        n3: list[int] = [int(d) for d in str(snet[4].split(",")[2])]
        N_: list = [n1,n2,n3]
        USR: str = snet[5]
        if snet[7] == "T":
            ROBOTECH: bool = True
        if snet[8] == "T":
            OPT1: bool = True
        GBIO: str = f"{MACROOT}\\corefuncs\\pycross\\garbage_io"
        del n1,n2,n3
    PSVER = int(snet[9])
    del snet


## Set python's PROTOCULTURE tracker
temp = False
if GBIO:
    proto_file = f"{GBIO}\\\\PROTOCULTURE.mac7"

## Set default PROTOCULTURE and CALLER values; 
## powershell and python require different methods
try:
    ## This checks for values in the temp file created by the "valkyrie" function
    ## in both powershell and python for sharing data between the two
    with open(proto_file) as tmp:
        temp = load(tmp)
except:
    pass

## If there's no "PROTOCULTURE" temp file, check environment vars
if getenv("CALLER"):
    CALLER = getenv("CALLER")
elif temp:
    CALLER = [t for t in temp][0]
if getenv("PROTOCULTURE"):
    PROTOCULTURE = getenv("PROTOCULTURE")
elif temp:
    PROTOCULTURE = temp[CALLER]["result"]
del temp

if getenv("MACCONF"):
    TEMPENV.append(getenv("MACCONF"))
    CONF: dict = {}
    for d in getenv("MACCONF").split(';'):
        k = d.split('::')[0]
        v = d.split('::')[1]
        CONF[k] = v
    del d,k,v

## Convert powershell's [macross] objects to python macross class
if GBIO:
    class macross:
        def __init__(self,n,ac,p,vt,l,au,e,r,v,f):
            self.name = n               ## The filename minus extension, used as the diamond's ID in MACROSS
            self.access = ac            ## tier 1, 2, 3 or "common" for all tiers
            self.priv = p               ## admin or user
            self.valtype = vt           ## What function does your diamond perform
            self.lang = l               ## powershell or python
            self.author = au
            self.evalmax = int(e)       ## The number of params/args accepted by the diamond
            self.rtype = r              ## The type of response given by the diamond
            self.ver = float(v)         ## Version number
            self.fname = f              ## The filename including the extension
            
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
                f"lang={self.lang}",
                f"author={self.author}",
                f"evalmax={self.evalmax}",
                f"rtype={self.rtype}",
                f"ver={self.ver}",
                f"fname={self.fname}"
            ]
            return f"macross({', '.join(return_string)})"


    attfile = f"{GBIO}\\\\LATTS.mac7"
    if path.isfile(attfile):
        LATTS = {}
        with open(attfile) as af:
            pa = load(af)
            for tool in pa:
                l = []
                K = tool
                V = pa[tool]
                for i in V.keys():
                    l.append(str(V[i]))
                ATT = macross(
                    n=l[0],
                    ac=l[1],
                    p=l[2],
                    vt=l[3],
                    l=l[4],
                    au=l[5],
                    e=l[6],
                    r=l[7],
                    v=l[8],
                    f=l[9])
                #LATTS.update({K:ATT})
                LATTS[K] = ATT

        del ATT,pa,i,K,V,tool,attfile,af



## Enable colorized terminal in Windows
system("color")
## Foreground (text) colors
fcolor = {
    "g":"\033[92m",     ## green
    "c":"\033[96m",     ## cyan
    "m":"\033[95m",     ## magenta
    "y":"\033[93m",     ## yellow
    "b":"\033[94m",     ## blue
    "r":"\033[91m",     ## red
    "k":"\033[30m",     ## blacK
    "w":"\033[97m",     ## white
    "ul":"\033[4m",     ## underline
    "rs":"\033[0m"      ## Reset formatting to default
}
## Background (highlight) colors
bcolor = {
    "n":"",
    "k":"\033[40m",
    "r":"\033[101m",
    "g":"\033[102m",
    "y":"\033[103m",
    "b":"\033[104m",
    "m":"\033[105m",
    "c":"\033[106m",
    "w":"\033[107m"
}


################################################################
###############  FUNCTION DEFINITIONS  #########################
################################################################
def ispath(check,p=None) -> bool:
    """ Check if a path exists. Send p="file" or p="dir" to specify files vs. 
 folders (optional). Default checks either.

 OPTIONS
    p: Specify if path-type is a file or folder. Default checks for both.
        'file': does filepath exist
        'dir':  does folder exist
        None:   does path exist whether file or folder

 USAGE
    ispath(path_to_check,p=<"file"|"dir">)

    """
    if p == "file":
        a = path.isfile(check)
    elif p == "dir":
        a = path.isdir(check)
    else:
        a = path.exists(check)

    return a


## Alias to write colorized text to screen
def w(TEXT,f="rs",b="n",i=False,u=False) -> None:
    """ Pass this function your text/string as arg 1, and the first letter of the
 color you want as arg2 ("k" for black). Send a second color to highlight 
 the text (args f and b respectively).
 
 Setting u=True will underline the text. Setting i=True for "inline" will write 
 the next block of text on the same line as the last.

 Colors: (c)yan, (g)reen, (y)ellow, (r)ed, (m)agenta, blac(k), (b)lue
 (default is (w)hite)

 USAGE:

 For green text underlined:
    w(text,'g',u=True)

 For yellow text followed by black text highlighted in red on the same line:
    w(text,'y',i=True)
    w(text,f='k',b='r')

    """
    tail = fcolor["rs"]     ## Reset text color after every line
    if f not in fcolor:
        lead = fcolor["w"]  ## Default to white if unknown option was passed
    else:
        lead = fcolor[f]
    endln = "\n"
    if u:
        lead = fcolor["ul"] + lead  ## Add underline code
    if i == True:
        endln = ""                  ## Omit newline from print()
    if b != None and b in bcolor:
        print(lead + bcolor[b] + TEXT + tail,end=endln)
    else:
        print(lead + TEXT + tail,end=endln)

def minmay(i=0):
    """ Display 1 of 2 Terminator images by supplying either 0 or 1.
    """
    if i in range(0,2):
        j = f"{RESOURCES}\\splash.json"
        with open(j) as o:
            splashes = loads(o.read())
        splash = reString(splashes["term"][i])
        print(splash)

def battroid(text=None,b=False):
    """ Rewrite your console text in blocky ascii art style. Single words only,
 and whitespace is stripped out except when used at the beginning of your string.

 Alternately, the "b" option returns the separator bar used in 
 MACROSS' main menu.

 This requires the "alphanum.json" file included in MACROSS' local resource folder.

 USAGE:

    title = battroid('hello')
    bar = battroid(b=True)

    """
    if b:
        return chr(9553)
    
    alpha = f"{RESOURCES}\\alphanum.json"
    if not ispath(alpha,p="file"):
        return f"ERROR! Missing required file\n{alpha}"
    
    title = []
    with open(alpha) as o:
        alphanum = loads(o.read())
    decoded = reString("".join(alphanum["alpha"]))
    reference = loads(decoded)
    buffer = " " * len(sub("\\w+","",text))
    text = [t for t in text if t in reference]
    for i in range(0,6):
        for t in text:
            if text.index(t) == 0:
                block = f"{buffer}{reference[t][i]}"
            else:
                block = reference[t][i]
            title.append(block)
        if i < 5:
            title.append("\n")
    return "".join(title)



def slp(s=0,m=0) -> None:
    """ The "slp" function will pause your diamond for the number of seconds you
 pass to it. Use m= for milliseconds.

 USAGE: 
    Pause your diamond for 3 seconds
    slp(3)

    Pause for 500 ms
    slp(m=500)
    
    """
    if m and isinstance(m,int):
        ts(m//1000)
    elif s and isinstance(s,int):
        ts(s)


def cdate(hms=False,d="/"):
    r""" Get the current date/time. Change the delimiter with d=DELIMTER

    USAGE:

        cdate()                 ## Returns "20xx/xx/xx"
        cdate(hms=True,d="-")   ## Returns "'20xx-xx-xx HH:MM:SS

    """
    if hms:
        return dt.now().strftime(f"%Y{d}%m{d}%d %H:%M:%S")
    else:
        return dt.now().strftime(f"%Y{d}%m{d}%d")



def errLog(*fields):
    """ Write messages to MACROSS' log file. Timestamps are added automatically
 as the first field. Send any number of fields for your log entry, but the 
 first field should be the log type (ERROR, INFO, etc.)

 **This function gives no response if executed outside of MACROSS, or if
 MACROSS is not configured for logging.

 Usage:
    errLog("<ERROR|INFO|WARN>","message field 1","message field 2"...)

    """
    
    ## Default path to MACROSS logs must be configured in setup
    if LOGS == 'none' or not ispath(LOGS):
        return

    cd = cdate(d="-")
    cm = cdate(d="-",hms=True)
    msg = str(f"{cm}\t")
    current_log = f"{LOGS}\\{cd}.txt"

    if fields:
        for f in fields:
            msg = str(f"{msg}\t{f}")

    msge = reString(msg,2) + "\n"

    if ispath(current_log,p="file"):
        with open(current_log,"a") as cl:
            cl.write(msge)
    else:
        with open(current_log,"w") as cl:
            cl.write(msge)


def delfile(d,force=False) -> None:
    """ Delete files.\n\n USAGE:\n\n\tdelfile(path_to_file)"""
    if not ispath(d):
        errLog("ERROR",f"Attempted to delete non-existent file '{d}'")
    else:
        if not force:
            confirm = input(f"""Are you sure you want to delete {d}?""")
        if force or search("^y",confirm):
            remove(d)


def rgx(pattern,string,replace=None,exact=False) -> str:
    """ Perform pattern matching/replacement. The pattern and string arguments are 
 required; add a third positional arg to perform replacement action. Use
 exact=True to perform exact pattern-matching. I had to import re for tasks
 in this library anyway, might as well make it part of macross.

 USAGE:
    Search a string:
    rgx(pattern,string)

    Search exact match:
    rgx(pattern,string,exact=True)

    Replace a string:
    rgx(pattern,string,replace)
 """
    if replace or replace == '':
        return sub(pattern,replace,string)
    else:
        r = None
        if exact:
            try:
                r = match(pattern,string).string
            except:
                pass
        else:
            try:
                r = search(pattern,string).string
            except:
                pass
        if r:
            return r


def gerwalk(cid: str) -> str:
    """ Retrieve MACROSS keys for use in your diamonds.  Keys must
 be generated in MACROSS' powershell gerwalk function; this
 python implementation can only retrieve existing keys, and only
 within the same configuration that created the key.

 USAGE:
    
    temp_key = gerwalk(<your macross id>) 

    """
    
    F = f"{RESOURCES}\\{cid}.ger"
    if not N_:
        return "MACROSS is not configured."
    elif not ispath(F,p="file"):
        nokey = f"Key {cid} does not exist"
        errLog("ERROR","MACROSS.gerwalk()",nokey)
        return f"{nokey}!"

    assembler1 = []
    assembler2 = []
    il1 = len(N_[1]) - 1
    il2 = len(N_[2]) - 1

    with open(F) as o:
        combine = "".join([c for c in o.read().split("\n") if "#" not in c])
    
    compacted = (reString(combine.strip())).split(".")
    nc = int(compacted[0])
    n = nc
    try:
        for c in compacted[1:]:
            mod = (N_[2][n]+2) * N_[0]
            assembler1.append(int(c) - mod)
            if n == 0:
                n = il2
            else:
                n -= 1
        
        n = nc

        for a in assembler1:
            mod = (N_[1][n]+2) * N_[0]
            ch = int(a) // mod
            assembler2.append(chr(ch))
            if n == 0:
                n = il1
            else:
                n -= 1
        
        return "".join(assembler2[::-1])
    except:
        return None
    

def psc(cc=None,cr=None) -> any:
    """ The psc function uses subfunctions of os.system() and os.popen() to   
 execute any Windows commands that you might require. Send your arg as "cc" 
 to simply execute a task; use "cr" instead if you need to save the result 
 from the task.
 
 USAGE EXAMPLES:

    # Launch a powershell diamond with args, but won't save any outputs
    psc(cc='powershell.exe "filepath\\myscript.ps1" "argument 1"')
    
    # Return your AD enumeration as a usable object
    result = psc(cr='powershell.exe "get-aduser -filter *"')

    """
    if cc:
        system(cc)
    if cr:
        TASK = popen(cr)
        return TASK.read()


def findDF(val:any,lang:str=".*",emax:int=None,rtype:str=".*",exact:bool=False) -> list:
    """ Use this function to search for tools with matching MACROSS attributes. Matching 
 tools are returned in a list that you can forward to the 
 valkyrie() function. 

 You can view attributes by looking at the third line of any MACROSS diamond.

 **This function only works when launched within MACROSS.

 OPTIONS: 
    val   = The valtype attribute(s) to filter (required)
    lang  = The lang attribute to filter
    emax  = The evalmax attribute to filter
    rtype = The rtype attribute to filter
    exact = Force exact matches for valtype attributes
 

 EXAMPLES:
 
    # Retrive a list of powershell tools that perform Active-Directory lookups
    ad_tools = findDF(val='active directory',lang='powershell')

    # Retrive a list of tools with the exact .valtype "active directory computer lookups"
    pc_lookups = findDF(val='active directory computer lookups',lang='powershell',exact=True)

    # Retrieve a list of tools that can parse IOCs from threat-intel, and can accept 2 args, and 
    # returns findings as a csv file, and can be written either in python or powershell
    ioc_tools = findDF(val='ioc,indicators',emax=2,rtype='csv')

    """

    ## The library is likely being used without MACROSS if LATTS is "False"
    if not LATTS or not val:
        return None

    res: list = []
    for t in LATTS:
        L = str(LATTS[t].lang)
        E = int(LATTS[t].evalmax)
        R = str(LATTS[t].rtype)
        N = str(LATTS[t].name)
        V = str(LATTS[t].valtype)
        me = False
        ml = rgx(lang,L)
        mr = rgx(rtype,R)
        if not emax or (emax and emax == E):
            me = True
        if ml and me and mr:
            if exact == True:
                if val == V:
                    res.append(N)
            elif rgx(val,V):
                res.append(N)

    return res


def valkyrie(Diamond:str=None,
    Caller:str=None,
    Protoculture:any=None,
    Spiritia:any=None,
    response:bool=False) -> any:
    """
######################################################################################
####   PYTHON COLLAB ~~~~~~~~~~~IMPORTANT!!!!!!~~~~~~~~~~~~~~~  ######################
######################################################################################
## If you want your MACROSS powershell diamonds to be able to respond to python requests,
## you **MUST** include this parameter check at the start of your powershell file to 
## ensure it can run as expected (an optional $spiritia param can accept another value
## as well):
##
##          param( [string]$pythonsrc=$null )     ## You can also include any other params needed
##          if( $pythonsrc -ne $null ){
##              $Global:CALLER = $pythonsrc
##              foreach( $core in gci "$PSScriptRoot\\..\\corefuncs\\*.ps1" |
##                Where-Object{$core.name -ne 'configurations.ps1'}){ 
##                     . $core.fullname
##                  }
##              spaceFold
##          }
##
## The "spaceFold" powershell function will load all of the required resources
## in a new, temporary session outside of your current MACROSS session.
######################################################################################

 The python "valkyrie" function writes your PROTOCULTURE value to a ".mac7"
 file in the GBIO folder for the powershell diamond to read and write its results to.

 **This function only works when launched within MACROSS.

 OPTIONS
    Diamond         = the name of the diamond you're calling
    Caller          = the name of your diamond
    Protoculture    = the value that needs to be investigated/enriched (global PROTOCULTURE)
    Spiritia        = "alt param", if the diamond you send Protoculture to can accept an 
                        addition arg/parameter, set it here
    response        = set True if you're only writing data to the PROTOCULTURE.mac7 file
                        for diamonds to read from, and not requesting them to send data back

 USAGE:
 If the PROTOCULTURE.mac7 file's "result" field is "PS_", then the "protoculture" field is meant
 to be python's PROTOCULTURE value. You can retrieve a dict of the file's contents by 
 calling the function without any arguments:

        c = valkyrie()
        c['caller']
        c['protoculture']
        c['spiritia']
        c['result']  ## If 'result' == "WAITING", the 'protoculture' field should be your
                     ## PROTOCULTURE value.
                     ## If 'result' == "PS_", valkyrie will swap 'protoculture' & 'result' for you, as
                     ## powershell added its PROTOCULTURE response to the initial protoculture field

 After processing the PROTOCULTURE value, write your results for powershell to retrieve:

        valkyrie(Protoculture=<script results>,response=True)

 To pass values for powershell to process and send back to your python diamond:

        diamond = <the name of the powershell diamond>
        caller = "MyScript"
        protoculture = "some ioc value"
        spiritia = "some hostname"
        valkyrie(Diamond=diamond, Caller=caller, Protoculture=protoculture, Spiritia=spiritia)
        
 where Diamond is the powershell diamond you're calling (no extension), Caller is the name of 
 your python diamond, and Protoculture is the value you need powershell to evaluate. You can  
 also send an additional parameter (Spiritia=) if the powershell diamond accepts one.

 The macross function "findDF()" can help you find diamonds for forwarding any 
 PROTOCULTURE values to.

 "corefuncs\\pycross\\garbage_io\\PROTOCULTURE.mac7" is a json file that contains the key-values
 "Caller.protoculture" (the PROTOCULTURE value) and "Caller.result". If the powershell diamond has a 
 response for your python diamond, it will be written to the "Caller.result" field of 
 PROTOCULTURE.mac7, where this function will retrieve it and forward it to your diamond.

 The PROTOCULTURE.mac7 file will remain the default PROTOCULTURE value in MACROSS until
 you delete it from the menu by entering "terminate", or exit MACROSS.

 All mac7 files are deleted at startup and exit, so if you want to keep persistent files in
 this directory, change the extension to anything other than ".mac7"

    """
    
    ## The library is likely being used without MACROSS if GBIO is "False"
    if not GBIO:
        return None


    set_policy = None
    #####################  IMPORTANT!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ## Your organization may frown on python modifying execution policy in powershell to
    ## prevent blocking MACROSS scripts. Uncomment this ONLY if your scripts are being
    ## blocked AND you won't be violating policy!
    #set_policy = "set-executionpolicy -executionpolicy remotesigned -scope currentuser"
    PROTOCULTURE,SPIRITIA = [""]*2

    def determineProto(prot):
        pr = []
        if type(prot) == list:
            for P in prot:
                pr.append(f"[{P}]")
        elif type(prot) == dict:
            for P in prot.keys():
                pr.append("{\""+f"{P}\":\"{prot[P]}\""+"}")
        else:
            del pr
            pr = str(prot)
        return pr

    ## Create new or update existing PROTOCULTURE.mac7 file
    def writeProto_(sc:dict=None,pf:str=proto_file) -> None:
        with open(pf,"w") as o:
            o.write(dumps(sc))
    
    # Read an existing PROTOCULTURE.mac7 file
    def readProto_(pf=proto_file) -> dict:
        proto_pairs: dict = {}
        with open(pf) as d:
            read_proto = load(d)
            
        res = read_proto["result"]
        proto = read_proto["protoculture"]
        proto_pairs["caller"] = read_proto["caller"]
        proto_pairs["spiritia"] = read_proto["spiritia"]
        if isinstance(res,str) and res == "PS_":
            proto_pairs["result"] = proto
            proto_pairs["protoculture"] = res
        else:
            proto_pairs["protoculture"] = proto
            proto_pairs["result"] = res

        return proto_pairs
    
    ## Make sure we can define the .mac7 file's primary index
    if Caller:
        use_caller = Caller
    elif CALLER:
        use_caller = CALLER
    elif Protoculture:
        raise ValueError("Missing required Caller value!")
        return


    if not Diamond and not Protoculture and not Spiritia:
        if ispath(proto_file,p='file'):
            return readProto_()  
        else:
            return False
    
    elif (Spiritia or Protoculture) and ispath(proto_file,p='file'):
        protoculture = {}
        readin = readProto_(proto_file)
        c = readin["caller"]
        ## Give priority to existing Caller value if different from the ID in the .mac7 file
        if c != use_caller:     
            c = use_caller
        protoculture = readin
        protoculture["caller"] = c
        if Protoculture:
            protoculture["result"] = Protoculture
        if Spiritia:
            protoculture["spiritia"] = Spiritia
        writeProto_(sc=protoculture)
        return
    else:
        if not Diamond:
            Diamond = use_caller
        L = LATTS[Diamond].lang
        R = LATTS[Diamond].rtype
        Diamond = LATTS[Diamond].fname        # The MACROSS diamond to query
        chdir(MACROOT)
        if L == 'python':
            div = "\\\\"
        else:
            div = "\\"
        fullpath = f"{MODS}{div}{Diamond}"
        empty = "WAITING"   # This lets python know whether or not powershell writes results to PROTOCULTURE.mac7

        if Protoculture:
            PROTOCULTURE = determineProto(Protoculture)
        if Spiritia:
            SPIRITIA = determineProto(Spiritia)
        

        '''
        pr: list = []       # Create the contents to write into PROTOCULTURE.mac7 file
        if type(Protoculture) == list:
            for P in Protoculture:
                pr.append(f"[{P}]")
        elif type(Protoculture) == dict:
            for P in Protoculture.keys():
                pr.append("{\""+f"{P}\":\"{Protoculture[P]}\""+"}")
        else:
            del pr
            pr = str(Protoculture)

        protoculture = {use_caller:{"protoculture":pr,"result":empty}}
        '''

        protoculture = {"caller":use_caller,"protoculture":PROTOCULTURE,"result":empty,"spiritia":SPIRITIA}
        writeProto_(sc=protoculture)

        # When only writing a response to other diamonds' valkyrie calls, quit here
        if response:
            return

        # Jumping back to powershell *may* require temporarily creating a temp env
        #if getenv("MACCONF"):
        #    environ["MACCONF"] = getenv("MACCONF")
        if getenv("MACROSS"):
            environ["MACTEMP"] = getenv("MACROSS")

        
        # Launching a MACROSS diamond from python requires a brand new session
        call = None
        if L == 'powershell':
            if PSVER < 7:
                call = f"powershell.exe {fullpath} -pythonsrc {use_caller}"
            else:
                call = f"pwsh.exe {fullpath} -pythonsrc {use_caller}"
            if Spiritia:
                call = f"{call} -spiritia {Spiritia}"
        else:
            call = f"py {fullpath} {Spiritia}"   ## Use sys.argv in your diamond to check for argv[1] if you want to accept Spiritia args
            environ["PROTOCULTURE"] = protoculture["protoculture"]
            environ["CALLER"] = use_caller

        if set_policy:
            psc(cc=set_policy)
        if call:
            psc(cc=call)

        res = readProto_()

        if (res.get("result") and res["result"] != empty) or res.get("spiritia"):
            return res
        else:
            return False

## getFile() definition
## Tkinter works best, but that lib doesn't work with the portable executable structure
if not nokinter:
        
    def getFile(filter:str='all',opendir:str="H:\\",folder:bool=False):
        """ The getFile() function opens a dialog window for users to select a file. 

    OPTIONS
    opendir: the default directory to being selection search. Default is "H:\\"

    folder: set to True if you need users to only select a folder path

    filter: limit user selections to type of file
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
        'zip' = zip, gz, 7z, jar, rar files

        You can send another file extension as a filter for custom file types, if 
        necessary.

    USAGE:

        FOLDER_PATH = getFile(folder=True,opendir='directory\\to\\file')
        PDFDOC = getFile(opendir='directory\\to\\file',filter='pdf')
        ZIPFILE = getFile(filter='zip')
        REPORT = getFile(filter='dox')

        # Send any custom extension filter:
        XYZ_FILE = getFile(filter='xyz')
        
        """
        ft = {
            'all':(("All files", "*.*"),("All files", "*.*")),
            'csv':(("Comma-Separated Document", "*.csv"),("Comma-Separated Document", "*.csv")),
            'custom':(("Custom Filetype", f"*.{filter}"),("Custom Filetype", f"*.{filter}")),
            'doc':(("Document Types", "*.docx"),("Document Types", "*.doc"),("Document Types", "*.rtf"),("Document Types", "*.pdf"),\
                ("Document Types", "*.xls"),("Document Types", "*.xlsx")),
            'dox':(("MS Word Doc", "*.docx"),("MS Word Doc", "*.doc")),
            'exe':(("Executables", "*.exe"),("Executables", "*.exe")),
            'msg':(("Email message", "*.msg"),("Email message", "*.msg")),
            'mso':(("Microsoft Office", "*.doc"),("Microsoft Office", "*.docx"),("Microsoft Office", "*.xls"),("Microsoft Office", "*.xlsx"),\
                ("Microsoft Office", "*.one"),("Microsoft Office", "*.ppt"),("Microsoft Office", "*.pptx"),("Microsoft Office", "*.accdb"),
                ("Microsoft Office", "*.accde"),("Microsoft Office", "*.ost"),("Microsoft Office", "*.pst")),
            'pdf':(("Portable Document Format", "*.pdf"),("Portable Document Format", "*.pdf")),
            'ppt':(("MS Powerpoint", "*.pptx"),("MS Powerpoint", "*.ppt")),
            'scr':(("Script files", "*.ps1"),("Script files", "*.psm"),("Script files", "*.py"),("Script files", "*.pyc"),\
                ("Script files", "*.pyd"),("Script files", "*.bat"),("Script files", "*.lua"),("Script files", "*.js")),
            'txt':(("Text files", "*.txt"),("Text files", "*.txt")),
            'web':(("Web Files", "*.html"),("Web Files", "*.htm"),("Web Files", "*.css"),("Web Files", "*.js"),("Web Files", "*.aspx"),\
                ("Web Files", "*.php"),("Web Files", "*.json")),
            'xls':(("Excel Spreadsheet", "*.xlsx"),("Excel Spreadsheet", "*.xls")),
            'zip':(("Compressed", "*.zip"),("Compressed", "*.rar"),("Compressed", "*.7z"),("Compressed", "*.tar"),("Compressed", "*.gz"),\
                ("Compressed", "*.jar"))
        }
        Tk().withdraw()
        FT = ft[filter]
        selection = None
        if folder:
            selection = aod(initialdir=opendir)
        else:
            if filter not in ft.keys():
                FT = ft['custom']
            selection = aof(initialdir=opendir,filetypes=FT)
        return selection

else:   
    def getFile(opendir="H:\\", filter='all', folder:bool=False) -> str:
        """
        Open a native Windows file/folder dialog to select a filepath. This function is
        no longer able to use tkinter, so it is a bit buggy.
        
        OPTIONS
        opendir: the default directory to begin selection. Default is "H:\\"
        folder: True -> select folder; False -> select file
        filter: restrict file selection* ->
            'all', 'csv', 'doc', 'dox', 'exe', 'msg', 'mso',
            'pdf', 'ppt', 'scr', 'txt', 'web', 'xls', 'zip', 'custom'
        
            *Selecting an M$ office format like 'xls' filters on both the modern and
                legacy formats, e.g. 'xls' and 'xlsx' 
            *doc vs. dox: 'doc' filters for all common document types, including pdf, xls
                & rtf; 'dox' filters specifically for M$ Word .doc and .docx
            *web: filters for filetypes commonly associated with web servers, e.g. html,
                php, json, css, etc.
            *scr: filters for common script types like ps1, py, js, lua, etc.
            *custom: lets you filter for a single custom/irregular filetype


        USAGE EXAMPLES:
        # Select a pdf document
        pdf_doc = getFile(opendir="C:\\Users\\bob\\Desktop", filter="pdf")

        # Select a folder
        folder_path = getFile(folder=True, opendir="C:\\Temp")

        # Custom extension
        xyz_file = getFile(filter="xyz")
        """


        if folder:
            BIF_RETURNONLYFSDIRS = 0x0001
            BIF_NEWDIALOGSTYLE = 0x0040
            """
            class FolderInfo(ctypes.Structure):
                _fields_ = [
                    ("hwndOwner", ctypes.wintypes.HWND),
                    ("pidlRoot", ctypes.c_void_p),
                    #("pszDisplayName", ctypes.c_wchar_p),
                    ("pszDisplayName", ctypes.c_wchar_p * 260),
                    ("lpszTitle", ctypes.c_wchar_p),
                    ("ulFlags", ctypes.c_uint),
                    ("lpfn", ctypes.c_void_p),
                    ("lParam", ctypes.c_void_p),
                    ("iImage", ctypes.c_int),
                ]
            def browse_for_folder(title):
                SHBrowseForFolder = ctypes.windll.shell32.SHBrowseForFolderW
                SHGetPathFromIDList = ctypes.windll.shell32.SHGetPathFromIDListW
                bi = FolderInfo()
                bi.hwndOwner = None
                bi.pidlRoot = None
                bi.pszDisplayName = buf
                bi.lpszTitle = title
                bi.ulFlags = BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE
                pidl = SHBrowseForFolder(ctypes.byref(bi))
                if pidl:
                    SHGetPathFromIDList(pidl, buf)
                    return buf.value
                return None
            return browse_for_folder("Select Folder")
            """
            def browse_for_folder(title="Select Folder"):
                MAX_PATH = 260
                buf = ctypes.create_unicode_buffer(MAX_PATH)

                class FolderInfo(ctypes.Structure):
                    _fields_ = [
                        ("hwndOwner", wintypes.HWND),
                        ("pidlRoot", ctypes.c_void_p),
                        ("pszDisplayName", wintypes.LPWSTR),  ## POINTER
                        ("lpszTitle", wintypes.LPCWSTR),
                        ("ulFlags", wintypes.UINT),
                        ("lpfn", ctypes.c_void_p),
                        ("lParam", ctypes.c_void_p),
                        ("iImage", ctypes.c_int),
                    ]

                bi = FolderInfo()
                bi.hwndOwner = None
                bi.pidlRoot = None
                bi.pszDisplayName = ctypes.cast(buf, wintypes.LPWSTR)  ## <-- THIS IS REQUIRED
                bi.lpszTitle = title
                bi.ulFlags = 0x0001 | 0x0040  ## BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE

                pidl = ctypes.windll.shell32.SHBrowseForFolderW(ctypes.byref(bi))
                if not pidl:
                    return None

                ctypes.windll.shell32.SHGetPathFromIDListW(pidl, buf)
                return buf.value
            
            return browse_for_folder()


        ## File filters
        ft = {
            'all': "All Files\0*.*\0",
            'csv': "Comma-Separated Files\0*.csv\0",
            'custom': f"Custom Files\0*.{filter}\0",
            'doc': "Documents\0*.docx;*.doc;*.pdf;*.rtf;*.xls;*.xlsx\0",
            'dox': "MS Word\0*.docx;*.doc\0",
            'exe': "Executables\0*.exe\0",
            'msg': "Email Messages\0*.msg\0",
            'mso': "Microsoft Office\0*.doc;*.docx;*.xls;*.xlsx;*.ppt;*.pptx;*.one;*.accdb;*.accde;*.ost;*.pst\0",
            'pdf': "PDF Files\0*.pdf\0",
            'ppt': "PowerPoint\0*.pptx;*.ppt\0",
            'scr': "Scripts\0*.ps1;*.psm;*.py;*.pyc;*.pyd;*.bat;*.lua;*.js\0",
            'txt': "Text Files\0*.txt\0",
            'web': "Web Files\0*.html;*.htm;*.css;*.js;*.aspx;*.php;*.json\0",
            'xls': "Excel Files\0*.xls;*.xlsx\0",
            'zip': "Compressed\0*.zip;*.rar;*.7z;*.tar;*.gz;*.jar\0"
        }

        file_filter = ft.get(filter, f"Custom Files*.{filter}")
        buffer = ctypes.create_unicode_buffer(260)

        ## This method sucks ass...
        class FilenameInfo(ctypes.Structure):
            _fields_ = [
                ("lStructSize", wintypes.DWORD),
                ("hwndOwner", wintypes.HWND),
                ("hInstance", wintypes.HINSTANCE),
                ("lpstrFilter", wintypes.LPCWSTR),
                ("lpstrCustomFilter", wintypes.LPWSTR),
                ("nMaxCustFilter", wintypes.DWORD),
                ("nFilterIndex", wintypes.DWORD),
                ("lpstrFile", wintypes.LPWSTR),
                ("nMaxFile", wintypes.DWORD),
                ("lpstrFileTitle", wintypes.LPWSTR),
                ("nMaxFileTitle", wintypes.DWORD),
                ("lpstrInitialDir", wintypes.LPCWSTR),
                ("lpstrTitle", wintypes.LPCWSTR),
                ("Flags", wintypes.DWORD),
                ("nFileOffset", wintypes.WORD),
                ("nFileExtension", wintypes.WORD),
                ("lpstrDefExt", wintypes.LPCWSTR),
                ("lCustData", wintypes.LPARAM),
                ("lpfnHook", wintypes.LPVOID),
                ("lpTemplateName", wintypes.LPCWSTR),
                ("pvReserved", wintypes.LPVOID),
                ("dwReserved", wintypes.DWORD),
                ("FlagsEx", wintypes.DWORD)
            ]

        ofn = FilenameInfo()
        ofn.lStructSize = ctypes.sizeof(ofn)
        ofn.lpstrFilter = file_filter
        ofn.lpstrFile = ctypes.cast(buffer, wintypes.LPWSTR) #buffer
        ofn.nMaxFile = len(buffer)
        ofn.lpstrInitialDir = opendir
        ofn.Flags = 0x00080000 | 0x00001000  ## OFN_EXPLORER | OFN_FILEMUSTEXIST

        if ctypes.windll.comdlg32.GetOpenFileNameW(ctypes.byref(ofn)):
            return buffer.value
        return None


def screenResults(A='endr',B=None,C=None,display=False) -> None:
    """ Print strings to screen in 1, 2 or 3 columns.
    
 Each string value is optional, and will be written to screen in separate
 rows & columns. (Your mileage may vary depending on the strings that get passed
 in; I sometimes get a display with broken columns. It usually works pretty well,
 though. Feel free to play with the math, since I suck at it)

 You can send the first letter of a color ("k" for black) and "~" to colorize
 text, for example "c~Value" to write "Value" in cyan.

 Formatting options: (c)yan, blac(k), (b)lue, (r)ed, (y)ellow, (w)hite, (m)agenta,
 and (ul) for underline.

 Note that adding formatting or colors to text can sometimes cause the columns 
 to break. This isn't quite a 1-for-1 translation from the powershell version.

 To finish your outputs, call the function again without any values to
 write the closing row boundary.

 OPTIONS
    A = The string you want printed to the first column
    B = The string you want printed to the second column
    C = The string you want printed to the third column



 EXAMPLE: Write 3 columns, with the second column in green:

    screenResults(headerstring1,headerstring2,headerstring3)
    screenResults(string1,f"g~{string2}",string3)
    screenResults()

"""
    if display:
        return reString('7465726D696E61746F72','h')
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
        def csep_(text,tc=None):
            if tc != None and tc in fcolor:
                print(fcolor[tc] + text + fcolor['rs'], end = ' ')
            else:
                print(text, end = ' ')

        ## Take the input and wrap it to fit within the specified column width, OR
        ## if the input is smaller, add whitespace to increase its length.
        def genBlocks_(outputs,min,max):
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
        ## End genBlocks_ nested function
        
        ## Check for highlight tags
        atc,btc,ctc = [None] * 3
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
            BLOCK1 = genBlocks_(A,23,22)
            if C != None:
                WIDE3 = len(C)
                BLOCK2 = genBlocks_(B,32,30) #genBlocks_(B,34,32)
                BLOCK3 = genBlocks_(C,28,26) #genBlocks_(C,28,25)
                CT3 = len(BLOCK3)
            else:
                CT3 = None
                BLOCK2 = genBlocks_(B,62,61) #genBlocks_(B,64,62)
                
            CT2 = len(BLOCK2)

        else:
            CT3 = None
            CT2 = None
            BLOCK1 = genBlocks_(A,88,87) #genBlocks_(A,96,95)

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

        """
        Outputs will get formatted to screen based on:
            -how many values got passed in (1, 2, or 3)
            -how many words are in each output
            -which outputs have the most words in them
            -I hate math
        """
        if CT3 != None:
            COUNTDOWN = CT1 + CT2 + CT3
            while COUNTDOWN != 0:
                csep_(c,'g')
                if CT1 != 0:
                    csep_(BLOCK1[INDEX1],atc)
                    CT1 = CT1 - 1
                    INDEX1 += 1
                    COUNTDOWN = COUNTDOWN - 1
                else:
                    csep_(EMPTY1)

                csep_(c,'g')
                if CT2 != 0:
                    csep_(BLOCK2[INDEX2],btc)
                    CT2 = CT2 - 1
                    INDEX2 += 1
                    COUNTDOWN = COUNTDOWN - 1
                else:
                    csep_(EMPTY2)

                csep_(c,'g')
                if CT3 != 0:
                    csep_(BLOCK3[INDEX3],ctc)
                    CT3 = CT3 - 1
                    INDEX3 += 1
                    COUNTDOWN = COUNTDOWN - 1
                else:
                    csep_(EMPTY3)

                w(c,'g')
    
        elif CT2 != None:
            if CT1 > CT2 and CT2 != 0:
                if CT2 == 1:
                    MIDDLE = ceil((CT1/2) - 1)
                else:
                    MIDDLE = ceil((CT1/CT2) - 1)

                for Block in BLOCK1:
                    if LINENUM < MIDDLE:
                        csep_(c,'g')
                        csep_(Block,atc)
                        csep_(c,'g')
                        csep_(EMPTY2)
                        w(c,'g')
                        LINENUM += 1
                    else:
                        csep_(c,'g')
                        csep_(Block,atc)
                        csep_(c,'g')
                        if CT2 != 0:
                            csep_(BLOCK2[INDEX2],btc)
                            w(c,'g')
                            INDEX2 += 1
                            CT2 = CT2 - 1
                        else:
                            LINENUM = -1
                            csep_(EMPTY2)
                            w(c,'g')
            elif CT2 > CT1 and CT1 != 0:
                if CT1 == 1:
                    MIDDLE = ceil((CT2/2) - 1)
                else:
                    MIDDLE = ceil((CT2/CT1) - 1)

                for Block in BLOCK2:
                    csep_(c,'g')
                    if LINENUM < MIDDLE:
                        csep_(EMPTY1)
                        LINENUM += 1
                    else:
                        if CT1 != 0 and INDEX1 < CT1:
                            csep_(BLOCK1[INDEX1],atc)
                            csep_(c,'g')
                            INDEX1 += 1
                        else:
                            LINENUM = -1
                            csep_(EMPTY1)
                    csep_(c,'g')
                    if CT2 != 0:
                        csep_(Block,btc)
                    w(c,'g')
            else:
                for Block in BLOCK2:
                    csep_(c,'g')
                    if INDEX1 < CT1:
                        csep_(BLOCK1[INDEX1],atc)
                        INDEX1 += 1
                        csep_(c,'g')
                    if CT2 != 0:
                        csep_(Block,btc)
                    w(c,'g')
        else:
            for Block in BLOCK1:
                csep_(c,'g')
                csep_(Block,atc)
                w(c,'g')


def reString(v,action='b',encd='utf8') -> str:
    """ This is the same as MACROSS' powershell function 'reString'. Your
 first argument is the encoded string you want to de/encode, and your
 second arg (action=) will be:

    'b' if decoding base64 (default action), or
    'h' if decoding hexadecimal, or
    'eb' if encoding to base64, or
    'eh' if encoding to hexadecimal.

 Unlike the powershell function, this function does NOT write to
 "dyrl_READ", it just returns your processed string.

 You can pass an optional arg encd= to specify the out-encoding (ascii,
 ANSI, etc.; default is UTF-8).

 Usage:
    PLAINTEXT       = reString(base64string)
    PLAINTEXTASCII  = reString(base64string,encd='ascii')
    PLAINTEXT       = reString(hexstring,action='h')
    HEX             = reString('plaintext',action='eh')
    BASE64          = reString('plaintext',action='eb')

    """
    if action == 'b':
        newval = b64.b64decode(v)
        newval = newval.decode(encd)
    elif action == 'h':
        if search('0x',v):
            v = sub('0x','',v)
        if search(' ',v):
            v = sub(' ','',v)
        newval = bytes.fromhex(v).decode(encd)
    elif action == 'eb':
        newval = str(b64.b64encode(v.encode()).decode())
    elif action == 'eh':
        newval = ''
        for b in v:
            hb = "{0:02x}".format(ord(b)).upper()
            newval = newval + hb
        
    return newval


