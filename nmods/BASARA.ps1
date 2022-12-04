#_wut Demo - a basic config walkthru
#_ver 0.1

<#
    Author: HiSurfAdvisory

    Simple explanation of how MACROSS connects automation
    scripts together to enrich active directory searches
    or API calls.

#>

function splashPage(){
    cls
    $b = 'ICAgICAgICDilojilojilojilojilojilojilZcgIOKWiOKWiOKWiOKWiOKWiOKVlyDilojiloj
    ilojilojilojilojilojilZcg4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKVlyAg
    4paI4paI4paI4paI4paI4pWXIAogICAgICAgIOKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVl
    OKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKVkOKVkOKVneKWiOKWiOKVlOKVkOKVkOKWiOKWiO
    KVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVlwogICAgICAgIOK
    WiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKW
    iOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKWi
    OKWiOKWiOKWiOKWiOKWiOKWiOKVkQogICAgICAgIOKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiO
    KVlOKVkOKVkOKWiOKWiOKVkeKVmuKVkOKVkOKVkOKVkOKWiOKWiOKVkeKWiOKWiOKVlOKVkOKVkOKWiOK
    WiOKVkeKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVkQogICAgICAg
    IOKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVkSAg4paI4paI4pWR4paI4paI4paI4paI4paI4
    paI4paI4pWR4paI4paI4pWRICDilojilojilZHilojilojilZEgIOKWiOKWiOKVkeKWiOKWiOKVkSAg4p
    aI4paI4pWRCiAgICAgICAg4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWdIOKVmuKVkOKVnSAg4pWa4pWQ4pWd4pW
    a4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ3ilZrilZDilZ0gIOKVmuKVkOKV
    neKVmuKVkOKVnSAg4pWa4pWQ4pWdCiAgICAgID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09P
    T09PT09PT09PT09PT09PT09PT0='
    getThis $b
    Write-Host '
    '
    Write-Host -f YELLOW $vf19_READ
    Write-Host -f CYAN   '                  A demo of MACROSS automations
    
    '
    
}

if($HELP){
  disVer 'BASARA'
  splashPage
  Write-Host "
                          Example script version $VER
      ======================================================================
  This script is a simple walkthru on how to use the MACROSS framework to connect
  your scripts together. The main goal of MACROSS is to give even your most
  junior analysts the ability to get as much information as quickly and easily as
  any crusty ol' command-line junkie -- on a budget!
  
  Hit ENTER to continue.
  "
  Read-Host
  Exit
}

function next(){
    Write-Host -f GREEN "
    Hit ENTER to continue!
    "
    Read-Host
}


transitionSplash 1
splashPage

Write-Host -f GREEN '    Welcome to MACROSS! This quick guide should get you started on combining
    your custom scripts together for your team to use with ease! FYI, this is
    aimed at folks who know how to write powershell automations and perform
    regular string-manipulations, to give you a headstart on building something
    useful for your SOC teams that is designed around your environment.'
Write-Host -f GREEN "
    You might have noticed an error when you first started this script, something
    about disabling update checks. That's because a default master repo hasn't
    been specified yet. MACROSS is capable of version control(-ish) automatic
    updates. This doesn't necessarily need to be configured, but it enables
    pushing out the newest scripts and latest versions to keep everyone using
    the same stuff."
next
splashPage
    
Write-Host -f GREEN "    Here's how it's done:"
Write-Host -f GREEN '
    The default filepath variables are set in an array called $vf19_MPOD.
    This is a critical component of MACROSS - and not just for updates!
    Right now, its contents are:
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
    By default, MACROSS reads its default variables beginning from line 4 in the
    extras.ps1 file. That file's opening comment section is where you will
    need to add your own values."

next
splashPage

