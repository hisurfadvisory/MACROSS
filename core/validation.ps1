## Functions for MACROSS input validations. You shouldn't need to modify anything here except the "setUser" function if
## you plan to use the basic access control.


function yorn(){
    <#
    ||longhelp||

    yorn [-s SCRIPTNAME] [-t TASK] [-q Alternate Question]

    Quickly get input from users on whether to continue a task. yorn opens a 
    "Yes/No" window for the user to click on. Returns 'Yes' or 'No' so  you 
    can kill tasks or perform other actions as the user chooses.
    
    The default question is "Do you want to continue $task?", where $task is 
    the value you supply with -t, but you can substitute your own question by
    using -q (-t and -q cannot be used together)
    


    If you want to modify the window options that get displayed, change
    these numbers within the function in "validation.ps1".
    
    ICONS:                   BUTTONS:
    Stop          16         OK               0
    Question      32         OKCancel         1
    Exclamation   48         AbortRetryIgnore 2
    Information   64         YesNoCancel      3
                             YesNo            4
                             RetryCancel      5
                            
    
    ||examples||
    
    if( $(yorn -s 'SCRIPTNAME' -t $CURRENT_TASK) -eq 'No' ){
        $STOP_DOING_TASK
    }

    $var = yorn -s 'SCRIPTNAME -q 'Do you want to write outputs to a file?'
    if($var -eq 'Yes'){ $write_to_file }
    
    #>
    param(
        [Parameter(Mandatory)]
        [string]$scriptname,
        [Parameter(Mandatory)]
        [string]$task,
        [string]$question
    )
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    
    <# # Uncomment these and add more parameters if you want to modify this
       # function to offer more options
    $Buttons = @{
        0='OK'
        1='OKCancel'
        2='AbortRetryIgnore'
        3='YesNoCancel'
        4='YesNo'
        5='RetryCancel'
    }
    $Icons = @{
        16='Stop'
        32='Question'
        48='Exclamation'
        64='Information'
    }
    #>
    
    if($question){
        $1 = $question
    }
    else{
        $task = $task + '?'
        $1 = "Do you want to continue $task"
    }
    

    Return [System.Windows.Forms.MessageBox]::Show(
        "$1",           # Window Message
        "$scriptname",  # Window Title
        "YesNo",        # Button scheme
        "Question",     # Icon
        "Button2"       # Set default button choice
    )
}

<################################

    SJW() details:

 Check your privilege LOL
 Some tools or APIs need admin-level access.
 
 Set $1 to 'deny' if your script requires elevated priv, or set
 it to 'pass' if it will kinda-sorta work in userland

 EXAMPLE: 
 
    SJW -pass
 
 will let the user choose whether to run your script with
 limited functionality;
 
    SJW -deny
        
 will tell the user they need to be admin or DA or whatever,
 then return to the console menu. 
 
 The [macross].priv attribute in each script may indicate "user", while
 certain functions within that script still need admin privilege to work. 
 Use this check in those cases.
################################>
function SJW([switch]$menu=$false,[switch]$deny=$false,[switch]$pass=$false){
    if( $menu -and $vf19_ROBOTECH ){
            w "                ****YOU ARE NOT LOGGED IN AS ADMIN**** " y
            w "      Some of these tools may be nerf'd without elevated privilege.
            " y
    }

    ## Privilege check for scripts; only cares if user has been tagged as non-admin
    else{
        if( $vf19_ROBOTECH ){
            cls
            if( $deny ){
                Write-Host -f YELLOW "
  
  
  Nope, you are not logged in as admin. Hit ENTER to quit."
                Read-Host
                Exit
            }
            elseif( $pass ){
                Write-Host -f YELLOW "
  You are not logged in as admin; this tool's scope will be extremely limited.
  Do you want to continue?  " -NoNewline;

                $Z = Read-Host

                if( $Z -ne 'y' ){
                    Remove-Variable nc_* -Scope Global
                    Exit
                }
            }
        }
    }
}

