## Functions for MACROSS input validations

## Don't leave crap in memory when not needed
function varCleanup($1){
    Remove-Variable vf19_FILECT -Scope Global
    Remove-Variable vf19_REPOCT -Scope Global
    Remove-Variable HELP -Scope Global
    Remove-Variable CALLHOLD -Scope Global
    Remove-Variable COMEBACK -Scope Global
    Remove-Variable GOBACK -Scope Global
    Remove-Variable dyrl_* -Scope Global
    Remove-Variable RESULTFILE -Scope Global
    Remove-Variable HOWMANY -Scope Global
    Remove-Variable CALLER -Scope Global
    Remove-Variable PROTOCULTURE -Scope Global
    if( $1 -eq 1 ){  ## Erase everything when quitting MACROSS
        Remove-Variable MONTY -Scope Global
        Remove-Variable SHARK -Scope Global
        Remove-Variable USR -Scope Global
        Remove-Variable vf19_* -Scope Global
    }
}

################################
## Tool Gateway
################################
function gethelp1($1){
    $b = $1 + $vf19_chk
    if( ! $vf19_DFIR ){
        $a = $vf19_SOC
    }
    else{
        $a = $vf19_IR
    }

    if( $a -ne $b ){
        errMsg 2
    }
}

################################
## IR Functions Gateway
################################
function gethelp2($1){
    $b = $vf19_chk + 1
    if( $vf19_DFIR ){
        $a = $vf19_IR
    }
    else{
        $a = $false
    }

    if( $a -ne $b ){
        Write-Host ''
        errMsg 2
    }
}




<#################################
        Deobfuscate your encoded value ($1), plaintext gets saved as $vf19_READ
            OR
        Encode your plaintext value ($1) to base64 by making your second param '0'

    
    -DO NOT USE ENCODING TO HIDE USERNAMES/PASSWORDS/KEYS or other sensitive info! This
    is only intended to prevent regular users from seeing your filepaths/URLs, etc.,
    and avoiding automated keyword scanners.

    -You MUST set your new variable to $vf19_READ **before** this function gets called again:

        getThis $base64string      >     DECODE A VALUE
        $new_variable = $vf19_READ

        
        getThis $plaintext 0       >     ENCODE A VALUE
        $base64_var = $dash_READ

    -To decode a hexadecimal string, call this function with '1' as a second parameter:

        getThis $hexstring 1
        $new_variable = $vf19_READ

    -Your hex string can include spaces and/or '0x' tags.

    This function can also be used by your scripts for normal decoding tasks, it isn't
    limited to MACROSS's startup.

#################################>
function getThis($1,$2){
    ## Start fresh
    Remove-Variable vf19_READ -Scope Global

    if( $2 -eq 1 ){
        $a = $1 -replace "0x",''
        $a = $a -replace " ",''
        $a = $(-join ($a -split '(..)' | ? { $_ } | % { [char][convert]::ToUInt32($_,16) }))
    }
    elseif( $2 -eq 0 ){
        $a = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($1))
    }
    else{
        $a = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($1))
    }
    
    $Global:vf19_READ = $a
}






################################
## Check for privileges LOL
################################
function SJW(){
    if( $vf19_GAVIL ){
        Write-Host -f YELLOW "                ****YOU ARE NOT LOGGED IN AS ADMIN**** "
        Write-Host -f YELLOW "     Some of these tools will not work without elevated privilege.
        "
    }
}


## This is an array of 4 numbers created from the hardcoded digit in
##  MACROSS.ps1. Use it for mathing obfuscation or anything else
##  you can think of where you don't want digits written in
##  plaintext.
$Global:vf19_M = [int[]](($vf19_numchk -split '') -ne '')




<################################
 Some tools need admin-privs.

 Set $1 to 'deny' if your script requires elevated priv, or set
 it to 'pass' if it will kinda-sorta work in userland

 EXAMPLE: 
 
    if( $vf19_GAVIL ){ adminChk 'pass' }
 
 will let the user choose whether to run your script with
 limited functionality;
 
    if( $vf19_GAVIL ){ adminChk 'deny' }
        
 will tell the user they need to be admin or DA or whatever,
 then return to the console menu.
