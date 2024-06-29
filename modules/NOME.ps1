#_sdf1 Targeted Active Directory Hunting
#_ver 1.5
#_class admin,active directory,powershell,HiSurfAdvisory,0,none

<#

    If your enterprise service accounts are named a specific way, replace all
    the instances of "service-" in this script with your organization's naming scheme.
    This helps shorten the amount of returns you might receive, though you may
    not always want to do so!
    
    Launching this with the 's' option (like "9s" from the main menu) enables the 
    debugger line that allows you to run commands after the active-directory search
    executes, so that you can view the raw outputs.
    
#>

if($HELP){
    cls
    Write-Host -f YELLOW "
    $($vf19_LATTS['NOME'].toolInfo())
    
    NOME provides a quick way to hunt for anomalies in Active Directory. You
    can select between property lists for users or computers, both of which
    contain dozens of search choices.

    This tool does NOT search or display GPO information, though it can send
    your findings to MYLENE and GERWALK to give you more data. Use MYLENE if
    you need to search specific GPO memberships.

    Hit ENTER to go back.
    "
    Read-Host
    Return
}



function splashPage(){
    cls
    Write-Host '
    '
    $b = 'ICAgICAgICAgIOKWiOKWiOKWiOKVlyAgIOKWiOKWiOKVlyDilojilojilojilojilojilojilZcg4paI4paI4paI4pWXICAg4paI4pa
    I4paI4pWX4paI4paI4paI4paI4paI4paI4paI4pWXCiAgICAgICAgICDilojilojilojilojilZcgIOKWiOKWiOKVkeKWiOKWiOKVlOKVkOKV
    kOKVkOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKVlyDilojilojilojilojilZHilojilojilZTilZDilZDilZDilZDilZ0KICAgICAgICAgIOKWi
    OKWiOKVlOKWiOKWiOKVlyDilojilojilZHilojilojilZEgICDilojilojilZHilojilojilZTilojilojilojilojilZTilojilojilZHilo
    jilojilojilojilojilZcgIAogICAgICAgICAg4paI4paI4pWR4pWa4paI4paI4pWX4paI4paI4pWR4paI4paI4pWRICAg4paI4paI4pWR4pa
    I4paI4pWR4pWa4paI4paI4pWU4pWd4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4pWdICAKICAgICAgICAgIOKWiOKWiOKVkSDilZrilojiloji
    lojilojilZHilZrilojilojilojilojilojilojilZTilZ3ilojilojilZEg4pWa4pWQ4pWdIOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWi
    OKWiOKVlwogICAgICAgICAg4pWa4pWQ4pWdICDilZrilZDilZDilZDilZ0g4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWdIOKVmuKVkOKVnSAgICAg4p
    Wa4pWQ4pWd4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWdCiAgPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0
    9PT09PT09CiAgICBGaW5kIHVzZXJzIG9yIGhvc3RzIGJ5IEFjdGl2ZS1EaXJlY3RvcnkgcHJvcGVydGllcw=='
    getThis $b
    Write-Host -f YELLOW $vf19_READ
    ''
}

## User account properties
$dyrl_sn_userslist = @{
    '01'='AccountExpirationDate';
    '02'='AccountLockoutTime';
    '03'='badLogonCount';
    '04'='badPasswordTime';
    '05'='CanonicalName';
    '06'='CN';
    '07'='Created';
    '08'='Deleted';
    '09'='Department';
    '10'='Description';
    '11'='DisplayName';
    '12'='DistinguishedName';
    '13'='isDeleted';
    '14'='DoesNotRequirePreAuth (b)';
    '15'='EmailAddress';
    '16'='Enabled (b)';
    '17'='HomeDirectory';
    '18'='HomeDrive';
    '19'='info';
    '20'='LastBadPasswordAttempt';
    '21'='LastLogonDate';
    '22'='LockedOut (b)';
    '23'='LockoutTime';
    '24'='logonCount';
    '25'='LogonWorkstations'
    '26'='msNPAllowDialin (b)';
    '27'='Modified';
    '28'='Name';
    '29'='Office';
    '30'='OfficePhone';
    '31'='Organization';
    '32'='otherTelephone';
    '33'='otherName';
    '34'='PasswordNotRequired (b)';
    '35'='PasswordExpired (b)';
    '36'='PasswordLastSet';
    '37'='PasswordNeverExpires (b)';
    '38'='PrimaryGroupID';
    '39'='ProfilePath';
    '40'='ProtectedFromAccidentalDeletion (b)';
    '41'='pwdLastSet';
    '42'='roomNumber';
    '43'='ScriptPath';
    '44'='SmartCardLogonRequired (b)'
    '45'='samAccountName';
    '46'='SID';
    '47'='telephoneNumber';
    '48'='Title';
    '49'='uid';
    '50'='userPrincipalName'
}