function setUser($1,[switch]$c=$false,[switch]$i=$false){
    if($c){
        $Global:USR = $vf19_USRCHK
        Return
    }
    if($1){ 
        $l_=$($vf19_GPOD.Item1);$ll_=$($vf19_GPOD.Item2)
        function x(){if($($vf19_check / ($vf19_ACCESSTIER.Item1) -eq $vf19_modifier)){Return $l_}}
        if( ! $vf19_USERAUTH ){Return $l_}
        elseif($1 -eq 0){Return $(x)}
        elseif($1 -eq 3 -and $vf19_ACCESSTIER.Item3){Return $(x)}
        elseif($1 -eq 2 -and $vf19_ACCESSTIER.Item2){Return $(x)}
        elseif($1 -eq 1){Return $(x)}
        else{Return $ll_}
    }
    elseif($i){
        Remove-Variable -Force vf19_ACCESSTIER -Scope Global
    
        ## First attempt is to avoid any local weirdness
        $u = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
        ## Plan B
        if( ! $u ){ $u = $env:USERNAME }
        
        $Global:USR = $u -replace "^(.+\\)?"  ## Remove domain from username
        battroid -n vf19_USRCHK -v $USR

        $aTIER=@{};$uTIER=@{};$aconf=$vf19_CONFIG[2]
        $vf19_MPOD.keys | where{$_ -Match "tr[1-3]"} | %{
            getThis $vf19_MPOD[$_]; $uTIER.Add($_,$vf19_READ)
        }
        $vf19_MPOD.keys | where{$_ -Match "ta[1-3]"} | %{
            getThis $vf19_MPOD[$_]; $aTIER.Add($_,$vf19_READ)
        }
        $id = Get-Random -min 10000000 -max 9999999999
        $idm = Get-Random -min 500 -max 50000
        $idc = $($id*$idm)
        
        function tup($1,$2,$3){
            Set-Variable -Name vf19_ACCESSTIER -Value $([System.Tuple]::Create($1,$2,$3)) -Scope Global -Option ReadOnly
            battroid -n vf19_USERAUTH -v $true
        }

        try{ $priv = Get-ADUser -Filter "samAccountName -eq '$USR'" -Properties memberOf }
        catch{ battroid -n vf19_ROBOTECH -v $true }
        
        
        if(Test-Path "$aconf"){
            $gj = setCC
            $current = setReset -d $(gc "$aconf") $gj | ConvertFrom-Json
            battroid -n vf19_USERAUTH -v $true
            if($USR -in $current.Tier3){tup $id $false $true}
            elseif($USR -in $current.Tier2){tup $id $true $false}
            elseif($USR -in $current.Tier1){tup $id $false $false}
        }
        ## If you don't create GPO/Tier names during configuration, access control will be disabled and everyone
        ## can download & execute all tools in the modules folder!
        elseif($aTIER['ta1'] -eq 'none' -and $uTIER['tr1'] -eq 'none'){
            battroid -n vf19_modifier -v 111; battroid -n vf19_check -v 555
            battroid -n vf19_USERAUTH -v $false
			battroid -n vf19_DTOP -v "$([string]$env:HOMEPATH)\Desktop"
            tup 5 $true $true; $skip = $true
        }
        else{
            ## Multiple methods because every use-case is different...
            if( $vf19_ROBOTECH ){
                if(net user $USR /domain | sls $($uTIER['tr3'])){tup $id $false $true}
                elseif(net user $USR /domain | sls $($uTIER['tr2'])){tup $id $true $false}
                elseif(net user $USR /domain | sls $($uTIER['tr1'])){tup $id $false $false}
            }
            else{
                ## If SysInternals is installed, create a list of its applications for quick-launching via $SI
                ## Useful for scanning evtx files, etc.
                if(Test-Path $vf19_SYSINT){
                    $sint=@{}; ls $vf19_SYSINT | Select -ExpandProperty FullName | where{$_ -Like "*exe"} |
                    %{$sint.Add($($_ -replace "^.+\\" -replace "\.exe$"),$_)}
                    battroid -n SI -v $sint
                }; rv vf19_SYSINT -Scope Global
                if($priv.memberOf | where{$_ -Like "*$($aTIER['ta3'])*"}){ tup $id $false $true }
                elseif($priv.memberOf | where{$_ -Like "*$($aTIER['ta2'])*"}){ tup $id $true $false }
                elseif($priv.memberOf | where{$_ -Like "*$($aTIER['ta1'])*"}){ tup $id $false $false }
            }
            
        }
        
        if($vf19_USERAUTH){
            ## This should point $vf19_DTOP to your desktop 99% of the time, but you can change the
            ## -v value if your environment is different.
            #battroid -n vf19_DTOP -v "$([string]$env:HOMEPATH)\Desktop"
            battroid -n vf19_DTOP -v "C:\Users\$USR\Desktop"
            battroid -n vf19_modifier -v $idm; battroid -n vf19_check -v $idc
        }
        elseif($vf19_ACCESSTIER.Item1 -ne 5){ eMsg 1; varCleanup -c; Exit }
        rv id,idm,idc,priv

    }
}


