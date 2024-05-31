#_sdf1 Carbon Black EDR Integration
#_ver 2.2
#_class user,EDR,powershell,HiSurfAdvisory,1,json

<#

    GERWALK Carbon Black module for MACROSS
    HiSurfAdvisory 9NOV2022

    This script is provided mainly as an example, but if you have Carbon Black
    running in your environment, give this a spin!


    ***************!!! AUTHENTICATION !!!***************
    The opening comments in "temp_config.txt" contain a block of Base64 lines
    separated by "@@@". There is a line in there that begins with "ger";
    when it is decoded by MACROSS using

        getThis $vf19_MPOD['ger']

    it gives you a placeholder URL for a Carbon Black server. Replace this
    line with your actual server URL encoded in Base64 (do not remove the
    "ger" at the front!). See the "craftQuery" function in this script to
    see where this decoding happens.

    You will need to develop a secure method for passing in your API keys,
    this script does not contain any built-in methods for you. Look for line
    1629, "$Script:dyrl_ger_MARK = $SETYOURKEYHERE", creating/passing in your
    key here ensures it can be reused for multiple queries in one session.
    You may want to do this in another way that creates and destroys the key
    for every single query, it's up to you.

    Please do not hardcode your keys and passwords in your scripts.

    Look for the commented lines in this script beginning "MPOD ALERT!", they
    will give tips on modifying that particular section to fit your needs.



    ===================================================
    CALLING GERWALK FROM OTHER SCRIPTS:

    The main purpose of GERWALK is to enrich other scripts.

    GERWALK automatically looks for $PROTOCULTURE when called via MACROSS' collab function,
    so you need to set $PROTOCULTURE as a global variable in your script. Your script
    can also send one additional parameter, which will be used to determine which
    API gets called, OR the maximum number of responses you want to receive from
    Carbon Black.

    GERWALK sends back different things based on the API called. If you search for a 
    single event (v1/$EVENT_ID/event), you will receive a single JSON of that event
    in response. This is also the only way to view files accessed, regkey changes, and
    successful network connections to IPs and websites. (See the "craftQuery" function)
    
    If you search for a specific host's sensor info (v1/sensor?hostname=$HOST), you will
    receive a single JSON of that host sensor's details. (See the "inspectSID" function)
    
    Finally, if you perform a standard process search (v1/process?q=$QUERY; See the "findThese"
    function), you will receive a list; the  first item is the JSON response from Carbon Black,
    and the second item will be a nested list of the noisiest processes so that your script can
    filter them out from the JSON if necessary. You can modify this list way down below, it is
    called "$dyrl_ger_dontCare". 



    How to specify your search -------------------

    See the section within the "findThese" function that checks for "$CALLER",
    $dyrl_ger_alternate is the optional value you can send, with these values:

        -'sensor' -- If you set a hostname as $PROTOCULTURE, you can get all the system
            info Carbon Black has on that host. Example

            $Global:PROTOCULTURE = desktop1
            $var = collab 'GERWALK.ps1' 'MyScript' 'sensor'

        -'usrlkup' -- specifies $PROTOCULTURE is a username, and sets the time window
            to search the last 2 days. Example

            $Global:PROTOCULTURE = 'Roy'; $var = collab 'GERWALK.ps1' 'MyScript' 'usrlkup'

        -'usrloggedin' -- tells GERWALK to just find out what host the $PROTOCULTURE
            username last logged in to. Example

            $Global:PROTOCULTURE = 'Roy'; $var = collab 'GERWALK.ps1' 'MyScript' 'usrloggedin'

        -Sending a number as your optional parameter will perform a host lookup
            using $PROTOCULTURE as the hostname, and your number value as the number
            of hours back to search for that host. Example

            $Global:PROTOCULTURE = 'desktop1'; $var = collab 'GERWALK.ps1' 'MyScript' 5

        -Sending a number with the word "results" tells GERWALK to send you a maximum 
            of N events. Example to get back up to 50 events:

            $Global:PROTOCULTURE = 'Roy'; $var = collab 'GERWALK.ps1' 'MyScript' '50results'

        -'greedy' sets the above to 250 results, and increases the time window to
            9999 hours (use this sparingly!)

            $Global:PROTOCULTURE = 'Roy'; $var = collab 'GERWALK.ps1' 'MyScript' 'greedy'

        -Sending a Carbon Black event ID will query the event API for a single event. Querying 
            single events will grab you all the filenames/regkeys/netconns associated with that 
            event, which can't be viewed in normal process searches. Example

            $ID = '01234567-0123-4567-8901-123456789012'      ## Set the Event ID
            $var = collab 'GERWALK.ps1' 'MyScript' $ID        ## Call GERWALK


    (GERWALK checks for what kind of MACROSS .valtype attribute your script has, i.e. IP
    addresses or usernames or whatever, but passing these optional parameters makes
    sure there's no confusion, and also will automatically set things like time windows).


    
    
    More usage examples to call GERWALK from your script:

        $Global:PROTOCULTURE = 'Roy'
        $events = collab 'GERWALK.ps1' 'MyScript' 'usrlkup'   # GERWALK will look for events with username 'Roy'
        $events = $events | convertfrom-json                  # Convert the results to a powershell object to make it easy

        $events[0].results  # This is the Carbon Black event list
        $events[0].facets   # This is a NON-sorted list of usernames, hostnames, processes and process paths that
                            #   appear in .results
        $events[1]          # This is the list of processes you can filter out if there are too many instances
                            #  (I've found stuff like firefox.exe and svchost.exe can clutter up the screen)

   Again, GERWALK *may* insert a result count as the first item in the json. If so, you'll need to shift keys,
   i.e. instead of $events[0].results, it will be $events[1].results, etc.


   # Example viewing user activity from the above results while filtering out the noisy stuff:

        $i = 0
        $total = ($events[0].results).count
        $e = $events[0].result

        while( $i -lt $total ){
            if( $e.process_name[$i] -notIn $events[1] ){   ## Ignore the process if it is in the $events[1] list
                Write-Host $e.username[$i]
                Write-Host $e.hostname[$i]
                Write-Host $e.process_name[$i]
            }
            $i++
        }



        # This will show all of the usernames that were collected in your search
        Write-Host $events[0].facets.username_full.name 

        # This will show all of the hostnames that were collected in your search
        Write-Host $events[0].facets.hostname.name

        # This will show all of the processes that were collected in your search
        Write-Host $events[0].facets.process_name.name

        # This will show all of the executable paths that were collected in your search
        Write-Host $events[0].facets.path_full.name

        # This will show all of the parent procs that were collected in your search
        Write-Host $events[0].facets.parent_name.name



    # Example grabbing details from a single event from the .results JSON:

        $id = '01234567-0123-4567-8901-123456789012'    ## .results can contain multiple IDs, select the one you need
        $e = collab 'GERWALK.ps1' 'MyScript' $id        ## GERWALK can recognize if you send it an ID
                                                        ## It will act on this instead of $PROTOCULTURE

        $e.process.username     ## You'll still get the same data as normal queries, like usernames
        $e.process.hostname     ##    and hostnames, but more of it, for example...

        $e.process.filemod_complete  ## This gives you a list of filepaths that were accessed, with timestamps
        $e.process.netconn_complete  ## List of websites/hosts visited with timestamps
        $e.process.regmod_complete   ## List of registry keys modified with timestamps
        $e.process.cmdline           ## List of cli arguments used with each process




    ===================================================
    KNOWN ISSUES:

        BEST PRACTICE ISN'T FOLLOWED:
        I mean to get around to fixing it eventually, but the debugging and craftQuery functions
        make use of "iex" or "Invoke-Expression". It always makes my eye twitch when I see other
        people doing it, but I got lazy with this one and needed some quick curl generators. Not
        a big deal to me on my networks, but you're getting this off the internet, so...
        I just wanted to make you're aware these exist, sorry. Make sure you review everything to
        make sure there's no evil going on.

        USING "collab" TO CALL PROCESS API SEARCHES (/v1/process?q=):
        -Sometimes a useless header informing you of the max results gets attached along
        with the json object and "dontCare" list (a list of the noisiest processes that
        would dominate the screen if you displayed them). When this happens, the response array 
        will contain 3 items instead of 2, with the useless header in the [0] spot. If your 
        script is erroring with no returns after calling GERWALK, check and see if you are 
        getting this header in your response, and modify your functions to look at items 
        [1] and [2] instead of [0] and [1].

        USING THE SEARCH WIZARD:
        -There is a bug that breaks performing new searches after using the automatic 
        "Who's logged in?" search. I've set the script to exit after performing this action 
        until I can figure out what's causing the problem.

    ===================================================
    DEBUGGING/TROUBLESHOOTING:

        In the query wizard, add some random value to the first or second search boxes that you 
        know will find results, then type 'debug' into the 3rd "website" menu box and click SEARCH.
        OR, call GERWALK with the 's' option to open the non-wizard query, and enter "carbon fiber"
        as your query. Doing either of these will turn on debugging.
        
        Debugging will display your full curl commands*, converts the JSON response into a powershell 
        object, and lets you manipulate that object to view the different data that gets returned by 
        your search. If you need the raw JSON, just convert it back with 
        "$DEBUGSPACE = $DEBUGSPACE | ConvertTo-Json" for your testing.

        All of MACROSS' functions are available, so while debugging you can play with using
        "screenResults", "sheetResults", "pyCross", etc. to manipulate the $DEBUGSPACE object.

        *NOTE: When your curl command gets printed to screen, the API key will be masked,
        and attempts to call variables from command line will be restricted to prevent 
        displaying the key onscreen. If you need to force curl to be more verbose, copy the
        command that gets displayed onscreen and add the key in, and replace the "--silent"
        option with "-v".

    ===================================================


    v2.2
    Added more detail to the comments and notes


#>




## This is the optional parameter that can be sent from MACROSS's collab
## function. It is currently used to either change the API requested (default
## is 'process', but can also use 'sensor' or 'binary'), specify an event ID
## to collect, or to change the default number of results to collect
param(
    [string]$Script:dyrl_ger_alternate
)




function splashPage(){
    cls
    $i = 'ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgciAgICAgICAgI
    CAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICDGkiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICA
    gICAgICAgICAgICAgICAgICAgICDilZPilabilaYsICAgICAgICDilZIgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgzrQg4paT4paRI
    iwgICws4pWTLCzOkyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgLlUiauKWiOKWjOKVn+KWhOKWiOKWjCLigb/ilad0xpJkPSDDpyJe4pW
    QfiwgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    zDp+KWk+KWk+KWk+KWk+KWgOKWgOKWgOKWgOKWiOKWiOKWiF3Ok+KWkOKBvyAgICLijILiloTigb8iI
    CAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgLGfiloTi
    loTiloDiloDilojiloDiloAwUeKWhOKWhOKWhOKWiE0i4paA4paAXmAsLuKMkMKs4pWYICAiLSAgICA
    gICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICzilZDDkeKWhOKWgOKWgO
    KWkOKWiOKWk+KWiGDOpl3ijJDiloDilojiloggdzbilahq4paE4pWZIiAgICBdLOKVkywgLOKVkCIiX
    l7ilZDilZDilZDCrH4uLiwsLCAgICAgICAgCiAgICAgICAgICAgICAgICAgICAuw4fiiJ7ilZ3ilZzD
    heKWkuKVouKWk+KWiOKWgOKUlCAgwr/iloTiloTiloQ7IOKVmeKWgOKWgOKWgOKWgOKWgOKWgOKWiFw
    g4oyQ4paA4paA4paA4paA4paA4paA4paA4paA4paA4paA4paAUFDiloDiloDiloDiloDilajilpPilp
    PDkeKInuKInsOE4oieNMOF4pWdICAKICAgICAgICAgICAgICAgLOKWhOKWiOKWiOKWiOKWiOKWhOKWh
    OKWiOKWgOKWgCnDsSLiloTiloTilogq4pSU4oG/4paA4paA4paA4paA4paA4paIIiAs4paE4oyQ4paA
    IuKWiOKWkuKUlH7iiJp+4pWlw6p+fn4t4pSA4pWQ4pWQ4pWQ4pWQ4pSA4pSA4pWQ4pWQ4oG/Xl5eXl4
    iIiIgIAogICAgICAgICAgICzilZBg4paA4paA4paA4paI4paA4paA4paA4paAICAs4paE4paEfuKWhO
    KWk+KVoeKWgOKWiE3ilaXilZPDpiVNU+KWhCwswqzijJDilZBA4paAWyAgIEx34pWnICAgICAgLCAgI
    CAgICAgICAgICAgICAgIAogICAgICAgLOKMkCIgICAgICBg4paAXOKWhOKWiOKWjOKWgOKWgOKVk+KM
    kCriloA+cOKVpyJgIMKyXSAgTCDilojilojiloDilozilZAi4pWZd2Digb/Dh8KsXUjiloAg4pSA4pW
    S4paI4paI4paMICAgICAgICAgICAgICAgICAgIAogICAs4oyQIiAgICAgICAgIOKVkCLilLQsbOKWgC
    rijKDilJQgICAgICAgICBW4paE4paIICBd4pWTL+KWiOKMkOKWkCAgIMK64paI4paI4paAeinDpyzCv
    OKVoz3ilpDilojiloQgICAgICAgICAgICAgICAgICAgCiBDIiAgICAgLC4u4oyQ4pWp4pWnwqrilZAi
    YCAgICAgICAgICAgICAgICAi4paA4paIKuKVllwgLV0od+KWhOKWgMKq4paI4paEYCDilojiloAiLMK
    yIOKWiOKWjOKWgOKWjCAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgIMOGLOKVk2DiloDCv+KImuKWiOKWjC/iloAgICAgIMOFICDilIzilZsg4paE4paIICAgI
    CAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIMK/YCDGkuKV
    mOKBv+KVkOKWiOKWiOKWiOKWiOKUmCAgL+KVmyAo4pWT4paE4paE4paE4paE4paE4paIICDilJggICA
    gICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgwqIgIMOc4paE4p
    aE4paE4paI4paA4paA4paAYCAg4paQ4paMIOKWhOKWiOKWgCAgIOKUlOKWiOKMkCDilZIgICAgICAgI
    CAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg4pWZ4pSUwqwgICAg
    IOKMkCAg4pWS4paAIOKWhOKWgOKBvyzCvyAgIF3iloTiloTilojilojilojilojilojilojilojiloj
    ilojilojilojilojilojilojilojilojiloDiloAgICAKICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICDCv+KUlCLilZXiloAgKsKsw58i4oG/SCAg4paE4paI4paI4paI4paI4paI4
    paI4paI4paI4paI4paI4paI4paI4paA4paA4paALSAgICAgICAgCiAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICDilZsgIC/ilpBb4paE4paE4pWT4paA4paI4paE4paI4paI4paI4pa
    I4paI4paI4paI4paI4paI4paI4paI4paI4paALSAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAgL+KUlOKBv1nDhMOnLOKWhOKWiOKWiOKWhOKWhOKWiOKWiOKWi
    OKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWgOKWgGAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgYCAgKGAgIOKWiOKWiOKWiOKWiOKWiOKWiOKWgOKWgOKWgOK
    WgOKWgOKUlGAiICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICDOpn4sz4bilKziloTiloTiloDiloDiloDiloAtICAgICAgICAgICAgICAgICAgICAgI
    CAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgYOKMkCAg'

    $b = 'ICAgICAgICDilojilojilojilojilojilojilZcg4paI4paI4paI4paI4paI4paI4paI4pWX4
    paI4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKVlyAgICDilojilojilZcg4paI4paI4paI4paI4paI
    4pWXIOKWiOKWiOKVlyAgICAg4paI4paI4pWXICDilojilojilZcKICAgICAgIOKWiOKWiOKVlOKVkOK
    VkOKVkOKVkOKVnSDilojilojilZTilZDilZDilZDilZDilZ3ilojilojilZTilZDilZDilojilojilZ
    filojilojilZEgICAg4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4paI4paI4pWRICAgI
    CDilojilojilZEg4paI4paI4pWU4pWdCiAgICAgICDilojilojilZEgIOKWiOKWiOKWiOKVl+KWiOKW
    iOKWiOKWiOKWiOKVlyAg4paI4paI4paI4paI4paI4paI4pWU4pWd4paI4paI4pWRIOKWiOKVlyDiloj
    ilojilZHilojilojilojilojilojilojilojilZHilojilojilZEgICAgIOKWiOKWiOKWiOKWiOKWiO
    KVlOKVnQogICAgICAg4paI4paI4pWRICAg4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4pWdICDilojil
    ojilZTilZDilZDilojilojilZfilojilojilZHilojilojilojilZfilojilojilZHilojilojilZTi
    lZDilZDilojilojilZHilojilojilZEgICAgIOKWiOKWiOKVlOKVkOKWiOKWiOKVlwogICAgICAg4pW
    a4paI4paI4paI4paI4paI4paI4pWU4pWd4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWRIC
    DilojilojilZHilZrilojilojilojilZTilojilojilojilZTilZ3ilojilojilZEgIOKWiOKWiOKVk
    eKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKVkSAg4paI4paI4pWXCiAgICAgICAg4pWa4pWQ
    4pWQ4pWQ4pWQ4pWQ4pWdIOKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pW
    dIOKVmuKVkOKVkOKVneKVmuKVkOKVkOKVnSDilZrilZDilZ0gIOKVmuKVkOKVneKVmuKVkOKVkOKVkO
    KVkOKVkOKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWd'
    if( $CALLER ){
        getThis $b
    }
    else{
        getThis $i
    }
    ''
    Write-Host -f YELLOW $vf19_READ
    Write-Host -f CYAN   '        =============================================================
                    Automated Carbon Black Response queries
    '
}




function showHelp($1){
    if($1 -eq 1){
        Write-Host -f YELLOW "
    Author: $($vf19_LATTS['GERWALK'].author)
    version $($vf19_LATTS['GERWALK'].ver)
    This script's primary purpose is to perform Carbon Black lookups
    based on values passed to it from other MACROSS tools, but it can
    also perform a basic CB query for you. This is quicker than logging
    into the web UI, but your results will be more limited here.

    If you want to run manual searches in GERWALK, use the query
    wizard to enter up to 3 search terms. If you simply search for
    a hostname in the wizard, the 'Who's logged in?' button
    will give you the name of whoever was loggged into that host
    during the time window you specify.

    Call this script with the 's' option (Example, '3s' from the
    main menu) to launch this script WITHOUT the query wizard and
    write your own Carbon Black queries.


    EXAMPLE MACROSS INVESTIGATIONS:
        -After performing an IP lookup in another script, you can
            pass IP or hostname info to GERWALK for extra details on
            who is logged in, running processes, etc.
        -After performing a user lookup with MYLENE, you can pass
            the username to GERWALK to review the latest hosts they
            were logged into, websites visited, etc.
        -After performing file searches in KONIG, you can pass
            filenames to GERWALK to find any info CB may have on them,
            such as which hosts executed/loaded them, which users have
            accessed them, etc.

    Hit ENTER to continue.
    "

        Read-Host
        Exit
    }
    elseif($1 -eq 2){

        ## This help page is for manually entering CB queries instead of using the wizard

        splashPage
        Write-Host "
                    BASIC CARBON BLACK KEYWORDS AND SYNTAX:

        -If your search value includes spaces, enclose the value in quotes
        -Use a '-' to exclude values from your results
        -You have to specify 'OR' between your keywords if you are searching
            more than one value of the same type
        
        SEARCHWORD        DESCRIPTION
        ==========        ============
        ipaddr            self-explanatory
        hostname          self-explanatory
        filemod           files being accessed/modified*
        cmdline           background commands when process a is launched
        username          self-explanatory
        domain            URLs*
        netconn_count     number of network connections*
        process_name      self-explanatory
        parent_name       parent processes
        childproc_name    child processes
        start             set a time window to search


        *These values don't immediately appear in your results, but you can drill
        into individual events to see them.


        Example queries:
        "
        Write-Host -f YELLOW '
        username:mario  OR  username:luigi'
        Write-Host '          --search for one of the super mario brothers'
        Write-Host -f YELLOW '
        childproc_name:acrobat.exe  netconn_count:3'
        Write-Host '          --search for acrobat being spawned and making exactly 3 network connections'
        Write-Host -f YELLOW '
        process_name:firefox.exe  -domain:*.com'
        Write-Host '          --search for web browsing to sites not ending in ".com"'
        Write-Host -f YELLOW '
        cmdline:*etc/passwd*  -username:root'
        Write-Host '          --search for users enumerating local accounts'
        Write-Host -f YELLOW '
        start:-168h'
        Write-Host '          --search 168 hours back (1 week)'
        Write-Host -f YELLOW '
        start:[2022-12-01T16:05:00  TO  2022-12-01T16:15:00]'
        Write-Host '          --search a specific 15 minute window (time is GMT)
        '

        Read-Host '        Hit ENTER to continue'
        splashPage
    }

}


if( $HELP ){
    cls
    showHelp 1
}



## $1 is the sensor ID passed in by user; inspectSID then forwards the params
## required by the craftQuery function to get data from Carbon Black's sensor API.
## To search by hostname instead of SID, call this function with an empty 1st param
## and the hostname as second param
function inspectSID($1,$2){
    if($2){
        if($CALLER -and $vf19_LATTS[$CALLER].valtype -Match ' IP(s| Addresses)?.*'){
            craftQuery '' "v1/sensor?ip=$2" $dyrl_ger_MARK '1'
        }
        else{
            craftQuery '' "v1/sensor?hostname=$2" $dyrl_ger_MARK '1'
        }
    }
    else{
        craftQuery $1 'v1/sensor/' $dyrl_ger_MARK ''
    }
}


## Hash a file and see if CB has info on it
##  $1 is the filepath, $2 is the hashing method
##  (MD5 or SHA256)
function inspectBin($1,$2){
    $api = 'v1/binary?facet=true'
    

    
    if( $2 -ne $null ){
        $gh = $(CertUtil -hashfile $1 $2) -split("\n")
        $gh = $gh[1]  ## cut out the useless garbage windows gives back after hashing
        $file = $2 + ":$gh"
    }
    else{
        $file = 'observed_filename:*' + [string]$1
        #$file = $1
    }

    $Script:dyrl_ger_file = $file
    
    $Script:dyrl_ger_BINARYQ = $true
    findThese $api $file

}


########################
##  Build additional queries based on these values
##  $2 specifies which API was searched;
##  $1 = sensor api
##  optional $3 should specify which facet to return from the
##  first "if" statement
function reviewResults($1,$2,$3){
    if( $2 -eq 'process' ){
        $r = $dyrl_ger_WORKSPACE1.facets
        Return $r.$3.name                  ## This is an array value!
    }
    elseif( $2 -eq 'binary' ){
        $r = $dyrl_ger_WORKSPACE[$1]
        $id = $r.id
        $cn = $r.computer_name
        $si = $r.computer_sid
        $na = $r.network_adapters
        $sc = $r.supports_cblr
        $lc = $r.last_checkin_time
        $sh = $r.sensor_health_message
        $st = $r.status
        $os = $r.os_environment_display_string
        $pm = $r.physical_memory_size
        $rt = $r.registration_time
        $un = $r.uninstalled

        screenResultsAlt "$cn" 'IP' $na
        screenResultsAlt 'next' 'WIN SID' $si
        screenResultsAlt 'next' 'CBLIVE' $sc
        screenResultsAlt 'next' 'LAST SEEN' "$lc (UTC)"
        screenResultsAlt 'next' 'HEALTH' $sh
        screenResultsAlt 'next' 'STATUS' $st
        screenResultsAlt 'next' 'OS' $os
        screenResultsAlt 'next' 'MEM SIZE' $pm
        screenResultsAlt 'next' 'REGISTERED' $rt
        screenResultsAlt 'next' 'UNINSTALLED' $un
        screenResultsAlt 'endr' 

        w '


        '
    }

}



<# 
 Carbon black sucks at localizing timestamps --
 $1 is the time to adjust; it will automatically modify CB's default format,
 but needs to specifically be "MM/dd hh:mm" when analyst is entering a time
 to search from

 $2 must be set to 0 for adjusting Carbon Black's result time (display only)
    OR
 $2 must be set to 1 for adjusting analysts's search windows
#>
function adjustTime($1,$2){
    $clock = 0..23
    $calendar = @{
    '01'=31
    '02'=28
    '03'=31
    '04'=30
    '05'=31
    '06'=30
    '07'=31
    '08'=31
    '09'=30
    '10'=31
    '11'=30
    '12'=31
    }
    # $1 CB time format > 2022-11-16T13:53:42.764Z
    # do subtractions to account for retarded daylight savings
    $dschk = (Get-Date).IsDaylightSavingTime()
    $local = Get-Date -Format 'YYYY-MM-ddThh:mm:ss' # Preformat for CB queries
    $year = Get-Date -Format YYYY
    
    if($dschk){
        $offset = 5
    }
    else{
        $offset = 6
    }

    
    ## If time is less or greater than the 24hr clock, make adjustments to the date
    if($2 -eq 0){
        $zh = $1 -replace "^.+T" -replace ":.+$"
        $zmins = $1 -replace "^.+T[0-9]{2}:" -replace ":[0-9]{2}.+$"
        $zd = $1 -replace "T.+$" -replace "^.+-"
        $zm = $1 -replace "^[0-9]{4}-" -replace "-.+$"
        $hour_diff = [int]$zh - $offset
        if($hour_diff -lt 0){
            $hour_diff = 24 - [math]::abs($hour_diff)
            $day_diff = [int]$zd - 1
            if( $day_diff -lt 0 ){
                $m = [int]$zm - 1
                if($m -lt 0){
                    $m = 12
                }
                $day_diff = [int]$calendar[$m] - [int]$day_diff
            }
        }
        else{
            $m = $zm
            $day_diff = $zd
        }

        $day_diff = $m + '/' + $day_diff
        $Script:dyrl_ger_LOCAL = $day_diff + ' ' + $hour_diff + ':' + $zmins

    }
    elseif($2 -eq 1){
        $lh = $1 -replace "^.+ " -replace ":.+$"
        $ld = $1 -replace "^../" -replace " .+$"
        $lm = $1 -replace "/.+$"
        $hour_diff = $lh + $offset
        if($hour_diff -gt 23){
            $day_max = $calendar[$lm]
            $hour_diff = $hour_diff - 24
            $day_diff = $ld + 1
            if($day_diff -gt $day_max){
                $m = [int]$lm + 1
                if($m -gt 12){
                    $m = 01
                    $day_diff = 01
                }
                $day_diff = '-' + $m + '-' + $day_diff
            }
        }
        else{
            $day_diff = $ld
        }



        # time format for queries windows = start:[2022-11-12T23:01:12 TO 2022-11-15T23:01:12]
        # ^^ formatted:  start%3A%5B2022-11-12T23%3A01%3A12%20TO%202022-11-15T23%3A01%3A12%5D
        # time format for same-day searches = start:-14m

        $Script:tw = 'start:[' + $year + $day_diff + 'T' + $hour_diff + ':00:00 TO ' + $local + ']'

    }
    
}




function findThese($1,$2){

    <#
        IF "findThese" IS CALLED WHEN "$CALLER" IS SET:
        $1 is the $CALLER value, $2 is the $PROTOCULTURE value to be queried
        $dyrl_ger_alternate is the optional param any script can send. Currently:

            'usrlkup' sets time window to 12 hours
            'usrloggedin' will only return usernames (if any) for the given hostname
            'hlkup' lets scripts with multiple attributes specify a hostname search for the
                $PROTOCULTURE value
            '[0-9]results' sets the number of events to fetch
            '[0-9]' sets the time window to the past x amount of days

        IF "findThese" IS CALLED AND $CALLER IS NULL:
        $1 is the API to query, $2 is the value to be queried, OR
        leave $1 and $2 empty to load the wizard menu for users to
        enter their own queries.
    
        -------------------------------------------------------------------------------
    
        The default will grab all facets, which can be parsed separate from the results, for example:

            $dyrl_ger_WORKSPACE.facets.process_name

        will list out all processes contained in your results. If you want to omit this, change
        "facet.field=true" to "facet.field=false" in the curl request. This won't affect anything
        within the "$dyrl_ger_WORKSPACE.results" object.

        EXISTING FACET FIELDS:
        -process_md5: the top unique md5s for the processes matching the search
        -hostname: the top unique hostnames matching the search
        -group: the top unique host groups for hosts matching this search
        -path_full: the top unique paths for the processes matching this search
        -parent_name: the top unique parent process names for the processes matching this search
        -process_name: the top unique process names for the processes matching this search
        -host_type: the distribution of host types matching this search: one of workstation,
            server, domain_controller
        -hour_of_day: the distribution of process start times by hour of day in computer local time
        -day_of_week: the distribution of process start times by day of week in computer local time
        -start: the distribution of process start times by day for the last 30 days
        -username_full: the top unique usernames associated with the event
    #>

    $defh = '-168h'                      ## Default time window is 1 week; can be changed based on other inputs below
    $qbuild = '&q='                      ## Query opener
    $qsection = 'v1/process?facet=true'  ## Default API call
    $res = '&rows=10'
    $eventID = [regex]"^\w+\-\w+\-\w+\-\w+\-\w+$"
    

    ## This string will only query non-system accounts if user chooses:
    $onlyusers = '-(username:*SERVICE OR username:root OR username:*SYSTEM OR username:svc* OR username:Window*) '
    $Script:no = [regex]".*(_MARK|get-variable|gv|::).*"
    if($CALLER){

        ## Script sent 'usrlkup' as the optional param
        ## The calling script wants to view user activity (set to 2 days)
        if($dyrl_ger_alternate -eq 'usrlkup'){  
            $defh = '-120h'
            $res = '&rows=80'           ## Send back enough events to account for noisy processes the user may want to filter out
        }

        ## Script sent 'usrloggedin' as the optional param
        ## The calling script wants to know who is/was logged into a host (8 hours)
        elseif($dyrl_ger_alternate -eq 'usrloggedin'){
            $defh = '-8h'
        }

        ## Script sent a digit as the optional param
        ## This checks options for remote hosts connecting TO the $PROTOCULTURE host (custom date)
        elseif($dyrl_ger_alternate -Match "^[0-9]+$"){
            $defh = '-' + [string]$dyrl_ger_alternate
            $skipsys = $true
            $skipres = $true
            $res = '&rows=20'
        }

        ## Script sent 'greedy' as the optional param
        ## This option will return the MOST results to calling scripts; it does NOT
        ## set a time window, so searches ALL events and collects up to 250!
        ## You can increase this if you want to, but coordinate with your Carbon Black
        ## admins before you choke their servers.
        elseif($dyrl_ger_alternate -eq 'greedy'){
            $skipres = $true
            $res = '&rows=250'
        }

        ## Script sent '<digit>results' as the optional param
        ## This lets other scripts set the amount of events to fetch
        ## Have your script send your custom value like "300results" or "125results".
        elseif($dyrl_ger_alternate -Match "^[0-9]+results$"){
            $skipsys = $true
            $skipres = $true
            $cr = $dyrl_ger_alternate -replace "results"
            $res = "&rows=$cr"
        }

        ## Script sent an event ID as the optional param
        ## Searching for a specific event ID is the ONLY way to capture filenames,
        ##   registry keys, netconns, modloads. This can be time consuming if you try
        ##   to query hundreds of events one after another. Save it for when you know
        ##   exactly which event you want to drill into
        elseif($dyrl_ger_alternate -Match $eventID){
            craftQuery "v1/$dyrl_ger_alternate/event"
            Return $dyrl_ger_SINGLEEVENT
        }

        ## The user typed 'file' into the MACROSS main menu; is searching for binary/hash info
        elseif($CALLER -eq 'MACROSS'){
            $qbuild = $qbuild + $2
            $qsection = $1
        }

        ## No optional parameter was sent by the calling script
        else{
            function convert($1){
                $d = (Get-Date).AddDays(-$1)
                [string]$d = Get-Date $d -Format 'yyyy-MM-dd'
                Return $d
            }
            
            $instructions = '
            -Type a new number of days back to search
                (example "14" to search everything in
                the past 2 weeks)
            -Type a new number with a "d" to only search
                that 24 hour period (example "3d" to view
                 only results from 3 days ago)
            -Hit ENTER to keep the default window
            -Type "q" to quit'
            <#Write-Host -f GREEN '
            The default search window is 1 week (in ZULU time).
                -Type a new number of days back to search
                   (example "14" to search everything in
                   the past 2 weeks)
                -Type a new number with a "d" to only search
                   that 24 hour period (example "3d" to view
                 only results from 3 days ago)
                -Hit ENTER to keep the default window
                -Type "q" to quit'
            #>

            screenResults 'The default search window is 1 week (in ZULU time)' $instructions
            screenResults 'endr'
            Write-Host -f GREEN '
            > ' -NoNewline; $Z = Read-Host
            

            if($Z -eq 'q'){
                Remove-Variable -Force dyrl_ger_* -Scope Global
                Exit
            }
            elseif($Z -Like "*d"){
                $Z = $Z -replace "d"
                [string]$defh = convert $Z
                $defh = "$dt last_update:$dt "
            }
            elseif($Z -Match "^[0-9]$"){
                [string]$defh = convert $Z
            }

            

        }
    }

    ## Tools that call with 'greedy' param don't want a time window
    if($dyrl_ger_alternate -eq 'greedy'){
        $startt = ''
    }
    else{
        $startt = "start:$defh "
    }

    if($2){
        if( $1 -Match '/v1/' ){         ## Indicates an API change
            $qsection = $1              ## Use this API instead of default
            $qbuild = $qbuild + $2      ## Second param should be the value being queried by the new API
        }
        else{
            
            $valtype = $vf19_LATTS[$1].valtype  ## Build query based on $CALLER's eval type if no optional parameters were sent

            ## Build query using $PROTOCULTURE and params from other tools
            ## The $dyrl_ger_alternate value takes precedence
            $Z = $null
            if($dyrl_ger_alternate -eq 'hlkup'){
                $hnsearch = $true
            }
            elseif($dyrl_ger_alternate -eq 'usrlkup'){
                $usrsearch = $true
            }
            elseif($dyrl_ger_alternate -eq 'usrloggedin'){
                $qbuild = $qbuild + $startt + "hostname:$2 " + $onlyusers
                $skipres = $true
                $skipsys = $true
                $res = '&rows=1'
                $Script:dyrl_ger_RES = 1
                $Script:dyrl_ger_WOF = $true
                $Script:dyrl_ger_woflist = @()
            }
            elseif($valtype -Like "*hostname*" -or $valtype -Like "*IPs*"){   ## Check if value is IP or hostname
                $hnsearch = $true
            }
            elseif($valtype -Like "*username*"){
                $usrsearch = $true
            }


            ## Host queries
            if($hnsearch){
                if($2 -Match "^[0-9]+\."){
                    $qbuild = $qbuild + $startt + "ipaddr:$2 " + $onlyusers
                }
                elseif($2 -Match "^[a-z]"){
                    $qbuild = $qbuild + $startt + "hostname:$2 " + $onlyusers
                    $skipsys = $true
                    if( ! $skipres ){
                        $skipres = $true
                        $Script:dyrl_ger_RES = 10
                    }
                }
            }
            ## Username queries
            elseif($usrsearch){
                $skipsys = $true
                $skipres = $true
                $res = '&rows=20'
                $qbuild = $qbuild + $startt + "username:$2 "
            }
            ## Check if value is a filename
            elseif($valtype -Like "*filename*"){
                
                ## Try to give back enough results; modify as necessary
                $Script:dyrl_ger_RES = 75
                

                ## Try not to blow up Carbon Black; the 'greedy' search is already huge, go ahead and
                ## omit the command line searches for filenames
                if($dyrl_ger_alternate -ne 'greedy'){
                    $qbuild = $qbuild + "(cmdline:*$2* OR fileless_scriptload_cmdline:*$2*) OR filemod:$2 "
                }
                else{
                    $qbuild = $qbuild + "filemod:$2 "
                }

                $skipsys = $true
                $skipres = $true
            }
            
            
            if( ! $skipsys ){
                Write-Host -f GREEN '        Omit SYSTEM & local service accounts?  ' -NoNewline;
                $Z = Read-Host
                if($Z -Match "^y"){
                    $skipsys = $true
                    $qbuild = $qbuild + $onlyusers
                }
            }
            if( ! $skipres ){
                ''
                Write-Host -f GREEN '            Display how many results? (1-50)  ' -NoNewline;
                $Z = Read-Host
                if($Z -notMatch "^[0-9]+$"){
                    $Script:dyrl_ger_RES = 10
                }
                else{
                    $Script:dyrl_ger_RES = $Z
                    $res ="&rows=$Z"
                }
                $skipres = $true
            }

            $f_val1 = $true
            $Z = $null

        }
    }
    else{

        ## Use query wizard by default; skip wizard if user launched GERWALK with the 's' option (sets $vf19_OPT1 to 'true')

        if( ! $vf19_OPT1){  
            $Script:dyrl_ger_DEBUG = $false
            $f_eicon = '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'
            $f_dicon = [Convert]::FromBase64String($f_eicon)
            $f_menulist = @('user','file','host','ip','process','website','email','attachment','cmdline')


            ## MPOD ALERT! This variable will tell Carbon Black to ignore system/root accounts. Add more name
            ## patterns here as necessary.
            $f_omits = ' -(username:*SYSTEM OR username:*SERVICE OR username:root OR username:Window*)'

            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.Application]::EnableVisualStyles()

            $f_form = New-Object System.Windows.Forms.Form
            $f_icon = New-Object Windows.Forms.PictureBox

            #$f_cbNAVY = Color.FromRgb(0,51,102)

            ## Main form configs
            $f_form.Text = "MACROSS -- GERWALK"
            $f_form.Font = [System.Drawing.Font]::new("Tahoma", 10.5)
            $f_form.ForeColor = 'WHITE'
            $f_form.Size = New-Object System.Drawing.Size(600, 550)
            $f_form.BackColor = 'NAVY'
            $f_form.StartPosition = "CenterScreen"

            ## Add the CB icon
            $f_icon.Width =  100
            $f_icon.Height =  100 
            $f_icon.Location = New-Object System.Drawing.Size(500,385)
            $f_icon.Image = $f_dicon
            $f_form.Controls.Add($f_icon)

            ## Instructions
            $f_instr1 = New-Object System.Windows.Forms.Label
            $f_instr1.Location = New-Object System.Drawing.Point(10, 5)
            $f_instr1.Size = New-Object System.Drawing.Size(565, 28)
            $f_instr1.Font = [System.Drawing.Font]::new("Tahoma", 8)
            $f_instr1.Text = "NOTE: this search is much more basic than logging into Carbon Black. You can also cancel now and launch GERWALK again with the 's' option to enter more detailed queries."
            $f_form.Controls.Add($f_instr1)

            $f_instr2 = New-Object System.Windows.Forms.Label
            $f_instr2.Location = New-Object System.Drawing.Point(10, 55)
            $f_instr2.Size = New-Object System.Drawing.Size(565, 50)
            $f_instr2.ForeColor = 'YELLOW'
            $f_instr2.Text = "Enter your search value, then select a key (username, web, etc). Checkmark the OR and EXCLUDE boxes as necessary; the 2nd and 3rd search boxes are optional."
            $f_form.Controls.Add($f_instr2)

    

            ## Search box 1
            $f_te1 = New-Object System.Windows.Forms.TextBox
            $f_te1.Location = New-Object System.Drawing.Point(10, 105)
            $f_te1.Size = New-Object System.Drawing.Size(395, 20)
            $f_form.Controls.Add($f_te1)

            $f_key1 = New-Object System.Windows.Forms.ComboBox
            $f_key1.Location = New-Object System.Drawing.Size(10, 130)
            $f_key1.Size = New-Object System.Drawing.Size(130, 25)
            $f_form.Controls.Add($f_key1)
            $f_menulist | %{$f_key1.Items.Add($_)} | Out-Null
            $f_key1.SelectedItem = $f_key1.Items[3]

            $f_wof = New-Object System.Windows.Forms.Button
            $f_wof.Location = New-Object System.Drawing.Size(200, 130)
            $f_wof.Size = New-Object System.Drawing.Size(250, 30)
            $f_wof.Text = "Who's logged in?"
            $f_wof.Enabled = $false
            $f_wof.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $f_form.Controls.Add($f_wof)
            $f_form.AcceptButton = $f_wof

            $f_neg1 = New-Object System.Windows.Forms.Checkbox
            $f_neg1.Location = New-Object System.Drawing.Size(430, 105)
            $f_neg1.Size = New-Object System.Drawing.Size(99, 25)
            $f_neg1.Checked = $false
            $f_neg1.ForeColor = 'CYAN'
            $f_neg1.Text = "EXCLUDE"
            $f_form.Controls.Add($f_neg1)

            ## Search box 2
            $f_te2 = New-Object System.Windows.Forms.TextBox
            $f_te2.Location = New-Object System.Drawing.Point(10, 175)
            $f_te2.Size = New-Object System.Drawing.Size(395, 20)
            $f_form.Controls.Add($f_te2)

            $f_key2 = New-Object System.Windows.Forms.ComboBox
            $f_key2.Location = New-Object System.Drawing.Size(10, 195)
            $f_key2.Size = New-Object System.Drawing.Size(130, 25)
            $f_form.Controls.Add($f_key2)
            $f_menulist | %{$f_key2.Items.Add($_)} | Out-Null

            $f_or2 = New-Object System.Windows.Forms.Checkbox
            $f_or2.Location = New-Object System.Drawing.Size(415, 175)
            $f_or2.Size = New-Object System.Drawing.Size(46, 25)
            $f_or2.Checked = $false
            $f_or2.ForeColor = 'CYAN'
            $f_or2.Text = "OR"
            $f_form.Controls.Add($f_or2)

            $f_neg2 = New-Object System.Windows.Forms.Checkbox
            $f_neg2.Location = New-Object System.Drawing.Size(465, 175)
            $f_neg2.Size = New-Object System.Drawing.Size(99, 25)
            $f_neg2.Checked = $false
            $f_neg2.ForeColor = 'CYAN'
            $f_neg2.Text = "EXCLUDE"
            $f_form.Controls.Add($f_neg2)

            ## Search box 3
            $f_te3 = New-Object System.Windows.Forms.TextBox
            $f_te3.Location = New-Object System.Drawing.Point(10, 240)
            $f_te3.Size = New-Object System.Drawing.Size(395, 20)
            $f_form.Controls.Add($f_te3)

            $f_key3 = New-Object System.Windows.Forms.ComboBox
            $f_key3.Location = New-Object System.Drawing.Size(10, 265)
            $f_key3.Size = New-Object System.Drawing.Size(130, 25)
            $f_form.Controls.Add($f_key3)
            $f_menulist | %{$f_key3.Items.Add($_)} | Out-Null
    
            $f_or3 = New-Object System.Windows.Forms.Checkbox
            $f_or3.Location = New-Object System.Drawing.Size(415, 240)
            $f_or3.Size = New-Object System.Drawing.Size(46, 25)
            $f_or3.Checked = $false
            $f_or3.ForeColor = 'CYAN'
            $f_or3.Text = "OR"
            $f_form.Controls.Add($f_or3)

            $f_neg3 = New-Object System.Windows.Forms.Checkbox
            $f_neg3.Location = New-Object System.Drawing.Size(465, 240)
            $f_neg3.Size = New-Object System.Drawing.Size(99, 25)
            $f_neg3.Checked = $false
            $f_neg3.ForeColor = 'CYAN'
            $f_neg3.Text = "EXCLUDE"
            $f_form.Controls.Add($f_neg3)
    
    
    
            ## Set a basic time window & optional exclude computer accounts
            $f_instr3 = New-Object System.Windows.Forms.Label
            $f_instr3.Location = New-Object System.Drawing.Point(10, 305)
            $f_instr3.Size = New-Object System.Drawing.Size(275, 30)
            $f_instr3.Font = [System.Drawing.Font]::new("Tahoma", 9)
            $f_instr3.ForeColor = 'YELLOW'
            $f_instr3.Text = "Default search window is 1 week. Modify as necessary."
            $f_form.Controls.Add($f_instr3)

            $f_instr3a = New-Object System.Windows.Forms.Label
            $f_instr3a.Location = New-Object System.Drawing.Point(16, 342)
            $f_instr3a.Size = New-Object System.Drawing.Size(80, 15)
            $f_instr3a.Font = [System.Drawing.Font]::new("Tahoma", 10)
            $f_instr3a.ForeColor = 'CYAN'
            $f_instr3a.Text = "START HRS"
            $f_form.Controls.Add($f_instr3a)

            $f_instr3b = New-Object System.Windows.Forms.Label
            $f_instr3b.Location = New-Object System.Drawing.Point(148, 342)
            $f_instr3b.Size = New-Object System.Drawing.Size(80, 15)
            $f_instr3b.Font = [System.Drawing.Font]::new("Tahoma", 10)
            $f_instr3b.ForeColor = 'CYAN'
            $f_instr3b.Text = "END HRS"
            $f_form.Controls.Add($f_instr3b)

            $f_te4a = New-Object System.Windows.Forms.DateTimePicker
            $f_te4a.Location = New-Object System.Drawing.Point(20, 361)
            $f_te4a.Size = New-Object System.Drawing.Size(100, 20)
            $f_te4a.Format = [windows.forms.datetimepickerFormat]::custom
            $f_te4a.CustomFormat = "yyyy-MM-dd"
            $f_te4a.Font = [System.Drawing.Font]::new("Tahoma", 10)
            $f_te4a.Text = $(Get-Date).AddDays(-7)
            $f_form.Controls.Add($f_te4a)

            $f_te4b = New-Object System.Windows.Forms.DateTimePicker
            $f_te4b.Location = New-Object System.Drawing.Point(20, 385)
            $f_te4b.Size = New-Object System.Drawing.Size(100, 20)
            $f_te4b.Format = [windows.forms.datetimepickerFormat]::custom
            $f_te4b.CustomFormat = "HH:mm"
            $f_te4b.Font = [System.Drawing.Font]::new("Tahoma", 10)
            $f_te4b.ShowUpDown = $true
            $f_te4b.Text = $(Get-Date).AddDays(-7)
            $f_form.Controls.Add($f_te4b)

            $f_te5a = New-Object System.Windows.Forms.DateTimePicker
            $f_te5a.Location = New-Object System.Drawing.Point(148, 361)
            $f_te5a.Size = New-Object System.Drawing.Size(100, 20)
            $f_te5a.Format = [windows.forms.datetimepickerFormat]::custom
            $f_te5a.CustomFormat = "yyyy-MM-dd"
            $f_te5a.Font = [System.Drawing.Font]::new("Tahoma", 10)
            $f_te5a.Text = $(Get-Date)
            $f_form.Controls.Add($f_te5a)

            $f_te5b = New-Object System.Windows.Forms.DateTimePicker
            $f_te5b.Location = New-Object System.Drawing.Point(148, 385)
            $f_te5b.Size = New-Object System.Drawing.Size(100, 20)
            $f_te5b.Format = [windows.forms.datetimepickerFormat]::custom
            $f_te5b.CustomFormat = "HH:mm"
            $f_te5b.Font = [System.Drawing.Font]::new("Tahoma", 10)
            $f_te5b.Text = $(Get-Date)
            $f_te5b.ShowUpDown = $true
            $f_form.Controls.Add($f_te5b)

            <#$f_te5 = New-Object System.Windows.Forms.TextBox
            $f_te5.Location = New-Object System.Drawing.Point(135, 412)
            $f_te5.Size = New-Object System.Drawing.Size(65, 20)
            $f_form.Controls.Add($f_te5)#>

            $f_instr4 = New-Object System.Windows.Forms.Label
            $f_instr4.Location = New-Object System.Drawing.Point(345, 305)
            $f_instr4.Size = New-Object System.Drawing.Size(220, 50)
            $f_instr4.Font = [System.Drawing.Font]::new("Tahoma", 10)
            $f_instr4.ForeColor = 'YELLOW'
            $f_instr4.Text = "Checkmark to omit System and Service accounts:"
            $f_form.Controls.Add($f_instr4)

            $f_neg4 = New-Object System.Windows.Forms.Checkbox
            $f_neg4.Location = New-Object System.Drawing.Size(350, 350)
            $f_neg4.Size = New-Object System.Drawing.Size(150, 25)
            $f_neg4.Checked = $false
            $f_neg4.ForeColor = 'CYAN'
            $f_neg4.Text = "User accounts only"
            $f_form.Controls.Add($f_neg4)




            ## Execution buttons
            $f_go = New-Object System.Windows.Forms.Button
            $f_go.Location = New-Object System.Drawing.Size(75, 460)
            $f_go.Size = New-Object System.Drawing.Size(150, 30)
            $f_go.Text = "SEARCH"
            $f_go.Enabled = $true
            $f_go.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $f_form.Controls.Add($f_go)
            $f_form.AcceptButton = $f_go

            $f_quit = New-Object System.Windows.Forms.Button
            $f_quit.Location = New-Object System.Drawing.Size(250, 460)
            $f_quit.Size = New-Object System.Drawing.Size(150, 30)
            $f_quit.Text = "CANCEL"
            $f_quit.Enabled = $true
            $f_quit.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $f_form.Controls.Add($f_quit)
            $f_form.AcceptButton = $f_quit


            
            ## Perform a simple host login lookup (Who's on first?)
            $f_key1.Add_Click({
                if($f_key1.SelectedItem -eq 'host' -and $f_te1.Text){
                    $f_wof.Enabled = $true
                }
                else{
                    $f_wof.Enabled = $false
                }
            })

            $f_wof.Add_Click({
                $Script:dyrl_ger_WOF = $true
                $skipsys = $true
                $Script:dyrl_ger_woflist = @()
            })

            
    
            ## Clean exit for CANCEL button
            $f_quit.Add_Click({
                $f_te1.Text = $null
                $f_val1 = $null
            })



            ## Keep form on top of other windows
            $f_form.TopMost = $true

            ## Open the input form
            $f_GUI = $f_form.ShowDialog()

            if( $f_te1.Text -and $f_te1.Text -ne ''){

                if($dyrl_ger_WOF){
                    $f_val1 = "hostname:$($f_te1.Text) " + $f_omits
                    $res = '&rows=150'
                    $skipres = $true
                }
                else{
                    if($f_key1.SelectedItem -eq 'user'){$f_val1 = [string]"username:$($f_te1.Text)"}
                    if($f_key1.SelectedItem -eq 'file'){$f_val1 = [string]"filemod:$($f_te1.Text)"}
                    if($f_key1.SelectedItem -eq 'host'){$f_val1 = [string]"hostname:$($f_te1.Text)"}
                    if($f_key1.SelectedItem -eq 'ip'){$f_val1 = [string]"ipaddr:$($f_te1.Text)"}
                    if($f_key1.SelectedItem -eq 'process'){$f_val1 = [string]"process_name:$($f_te1.Text)"}
                    if($f_key1.SelectedItem -eq 'website'){$f_val1 = [string]"domain:$($f_te1.Text)";$webs = $true}
                    if($f_key1.SelectedItem -eq 'email'){$f_val1 = [string]"(cmdline:*@* AND cmdline:*mail* AND cmdline:*$($f_te1.Text -replace '\*')*) -cmdline:*safelinks*";$Script:dyrl_ger_emails = $true}
                    if($f_key1.SelectedItem -eq 'attachment'){$f_val1 = [string]"filemod:Content.Outlook*$($f_te1.Text -replace '\*')*";$Script:srch = '*' + $($f_te1.Text -replace '\*') + '*';$Script:dyrl_ger_attch = $true}
                    if($f_key1.SelectedItem -eq 'cmdline'){$f_val1 = [string]"fileless_scriptload_cmdline:$($f_te1.Text) OR cmdline:$($f_te1.Text)"}
                
                    if($f_neg1.Checked){$f_val1 = '-' + $f_val1}
    
                    if($f_key2.SelectedItem -eq 'user'){$f_val2 = [string]"username:$($f_te2.Text)"}
                    if($f_key2.SelectedItem -eq 'file'){$f_val2 = [string]"filemod:$($f_te2.Text)"}
                    if($f_key2.SelectedItem -eq 'host'){$f_val2 = [string]"hostname:$($f_te2.Text)"}
                    if($f_key2.SelectedItem -eq 'ip'){$f_val2 = [string]"ipaddr:$($f_te2.Text)"}
                    if($f_key2.SelectedItem -eq 'process'){$f_val2 = [string]"process_name:$($f_te2.Text)"}
                    if($f_key2.SelectedItem -eq 'website'){$f_val2 = [string]"domain:$($f_te2.Text)";$webs = $true}
                    if($f_key2.SelectedItem -eq 'email'){$f_val2 = [string]"(cmdline:*@* AND cmdline:*mail* AND cmdline:*$($f_te2.Text -replace '\*')*) -cmdline:*safelinks*";$Script:dyrl_ger_emails = $true}
                    if($f_key2.SelectedItem -eq 'attachment'){$f_val2 = [string]"filemod:Content.Outlook*$($f_te2.Text -replace '\*')*";$Script:srch = '*' + $($f_te1.Text -replace '\*') + '*';$Script:dyrl_ger_attch = $true}
                    if($f_key2.SelectedItem -eq 'cmdline'){$f_val2 = [string]"fileless_scriptload_cmdline:$($f_te2.Text) OR cmdline:$($f_te2.Text)"}
            
                    if($f_key3.SelectedItem -eq 'user'){$f_val3 = [string]"username:$($f_te3.Text)"}
                    if($f_key3.SelectedItem -eq 'file'){$f_val3 = [string]"filemod:$($f_te3.Text)"}
                    if($f_key3.SelectedItem -eq 'host'){$f_val3 = [string]"hostname:$($f_te3.Text)"}
                    if($f_key3.SelectedItem -eq 'ip'){$f_val3 = [string]"ipaddr:$($f_te3.Text)"}
                    if($f_key3.SelectedItem -eq 'process'){$f_val3 = [string]"process_name:$($f_te3.Text)"}
                    if($f_key3.SelectedItem -eq 'website'){
                        if($f_te3.Text -eq 'debug'){
                            $dyrl_ger_DEBUG = $true
                        }
                        else{
                            $f_val3 = [string]"domain:$($f_te3.Text)"
                            $webs = $true
                        }
                    }
                    if($f_key3.SelectedItem -eq 'email'){$f_val3 = [string]"(cmdline:*@* AND cmdline:*mail* AND cmdline:*$($f_te3.Text -replace '\*')*) -cmdline:*safelinks*";$Script:dyrl_ger_emails = $true}
                    if($f_key3.SelectedItem -eq 'attachment'){$f_val3 = [string]"filemod:Content.Outlook*$($f_te3.Text -replace '\*')*";$Script:srch = '*' + $($f_te1.Text -replace '\*') + '*';$Script:dyrl_ger_attch = $true}
                    if($f_key3.SelectedItem -eq 'cmdline'){$f_val3 = [string]"fileless_scriptload_cmdline:$($f_te3.Text) OR cmdline:$($f_te3.Text)"}

                    if($f_val2){
                        $f_val1 = $f_val1 + ' '
                        if($f_neg2.Checked){$f_val2 = '-' + $f_val2}
                        if($f_or2.Checked){$f_val2 = 'OR ' + $f_val2}
                    }
                    if($f_val3){
                        if($f_val2){
                            $f_val2 = $f_val2 + ' '
                        }
                        else{
                            $f_val1 = $f_val1 + ' '
                        }
                        if($f_neg3.Checked){$f_val3 = '-' + $f_val3}
                        if($f_or3.Checked){$f_val3 = 'OR ' + $f_val3}
                    }



                    if($f_val2){
                        $f_val1 = $f_val1 + $f_val2
                    }
                    if($f_val3){
                        $f_val1 = $f_val1 + $f_val3
                    }

                    
                    ## Only return user events
                    if($f_neg4.Checked){
                        $f_val1 = $f_val1 + $f_omits
                        $skipsys = $true
                    }
                    ## If user checks then unchecks the OMIT box, remove the omit query
                    elseif($f_val1 -Match $f_omits){
                        $f_val1 = $f_val1 -replace $f_omits
                    }

                }

                

                $se = [string]$($f_te4a.Text) -Split('-')
                $sy = [int]$se[0]
                $sm = [int]$se[1]
                $sd = [int]$se[2]
                $sfuture = [DateTime]::DaysInMonth($sy,$sm)

                $st = [string]$($f_te4b.Text) -Split(':')
                $lh = [int]$st[0]
                $mm = [string]$st[1]

                if((Get-Date).IsDaylightSavingTime()){
                    $zh = $lh + 5
                }
                else{
                    $zh = $lh + 6
                }

                if($zh -eq 24){
                    [string]$zh = '00'
                }
                elseif($zh -gt 24){
                    $diff = $zh - 24
                    [string]$zh = '0' + [string]$diff
                    $sd = $sd + 1
                }

                $hm = [string]$zh + ':' + $mm

                if($sd -gt $sfuture){
                    $sd = 1
                    $sm = $sm + 1
                }
                if($sm -gt 12){
                    $sm = 1
                    $sy = $sy + 1
                }
                if($sm -lt 10){
                    $sm = '0' + [string]$sm
                }
                if($sd -lt 10){
                    $sd = '0' + [string]$sd
                }



                $ee = [string]$($f_te5a.Text) -Split('-')
                $ey = [int]$ee[0]
                $em = [int]$ee[1]
                $ed = [int]$ee[2]
                $efuture = [DateTime]::DaysInMonth($ey,$em)

                $et = [string]$($f_te5b.Text) -Split(':')
                $lh2 = [int]$et[0]
                $mm2 = [string]$et[1]

                if((Get-Date).IsDaylightSavingTime()){
                    $zh2 = $lh2 + 5
                }
                else{
                    $zh2 = $lh2 + 6
                }

                if($zh2 -eq 24){
                    [string]$zh2 = '00'
                }
                elseif($zh2 -gt 24){
                    $diff2 = $zh2 - 24
                    [string]$zh2 = '0' + [string]$diff2
                    $ed = $ed + 1
                }

                $hm2 = [string]$zh2 + ':' + $mm2
                
                if($sd -gt $sfuture){
                    $sd = 1
                    $sm = $sm + 1
                }
                if($sm -gt 12){
                    $sm = 1
                    $sy = $sy + 1
                }
                if($em -lt 10){
                    $em = '0' + [string]$em
                }
                if($ed -lt 10){
                    $ed = '0' + [string]$ed
                }



                $startt = 'start:[' + [string]$sy + '-' + [string]$sm + '-' + [string]$sd + 'T' + [string]$hm + ':00 TO '
                $startt = $startt +  [string]$ey + '-' + [string]$em + '-' + [string]$ed + 'T' + [string]$hm2 + ':00] '
                

                
                $qbuild = $qbuild + $startt + $f_val1
            }

        } ## End the "! $vf19_OPT" check

        else{
            $oneuser = $true; $skipsys = $true
            ''
            if($dyrl_ger_DEBUG){
                w '                 DEBUGGING MODE
                
                ' 'c'
            }
            w ' Enter your query, "?" for help, or "q" to quit:
            ' 'g'
            Write-Host ' > ' -NoNewline;
            $Z1 = Read-Host
            if($Z1 -eq '?'){
               showHelp 2
               findThese
            }
            elseif($Z1 -eq 'q'){
               Remove-Variable -Force dyrl_ger_* -Scope Global
               Exit
            }
            elseif($Z1 -eq 'carbon fiber'){
                $Z1 = ''
                $dyrl_ger_DEBUG = $true
                w ' Debugging  mode enabled.'; slp 2; splashPage; findThese
            }
            elseif($Z1 -Match "\w"){
               $qbuild = $qbuild + $Z1
               $f_val1 = $true
            }
            else{
               Exit
            }
        }
        
        
    }

    if( ! $f_val1 ){
        Remove-Variable f_*,dyrl_ger_* -Scope Global
        Exit
    }
    
    
    
    ## I set the max results to 75 out of personal preference. If there was any significant
    ## event to investigate, I wouldn't use GERWALK, I'd just log into Carbon Black. GERWALK
    ## is meant for supplying quick enrichment/confirmation & context to other MACROSS tools.
    if( ! $skipres ){
        Write-Host -f GREEN "
        By default I'll only grab the 10 most recent results for you, and unless you are
        searching for a process, each process will only be displayed once (otherwise you'd 
        end up with a screen full of svchost and firefox). Enter a new max threshold up to
        75, or ENTER to keep the default:  " -NoNewline;
        $Z = Read-Host

        if($Z -Match "[0-9]{1,2}"){
            if($Z -gt 75){
                ''
                Write-Host -f CYAN '    The limit is currently 75. Setting max results to 75.
                '
                $Z = 75
                slp 2
            }
            $Script:dyrl_ger_RES = $Z
            $res ="&rows=$Z"
        }
        else{
            $Script:dyrl_ger_RES = 10
            $res='&rows=10'
        }
    }

    Write-Host '

    '

    
    ## Finalize the query and URL encode it
    $Script:displayq = $qbuild
    $qbuild = $qbuild -replace "\(",'%28' -replace "\)",'%29'
    $qbuild = $qbuild -replace ' ','%20'
    $qbuild = $qbuild -replace ':','%3A'
    $qbuild = $qbuild -replace "\[",'%5B'
    $qbuild = $qbuild -replace "\]",'%5D'
    $qbuild = $qbuild + $res
    $qbuild = $qbuild + '&sort=server_added_timestamp%20desc&start=0'

    craftQuery $qbuild $qsection $dyrl_ger_MARK $max
    
    
}


