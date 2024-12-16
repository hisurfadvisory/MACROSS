#_sdf1 Targeted Active Directory Hunting
#_ver 1.1
#_class 2,admin,search active-directory account properties,powershell,HiSurfAdvisory,0,none

<#
    Active-Directory sniffer: find accounts based on specific properties.

    If your enterprise service accounts are named a specific way, replace all
    the instances of "service-" in this script with your organization's naming scheme.
    This helps shorten the amount of returns you might receive, though you may
    not always want to do so!

    
    Review the sections at lines 370 & 490... you can modify these sections to better
    suit your network. For example, the lines following

        $dyrl_sn_T = availableTypes -v 'active-directory user,EDR' -e

    is where you can write instructions to match your own EDR script's requirements,
    if necessary.


#>



if($HELP){
    cls
    w '    ' -i; w " NOME v$($vf19_LATTS['NOME'].ver) " y bl
    Write-Host -f YELLOW "

    NOME provides a quick way to hunt for anomalies in Active Directory. You
    can select between property lists for users or computers, both of which
    contain dozens of search choices.

    This tool does not search or display GPO information, though it can send
    your findings to MYLENE or your EDR to give you more data. Use MYLENE if
    you need to search specific GPO memberships.

    Hit ENTER to go back.
    "
    Read-Host; Return
}



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


## Uncommon and boolean values
$dyrl_sn_userslist = @{
    '01'='AccountExpirationDate';
    '02'='AccountLockoutTime (in Minutes)';
    '03'='badLogonCount';
    '04'='badPasswordTime';
    '05'='CanonicalName';
    '06'='CN (Full name)';
    '07'='Created (days)';
    '08'='Deleted (days)';
    '09'='Department';
    '10'='Description';
    '11'='DisplayName';
    '12'='DistinguishedName';
    '13'='isDeleted';
    '14'='DoesNotRequirePreAuth (b)';
    '15'='EmailAddress';
    '16'='EmployeeID (EDIPI)';
    '17'='Enabled (b)';
    '18'='HomeDirectory';
    '19'='HomeDrive';
    '20'='info';
    '21'='instanceType';
    '22'='LastBadPasswordAttempt';
    '23'='LastLogonDate (days)';
    '24'='LockedOut (b)';
    '25'='LockoutTime';
    '26'='logonCount';
    '27'='LogonWorkstations'
    '28'='msNPAllowDialin (b)';
    '29'='Modified (days)';
    '30'='Name';
    '31'='Office';
    '32'='OfficePhone';
    '33'='Organization';
    '34'='otherTelephone';
    '35'='otherName';
    '36'='PasswordNotRequired (b)';
    '37'='PasswordExpired (b)';
    '38'='PasswordLastSet (days)';
    '39'='PasswordNeverExpires (b)';
    '40'='PrimaryGroupID';
    '41'='ProfilePath';
    '42'='ProtectedFromAccidentalDeletion (b)';
    '43'='pwdLastSet';
    '44'='roomNumber';
    '45'='ScriptPath';
    '46'='SmartCardLogonRequired (b)'
    '47'='samAccountName';
    '48'='SID';
    '49'='telephoneNumber';
    '50'='Title (EDIPI)';
    '51'='TrustedForDelegation (b)';
    '52'='TrustedToAuthForDelegation (b)';
    '53'='uid (EDIPI)';
    '54'='userPrincipalName (EDIPI)'
}


