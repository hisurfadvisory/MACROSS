## MACROSS shared utilities

## These values can only be set after all initializations have finished
function finalSet(){   
    getThis $vf19_MPOD.enr
    battroid -n vf19_RSRC -v $vf19_READ
    getThis $vf19_MPOD.log
    battroid -n vf19_LOG -v $vf19_READ
    getThis $vf19_MPOD.rep
    battroid -n vf19_REPOCORE -v $vf19_READ
    if($vf19_REPOCORE -ne 'n'){
        ## If you want to control tier-level access, change the $vf19_REPOCORE location and store  
        ## master copies of your tools there. That way, MACROSS will be able to auto-download tier- 
        ## appropriate tools to each analyst. You can use the configuration wizard to store the
        ## location of your master copies, and modify the vf19_REPOTOOLS line below using the same 
        ## method seen above:

        ##     getThis $vf19_MPOD[your_key]; battroid -n vf19_REPOTOOLS -v $vf19_READ

        ## Enable or disabled live updating
        function fs_([switch]$e=$false,$d='\'){
            if($e){
                errLog ERROR "$USR/MACROSS(finalSet)" "Main repository $vf19_REPOCORE was unreachable; updates disabled"
            }
            else{
                battroid -n vf19_REPOTOOLS -v ("$vf19_REPOCORE$d"+'modules')
                $Global:vf19_VERSIONING = $true
            }
        }

        if( $vf19_REPOCORE -Like "http*" ){
            if(! $vf19_ATTS){
                try{ 
                    $g = [net.Webrequest]::Create($vf19_REPOCORE).getResponse()
                    if($g.statusCode -eq 200){ fs_ '/' }else{ fs_ -e }
                    $g.close()
                }
                catch{ fs_ -e }
            }
        }
        else{
            if(Test-Path $vf19_REPOCORE){ fs_ }
            else{ fs_ -e }
        }
    }
}

<###############################################################
    Unlisted MACROSS menu option --
    Change the message output for errors so you can troubleshoot scripts, and
    view helpfiles for all the core MACROSS functions.
   
    Type 'debug' in the MACROSS menu to launch this debugger. From here,
    you can access all MACROSS resources and run test commands to develop
    your MACROSS scripts.

    Use the MACROSS config wizard to add terms or patterns to the blacklist
    regex key (bl0). All users have access to the debug menu, but any commands 
    they run that match the blacklist will require the MACROSS admin password.

