#_sdf1 Demo - a basic config walkthru (8-10 mins)
#_ver 0.3
#_class User,demo script,Powershell,HiSurfAdvisory,0

<#
    Author: HiSurfAdvisory
    This script is a simple demonstration of collecting information
    from one script and passing it others that could add more detail
    or uncover more indicators related to your SOC investigations.
#>

function splashPage($1){
    cls
    if($1 -eq 1){
        screenResults '[macross] Attributes' '.name | .ver | .priv | .valtype | .lang | .author | .evalmax'
        screenResults 'Variables to remember' '$PROTOCULTURE, $CALLER, $RESULTFILE, $vf19_MPOD, $vf19_ATTS'
        screenResults 'endr'
    }
    else{
    $b = 'ICAgICAgIOKWiOKWiOKVlyAg4paI4paI4pWX4paI4paI4pWX4paI4paI4pWXICDilojiloj
    ilZcg4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKVlyDilojilojilZcgICDi
    lojilojilZcKICAgICAgIOKWiOKWiOKVkSAg4paI4paI4pWR4paI4paI4pWR4paI4paI4pWRIOKWi
    OKWiOKVlOKVneKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+
    KWiOKWiOKVkSAgIOKWiOKWiOKVkQogICAgICAg4paI4paI4paI4paI4paI4paI4paI4pWR4paI4pa
    I4pWR4paI4paI4paI4paI4paI4pWU4pWdIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkeKWiOKWiOKW
    iOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVkSAgIOKWiOKWiOKVkQogICAgICAg4paI4paI4pWU4pWQ4
    pWQ4paI4paI4pWR4paI4paI4pWR4paI4paI4pWU4pWQ4paI4paI4pWXIOKWiOKWiOKVlOKVkOKVkO
    KWiOKWiOKVkeKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVkSAgIOKWiOKWiOKVkQogICA
    gICAg4paI4paI4pWRICDilojilojilZHilojilojilZHilojilojilZEgIOKWiOKWiOKVl+KWiOKW
    iOKVkSAg4paI4paI4pWR4paI4paI4pWRICDilojilojilZHilZrilojilojilojilojilojilojil
    ZTilZ0KICAgICAgIOKVmuKVkOKVnSAg4pWa4pWQ4pWd4pWa4pWQ4pWd4pWa4pWQ4pWdICDilZrilZ
    DilZ3ilZrilZDilZ0gIOKVmuKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWdIOKVmuKVkOKVkOKVkOK
    VkOKVkOKVnSA='
    getThis $b
    Write-Host '
    '
    Write-Host -f YELLOW $vf19_READ
    Write-Host -f CYAN   '              A demo of MACROSS automations
    
    '
    }
    
}

if($HELP){
    splashPage
    $vf19_ATTS['HIKARU'].toolInfo() | %{
        Write-Host -f YELLOW $_
    }
    Write-Host "
      ======================================================================
  This script is a simple walkthru on how to use the MACROSS framework to connect
  your scripts together. The main goal of MACROSS is to automate your automations;
  give even your most junior analysts the ability to get as much information as
  quickly and easily as any crusty ol' command-line junkie -- on a budget!
  
  HIKARU explains the rules/guidelines of the framework that help automate your
  automations. It takes about 8-10 minutes to go through the basics.
  
  Hit ENTER to exit.
  "
    Read-Host
    Exit
}

function next($1){
    if($1 -eq 1){
        while($Z -ne 'c'){
            Write-Host -f GREEN "
    Type 'c' to continue! " -NoNewline;
            $Z = Read-Host
        }
    }
    else{
        Write-Host -f GREEN "
    Hit ENTER to continue!
        "
        Read-Host
    }
}

$Z = $null
transitionSplash 8
splashPage

while($Z -notMatch "(1|2)"){
    Write-Host -f GREEN '
        Choose a walk-thru:

        1. Quick & dirty (3-4 mins)
        2. Detailed (8-10 mins)
    
        > ' -NoNewline;

        $Z = Read-Host
        if($Z -eq ''){
            Exit
        }
}

