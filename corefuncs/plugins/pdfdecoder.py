'''
    MACROSS pdf decoder. Requires at least one of [pdfplumber] or [pypdf] libs.
    USAGE: Send the filepath as your first arg, and a name for the output file (no 
    extension) as the second arg. Plaintext is written to your 

                 %LOCALAPPDATA%\Temp\MACROSS

    folder so that your scripts can read from it as necessary using either {TMP} or $vf19_TMP.  
    MACROSS cleans out this folder at startup and shutdown.
    Send "1" as a third argument to parse using pdfplumber instead of pypdf. It's
    usually better at preserving layouts, which aids with more accurate searches, but 
    makes it harder to just read the text output in a powershell window.

         python.exe 'pdfdecoder.py' 'path\\to\\file' 'filename'

'''


from sys import argv
from macross import errLog,slp,TMP,w
try:
    from importlib.util import find_spec
except:
    emsg1 = 'Could not import util from importlib for macross.pdfdecoder.'
    errLog('ERROR',emsg1)
    raise Exception(emsg1)
    slp(2)
    exit()


pdf1 = (find_spec("pdfplumber")) != None
pdf2 = (find_spec("pypdf")) != None
L = len(argv)

if L >= 3:
    from re import sub
    FILE = argv[1]                              ## PDF to parse
    FNAME = argv[2]                             ## Name for the output file
    OUT = f"{TMP}\\decoded-pdf-{FNAME}.mac7"
    if L > 3 and pdf1:
        import pdfplumber as pdfp
        PDR = False
        PLM = True
    elif pdf2:
        from pypdf import PdfReader as pdr
        PLM = False
        PDR = pdr(FILE)
    else:
        emsg2 = 'Missing required libs "pdfplumber" and/or "pypdf"'
        errLog('ERROR',emsg2)
        raise Exception(emsg2)
        slp(3)
        exit()
else:
    exit()


## Strip out unicode that can't be extracted to plaintext
def asciiFilter(e):
    #return sub(r"[^\x20-\x7E]+","",e)
    encoded = e.encode('ascii','ignore')
    return encoded.decode('ascii')



plaintext = []


## User wants to preserve layout of the pdf
if PLM:
    w(f" Decoding {FNAME}.pdf","g")
    with pdfp.open(FILE) as o:
        for page in o.pages:
            extract = page.extract_text(layout=True)
            plaintext.append(asciiFilter(extract))

## DEFAULT: just grab the plaintext, don't care about where
## whitespace or carriage returns are.
elif PDR:
    for p in PDR.pages:
        
        extract = p.extract_text()

        ## Create a list with each line as an item
        if "\n\n" in extract:
            splitter = "\n\n"
        elif "\n\r" in extract:
            splitter = "\n\r"
        
        ## If no new lines, create a single-value list
        else:
            splitter = "jUsTaS1NgLe_Bl0cK_"
        
        decodeit = asciiFilter(extract)
        for d in decodeit.split(splitter):
            d = sub("\\n","",d)
            plaintext.append(d)


if len(plaintext) > 0:
    with open(OUT,'w') as o:
        o.write("\n".join(plaintext))