################################>
function adminChk($1){
    if( $vf19_GAVIL ){
    cls
    if( $1 -eq 'deny' ){
        Write-Host -f YELLOW "
  
  
  Nope, you are not logged in as admin. Hit ENTER to quit."
        Read-Host
        Exit
    }
    elseif( $1 -eq 'pass' ){
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

################################
## Error message list
##  Modify or add your own as necessary
################################
function errMsg($1){
    if( $1 -eq 1 ){  ## Error check for gethelp functions
        Write-Host ''
        Write-Host -f YELLOW '   You are not in the correct security group. Exiting...
        '
        ss 2
        Remove-Variable nc_*
        Exit
    }
    elseif( $1 -eq 2 ){  ## Generic error message for tools
        Write-Host -f YELLOW '   Unknown error! You may need to exit this script and restart it.
        '
        ss 2
    }
    elseif( $1 -eq 3 ){  ## Error check for the updates.ps1 script
        cls
        Write-Host -f YELLOW '  Invalid parameter, update checks and/or downloads aborted.
        '
        ss 3
    }
    elseif( $1 -eq 4 ){  ## Generic 'not found' error
        Write-Host -f YELLOW '  Could not find a required value!
        '
        ss 3
    }
    else{    ## Default error message for failed tool checks
        Write-Host -f CYAN '
        ERROR: that module is unavailable!
        '
        $Global:vf19_Z = ''
        ss 1
    }
}


<################################
## Define User Permissions... this isn't secure, just convoluted
    If you have a better method of controlling script-use, use that
    instead of this!!

    If you use this framework/toolset in an Active-Directory environ and
    your SOC or incident-response users have unique GPO names, you can use
    this check to restrict your script use to cybersecurity analysts. (It
    also helps if your network enforces digitally-signed code).

    $vf19_numchk, $vf19_chk and $vf19_salt are set in the MACROSS.ps1 file.
    
    $vf19_salt & $vf19_chk are randomly generated numbers that are used in
    the getHelp and setUserCt functions, respectively, to create unique
    keys every time MACROSS gets launched.
    
    $vf19_numchk is a hardcoded 6-digit value that gets split into $vf19_M,
    a 6 character array that can be used for any kind of math you want, like
    obscuring IP addresses, etc.

    To use these functions (setUserCt and setUser), determine a unique string
    in the SOC and/or incident-response GPO membership in your active directory,
    and base64-encode it. Then add one of these identifiers to the front of your
    b64 string, and append it to the opening comments of extras.ps1 as explained
    the Core_Functions_README.md:

        sga  -- admins
        sgh  -- vulnerability managers/assessors
        sgu  -- standard SOC users
        sgn  -- domain admins
        sgi  -- forensics/incident-response users


    When these variables are set correctly, you can add this check to your
    custom scripts:

        try{
            getHelp1 $vf19_UCT  ## Perform just this check if your script can be used by all SOC/IR users
            getHelp2 $vf19_UCT  ## Perform this ADDITIONAL check if your script is intended only for tier 2/tier 3 users.
        }
        catch{
            Exit
        }

    Additionally, if your admin accounts are easily identifiable, like 'admin-name' or 'admin.name',
    modify the line in the setUser function below that reads

        if( $USR -notMatch "^admin*" )

    to match whatever your admin accounts look like. This way, non-admin users are tagged with
    '$vf19_GAVIL', and you can use this variable to prevent non-admins from trying to launch
    scripts that require elevated privilege (see the 'adminChk' function elsewhere in this file).


################################>
function setUserCt($1,$2){  ## Mathy math stuff for user restrictions
    $b = $vf19_M
    $val0 = $b[0] + $vf19_salt + $vf19_chk  
    $val1 = ($b[4] + $b[3]) + $vf19_salt
    $Global:vf19_NUSER = [tuple]::create($val0,$val1) # Create unique keys for every session

    $Global:vf19_UCT = $vf19_NUSER.Item2    ## your scripts pass this var to the getHelp functions to perform the check
    

    if( $vf19_DFIR ){
        $Global:vf19_IR = $vf19_NUSER.Item1  ## Random key for incident responders
    }
    else{
        $Global:vf19_SOC = $vf19_NUSER.Item1  ## Random key for non-IR cybersec analysts
    }
}
function setUser(){
    if([System.Security.Principal.WindowsIdentity]::GetCurrent().Name){
        $u = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
    }
    else{
        $u = $(whoami)
    }
    $Global:USR = $u -replace("^(.+\\)?",'')  ## Set the logged-in user
    $Global:vf19_USRCHK = $USR                ## Set this check in case another script changes $USR

    <#  UNCOMMENT THIS SECTION TO USE PERMISSION-RESTRICTED FUNCTIONS
    $Global:vf19_UGM = $null
    

    # vf19_MPOD is an array of base64 encoded strings that store your default variables;
    #    to make use of it, you need to base64-encode any values you don't wish to have
    #    sitting in plaintext, and prepend a 3-character identifier so that it can be
    #    indexed into $vf19_MPOD. Add your 3char+b64 string to the line 4 comments in
    #    ncore\extras.ps1, separated from the previous value using a '@@@'.
    
    $GRA = $vf19_MPOD['sga']  ## This is the base64-encoded string of what your admin GPO name is
    $GRH = $vf19_MPOD['sgh']  ## This is the base64-encoded string of what your vuln-mgmt GPO name is
    $GRD = $vf19_MPOD['sgu']  ## This is the base64-encoded string of what your SOC GPO name is
    $GRN = $vf19_MPOD['sgn']  ## This is the base64-encoded string of what your domain admin GPO name is
    $GRI = $vf19_MPOD['sgi']  ## This is the base64-encoded string of what your DFIR GPO name is


    function userMem(){   ## Check user GPO
        if( net user "$USR" /domain | Select-String $vf19_READ ){
            $Global:vf19_UGM = $vf19_READ
        }
    }
    function adminMem(){  ## Check admin GPO
        if( Get-ADUser -Filter "samAccountName -eq '$USR'" -Properties memberOf | Select -ExpandProperty memberOf | Select-String $vf19_READ ){
            $Global:vf19_UGM = $vf19_READ
        }
    }

    getThis $GRN

    if( $USR -notMatch "^admin*" ){   ## Your environment may not specify admin users with an "admin."; adjust these checks as necessary
        $Global:vf19_GAVIL = $true      ## Prevent loading certain tools for non-admins to avoid alerts
        $Global:vf19_USR = whoami
        $Global:vf19_USR = $vf19_USR.replace("^(.+\\)?",'')
        $Global:USR = $vf19_USR
        $cmd = "net"
        userMem
        if( $vf19_UGM ){
            $Global:vf19_DFIR = $true
        }
        else{
            getThis $GRD
            userMem
            if( ! $vf19_UGM ){
                getThis $GRH
                userMem
                if( ! $vf19_UGM  ){
                    gethelp1
                }
            }
        }

    }
    else{
        $cmd = "ad"
        getThis $GRI
        $Global:vf19_USR = Get-ADUser -Filter "samAccountName -eq '$USR'" | Select -ExpandProperty GivenName
        adminMem
        if( $vf19_UGM ){
            $Global:vf19_DFIR = $true
        }
        else{
            getThis $GRA
            adminMem
            if( ! $vf19_UGM ){
                gethelp1
            }
        }

    }

    setUserCt $cmd $vf19_UGM
    #>

    $Global:vf19_DEFAULTPATH = "C:\Users\$USR\Desktop"  ## You may need to change this desktop path in your environ;
                                                        ## This can be used by the scripts to write reports/results to
                                                        ## text outputs when necessary.

}




<#
  Call this function from one script to load your current
  search values into another.
  
  The 1st param is the script filename you're calling, INCLUDING
  the extension, and is required. (The script also needs be
  located in the nmods folder and recognized by MACROSS, i.e.
  it has the magic words in the first two lines -- #_wut and #_ver)

  If you're calling a python script, all the default MACROSS values
  will be passed in the standard 6-argument sequence, with your
  $CALLER and $PROTOCULTURE values added in as the 7th and 8th args.
  
  The 2nd param is the name of the script calling this function
  ($CALLER) and is required. (I set this to be required so that
  users always know which scripts they're jumping to and from.
  Of course that only works if you make use of the var in your
  scripts.)

  The 3rd param is the item you're passing for eval ($PROTOCULTURE)

  If you need the called script to launch in a new window, set

                $Global:vf19_NEWWINDOW = $true

  in your script. Be aware that the called script will NOT have access
  to MACROSS resources if called in a new window!

  The $CALLER and $PROTOCULTURE variables should already be GLOBALLY
  set by your script. Passing them here is just an additional check
  to give more flexibility on how you want your script to behave based
  on these values. For instance, it could be that $PROTOCULTURE is
  globally set, but you have a script that can accept more than
  one item to evaluate. In this case, you can send a new value to this
  function to be passed along in addition to $PROTOCULTURE, and have your
  script recognize when both values exist.

  After the called script exits, $CALLER will be erased, but $PROTOCULTURE
  will remain globally available.

  Also remember that MACROSS intends for the following variables to be
  global as well:

    $RESULTFILE -- any files generated by your scripts that can be used
    for further eval or formatting in other scripts

    $HOWMANY -- the number of successful actions tracked between scripts


#>
function collab(){
    param(
        [Parameter(Mandatory=$true)]
        [string]$module,
        [Parameter(Mandatory=$true)]
        [string]$C,
        $eNM
    )

    if(-not($module)){
        Write-Host -f CYAN “
        A script name wasn't supplied!
        ”
    }
    if(-not($C)){
        Write-Host -f CYAN “
        A CALLER name wasn't supplied!
        ”
    }
    else{
        $Global:CALLER = $C
    }

    ## Python check
    if( $module -Match "py$" ){
        if( ! $MONTY ){
            Write-Host -f CYAN "
            ERROR! Python is not installed! Cannot load script...
            "
            ss 2
            Return
        }
        else{
            $py = $true
        }
    }
    $mod = "$vf19_TOOLSDIR\$module"

    if( Test-Path -Path $mod ){
        if( $vf19_NEWWINDOW ){  ## Launches script in new window if user desires; WILL NOT SHARE CORE MACROSS FUNCTIONS!
            $vf19_NEWWINDOW = $false
            if($py){
                Start-Process powershell.exe "python3 $mod $CALLER $eNM"
            }
            else{
               Start-Process powershell.exe -File $mod $CALLER $eNM
            }
        }
        else{
            if($py){
                if( $eNM -ne $PROTOCULTURE ){  ## Pass both $eNM and $PROTOCULTURE to python if they are different values
                    python3 $mod $USR $vf19_DEFAULTPATH $vf19_PYOPT $vf19_numchk $vf19_pylib $vf19_TABLES $CALLER $PROTOCULTURE $eNM
                }
                else{
                    python3 $mod $USR $vf19_DEFAULTPATH $vf19_PYOPT $vf19_numchk $vf19_pylib $vf19_TABLES $CALLER $eNM
                }
            }
            else{
                . $mod $eNM
                Remove-Variable -Force CALLER -Scope Global
            }
        }
    }
    else{
        errMsg
    }

}

<################################
    Verify tool locations, permissions, and options
    
    The chooseMods function in display.ps1 generates the menu of tools
    for the user to choose from. When they make a selection, it is
    sent to this function which

        1. Checks to see that the script is still in the nmods folder
        2. Forwards the selected script name to the function verChk, which
            compares version numbers in the user's folder vs. the same
            script in your master repo (only if you're using a master repo).
            If the repo has a newer version, it automatically downloads
            before launching the script.
        3. Checks if the selected script is in python; if so, it launches
            the script with a default sequence of arguments that contain
            MACROSS' default variables and hashtables


     
################################>
function availableMods($1){
    if( $1 -Match $vf19_CHOICE ){
        # The array starts with '0', so need to adjust the user's input; the menu
        # only accomodates 20 tools right now; after that they'll ALL populate the second page  
        if( $1 -Match "[0-9]{1,2}" ){
            if( $1 -Match "[0-9]{2}" ){
                $1 = ($1 - 10)
            }
            else{
                $1 = ($1 - 1)                                 
            }


            # Use the adjusted input as the index for the MODULENUM array
            $MODULE = $Global:vf19_MODULENUM[$1]

            # Make sure the script is still valid before trying to run
            $MODCHK = Test-Path "$vf19_TOOLSDIR\$MODULE" -PathType Leaf

            if( $MODCHK ){

                ## Check tool versions, but only if the tool count matches
                if( ! $vf19_MISMATCH ){
                    if( $vf19_REF ){
                        $Global:vf19_REF = $false
                        verChk $MODULE 'refresh'
                    }
                    else{
                        verChk $MODULE
                    }
                }


                # Run the script selected by the user
                if($MODULE -Match "py$"){  # MACROSS already checked for python install, ignores if $MONTY is $false
                    cls
                    if($HELP){
                        python3 "$vf19_TOOLSDIR\$MODULE" 'HELP'
                    }
                    else{
                        ## Always send 6 default args for all python scripts to make use of:
                        ## The user; their desktop; the MPOD hashtable; the numchk integer; the filepath to the MACROSS py library;
                        ##  and the path to the \resources folder
                        python3 "$vf19_TOOLSDIR\$MODULE" $USR $vf19_DEFAULTPATH $vf19_PYOPT $vf19_numchk $vf19_pylib $vf19_TABLES

                    }
                }
                else{
                    #iex "& $vf19_TOOLSDIR\$MODULE '$CALLHOLD'"  ## Deprecated arg
                    $1 = ''
                    if( $vf19_NEWWINDOW ){  ## Launches script in new window if user desires; WILL NOT SHARE CORE MACROSS FUNCTIONS!
                        $Global:vf19_NEWWINDOW = $false
                        powershell.exe "$vf19_TOOLSDIR\$MODULE"
                    }
                    else{
                        . "$vf19_TOOLSDIR\$MODULE"
                    }
                }  
                
            }
            else{
                errMsg
            }
        }
        else{
            errMsg   # don't let the user just type whatever they like
        }
    }
}
