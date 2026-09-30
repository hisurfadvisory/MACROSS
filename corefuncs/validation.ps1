## Functions for MACROSS task validations


function diamondCount(){
    $valid = @('#_sdf1','#_ver','#_class')
    Remove-Variable -Force dyrl_LATTS -Scope Global   ## Clear old lists from memory
    $Global:dyrl_LATTS = [ordered]@{}           ## Collect MACROSS class info for diamond scripts
    $Global:dyrl_FILECT = 0                     ## Track how many diamonds are installed
    $menunum = 0                                ## Create selector for the main menu
    if($MONTY -or $LIFEOFBRIAN){ 
        $ext = "*.p*"; $pa = ''     ## Count python scripts
    }     
    else{ $ext = "*.ps*" }          ## Ignore python scripts if python not installed

    ## Record the diamonds list
    foreach( $lc in (Get-ChildItem -File "$dyrl_DMDS\$ext" | Sort -Property Name)){
        $check = gc $lc -First 3
        $lclassed = $true
        0..2 | %{
            if(-not ($check[$_] | sls $valid[$_])){ $lclassed = $false }
        }
        if($lclassed){
            $menunum++
            $ldesc = $check[0] -replace "^\S+ " -replace ','
            $lver = $check[1] -replace "^\S+ "
            $lclass = $check[2] -replace "^\S+ "
            $lname = $lc.Name -replace "\..+$"              ## Strip the file extension
            $Global:dyrl_FILECT++                           ## Increment total diamond count
            [macross]$lsc = $lname + ",$lclass" + ",$lver" + ",$($lc.Name)" + ",$ldesc,$menunum"   ## Create custom [macross] object
            $Global:dyrl_LATTS.Add($lname,$lsc)             ## Only collect macross attributes for the user's scripts
        }
    }
    $menunum = 0
    if($MONTY -or $LIFEOFBRIAN){ pyATTS }
}