function eMsg($m='ERROR: that module is unavailable!',$c='c'){
    <#
    ||longhelp||

    eMsg [-m MSG NUMBER OR TEXT STRING] [-c TEXT COLOR]

    Call a list of canned messages. You can add more to the $msgs list within the function,
    or you can send your own message, which will both write to the screen and record the
    message in a MACROSS log file along with the timestamp and logged-in username.

    Accepts two parameters: -m is the number of the message you want to select from the $msgs 
    list, OR your own custom error message string. -c is the first letter of the color you want 
    the error to write onscreen (or "bl" for black; default is cyan).

    ||examples||
    Display an authentication warning:

        if( -not $authorized ){ eMsg 1 }

    Log and print your own error message in red text:

        if(-not $Result){ eMsg -m "These aren't the droids you're looking for." -c r }

    There are currently 5 canned messages, but you can add more if necessary.


    #>
    ## MOD SECTION! ##
    ## Add your own error message if it's something you'd use often.
    $msgs = @(
        'You are not in the correct security group. Exiting...',
        'Unknown error! You may need to exit this script and restart it.',
        'Invalid parameter, update checks and/or downloads aborted.',
        'Could not find a required value!',
        'You are not in the correct analyst group. Exiting...'
    )
    ''
    $cc = $($vf19_colors[$c])
    if($m.getType().Name -eq 'String' -and $m -ne 'ERROR: that module is unavailable!'){
        Write-Host -f $cc " $m
        "
        errLog 'ERROR' "$USR" $m
    }
    elseif($m.getType().Name -eq 'Int32'){
        Write-Host -f $cc " $($msgs[$m])
        "
        slp 2
    }
    else{
        ## Default error message for failed tool checks; clear the user input $vf19_Z to avoid loops
        cls
        Write-Host -f $cc "
        $m
        "
        $Global:vf19_Z = $null
        slp 2
    }
}

