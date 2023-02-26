#_superdimensionfortress Demo - a basic config walkthru (7-10 mins)
#_ver 0.2
#_class User,demo script,Powershell,HiSurfAdvisory,0

<#
    Author: HiSurfAdvisory

    This script is a simple demonstration of collecting information
    from one script and passing it others that could add more detail
    or uncover more indicators related to your SOC investigations.

#>

function splashPage(){
    cls
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
    Write-Host -f CYAN   '                  A demo of MACROSS automations
    
    '
    
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
  automations.
  
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


transitionSplash 8
splashPage

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

    For instance, MACROSS is capable of version control(-ish) automatic updates.
    If you have multiple APIs or automations that require an occasional change,
    this lets you modify just the master copies, which MACROSS will then push out
    to whoever is using the old versions.
    
    You need to read the documentation for all the details, but this demo will
    give you the basics of why this framework has worked well for me."
next 1
splashPage
    
Write-Host -f GREEN "    We'll start with the missile pod (MPOD):"
Write-Host -f GREEN '
    The default values I want to be common-use for *all* the tools are set in an
    array called $vf19_MPOD. This is a critical component of MACROSS - and not just
    for updates! Right now, its contents are:
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
    By default, MACROSS reads its default values from the ncore\utility.ps1 file.
    That file's opening comment section is where you will need to add your own values,
    although you can easily change the at-rest location of MPOD's ammo... maybe to a
    text file on a web server that you control, for instance (see the startUp function
    in display.ps1."

next
splashPage

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
splashPage
Write-Host -f GREEN "    MACROSS then sets its *global* default filepaths:"
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
            enrich your scripts; GUBABA.ps1 demonstrates this by using a text file in
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
Write-Host -f GREEN '    function, like so:'
Write-Host -f YELLOW "
        getThis " -NoNewline;
Write-Host -f CYAN '$vf19_MPOD["tbl"]'
Write-Host -f GREEN "        ^^That command decoded the 'tbl' index to this value ˉ˥"
Write-Host -f GREEN '                                                              |'
Write-Host -f GREEN '                                                              ˅'
getThis $vf19_MPOD['tbl']
Write-Host "                                                       $vf19_READ"

Write-Host -f GREEN '
    ...which is stored in the variable ' -NoNewline;
    Write-Host '$vf19_READ' -NoNewline;
Write-Host -f GREEN ". Again, if you need to make use of that
    value more than once, you'll need to store it in another variable because it gets
    rewritten everytime " -NoNewline;
    Write-Host -f YELLOW "getThis" -NoNewline;
    Write-Host -f GREEN ' is called.'

if( Test-Path "$vf19_TOOLSDIR\GUBABA.ps1" ){
Write-Host -f GREEN "
    Next, I'll briefly explain script tagging, then we'll do a quick demo on jumping between
    MACROSS scripts.
    "
next
cls


while($dyrl_Z -notMatch "[\w]"){
Write-Host -f GREEN "
    Another part of the MACROSS framework is standardized tagging in your scripts. The first
    three lines of _every_ MACROSS script should contain identifying info:

        first line = a brief description that gets written to the menu
        second line = the script version number
        third line = the class attributes of a script
        
    There is a custom powershell class called --you guessed it-- 'macross'. It enables
    MACROSS to track key details of each script in another hashtable called " -NoNewline;
Write-Host '$vf19_ATTS' -NoNewline;
Write-Host -f GREEN ".
    
    Let's explore this with GUBABA. It's powershell script that acts as an offline Windows Event
    reference for when you're looking at some random log and you see an Event ID but have no
    idea what it means, or you want to find out what the event ID is for a specific kind of event.

    You can take a look at any MACROSS script's attributes by reading the " -NoNewline;
    Write-Host -f GREEN '$vf19_ATTS' -NoNewline;
    Write-Host -f GREEN " hashtable
    and using the toolInfo method,  " -NoNewline;
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
    else{
        $choice = $varc1 -replace "^.+\['" -replace "'\].*$"
        $choice_eval = $vf19_ATTS[$choice].valtype
    }
}

splashPage
iex "$varc1" | %{Write-Host -f YELLOW "      $_"}
Remove-Variable -Force varc*

Write-Host -f GREEN "
    As you can see from the 'Evaluates:' field, $choice works with $choice_eval.

    Play with this in MACROSS' debug menu to figure out how your script can quickly find
    other scripts to interact with, via these class attributes. Just type"
    Write-Host '
    debug <any powershell command string>'
    Write-Host -f GREEN "
    This little snippet would find any MACROSS scripts that can accept IP addresses for
    for blacklisting or searching:"
    Write-Host '
 debug $vf19_ATTS.keys | %{if($vf19_ATTS[$_].valtype -like "*ips*"){$vf19_ATTS[$_].name}}'
    Write-Host -f GREEN "
    The 'classes.ps1' file contains all the details on what attributes need to get passed
    from your scripts, and in what order. Now, back to GUBABA."
    next
    cls
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
Write-Host '$PROTOCULTURE' -NoNewline;
Write-Host -f GREEN '. This is a *globally* set variable that all scripts can make use of
    during investigations. Because $PROTOCULTURE is a global value, part of the MACROSS
    framework dictates that when you write collaborative scripts, they need to be aware
    and looking for it.
    
    All we need to do is specify the caller and the callee, which will happen when you hit
    ENTER:
    '
Write-Host '        collab "GUBABA.ps1" "HIKARU"'
Read-Host

$Global:PROTOCULTURE = $dyrl_Z

collab 'GUBABA.ps1' 'HIKARU'
read-host

splashPage
Write-Host -f GREEN "
    So, did GUBABA find what you were looking for? In practice, I've just used GUBABA by
    itself and never had a reason for my automations to pass queries to it. So let's do
    something a little more useful (hopefully you have the MINMAY script in your tools...
    if not, the demo will skip her)."

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
    ...to MACROSS' collab function:"
    Write-Host '
                  collab  "MINMAY.py"  "HIKARU"  $PROTOCULTURE
    '
    Write-Host -f GREEN "
    
    Using the 'collab' function ensures MACROSS resources get shared with python tools,
    though you will need to do the work of importing the MACROSS python library.

    For this part of the demo, we'll have MINMAY explain what she does with stuff you pass
    into python (and she goes into a little more detail if you launch her by herself)."
    next
    
    transitionSplash 5

    collab 'MINMAY.py' 'HIKARU' $PROTOCULTURE

    
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
    splashPage
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
    splashPage

    Write-Host -f GREEN '
    This demo is about done, but first a quick breakdown of the MACROSS framework:
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
    splashPage
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
    splashPage

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
    an additional value can be sent along to any script for added evals, if you include
    instructions to look for parameters that are not equal to PROTOCULTURE's value.

    Even if you don't have many security tools/APIs on your network, what you probably
    DO have is Active Directory. MACROSS can provide an immediate key-press for your
    security team to quickly collect data, if you don't mind putting in the work to script
    it! I have a few tools included here that I used extensively in customer networks, but
    it's really better if you build your own from the ground up and incorporate the frame-
    work as you go.

    Also, don't overlook MACROSS' built-in utilities! Things like the " -NoNewline;
    Write-Host -f YELLOW 'houseKeeping' -NoNewline;
    Write-Host -f GREEN ' function,
    which checks for stale reports generated by your scripts so the user can delete them,
    or the ' -NoNewline;
    Write-Host -f YELLOW 'varCleanup' -NoNewline;
    Write-Host -f GREEN " function which you can tweak to manage all the variables being
    shared by the various scripts within the console.

    And of course, if no scripts are active, the main menu will alert you when PROTOCULTURE
    still contains an active value so you can choose to delete it if it's no longer needed.

    Be sure to read the detailed notes provided to take full advantage of MACROSS. Get creative
    with linking your automations together to give your SOC a huge advantage in defending your
    networks!

    Hit ENTER to exit this demo.
    "
Read-Host
Exit
