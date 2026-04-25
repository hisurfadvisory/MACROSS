## MACROSS added functionalities


function alphanum([switch]$hex=$false,$rand=0){    #mp
    <#
    ||shorthelp||
    alphanum [-h HEX CHARS] [-r NUMBER_OF_RAND_TO_RETURN]

    ||longhelp||
    Returns a list of alphanumeric & special characters. Use -h to only
    return characters used in hexadecimal bytes. Use -r to return a random
    string that is $r characters long.

    Index 0 is the lower-upper case alphabet and 0-9, while Index 1
    contains a string of special characters.

    ||examples||
    $hex_chars = alphanum -h        List of A-F and 0-9
    $random_str = alphanum -r 32    String of 32 random chars
    $alpha_string = (alphanum)[0]   List of lower & upper alphabet and 0-9
    $specials = (alphanum)[1]       List of non-alphanumeric chars

    $a = $alpha_string[0]           The letter 'a'
    $zero = $alpha_string[52]       The number '0'
    $nine = $alpha_string[61]       The number '9'
    $aa = $specials[2]              The character '#'

    #>
    $an = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' -Split '' | ?{$_ -ne ''}
    $sc = '!@#$%^&*_' -Split '' | ?{$_ -ne ''}
    if($hex){ $an = '0123456789ABCDEF' -Split '' | ?{$_ -ne ''} }
    elseif($rand -gt 0){
        $na = @()
        0..$rand | %{$na += $an[$(Get-Random -min 0 -max $an.count)]}
        $an = $na -Join ''
    }
    else{ $an = @($an,$sc) }
    Return $an
}

function cfJson($psobj){   #mp
    <#
    ||shorthelp||
    cfJson [-p DATA_AS_PSOBJECT]

    ||longhelp||
    Convert a custom PSObject directly into a hashtable or array without messing
    with object trees all day long. This should work with powershell versions
    5, 6 & 7, though probably unnecessary on 7.

    ||examples||

    ## Convert from a PSObject
        $my_data = get-content $path_to_file -raw | convertfrom-json
        $my_json = cfJson -d $mydata


    #>

    if($psobj -is [System.Collections.IDictionary]){
        $dict = @{}
        foreach($k in $psobj.keys){
            $dict[$key] = cfJson -d $($psobj[$key])
        }
        Return $dict
    }

    if($psobj -is [System.Collections.IENumerable] -and -not ($psobj -is [string])){
        $array = mkList
        foreach($j in $psobj){
            [void]$array.Add($(cfJson -d $j))
        }
        Return $array.toArray()
    }

    Return $psobj
}

function mkList(){      #mp
    <#
    ||shorthelp||
    Returns a dynamic array for collecting lists of items.

    ||longhelp||
    I despise how wordy powershell & .NET are. Use this when you need a dynamic
    array for large datasets and can't use "@()"

    ||examples||

    $list = mkList
    $list.add('abc 123')

    #>
    Return New-Object System.Collections.Arraylist
}

## Pause the console to run powershell commands in a temporary shell
function runSomething(){
    cls
    w "`n`n  Pausing MACROSS: type" -i g
    w 'exit' -i y
    w 'to close your session and return to' g
    w " the tools menu.`n`n" g

    powershell.exe

    Return
}


## Decode one-off base64 or hex strings
function decodeSomething(){
    w "
    Enter 'hex' or 'b64' followed by your encoded string (hex strings can contain '0x'),
    or 'c' to cancel:
    >  " g -i; $Z = Read-Host
    if($Z -Like "hex*"){
        $Z = $Z -replace "^hex ?",''
        reString $Z -h
    }
    elseif($Z -Like "b64*"){
        $Z = $Z -replace "^b64 ?",''
        reString $Z
    }
    elseif($Z -eq 'c'){
        Remove-Variable Z
    }
    else{
        Remove-Variable Z
        w '
        You need to specify "b64" or "hex".' c
        decodeSomething
    }

    if($Z){
        w "
        Decoded: " g -i
        w " $dyrl_PT`n"
        w '    Enter another string to decode, or "c" to cancel: ' g -i
        $Z = Read-Host
        if($Z -ne 'c'){
            decodeSomething
        }
    }

}

function uniStrip($dirty_string){ #mp
    <#
    ||shorthelp||
    uniStrip [-d STRING_WITH_BOM]

    ||longhelp||
    Not much else to explain for this. Useful when reading data from a
    Microsoft text file because they BOM the $#!t out of unicode for
    some dumb reason.

    ||examples||

    $plaintext = uniStrip $string_with_unicode


    #>
    Return $($dirty_string -replace $dyrl_ASCII)
}


## Non-tool selections from the main menu
function extras($1){
    function flkup_(){
        $Global:CALLER = 'MACROSS'
        . "$dyrl_MODS\$($dyrl_LATTS[$((findMods -v edr -e)[0])].fname)"
        rv -Force CALLER -Scope Global
    }
    function refall_(){
        w "`n   This will pull fresh copies of ALL the tools in your nmods folder." g
        w '  Continue?  ' y -i
        $Z = Read-Host
        if($Z -notMatch "^n"){
            foreach($f in (gci $dyrl_MODS)){rm -path $f.FullName}
        }
    }

    if($1 -eq 'config'){splashBanner; runModify -a $(xEntry) }
    elseif($1 -eq'dec'){cls;decodeSomething}
    elseif($1 -eq 'strings'){stringz -w}
    elseif($1 -eq 'phone'){yellowPages}
    elseif($1 -eq 'passw'){updatePass}
    elseif($1 -eq 'shell'){runSomething}
    elseif($1 -eq 'refresh'){dlNew MACROSS $dyrl_LATESTVER}
    elseif($1 -eq 'refreshall'){refall_}
    elseif($1 -eq 'file'){ flkup_ }
    elseif($1 -eq 'export'){ upWrite -e }
    elseif($1 -eq 'terminate'){
        if($PROTOCULTURE){ Remove-Variable -Force PROTOCULTURE -Scope Global }
        cleanGBIO -s
    }
    elseif($1 -eq 'newkey'){
        "`n`n"
        startUp
        $n = Read-Host 'Enter a name for your key'
        gerwalk $n -g
        "`n Hit ENTER to continue."
        Read-Host
    }
    elseif($1 -eq 'pydev'){
        splashBanner
        pyATTS; pyENV
        cls
        launcher -p -c "$dyrl_MACROSS\corefuncs\pydev.py"
        pyENV -c
    }
}


## Phone lookups (requires admin)
function yellowPages(){
    while($lookup -ne 'c'){
        w "
    MACROSS PHONEBOOK (relies on Active Directory):

    Enter a username, partial name, or the last 4 digits of an extension ('c' to cancel): " -i g
    $lookup = Read-Host


        if($lookup -eq 'c'){
            Return
        }


        if($lookup -match "^\d{4}$"){
            $result = (Get-ADUser -filter * -properties samAccountName,displayName,officePhone |
                where{$_.officePhone -like "*$lookup"} |
                Select samAccountName,displayName,officePhone)
        }
        else{
            $result = (Get-ADUser -filter * -properties samAccountName,displayName,officePhone |
                where{$_.samAccountName -eq "$lookup" -or $($_.displayName) -Like "*$lookup*"}) |
                Select samAccountName,displayName,officePhone,description
        }


        if($result){
            $result | %{
                screenResultsAlt -h $_.samAccountName -k 'NAME: ' -v $_.displayName
                screenResultsAlt -k 'PHONE: ' -v $_.officePhone
                screenResultsAlt -k 'OFFICE: ' -v $_.description
                screenResultsAlt -e
            }
        }
        else{
            $lookup = $lookup + '!'
            w "
    No results for $lookup
        " c
        }
    }
}