if($Z -eq 1){
    splashPage
    Write-Host -f GREEN '

    Core breakdown:
    The "ncore" folder contains all of the core MACROSS functions.
        
        -utility.ps1
        Any functions that add capabilities to your automations go in this file. For example,
        the "getThis" function can perform Base64 and hexadecimal decoding, the "getFile"
        function can open dialog windows for your scripts to let users select files/folders,
        and the "sheetResults" function can write your outputs to an excel spreadsheet. Make
        sure to familiarize yourself with all the functions in here!

        -display.ps1
        The functions in this file control how things get displayed on screen. The "screenResults"
        and "screenResultsAlt" functions can receive inputs from your scripts and format them in
        different ways to prettify how outputs are written to screen.

        From the MACROSS main menu, type these commands to preview outputs ("debug" is only
        necessary the first time):

            debug screenResults "items" "Thing 1" "Thing 2"; screenResults "endr"
            screenResultsAlt "items" "Thing 1" "Thing 2"; screenResultsAlt "endr"

        -updates.ps1
        These functions are used if you are maintaining your automations in a central repository
        like gitlab or a fileshare. They allow MACROSS to look for new or updated scripts and 
        automatically download them.

        -validation.ps1
        This file contains functions specific to making sure scripts chosen by the user are 
        valid, and (if configured) that only valid users can use certain scripts. It also contains
        one of the primary reasons for MACROSS, the "collab" function, which passes values from
        one script to another and back.

        -splashes.ps1
        The function "transitionSplash" can be called to briefly display some Macross-related
        ASCII art. You can add your own art here as well.

        -classes.ps1
        The custom "macross" powershell class will be explained in a bit.

        -py_classes\mcdefs.py
        This is a generic python library that converts functionality in "utility.ps1" into
        python. It can sometimes help with minimizing imports in your python scripts by just
        importing this library.

        Hit ENTER to continue.
    '
    Read-Host
    splashPage 1
    Write-Host -f GREEN '
    The primary purpose of MACROSS is to let automations talk to each other and share info/
    resources. The "utility.ps1" file contains Base64 lines in its opening comments,
    separated by "@@@". These are values that can be commonly shared by all the MACROSS tools,
    and they get stored in a hashtable called "$vf19_MPOD". The first three letters of each
    Base64 string are index keys for this hashtable, so your script can quickly grab and
    decode them whenever necessary by using MACROSS decoding function, "getThis":

        getThis $vf19_MPOD["abc"]  ## Writes the decoded value to $vf19_READ for you to use.
    
    Just as importantly, the MACROSS framework revolves around another global variable,
    "$PROTOCULTURE", which all your automations should be aware of and looking for. If a script
    is called via the "collab" function, it should contain a check that evaluates the
    $PROTOCULTURE value if it exists.

    The collab function also supports sending an additional value to scripts that can evaluate
    $PROTOCULTURE + an optional value. See the notes for "collab" in the validation.ps1 file.

    Hit ENTER to continue.
    '
    Read-Host
    splashPage 1
    Write-Host -f GREEN '

    ADDING YOUR CUSTOM SCRIPTS TO MACROSS'
    Write-Host -f GREEN '
    Your custom scripts go in the "nmods" folder. These are the scripts that are
    selectable from the main menu.

    The first three lines of your powershell/python scripts must be reserved for
    MACROSS attributes. For example, the first three lines in this HIKARU script are:'
    Write-Host -f YELLOW '
        #_sdf1 Demo - a basic config walkthru (8-10 mins)
        #_ver 0.2
        #_class User,demo script,Powershell,HiSurfAdvisory,0'
    Write-Host -f GREEN "
    MACROSS ignores any scripts in the nmods folder that don't contain these lines.

    The first line contains a BRIEF description of the script -- this is the text that
    gets written to MACROSS' main menu.

    MACROSS uses the #_ver line to track versioning. And the final line, #_class, is
    what is used to create custom macross objects. From left to right, these are the
    attributes you need to assign to your script:

        -the LOWEST level of privilege required (user vs. admin)   (.priv)
        -what kind of data your script evaluates                   (.valtype)
        -what language your script is in                           (.lang)
        -the script author                                         (.author)
        -the maximum number of values it can process per session   (.evalmax)

    The script's filename and version also get collected as macross object attributes
    (.ver and .name).

    When this demo finishes and the main menu loads again, try typing"
    Write-Host -f YELLOW '
        debug $vf19_ATTS["KONIG"]

        or

        debug $vf19_ATTS["KONIG"].toolInfo()
    '
    Write-Host -f GREEN "
    To view that script's attributes.

    Hit ENTER to continue."
    Read-Host
    splashPage 1
    Write-Host -f GREEN '

    The purpose of [macross] class is to make your script easily searchable within MACROSS.
    Each script and its attributes is tracked in an array called ' -NoNewline;
    Write-Host -f YELLOW '"$vf19_ATTS"' -NoNewline;
    Write-Host -f GREEN '. If your
    script performs Active Directory audits, and you want it to collect enrichment on
    certain artifacts automatically as it scans, you can write a simple command that
    will find relevant scripts and send values to them via the "collab" function:
    
        # Send usernames found in your active directory script to MACROSS scripts
        # that can search usernames in a database, or an EDR, or whatever, and
        # collect all the results to enrich whatever your "ADScript" is reporting on.
        # In this example "Bob" is set as $PROTOCULTURE, the global value/IOC that
        # every MACROSS script should be coded to automatically act on.'
    Write-Host -f YELLOW '
        $Global:PROTOCULTURE = "Bob"
        $collection = @{}
        foreach ($key in $vf19_ATTS.keys) {
        '
    Write-Host -f GREEN '            # "collab" requires the file extension in the first param
            # This check will append the correct extension based on .lang attribute'
    Write-Host -f YELLOW '            if($MONTY -and $vf19_ATTS[$key].lang -eq "Python"){
                $script = $key + ".py"
            }
            else{
                $script = $key + ".ps1"
            }  

            if ($vf19_ATTS[$key].valtype -eq "usernames") { 
                $enrich = $( collab  $script  "ADScript" ) 
                $collection.Add("$key ENRICHMENT", $enrich)
            }
        }
    '
    Write-Host -f GREEN '    The $MONTY variable is set during startup, and is used to tell MACROSS tools
    whether or not python3 is installed. If it is not, MACROSS will not bother
    with any python scripts in the "nmods" folder. (MACROSS came about in part while
    I worked on a network that prevented python use, because that was easier 
    "security" than creating group-policies or something).

    Hit ENTER to continue.
    '
    Read-Host
    splashPage 1
    Write-Host -f GREEN "
    Lastly, if your automations are written in python, MACROSS contains a library
    called 'mcdefs.py', located in the 'ncore/py_classes' folder. I recommend you 
    take a quick look at that file, it is meant to replicate most of the same
    functions in 'utility.ps1' for python. MACROSS handles sending all the required
    values to your python automations; the main requirement for you is to use
    python's sys.argv to parse those values. The MINMAY demo script touches on how
    this is supposed to work.

    MACROSS uses a function called 'pyCross'; when one of the powershell scripts
    is called by a python script, pyCross should be used to write your powershell
    outputs to an '.eod' file that your python script can then parse as needed if
    that output can't be returned in a variable. It's not ideal, but it works until
    I have time to improve the method.

    Hit ENTER to wrap this up!
    "
    Read-Host
    splashPage 1
    Write-Host -f GREEN '
    As we conclude this infodump, here are the key takeaways:

    -Make your life easier by using the functions within utility.ps1

    -$PROTOCULTURE is a global variable that all MACROSS tools should be coded to
    look for and act on if it contains a value. That way multiple scripts can all
    gather data on the same artifact for you.

    -The "collab" function requires two parameters: The full name of the script
    you are calling (including its extension!), and the name of your script (no
    extension). The called script should be able to look up your script in $vf19_ATTS
    to see what kind of value it is likely to be passing (IP, username, etc.). You
    can also send a third optional value which, depending on context, will get
    evaluated with or in place of $PROTOCULTURE.

    -Python integration is a little clunky; sorry! Review the "collab" function
    in validation.ps1 to see what values and in what order they get passed to
    python. Powershell outputs for python get written to plaintext ".eod" files in
    "ncore/py_classes/gbio/" if the response cannot or should not be contained in a
    simple variable. (For example, maybe the output will need to be stored so that
    other automations can make use of it later).

    -MACROSS uses a custom python library called "mcdefs", located in the
    "ncore\py_classes" folder. It replicates many of the functions in utility.ps1
    for use in python.

    -While not necessary, you should write a man/help page that will load if the
    user selects your script from the menu with the "h" option, which temporarily
    sets the global variable $HELP to "true".


    Thanks for taking MACROSS for a spin! Hit ENTER to exit.
    '
    Read-Host
    Exit
}
elseif($Z -eq 2){
    Clear-Variable -Force Z

Write-Host -f GREEN '
    Welcome to MACROSS! This quick guide should get you started on combining
    your custom scripts together for your team to use with ease! FYI, this is
    aimed at folks who know how to write automation scripts and perform heavy
    string-manipulations, to give you a headstart on building or improving a
    toolset for your SOC teams that is designed around your environment.'
Write-Host -f GREEN "
    This is not a ready-to-go suite of tools (although the scripts included in
    the github library do work), but a framework with a 'front-end' to manage
    however many scripts you regularly make use of.

    For instance, MACROSS is capable of taking a value you're investigating,
    and looking to see which of its tools might be able to add enrichment to
    the investigation.
    
    You need to read the documentation for all the details, but this demo will
    give you the basics of why this framework has worked well for me."
next 1
splashPage 1
    
Write-Host -f GREEN "
    We'll start with the missile pod (MPOD):"
Write-Host -f GREEN '
    $vf19_MPOD is a hashtable that contains all the default values that MACROSS
    and its tools can access as needed. This is a critical component of how
    MACROSS works! Right now, the contents of $vf19_MPOD are:
    '
foreach($dyrl_i in $vf19_MPOD.Values){
    Write-Host -f YELLOW "        $dyrl_i"
}


Write-Host -f GREEN "
    Oops -- They're encoded! That's done so random people looking at the script
    don't see any obvious things they don't need to see, and to prevent automated
    keyword scanners from snagging IPs and hostnames and such... but do NOT mistake
    base64 encoding for a security feature. Please don't use the framework's
    obfuscation functions to 'secure' your code!"

Write-Host -f GREEN "
    Right now, MACROSS reads its default values from the ncore\utility.ps1 file. That
    file's opening comment section is where you will need to add your own values,
    although you can easily change the at-rest location of MPOD's ammo. Instead of the
    utility.ps1 file, maybe you can store these values in a text file on a web server
    that you control, for instance (see the startUp function in ncore\display.ps1)."

next
splashPage 1

Write-Host -f GREEN "    How to set your own default values:
      1. Take any filepaths or URLs (or anything else) you might need MACROSS or your
         scripts to reference regularly, and encode each into its own Base64 string.
         MACROSS' main menu has a function to do that for you -- just type 'enc' as
         your selection.
      2. Add a 3-letter identifier to the front of your encoded value. This is your
         index. Two indexes are already in use -- 'tbl' and 'nre'. They are used to
         set the location of the \resources folder and the location of the master
         MACROSS repository, respectively (which you'll need to set yourself if you want
         to use it). If you view the MACROSS.ps1 file, you'll see entries like
         "
         Write-Host '                  getThis $vf19_MPOD["nre"]'
         Write-Host -f GREEN '
         where "nre" is the index of the string that MACROSS needs to read in order to
         decode the location of the repository.'
         Write-Host -f GREEN "
      3. Next you need to edit " -NoNewline;
        Write-Host -f YELLOW "utility.ps1" -NoNewline;
        Write-Host -f GREEN " and add a '@@@' to the end of whatever the
         last opening comment line is, then append your encoded value after it. It
         doesn't matter where you start a new line -- you could put everything
         on line 4 if you want to, but you MUST separate each new string with a
         '@@@', and the closing comment '#>' must be left alone. Don't add anything
         in front of it otherwise MACROSS will get confused!
      4. MACROSS automatically stores everything from utility.ps1's opening comments
         in a hashtable called " -NoNewline;
Write-Host '$vf19_MPOD' -NoNewline;
Write-Host -f GREEN '. Your indexes will let your scripts pull
         these values out whenever you need them. To get your plaintext value...
      5. Obfuscated strings are decoded using the ' -NoNewline;
      Write-Host -f YELLOW 'getThis' -NoNewline;
      Write-Host -f GREEN ' function. You can use this
         function in your own scripts. Call it with your encoded base64 value as the
         first parameter, or if decoding hex, make your hex value the first parameter
         and 1 your second parameter.
         '
         Write-Host '              getThis $b64' -NoNewline;
         Write-Host -f GREEN "    ## decodes base64"
         Write-Host '              getThis $hex 1' -NoNewline;
         Write-Host -f GREEN "  ## decodes hexadecimal"
            
      Write-Host -f GREEN '
         The plaintext value gets stored as $vf19_READ. You may only need to use the
         decoded value once, but if you need it persistently, make sure to store it
         as a new variable before the getThis function is executed again!'
next
splashPage 1
Write-Host -f GREEN "    After reading utility.ps1, MACROSS sets its *global* default filepaths:"
Write-Host -f GREEN '
        -$vf19_TOOLSDIR = the local \nmods folder, where your automation scripts will be
            located
        -vf19_DEFAULTPATH = the path to the' -NoNewline;
Write-Host -f GREEN " user's desktop, currently:"
Write-Host "                $vf19_DEFAULTPATH"
Write-Host -f GREEN '        -$vf19_MPOD = an array/hashtable of string-indexed values that are Base64 encoded;
            the primary values stored in this array by default are URLs or IP addresses
            regularly accessed by your scripts (explained on the previous screen).
        -$vf19_TABLES = the filepath to the directory containing resources that can
            enrich your scripts; GUBABA.ps1 demonstrates this by using a json file in
            $vf19_TABLES to perform ID lookups
        -$vf19_REPO = the URL/filepath to where your master MACROSS files will be located
            (optional; this is meant to ensure up-to date copies get pushed to everyone)
        -$vf19_numchk = a hard-coded integer that can be used for common math functions
        -$vf19_M = an array of digits created by splitting $vf19_numchk, used for more
            mathing or obfuscation
        -Add your own default filepaths as needed so all your scripts can use them!'
Write-Host -f GREEN "
    If you need to decode a default value for your scripts from MPOD, use the " -NoNewline;
Write-Host -f YELLOW "getThis"
Write-Host -f GREEN '    function, like so:
'
Write-Host -f YELLOW "
        getThis " -NoNewline;
Write-Host -f CYAN '$vf19_MPOD["ger"]'
Write-Host -f GREEN '        ^^That command decoded the "ger" index to this value:'
getThis $vf19_MPOD['ger']
Write-Host "                 $vf19_READ"

Write-Host -f GREEN '
    ...which is stored in the variable ' -NoNewline;
    Write-Host '$vf19_READ' -NoNewline;
Write-Host -f GREEN ". Again, if you need to make use of that
    value more than once, you'll need to store it in another variable because it gets
    overwritten everytime " -NoNewline;
    Write-Host -f YELLOW "getThis" -NoNewline;
    Write-Host -f GREEN ' is called.'

if( Test-Path "$vf19_TOOLSDIR\GUBABA.ps1" ){
Write-Host -f GREEN "
    Next, I'll briefly explain script tagging, then we'll do a quick demo on jumping between
    MACROSS scripts.
    "
next
splashPage 1


while($dyrl_Z -notMatch "[\w]"){
Write-Host -f GREEN "
    Another part of the MACROSS framework is standardized tagging in your scripts. The first
    three lines of ***every*** MACROSS script should contain identifying info:

        first line = a brief description that gets written to the menu
        second line = the script version number
        third line = the class attributes of a script
        
    There is a custom powershell class called --you guessed it-- 'macross'. It enables
    MACROSS to track key details of each script in another hashtable called " -NoNewline;
Write-Host '$vf19_ATTS' -NoNewline;
Write-Host -f GREEN ".
    
    Let's explore this with GUBABA. GUBABA is a powershell script that acts as an offline Windows
    Event reference for when you're looking at some random log and you see an Event ID but have no
    idea what it means, or you want to start a threat-hunt based on Event IDs for particular
    activities. You can take a look at any MACROSS script's attributes by reading the " -NoNewline;
    Write-Host -f GREEN '$vf19_ATTS' -NoNewline;
    Write-Host -f GREEN "
    hashtable and using the toolInfo method,  " -NoNewline;
    Write-Host '$vf19_ATTS[$tool].toolInfo()
    '

$varc0 = [regex]"^\$.+\.tool[i|I]nfo..$"
while($varc1 -notMatch $varc0){
    Write-Host -f GREEN '
    Type the above command, but replace $tool with "gubaba" (include quotes).
    >  ' -NoNewline;
    $varc1 = Read-Host
    if($varc1 -Match "\s"){
        $varc1 = ''
    }
    if($varc1 -eq ''){
        Break
    }
    else{
        $choice = $varc1 -replace "^.+\[(`'|`")" -replace "(`'|`")\].*$"
        $choice_eval = $vf19_ATTS[$choice].valtype
        iex "$varc1" | %{Write-Host -f YELLOW "      $_"}
        Write-Host -f GREEN "
    As you can see from the 'Evaluates:' field, $choice works with $choice_eval."
    }
}

    Remove-Variable -Force varc*

    next
    splashPage 1
    Write-Host -f GREEN "
    Play with this in MACROSS' debug menu to figure out how your script can quickly find
    other scripts to interact with, via these class attributes. Just type"
    Write-Host '
    debug <any powershell command string>'
    Write-Host -f GREEN "
    ('debug' is not listed on the main menu, it's just for the script writers to use)

    This little snippet would find any MACROSS scripts that can accept IP addresses for
    for blacklisting or searching:"
    Write-Host '
 debug $vf19_ATTS.keys | %{if($vf19_ATTS[$_].valtype -like "*IPs*"){$vf19_ATTS[$_].name}}'
    Write-Host -f GREEN "
    The 'classes.ps1' file contains all the details on what attributes need to get passed
    from your scripts, and in what order. You can also look at all the scripts in the nmods
    folder included in this github release to get a rough idea of how this all works.
    
    Now, back to GUBABA."
    next
    splashPage 1
    Write-Host -f GREEN "
    Give me an ID like '5157' or keywords like 'windows firewall', and we'll ask GUBABA
    if he can find it.
        > " -NoNewline;
$dyrl_Z = Read-Host
Remove-Variable -Force choice*
}

Write-Host -f GREEN "
    Okay, now we pass the the name of this script (HIKARU) over to MACROSS' built-in
    collab function, (which is in the validation.ps1 file). You've set " -NoNewline;
Write-Host -f YELLOW "$dyrl_Z
    " -NoNewline;
Write-Host -f GREEN 'as ' -NoNewline;
Write-Host '$PROTOCULTURE.'
Write-Host -f GREEN '
    Part of the MACROSS framework dictates that when you write collaborative scripts,
    they need to

        1) Set their current result/IOC as the global variable $PROTOCULTURE, and
        2) They need to have functions that act on $PROTOCULTURE whenever it
            exists
    
    Now all we need to do is specify the caller and the callee, and GUBABA will respond
    with any results he finds from your terms after you hit ENTER:
    '
Write-Host '        $searchID = collab "GUBABA.ps1" "HIKARU"'
Read-Host

$Global:PROTOCULTURE = $dyrl_Z

$searchID = collab 'GUBABA.ps1' 'HIKARU'


splashPage 1
''
''
if($searchID.count -gt 0){
    screenResults "derp                       GUBABA RESULTS FOR $dyrl_Z"
    $searchID.keys | %{
        screenResults $_ $searchID[$_]
    }
}
else{
    screenResults "derpy               Nothing found for $dyrl_Z"
}
screenResults 'endr'
Write-Host -f GREEN "
    In practice, I've just used GUBABA by itself and never had a reason for my automations
    to pass queries to it. So let's do something a little more useful (hopefully you have
    the MINMAY script in your tools; if not, the demo will skip her)."

