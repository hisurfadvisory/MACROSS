#_sdf1 Python collab demo
#_ver 0.0
#_class 0,user,demo script,python,HiSurfAdvisory,0,dictionary

from valkyrie import w,screenResults,collab
from json import loads

def main():
    p = 'user change'
    c = 'MISA'
    w(f"\n\nThis is a simple demo. I am sending the search term \"{p}\" to {c}. If any","g")
    w("results are found, they'll print below.","g")
    w("\nNote that the GUBABA.ps1, HIKARU.py and MISA.py scripts must be present in the ","g")
    w("modules folder, and the gubaba.json file must be present in the resources folder","g")
    w("for these demonstrations to work.","g")
    w("\n\nHit ENTER to continue.","g",i=True)
    input()
    t = collab(Tool=c,Caller="CLAUDIA",Protoculture=p)
    w(f"MISA's response proto:\n","c")
    for i in t:
        r = loads(i)
        k = [R for R in r.keys()][0]
        screenResults(f"Event ID: {k}",r[k])
        #w(f"    {k}:",i=True,u=True)
        #w(f"{r[k]}","y")
    
    screenResults()
    input('\n Review the MISA, CLAUDIA, and HIKARU scripts to view the collaboration\n '\
    'process. Hit ENTER to exit this demo. Run the HIKARU demo for a more\n '\
    'detailed demonstration.')
    

if __name__ == "__main__":
    main()