## Take user inputs to build query
## $1 = CB queries from "findThese" function
## $2 = the CB module to query, passed from "findThese"
## $3 is the close-off section
## $4 limits the # of results returned
##
## If only param $1 is passed in, it should be a CB event ID number. This function will
##  then perform a query for that specific event, which will include all details not
##  available in a standard query.
function craftQuery($1,$2,$3,$4){
    
    $ua = 'MACROSS'      ## Help track the use of this script in logs/events by setting
                         ## a unique user-agent

    ## MPOD ALERT! This $vf19_MPOD['ger'] value can be found in the core/temp_config.txt file.
    ## Replace the base64 string beginning "@@@ger" with your own base64-encoded URL for your
    ## Carbon Black Response EDR server.
    getThis $vf19_MPOD['ger']          
    $SRV1 = "$vf19_READ"


    getThis 'IC1IICdYLUF1dGgtVG9rZW46IA=='
    $SRV2 = $vf19_READ
    $qopen = "curl.exe --silent -k -A '$ua' $SRV1"


    if( ! $2 ){
        Clear-Variable dyrl_ger_FULLEVENT -Force
        $getResults = "$qopen$1' -H 'accept: application/json' $SRV2$dyrl_ger_MARK'"
        $Script:dyrl_ger_SINGLEEVENT = iex $getResults | ConvertFrom-Json
    }
    elseif($1 -eq ''){
        $getResults = "$qopen$2' -H 'accept: application/json' $SRV2$3'"
        $Script:dyrl_ger_REQUESTED = iex "$getResults" | ConvertFrom-Json
    }
    else{
        Clear-Variable dyrl_ger_WORKSPACE -Force
        
        $qmaxres = $4
        $getResults = "$qopen$2$1' -H 'accept: application/json' $SRV2$3'"

        if( $CALLER ){
            if( $CALLER -eq 'MACROSS'){
                $dyrl_ger_VAL = $dyrl_ger_file
            }
            else{
                $dyrl_ger_VAL = $PROTOCULTURE
            }
            Write-Host -f GREEN '
        Searching on ' -NoNewline;
            Write-Host -f YELLOW "$dyrl_ger_VAL" -NoNewline;
            Write-Host -f GREEN ', standby...
            '
        }
        elseif( $dyrl_ger_DEBUG ){
            $debugResults = "$qopen$2$1' -H 'accept: application/json' $SRV2 ****key*masked****'"
            $debugResults
            ''
            ''
            $z = Read-Host '  Hit ENTER to execute curl or "q" to quit'
            if($z -eq 'q'){
                Remove-Variable dyrl_ger_*
                Exit
            }
            Clear-Variable z
        }
        else{
        Write-Host -f GREEN '
        Searching now, standby...
        '
        }



        if( $dyrl_ger_DEBUG ){
            Remove-Variable -Force dyrl_ger_DEBUG -Scope Global
            $DEBUGSPACE = iex "$getResults" -ErrorAction Inquire | ConvertFrom-Json
            $c = 'continue'

            while($c -ne ''){
                Write-Host '  "$DEBUGSPACE" is your JSON response converted to a powershell object.'
                Write-Host '  When finished testing, hit ENTER to continue without debugging, or "q" to quit.
                '
                $c = Read-Host '  Parse'

                if($c -eq 'q'){
                    Remove-Variable -Force dyrl_ger_* -Scope Global
                    Exit
                }
                elseif($c -Match $no){
                    $c = $null
                }
                elseif($c -Match "^\$DEBUGSPACE"){
                    iex "$c"
                }
            }
        }

        Write-Host '  Your search:'
        Write-Host -f CYAN "  > $displayq"
        if($DEBUGSPACE){
            $Script:dyrl_ger_WORKSPACE = $DEBUGSPACE  ## No need to send another API call if testing
        }
        else{
            $Script:dyrl_ger_WORKSPACE = iex "$getResults" #| ConvertFrom-Json
        }
    }

}


