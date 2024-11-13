#_sdf1 AD account audits & lookups
#_ver 2.5
#_class 1,user,active-directory user lookups,powershell,HiSurfAdvisory,1,onscreen

<#
    MYLENE: Target recently-created accounts for inspection; look up AD info
    on users of interest

    This script uses the "net" utility and Active-Directory cmdlets to gather
    data on enterprise users and hosts -- primarily accounts and devices
    that are newly-joined to your domain.

    MYLENE is part of the MACROSS framework, so many tasks or functions may
    not be available to a user if MACROSS has determined they do not have
    admin-level privileges.

    If MYLENE is run with admin- or Active Directory read-permissions:
    1) AD Objects will be collected based on:
        -usernames
        -hostnames
        -creation dates
        -keywords to match against Group-Policy names

    2) Anomalous attributes can be highlighted by modifying the function "cleanList".
        Look for the section labeled:
        "Add other values here to highlight deviations from standard account attributes"

    3) Results will output to screen AND to your Desktop in a folder called
        "NewUserSearches" when searching for newly-created accounts.

    4) Standard user searches will have summaries printed to screen, with
        options to display more info as needed.
    
    5) This script was written in an environment that used VMWare's Carbon Black as an
        Endpoint Detection (EDR) solution, which this script would use to perform user
        activity lookups to aid analyst investigations. If your environment uses something
        else and you write a MACROSS tool to access its API, you can modify the EDR/Carbon 
        Black sections of this script to parse its output as necessary.

        If there is no EDR, don't worry. If the "modules" folder doesn't contain any scripts
        with 'EDR' as a .valtype, MYLENE won't offer the option.

    ---------------------------------------------------
    If calling MYLENE from your script via the "collab" function, MYLENE
    does not return any values. It writes all of its search results
    for $PROTOCULTURE to the screen, then exits back to your script when
    the analyst is finished reviewing it.
    ---------------------------------------------------

    Scan this script for all the comment lines with "MOD SECTION!". They contain tips for
    modifying those lines to meet your needs.



#>


###################################################################################
###       README ~~~~~~~~~ MACROSS PYTHON INTEGRATION EXAMPLE
###################################################################################
## If you want your powershell scripts to work with MACROSS python scripts,
## copy-paste this check to restore all the values that get lost when transitioning
## via both the powershell and python versions of the collab function.
param(
    [string]$pythonsrc=$null    ## The python collab function will set this value
)
if($pythonsrc -ne $null){
    
    ## This will be the name of the python script calling this one
    $Global:CALLER = $pythonsrc
    
    ## This is a unique temporary session, so launch the core scripts to get their functions
    foreach( $core in gci "$PSScriptRoot\..\core\*.ps1" ){ . $core.fullname }

    ## Now that the core files are loaded, this function can restore all the MACROSS 
    ## defaults your powershell script might need
    restoreMacross
    
    ## Note that just like the powershell version, the python collab function can also
    ## send an alternate param to your scripts when relevant. So, you can write your  
    ## scripts to accept a value in addition to (or instead of) $PROTOCULTURE, if necessary.
}