## Don't leave crap in memory when not needed
function varCleanup([switch]$c=$false){
    Remove-Variable -Force dyrl_* -Scope Script
    Remove-Variable -Force vf19_FILECT,vf19_REPOCT,HELP,vf19_OPT1,RESULTFILE,HOWMANY,`
    M_,N_,d9,CALLER,vf19_MPOD,vf19_PYPOD,vf19_READ,dyrl_* -Scope Global

    ## UNCOMMENT THESE TO ALWAYS CLEAR PROTOCULTURE AUTOMATICALLY
    #Remove-Variable -Force PROTOCULTURE -Scope Global
    #if(Test-Path $vf19_PROTO){ Remove-Item -Path $vf19_PROTO }

    ## Cleanup python usage
    if($env:MACROSS){ pyENV -c }

    ## Erase everything when quitting MACROSS
    if($c){
        cleanGBIO  ## Don't leave eod files sitting around, it might interfere with python tools
        Remove-Variable -Force PROTOCULTURE,MAPPER,MONTY,MSXL,SHARK,SI,USR,vf19_*,dyrl_* -Scope Global
    }
}

<#
      pyATTS()  details:

   Converts the hashtable of macross objects for python. Your python
   script can either reference the JSON file "LATTS.eod", or the 
   simplified value forwarded as sys.argv[6] which only includes the 
   .fname and .valtype attributes.
   
   We don't want this to be a static global value in case scripts get
   modified/removed/added while MACROSS is active, so this function 
   will create a new argv[6] and new JSON everytime a python script is 
   launched from the "collab" or "availableMods" functions.
   
   Your python scripts can iterate through argv[6] (each item is 
   "script1.fname"="script1.valtype","script2.fname"="script2.valtype"...)
   or reference the LATTS.eod json file which has all the [macross] object
   attributes {script1:{},script2:{}}...
   
#>
function pyATTS(){
    $p = @(); $p2j = @{}
    foreach($k in $vf19_LATTS.keys){
        $n = $vf19_LATTS[$k].fname       ## The full filepath to the script
        $t = $vf19_LATTS[$k].valtype     ## The value type processed by the script
        $l = $vf19_LATTS[$k].lang        ## python vs. powershell
        $a = $vf19_LATTS[$k].author      ## who wrote the script
        $r = $vf19_LATTS[$k].rtype       ## the script's response format type
        $v = $vf19_LATTS[$k].ver         ## the script's version
        $m = $vf19_LATTS[$k].evalmax     ## max number of args/params accepted by the script

        $p2j.Add($k,@{'fname'=$n;'valtype'=$t;'lang'=$l;'evalmax'=$m;'author'=$a;'rtype'=$r;'ver'=$v})
        $atts = $n + '=' + $v
        $p += $atts
    }
    [IO.File]::WriteAllLines("$vf19_TOOLSROOT\core\py_classes\garbage_io\LATTS.eod", $($p2j | ConvertTo-Json))
    [string]$str = $p -Join(',')
    Return $str
}
function altByte($1,[int]$2,[int]$3){
    Return $([convert]::ToByte($($1[$2,$3] -join ''),16))
}
function setReset(){
    param(
        [Parameter(Mandatory=$true)]$v,
        [Parameter(Mandatory=$true)]$n,
        [switch]$d = $false
    )
    $p=chr 83;$lines=''
    if($d){
        setML 1
        $sml = [scriptblock]::Create("$vf19_READ")
        $($v -Split("$p")) | %{$lines += $([System.Text.Encoding]::UTF8.GetString("$(. $sml)"))}
    }
    else{
        $v = $v -replace ",$"
        setML 2
        $x = $([System.Text.Encoding]::UTF8.GetBytes("$v"))
        $sml = [scriptblock]::Create("$vf19_READ")
        $i=0; while($i -lt $x.count){ $lines += ("$(. $sml)" + "$p"); $i++ }
    }

    Return $($lines -replace "[,$p]$")
}


## Make MACROSS values accessible to python's mcdefs library
function pyENV([switch]$c=$false){
    if($c){
        Remove-Item env:PYPROTO,env:MPOD,env:MACROSS,env:HELP
    }
    else{
        if( $HELP ){ $env:HELP = 'T' }
        else{
            $env:HELP = 'F'
            startUp; $l = ''
            $vf19_MPOD.keys | Sort -Descending | where{$_ -ne 'mad'} | %{
                $l += $($_ + ':' + "$($vf19_MPOD[$_])" + ';')
            }
            $l = $l -replace ";$"
            $env:MPOD = $l
            $env:MACROSS = "$vf19_TOOLSROOT;$vf19_TOOLSDIR;$vf19_DTOP;$vf19_TABLES;$vf19_LOG;$($N_[0]);$USR;$CALLER"
            if($PROTOCULTURE){ $env:PYPROTO = $PROTOCULTURE }
            else{ $env:PYPROTO = 'None' }
        }
    }
}


function collab(){
    <#
    ||longhelp||

    collab [-m SCRIPT.EXTENSION] [-c MYSCRIPTNAME] [-o OPTIONAL VALUE]

    Call this function from one script to load your current investigation values into 
    another. The -m and -c parameters are required, -o is conditional on your task
    and whether the called script can accept an extra parameter.
        
    The -m param is the script filename you're calling, INCLUDING the extension, 
    and is *required*. The script also needs to be located in the modules folder 
    and recognized by MACROSS, i.e. it has the magic words in the first three 
    lines --
        
        #_sdf1
        #_ver
        #_class
        
    The -c param is the name of the script calling this function ($CALLER) and is 
    required. (I set this to be required so that you always have the option to have 
    your scripts lookup attributes from  the $vf19_LATTS array and determine its 
    .valtype, .lang, etc.)

    The -o param is an ***optional*** item you're passing if you want something other 
    than $PROTOCULTURE to be eval'd, or if the script being called requires 2 eval 
    parameters.

    If you're calling a python script, all the default MACROSS values will be passed 
    in the standard 6-argument sequence that is used in the availableMods function, 
    but your $CALLER, $PROTOCULTURE and -o values will also be added in as the 7th, 
    8th and 9th args.

    If you need the called script to launch in a new window, set

        $Global:vf19_NEWWINDOW = $true

    in your script. Be aware that the called script will NOT have access to MACROSS 
    resources if launched in a new window, as it will be its own entirely different session!

    The $PROTOCULTURE variable should already be globally set by ***your*** script. If you 
    pass another value in, make sure the script you are calling has an .evalmax value of 2.
        
    For instance, it could be that $PROTOCULTURE is globally set, but you're calling a script 
    that can accept more than one item to evaluate. In this case, you can send a new value to 
    this function to be passed along in addition to $PROTOCULTURE, if the called script is 
    designed to recognize when it is receiving a parameter while $PROTOCULTURE also contains a 
    value.
        
    Remember that $PROTOCULTURE is meant to be available to all the scripts all the time until 
    *you* decide to overwrite or clear it, or you exit MACROSS cleanly which will delete all 
    related values.

    (After the called script exits, $CALLER will be erased, but $PROTOCULTURE will remain 
    globally available unless you explicitly remove it; you can force $PROTOCULTURE to always 
    clear when the MACROSS menu loads by modifying the varCleanup function at the top of this 
    script)

    Also remember that MACROSS intends for the following variables to be global as well, *but* 
    they get cleared every time you exit a script back to the MACROSS menu:

    1. $RESULTFILE -- any files generated by your scripts that can be used for
        further eval or formatting in other scripts
    2. $HOWMANY -- the number of successful tasks tracked between scripts
            
    ||examples||
    Example on how you might use the availableTypes function to search each tool's MACROSS class
    for tools that look up data on hostnames, and then filtering that list of tools based on
    their .evalmax & .rtype values to automatically call them via the collab function to collect 
    data on the hostnames you're investigating:
        
        $results = @()
        $list = availableTypes 'hostname'
        $hostnames | foreach-object
        {
            $PROTOCULTURE = $_
            foreach( $tool in $list )
            {
                if( $tool.evalmax -gt 0 -and $tool.rtype -eq 'xml' )
                {
                    $results += $(collab $tool.fname 'MyScriptName')
                }
            }
        }
            
        
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [string]$module,
        [Parameter(Mandatory=$true)]
        [string]$C,
        $option=$PROTOCULTURE
    )

    if($module -Like "*py"){
        $py = $true
        $pyATTS = pyATTS
    }
    $Global:CALLER = $C
    

    $mod = "$vf19_TOOLSDIR\$module"
    $tpm = Test-Path -Path $mod
    $dom = setUser "$($vf19_LATTS[$($module -replace "\.\w+$")].access)"

    if( ($dom -eq $vf19_GPOD.Item1) -and $tpm ){
        startUp
        if($py){
            pyENV
            if( $vf19_NEWWINDOW ){ 
                if( $option -ne $PROTOCULTURE ){
                    #Start-Process powershell.exe "python3
                    #Start-Process powershell.exe "py $mod $USR $pyATTS $vf19_DTOP $vf19_PYPOD $($N_[0]) $vf19_pylib $vf19_TOOLSROOT $CALLER $PROTOCULTURE $option"
                    Start-Process powershell.exe "py $mod $vf19_pylib $option"
                } 
                else{
                    #Start-Process powershell.exe "py $mod $USR $pyATTS $vf19_DTOP $vf19_PYPOD $($N_[0]) $vf19_pylib $vf19_TOOLSROOT $CALLER $PROTOCULTURE"
                    Start-Process powershell.exe "py $mod $vf19_pylib"
                }
            }
            else{
                if( $option -ne $PROTOCULTURE ){
                    #python3 $mod
                    #py $mod $USR $pyATTS $vf19_DTOP $vf19_PYPOD $N_[0] $vf19_pylib $vf19_TOOLSROOT $CALLER $PROTOCULTURE $option
                    py $mod $vf19_pylib $option
                } 
                else{
                    #py $mod $USR $pyATTS $vf19_DTOP $vf19_PYPOD $N_[0] $vf19_pylib $vf19_TOOLSROOT $CALLER $PROTOCULTURE
                    py $mod $vf19_pylib
                }
            }
            pyENV -c
        }
        else{
            if( $vf19_NEWWINDOW ){
                ## Launches script in new window if user desires; WILL NOT SHARE CORE MACROSS VALUES OR FUNCTIONS!
                Start-Process powershell.exe "$mod $CALLER $option"
            }
            else{
                . $mod $option  
            }
            Remove-Variable -Force CALLER -Scope Global
        }
        
        $vf19_NEWWINDOW = $false  ## Always reset value
    }
    elseif($tpm){
        eMsg 4
    }
    else{
        eMsg
    }

}



function availableTypes(){
    <#
    ||longhelp||

    availableTypes [-v VALTYPES] [-r RESPONSETYPES] [-l LANGUAGE] [-e EXACT "-v" MATCHES]

    When you need to use the "collab" function to pass values into other scripts, you can find 
    relevant tools by calling this function with the .valtypes you want as a comma-separated
    string. By default it searches for *like* matches in all scripts, but you can force
    exact matches with -e and use -l specify python vs. powershell. If your script needs a
    specific output format, you can use -r to only find scripts that will return json, csv, etc.
    You can use MACROSS' debugger to view the .rtype (Response Type) of each tool in the modules
    folder.

    Any tools matching your request will be returned to your script as a list. You can use that 
    list to automatically query other tools via the "collab" function.

    ||examples||
    Ask for any scripts that process usernames, including EDR apis:
    
        $tools = availableTypes  'user, edr'
        foreach($t -in $tools){ collab $t 'myscript'}

    Ask only for python scripts with .valtype that is "firewall api":
    
        $tools = availableTypes  'firewall api' -e -l python
        foreach($t -in $tools){ collab $t 'myscript'}


    #>
    param(
        [switch]$e=$false,
        [string]$v,
        [regex]$r="[^(none)]",
        [string]$l='p'
    )
    $list = @()
    $vf19_LATTS.keys | %{
        $k = $_
        if($vf19_LATTS[$k].evalmax -gt 0 -and $vf19_LATTS[$k].lang -Like "$l*" `
        -and $vf19_LATTS[$k].rtype -Match $r){
            if($e -and $vf19_LATTS[$k].valtype -eq $v){
                $list += "$($vf19_LATTS[$k].fname)"
            }
            elseif(! $e){
                $v = $v -replace ", ",','
                $v -Split ',' | %{
                    if($vf19_LATTS[$k].valtype -Like "*$_*"){
                        $list += "$($vf19_LATTS[$k].fname)"
                    }
                }
            }
        }
    }
    
    if($list.count -gt 0){
        $list = $list | Sort -Unique
        Return $list
    }
}