if($MONTY -and (Test-Path "$vf19_TOOLSDIR\MINMAY.py")){
    Write-Host -f GREEN "
    Real quick, let's show that you can also tie your python scripts into this framework
    by sending some new values over to MINMAY. We'll simulate a new investigation. Hit
    ENTER to select a file from somewhere in your Desktop or Documents, we'll pretend it's
    malware or an exfil document or something:"
    Read-Host
    $Global:PROTOCULTURE = getFile
    if($PROTOCULTURE -eq ''){
        while($PROTOCULTURE -eq ''){
            Write-Host -f GREEN '
            Hmm, okay, just type in a filename, then: '
            $Global:PROTOCULTURE = Read-Host
            if( $PROTOCULTURE -eq '' ){
                Write-Host -f CYAN "
    Wow, you really don't want to provide a file huh? Unfortunately, the demo won't
    work without it, so we'll go ahead and close early. Hit ENTER to exit, and thanks
    for taking MACROSS for a spin!"
                Read-Host
                Exit
            }
        }
    }
    splashPage 1
    Write-Host -f GREEN "
    MACROSS handles setting up many of its resources in python for you. All you need to
    do is supply the filename of the script you need to call, the name of your running
    script, in this case... " -NoNewline;
    Write-Host -f YELLOW 'HIKARU' -NoNewline;
    Write-Host -f GREEN ',' -NoNewline;
    Write-Host -f GREEN " and the 'PROTOCULTURE' value, in this case
    "
    Write-Host -f YELLOW "      $PROTOCULTURE"
    Write-Host -f GREEN "
    ...to MACROSS' collab function (PROTOCULTURE gets sent automatically):"
    Write-Host '
                  collab  "MINMAY.py"  "HIKARU"
    '
    Write-Host -f GREEN "
    
    Using the 'collab' function ensures MACROSS resources get shared with python tools,
    though you will need to do the work of importing the MACROSS python library.
    For this part of the demo, we'll have MINMAY explain what she does with stuff you pass
    into python (and she goes into a little more detail if you launch her by herself)."
    next
    
    transitionSplash 5

    collab 'MINMAY.py' 'HIKARU' $PROTOCULTURE

    read-host '...'
    splashPage
    Write-Host -f GREEN "
    And now we're back with HIKARU... again!
    MACROSS' \ncore folder contains a subfolder called 'py_classes' where you can
    store any custom classes or libraries you want for your python scripts. Run MINMAY
    again later for a little more detail, or go read the notes inside mcdefs.py"
}

