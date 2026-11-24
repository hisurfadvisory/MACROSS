## MACROSS added functionalities


function alphanum([switch]$hex=$false,$rand=0,[switch]$special=$false){    #mp
    <#
    ||shorthelp||
    alphanum [-h HEX CHARS] [-r STRING OF $r RANDOM CHARS] [-s INCLUDE SPECIAL CHARS WITH -r]

    ||longhelp||
    Returns a list of alphanumeric & special characters. Use -h to only
    return characters used in hexadecimal bytes. Use -r and a length to
    return a string of random alphanumeric characters; add -s to include
    the special characters too.

    Without -s, random strings are safe for filenames, URLs and CSV cells.
    With -s, they may contain characters that break those (* ? < > are
    illegal in Windows filenames; & + = break URLs; a leading = + @ is
    read as a formula by spreadsheets; $ ^ * ? + are regex operators, so
    use [regex]::Escape() before matching on them).

    Random strings use Get-Random, which is fine for test data but is not
    cryptographically secure; don't use them as real passwords or keys.

    Calling without any options:
    Index 0 is the lower-upper case alphabet and 0-9, while Index 1
    contains a string of special characters.

    ||examples||
    $hex_chars = alphanum -h            List of characters used in hexadecimal
    $random_string = alphanum -r 32     String of 32 random characters
    $random_string = alphanum -r 32 -s  String of 32 random characters, including specials
    $a = (alphanum)[0][0]               The letter 'a'
    $zero = (alphanum)[0][52]           The number '0'
    $nine = (alphanum)[0][61]           The number '9'
    $aa = (alphanum)[1][2]              The character '#'

    #>
    $an = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' -Split '' | ?{$_ -ne ''}
    $hc = '0123456789ABCDEF' -Split '' | ?{$_ -ne ''}
    $sc = '!@#$%^&*_?><+=' -Split '' | ?{$_ -ne ''}
    if($hex){ $an = $hc }
    elseif($rand -gt 0){
        if($special){ $an = $an + $sc }
        $na = @()
        1..$rand | %{$na += $an[$(Get-Random -min 0 -max $an.count)]}
        $an = $na -Join ''
    }
    else{ $an = @($an,$sc) }
    Return $an
}

function mkList([switch]$h){      #mp
    <#
    ||shorthelp||
    mkList [-h <return hashtable instead of array>]

    ||longhelp||
    I hate how wordy powershell & .NET are. Use this when you need a dynamic
    array for large datasets and can't use "@()". Use -h to create a hashtable
    instead.

    ||examples||

    $list = mkList
    [void]$list.add('abc 123')

    $dict = mkList -h
    $dict['index0'] = $value

    #>
    if($h){ Return New-Object System.Collections.Hashtable }
    else{ Return New-Object System.Collections.Arraylist }
}

