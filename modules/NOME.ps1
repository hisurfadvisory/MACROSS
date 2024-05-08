#_sdf1 Targeted Active Directory Hunting
#_ver 1.0
#_class admin,active directory,powershell,HiSurfAdvisory,0,none

<#

    If your enterprise service accounts are named a specific way, replace all
    the instances of "service-" in this script with your organization's naming scheme.
    This helps shorten the amount of returns you might receive, though you may
    not always want to do so!
#>

if($HELP){
    cls
    w "
    NOME uses 3 different lists of Active Directory account properties based
    on what you need to search for.

    If hunting for anomalies, you can filter on the properties most likely
    to raise red-flags.

    You can also perform a search on the most common properties, like user
    descriptions, creation times, etc. to find deviations from what's
    normal in your environment.

    Finally, you can perform searches specific to computer properties to find
    hosts with Active Directory information.

    This tool does NOT search or display GPO information. Use MYLENE to search
    policy memberships.

    Hit ENTER to go back.
    " 'y'
    Read-Host
    Return
}

transitionSplash 9 2

function splashPage(){
    cls
    w '
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
}


## Less common and boolean values
$huntlist = @{
    '01'='AccountExpirationDate';
    '02'='AccountLockoutTime';
    '03'='badLogonCount';
    '04'='badPasswordTime';
    '05'='DoesNotRequirePreAuth (b)';
    '06'='isDeleted';
    '07'='Enabled (b)';
    '08'='LastBadPasswordAttempt';
    '09'='LastLogonDate';
    '10'='LockedOut (b)';
    '11'='LockoutTime';
    '12'='logonCount';
    '13'='msNPAllowDialin (b)';
    '14'='otherName';
    '15'='PasswordExpired (b)';
    '16'='PasswordLastSet';
    '17'='PasswordNeverExpires (b)';
    '18'='PasswordNotRequired (b)';
    '19'='PrimaryGroupID';
    '20'='ProfilePath';
    '21'='ProtectedFromAccidentalDeletion (b)';
    '22'='pwdLastSet';
    '23'='ScriptPath';
    '24'='SmartCardLogonRequired (b)'
}


## String-searchable common properties
$searchlist = @{
    '01'='CanonicalName';
    '02'='CN';
    '03'='Created';
    '04'='Deleted';
    '05'='Department';
    '06'='Description';
    '07'='DisplayName';
    '08'='DistinguishedName';
    '09'='EmailAddress';
    '10'='HomeDirectory';
    '11'='HomeDrive';
    '12'='info';
    '13'='Modified';
    '14'='Name';
    '15'='Office';
    '16'='OfficePhone';
    '17'='Organization';
    '18'='otherTelephone';
    '19'='roomNumber';
    '20'='samAccountName';
    '21'='SID';
    '22'='telephoneNumber';
    '23'='Title';
    '24'='uid';
    '25'='userPrincipalName'
}


## Computers
$hostslist = @{
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
    '19'='LockedOut (b)';
    '20'='logonCount';
    '21'='Modified';
    '22'='OperatingSystem';
    '23'='OperatingSystemVersion';
    '24'='PasswordExpired (b)';
    '25'='PasswordLastSet';
    '26'='PasswordNeverExpires (b)';
    '27'='PasswordNotRequired (b)';
    '28'='ProtectedFromAccidentalDeletion (b)';
    '29'='SID'
}


