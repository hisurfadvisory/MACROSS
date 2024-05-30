#_sdf1 User lookup + audit new accounts
#_ver 2.5
#_class user,active-directory lookups,powershell,HiSurfAdvisory,1,onscreen

<#
    MYLENE: Target recently-created accounts for inspection; look up AD info
    on users of interest

    This script uses the "net" utility and Active-Directory cmdlets to gather
    data on enterprise users and hosts -- primarily accounts and devices
    that are newly-joined to your domain.

    MYLENE is part of the MACROSS framework, so many tasks or functions may
    not be available to a user if they've been ID'd as not having admin-
    level privilege to perform these lookups. This is determined at startup
    in the "validation.ps1" file's function "setUser".

    If MYLENE is run with admin- or Active Directory read-permissions:
    1) AD Objects will be collected based on:
        -usernames
        -hostnames
        -creation dates
        -keywords to match against Group-Policy names

    2) Anomalous attributes can be highlighted by modifying the function "cleanList".
        Look for line 725, or the section labeled
        "Add other values here to highlight deviations from standard account attributes"

    3) Results will output to screen and to your Desktop in a folder called
        "NewUserSearches" when searching for newly-created accounts.

    4) Standard user searches will have summaries printed to screen, with
        options to display more info as needed. Future updates will have
        improved outputs for $CALLER scripts.
    
    5) This script was written in an environment that used VMWare's Carbon Black as an
        Endpoint Detection (EDR) solution, which this script would use to perform user
        activity lookups to aid analyst investigations. If your environment uses something
        else, you can modify the EDR/Carbon Black sections of this script to fit your needs.
        You may also find it useful to write your own EDR API script in powershell or
        python so that it can be used within MACROSS with your other scripts.

        If there is no EDR, don't worry. If you delete GERWALK from the "modules" folder,
        MACROSS will know there is no EDR-specific script and won't offer the option to this
        or any other tool.

    ---------------------------------------------------
    If calling MYLENE from your script via the "collab" function, MYLENE
    does not return any values. It writes all of its search results
    for $PROTOCULTURE to the screen, then exits back to your script when
    the analyst is finished reviewing it.
    ---------------------------------------------------

    Scan this script for all the comment lines with "MPOD ALERT!". They contain tips for
    modifying those lines to meet your needs.



#>


## Watch for python scripts making queries:
## First param needs to be your script's name, prefixed with "py"
param(
    [Parameter(position = 0)]
    [string[]]$dyrl_mypy_CALLER,  ## The calling script
    [Parameter(position = 1)]
    [string[]]$dyrl_mypy_QNAME,   ## The username being queried
    [Parameter(position = 2)]
    [string[]]$dyrl_mypy_DESKTOP, ## The user's desktop path
    [Parameter(position = 3)]
    [string]$dyrl_mypy_GBIO       ## The garbage_io folder path
)

## Python scripts must call MYLENE with all 4 params.
if($dyrl_myl_CALLER){
    if($dyrl_myl_CALLER -Match "^py"){
    if($dyrl_mypy_QNAME -Match "\w"){
    if($dyrl_mypy_DESKTOP -Match "\w"){
    if($dyrl_mypy_GBIO -Match "\w"){
        $CALLER = $dyrl_mypy_CALLER -replace "^py"
        $PROTOCULTURE = $dyrl_mypy_QNAME
        $vf19_DEFAULTPATH = $dyrl_mypy_DESKTOP
        $vf19_GBIO = $dyrl_mypy_GBIO
    }}}}
    else{
        Read-Host " 
        You are missing arguments, I can't perform the query. Hit ENTER to quit."
        Exit
    }
    Remove-Variable -Force dyrl_mypy_*
}



## Display help/description
if( $HELP ){
    cls
    Write-Host -f YELLOW "
 Author: $($vf19_LATTS['MYLENE'].author)
 version $($vf19_LATTS['MYLENE'].ver)
 
 
 
 MYLENE's Recent Account Search lets you perform user lookups by name or creation 
 date. As an admin, you can query Active Directory for partial name matches. If you 
 don't know the entire username, you can search with wildcards (*), but it might 
 return several results. If you wildcard the front  of your searches, you must 
 wildard the end (ex. *partname will not work, but *partname* and partname* will).
 
 When searching for recently created users, you can:
    -forward search results to the KONIG tool to perform a filesearch on those 
        profiles.
    -do a quick keyword search on all of the new accounts' GPO assignments
    -get a quickview of all the GPO assignments for specific new accounts
    -get a quick alert for non-standard attributes on any new accounts (i.e. things 
        like 'null password' will be highlighted in red)
 
 MYLENE also lets you search for new hosts recently added to the network.

 If you are NOT admin, your search will be performed with the " -NoNewline;
    Write-Host -f GREEN 'net' -NoNewline;
    Write-Host -f YELLOW ' utility, and
 you cannot wildcard. You must search for exact names.


 If you are logged in as admin and select MYLENE with the "s" option (example "12s" 
 from the main menu), you can search for keywords and creation dates instead of 
 usernames in Active-Directory GPO.

 
 Hit ENTER to return.
 '

    Read-Host
    Return
}