## Computers
$dyrl_sn_hostslist = @{
    '01'='AccountExpirationDate';
    '02'='AccountLockoutDate';
    '03'='adminDescription';
    '04'='CanonicalName';
    '05'='CN';
    '06'='Created (days)';
    '07'='Deleted (days)';
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
    '18'='LastLogonDate (days)';
    '19'='Location';
    '20'='LockedOut (b)';
    '21'='logonCount';
    '22'='ManagedBy';
    '23'='Modified (days)';
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


## Properties that are integer-values
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
    w '       ' -i
    w " ACTIVE DIRECTORY -- SEARCH $2 SETTINGS" bl w
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
        if($v1 -in $t2_wo_intlist){$c1 = 'c'}
        $n = 24 - $($v1.length)
        while($n -gt 0){
            $v1 = $v1 + ' '
            $n--
        }
        w " $($k1 -replace "^0",' ')." -i
        if($v2){
            if($v2 -in $t2_wo_intlist){$c2 = 'c'}
            w " $v1" $c1 -i
            w " $($k2 -replace "^0",' ')." -i
            w " $v2" $c2
        }
        else{
            w " $v1" $c1
        }
        $i++
    }
    while([int]$num -notIn 1..$($1.count)){
        w '
        
        '
        w '  ' g -i
        w 'Properties with a (b) can only be True/False; those in blue are integer-only! ' bl y
        w "
    Enter the number for each property you want to search, followed by
    a colon and the value you're filtering on. for multiple filters,
    separate each with a comma.

    -Regex can be used for the non-boolean properties
        (don't use commas in your pattern)
    -Operators > and < can be used for integer properties
    " g
    
        w '   Example filters --
        ' g
        w '    17:some string value,16:true,7:3/15/2024' 'c' -i
        w ' (Search multiple properties)' g
        w '    43:some string value' c -i
        w '    (Search a single property)' g
        w '    3:>10' c -i
        w '                   (Search an int property for values 10 & higher)
        ' g
        w '
    Enter filters or "q" to quit:
    > ' g -i


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
        $specific += $($property -replace " \(EDIPI\)$",".*" -replace " \(\w+\)$")
        if($property -Like "*days)"){
            $filterstring = $filterstring + '$_.' + $property + " -gt `"$((Get-Date).AddDays(-$fv))`" "
            $filterstring = $filterstring + ' -and $_.' + $property + " -lt `"$(Get-Date)`""
        }
        elseif($property -Like "* (b)"){
            ## Set boolean filters
            if($filter.values -Match "^f"){
                $filterstring = $filterstring + ' ! $_.' + $($property -replace " \(b\)$")
            }
            else{
                $filterstring = $filterstring + '$_.' + $($property -replace " \(b\)$")
            }
        }
        elseif($property -in $t2_wo_intlist){
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
    Searching...' g
    
    ## Debugging
    if($hk_OPT1){while($z -ne 'q'){$z = read-host 'debug'; iex "$z"; w "`n`n" }rv -force hk_OPT1 -scope global; Exit}


    $matches = . $([scriptblock]::Create("$($cmdlet[$2]) -filter * -properties * | ?{$filterstring}"))


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
            screenResultsAlt -h $([string]$i + '. ' + $U.Name) -k 'SYSTEM' -v $U.OS
        }
        else{
            screenResultsAlt -h $([string]$i + '. ' + $U.displayName) -k 'ACCOUNT' -v $U.samAccountName
        }
        screenResultsAlt -k 'DESCRIPTION' -v $U.description
        $2 | %{
            screenResultsAlt -k "$_" -v "$($U.$_)"
        }
        screenResultsAlt -e
        $i++
    }
    ''
    w ' Enter the number of an account to review,' c -i
    if($limit -ge 0){
        w 'hit ENTER for the next 10,' c
    }
    w ' "n" for a new search or "q" to quit:  ' c -i
    $z = Read-Host

    if($z -eq 'q'){
        rv dyrl_sn_*; Exit
    }
    elseif($z -eq 'n'){
        $Script:dyrl_sn_quit = $true
        Break
    }
    elseif($z -eq ''){
        Return
    }
    else{

        $focus = $dyrl_sn_list[([int]$z - 1)]
        $focus

        $check = availableTypes 'edr' -e
        if($check.count -gt 0){ $dyrl_sn_EDRQ = $true; rv check }
        $dyrl_sn_T = availableTypes 'active-directory,edr'  ## Get any scripts that query EDR or AD
        if($dyrl_sn_T.count -ge 1){
            ''
            screenResults '         Enter one of the tools below for more data, or hit ENTER to skip.'
            
                $dyrl_sn_T | %{
                    screenResults $_ $(TL $_).valtype
                }
                screenResults -e
            
            ''
            $z = Read-Host '  '

            #########################  MOD SECTION   #########################
            ########   MODIFY THIS BLOCK IF YOU USE A SPECIFIC EDR SOLUTION
            if((TL $z).valtype -eq 'EDR'){
                if($dyrl_sn_EDRQ -and $dyrl_sn_computer){
                    $Global:PROTOCULTURE = $focus.name -replace "\..+"            ## Remove domain from local hostname
                    $qtype = 'hlkup'                                              ## Tell GERWALK to search by hostname
                }
                elseif($dyrl_sn_EDRQ){
                    $Global:PROTOCULTURE = $focus.samAccountName -replace "\\\w"  ## Remove domain from username
                    $qtype = 'usrlkup'                                            ## Tell GERWALK to search by username
                }
                $er = (collab $z 'NOME' $qtype)
            }
            elseif((TL $z).valtype -like "active-d*"){
                if($SINGER -eq 'NOME'){
                    $Global:PROTOCULTURE = $focus.samAccountName -replace "\\\w"
                }
                else{
                    $Global:PROTOCULTURE = $focus.name -replace "\..+"   ## Remove domain from hostname
                }
                $ar = collab $z 'NOME'
            }
            ########   END OF EDR SECTION
        }
        
        
        if($er){
            if(($er).count -gt 2){
                $rr = $($er[1] | ConvertFrom-Json).results
                $l = $er[2]
            }
            else{
                $rr = $($er[0] | ConvertFrom-Json).results
                $l = $er[1]
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
    
                screenResults -e
                w '
                '
                w '  Hit ENTER to continue.' c
                Read-Host
                showAccounts $1 $2 $3
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


function cv(){
    Remove-Variable dyrl_sn_focus,dyrl_sn_extra,dyrl_sn_computer -Scope script
    Remove-Variable PROTOCULTURE -Scope global
}


transitionSplash 9 2

while($dyrl_sn_Z -ne 'c'){
    $dyrl_sn_quit = $false
    $SINGER = $null
    splashPage
    w "`n`n"
    w '                                SELECT A SINGER:
    ' g
    w '  1. Sheryl Nome (hunt for USER properties)
       ' g
    w '  2. Sharon Apple (hunt for COMPUTER properties)

    ' g
    w '  (type "c" to cancel):  ' g -i

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
        "account, $($dyrl_sn_accounts[1]), desc" | Out-File "$vf19_DTOP\ad_user_search.csv"
        $1 | %{
            "$($_.samAccountName), $($_.$($dyrl_sn_accounts[1])), $($_.description) " | 
            Out-File "$vf19_DTOP\ad_user_search.csv" -Append
        }
        ''
        w '  Results have been written to "ad_user_search.csv" on your desktop.' y
        slp 1
    }


    ######################################################################
    ## Modify the -Like, -Match, etc. values below to match up with the naming
    ## scheme of your network for service accounts and external users
    ######################################################################
    if($dyrl_sn_accounts[0] -ne 0){
        $dyrl_sn_Z = $null
        $dyrl_sn_total = $dyrl_sn_accounts[0].count
        $dyrl_sn_svca = ($dyrl_sn_accounts[0] | where{$_.samAccountName -Like "service*"})
        $dyrl_sn_svcn = ($dyrl_sn_accounts[0] | where{$_.samAccountName -notLike "service*"})
        $dyrl_sn_extu = ($dyrl_sn_accounts[0] | where{$_.samAccountName -Match "^ext\-"})
        $dyrl_sn_extn = ($dyrl_sn_accounts[0] | where{$_.samAccountName -notMatch "^ext\-"})
        if(-not $dyrl_sn_svca.count){$dyrl_sn_sc=0}else{$dyrl_sn_sc = $dyrl_sn_svca.count}
        if(-not $dyrl_sn_extu.count){$dyrl_sn_ec=0}else{$dyrl_sn_ec = $dyrl_sn_extu.count}
        w '

        '
        if($dyrl_sn_total -gt 21){
            w "  There are " g -i
            w "$dyrl_sn_total" y -i
            w " accounts matching your search (" g -i
            w "$($dyrl_sn_sc)" c -i
            w  " service and " g -i
            w "$($dyrl_sn_ec)" c -i
            w " external accounts )" g
            w '  Enter one or more of the following choices (examples, "fo" to view' g
            w '  and save user accounts, or "s" to view service accounts):' g
            w '   -"a" to display them all' g
        if($dyrl_sn_sc -gt 0){
            w '   -"s" to view service accounts
    -"o" to omit service accounts' g
        }if($dyrl_sn_ec -gt 0){
            w '   -"e" to view external accounts
    -"i" to ignore external accounts' g
        }
            w '   -"f" to write them to a file on your desktop
    -"q" to quit' g 
            w '   > ' g -i
            $dyrl_sn_Z = Read-Host
            if($dyrl_sn_Z -eq 'q'){
                Exit
            }
            else{
                $dyrl_sn_list = $false; $write = $false
                $dyrl_sn_choices = @{'o'=$dyrl_sn_svcn; 's'=$dyrl_sn_svca; 'i'=$dyrl_sn_extn; 'e'=$dyrl_sn_extu; 'f'=''}
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
        Remove-Variable accounts

    }
    else{
        w '
    
        No accounts found matching
        ' g
        w "$($dyrl_sn_accounts[2])" w
        w '
        Hit ENTER to continue.' g; Read-Host
    }
}