## Computer properties
$dyrl_sn_hostslist = @{
    '01'='AccountExpirationDate';
    '02'='AccountLockoutDate';
    '03'='adminDescription';
    '04'='CanonicalName';
    '05'='CN';
    '06'='Created';
    '07'='Deleted';
    '08'='Description';
    '09'='DisplayName';
    '10'='DistinguishedName';
    '11'='DNSHostName';
    '12'='DoesNotRequirePreAuth (b)';
    '13'='Enabled (b)';
    '14'='IPv4Address';
    '15'='IPv6Address';
    '16'='isCriticalSystemObject (b)';
    '17'='isDeleted';
    '18'='LastLogonDate';
    '19'='Location';
    '20'='LockedOut (b)';
    '21'='logonCount';
    '22'='ManagedBy';
    '23'='Modified';
    '24'='Name';
    '25'='OperatingSystem';
    '26'='OperatingSystemVersion';
    '27'='PasswordExpired (b)';
    '28'='PasswordLastSet';
    '29'='PasswordNeverExpires (b)';
    '30'='ProtectedFromAccidentalDeletion (b)';
    '31'='PasswordNotRequired (b)';
    '32'='ServiceAccount';
    '33'='servicePrincipalName';
    '34'='SID'
}


## Properties that are int-only
$dyrl_sn_intlist = @(
    'logonCount',
    'badLogonCount',
    'LockoutTime'
)