################################################################>
function debugMacross($1,[switch]$continue=$true){
    if($continue){
        splashPage
        ''
        w '                        MACROSS DEBUG MODE
        ' y
    }
    macrossHelp show
    ''
    #getThis -h $(setCC -b); getThis $vf19_READ; $rst = [regex]$vf19_READ
    $rst = $(setCC -b); getThis IFRoYXQgaXMgYSBwcml2aWxlZ2VkIGNvbW1hbmQu; $bm = $vf19_READ
    
    if($1){
        if($1 -Match $rst -and ! $ad){w "$bm`n`n" 'r' 'bl'; $ad = setConfig -a}
        if(($ad -eq $vf19_GPOD.Item1) -or ($1 -notMatch $rst)){
            startUp;if($1 -eq 'help'){macrossHelp dev;macrossHelp show}
            elseif($1 -Like "help *"){macrossHelp $($1 -replace "help ");macrossHelp show}
            else{$1=$1 -replace "^debug ";$cmd = [scriptblock]::Create("$1");. $cmd};varCleanup
        }
    
            w "
 Type another command for testing, `"d`" to load the debugging menu, or hit ENTER to close:
    " g
            $response = Read-Host
            if($response -eq 'd'){ rv 1,response; debugMacross -c }
            elseif($response -ne ''){ debugMacross $response -c }
    }
    else{
        $e = @('SilentlyContinue','Continue','Inquire')
        $c = $ErrorActionPreference
        
        w "
            Current error display:  $c" c
        w '

            Which error level do you want to set (1-3)?
                1. Suppress all error messages
                2. Display errors without stopping scripts
                3. Pause after each error message with a choice to continue
                4. Cancel
            
            OR Type "logs" to review MACROSS log files,' g
            if($MONTY[1]){ w '
            OR Type "python" to open a MACROSS python session for testing,' g}
            w '
            OR Enter any command to begin testing/debugging within powershell

            >  ' g -i
        $z = Read-Host
        
        if($z -ne 'logs'){
            if($z -eq 4){
                Return
            }
            elseif($z -eq 'python'){
                startUp; $pyATTS = pyATTS; pyENV; cls
                py "$vf19_TOOLSROOT\core\pydev.py" #$vf19_pylib
                varCleanup
            }
            elseif($z -notIn 1..3){
                cls
                debugMacross $z
            }
            else{
                $Script:ErrorActionPreference = $e[$([int]$z - 1)]
                splashPage
                $c = $ErrorActionPreference
                w "
                Error display is now set to:  $c" c
                slp 2
            }
        }
        else{
            $la = New-Object System.Collections.ArrayList
            $lc = $((Get-ChildItem $vf19_LOG).count)
            (Get-ChildItem $vf19_LOG).Name | Sort -Descending | %{
                $la.Add($_)
            }
            splashPage
            ''
            while( $z -ne 'q' ){
                $ln = 1; $row = 0
                Foreach($lf in $la){
                    $row++
                    if($ln -ge 100){$index = "$ln`. "}
                    elseif($ln -lt 100 -and $ln -ge 10){$index = " $ln`. "}
                    elseif($ln -lt 10){$index = "  $ln`. "}
                    w $index y -i
                    if($row -eq 1){$row++; $ln++; w "$lf" -u -i}
                    elseif($row -eq 2){$row = 0; $ln++; w "$lf" -u}
                }
                ''
                screenResults "y~    ($lc logs)             SELECT A FILE # ABOVE (`"q`" to quit):"
                screenResults -e
                w ' Log file >  ' g -i
                $z = Read-Host

                if($la[$z-1]){
                    $logmsgs = New-Object System.Collections.ArrayList
                    foreach($msg in (Get-Content "$vf19_LOG\$($la[$z-1])")){
                        getThis $msg
                        $logmsgs.Add($vf19_READ) > $null
                    }

                    Add-Type -AssemblyName System.Windows.Forms
                    [System.Windows.Forms.Application]::EnableVisualStyles()
                    $viewer = New-Object System.Windows.Forms.Form
                    $viewer.Size = New-Object System.Drawing.Size(1100,650)
                    $viewer.StartPosition = "CenterScreen"
                    $viewer.Font = [System.Drawing.Font]::New("Tahoma",10.5)
                    $viewer.Text = "MACROSS log viewer"
                    $viewer.ForeColor = 'YELLOW'
                    $viewer.BackColor = 'BLACK'

                    $thislog = New-Object System.Windows.Forms.Label
                    $thislog.Location = New-Object System.Drawing.Point(10,8)
                    $thislog.Size = New-Object System.Drawing.Size(700,20)
                    $thislog.Font = [System.Drawing.Font]::New("Tahoma",10)
                    $thislog.Text = "Viewing log $lf"
                    $viewer.Controls.Add($thislog)

                    $msgpane = New-Object System.Windows.Forms.TextBox
                    $us=chr 175;$ul="$us";1..63 | %{$ul="$ul"+"$us"}
                    $msgpane.MultiLine = $true
                    $msgpane.Scrollbars = 'Vertical'
                    $msgpane.Font = [System.Drawing.Font]::New("Consolas", 10)
                    $msgpane.ForeColor = 'WHITE'
                    $msgpane.BackColor = 'GRAY'
                    $msgpane.Text = "LOCAL TIME`t`tLEVEL`tLOG SOURCE`t`tMESSAGE(S)"+[System.Environment]::NewLine
                    $msgpane.AppendText($ul+[System.Environment]::NewLine)
                    $msgpane.Location = New-Object System.Drawing.Point(10,30)
                    $msgpane.Size = New-Object System.Drawing.Size(1050,510)
                    $viewer.Controls.Add($msgpane)

                    $logmsgs | %{ ($msgpane.AppendText("$_"+[System.Environment]::NewLine)) }

                    $fin = New-Object System.Windows.Forms.Button
                    $fin.Location = New-Object System.Drawing.Point(490,555)
                    $fin.Size = New-Object System.Drawing.Size(150,30)
                    $fin.Text = "EXIT"
                    $fin.Enabled = $true
                    $fin.DialogResult = [System.Windows.Forms.DialogResult]::OK
                    $viewer.Controls.Add($fin)
                    $viewer.AcceptButton = $fin

                    $fin.Add_Click({
                        $thislog = $null
                        $logmsgs = $null
                    })

                    $viewer.TopMost = $true
                    $logswindow = $viewer.ShowDialog()
                    
                    
                    ''
                    w '  Hit ENTER to continue.
                    ' g
                    Read-Host
                }
            }
        }
    }
}


function runSomething(){
    cls
    Write-Host '
    '
    Write-Host -f GREEN '  Pausing MACROSS: type ' -NoNewline;
        Write-Host -f YELLOW 'exit' -NoNewline;
            Write-Host -f GREEN ' to close your session and return to'
    Write-Host -f GREEN '  the tools menu.

    '

    powershell.exe  ## Start new session outside of MACROSS

    Return
}

## Make sure the GBIO folder is cleaned out:
## this is where .eod files are written so python can 
## read powershell outputs
function cleanGBIO(){
    ## Make sure the GBIO directory is clean
    if(Get-ChildItem "$($vf19_PYG[0])\*.eod"){
        Get-ChildItem "$($vf19_PYG[0])\*.eod" | %{
            try{
                Remove-Item -Force $_
            }
            catch{
                $exc = $_ + '!'
                Write-Host -CYAN " Could not delete $exc"
            }
        }
    }
}


## Admin/dev function: type 'defs' into MACROSS' main menu.
## It will accept super-long strings and wrap them into a block of 100 char lines for you to then
## copy-pasta into whatever project you're working on. This is purely a cosmetic preference; 
## sometimes I don't want lines of code (like base64) that stretch longer than my screen.
function formatDefaults(){
    Write-Host -f GREEN '  Paste the string to format: ' -NoNewline;
    $z = Read-Host
    Write-Host '
    '
    $z | ForEach-Object {
        $line = $_
        for($i = 0; $i -lt $line.Length; $i += 100){
            $length = [Math]::Min(100, $line.Length - $i)
            $line.SubString($i, $length)
        }
    }
    Read-Host
}

