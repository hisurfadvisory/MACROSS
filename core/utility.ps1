## MACROSS shared utilities

## These values can only be set after all initializations have finished
function finalSet(){   
    getThis $vf19_MPOD['enr']
    battroid -n vf19_TABLES -v $vf19_READ
    getThis $vf19_MPOD['log']
    battroid -n vf19_LOG -v $vf19_READ
    getThis $vf19_MPOD['rep']
    battroid -n vf19_REPOCORE -v $vf19_READ
    if(Test-Path $vf19_REPOCORE){
        ## If you want to control tier-level access, change the $vf19_REPOCORE location and store  
        ## master copies of your tools there. That way, MACROSS will be able to auto-download tier- 
        ## appropriate tools to each analyst. You can use the configuration wizard to store the
        ## location of your master copies, and modify the vf19_REPOTOOLS line below using the same 
        ## method seen above:

        ##     getThis $vf19_MPOD[your_key]; battroid -n vf19_REPOTOOLS -v $vf19_READ

        battroid -n vf19_REPOTOOLS -v "$vf19_REPOCORE\modules"
        $Global:vf19_VERSIONING = $true
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
    macrossHelp 'show'
    ''
    #getThis -h $(setCC -b); getThis $vf19_READ; $rst = [regex]$vf19_READ
    $rst = $(setCC -b); getThis IFRoYXQgaXMgYSBwcml2aWxlZ2VkIGNvbW1hbmQu; $bm = $vf19_READ
    
    if($1){
        if($1 -Match $rst -and ! $ad){w "$bm`n`n" 'r' 'bl'; $ad = setConfig -a}
        if(($ad -eq $vf19_GPOD.Item1) -or ($1 -notMatch $rst)){
            startUp;if($1 -eq 'help'){macrossHelp 'dev';macrossHelp 'show'}
            elseif($1 -Like "help *"){macrossHelp $($1 -replace "help ");macrossHelp 'show'}
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
            if($MONTY){ w '
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
                #py "$vf19_TOOLSROOT\core\pydev.py" $USR $pyATTS $vf19_DTOP $vf19_PYPOD $N_[0] $vf19_pylib $vf19_TOOLSROOT
                py "$vf19_TOOLSROOT\core\pydev.py" $vf19_pylib
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
            $la = @()
            $lc = $((Get-ChildItem $vf19_LOG).count)
            (Get-ChildItem $vf19_LOG).Name | Sort -Descending | %{
                $la += $_
            }
            splashPage
            ''
            while( $z -ne 'q' ){
                $ln = 1
                $la | %{
                    screenResults "$ln" "$($la[$ln-1])"
                    $ln++
                }
                screenResults "y~    ($lc logs)             SELECT A FILE # ABOVE (`"q`" to quit):"
                screenResults -e
                w ' Log file >  ' g -i
                $z = Read-Host

                if($la[$z-1]){
                    $mi=1
                    foreach($msg in (Get-Content "$vf19_LOG\$($la[$z-1])")){
                        $msg = $msg -Split "`t"
                        if($msg[1] -eq 'ERROR'){
                            $level = "r~MSG $mi`: " + "$($msg[1])"
                        }
                        else{
                            $level = "MSG $mi`: $($msg[1])"
                        }
                        screenResults $("$level  $($msg[0])")
                        if($msg[3]){
                            screenResults "w~$($msg[2])" "$($msg[3])"
                        }
                        elseif($msg[2]){
                            screenResults "w~$($msg[2])"
                        }
                        $mi++
                    }
                    screenResults -e
                    ''
                    Write-Host -f GREEN '  Hit ENTER to continue.
                    '
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
    if(Get-ChildItem "$vf19_GBIO\*.eod"){
        Get-ChildItem "$vf19_GBIO\*.eod" | %{
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
    Write-Host '
    
    '
    if($1 -eq 0){
        $resp = "Decoded:"
        $ask = "Decode another?"
        Write-Host -f GREEN "
        Enter 'hex' or 'b64' followed by your encoded string (hex strings can contain '0x'),
        or 'c' to cancel:
        >  " -NoNewline; $Z = Read-Host
        if($Z -Match "^hex"){
            $Z = $Z -replace "^hex ?",''
            getThis $Z -h; $Z = $vf19_READ
        }
        elseif($Z -Match "^b64"){
            $Z = $Z -replace "^b64 ?",''
            getThis $Z; $Z = $vf19_READ
        }
        elseif($Z -eq 'c'){
            Remove-Variable Z
        }
        else{
            Remove-Variable Z
            Write-Host -f CYAN '
            You need to specify "b64" or "hex".'
            decodeSomething
        }
    }
    elseif($1 -eq 1){
        $resp = "Encoded:"
        $ask = "Encode another?"
        Write-Host -f GREEN "
        Enter the string to base64-encode, or 'c' to cancel:
        >  " -NoNewline; $Z = Read-Host 

        $Z = "$resp $(getThis $Z -e)"
    }

    if($Z){
        Write-Host -f GREEN "
        $resp " -NoNewline;
        Write-Host " $Z
        "
        Write-Host -f GREEN "    $ask " -NoNewline;
        $Z = Read-Host
        if($Z -Match "^y"){
            Remove-Variable Z
            decodeSomething $1
        }
    }
        
}

## These vars & functions need to get loaded when python calls powershell scripts without MACROSS values
if( ! $vf19_TOOLSROOT ){
    $vf19_TOOLSROOT = '..'
    $Global:vf19_TOOLSDIR = "$vf19_TOOLSROOT\modules\"
    . "$vf19_TOOLSROOT\core\display.ps1"
    . "$vf19_TOOLSROOT\core\validation.ps1"
}



function getThis(){
    <#
    ||longhelp||

    getThis [-v value] [-e encode] [-h hexadecimal]

    Decode encoded values to $vf19_READ, or encode your plaintext value.
    
    -DO NOT USE ENCODING TO HIDE USERNAMES/PASSWORDS/KEYS or other sensitive info!
    

    ||examples||
    -$vf19_READ gets overwritten every time this function is called. If you require the plaintext 
    as a persistent value, You *must* set $vf19_READ to a new variable:

        getThis $base64string
        $plaintext = $vf19_READ

    -To decode a hexadecimal string, call this function with -h (and your hex string can include 
    spaces and/or "0x" tags, or neither):

        getThis "0x746869732069 730x20 61 200x740x650x7374" -h
        $plaintext = $vf19_READ

    -If you want to ENCODE plaintext, call this function with your plaintext as the first parameter 
    using the -e option. Use -h if you want hexadecimal output. This mode does NOT write to $vf19_READ!
        
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
    Have your scripts write to MACROSS logs for troubleshooting/auditing. The default location
    is $vf19_LOG, wherever you've specified that location to be. The current timestamp automatically
    gets written to the log, you don't need to send it. Just send at least 2 params, like a log-level
    (ERROR, INFO, etc.) and the log message. You can also send a 3rd parameter if necessary.
    
    These logs can be viewed from MACROSS' debug screen.
    
    ||examples||

    errLog 'WARN' "$SCRIPT failed to perform $TASK"
    errLog 'INFO' $USR 'Accessed API for blah.'

    #>
    Param(
        [Parameter(Mandatory=$true)]
        $1,
        $2,
        $3
    )
    

    ## By default, the logs directory is set to your local MACROSS/resources/logs
    ## folder. You should change this to an alternate location if you don't want
    ## all users to see these logs. (It is set with $vf19_MPOD['log'], which gets
    ## set in the "temp_config.txt" file.)
    
    $d = $(Get-Date -Format 'yyyy-MM-dd')
    $t = $(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')
    [string]$log = $($d) + '.log'                 ## Create the log filename
    [string]$msg = "$t"                           ## Begin the log msg with the timestamp

    if($3){
        $msg = $msg + "`t" +$1 + "`t" + $2 + "`t" + $3
    }
    elseif($2){
        $msg = $msg + "`t" +$1 + "`t" + $2
    }
    else{
        $msg = $msg + "`t" +$1
    }
    
    if(Test-Path -Path "$vf19_LOG\$log"){
        $msg | Out-File "$vf19_LOG\$log" -Append
    }
    else{
        $msg | Out-File "$vf19_LOG\$log"
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
        $pyp = (gc "$vf19_GBIO\PROTOCULTURE.eod" | ConvertFrom-Json)
        screenResults "PROTOCULTURE = " "$PROTOCULTURE"
        if($pyp){
            $k = $pyp.PSObject.Properties.Name
            screenResults 'PROTOCULTURE.eod' $($pyp."$k" + ': ' + "$($pyp."$k".results)")
        }
        screenResults -e
        ''
        w 'Hit ENTER to clear it.' 'g'
        Read-Host; Remove-Variable -Force PROTOCULTURE -Scope Global
        if(Test-Path $vf19_PROTO){ Remove-Item -Path $vf19_PROTO }
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
    
        "MACROSS\core\py_classes\garbage_io\"

    so that python & powershell scripts can easily share the same investigation data during a 
    MACROSS session. Eventually MACROSS will improve the way it handles this.
    
    The .eod files are encoded in utf8, so plan accordingly.
  
    REQUIRED:  Your script name, as well as the value you want written to that file ($val1). 
    The default file will be PROTOCULTURE.eod, written as a basic json string:
    
        { 'YourScriptName' : { 'target': $value1, 'result': $value2 } }
        
    If you need something other than this format, you can provide an alternative filename as the 
    3rd parameter, and write whatever type of data your file is to that.

    Originally, the PROTOCULTURE.eod file collected search values for all scripts during any
    given MACROSS session, which is why it is in json format. But it made more sense to limit
    this to a single result field, so this file simply gets overwritten with each use of pyCross, 
    and no longer appends json items for every PROTOCULTURE search.
    
    If the PROTOCULTURE.eod file already exists, this function will check to see if the "result" 
    key contains a non-empty value. If so, it assumes this is a response from python to a query 
    from powershell, and sets that "result" value as $PROTOCULTURE.
    
    If "result" is empty, pyCross then assumes you are responding to a python script's request, 
    and will write your $value to the "result" key of the json. Otherwise, $value gets written to 
    the "target" key in a new PROTOCULTURE.eod file. If your value is a hashtable or list, it will
    be converted into a single large string dilineated by "@@".
    
    ||examples||
    if( $python_called -eq $true){
  
        # Write the results of the python script's request to "PROTOCULTURE.eod"
        pyCross 'myScriptName' $value
  
        # Or you can create a different file, "myResultFile.eod"
        foreach($item in $list){
            pyCross 'myScriptName' $item 'myResultFile'
        }
  
    }
  
    ...and then your python script can do whatever with it:
        json.dumps(open('PATH\\PROTOCULTURE.eod).read())
        open('PATH\\myResultFile.eod').read()
  
    The file outputs are written with the extension "*.eod" (including your custom filenames) to 
    ensure regular cleanup (see the "cleanGBIO" function elsewhere in this file).
    
#>
    Param(
        [Parameter(Mandatory)]
        [string]$caller,
        [Parameter(Mandatory)]
        $result,
        [string]$filenm
    )
    
    if($filenm){
        $filenm = $filenm + '.eod'  ## Append custom extension
        [IO.File]::WriteAllLines("$vf19_GBIO\$filenm",$result)
        #$result | Out-File -FilePath "$vf19_GBIO\$filenm" -Encoding UTF8 -Append  ## Write results to file
        if(-not(Test-Path -Path "$vf19_GBIO\$filenm")){
            errLog 'ERROR' "$USR/$caller" "Failed pyCross write-to $filenm"
            w "r~ERROR! File did not write! "
            slp 3
        }
    }
    elseif(Test-Path -Path $PROTOFILE){
        $p = Get-Content $PROTOFILE | ConvertFrom-Json
        if($p.$((gc $PROTOFILE) -replace "^\W+" -replace "\W.+$").result -ne ''){
            $PROTOCULTURE = $p.$((gc $PROTOFILE) -replace "^\W+" -replace "\W.+$").result
        }
        else{
            if($result.getType().Name -eq 'Hashtable'){
                $h2s = ''; $result.keys | %{
                    $h2s += $("$_" + ':' + "$($result[$_])" + '@@')
                }
                $result = $h2s -replace "@@$"
            }
            elseif($result.getType().Name -eq 'Array'){
                $a2s = ''; $result | %{
                    $a2s += "$_" + '@@'
                }
                $result = $a2s -replace "@@$"
            }
            $r = (Get-Content $PROTOFILE) -replace ".result.+:.+\}","`"result`":`"$result`"}}"
            [IO.File]::WriteAllLines($PROTOFILE,$r) #Set-Content $PROTOFILE $r -Encoding UTF8
        }
    }
    else{
        [IO.File]::WriteAllLines($vf19_PROTO,"{'$caller':{'target':$result,'result':''}}")
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
        Return $($vf19_LATTS[$1].toolInfo())
    }
    else{
        $vf19_LATTS.keys | %{$vf19_LATTS[$_].toolInfo()}
    }
}



function stringz($f=$(getFile),$noKeep=0){
    <#
    ||longhelp||
    For those deployments when "strings" isn't a default Windows utility.
    
    Send a filepath, or let the function open a dialog for you. Send 1 as 
    parameter $2 if you don't want to keep the outputs.
    
    ||examples||
    Dump strings from an executable to your desktop:
    
        stringz <filepath>
        
    Do the same, but write outputs to screen without saving to file:
    
        strings <filepath> 1
    
    #>
    if($f -ne ''){
        Get-Content $f | %{
            if( !($_ -cMatch "[^\x00-\x7F]")){
                $n++
                Write-Host "  Extracting line $n to macross-stringz.txt..."
                $_ | Out-File "$vf19_DTOP\macross-stringz.txt" -Append
            }
        }
    }
    Get-Content "$vf19_DTOP\macross-stringz.txt"
    if( $noKeep -eq 0){
        Remove-Item -Path "$vf19_DTOP\macross-stringz.txt"
    }
}



function getHash(){
<#
    ||longhelp||

    getHash [-f FILE] [-a MD5|SHA256]

    Get the hash of a file; must pass the filepath and hashing method
    
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
        if($alg -in $type){
            $h = CertUtil -hashfile $file $alg
        }
    }
    Return $h
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

    if(! $MSXL){
        w '    ' -i; w 'Microsoft Excel is not installed!' r bl
        w ''; slp 2; Return
    }
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
    Add-Type -AssemblyName Microsoft.Office.Interop.Excel

    
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

    houseKeeping $filepath $your_script_name

    Delete stale reports generated by various MACROSS tools.
    
    Users can choose to delete some, all, or none of the files in the directory 
    you pass to this function. Make sure not to pass generic folders like 'Desktop' 
    or 'Documents', giving users the opportunity to accidentally delete all their 
    stuff!

        Param $1 = the filepath determined by the tool that calls this function,
        Param $2 = your tool's name

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
        #Write-Host 'deleting ' -NoNewline; write-host "$reportdir\$del"  # uncomment for debugging the occasional derp
        Remove-Item -Force -Path "$reportdir\$del"
        if(Test-Path -Path "$reportdir\$del"){
            Write-Host -f CYAN '
            ...Delete action failed!
            '
            errLog 'ERROR' "$USR failed to delete $($_.Name) for $2 (houseKeeping)"
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
                    errLog 'INFO' "$USR deleted $($_.Name) for $2 (houseKeeping)"
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
                        errLog 'INFO' "$USR deleted $($_.Name) for $2 (houseKeeping)"
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



