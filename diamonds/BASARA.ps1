#_sdf1 Example Python Automation
#_ver 0.1
#_class user,common,example encoder diamond,python,HiSurfAdvisory,1,string

import macross as mac
from macross import macross


## The macross library replicates most of MACROSS' powershell utilities; some of these functions
## are redundant in python, but it helps to use the same function names for MACROSS-specific
## code. Importing macross also carries over the global powershell variables like PROTOCULTURE 
## and CALLER when they've already been set beforehand.

## In the debug menu, just type "python" and you can manually import macross in a python shell
## to view all its functions.

## In addition to macross, the portable python environment provides these libraries:
##  numpy, pandas, pypdf, pdfplumber, beautifulsoup, paramiko


## Here we check if BASARA is being called by another diamond vs. from the main menu
if mac.CALLER:
    ## You can check the properties of a calling diamond using the LATTS object: 
    LANGUAGE = mac.LATTS[mac.CALLER].lang

    ## If a powershell diamond called, it should have already imported a PROTOCULTURE variable
    if LANGUAGE == 'powershell' and mac.PROTOCULTURE:

        ## The reString function encodes & decodes both Base64 and Hexadecimal
        base64 = mac.reString(mac.PROTOCULTURE,action='eb')
        processed = f"Encoded as Base64: {base64}"

        ## In python, MACROSS' valkyrie function handles both retrieving and forwarding a PROTOCULTURE 
        ## value back and forth with powershell by using disposable ".mac7" files in the local 
        ## folder "corefuncs\pycross\garbage_io". Here, we send the encoded text back to
        ## powershell for this demo by setting "response=True".
        mac.valkyrie(Protoculture=processed,response=True)
    
    else:
        ## A python diamond will set PROTOCULTURE a little differently.
        ## Calling valkyrie() without arguments will retrieve PROTOCULTURE values in the fields
        ## "protoculture". It also returns "caller", "spiritia" & "results".
        assist = mac.valkyrie()

        ## When a diamond is waiting for response, the "result" value will be "WAITING". Your 
        ## diamond will update this value with the valkyrie() function when it finishes its work.
        ## You must set "response=True" if your diamond is providing data instead of requesting it!
        ## (default is False)
        if assist["result"] == "WAITING":
            PROTOCULTURE = assist["protoculture"]               ## PROTOCULTURE should be in the protoculture field
            base64 = mac.reString(PROTOCULTURE,action='eb')     ## Encode whatever value was requested to be processed
            processed = f"Encoded as Base64: {base64}"          ## Format our response
            mac.valkyrie(Protoculture=processed,response=True)  ## Send the response back to the python diamond

        
else:
    ## MACROSS' psc() function executes commands via the os library
    mac.psc("cls")

    ## MACROSS' battroid() function generates ascii-art text for your diamond titles
    title = mac.battroid("basara")
    print("\n\n")
    
    ## MACROSS' w() function simplifies formatting the way text looks on screen by letting colorize
    ## both the text and the background.
    mac.w(title,"y")
    print("\n")
    mac.w(f"{' '*10}MACROSS automation flow:{' '*10}",f="k",b="y")


    ## The powershell HIKARU diamond demonstrates protecting data using gerwalk keys; in python,
    ## you can decrypt keys using macross.gerwalk(), but you can only generate new keys
    ## in powershell's gerwalk.



    ## The w() function also lets you format text with underlines (u=True) and "no new lines"
    ## (i=True) if you need to use several different formats on the same line.
    mac.w("\n\n  1.",f="k",b="y",u=True,i=True)
    mac.w(""" Your automation does whatever it needs to do, but instead of coding extra tasks,
 you can search for existing automations within MACROSS written by yourself or your team
 to enrich or further process your diamond's data:""","g")
    mac.w("\n  2.",f="k",b="y",u=True,i=True)
    mac.w(""" The findDF function finds relevant diamonds (scripts), and the valkyrie function 
 forwards and retrieves data between them, with all automations giving priority to data 
 assigned to the global variable PROTOCULTURE""","g")
    mac.w("\n  3.",f="k",b="y",i=True,u=True)
    mac.w("""  MACROSS provides numerous utilities to quickly reformat data onscreen or into 
 reports & spreadsheets""","g")

    mac.w("\n\n This demo will send a filepath to powershell and ask for the file's hash.","g")
    mac.w(" Hit ENTER to select a file and begin the demo.","g")
    input()

    ## getFile() lets you open explorer to quickly get a filepath
    file = mac.getFile()

    ## Use MACROSS' findDF() to find other diamonds that can help enrich or transform your diamond's 
    ## outputs. This function searches the LATTS object for diamond attributes based on filters you provide.
    relevant_tools = mac.findDF(val="code example",lang="powershell",exact=False)

    for r in relevant_tools:

        ## Your diamond can figure out what the response format is by checking the called-script's rtype attribute
        data_type = mac.LATTS[r].rtype

        ## The LATTS object contains properties for all of MACROSS' diamonds; you can use this to 
        ## determine how to respond to a calling diamond.
        mac.w(" MACROSS provided the diamond ","g",i=True)
        mac.w(mac.LATTS[r].name,"c",i=True)
        mac.w("/","g",i=True)
        mac.w(f"'{mac.LATTS[r].valtype}'","m",i=True)
        mac.w(" to get","g")
        mac.w(" info about the file.\n","g")
        mac.w(f" the response should be in {data_type} format.","g")
        
        ## Use the valkyrie() function to send a PROTOCULTURE value to the powershell diamond for processing.
        ## This requires knowing what Diamond to call, and telling valkyrie that your diamond is the CALLER.
        mac.valkyrie(Diamond=r,Caller='BASARA',Protoculture=file)

        ## Call the valkyrie function without args to retrieve the powershell response, which is 
        ## a dictionary containing "caller", "protoculture", "spiritia" and "result" indexes.
        proto_result = mac.valkyrie()
        response = proto_result["result"]
        spiritia = proto_result["spiritia"]

        mac.w("\n ...Now we're back in python.\n","g")

        mac.w(" The powershell diamond should have given us back the filehash and creation timestamp:\n")
        labels = [" filename"," hash"," creation time"]

        for i,result in enumerate(response):
            ## MACROSS' screenResults function takes multiple lines, or large blocks of text, and 
            ## **attempts** to format them in rows with up to 3 columns (the python implementation 
            ## doesn't always work as well as the powershell version):
            mac.screenResults(labels[i],result)
        mac.screenResults()

    input("\n\n Be sure to review this python code's comments to see how MACROSS works.\n Hit ENTER to close this demo.")
    exit()