Write-Host -f GREEN "    How to use your own default variables:
      1. Take any filepaths or URLs you might need MACROSS or your scripts to
         reference regularly, and encode each into its own Base64 string. MACROSS'
         main menu has a function to do that for you -- just type 'enc' as your
         selection.
      2. Add a 3-letter identifier to the front of your encoded value. This is
         your index. Some indexes like 'tbl' are already reserved ('tbl' is the
         index where your custom resource files will be located), so be careful!
         Reserved indexes are referenced in the " -NoNewline;
         Write-Host -f YELLOW "MACROSS.ps1" -NoNewline;
         Write-Host -f GREEN " file, as well as the
         setUser function, which is in the " -NoNewline;
         Write-Host -f YELLOW "validation.ps1" -NoNewline;
         Write-Host -f GREEN " file. Look for instances of
         'getThis' being used. The setUser function performs tasks that restrict
         who can use your scripts, and is entirely optional, so if you're not
         planning to make use of it you don't need to worry about its reserved
         indexes.
      3. Next you need to open " -NoNewline;
        Write-Host -f YELLOW "extras.ps1" -NoNewline;
        Write-Host -f GREEN " and add a '@@@' to the end of whatever
         the last comment line is, then append your encoded value after it. It
         doesn't matter where you start a new line -- you could put everything
         on line 4 if you want to, but you MUST separate each new string with a
         '@@@', and the closing comment '#>' must be left alone. Don't add anything
         in front of it otherwise MACROSS will get confused!
      4. MACROSS automatically stores everything from extras.ps1's opening comments
         in an array called " -NoNewline;
Write-Host '$vf19_MPOD' -NoNewline;
Write-Host -f GREEN ".
      5. Obfuscated strings are decoded using the " -NoNewline;
      Write-Host -f YELLOW 'getThis' -NoNewline;
      Write-Host -f GREEN ' function. You can use this
         function in your own scripts. Call it with your encoded base64 value as the
         first parameter, or if decoding hex, make your hex value the first parameter
         and 1 your second parameter.
         '
         Write-Host '         getThis $b64' -NoNewline;
         Write-Host -f GREEN "    ## decodes base64"
         Write-Host '         getThis $hex 1' -NoNewline;
         Write-Host -f GREEN "  ## decodes hexadecimal"
            
      Write-Host -f GREEN '
         The plaintext value gets stored as $vf19_READ. Make use of it before getThis
         is called again!'

Write-Host -f GREEN "
    MACROSS then sets its default filepaths in the following examples."

next
splashPage

Write-Host -f GREEN "    MACROSS' default variables:"
Write-Host -f GREEN '
        -$vf19_TOOLSDIR is the local "nmods" folder, where your automation scripts &
            custom utilities will be located
        -$vf19_MPOD is an array/hashtable of string-indexed values that are Base64 encoded;
            the primary values stored in this array by default are URLs or IP addresses
            regularly accessed by your scripts (explained on the previous screen).
        -$vf19_TABLES is the filepath to the directory containing resources that can
            enrich your scripts; GUBABA.ps1 demonstrates this by using a text file in
            $vf19_TABLES to perform ID lookups
        -$vf19_REPO is the URL/filepath to where your master MACROSS files will be located
        -$vf19_numchk is a hard-coded integer that can be used for common math functions
        -$vf19_M is an array of digits created by splitting $vf19_numchk, used for more
            mathing
        -Add your own default filepaths as needed so all your scripts can use them!'
Write-Host -f GREEN "
    If you need to decode the value for your scripts, use the " -NoNewline;
Write-Host -f YELLOW "getThis" -NoNewline;
Write-Host -f GREEN ' function, like so:
           '
Write-Host -f YELLOW "
    getThis " -NoNewline;
Write-Host -f CYAN '$vf19_MPOD["tbl"]'
Write-Host -f GREEN "    ^^That command decoded the 'tbl' index to this value ->"
getThis $vf19_MPOD['tbl']
Write-Host "
        $vf19_READ"

Write-Host -f GREEN '
    ...which is stored in the variable ' -NoNewline;
    Write-Host '$vf19_READ' -NoNewline;
Write-Host -f GREEN ". If you need to make use of that value
    more than once, you'll need to store it in another variable because it gets rewritten
    everytime " -NoNewline;
    Write-Host -f YELLOW "getThis" -NoNewline;
    Write-Host -f GREEN ' is called.'