function spaceFold(){
    $Global:ErrorActionPreference = 'SilentlyContinue'
    $Global:dyrl_LATTS = @{}
    $ss = $env:MACTEMP -Split ';'; $snn = ($ss -Split ',')[4]
    $Global:dyrl_MACROSS=$ss[0]; $Global:dyrl_OUTFILES=$ss[1]
    $Global:dyrl_CONTENT=$ss[2]; $Global:dyrl_LOGS=$ss[3];
    $Global:N_=@($snn[0],$([int[]](($snn[0] -split '') -ne '')),$([int[]](($snn[1] -split '') -ne '')));
    $Global:USR=$ss[5]; $Global:dyrl_TMP=$ss[6]
    $Global:dyrl_MODS="$dyrl_MACROSS\diamonds"
    $Global:dyrl_PG=@("$dyrl_MACROSS\corefuncs\pycross","$dyrl_MACROSS\corefuncs\pycross\garbage_io")
    $latts = (Get-Content -raw "$($dyrl_PG[1])\LATTS.mac7" | ConvertFrom-Json)
    $proto = (Get-Content -raw "$($dyrl_PG[1])\PROTOCULTURE.mac7" | ConvertFrom-Json)
    if(-not $latts.$CALLER){$latts = cfJson $latts} 
    if(-not $proto.caller){$proto = cfJson $proto}
    $Global:dyrl_LATTS = $latts
    $Global:PROTOCULTURE = $proto.protoculture
}