<################################

    availableMods() details:

    Verify tool locations, permissions, and options
    
    The chooseMods function in display.ps1 generates the menu of tools
    for the user to choose from. When they make a selection, it is
    sent to this function which:
        1. Checks to see that the script is still in the modules folder
        2. Forwards the selected script name to the function verChk, which
            compares version numbers in the user's folder vs. the same
            script in your master repo (only if you're using a master repo).
            If the repo has a newer version, it automatically downloads
            before launching the script.
        3. Checks if the selected script is in python; if so, it launches
            the script with a default sequence of arguments that contain
            MACROSS' core values and the filepath to the mcdefs.py library
     
################################>
function availableMods($1){
    if( $($1).getType().Name -eq 'Int32' ){

            # Use the adjusted input as the index for the MODULENUM array
            $MODULE = "$vf19_TOOLSDIR\$($vf19_MODULENUM[$1])"
            $MODCHK = Test-Path $MODULE -PathType Leaf; $tk = $($vf19_MODULENUM[$1] -replace "\.\w+$")
            $LAUNCH = setUser "$($vf19_LATTS[$tk].access)"
            
            if( $MODCHK -and ($LAUNCH -eq $vf19_GPOD.Item1) ){
                startUp; if( $vf19_VERSIONING ){
                    if( ! $vf19_MISMATCH ){
                        if( $vf19_REF ){ $Global:vf19_REF = $false; verChk $MODULE 'refresh' }
                        else{ verChk $MODULE }
                    }
                }

                
                # Run the script selected by the user
                if( "$($vf19_LATTS[$tk].lang)" -eq 'python' ){
                    cls; pyENV
                    if( $HELP ){
                        #py $MODULE 'HELP' '' '' '' '' $vf19_pylib
                    }
                    else{
                        $pyATTS = pyATTS
                        if($vf19_NEWWINDOW){
                            $MODULE = $($MODULE -replace "\\\\",'\') ## I don't know why extra slashes get added sometimes
                            #Start-Process powershell.exe "py $MODULE $USR $pyATTS $vf19_DTOP $vf19_PYPOD $($N_[0]) $vf19_pylib $vf19_TOOLSROOT"
                            Start-Process powershell.exe "py $MODULE $vf19_pylib"
                        }
                        else{
                            #py $MODULE $USR $pyATTS $vf19_DTOP $vf19_PYPOD $N_[0] $vf19_pylib $vf19_TOOLSROOT
                            py $MODULE $vf19_pylib
                        }
                        pyENV -c
                    }
                }
                else{
                    $1 = ''
                    if( $vf19_NEWWINDOW ){  ## Launches script in new window if user desires; WILL NOT SHARE CORE MACROSS FUNCTIONS!
                        Start-Process powershell.exe $MODULE
                    }
                    else{
                        . $MODULE
                    }
                }
                $Global:vf19_NEWWINDOW = $false  ## Always make sure this is reset
            }
            elseif( $MODCHK -and ! $LAUNCH ){
                eMsg 0
            }
            else{
                eMsg  # User chose a number outside the range
            }
    }
    else{
        eMsg   # Don't let the user just type whatever they like
    }
    
}