## Pause the console to run powershell commands in a temporary shell
function runSomething(){
    cls
    w "`n`n  Pausing MACROSS: type" -i g
    w 'exit' -i y
    w 'to close your session and return to' g
    w " the tools menu.`n`n" g

    & (Get-Process -Id $PID).Path       ## same powershell edition MACROSS is running in

    skSanitize                          ## scrub anything sensitive typed in that shell
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
        gerwalk $Z -h
    }
    elseif($Z -Like "b64*"){
        $Z = $Z -replace "^b64 ?",''
        gerwalk $Z
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
    function hec_(){
        w  "`n Hit ENTER to continue." g
        Read-Host
    }
    if($1 -eq 'config'){splashBanner; runModify -a $(xEntry)}
    elseif($1 -eq 'dec'){cls;decodeSomething}
    elseif($1 -eq 'strings'){stringz -w; hec_}
    elseif($1 -eq 'phone'){yellowPages}
    elseif($1 -eq 'passw'){updatePass}
    elseif($1 -eq 'shell'){runSomething}
    elseif($1 -eq 'screens'){ 
        0..11 | %{
            cls
            minmay $_
            "$(' '*7)command:  minmay $_"
            sleep 2
        } 
    }
    elseif($1 -eq 'debug'){ 
        $def = returnDefault -b
        splashBanner; consoleDebug -c $def[0]
    }
    elseif($1 -eq 'proto'){
        if($PROTOCULTURE){ Remove-Variable -Force PROTOCULTURE -Scope Global }
        cleanGBIO -s
    }
    elseif($1 -eq 'newkey'){
        "`n`n"; startUp
        $n = Read-Host 'Enter a name for your key'
        $x = Read-Host 'Extra AD groups/users to grant (comma-separated, or ENTER for tier lists only)'
        $p = @($x -split ',' | %{ $_.Trim() } | ?{ $_ })
        try{ kawamori -c $n -g -m -p $p }
        catch{ w "$($_.Exception.Message)" y }
        hec_
    }
    elseif($1 -eq 'chats'){
        ## Review saved AI chats (.chat files anywhere under the outputs folder)
        screenResultsForm -chats
    }
    elseif($1 -eq 'enroll'){
        ## Let this account use shared keys without the passphrase from now on
        "`n`n"; startUp
        try{ kawamori -e }
        catch{ w "$($_.Exception.Message)" y }
        hec_
    }
    elseif($1 -eq 'keys'){
        ## Every protected key file (shared and personal), with owner and creation date
        try{ kawamori -list }
        catch{ w "$($_.Exception.Message)" y; hec_ }
    }
    elseif($1 -eq 'pydev'){
        ## Interactive python with the MACROSS environment loaded ("import macross")
        startUp
        if(-not (pyGate_ 'pydev')){ Return }
        try{ errLog INFO 'MACROSS.debug' "pydev opened by $USR on $dyrl_HN0" }catch{ }
        pyATTS; macrossMirror -n $N_
        splashBanner
        try{
            if($MONTY){ & $dyrl_PYCROSS }
            elseif($LIFEOFBRIAN){ py }
            else{ w 'Python is not installed.' y; Read-Host }
        }
        finally{ macrossMirror -c }
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

## Python needs to warp spacetime to restore defaults in powershell
function spaceFold(){
    $Global:ErrorActionPreference = 'SilentlyContinue'
    $Global:dyrl_CONF = @{};
    $dd = $env:MACONF -Split ';'
    $ss = $env:TEMPENV -Split ';'; $snn = $ss[4] -Split ','
    foreach($d in $dd){
        $Global:dyrl_CONF.Add($(($d -Split '::')[0]),$(($d -Split '::')[1]))
    }
    $Global:dyrl_MACROSS=$ss[0]; $Global:dyrl_OUTFILES=$ss[1]
    $Global:dyrl_PYLIB = "$dyrl_MACROSS\corefuncs\pycross"
    $Global:dyrl_RESOURCES = "$dyrl_MACROSS\corefuncs\resources"
    $Global:dyrl_PLUGINS = "$dyrl_MACROSS\corefuncs\plugins"
    $Global:dyrl_CONTENT=$ss[2]; $Global:dyrl_LOG=$ss[3];
    $Global:N_=@([int64]$snn[0],$([int[]](($snn[1] -split '') -ne '')),$([int[]](($snn[2] -split '') -ne '')));
    $Global:USR=$ss[5]; $Global:dyrl_TMP=$ss[6]
    $Global:ROBOTECH = ($ss[7] -eq 'T'); $Global:dyrl_OPT1 = ($ss[8] -eq 'T')
    $Global:dyrl_DIAMONDS="$dyrl_MACROSS\diamonds"
    $Global:dyrl_PG=@("$dyrl_PYLIB","$dyrl_PYLIB\gbio")
    $Global:dyrl_LATTS=(gc "$($dyrl_PG[1])\LATTS.vf1" | ConvertFrom-Json)
    $Global:PROTOCULTURE=(gc "$($dyrl_PG[1])\PROTOCULTURE.vf1" | ConvertFrom-Json).target
}

## $true unless the admin turned debug restriction off in the config ('dbg' -> 'bl0')
function dbgRestricted_(){
    if(-not $dyrl_CONF){ startUp }
    if($dyrl_CONF -and $dyrl_CONF.bl0){ gerwalk $dyrl_CONF.bl0; Return ($dyrl_PT -ne (returnDefault -b)[0]) }
    Return $true
}
## Admin password check for interactive python (pydev / debug "python"), which runs with the
## decrypted config in MACONF. Returns $true if allowed. Respects the debug-restriction setting.
function pyGate_([string]$what){
    if(-not (dbgRestricted_)){ Return $true }
    w "`n $what opens python with the MACROSS configuration loaded and requires the admin password." y
    for($i = 1; $i -le 3; $i++){
        $pw = xEntry
        if(-not $pw){ Break }
        $ok = [bool](confLoad_ $pw)
        Remove-Variable pw
        if($ok){
            try{ errLog INFO 'MACROSS.debug' "$USR verified as admin for $what on $dyrl_HN0" }catch{ }
            Return $true
        }
        w ' That password is not correct.' y
    }
    try{ errLog WARN 'MACROSS.debug' "$what refused for $USR on $dyrl_HN0 (admin password)" -forward }catch{ }
    w ' Python was not opened. Hit ENTER to continue.' y; Read-Host | Out-Null
    Return $false
}

function consoleDebug($x=$null,$ch=$null){
    $msgloop = 'Type another command for testing, "d" to reload the menu, or hit ENTER to exit debugging: '
    w "`n                         MACROSS DEBUG MODE`n" y
    macrossHelp show
    ''
    if($x){
        varCleanup; startUp
        gerwalk VGhhdCdzIGEgcHJpdmlsZWdlZCBjb21tYW5kLg==; $ha = $dyrl_PT
        $restricted = dbgRestricted_
        New-Variable -Name dbgrx_ -Option Constant -Value $(if($restricted){ setLocal -i }else{ $null })
        New-Variable -Name dbggate_ -Option Constant -Value @{ ok = $false }
        function dbggate_check($cmdText){
            if(-not $dbgrx_ -or $dbggate_.ok -or $cmdText -notmatch $dbgrx_){ Return $true }
            w "`n $ha" -b r -f k
            w ' Enter the MACROSS admin password to run privileged commands in this debug session.' y
            for($i = 1; $i -le 3; $i++){
                $pw = xEntry
                if(-not $pw){ Break }
                if(confLoad_ $pw){
                    $dbggate_.ok = $true
                    try{ errLog INFO 'MACROSS.debug' "$USR verified as admin for privileged debug commands on $dyrl_HN0" }catch{ }
                    Return $true
                }
                w ' That password is not correct.' y
            }
            try{ errLog WARN 'MACROSS.debug' "Privileged debug command refused for $USR on ${dyrl_HN0}: $(skScrub $cmdText)" }catch{ }
            w ' Command not run.' y
            Return $false
        }
        
        $mfuncs = macrossFuncList_
        $z = $x
        while("$z".Trim() -ne ''){
            $t = "$z".Trim()
            if($t -eq 'd'){ consoleDebug; Return }
            elseif($t -match '^(help|man)$'){
                macrossHelp dev
                splashBanner
                macrossHelp show
            }
            elseif($t -match '^(help|man|get-help)\s+(\S+)\s*$' -and ($Matches[1] -ne 'get-help' -or $Matches[2] -in $mfuncs)){
                $name = $Matches[2]
                if($name -in $mfuncs){
                    macrossHelp $name
                    cls
                    macrossHelp show
                }
                else{
                    $near = @($mfuncs | ?{ $_ -like "*$name*" -or $name -like "*$_*" })
                    w "`n '$name' is not a MACROSS function.$(if($near.Count){ " Did you mean: $($near -join ', ')?" })" y
                    w " For PowerShell's own help on a command, use:  Get-Help $name" g
                }
            }
            elseif(dbggate_check $t){
                if($dyrl_LOG -ne 'none'){ errLog INFO 'MACROSS.debug' "$USR/$dyrl_HN0`: $(skScrub $t)" }
                $cmd = [scriptblock]::Create($t)
                if(-not $dyrl_CONF){ startUp }
                . $cmd; varCleanup
            }
            w "`n    $msgloop" g -i
            $z = Read-Host
        }
        Return
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
            if($MONTY -or $LIFEOFBRIAN){ w '
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
                if(-not (pyGate_ 'Debug python')){ Return }
                startUp;pyATTS;macrossMirror -n $N_;if($dyrl_LOG -ne 'none'){errLog INFO 'MACROSS.debug' "pydev success ($dyrl_HN0)"};cls
                if($dyrl_PYCROSS -and $dyrl_PYCROSS -ne 'none'){ . $dyrl_PYCROSS }
                else{ py }
            }
            elseif($z -notIn 1..3){
                cls
                consoleDebug $z
            }
            else{
                $Script:ErrorActionPreference = $e[$([int]$z - 1)]
                splashBanner
                $c = $ErrorActionPreference
                Write-Host -f CYAN "
                Error display is now set to:  $c"
                slp 2; consoleDebug
            }
        }
        else{
            $la = @()
            (Get-ChildItem $dyrl_LOG).Name | Sort -Descending | %{
                $la += $_
                $ln++
            }
            splashBanner
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
                w "`n  Log file >  " g -i
                $z = Read-Host

                if([int]$z -and $la[$z-1]){
                    $lf = $la[$z-1]; $logmsgs = New-Object System.Collections.ArrayList
                    foreach($mm in Get-Content "$dyrl_LOG\$lf"){
                        gerwalk $mm
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



if(! $ROBOTECH){
function updatePass(){
    splashBanner
    try{ $pls = "$((Get-QADUser -Identity $USR).passwordLastSet)`." }
    catch{
        errMsg "`"Get-QADUser`" Failed! Try again with a different powershell version (currently $pver)" -c r
        w 'Hit ENTER to go back.' g; Read-Host; Return
    }
    w "
    Your password was last changed on $pls

    MACROSS will update your admin password in Active Directory. Hit ENTER to
    continue, or 'c' to cancel: " g -i
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
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($a1)
            if($b1 -eq "q"){ Remove-Variable -Force b1; Return }
            w '
                  Enter the password again: ' -i g
            $a2 = Read-Host -AsSecureString
            $a2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($a2)
            $b2 = [System.Runtime.InteropServices.Marshal]::ptrToStringAuto($a2)
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($a2)
            if($b1 -cne $b2){ w 'Passwords do not match!' y }
            else{ Break }
        }
    }

    w '
    Updating password...
    ' g

    Set-QADUser -Identity $USR -UserPassword "$b1" -Proxy | Out-Null
    Remove-Variable -Force b1,b2


    $date = $(Get-Date)
    $plu = $(Get-QADUser -Identity $USR).passwordLastSet


    ## The password was changed if .PasswordLastSet is within the last few minutes
    if($plu -and ([datetime]$plu) -gt $date.AddMinutes(-5)){
        w '
    Success!
    ' g
    }
    else{
        w "
    Current Date:              $($date)
    New Password Last Set:     $($plu)

    If the date+time match (within a few minutes), then you're good to go!

    If not, this is the last error collected by Windows:
    " c
        w "
    $($error[0])
        " y
    }

    w '
    Hit ENTER to exit.
    ' g

    ## Don't leave passwords sitting in the powershell history, if they
    ## somehow got recorded here
    skSanitize
    Remove-Variable -Force a0,a1,a2

    Read-Host
}
}



function stringz($f=$(getFile),[switch]$w=$false){   #mp
    <#
    ||shorthelp||

    stringz [-f FILEPATH] [-w WRITE_TO_FILE]

    ||longhelp||
    For those deployments when "strings" isn't a default Windows utility.

    Extract ASCII strings/chars from files. Call this function without parameters
    to open a nav window and select a file. Alternately, you can use the -f to send 
    a filepath.

    The -w option will save outputs to your local MACROSS\outputs folder.

    Send a filepath, or let the function open a dialog for you.

    ||examples||
    Dump strings from an executable to your screen:

        stringz -f <filepath>

    Use -w to write outputs to file:

        strings -w

    #>

    $of = "$dyrl_OUTFILES\strings.txt"

    if($f -Match "\.(doc|dot|ppt|pot|xls|xlt|od[tspg]|ot[tspg]|fod[tspg]|sx[wci])\w*$"){
        ## Office/LibreOffice documents: let decodeDoc pull the text and macros out
        $r = decodeDoc $f -n
        $stringlist = @($r.vb) + @($r.pt | %{ $_ -split "`n" })
        if($w){ noBOM -t ($stringlist -join "`n") -f $of -m }
    }
    elseif($f -Like "*pdf"){
        $stringlist = decodePdf $f
        $stringlist = $($stringlist -Split "`n")
        if($w){ noBOM -t $stringlist -f $of }
    }
    elseif($f -and $f -ne ''){
        $binstr = Get-Content $f -raw | %{
            $_ -replace '[^\p{L}\p{N}\s:./_-]+'} | ?{ 
                $_ -Match '^[ -~]+$' 
            }
        if($w){ noBOM -t "$binstr" -f $of }
        Return $binstr
    }
    if($stringlist.length -gt 0){
        Return $stringlist
    }
}



function getHash(){   #mp
    <#
    ||shorthelp||
    Get the hash of a file or string.
    Usage:
        getHash [-f FILEPATH_OR_STRING] [-a  md5|sha256] [-s HASH_A_STRING]

    ||longhelp||
    Get an MD5 or SHA256 hash of a file. Use -s to hash a string instead (This
    option only returns a SHA256 hash).

    ||examples||
    Usage:

        $md5 = getHash $filepath md5
        $sha = getHash $filepath sha256
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
        $io = [IO.MemoryStream]::new([byte[]][char[]]$fstring)
        $h = (Get-FileHash -InputStream $io -Algorithm "$($type[1])").Hash
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
            [-f FORWARD_TO_SEIM]

    ||longhelp||
    Have your scripts write to MACROSS logs for troubleshooting/auditing. The default location
    is $dyrl_LOG, wherever you've specified that location to be in the macross.conf file. The current
    timestamp automatically gets written to the log, you don't need to send it. The first param,
    "-level", is required, and should indicate the type of log (ERROR, INFO, etc.). You can send
    the actual log message as "-text", and any additional fields you need to add should be sent
    TAB-SEPARATED as "-extra".

    These logs are written encoded to avoid weirdness, but can be viewed from MACROSS's debug screen.

    If you call this function with the -f option, it will forward the log message to your SEIM,
    provided that the SEIM's address has been added to MACROSS's configurations.

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
    if($dyrl_LOG -and $dyrl_LOG -ne 'none' -and (Test-Path $dyrl_LOG)){     ## (log folder isn't known until the config loads)
        [string]$log = "$(Get-Date -Format 'yyyy-MM-dd')" + '.txt'      ## Create the log filename
        [string]$local = $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')      ## First field is the timestamp (24-hour)
        $msg = "MACROSS/$($env:COMPUTERNAME)/$USR"                       ## Specify the source
        $d = "`t"                                                       ## Delimiter

        if($forward){
            ## Use UTC for sending logs to SEIM
            $utc = "$((Get-Date).toUniversalTime() | Get-Date -Format 'yyyy/MM/dd HH:mm:ss.fff+0000')"
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
        $menc = [string]$(gerwalk -e "$local$d$msg")

        ## The second param for StreamWriter is "-Append"; set to $true
        $newout = [System.IO.StreamWriter]::New("$dyrl_LOG\$log",$true)
        $newout.WriteLine("$menc"); $newout.Close()

        ## Log server <host|ip>:port is set by the setup wizard as 'fwd'
        if($forward -and ('fwd' -in $dyrl_CONF.keys)){ 
            try{
                gerwalk $dyrl_CONF.fwd
                $addr = ($dyrl_PT -Split ':')[0]; $port = ($dyrl_PT -Split ':')[1]
                if("$dyrl_PT" -notMatch '^[\w\.\-]+:\d{1,5}$'){ $addr = $null }   ## 'none' or malformed: don't forward
                elseif($addr -Match "[a-z]"){
                    $addr = ([System.Net.Dns]::GetHostAddresses("$addr") |
                        ?{$_.AddressFamily -eq 'InterNetwork'} | Select -First 1).IPAddressToString
                }
                if($addr){
                    $target = [System.Net.IPAddress]::Parse($addr)
                    $sendto = New-Object System.Net.IPEndpoint $target,$port

                    $set1 = [System.Net.Sockets.AddressFamily]::InterNetwork
                    $set2 = [System.Net.Sockets.SocketType]::Dgram
                    $proto = [System.Net.Sockets.ProtocolType]::UDP
                    $socket = New-Object System.Net.Sockets.Socket $set1,$set2,$proto
                    $socket.Connect($sendto)

                    $encoding = [System.Text.Encoding]::UTF8
                    $tosend = $encoding.GetBytes("$utc$d$msg")
                    $fwd = $socket.Send($tosend)
                    $socket.Close()
                }
            }
            catch{ }
        }
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

    The -m option preserves multilines; the default removes newline/carriage returns and
    writes to a single line.

    Use -a to append to the end of a file (if the last line contains text, it will
    begin writing at the end of that line). Use -n to append to the very next line
    instead.

    ||examples||
    noBOM -t $some_text -f $output_file

    #>
    param(
        [Parameter(Mandatory=$true)]    ## Content to write
        [string]$to_write,
        [Parameter(Mandatory=$true)]    ## Output filepath
        [string]$file,
        [switch]$multiline,             ## Preserve your newline/carriage return
        [switch]$next,                  ## Write to existing file's next empty line
        [switch]$append                 ## Append to the end of an existing file (won't add new line)
    )
    if(-not (Test-Path $file)){
        New-item $file | Out-Null
    }
    try{
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
    catch{
        errLog ERROR "$_"
    }
}

## Take a single large block of text and break it into multiple lines. Supply a $filename,
## the $block to be split, and the max line length ($maxlen). The output is a multi-line file
## written to the $dyrl_OUTFILES folder.
function blockWriter(){
    param(
        [Parameter(Mandatory=$true)]
        [string]$block,
        [Parameter(Mandatory=$true)]
        [int]$maxlen,
        [string]$filename,
        [string]$initial = $null,
        [switch]$nowrite
    )
    function p_([switch]$c){
        if($c -and -not $initial){macrossMirror -c}
        elseif(-not $initial){macrossMirror -n $N_}
    }
    
    $c='';$i=0
    $block -Split '' | %{
        $c = "$c$_"
        $i++
        if($i -gt $maxlen){
            $i = 0
            $c = "$c`n"
        }
    }
    $c = $($c -Join '')
    if($nowrite){ Return $c }
    noBOM -f "$dyrl_OUTFILES\$filename" -t $c -m
}

## Make sure the GBIO folder is cleaned out:
## this is where .vf1 files are written so python can
## read powershell outputs & vice-versa.
function cleanGBIO([switch]$s=$false){
    ## Clear $PROTOCULTURE
    if($s){ Remove-Item -Force "$($dyrl_PG[1])\PROTOCULTURE.vf1"}
    ## Make sure the GBIO directory is clean
    else{
        $gb = Get-ChildItem "$($dyrl_PG[1])\*.vf1"
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


function pyNet(){   #mp
    <#
    ||shorthelp||
    pyNet [-c YOUR_SCRIPTNAME] [-v WRITE_VALUE] [-f OUTPUT_FILENAME] [-d DEPTH]

    ||longhelp||
    This function lets scripts write results to a file in the directory

        "corefuncs\pycross\gbio"

    so that python & powershell scripts can easily share the same investigation data during a
    MACROSS session. Eventually MACROSS will improve the way it handles this.

    The .vf1 files are encoded in utf8.

    REQUIRED:  Your script name, as well as the value you want written to that file ($val1).
    The default file will be PROTOCULTURE.vf1, written as a json string:

        { 'caller': $CALLER, 'target':$value1, 'result': $value2 }

    If you are providing a large json dataset, the default writing depth is 10, but you can
    increase it if necessary using the -d parameter.

    If you need something other than this format and want to use a method outside of the
    valkyrie functions, you can provide an alternative filename as the -f parameter to name the
    file anything but "PROTOCULTURE", and write whatever type of data you need to it instead.
    (The ".vf1" extension is still applied). Note that by using -f, pyNet does not format your
    -v $value at all, it will only write the value to the file, so formatting needs to be
    performed by your script.

    If the PROTOCULTURE.vf1 file already exists, this function will check to see if the "result"
    key contains a non-empty value. If so, it assumes this is a response from python to a query
    from powershell, and sets that "result" value as $PROTOCULTURE.

    If "result" is empty, pyNet then assumes you are responding to a python script's request,
    and will write your $value to the "result" key of the json. Otherwise, $value gets written to
    the "target" key in a new PROTOCULTURE.vf1 file.

    ||examples||
    if( $python_called ){

        # Write the results of the python script's request
        pyNet 'myScriptName' $value

        # Or you can just write all the results the script found
        foreach($line in $eval){
            pyNet 'myScriptName' $line 'myResultFile'
        }

    }

    ...and then your python diamond can import the macross library to read it:

        $val = macross.valkyrie()
        $val['result']
        $val['caller']
        $val['target']
        $val['spiritia']


    The file outputs are written with the extension "*.vf1" (including your custom filenames)
    to ensure regular cleanup (see the "cleanGBIO" function elsewhere in this file).

    #>
    Param(
        [Parameter(Mandatory)]
        [string]$caller_,
        $v,
        [string]$f=$null,
        [int]$d=10
    )

    $s = "$($dyrl_PG[1])\PROTOCULTURE.vf1"

    function em_($m=$($error[0])){ errMsg -m $m -c r -f 'MACROSS.pyNet' }
    function w2f_($w,$file=$s){
        if($w -is [System.Management.Automation.PSCustomObject]){     ## Assuming a dict was sent as the $v value
            try{ noBOM -f $file -t "$($w | ConvertTo-Json -Depth $d)" } ## Change depth if necessary...
            catch{ em_ $_ }
        }
        else{
            try{ noBOM -f $file -t $w -m }
            catch{ em_ $_ }
        }
        if( ! (Test-Path -Path "$file") ){
            errLog ERROR "$USR/$caller_" "Failed to write $file file during macross.valkyrie operation ($dyrl_HN0)"
        }
    }

    if($f){
        $f = "$($dyrl_PG[1])\$f`.vf1"   ## Use custom filename
        w2f_ $v $f
    }
    elseif((Test-Path $s) -and ($caller_ -eq $CALLER)){
        $j = Get-Content -raw $s | ConvertFrom-Json
        if($j.result -ne 'WAITING'){ $Global:PROTOCULTURE = $j.result }
        else{
            $j.result = $v
            w2f_ $j
        }
    }
    else{
        $j = [pscustomobject]@{ 'caller'=$caller_; 'target'=$v; 'result'='WAITING' }
        w2f_ $j
    }


}

function TL($d){    #mp
    <#
    ||shorthelp||
    TL [-d DIAMOND_NAME]

    ||longhelp||
    Get a full listing of *all* available diamonds and their [macross] attributes

    ||examples||
    Call from the main menu with debug:

        debug TL

    Get the details for a specific tool while in debugging mode:

        TL <tool name>

    #>
    if($d -and $d -in $dyrl_LATTS){ $dyrl_LATTS[$d].toolInfo() }
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
    Output results to a spreadsheet (MS Excel, or LibreOffice Calc if Excel is not
    installed). Specify the name of your spreadsheet with -o; -v is the values you're
    writing, separated by "<::>". -r is the row to start writing in (when adding to an
    existing sheet, the default is the next empty row). Use -h for comma-separated
    column names, OR if you are editing an existing sheet/don't need column headers, you
    can send the number of columns you require. You can colorize text by adding a 'color~'
    to the beginning of any value in -v, or colorize the cell by adding
    'cellColor~textColor~' to the value. Use -libre to force LibreOffice Calc.
    Usage:
        sheetz [-o FILENAME] [-v VALUE1<::>VALUE2...] [-r ROW_NUMBER] [-h COLUMN1,COLUMN2...]
            [-s SHEET_NAME1,SHEET_NAME2...] [-libre]

    ||longhelp||
    Output tool values to a spreadsheet in your MACROSS outputs folder ($dyrl_OUTFILES)

    (This is very simplistic at the moment; the goal is to eventually make more useful
    spreadsheets when simple CSV files aren't good enough.)

    Parameters for this function:
    -o = (req'd) the name of the output file
        -will always read/write to $dyrl_OUTFILES
        -do NOT include an extension, sheetz sets it automatically (.xlsx)
    -v = (req'd) cell values, "<::>"-separated. YOU MUST SEPARATE YOUR CELL VALUES
        USING THIS PATTERN. This allows your cell text to contain commas and other
        commonly-used delimiter characters, without mistakenly splitting them into
        separate cells.
    -r = (optional) the starting row number to write to. The default is 1 for a new
        sheet, or the next empty row when adding to a sheet that already has values.
    -h = (optional) comma-separated column names, OR the number of columns you are
        writing across
    -s = (optional) comma-separated names for individual sheets/tabs.
    -libre = (optional) use LibreOffice Calc even if MS Excel is installed. Without this
        switch, sheetz defaults to Excel if it is installed, then falls back to LibreOffice 
        Calc if it is available when Excel is not. Either way, the file is saved in .xlsx 
        format.

    Every cell is written as plain text, including numbers and dates. Values that start with
    "=" are never turned into formulas, so data from logs or other untrusted sources are not
    executable when you open the spreadsheet.

    If only -o and -v are sent, this function will separate -v values and write them as a
    list into column A.

    ####### USING MULTIPLE SHEETS WITHIN A WORKBOOK ######

    To write values across multiple sheets/tabs, send a **list** of separated values
    in -v instead of a string. For example, to write cells on two tabs, all the cell values
    for each tab should be "<::>"-separated strings within the list:

        -v @(
            'station001<::>windows 10, licensed<::>192.168.1.100',
            'station001<::>patched on 12/1/2020<::>online'
        )

    ..and so on. The same method must be used in -h if you are using column headers OR specifying
    the number of columns:

        -h @(
            'HOSTNAME,OS,IP',
            3
        )

    In the above -h, the first sheet will have the headers HOSTNAME, OS and IP for columns
    A, B and C; the second sheet will simply write across the first 3 columns without naming
    them. An empty entry ('' or $null) writes that sheet's values as a list in column A.

    The -s option for naming each individual sheet is optional, but if you use it, it must
    include the exact amount of names (comma-separated) as there are items in your -v and -h
    lists, and make sure they are arranged **in order** to match the first-thru-last items
    in your -v and -h lists! Tabs are created in that same order.

    ###### UPDATING EXISTING WORKBOOKS ######

    If you're adding values to an existing sheet, sheetz starts writing at the next empty
    row automatically. The -r parameter lets you specify a different row to start in. For
    example, to start at row 200, send -r 200.

    If you send a NUMBER as the -h parameter, it tells this function how many values to write
    horizontally from parameter -v, before it shifts to the next row and continues writing
    cells.

    If you send comma-separated strings as param -h, this function will write those values as
    the column headers in the worksheet, and then begin writing the values from param -v into
    the appropriate row/columns. When the headers are written to row 1, the top row is frozen.

    ###### FORMATTING ######

    TO COLORIZE TEXT:
    Send the single-letter code of your color choice with a "~" symbol between your color and
    the value:

        r = red        g = green      b = blue       y = yellow
        c = cyan       m = magenta    a = gray       w = white
        k = black

    i.e. "r~RESULT FAILED!" will write "RESULT FAILED!" in red text.

    TO COLORIZE CELLS:
    Add a color letter (same choices as above) AND the color you want for text, separated with "~"
    like so:

        "k~r~RESULT FAILED"

    The above will make the cell black with red text. You must send BOTH a cell color AND a
    text color to colorize cells. A letter that isn't in the list above is not treated as a
    color, and the value is written as-is.

    ||examples||
    EXAMPLE 1

        $vals = 'host 10<::>host 24<::>host 13<::>host 3'
        sheetz -o 'myoutput' -v $vals

    The above example will write out the hosts in a simple list to 'myoutput.xlsx' in cells
    A1 - A4

    EXAMPLE 2

        $hosts = @('host 1',
            'b~w~windows',
            '11',
            '192.168.10.10',
            'host 2',
            'linux',
            'r~kali',
            '192.168.10.11') -Join '<::>'
        $headers = 'HOST,OS,VER,IP'
        sheetz -o 'myoutput' -v $hosts -r 5 -h $headers

    The above will create (or open) myoutput.xlsx, and then writes 'HOST' to cell A5, 'OS' to B5,
    'VER' to C5, and 'IP' to D5. Next it will go through all the "<::>"-separated values in -v,
    writing values into the next row until it reaches column D, then jump to the next row back at
    column A. And in this example, cell B6 (windows) will be blue with white text while cell C7
    (kali) will be in red text.

                         A         B       C         D
            row 5      HOST       OS      VER        IP
            row 6      host 1   windows   11    192.168.10.10
            row 7      host 2   linux     kali  192.168.10.11

    Make sure your script is sending your -v values IN ORDER, otherwise they'll get
    written to the wrong cells! Also, if you're adding values to an existing sheet, don't send the
    headers; send the number of columns being written instead, in this case 4 columns (A-D).

    EXAMPLE 3

    Sometimes you don't need headers. You could set -h to 6 if you just need to specify
    that there should be 6 columns (A-F). If $patchInfo contains hosts and patch dates:

        sheetz -o 'patch report' -v $patchInfo -r 1 -h 6

                    A         B        C         D                 E           F
        row 1      host 1   windows   11    192.168.10.10      patched     1/31/2020
        row 2      host 2   windows   10    192.168.10.11      unpatched


    #>
    <#
    TO ADD OR MODIFY THE DEFAULT CELL & FONT COLORIZATION:
    Add a single-letter key and its RGB(red,green,blue) values to $rgb below. Excel and
    LibreOffice store colors differently (Excel = R + G*256 + B*65536, LibreOffice =
    R*65536 + G*256 + B), so sheetz converts the RGB values for whichever program it uses.

        RGB COLORS:
        Black: RGB(0,0,0)
        White: RGB(255,255,255)
        Red: RGB(255,0,0)
        Green!: RGB(0,255,0)
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
        [string]$s='Sheet 1',
        [switch]$libre
    )

    ## Pick the spreadsheet program ($SHEETZ1 and $SHEETZ2 are set from installed_programs.json)
    if($libre -or -not $SHEETZ1){
        if(-not $SHEETZ2){
            if($libre){ $em = 'LibreOffice Calc is not installed!' }
            else{ $em = 'Neither MS Excel nor LibreOffice Calc is installed!' }
            errMsg -f 'MACROSS.sheetz' -m $em -c r
            Return
        }
        $useLibre = $true
    }
    else{ $useLibre = $false }

    $rgb = @{
        'r' = @(255,0,0);
        'g' = @(204,255,204);
        'b' = @(0,0,255);
        'w' = @(255,255,255);
        'a' = @(128,128,128);
        'y' = @(255,255,0);
        'c' = @(0,255,255);
        'm' = @(255,0,255);
        'k' = @(0,0,0)
    }

    ## No point continuing if mismatched values were sent...
    if($h -and ($h.count -ne $v.count)){
        errMsg -m "The -h and -v counts do not match; could not write $o.xlsx" -c r -f sheetz
        w "`n Hit ENTER to close`n" g
        Read-Host
        Return
    }

    $plan = sheetzPlan_ $v $h $s $rgb
    if(-not $plan.count){ Return }

    ## Convert the RGB values to the chosen program's color format
    $colors = @{}
    foreach($k in $rgb.Keys){
        $c3 = $rgb[$k]
        if($useLibre){ $colors[$k] = ($c3[0]*65536) + ($c3[1]*256) + $c3[2] }
        else{ $colors[$k] = $c3[0] + ($c3[1]*256) + ($c3[2]*65536) }
    }

    w "$(' '*76)" -b g -f k
    w "Do not click anywhere in the sheet as it is being written, or it may fail! " -b g -f k
    w "$(' '*76)" -b g -f k

    $outpath = "$dyrl_OUTFILES\$o.xlsx"
    $auto = -not $PSBoundParameters.ContainsKey('r')     ## No -r sent: append to sheets that have values
    if($useLibre){ sheetzLo_ $plan $outpath $r $auto $colors }
    else{ sheetzXl_ $plan $outpath $r $auto $colors }
}

## sheetz helper: split the color tags ('text~VALUE' or 'cell~text~VALUE') from a cell value.
## Returns @(value, cellColor, textColor); letters that aren't in $p are left in the value.
function sheetzTag_($t,$p){
    $bg = $null; $fg = $null
    if($t -Match '^([a-z])~([a-z])~' -and $p.ContainsKey($Matches[1]) -and $p.ContainsKey($Matches[2])){
        $bg = $Matches[1].ToLower(); $fg = $Matches[2].ToLower(); $t = $t.Substring(4)
    }
    elseif($t -Match '^([a-z])~' -and $p.ContainsKey($Matches[1])){
        $fg = $Matches[1].ToLower(); $t = $t.Substring(2)
    }
    Return ,@($t,$bg,$fg)
}

## sheetz helper: turn the -v/-h/-s values into one plan per sheet, shared by the Excel and
## LibreOffice writers. Each plan has the sheet name, a 2-D grid of values (header row first,
## if any), and 'marks' = @(rowOffset, colOffset, cellColor, textColor) for colored cells.
function sheetzPlan_($v,$h,$s,$p){
    if($v -is [string]){ $v = @($v) }
    if($h -and $h -is [string]){ $h = @($h) }
    $snames = @($s -Split ',')
    $plan = New-Object System.Collections.ArrayList

    for($i = 0; $i -lt $v.count; $i++){
        if($snames.count -ne $v.count){ $name = "Sheet $($i+1)" }
        else{ $name = $snames[$i].Trim() }

        $cells = @("$($v[$i])".Trim() -Split '<::>')
        $heads = $null
        $ncols = 1
        $top = ''; if($h){ $top = "$($h[$i])".Trim() }
        if($top -ne ''){                                ## An empty -h entry = list in column A
            if($top -Match '^\d+$'){ $ncols = [math]::Max(1,[int]$top) }
            elseif($top -Match '[a-zA-Z]'){
                $heads = @($top -Split ',' | %{ $_.Trim() })
                $ncols = $heads.count
            }
            else{
                errMsg -m "Incorrect header value for '$name'; that sheet was not written" -c r -f sheetz
                continue
            }
        }

        $hrow = [int]($null -ne $heads)
        $nrows = $hrow + [math]::Ceiling($cells.count / $ncols)
        $grid = New-Object 'object[,]' $nrows,$ncols
        $marks = New-Object System.Collections.ArrayList
        if($heads){ for($j = 0; $j -lt $ncols; $j++){ $grid[0,$j] = $heads[$j] } }

        $ro = $hrow; $co = 0
        foreach($cell in $cells){
            $tag = sheetzTag_ $cell $p
            $grid[$ro,$co] = $tag[0]
            if($tag[1] -or $tag[2]){ [void]$marks.Add(@($ro,$co,$tag[1],$tag[2])) }
            $co++
            if($co -ge $ncols){ $co = 0; $ro++ }      ## all columns written, go to the next row
        }

        [void]$plan.Add([pscustomobject]@{
            name = $name; heads = [bool]$hrow; grid = $grid
            rows = $nrows; cols = $ncols; marks = $marks
        })
    }
    Return ,$plan
}

## sheetz writer for MS Excel
function sheetzXl_($plan,$path,$r,$auto,$colors){
    $new = -not (Test-Path $path)
    $excel = $null; $workbook = $null; $worksheet = $null
    try{
        $excel = New-Object -ComObject Excel.Application -ErrorAction Stop
        $excel.Visible = $true
        if($new){ $workbook = $excel.Workbooks.Add() }
        else{ $workbook = $excel.Workbooks.Open($path) }

        ## A new workbook comes with blank sheets; remember them so unused ones can be removed
        $blank = @(); if($new){ foreach($ws in $workbook.Worksheets){ $blank += $ws.Name } }

        $excel.Interactive = $false                 ## Ignore clicks/typing while the sheet is written
        foreach($sheet in $plan){
            $exists = $true
            try{ $worksheet = $workbook.Worksheets.Item($sheet.name) }
            catch{
                $last = $workbook.Worksheets.Item($workbook.Worksheets.Count)
                $worksheet = $workbook.Worksheets.Add([System.Reflection.Missing]::Value, $last)    ## add as the last tab
                $worksheet.Name = $sheet.name
                $exists = $false
            }

            $start = $r
            if($exists -and $auto){
                $used = $worksheet.UsedRange
                if($used.Rows.Count -gt 1 -or $used.Columns.Count -gt 1 -or $null -ne $worksheet.Cells.Item(1,1).Value2){
                    $start = $used.Row + $used.Rows.Count     ## next empty row
                }
            }

            ## Write the whole grid in one call, then color only the tagged cells
            $range = $worksheet.Range($worksheet.Cells.Item($start,1),
                $worksheet.Cells.Item($start + $sheet.rows - 1, $sheet.cols))
            $range.NumberFormat = '@'                 ## Text format: values are never read as formulas, numbers or dates
            $range.Value2 = $sheet.grid
            foreach($m in $sheet.marks){
                $cell = $worksheet.Cells.Item($start + $m[0], 1 + $m[1])
                if($m[2]){ $cell.Interior.Color = $colors[$m[2]] }
                if($m[3]){ $cell.Font.Color = $colors[$m[3]] }
            }

            if($sheet.heads -and $start -eq 1){       ## Freeze the header row
                $worksheet.Activate()
                $win = $excel.ActiveWindow
                $win.FreezePanes = $false
                $win.SplitColumn = 0
                $win.SplitRow = 1
                $win.FreezePanes = $true
            }
        }

        if($new){
            $excel.DisplayAlerts = $false
            foreach($b in $blank){
                if($b -notIn $plan.name){ $workbook.Worksheets.Item($b).Delete() }
            }
            $excel.DisplayAlerts = $true
            $workbook.SaveAs($path, 51)               ## 51 = xlOpenXMLWorkbook (.xlsx)
        }
        else{ $workbook.Save() }
    }
    catch{
        errMsg -m "Could not write $path to Excel: $($_.Exception.Message)" -c r -f sheetz
    }
    finally{
        if($excel){ try{ $excel.Interactive = $true }catch{ $null } }
        ## Excel stays open so the user can review the sheet; just release the COM objects
        @($worksheet,$workbook,$excel) | ?{ $_ } | %{
            [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($_)
        }
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
    }
}

## sheetz helper: call a LibreOffice COM bridge object. PowerShell can't use these objects directly
## ($obj.method() throws "not implemented" because the bridge has no type info), so every call goes
## through InvokeMember. -get/-set read or write a property (used for UNO structs).
function sheetzUno_($o,[string]$m,[array]$a=@(),[switch]$get,[switch]$set){
    $how = [System.Reflection.BindingFlags]::InvokeMethod
    if($get){ $how = [System.Reflection.BindingFlags]::GetProperty }
    elseif($set){ $how = [System.Reflection.BindingFlags]::SetProperty }
    ## The bridge can't convert PowerShell's wrapped objects (PSObject), so pass the real ones
    $args2 = New-Object 'object[]' $a.Count
    for($i = 0; $i -lt $a.Count; $i++){
        $x = $a[$i]
        if($x -is [System.Management.Automation.PSObject]){ $x = $x.PSObject.BaseObject }
        $args2[$i] = $x
    }
    if($o -is [System.Management.Automation.PSObject]){ $o = $o.PSObject.BaseObject }
    try{ Return ,([System.__ComObject].InvokeMember($m, $how, $null, $o, $args2)) }
    catch{
        $em = $_.Exception
        while($em.InnerException){ $em = $em.InnerException }
        throw "$m(): $($em.Message)"
    }
}

## sheetz writer for LibreOffice Calc (uses LibreOffice's COM bridge, com.sun.star.ServiceManager)
function sheetzLo_($plan,$path,$r,$auto,$colors){
    $new = -not (Test-Path $path)
    $url = ([System.Uri]$path).AbsoluteUri       ## file:///C:/... with spaces encoded
    $sm = $null; $doc = $null; $locked = $false; $opened = $false
    $freeze = New-Object System.Collections.ArrayList

    try{
        $sm = New-Object -ComObject com.sun.star.ServiceManager -ErrorAction Stop
        $desk = sheetzUno_ $sm 'createInstance' @('com.sun.star.frame.Desktop')

        ## If the file is already open in Calc (e.g. from an earlier sheetz run), write to that window;
        ## loading it a second time pops up a "Document in Use" dialog that would hang MACROSS
        if(-not $new){
            $en = sheetzUno_ (sheetzUno_ $desk 'getComponents') 'createEnumeration'
            while($null -eq $doc -and (sheetzUno_ $en 'hasMoreElements')){
                $d = sheetzUno_ $en 'nextElement'
                try{ if((sheetzUno_ $d 'getURL') -eq $url){ $doc = $d } }catch{ $null }
            }
        }
        if($null -eq $doc){
            if(-not $new){
                ## Not open here; a lock file means it's open in another program or by another user
                $fn = Split-Path $path -Leaf; $dir = Split-Path $path -Parent
                $lock = @(@("$dir\.~lock.$fn#", "$dir\~`$$fn") | ?{ Test-Path -LiteralPath $_ })
                if($lock){
                    throw "the file is open in another program or by another user. Close it and try again (if nobody has it open, delete $($lock[0]))"
                }
                $src = $url
            }
            else{ $src = 'private:factory/scalc' }
            $doc = sheetzUno_ $desk 'loadComponentFromURL' @($src,'_blank',0,[Array]::CreateInstance([object],0))
            $opened = $true
        }
        $sheets = sheetzUno_ $doc 'getSheets'

        ## A new document comes with a blank sheet; remember it so it can be removed if unused
        $blank = @(); if($new){ $blank = @(sheetzUno_ $sheets 'getElementNames') }

        [void](sheetzUno_ $doc 'lockControllers'); $locked = $true    ## No screen redraws while writing
        foreach($sheet in $plan){
            $exists = sheetzUno_ $sheets 'hasByName' @($sheet.name)
            if(-not $exists){   ## add as the last tab
                [void](sheetzUno_ $sheets 'insertNewByName' @($sheet.name, [int16](sheetzUno_ $sheets 'getCount')))
            }
            $sh = sheetzUno_ $sheets 'getByName' @($sheet.name)

            $start = $r
            if($exists -and $auto){
                $cur = sheetzUno_ $sh 'createCursor'
                [void](sheetzUno_ $cur 'gotoEndOfUsedArea' @($false))
                $end = sheetzUno_ $cur 'getRangeAddress'
                $endRow = sheetzUno_ $end 'EndRow' -get
                $endCol = sheetzUno_ $end 'EndColumn' -get
                $a1 = sheetzUno_ (sheetzUno_ $sh 'getCellByPosition' @(0,0)) 'getString'
                if($endRow -gt 0 -or $endCol -gt 0 -or $a1 -ne ''){
                    $start = $endRow + 2                  ## EndRow counts from 0; next empty row counting from 1
                }
            }

            ## Calc wants an array of rows instead of a 2-D grid. Every value is sent as a string, and
            ## setDataArray stores strings as text (never as formulas, numbers or dates)
            ## ([Array]::CreateInstance gives plain arrays; New-Object would wrap them in PSObjects)
            $data = [Array]::CreateInstance([object], $sheet.rows)
            for($i = 0; $i -lt $sheet.rows; $i++){
                $row = [Array]::CreateInstance([object], $sheet.cols)
                for($j = 0; $j -lt $sheet.cols; $j++){ $row.SetValue([string]"$($sheet.grid[$i,$j])", $j) }
                $data.SetValue($row, $i)
            }

            ## Calc counts rows and columns from 0, and takes (column, row) instead of (row, column)
            $top = $start - 1
            $range = sheetzUno_ $sh 'getCellRangeByPosition' @(0, $top, ($sheet.cols - 1), ($top + $sheet.rows - 1))
            [void](sheetzUno_ $range 'setDataArray' @(,$data))

            foreach($m in $sheet.marks){
                $cell = sheetzUno_ $sh 'getCellByPosition' @($m[1], ($top + $m[0]))
                if($m[2]){ [void](sheetzUno_ $cell 'setPropertyValue' @('CellBackColor', [int]$colors[$m[2]])) }
                if($m[3]){ [void](sheetzUno_ $cell 'setPropertyValue' @('CharColor', [int]$colors[$m[3]])) }
            }

            if($sheet.heads -and $start -eq 1){ [void]$freeze.Add($sh) }
        }

        if($new){
            foreach($b in $blank){
                if($b -notIn $plan.name){ [void](sheetzUno_ $sheets 'removeByName' @($b)) }
            }
        }

        [void](sheetzUno_ $doc 'unlockControllers'); $locked = $false
        $ctrl = sheetzUno_ $doc 'getCurrentController'
        foreach($sh in $freeze){                      ## Freeze the header row
            [void](sheetzUno_ $ctrl 'setActiveSheet' @($sh))
            [void](sheetzUno_ $ctrl 'freezeAtPosition' @(0,1))
        }

        ## Always save in .xlsx format so the output matches the Excel version
        $props = [Array]::CreateInstance([object], 2)
        $i = 0
        foreach($pv in @(@('FilterName','Calc MS Excel 2007 XML'), @('Overwrite',$true))){
            $s = sheetzUno_ $sm 'Bridge_GetStruct' @('com.sun.star.beans.PropertyValue')
            [void](sheetzUno_ $s 'Name' @($pv[0]) -set)
            [void](sheetzUno_ $s 'Value' @($pv[1]) -set)
            if($s -is [System.Management.Automation.PSObject]){ $s = $s.PSObject.BaseObject }
            $props.SetValue($s, $i); $i++
        }
        [void](sheetzUno_ $doc 'storeAsURL' @($url, $props))
    }
    catch{
        $em = $_.Exception
        while($em.InnerException){ $em = $em.InnerException }    ## InvokeMember wraps the real error
        errMsg -m "Could not write $path to LibreOffice Calc: $($em.Message)" -c r -f sheetz
        ## Don't leave a half-written new document open (a document the user already had open stays)
        if($new -and $opened -and $null -ne $doc){
            try{ [void](sheetzUno_ $doc 'close' @($true)) }catch{ $null }
            $locked = $false
        }
    }
    finally{
        if($locked){ try{ [void](sheetzUno_ $doc 'unlockControllers') }catch{ $null } }
        ## Calc stays open so the user can review the sheet; just release the COM objects
        ## ($null checks only: PowerShell can't test these objects for true/false)
        foreach($o in @($doc,$sm)){
            if($null -ne $o){ try{ [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($o) }catch{ $null } }
        }
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
    }
}


function gerwalk($t,[switch]$hex=$false,[switch]$e=$false){   #mp
    <#
    ||shorthelp||
    gerwalk [-t STRING] [-h USE_HEXADECIMAL] [-e ENCODE_PLAINTEXT]

    ||longhelp||
    Decode your encoded value ($t), plaintext gets saved as "$dyrl_PT".
    Default is Base64, change to hexadecimal with -h.

    Encode your plaintext value ($t) by using -e. The encoded text is automatically
    returned; it is not written to "$dyrl_PT".

    -DO NOT USE ENCODING TO HIDE USERNAMES/PASSWORDS/KEYS or other sensitive info! This
    is only intended to prevent regular users from seeing your filepaths/URLs, etc.,
    avoiding automated keyword scanners, and decoding values found during investigations.

    ||examples||
    -If you need persistence, you MUST set your new variable to $dyrl_PT **before** this
      function gets called again:

        gerwalk $base64string
        $plaintext = $dyrl_PT

    -To decode a hexadecimal string, send the hex and use -h (your hex string can include
      spaces and/or "0x" tags, or neither):

        gerwalk "0x746869732069 730x20 61 200x740x650x7374" -h
        $plaintext = $dyrl_PT

    -If you want to ENCODE plaintext, call this function with your plaintext and -e.
      This mode does NOT write to $dyrl_PT!

        $b64 = gerwalk $plaintext -e
        $hex = gerwalk $plaintext -h -e


    Anime note: "gerwalk" is the transformation mode of the valkyrie fighters in Macross;
    a hybrid of the fighter half-transformed into a giant battle-robot.


    #>
    if($dyrl_PT){Remove-Variable dyrl_PT -Scope Global}
    if($e){
        if($hex){$a = ([System.Text.Encoding]::UTF8.GetBytes($t) | Foreach{$_.ToString("X2")}) -Join ''}
        else{$a = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($t))}
        Return $a
    }
    elseif($hex){
        $a = $t -replace "0x"; $a = $a -replace "\s"
        [byte[]]$hb = $a -Split '(..)' | ?{$_ -ne ''} | %{[convert]::ToByte($_,16)}
        $a = [Text.Encoding]::UTF8.GetString($hb)
    }
    else{
        $a = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($t))
    }

    $Global:dyrl_PT = $a


}

function urlEnc($str,$alt='%20'){   #mp
    <#
    ||shorthelp||
    urlEnc [-s STRING] [-a ALTERNATE WHITESPACE ENCODING]

    ||longhelp||
    Converts a plaintext string to a URL-encoded string that can be passed to web APIs.
    The default encoding for whitespace is "%20", but you can send an alternate if required
    with -a.

    ||examples||

    # Standard usage
    $site = 'http://example.com/api?q=msg+where+sockets=(1.2.3.4:8443)&&time=[some time frame]'
    $api_call = urlEnc $site

    # Alternate usage - replace whitespace with a "+" character instead of "%20"
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
    decodePdf [-f PATH_TO_FILE] [-preserve (Preserve layout)]
        [-s (return a list of lines)]

    ||longhelp||
    Returns decoded plaintext from PDF documents. The -p option helps
    preserve decoded text with minimal breakage (removed lines, conjoined
    words, etc.). 
    
    The default behavior just pulls out blobs of text, but you can use -s 
    to get back a list of text lines, which also removes all empty lines.

    NOTE: the plugin used for this function requires the python
    packages pdfplumber and PdfReader, which are NOT part of a standard
    python install. Check your company policy before installing these
    packages:

        pip install PdfReader
        pip install pdfplumber

    ||examples||

        decodePdf "C:\Users\Me\Documents\Intel.pdf" -p


    #>

    $emsg = "Failed to extract text from $filepath"
    $filename = $filepath -replace "^.+\\" -replace "\.\w+$"
    $readfrom = "$dyrl_TMP\decoded-pdf-$filename.vf1"
    $pyargs = @("$dyrl_PLUGINS\pdfdecoder.py",$filepath,$filename)
    if($preserve){ $pyargs += '1' }
    if($MONTY){ & $dyrl_PYCROSS @pyargs }
    elseif($LIFEOFBRIAN){ py @pyargs }
    else{
        errLog ERROR "MACROSS.decodePdf" "No python available to decode $filepath"
        Return ''
    }
    if(-not (Test-Path $readfrom)){
        errLog ERROR "MACROSS.decodePdf" $emsg
        Return ''
    }
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

## decodeDoc helper: what kind of document this is, from its first bytes (not the file extension)
function docKind_($path){
    $h = New-Object byte[] 512
    $fs = [IO.File]::OpenRead($path)
    try{ $n = $fs.Read($h,0,512) }
    finally{ $fs.Close() }
    if($n -ge 4 -and $h[0] -eq 0x50 -and $h[1] -eq 0x4B -and $h[2] -eq 3 -and $h[3] -eq 4){ Return 'zip' }
    if($n -ge 8 -and [BitConverter]::ToString($h,0,8) -eq 'D0-CF-11-E0-A1-B1-1A-E1'){ Return 'ole' }
    $t = [Text.Encoding]::UTF8.GetString($h,0,$n).TrimStart([char]0xFEFF,' ',"`t","`r","`n")
    if($t -match '^<(\?xml|office:document|w:wordDocument|pkg:package)'){ Return 'xml' }
    Return 'other'
}

## decodeDoc helper: read a zip entry, refusing to inflate more than $cap bytes (zip bombs)
function docEntryBytes_($e,$cap){
    $s = $e.Open(); $ms = New-Object IO.MemoryStream
    try{
        $buf = New-Object byte[] 81920
        while(($n = $s.Read($buf,0,$buf.Length)) -gt 0){
            $ms.Write($buf,0,$n)
            if($ms.Length -gt $cap){ throw "it unpacks to more than $([math]::Round($cap/1MB)) MB" }
        }
    }
    finally{ $s.Close() }
    Return ,$ms.ToArray()
}

## decodeDoc helper: turn document XML into readable lines. Paragraphs, rows and breaks become new
## lines and other tags are dropped (other XML gets one value per line); entities are decoded and
## invisible direction/zero-width characters are shown as [U+XXXX] so spoofed text stands out.
function docText_([string]$xml){
    $t = $xml -replace '(?s)<(office:binary-data|w:binData|pkg:binaryData|ooo:source-code)\b.*?</\1>',''
    $t = $t -replace '<(w:tab|text:tab)\b[^>]*/>',"`t" -replace '<text:s\b[^>]*/>',' '
    if($t -match '<(w:p|a:p|text:p|text:h|si)[\s>]'){
        $t = $t -replace '</(w:p|a:p|text:p|text:h|si|w:tc|w:tr|table:table-cell|table:table-row)>|<(w:br|w:cr|a:br|text:line-break)\b[^>]*/?>',"`n"
        $t = $t -replace '<[^>]*>',''
    }
    else{ $t = $t -replace '<[^>]*>',"`n" }
    $t = [System.Net.WebUtility]::HtmlDecode($t)
    $t = $t -replace '[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]',''
    $t = [regex]::Replace($t, '[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]', { param($m) '[U+{0:X4}]' -f [int][char]$m.Value })
    Return (@($t -split "`r?`n" | %{ $_.TrimEnd() } | ?{ $_.Trim() -ne '' }) -join "`n")
}

## decodeDoc helper: image type from the file's first bytes, never its name. $null = not an image
## we save. SVG can carry scripts, so it is saved as .svg.txt and won't open in a browser.
function docImgType_([byte[]]$b){
    if($null -eq $b -or $b.Length -lt 16){ Return $null }
    $hex = [BitConverter]::ToString($b,0,16)
    if($hex.StartsWith('89-50-4E-47')){ Return 'png' }
    if($hex.StartsWith('FF-D8-FF')){ Return 'jpg' }
    if($hex.StartsWith('47-49-46-38')){ Return 'gif' }
    if($hex.StartsWith('49-49-2A-00') -or $hex.StartsWith('4D-4D-00-2A')){ Return 'tif' }
    if($hex.StartsWith('42-4D')){ Return 'bmp' }
    if($hex.StartsWith('52-49-46-46') -and $hex.Substring(24,11) -eq '57-45-42-50'){ Return 'webp' }
    if($hex.StartsWith('D7-CD-C6-9A') -or $hex.StartsWith('01-00-09-00') -or $hex.StartsWith('02-00-09-00')){ Return 'wmf' }
    if($hex.StartsWith('01-00-00-00') -and $b.Length -gt 44 -and [Text.Encoding]::ASCII.GetString($b,40,4) -eq ' EMF'){ Return 'emf' }
    if([Text.Encoding]::ASCII.GetString($b,0,6) -eq 'VCLMTF'){ Return 'svm' }
    if([Text.Encoding]::UTF8.GetString($b,0,[math]::Min(1024,$b.Length)) -match '<svg[\s>]'){ Return 'svg.txt' }
    Return $null
}

## decodeDoc helper: check a PNG for data hidden after its end marker (the IEND chunk), a common
## way to smuggle a payload inside an innocent-looking picture. Walks the chunks instead of
## searching for "IEND", so the text "IEND" inside image data can't fool it.
## Returns @{ Extra = bytes after the end; Bad = chunk structure is broken; Hint = what the extra data looks like }
function docPngTail_([byte[]]$b){
    $p = 8; $end = -1; $n = 0
    while($p + 12 -le $b.Length -and $n -lt 100000){
        $len = ([int64]$b[$p] -shl 24) -bor ([int64]$b[$p+1] -shl 16) -bor ([int64]$b[$p+2] -shl 8) -bor $b[$p+3]
        $type = [Text.Encoding]::ASCII.GetString($b, $p + 4, 4)
        if($type -cnotmatch '^[A-Za-z]{4}$' -or $p + 12 + $len -gt $b.Length){ break }
        $p += 12 + $len; $n++
        if($type -ceq 'IEND'){ $end = $p; break }
    }
    if($end -lt 0){ Return @{ Extra = 0; Bad = $true; Hint = '' } }
    $extra = $b.Length - $end
    $hint = ''
    if($extra -gt 0){
        $t = [Text.Encoding]::GetEncoding(28591).GetString($b, $end, $extra)       ## one char per byte
        if($t -notmatch '[^\x00]'){ $hint = 'all zero bytes, probably just padding' }
        elseif($t.StartsWith('MZ')){ $hint = 'it starts with "MZ", the header of a Windows program (.exe/.dll)' }
        elseif($t.StartsWith("PK$([char]3)$([char]4)")){ $hint = 'it is a zip archive (could hold a .docx, .jar or other files)' }
        elseif($t.StartsWith("$([char]0xD0)$([char]0xCF)$([char]0x11)$([char]0xE0)")){ $hint = 'it is an OLE2 file (old Office format or MSI)' }
        elseif($t.StartsWith('%PDF')){ $hint = 'it is a PDF' }
        elseif($t.StartsWith("$([char]0x89)PNG") -or $t.StartsWith("$([char]0xFF)$([char]0xD8)$([char]0xFF)")){ $hint = 'it is another image' }
        else{ $hint = "it starts with: $($t.Substring(0, [math]::Min(60, $t.Length)) -replace '[^\x20-\x7E]','.')" }
    }
    Return @{ Extra = $extra; Bad = $false; Hint = $hint }
}

## decodeDoc helper: copy part of a byte array
function docSlice_([byte[]]$b,$from,$to){
    $o = New-Object byte[] ($to - $from)
    [Array]::Copy($b,$from,$o,0,$to - $from)
    Return ,$o
}

## decodeDoc helper: find PNG and JPEG images inside binary data (legacy .doc/.xls/.ppt streams).
## Each match is checked by walking the image's own structure, so random byte matches are dropped.
function docCarve_([byte[]]$b){
    $found = New-Object System.Collections.ArrayList
    if($null -eq $b -or $b.Length -lt 100){ Return ,$found }
    $s = [Text.Encoding]::GetEncoding(28591).GetString($b)      ## one char per byte, for fast searching
    $ord = [StringComparison]::Ordinal

    $sig = "$([char]0x89)PNG`r`n$([char]0x1A)`n"
    $i = $s.IndexOf($sig, $ord)
    while($i -ge 0){
        $p = $i + 8; $end = -1; $n = 0
        while($p + 12 -le $b.Length -and $n -lt 100000){
            $len = ([int64]$b[$p] -shl 24) -bor ([int64]$b[$p+1] -shl 16) -bor ([int64]$b[$p+2] -shl 8) -bor $b[$p+3]
            $type = $s.Substring($p + 4, 4)
            if($type -cnotmatch '^[A-Za-z]{4}$' -or $p + 12 + $len -gt $b.Length){ break }
            $p += 12 + $len; $n++
            if($type -ceq 'IEND'){ $end = $p; break }
        }
        if($end -gt 0){ [void]$found.Add((docSlice_ $b $i $end)); $i = $s.IndexOf($sig, [int]$end, $ord) }
        else{ $i = $s.IndexOf($sig, $i + 8, $ord) }
    }

    $sig = "$([char]0xFF)$([char]0xD8)$([char]0xFF)"
    $i = $s.IndexOf($sig, $ord)
    while($i -ge 0){
        $p = $i + 2; $end = -1; $scan = $false; $n = 0
        while($p + 2 -le $b.Length -and $n -lt 100000){
            $n++
            if($b[$p] -ne 0xFF){ break }
            $m = $b[$p+1]
            if($m -eq 0xFF){ $p++; continue }
            if($m -eq 0xD9){ if($scan){ $end = $p + 2 }; break }        ## end marker: the image may end the data
            if(($m -ge 0xD0 -and $m -le 0xD7) -or $m -eq 0x01){ $p += 2; continue }
            if($p + 4 -gt $b.Length){ break }
            $len = ([int]$b[$p+2] -shl 8) -bor $b[$p+3]      ## [int]: a [byte] shifted left stays a byte (and becomes 0)
            if($len -lt 2){ break }
            $p += 2 + $len
            if($m -eq 0xDA){
                $scan = $true
                ## Skip the compressed image data: stop at the next real marker (not FF00 or a restart marker)
                while($true){
                    $p = $s.IndexOf([char]0xFF, [int][math]::Min($p, $s.Length))
                    if($p -lt 0 -or $p + 1 -ge $b.Length){ $p = $b.Length; break }
                    $q = $b[$p+1]
                    if($q -eq 0 -or $q -eq 0xFF -or ($q -ge 0xD0 -and $q -le 0xD7)){ $p++; continue }
                    break
                }
            }
        }
        if($end -gt 0){ [void]$found.Add((docSlice_ $b $i $end)); $i = $s.IndexOf($sig, [int]$end, $ord) }
        else{ $i = $s.IndexOf($sig, $i + 3, $ord) }
    }
    Return ,$found
}

## decodeDoc helper: read the streams out of an OLE2 compound file (legacy .doc/.xls/.ppt,
## vbaProject.bin, password-protected .docx/.xlsx/.pptx). This only reads the file's structure;
## nothing in it is run. Returns a list of @{Path; Name; Bytes}, empty if it isn't OLE2.
function docCfb_([byte[]]$b){
    $out = New-Object System.Collections.ArrayList
    if($null -eq $b -or $b.Length -lt 1024 -or [BitConverter]::ToString($b,0,8) -ne 'D0-CF-11-E0-A1-B1-1A-E1'){ Return ,$out }
    $ss = 1 -shl [BitConverter]::ToUInt16($b,0x1E)
    if($ss -notin 512,4096 -or [BitConverter]::ToUInt16($b,0x20) -ne 6){ Return ,$out }
    $cut = [BitConverter]::ToUInt32($b,0x38)
    $per = $ss / 4
    $nsec = [math]::Floor(($b.Length - $ss) / $ss)

    ## Follow a sector chain; stops at the end marker, bad entries or loops
    function cfbRead_($start,$size,$tbl,$src,$unit,$base){
        $ms = New-Object IO.MemoryStream
        $sec = $start; $g = 0
        while($sec -ge 0 -and $sec -lt $tbl.Length -and $g -le $tbl.Length){
            $o = $base + $sec * $unit
            if($o + $unit -gt $src.Length){ break }
            $ms.Write($src, $o, $unit)
            $sec = $tbl[$sec]; $g++
        }
        $r = $ms.ToArray()
        if($size -ge 0 -and $size -lt $r.Length){ $r = docSlice_ $r 0 $size }
        Return ,$r
    }

    ## Sectors holding the FAT: 109 listed in the header, the rest in the DIFAT chain
    $fatSecs = New-Object System.Collections.Generic.List[int]
    for($k = 0; $k -lt 109; $k++){
        $v = [BitConverter]::ToInt32($b, 0x4C + 4*$k)
        if($v -ge 0 -and $v -lt $nsec){ $fatSecs.Add($v) }
    }
    $d = [BitConverter]::ToInt32($b,0x44); $g = 0
    while($d -ge 0 -and $d -lt $nsec -and $g -lt $nsec){
        $o = ($d + 1) * $ss
        for($k = 0; $k -lt $per - 1; $k++){
            $v = [BitConverter]::ToInt32($b, $o + 4*$k)
            if($v -ge 0 -and $v -lt $nsec){ $fatSecs.Add($v) }
        }
        $d = [BitConverter]::ToInt32($b, $o + $ss - 4); $g++
    }
    $fat = New-Object int[] ($fatSecs.Count * $per)
    for($k = 0; $k -lt $fatSecs.Count; $k++){ [Buffer]::BlockCopy($b, ($fatSecs[$k] + 1) * $ss, $fat, $k * $ss, $ss) }

    ## Directory entries (128 bytes each)
    $dirB = cfbRead_ ([BitConverter]::ToInt32($b,0x30)) (-1) $fat $b $ss $ss
    $n = [math]::Floor($dirB.Length / 128)
    if($n -lt 1 -or $dirB[66] -ne 5){ Return ,$out }        ## entry 0 must be the root
    $dirs = New-Object object[] $n
    for($k = 0; $k -lt $n; $k++){
        $o = $k * 128
        $nl = [BitConverter]::ToUInt16($dirB, $o + 64)
        $name = ''
        if($nl -ge 2 -and $nl -le 64){ $name = [Text.Encoding]::Unicode.GetString($dirB, $o, $nl - 2) }
        $dirs[$k] = @{
            Name = $name; Type = $dirB[$o + 66]
            L = [BitConverter]::ToInt32($dirB, $o + 68); R = [BitConverter]::ToInt32($dirB, $o + 72)
            C = [BitConverter]::ToInt32($dirB, $o + 76); Start = [BitConverter]::ToInt32($dirB, $o + 116)
            Size = [int64][BitConverter]::ToUInt32($dirB, $o + 120)
        }
    }

    ## Small streams live in the "mini stream", indexed by the mini FAT
    $mini = cfbRead_ $dirs[0].Start $dirs[0].Size $fat $b $ss $ss
    $mfB = cfbRead_ ([BitConverter]::ToInt32($b,0x3C)) (-1) $fat $b $ss $ss
    $mfat = New-Object int[] ([math]::Floor($mfB.Length / 4))
    [Buffer]::BlockCopy($mfB, 0, $mfat, 0, $mfat.Length * 4)

    ## Walk the storage tree (each storage's children are a tree of siblings)
    $stack = New-Object System.Collections.Stack
    $seen = @{}
    $stack.Push(@($dirs[0].C, ''))
    while($stack.Count){
        $it = $stack.Pop(); $k = $it[0]; $pre = $it[1]
        if($k -lt 0 -or $k -ge $n -or $seen.ContainsKey($k)){ continue }
        $seen[$k] = 1
        $e = $dirs[$k]
        $stack.Push(@($e.L, $pre)); $stack.Push(@($e.R, $pre))
        $path = "$pre$($e.Name)"
        if($e.Type -eq 1){ $stack.Push(@($e.C, "$path/")) }
        elseif($e.Type -eq 2){
            $size = [math]::Min($e.Size, [int64]$b.Length)
            if($size -lt $cut){ $data = cfbRead_ $e.Start $size $mfat $mini 64 0 }
            else{ $data = cfbRead_ $e.Start $size $fat $b $ss $ss }
            [void]$out.Add([pscustomobject]@{ Path = $path; Name = $e.Name; Bytes = $data })
        }
    }
    Return ,$out
}

## decodeDoc helper: macro module names from a VBA project's streams (the PROJECT stream lists
## them in plain text). This lists the modules; the macro source itself stays compressed.
function docVbaNames_($streams){
    $names = New-Object System.Collections.ArrayList
    foreach($st in $streams){
        if($st.Name -ceq 'PROJECT'){
            $txt = [Text.Encoding]::GetEncoding(28591).GetString($st.Bytes)
            foreach($ln in ($txt -split "`r?`n")){
                if($ln -match '^(Module|Document|Class|BaseClass)=([^/]+)'){ [void]$names.Add("$($Matches[2]) ($($Matches[1]))") }
            }
        }
    }
    if(-not $names.Count){      ## No PROJECT stream: fall back to the module streams' names
        foreach($st in $streams){
            if($st.Path -match '(^|/)VBA/' -and $st.Name -notmatch '^(dir|_VBA_PROJECT|__SRP_\d+|PROJECT.*)$'){
                [void]$names.Add($st.Name)
            }
        }
    }
    Return ,$names
}

## decodeDoc helper: readable text runs in binary data, both 8-bit and UTF-16 (like 'strings'),
## kept in the order they appear. UTF-16 runs are limited to Latin, Cyrillic and punctuation
## characters, so random bytes don't come out as fake Asian text.
function docStrings_([byte[]]$b,$min=4){
    $runs = New-Object System.Collections.ArrayList
    if($null -eq $b -or $b.Length -lt $min){ Return '' }
    $l1 = [Text.Encoding]::GetEncoding(28591).GetString($b)
    foreach($m in [regex]::Matches($l1, "[\x20-\x7E\t]{$min,}")){ [void]$runs.Add(@($m.Index, $m.Value)) }
    foreach($off in 0,1){
        $len = ($b.Length - $off) - (($b.Length - $off) % 2)
        if($len -lt 2){ continue }
        $u = [Text.Encoding]::Unicode.GetString($b, $off, $len)
        foreach($m in [regex]::Matches($u, "[\u0020-\u007E\u00A0-\u024F\u0400-\u04FF\u2010-\u206F\t]{$min,}")){
            [void]$runs.Add(@(($off + 2 * $m.Index), $m.Value))
        }
    }
    $t = @($runs | Sort-Object { $_[0] } | %{ $_[1].Trim() } | ?{ $_ }) -join "`n"
    Return [regex]::Replace($t, '[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]', { param($m) '[U+{0:X4}]' -f [int][char]$m.Value })
}

## decodeDoc helper: walk an .xls Workbook stream. Joins the drawing records (images are split
## across CONTINUE records), flags Excel 4.0 macro sheets and notices encryption.
function docBiff_([byte[]]$w){
    $draw = New-Object IO.MemoryStream
    $xlm = New-Object System.Collections.ArrayList
    $enc = $false; $p = 0; $last = 0
    $state = @('visible','hidden','very hidden','unknown')
    while($p + 4 -le $w.Length){
        $id = [BitConverter]::ToUInt16($w,$p); $len = [BitConverter]::ToUInt16($w,$p + 2)
        $d = $p + 4
        if($d + $len -gt $w.Length){ break }
        if($id -eq 0x00EB -or ($id -eq 0x003C -and $last -eq 0x00EB)){ $draw.Write($w,$d,$len); $last = 0x00EB }
        else{ $last = $id }
        if($id -eq 0x002F){ $enc = $true }
        if($id -eq 0x0085 -and $len -ge 8 -and $w[$d + 5] -eq 1){        ## BOUNDSHEET for a macro sheet
            $cch = $w[$d + 6]
            if($w[$d + 7] -band 1){ $nm = [Text.Encoding]::Unicode.GetString($w, $d + 8, [math]::Min($cch * 2, $len - 8)) }
            else{ $nm = [Text.Encoding]::GetEncoding(28591).GetString($w, $d + 8, [math]::Min($cch, $len - 8)) }
            [void]$xlm.Add("Excel 4.0 macro sheet: $nm ($($state[$w[$d + 4] -band 3]))")
        }
        $p = $d + $len
    }
    Return @{ draw = $draw.ToArray(); xlm = $xlm; enc = $enc }
}

function decodeDoc($filepath,[switch]$nosave,$outfile=$null,[switch]$images){   #mp
    <#
    ||shorthelp||
    decodeDoc [-f PATH_TO_FILE] [-n NO_OUTPUT_FILE] [-o OUTPUT_FILENAME (optional)]
        [-i EXTRACT_IMAGES]

    ||longhelp||
    Extract plaintext from Microsoft Office and LibreOffice/OpenOffice documents without
    opening them in Office. Nothing inside the document is run. This function also lists
    any macros it finds and adds them to the output file:
        -Word macro names, and the module names in any VBA project (.docm, .xlsm, .pptm,
         .doc, .xls, .ppt). The VBA source itself is compressed and is not shown.
        -LibreOffice Basic macros and scripts, with their full source code
        -Macros that a LibreOffice document runs on an event (like opening it)
        -Excel 4.0 macro sheets, including hidden ones
    It also notes password protection, hidden sheets, and links to outside resources
    (like a remote template) that the document would reach out to when opened.

    Everything is saved to a folder in your MACROSS outputs ($dyrl_OUTFILES) named after
    the document without its extension, and the .txt file keeps the extension, e.g.
    "Suspicious\Suspicious.docx.txt". Documents with the same name in different formats
    share the folder ("Suspicious\Suspicious.doc.txt" goes next to it). Use -o to choose a
    different name for the .txt file; the folder name stays the same. (If a file with the
    folder's name is already in the outputs folder, the folder gets ".decoded" added.)

    If the document has images, you'll be asked whether to extract them into the same
    folder. Use -i to extract them without asking. Image files start with the document's
    name ("Suspicious.docx_001_image1.png") so they don't mix with images from the other
    formats. They are saved by their real type (not their name), and SVG images are saved
    as .svg.txt because they can hold scripts.

    Every PNG found (extracted or not) is checked for extra data after its end marker, a
    common way to hide a payload in a picture, and for a broken internal structure. These
    show as red ALERT lines on screen and in an "!! ALERTS" section at the top of the .txt
    file. (PNGs cut out of the older binary formats always end at their end marker, so this
    check can't see hidden data there.)

    Use -n to receive a hashtable instead of saving the .txt file:
        .vb      = list of macros found
        .pt      = list of plaintext sections ("## <part name>" on the first line)
        .links   = links to outside resources
        .notes   = warnings (password protection, hidden sheets, skipped parts)
        .alerts  = signs of something hidden on purpose (data after a PNG's end marker)
        .img     = paths of extracted images (only with -i)
        .imgct   = number of images found
        .format  = the document format
    With -n you are never asked about images; add -i to extract them.

    Handles doc, docx, docm, dot, dotx, dotm, xls, xlsx, xlsm, xlsb, ppt, pptx, pptm,
    odt, ods, odp, odg, ott, ots, otp, sxw, sxc, sxi, and the flat XML formats (fodt, fods,
    fodp, fodg, Word XML). The format is detected from the file's contents, so renamed files
    are handled correctly. For the older binary formats (doc, xls, ppt) the text is pulled out
    as readable runs (like the 'strings' tool), so it can include some formatting leftovers,
    and only their PNG and JPEG images can be extracted.

    ||examples||
        ## Get plaintext without saving to file:
            $plaintext = decodeDoc "C:\Users\Me\Documents\Suspicious.docx" -n
            $plaintext.vb       ## List of macros, if any
            $plaintext.pt       ## List of plaintext sections from the document

        ## Write plaintext to "Suspicious\report001.txt" in the outputs folder:
            decodeDoc "C:\Users\Me\Documents\Suspicious.docx" -o 'report001'

        ## Write plaintext to "Suspicious\Suspicious.ods.txt" in the outputs folder, and
        ## extract any images without asking:
            decodeDoc "C:\Users\Me\Documents\Suspicious.ods" -i

    #>

    if(-not $filepath -or -not (Test-Path -LiteralPath $filepath -PathType Leaf)){
        errMsg -m "decodeDoc: file not found: $filepath" -c r -f 'MACROSS.decodeDoc'
        Return
    }
    $filepath = (Resolve-Path -LiteralPath $filepath).ProviderPath
    $src = Split-Path $filepath -Leaf
    ## Folder = name without extension, so other formats of the same document share it;
    ## the .txt keeps the extension ("Suspicious\Suspicious.docx.txt")
    $base = [IO.Path]::GetFileNameWithoutExtension($src)
    if(-not $base){ $base = $src }
    $folder = "$dyrl_OUTFILES\$base"
    ## A file with the folder's name may already be in the outputs folder
    if(Test-Path -LiteralPath $folder -PathType Leaf){ $folder = "$folder.decoded" }
    if($outfile){ $tname = [IO.Path]::GetFileNameWithoutExtension((Split-Path "$outfile" -Leaf)) }
    else{ $tname = $src }
    if(-not $tname){ $tname = 'document' }
    $fn = "$folder\$tname.txt"

    $maxPart = 64MB                 ## Largest part we'll unpack from a zip-based document
    $maxFile = 256MB                ## Largest file we'll read into memory whole
    $msa = mkList                   ## macros
    $fnt = mkList                   ## plaintext sections
    $notes = mkList                 ## warnings
    $alerts = mkList                ## findings that suggest something was hidden on purpose
    $links = mkList                 ## outside resources
    $imgs = New-Object System.Collections.ArrayList     ## @{ Name; Bytes }
    $seen = @{}                     ## de-duplicates macros/links
    function addOnce_($list,$val){ if(-not $seen.ContainsKey($val)){ $seen[$val] = 1; [void]$list.Add($val) } }
    $b64 = { param($s) try{ ,[Convert]::FromBase64String(($s -replace '\s','')) }catch{ ,$null } }

    $kind = docKind_ $filepath
    $x = $null
    try{
        if($kind -eq 'zip'){
            Add-Type -Assembly System.IO.Compression.FileSystem
            $x = [IO.Compression.ZipFile]::OpenRead($filepath)
            $names = @($x.Entries | %{ $_.FullName })
            if($names -contains 'mimetype' -or $names -contains 'content.xml'){ $fmt = 'OpenDocument (LibreOffice/OpenOffice)' }
            elseif($names -contains '[Content_Types].xml'){ $fmt = 'Office Open XML (MS Office 2007+)' }
            else{ $fmt = 'zip archive' }

            ## OpenDocument password protection: the manifest lists the encrypted parts
            $crypt = @{}
            $man = @($x.Entries | ?{ $_.FullName -eq 'META-INF/manifest.xml' })
            if($man.Count){
                $mt = [Text.Encoding]::UTF8.GetString((docEntryBytes_ $man[0] $maxPart))
                foreach($seg in ($mt -split '<manifest:file-entry')){
                    if($seg -match '<manifest:encryption-data' -and $seg -match 'manifest:full-path="([^"]+)"'){ $crypt[$Matches[1]] = 1 }
                }
                if($crypt.Count){ addOnce_ $notes "Password-protected: $($crypt.Count) parts are encrypted and can't be read without the password" }
            }

            ## Parts that only hold formatting, layouts or settings (no document text)
            $noise = '^(\[Content_Types\]\.xml|word/(styles|stylesWithEffects|fontTable|settings|webSettings|numbering)\.xml|(word|xl|ppt)/theme/|xl/styles\.xml|ppt/(slideMasters|slideLayouts|presProps|viewProps|tableStyles)|META-INF/|settings\.xml|Configurations2/|manifest\.rdf)'

            foreach($e in $x.Entries){
                $p = $e.FullName
                if($p.EndsWith('/') -or $crypt.ContainsKey($p)){ continue }
                try{
                    if($p -match '(^|/)vbaProject\.bin$'){
                        $mods = docVbaNames_ (docCfb_ (docEntryBytes_ $e $maxPart))
                        if($mods.Count){ addOnce_ $msa "VBA project ($p), modules: $($mods -join ', ')" }
                        else{ addOnce_ $msa "VBA project ($p)" }
                    }
                    elseif($p -match '^(word|xl|ppt)/media/|^Pictures/|^Thumbnails/|^docProps/thumbnail\.'){
                        [void]$imgs.Add(@{ Name = $p; Bytes = (docEntryBytes_ $e $maxPart) })
                    }
                    elseif($p -match '^Basic/.+\.xml$'){
                        if($p -notmatch '/(script|dialog)-l[bc]\.xml$'){
                            $raw = [Text.Encoding]::UTF8.GetString((docEntryBytes_ $e $maxPart))
                            if($raw -match '(?s)<script:module\b[^>]*>(.*)</script:module>'){
                                addOnce_ $msa "LibreOffice Basic macro ($p):`n$([System.Net.WebUtility]::HtmlDecode($Matches[1]).Trim())"
                            }
                        }
                    }
                    elseif($p -match '^Scripts/.+[^/]$'){
                        addOnce_ $msa "Script ($p):`n$([Text.Encoding]::UTF8.GetString((docEntryBytes_ $e $maxPart)).Trim())"
                    }
                    elseif($p -match '\.rels$'){
                        ## External targets: remote templates, linked objects, web links
                        $raw = [Text.Encoding]::UTF8.GetString((docEntryBytes_ $e $maxPart))
                        foreach($m in [regex]::Matches($raw,'<Relationship\b[^>]*>')){
                            if($m.Value -match 'TargetMode="External"' -and $m.Value -match '\bTarget="([^"]*)"'){
                                $tg = [System.Net.WebUtility]::HtmlDecode($Matches[1])
                                $ty = ''; if($m.Value -match '\bType="[^"]*/([^"/]+)"'){ $ty = $Matches[1] }
                                addOnce_ $links "$tg  ($ty, from $p)"
                            }
                        }
                    }
                    elseif($p -match '\.xml$' -and $p -notmatch $noise){
                        $raw = [Text.Encoding]::UTF8.GetString((docEntryBytes_ $e $maxPart))
                        if($p -match '(^|/)vbaData\.xml$'){
                            $mn = @([regex]::Matches($raw,'wne:macroName="([^"]+)"') | %{ $_.Groups[1].Value })
                            if($mn.Count){ addOnce_ $msa "Word macro names ($p): $($mn -join ', ')" }
                            continue
                        }
                        if($p -match '^xl/macrosheets/'){ addOnce_ $msa "Excel 4.0 macro sheet ($p)" }
                        if($p -eq 'xl/workbook.xml'){
                            foreach($m in [regex]::Matches($raw,'<sheet\b[^>]*>')){
                                if($m.Value -match 'state="(hidden|veryHidden)"'){
                                    $st = $Matches[1]
                                    if($m.Value -match '\bname="([^"]*)"'){ addOnce_ $notes "Sheet '$([System.Net.WebUtility]::HtmlDecode($Matches[1]))' is $st" }
                                }
                            }
                        }
                        foreach($m in [regex]::Matches($raw,'vnd\.sun\.star\.script:[^"''<>\s]+')){
                            addOnce_ $msa "Macro run by a document event ($p): $([System.Net.WebUtility]::HtmlDecode($m.Value))"
                        }
                        $t = docText_ $raw
                        if($t){ [void]$fnt.Add("## $p`n$t") }
                    }
                }
                catch{ addOnce_ $notes "Skipped $p`: $($_.Exception.Message)" }
            }
        }
        elseif($kind -eq 'xml'){
            if((Get-Item -LiteralPath $filepath).Length -gt $maxFile){ throw "the file is larger than 256 MB" }
            $raw = [IO.File]::ReadAllText($filepath)
            if($raw -match '<office:document\b'){ $fmt = 'Flat OpenDocument XML (LibreOffice .fodt/.fods/.fodp/.fodg)' }
            elseif($raw -match '<pkg:package\b'){ $fmt = 'Flat Office Open XML (Word/PowerPoint XML)' }
            elseif($raw -match '<w:wordDocument\b'){ $fmt = 'Word 2003 XML' }
            else{ $fmt = 'XML' }

            foreach($m in [regex]::Matches($raw,'(?s)<ooo:module\b[^>]*ooo:name="([^"]*)"[^>]*>\s*<ooo:source-code>(.*?)</ooo:source-code>')){
                addOnce_ $msa "LibreOffice Basic macro ($($m.Groups[1].Value)):`n$([System.Net.WebUtility]::HtmlDecode($m.Groups[2].Value).Trim())"
            }
            foreach($m in [regex]::Matches($raw,'vnd\.sun\.star\.script:[^"''<>\s]+')){
                addOnce_ $msa "Macro run by a document event: $([System.Net.WebUtility]::HtmlDecode($m.Value))"
            }
            foreach($m in [regex]::Matches($raw,'(?s)<pkg:part\b[^>]*pkg:name="([^"]+)"[^>]*>\s*<pkg:binaryData>(.*?)</pkg:binaryData>')){
                $data = & $b64 $m.Groups[2].Value
                if($null -eq $data){ continue }
                if($m.Groups[1].Value -match 'vbaProject\.bin$'){
                    $mods = docVbaNames_ (docCfb_ $data)
                    addOnce_ $msa "VBA project ($($m.Groups[1].Value)), modules: $($mods -join ', ')"
                }
                else{ [void]$imgs.Add(@{ Name = $m.Groups[1].Value; Bytes = $data }) }
            }
            foreach($m in [regex]::Matches($raw,'(?s)<pkg:part\b[^>]*pkg:name="([^"]+\.rels)"[^>]*>(.*?)</pkg:part>')){
                foreach($r in [regex]::Matches($m.Groups[2].Value,'<Relationship\b[^>]*>')){
                    if($r.Value -match 'TargetMode="External"' -and $r.Value -match '\bTarget="([^"]*)"'){
                        addOnce_ $links "$([System.Net.WebUtility]::HtmlDecode($Matches[1]))  (from $($m.Groups[1].Value))"
                    }
                }
            }
            $k = 0
            foreach($m in [regex]::Matches($raw,'(?s)<office:binary-data>(.*?)</office:binary-data>')){
                $k++; $data = & $b64 $m.Groups[1].Value
                if($null -ne $data){ [void]$imgs.Add(@{ Name = "image$k"; Bytes = $data }) }
            }
            foreach($m in [regex]::Matches($raw,'(?s)<w:binData\b[^>]*w:name="([^"]*)"[^>]*>(.*?)</w:binData>')){
                if($m.Groups[1].Value -match 'editdata\.mso'){ addOnce_ $msa 'Word 2003 XML: embedded macro storage (editdata.mso)'; continue }
                $data = & $b64 $m.Groups[2].Value
                if($null -ne $data){ [void]$imgs.Add(@{ Name = $m.Groups[1].Value; Bytes = $data }) }
            }
            $t = docText_ $raw
            if($t){ [void]$fnt.Add("## $src`n$t") }
        }
        else{
            if($kind -eq 'ole'){
                $fmt = 'OLE2 compound file (MS Office 97-2003)'
                if((Get-Item -LiteralPath $filepath).Length -le $maxFile){
                    $streams = docCfb_ ([IO.File]::ReadAllBytes($filepath))
                    if(@($streams | ?{ $_.Name -eq 'EncryptedPackage' }).Count){
                        $fmt = 'Password-protected Office Open XML (.docx/.xlsx/.pptx)'
                        addOnce_ $notes "Password-protected: the document's contents are encrypted and can't be read without the password"
                    }
                    $mods = docVbaNames_ $streams
                    if($mods.Count){ addOnce_ $msa "VBA project, modules: $($mods -join ', ')" }
                    foreach($st in $streams){
                        if($st.Path -match '(^|/)(VBA|_VBA_PROJECT_CUR)/'){ continue }
                        ## Text: readable runs from the streams that hold document text and properties
                        if($st.Name -match '^(WordDocument|PowerPoint Document|Workbook|Book|Current User|.?SummaryInformation|.?DocumentSummaryInformation)$'){
                            $t = docStrings_ $st.Bytes
                            if($t){ [void]$fnt.Add("## $($st.Path -replace '[\x00-\x1F]','') (text runs)`n$t") }
                        }
                        if($st.Bytes.Length -lt 100){ continue }
                        $data = $st.Bytes
                        if($st.Name -in 'Workbook','Book'){
                            $bf = docBiff_ $data
                            $data = $bf.draw
                            foreach($xm in $bf.xlm){ addOnce_ $msa $xm }
                            if($bf.enc){ addOnce_ $notes 'Password-protected: the workbook is encrypted, so its text and images are unreadable' }
                        }
                        foreach($img in (docCarve_ $data)){ [void]$imgs.Add(@{ Name = "$($st.Name)-image"; Bytes = $img }) }
                    }
                }
                else{ addOnce_ $notes 'The file is larger than 256 MB; images and macro names were not scanned' }
            }
            else{ $fmt = 'Unrecognized format (raw text scan)' }

            ## Unknown formats (or an OLE2 file whose streams couldn't be read): just read the raw text
            if($kind -ne 'ole' -or -not $fnt.Count){
                $findvba = Get-Content -LiteralPath $filepath
                $findstr = [IO.File]::ReadLines($filepath)

                ## If 'VBA...DLL' and 'Sub ' are in the same doc, it's likely a macro
                if( $findvba | Select-String -CaseSensitive 'VBA' | Select-String 'dll' ){
                    $mac = ($findvba | Select-String -Pattern "Sub .+\(\)") -replace $dyrl_ASCII
                    $mac = $mac -replace "^Sub " -replace "\(\)"
                    if("$mac".Trim()){ addOnce_ $msa "Possible macro names (raw scan): $($mac -join ', ')" }
                }
                [void]$fnt.Add("## raw text`n$(@($findstr) -join "`n")")
                Remove-Variable findstr,findvba
            }
        }
    }
    catch{
        errLog ERROR 'MACROSS.decodeDoc' "$src`: $($_.Exception.Message)"
        addOnce_ $notes "Extraction stopped early: $($_.Exception.Message)"
    }
    finally{
        if($null -ne $x){ $x.Dispose() }
    }

    ## Keep only real images (by their bytes), once each
    $sha = [Security.Cryptography.SHA256]::Create()
    $hashes = @{}
    $found = New-Object System.Collections.ArrayList
    foreach($im in $imgs){
        $ext = docImgType_ $im.Bytes
        if(-not $ext){ continue }
        $h = [BitConverter]::ToString($sha.ComputeHash($im.Bytes))
        if($hashes.ContainsKey($h)){ continue }
        $hashes[$h] = 1
        [void]$found.Add(@{ Name = $im.Name; Bytes = $im.Bytes; Ext = $ext })

        ## PNGs: anything after the end marker could be a hidden payload ("#n" = the extracted file's number)
        if($ext -eq 'png'){
            $pt = docPngTail_ $im.Bytes
            if($pt.Bad){ addOnce_ $alerts "PNG #$($found.Count) ($($im.Name)): its internal structure is broken, so it may not really be an image" }
            elseif($pt.Extra -gt 0){ addOnce_ $alerts "PNG #$($found.Count) ($($im.Name)): $($pt.Extra) bytes of extra data after the image's end marker; $($pt.Hint)" }
        }
    }
    foreach($a in $alerts){ w "ALERT ($src): $a" r }
    $sha.Dispose()

    $doImg = [bool]$images
    if($found.Count -and -not $images -and -not $nosave){
        $doImg = (yorn -l 'decodeDoc' -q "Found $($found.Count) image(s) in $src. Extract them to $folder ?" -b 4 -i 32) -eq 'Yes'
    }
    $saved = mkList
    if($doImg -and $found.Count){
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
        $k = 0
        foreach($im in $found){
            $k++
            $ibase = [IO.Path]::GetFileNameWithoutExtension(($im.Name -split '/')[-1]) -replace '[^\w.-]','_'
            if(-not $ibase){ $ibase = 'image' }
            $out = "$folder\{0}_{1:D3}_{2}.{3}" -f $src, $k, $ibase, $im.Ext     ## document name + number: never collide
            [IO.File]::WriteAllBytes($out, $im.Bytes)
            [void]$saved.Add($out)
        }
    }

    if($nosave){
        Return @{ vb = $msa; pt = $fnt; links = $links; notes = $notes; alerts = $alerts; img = $saved; imgct = $found.Count; format = $fmt }
    }

    $final = mkList
    [void]$final.Add("SOURCE:  $filepath")
    [void]$final.Add("SHA256:  $((Get-FileHash -LiteralPath $filepath -Algorithm SHA256).Hash)")
    [void]$final.Add("FORMAT:  $fmt")
    if($alerts.Count){ [void]$final.Add("`n!! ALERTS:"); $alerts | %{ [void]$final.Add("  - $_") } }
    if($notes.Count){ [void]$final.Add("`nNOTES:"); $notes | %{ [void]$final.Add("  - $_") } }
    if($links.Count){
        [void]$final.Add("`nOUTSIDE LINKS (the document can reach out to these when opened):")
        $links | %{ [void]$final.Add("  - $_") }
    }
    if($msa.Count){ [void]$final.Add("`nFOUND MACROS:"); $msa | %{ [void]$final.Add("$_`n") } }
    if($found.Count){
        if($saved.Count){ [void]$final.Add("`nIMAGES: $($saved.Count) extracted to $folder") }
        else{ [void]$final.Add("`nIMAGES: $($found.Count) found, not extracted") }
    }
    [void]$final.Add("$('='*65)`n")
    $fnt | %{ [void]$final.Add("$_`n") }

    try{
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
        noBOM -t "$($final -join "`n")" -f $fn -m
        notepad.exe $fn
    }
    catch{
        $error[0]
        Read-Host
    }
}

function getFile($filter='all',$opendir="H:\",[switch]$directory=$false){   #mp
    <#
    ||shorthelp||
    $file = getFile [-f <all|csv|doc|dox|exe|msg|mso|pdf|ppt|scr|txt|web|xls|zip>]
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
        'xls'="Excel Spreadsheet|*.xlsx; *.xls";
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

function getBlox(){ #mp
    <#
    ||shorthelp||
    getBlox [-t <TITLE> REQUIRED] [-i <INSTRUCTION> OPTIONAL] [-p PREFILL TEXT]

    ||longhelp||
    When your diamond needs users to enter a large block of text, this function
    opens a dialog box where users can type or paste those blocks.

    You must send a title with -t; The default instruction is
    "Use this entry form to add your input", but you can send a different
    instruction with the -i option.

    To pre-fill the text box with string values, use the -p option.

    ||examples||

    $textblock = getBlox 'My Tool Needs Strings'
    $ip_list = getBlox 'My Tool Needs IPs' -i 'Only enter a list of IPs in this box:'

    ## Open the text box with an existing value for the user to keep or change:
    $ip = '192.168.1.1'
    $ip_list = getBlox 'My Tool Needs IPs' -i 'Only enter a list of IPs in this box:' -p $ip


    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$title,
        [string]$instruction="--- Use this entry form to add your input ---",
        [string]$prefill=$null
    )

    ## Preserve newlines
    if($prefill){ $prefill = $prefill -replace "`n","`r`n" }

    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $textEntry = New-Object System.Windows.Forms.Form
    $textEntry.Text = "$title (Use CTRL+ENTER to add a newline)"
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
    $entryBlock.Text = $prefill
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



function houseKeeping($reports,$tool){   #mp
    <#
    ||shorthelp||
    houseKeeping [-r PATH_TO_REPORTS] [-t YOUR_SCRIPTNAME]

    ||longhelp||
    Delete stale reports generated by various tools.

    This function lists all files in the $reports path you provide, and offers
    the choice to delete some, all, or none of the files. Make sure not to pass
    generic folders like 'Desktop' or 'Documents', giving users the opportunity
    to accidentally delete all their stuff!

        Param $reports = the filepath determined by the tool that calls this function,
        Param $tool = your script's name

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
        Write-Host -f YELLOW "       EXISTING $tool REPORTS`n`n"
        $fpath | ForEach-Object{  ## Create a list of the filenames to display onscreen
            $b++
            $n = $_.Name
            $m = $_.LastWriteTime
            $Script:flist += $n
            Write-Host "   $b. $n" -NoNewline;  ## display the filename and its last modified time
            Write-Host ":  $m"
        }
        Write-Host -f GREEN "`n   Select a file to delete, 'a' to delete all of them,  "
        Write-Host -f GREEN "  or 's' to skip:  " -NoNewline;
    }
    function rmFiles($del){
        $reportdir = $reports -replace "\*.*$",''
        #Write-Host 'deleting ' -NoNewline; write-host "$reportdir\$del"  # uncomment for debugging the occasional derp
        Remove-Item -Force -Path "$reportdir\$del"
        if(Test-Path -Path "$reportdir\$del"){
            Write-Host -f CYAN "
            ...Delete action failed!`n"
        }
        else{
            $Script:fcount = $fcount - 1
        }
    }

    $Z = '';

    ''
    while( "$Z" -notMatch "^[0-9]+$" ){
        while($Z -eq ''){
            listFiles
            $Z = Read-Host
        }
        ''
        slp 1
        if( $Z -eq 's' ){    ##  Setting to 99999 skips the final task of selecting files to delete
            $Z = 99999
        }
        elseif( $Z -eq 'a' ){  ## Delete all files in the provided directory if user selects 'a'
            $Z = 99999
            $fpath |
                Foreach-Object{
                    $dn = $_.Name
                    Write-Host -f CYAN "  Deleting $dn...."
                    rmFiles $dn
                    slp 1
                }
        }


        if($Z -ne 99999 -and ("$Z" -notMatch '^\d+$' -or [int]$Z -lt 1 -or [int]$Z -gt $flist.count)){
            Write-Host -f CYAN "  $Z is not on the list."
            $Z = ''
            Continue
        }
        if($Z -ne 99999){
            $Z = $Z - 1
            $fpath |
                Foreach-Object{
                    if($flist[$Z] -eq $_.Name){
                        $dn = $_.Name
                        Write-Host -f CYAN "  Deleting $dn...."
                        rmFiles $dn
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
                    $Z = 99999
                }
            }
        }
    }

    ''
    slp 1

    try{ Remove-Variable -Force fpath }catch{ $null }
    try{ Remove-Variable -Force flist }catch{ $null }
}