## Decode base64 or hex string one-offs from the main menu
function decodeSomething($1){
    cls
    w "`n`n"
    if($1 -eq 0){
        $resp = "Decoded:"
        $ask = "Decode another?"
        Write-Host -f GREEN "
        Enter 'h' or 'b' followed by your encoded string (hex strings can contain '0x'),
        or 'c' to cancel:
        >  " -NoNewline; $Z = Read-Host
        if($Z -Like "h*"){
            $Z = $Z -replace "^h ?",''
            getThis $Z -h; $Z = $vf19_READ
        }
        elseif($Z -Like "b*"){
            $Z = $Z -replace "^b ?",''
            getThis $Z; $Z = $vf19_READ
        }
        elseif($Z -eq 'c'){
            Remove-Variable Z
        }
        else{
            Remove-Variable Z
            w '
            You need to specify "b" or "h".' c
            decodeSomething
        }
    }
    elseif($1 -eq 1){
        $resp = "Encoded:"
        $ask = "Encode another?"
        while($Z -notMatch "^[hcb]"){
            w '
        Enter "h" or "b" and the string to encode, or "c" to cancel:
        >  ' -i g; $Z = Read-Host 
        }
        if($Z -eq "c"){  Return }
        elseif($Z -Like "h*"){ $Z = "$resp $(getThis $($Z -replace "^h ?") -h -e)" }
        else{ $Z = "$resp $(getThis $($Z -replace "^b ?") -e)" }
    }

    if($Z){
        w "
        $resp " -i g; w " $Z`n"
        w "    $ask " -i g;
        $Z = Read-Host
        if($Z -Match "^y"){
            Remove-Variable Z
            decodeSomething $1
        }
    }
        
}

<## These vars & functions need to get loaded when python calls powershell scripts without MACROSS values
if( ! $vf19_TOOLSROOT ){
    $vf19_TOOLSROOT = '..'
    $Global:vf19_TOOLSDIR = "$vf19_TOOLSROOT\modules\"
    . "$vf19_TOOLSROOT\core\display.ps1"
    . "$vf19_TOOLSROOT\core\validation.ps1"
}#>



function getThis(){
    <#
    ||longhelp||

    getThis [-v value] [-e encode] [-h hexadecimal]

    Decode encoded values to $vf19_READ, or encode your plaintext value.
    
    -DO NOT USE ENCODING TO HIDE USERNAMES/PASSWORDS/KEYS or other sensitive info!
    

    ||examples||
    $vf19_READ gets overwritten every time this function is called. If you require the plaintext 
    as a persistent value, You *must* set $vf19_READ to a new variable:

        getThis $base64string
        $plaintext = $vf19_READ

    To decode a hexadecimal string, call this function with -h (and your hex string can include 
    spaces and/or "0x" tags, or neither):

        getThis "0x746869732069 730x20 61 200x740x650x7374" -h
        $plaintext = $vf19_READ

    If you want to *encode* plaintext, use the -e option. Use -h if you want hexadecimal output. 
    This mode does NOT write to $vf19_READ!
        
        $b64 = getThis $plaintext -e
        $hex = getThis $plaintext -e -h
     
    #>
    param(
        $v,
        [switch]$h=$false,
        [switch]$e=$false
    )

    ## Start fresh
    $Global:vf19_READ = $null

    if($e){
        if($h){$a = ([System.Text.Encoding]::UTF8.GetBytes($v) | foreach{$_.ToString("X2")}) -join ''}
        else{$a = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($v))}
        Return $a
    }
    elseif( $h ){
        $a = $v -replace "0x"; $a = $a -replace " "
        $a = $(-join ($a -Split '(..)' | %{[char][convert]::ToUInt32($_,16)}))
    }
    else{
        $a = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($v))
    }
    
    $Global:vf19_READ = $a
    
}




## I can never remember how to convert unicode in powershell, just rename it to match python
function ord($1){
    <#
    ||longhelp|| 
    Convert a single string char to its decimal format.
    
    ||examples||
    Get the decimal representation of 'A':
    
        ord 'A'
        
    #>
    if($1.getType().Name -eq 'String'){
        Return [char]"$1" -as [int]
    }
}
function chr($1){
    <#
    ||longhelp|| 
    Convert a decimal value into its string format
    
    ||examples||
    Convert decimal 65 into the string char 'A':
    
        chr 65
        
    #>
    if($1.getType().Name -eq 'Int32'){
        Return [char]$1
    }
}



function errLog(){
    <#
    ||longhelp||

    errLog [message] [optional message field 1] [optional message field 2] [forwarding]

    This function only acts if you've set a logging location in the MACROSS config.

    Have your scripts write to MACROSS logs for troubleshooting/auditing. The default location
    is $vf19_LOG, wherever you've specified that location to be. The current timestamp automatically
    gets written to the log, you don't need to send it. Just send at least 2 params, like a log-level
    (ERROR, INFO, etc.) and the log message. You can also send a 3rd parameter if necessary.
    
    These logs can be viewed from MACROSS' debug screen.
    
    ||examples||

    Write local logs with 2 or 3 fields:
        errLog WARN "$SCRIPT failed to perform $TASK"
        errLog INFO $USR 'Accessed API for blah.'

    Write a local log *and* forward it to a log collector:
        errLog -f INFO $USR 'Your log message'

    #>
    Param(
        [Parameter(Mandatory=$true)]$level,
        [Parameter(Mandatory=$false)]$message,
        [Parameter(Mandatory=$false)]$msgplus,
        [switch]$forward=$false
    )
    
    
    ## By default, the logs directory is set to your local MACROSS/resources/logs
    ## folder. You should change this to an alternate location if you don't want
    ## all users to see these logs. (It is stored in $vf19_MPOD['log'], which gets
    ## set by you in the configuration wizard.)
    if(Test-Path -Path "$vf19_LOG"){
        $t = "$(Get-Date -Format 'yyyy-MM-dd hh:mm:ss:ms')"
        $u = "$((Get-Date).toUniversalTime() | Get-Date -Format 'yyyy-MM-dd hh:mm:ss:ms')"
        [string]$log = "$(Get-Date -Format 'yyyy-MM-dd')" + '.log'  ## Create the log filename
        $msg = "MACROSS ($env:COMPUTERNAME)"
        $d = "`t"                                                   ## Delimiter

        if($msgplus){ $msg = "$msg$d$level$d$message$d$msgplus" }
        elseif($message){ $msg = "$msg$d$level$d$message" }
        else{ $msg = "$msg$d$level" }
        $(getThis -e "$t$d$msg") | Out-File "$vf19_LOG\$log" -Append
        if($forward){
            getThis $vf19_MPOD.elc; $addr = ($vf19_READ -Split ':')[0]; $port = ($vf19_READ -Split ':')[1]
            ## MOD SECTION ##
            # If you have dig, use that to do hostname lookups below; otherwise you may need to adjust the
            # "Select -Index" number depending on your nameserver's responses. The alternative *easy* way
            # is to just specify an IP address when using the configuration wizard (but IPs can change,
            # which is why I wrote this to accept hostnames or IPs).
            if($addr -Match "[a-z]"){$addr = $((nslookup $addr | Select -Index 4) -replace "Address\W+")}
            if($addr){
                $syslog_server = [System.Net.IPAddress]::Parse($addr) 
                $local = New-Object System.Net.IPEndPoint $syslog_server,$port 

                $set1 = [System.Net.Sockets.AddressFamily]::InterNetwork 
                $set2 = [System.Net.Sockets.SocketType]::Dgram 
                $proto = [System.Net.Sockets.ProtocolType]::UDP 
                $socket = New-Object System.Net.Sockets.Socket $set1, $set2, $proto 
                $socket.TTL = 26 
                $socket.Connect($local) 

                $encoding = [System.Text.Encoding]::UTF8
                ## Forwarded logs will be timestamped in UTC
                $tosend = $encoding.GetBytes("$u$d$msg")
                $fwd = $socket.Send($tosend)
                $socket.close()
            }
        }
    }

}

