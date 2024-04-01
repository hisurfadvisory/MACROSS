## Functions for MACROSS input validations



## Don't leave crap in memory when not needed
function varCleanup($1){
    Remove-Variable vf19_FILECT,vf19_REPOCT,HELP,CALLHOLD,COMEBACK -Scope Global
    Remove-Variable GOBACK,RESULTFILE,HOWMANY,CALLER,vf19_READ,dyrl_* -Scope Global
    #Remove-Variable PROTOCULTURE -Scope Global  ## Uncomment this to always clear PROTOCULTURE automatically

    ## Erase everything when quitting MACROSS
    if( $1 -eq 1 ){

        cleanGBIO  ## Don't leave eod files sitting around, it might interfere with python tools

        Remove-Variable M_,N_,PROTOCULTURE,MONTY,SHARK,USR,vf19_* -Scope Global
    }
}
 
<#
    yorn() details:

    Quickly get input from users on whether to continue a task.
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
 
    SJW 'pass'
 
 will let the user choose whether to run your script with
 limited functionality;
 
    SJW 'deny'
        
 will tell the user they need to be admin or DA or whatever,
 then return to the console menu.
################################>
function SJW($1){
    if( $1 = 'menu' ){
        if( $vf19_ROBOTECH ){
            Write-Host -f YELLOW "                ****YOU ARE NOT LOGGED IN AS ADMIN**** "
            Write-Host -f YELLOW "      Some of these tools will be nerf'd without elevated privilege.
            "
        }
    }

    ## Privilege check for scripts; only cares if user has been tagged as non-admin
    else{
        if( $vf19_ROBOTECH ){
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


##  These are arrays of 6 digits created from the hardcoded digit in
##  MACROSS.ps1. Use it for mathing obfuscation or anything else
##  you can think of where you don't want digits written in
##  plaintext.
$Global:M_ = [int[]](($N_ -split '') -ne '')



################################
##
##   errMsg()  details:
##
## Error message list
##  Modify or add your own as necessary
################################
function errMsg($1){
    if( $1 -eq 1 ){  ## Error check for any restrictions you write
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


##    pyATTS()  details:
## Convert the hashtable of macross objects for python
## Don't want this to be a static global value in case scripts
## get modified while MACROSS is active
function pyATTS(){
    $p = @()
    foreach($k in $vf19_ATTS.keys){
        $n = $vf19_ATTS[$k].name
        $v = $vf19_ATTS[$k].valtype
        $atts = $n + '=' + $v
        $p += $atts
    }
    [string]$str = $p -Join(',')
    Return $str
}



<################################

    setUser() details:

##  Define User Permissions:
    Checks to see if the user can lookup their name via two methods,
    and set the global $USR value.

    First it looks at the logged-in account on the local system.

    Next, it makes an Active-Directory query for $USR. If that fails, 
    setting $vf19_ROBOTECH to 'true' lets MACROSS scripts know the user
    doesn't have admin privileges to make such queries, so you can avoid
    loading tasks or functions that won't work for them by just checking
    for whether $vf19_ROBOTECH is 'true'.

    You should change the very first "if" statement to match your
    analyst's roles, if you want to use that level of access control.
    The "$1" should match where the "Get-Random" statement generates
    user keys down below. If you don't care about access control you
    don't have to change anything.

    There are better ways to ID your users' access/permissions, but
    they will be unique to your environment. You can modify this
    function however works best on your enterprise.
################################>
function setUser($1){
    if($1){
        if(($1 + 53) -ne $vf19_check){
        getThis '596f7520646f206e6f7420686176652061636365737320746f2074686973207363726970742e' 1
            Write-Host -f CYAN '
        $vf19_READ
            '
            slp 2
            Exit
        }
    }
    else{
        $u = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
        if( ! $u ){
            $u = $(whoami)
        }
        $Global:USR = $u -replace("^(.+\\)?",'')  ## Set the logged-in user, remove domain if present
        $Global:vf19_USRCHK = $USR                ## Set this check in case another script changes $USR
        
        ## Check Active Directory GPO first; I ***hope*** non-admins can't run Active Directory cmdlets!!!!
        if(Get-ADUser -Filter * -Properties memberOf | where{$_.samAccountName -eq $USR}){
            $priv = Get-ADUser -Filter * -Properties memberOf | where{$_.samAccountName -eq $USR}
        }
        ## Check local permissions next
        if( ! $priv ){
            if(Get-LocalGroupMember Administrators -Member $USR){
                $priv = (Get-LocalGroupMember Administrators -Member $USR).Name -replace ".*\\"
            }
        }

        try{
            [void]$priv[0] ## Verify if anything got written during admin checks

            <# TWEAK & UNCOMMENT THIS SECTION TO FURTHER ID YOUR USERS FOR SPECIAL FUNCTIONS
             # Obviously you need to change "cyber" and "sooper cyber" to match your GPO names

            if($priv | Select -ExpandProperty memberOf | where{$_ -like "*cyber**}){
            
                $Global:vf19_tier1 = $true
                ## Or... create randomly generated keys as identifiers for each session
                ## Begin your "Tier 1 ONLY!" scripts with checks like 

                ##    try { setUser $vf19_tier3 } catch { Exit }

                ##  which checks if the "tier3" key and the "check" key match. There's not
                ##  really a huge difference and isn't "security", just a basic access control
                ##  if you have nothing else. Code-signing helps, otherwise this can be bypassed
                ##  pretty easily.
                #$Global:vf19_tier1 = $(Get-Random -min 10000000 -max 9999999999)
                #$Global:vf19_check = $vf19_tier1 + 53
            
            }
            elseif($priv | Select -ExpandProperty memberOf | where{$_ -like "*sooper cyber**}){
                $Global:vf19_tier1 = $true
                #$Global:vf19_tier3 = $(Get-Random -min 10000000 -max 9999999999)
                #$Global:vf19_check = $vf19_tier1 + 53
            }
            #>

            Remove-Variable priv
        }

        ## Tag the user as a non-admin lesser being if they can't read AD
        catch{
            $Global:vf19_ROBOTECH = $true 
        }


        <#
            You may need to change this desktop path in your environment if
            roaming profiles are in use;
            This global variable is used by the scripts to write reports/results
            to file when necessary.

            Example of writing outputs:

            $some_output | Out-File "$vf19_DEFAULTPATH\workstations\report.txt"

            I recommend you have your scripts create specific directories
            on the desktop to output reports to, so that MACROSS' houseKeeping
            function can tidy them up when necessary.
        #>
        $Global:vf19_DEFAULTPATH = "C:\Users\$USR\Desktop"
    }
}




<#
    collab() details:

  Call this function from one script to load your current
  search values into another.
  
  The 1st param is the script filename you're calling, INCLUDING
  the extension, and is *required*. The script also needs be
  located in the modules folder and recognized by MACROSS, i.e.
  it has the magic words in the first three lines --
  
        #_sdfm
        #_ver
        #_class

  If you're calling a python script, all the default MACROSS values
  will be passed in the standard 6-argument sequence that is used in
  the availableMods function, but your $CALLER and $PROTOCULTURE values
  will also be added in as the 7th and 8th args.
  
  The 2nd param is the name of the script calling this function
  ($CALLER) and is required. (I set this to be required so that
  all the scripts can lookup attributes from the $vf19_ATTS array.)

  The 3rd param is an ***optional*** item you're passing if you
  want something other than $PROTOCULTURE to be eval'd, or if
  the script being called requires 2 eval parameters.

  If you need the called script to launch in a new window, set

                $Global:vf19_NEWWINDOW = $true

  in the $CALLER script. Be aware that the called script will NOT have
  access to MACROSS resources if launched in a new window, as it will be
  its own entirely different session!

  The $PROTOCULTURE variable should already be globally set by ***your***
  script. Passing another value in will either invalidate $PROTOCULTURE
  or have it evaluated in addition to $PROTOCULTURE, depending on what
  the called script is doing.
  
  For instance, it could be that $PROTOCULTURE is globally set, but you're
  calling a script that can accept more than one item to evaluate. In this
  case, you can send a new value to this function to be passed along in 
  addition to $PROTOCULTURE, if the called script is designed to recognize 
  when it is receiving a parameter while $PROTOCULTURE also contains a value.
  
  Remember that $PROTOCULTURE is meant to be available to all the scripts all
  the time until *you* decide to overwrite or clear it, or you exit MACROSS
  cleanly which will delete all related values.

  (After the called script exits, $CALLER will be erased, but $PROTOCULTURE
  will remain globally available unless you explicitly remove it; you can force
  $PROTOCULTURE to always clear when the MACROSS menu loads by modifying the
  varCleanup function at the top of this script)

  Also remember that the MACROSS framework intends for the following variables
  to be global as well, *but* they get cleared every time you exit a script back
  to the MACROSS menu:

    1. $RESULTFILE -- any files generated by your scripts that can be used for
        further eval or formatting in other scripts
    2. $HOWMANY -- the number of successful tasks tracked between scripts
#>
function collab(){
    Param(
        [Parameter(Mandatory=$true)]
        [string]$module,
        [Parameter(Mandatory=$true)]
        [string]$C,
        $extra
    )

    if(-not($module)){
        Read-Host -f CYAN ï¿½
        A script name wasn't supplied!
        ï¿½
        Return
    }
    if(-not($C)){
        Read-Host -f CYAN ï¿½
        A CALLER name wasn't supplied!
        ï¿½
        Return
    }
    else{
        $Global:CALLER = $C
    }

    ## Python check
    $modname = $module -replace "\..+$"
    if( $vf19_ATTS["$modname"].lang -Like "Python*" ){
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
        if( $vf19_NEWWINDOW ){  ## Launches script in new window if user desires; WILL NOT SHARE CORE MACROSS VALUES OR FUNCTIONS!
            $vf19_NEWWINDOW = $false
            if($py){
                #Start-Process powershell.exe "python3 $mod $CALLER $extra"
                Start-Process powershell.exe "py $mod $CALLER $extra"
            }
            else{
               Start-Process powershell.exe -File $mod $CALLER $extra
            }
        }
        else{
            if($py){
                $pyATTS = pyATTS
                if( $extra -ne $PROTOCULTURE ){  ## Pass both $extra and $PROTOCULTURE to python if they are different values
                    #python3 $mod $USR $vf19_DEFAULTPATH $vf19_PYPOD $vf19_numchk $vf19_pylib $vf19_TOOLSROOT $CALLER $PROTOCULTURE $extra
                    py $mod $USR $pyATTS $vf19_DEFAULTPATH $vf19_PYPOD $N_ $vf19_pylib $vf19_TOOLSROOT $CALLER $PROTOCULTURE $extra
                }
                else{
                    #python3 $mod $USR $vf19_DEFAULTPATH $vf19_PYPOD $vf19_numchk $vf19_pylib $vf19_TOOLSROOT $CALLER $PROTOCULTURE
                    py $mod $USR $pyATTS $vf19_DEFAULTPATH $vf19_PYPOD $N_ $vf19_pylib $vf19_TOOLSROOT $CALLER $PROTOCULTURE
                }
            }
            else{
                . $mod $extra
                Remove-Variable -Force CALLER -Scope Global
            }
        }
    }
    else{
        errMsg
    }

}

<#
    availableTypes() details:

    When you need to use the "collab" function to pass values into other scripts, you can find 
    relevant tools by calling this function with the .valtype you want as $1, and if necessary,
    you can pass the language (powershell or python) as the optional param $2.

    If you want the .valtype to be an EXACT match, leave $1 empty and send your filter
    as param $3.

    ## Ask for any scripts that process strings:
    availableTypes  'strings'

    ## Ask only for python scripts with .valtype that is "firewall api":
    availableTypes  ''  'python'  'firewall api'

    Any matching scripts get added to the response list that your script can iterate through
    and send to "collab".

#>
function availableTypes($1,$2,$3){
    $t = @()
    $vf19_ATTS.keys | %{
        if($3 -and $vf19_ATTS[$_].valtype -eq "$3"){
            $match += $vf19_ATTS[$_].fname
        }
        elseif($1 -Match "\w" -and $vf19_ATTS[$_].valtype -Like "*$1*"){
            $match += $vf19_ATTS[$_].fname
        }

        if($match -and $2){
            if($vf19_ATTS[$_].lang -eq $2){
                $t += $match
            }
        }
        elseif($match){
            $t += $match
        }
        Clear-Variable match
    }
    if($t.count -gt 0){
        $t = $t | Sort -Unique
        Return $t
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
            MACROSS' core variables and hashtables
     
################################>
function availableMods($1){
    if( $1 -Match $vf19_CHOICE ){
        # The array starts with '0', so need to adjust the user's input; the menu
        # only accomodates 20 tools right now; after that they'll ALL populate the second page
        # I'll fix this eventually...
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
                ## Set this value in MACROSS.ps1
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
                        py "$vf19_TOOLSDIR\$MODULE" 'HELP' '' '' '' $vf19_pylib
                    }
                    else{

                        ## Convert [macross] objects for python; python will be able to see each script's
                        ## .name and .valtype from the $vf19_ATTS hashtable
                        $pyATTS = pyATTS

                        
                        ## Always send 6 default args for all python scripts to make use of:
                        ## The user; their desktop; the MPOD hashtable; the numchk integer; the filepath to the MACROSS py library;
                        ##  and the path to the \resources folder
                        py "$vf19_TOOLSDIR\$MODULE" $USR $pyATTS $vf19_DEFAULTPATH $vf19_PYPOD $N_ $vf19_pylib $vf19_TOOLSROOT

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