## Don't leave crap laying around when diamonds quit
## Using -c will perform exit cleanup; using -s will
## sanitize the powershell logs, and skips clearing variables
function varCleanup([switch]$c,[switch]$s){
    ## Logfile sanitize
    if($c){ skSanitize -c }
    if($s){ Return }

    ## Remove any global vars created via the installed_programs.json file
    function customVars_($j="$dyrl_CONTENT\installed_programs.json"){
        if(Test-Path $j){
            (Get-Content -raw $j | ConvertFrom-Json).PSObject.Properties.Value | %{
                if(Get-Variable -Name "$_"){ Remove-Variable -Force "$_" -Scope Global }
            }
        }
    }

    ## Clear PROTOCULTURE values (comment these if you want them to persist even after all
    ## diamonds finish their tasks)
    if($env:PROTOCULTURE){ Remove-Item env:PROTOCULTURE }
    Remove-Variable -Force PROTOCULTURE -Scope Global

    ##
    Remove-Variable -Force vf_*,RESULTFILE,HOWMANY -Scope Script
    Remove-Variable -Force vf_*,dyrl_FILECT,dyrl_REPOCT,dyrl_OPT1,HELP,CALLHOLD,dyrl_CONF,`
    N_,RESULTFILE,HOWMANY,CALLER -Scope Global

    foreach($file in gci $dyrl_TMP){ Remove-Item -Force -Recurse -Path $file.fullname }

    if($env:MACCONF){ Remove-Item env:MACCONF }
    if($env:CALLER){ Remove-Item env:CALLER }
    if($env:HELP){ Remove-Item env:HELP }

    cleanGBIO -s

    if($c){
        customVars_
        if($MONTY){ Remove-Item env:dyrl_*,env:MACROSS,env:USR,env:MACROSSVENV }
        cleanGBIO
        if($env:PYTHONPATH -Like "*$dyrl_PYLIB*"){
            $env:PYTHONPATH = $env:PYTHONPATH -replace "$dyrl_PYLIB;*"
        }
        Remove-Variable -Force dyrl_*,MONTY,ROBOTECH,USR -Scope Global
    }
    else{ $Global:dyrl_MPAGE = 0 }    ## Reset the main menu
}


function yorn(){   #mp
    <#
    ||shorthelp||
    Open a "yes/no" dialog to get response from analysts so your diamond can perform
    an action they choose. Buttons and icons can be changed using -b and -i, and -q
    allows you to customize the message seen by the user.
    Usage:
        yorn [-l SCRIPTNAME|LOOP VALUE] [-t TASKNAME] [-q ALT_TEXT] [-b BUTTON SCHEME] [-i ICON]
    [-d DEFAULT BUTTON] [-n <disables dialog>]

    ||longhelp||
    Quickly get input from users on whether to continue a task.

    To perform a simple loop that requires specific user input to break, use the -n
    option to disable the dialog box, and send your required value using the -l
    option.

    Opens a "Yes/No" window for the user to click on. Returns 'Yes' or 'No' so
    you can kill tasks or continue as the user chooses.

    The default question box asks "Do you want to continue $TASK?" where $TASK
    is the value you send with -t. You can send an alternate question with -q,
    but -t and -q cannot be used together.

    The default button selected for the user is "2", but you can change this with
    "-d" (Minimum 1, Max 3 depending on the scheme; for example, scheme 0 only
    has a single button, so auto-selecting it would require using -d 1).

    If you want to modify the window options that get displayed, send the number
    associated with -b (BUTTONS) or -i (ICONS) below:

        ICONS:                   BUTTON SCHEMES:
        Stop          16         OK               0
        Question      32         OKCancel         1
        Exclamation   48         AbortRetryIgnore 2
        Information   64         YesNoCancel      3
                                 YesNo            4
                                 RetryCancel      5

    Values will equal whichever of the buttons the user clicks, i.e. "OK", "Cancel",
    "Yes", "No", etc.

    ||examples||

    ## Pause your diamond WITHOUT a dialog box until the user acknowledges a message
    ## by entering "ack":
        yorn -l 'ack' -n

    ## Change the default scheme from "Question" icon and "YesNo" buttons to
    ## "Information" icon and "OK" button, and auto-select the button using -d:
        yorn -l $SCRIPTNAME -t 'Task is complete!' -b 0 -i 64 -d 1 | Out-Null

    ## Get the user's response:
        $answer = yorn -l $SCRIPTNAME -t $CURRENT_TASK
        if( $answer -eq 'No' ){
            $STOP_DOING_TASK
        }

    ## Use a custom text string (-q) to get the response:
        $answer = yorn -l $SCRIPTNAME -q 'Do you want to write results to file?'
        if( $answer -eq 'Yes' ){
            $write_to_file
        }

    #>
    param(
        [Parameter(Mandatory)]
        [string]$label,
        [string]$task,
        [string]$question,
        [int]$button=4,
        [int]$icon=32,
        [int]$default=2,
        [switch]$nobox
    )

    if($nobox){
        while($z -ne $label){
            w 'Enter ' g -i
            w $label -b y -f k -i -n
            w 'to continue: ' g -i
            $z = Read-Host
        }
        Return
    }

    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')


    $Buttons = @{
        0='OK';
        1='OKCancel';
        2='AbortRetryIgnore';
        3='YesNoCancel';
        4='YesNo';
        5='RetryCancel'
    }
    $Icons = @{
        16='Stop';
        32='Question';
        48='Exclamation';
        64='Information'
    }


    if($question){ $msg = $question }
    else{ $msg = "Do you want to continue $($task)?" }


    Return [System.Windows.Forms.MessageBox]::Show(
        "$msg",                     # Window Message
        "$label",                   # Window Title
        "$($Buttons[$button])",     # Button scheme
        "$($Icons[$icon])",         # Icon
        "Button$default"            # Set default button choice
    )
}

function errMsg($m=0,$c='c',$f='MACROSS.errMsg',[switch]$s){   #mp
    <#
    ||shorthelp||
        errMsg [-m  1-6|MESSAGE STRING] [-c COLOR b|k|c|g|m|r|y] [-f FUNCTION NAME]
            [-s SHUTDOWN]

    ||longhelp||
    Use -m to select from a list of canned error messages to display onscreen, or send an error
    message specific to your diamond that will both write to screen and write to a
    MACROSS log file. There are 6 canned messages:

        1 - 'You are not in the correct security group.'
        2 - 'Unable to connect with Active-Directory...'
        3 - 'Invalid parameter, update checks and/or downloads aborted.'
        4 - 'That is an invalid entry!'
        5 - 'ERROR - missing required value(s).'
        6 - 'UNKNOWN ERROR - something went wrong...'


    If you send a custom message instead of one of the numbers above, the message will
    also be written to the MACROSS logs if logging is enabled.

    Using the -s param will put MACROSS in graceful shutdown following the error message
    so you can cleanly restart it.

    The -c option colorizes your message on the screen.

    The -f option lets you specify which function or diamond generated the message.


    ||examples||
    Display an AD error in white text (default is cyan):

        errMsg 2 -c w

    Display a custom message from "someFunction" in (r)ed text, and write it to logs:

        errMsg 'The coffee machine is broken!' -c r -f someFunction



    #>
    $msgs = @(
        'ERROR: that module is unavailable!',
        'You are not in the correct security group.',
        'Unable to connect with Active-Directory...',
        'Invalid parameter, update checks and/or downloads aborted.',
        'That is an invalid entry!',
        'ERROR - missing required value(s).',
        'UNKNOWN ERROR - something went wrong...'
    )

    if($m.getType().Name -eq 'String'){
        w " $m`n" $c
        errLog ERROR $f $m
    }
    else{
        $msg = $msgs[$([int]$m)]
        if( $s -or ($m -eq [int]1) ){
            errLog ERROR $f "$($msg + '  ' + $dyrl_mErr)"
            w $c "
            $m Exiting...`n" $c
            sleep 2
            Remove-Variable -Force vf_* -Scope Global
        }
        elseif( $m -in 2..6 ){  ## Error for access check
            w "   $msg `n`n" $c
            errLog ERROR $f $msg
            sleep 2
        }
        else{    ## Default error message for diamondchecks (don't send any params)
            cls
            w "`n`n`t $msg `n" $c
            $Global:dyrl_Z = ''  ## Prevent loops in the main menu
            sleep 1
        }
    }
    if($s){ varCleanup -c; Exit }
}


## Give python what it needs to convert the [macross] class
function pyATTS(){
    $h2j = "$($dyrl_LATTS | ConvertTo-Json -Depth 10)"
    noBOM -t $h2j -f "$($dyrl_PG[1])\LATTS.vf1" -m
}
function macrossMirror([switch]$c,$nval="11,153,731"){
    if($c){
        foreach($e in @('PROTOCULTURE','MACCONF','MACROSS','CALLER','TEMPENV')){
            gci env: | %{if($_.name -eq $e){ Remove-Item "env:$e" }}
        }
        if($env:HELP){ Remove-Item env:HELP }
    }
    else{
        $np,$opt = 'F','F'
        $l = mkList
        startUp; $dyrl_CONF.keys | Sort -Descending | ?{$_ -notIn @('di1','di2','sky')} | %{
            [void]$l.add($_ + '::' + "$($dyrl_CONF[$_])")
        }
        $psv = $PSVersionTable.PSVersion.Major
        $env:MACCONF = "$($l -join ';')"
        if($ROBOTECH){ $np = 'T' }
        if($dyrl_OPT1){ $opt = 'T' }
        if($HELP){ $env:HELP = 'T' }
        if($nval.count -gt 1){
            $lavn = @()
            $nval | %{$nnl = $_ -Join '';$lavn += $nnl}
            $nval = $lavn -Join ','
        }
        $logfile = "$dyrl_LOG\$(Get-Date -format 'yyyy-MM-dd')`.log"
        $env:MACROSS = "$dyrl_MACROSS;$dyrl_OUTFILES;$dyrl_CONTENT;$dyrl_LOG;$nval;$USR;$dyrl_TMP;$np;$opt;$psv"
        if($PROTOCULTURE){ $env:PROTOCULTURE = $PROTOCULTURE }
        if($CALLER){ $env:CALLER = $CALLER }
    }
}