## Loop until user quits
##  $1 is automatically passed if $CALLER has any value
function searchAgain($1){
    ''
    $Script:dyrl_ger_SINGLEEVENT = $null
    $Script:dyrl_ger_WORKSPACE = $null
    $Script:dyrl_ger_WORKSPACE1 = $null
    $Script:RESULTS = $null
    $Script:EVENTLISTING = $null
    $Script:srch = $null
    $Script:dyrl_ger_emails = $false
    $Script:dyrl_ger_attch = $false
    if( $1 -ne 1 ){
        Write-Host -f GREEN "    Hit ENTER to search again, or 'q' to quit: " -NoNewline;
        $Z = Read-Host
        if( $Z -eq 'q' ){
            $1 = 1
        }
    }

    cls

    if( $1 -eq 1 ){
        Exit
    }
}




$Script:r = 0
## You need to figure out how to get your API key passed in here.
## DO NOT HARDCODE KEYS IN YOUR SCRIPTS!!!!!!
$Script:dyrl_ger_MARK = 'your api key goes in here'



## Don't display these procs on screen, or they will be the only things anyone sees
## You'll probably need to add programs like your org's antivirus to this list
$dyrl_ger_dontCare = @(
    'explorer.exe',
    'onedrive.exe',
    'searchindexer.exe',
    'searchprotocolhost.exe',
    'startmenuexperiencehost.exe',
    'svchost.exe',
    'taskhostw.exe',
    'userinit.exe'
)


