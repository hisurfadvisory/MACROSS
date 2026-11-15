## Functions for MACROSS task validations

## Validate diamond scripts in the diamonds folder
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
            [macross]$lsc = $lname + ",$lclass" + ",$lver" + ",$($lc.Fullname)" + ",$ldesc,$menunum"   ## Create custom [macross] object
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

    if($env:MACONF){ Remove-Item env:MACONF }
    if($env:CALLER){ Remove-Item env:CALLER }
    if($env:HELP){ Remove-Item env:HELP }

    cleanGBIO -s

    if($c){
        customVars_
        Remove-Item env:dyrl_* -ErrorAction SilentlyContinue
        if($MONTY){ Remove-Item env:MACROSS,env:USR,env:MACROSSVENV -ErrorAction SilentlyContinue }
        cleanGBIO
        if($env:PYTHONPATH -Like "*$dyrl_PYLIB*"){
            $env:PYTHONPATH = $env:PYTHONPATH -replace "$([regex]::Escape($dyrl_PYLIB));*"
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
            w "
            $msg Exiting...`n" $c
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
        foreach($e in @('PROTOCULTURE','MACONF','MACROSS','CALLER','TEMPENV')){
            gci env: | %{if($_.name -eq $e){ Remove-Item "env:$e" }}
        }
        if($env:HELP){ Remove-Item env:HELP }
    }
    else{
        $np,$opt = 'F','F'
        $l = mkList
        startUp; $dyrl_CONF.keys | Sort -Descending | ?{$_ -notIn @('di1','di2','sky','tsk')} | %{     ## python never needs the sealed team key
            [void]$l.add($_ + '::' + "$($dyrl_CONF[$_])")
        }
        $psv = $PSVersionTable.PSVersion.Major
        $env:MACONF = "$($l -join ';')"
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
        ## Debug-restriction pattern used by consoleDebug: hex wrapping base64, so the hex is
        ## decoded first. (The previous version decoded in the opposite order and returned an
        ## empty or garbled pattern.)
        gerwalk -h (@(
            '4B4438365847496F507A706E646E786E5A585174646D4679615746696247563863335A386332',
            '56304C585A68636D6C68596D786C66484A3266484A6C625739325A53313259584A7059574A73',
            '5A587875646E78755A586374646D467961574669624756385932783266474E735A5746794C58',
            '5A68636D6C68596D786C4B567869664678694B443836646D467961574669624756385A6E5675',
            '59335270623234704F6E7863596E427A646D46796157466962475663596E7863596E4E6C6333',
            '4E706232357A644746305A5678696646776B5A58686C59335630615739755932397564475634',
            '644678696646776B4B4438365A327876596D46734F6E787A59334A7063485136664778765932',
            '46734F696B2F4B4438365A486C796246386F507A706A6232356D58486371664774755A317833',
            '4B6E78776448786859324E6C63334E30615756796648567A5A584A686458526F664731765A47',
            '353864584E795932687266474A735A436C38626C387058474A385847496F507A707459574E76',
            '626D5A38644756746347567564696C63596E7863596D52695A79672F4F6E4A34664764686447',
            '5570583378635969672F4F6E4E3059584A3064584238636E56755932397564476C7564575638',
            '636E567563335268636E5238636E56756257396B61575A3566484A31626E567A5A584A306157',
            '567966486470656D46795A4878685A475233636D6C305A584E38636D563064584A755A47566D',
            '5958567364487831634752686447567A61336C384B4438366458423863326C6B5A58786B6233',
            '64754B5864796158526C5848637166477876593246734B443836636D56685A487833636D6C30',
            '5A536C776648686C626E5279655878696558526C636E787459574E7962334E7A62576C79636D',
            '397966484E7759574E6C5A6D39735A4878725958646862573979615678334B6E7872626D6463',
            '64797438593239755A6C78334B313938593239755A6E4E705A323570626D64725A586B705847',
            '4A3858474A7A5A58527362324E6862467869573134376646307158484D74615878635969672F',
            '4F6E42796233526C5933526C5A4752686447463859334A3563485277636D39305A574E305A47',
            '46305958786A636E6C776448567563484A766447566A6447526864474638626D4E7965584230',
            '584863714B567869664678694B4438366157563466476C75646D39725A53316C654842795A58',
            '4E7A6157397566476C75646D39725A53316A623231745957356B66476C6A625878685A475174',
            '64486C775A58787A644746796443317162324A3863335268636E517463484A765932567A6333',
            '78795A575A735A574E306157397566475A796232316959584E6C4E6A527A64484A70626D6370',
            '58474A385847496F507A70776233646C636E4E6F5A57787366484233633267704B4438365843',
            '356C65475570503178696646786263324E7961584230596D7876593274635858787A59334A70',
            '634852696247396A613178644F6A706A636D56686447563858433570626E5A76613256636379',
            '70634B48776F507A7065664673376648736F5856787A4B696B6D58484D71577968634A436369',
            '5858776F507A7065664673376648736F5856787A4B696C634C6C787A4B31736F5843516E496C',
            '3070'
        ) -join '')
        gerwalk $dyrl_PT
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


## Redact authentication material (passwords, tokens, keys, connection strings, etc.)
## from a block of text
function skScrub(){   #mp
    <#
    ||shorthelp||
    Redact passwords, tokens, API keys and other authentication strings from text.
    Usage:
        $clean = skScrub [-t TEXT]

    ||longhelp||
    Returns your text with sensitive authentication values replaced by
    "<MACROSS REDACTED>". The labels (e.g. "-Password", "Authorization: Bearer",
    "api_key=") are kept so you can still see what was there. This is the same
    scrubber MACROSS uses to sanitize the powershell history when it exits; you
    can use it before writing outputs or logs from your diamonds.

    Detection is intentionally aggressive (it prefers redacting a harmless value
    over missing a real secret). It covers:
        -key=value / key: value pairs, variable assignments, JSON & hashtables,
            and connection strings using password/secret/token/key-type names
        -command parameters like -Password, --token, -ClientSecret, /pass:,
            and tool-specific forms (net user/use, cmdkey, schtasks, psexec,
            sshpass, mysql -p, openssl -passin, ssh-keygen -N/-P, curl -u,
            aws configure set)
        -Authorization / X-*-Key / X-*-Token headers, Bearer & Basic tokens
        -credentials embedded in URLs (scheme://user:pass@host) and secret
            query-string parameters (token=, sig=, key=, code= ...)
        -ConvertTo-SecureString plaintext and NetworkCredential/PSCredential
            constructor passwords
        -PEM private key blocks
        -well-known token formats: JWTs, AWS access key IDs, GitHub, GitLab,
            Slack, Google, Stripe, OpenAI/Anthropic-style sk- keys, npm, PyPI,
            SendGrid, Twilio, and Slack/Teams/Discord webhook URLs

    Values that are references rather than literal secrets ($variables,
    (subexpressions), Read-Host, Get-Credential...) are left alone. Running it
    more than once on the same text gives the same result.

    ||examples||
    Scrub a command before logging it:

        errLog INFO 'MyScript' "$(skScrub $command_line)"

    Scrub an output file:

        $raw = Get-Content -Raw $report
        skScrub $raw | Set-Content $report

    #>
    param(
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        [string]$text
    )
    if($text -eq ''){ Return $text }

    $R = '<MACROSS REDACTED>'

    ## A secret value: quoted (including JSON-escaped quotes) or a bare token
    $val = '(?:\\"(?:[^"\\]|\\[^"])*\\"|"[^"\r\n]*"|''[^''\r\n]*''|[^\s''"`,;&|)}\]]+)'

    ## Don't redact references that aren't literal secrets ($vars, subexpressions,
    ## arrays/hashtables, prompts, or values that were already redacted)
    $notref = '(?!\$|\(|\[|@[\(\{]|<MACROSS REDACTED|\*(?:\s|$)|(?:Get|Read|ConvertTo|ConvertFrom|New|Import|Invoke)-[A-Za-z]+\b)'

    ## Names that indicate the value is a secret
    $kw = '(?:passw(?:or)?d|passwd|pwd|passphrase|pass(?:code|key)|secret|token|bearer|' +
        'api[_-]?key|apikey|(?:access|account|storage|subscription|master|shared|signing|encryption|' +
        'license|primary|secondary|private|secret|auth|client|host|function|app|service|session)[_-]?key|' +
        'client[_-]?secret|credential|creds?\b|connection[_-]?string|conn[_-]?str|' +
        'shared[_-]?access[_-]?(?:key|signature)|cookie|session[_-]?id|sas[_-]?token|' +
        'auth[_-]?(?:token|code|header)|(?<![a-z])otp(?![a-z])|mfa[_-]?code|pin[_-]?code)'

    $rules = @(
        ## PEM private key blocks (multi-line)
        @('(?is)-----BEGIN[ A-Z0-9]*PRIVATE KEY(?: BLOCK)?-----.*?(?:-----END[ A-Z0-9]*PRIVATE KEY(?: BLOCK)?-----|\z)',
            '<MACROSS REDACTED PRIVATE KEY>'),

        ## Credentials embedded in URLs: scheme://user:password@host
        @('(?i)(\b[a-z][a-z0-9+.-]*://[^/\s:@''"]+:)[^/\s@''"]+(?=@)', "`$1$R"),

        ## Authorization headers: Authorization: Bearer xyz / Basic xyz / ApiKey xyz ...
        @('(?i)(\b(?:Proxy-)?Authorization["'']?\s*[:=]\s*["'']?(?:(?:Bearer|Basic|Digest|Negotiate|NTLM|Token|ApiKey|SSWS|Key|SharedAccessSignature)\s+)?)[^\s"'';,}]+',
            "`$1$R"),
        @('(?i)(\b(?:Bearer|Basic)\s+)[A-Za-z0-9\-._~+/]{8,}=*', "`$1$R"),

        ## API-style headers: X-API-Key, X-Auth-Token, Ocp-Apim-Subscription-Key, etc.
        @('(?i)(\b(?:X-[\w-]*|Ocp-Apim-[\w-]*|[\w-]*-)(?:key|token|secret|auth|signature|session)[\w-]*["'']?\s*[:=]\s*["'']?)[^\s"'';,}]+',
            "`$1$R"),

        ## Command parameters: -Password x, --token=x, -ClientSecret 'x', -AccountPassword x ...
        @("(?i)((?:^|[\s(])--?[\w-]*$kw[\w-]*(?:\s*[=:]\s*|\s+))$notref$val", "`$1$R"),

        ## Windows-style switches: /pass:x  /password:x  /pwd:x  /p:x
        @("(?i)((?:^|\s)/(?:pass|password|passwd|pwd|p|rp)\s*:\s*)$notref$val", "`$1$R"),

        ## key=value, key: value, $var = value, JSON "key":"value", hashtable key='value',
        ## connection strings (Password=...;AccountKey=...;)
        @("(?i)((?:\$|\b)[\w.-]*$kw[\w.-]*(?:\\?[""''])?\s*(?:=|:(?!:))\s*)$notref$val", "`$1$R"),
        @('(?i)(\bSharedAccessSignature\s*=\s*)[^;''"\s]+', "`$1$R"),

        ## Secret query-string parameters
        @('(?i)([?&;](?:access_token|refresh_token|id_token|token|api[_-]?key|apikey|key|secret|client_secret|password|passwd|pwd|sig|signature|code|auth|session|sessionid|sas)=)[^&\s''"#]+',
            "`$1$R"),

        ## Tool-specific positional passwords
        @("(?i)(\bnet1?(?:\.exe)?\s+user\s+(?:""[^""]+""|\S+)\s+)(?![/*])$notref$val", "`$1$R"),
        @("(?i)(\bnet1?(?:\.exe)?\s+use\b[^\r\n]*?\\\\\S+\s+)(?![/*])$notref$val", "`$1$R"),
        @("(?i)(\bschtasks(?:\.exe)?\b[^\r\n]*?\s/r?p\s+)(?![/*])$notref$val", "`$1$R"),
        @("(?i)(\b(?:ps|pa)exec(?:64)?(?:\.exe)?\b[^\r\n]*?\s-p\s+)$notref$val", "`$1$R"),
        @('(?i)(\bsshpass\b[^\r\n]*?\s-p\s*)\S+', "`$1$R"),
        @('(?i)(\bmysql\w*(?:\.exe)?\b[^\r\n]*?\s-p)(?=[^\s-])\S+', "`$1$R"),
        @("(?i)(\bssh-keygen(?:\.exe)?\b[^\r\n]*?\s-[NP]\s+)$val", "`$1$R"),
        @('(?i)(-pass(?:in|out)?\s+(?:pass|env):)\S+', "`$1$R"),
        @('(?i)((?:^|\s)(?:-u|--user|--proxy-user|-U|--http-user)\s+["'']?[^:\s"'']+:)[^\s"'']+', "`$1$R"),
        @('(?i)(\baws\s+configure\s+set\s+\S*(?:key|secret|token)\S*\s+)\S+', "`$1$R"),

        ## Second (password) argument of NetworkCredential / PSCredential constructors
        @("(?i)(NetworkCredential[^\r\n(]*\(\s*(?:""[^""]*""|'[^']*'|[^,()]*?)\s*,\s*)$notref$val", "`$1$R"),
        @("(?i)(NetworkCredential\b[^\r\n|;]*?-ArgumentList\s+(?:""[^""]*""|'[^']*'|[^,\s]+)\s*,\s*)$notref$val", "`$1$R"),

        ## Well-known token formats, wherever they appear
        @('\beyJ[A-Za-z0-9_-]{5,}\.eyJ[A-Za-z0-9_-]{5,}\.[A-Za-z0-9_-]{5,}', $R),            ## JWT
        @('\b(?:AKIA|ASIA|AGPA|AIDA|AROA|ANPA|ANVA|AIPA)[A-Z0-9]{16}\b', $R),             ## AWS key IDs
        @('\b(?:gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{22,})', $R),            ## GitHub
        @('\bglpat-[A-Za-z0-9_-]{20,}', $R),                                               ## GitLab
        @('\bxox[abposr]-[A-Za-z0-9-]{10,}', $R),                                          ## Slack tokens
        @('\bAIza[0-9A-Za-z_-]{35}', $R),                                                  ## Google API
        @('\bya29\.[0-9A-Za-z_-]{20,}', $R),                                               ## Google OAuth
        @('\b(?:sk|rk|pk)_(?:live|test)_[0-9A-Za-z]{16,}', $R),                            ## Stripe
        @('\bsk-(?:ant-|proj-)?[A-Za-z0-9_-]{20,}', $R),                                   ## OpenAI/Anthropic-style
        @('\bnpm_[A-Za-z0-9]{36}\b', $R),                                                  ## npm
        @('\bpypi-[A-Za-z0-9_-]{50,}', $R),                                                ## PyPI
        @('\bSG\.[\w-]{22}\.[\w-]{43}\b', $R),                                             ## SendGrid
        @('\bSK[0-9a-fA-F]{32}\b', $R),                                                    ## Twilio
        @('(?i)(https://(?:hooks\.slack\.com/(?:services|workflows)|[\w.-]*\.webhook\.office\.com|discord(?:app)?\.com/api/webhooks)/)\S+',
            "`$1$R")                                                                        ## Webhook URLs
    )

    $out = $text
    foreach($rule in $rules){
        $out = $out -replace $rule[0],$rule[1]
        ## A later rule can re-match an earlier "<MACROSS REDACTED>"; collapse the leftovers
        $out = $out -replace '<MACROSS REDACTED>(?:\s*REDACTED>)+','<MACROSS REDACTED>'
    }

    ## Plaintext handed to ConvertTo-SecureString (quoted literals, or a bare first argument)
    $out = [regex]::Replace($out,'(?i)\bConvertTo-SecureString\b[^|;\r\n]*',
        [System.Text.RegularExpressions.MatchEvaluator]{
            param($m)
            $seg = $m.Value -replace '"[^"]*"|''[^'']*''',"'$R'"
            $seg -replace '(?i)(ConvertTo-SecureString\s+(?:-String\s+)?)(?![-$(@''<])\S+',"`$1$R"
        })

    Return $out
}