## Highlight properties that are integer-only; add more as needed
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
    w "
        ACTIVE DIRECTORY -- SEARCH $2 SETTINGS
        " 'c'
    $1.keys | Sort | %{
        $k = $_ -replace "^0",' '
        w $($k + '. ') 'g' 'nl'
        if($1[$_] -in $dyrl_sn_intlist){w $1[$_] 'c'}  ## Let user know this property is integer-only
        else{w $1[$_] 'y'}
    }
    while([int]$num -notIn 1..$($1.count)){
        w '
        
        '
        w '  ' 'g' 'nl'
        w 'Properties with a (b) can only be True/False; those in blue can only be integers! ' 'bl' 'y'
        w "
    Enter the number for each property you want to search, followed by
    a colon and the value you're filtering on. for multiple filters,
    separate each with a comma. 
    
    -Regex can be used for the non-boolean properties
    -Operators > and < can be used for integer properties
    " 'g'
        w '   Example filters --' 'g'
        w '
    9:some value                               (search a single property)
    3:>10                                      (search an int property for more than 10)
    16:some other values,19:true,11:1/15/2024  (search multiple properties)
        ' 'c'
        w '
    Enter your filters, or "q" to quit: ' 'g' 'nl'

        $Z = Read-Host
        if($Z -eq 'q'){
            Exit
        }
        $num = [int]$($Z -replace ":.+")
        $Z -Split(',') | %{
            if($_ -Match "^.:"){
                $filters += @{$($_ -replace "^",'0' -replace ":.+")=$($_ -replace "^.+:")}
            }
            else{
                $filters += @{$($_ -replace ":.+")=$($_ -replace "^.+:")}
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
            if($filter.values -eq 'false'){
                $filterstring = $filterstring + '! $_.' + $($property -replace " \(b\)$")
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
                $filterstring = $filterstring + '$_.' + $property + ' -eq ' + [string]$filter.values
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
    $command = [scriptblock]::Create("$($cmdlet[$2]) -filter * -properties * | where{$filterstring}")
    $matches = . $command

    if($sn_dbg){
        while($zz -ne 'q'){
            w " DEBUG MODE:" 'y'
            w ' $matches = contains any positive search results
  $filters = the search you entered
  $filterstring = the command generated by your search
  
  ' 'g'
            $zz = read-host '  Enter your test commands, or "q" to quit debugging'
            if($zz -ne 'q'){
                $cmd = $($zz -split(' ')[0])
                $scrblk = $zz -replace "^\S+\s"
                Invoke-Command -NoNewScope $cmd {$scrblk}
            }
        }
        Remove-variable cmd,zz
    }

    if(! $matches){ 
        $matches = 0
    }
    elseif($matches.getType().basetype -ne 'System.Array'){
        $matches = @($matches)
    }

    Return @($matches,$specific,$Z[1])

}


function showAccounts($1,$2){
    $i = 1
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
    Remove-Variable focus,extra -Scope script
    Remove-Variable PROTOCULTURE -Scope global
}




while($Z -ne 'c'){
    $quit = $false
    splashPage
    w '
    
    '
    w '                                SELECT A SINGER:
    ' 'g'
    w '  1. Sheryl Nome (boolean and less-common properties)
       ' 'g'
    w '  2. Lynn Minmay (common properties with unique identifiers like descriptions, IDs, etc.)
      ' 'g'
    w '  3. Sharon Apple (search for computers/servers)

    ' 'g'
    w '  (type "c" to cancel):  ' 'g' 'nl'

    $Z = Read-Host

    
    if($Z -eq 'c'){
        Exit
    }



    if($Z -eq 1){
        $accounts = searchAD $huntlist 'USER'
    }
    elseif($Z -eq 2){
        $accounts = searchAD $searchlist 'USER'
    }
    elseif($Z -eq 3){
        $accounts = searchAD $hostslist 'COMPUTER'
        $computer = $true
    }


    
    if($accounts[0] -ne 0){
        $Z = $null
        $total = $accounts[0].count
        $svca = ($accounts[0] | where{$_.samAccountName -Like "service-"})
        $svcn = ($accounts[0] | where{$_.samAccountName -notLike "service-"})
        w '

        '
        if($total -gt 21){
            w "  There are" 'g' 'nl'
            w "$total" 'y' 'nl'
            w "accounts matching your search (" 'g' 'nl'
            w "$($svca.count)" 'c' 'nl'
            w  "'service-' accounts )" 'g'
            w '   -Type "a" to display them all' 'g'
        if($svca.count -gt 0){
            w '   -Type "s" to view service accounts
    -Type "o" to omit service accounts' 'g'
        }
            w '   -Type "f" to write them to a file on your desktop
    -Type "q" to quit' 'g' 
            w '   > ' 'g' 'nl'
            $Z = Read-Host
            if($Z -eq 'q'){
                Exit
            }
            if($Z -eq 'f'){
                "account, $($accounts[1]), desc" | Out-File "$vf19_DEFAULTPATH\ad_user_search.csv"
                $accounts[0] | %{
                    "$($_.samAccountName), $($_.$($accounts[1])), $($_.description) " | 
                        Out-File "$vf19_DEFAULTPATH\ad_user_search.csv" -Append
                }
                ''
                w '  Results have been written to "ad_user_search.csv" on your desktop.'
                Exit
            }
            elseif($Z -eq 'o'){
                $list = $svcn
            }
            elseif($Z -eq 's'){
                $list = $svca
            }
            else{
                $list = $accounts[0]
            }

        }
        else{
            $list = $accounts[0]
        }

        $Z = $null

        while(-not $quit){

            showAccounts $list $accounts[1]

            ''
            w ' Enter the number of an account to view the full profile, or hit ENTER to skip: ' 'c' 'nl'
            $Z = Read-Host

            if($Z -eq ''){
                $quit = $true; Break
            }
            else{
                
                $focus = $list[$([int]$Z - 1)]
                $focus
                ''
                screenResults '         Enter one of the tools below for more data, or hit ENTER to skip.'
                if($computer){
                    showTools 'hostname'
                    $Global:PROTOCULTURE = $focus.name -replace "\.\w+"             ## Remove domain from hostnames
                    $extra = 'hlkup'
                }
                else{
                    showTools 'user'
                    $Global:PROTOCULTURE = $focus.samAccountName -replace "\\\w+"   ## Remove domain from usernames
                    $extra = 'usrlkup'
                }
                ''
                $Z = Read-Host '  '


                if($Z -in $vf19_LATTS.keys){
                    w '
                    '
                    if($vf19_LATTS[$Z].valtype -eq 'EDR'){
                        $r = (collab $($vf19_LATTS[$Z].fname) 'NOME' $extra)
                        if($r){
                            if(($r).count -gt 2){
                                $r = $($r[1] | ConvertFrom-Json).results
                            }
                            else{
                                $r = $($r[0] | ConvertFrom-Json).results
                            }
                            if($r){
                            $ct = 0
                            $total = ($r).count

                            screenResults "   Recent activity for $PROTOCULTURE (unsorted; system processes omitted)"
                            screenResults 'c~HOSTNAME' 'c~ACTIVITY' 'c~DATE'

                            while($ct -lt $total){
                                if("$(($r.process_name[$ct]))" -notIn $l){
                                    [string]$cmdl = $($r.cmdline[$ct])
                                    screenResults "$(($r.hostname[$ct]))  $(($r.username[$ct]))" "$(($r.process_name[$ct]))" "$(($r.start[$ct]))"
                                }
                                $ct++
                            }

                            screenResults 'endr'
                            }
                        }
                    }
                    elseif($vf19_LATTS[$Z].rtype -ne 'onscreen'){
                        $rr = collab $($vf19_LATTS[$Z].fname) 'NOME'  ## Clean this up later
                    }
                    else{
                        ''
                        collab $($vf19_LATTS[$Z].fname) 'NOME'
                    }

                    if($rr){
                        ''
                        $outfile = 'nome_' + $PROTOCULTURE + '.txt'
                        $rr | Out-File "$vf19_DEFAULTPATH\$outfile"
                        w "    Results were written to $outfile on your desktop.
                        "
                    }
                }
                $Z = $null
                cv
            }
        }
        cv
        Remove-Variable accounts

    }
    else{
        w "
    
        No accounts found matching '$($accounts[2])' in" 'g' 'nl'
        w "$($accounts[1])" 'c'
        ''
        w '  Hit ENTER to continue.' 'g'; Read-Host
    }
}