## List out contents from the facet object
function quickList($1,$2){
    splashPage
    Write-Host '
    Your search:'
    Write-Host -f CYAN " > $displayq"
    ''
    if($2 -eq 'p'){
        $obj = 'process_name'
    }
    if($2 -eq 'h'){
        $obj = 'hostname'
    }
    if($2 -eq 'u'){
        $obj = 'username_full'
    }

    $fac = reviewResults '' 'process' $obj

    $fac | Sort -Unique | %{
        Write-Host -f YELLOW "  $_"
    }
    
    Write-Host -f GREEN '
    Hit ENTER to continue.
    '
    Read-Host
}


## Check if another tool is requesting an alt API call
## Add more values as necessary. Currently, the 'sensor'
## call will grab sensor IDs from hostnames, all other
## values go through the process api in "findThese"
if($dyrl_ger_alternate -eq 'sensor'){
    $dyrl_ger_XOBJ = $PROTOCULTURE
    inspectSID '' $dyrl_ger_XOBJ
    Return $dyrl_ger_REQUESTED  ## Response is a simple JSON
}
elseif($dyrl_ger_alternate){
    $dyrl_ger_XOBJ = $PROTOCULTURE
    findThese $CALLER $dyrl_ger_XOBJ
    ## Send back the CB response JSON + a list of the noisiest processes that
    ##   can be filtered out if necessary.
    ## Make sure your calling script is expecting an array as the response!
    $requested = @($dyrl_ger_WORKSPACE,$dyrl_ger_dontCare)
    Return $requested
}

