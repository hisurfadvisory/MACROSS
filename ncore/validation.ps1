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


    ## Erase everything when quitting MACROSS
    if( $1 -eq 1 ){

        cleanGBIO  ## Don't leave eod files sitting, it might interfere with python tools

        Remove-Variable PROTOCULTURE -Scope Global
        Remove-Variable MONTY -Scope Global
        Remove-Variable SHARK -Scope Global
        Remove-Variable USR -Scope Global
        Remove-Variable vf19_* -Scope Global
    }
}


 
<#  Quickly get input from users on whether to continue a task.
    Opens a "Yes/No" window for the user to click on.

    You MUST provide the name of your script, AND the task in progress
    You can also provide an optional question

    ICONS:                   BUTTONS:
    Stop          16         OK               0
    Question      32         OKCancel         1
    Exclamation   48         AbortRetryIgnore 2
    Information   64         YesNoCancel      3
                             YesNo            4
                             RetryCancel      5

    Returns 'Yes' or 'No' so you can kill tasks or continue as the
    user chooses.

    Usage:  if($(yorn 'SCRIPTNAME' '$CURRENT_TASK') -eq 'No'){$STOP_DOING_TASK}

#>
function yorn(){
    param(
        [Parameter(Mandatory)]
        [string]$scriptname,
        [Parameter(Mandatory)]
        [string]$task,
        [string]$question
    )

    if($question){
        $1 = $question
    }
    else{
        $1 = "Do you want to continue $task ?"
    }
    

    Return [System.Windows.Forms.MessageBox]::Show(
        "$1",           # Window Message
        "$scriptname",  # Window Title
        "YesNo",        # Button scheme
        "Question",     # Icon
        "Button2"       # Set default button choice
    )
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






<################################
 Check for privileges LOL
 Some tools or APIs need admin-level access.

 Set $1 to 'deny' if your script requires elevated priv, or set
 it to 'pass' if it will kinda-sorta work in userland

 EXAMPLE: 
 
    SJW 'pass'
 
 will let the user choose whether to run your script with
 limited functionality;
 
    SJW 'deny'
        
 will tell the user they need to be admin or DA or whatever,
 then return to the console menu.
################################>
function SJW($1){
    if( $1 = 'menu' ){
        if( $vf19_GAVIL ){
            Write-Host -f YELLOW "                ****YOU ARE NOT LOGGED IN AS ADMIN**** "
            Write-Host -f YELLOW "     Some of these tools will not work without elevated privilege.
            "
        }
    }

    ## Privilege check for scripts; only cares if user has been tagged as non-admin
    else{
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
}


## This is an array of 6 digits created from the hardcoded digit in
##  MACROSS.ps1. Use it for mathing obfuscation or anything else
##  you can think of where you don't want digits written in
##  plaintext.
$Global:vf19_M = [int[]](($vf19_numchk -split '') -ne '')



################################
## Error message list
##  Modify or add your own as necessary
################################
function errMsg($1){
    if( $1 -eq 1 ){  ## Error check for gethelp functions
        Write-Host ''
        Write-Host -f YELLOW '   You are not in the correct security group. Exiting...
        '
        slp 2
        Remove-Variable nc_*
        Exit
    }
    elseif( $1 -eq 2 ){  ## Generic error message for tools
        Write-Host -f YELLOW '   Unknown error! You may need to exit this script and restart it.
        '
        slp 2
    }
    elseif( $1 -eq 3 ){  ## Error check for the updates.ps1 script
        cls
        Write-Host -f YELLOW '  Invalid parameter, update checks and/or downloads aborted.
        '
        slp 3
    }
    elseif( $1 -eq 4 ){  ## Generic 'not found' error
        Write-Host -f YELLOW '  Could not find a required value!
        '
        slp 3
    }
    else{    ## Default error message for failed tool checks
        Write-Host -f CYAN '
        ERROR: that module is unavailable!
        '
        $Global:vf19_Z = ''
        slp 1
    }
}


<################################
##  Define User Permissions:
    Checks to see if the user can lookup their name via two methods,
    and set the global $USR value.

    Next, it makes an Active-Directory query for $USR. If that fails, 
    setting $vf19_GAVIL to 'true' lets MACROSS scripts know the user
    doesn't have admin privileges, so you can avoid loading tasks
    or functions that won't work for them.

    There are better ways to ID your users' access/permissions, but
    they will be unique to your environment. You can modify this
    function however works best for your domain.

################################>
function setUser(){
    if([System.Security.Principal.WindowsIdentity]::GetCurrent().Name){
        $u = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
    }
    else{
        $u = $(whoami)
    }
    $Global:USR = $u -replace("^(.+\\)?",'')  ## Set the logged-in user
    $Global:vf19_USRCHK = $USR                ## Set this check in case another script changes $USR

    try{
        $priv = Get-ADUser -Filter "samAccountName -eq $USR"
        Remove-Variable $priv
    }
    catch{
        $Global:vf19_GAVIL = $true
    }
    
    $Global:vf19_DEFAULTPATH = "C:\Users\$USR\Desktop"  ## You may need to change this desktop path in your environ;
                                                        ## This is used by the scripts to write reports/results to
                                                        ## text outputs when necessary.
}




<#
  Call this function from one script to load your current
  search values into another.
  
  The 1st param is the script filename you're calling, INCLUDING
  the extension, and is *required*. The script also needs be
  located in the nmods folder and recognized by MACROSS, i.e.
  it has the magic words in the first two lines --
  
        #_superdimensionfortress

        and
        
        #_ver

  If you're calling a python script, all the default MACROSS values
  will be passed in the standard 6-argument sequence that is used in
  the availableMods function, but your $CALLER and $PROTOCULTURE values
  will also be added in as the 7th and 8th args.
  
  The 2nd param is the name of the script calling this function
  ($CALLER) and is required. (I set this to be required so that
  users always know which scripts they're jumping to and from.
  Of course that only works if you make use of the var in your
  scripts.)

  The 3rd param is the item you're passing for eval ($PROTOCULTURE)

  If you need the called script to launch in a new window, set

                $Global:vf19_NEWWINDOW = $true

  in the CALLER script. Be aware that the called script will NOT have
  access to MACROSS resources if launched in a new window!

  The $CALLER and $PROTOCULTURE variables should already be *globally*
  set by your script. Passing them here is just an additional check
  to give more flexibility on how you want your script to behave based
  on these values. For instance, it could be that $PROTOCULTURE is
  globally set, but you're calling a script that can accept more than
  one item to evaluate. In this case, you can send a new value to this
  function to be passed along in addition to $PROTOCULTURE, if the called
  script is designed to recognize when both values exist. Remember that 
  $PROTOCULTURE is meant to be available to all the scripts all the time
  until *you* decide to overwrite or clear it, or you exit MACROSS cleanly
  which will delete all related values.

  (After the called script exits, $CALLER will be erased, but $PROTOCULTURE
  will remain globally available unless you explicitly remove it.)

  Also remember that the MACROSS framework intends for the following variables
  to be global as well, *but* they get cleared every time you exit a script back
  to the MACROSS menu:

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
            slp 2
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
                    python3 $mod $USR $vf19_DEFAULTPATH $vf19_PYOPT $vf19_numchk $vf19_pylib $vf19_TOOLSROOT $CALLER $PROTOCULTURE $eNM
                }
                else{
                    python3 $mod $USR $vf19_DEFAULTPATH $vf19_PYOPT $vf19_numchk $vf19_pylib $vf19_TOOLSROOT $CALLER $eNM
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
    sent to this function which:

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
                if( $vf19_VERSIONING ){
                    if( ! $vf19_MISMATCH ){
                        if( $vf19_REF ){
                            $Global:vf19_REF = $false
                            verChk $MODULE 'refresh'
                        }
                        else{
                            verChk $MODULE
                        }
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
                        python3 "$vf19_TOOLSDIR\$MODULE" $USR $vf19_DEFAULTPATH $vf19_PYOPT $vf19_numchk $vf19_pylib $vf19_TOOLSROOT

                    }
                }
                else{
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