getThis '4pWR'
$c = $vf19_READ

############################################
##  BEGIN FUNCTIONS
############################################
## Display tool banner
function splashPage(){
    cls
    Write-Host '
    '
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
    Write-Host $vf19_READ
    ''
    Write-Host "          ==== Mylene's Recent Accounts Search ====
    "
}


function noFind($1){
    Write-Host -f YELLOW " $1" -NoNewline;
    Write-Host -f GREEN ' not found! Hit ENTER.
    '
    Read-Host
}

## Let user choose when to proceed
function hetc(){
    Write-Host -f GREEN ' Hit ENTER to continue. ' -NoNewline; Read-Host
}


function rvf(){
    Remove-Variable -Force CALLER,PROTOCULTURE -Scope Global
}



<#####################################################################################
    MPOD ALERT!
    The $vf19_C8 variable is set to $true when you have a Carbon Black EDR deployment
    and the GERWALK script in the modules folder. It enables analysts to automatically
    pull logged-in activity from the EDR for any username they find with MYLENE.

    If you have a different EDR and script you've created for MACROSS, make sure to 
    modify this section to make use of those instead. 
#####################################################################################>
## GERWALK plugin function
if( $vf19_C8 ){
    function uActivity($1){  ## Send a username to Carbon Black
        $Global:PROTOCULTURE = $1
        $activityu = collab 'GERWALK.ps1' 'MYLENE' 'usrlkup'
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

        screenResults 'endr'
        hetc
        ''
        Remove-Variable -Force activityu
    }

    function hActivity($1){  ## Send a hostname to Carbon Black
        $Global:PROTOCULTURE = $1

        if( ! $activityh ){
            $activityh = collab 'GERWALK.ps1' 'MYLENE' 'hlkup'
            rvf
        }

        ## GERWALK randomly sends a useless header with the max results,
        ## need to ignore when it does this
        if(($activityh).count -gt 2){
            $f = $($activityh[1] | ConvertFrom-Json).facets   # CB results
            $l = $activityh[2]                                # Noisy proc lists
        }
        else{
            $f = $($activityh[0] | ConvertFrom-Json).facets
            $l = $activityh[1]
        }

        ## Query C2EFFD to see if it has host descriptions
        if($1 -Like "*-*"){
            $Global:PROTOCULTURE = $($1 -replace "^.*\-",'-' -replace "\.ent.*$" -replace "\d{3,4}$")
        }
        $type = (collab 'C2EFFD.ps1' 'MYLENE' 'sendback').TYPE
        rvf


        while( $z -ne '' ){
            screenResults "           Activity on host $1 ($type)"
            screenResults 'c~ACCOUNTS' 'c~RUNNING PROCESSES' 'c~CB GROUP'
            screenResults "$($f.username_full.name)" "$($f.process_name.name)" "$($f.group.name)"
            screenResults "Last seen: $(($f.start.name | Sort -Descending)[0])"
            screenResults 'endr'
            ''
            w ' Type a username to view their recent activity, or hit ENTER to continue.' 'g'
            Write-Host -f GREEN ' Username: ' -NoNewline;
            $z = Read-Host
            if( $z -ne ''){
                if($z -notLike '*\*'){
                    $z = 'ENT\' + $z  ## try to be helpful
                }
                if($z -in $($f.username_full.name)){
                    $z = $z -replace "^.*\\"
                    uActivity $z
                }
                elseif($z -Match "\w"){   ## Might be another domain other than "ENT"
                    ''
                    w " That name isn't listed. Try adding the domain.
                    " 'c'
                }
            }
        }
    }

}