## Display help/description
if( $HELP ){
    cls
    w "
 Author: $($vf19_LATTS['MYLENE'].author)
 version $($vf19_LATTS['MYLENE'].ver)
 
 
 MYLENE's Recent Account Search lets you perform user lookups by name or creation 
 date. As an admin, you can query Active Directory for partial name matches. If you 
 don't know the entire username, you can search with wildcards (*), but it might 
 return several results. If you wildcard the front  of your searches, you must 
 wildard the end (ex. *partname will not work, but *partname* and partname* will).
 
 When searching for recently created users, you can:
    -do a quick keyword search on all of the new accounts' GPO assignments
    -get a quickview of all the GPO assignments for specific new accounts
    -get a quick alert for non-standard attributes on any new accounts (i.e.  
        things like 'null password' will be highlighted in red)
 
 MYLENE also lets you search for new hosts recently added to Active Directory.

 If you are logged with admin privileges and select MYLENE with the `"s`" option  
 (example `"12s`" from the main menu if MYLENE is #12), you can search for keywords   
 and creation dates instead of usernames in Active-Directory GPO.

 If you are NOT admin, your search will be performed with the " -i y
    w 'net' -i g
    w ' utility, and
 you cannot wildcard. You must search for exact names.

 Hit ENTER to return.
 ' y

    Read-Host
    Return
}


############################################
##  BEGIN FUNCTIONS
############################################
## Display tool banner
function splashPage(){
    cls
    w "`n"
    $b = 'ICAgICDilojilojilojilZcgICDilojilojilojilZfilojilojilZcgICDilojilojilZfilojilojilZcgI
    CAgIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKWiOKVlyAgIOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKW
    iOKWiOKVlwogICAgIOKWiOKWiOKWiOKWiOKVlyDilojilojilojilojilZHilZrilojilojilZcg4paI4paI4pWU4pW
    d4paI4paI4pWRICAgICDilojilojilZTilZDilZDilZDilZDilZ3ilojilojilojilojilZcgIOKWiOKWiOKVkeKWiO
    KWiOKVlOKVkOKVkOKVkOKVkOKVnQogICAgIOKWiOKWiOKVlOKWiOKWiOKWiOKWiOKVlOKWiOKWiOKVkSDilZrilojil
    ojilojilojilZTilZ0g4paI4paI4pWRICAgICDilojilojilojilojilojilZcgIOKWiOKWiOKVlOKWiOKWiOKVlyDi
    lojilojilZHilojilojilojilojilojilZcgCiAgICAg4paI4paI4pWR4pWa4paI4paI4pWU4pWd4paI4paI4pWRICD
    ilZrilojilojilZTilZ0gIOKWiOKWiOKVkSAgICAg4paI4paI4pWU4pWQ4pWQ4pWdICDilojilojilZHilZrilojilo
    jilZfilojilojilZHilojilojilZTilZDilZDilZ0gCiAgICAg4paI4paI4pWRIOKVmuKVkOKVnSDilojilojilZEgI
    CDilojilojilZEgICDilojilojilojilojilojilojilojilZfilojilojilojilojilojilojilojilZfilojiloji
    lZEg4pWa4paI4paI4paI4paI4pWR4paI4paI4paI4paI4paI4paI4paI4pWXCiAgICAg4pWa4pWQ4pWdICAgICDilZr
    ilZDilZ0gICDilZrilZDilZ0gICDilZrilZDilZDilZDilZDilZDilZDilZ3ilZrilZDilZDilZDilZDilZDilZDilZ
    3ilZrilZDilZ0gIOKVmuKVkOKVkOKVkOKVneKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVnQ=='
    getThis $b
    w $vf19_READ
    ''
    w "          ==== Mylene's Recent Accounts Search ====`n"
}


function noFind($1){
    w " $1" -i y
    w " not found! Hit ENTER.`n"
    Read-Host
}

## Let user choose when to proceed
function hetc(){
    w ' Hit ENTER to continue. ' -i g; Read-Host
}


function rvf(){
    Remove-Variable -Force CALLER,PROTOCULTURE -Scope Global
}



<#####################################################################################
    MOD SECTION!
    The $dyrl_myl_EDR variable will contain the name of any scripts in the module folder
    with "EDR" as their .valtype value. This enables analysts to automatically
    pull logged-in activity from the EDR for any username they find with MYLENE.

    It assumes you only have one EDR, if any, so it always references $dyrl_myl_EDR[0]

#####################################################################################>
## GERWALK plugin function
if( $dyrl_myl_EDR ){
    function uActivity($1){  ## Send a username to EDR
        $Global:PROTOCULTURE = $1
        $activityu = collab $($dyrl_myl_EDR[0]) 'MYLENE' 'usrlkup'
        rvf


        ## GERWALK randomly sends a useless header with the max results,
        ## need to ignore when it does this
        if(($activityu).count -gt 2){
            $r = $($activityu[1] | ConvertFrom-Json).results  # CB results
            $l = $activityu[2]                                # Noisy proc lists
        }
        else{
            $r = $($activityu[0] | ConvertFrom-Json).results
            $l = $activityu[1]
        }


        $ct = 0
        $total = ($r).count

        screenResults "   Recent activity for user $1 (unsorted; system processes omitted)"
        screenResults 'c~HOSTNAME' 'c~ACTIVITY' 'c~DATE'

        while($ct -lt $total){
            if("$(($r.process_name[$ct]))" -notIn $l){
                [string]$cmdl = $($r.cmdline[$ct])
                screenResults "$(($r.hostname[$ct]))" "$(($r.process_name[$ct]))" "$(($r.start[$ct]))"
            }
            $ct++
        }

        screenResults -e
        hetc
        ''
        Remove-Variable -Force activityu
    }

    function hActivity($1){  ## Send a hostname to Carbon Black
        $Global:PROTOCULTURE = $1

        if( ! $activityh ){
            $activityh = collab $($dyrl_myl_EDR[0]) 'MYLENE' 'hlkup'
            rvf
        }

        ## GERWALK randomly sends a useless header with the max results,
        ## need to ignore when it does this
        if(($activityh).count -gt 2){
            $f = $($activityh[1] | ConvertFrom-Json).facets   # EDR results
            $l = $activityh[2]                                # Noisy proc lists
        }
        else{
            $f = $($activityh[0] | ConvertFrom-Json).facets
            $l = $activityh[1]
        }


        while( $z -ne '' ){
            screenResults "           Activity on host $1 ($type)"
            screenResults 'c~ACCOUNTS' 'c~RUNNING PROCESSES' 'c~CB GROUP'
            screenResults "$($f.username_full.name)" "$($f.process_name.name)" "$($f.group.name)"
            screenResults "Last seen: $(($f.start.name | Sort -Descending)[0])"
            screenResults -e
            ''
            w ' Type a username to view their recent activity, or hit ENTER to continue.' g
            w ' Username: ' g -i
            $z = Read-Host
            if( $z -ne ''){
                if($z -in $($f.username_full.name)){
                    $z = $z -replace "^.*\\"
                    uActivity $z
                }
                elseif($z -Match "\w"){
                    ''
                    w " That name isn't listed. Try adding the domain.
                    " c
                }
            }
        }
    }

}


## Make the "memberOf" field actually readable
## $1 is the GPO object (memberOf), $2 is the user's search string (optional)
function listGroups($1,$2){
    if($2){
        $1  | Select-String -Pattern $2 | Sort -Unique | 
            %{
                $cat = detailGroups $_
                $grp = $($_ -replace "..=" -replace ",.*$") + ' (' + $cat + ')'
               w "   $grp" y
            }
    }
    else{
        $1 | Sort -Unique |
            %{
                $cat = detailGroups $_
                $grp = $($_ -replace "..=" -replace ",.*$") + ' (' + $cat + ')'
                w "   $grp" y
            }
    }
}



## Select description of the security group. Right now only looking at 
## category, can grab other objects later. $1 is the Group name (must be exact)
function detailGroups($1){
    $a = $(Get-ADGroup -Filter * -Properties * | 
        where{$_.name -eq "$1"} |
        Select groupCategory)

    Return $a
}



## Write results to text file on user's desktop. $1 is the info to write (filename has already 
## been determined). If $2 contains a value, it will be written to file first (should usually 
## be a username, or newline/whitespace to separate each user entry)
function w2f($1,$2){
    if($2){
        $2 | Out-File -Filepath "$vf19_DTOP\NewUserSearches\$dyrl_myl_OUTNAME" -Append
    }
    $1 | Out-File -Filepath "$vf19_DTOP\NewUserSearches\$dyrl_myl_OUTNAME" -Append
}


## Provide examples to noobs on how they can query active-directory themselves
function selfService(){
    w '
    Here are some examples for searching users with the "get-aduser" cmdlet (not case-sensitive):
    ' g
    ''
    w "   Return a limited set of attributes for a specific account:"
    w " get-aduser -filter 'samaccountname -eq `"USERNAME`"'" y
    ''
    w "   Return all of the account's attributes. Take note of all the attribute keys (on the left when
    your search gives back results) and use them to refine your searches:"
    w "get-aduser -filter 'samaccountname -eq `"USERNAME`"' -properties *" y
    ''
    w '   Return all account names that are disabled:'
    w ' (get-aduser -filter * -properties * | where {$_.enabled -eq "false"}).samaccountname' y
    ''
    '   Search for accounts with "help desk" in the description, and show you only their names & descriptions:'
    w ' get-aduser -filter * -properties * | where {$_.description -like "*help desk*"} | select samaccountname,displayname,description' y
    ''
}



## Only load AD functions if user is admin
if( ! $vf19_ROBOTECH ){

    function searchDesc(){
        
        function listSearchR(){
            $index = 1
            $Script:list = @()
            $getad | %{
                $a = $_.samAccountName
                $c = $_.whenCreated
                $e = $($_.Enabled)
                $l = $_.lastLogonDate
                if($obj -eq 1){
                    $d = "$($_.Department) | $($_.displayName)"
                }
                else{
                    $d = "$($_.Description) | $($_.info)"
                }

                

                $Script:list += $a
                if( $e -eq $false ){
                    $a = $a + ' (DISABLED)'
                    $item = 'cyan~' + $([string]$index) + '. ' + $a
                }
                else{
                    $item = $([string]$index) + '. ' + $a
                }
                $item = $item -replace "\s+$"
                $crlo = $($c -replace "\s+$")
                $llogon = $($l -replace "\s+$")
                $index++
                if($obj -eq 2){
                    screenResultsAlt -h $item -k 'CREATED' -v $crlo
                    screenResultsAlt -k 'LASTLOGON' -v $llogon
                    screenResultsAlt -k 'INFO' -v $d
                    screenResultsAlt -e
                }
                else{
                    screenResults $item $d
                }
            }
            screenResults -e
            ''
        }
        ''
        while($Z -notMatch "(d|o|c)"){
            w ' Do you want to search by (' -i g
            w 'd' -i y
            w ')escription or (' -i g
            w 'o' -i y
            w ')ffice/Org (type "' -i g
            w 'c' -i y
            w '" to cancel)?  ' -i g
            $Z = Read-Host
        }

        if($Z -eq 'c'){
            Remove-Variable -Force list -Scope Global
            Return
        }

        w ' Enter your keyword(s): ' -i g
        $ZZ = Read-Host

        if($Z -eq 'd'){
            $obj = 2
            $getad = Get-ADUser -Filter * -Properties * | 
                where{$_.Description -Like "*$ZZ*" -or $_.info -like "*$ZZ*"}
        }
        elseif($Z -eq 'o'){
            $obj = 1
            $getad = Get-ADUser -Filter * -Properties * | 
                where{$_.displayName -Like "*$ZZ*" -or $_.Department -like "*$ZZ*"}
        }

        $ZZ = $null
        $Z = $null

        if($getad){
            while($Z -ne ''){
                if($obj -eq 2){
                    screenResultsAlt -e
                }
                else{
                    screenResults 'ACCOUNT' '   OFFICE | ORG'
                }
                listSearchR
                w ' Select a number for full details, or ENTER to skip: ' -i g
                $Z = Read-Host
                if($Z -Match "\d+"){
                    $Z = $Z - 1
                    $u = $list[$Z]
                    $getad | where{$_.samAccountName -eq "$u"}
                    ''
                    hetc
                    ''
                }
            }
            Remove-Variable -Force list -Scope Global
        }
        else{
            w ' Nothing found.
            ' c
        }

        w ' Hit ENTER to search descriptions again, or type "c" to cancel: ' -i g
        $Z = Read-Host
        
        if($Z -eq 'c'){
            Return
        }
        else{
            Clear-Variable -Force Z,obj,g*
            splashPage
            searchDesc
        }

    }

    ## Collect Group Policy details; if $option param is '1', just return
    ## true or false; if $option is '2', perform an EXACT search; if $option
    ## is '3', user wants to search by creation date; if $option is null,
    ## perform a wildcard search
    function 3gpo($filter,$option){
        Remove-Variable g*
        function chooseG(){
            $gpolist = @()
            $i = 1
            $gname | %{
                $gpolist += $_
            }
            $gpolist | %{
                Write-Host -f YELLOW "  $i" -i
                Write-Host -f GREEN ". $_"
                $i++
            }
            Write-Host '
            '
            while( ! $l ){
                w ' Select a number from the list to view it in detail, or "q" to quit: ' -i g
                $Z = Read-Host
                if($Z -eq 'q'){
                    Return
                }
                elseif($gpolist[$($Z - 1)]){
                    $l = $gpolist[$($Z - 1)]
                }
            }
            Clear-Variable Z,g*
            3gpo $l 2
        }

        if($option -eq 3){
            $a1 = [string]$([int]$dyrl_myl_ZA[0] + 1) + ','
            $a1 = $filter -replace "^\d+\.",$a1
            $a2 = [string]$([int]$dyrl_myl_ZA[0] + 2) + ','
            $a2 = $filter -replace "^\d+\.",$a2
            $a3 = [string]$([int]$dyrl_myl_ZA[0] - 1) + ','
            $a3 = $filter -replace "^\d+\.",$a3
            $a4 = [string]$([int]$dyrl_myl_ZA[0] - 2) + ','
            $a4 = $filter -replace "^\d+\.",$a4
            
            $gquery = Get-ADGroup -filter * -properties * |
                where{[string]$($_.Created) -Match "($a1|$a2|$a3|$a4)"} |
                Select Created,Description,Name,ManagedBy,Members,whenChanged

        }
        elseif($option -eq 2){
            $filter = "Name -eq '$filter'"
        }
        else{
            $filter = "Name -Like '*$filter*'"
        }

        if($filter -and -not $gquery){
            $gquery = Get-ADGroup -Filter $filter -Properties Created,Description,Name,ManagedBy,Members,whenChanged
        }
        $gname = $gquery.Name
        $gnamec = $gname.count
        $gdesc = $gquery.Description -replace "\s{2,}"
        $gman = $gquery.ManagedBy -replace "CN=" -replace ",.+$" -replace "\s{2,}"
        $gcreated = $gquery.Created -replace "\s{2,}"
        $gchanged = $gquery.whenChanged -replace "\s{2,}"
        if($option -eq 1){
            if($gname){
                Return $true
            }
            else{
                Return $false
            }
        }
        elseif($gnamec -gt 0){
            if($gnamec -gt 1){
                chooseG
            }
            else{
                $gmembers = $gquery | Select -ExpandProperty Members
                if($option -eq 1){
                    screenResults '  GROUP' '  CREATED'
                    screenResults $gname $gcreated
                }
                else{
                    screenResults '  GROUP' '  DESC' '  CREATED'
                    screenResults $gname $gdesc $gcreated
                    if($gman -or $changed){
                        screenResults -e
                        screenResults -e
                        screenResults -e
                        screenResults '  MANAGED BY' $gman
                        screenResults '  UPDATED' $changed
                    }
                }
                screenResults -e
                ''
                while($Z -ne 'q'){
                    w ' Enter "' -i g
                    w 'm' -i y
                    w '" to view group members, "' -i g
                    w 'd' -i y
                    w '"' -i g
                    w " to view this GPO's full description," g
                    w ' "' -i g
                    w 'x' -i y
                    w '" for extra details, ' -i g
                    if($vf19_OPT1){
                        w 'or "' -i g
                    }
                    else{
                        w '"' -i g
                    }
                     w 'c' -i y
                    if($vf19_OPT1){
                        w ' to cancel and go back:' g
                    }
                    else{
                        w '" to cancel, ' -i g
                        if($option -eq 2){
                            w 'or "' -i g
                        }
                        else{
                            w '"' -i g
                        }
                        w 'q' -i y
                        if($option -eq 2){
                            w '" to quit MYLENE.' g
                        }
                        else{
                            w '" to quit MYLENE, or a new' g
                            w ' keyword to search:' g
                        }
                    }
                    w '  > ' -i g
                    $Z = Read-Host
                    if($Z -eq 'm'){
                        $Zu = $null
                        $d = 'c~DERP!'
                        $uaccts = @{}
                        function showAccts(){
                            $uaccts.keys | %{
                                $fn = $uaccts[$_]
                                screenResults $_ $fn
                            }
                            screenResults -e
                        }
                        $gmembers | %{
                            $fullname = $_ -replace "^..=" -replace ",OU=.+$" -replace "\\"
                            $shortname = $(Get-ADUser -filter "Name -eq '$fullname'" | Select -ExpandProperty samAccountName)
                            if(! $shortname){
                                $shortname = $d
                            }
                            if(! $fullname){
                                $fullname = $d
                            }
                            $uaccts.Add($shortname,$fullname)
                        }
                        showAccts
                        while($Zu -ne ''){
                            ''
                            ''
                            if($d -in $uaccts.keys -or $d -in $uaccts.values){
                                w " Type 'derp' to show all members if there are derp'd entries, or hit" g
                            }
                            else{
                                w ' Hit' -i g
                            }
                            w ' ENTER to continue, or type a username to lookup their account' g
                            w ' (wildcarding names "*" is okay): ' -i g
                            $Zu = Read-host
                            if($Zu -eq 'derp'){
                                $gmembers | %{
                                    Write-Host "  $_"
                                }
                            }
                            elseif($Zu -ne ''){
                                singleUser $Zu
                                showAccts
                            }
                            ''
                        }
                    }
                    elseif($Z -eq 'd'){
                        ''
                        w "  $gdesc`n" c
                    }
                    elseif($Z -eq 'x'){
                        $gquery
                    }
                    elseif($Z -eq 'q'){
                        Remove-Variable dyrl_myl_*
                        Exit
                    }
                    elseif($Z -eq 'c'){
                        Return
                    }
                }
            }
        }


    }


    ## Unfuglify powershell's output
    function cleanList($1,$2){

        Remove-Variable -Force dyrl_myl_0* -Scope Global ## Start fresh


        <#####################################################################################
            MOD SECTION!
            Add or remove the active-directory properties below to fit your needs. They are
            currently being set as script-scoped variables so that you can add them into
            other parts of this script if you need to. As-is, they are only used within
            this function despite the scope. 
        #####################################################################################>
        $Script:dyrl_myl_P = @{
            'uname'=$1.samAccountName;
            'dname'=$1.displayName;
            'title'=$1.Title;
            'fullname'=$1.Name;
            'cn'=$1.CN;
            'info'=$1.Info;
            'desc'=$1.Description;
            'created'=$1.whenCreated;
            'modified'=$1.whenChanged;
            'llogon'=$1.lastLogonDate;
            'enabled'=$1.Enabled;
            'locked'=$1.LockedOut;
            'locktm'=$1.AccountLockoutTime;
            'email'=$1.Mail;
            'phone'=$1.telephoneNumber;
            'room'=$1.roomNumber;
            'passwx'=$1.PasswordNeverExpires;
            'passwn'=$1.PasswordNotRequired;
            'exp'=$1.AccountExpirationDate;
            'smartc'=$1.SmartcardLogonRequired
        }

        if($2 -gt 0){
            $n = "NEW ACCOUNT $([string]$2)" + ". $($dyrl_myl_P['uname'])"
        }
        else{
            $n = $($dyrl_myl_P['uname'])
        }
        
        ## Check for sus timestamps
        if([string]$($dyrl_myl_P['created']) -Like "*00:00"){
            $cr = "r~$($dyrl_myl_P['created'])"
        }
        else{ $cr = "$($dyrl_myl_P['created'])" }
        

        <#####################################################################################
            MOD SECTION!
            If you have a standardized description for active-directory profiles, like 
                ACCOUNTING - 1st floor
            or
                501 Suite 12
            or any repeatable pattern, add a regex to $pattern and uncomment + modify the check
            below (adding more checks if necessary). This will highlight any deviations from the 
            norm when you are polling new accounts.
        #####################################################################################>
        ## Highlight AD object deviations
        $desc_label = 'DESCRIPTION'
        #$pattern = "ENTER YOUR REGEX HERE"
        #if($($dyrl_myl_P['desc']) -notMatch $pattern){ $desc_label = 'r~' + $desc_label }


        if( ! $CALLER -and -not $PROTOCULTURE){
            screenResultsAlt -h $n -k 'NAME' -v $($dyrl_myl_P['cn'])
        }
        else{
            screenResultsAlt -e
            screenResultsAlt -k 'NAME' -v $($dyrl_myl_P['cn'])
        }   
        screenResultsAlt -k 'CREATED    ' -v "$cr " ## Add whitespace so values are never empty
        screenResultsAlt -k $desc_label   -v "$($dyrl_myl_P['desc']) "
        screenResultsAlt -k 'INFO       ' -v "$($dyrl_myl_P['info']) "
        screenResultsAlt -k 'LAST LOGON ' -v "$($dyrl_myl_P['llogon']) "
        screenResultsAlt -k 'EMAIL      ' -v "$($dyrl_myl_P['email']) "
        screenResultsAlt -k 'PHONE      ' -v "$($dyrl_myl_P['phone']) "
        screenResultsAlt -k 'OFFICE     ' -v "$($dyrl_myl_P['room']) "
        if($($dyrl_myl_P['exp']) -Match "\w"){ 
            screenResultsAlt -k 'r~EXPIRES' $($dyrl_myl_P['exp'])
        }
        if($($dyrl_myl_P['passwx']) -eq $true -or $($dyrl_myl_P['passwn']) -eq $true){
            screenResultsAlt -k 'r~ALERT      ' -v 'PASSWORD NULL OR NEVER EXPIRES'
        }
        if( $($dyrl_myl_P['enabled']) -eq $false ){
            screenResultsAlt -k 'STATUS     ' -v 'w~ACCOUNT IS DISABLED'
        }
        if( $($dyrl_myl_P['locked']) -eq $true){
            screenResultsAlt -k 'STATUS     ' -v "w~ACCOUNT IS LOCKED ($($dyrl_myl_P['locktm']))"
        }
        screenResultsAlt -e

        ## If user wanted to save results, save them to file here
        if($dyrl_myl_wf){
            w2f "Username: $dyrl_myl_0username   ||   Fullname: $dyrl_myl_0propername"
            w2f "Created: $dyrl_myl_0created"
            w2f "Description: $dyrl_myl_0desc`n"
        }

    }


    ## Tailor AD query based on user input
    function singleUser($1){

        if( $1 -Match "\*" ){
            $sU_FILTER = "displayName -Like '$1' -or samAccountName -Like '$1'"
        }
        else{
            $sU_FILTER = "samAccountName -eq '$1'"
            $sU_SPECIFIC = $true
        }

        ## User ran a specific search
        if($sU_SPECIFIC){
            $sU_Q1 = $(Get-ADUser -Filter $sU_FILTER -properties *)
            $sU_GPO = $(($sU_Q1).memberOf -replace "..=" -replace ",.*$")
        }

        ## User ran a wildcard search
        else{
            $sU_Q0 = $(Get-ADUser -Filter $sU_FILTER -Properties displayName,samAccountName |
                Select samAccountName,displayName)
            if($sU_Q0.count -eq 1){
                singleUser $sU_Q0.samAccountName ## Only one user was found, re-run the function to get all their attributes
            }
            elseif($sU_Q0.count -gt 1){
                w '  Found multiple users matching that search:
                ' g
                foreach( $n in $sU_Q0 ){
                    w "   $($n.samAccountName): $($n.displayName)" y
                }
                ''
                w '  Type one of the usernames above, or hit ENTER for a new search:' g
                w '   > ' g -i; $Z = Read-Host
                if( $Z -in $sU_Q0.samAccountName ){
                    Remove-Variable sU_*
                    singleUser $Z
                }
            }
        }

        if( $su_Q1 ){

            <#####################################################################################
            MOD SECTION!
            If your administrator usernames are not registered like "admin-bob" or "bob.admin",
            Modify the line below! This checks for potential user-level accounts that were added
            into admin-privileged group-policies.
            #####################################################################################>
            function listGPO(){
                $sU_GPO | %{
                    if($_ -Like "*admin*" -and $1 -notLike "*admin*"){
                        w "   $_" r
                    }
                    else{
                        w "   $_" y
                    }
                }
            }
            ''
            cleanList $sU_Q1
            ''
            'GPO ASSIGNMENTS:'
            listGPO

            Remove-Variable g
            ''
            if( $sU_SPECIFIC -and -not $PROTOCULTURE ){
                w ' Do you need extra domain details for this user (y/n)?  ' g -i
                $Z = Read-Host
            }


            if( $Z -like "y*"){
                $Z = $null
                while($Z -notMatch "^[AEGS]$"){
                    w " -Enter 'A' for Active-Directory info" g
                    if($dyrl_myl_EDR){
                        w " -Enter 'E' for EDR lookup" g
                    }
                    w " -Enter 'G' for GPO details" g
                    w " -Enter 'S' to skip" g
                    w '  >  ' g -i; $Z = Read-Host
                }
                if( $Z -eq 'A' ){
                    $sU_Q1
                }
                elseif($Z -eq 'E'){
                    uActivity "$1"
                    splashPage
                }
                elseif($Z -eq 'G'){
                    while($Z -ne ''){
                        ''
                        w ' Type the GPO name to view or hit ENTER to cancel: ' g -i
                        $Z = Read-Host
                        if($Z -in $sU_GPO){
                            3gpo $Z 2
                            ''
                            cleanList $sU_Q1
                            ''
                            'GPO ASSIGNMENTS:'
                            listGPO
                        }
                    }
                }

                if($Z -ne 'S'){
                    hetc
                }

                $Z = $null
            }
            $sU_SPECIFIC = $null
        }

    }
    else{
        noFind $1
        hetc
    }

    if( ! $PROTOCULTURE ){
        splashPage
    }

}
############################################
##  END FUNCTIONS
############################################

## If a script for accessing EDR APIs is present, make it available to MYLENE
$dyrl_myl_EDR = availableTypes -e EDR  


if( $vf19_ROBOTECH ){               ## User does not have admin privilege
    while( $dyrl_myl_Z -ne 'q' ){
        splashPage
        w ' What username are you searching on? Enter ' g -i
        w 'q' y -i
        w ' to quit:  ' g -i
        $dyrl_myl_Z = Read-Host
        if( $dyrl_myl_Z -ne 'q' ){
            $dyrl_myl_U = net user $dyrl_myl_Z /domain
            if( $dyrl_myl_U ){
                $dyrl_myl_U
                if( $dyrl_myl_EDR[0] ){  ## MOD SECTION! This is another function linking to EDR tools
                    ''
                    w " Do you want to see this user's most recent login(s)? " g -i
                    $dyrl_myl_CQ = Read-Host
                    if($dyrl_myl_CQ -Like "y*"){
                        uActivity $dyrl_myl_Z        ## Modify the uActivity function way up above to work with your EDR script
                    }
                    Remove-Variable dyrl_myl_CQ
                }
                else{
                    hetc
                    ''
                }
                
            }
            else{
                noFind $dyrl_myl_Z
            }
        }
        else{
            Exit
        }
    }
}
else{

    $dyrl_usage = 1   ## Increments each search. Skip some menus when multiple searches are performed

    do{

        splashPage

        if($dyrl_usage -ne 1){
            Remove-Variable -Force dyrl_myl_* -Scope Global
            $dyrl_myl_loop = $true
            slp 1
        }

        if($vf19_OPT1){
            ''
            while($dyrl_myl_Z -ne 'q'){
                w ' Enter a keyword to search for matching Group Policy names, OR a MM/YYYY' g
                w ' date to view Group Policies by creation times (searches 2 months before and' g
                w ' after the date you enter), OR "q" to quit: ' g -i
                [string]$dyrl_myl_Z = Read-Host
                if($dyrl_myl_Z -ne 'q'){
                    if($dyrl_myl_Z -Match "\d{1,2}/\d{4}"){
                        $dyrl_myl_Z = $dyrl_myl_Z -replace "^0"
                        $dyrl_myl_ZA = $dyrl_myl_Z -Split('/')
                        $dyrl_myl_Z = $dyrl_myl_Z -replace '/','/.*' -replace "$",'.*'
                        3gpo $dyrl_myl_Z 3
                    }
                    else{
                        3gpo $dyrl_myl_Z
                    }
                    $dyrl_myl_Z = ''
                    ''
                    ''
                    w " Hit ENTER to search again, or 'q' to quit: " g -i
                    $dyrl_myl_Z = Read-Host
                }
            }
            Remove-Variable -Force dyrl_myl_*
            Exit
        }


        ## MOD SECTION!
        ## If you have service accounts that use standard naming, modify the $dyrl_myl_NOSVC variable below!
        ## Set default vars
        $dyrl_myl_NOSVC = [regex]"^service\S*"
        $dyrl_myl_SINGLENAME = [regex]"[a-zA-Z]\w\S*"
        $dyrl_myl_WILDC = [regex]"^*?\S*\*$"

        ## Verify paths
        $dyrl_myl_REPORTS = "$vf19_DTOP\NewUserSearches\*.txt"

        
        
        ##### EXTERNAL SCRIPTS #########################################
        ## When calling from other scripts, send multiple usernames as comma-space-separated string
        ## Results only print to screen, they do not write to file!
        if($CALLER -and $PROTOCULTURE){
            ($PROTOCULTURE -replace ', ',',') -Split ',' | %{
                singleUser $_
            }
            ''
            w '  Hit ENTER to continue.' g
            Read-Host; Exit
        }
        ################################################################



        ## Clean up old reports if not needed anymore
        if( (Get-ChildItem -Path $dyrl_myl_REPORTS).count -gt 0){
            if($dyrl_usage -eq 1){
                houseKeeping $dyrl_myl_REPORTS 'MYLENE'
            }
        }

        



        if($dyrl_usage -eq 1){  ## Only run this option once, ignore it for subsequent searches
            ''
            w ' Before searching for user accounts, would you like a list of any recent' c
            w ' hosts joined to the domain?  ' c -i
            $dyrl_myl_Z1 = Read-Host

            if( $dyrl_myl_Z1 -Like "y*" -or $dyrl_myl_Z1 -Match "^\d+$"){
                $dyrl_myl_arrayh = @{}   ## Collect list of hostnames
                $dyrl_myl_sensors = @{}  ## Track hosts with EDR agents installed
                $dyrl_myl_arrayn = 0
                ''
                if($dyrl_myl_Z1 -Like "y*"){
                    while($dyrl_myl_Z1 -notMatch "^\d{1,2}$"){
                        w ' How many days back?  ' g -i
                        $dyrl_myl_Z1 = Read-Host
                    }
                }
                $dyrl_myl_DATE = (Get-Date).AddDays(-$dyrl_myl_Z1)

                ####################################
                ## MOD SECTION!
                ## You can modify this "Where" statement to include additional filters if you're
                ## getting too much noise.
                $dyrl_myl_GAD = Get-ADComputer -Filter * -Properties createTimeStamp,`
                    Name,`
                    whenCreated,`
                    Description,`
                    IPv4Address, `
                    IPv6Address, `
                    OperatingSystem | 
                        Where {$_.createTimeStamp -ge $dyrl_myl_DATE}
        
                w "`n"
                foreach( $dyrl_myl_i in $dyrl_myl_GAD ){
                    $dyrl_myl_arrayn++
                    $dyrl_myl_in = $dyrl_myl_i.Name -replace "\.\w.+$"            ## Remove domain, if any
                    $dyrl_myl_arrayh.Add([string]$dyrl_myl_arrayn,$dyrl_myl_in)


                    ## MOD SECTION!
                    ## Here's another EDR-specific check. You'll probably need to modify it specifically for
                    ## your EDR's output (this was written for Carbon Black JSON responses)
                    if($dyrl_myl_EDR){
                        ## See if EDR has a sensor for the host in question
                        $Global:PROTOCULTURE = $dyrl_myl_in
                        $dyrl_myl_CHECKSENSOR = $(collab $($dyrl_myl_EDR[0]) 'MYLENE' 'sensor' | ConvertFrom-Json)
                        rvf
                        
                        if( $dyrl_myl_CHECKSENSOR[0].id ){
                            $dyrl_myl_SENSOR = $true
                            $dyrl_myl_sensors.Add([string]$dyrl_myl_arrayn,$dyrl_myl_in)
                        }
                    }


                    $dyrl_myl_ipadd0 = $dyrl_myl_i.name
                    $dyrl_myl_ipadd0 = $dyrl_myl_ipadd0.toUpper()
                    $dyrl_myl_ipadd1 = $dyrl_myl_i.IPv4Address
                    $dyrl_myl_ipadd2 = $dyrl_myl_i.IPv6Address
                    
                    if( $dyrl_myl_ipadd1 -and $dyrl_myl_ipadd2 ){
                        screenResults "c~NEW HOST $dyrl_myl_arrayn" $($dyrl_myl_i.Name) "resolves to $dyrl_myl_ipadd1`n$dyrl_myl_ipadd2"
                    }
                    elseif( $dyrl_myl_ipadd1 ){
                        screenResults "c~NEW HOST $dyrl_myl_arrayn" $($dyrl_myl_i.Name) "resolves to $dyrl_myl_ipadd1"
                    }
                    else{
                        screenResults "c~NEW HOST $dyrl_myl_arrayn" $($dyrl_myl_i.Name) 'r~DOES NOT RESOLVE'
                    }
                    screenResults 'Operating System' $($dyrl_myl_i.OperatingSystem)
                    screenResults 'Created' $($dyrl_myl_i.whenCreated)
                    if( $($dyrl_myl_i.Description) ){
                        screenResults 'Description' $($dyrl_myl_i.Description)
                    }
                    else{
                        screenResults 'Description' 'c~NONE'
                    }

                    ## MOD SECTION!  --- EDR results check. It continues to the next section "if( $dyrl_myl_arrayn -gt 0"
                    if($dyrl_myl_CHECKSENSOR){
                        screenResults 'Sensor ID' $($dyrl_myl_CHECKSENSOR[0].id)
                        screenResults 'Registered' $($($dyrl_myl_CHECKSENSOR[0].registration_time) -replace "\..*")
                        screenResults 'Last Checkin' $($($dyrl_myl_CHECKSENSOR[0].last_checkin_time) -replace "\..*")
                        screenResults 'OS Check' $($dyrl_myl_CHECKSENSOR[0].os_environment_display_string)
                        screenResults 'Status' $($dyrl_myl_CHECKSENSOR[0].status)
                        Remove-Variable -Force dyrl_myl_CHECKSENSOR -Scope Global
                    }
                    else{
                        screenResults 'c~No EDR agent installed!'
                    }
                    
                    
                    screenResults -e
                    
                }
                
                Remove-Variable dyrl_myl_DATE

                ''
                w ' ...search complete.
                ' g

                ## If hosts were found and EDR script exists, offer to search EDR for any host's activity
                if( $dyrl_myl_arrayn -gt 0 ){
                    if($dyrl_myl_SENSOR){
                    while( $dyrl_myl_Z -ne 'skip' ){
                        w ' Select a' g -i
                        w ' NEW HOST #' c -i
                        w ' to query EDR, or hit ENTER to skip: ' g -i
                        $dyrl_myl_Z1 = Read-Host
                        if($dyrl_myl_Z1 -Match "^\d+$"){

                            $dyrl_myl_HH = $dyrl_myl_sensors[$dyrl_myl_Z1]
                            
                            if( $dyrl_myl_HH ){
                                hActivity  $dyrl_myl_HH
                                w "`n"
                                foreach($key in $dyrl_myl_arrayh.keys){
                                    if($key -in $dyrl_myl_sensors.keys){
                                        screenResults "c~NEW HOST $key" $dyrl_myl_arrayh[$key]
                                    }
                                    else{
                                        screenResults "c~NEW HOST $key" 'r~ (no cb agent installed)'
                                    }
                                }
                                screenResults -e
                                ''
                            }
                            else{
                                w ' That host does not have an agent installed.' c
                            }
                        }
                        else{
                            $dyrl_myl_Z1 = 'skip'
                            Break
                        }

                    }
                    }
                }

                Clear-Variable -Force dyrl_myl_Z1,dyrl_myl_arrayh,dyrl_myl_arrayn
                w "`n"

                w '  Continue to new user search? (y/n) ' g -i
                $dyrl_myl_Z1 = Read-Host

                if( $dyrl_myl_Z1 -Match "^n" ){
                    Remove-Variable dyrl_myl_*
                    Exit
                }

            }
        }
        

    

        $dyrl_myl_loop = $true
        while( $dyrl_myl_loop ){
            ''
            w '  OPTIONS:' g
            w '    -Enter a username (you can wildcard' g -i
            w ' *' y -i
            w " if you don't have the full name)" g
            w '    -Enter "' -i g
            w 'd' -i y
            w '" to search by user Description objects' g
            w '    -Enter how many days back you want to search for new accounts (max 30)' g
            w '    -Add an "' -i g
            w 'f-' -i y
            w '" to save your results (example, "30f-")' g
            w '    -Enter "' -i g
            w '?' -i y
            w '" to see examples for writing your own searches' g
            w '    -Enter "' -i g
            w 'q' -i y
            w '" to quit' g
            w ' > ' g -i
            $dyrl_myl_Z = Read-Host
    
            
            if($dyrl_myl_Z -like "*f-"){ 
                $dyrl_myl_wf = $true 
                $dyrl_myl_Z = $dyrl_myl_Z -replace "f\-$"
                ''
                w ' Results will be saved on your desktop in "NewUserSearches\"...
                ' y
            }
            else{ $dyrl_myl_wf = $false }

            if( $dyrl_myl_Z -eq 'q' ){
                if( $CALLER ){
                    Remove-Variable dyrl_myl_*
                    Return
                }
                else{
                    Remove-Variable dyrl_myl_*
                    Exit
                }
            }
            
            if($dyrl_myl_Z -eq '?'){
                selfService
                ''
            }
            elseif($dyrl_myl_Z -eq 'd'){
                $dyrl_myl_Z = ''
                splashPage
                searchDesc
            }
            elseif( $dyrl_myl_Z -Match $dyrl_myl_SINGLENAME ){
                singleUser $dyrl_myl_Z
            }
            elseif( $dyrl_myl_Z -Match "^\d+$" ){
                while( $dyrl_myl_Z -gt 30 ){
                    w "  $dyrl_myl_Z is not less than 30. Please enter a new number:  " c -i
                    $dyrl_myl_Z = Read-Host
                }



                ####### SET UP REPORT OUTPUTS ##################################################################
                if($dyrl_myl_wf){
                    ## Format the output filenames; generate new filenames if previous outputs exist
                    ## Currently appends a-z at the end of the filename, then goes back and appends two letters
                    ##     (ab, ac, ad, etc.) if the whole alphabet was already used once. Hopefully nobody
                    ##     needs more than 52 reports at a time.
                    $dyrl_myl_FDATE = "$(Get-Date -f yyyy-MM-dd_hh:mm-)"
                    $dyrl_myl_REPAL = 'abcdefghijklmnopqrstuvwxyz'
                    $dyrl_myl_REPNO = 0
                    $dyrl_myl_OUTNAME = "MYLENE_" + $dyrl_myl_FDATE + $dyrl_myl_REPAL[$dyrl_myl_REPNO]
                    do{
                        if( $dyrl_myl_REPNO -le 25 ){
                            $dyrl_myl_REPNO++
                            $dyrl_myl_OUTNAME = 'MYLENE_' + $dyrl_myl_FDATE + $dyrl_myl_REPAL[$dyrl_myl_REPNO] + '.txt'
                        }
                        else{
                            $dyrl_myl_REPNO++
                            $dyrl_myl_REPNO2 = $dyrl_myl_REPNO + 1
                            $dyrl_myl_OUTNAME = 'MYLENE_' + $dyrl_myl_FDATE + $dyrl_myl_REPAL[$dyrl_myl_REPNO] + $dyrl_myl_REPAL[$dyrl_myl_REPNO2] + '.txt'
                        }
                    }while( Test-Path "$vf19_DTOP\NewUserSearches\$dyrl_myl_OUTNAME*" )
                    $dyrl_myl_FO = ($vf19_M[2] * $vf19_M[1]) * ($vf19_M[1] + $vf19_M[0]) - 2
                    $dyrl_myl_FO = [string]$dyrl_myl_FO
                }
                ####### SET UP REPORT OUTPUTS ##################################################################




                $dyrl_myl_loop = $false
                $dyrl_myl_DATE = (Get-Date).AddDays(-$dyrl_myl_Z)
            }
            else{
                w '  What?
                ' c
                slp 2
            }
    

        }
        ''
        w '
     If you get a large amount of results, you can click anywhere in the window
     to pause the script, then hit "Backspace" or the back arrow key to resume.
                          
     Polling AD...
        ' g


        ##########
        ## Parse out user properties as needed
        ##########
        $dyrl_myl_GETNEWTABLE = Get-ADUser -Filter * -Properties * |
            Where{$_.whenCreated -gt $dyrl_myl_DATE}
        $Script:dyrl_myl_howmany = $dyrl_myl_GETNEWTABLE.count
        $dyrl_myl_ACCOUNTLIST = @{}

    

        ##########
        ## Make sure we have a directory to collect search result files into
        ##########
        if( ! (Test-Path "$vf19_DTOP\NewUserSearches\") ){
            New-Item -Path $vf19_DTOP -Name 'NewUserSearches' -ItemType 'directory'
        }


        if( $dyrl_myl_GETNEWTABLE -ne $null ){
            $Script:dyrl_myl_MULTIACCT = @()

           
            function listAccounts(){
                $track = 1
                $dyrl_myl_MULTIACCT | %{
                    cleanList $_ $track
                    $track++
                }
            }



            $nnn = 0; $dyrl_myl_GETNEWTABLE | %{
                Write-Progress -activity "Searching for new users..." `
                    -status "Collecting $nnn of $dyrl_myl_howmany" `
                    -CurrentOperation "Found user: $($_.samAccountName)" `
                    -percentComplete (($nnn / $dyrl_myl_howmany)  * 100)
                $dyrl_myl_ACCOUNTLIST.Add($_.samAccountName,$_)
            }
            Write-Progress -activity 'Searching for new users...' -Completed
            Remove-Variable -Force nnn
            $dyrl_myl_ACCOUNTLIST | %{
                $k = $dyrl_myl_ACCOUNTLIST.Keys
                $Script:dyrl_myl_MULTIACCT += $dyrl_myl_ACCOUNTLIST[$k]
            }
        
            listAccounts

            if( $dyrl_myl_wf -and (Test-Path -Path "$vf19_DTOP\NewUserSearches\$dyrl_myl_OUTNAME") ){
                w '  Search results (if any) have been written to' g
                w " $vf19_DTOP\NewUserSearches\$dyrl_myl_OUTNAME"
            }
            elseif($dyrl_myl_wf){
                $ermsg = "Failed to write $vf19_DTOP\NewUserSearches\$dyrl_myl_OUTNAME"
                errLog $ermsg
                w $ermsg c; Remove-Variable -Force ermsg
            }

        }
        else{
            w '   No users found during this time window. Press ENTER to exit... 
            ' c
            Read-Host
            Remove-Variable dyrl_myl_*
            Exit
        }

        
        function firstMenu (){ 
            w "
         -Enter a NEW ACCOUNT number to view that specific user's GPO assignments
         -Enter a keyword to search existing Group Policies for these users
          (example: 'admin', 'Temp', etc.)
         -Hit ENTER to skip:  " g -i
            Return $(Read-Host)
        }

        $dyrl_myl_Z = firstMenu
        ''
    
        <# Example of iterating through user groups
            get-aduser -filter "samaccountname -eq '$USER'" -properties memberof | 
            select-object -expandproperty memberof | 
            foreach( $_.memberof ){
                if($_ -Match "$GROUP"){write-host $_}
            }
        #>

        if( $dyrl_myl_Z -eq '' ){
            $dyrl_myl_SKIP1 = $true   ## No need to reload the list if the screen isn't changing
        }
        else{
            $dyrl_myl_userReload = $true
        }


        ## Loop the choices until users have investigated all the accounts they needed to
        while( $dyrl_myl_userReload ){

            
            function keepSearching(){
                w '  Enter:' g
                w '    -a different "NEW ACCOUNT" number to view their permissions' g
                w '    -keyword(s) for GPO assignments' g
                w '    -"gpo" to view details for a specific group policy' g
                w '    -hit ENTER to reload the user list' g
                w '    -"q" to quit' g
                w '  > ' g -i
                Return $(Read-Host)
            }

            $dyrl_myl_ZPO = $true


            if($dyrl_myl_Z -Match "^[0-9]+$"){
                $dyrl_myl_Z = $dyrl_myl_Z - 1
                $dyrl_myl_UGPO = $dyrl_myl_MULTIACCT[$dyrl_myl_Z] | Select -ExpandProperty memberOf
                if($dyrl_myl_UGPO){
                w "  $($dyrl_myl_MULTIACCT[$dyrl_myl_Z].samAccountName) is assigned:" c
                #listGroups $dyrl_myl_UGPO
                $dyrl_myl_UGPO | %{
                    $g = $_ -replace "..=" -replace ",.*$"
                    w "     $g" y
                }
                Remove-Variable g
                }
                else{
                    w '
        That is not a valid selection.
                    ' c
                    slp 2
                    $dyrl_myl_BADCHOICE = $true
                    $dyrl_myl_ZPO = $false
                }
                
            }
            elseif($dyrl_myl_Z -Match "[a-z]"){
                screenResultsAlt -e
                $dyrl_myl_MULTIACCT | %{
                    $dyrl_myl_UGPO = $_ | Select -ExpandProperty memberOf
                    w "  Searching $($_.samAccountName) for " -i c
                    Write-Host "$dyrl_myl_Z" -i 
                    w ':' c
                    #listGroups $dyrl_myl_UGPO $dyrl_myl_Z
                    $dyrl_myl_UGPO | %{
                        $g = $_ -replace "..=" -replace ",.*$"
                        if($g -Match $dyrl_myl_Z){
                            w "        $g" y
                        }
                    }
                    Remove-Variable g
                }
            }
            else{
                $dyrl_myl_ZPO = $false
            }

            $dyrl_myl_Z = $null
            Remove-Variable dyrl_myl_Z,dyrl_myl_GRPMEM
            ''


            

            while( $dyrl_myl_ZPO ){
                $dyrl_myl_Z = keepSearching
                ''
                if( $dyrl_myl_Z -eq 'q' ){
                    Exit
                }
                elseif( $dyrl_myl_Z -eq '' ){
                    $dyrl_myl_ZPO = $false
                }
                elseif($dyrl_myl_Z -eq 'gpo'){
                    ''
                    $dyrl_myl_Z = $null
                    w " Enter a GPO to search for. If you don't enter an exact GPO name, you" g
                    w " may end up with several results: " -i g
                    $dyrl_myl_Z = Read-Host
                    if($dyrl_myl_Z -Match "\w{2,}"){
                        3gpo $dyrl_myl_Z
                        ''
                        hetc
                    }
                }

                ## Don't reset anything if the user searching GPO memberships with a new keyword
                else{
                    $dyrl_myl_SKIPMENU = $true
                    $dyrl_myl_ZPO = $false
                }
            }

            if( ! $dyrl_myl_BADCHOICE -and ! $dyrl_myl_SKIPMENU ){
                listAccounts
            }
            else{
                $dyrl_myl_BADCHOICE = $false
            }

            if( ! $dyrl_myl_SKIPMENU ){
                $dyrl_myl_Z = firstMenu
                if($dyrl_myl_Z -eq ''){
                    $dyrl_myl_userReload = $false
                    $dyrl_myl_SKIP1 = $true
                }
                ''
            }
            else{
                $dyrl_myl_SKIPMENU = $false
            }
        }

        $dyrl_myl_SKIP2 = $true
        $dyrl_myl_Z = $null
        ''
        if( $dyrl_myl_EDR ){
            if( ! $dyrl_myl_SKIP2 ){
                splashPage
                listAccounts
            }
            while($dyrl_myl_Z -ne ''){
                w '  Enter a NEW ACCOUNT number for a quick host/process lookup on' g
                w '  that username, or hit ENTER to skip: ' g -i 
                $dyrl_myl_Z = Read-Host
                if($dyrl_myl_Z -Match "^\d+$"){
                    $dyrl_myl_Z = $dyrl_myl_Z - 1
                    $CUSER = $dyrl_myl_MULTIACCT[$dyrl_myl_Z].samAccountName
                    uActivity $CUSER
                    Remove-Variable CUSER
                    rvf
                    $dyrl_myl_Z = $null
                
                    splashPage
                    listAccounts
                }
                ''
            }
        }



        $dyrl_myl_Z = $null

        if( $dyrl_myl_GETNEWFILE ){
            w '  Search results (if any) have been written to text files on your Desktop' g
            w '  in the folder ' g -i
            w 'target-pkgs' y -i
            w '.
            ' g
        }


        ## Prevent user accidentally clearing the screen if they've been hitting ENTER during slow searches
        while( $dyrl_myl_Z -notMatch "^[cq]$" ){
            w '  Type "' g -i; w 'c' y -i; w '" to continue, or "' g -i; w 'q' y -i
            w '" to quit:   ' g -i; $dyrl_myl_Z = Read-Host
        }

        if($dyrl_myl_Z -eq 'c'){
            $dyrl_myl_Z = $null
            $dyrl_usage++  ## Switch menus after first run-thru
        }

    }while($dyrl_myl_Z -ne 'q') 

}