## When python needs to call powershell scripts. This is kind of a circle-jerk but
## I'll write a better solution at some point.
function restoreMacross(){
    $Global:ErrorActionPreference = 'SilentlyContinue'
    $v = $env:MACROSS -Split ';'
    $Global:vf19_TOOLSROOT = "$((pwd).path)"; $Global:vf19_TOOLSDIR = "$vf19_TOOLSROOT\modules"
    $Global:USR = $v[6]; $Global:vf19_DTOP = $v[2]; $Global:vf19_RSRC = $v[3]; $Global:vf19_LOGS = $v[4]
    $Global:N_ = $v[5]
    $Global:vf19_PYG = @("core\macross_py\garbage_io","core\macross_py\garbage_io\PROTOCULTURE.eod")
    $Global:PROTOCULTURE = (gc "$($vf19_PYG[1])" | ConvertFrom-Json).$CALLER.target; $Global:vf19_MPOD = @{}
    foreach($missile in $($env:MPOD -split ';')){
        $payload = ($missile -split('::'))[0]
        $fuel = ($missile -split('::'))[1]
        $Global:vf19_MPOD.Add($payload,$fuel)
    }
}

## Provide additional functions from the main menu
function extras($1){
    ## Cycle through all the available splash screens. For funsies.
    function easterEgg(){
        0..11 | %{transitionSplash $_ 2}
    }
    ## Clear out the global PROTOCULTURE value before the next investigation
    function clearProto(){
        cls
        w "`n`n`n"
        $pf = "$($vf19_PYG[1])"
        screenResults "PROTOCULTURE = " "$PROTOCULTURE"
        screenResults -e
        ''
        w 'Hit ENTER to clear it.' g
        Read-Host; Remove-Variable -Force PROTOCULTURE -Scope Global
        if(Test-Path $pf){ Remove-Item -Path $pf }
        w " Enter `"p`" to automatically clear `$PROTOCULTURE from now on, or hit ENTER to skip: " -i g
        if($(Read-Host) -eq 'p'){ userPrefs -proto }
    }
    $ex = @{
        'config'='splashPage;setConfig -u'
        'dec'='splashPage;decodeSomething 0'
        'defs'='cls;formatDefaults'
        'enc'='splashPage;decodeSomething 1'
        'proto'='clearProto'
        'strings'='stringz'
        'shell'='runSomething'
        'splash'='easterEgg'
        'refresh'="dlNew 'MACROSS.ps1' $vf19_LVER"
    }

    . $([scriptblock]::Create("$($ex[$1])"))

    $Global:vf19_Z = $null
    Return
}