Write-Host -f GREEN '   
    In other scenarios, the scripts we jump to could potentially have returned results for
    us to further manipulate and investigate in ' -NoNewline;
    Write-Host '$HOWMANY' -NoNewline;
    Write-Host -f GREEN ' (the number of successful search
    results) and ' -NoNewline;
    Write-Host '$RESULTFILE' -NoNewline;
    Write-Host -f GREEN ' (any file your script generates that can be passed to other
    scripts for manipulation, refinement; example txt, log, JSON, etc.).
    '
    if( Test-Path "$vf19_GBIO\konig.eod" ){
        $fp = $(gc "$vf19_GBIO\konig.eod" | Select -Index 0)
        Write-Host -f GREEN "    For example, this script (HIKARU) knows " -NoNewline;
        Write-Host -f GREEN "that"
        Write-Host -f YELLOW "        $fp"
        Write-Host -f GREEN "    is your KÖNIG report retrieved by MINMAY, so if we needed to, we could grab it to read
    or edit however we wanted."
    }

}
else{
    next
    splashPage 1
    Write-Host -f GREEN '    The key to making MACROSS valuable is writing your scripts to be able
    to interact with each other. ' -NoNewline;
    Write-Host '$HOWMANY' -NoNewline;
    Write-Host -f GREEN ' keeps track of successful results
    from the previous task, ' -NoNewline;
    Write-Host '$PROTOCULTURE' -NoNewline;
    Write-Host -f GREEN ' is the value currently being
    investigated & shared between scripts. And ' -NoNewline;
    Write-Host '$RESULTFILE' -NoNewline;
    Write-Host -f GREEN ' is the current
    text file being used to record your findings, which can get passed around
    to scripts or functions for any kind of manipulation necessary to generate
    reports or JSON or anything else required.'
    Write-Host -f GREEN "    I've included one of my API automations for Carbon Black, an EDR
    product that monitors host processes and users, mainly as an example of
    how I've tied scripts and APIs together in my own work. 'Let me investigate
    the IP in this alert... okay, show me AD info for the user logged into that
    host... now let's see what process made the network connection to that IP...'
    You get the idea. Keeping it all within powershell can be less aggravating
    than jumping into several web tabs when you just want a couple of quick
    data points.
    "
}
    Write-Host -f GREEN '
    Oh, one more thing to note is make sure the ' -NoNewline;
    Write-Host '$vf19_DEFAULTPATH' -NoNewline;
    Write-Host -f GREEN " variable gets set correctly
    in your environment -- this is the path to your user's desktop where " -NoNewline;
    Write-Host '$RESULTFILE' -NoNewline;
    Write-Host -f GREEN ' will
    typically write to. See the ' -NoNewline;
    Write-Host -f YELLOW 'setUser ' -NoNewline;
    Write-Host -f GREEN 'function in the validation.ps1 file.'
    next
    splashPage 1

    Write-Host -f GREEN '
    The demo is about done, but first a quick breakdown of the MACROSS framework:
        -Shared utilities, most of which are in the utility.ps1 file -- make
            sure to read its documentation!
        -Global investigation values -- your scripts should be able to
            automatically recognize $CALLER, $PROTOCULTURE, $RESULTFILE, and
            $HOWMANY... but be careful not to lose track of things if you jump
            between multiple scripts!!
        -Shared default values -- stored encoded in utility.ps1
        -Magic lines -- the first three lines of each script are reserved for
            info that MACROSS expects to be available
        -Custom class -- you can design your scripts to scan the attributes
            of other scripts listed in $vf19_ATTS to quickly make collab calls
            to the ones most relevant
        -Standardized variable naming to avoid crossing the streams'
    next
    splashPage 1
    Write-Host '
             IMPORTANT VARS (available to all MACROSS tools):
    $vf19_TOOLSROOT - the directory MACROSS is run from
    $vf19_TOOLSDIR - the location of the nmods folder
    $vf19_MPOD - the array storing base64-encoded default values (this is
        a value you need to configure)
    $vf19_PYOPT - same as previous, but formatted so python can ingest it
        (MACROSS does this for you automagically)
    $vf19_numchk - a hardcoded 6-digit number for performing math
        without plaintext numbers, like obscuring IP addresses or
        generating hexadecimal values (you can change this to be whatever
        integer you want in the MACROSS.ps1 file, or better yet, have this
        value read from an external location.)
    $vf19_M - an array created by splitting $vf19_numchk for more mathing
        (MACROSS generates this for you automagically)
    $vf19_READ - the last plaintext value decoded/encoded by the getThis function
    $vf19_REPO - the location of your MACROSS master copies; MACROSS
        itself keeps track of all script versions so long as you mark them
        appropriately (this is a value you need to set within $vf19_MPOD["nre"])
    $HOWMANY - successful results from the previous task; you can increment this
        across scripts
    $RESULTFILE - a file generated by any given script that can be passed
        to other scripts
    $PROTOCULTURE - the primary value that gets passed from one script to another
        for eval/investigation
        '

    next
    splashPage 1

    Write-Host -f GREEN '    My uses for this framework involved sharing the ' -NoNewline;
    Write-Host '$PROTOCULTURE' -NoNewline;
    Write-Host -f GREEN ',' -NoNewline;
    Write-Host ' $HOWMANY' -NoNewline;
    Write-Host -f GREEN ',
    and ' -NoNewline;
    Write-Host '$RESULTFILE' -NoNewline
    Write-Host -f GREEN " variables between several scripts at will so analysts could
    grab details on any particular thing they were investigating --users, servers,
    files downloaded from the internet, whatever-- and then easily pivot to other
    searches using the information they found. And by using the 'collab' function,
    an additional value can be sent along to any script for added evals, if you
    include instructions to look for parameters that are not equal to PROTOCULTURE's
    value."
    Write-Host -f GREEN '
    Your existing automations can easily be plugged into MACROSS with a few modifications:
        1. Add the "magic comments" to the first three lines of your script
        2. If you want to interact with other scripts in the framework, add checks to
           look for $PROTOCULTURE, and to generate $PROTOCULTURE that you can send to the
           "collab" function
        3. If your automation is written in python, use sys.argv to read the default values
           MACROSS always sends to python scripts.'
    Write-Host -f GREEN "
    Even if you don't have many security tools/APIs on your network, what you probably
    DO have is Active Directory. MACROSS can provide an immediate key-press for your
    security team to quickly collect data, if you don't mind putting in the work to
    script it! I have a few tools included here that I used extensively in customer
    networks, but it's really better if you build your own from the ground up and
    incorporate the framework as you go.

    Also, don't overlook MACROSS' built-in utilities! Things like the " -NoNewline;
    Write-Host -f YELLOW 'houseKeeping' -NoNewline;
    Write-Host -f GREEN '
    function, which checks for stale reports generated by your scripts so the user
    can delete them, the ' -NoNewline;
    Write-Host -f YELLOW 'varCleanup' -NoNewline;
    Write-Host -f GREEN " function which you can tweak to manage all the
    variables that are shared by the various scripts within the console, or
    " -NoNewline;
    Write-Host -f YELLOW 'screenResults' -NoNewline;
    Write-Host -f GREEN ", which can prettify your outputs onscreen by formatting them into a
    colorized table. And of course, if no scripts are active, the main menu will alert
    you when PROTOCULTURE still contains an active value so you can choose to delete it
    if it's no longer needed.

    Be sure to read the detailed notes provided to take full advantage of MACROSS. Get
    creative with linking your automations together to give your SOC a huge advantage
    in defending your networks!

    Hit ENTER to exit this demo.
    "
Read-Host
}
Exit
