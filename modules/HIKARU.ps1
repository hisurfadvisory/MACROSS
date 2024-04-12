#_sdf1 Demo - a basic config walkthru (6-8 mins)
#_ver 0.2
#_class user,demo script,powershell,HiSurfAdvisory,0

<#

    This script is a simple demonstration of collecting information
    from one script and passing it others that could add more detail
    or uncover more indicators related to your SOC investigations.
    
    This script requires the file "hikaru_demo.txt" in the resources folder.
#
#>

$dyrl_hik_HD = (Get-Content -Path "$vf19_TOOLSROOT\resources\hikaru_demo.txt") -Split("`n")
function splashPage($1){
    cls
    if($1 -eq 1){
        ''
        screenResults '[macross] Attributes' ' .priv | .valtype | .lang | .auth | .evalmax | .ver | .fname'
        screenResults 'Variables to remember' '$PROTOCULTURE, $CALLER, $RESULTFILE, $vf19_MPOD, $vf19_LATTS $vf19_TABLES'
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
    $vf19_LATTS['HIKARU'].toolInfo() | %{
        Write-Host -f YELLOW $_
    }
    Write-Host "
      ======================================================================
  This script is a simple walkthru on how to use the MACROSS framework to connect
  your scripts together. The main goal of MACROSS is to automate your automations;
  give even your most junior analysts the ability to get as much information as
  quickly and easily as any crusty ol' command-line junkie -- on a budget!
  
  HIKARU explains the rules/guidelines of the framework that help automate your
  automations. It takes about 3 minutes for a quick overview, or you can pick the
  detailed option which takes around 6-8 minutes to go through the basics.
  
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

$dyrl_hik_Z = $null
$K = 'KONIG'
if($N_){ $K = "K$(chr 214)NIG" }

transitionSplash 8
splashPage

while($dyrl_hik_Z -notIn 1..3){
    Write-Host -f GREEN '
        Choose a walk-thru:

        1. Quick & dirty (2-3 mins)
        2. Detailed (6-8 mins)
        3. Quit
    
        > ' -NoNewline;

        $dyrl_hik_Z = Read-Host
        if($dyrl_hik_Z -eq '3'){
            Exit
        }
}

function writeDemo($1){
    getThis $dyrl_hik_HD[$1]
    $a = ([System.Management.Automation.Language.Parser]::ParseInput($vf19_READ, [ref]$null, [ref]$null)).GetScriptBlock()
    Invoke-Command -NoNewScope $a
}


if($dyrl_hik_Z -eq 2){
    splashPage
    writeDemo 0
    
	Read-Host
    splashPage 1
    
    writeDemo 1
    
	Read-Host
    splashPage 1
	
    writeDemo 2
    
	Read-Host
    splashPage 1
    
    writeDemo 3
    
	Read-Host
    splashPage 1
    
    writeDemo 4
    
    Write-Host -f GREEN "
 Give me a keyword or keywords (something a bit more specific than just 'change' or 'SQL'), or an ID like 
 5157, and we'll see what GUBABA comes up with: " -NoNewline;
 $dyrl_hik_Z = Read-Host
 if($dyrl_hik_Z -ne ''){
    $Global:PROTOCULTURE = $dyrl_hik_Z
    $results = collab 'GUBABA.ps1' 'HIKARU'
    if($results.count -gt 0){
        $results.keys | Sort | %{
            screenResults $_ $results[$_]
        }
        screenResults 'endr'
        Write-Host -f GREEN '
 Your automation can now parse these and begin searching log files. But this is a very basic 
 example.'
    }
    else{
        screenResults "red~         No results found for $dyrl_hik_Z"
    }
    rv PROTOCULTURE -Scope Global
 }
    Write-Host -f GREEN '
 Hit ENTER to continue!'
	Read-Host
    splashPage 1
    
    writeDemo 5
    
    Read-Host
    $dyrl_hik_file = getFile
    if($dyrl_hik_file -ne ''){
        writeDemo 6
    }
    else{
        writeDemo 7
    }
    splashPage 1
    writeDemo 8
    next
    splashPage 1
    writeDemo 9
    Read-Host
    Exit
}
elseif($dyrl_hik_Z -eq 1){
    splashPage 1
    Write-Host -f GREEN '
 You have chosen the quick & dirty:

 MACROSS is not a toolset, although it includes several tools you may or may not find useful. 
 It is a <buzzword>"framework"</buzzword> for you to easily chain your custom automations 
 together, and provides some handy functionality to format the outputs from those automations.
 
 "Why is it in powershell?"
 Because I wrote it in an environment where python was not allowed (CISOs, amiright), and most 
 of my initial MACROSS tools dealt with Windows servers and Active Directory anyway.
 
 Your automations go in the "modules" folder. All of the MACROSS core functions are in "core", 
 and everything else goes in "resources" (which you can also change the location of if you want).
 
 The table up top lists the attributes of the custom powershell class "macross", and also the
 commonly used variables within MACROSS and all its tools.
 
 So, here we go...
 
 I. Naming your variables
    
    MACROSS is written to perform as much internal hygiene as possible. Every time the main menu 
    loads, it clears out a number of values, including and especially all variables in all scopes 
    that begin with "$dyrl_". My scripts also follow the pattern of including part of the tool 
    name in the variable name. Although not required (and kind of tedious), I recommend you name 
    variables in this manner especially in complex scripts. Let MACROSS handle cleanup to make 
    sure each tool functions the way it is expected to.
    '
    next
    splashPage 1
    Write-Host -f GREEN '
 II. The custom [macross] class
 
    Custom scripts you add to MACROSS *must* include these as the first three lines:
    #_sdf1
    #_ver
    #_class
    
    The sdf1 line contains a brief description of your tool; this is what gets written to the 
    MACROSS menu. The ver line helps with version control. The class line is where you set the 
    attributes for your tool, separated by commas:
    '
    w '        #_class admin,ip addresses,python,HiSurfAdvisory,2' 'y'
    Write-Host -f GREEN '
    The example attribute values above are as follows:
        field 1 (admin): the LOWEST level of privilege your script requires
        field 2 (ip addresses): specify the task or type of info your script handles
        field 3 (python): the language (no versions)
        field 4 (HiSurfAdvisory): the author
        field 5 (2): the max number of parameters/arguments your script can accept
    
    If you type "help" in the main menu, you will get a list of all the tools currently in the 
    "module" folder, and their macross attributes.
    '
    next
    splashPage 1
    Write-Host -f GREEN '
 III. temp_config.txt
 
    The file "temp_config.txt" inside the resources folder contains a block of base64-encoded 
    lines. The lines are separated by "@@@", and the first three characters of each line are 
    used by MACROSS as an index key for that line. If you have a regularly-used value, like a 
    server IP/hostname, that one or more of your MACROSS scripts requires, you can base64-encode 
    it, add a three-character "key" to the front of that base64 value, add a "@@@" to the front 
    of that, then add the whole thing to the end of the block in "temp_config.txt".'
    w "
    No, this not for security, but I don't like leaving certain things sitting around hardcoded 
    in plaintext for keyword scanners to find. Don't use this for storing credentials or 
    sensitive data, please." 'g'
    Write-Host -f GREEN '
    Ideally, you will use a different file that is kept in an access-controlled location. If you 
    do, you will need to keep the lines from temp_config that begin with "nre", "tbl", and "log", 
    and update them if you change their default locations. Also, you will need to modify the 
    filepath to your new "temp_config" in the "startUp" function, which is in the display.ps1 
    file.
    '
    next
    splashPage 1
    Write-Host -f GREEN '
 IV. $vf19_MPOD & "getThis"
 
    The values you encode in the temp_config file get stored by MACROSS in a hashtable called 
    $vf19_MPOD. When your script needs one of the values, simply select it with its key and 
    send it to the "getThis" function. For example, the key for the MACROSS logs location is 
    "log", so I would need to send
    '
    w '            getThis $vf19_MPOD["log"]' 'y'
    Write-Host -f GREEN '
    Doing this will decode the value and temporarily store it in the variable $vf19_READ for 
    your use. 
    
    Be aware that $vf19_READ gets overwritten every time "getThis" is run, and also 
    every time the MACROSS main menu loads. This helps make sure plaintext cleanup happens on 
    a regular basis while MACROSS is active.
    '
    next
    splashPage 1
    Write-Host -f GREEN "
 V. $('$'+'PROTOCULTURE') and the MACROSS collab function
    
    The key component of MACROSS is the collab function, which lets you send your script's 
    current focus, be it a filename or IP, etc., to one or more other scripts within MACROSS 
    for enrichment, reporting, or any other task you can think of, all during a single session. 
    Whatever artifact you're currently locked in on should get set in a global variable called 
    $('$'+'PROTOCULTURE').
    
    Wherever it makes sense, MACROSS tools should all be coded to act on $('$'+'PROTOCULTURE') any time
    it has a value when they get called. In this way, you can quickly gather all kinds of
    information on your artifact depending on what tasks your scripts perform, and you can 
    keep the artifact static across multiple scripts while letting them transform it, add to 
    it, or do whatever else they want with it in their own scope.
    
    The collab function can also pass along an additional parameter/value if you want something 
    evaluated/processed in addition to or instead of the active $('$'+'PROTOCULTURE') value.
    
    Each MACROSS script's .valtype attribute can be used to choose relevant scripts automatically."
    w '
      $Global:PROTOCULTURE = "www.evilcorp.net/malwarez"
      $vf19_LATTS | ?{ $_.valtype -Like "*websites*"} | %{ collab $_.fname "MyScript" }' 'y'
    Write-Host -f GREEN "
    The above one-liner would cycle through all MACROSS tools that process or enrich data on URLs
    or domains (if you set your script's .valtypes consistently), and then each of those would
    perform their actions on $('$'+'PROTOCULTURE') via the collab function. 
    "
    next
    splashPage 1
    Write-Host -f GREEN '
 VI. MACROSS utilities
    
    Last but not least, MACROSS provides lots of extras your script can make use of. As this is 
    the "quick & dirty" demo, I will skip describing them and just let you view them from the 
    main menu. Type "help dev" to get a list of MACROSS functions and their descriptions/usage. 
    You can also type "help " followed by any of the functions or tools to get that specific help 
    page.
    
    There is also an unlisted menu option, "debug". Entering this will open a menu that lets you 
    read logs and change the powershell error action (MACROSS sets it to "silent" by default). 
    You can also type "debug " followed by a command (including MACROSS functions) for testing.
    
    If you want to, you can run this demo again and choose the "Detailed" option. Then you can 
    see an example of how MACROSS is intended to work.
    
    Each function has detailed information on its use if you view the files in the "core" folder, 
    and added detail can be found in the github pages:
    
    https://github.com/hisurfadvisory/MACROSS
    
    Thanks for taking MACROSS for a spin! Hit ENTER to exit!
    '
    Read-Host
    Exit
}