function pyCross(){
<#
    ||longhelp||
    
    This function lets scripts write results to a file in the directory 
    
        "MACROSS\core\macross_py\garbage_io\"

    so that python & powershell scripts can easily share the same investigation data during a 
    MACROSS session. The files are encoded in utf8.
  
    REQUIRED:  Your script name, as well as the value you want written to that file ($val1). 
    The default file will be PROTOCULTURE.eod, written as a basic json string:
    
        { 'YourScriptName' : { 'target': $value1, 'result': $value2 } }
        
    If you need something other than this format, you can provide an alternative filename as the 
    3rd parameter, and write whatever type of data your file is to that. (the extension will
    still be .eod to handle auto-cleanup.)

    Originally, the PROTOCULTURE.eod file collected search values for all scripts during any
    given MACROSS session, which is why it is in json format. But it made more sense to limit
    this to a single result field, so this file simply gets overwritten with each use of pyCross, 
    and no longer appends json items for every PROTOCULTURE search.
    
    When a python script uses valkyrie.collab() to query your powershell scripts, your script
    should contain this check & instruction:

    param( $pythonsrc = $null )
    if( $pythonsrc ){
        $Global:CALLER = $pythonsrc
        foreach( $core in gci "core\*.ps1" ){ . $core.fullname }
        restoreMacross
    }

    The restoreMacross function will automatically read any PROTOCULTURE.eod files, and generate
    a $PROTOCULTURE value for your powershell script to act on.
    
#>
    Param(
        [Parameter(Mandatory)]
        [string]$caller_,
        [Parameter(Mandatory)]
        $result,
        [string]$filenm
    )

    $PF = "$($vf19_PYG[1])"  ## Read the PROTOCULTURE.eod data

    function w2f($1,$2="$PF"){
        [IO.File]::WriteAllLines("$2",$($1 | ConvertTo-Json -Depth 3))
    }
    <#if($result -isNot [System.String] -and $result -isNot [System.Int32]){
        $result = [PSCustomObject]@{ } + $result
    }#>

    if($filenm){
        $filenm = "$($vf19_PYG[0])\$filenm" + '.eod'  ## Append custom extension
        w2f $result $filenm
        if(-not(Test-Path -Path "$($vf19_PYG[0])\$filenm")){
            $em = "Failed write to $filenm for $caller_"
            errLog ERROR "$USR/MACROSS(pyCross)" $em
            w "ERROR! $em " -f r -b bl
            slp 3
        }
    }
    elseif(Test-Path -Path $PF){
        $p = Get-Content $PF | ConvertFrom-Json
        if($p.$caller_.result -ne 'WAITING'){
            $Global:PROTOCULTURE = $p.$caller_.result
        }
        else{
            $p.$caller_.result = $result
            w2f $p
        }
    }
    else{ 
        errLog ERROR "$USR/MACROSS(pyCross)" "Attempted to write to non-existent PROTOCULTURE.eod file while launching $caller_"
    }
}



function TL($1){
    <#
    ||longhelp||
    Get a full listing of all available tools and their [macross] attributes
    
    ||examples||
    Call from the main menu with debug:
    
        debug TL
    
    Get the details for a specific tool:
        
        TL <tool name>
    
    #>
    if($1){
        Return $($vf19_LATTS.$1.toolInfo())
    }
    else{
        $vf19_LATTS.keys | %{$vf19_LATTS.$_.toolInfo()}
    }
}



function stringz($f=$(getFile),[switch]$save=$false){
    <#
    ||longhelp||
    For those deployments when "strings" isn't a default Windows utility.
    
    Send a filepath, or let the function open a dialog for you. Send -s 
    if you want to keep the outputs.
    
    ||examples||
    Dump strings from an executable to your screen:
    
        stringz <filepath>
        
    Do the same, but write outputs to file on your desktop:
    
        strings <filepath> -s
    
    #>
    if($f -ne ''){
        Get-Content $f | %{
            if( !($_ -cMatch "[^\x00-\x7F]")){
                $n++
                if( $save ){
                    Write-Host "  Extracting line $n to macross-stringz.txt..."
                    "$_" | Out-File "$vf19_DTOP\macross-stringz.txt" -Append
                }
                else{ w " $_" }
            }
        }
    }
    
    if( $save ){
        Get-Content "$vf19_DTOP\macross-stringz.txt"
    }
    w " Hit ENTER to exit." g; Read-Host
}



function getHash(){
<#
    ||longhelp||

    getHash [-f FILE] [-a MD5|SHA256]

    Get the hash of a file. The -f and -a values are both required.
    
    ||examples||
    Usage:  

    $md5 = getHash $filepath -a md5
    $sha = getHash $filepath -a sha256
    
#>
    Param(
        [Parameter(Mandatory)]
        [string]$file,
        [Parameter(Mandatory)]
        [string]$alg
    )

    $type = @('md5','sha256')

    if( Test-Path -Path $file ){
        if($alg -in $type){ Return (CertUtil -hashfile $file $alg)[1] }
    }
}