function xEntry($x='456E746572207468652061646D696E2070617373776F7264'){
    gerwalk $x -h
    $z = Read-Host "`n`n $dyrl_PT" -AsSecureString;
    Return $(byter $z)
}

## Set default values for the networks
function setLocal([switch]$init,[switch]$mine){   #mp
    <#
    ||shorthelp||
        $nets = setLocal

    ||longhelp||
    Dynamically generates the domain & first two octets for your IPv4 and IPv6 networks so
    you don't need to hardcode entire IPs.

    ||examples||

    $ip = setLocal

    $enclave    = [string]$ip[0]
    $v4         = [string]$ip[1]
    $v6         = [string]$ip[2]
    $domain     = [string]$ip[3]


    #>
    if($init){
        gerwalk 'MmUyYTI4Mjg2Nzc2N2M2NzY1NzQyZDc2NjE3MjY5NjE2MjZjNjUyOTI4MjA3YzVjN
        WM3MzI5MmIyODY0MjgyODc5NzI2YzI5M2YyZTJhMjkzZjI5M2Y1YzJhN2M3Mzc0NjE3Mjc0NzU3
        MDdjNDM0ZjRlNDYyZTdiMzEyYzMyN2QyODczNmI3OTdjNjI2YzMwN2M2NDY5Mjk3YzY3NjU3Mjc
        3NjE2YzZiN2M1YzI0NGU1ZjdjNjQ3OTcyNmM1ZjQzNGY0ZTQ2NDk0NzdjNmM2ZjYzNjE2YzI4Nz
        I2NTYxNjQ3Yzc3NzI2OTc0NjUyOTcwN2MyODc1NzA3YzczNjk2NDY1N2M2NDZmNzc2ZTI5Nzc3M
        jY5NzQ2NTI5MmUyYQ=='
        gerwalk -h $dyrl_PT
        Return "$dyrl_PT"
    }

    $local = [System.Net.Dns]::GetHostEntry($dyrl_HN0)
    foreach($m in $local.AddressList){
        if($m -Like '*:*'){ $a = ($m -Split ':')[0..3] -Join ':' }
        else{ $a = ($m -Split '\.')[0..1] -Join '.' }
        if($a -Like 'fe80*'){ $l6 = $a }
        elseif($a -Like '169*'){ $l4 = $a }
        elseif($a -Like "*:*"){ $i6 = $a }
        else{
            if($mine -and [int]$dyrl_PSVER -ge 6 ){ Return $m.IPAddressToString }
            if($mine -and [int]$dyrl_PSVER -lt 6 ){ Return $m }
            else{ $i4 = $a }
        }
    }
    if($l6 -and -not $i6){ $i6 = $l6 }
    elseif(-not $i6){ $i6 = $null }
    if($l4 -and -not $i4){ $i4 = $l4 }
    elseif(-not $i4){ $i4 = $null }
    try{ $dom = ".$($env:USERDNSDOMAIN.toLower())" }
    catch{ $dom = $null }

    Return @("$i4`.","$i6`:",$dom)

}