## Redact authentication strings from the powershell history (and optionally from
## powershell transcripts). Runs automatically when MACROSS exits and after the
## "shell" option closes. Use -t to also scrub the transcripts in a folder (this
## includes subfolders, i.e. the GPO transcription layout <dir>\yyyyMMdd\*.txt).
## Note that PSReadLine also keeps the current console's history in memory until
## that powershell window is closed.
function skSanitize([switch]$c=$false,[string]$t=$null){
    $redacted = mkList
    $failed = mkList

    function scrubFile_($file){
        try{
            $raw = [IO.File]::ReadAllText($file)
            $clean = skScrub $raw
            if($clean -cne $raw){
                [IO.File]::WriteAllText($file,$clean,[Text.UTF8Encoding]::new($false))
                [void]$redacted.Add($file)
            }
        }
        catch{ [void]$failed.Add("$file ($($_.Exception.Message))") }
    }

    ## PSReadLine keeps a separate history file per host (ConsoleHost, VS Code, ISE...);
    ## scrub each file on its own so their contents never get mixed together
    $hfiles = mkList
    try{
        $hp = (Get-PSReadLineOption -ErrorAction Stop).HistorySavePath
        if($hp -and (Test-Path -PathType Leaf $hp)){ [void]$hfiles.Add($hp) }
    }
    catch{ $null }
    if($env:APPDATA){
        $psr = Join-Path $env:APPDATA 'Microsoft\Windows\PowerShell\PSReadLine'
        if(Test-Path $psr){
            Get-ChildItem -File -Path $psr -Filter '*history*.txt' -ErrorAction SilentlyContinue |
                %{ if($_.FullName -notIn $hfiles){ [void]$hfiles.Add($_.FullName) } }
        }
    }
    foreach($hf in $hfiles){ scrubFile_ $hf }

    ## Optional: powershell transcripts
    if($t -and (Test-Path $t)){
        Get-ChildItem -File -Recurse -Path $t -Filter '*transcript*.txt' -ErrorAction SilentlyContinue |
            %{ scrubFile_ $_.FullName }
    }

    if($redacted.count -gt 0){
        errLog INFO 'MACROSS.skSanitize' "Redacted authentication strings in $($redacted.count) file(s): $($redacted -join ', ')"
    }
    elseif($c){ errLog INFO 'MACROSS.skSanitize' 'Clean exit; nothing to sanitize.' }
    foreach($f in $failed){
        errLog WARN 'MACROSS.skSanitize' "Could not scrub $f; possible permission lock."
    }
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
            if($sp){ launcher $diamond -n -p $lang[-1] -alt $sp -v $vtype }
            else{ launcher $diamond -n -p $lang[-1] -v $vtype }
        }
        elseif($sp){ launcher $diamond -p $lang[-1] -alt $sp -v $vtype -x $sorted }
        else{ launcher $diamond -p $lang[-1] -v $vtype -x $sorted }
    }


    $Global:CALLER = $c

    if($n){ $Global:dyrl_NEWW = $true }

    $vtype = $dyrl_LATTS.$c.valtype
    $diamond = $dyrl_LATTS.$m.fname -replace "\\\\",'\'
    $valid = setUser "$($dyrl_LATTS.$m.access)"
    $lang = $dyrl_LATTS.$m.lang

    if( $valid -and (Test-Path -Path $diamond) ){
        startUp
        if($lang -Like 'python*'){
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
                if($sp -and $sp -ne $PROTOCULTURE){ launcher -n $diamond -alt $sp -v $vtype }
                else{ launcher -n $diamond -v $vtype }
            }
            else{
                if($sp -and $sp -ne $PROTOCULTURE){ launcher $diamond -alt $sp -v $vtype }
                else{ launcher $diamond -v $vtype }
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


## Marker used to unwind nested diamond calls (valkyrie) back to the main menu after a
## failure has already been shown to the user.
$Global:dyrl_HALT = 'MACROSS_DIAMOND_HALTED'

function diamondFault(){   #mp
    <#
    ||shorthelp||
    Show the error that stopped a diamond, log it, and wait for ENTER.
    Usage:
        diamondFault [-r ERROR_RECORD] [-s SOURCE_NAME] [-d DETAIL_TEXT] [-l <LAST KNOWN>]

    ||longhelp||
    MACROSS calls this automatically when a diamond stops because of an error, so you
    normally don't need to. It displays the error that caused the stoppage (message,
    script, line and the offending code). If no error record is available, it shows the
    last error on record instead and labels it as such. The error is written to the
    MACROSS log, and the user hits ENTER to go back to the main menu.

    -r  an ErrorRecord/exception (e.g. $_ inside a catch block)
    -s  the name of the diamond or function that failed
    -d  extra detail, e.g. "exited with code 2" or a python traceback
    -l  label -r as "the last error on record" instead of the cause

    If your diamond catches its own errors but still needs to stop, you can throw
    from your catch block; MACROSS will show the error and return to the menu
    without ending the session.

    ||examples||
    Inside your diamond:

        try{ Invoke-RestMethod $uri -ErrorAction Stop }
        catch{ diamondFault $_ -s 'MYSCRIPT'; Return }

    #>
    param(
        $r=$null,
        [string]$s='MACROSS',
        [string]$d=$null,
        [switch]$l
    )
    if(-not $r -and -not $d){ $r = $Error[0]; $l = $true }

    $msg = $null; $where = $null
    if($r -is [System.Management.Automation.ErrorRecord]){
        $msg = $r.Exception.Message
        if($r.InvocationInfo -and $r.InvocationInfo.ScriptName){
            $where = "$($r.InvocationInfo.ScriptName) (line $($r.InvocationInfo.ScriptLineNumber))"
            $code = "$($r.InvocationInfo.Line)".Trim()
        }
    }
    elseif($r -is [System.Exception]){ $msg = $r.Message }
    elseif($r){ $msg = "$r" }

    Write-Host ''
    w "  $s STOPPED  " -b r -f k
    if($d){ w "`n $d" y }
    if($msg){
        if($l){ w "`n Last error on record:" c }
        else{ w "`n Error:" c }
        w " $msg" y
        if($where){ w " Location: $where" c }
        if($code){ w " Code:     $code" c }
    }
    elseif(-not $d){ w "`n No error details were recorded." y }

    $logmsg = (@($d,$msg,$where) | ?{$_}) -join ' | '
    try{ errLog ERROR $s "$(skScrub "$logmsg")" }catch{ $null }

    w "`n Hit ENTER to return to the main menu." g -i
    Read-Host | Out-Null
}


## Execute the selected automation tool, with any alt options. If the diamond stops because
## of an error (a terminating error, or a non-zero exit code), the error is shown to the user
## via diamondFault and MACROSS returns to the main menu without ending the session. $alt is
## passed to the diamond as -spiritia, so the diamond must accept that parameter.
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
    $name = [IO.Path]::GetFileNameWithoutExtension($command)
    $pyerr = Join-Path "$dyrl_TMP" 'pyerror.vf1'    ## python's macross library writes uncaught tracebacks here

    ## Regardless of 'python0' or 'python1' as the diamond's .lang value, if only one
    ## python version is available, we'll attempt to execute it.
    function whichPy_($option){
        $pyargs = @($command)
        if($null -ne $alt -and "$alt" -ne ''){ $pyargs += "$alt" }
        if(Test-Path $pyerr){ Remove-Item -Force $pyerr -ErrorAction SilentlyContinue }
        pyATTS; macrossMirror -n $N_
        try{
            $usealt = $MONTY -and ($option -eq '0' -or -not $LIFEOFBRIAN)
            if($usealt){ & $dyrl_PYCROSS @pyargs }
            elseif($LIFEOFBRIAN){ py @pyargs }
            else{ throw "No python interpreter is available to run $command" }
        }
        finally{ macrossMirror -c }
    }

    if($PSVersionTable.PSVersion.Major -lt 7){ $exe = 'powershell.exe' }
    else{ $exe = 'pwsh.exe' }

    $Global:dyrl_LDEPTH = [int]$dyrl_LDEPTH + 1
    $Global:LASTEXITCODE = 0
    $before = $Error[0]                 ## to tell new errors apart from older ones
    $fault = $null; $detail = $null; $lastknown = $false; $halted = $false

    try{
        if($py -ne '2'){ whichPy_ "$py" }
        elseif($new){
            $al = @('-NoExit','-File',"`"$command`"")
            if($null -ne $alt){ $al += @('-spiritia',"`"$alt`"") }
            Start-Process $exe -ArgumentList $al -ErrorAction Stop
        }
        elseif($null -ne $alt){ . $command -spiritia $alt }
        else{ . $command }

        ## No exception, but the diamond (or python) reported failure through its exit code
        if($LASTEXITCODE -and $LASTEXITCODE -ne 0){
            $detail = "$name exited with code $LASTEXITCODE."
            if($py -ne '2' -and (Test-Path $pyerr)){
                $detail = "$detail`n`n$((Get-Content -Raw $pyerr).TrimEnd())"
            }
            elseif($Error[0]){
                $fault = $Error[0]; $lastknown = $true
                if([object]::ReferenceEquals($Error[0],$before)){
                    $detail = "$detail (No new error was recorded while it ran.)"
                }
            }
        }
    }
    catch{
        if("$($_.Exception.Message)" -eq $dyrl_HALT){ $halted = $true }   ## already shown by a nested call
        else{ $fault = $_ }
    }
    finally{
        $Global:dyrl_LDEPTH = [math]::Max(0,[int]$dyrl_LDEPTH - 1)
        $Global:LASTEXITCODE = 0
    }

    if($fault -or $detail){
        diamondFault -r $fault -s $name -d $detail -l:$lastknown
        $halted = $true
    }

    ## If this diamond was called by another diamond, stop that one too so the user
    ## lands back at the main menu instead of in a half-finished caller
    if($halted -and $dyrl_LDEPTH -gt 0){ throw $dyrl_HALT }
}

################################
## Verify a diamond's location, permissions, and options, get it ready for launch; $r will force
## an update/download of the latest version of the selected diamond if a repo is configured
################################
function flightDeck($dmd,[switch]$r){

    if($dmd -in $dyrl_LATTS.keys){

        $DIAMOND = $dyrl_LATTS.$dmd.fname

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
    }
    ## Diamond failures are reported by the launcher (see diamondFault)
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
        ## ($dyrl_PG is set at startup in MACROSS.ps1)
        if(-not $env:PYTHONPATH){
            $env:PYTHONPATH = $dyrl_PYLIB
        }
        elseif($env:PYTHONPATH -notLike "*$dyrl_PYLIB*"){
            $env:PYTHONPATH += ";$dyrl_PYLIB"
        }
    }
}