function sheetz(){
    <#
    ||longhelp||

    sheetz [-f FILENAME] [-v VALUES] [-r ROWNUMBER] [-h COLUMN HEADERS/COLUMN NUMBERS]

    Output tool values to an Excel spreadsheet on user's desktop

    (This is very simplistic at the moment; the goal is to eventually make more useful 
    spreadsheets when simple CSV files aren't good enough.)

    Parameters for this function:
    -f = (req'd) the name of the output file
    -v = (req'd) output values, comma-separated
    -r = (optional) the starting row number to write to (default is 1)
    -h = (optional) column values, OR the number of columns you are writing across

    -f, -v
    If only 2 parameters are sent, this function will separate the values in param -v by 
    removing the commas, and write each value as a list into column A to the -f file.

    -r
    If you're adding values to an existing sheet, the -r parameter lets you specify which 
    row to start in. For example, if you know the next empty row is 200, send "-r 200".

    -h
    If you send a NUMBER as the -h parameter, it tells this function how many values to write 
    horizontally from parameter -v, before it shifts to the next row and continues writing 
    cells.

    If you send comma-separated strings as param -h, this function will write those values as 
    the column headers in the worksheet, and then begin writing the values from param -v into 
    the appropriate row/columns.

    TO COLORIZE TEXT:
    Send your color choice (red, green, blue, yellow, cyan, gray, black or white) with a "~" 
    symbol between your color and the value, i.e. "red~RESULT FAILED!" will write 
    "RESULT FAILED!" in red text.

    TO COLORIZE CELLS:
    Send your color (same choices as above) AND the color you want for text, separated with "~" 
    like so:

        "black~red~RESULT FAILED!"

    The above will make the cell black with red text. You must send BOTH a cell color AND a 
    text color to colorize cells.
    
    ||examples||
    EXAMPLE 1

        $vals = 'host 10,host 24,host 13,host 3'
        sheetz -f 'myoutput' -v $vals

    The above example will write out the hosts in a simple list to 'myoutput.xlsx' in cells 
    A1 - A4.

    EXAMPLE 2

        $hosts = 'host 1,blue~white~windows,11,192.168.10.10,host2,linux,red~kali,192.168.10.11'
        $headers = 'HOST,OS,VER,IP'
        sheetz -f 'myoutput' -v $hosts -r 5 -h $headers

    The above will create (or open) myoutput.xlsx, and then writes 'HOST' to cell A5, 'OS' to B5, 
    'VER' to C5, and 'IP' to D5. Next it will go through all the comma-separated values in param 2, 
    writing values into the next row until it reaches column D, then jump to the next row back at 
    column A. And in this example, cell B6 (windows) will be blue with white text while cell C7 
    (kali) will be in red text.
    
                         A         B       C         D
            row 5      HOST       OS      VER        IP
            row 6      host 1   windows   11    192.168.10.10
            row 7      host 2   linux     kali  192.168.10.11

    Make sure your script is sending your report values to param -v IN ORDER, otherwise they'll get 
    written to the wrong cells! Also, if you're adding values to an existing sheet, don't send the 
    headers, sheetz will automatically start writing to the next empty row (or you can specify a row
    in parameter -r, and the number of columns being written, in this case 4 columns (A-D).

    EXAMPLE 3

    Sometimes you don't need headers. You could set the fourth param to 6 if you just need to specify 
    that there should be 6 columns (A-F). If "$patchInfo" contains hosts and patch dates:
        
        sheetz -f 'patch report' -v $patchInfo -r 1 -h 6

                    A         B        C         D                 E           F
        row 1      host 1   windows   11    192.168.10.10      patched     1/31/2020
        row 2      host 2   windows   10    192.168.10.11      unpatched
    

    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$f,
        [Parameter(Mandatory=$true)]
        [string]$v,
        [int]$r=1,
        $h
    )

    <#
    TO ADD OR MODIFY THE DEFAULT CELL & FONT COLORIZATION:
    Colors have to be calculated by adding R + G + B, but G has to be multiplied by G and 256, 
    and B has to be multiplied by B * 256 * 256 because why just let us write 'blue', 'green, 
    'red'...

        Play with the equations to find more colors, and add them to $colors

        RGB COLORS:
        Black: RGB(0,0,0)
        White: RGB(255,255,255)
        Red: RGB(255,0,0)
        Green: RGB(0,255,0) This green is eye cancer
        Blue: RGB(0,0,255)
        Yellow: RGB(255,255,0)
        Magenta: RGB(255,0,255)
        Cyan: RGB(0,255,255)
        Light Gray: RGB(192,192,192)
        Dark Gray: RGB(128,128,128)
        Snot Green: RGB(204,255,204)
    #>

    ## MOD SECTION! ##
    $colors = @{
        'red~' = 255 + (1*256) + (1*256*256);
        'green~' = 204 + (255*256) + (204*256*256);
        'blue~' = (255*256*256);
        'white~' = 255 + (255*256) + (255*256*256);
        'gray~' = 128 + (128*256) + (128*256*256);
        'yellow~' = 255 + (255*256);
        'cyan~' = (255*256) + (255*256*256);
        'black~' = 0
    }

    $c = 1  ## Starting column

    if($h){
        if($h -Match "[a-z]"){
            $val2 = $h -Split(',')
            $val2c = $(($val2).count)
        }
        else{
            $val2c = $h
        }
    }

    $val1 = $v -Split(',')  ## Scripts should be sending comma-separated values


    # Add reference to the Microsoft Excel assembly
    try{ Add-Type -AssemblyName Microsoft.Office.Interop.Excel }
    catch{
        w '    ' -i; w 'Microsoft Excel is not installed!' r bl
        w ''; slp 2; Return
    }

    
    # Create a new Excel application
    $excel = New-Object -ComObject Excel.Application

    # Make Excel visible (optional)
    $excel.Visible = $true

    # Create a new workbook
    if(Test-Path "$vf19_DTOP\$f.xlsx"){
        $workbook = $excel.Workbooks.Open("$vf19_DTOP\$f.xlsx")
        $adding = $true
    }
    else{
        $workbook = $excel.Workbooks.Add()
    }

    # Select the first worksheet
    $worksheet = $workbook.Worksheets.Item(1)
    if($adding -and ! $r){
        $r = $worksheet.UsedRange.Rows.Count + 1
        write-host "$r"
    }


    # Write values to cells; if no $h values were passed, just write $val1 as a list in column A
    if($h){
        
        function columnVals($rr,$cc,$count){
            Foreach($v1 in $val1){
                if($v1 -Match "^[a-z]+~[a-z]+~"){
                    $shade_cell = $v1 -replace "~[a-z]+~",'~' -replace "~.+",'~'
                    $shade_text = $v1 -replace "^[a-z]+~?" -replace "~.+",'~'
                    $v1 = $v1 -replace "^[a-z]+~[a-z]+~"
                }
                elseif($v1 -Match "^[a-z]+~"){
                    $shade_text = $v1 -replace "~.+",'~'
                    $v1 = $v1 -replace "^[a-z]+~"
                }
                
                $worksheet.Cells.Item($rr, $cc).Value2 = $v1     ## Write values as a list in column A
                

                ## Format cells if applicable
                if($shade_cell){
                    $worksheet.Cells.Item($rr, $cc).Interior.Color = $colors[$shade_cell]    
                }
                if($shade_text){
                    $worksheet.Cells.Item($rr, $cc).Font.Color = $colors[$shade_text]
                }

                Remove-Variable shade_*

                $cc++                                         ## shift to the next column
                $count++                                      ## track which column is current
                if($count -gt $val2c){                        ## stop shifting if all columns have been written
                    $rr++                                     ## shift to the next row
                    $cc = 1                                   ## go back to column A
                    $count = 1                                ## reset column tracker
                }
            }
        }


        if($val2){
            Foreach($v2 in $val2){
                if($v2 -Match "^[a-z]+~[a-z]+~"){
                    $shade_cell = $v2 -replace "~[a-z]+~",'~' -replace "~.+",'~'
                    $shade_text = $v2 -replace "^[a-z]+~?" -replace "~.+",'~'
                    $v2 = $v2 -replace "^[a-z]+~[a-z]+~"
                }
                elseif($v2 -Match "^[a-z]+~"){
                    $shade_text = $v2 -replace "~.+",'~'
                    $v2 = $v2 -replace "^[a-z]+~"
                }

                ## Format cells if applicable & Write all the initial column values in row 1
                if($shade_cell){
                    $worksheet.Cells.Item($r, $c).Interior.Color = $colors[$shade_cell]    
                }
                if($shade_text){
                    $worksheet.Cells.Item($r, $c).Font.Color = $colors[$shade_text]
                }
                Remove-Variable shade_*

                $worksheet.Cells.Item($r, $c).Value2 = $v2  ## 
                $c++                                        ## shift to next column
            }
            $c = 1                                          ## go back to column A
            $r++                                            ## shift to next row
            
            columnVals $r $c 1
        }
        else{
            columnVals $r 1 1
        }

    }
    else{
        Foreach($v1 in $val1){
            if($v1 -Match "^[a-z]+~[a-z]+~"){
                $shade_cell = $v1 -replace "~[a-z]+~",'~' -replace "~.+",'~'
                $shade_text = $v1 -replace "^[a-z]+~?" -replace "~.+",'~'
                $v1 = $v1 -replace "^[a-z]+~[a-z]+~"
            }
            elseif($v1 -Match "^[a-z]~"){
                $shade_text = $v1 -replace "~.+",'~'
                $v1 = $v1 -replace "^[a-z]~"
            }

            $worksheet.Cells.Item($r, $c).Value2 = $v1     ## Write values as a list in column A

            if($shade_cell){
                $worksheet.Cells.Item($rr, $cc).Interior.Color = $colors[$shade_cell]    
            }
            if($shade_text){
                $worksheet.Cells.Item($rr, $cc).Font.Color = $colors[$shade_text]
            }

            Remove-Variable shade_*
            
            $r++
        }
    }
    

    #$worksheet.Cells.Item(4, 3).Value2 = 'TEST'
    #$worksheet.Cells.Item(4, 4).Value2 = 'SUCCESSFUL'



    # Save the workbook (optional)
    if( Test-Path "$vf19_DTOP\$f.xlsx" ){
        $workbook.Save()
    }
    else{
        $workbook.SaveAs("$vf19_DTOP\$f.xlsx")
    }

    # Close Excel
    #$excel.Quit()

    # Clean up COM objects
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}




function getFile([string]$filter){
    <#
    ||longhelp||

    getFile [-f FILTER]

    This opens a dialog window so the user can specify a filepath to whatever.
    
    Param -f is optional, and allows you to specify a filetype to select, OR
    to select a folder instead of a file. The default is to show all files for 
    selection.
    
    ||examples||
    Ask user to select any filetype:
    
        $file_to_read = getFile
    
    Ask user for a .txt file:
    
        $file_to_read = getFile -f 'Text Document (.txt)|*.txt'

    Ask user to select a folder:

        $folder = getFile -f folder
        
    #>
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    if($filter -eq 'folder'){
        $f = New-Object System.Windows.Forms.FolderBrowserDialog
    }
    else{
        $o = New-Object System.Windows.Forms.OpenFileDialog
    }
    
    if($f){
        #$f.rootfolder = $wherever
        $f.Description = "Select a folder"
        $f.SelectedPath = 'C:\'

        if($f.ShowDialog() -eq "OK"){
            Return $f.SelectedPath
        }
        else{
            Return $false
        }
        
    }
    else{
        #$o.initialDirectory = $vf19_DTOP  ## this got annoying for selecting multiple files
        $o.InitialDirectory = $wherever
        if($filter){
            $o.filter = $filter
        }
        else{
            $o.filter = "All files (*.*)| *.*"
        }
        $o.ShowDialog() | Out-Null
        $o.filename
    }

}






function houseKeeping(){
    <#
    ||longhelp||

    houseKeeping [$1] [$2]

    Delete stale reports generated by various MACROSS tools.
    
    Users can choose to delete some, all, or none of the files in the directory 
    you pass to this function. Make sure not to pass generic folders like 'Desktop' 
    or 'Documents', giving users the opportunity to accidentally delete all their 
    stuff!

        Param $1 = the filepath determined by the tool that calls this function,
        Param $2 = your tool's name

    Both params are required in that order.

    ||examples||
    If your script writes outputs to text files in a specific folder:
    
        houseKeeping "$filepath\*txt" 'MyScript'
        
        
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [string]$1,
        [Parameter(Mandatory=$true)]
        [string]$2
    )
    $reports = $1
    function listFiles(){
        $Script:fpath = (Get-ChildItem -File -Path "$reports")
        $Script:fcount = $fpath.count
        $Script:flist = @()
        $b = 0
        Write-Host -f YELLOW "       EXISTING $2 REPORTS
    
        "
        $fpath | ForEach-Object{  ## Create a list of the filenames to display onscreen
            $b++
            $n = $_.Name
            $m = $_.LastWriteTime
            $Script:flist += $n
            Write-Host "   $b. $n" -NoNewline;  ## display the filename and its last modified time
            Write-Host ":  $m"
        }
        Write-Host '
        '
        Write-Host -f GREEN "  Select a file to delete, 'a' to delete all of them,  "
        Write-Host -f GREEN "  or 's' to skip:  " -NoNewline;
    }
    function rmFiles($del){
        $reportdir = $reports -replace "\*.*$",''

        ## MOD SECTION
        ## uncomment for debugging the occasional derp
        #Write-Host 'deleting ' -NoNewline; write-host "$reportdir\$del" 

        Remove-Item -Force -Path "$reportdir\$del"
        if(Test-Path -Path "$reportdir\$del"){
            Write-Host -f CYAN '
            ...Delete action failed!
            '
            errLog INFO "$USR/MACROSS(houseKeeping)" "Failed to delete $($_.Name) for $2"
        }
        else{
            $Script:fcount = $fcount - 1
        }
    }

    $Z = '';
    
    ''
    while( $Z -notMatch "^[0-9]+$" ){
        while($Z -eq ''){
            listFiles
            $Z = Read-Host
        }
        ''
        slp 1
        if( $Z -eq 's' ){    ##  Setting to 9999 skips the final task of selecting files to delete
            $Z = 9999
        }
        elseif( $Z -eq 'a' ){  ## Delete all files in the provided directory if user selects 'a'
            $Z = 9999
            $fpath |
                Foreach-Object{
                    $dn = $_.Name
                    Write-Host -f CYAN "  Deleting $dn...."
                    rmFiles $dn
                    errLog INFO "$USR/MACROSS(houseKeeping)" "Deleted $($_.Name) for $2"
                    slp 1
                }
        }
    
     
        if($Z -ne 9999){
            $Z = $Z - 1
            $fpath |
                Foreach-Object{
                    if($flist[$Z] -eq $_.Name){
                        $dn = $_.Name
                        Write-Host -f CYAN "  Deleting $dn...."
                        rmFiles $dn
                        errLog INFO "$USR/MACROSS(houseKeeping)" "Deleted $($_.Name) for $2"
                        slp 1 
                    }
            }
            if( $fcount -gt 0 ){
                Write-Host -f GREEN '
                Delete another? (y/n) ' -NoNewline;
                $Z = Read-Host
                if($Z -eq 'y'){
                    $Z = ''
                }
                else{
                    $Script:fcount = 0
                    $Z = 9999
                }
            }
        }
    }

    ''
    slp 1
    
    Remove-Variable -Force fpath,flist
}