function setUser($ac,[switch]$c,[switch]$i){
    function rs_(){gerwalk $dyrl_CONF.uac; Return [int]$dyrl_PT}
    if($c){
        $Global:USR = $dyrl_USRCHK
        Return
    }
    $rs = rs_
    if($ac){
        $acn = $ac[4]
        if($rs){
            $fm = "Mismatch for tier $acn"; $fc = $($dyrl_modn[1] / ($dyrl_ACCESSTIER.Item1) -eq $dyrl_modn[0])
            if(! $dyrl_USERAUTH){ Return $dyrl_ACCESSTIER.Item2 }
            elseif($ac -eq 'common'){ Return $fc }
            elseif($fc){
                2..4 | %{
                    if($ac -eq "tier$($_-1)" -and $dyrl_ACCESSTIER."Item$_"){ Return ($dyrl_ACCESSTIER."Item$_") }
                }
            }
            else{ errLog AUTH 'MACROSS.setUser' "$fm ($dyrl_HN0)"; Return $fc }
        }
        else{ Return $dyrl_ACCESSTIER.Item2 }
    }
    elseif($i){
        Remove-Variable -Force dyrl_ACCESSTIER -Scope Global
        gerwalk -h 596F7520617265206E6F7420696E20746865206B6E6F776E2075736572206C697374732E
        $em1 = $dyrl_PT
        gerwalk -h 436F756C64206E6F74207665726966792075736572206163636573732E
        $em2 = $dyrl_PT

        ## First attempt to avoid any local weirdness
        $u = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
        if( ! $u ){ $u = $env:USERNAME }

        ## $USR is a common variable, so don't set read-only but use this to reclaim it if
        ## another diamond has overwritten the value. Or, you can just use the read-only
        ## $dyrl_USRCHK instead. But it is more chars to write and I'm lazy. :p
        $Global:USR = $u -replace "^(.+\\)?"
        lockIn -n dyrl_USRCHK -v $USR
        $tiers = @()

        foreach($w in @('r','a')){
            1..3 | %{
                $k = "t$w$_"
                gerwalk $dyrl_CONF.$k
                $dyrl_PT -Split ',' | %{if($_ -eq $USR){ $tiers += $k }}
            }
        }


        try{ lockIn -n ROBOTECH -v (Get-ADUser -Filter "samAccountName -eq '$USR'" -Properties LockedOut).LockedOut }
        catch{ lockIn -n ROBOTECH -v $true }

        function tup_($1,$2,$3,$4,$g=$false){
            lockIn -n dyrl_ACCESSTIER -v $([System.Tuple]::Create($1,$2,$3,$4))
            lockIn -n dyrl_USERAUTH -v $g
        }

        if($rs -and $tiers.count -eq 0){
            errMsg $em1
            varCleanup -c
            Exit 
        }
        if(! $rs){
            lockIn -n dyrl_modn -v @(111,555)
            tup_ 1000 $true $true $true
        }
        elseif($tiers.count -gt 0){
            $tx1,$tx2,$tx3 = $false,$false,$false
            $id = Get-Random -min 10000000 -max 9999999999
            $idm = Get-Random -min 500 -max 50000
            $idc = $($id * $idm)
            foreach($ti in $tiers){
                if($ti -Like "*3"){ $tx3 = $true }
                elseif($ti -Like "*2"){ $tx2 = $true }
                elseif($ti -Like "*1"){ $tx1 = $true }
            }
            lockIn -n dyrl_modn -v @($idm,$idc)


            #########################################################
            ## Uncomment these if you want to load sysinternals paths into $dyrl_SYSIN
            #########################################################
            <#if(-not $ROBOTECH){
                $s = 'C:\Program Files\Microsoft Sysinternals Suite'
                if(Test-Path $s){
                    $si=@{}
                    ls $s | Select -ExpandProperty FullName | where{$_ -Like "*exe"} |
                    %{$si.Add($(($_ -replace "^.+\\" -replace "\.exe$"),$_)) | Out-Null}
                    lockIn -n dyrl_SYSIN -v $si
                }
            }#>

            tup_ $id $tx1 $tx2 $tx3 -g $true

            if($dyrl_USERAUTH){
                errLog AUTH 'MACROSS.setUser' "$USR successfully launched MACROSS ($dyrl_HN0)"
            }

            rv id,idm,idc,priv,tx*
        }
        elseif($rs){
            errMsg $em2
            varCleanup -c
            Exit
        }
        
    }
    elseif(-not $rs){ errLog AUTH 'MACROSS.setUser' "$USR successfully launched MACROSS ($dyrl_HN0)" }
}