## Feed the list as $1, and "user" or "computer" as $2
## Returns a list with all results, the property searched, and the value
## specified by the user
function searchAD($1,$2){
    $cmdlet = @{
        'COMPUTER'='Get-ADComputer'
        'USER'='Get-ADUser'
    }
    cls
    $filters = @(); $filterstring = ''
    $specific = @()
    w ''
    w '       ' 'w' 'nl'
    w "ACTIVE DIRECTORY -- SEARCH $2 SETTINGS" 'bl' 'w'
    w ''
    
    $i = 1
    while($i -lt $1.count){
        $k1 = [string]$i; $c1 = 'y'; $c2 = 'y'
        if($i -lt 10){
            $k1 = '0' + $k1
        }
        $i++; $k2 = [string]$i
        if($i -lt 10){
            $k2 = '0' + $k2
        }
        $v1 = $1[$k1]; $v2 = $1[$k2]
        if($v1 -in $dyrl_sn_intlist){$c1 = 'c'}
        $n = 24 - $($v1.length)
        while($n -gt 0){
            $v1 = $v1 + ' '
            $n--
        }
        w "$($k1 -replace "^0",' ')." 'w' 'nl'
        if($v2){
            if($v2 -in $dyrl_sn_intlist){$c2 = 'c'}
            w $v1 $c1 'nl'
            w "$($k2 -replace "^0",' ')." 'w' 'nl'
            w $v2 $c2
        }
        else{
            w $v1 $c1
        }
        $i++
    }
    while([int]$num -notIn 1..$($1.count)){
        w '
        
        '
        w '  ' 'g' 'nl'
        w 'Properties with a (b) can only be True/False; those in blue are integer-only! ' 'bl' 'y'
        w "
    Enter the number for each property you want to search, followed by
    a colon and the value you're filtering on. for multiple filters,
    separate each with a comma.

    -Regex can be used for the non-boolean properties
        (but don't use commas in your pattern)
    -Operators > and < can be used for integer properties
    " 'g'
    
        w '   Example filters --
        ' 'g'
        w '    16:some other values,19:true,11:3/15/2024' 'c' 'nl'
        w ' (Search multiple properties)' 'g'
        w '    9:some string value' 'c' 'nl'
        w '    (Search a single property)' 'g'
        w '    3:>10' 'c' 'nl'
        w '                  (Search an int property for values 10 & higher)
        ' 'g'
        w '
    Enter filters or "q" to quit:
    > ' 'g' 'nl'


        $Z = Read-Host
        if($Z -eq 'q'){
            Exit
        }
        $num = [int]$($Z -replace ":.+")
        $Z -Split(',') | %{
            if($_ -Match "^[0-9]{1}:"){
                $filters += @{$($_ -replace "^",'0' -replace ":.+")=$($_ -replace "^[0-9]+:")}
            }
            else{
                $filters += @{$($_ -replace ":.+")=$($_ -replace "^[0-9]+:")}
            }
        }
        
    }

    $c = $filters.count
    
    foreach($filter in $filters){
        $c--
        $property = $1[$filter.keys]
        $specific += $($property -replace " \(b\)$")
        if($property -Like "* (b)"){
            ## Set boolean filters
            if($filter.values -Match "^f"){
                $filterstring = $filterstring + ' ! $_.' + $($property -replace " \(b\)$")
            }
            else{
                $filterstring = $filterstring + '$_.' + $($property -replace " \(b\)$")
            }
        }
        elseif($property -in $dyrl_sn_intlist){
            if($filter.values -Match "^<\d+$"){
                $filterstring = $filterstring + '$_.' + $property + ' -lt ' + [string]$($filter.values -replace "<")
            }
            elseif($filter.values -Match "^>\d+$"){
                $filterstring = $filterstring + '$_.' + $property + ' -gt ' + [string]$($filter.values -replace ">")
            }
            elseif($filter.values -Match "^\d+$"){
                $filterstring = $filterstring + '$_.' + $property + ' -eq ' + [string]$($filter.values)
            }

        }
        else{
            ## set alphanumeric filters
            $filterstring = $filterstring + '$_.' + $property + ' -Match "' + $($filter.values) + '"'
        }
        if($c -gt 0){
            $filterstring = $filterstring + ' -and '
        }
    }
    
    w '
    Searching...' 'g'
    


    $matches = Invoke-Expression "$($cmdlet[$2]) -filter * -properties * | where{$filterstring}"
    
    
    
    ## If $vf19_OPT1 gets set to $True by launching this script from the MACROSS menu with the "s" option,
    ## the script pauses here so you can run commands and view the $filterstring and $matches outputs.
    ## This requires you to use 'write-host' to actually show outputs onscreen. You change the method to
    ## invoke-expression to make it more friendly.
    if($vf19_OPT1){
        while($z -ne 'q'){
            w '
        DEBUGGING MODE:
            ' 'c'
            w ' $filterstring' 'c' 'nl'; w ' contains your get-ad query, while ' 'g' 'nl'; w '$matches' 'c' 'nl'
            w ' contains your search results (if any).' 'g'
            w ' Use ' 'g' 'nl'; w 'write-host "$($COMMANDS)"' 'y' 'nl' ; w ' to view outputs.' 'g'
            $z = read-host ' debug ("q" to quit)'
            if($z -ne 'q'){
                w ' Result:
                ' 'y'
                $dbg = ([System.Management.Automation.Language.Parser]::ParseInput($z, [ref]$null, [ref]$null)).GetScriptBlock()
                Invoke-Command -NoNewScope $dbg
            }
        }
    }


    if(! $matches){ 
        $matches = 0
    }

    Return @($matches,$specific,$filterstring)

}


function showAccounts($1,$2,$3){
    $i = $3
    $1 | %{
        $U = $_
        if($computer){
            screenResultsAlt $([string]$i + '. ' + $U.Name) 'SYSTEM' $U.OS
        }
        else{
            screenResultsAlt $([string]$i + '. ' + $U.displayName) 'ACCOUNT' $U.samAccountName
        }
        screenResultsAlt 'next' 'DESCRIPTION' $U.description
        $2 | %{
            screenResultsAlt 'next' "$_" "$($U.$_)"
        }
        screenResultsAlt 'endr'
        $i++
    }
    ''
    w ' Enter the number of an account to review,' 'c' 'nl'
    if($limit -ge 0){
        w 'hit ENTER for the next 10,' 'c' 'nl'
    }
    w 'or "n" for a new search:  ' 'c' 'nl'
    $z = Read-Host

    if($z -eq 'n'){
        $Script:dyrl_sn_quit = $true
        Break
    }
    elseif($z -eq ''){
        Return
    }
    else{

        $focus = $dyrl_sn_list[([int]$z - 1)]
        $focus

        ''
        screenResults '         Enter one of the tools below for more data, or hit ENTER to skip.'
        if($dyrl_sn_computer){
            showTools 'hostname'
            $Global:PROTOCULTURE = $focus.name -replace "\.[\w\.\\]+"  ## Remove domain from hostnames
            $extra = 'hlkup'
        }
        else{
            showTools 'user'
            $Global:PROTOCULTURE = $focus.samAccountName -replace "\\\w+"  ## Remove domain from usernames
            $extra = 'usrlkup'
        }
        ''
        $z = Read-Host '  '


        if($z -in $vf19_LATTS.keys){
            w '
            '
            if($vf19_LATTS[$z].valtype -eq 'EDR'){
                $r = (collab $($vf19_LATTS[$z].fname) 'NOME' $extra)
                    if($r){
                        if(($r).count -gt 2){
                            $rr = $($r[1] | ConvertFrom-Json).results
                            $l = $r[2]
                        }
                        else{
                            $rr = $($r[0] | ConvertFrom-Json).results
                            $l = $r[1]
                        }
                    if($rr){
                        $ct = 0
                        $total = ($rr).count

                        screenResults "   Recent activity for $PROTOCULTURE (unsorted; system processes omitted)"
                        screenResults 'c~HOSTNAME' 'c~ACTIVITY' 'c~DATE'

                        while($ct -lt $total){
                            if("$(($rr.process_name[$ct]))" -notIn $l){
                                [string]$cmdl = $($rr.cmdline[$ct])
                                screenResults "$(($rr.hostname[$ct]))  $(($rr.username[$ct]))" "$(($rr.process_name[$ct]))" "$(($rr.start[$ct]))"
                            }
                            $ct++
                        }

                        screenResults 'endr'
                        w '
                        '
                        w '  Hit ENTER to continue.' 'c'
                        Read-Host
                        showAccounts $1 $2 $3
                    }
                }
            }
            elseif($vf19_LATTS[$z].rtype -ne 'onscreen'){
                $rrr = collab $($vf19_LATTS[$z].fname) 'NOME'  ## Clean this up later
            }
            else{
                ''
                collab $($vf19_LATTS[$z].fname) 'NOME'
                showAccounts $1 $2 $3
            }

            if($rrr){
                ''
                $outfile = 'waldo_' + $PROTOCULTURE + '.txt'
                $rrr | Out-File "$vf19_DEFAULTPATH\$outfile"
                w "    Results were written to $outfile on your desktop.
                "
            }
        }
        else{
            showAccounts $1 $2 $3
        }
        $z = $null
        rv extra,rr,r,cmdl,total,ct,z
        rv PROTOCULTURE -Scope Global
    }
}


## Provide a list of relevant tools for more data
function showTools($2){
    $vf19_LATTS.keys | %{
        if($vf19_LATTS[$_].valtype -Match "($2|EDR)" -and $vf19_LATTS[$_].rtype -ne 'none'){
            screenResults $_ $vf19_LATTS[$_].valtype
        }
    }
    screenResults 'endr'
}

function cv(){
    Remove-Variable dyrl_sn_focus,dyrl_sn_extra,dyrl_sn_computer -Scope script
    Remove-Variable PROTOCULTURE -Scope Global
}




while($dyrl_sn_Z -ne 'c'){
    $dyrl_sn_quit = $false
    splashPage

    w '                    SELECT A SINGER:
    ' 'g'
    w '  1. Sheryl Nome (hunt anomalies in USER profiles)
       ' 'g'
    w '  2. Sharon Apple (hunt anomalies in COMPUTER profiles)

    ' 'g'
    w '  (type "c" to cancel):  ' 'g' 'nl'

    $dyrl_sn_Z = Read-Host

    
    if($dyrl_sn_Z -eq 'c'){
        Exit
    }



    if($dyrl_sn_Z -eq 1){
        $dyrl_sn_accounts = searchAD $dyrl_sn_userslist 'USER'
        $dyrl_sn_computer = $false
    }
    elseif($dyrl_sn_Z -eq 2){
        $dyrl_sn_accounts = searchAD $dyrl_sn_hostslist 'COMPUTER'
        $dyrl_sn_computer = $true
    }

    
    function writeToFile($1){
        "account, $($dyrl_sn_accounts[1]), desc" | Out-File "$vf19_DEFAULTPATH\ad_user_search.csv"
        $1 | %{
            "$($_.samAccountName), $($_.$($dyrl_sn_accounts[1])), $($_.description) " | 
            Out-File "$vf19_DEFAULTPATH\ad_user_search.csv" -Append
        }
        ''
        w '  Results have been written to "ad_user_search.csv" on your desktop.' 'y'
        slp 1
    }


    ## If your organization tracks service accounts by naming them a specific way, modify the lines below
    ## by changing "service-" to your naming scheme. If you have other special-type accounts, you can add
    ## more "-Like" and "-notLike" lines, but make sure to include them in the choice menu and 
    ## "$dyrl_sn_choices" list in the section immediately after this!
    if($dyrl_sn_accounts[0] -ne 0){
        $dyrl_sn_Z = $null
        $dyrl_sn_total = $dyrl_sn_accounts[0].count
        $dyrl_sn_svca = ($dyrl_sn_accounts[0] | where{$_.samAccountName -Like "service-*"})
        $dyrl_sn_svcn = ($dyrl_sn_accounts[0] | where{$_.samAccountName -notLike "service-*"})  ## Add more naming patterns as needed
        if(-not $dyrl_sn_svca.count){$dyrl_sn_sc=0}else{$dyrl_sn_sc = $dyrl_sn_svca.count}      ## Also add more .counts as needed
        w '

        '
        if($dyrl_sn_total -gt 21){
            w "  There are" 'g' 'nl'
            w "$dyrl_sn_total" 'y' 'nl'
            w 'accounts matching your search (' 'g' 'nl'
            w "$($dyrl_sn_sc)" 'c' 'nl'
            w  'service accts )' 'g'
            w '  Enter one or more of the following choices (examples, "fo" to view' 'g'
            w '  and save user accounts, or "s" to view service accounts):' 'g'
            w '   -"a" to display them all' 'g'
        ## Add more of these "if" lines if you have added "-Like" names and counts above
        if($dyrl_sn_sc -gt 0){
            w '   -"s" to view service accounts
    -"o" to omit service accounts' 'g'
        }
            w '   -"f" to write them to a file on your desktop
    -"q" to quit' 'g' 
            w '   > ' 'g' 'nl'
            $dyrl_sn_Z = Read-Host
            if($dyrl_sn_Z -eq 'q'){
                Exit
            }
            else{
                $dyrl_sn_list = $false; $write = $false
                $dyrl_sn_choices = @{'o'=$dyrl_sn_svcn; 's'=$dyrl_sn_svca; 'f'=''} ## Add your additional name variables to this list
                foreach($ch in $($dyrl_sn_Z -Split(''))){
                    if($ch -in $dyrl_sn_choices.keys){
                        if($ch -eq 'f'){ $write = $true }
                        else{ [array]$dyrl_sn_list += $dyrl_sn_choices[$ch] }
                    }
                }
            }
            
            
            if(! $dyrl_sn_list ){ $dyrl_sn_list = $dyrl_sn_accounts[0] }
            if($write){ $write = $false; writeToFile $dyrl_sn_list }
            Remove-Variable ch

        }
        else{
            $dyrl_sn_list = $dyrl_sn_accounts[0]
        }

        $dyrl_sn_Z = $null

        if($dyrl_sn_list.count -gt 10){
            $limit = 0
        }

        while(-not $dyrl_sn_quit){
            if($limit -ge 0){
                showAccounts $dyrl_sn_list[$limit .. $($limit + 10)] $dyrl_sn_accounts[1] $($limit + 1)
                if($limit -lt $dyrl_sn_list.count){ $limit = $limit + 10 }
                else{ $dyrl_sn_quit = $true }
            }
            else{ showAccounts $dyrl_sn_list $dyrl_sn_accounts[1] 1 }
        }
        cv
        Remove-Variable dyrl_sn_accounts

    }
    else{
        w '
    
        No accounts found matching your filter:
        ' 'g'
        w "$($dyrl_sn_accounts[2])" 'w'
        w '
        Hit ENTER to continue.' 'g'; Read-Host
    }
}