## Make the "memberOf" field actually readable
## $1 is the GPO object (memberOf), $2 is the user's search string (optional)
function listGroups($1,$2){
    if($2){
        $1  | 
            Select-String -Pattern $2 | 
            Sort -Unique | 
            %{
                $cat = detailGroups $_
                $grp = $($_ -replace "..=" -replace ",.*$") + ' (' + $cat + ')'
                Write-Host -f YELLOW "   $grp"
            }
    }
    else{
        $1 | 
            Sort -Unique |
            %{
                $cat = detailGroups $_
                $grp = $($_ -replace "..=" -replace ",.*$") + ' (' + $cat + ')'
                Write-Host -f YELLOW "   $grp"
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
## been determined). If $2 is sent, it will be written to file first (should usually be a 
## username, or empty space to separate each user entry)
function w2f($1,$2){
    if($2){
        $2 | Out-File -Filepath "$vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_OUTNAME" -Append
    }
    $1 | Out-File -Filepath "$vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_OUTNAME" -Append
}


## Provide examples to noobs on how they can query active-directory themselves
function selfService(){
    Write-Host -f GREEN '
    Here are some examples for searching users with the "get-aduser" cmdlet (not case-sensitive):
    '
    ''
    "   Return a limited set of attributes for a specific account:"
    Write-Host -f YELLOW $(" get-aduser -filter 'samaccountname -eq " + '"USERNAME"' + " '")
    ''
    Write-Host "   Return all of the account's attributes. Take note of all the attribute keys (on the left when
    your search gives back results) and use them to refine your searches:"
    Write-Host -f YELLOW $("get-aduser -filter 'samaccountname -eq " + '"USERNAME"' + "' -properties *")
    ''
    '   Return all account names that are disabled:'
    Write-Host -f YELLOW $(' (get-aduser -filter * -properties * | where {$_.enabled -eq "false"}).samaccountname')
    ''
    '   Search for accounts with "j63" in the description, and show you only their names & descriptions:'
    Write-Host -f YELLOW $(' get-aduser -filter * -properties * | where {$_.description -like "*j63*"} | select samaccountname,displayname,description')
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
                    screenResultsAlt $item 'CREATED' $crlo
                    screenResultsAlt 'next' 'LASTLOGON' $llogon
                    screenResultsAlt 'next' 'INFO' $d
                    screenResultsAlt 'endr'
                }
                else{
                    screenResults $item $d
                }
            }
            screenResults 'endr'
            ''
        }
        ''
        while($Z -notMatch "(d|o|c)"){
            Write-Host -f GREEN ' Do you want to search by (' -NoNewline;
            Write-Host -f YELLOW 'd' -NoNewline;
            Write-Host -f GREEN ')escription or (' -NoNewline;
            Write-Host -f YELLOW 'o' -NoNewline;
            Write-Host -f GREEN ')ffice/Org (type "' -NoNewline;
            Write-Host -f YELLOW 'c' -NoNewline;
            Write-Host -f GREEN '" to cancel)?  ' -NoNewline;
            $Z = Read-Host
        }

        if($Z -eq 'c'){
            Remove-Variable -Force list -Scope Global
            Return
        }

        Write-Host -f GREEN ' Enter your keyword(s): ' -NoNewline;
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
                    screenResultsAlt 'endr'
                }
                else{
                    screenResults 'ACCOUNT' '   OFFICE | ORG'
                }
                listSearchR
                Write-Host -f GREEN ' Select a number for full details, or ENTER to skip: ' -NoNewline;
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
            Write-Host -f CYAN ' Nothing found.
            '
        }

        Write-Host -f GREEN ' Hit ENTER to search descriptions again, or type "c" to cancel: ' -NoNewline;
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
                Write-Host -f YELLOW "  $i" -NoNewline;
                Write-Host -f GREEN ". $_"
                $i++
            }
            Write-Host '
            '
            while( ! $l ){
                Write-Host -f GREEN ' Select a number from the list to view it in detail, or "q" to quit: ' -NoNewline;
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
                        screenResults 'endr'
                        screenResults 'endr'
                        screenResults 'endr'
                        screenResults '  MANAGED BY' $gman
                        screenResults '  UPDATED' $changed
                    }
                }
                screenResults 'endr'
                ''
                while($Z -ne 'q'){
                    Write-Host -f GREEN ' Enter "' -NoNewline;
                    Write-Host -f YELLOW 'm' -NoNewline;
                    Write-Host -f GREEN '" to view group members, "' -NoNewline;
                    Write-Host -f YELLOW 'd' -NoNewline;
                    Write-Host -f GREEN '"' -NoNewline;
                    Write-Host -f GREEN " to view this GPO's full description,"
                    Write-Host -f GREEN ' "' -NoNewline;
                    Write-Host -f YELLOW 'x' -NoNewline;
                    Write-Host -f GREEN '" for extra details, ' -NoNewline;
                    if($vf19_OPT1){
                        Write-Host -f GREEN 'or "' -NoNewline;
                    }
                    else{
                        Write-Host -f GREEN '"' -NoNewline;
                    }
                     Write-Host -f YELLOW 'c' -NoNewline;
                    if($vf19_OPT1){
                        Write-Host -f GREEN ' to cancel and go back:'
                    }
                    else{
                        Write-Host -f GREEN '" to cancel, ' -NoNewline;
                        if($option -eq 2){
                            Write-Host -f GREEN 'or "' -NoNewline;
                        }
                        else{
                            Write-Host -f GREEN '"' -NoNewline;
                        }
                        Write-Host -f YELLOW 'q' -NoNewline;
                        if($option -eq 2){
                            Write-Host -f GREEN '" to quit MYLENE.'
                        }
                        else{
                            Write-Host -f GREEN '" to quit MYLENE, or a new'
                            Write-Host -f GREEN ' keyword to search:'
                        }
                    }
                    Write-Host -f GREEN '  > ' -NoNewline;
                    $Z = Read-Host
                    if($Z -eq 'm'){
                        $Zu = $null
                        $d = 'cyan~DERP!'
                        $uaccts = @{}
                        function showAccts(){
                            $uaccts.keys | %{
                                $fn = $uaccts[$_]
                                screenResults $_ $fn
                            }
                            screenResults 'endr'
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
                                Write-Host -f GREEN " Type 'derp' to show all members if there are derp'd entries, or hit"
                            }
                            else{
                                Write-Host -f GREEN ' Hit' -NoNewline;
                            }
                            Write-Host -f GREEN ' ENTER to continue, or type a username to lookup their account'
                            Write-Host -f GREEN ' (wildcarding names "*" is okay): ' -NoNewline;
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
                        Write-Host -f CYAN "  $gdesc
                        "
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
            MPOD ALERT!
            Add or remove the active-directory properties below to fit your needs. They are
            currently being set as script-scoped variables so that you can add them into
            other parts of this script if you need to. As-is, they are only used within
            this function. 
        #####################################################################################>
        $Script:dyrl_myl_0username = $1.samAccountName
        $Script:dyrl_myl_0propername = $1.displayName
        $Script:dyrl_myl_0title = $1.Title
        $Script:dyrl_myl_0fullnm = $1.Name
        $Script:dyrl_myl_0cn = $1.CN
        $Script:dyrl_myl_0desc = $1.Description
        #$Script:dyrl_myl_0created = $1.createTimeStamp    ## This is a useless replication
        $Script:dyrl_myl_0wcreated = $1.whenCreated
        $Script:dyrl_myl_0changed = $1.whenChanged
        $Script:dyrl_myl_0lastlogon = $1.lastLogonDate
        #$Script:dyrl_myl_0modified = $1.Modified          ## These are also replicated and useless
        #$Script:dyrl_myl_0wmodified = $1.modifyTimeStamp
        $Script:dyrl_myl_0enabled = $1.Enabled
        $Script:dyrl_myl_0lockedout = $1.LockedOut
        if($dyrl_myl_lockedout -eq $true){
            $Script:dyrl_myl_0locktime = $1.AccountLockoutTime
        }
        $Script:dyrl_myl_0email = $1.Mail
        $Script:dyrl_myl_0phone = $1.telephoneNumber
        $Script:dyrl_myl_0room = $1.roomNumber
        $Script:dyrl_myl_0passwX = $1.PasswordNeverExpires
        $Script:dyrl_myl_0passwN = $1.PasswordNotRequired
        $Script:dyrl_myl_0exp = $1.AccountExpirationDate
        $Script:dyrl_myl_0smartC = $1.SmartcardLogonRequired


        if($2 -gt 0){
            $n = "NEW ACCOUNT $([string]$2)" + ". $dyrl_myl_0username"
        }
        else{
            $n = $dyrl_myl_0username
        }
        
        ## Check for sus timestamps
        if($dyrl_myl_0wcreated -like "*00:00"){
            $dyrl_myl_0wcreated = 'r~' + $dyrl_myl_0wcreated
        }
        

        <#####################################################################################
            MPOD ALERT!
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
        #if($dyrl_myl_0username -notMatch $pattern){
        #    $desc_label = 'r~' + $desc_label
        #}


        if( ! $CALLER -and -not $PROTOCULTURE){
            screenResultsAlt $n 'NAME' $dyrl_myl_0cn
        }
        else{
            screenResultsAlt 'endr'
            screenResultsAlt 'next' 'NAME' $dyrl_myl_0cn
        }   
        screenResultsAlt 'next' 'CREATED    ' "$dyrl_myl_0wcreated " ## Add whitespace so values are never empty
        screenResultsAlt 'next' $desc_label   "$dyrl_myl_0desc "
        screenResultsAlt 'next' 'INFO       ' "$dyrl_myl_0info "
        screenResultsAlt 'next' 'LAST LOGON ' "$dyrl_myl_0lastlogon "
        screenResultsAlt 'next' 'EMAIL      ' "$dyrl_myl_0email "
        screenResultsAlt 'next' 'PHONE      ' "$dyrl_myl_0phone "
        screenResultsAlt 'next' 'OFFICE     ' "$dyrl_myl_0room "
        if($dyrl_myl_0exp -Match "\w"){ 
            screenResultsAlt 'next' 'r~EXPIRES' $dyrl_myl_0exp
        }
        if($dyrl_myl_0passwX -eq $true -or $dyrl_myl_0passwN -eq $true){
            screenResultsAlt 'next' 'r~ALERT      ' 'PASSWORD NULL OR NEVER EXPIRES'
        }
        if( $dyrl_myl_0enabled -eq $false ){
            screenResultsAlt 'next' 'STATUS     ' 'w~ACCOUNT IS DISABLED'
        }
        if( $dyrl_myl_0lockedout -eq $true){
            screenResultsAlt 'next' 'STATUS     ' "w~ACCOUNT IS LOCKED ($dyrl_myl_0locktime)"
        }
        screenResultsAlt 'endr'

        if($dyrl_myl_wf){
            w2f "Username: $dyrl_myl_0username   ||   Fullname: $dyrl_myl_0propername"
            w2f "Created: $dyrl_myl_0created"
            w2f "Description: $dyrl_myl_0desc"
            w2f ''
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
                ' 'g'
                foreach( $n in $sU_Q0 ){
                    w "   $($n.samAccountName): $($n.displayName)" 'y'
                }
                ''
                w '  Type one of the usernames above, or hit ENTER for a new search:' 'g'
                w '   > ' 'g' 'nl'; $Z = Read-Host
                if( $Z -in $sU_Q0.samAccountName ){
                    Remove-Variable sU_*
                    singleUser $Z
                }
            }
        }

        if( $su_Q1 ){

            <#####################################################################################
            MPOD ALERT!
            If your administrator usernames are not registered like "admin-bob" or "bob.admin",
            Modify the line below! This checks for potential user-level accounts that were added
            into admin-privileged group-policies.
            #####################################################################################>
            function listGPO(){
                $sU_GPO | %{
                    if($_ -Like "*admin*" -and $1 -notLike "*admin*"){
                        Write-Host -f RED "   $_"
                    }
                    else{
                        Write-Host -f YELLOW "   $_"
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
                Write-Host -f GREEN ' Do you need extra domain details for this user (y/n)?  ' -NoNewline;
                $Z = Read-Host
            }


            if( $Z -like "y*"){
                $Z = $null
                while($Z -notMatch "^(A|C|G|S)$"){
                    Write-Host -f GREEN " -Enter 'A' for Active-Directory info"
                    if($vf19_C8){
                        Write-Host -f GREEN " -Enter 'C' for a Carbon Black lookup"  ## MPOD ALERT! If you are using another EDR script, you should modify this check
                    }
                    Write-Host -f GREEN " -Enter 'G' for GPO details"
                    Write-Host -f GREEN " -Enter 'S' to skip"
                    Write-Host -f GREEN '  >  ' -NoNewline; $Z = Read-Host
                }
                if( $Z -eq 'A' ){
                    $sU_Q1
                }
                elseif($Z -eq 'C'){
                    uActivity "$1"
                    splashPage
                }
                elseif($Z -eq 'G'){
                    while($Z -ne ''){
                        ''
                        Write-Host -f GREEN ' Type the GPO name to view or hit ENTER to cancel: ' -NoNewline;
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



if( $vf19_ROBOTECH ){
    while( $dyrl_myl_Z -ne 'q' ){
        splashPage
        Write-Host -f GREEN ' What username are you searching on? Enter ' -NoNewline;
        Write-Host -f YELLOW 'q' -NoNewline;
        Write-Host -f GREEN ' to quit:  ' -NoNewline;
        $dyrl_myl_Z = Read-Host
        if( $dyrl_myl_Z -ne 'q' ){
            $dyrl_myl_U = net user $dyrl_myl_Z /domain
            if( $dyrl_myl_U ){
                $dyrl_myl_U
                if( $vf19_C8 ){  ## MPOD ALERT! This is another function linking to EDR
                    ''
                    Write-Host -f GREEN " Do you want to see this user's most recent login(s)? " -NoNewline;
                    $dyrl_myl_CQ = Read-Host
                    if($dyrl_myl_CQ -Match "^y"){
                        uActivity $dyrl_myl_Z
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

    $dyrl_usage = 1   ## Skip some menus when multiple searches are performed

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
                Write-Host -f GREEN ' Enter a keyword to search for matching Group Policy names, OR a MM/YYYY'
                Write-Host -f GREEN ' date to view Group Policies by creation times (searches 2 months before and'
                Write-host -f GREEN ' after the date you enter), OR "q" to quit: ' -NoNewline;
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
                    Write-Host -f GREEN " Hit ENTER to search again, or 'q' to quit: " -NoNewline;
                    $dyrl_myl_Z = Read-Host
                }
            }
            Remove-Variable -Force dyrl_myl_*
            Exit
        }


        ## MPOD ALERT!
        ## If you have service accounts that have standard naming, modify the $dyrl_myl_NOSVC variable below!
        ## Set default vars
        $dyrl_myl_FTMP = "C:\Users\$USR\AppData\Local\Temp\7370617761727375636b73.txt"    ## Temp file gets passed to KONIG then sanitized and deleted
        $dyrl_myl_CHKWRITE = Test-Path $dyrl_myl_FTMP -PathType Leaf
        $dyrl_myl_NOSVC = [regex]"[^service]*"
        $dyrl_myl_SINGLENAME = [regex]"[a-zA-Z][a-zA-Z0-9].*"
        $dyrl_myl_WILDC = [regex]"^*?.*\*$"

        ## Verify paths
        $dyrl_myl_DIREXISTS = Test-Path "$vf19_DEFAULTPATH\NewUserSearches\"
        $dyrl_myl_REPORTS = "$vf19_DEFAULTPATH\NewUserSearches\*.txt"

        
        
        ##### EXTERNAL SCRIPTS #########################################
        ## When calling from other scripts, send multiple usernames as comma-space-separated string ", "
        if($CALLER -and $PROTOCULTURE){
            $PROTOCULTURE -Split ', ' | %{
                singleUser $_
            }
            ''
            w '  Hit ENTER to continue.' 'g'
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
            w ' Before searching for user accounts, would you like a list of any recent' 'c'
            w ' hosts joined to the domain?  ' 'c' 'nl'
            $dyrl_myl_Z1 = Read-Host

            if( $dyrl_myl_Z1 -Match "^y" -or $dyrl_myl_Z1 -Match "^[0-9]+$"){
                $dyrl_myl_arrayh = @{}   ## Collect list of hostnames
                $dyrl_myl_sensors = @{}  ## Track hosts with EDR agents installed
                $dyrl_myl_arrayn = 0
                ''
                if($dyrl_myl_Z1 -Match "^y"){
                    while($dyrl_myl_Z1 -notMatch "^[0-9]{1,2}$"){
                        w ' How many days back?  ' 'g' 'nl'
                        $dyrl_myl_Z1 = Read-Host
                    }
                }
                $dyrl_myl_DATE = (Get-Date).AddDays(-$dyrl_myl_Z1)

                $dyrl_myl_GAD = Get-ADComputer -Filter * -Properties createTimeStamp,`
                    Name,`
                    whenCreated,`
                    Description,`
                    IPv4Address, `
                    IPv6Address, `
                    OperatingSystem | 
                        Where {$_.createTimeStamp -ge $dyrl_myl_DATE} | 
                        Where {$_.Name -notLike "*-xb*" -and $_.Name -notLike "it*"}
        
                w '

                '
                foreach( $dyrl_myl_i in $dyrl_myl_GAD ){
                    $dyrl_myl_arrayn++
                    $dyrl_myl_in = $dyrl_myl_i.Name -replace "\.\w.+$"            ## Remove domain, if any
                    $dyrl_myl_arrayh.Add([string]$dyrl_myl_arrayn,$dyrl_myl_in)


                    ## MPOD ALERT!
                    ## Here's another Carbon-Black specific check.
                    if($vf19_C8){
                        ## See if CB has a sensor for the host in question
                        $Global:PROTOCULTURE = $dyrl_myl_in
                        $dyrl_myl_CHECKSENSOR = $(collab 'GERWALK.ps1' 'MYLENE' 'sensor' | ConvertFrom-Json)
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

                    ## MPOD ALERT!  --- EDR results check. It continues to the next section "if( $dyrl_myl_arrayn -gt 0"
                    if($dyrl_myl_CHECKSENSOR){
                        screenResults 'CB Sensor ID' $($dyrl_myl_CHECKSENSOR[0].id)
                        screenResults 'CB Registered' $($($dyrl_myl_CHECKSENSOR[0].registration_time) -replace "\..*")
                        screenResults 'CB Last Checkin' $($($dyrl_myl_CHECKSENSOR[0].last_checkin_time) -replace "\..*")
                        screenResults 'CB OS Check' $($dyrl_myl_CHECKSENSOR[0].os_environment_display_string)
                        screenResults 'CB Status' $($dyrl_myl_CHECKSENSOR[0].status)
                        Remove-Variable -Force dyrl_myl_CHECKSENSOR -Scope Global
                    }
                    else{
                        screenResults 'c~No Carbon Black agent installed!'
                    }
                    
                    
                    screenResults 'endr'
                    
                }
                
                Remove-Variable dyrl_myl_DATE

                ''
                Write-Host -f GREEN ' ...search complete.
                '
                if( $dyrl_myl_arrayn -gt 0 ){  ## If hosts were found and CB script exists, offer to search CB
                    if($dyrl_myl_SENSOR){
                    while( $dyrl_myl_Z -ne 'skip' ){
                        w ' Select a' 'g' 'nl'
                        w ' NEW HOST #' 'c' 'nl'
                        w ' to query Carbon Black, or hit ENTER to skip: ' 'g' 'nl'
                        $dyrl_myl_Z1 = Read-Host
                        if($dyrl_myl_Z1 -Match "^[0-9]+$"){

                            $dyrl_myl_HH = $dyrl_myl_sensors[$dyrl_myl_Z1]
                            
                            if( $dyrl_myl_HH ){
                                hActivity  $dyrl_myl_HH
                                w '
                                '
                                foreach($key in $dyrl_myl_arrayh.keys){
                                    #$dyrl_myl_arraynn++
                                    if($key -in $dyrl_myl_sensors.keys){
                                        screenResults "c~NEW HOST $key" $dyrl_myl_arrayh[$key]
                                    }
                                    else{
                                        screenResults "c~NEW HOST $key" 'r~ (no cb agent installed)'
                                    }
                                }
                                screenResults 'endr'
                                ''
                            }
                            else{
                                w ' That host does not have CB installed.' 'c'
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
                w '
                '

                w '  Continue to new user search? (y/n) ' 'g' 'nl'
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
            w '  OPTIONS:' 'g'
            w '    -Enter a username (you can wildcard' 'g' 'nl'
            w ' *' 'y' 'nl'
            w " if you don't have the full name)" 'g'
            Write-Host -f GREEN '    -Enter "' -NoNewline;
            Write-Host -f YELLOW 'd' -NoNewline;
            Write-Host -f GREEN '" to search by user Description objects'
            w '    -Enter how many days back you want to search for new accounts (max 30)' 'g'
            Write-Host -f GREEN '    -Add an "' -NoNewline;
            Write-Host -f YELLOW 'f-' -NoNewline;
            Write-Host -f GREEN '" to save your results (example, "30f-")'
            Write-Host -f GREEN '    -Enter "' -NoNewline;
            Write-Host -f YELLOW '?' -NoNewline;
            Write-Host -f GREEN '" to see examples for writing your own searches'
            Write-Host -f GREEN '    -Enter "' -NoNewline;
            Write-Host -f YELLOW 'q' -NoNewline;
            Write-Host -f GREEN '" to quit'
            w ' > ' 'g' 'nl'
            $dyrl_myl_Z = Read-Host
    
            
            if($dyrl_myl_Z -like "*f-"){ 
                $dyrl_myl_wf = $true 
                $dyrl_myl_Z = $dyrl_myl_Z -replace "f\-$"
                ''
                w ' Results will be saved on your desktop...
                ' 'y'
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
            elseif( $dyrl_myl_Z -Match "^[0-9]+$" ){
                if( $dyrl_myl_Z.toString.Length -ne 1 ){
                    while( $dyrl_myl_Z -gt 30 ){
                        w "  $dyrl_myl_Z is not less than 30. Please enter a new number:  " 'c' 'nl'
                        $dyrl_myl_Z = Read-Host
                    }
                }



                ####### SET UP REPORT OUTPUTS ##################################################################
                if($dyrl_myl_wf){
                    ## Format the output filenames; generate new filenames if previous outputs exist
                    ## Currently appends a-z at the end of the filename, then goes back and appends two letters
                    ##     (ab, ac, ad, etc.) if the whole alphabet was already used once. Hopefully nobody
                    ##     needs more than 52 reports at a time.
                    $dyrl_myl_FDATE = (Get-Date).DateTime -replace "^[a-zA-Z]*, " -replace ", .*$" -replace ' ','-'
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
                    }while( Test-Path "$vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_OUTNAME*" )
                    $dyrl_myl_FO = ($vf19_M[2] * $vf19_M[1]) * ($vf19_M[1] + $vf19_M[0]) - 2
                    $dyrl_myl_FO = [string]$dyrl_myl_FO
                }
                ####### SET UP REPORT OUTPUTS ##################################################################




                $dyrl_myl_loop = $false
                $dyrl_myl_DATE = (Get-Date).AddDays(-$dyrl_myl_Z)
            }
            else{
                w '  What?
                ' 'c'
                slp 2
            }
    

        }
        ''
        w '
     If you get a large amount of results, you can click anywhere in the window
     to pause the script, then hit "Backspace" or the back arrow key to resume.
                          
     Polling AD...
        ' 'g'


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
        if( ! $dyrl_myl_DIREXISTS ){
            New-Item -Path $vf19_DEFAULTPATH -Name 'NewUserSearches' -ItemType 'directory'
        }


        <#
            Iterate through non-service accounts and send them to KONIG to look at their files.
            Manually review the outputs for any suspicious looking docs/binaries in newly created
            accounts or send them to ASS
        #>

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

            if( $dyrl_myl_wf -and (Test-Path -Path "$vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_OUTNAME") ){
                w '  Search results (if any) have been written to' 'g'
                w " $vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_OUTNAME"
            }
            elseif($dyrl_myl_wf){
                $ermsg = "Failed to write $vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_OUTNAME"
                errLog $ermsg
                w $ermsg 'c'; Remove-Variable -Force ermsg
            }

        }
        else{
            w '   No users found during this time window. Press ENTER to exit... 
            ' 'c'
            Read-Host
            Remove-Variable dyrl_myl_*
            Exit
        }

        
        function firstMenu (){ 
            w "
         -Enter a NEW ACCOUNT number to view that specific user's GPO assignments
         -Enter a keyword to search existing Group Policies for these users
          (example: 'admin', 'Temp', etc.)
         -Hit ENTER to skip:  " 'g' 'nl'
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
                w '  Enter:' 'g'
                w '    -a different "NEW ACCOUNT" number to view their permissions' 'g'
                w '    -keyword(s) for GPO assignments' 'g'
                w '    -"gpo" to view details for a specific group policy' 'g'
                w '    -hit ENTER to reload the user list' 'g'
                w '    -"q" to quit' 'g'
                w '  > ' 'g' 'nl'
                Return $(Read-Host)
            }

            $dyrl_myl_ZPO = $true


            if($dyrl_myl_Z -Match "^[0-9]+$"){
                $dyrl_myl_Z = $dyrl_myl_Z - 1
                $dyrl_myl_UGPO = $dyrl_myl_MULTIACCT[$dyrl_myl_Z] | Select -ExpandProperty memberOf
                if($dyrl_myl_UGPO){
                Write-Host -f CYAN "  $($dyrl_myl_MULTIACCT[$dyrl_myl_Z].samAccountName) is assigned:"
                #listGroups $dyrl_myl_UGPO
                $dyrl_myl_UGPO | %{
                    $g = $_ -replace "..=" -replace ",.*$"
                    Write-Host -f YELLOW "     $g"
                }
                Remove-Variable g
                }
                else{
                    Write-Host -f CYAN '
        That is not a valid selection.
                    '
                    slp 2
                    $dyrl_myl_BADCHOICE = $true
                    $dyrl_myl_ZPO = $false
                }
                
            }
            elseif($dyrl_myl_Z -Match "[a-z]"){
                screenResultsAlt 'endr'
                $dyrl_myl_MULTIACCT | %{
                    $dyrl_myl_UGPO = $_ | Select -ExpandProperty memberOf
                    Write-Host -f CYAN "  Searching $($_.samAccountName) for " -NoNewline;
                    Write-Host "$dyrl_myl_Z" -NoNewline; 
                    Write-Host -f CYAN ':'
                    #listGroups $dyrl_myl_UGPO $dyrl_myl_Z
                    $dyrl_myl_UGPO | %{
                        $g = $_ -replace "..=" -replace ",.*$"
                        if($g -Match $dyrl_myl_Z){
                            Write-Host -f YELLOW "        $g"
                        }
                    }
                    Remove-Variable g
                }
            }
            else{
                $dyrl_myl_ZPO = $false
            }

            $dyrl_myl_Z = $null
            Remove-Variable dyrl_myl_Z
            Remove-Variable dyrl_myl_GRPMEM
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
                    Write-Host -f GREEN " Enter a GPO to search for. If you don't enter an exact GPO name, you"
                    Write-Host -f GREEN " may end up with several results: " -NoNewline;
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

    
    
        if( $vf19_LATTS['KONIG'].name ){

            if( ! $dyrl_myl_SKIP1 ){
                splashPage
                listAccounts
            }

            w '
    
            '
            w "   Do you want to search for the presence of any files in these users'" 'g'
            w '   home directories? (y/n) ' 'g' 'nl' 
            $dyrl_myl_Z = Read-Host
            

            if( $dyrl_myl_Z -Match "^y" ){
                $Global:PROTOCULTURE = ''
                $dyrl_myl_MULTIACCT | %{
                    $Global:PROTOCULTURE = $_.samAccountName
                    slp 1
                    collab 'KONIG.ps1' 'MYLENE'
                    $dyrl_myl_GETNEWFILE = Split-Path $RESULTFILE -leaf
                    Move-Item -Path "$RESULTFILE" -Destination "$vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_GETNEWFILE"
                    Remove-Variable -Force RESULTFILE -Scope Global
                }
                $dyrl_myl_KONIGFILES = Get-ChildItem "$vf19_DEFAULTPATH\NewUserSearches\*"
                $dyrl_myl_Z = $null
                rvf

            }
            else{
                w '
    Skipping file searches...
                '
                $dyrl_myl_SKIP2 = $true  ## No need to reload the list if the screen isn't changing
            }
        }
        else{
            $dyrl_myl_SKIP2 = $true
        }

        $dyrl_myl_Z = $null
        ''
        if( $vf19_C8 ){
            if( ! $dyrl_myl_SKIP2 ){
                splashPage
                listAccounts
            }
            while($dyrl_myl_Z -ne ''){
                w '  Enter a NEW ACCOUNT number for a quick host/process lookup on' 'g'
                w '  that username, or hit ENTER to skip: ' 'g' 'nl' 
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
            w '  Search results (if any) have been written to text files on your Desktop' 'g'
            w '  in the folder' 'g' 'nl'
            w ' target-pkgs' 'y' 'nl'
            Write-Host -f GREEN '.
            '
        }


        ## Prevent user accidentally clearing the screen if they've been hitting ENTER during slow searches
        while( $dyrl_myl_Z -notMatch "^(c|q)$" ){
            Write-Host -f GREEN '  Type "' -NoNewline;
            Write-Host -f YELLOW 'c' -NoNewline;
            Write-Host -f GREEN '" to continue, or "' -NoNewline;
            Write-Host -f YELLOW 'q' -NoNewline;
            Write-Host -f GREEN '" to quit:   ' -NoNewline;
            $dyrl_myl_Z = Read-Host
        }

        if($dyrl_myl_Z -eq 'c'){
            $dyrl_myl_Z = $null
            $dyrl_usage++  ## Switch menus after first run-thru
        }

    }while($dyrl_myl_Z -ne 'q') 

}