## Proceed with the regular proc search types
else{
while($r -Match "[0-9]"){

    splashPage

    ## Import values from other tools
    if( $CALLER ){
        if( $CALLER -eq 'MACROSS' ){
            Write-Host -f GREEN "
            Type in a filename for a general search, or hit ENTER
            to open a file window to select a specific file: " -NoNewline;
            $Z1 = Read-Host

            if( $Z1 -eq '' ){
                $Z1 = getFile
                if( $Z1 -eq '' ){
                    ''
                    Write-Host -f CYAN '    Action cancelled. Hit ENTER to exit.'
                    Read-Host
                    Exit
                }
                while($Z2 -notMatch "^(md5|sha256)$"){
                    Write-Host -f GREEN "
                    MD5 or SHA256? " -NoNewline;
                    $Z2 = Read-Host
                }
            }
            else{
                $Z2 = $null
            }

            inspectBin $Z1 $Z2
        }
        elseif( $PROTOCULTURE ){
            Write-Host -f GREEN "                        $CALLER searching " -NoNewline;
            Write-Host -f YELLOW "$PROTOCULTURE" -NoNewline;
            Write-Host '...
            '
            findThese $CALLER $PROTOCULTURE  ## Send imported query params to the builder function
        }
        else{
            eMsg 3  # Inform user they're missing something
        }

    }
    # Run GERWALK by itself with user inputs
    else{
        findThese
    }


    $dyrl_ger_WORKSPACE = $dyrl_ger_WORKSPACE | ConvertFrom-Json
    $HOWMANY = ($dyrl_ger_WORKSPACE.results).length


    ## Limit screen results to the (probably) most relevant events
    $Script:dyrl_ger_UNIQUE = @()

    

    if( $HOWMANY -gt 0){
        $dyrl_ger_WORKHIGHLIGHTS = @()
        $dyrl_ger_WORKSPACE1.highlights | %{
            $dyrl_ger_WORKHIGHLIGHTS += $($_.name -replace 'PREPREPRE' -replace 'POSTPOSTPOST')
        }
        ## Extract useful details from a single event ID
        function showFULLEVENT($1,$2){
            if( ! $dyrl_ger_attch){
                $Script:srch = "*content.outlook*"
            }
            $attch = $1.process.filemod_complete | %{
                $fmfield = $_ -Split('\|')
                $fmfield[2] -replace ".*\\" | where{$_ -Like $srch}
            }
            $attch = $attch | Sort -Unique
            $bexec = $1.process.modload_complete | %{
                $bx = $_ -Split('\|')
                $bx[2] | where{$_ -notMatch "(activclient|appsense|syswow64|microsoft|windows|avast|mcafee|symantec|vmware|oracle)"}
            }
            $bexec = $bexec | Sort -Unique
            $fcmd = $1.process.fileless_scriptload_complete | %{
                $_ -replace "^.+\|\w{64}\|"} | 
                Sort -Unique
            if($notmp){
                $fmod = $1.process.filemod_complete | %{
                    $spl1 = $_.split('\|')
                    $spl1[2] | where{$_ -notMatch "(.*(local|roaming)\\microsoft.*|(dat|tmp)$)"} |
                    Sort -Unique
                }
            }
            else{
                $fmod = $1.process.filemod_complete | 
                %{$spl1 = $_.split('\|');$spl1[2] -replace ".*\\"} | 
                Sort -Unique
            }
            $child = $1.process.childproc_complete | 
                %{$spl2 = $_.split('\|');$spl2[3] -replace ".*\\"} | 
                Sort -Unique
            $netc = $1.process.netconn_complete | 
                %{$spl3 = $_.split('\|');$spl3[4]} | 
                Sort -Unique
            $reg = $1.process.regmod_complete | 
                %{$spl4 = $_.split('\|');$spl4[2]} | 
                Sort -Unique
            
            
            if($attch.count -gt 0){
                ''
                Write-Host -f YELLOW "  $($attch.count)" -NoNewline;
                Write-Host -f CYAN " Email attachments:"
                if($cmdmail){
                    $2nd = $cmdmail
                }
                else{
                    $2nd = $1.process.process_name
                }
                $attch | %{
                    screenResults $uname $2nd
                    screenResults $_
                }
                screenResults 'endr'
            }
            if($fcmd.count -gt 0 -and ($displayq -Like "*cmdline*" -or $2 -eq 'c')){
                ''
                Write-Host -f YELLOW "  $($fcmd.count)" -NoNewline;
                Write-Host -f CYAN " Command lines:"
                screenResults 'endr'
                $fcmd | %{
                    screenResults $_
                    screenResults 'endr'
                }
            }
            if($fmod.count -gt 0 -and -not $dyrl_ger_attch -and ($displayq -Like "*filemod*" -or $2 -eq 'n')){
                ''
                Write-Host -f YELLOW "  $($fmod.count)" -NoNewline;
                Write-Host -f CYAN " File mods (system files & files without extensions will be omitted):"
                screenResults 'endr'
                $fmod | 
                    where{$_ -notMatch "(.*(local|roaming)\\microsoft.*|(dat|tmp)$)"} |
                    where{$_ -Match "\.[a-z][a-z]+$"} | %{
                        screenResults $_
                        screenResults 'endr'
                }
            }
            if($2 -eq 'e'){
                ''
                Write-Host -f YELLOW "  $($bexec.count)" -NoNewline;
                Write-Host -f CYAN " Binary execution (system applications are ignored):"
                screenResults 'endr'
                $bexec | %{
                    screenResults $_
                    screenResults 'endr'
                }
            }
            if($netc.count -gt 0 -and ($displayq -Like "*domain*" -or $2 -eq 'd')){
                ''
                Write-Host -f YELLOW "  $($netc.count)" -NoNewline;
                Write-Host -f CYAN " Network connections:"
                screenResults 'endr'
                $netc | %{
                    screenResults $_
                    screenResults 'endr'
                }
            }
            if($reg.count -gt 0 -and $2 -eq 'r'){
                ''
                Write-Host -f YELLOW "  $($reg.count)" -NoNewline;
                Write-Host -f CYAN " Registry mods:"
                screenResults 'endr'
                $reg | %{
                    screenResults $_
                    screenResults 'endr'
                }
            }
            if($child.count -gt 0 -and $2 -eq 'k'){
                ''
                Write-Host -f YELLOW "  $($child.count)" -NoNewline;
                Write-Host -f CYAN " Child processes:"
                screenResults 'endr'
                $child | %{
                    screenResults $_
                    screenResults 'endr'
                }
            }
            
            Write-Host '

            '
        }


        ## Display results as an indexed list
        function showRESULT($1){
            cls
            $Script:r = 0                 ## Total up the events found
            $Script:RESULTS = @{}         ## Collect from the .results object
            $Script:EVENTLISTING = @{}    ## Collect from each query to a specific .id event
            Write-Host '
            '

            $1.results | Foreach-Object{
                $Script:r++
                $Script:RESULTS.Add($r,$_) ## Save all .results in an array
                ## Save each individual event from .results in a separate array
                if( ! $CALLER ){
                    Write-Host -f GREEN "  Collecting Event $r"
                    craftQuery "v1/$($_.id)/event"
                    $Script:EVENTLISTING.Add($($_.id),$dyrl_ger_SINGLEEVENT[0])
                }
            }
            
            splashPage
            ''
            Write-Host '  Your search:'
            Write-Host -f CYAN "> $displayq"

            Write-Host -f GREEN '
            Displaying the latest ' -NoNewline;
            Write-Host -f YELLOW "$HOWMANY" -NoNewline;
            Write-Host -f GREEN ' results:'
            Write-Host -f YELLOW '         ======================================
            '

            
            
            $mailstrings = 0
            foreach($rk in ($RESULTS.keys | Sort)){
                $rv = $RESULTS[$rk]
                $Script:rr = $rk
                    #$r++
                    #$Script:rr = $r
                    #$Script:RESULTS.Add($r,$_)
                    $starttt = $rv.start  ## Don't mix up with user's time window search param
                    $eid = $rv.id
                    $cmdline = $rv.cmdline
                    $hname = $rv.hostname
                    $htype = $rv.host_type
                    $uname = $rv.username -replace "^ENT."
                    $proc = [string]$rv.process_name
                    $ppath = $rv.path
                    $daddy = $rv.parent_name
                    $kid = $rv.childproc_name
                    $dom = $rv.domain
                    $os = $rv.os_type
                    $fname = $rv.observed_filename -replace "^.+\\" -replace "}$"
                    $rname = $rv.internal_name
                    $fpath = $rv.path
                    $md5 = $rv.md5
                    $grp = $rv.group
                    $fdesc = $rv.file_desc
                    $sigstat = $rv.digsig_result
                    $hnwithfn = $rv.host_count
                    $filesrc = $rv.product_name
                    $hsid = $rv.sensor_id

                    if( $hsid ){
                        $Script:getSID = $true
                    }
                
                    if($displayq -Like "*domain:*"){
                        if($cmdline -Like "*http*"){
                            $cmdline = $cmdline -replace "^.+http",'http' -replace " .+"
                        }
                    }

                if($dyrl_ger_WOF){
                    $Script:dyrl_ger_woflist += $uname
                }
                else{

                    adjustTime $starttt 0  # Localize timestamp

                    $showEvent = $true
                
                    ## Limit duplicates and standard proc events
                    if($displayq -Like "*username*" -and $displayq -notLike "*process_name*"){
                        $dyrl_ger_dontCare | %{
                            if($_ -eq $proc){
                                $showEvent = $false
                            }
                        }

                        if( $showEvent ){
                            $dyrl_ger_UNIQUE | %{
                                if($_ -eq $proc){
                                    $showEvent = $false
                                }
                            }
                        }
                    }


                    


                    if($showEvent){
                        ## Track procs that get listed; don't list a proc more than once UNLESS
                        ## user is searching for procs
                        if($displayq -Like "*ipaddr*" -or $displayq -Like "*hostname*"){
                            $Script:dyrl_ger_UNIQUE += $proc
                        }

                        [string]$dyrl_ger_EVENTT = [string]$rr + '. ' + [string]$dyrl_ger_LOCAL

                        if($cmdline -Like "*@*" -and $cmdline -Like "*mailto*"){
                            $cmdmail = $cmdline -replace "^.*mailto:" -replace '".*' 
                            $cmdmail = $cmdmail -replace "^.+PREPREPRE" -replace "POSTPOSTPOST.*"
                        }

                        $bar = chr 9553
                        $bars = $bar + $bar + $bar + $bar


                        ## Create menus dynamically based on API called
                        if( $dyrl_ger_BINARYQ ){
                            $bname = $($1.facets.observed_filename_facet.name)
                            $bhosts = $1.facets.hostname
                            $signer = $($1.facets.digsig_publisher_facet.name)
                            $bver = $($1.facets.file_version_facet.name)
                            Write-Host -f GREEN "   $r. FILE: " -NoNewline;
                            Write-Host -f YELLOW "$fname"
                            Write-Host -f GREEN '         VERSION: ' -NoNewline;
                            Write-Host -f YELLOW "$bver"
                            Write-Host -f GREEN '         REAL NAME: ' -NoNewline;
                            Write-Host -f YELLOW "$rname"
                            Write-Host -f GREEN '         DESCRIPTION: ' -NoNewline;
                            Write-Host -f YELLOW "$fdesc"
                            Write-Host -f GREEN '         PRODUCT: ' -NoNewline;
                            Write-Host -f YELLOW "$filesrc"
                            Write-Host -f GREEN '         SIGNED: ' -NoNewline;
                            Write-Host -f YELLOW "$sigstat"
                            Write-Host "             $signer"
                            Write-Host -f GREEN '         HOSTS SEEN WITH THIS SPECIFIC FILE: ' -NoNewline;
                            Write-Host -f YELLOW "$hnwithfn"
                            Write-Host -f GREEN '         MD5: ' -NoNewline;
                            Write-Host -f YELLOW "$md5"
                        }
                        elseif($dyrl_ger_attch){
                            Write-Host -f CYAN "$bars  $dyrl_ger_EVENTT   $hname  '$htype'   '$grp'"
                            showFULLEVENT $EVENTLISTING["$eid"]
                        }
                        else{
                            Write-Host -f CYAN "$bars  $dyrl_ger_EVENTT   $hname  '$htype'   '$grp'"
                            if($dyrl_ger_emails){
                                if($cmdmail){
                                    $mailstrings++
                                    screenResults $uname $proc $cmdmail
                                }
                            
                                if($mailstrings -gt 0){
                                    screenResults 'endr'
                                }
                                else{
                                    Write-Host -f GREEN ' No email addresses...
                                    '
                                }
                            }
                            elseif($dyrl_ger_cmd){
                                screenResults "User: $uname" "  Proc: $proc"
                                if($daddy){
                                    screenResults 'Parent' $daddy
                                }
                                screenResults 'endr'
                                Write-Host -f GREEN '$bar ' -NoNewline;
                                Write-Host " $cmdline"
                                screenResults 'endr'
                                Write-Host '
                                '
                            }
                            elseif($dyrl_ger_filesearch){
                                Write-Host -f YELLOW ' File was found, but filenames cannot be shown in this view.'
                                Write-Host -f YELLOW " Showing the file's process path and command line values instead:"
                                screenResults 'endr'
                                Write-Host -f GREEN "$bar $ppath"
                                screenResults 'endr'
                                Write-Host -f GREEN "$bar $cmdline"
                                screenResults 'endr'
                                Write-Host '
                                '
                            }
                            else{
                                screenResults "User: $uname" "OS: $os" "Sensor: $hsid"
                                <#if($proc -notMatch "\w"){
                                    $proc = 'null'
                                }
                                if($ppath -notMatch "\w"){
                                    $ppath = 'null'
                                }
                                if($kid -notMatch "\w"){
                                    $kid = 'null'
                                }
                                if($cmdline -notMatch "\w"){
                                    $cmdline = 'null'
                                }#>


                                screenResults 'Process' $proc
                                if($ppath){
                                    screenResults 'Proc Path' $ppath
                                }
                                if($daddy){
                                    screenResults 'Parent' $daddy
                                }
                                if($kid){
                                    screenResults 'Child' $kid
                                }
                                if($cmdline){
                                    if($cmdline -Match '^"'){
                                        $cmd = $cmdline -replace '^".*?"\s'
                                    }
                                    else{
                                        $cmd = $cmdline -replace "^.*?\s"
                                    }
                                    screenResults 'Cmdline' $cmd
                                }
                                screenResults 'endr'
                                Write-Host '
                                '
                            }
                        }
                    }
                    else{
                        $Script:dyrl_ger_SKIPPEDSUM = ' Some results were omitted to avoid duplicates. You can try searching again 
 and increasing the number of results to pull.'
                        $r = $r - 1
                    }
                }
            }
        }
        
        
        ''
        while($dyrl_ger_Z -ne 'f'){
            $Script:dyrl_ger_WORKSPACE1 = $dyrl_ger_WORKSPACE
            Clear-Variable -Force dyrl_ger_Z
            showRESULT $dyrl_ger_WORKSPACE1

            ## Only show the logged in user
            if($dyrl_ger_WOF){
                $dyrl_ger_wofnames = $($dyrl_ger_woflist | Sort -Unique) -Join ', '
                $dyrl_ger_wofnames = 'Logged in user(s): ' + $dyrl_ger_wofnames
                $f_wshell = New-Object -ComObject Wscript.Shell
                $f_wshell.Popup(
                    $dyrl_ger_wofnames,
                    0,
                    "Logged in user(s)",
                    64+0+4096
                )
                $dyrl_ger_Z = 'f'
                if(! $CALLER){
                    Remove-Variable dyrl_ger_*
                    Exit
                }
            }


            if($dyrl_ger_SKIPPEDSUM){
                Write-Host -f CYAN $dyrl_ger_SKIPPEDSUM
            }
            ''
            
            if( $dyrl_ger_BINARYQ ){
                Write-Host -f GREEN '         HOSTS ASSOCIATED WITH THE FILENAME/HASH:'
                $bhosts | %{
                    Write-Host "             $($_.name)"
                }
                Remove-Variable tw_c8_* -Scope Global
                Write-Host -f GREEN '   Hit ENTER to exit.
                '
                Read-Host
                Exit
            }
            else{
                Write-Host -f GREEN "    Select a result (1 - $rr) to drill down, " -NoNewline;
                Write-Host -f GREEN ' "' -NoNewline;
                Write-Host -f YELLOW 'p' -NoNewline;
                Write-host -f GREEN '"'
                Write-Host -f GREEN '    to see a quick list of all processes, "' -NoNewline;
                Write-Host -f YELLOW 'u' -NoNewline;
                Write-Host -f GREEN '" to'
                Write-Host -f GREEN '    see a quicklist of all usernames, "' -NoNewline;
                Write-Host -f YELLOW 'h' -NoNewline;
                Write-Host -f GREEN '" for a'
                Write-Host -f GREEN '    quicklist of hostnames, ' -NoNewline;
                Write-Host -f GREEN "or '" -NoNewline;
                Write-Host 'f' -NoNewline;
                Write-Host -f GREEN "' to finish:  " -NoNewline;
                $dyrl_ger_Z = Read-Host
            }
            

            
            if($dyrl_ger_Z -eq 'u'){
                quickList $dyrl_ger_WORKSPACE1 'u'
            }
            elseif($dyrl_ger_Z -eq 'p'){
                quickList $dyrl_ger_WORKSPACE1 'p'
            }
            elseif($dyrl_ger_Z -eq 'h'){
                quickList $dyrl_ger_WORKSPACE1 'h'
            }
            elseif($dyrl_ger_Z -in $RESULTS.Keys){
                if( ! ($dyrl_ger_hname) -and ($RESULTS[[int]$dyrl_ger_Z].hostname) ){
                    $Script:dyrl_ger_hname = $RESULTS[[int]$dyrl_ger_Z].hostname
                }

                $dyrl_ger_IDSELECT = $RESULTS[[int]$dyrl_ger_Z].id      ## Get the event ID for the item chosen by the user
                #craftQuery "v1/$dyrl_ger_IDSELECT/event"               ## Run another CB query for that specific event ID
                
                while($dyrl_ger_ZZ -ne ''){
                    Write-Host -f GREEN "   $dyrl_ger_Z. EVENT TIME: " -NoNewline;
                    Write-Host -f YELLOW "$dyrl_ger_LOCAL"
                    $RESULTS[[int]$dyrl_ger_Z]
                    #showFULLEVENT $dyrl_ger_SINGLEEVENT[0]  ## json object similar to the WORKSPACE variable, but for a single event
                    showFULLEVENT $EVENTLISTING[$dyrl_ger_IDSELECT]
                    ''
                    Write-Host -f YELLOW ' Other notable event objects (shell commands, etc):'
                    $dyrl_ger_WORKHIGHLIGHTS | %{
                        Write-Host "  $_
                        "
                    }
                    ''
                    ''
                    Write-Host -f GREEN '    Hit ENTER to continue' -NoNewline;


                    if($RESULTS[[int]$dyrl_ger_Z].netconn_count -ne 0 -and $displayq -notLike "*domain*"){
                        Write-Host -f GREEN ', or'
                        Write-Host -f GREEN "       -Type '" -NoNewline;
                        Write-Host -f YELLOW 'd' -NoNewline;
                        Write-Host -f GREEN "' to list website Domains" -NoNewline;
                    }
                    if($RESULTS[[int]$dyrl_ger_Z].filemod_count -ne 0 -and $displayq -notLike "*filemod*"){
                        Write-Host -f GREEN ', or'
                        Write-Host -f GREEN "       -Type '" -NoNewline;
                        Write-Host -f YELLOW 'n' -NoNewline;
                        Write-Host -f GREEN "' to list file Names" -NoNewline;
                    }
                    if($RESULTS[[int]$dyrl_ger_Z].childproc_count -ne 0){
                        Write-Host -f GREEN ', or'
                        Write-Host -f GREEN "       -Type '" -NoNewline;
                        Write-Host -f YELLOW 'k' -NoNewline;
                        Write-Host -f GREEN "' to list child processes" -NoNewline;
                    }
                    if($RESULTS[[int]$dyrl_ger_Z].fileless_scriptload_count -ne 0 -and $displayq -notLike "*cmdline*"){
                        Write-Host -f GREEN ', or'
                        Write-Host -f GREEN "       -Type '" -NoNewline;
                        Write-Host -f YELLOW 'c' -NoNewline;
                        Write-Host -f GREEN "' to list Command lines" -NoNewline;
                    }
                    if($RESULTS[[int]$dyrl_ger_Z].regmod_count -ne 0){
                        Write-Host -f GREEN ', or'
                        Write-Host -f GREEN "       -Type '" -NoNewline;
                        Write-Host -f YELLOW 'r' -NoNewline;
                        Write-Host -f GREEN "' to list Registry changes" -NoNewline;
                    }
                    if($RESULTS[[int]$dyrl_ger_Z].modload_count -ne 0){
                        Write-Host -f GREEN ', or'
                        Write-Host -f GREEN "       -Type '" -NoNewline;
                        Write-Host -f YELLOW 'e' -NoNewline;
                        Write-Host -f GREEN "' to list binary execution" -NoNewline;
                    }
                    if( $getSID ){  ## Not implemented yet
                        Write-Host -f GREEN ', or '
                        Write-Host -f GREEN "       -Type '" -NoNewline;
                        Write-Host -f YELLOW 's' -NoNewline;
                        Write-Host -f GREEN "' to see more info on this sensor
                        "
                    }
                    Write-Host -f GREEN '   > ' -NoNewline;

                    $dyrl_ger_ZZ = Read-Host


                    if( $dyrl_ger_ZZ -in @('d','n','k','r','e','c') ){
                        showFULLEVENT $dyrl_ger_SINGLEEVENT[0] $dyrl_ger_ZZ
                    }
                    elseif( $dyrl_ger_ZZ -eq 's' ){
                        $ssiidd = $RESULTS[[int]$dyrl_ger_Z].sensor_id
                        inspectSID $ssiidd
                        reviewResults 0 1
                        Remove-Variable -Force ssiidd
                    }
                    else{
                        $dyrl_ger_ZZ = ''
                    }
                    w '
                    '

                    if($dyrl_ger_ZZ -ne ''){
                        ''
                        w '  Hit ENTER to continue.' 'g'
                        Read-Host
                    }
                }
                Remove-Variable dyrl_ger_ZZ,RESULTS,dyrl_ger_SINGLEEVENT,dyrl_ger_IDSELECT
            }
            elseif($dyrl_ger_Z -ne 'f'){
                Write-Host "    $dyrl_ger_Z isn't one of the results..."
                slp 1
            }
            $Script:dyrl_ger_UNIQUE = @()
        }

        $dyrl_ger_Z = $null

        if( $CALLER ){
            searchAgain 1
        }
        else{
            searchAgain
        }
    
    }
    else{
        
        $dyrl_ger_Z = ''
        Write-Host -f CYAN '
        No results found...
        '
        if( $CALLER ){
            Write-Host -f GREEN "  Hit ENTER to return to $CALLER" -NoNewline;
            Write-Host -f GREEN '.'
            Read-Host
            searchAgain 1
        }
        else{
            searchAgain
        }

    }
}
}

Remove-Variable -Force f_*,dyrl_ger_*,Z1