function consoleDebug($x=$null,$ch=$null){
    $msgloop = 'Type another command for testing, "d" to reload the menu, or hit ENTER to exit debugging: '
    w "`n                         MACROSS DEBUG MODE`n" y
    macrossHelp show
    ''
    if($x){
        startUp;reString VGhhdCdzIGEgcHJpdmlsZWdlZCBjb21tYW5kLg==;$ha=$dyrl_PT
        reString $dyrl_CONF.bl0;$hb=$dyrl_PT;errLog INFO ;slp -m 450
        if($ch -eq $hb){$if="$USR debug ($x)"}else{varCleanup;$if="$USR debug ($x)"}
        while(-not $dyrl_CONF.tr1 -and $x -Match $hb){w "$ha`n`n" -b r -f k;startUp -r "$(xEntry)"
        if(-not $dyrl_CONF.tr1){Return}}
        if($x -eq 'help'){
            macrossHelp dev
            splashPage
            macrossHelp show
        }
        elseif($x -Like "help *"){
            macrossHelp $($x -replace "help ")
            cls
            macrossHelp show
        }
        else{
            $z = $x; while($z -ne ''){
                if($z -eq 'd'){rv cmd,x,z; consoleDebug}
                $z = $z -replace "^debug ";
                if($dyrl_LOG -ne 'none'){errLog INFO 'MACROSS.debug' "$USR/$dyrl_HN0`: $z"}
                $cmd = [scriptblock]::Create("$z")
                . $cmd
                w $msgloop g; $z = Read-Host
            }
            Return
        }


        w "`n    $msgloop`n" g
        $response = Read-Host
        if($response -ne ''){
            consoleDebug $response
        }
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
                3. Pause after each error message with a choice to continue' g

            if($dyrl_LOG -ne 'none'){w '
            OR Type "logs" to review MACROSS log files,' g}
            if($MONTY){ w '
            OR Type "python" to open a MACROSS python session for testing,' g}
            w '
            OR Enter any command to begin testing/debugging within powershell' g
            w '
            OR hit ENTER to quit and exit.

            >  ' g -i
        $z = Read-Host

        if($z -eq ''){ Return }
        if($z -ne 'logs'){
            if($z -eq 4){
                Return
            }
            elseif($z -eq 'python'){
                startUp;pyATTS;pyENV;if($dyrl_LOG -ne 'none'){errLog INFO 'MACROSS.debug' "pydev success ($dyrl_HN0)"};cls
                launcher -p -c 'dev'
            }
            elseif($z -notIn 1..3){
                cls
                consoleDebug $z
            }
            else{
                $Script:ErrorActionPreference = $e[$([int]$z - 1)]
                splashPage
                $c = $ErrorActionPreference
                Write-Host -f CYAN "
                Error display is now set to:  $c"
                sleep 2; consoleDebug
            }
        }
        else{
            $la = @()
            (Get-ChildItem $dyrl_LOG).Name | Sort -Descending | %{
                $la += $_
                $ln++
            }
            splashPage
            ''
            while( $z -ne 'q' ){
                $ln = 1;$row = 0
                Foreach($file in $la){
                    $row++
                    if($ln -ge 100){$index = "$ln"}
                    elseif($ln -lt 10){$index = "  $ln"}
                    else{$index = " $ln"}
                    w "$($index+'.')" -i y
                    if($row -eq 1){$ln++; $row++; w $file -u -i}
                    else{w $file -u; $row = 0}
                }
                ''
                screenResults "c~             SELECT A FILE ABOVE (1-$($ln-1) or `"q`" to quit):"
                screenResults -e
                w ' Log file >  ' g -i
                $z = Read-Host

                if([int]$z -and $la[$z-1]){
                    $lf = $la[$z-1]; $logmsgs = New-Object System.collections.ArrayList
                    foreach($mm in Get-Content "$dyrl_LOG\$lf"){
                        reString $mm
                        $logmsgs.Add($dyrl_PT) > $null
                    }

                    Add-Type -AssemblyName System.Windows.Forms
                    [System.Windows.Forms.Application]::EnableVisualStyles()
                    $L_viewer = New-Object System.Windows.Forms.Form

                    $L_viewer.Text = "MACROSS log view"
                    $L_viewer.Font = [System.Drawing.Font]::new("Tahoma",10.5)
                    $L_viewer.ForeColor = 'WHITE'
                    $L_viewer.Size = New-Object System.Drawing.Size(1350,725)
                    $L_viewer.BackColor = 'BLACK'
                    $L_viewer.StartPosition = "CenterScreen"

                    $L_label = New-Object System.Windows.Forms.Label
                    $L_label.Font = [System.Drawing.Font]::new("Tahoma",10)
                    $L_label.Location = New-Object System.Drawing.Point(10,5)
                    $L_label.Size = New-Object System.Drawing.Size(200,20)
                    $L_label.ForeColor = 'YELLOW'
                    $L_label.Text = "Viewing log $lf"
                    $L_viewer.Controls.Add($L_label)

                    $L_logs = New-Object System.Windows.Forms.TextBox
                    $L_logs.Font = [System.Drawing.Font]::new("Consolas",9)
                    $L_logs.Multiline = $true
                    $L_logs.ScrollBars = 'Vertical'
                    $L_logs.ForeColor = 'WHITE'
                    $L_logs.BackColor = 'GRAY'
                    $L_logs.Location = New-Object System.Drawing.Point(10,30)
                    $L_logs.Size = New-Object System.Drawing.Size(1300,500)
                    $L_viewer.Controls.Add($L_logs)

                    $logmsgs | %{
                        $L_logs.AppendText($_ + [Environment]::NewLine)
                    }

                    $L_exit = New-Object System.Windows.Forms.Button
                    $L_exit.Location = New-Object System.Drawing.Point(623,600)
                    $L_exit.Size = New-Object System.Drawing.Size(150,30)
                    $L_exit.Text = "EXIT"
                    $L_exit.Enabled = $true
                    $L_exit.DialogResult = [System.Windows.Forms.DialogResult]::OK
                    $L_viewer.Controls.Add($L_exit)
                    $L_viewer.AcceptButton = $L_exit

                    $L_exit.Add_Click({
                        $L_logs = $null
                        $logmsgs = $null
                    })

                    $L_viewer.TopMost = $true
                    $L_GUI = $L_viewer.ShowDialog()

                }
            }
            Return
        }
    }
}


## ARS and CTRL+ALT+DEL won't let you update your own password when it expires SMH
if(! $dyrl_NOPE){
function updatePass(){
    splashPage
    $PSR = "C:\Users\$USR\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    $pls = "$((Get-QADUser -Identity $USR).passwordLastSet)`."
    Write-Host -f GREEN "
    Your password was last changed on $pls

    MACROSS will update your admin password in Active Directory. Hit ENTER to
    continue, or 'c' to cancel: " -NoNewline;
    $a0 = Read-Host
    if($a0 -eq 'c'){
        Return
    }
    else{
        while($true){
            w '
    Enter your new password or "q" to quit: ' -i g
            $a1 = Read-Host -AsSecureString
            $a1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($a1)
            $b1 = [System.Runtime.InteropServices.Marshal]::ptrToStringAuto($a1)
            if($b1 -eq "q"){ Exit }
            w '
                  Enter the password again: ' -i g
            $a2 = Read-Host -AsSecureString
            $a2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($a2)
            $b2 = [System.Runtime.InteropServices.Marshal]::ptrToStringAuto($a2)
            if($b1 -ne $b2){ w 'Passwords to not match!' y }
            else{ Break }
        }
    }

    w '
    Updating password...
    ' g

    Set-QADUser -Identity $USR -UserPassword "$b1" -Proxy | Out-Null

    $date = $(Get-Date)
    $plu = $(Get-QADUser -Identity $USR).passwordLastSet
    $sd = ($($plu) -Split ' ')[0]
    $st = (($($plu) -Split ' ')[1] -split ':')[0,1]
    $cd = ($date -Split ' ')[0]
    $ct = ((($date -Split ' ')[1] -Split ':'))[0,1]


    ## Compare the current date/time with the .PasswordLastSet time to verify success
    if($sd -eq $cd -and "$($st[0]):$($st)[1]" -eq "$($ct[0]):$($ct[1])"){
        Write-Host -r GREEN '
    Success!
    '
    }
    else{
        Write-Host -f CYAN "
    Current Date:              $($date)
    New Password Last Set:     $($plu)

    If the day+hour match, then you're good to go!

    If not, this is the last error collected by Windows:
    "
        Write-Host -f YELLOW "
    $($Error[0])
        "
    }

    Write-Host -f GREEN '
    Hit ENTER to exit.
    '

    ## Don't leave password sitting around
    if(Test-Path -Path $PSR){
        $pr = $(Get-Content $PSR | %{$_ -replace "(Set-QADUser -Identity $USR -UserPassword .*|$c)",'CYOC MACROSS MSG: PASSWORD ENTRY REDACTED'})
        Set-Content -Path $PSR -Value $pr
    }
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b)
    Remove-Variable -Force a0,a1,b,c

    Read-Host
}
}



function stringz($f=$(getFile),[switch]$w=$false){   #mp
    <#
    ||shorthelp||
    Extract ASCII characters from binary files. Call this function without parameters to open a nav window and select a file.
    You can also send a filepath as parameter one. If you do not want to keep the output text file, use the -w option.
    Usage:
        stringz [-f FILEPATH] [-w WRITE_TO_FILE]

    ||longhelp||
    For those deployments when "strings" isn't a default Windows utility.

    Send a filepath, or let the function open a dialog for you.

    ||examples||
    Dump strings from an executable to your screen:

        stringz <filepath>

    Use -w to write outputs to a file on your desktop:

        strings <filepath> -w

    #>
    $stringlist = @()
    $n = 0

    if($f -and $f -ne ''){
        Get-Content $f | %{
            if( !($_ -cMatch $dyrl_ASCII)){
                if($w){
                    $n++
                    Write-Host "  Extracting line $n to stringz.txt..."
                    $_ | Out-File "$dyrl_SKYFOLDER\stringz.txt" -Append
                }
                else{
                    $stringlist += $_
                }
            }
        }

        if($stringlist.length -gt 0){
            Return $stringlist
        }
        elseif($n -gt 0){
            Get-Content "$dyrl_SKYFOLDER\stringz.txt"
            Write-Host "
            Do you want to delete $dyrl_SKYFOLDER\stringz.txt? " -NoNewline;
            $z = Read-Host
            if( $z -eq 'y'){
                Remove-Item -Path "$dyrl_SKYFOLDER\stringz.txt"
            }
        }
    }
}



function getHash(){   #mp
    <#
    ||shorthelp||
    getHash [-f FILEPATH_OR_STRING] [-a  md5|sha256] [-s HASH_A_STRING]

    ||longhelp||
    Get an MD5 or SHA256 (default) hash of a file. Use the CertUtil and
    .NET methods so powershell v5 won't freak out.
    
    Use -s to hash a string instead (This option only returns a SHA256 hash).

    ||examples||
    Usage:

        $md5 = getHash $filepath md5
        $sha256 = getHash $filepath
        $hashed_string = getHash 'my string of text' -s

    #>
    param(
        [Parameter(Mandatory)]
        [string]$fstring,
        [string]$alg='sha256',
        [switch]$str
    )

    $type = @('md5','sha256')
    if($str){
        $io = [IO.MemoryStream]::New([byte[]][char[]]$fstring)
        $s = [System.Security.Cryptography.sha256]::Create()
        $hash = $s.computehash($io)
        $h = (($hash|%{$_.toString("x2")}) -join '').toUpper()
    }
    elseif( (Test-Path -Path $fstring) -and $alg -in $type){
        $h = (CertUtil -hashfile $fstring $alg)[1]
    }
    Return $h
}



function errLog(){   #mp
    <#
    ||shorthelp||
    Write messages to MACROSS's log folder. Timestamps are added automatically. You can
    read these logs by typing 'debug' into MACROSS's main menu.
    Usage:
        errLog [-l INFO|WARN|ERROR] [-t TEXT_STRING] [-e EXTRA_TEXT_FIELD]

    ||longhelp||
    Have your diamonds write to MACROSS logs for troubleshooting/auditing. The default location
    is $dyrl_LOG, wherever you've specified that location to be in the macross.conf file. The current
    timestamp automatically gets written to the log, you don't need to send it. The first param,
    "-level", is required, and should indicate the type of log (ERROR, INFO, etc.). You can send
    the actual log message as "-text", and any additional fields you need to add should be sent
    TAB-SEPARATED as "-extra".

    These logs are written encoded to avoid weirdness, but can be viewed from MACROSS's debug screen.

    ||examples||
    errLog $param1 $param2 $param3

    errLog 'WARN' $error_count "$USR/$SCRIPT failed to perform $TASK"
    errLog 'INFO' 'Something else happened blah blah.'
    #>
    Param(
        [Parameter(Mandatory=$true)]$level,
        [Parameter(Mandatory=$false)]$text,
        [Parameter(Mandatory=$false)]$extra,
        [switch]$forward=$false
    )
    if($dyrl_LOG -ne 'none' -and (Test-Path $dyrl_LOG)){
        [string]$log = "$(Get-Date -Format 'yyyy-MM-dd')" + '.txt'      ## Create the log filename
        [string]$local = $(Get-Date -Format 'yyyy-MM-dd hh:mm:ss')      ## First field is the timestamp
        $msg = "MACROSS/$($env:COMPUTERNAME)/$USR"                       ## Specify the source
        $d = "`t"                                                       ## Delimiter

        if($forward){
            ## Use UTC for sending logs to QRadar
            $utc = "$((Get-Date).toUniversalTime() | Get-Date -Format 'yyyy/MM/dd hh:mm:ss:ms+0000')"
        }

        if($extra){
            $msg = "$msg$d$level$d$text"
            $extra -Split $d | %{
                $msg = "$msg$d$_"
            }
        }
        elseif($text){
            $msg = "$msg$d$level$d$text"
        }
        else{
            $msg = "$msg$d$level"
        }
        $menc = [string]$(reString -e "$local$d$msg")

        ## The second param for StreamWriter is "-Append"; set to $true
        $newout = [System.IO.StreamWriter]::New("$dyrl_LOG\$log",$true)
        $newout.WriteLine("$menc"); $newout.Close()
    }

}

function noBOM(){   #mp
    <#
    ||shorthelp||
    noBOM [-t TEXT_TO_WRITE] [-f OUTPUT_FILEPATH] [-m WRITE_MULTILINE]
        [-n APPEND_TO_NEXT LINE] [-a APPEND_TO_EOF]

    ||longhelp||
    Powershell doesn't just let you write text using "Out-File" or ">>" to a new file,
    you have to get extra-wordy to tell it specifically not to encode it with BOM.
    Good luck getting anything else to read that file cleanly otherwise.

    Use -a to append to the end of a file (if the last line contains text, it will
    begin writing at the end of that line). Use -n to append to the very next line
    instead.

    ||examples||
    noBOM -t $some_text -f $output_file

    #>
    param(
        [Parameter(Mandatory=$true)]    ## Content to write
        $to_write,
        [Parameter(Mandatory=$true)]    ## Output filepath
        [string]$file,
        [switch]$multiline,             ## Preserve your newline/carriage return
        [switch]$next,                  ## Write to existing file's next empty line
        [switch]$append                 ## Append to the end of an existing file (won't add new line)
    )
    if($multiline){
        if($next){
            [IO.File]::AppendAllLines("$file",@(""))
            [IO.File]::AppendAllLines("$file","$to_write")
        }
        elseif($append){ [IO.File]::AppendAllLines("$file","$to_write")}
        else{ [IO.File]::WriteAllLines("$file","$to_write") }
    }
    elseif($next){ [IO.File]::AppendAllText("$file","`n$to_write") }
    elseif($append){ [IO.File]::AppendAllText("$file","$to_write") }
    else{ [IO.File]::WriteAllText("$file","$to_write") }
}

## Take a single large block of text and break it into multiple lines. Supply a $filename,
## the $block to be split, and the max line length ($maxlen). The output is a multi-line file
## written to the $dyrl_OUTFILES folder. Requires the blockwriter.py plugin.
function blockwriter(){
    param(
        [Parameter(Mandatory=$true)]
        [string]$filename,
        [Parameter(Mandatory=$true)]
        [string]$block,
        [Parameter(Mandatory=$true)]
        [int]$maxlen,
        [string]$plugin = 'blockwriter.py',
        [string]$initial = $null
    )
    function p_([switch]$c){
        if($c -and ! $initial){pyENV -c}
        elseif(! $initial){pyENV}
    }
    $plugin = "$dyrl_PLUGINS\$plugin"
    $c='';$i=0
    $block -Split '' | %{
        $c = "$c$_"
        $i++
        if($i -gt $maxlen){
            $i = 0
            $c = "$c`n"
        }
    }
    noBOM -f "$dyrl_OUTFILES\$filename" -t $($c -Join '') -m

}

## Make sure the GBIO folder is cleaned out:
## this is where .mac7 files are written so python can
## read powershell outputs
function cleanGBIO([switch]$s=$false){
    ## Clear $PROTOCULTURE
    if($s){ Remove-Item -Force "$($dyrl_PG[1])\PROTOCULTURE.mac7"}
    ## Make sure the GBIO directory is clean
    else{
        $gb = Get-ChildItem "$($dyrl_PG[1])\*.mac7"
        if($gb){
            $gb | %{
                try{ Remove-Item -Force $_.fullname }
                catch{
                    $exc = $($_.name) + '!'
                    $e = " Could not delete $exc"
                    errLog ERROR "$USR/MACROSS" "$e ($dyrl_HN0)"
                    w $e c
                }
            }
        }
    }
}


function kawamori(){   #mp
    <#
    ||shorthelp||
    kawamori [-c YOUR_SCRIPTNAME] [-v PROTOCULTURE_VALUE] [-f OUTPUT_FILENAME] [-d DEPTH]
        [-s SPIRITIA_VALUE]

    ||longhelp||
    Read/write your $PROTOCULTURE results to a json file (PROTOCULTURE.mac7) so that python
    & powershell diamonds can share data. This file is written to a the local folder
    'corefuncs\pycross\garbage_io', which MACROSS regularly empties. You only need to send the 
    name of your diamond as -c and your values as -v. If you are writing a large set of
    json data, you change the depth using -d (the default depth is 10).

    If you want to write something other than the default json structure shown below, send an 
    alternate filename as -f, and your data will be written as a string to another .mac7 file.
    Whatever the receiving diamond is, it needs to be coded to retrieve your specific file
    from the path macross.OUTFILES, and to know that the file contains a single string!

    The .mac7 files are encoded in utf8.

    REQUIRED TO READ: Send the name of your diamond as -c. If there is a python PROTOCULTURE
    file, it will return a hashtable containing indexes for "caller", "protoculture", "result"
    and "spiritia".

    REQUIRED TO WRITE:  Your diamond name, as well as the value you want written to that file 
    ($val1). The default file will be PROTOCULTURE.mac7, written as a json string:

        { $CALLER : { "protoculture":$PROTOCULTURE, "result": $results, "spiritia": $s } }

    If you are providing a large json dataset, the default writing depth is 10, but you can
    increase it if necessary using the -d parameter.

    If you need something other than this format and want to use a method outside of the
    valkyrie functions, you can provide an alternative filename as the -f parameter to name the
    file anything but "PROTOCULTURE", and write whatever type of data you need to it instead.
    (The ".mac7" extension is still applied). Note that by using -f, kawamori does not format your
    -v $value at all, it will only write the value to the file, so formatting needs to be
    performed by your diamond.

    If the PROTOCULTURE.mac7 file already exists, this function will check to see if the "result"
    key contains a non-empty value. If so, it assumes this is a response from python to a query
    from powershell, and sets that "result" value as $PROTOCULTURE.

    If "result" is empty, kawamori then assumes you are responding to a python diamond's request,
    and will write your $value to the "result" key of the json. Otherwise, $value gets written to
    the "protoculture" key in a new PROTOCULTURE.mac7 file.

    ||examples||
    if( $hk_LATTS.$CALLER.lang -eq 'python' ){

        # Write the results of the python diamond's request
        kawamori 'MyScriptName' $value

        # Include an alternative "spiritia" value
        kawamorei -c 'MyScriptName' -v $value -s $spiritia_value

        # Or you can just write all the results the diamond found to a string value by
        # using -f to specify a filename other than "PROTOCULTURE" (it will retain the 
        # ".mac7" file extension).
        foreach($line in $eval){
            kawamori -c 'MyScriptName' -v $line -f 'myResultFile'
        }

    }

    ...and then your python diamond can do whatever with it:
        json.dumps(open('PATH\\PROTOCULTURE.mac7).read())
        open('PATH\\myResultFile.mac7').read()

    The file outputs are written with the extension "*.mac7" (including your custom filenames)
    to ensure regular cleanup (see the "cleanGBIO" function elsewhere in this file).

    *otaku note: Shoji Kawamori developed the original Macross series (my favorite anime), 
    among other classics like "Vision of Escaflowne".

    ||examples||


    #>
    Param(
        [Parameter(Mandatory)]
        [string]$caller_,
        $v,
        $s='',
        [string]$f=$null,
        [int]$d=10
    )

    $proto_file = "$($dyrl_PG[1])\PROTOCULTURE.mac7"

    function em_(){ errMsg -m "$($error[0])" -c r -f 'MACROSS.kawamori' }
    function w2f_($w,$file=$proto_file){ 
        #if($w -and ($w -isNot [System.String] -and $v -isNot [System.Int32])){
        #if($w -is [System.Collections.IDictionary] -or $w -is [System.Collections.IENumerable]){
        if($w.caller){
            try{ noBOM -f $file -t "$($w | ConvertTo-Json -Depth $d)" }
            catch{ em_ }
        }
        else{
            try{ noBOM -f $file -t "$w" -encoding 'utf8'}
            catch{ em_ }
        }
        if( ! (Test-Path -Path "$file") ){
            errLog ERROR "$USR/$caller_" "Failed to write $file file during macross.valkyrie operation ($dyrl_HN0)"
        }
    }

    if(! $v -and $s -eq '' -and (Test-Path $proto_file)){
        Return $(Get-Content -raw $proto_file | ConvertFrom-Json)
    }

    if($f){
        $f = "$($dyrl_PG[1])\$f" + '.mac7'  ## Use custom filename
        w2f_ $v.toString() -f $f
    }
    else{
        if((Test-Path $proto_file) -and ($caller_ -eq $CALLER)){
            $j = Get-Content -raw $proto_file | ConvertFrom-Json
            if($j -and -not $j.caller){ $j = cfJson $j }
            $j.spiritia = $s
            if($j.result -ne 'WAITING'){ $Global:PROTOCULTURE = $j.protoculture }
            else{ $j.result = $v }
        }
        else{
            $j = @{}
            $j.caller = $caller_
            $j.protoculture = $v
            $j.result = 'PS_'
            $j.spiritia = $s
        }

        
        w2f_ $j
    }

}

function dfList($t){    #mp
    <#
    ||shorthelp||
    dfList [-t TOOLNAME]

    ||longhelp||
    Get a full listing of *all* available tools and their [macross] attributes

    ||examples||
    Call from the main menu with debug:

        debug dfList

    Get the details for a specific diamondwhile in debugging mode:

        dfList <tool name>

    #>
    if($t){ $dyrl_LATTS[$t].toolInfo() }
    else{ $dyrl_LATTS.keys | %{ $dyrl_LATTS[$_].toolInfo()} }
}

## Byte conversions
function byter($1,$2=0,[switch]$s,[switch]$b){
    if($b){[byte[]]$bytes = $($1 -split '' | ?{$_ -ne ''} | %{ord $_}); Return $bytes}
    elseif($s){ $1 = $1 | ConvertTo-SecureString }
    Return $([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($1)))
}


## Use this for ignoring non-ascii chars when parsing files
$Global:dyrl_ASCII = "[^\x00-\x7F]"

function sheetz(){   #mp
    <#
    ||shorthelp||
    Output results to an excel worksheet. Specify the name of your spreadsheet with
    -o; -v is the values you're writing, separated by commas. -r is the row to start
    writing in (default is 1; if you are adding values to an existing sheet, set this
    to the next empty row). Use -h for comma-separated column names, OR if you are
    editing an existing sheet/don't need column headers, you can send the number of
    columns you require. You can colorize text by adding a 'color~' to the beginning
    of any field in the first parameter's comma-separated list, or colorize the cell
    by adding 'cellColor~textColor~' to the value.
    Usage:
        sheetz [-o FILENAME] [-v VALUE1,VALUE2...] [-r ROW_NUMBER] [-h COLUMN1,COLUMN2...]
            [-s SHEET_NAME1,SHEET_NAME2...]

    ||longhelp||
    Output diamondvalues to an Excel spreadsheet on user's desktop

    (This is very simplistic at the moment; the goal is to eventually make more useful
    spreadsheets when simple CSV files aren't good enough.)

    Parameters for this function:
    -o = (req'd) the name of the output file
        -will always read/write to your desktop
        -do NOT include an extension, sheetz sets it automatically
    -v = (req'd) cell values, comma-separated. If your cell values contain commas,
        this function is coded to replace the string "<comma>" with a ","; you should
        replace all your individual cell value commas with that string to ensure values
        get written to the correct column/row
    -r = (optional) the starting row number to write to (default is 1)
    -h = (optional) column values, OR the number of columns you are writing across
    -s = (optional) names for individual sheets/tabs, comma-separated.

    If only -o and -v are sent, this function will separate -v values and write them as a
    list into column A.

    ####### USING MULTIPLE SHEETS WITHIN A WORKBOOK ######

    Tto write values across multiple sheets/tabs, send a **list** of comma-separated values
    in -v instead of a string. For example, to write cells on two tabs, all the cell values
    for each tab should be comma-separated strings within the list:

        -v @(
            'station001,windows 10<comma> licensed,192.168.1.100',
            'station001,patched on 12/1/2020,online'
        )

    ..and so on. The same method must be used in -h if you are using column headers OR specifying
    the number of columns:

        -h @(
            'HOSTNAME,OS,IP',
            3
        )

    In the above -h, the first sheet will have the headers HOSTNAME, OS and IP for columns
    A, B and C; the second sheet will simply write across the first 3 columns without naming
    them.

    The -s option for naming each individual sheet is optional, but if you use it, it must
    include the exact amount of names (comma-separated) as there are items in your -v and -h
    lists, and make sure they are arranged **in order** to match the first-thru-last items
    in your -v and -h lists!

    ###### UUPDATING EXISTING WORKBOOKS ######

    If you're adding values to an existing sheet, the -r parameter lets you specify which
    row to start in. For example, if you know the next empty row is 200, send 200 as a 3rd
    parameter.

    If you send a NUMBER as the -h parameter, it tells this function how many values to write
    horizontally from parameter -v, before it shifts to the next row and continues writing
    cells.

    If you send comma-separated strings as param -h, this function will write those values as
    the column headers in the worksheet, and then begin writing the values from param -v into
    the appropriate row/columns.

    ###### FORMATTING ######

    TO COLORIZE TEXT:
    Send the first letter of your color choice (red, green, blue, yellow, cyan, gray, white,
    "k" for black or "gr" for gray) with a  "~" symbol between your color and the value, i.e.
    "r~RESULT FAILED!" will write "RESULT FAILED!" in red text.

    TO COLORIZE CELLS:
    Add a color letter (same choices as above) AND the color you want for text, separated with "~"
    like so:

        "k~r~RESULT FAILED"

    The above will make the cell black with red text. You must send BOTH a cell color AND a
    text color to colorize cells.

    ||examples||
    EXAMPLE 1

        $vals1 = 'host 10,host 24,host 13,host 3'
        sheetz -o 'myoutput' -v $vals

    The above example will write out the hosts in a simple list to 'myoutput.xlsx' in cells
    A1 - A4

    EXAMPLE 2

        $hosts = 'host 1,b~w~windows,11,192.168.10.10,host2,linux,r~kali,192.168.10.11'
        $headers = 'HOST,OS,VER,IP'
        sheetz -o 'myoutput' -v $hosts -r 5 -h $headers

    The above will create (or open) myoutput.xlsx, and then writes 'HOST' to cell A5, 'OS' to B5,
    'VER' to C5, and 'IP' to D5. Next it will go through all the comma-separated values in param 2,
    writing values into the next row until it reaches column D, then jump to the next row back at
    column A. And in this example, cell B6 (windows) will be blue with white text while cell C7
    (kali) will be in red text.

                         A         B       C         D
            row 5      HOST       OS      VER        IP
            row 6      host 1   windows   11    192.168.10.10
            row 7      host 2   linux     kali  192.168.10.11

    Make sure your diamond is sending your -v values IN ORDER, otherwise they'll get
    written to the wrong cells! Also, if you're adding values to an existing sheet, don't send the
    headers, sheetz will automatically start writing to the next empty row (or you can specify a row
    in parameter -r, and the number of columns being written, in this case 4 columns (A-D).

    EXAMPLE 3

    Sometimes you don't need headers. You could set -h to 6 if you just need to specify
    that there should be 6 columns (A-F). If $patchInfo contains hosts and patch dates:

        sheetz -o 'patch report' -v $patchInfo -r 1 -c 6

                    A         B        C         D                 E           F
        row 1      host 1   windows   11    192.168.10.10      patched     1/31/2020
        row 2      host 2   windows   10    192.168.10.11      unpatched



    #>
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
    param(
        [Parameter(Mandatory=$true)]
        [string]$o,
        [Parameter(Mandatory=$true)]
        [array]$v,
        [int]$r=1,
        [array]$h,
        [string]$s='Sheet 1'
    )

    if(! $SHEETZ){ errMsg -f 'MACROSS.sheetz' "Microsoft Excel is not installed!" }

    $colors = @{
        'r~' = 255 + (1*256) + (1*256*256);
        'g~' = 204 + (255*256) + (204*256*256);
        'b~' = (255*256*256);
        'w~' = 255 + (255*256) + (255*256*256);
        'gr~' = 128 + (128*256) + (128*256*256);
        'y~' = 255 + (255*256);
        'c~' = (255*256) + (255*256*256);
        'k~' = 0
    }

    $c = 1  ## Start in column A

    ## Collect the columns info, make sure it's an array
    if($h -and $h.getType().Name -eq 'String'){
        $h = @($h)
    }
    ## Collect cell values, make sure it's an array
    if($v.getType().Name -eq 'String'){
        $v = @($v)
    }
    ## Collect sheet names, make sure it's an array
    $snames = $s -Split ','

    $values_table = @{}

    ## No point continuing if mismatched values were sent...
    if($h -and ($h.count -ne $v.count)){
        $errmsg = "The -h and -v counts do not match; could not write $o.xlsx"
        errMsg $errms -c 'RED' -f sheetz
        w "`n Hit ENTER to close`n" g
        Read-Host
        Return
    }

    ## Set the cell value placement based on provided headers and sheet names (if any)
    0..$($v.count-1) | %{
        $vlist = $v[$_].Trim()
        if($snames.count -ne $v.count){ $skey = "Sheet $($_+1)"}
        else{ $skey = "$($snames[$_])"}
        if($h){ $hd = $h[$_].Trim() }
        else{ $hd = $null }
        $values_table.add($skey,@($vlist,$hd))
    }

    ## Dump the original values to free up resources
    @('h','s','v','hd','sn','skey','vlist') | %{
        try{ Remove-Variable $_ }
        catch{ $null }
    }

    $outpath = "$dyrl_OUTFILES\$o.xlsx"

    # Add reference to the Microsoft Excel assembly
    Add-Type -AssemblyName Microsoft.Office.Interop.Excel


    # Create a new Excel application
    $excel = New-Object -ComObject Excel.Application

    # Make Excel visible (optional)
    $excel.Visible = $true

    # Create a new workbook or load an existing one
    if(Test-Path $outpath){
        $edit = $true
        $workbook = $excel.Workbooks.Open($outpath)
    }
    else{
        $edit = $false
        $workbook = $excel.Workbooks.Add()
    }


    # Start creating new worksheets or loading existing sheets in order, then write headers+values to cells
    foreach($newsheet in $values_table.keys){
    $startrow = $r
    if($edit){
        $current_sheets = New-Object System.Collections.Arraylist
        $workbook.sheets | %{
            $current_sheets.add($_.name) | Out-Null
        }
        if($newsheet -notIn $current_sheets){
            $worksheet = $workbook.Worksheets.Add()
            $worksheet.Name = "$newsheet"
        }
        rv current_sheets
    }
    else{
        $worksheet = $workbook.Worksheets.Add()
        $worksheet.Name = "$newsheet"
    }

    $worksheet = $workbook.Worksheets.Item("$newsheet")

    $cell_values = "$($values_table.$newsheet[0])" -Split ','


    # Write values to cells; if no $h values were passed, just write $cell_values as a list in column A
    if($values_table.$newsheet[1]){
        function columnVals_($rr,$cc,$count){
            Foreach($v1 in $cell_values){
                $v1 = $v1 -replace '<comma>',','
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
                if($count -gt $column_ct){                    ## stop shifting if all columns have been written
                    $rr++                                     ## shift to the next row
                    $cc = 1                                   ## go back to column A
                    $count = 1                                ## reset column tracker
                }
            }
        }

        ## Determine headers or number of columns
        $toprow = $values_table.$newsheet[1]
        if($toprow -Match "[a-zA-Z]"){
            $column_nm = $toprow -Split ','
            $column_ct = $column_nm.count
        }
        elseif($toprow -Match "^\d+$"){
            $column_nm = $null
            $column_ct = [int]$toprow
        }
        else{
            errMsg 'Incorrect header value; cannot write to Excel' -c RED -f sheetz
        }


        if($column_nm){
            Foreach($v2 in $column_nm){
                $worksheet.Cells.Item($startrow, $c).Value2 = $v2   ## Write all the initial column values in row 1
                $c++                                                ## shift to next column
            }
            $c = 1                                                  ## go back to column A
            $startrow++                                             ## shift to next row
            if($startrow -eq 2){
                $excel.Rows.Item("$startrow`:$startrow").Select()   ## Select 2nd row for next command
                $excel.ActiveWindow.FreezePanes = $true             ## Freeze the top row
            }

            columnVals_ $startrow $c 1
        }
        else{
            columnVals_ $startrow 1 1
        }

    }
    else{
        Foreach($v1 in $cell_values){
            $v1 = $v1 -replace '<comma>',','
            if($v1 -Match "^[a-z]+~[a-z]+~"){
                $shade_cell = $v1 -replace "~[a-z]+~",'~' -replace "~.+",'~'
                $shade_text = $v1 -replace "^[a-z]+~?" -replace "~.+",'~'
                $v1 = $v1 -replace "^[a-z]+~[a-z]+~"
            }
            elseif($v1 -Match "^[a-z]~"){
                $shade_text = $v1 -replace "~.+",'~'
                $v1 = $v1 -replace "^[a-z]~"
            }

            $worksheet.Cells.Item($startrow, $c).Value2 = $v1     ## Write values as a list in column A

            if($shade_cell){
                $worksheet.Cells.Item($startrow, $cc).Interior.Color = $colors[$shade_cell]
            }
            if($shade_text){
                $worksheet.Cells.Item($startrow, $cc).Font.Color = $colors[$shade_text]
            }

            Remove-Variable shade_*

            $startrow++
        }
    }
    }


    #$worksheet.Cells.Item(4, 3).Value2 = 'TEST'
    #$worksheet.Cells.Item(4, 4).Value2 = 'SUCCESSFUL'



    # Save the workbook (optional)
    if( Test-Path $outpath ){
        $workbook.Save()
    }
    else{
        $workbook.SaveAs($outpath)
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


function reString($t,[switch]$hex=$false,[switch]$e=$false){   #mp
    <#
    ||shorthelp||
    Decode base64 and hex values to plaintext in the global variable `$dyrl_PT; encode
    plaintext to hex or base64
    Usage:
        reString [-t STRING] [-h USE_HEXADECIMAL] [-e ENCODE_PLAINTEXT]

    ||longhelp||
    Deobfuscate your encoded value ($t), plaintext gets saved as $dyrl_PT
    Default is Base64, change to hexadecimal with -h.
    Encode your plaintext value ($t) by using -e.

    -DO NOT USE ENCODING TO HIDE USERNAMES/PASSWORDS/KEYS or other sensitive info! This
    is only intended to prevent regular users from seeing your filepaths/URLs, etc.,
    and avoiding automated keyword scanners.

    The reason it always writes to $dyrl_PT instead of just returning a value to your diamond
    is to ensure that decoded plaintext gets wiped from memory every time the MACROSS menu loads.
    Yes, I'm one of those paranoid types, but I can only control my code, not yours!

    This function can also be used by your diamonds for normal decoding tasks, it isn't
    limited to MACROSS' startup.

    ||examples||
    -If you need presistence, you MUST set your new variable to $dyrl_PT **before** this
      function gets called again:

        reString $base64string
        $plaintext = $dyrl_PT

    -To decode a hexadecimal string, send the hex and use -h (your hex string can include
      spaces and/or "0x" tags, or neither):

        reString "0x746869732069 730x20 61 200x740x650x7374" -h
        $plaintext = $dyrl_PT

    -If you want to ENCODE plaintext, call this function with your plaintext and -e.
      This mode does NOT write to $dyrl_PT!

        $b64 = reString $plaintext -e
        $hex = reString $plaintext -h -e



    #>
    if($dyrl_PT){Remove-Variable dyrl_PT -Scope Global}
    if($e){
        if($hex){$a = ([System.Text.Encoding]::UTF8.GetBytes($t) | Foreach{$_.ToString("X2")}) -Join ''}
        else{$a = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($t))}
        Return $a
    }
    elseif($hex){
        $a = $t -replace "0x"; $a = $a -replace " "
        $a = $(-join ($a -Split '(..)' | ?{$_ -ne ''} | %{[char][convert]::ToUInt32($_,16)}))
    }
    else{
        $a = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($t))
    }

    $Global:dyrl_PT = $a


}

function urlEnc($str,$alt='%20'){   #mp
    <#
    ||shorthelp||
    Encode strings for passing as a URL to APIs.
    Usage:
        urlEnc [-s STRING] [-a ALTERNATE WHITESPACE ENCODING]

    ||longhelp||
    Converts a plaintext string to a URL-encoded string that can be passed to web APIs.
    The default encoding for whitespace is "%20", but you can send an alternate if required.

    ||examples||

    # Standard usage
    $site = 'http://example.com/api?q=msg+where+sockets=(1.2.3.4:8443)&&time=[some time frame]'
    $api_call = urlEnc $site

    # Alternate usage - replace whitespace with a "+" character
    $api_call = urlEnc $site -a "+"


    #>
    Return $($str -replace "\s",$alt `
            -replace "'",'%27' `
            -replace ":",'%3A' `
            -replace "\[",'%5B' `
            -replace "\]",'%5D' `
            -replace "\(",'%28' `
            -replace "\)",'%29' `
            -replace "=",'%3D' `
            -replace "&",'%26')
}


function decodePdf($filepath,[switch]$preserve,[switch]$split){   #mp
    <#
    ||shorthelp||
    decodePdf [-f PATH_TO_FILE] [-preserve (Preserve layout)] [-s (return a list of lines)]

    ||longhelp||
    Returns decoded plaintext from PDF documents. The -p option helps
    preserve decoded text with minimal breakage (removed lines, conjoined
    words, etc.). The default behavior just pulls out blobs of text, but
    you can use -s to get back a list of text lines, which also
    removes all empty lines.

    ||examples||

        decodePdf "C:\Users\Me\Documents\Intel.pdf" -p


    #>

    $emsg = "Failed to extract text from $filepath"
    $filename = $filepath -replace "^.+\\" -replace "\.\w+$"
    $readfrom = "$dyrl_TMP\decoded-pdf-$filename.mac7"
    if($preserve){ $arg = "$("$dyrl_PLUGINS\pdfdecoder.py") $filepath $filename 1" }
    else{ $args = "$("$dyrl_PLUGINS\pdfdecoder.py") $filepath $filename" }
    launcher -p -c $args
    if($split){ $text = uniStrip $(Get-Content $readfrom | ?{$_.Trim() -ne ""}) }
    else{ $text = $(uniStrip $(Get-Content -Raw $readfrom)) }
    if($text){
        Remove-Item $readfrom
        Return $text
    }
    else{
        errLog ERROR "MACROSS.decodePdf" "Failed to extract text from $filepath"
        Return ''
    }
}


function getFile($filter='all',$opendir="H:\",[switch]$directory=$false){   #mp
    <#
    ||shorthelp||
    Open a dialog window to let analysts select a file from any local/network location
    Usage:
        $file = getFile -f [all|csv|doc|dox|exe|msg|mso|pdf|ppt|scr|txt|web|xls|zip]
        $folder = getFile -d

    ||longhelp||
    This opens a dialog window so the user can specify a filepath to whatever.

    OPTIONS
    -o = Set the root directory to search in (default is "H:\")
    -d = Use to limit user selections to a folder path
    -f = Limit user selections to type of file
        'all' = All filetypes (default)
        'csv' = Comma-separated value format
        'doc' = pdf, doc, docx, rtf files
        'dox' = Microsoft Word formats
        'exe' = Executables
        'ioc' = Common document types containing intel on IPs or URLs
        'msg' = Saved email messages
        'mso' = All common Microsoft Office formats
        'pdf' = pdf files
        'ppt' = Microsoft Powerpoint formats
        'scr' = Common script types
        'txt' = Plaintext .txt files
        'web' = htm, html, css, js, json, aspx, php files
        'xls' = Microsoft Excel formats
        'zip' = zip, gz, 7z, jar, rar files

        You can also send a file extension as a filter for custom file types,
        if necessary.

    ||examples||
    Ask user to specify any file:

        $file_to_read = getFile

    Ask user for specific types of file:

        $file_to_read = getFile -f txt
        $compressed_file = getFile -f zip

    Ask user to specify a folder:

        $folder = getFile -d

    #>
    $ft = @{
        'all'="All files|*.*; *.*";
        'csv'="Comma-Separated Document|*.csv; *.csv";
        'custom'="Custom Filetype|*.$filter; *.{filter}";
        'doc'="Document Types|*.docx; *.doc; *.rtf; *.pdf; *.xls; *.xlsx";
        'dox'="MS Word Doc|*.docx; *.doc";
        'exe'="Executables|*.exe; *.exe";
        'ioc'="Indicator dumps|*.xml;*.docx;*.xlsx;*.txt;*.csv;*.json;*.pdf;*.yara;;*.log";
        'msg'="Email message|*.msg; *.msg";
        'mso'="Microsoft Office|*.doc; *.docx; *.xls; *.xlsx; *.one; *.ppt; *.pptx; *.accdb; *.accde; *.ost; *.pst";
        'pdf'="Portable Document Format|*.pdf; *.pdf";
        'ppt'="MS Powerpoint|*.pptx; *.ppt";
        'scr'="Script files|*.ps1; *.psm; *.py; *.pyc; *.pyd; *.bat; *.lua; *.js";
        'txt'="Text file|*.txt; *.txt";
        'web'="Web Files|*.html; *.htm; *.css; *.js; *.aspx; *.php; *.json";
        'xls'="Excel Spreadsheet|.xlsx; *.xls";
        'zip'="Compressed|*.zip; *.rar; *.7z; *.tar; *.gz; *.jar"
    }

    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    if($directory){
        $f = New-Object System.Windows.Forms.FolderBrowserDialog
        $f.rootfolder = $opendir
        $f.Description = "Select a folder"
        $f.SelectedPath = $opendir

        if($f.ShowDialog() -eq "OK")
        {
            Return $f.SelectedPath
        }
    }
    else{
        $o = New-Object System.Windows.Forms.OpenFileDialog
        $o.InitialDirectory = $opendir
        if($filter -in $ft.keys){ $o.filter = $ft[$filter] }
        else{ $o.filter = $ft['custom'] }
        $o.ShowDialog() | Out-Null
        $o.filename
    }

}


function gerwalk(){  #mp
    <#
    ||shorthelp||
    gerwalk [-c 'ID or name for your key' <REQUIRED>] [-g <GENERATE A NEW KEY>]

    ||longhelp||
    This is MACROSS's key generator for protecting regularly accessed data or
    resources. To create a new key, provide any string as a key name, and use
    the -g option. An entry window will open for you to paste whatever value you
    need protected within MACROSS.

    To retrieve your key, supply the ID that MACROSS generated when you created
    the key. Keys are stored in MACROSS's corefuncs\resources folder.

    ||examples||

    ## Generate a new key and get an ID to use for retrieval:
        gerwalk 'give_me_a_key' -g
    ## Retrieve the key's value:
        $key = gerwalk <macross-id>

    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$cid,
        [switch]$gen
    )

    ## In a multi-user setup, you can store keys in a central location
    ## ($dyrl_CONTENT) where all validated users' diamonds can read them.
    ## Note that if there are local and central keys with the same ID,
    ## the central key takes priority.
    $checkrep = "$dyrl_CONTENT\$cid.ger"
    $assembled = "$dyrl_RESOURCES\$cid.ger"
    if((Test-Path -Path $checkrep)){
        $content_key = $checkrep
    }
    else{
        $content_key = $false
    }
    $assembler1 = mkList
    $assembler2 = mkList
    $il1 = $N_[1].count -1; $il2 = $N_[2].count -1
    if($gen){
        $alpha = (alphanum)[0]
        $tag = $($cid.substring(0,1))
        if($tag -notMatch "\w"){ $tag = 's'}
        $bid = reString -e $cid
        $hid = reString -e -h $cid
        $eid = "$tag$bid$hid" -replace "[+=/\.]"; $el = $eid.length
        while($el -lt 35){
            $al = Get-Random -min 0 -max 62
            $eid = "$($eid)$($alpha[$al])"; $el = $eid.length
        }
        $eid = "$($eid.substring(0,15))-$($eid.substring(15,20))"
        $of = "$dyrl_RESOURCES\$eid`.ger"
        $vn = @('kh','kt','sg')
        $vv = @('20232323205354415254204B455920232323',
            '202323232320454E44204B45592023232323',
            '534B594E4554204B455947454E')
        0..2 | %{
            reString -h $vv[$_]
            Set-Variable -Name $vn[$_] -Value $dyrl_PT
        }
        $rawmaterials = getBlox -t $sg -i 'Paste your inputs:'
        $n = 0
        foreach($c in ($rawmaterials.trim() -Split '' | ?{$_ -ne ''})){
            $mod = ($N_[1][$n]+2) * $N_[0]
            $assembler1.add($(([int](ord $c) * $mod))) | Out-Null
            if($n -eq $il1){ $n = 0 }
            else{ $n++ }
        }
        $n = 0
        foreach($c in $assembler1){
            $mod = ($N_[2][$n]+2) * $N_[0]
            $assembler2.add($([int]$c + $mod)) | Out-Null
            if($n -eq $il2){ $n = 0 }
            else{ $n++ }
        }
        if($n -eq 0){ $n = $il2 }
        else{ $n-- }
        #$h = [math]::truncate($assembler2.length / 4)
        $assembler2.reverse()
        $assembler2.insert(0,$n)

        $compacting = reString $($assembler2 -Join '.') -e
        $compacted = mkList
        $compacted.add($kh) | Out-Null
        foreach($comp in $compacting -Split "(.{12})" -ne ''){
            $compacted.add($comp) | Out-Null
        }
        $compacted.add($kt) | Out-Null

        $wr = "$($compacted -Join "`n")"
        noBOM -f $of -t $wr
        errLog INFO 'MACROSS.gerwalk' "Key $eid generated for $cid"
        w "SAVE THIS ID: $eid"
        w "Your diamond can now retrieve this value using`n`n`tgerwalk $eid`n`n"
        w "This key will no longer function if your macross.conf file gets deleted!" y
    }
    else{
        if($content_key -and (Test-Path $content_key)){
            $assembled = $content_key   ## Give preference to files in central storage, if any
        }
        if(! (Test-Path $assembled)){
            errLog ERROR 'MACROSS.gerwalk' "No key found for $cid"
            Return $false #"$cid does not exist!"
        }
        else{
            reString $((Get-Content $assembled | ?{$_ -notLike '*#*'}) -Join '').trim()
            $compacted = $dyrl_PT -Split '\.'

            $nc = [int]$compacted[0]; $n = $nc
            $compacted = $compacted[1..($compacted.count)]
            foreach($c in $compacted){
                $mod = ($N_[2][$n]+2) * $N_[0]
                $assembler1.add($([int]$c - $mod)) | Out-Null
                if($n -lt 1){ $n = $il2 }
                else{ $n-- }
            }
            $n = $nc
            foreach($c in $assembler1){
                $mod = ($N_[1][$n]+2) * $N_[0]
                $assembler2.add($(chr $([int]$c / $mod))) | Out-Null
                if($n -lt 1){ $n = $il1 }
                else{ $n-- }
            }
            $assembler2.reverse()
            Return $assembler2 -Join ''
        }
    }

}


## Open a dialog box to get large text entries
function getBlox(){ #mp
    <#
    ||shorthelp||
    getBlox [-t <TITLE> REQUIRED] [-i <INSTRUCTION> OPTIONAL]

    ||longhelp||
    When your diamondneeds users to enter a large block of text, this function
    opens a dialog box where users can type or paste those blocks.

    You must send a title with -t; The default instructions is
    "Use this entry form to add your input", but you can send a different
    instruction with the -i option.

    ||examples||

    $textblock = getBlox 'My Tool Needs Strings'
    $ip_list = getBlox 'My Tool Needs IPs' -i 'Only enter a list of IPs in this box:'


    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$title,
        [string]$instruction="--- Use this entry form to add your input ---"
    )
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $textEntry = New-Object System.Windows.Forms.Form
    $textEntry.Text = "$title"
    $textEntry.Font = [System.Drawing.Font]::New("Tahoma",9)
    $textEntry.Forecolor = 'WHITE'
    $textEntry.size = New-Object System.Drawing.Size(1000,550)
    $textEntry.BackColor = 'BLACK'
    $textEntry.StartPosition = 'CenterScreen'

    $boxMessage = New-Object System.Windows.Forms.Label
    $boxMessage.Location = New-Object System.Drawing.Point(10,15)
    $boxMessage.Size = New-Object System.Drawing.Size(980,45)
    $boxMessage.Font = [System.Drawing.Font]::New("Tahoma",10)
    $boxMessage.ForeColor = 'YELLOW'
    $boxMessage.Text = "$instruction"
    $textEntry.Controls.Add($boxMessage)

    $entryBlock = New-Object System.Windows.Forms.TextBox
    $entryBlock.Location = New-Object System.Drawing.Point(10,105)
    $entryBlock.Size = New-Object System.Drawing.Size(980,300)
    $entryBlock.Font = [System.Drawing.Font]::New("Tahoma",10)
    $entryBlock.Text = $null
    $entryBlock.MultiLine = $true
    $entryBlock.Scrollbars = 'Vertical'
    $textEntry.Controls.Add($entryBlock)

    $confirm = New-Object System.Windows.Forms.Button
    $confirm.Location = New-Object System.Drawing.Point(425,435)
    $confirm.Size = New-Object System.Drawing.Size(175,35)
    $confirm.ForeColor = 'YELLOW'
    $confirm.BackColor = 'BLUE'
    $confirm.Text = 'Confirm Entry'
    $textEntry.AcceptButton = $confirm
    $confirm.Add_Click({
        $Script:clicked = $true
        $Script:block = $entryBlock.Lines
        $textEntry.Close()
    })
    $textEntry.Controls.Add($confirm)

    $textEntry.TopMost = $true
    $t = $textEntry.ShowDialog()

    if($clicked){
        $b = $block
        Remove-Variable block,clicked -Scope Script
        Return $b
    }
}



## I can never remember how to convert in powershell, just rename it to match python
function ord(){   #mp
    <#
    ||shorthelp||
    Get the decimal value of a text character
    Usage:
        ord [char]

    ||longhelp||
    Convert a single string char to its decimal format.

    ||examples||
    Get the decimal representation of 'A':

        ord 'A'

    #>
    param( [string]$c )
    Return [char]"$c" -as [int]
}
function chr(){   #mp
    <#
    ||shorthelp||
    Get the text character of a decimal value
    Usage:
        chr [int]

    ||longhelp||
    Convert a decimal value into its string format

    ||examples||
    Convert 65 into the string char 'A':

        chr 65

    #>
    param( [int]$d )
    Return [char]$d
}



function houseKeeping($reports,$diamond){   #mp
    <#
    ||shorthelp||

        houseKeeping [-r PATH_TO_REPORTS] [-t YOUR_SCRIPTNAME]

    ||longhelp||
    Delete stale reports generated by various tools.

    This function lists all files in the $reports path you provide, and offers
    the choice to delete some, all, or none of the files. Make sure not to pass
    generic folders like 'Desktop' or 'Documents', giving users the opportunity
    to accidentally delete all their stuff!

        Param $reports = the filepath determined by the diamondthat calls this function,
        Param $diamond = your diamond's name

    ||examples||

    Review stale txt files in one location, & pdf files in another:

        houseKeeping -r "$filepath\*txt" -t MyScript
        housekeeping -r "$other_filepath\*pdf" -t MyScript


    #>
    function listFiles(){
        $Script:fpath = (Get-ChildItem -File -Path "$reports")
        $Script:fcount = $fpath.count
        $Script:flist = @()
        $b = 0
        Write-Host -f YELLOW "       EXISTING $diamond REPORTS

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
        sleep 1
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
                    sleep 1
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
                        sleep 1
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
    sleep 1

    try{ Remove-Variable -Force fpath }catch{ $null }
    try{ Remove-Variable -Force flist }catch{ $null }
}