## Clean up the logging
function skSanitize([switch]$c=$false){
    $mixed = 'M2MgNTIgNDUgNDQgNDEgNDMgNTQgNDUgNDQgM2UgMmMgMjAgNTQgNjgg
    NjEgNzQgMjcgNzMgMjAgNjEgMjAgNzAgNzIgNjkgNzYgNjkgNmMgNjUgNjcgNjUgNj
    QgMjAgNjMgNmYgNmQgNmQgNjEgNmUgNjQgMmUgMmMgMjAgNDMgNTUgNTIgNTIgNDUg
    NGUgNTQgMjAgNDMgNGYgNGUgNDYgNDkgNDcgNTUgNTIgNDEgNTQgNDkgNGYgNGUgMj
    AgNGIgNDUgNTkgNTMgMmMgNGYgNzIgNjUgMjAgNmUgNmYgMjAgNzUgNzQgNjEgMjAg
    NmYgMjAgNmIgNjkgNmIgNjUgMjEgMmMgNDQgNmYgMjAgNzkgNmYgNzUgMjAgNmUgNj
    UgNjUgNjQgMjAgNzQgNmYgMjAgNjEgNjQgNjQgMjAgNmYgNzIgMjAgNjMgNjggNjEg
    NmUgNjcgNjUgMjAgNjEgNmUgNzkgMjAgNjQgNjUgNjYgNjEgNzUgNmMgNzQgMjAgNj
    MgNmYgNmUgNjYgNjkgNjcgNzMgM2YgMjAgMjggNzkgMmYgNmUgMjk='
    if(! $dyrl_CONF){ startUp }
    function transcripts_($dir,$message=''){
        try{
            $tlist = Get-ChildItem -Recurse "$dir\$(Get-Date -format 'yyyyMMdd')\Powershell_transcript*txt" |
                ?{$_.LastWriteTime -ge (Get-Date).AddDays(-1)} | Sort -d -Property LastWriteTime
        }
        catch{
            if($c){ errLog INFO "$($msgs[0]) $($msgs[3])" }
            Return
        }

        foreach($t in $tlist | ?{$t.Name -ne $tlist[0].Name}){
            $dirty = $false; $redact = $false
            if(sls $scrub $t.Fullname){
                Continue
            }
            else{
                $scan = Get-Content $t.Fullname
                $modify = ''
                foreach($line in $scan){
					if($line -Like "*key=*"){
						$line = $line -replace "key=[\w-_\.]+[^\w-_\.]",'key=<MACROSS REDACTED>'
						$redact = $true
						$dirty = $true
					}
                    elseif($line -Like "*passw*"){
						$line = $line -replace "passw(ord)?[\s\t]?[\S\T]+",'passw <MACROSS REDACTED>'
						$redact = $true
						$dirty = $true
					}
                    elseif($line -eq "$($mix[1])" -or $line -Like "*$($mix[2])"){
                        $redact = $true
                        $dirty = $true
                    }
                    elseif($redact){
                        if($line -Like "*$($mix[3])*"){
                            $redact = $false
                        }
                        elseif($line -Like "*$($mix[4])"){
                            $redact = $false
                        }
                        else{ $line = $scrub }
                    }
                    elseif($line -Match $mix[0] -or $line -Match $mix[1]){
                        $dirty = $true
                        $line = $scrub
                    }

                    $modify += "$line`n"
                }
                if($dirty){
                    $modify | Set-Content $t.Fullname
                    errLog INFO $msgs[1]
                }
            }
        }
    }

    $msgs = @(
		'Clean exit;',
		'Powershell history file was sanitized',
		'nothing to sanitize in the transcripts',
		'there are no powershell transcripts to sanitize.',
		'possible permission lock.'
	)

    ## Sanitize logs
    $psr = "$env:AppData\Microsoft\Windows\Powershell\PSReadline"
    if(Test-Path $psr){
        $sanitize = mkList
        $pslog = (Get-ChildItem "$psr\*" | ?{$_.LastWriteTime -gt $(Get-Date).AddHours(-24)}).Fullname
        if(Select-String -Pattern "(ssh |curl.exe )" $pslog){
            foreach($line in Get-Content $pslog){
                if($line -Like "ssh *"){ $line = $line -replace $mix[2],"echo | $($mix[3])" }
                elseif($line -Like "*curl.exe *"){ $line = $line -replace $mix[1],$mix[3] -replace $mix[0],$mix[3] }
                $sanitize.Add($line) | Out-Null
            }
			try{
				$sanitize | Set-Content $pslog
				errLog INFO 'MACROSS.skSanitize' $msgs[1]
			}
			catch{
				errLog WARN 'MACROSS.skSanitize' "Could not scrub $pslog; $($msgs[4])"
				return
			}
        }
    }
    elseif($c){ errLog INFO "$($msgs[0]) $($msgs[2])" }
}