Write-Host -f YELLOW "
        getThis " -NoNewline;
Write-Host -f CYAN '$vf19_MPOD["tbl"]'
Write-Host '        $my_var = $vf19_READ'

if( Test-Path "$vf19_TOOLSDIR\SDF1.ps1" ){
Write-Host -f GREEN "
    Next, we'll do a quick demo on jumping between MACROSS scripts.
    "
next
cls

while($dyrl_Z -notMatch "^[0-9.]+$"){
Write-Host -f GREEN "
 Enter an IP address to see how you can interact with the SDF1 scanner: 
   > " -NoNewline;
 $dyrl_Z = Read-Host
}

Write-Host -f GREEN '
    Okay, now we set the ' -NoNewline;
Write-Host '$CALLER' -NoNewline;
Write-Host -f GREEN ' variable as the name of this script (BASARA),'
Write-Host -f GREEN "    and you've set " -NoNewline;
Write-Host -f YELLOW "$dyrl_Z" -NoNewline;
Write-Host -f GREEN ' as ' -NoNewline;
Write-Host '$PROTOCULTURE' -NoNewline;
Write-Host -f GREEN '. This is a *globally* set
    variable that all scripts can make use of during investigations.'
Write-Host -f GREEN "
    Both of these values will now be sent to my SDF1 script, using
    MACROSS' built-in " -NoNewline;
Write-Host -f YELLOW 'collab' -NoNewline;
Write-Host -f GREEN ' function (which is in the validation.ps1 file)
    as soon as you hit ENTER.'
Read-Host
$Global:CALLER = 'BASARA'
$Global:PROTOCULTURE = $dyrl_Z

collab 'SDF1.ps1' $CALLER $PROTOCULTURE

splashPage
$Global:CALLER = 'BASARA'
Write-Host -f GREEN "    And now we're back with BASARA!"

if($MONTY -and (Test-Path "$vf19_TOOLSDIR\MAX.py")){
    Write-Host -f GREEN "
    Real quick, let's show that you can also tie your python scripts
    into this framework by sending these same values over to my
    MAX (Jenius) python script.
    
    MACROSS handles passing many of its shared resources into python for
    you. All you need to do is supply the filename of the script you
    need to call, the 'CALLER' variable (which is the name of your
    current script, in this case " -NoNewline;
    Write-Host -f YELLOW "$CALLER" -NoNewline;
    Write-Host -f GREEN "), and the 'PROTOCULTURE' value,
    in this case " -NoNewline;
    Write-Host -f YELLOW "$PROTOCULTURE" -NoNewline;
    Write-Host -f GREEN ", to MACROSS' collab function:"
    Write-Host '
        collab "MAX.py" $CALLER $PROTOCULTURE
    '
    Write-Host -f GREEN "
    Using the 'collab' function ensures MACROSS resources get shared with
    python tools, though you will need to do the work of importing the
    MACROSS python library.

    For this example, we'll have MAX.py do a quick lookup on the IP
    you just scanned."
    next
    cls


    $global:vf19_TABLES = 'C:\Users\kamue\Documents\MACROSS\resources'  # delete when done

    collab 'MAX.py' $CALLER $PROTOCULTURE

 #python3 "$vf19_TOOLSDIR\MAX.py" $USR $vf19_DEFAULTPATH $vf19_PYOPT $vf19_numchk $vf19_pylib $vf19_TABLES $CALLER $PROTOCULTURE
    
    splashPage
    Write-Host -f GREEN "
    And now we're back with BASARA... again!

    MACROSS' nmods folder contains a subfolder called 'py_classes'
    where you can store any custom libraries you want for your python
    scripts."
}

Write-Host -f GREEN '   
    In other scenarios, the scripts we jump to could potentially
    have returned results for us to further manipulate and
    investigate in ' -NoNewline;
    Write-Host '$HOWMANY' -NoNewline;
    Write-Host -f GREEN ' (the number of successful search
    results) and ' -NoNewline;
    Write-Host '$RESULTFILE' -NoNewline;
    Write-Host -f GREEN ' (any file your script generates
    that can be passed to other scripts for manipulation,
    refinement; example txt, log, JSON, etc.).
    '
    Write-Host -f GREEN "    For example, this script (BASARA) knows " -NoNewline;
    if( $RESULTFILE ){
        Write-Host -f GREEN "that"
        Write-Host -f YELLOW "        $RESULTFILE"
        Write-Host -f GREEN "    is your SDF1 report and " -NoNewline;
    }
    Write-Host -f GREEN 'MAX gave you '
    Write-Host -f YELLOW "                    $HOWMANY"
    Write-Host -f GREEN '    successful hits.'

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
    Write-Host -f GREEN "
    variable gets set correctly in your environment -- this is the
    path to your user's desktop where " -NoNewline;
    Write-Host '$RESULTFILE' -NoNewline;
    Write-Host -f GREEN ' will typically 
    write to. See the ' -NoNewline;
    Write-Host -f YELLOW '    setUser ' -NoNewline;
    Write-Host -f GREEN 'function in the validation.ps1 file.'
    Write-Host -f GREEN '
    Right now, your $vf19_DEFAULTPATH is set to:'
    Write-Host "        $vf19_DEFAULTPATH"
    next
    splashPage

    Write-Host '

             IMPORTANT VARS (all MACROSS tools share these):
    $vf19_TOOLSROOT - the directory MACROSS is run from
    $vf19_TOOLSDIR - the location of the nmods folder
    $vf19_MPOD - the array storing base64-encoded default values
    $vf19_PYOPT - same as previous, but formatted so python can ingest it
    $vf19_numchk - a hardcoded 6-digit number for performing math
        without plaintext numbers, like obscuring IP addresses
    $vf19_M - an array created from splitting $vf19_numchk for more maths
    $vf19_READ - the last plaintext value decoded/encoded by the getThis function
    $vf19_REPO - the location of your MACROSS master copies; MACROSS
        itself keeps track of all script versions so long as you mark them
        appropriately
    $HOWMANY - successful results from the previous task; you can increment this
        across scripts
    $RESULTFILE - a file generated by any given script that can be passed
        to other scripts
    $PROTOCULTURE - the primary value that gets passed from one script to another for
        eval/investigation
        '

    next
    splashPage

    Write-Host -f GREEN '    My uses for this framework involved sharing the ' -NoNewline;
    Write-Host '$PROTOCULTURE' -NoNewline;
    Write-Host -f GREEN ','
    Write-Host '    $HOWMANY' -NoNewline;
    Write-Host -f GREEN ', and ' -NoNewline;
    Write-Host '$RESULTFILE' -NoNewline;
    Write-Host -f GREEN " variables between several scripts
    at will to give analysts the ability to grab details on any
    particular thing they were investigating -- users, servers,
    files downloaded from the internet, whatever -- and then
    easily pivot to other searches using the information they
    found.

    Even if you don't have alot of security tools on your network,
    what you probably DO have is Active Directory. MACROSS can
    provide a one-stop shop for your security team to quickly
    collect data, if you don't mind putting in the work to script
    it! I have a few tools included here that I used extensively
    in customer networks, but it's really better if you build your
    own from the ground up and incorporate the framework as you go.

    Also, don't overlook MACROSS' built-in functions! Things
    like the " -NoNewline;
    Write-Host -f YELLOW 'houseKeeping' -NoNewline;
    Write-Host -f GREEN ' function, which checks for stale
    reports generated by your scripts so the user can delete
    them, or the ' -NoNewline;
    Write-Host -f YELLOW 'varCleanup' -NoNewline;
    Write-Host -f GREEN " function which you can tweak to
    manage all the variables being shared by the various
    scripts within the console.

    Be sure to read the detailed notes provided to take full
    advantage of MACROSS. Get creative with linking your automations
    together to give your SOC a huge advantage in defending your
    networks!

    Hit ENTER to exit this demo.
    "
Read-Host
Exit
