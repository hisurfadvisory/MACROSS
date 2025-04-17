#_sdf1 Python collab demo
#_ver 0.1
#_class 0,user,demo script,python,HiSurfAdvisory,0,dictionary


# The HELP value means that a user wants to view the help/description page.
from valkyrie import w,HELP
if HELP:
    w("""
    This script is a companion to HIKARU, performing the same demonstration
    by forwarding a search query to MISA. Unlike HIKARU, which asks you for
    keywords, CLAUDIA's search query is hard-coded.

    When MISA receives a query from any MACROSS tool with a .valtype of 
    "demo script", it will forward that query to a standard MACROSS tool
    called GUBABA, which is an index of Windows Event IDs and their
    descriptions.

    HIKARU demonstrates using the availableTypes and collab functions in
    powershell; CLAUDIA demonstrates doing the same from python using the
    built-in valkyrie python library.
      
    Hit ENTER to exit.
    ""","y")
    input()
    exit()
    
else:
    
    # The w() function lets you quickly format screentext; the screenResults()
    # function formats blocks of text into columns; availableTypes() allows you
    # to filter for tools that are relevant to your script; and collab() allows 
    # sharing a common IOC value between MACROSS tools.
    from valkyrie import availableTypes,screenResults,collab
    from json import loads


    def main():
        keywords = 'user change'

        # MACROSS' valkyrie.availableTypes() function allows you to grab specific collaboration
        # scripts based on their macross-class attributes. In this case, I know this specific filter
        # will only return the script MISA. These attributes are set according to the third line
        # of a MACROSS script, which begins with "#_class ".
        partner = (availableTypes(val='demo script',la='python',ra='onscreen'))[0]

        w(f"\n\nThis is a simple demo. I am sending the search term \"{keywords}\" to {partner}.","g")
        w("If any results are found, they'll print below.","g")
        w("\nNote that the GUBABA.ps1, HIKARU.py and MISA.py scripts must be present in the ","g")
        w("modules folder, and the gubaba.json file must be present in the resources folder","g")
        w("for these demonstrations to work.","g")
        w("\n\nHit ENTER to continue.","g",i=True)
        input()

        # The collab function handles creating and clearing the necessary global values, including
        # managing the PROTOCULTURE.eod file that enables passing data back and forth between
        # powershell and python scripts.
        t = collab(Tool=partner,Caller="CLAUDIA",Protoculture=keywords)
        print("\n")
        screenResults(f"y~{' '*29}Welcome back to CLAUDIA")
        screenResults(f"c~{' '*20}MISA's response after searching with GUBABA:")
        screenResults()
        for i in t:
            r = loads(i)
            k = [R for R in r.keys()][0]
            screenResults(f"Event ID: {k}",r[k])
        
        screenResults()
        input('\n Review the MISA, CLAUDIA, and HIKARU scripts to view the collaboration\n '\
        'process. Hit ENTER to exit this demo. Run the HIKARU demo for a more\n '\
        'detailed demonstration.')

    if __name__ == "__main__":
        main()