function valkyrie(){   #mp
    <#
    ||shorthelp||
    Enrich or collect data from other MACROSS diamonds. An optional value can be
    sent as parameter three if the called diamond's .evalmax value is 2.
    Usage:
        valkyrie [-m SCRIPTNAME] [-c YOUR_SCRIPTNAME] [-s ADDITIONAL_PARAM_TO_SEND]
            [-n OPEN IN NEW WINDOW]

    ||longhelp||
    Call this function from one diamond to load your current investigation values into
    another. You can send up to 3 parameters.

    The 1st param is the diamond ID you're calling, and is *required*. The diamond
    also needs to be located in the modules folder and recognized by MACROSS, i.e. it
    has the magic terms in the first three lines --

        #_sdf1
        #_ver
        #_class

    The 2nd param is the name of the diamond calling this function ($CALLER) and is
    required. (I set this to be required so that you always have the option to have
    your diamonds lookup attributes from  the $dyrl_LATTS array and determine its
    .valtype, .lang, etc.)

    The 3rd param -n will launch the diamond in a new window. You should only
    do this with diamonds that do NOT rely on MACROSS resources and functions. The
    new window is an entirely separate session from your running MACROSS instance.

    The 4th param -s is an ***optional*** item you're passing if you want something
    other than $PROTOCULTURE to be eval'd, or if the diamond being called requires 2 eval
    parameters. (Note -- that diamond must be coded to accept this optional param as
    "$spiritia", otherwise it will fail).

    The $PROTOCULTURE variable should **NEVER** be passed as a parameter. It should only
    ever be a global variable all diamonds can read. If you pass another value to valkyrie,
    make sure the diamond you are calling has an .evalmax value greater than 0.

    (After the called diamond exits, $CALLER will be erased, but $PROTOCULTURE will remain
    globally available unless you explicitly remove it; you can force $PROTOCULTURE to always
    clear when the MACROSS menu loads by modifying the varCleanup function at the top of this
    script)

    Also remember that MACROSS intends for the following variables to be global as well, *but*
    they get cleared every time you exit a diamond back to the MACROSS menu:

    1. $RESULTFILE -- any files generated by your diamonds that can be used for
        further eval or formatting in other diamonds
    2. $HOWMANY -- the number of successful tasks tracked between diamonds

    ||examples||
    Example on how you might use the findDF function to search for diamonds that look up data on
    hostnames, and then filtering that list of diamonds based on their .evalmax and .rtype values
    to automatically call them via the valkyrie function to collect data on the hostnames you're
    investigating:

        $results = @()
        $list = findDF 'hostname'
        $hostnames | foreach-object{
            $PROTOCULTURE = $_
            foreach( $diamond in $list ){
                if($diamond.evalmax -gt 0 ` -and $diamond.rtype -ne 'none'){
                    $results += $(valkyrie $diamond.fname 'MyScriptName')
                }
            }
        }

    ** Make sure to be consistent when assigning an .rtype attribute to your diamonds, so that
    the findDF function gives you the correct diamonds every time! For example, if there are diamonds
    that return straight json vs. writing json to a file, you might use separate .rtypes, like 'json'
    vs. 'json file'

    **otaku notes: "valkyrie" is the name of the original fighters developed to combat the giant
     alien Zentradi. The valkyrie had 3 modes: a traditional fighter jet, a "battroid" mecha
     (giant robot) and "gerwalk", a hybrid form as a fighter jet with arms and legs.

     "spiritia" is the term used by the alien Protodevlin to describethe energy & morale generated
     by human music. Specifically, the band "Firebomber's" rock anthems.



    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$m,
        [Parameter(Mandatory=$true)]
        [string]$c,
        [switch]$n=$false,
        $sp=$null
    )

    function pyTool_(){
        if($dyrl_NEWW){
            if($sp){ launcher $mod -n -p -alt $sp -v $vtype }
            else{ launcher $mod -n -p -v $vtype }
        }
        elseif($sp){ launcher $mod -p -alt $sp -v $vtype -x $sorted }
        else{ launcher $mod -p -v $vtype -x $sorted }
    }


    $Global:CALLER = $c

    if($n){ $Global:dyrl_NEWW = $true }

    $diamond = $dyrl_LATTS.$m.fname
    $vtype = $dyrl_LATTS.$c.valtype
    $mod = "$dyrl_DMDS\$diamond" -replace "\\\\",'\'
    $valid = setUser "$($dyrl_LATTS.$m.access)"

    if( $valid -and (Test-Path -Path $mod) ){
        startUp
        if($dyrl_LATTS.$m.lang -eq 'python'){
            $result = "$($dyrl_PG[1])\PROTOCULTURE.vf1"
            $sorted = "$($N_[0]),$($N_[1] -join ''),$($N_[2] -join '')"
            pyTool_
            if(Test-Path $result){
                $result = Get-Content -Raw $result | ConvertFrom-Json
                #$tool = $result.PSObject.Properties.Name
                if($result.result -eq 'WAITING'){
                    Return $result.protoculture
                }
                else{
                    Return $result.result
                }
            }
        }
        else{
            if( $dyrl_NEWW ){
                ## Launches diamond in new window if user desires; WILL NOT SHARE CORE MACROSS VALUES OR FUNCTIONS!
                if($sp -and $sp -ne $PROTOCULTURE){launcher -n "$mod -spiritia $sp" -v $vtype}
                else{launcher $mod -v $vtype}
            }
            else{
                if($sp -and $sp -ne $PROTOCULTURE){ . $mod -spiritia $sp }
                else{ launcher $mod -v $vtype }
            }
            Remove-Variable -Force CALLER -Scope Global
        }

        $Global:dyrl_NEWW = $false  ## Always reset new-window value

    }
    else{ errMsg }

    Remove-Variable -Force CALLER -Scope Global

}




function findDF($v,$l,[switch]$e,$m=$null){   #mp
    <#
    ||shorthelp||
    Search MACROSS diamonds by their .valtype attributes. Use -l to specify
    language, and -e to match exact .valtypes
    Usage:
        findDF [-v VALTYPE1,VALTYPE2...] [-l LANGUAGE] [-e FORCE_EXACT_MATCH]
    [-m number of parameters]

    ||longhelp||
    When you need to use the "valkyrie" function to pass values into other scripts, you can find
    relevant diamonds by calling this function with the .valtypes you want as parameter -v (comma-
    separated), and if necessary, you can pass the language (powershell or python) as the optional
    parameter -l.

    Use -e if you want the .valtype to be an EXACT match.

    The -m option lets you specify scripts that accept n number of parameters (default is 1: if
    a MACROSS diamondonly looks for a $PROTOCULTURE value, its .evalmax value should be 1; if a diamond can
    accept a separate parameter, the .evalmax will be 2; if niether of those is true, the .evalmax
    will be 0).

    Any diamonds matching your request get added to the response list, that returns to your script.
    You can use that list to automatically query other diamonds via the "valkyrie" function.

    ||examples||
    Ask for any scripts that process usernames, including EDR APIs:

        findDF 'user, edr'

    Ask only for python scripts with .valtype that equals "firewall api" or "url lookup":

        findDF -l python -v 'firewall api,url lookup' -e

    **otaku note: "Diamond Force" is the name of the top fighter squadron assigned to Battle 7,
    the Macross 7 Expedition fleet's battle carrier.

    #>
    function ce_($1,$2){
        if($1 -eq $null){ $q = $true}
        elseif($1 -eq $2){$q = $true }
        else{$q=$false}
        Return $q
    }
    $t = mkList
    $v = ($v -replace ', ',',') -Split ','
    $c = 0
    foreach($vv in $v){
        foreach($nm in $dyrl_LATTS.keys){
            $lnm = $dyrl_LATTS.$nm
            $max = ce_ $m $lnm.evalmax
            if($max){
                if($e -and $l){
                    if($lnm.valtype -eq "$vv" -and $lnm.lang -eq "$l"){
                        $t.Add($nm) | Out-Null
                        $c++
                    }
                }
                elseif($e){
                    if($lnm.valtype -eq "$vv"){
                        $t.Add($nm) | Out-Null
                        $c++
                    }
                }
                elseif($l){
                    if($lnm.lang -eq "$l" -and $lnm.valtype -Like "*$vv*"){
                        $t.Add($nm) | Out-Null
                        $c++
                    }
                }
                elseif($lnm.valtype -Like "*$vv*"){
                    $t.Add($nm) | Out-Null
                    $c++
                }
            }
        }
    }
    Return $($t.toArray() | Sort -U)
}


## Execute the selected automation tool, with any alt options. Display errors for failed launch.
## $alt options are dependent on the tool itself; sending an $alt to the wrong tool as the
## -kreese parameter can cause problems!
function launcher(){
    param(
        [switch]$new=$false,            ## Open new window
        [Parameter(Mandatory=$true)]
        [string]$command,               ## diamond script
        [string]$py='2',                ## execute system python (1) or alt python (0)
        $alt=$null,                     ## -spiritia param/arg
        [string]$vt,                    ## diamond valtype
        [string]$xm=$null               ## option
    )
    function err_(){
        errLog ERROR 'MACROSS.launcher' "Failed to launch $command"
        macrossHelp -h
    }
    

    ## Regardless of 'python0' or 'python1' as the diamond's .lang value, if only one
    ## python version is available, we'll attempt to execute it.
    function whichPy_($option){
        pyATTS
        if($option -eq '1' -or -not $MONTY){
            try{ py $command }
            catch{ err_ }
        }
        elseif($option -eq '0' -or -not $LIFEOFBRIAN){
            try{ & $dyrl_PYCROSS $command }
            catch{ err_ }
        }
    }

    if($PSVersionTable.PSVersion.Major -lt 7){ $exe = 'powershell.exe' }
    else{ $exe = 'pwsh.exe' }

    if($py -ne '2'){
        if($alt){ $command = "$command $alt" }
        whichPy_ "$py"
    }
    elseif($alt){
        if($new){
            try{ Start-Process $exe $command -kreese $alt }
            catch{ err_ }
        }
        else{
            try{ . $command -kreese $alt }
            catch{ err_ }
        }
    }
    else{
        if($new){
            try{ Start-Process $exe $command }
            catch{ err_ }
        }
        else{
            try{ . $command }
            catch{ err_ }
        }
    }
}

################################
## Verify a diamond's location, permissions, and options, get it ready for launch; $r will force
## an update/download of the latest version of the selected diamond if a repo is configured
################################
function flightDeck($dmd,[switch]$r){

    if($dmd -in $dyrl_LATTS.keys){

        $tf = $($dyrl_LATTS.$dmd.fname)
        $DIAMOND = "$dyrl_DMDS\$tf"

        # Make sure the diamond still exists before trying to run
        $check = Test-Path $DIAMOND -PathType Leaf
        $valid = setUser -a "$($dyrl_LATTS.$dmd.access)"
        $valtype = $dyrl_LATTS.$dmd.valtype
        $dlang = $dyrl_LATTS.$dmd.lang

        if( $check -and $valid ){
            startUp
            $sorted = "$($N_[0]),$($N_[1] -join ''),$($N_[2] -join '')"

            # Run the diamond selected by the user
            if( $dlang -Like 'python*' ){
                cls
                if($dyrl_NEWW){
                    $DIAMOND = $($DIAMOND -replace "\\\\",'\') ## I don't know why extra slashes get added "sometimes but not always" :/
                    launcher $DIAMOND -p $dlang[-1] -n -v $valtype
                }
                else{
                    launcher $DIAMOND -p $dlang[-1] -v $valtype -x $sorted
                }
            }
            else{
                $dmd = ''
                ## Launch diamond in new window if user desires; WILL NOT SHARE CORE MACROSS FUNCTIONS!
                if( $dyrl_NEWW ){ launcher -n $DIAMOND -v $valtype }
                else{ launcher $DIAMOND -v $valtype }
            }
            $Global:dyrl_NEWW = $false  ## Always make sure this is reset

        }
        elseif($check){
            w '  Wrong tier group   ' -b r -f k     ## Incorrect tier group
            sleep 2
        }
        else{
            errMsg
        }
    }

    if($LASTEXITCODE -gt 0){
        macrossHelp -h
    }
}
## Set default values for python execution
function setPY(){
    $npi = "No python installed"

    ## This is the *usual* path with the "py" alias that will be used if $LIFEOFBRIAN 
    ## is $true:
    ##      "$env:LOCALAPPDATA\Programs\Python\Python3*\python.exe"
    ## If you specified an alternate python install during setup, set your diamond
    ## script's .lang value to "python0" to use it.
    ## MACROSS' macross library was only tested with python 3.13, so your mileage 
    ## may vary.

    $versions = mkList
    try{ $version = "$(py -V)" }
    catch{ $version = $null }
    if($version){ 
        if(-not $LIFEOFBRIAN){ lockIn -n LIFEOFBRIAN -v $true }
        $versions += $version
    }
    if($dyrl_PYCROSS -and (Test-Path $dyrl_PYCROSS)){
        $altver = "$(& $dyrl_PYCROSS -V)"
        if($altver){
            $versions += $altver
            lockIn -n MONTY -v $true
        }
    }
    if($versions.count -eq 0){ $versions += $npi }

    $Global:dyrl_PYVERS = $versions -Join ' | '

    ## Make sure powershell can find the macross python library
    if($dyrl_PYVERS -ne $npi){
        if($LIFEOFBRIAN -and (Test-Path "$($dyrl_PG[0])\__init__.py")){
            if(-not $env:PYTHONPATH){ $env:PYTHONPATH = $dyrl_PG[0] }
            elseif($env:PYTHONPATH -notMatch $dyrl_PG[0]){ $env:PYTHONPATH = "$($dyrl_PG[0]);$env:PYTHONPATH" }
        }
        lockIn -n dyrl_PG -v @("$dyrl_PYLIB","$dyrl_PYLIB\gbio")
        if(-not $env:PYTHONPATH){
            $env:PYTHONPATH = $dyrl_PYLIB
        }
        elseif($env:PYTHONPATH -notLike "*$dyrl_PYLIB*"){
            $env:PYTHONPATH += ";$dyrl_PYLIB"
        }
    }
}
