#_sdf1 User lookup + audit new accounts
#_ver 2.1
#_class User,Common,Usernames,Powershell,HiSurfAdvisory,1

<#
    MYLENE: Target recently-created accounts for inspection; look up AD info
    on users of interest

    This script uses the "net" utility and Active-Directory cmdlets to gather
    data on enterprise users and hosts -- primarily accounts and devices
    that are newly-joined to your domain.

    MYLENE is part of the MACROSS framework, so many tasks or functions may
    not be available to a user if they've been ID'd as not having admin-
    level privilege to perform these lookups.
    

    ---------------------------------------------------
    If calling MYLENE from your script via the "collab" function, MYLENE
    does not return any values. It writes all of its search results
    for $PROTOCULTURE to the screen, then exits back to your script.
    ---------------------------------------------------


    v2.1
    Improved data collection from GERWALK and C2EFF

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
    if($dyrl_mypy_QNAME){
    if($dyrl_mypy_DESKTOP){
    if($dyrl_mypy_GBIO){
        $CALLER = $dyrl_mypy_CALLER
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
 Author: $($vf19_ATTS['MYLENE'].author)
 version $($vf19_LIST0['MYLENE.ps1'])
 
 
 Recent ACcount Search lets you perform user lookups by name or creation date.
 As an admin, you can query Active Directory for partial name matches. If you 
 don't know the entire username, you can search with wildcards (*), but it might 
 return several results. If you wildcard the front  of your searches, you must 
 wildard the end (ex. *partname will not work, but *partname* and partname* will).
 
 When searching for recently created users, your search results can be rolled into
 the KONIG tool to perform a filesearch on those profiles.
 
 MYLENE also lets you search for new laptops/tablets recently added to the network.

 If you are NOT admin, your search will be performed with the " -NoNewline;
 Write-Host -f GREEN 'net' -NoNewline;
 Write-Host -f YELLOW ' utility, and
 you cannot wildcard. You must search for exact names.
 

 MYLENE interacts with these SKYNET tools:
    -KONIG can scan new user accounts for the presence of *any* files
    -GERWALK can lookup history of usernames or hostnames being evaluated by MYLENE


 If you are logged in as admin and select MYLENE with the "s" option (example "12s" 
 from the main menu), you can search for keywords and creation dates in Active-
 Directory GPO instead of usernames.

 
 Hit ENTER to return.
 '

 Read-Host
 Return
}
try{
    gethelp1 $vf19_UCT
}
catch{
    Remove-Variable dyrl_* -Scope Global
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


## GERWALK plugin function
if( $vf19_C8 ){
    function uActivity($1){  ## Send a username to Carbon Black
        $Global:PROTOCULTURE = $1
        $activityu = collab 'GERWALK.ps1' 'MYLENE' 'usrlkup'


        ## GERWALK randomly sends a useless header with the max results,
        ## need to ignore when it does this
        if(($activityu).count -gt 2){
            $r = $($activityu[1] | ConvertFrom-Json).results
        }
        else{
            $r = $($activityu[0] | ConvertFrom-Json).results
        }


        $ct = 0
        $total = ($r).count

        screenResults "   Recent activity for user $1 (unsorted; system processes omitted)"
        screenResults 'derpHOSTNAME' 'derpACTIVITY' 'derpDATE'

        while($ct -lt $total){
            if("$(($r.process_name[$ct]))" -notIn $l){
                [string]$cmdl = $($r.cmdline[$ct])
                screenResults "$(($r.hostname[$ct]))" "$(($r.process_name[$ct]))" "$(($r.start[$ct]))"
            }
            $ct++
        }

        screenResults 'endr'
        Write-Host -f GREEN '
        Hit ENTER to continue.
        '
        Read-Host
        Remove-Variable -Force activityu
    }

    function hActivity($1){  ## Send a hostname to Carbon Black
        $Global:PROTOCULTURE = $1

        if( ! $activityh ){
            $activityh = collab 'GERWALK.ps1' 'MYLENE' 'hlkup'
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


        while( $z -ne '' ){
            screenResults "           Activity on host $1 ($type)"
            screenResults 'derpACCOUNTS' 'derpRUNNING PROCESSES' 'derpCB GROUP'
            screenResults "$($f.username_full.name)" "$($f.process_name.name)" "$($f.group.name)"
            screenResults "Last seen: $(($f.start.name | Sort -Descending)[0])"
            screenResults 'endr'
            ''
            Write-Host -f GREEN ' Type a username to view their recent activity, or hit ENTER to continue.'
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
                    Write-Host -f CYAN " That name isn't listed. Try adding the domain.
                    "
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



## Select description of the security group
## right now only looking at category, can grab other
## objects later.
## $1 is the Group name (must be exact)
function detailGroups($1){
    $a = $(Get-ADGroup -Filter * -Properties * | 
        where{$_.name -eq "$1"} |
        Select groupCategory)

    Return $a
}



## Write results to text file on user's desktop
## If $2 is sent, it will be written to file first (should usually be a username or empty space)
function w2f($1,$2){
    if($2){
        $2 | Out-File -Filepath "$vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_OUTNAME" -Append
    }
    $1 | Out-File -Filepath "$vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_OUTNAME" -Append
}



## Only load AD functions if user is admin
if( ! $vf19_NOPE ){

    function searchDesc(){
        
        function listSearchR(){
            $index = 1
            $Script:list = @()
            $getad | %{
                $a = $_.samAccountName
                $c = $_.whenCreated
                if($obj -eq 1){
                    $d = $_.Name
                }
                else{
                    $d = $_.Description
                }
                $Script:list += $a
                $item = [string]$index + '. ' + $a
                $item = $item -replace "\s+$"
                $cr = $c -replace "\s+$"
                $index++
                if($obj -eq 2){
                    screenResults $item $cr $d
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
            Write-Host -f GREEN ')ffice symbol/JDIR (type "' -NoNewline;
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
            $getad = Get-ADUser -Filter * -Properties * | where{$_.Description -Like "*$ZZ*"}
        }
        elseif($Z -eq 'o'){
            $obj = 1
            $getad = Get-ADUser -Filter * -Properties * | where{$_.Description -Like "*$ZZ*"}
        }

        $ZZ = $null
        $Z = $null

        if($getad){
            while($Z -ne ''){
                if($obj -eq 2){
                    screenResults 'ACCOUNT' '  CREATED' '  DESCRIPTION'
                }
                else{
                    screenResults 'ACCOUNT' '   OFFICE SYMBOL/JDIR'
                }
                listSearchR
                Write-Host -f GREEN ' Select a number for full details, or ENTER to skip: ' -NoNewline;
                $Z = Read-Host
                if($Z -Match "\d+"){
                    $Z = $Z - 1
                    $u = $list[$Z]
                    $getad | where{$_.samAccountName -eq "$u"}
                    ''
                    Write-Host -f GREEN ' Hit ENTER to continue.
                    '
                    Read-Host
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
            $filter = "Created -Match '$filter' -or Created -Match '$a1' -or Created -Match '$a2' -or Created -Match '$a3' -or Created -Match '$a4'"
        }
        elseif($option -eq 2){
            $filter = "Name -eq '$filter'"
        }
        else{
            $filter = "Name -Like '*$filter*'"
        }



        $gquery = Get-ADGroup -Filter $filter -Properties Created,Description,Name,ManagedBy,Members,whenChanged
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
                        Write-Host -f YELLOW 'c' -NoNewline;
                        Write-Host -f GREEN ' to cancel and go back:'
                    }
                    else{
                        Write-Host -f GREEN '"' -NoNewline;
                        Write-Host -f YELLOW 'q' -NoNewline;
                        Write-Host -f GREEN '" to quit, or a new keyword to search:'
                    }
                    Write-Host -f GREEN '  > ' -NoNewline;
                    $Z = Read-Host
                    if($Z -eq 'm'){
                        $Zu = $null
                        $d = 'derpyDERP!'
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
    function cleanList($1){

        Remove-Variable -Force dyrl_myl_0* -Scope Global ## Start fresh

        
        <#
             $dyrl_myl_username
             ============================================================================
             NAME         ||  $dyrl_myl_0cn
             CREATED      ||  $dyrl_myl_0wcreated
             TIMESTAMP    ||  $dyrl_myl_0created     ## In case of timestomping, not sure if CREATED &
             MODIFIED     ||  $dyrl_myl_0modified    ##     TIMESTAMP could ever legit be different values
             DESCRIPTION  ||  $dyrl_myl_0desc
             LAST LOGON   ||  $dyrl_myl_0lastlogon
             EMAIL        ||  $dyrl_myl_0email
            =============================================================================
        #>
        function dv($obj){
            Write-Host -f GREEN "$c  $obj"
        }

        function mg($j){
            $1 | Select -ExpandProperty memberOf | %{
                $g = $_ -replace "..="
                if($j){
                    if($g -Match $j){

                    }
                }
            }
        }
    
        

        ## Make these available for future functions
        $Script:dyrl_myl_0username = $1.samAccountName
        $Script:dyrl_myl_0propername = $1.displayName
        $Script:dyrl_myl_0cn = $1.CN
        $Script:dyrl_myl_0desc = $1.Description
        $Script:dyrl_myl_0created = $1.createTimeStamp
        $Script:dyrl_myl_0wcreated = $1.whenCreated
        $Script:dyrl_myl_0changed = $1.whenChanged
        $Script:dyrl_myl_0lastlogon = $1.lastLogonDate
        $Script:dyrl_myl_0modified = $1.Modified
        $Script:dyrl_myl_0wmodified = $1.modifyTimeStamp
        $Script:dyrl_myl_0email = $1.Mail
        $Script:dyrl_myl_0passwX = $1.PasswordNeverExpires
        $Script:dyrl_myl_0passwN = $1.PasswordNotRequired
        $Script:dyrl_myl_0exp = $1.AccountExpirationDate
        $Script:dyrl_myl_0smartC = $1.SmartcardLogonRequired
        $Script:dyrl_myl_0gpochk = 3gpo $dyrl_myl_0jdir 1


        if($dyrl_myl_LISTNUM){
            $n = [string]$dyrl_myl_LISTNUM + '. ' + $dyrl_myl_username
        }
        else{
            $n = $dyrl_myl_username
        }

        ## Check for possible timestomping
        if($dyrl_myl_0created -ne $dyrl_myl_0wcreated){
            $redT = $true
        }
        if($dyrl_myl_0modified -ne $dyrl_myl_0wmodified){
            $redM = $true
        }
        

        ## Uncomment and modify to highlight AD object deviations in your environment
        <#
        if($dyrl_myl_0username -notMatch "^(superadmin|superuser).*"){
            $redD = $true
        }
        #>

        
        Write-Host -f CYAN "  $c$c$c$c$c$c NEW ACCT $n"
        Write-Host -f GREEN '  ============================================================================'
        Write-Host -f YELLOW '  NAME         ' -NoNewline;
        dv $dyrl_myl_0cn
        Write-Host -f YELLOW '  ACCOUNT      ' -NoNewline;
        dv $dyrl_myl_0username
        if($dyrl_myl_0exp -Match "\w"){
            Write-Host -f RED    '  EXPIRES      ' -NoNewline;
            dv $dyrl_myl_0exp
        }
        Write-Host -f YELLOW '  CREATED      ' -NoNewline;
        dv $dyrl_myl_0wcreated
        if($redT){
            Write-Host -f RED '  CR.TIMESTAMP ' -NoNewline;
        }
        else{
            Write-Host -f YELLOW '  CR.TIMESTAMP ' -NoNewline;
        }
        dv $dyrl_myl_0created
        if($redM){
            Write-Host -f RED '  MODIFIED     ' -NoNewline;
        }
        else{
            Write-Host -f YELLOW '  MODIFIED     ' -NoNewline;
        }
        dv $dyrl_myl_0modified
        if($redD){
            Write-Host -f RED '  DESCRIPTION  ' -NoNewline;
        }
        else{
            Write-Host -f YELLOW '  DESCRIPTION  ' -NoNewline;
        }
        dv $dyrl_myl_0desc
        Write-Host -f YELLOW '  LAST LOGON   ' -NoNewline;
        dv $dyrl_myl_0lastlogon
        Write-Host -f YELLOW '  EMAIL        ' -NoNewline;
        dv $dyrl_myl_0email
        if($dyrl_myl_0passwX -eq $true -or $dyrl_myl_0passwN -eq $true){
            Write-Host -f RED '  PASSWORD NULL OR NEVER EXPIRES'
        }
        Write-Host -f GREEN '  ============================================================================'


        w2f $dyrl_myl_0wcreated $dyrl_myl_0username
        w2f $dyrl_myl_0created
        w2f $dyrl_myl_0propername
        w2f '' $dyrl_myl_0desc

    }


    ## Tailor AD query based on user input
    function singleUser($1){
        if( $1 -Match $dyrl_myl_WILDC ){
            $sU_FILTER = "displayName -Like '$1' -or samAccountName -Like '$1'"
        }
        else{
            $sU_FILTER = "samAccountName -eq '$1'"
            $sU_SPECIFIC = $true
        }

        $sU_Q1 = $(Get-ADUser -Filter $sU_FILTER -Properties displayName,samAccountName | 
            Select samAccountName,displayName)
        $sU_QCT = $sU_Q1.count
        $sU_QUERY = Get-ADUser -Filter $sU_FILTER -Properties *
        $sU_GPO = $sU_QUERY | Select -ExpandProperty memberOf

        if( $sU_Q1 ){
            ''
            if( $sU_QCT -gt 1 ){
                Write-Host -f GREEN ' Found multiple users matching that search:
                '
                foreach( $n in $sU_Q1 ){
                    $n = $n -replace "^.+samAccountName=" -replace "; displayName=",":  " -replace "}$"
                    Write-Host -f YELLOW "  $n"
                }
                ''
                Write-Host -f GREEN " Choose one of the usernames above, or ENTER for a new search:"
                Write-Host -f GREEN "  >  " -NoNewline; $Z = Read-Host
                if( $Z -Match "[a-z0-9]" ){
                    Remove-Variable sU_*
                    singleUser $Z
                }
            }
            else{
                $sU_SPECIFIC = $true
                Write-Host -f GREEN ' Pay special attention to the ' -NoNewline;
                Write-Host -f YELLOW 'LAST LOGON' -NoNewline;
                Write-Host -f GREEN ' and ' -NoNewline;
                Write-Host -f YELLOW 'MODIFIED' -NoNewline;
                Write-Host -f GREEN ' fields.'
                Write-Host -f GREEN ' There should not usually be a huge gap between the two.
    
                '
                cleanList $sU_QUERY
                ''
                'GPO ASSIGNMENTS:'
                $sU_GPO | %{
                    $g = $_ -replace "..=" -replace ",.*$"
                    Write-Host -f YELLOW "   $g"
                }
                Remove-Variable g
                ''
                if( $sU_SPECIFIC ){
                    Write-Host -f GREEN ' Do you need extra domain details for this user? (y/n)  ' -NoNewline;
                    $Z = Read-Host

                    if( $Z -eq 'y' ){
                        $Z = $null
                        while($Z -notMatch "^(A|C|G|S)$"){
                            Write-Host -f GREEN " Type 'A' for Active-Directory info, 'C' for a Carbon Black lookup, 'G'"
                            Write-Host -f GREEN " for GPO details, or 'S' to skip: " -NoNewline;
                            $Z = Read-Host
                        }
                        if( $Z -eq 'A'){
                            $sU_QUERY
                        }
                        elseif($Z -eq 'C'){
                            uActivity "$1"
                            splashPage
                        }
                        elseif($Z -eq 'G'){
                            ''
                            Write-Host -f GREEN ' Copy-in the GPO name to view: ' -NoNewline;
                            $Z = Read-Host
                            if($Z -Match "\w{4,}"){
                                3gpo $Z 2
                            }
                        }

                        if($Z -ne 'S'){
                            Write-Host -f GREEN ' Hit ENTER to continue.' -NoNewline;
                            Read-Host
                        }
                        $Z = $null
                    }
                    $sU_SPECIFIC = $null
                }
            }



        }
        else{
            noFind $1
            Write-Host -f GREEN ' Hit ENTER to continue.' -NoNewline;
            Read-Host
        }
        
        splashPage

    }

}
############################################
##  END FUNCTIONS
############################################



if( $vf19_NOPE ){
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
                if( $vf19_C8 ){
                    ''
                    Write-Host -f GREEN " Do you want to see this user's most recent host(s)? " -NoNewline;
                    $dyrl_myl_CQ = Read-Host
                    if($dyrl_myl_CQ -Match "^y"){
                        uActivity $dyrl_myl_Z
                    }
                    Remove-Variable dyrl_myl_CQ
                }
                else{
                    Write-Host -f GREEN ' Hit ENTER to continue.
                    '
                    Read-Host
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
            $dyrl_myl_C2F = 'trash'
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

        ## Set default vars
        $dyrl_myl_FTMP = "C:\Users\$USR\AppData\Local\Temp\6d6163726f737364656c7461737578.txt"    ## Temp file gets passed to KONIG then sanitized and deleted
        $dyrl_myl_CHKWRITE = Test-Path $dyrl_myl_FTMP -PathType Leaf
        $dyrl_myl_NOSVC = [regex]"[^svc.]*"
        $dyrl_myl_SINGLENAME = [regex]"[a-zA-Z][a-zA-Z0-9].*"
        $dyrl_myl_WILDC = [regex]"^*?.*\*$"

        ## Verify paths
        $dyrl_myl_DIREXISTS = Test-Path "$vf19_DEFAULTPATH\NewUserSearches\"
        $dyrl_myl_REPORTS = "$vf19_DEFAULTPATH\NewUserSearches\*.txt"

        ## Clean up old reports if not needed anymore
        if( (Get-ChildItem -Path $dyrl_myl_REPORTS).count -gt 0){
            if($dyrl_usage -eq 1){
                houseKeeping $dyrl_myl_REPORTS 'MYLENE'
            }
        }

        ## Format the output filenames; generate new filenames if previous outputs exist
        ## Currently appends a-z at the end of the filename, then goes back and appends two letters
        ##     (ab, ac, ad, etc.) if the whole alphabet was already used once. Hopefully nobody
        ##     needs more than 50 reports at a time.
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




        if($dyrl_usage -eq 1){  ## Only run this option once, ignore it for subsequent searches
            ''
            Write-Host -f CYAN ' Before searching for user accounts, would you like a list of any recent'
            #Write-Host -f CYAN ' hosts joined to the domain?  ' -NoNewLine;
            Write-Host -f CYAN ' hosts joined to the domain?  ' -NoNewLine;
            $dyrl_myl_Z1 = Read-Host

            if( $dyrl_myl_Z1 -Match "^y" -or $dyrl_myl_Z1 -Match "^[0-9]+$"){
                $dyrl_myl_arrayh = @{}   ## Collect list of hostnames
                $dyrl_myl_sensors = @{}  ## Track hosts with CB installed
                $dyrl_myl_arrayn = 0
                ''
                if($dyrl_myl_Z1 -Match "^y"){
                    while($dyrl_myl_Z1 -notMatch "^[0-9]{1,2}$"){
                        Write-Host -f GREEN ' How many days back?  ' -NoNewLine;
                        $dyrl_myl_Z1 = Read-Host
                    }
                }
                $dyrl_myl_DATE = (Get-Date).AddDays(-$dyrl_myl_Z1)

                $dyrl_myl_GAD = Get-ADComputer -Filter * -Properties createTimeStamp,`
                    Name,`
                    whenCreated,`
                    Description,`
                    OperatingSystem | 
                        Where {$_.createTimeStamp -ge $dyrl_myl_DATE} | 
                        Where {$_.Name -notLike "SRV" }                      ## Modify this to match your network hosts!!!!
        
                Write-Host '

                '
                foreach( $dyrl_myl_i in $dyrl_myl_GAD ){
                    $dyrl_myl_arrayn++

                    ## Uncomment to remove the domain from the hostname
                    #$dyrl_myl_in = $dyrl_myl_i.Name -replace ".DOMAIN.NAME$"

                    $dyrl_myl_arrayh.Add([string]$dyrl_myl_arrayn,$dyrl_myl_in)

                    if($vf19_C8){
                        ## See if CB has a sensor for the host in question
                        $Global:PROTOCULTURE = $dyrl_myl_in
                        $dyrl_myl_CHECKSENSOR = $(collab 'GERWALK.ps1' 'MYLENE' 'sensor' | ConvertFrom-Json)
                    }

                    if( $dyrl_myl_CHECKSENSOR[0].id ){
                        $dyrl_myl_SENSOR = $true
                        $dyrl_myl_sensors.Add([string]$dyrl_myl_arrayn,$dyrl_myl_in)
                    }

                    $dyrl_myl_ipadd0 = $dyrl_myl_i.name
                    $dyrl_myl_ipadd0 = $dyrl_myl_ipadd0.toUpper()
                    $dyrl_myl_ipadd1 = nslookup $dyrl_myl_ipadd0 | Select-String "Address.*$dyrl_myl_FO"
                    $dyrl_myl_ipadd2 = $dyrl_myl_ipadd0 + " resolves to " + $dyrl_myl_ipadd1 -replace("Address.*$dyrl_myl_FO","$dyrl_myl_FO")
                    
                    if( $dyrl_myl_ipadd1 ){
                        screenResults "derpNEW HOST $dyrl_myl_arrayn" $($dyrl_myl_i.Name) $dyrl_myl_ipadd2
                    }
                    else{
                        screenResults "derpNEW HOST $dyrl_myl_arrayn" $($dyrl_myl_i.Name) 'derpyDOES NOT RESOLVE'
                    }
                    screenResults 'Operating System' $($dyrl_myl_i.OperatingSystem)
                    screenResults 'Created' $($dyrl_myl_i.whenCreated)
                    if( $($dyrl_myl_i.Description) ){
                        screenResults 'Description' $($dyrl_myl_i.Description)
                    }
                    else{
                        screenResults 'Description' 'derpyNONE'
                    }
                    if($dyrl_myl_CHECKSENSOR){
                        screenResults 'CB Sensor ID' $($dyrl_myl_CHECKSENSOR[0].id)
                        screenResults 'CB Registered' $($($dyrl_myl_CHECKSENSOR[0].registration_time) -replace "\..*")
                        screenResults 'CB Last Checkin' $($($dyrl_myl_CHECKSENSOR[0].last_checkin_time) -replace "\..*")
                        screenResults 'CB OS Check' $($dyrl_myl_CHECKSENSOR[0].os_environment_display_string)
                        screenResults 'CB Status' $($dyrl_myl_CHECKSENSOR[0].status)
                        Remove-Variable -Force dyrl_myl_CHECKSENSOR -Scope Global
                    }
                    else{
                        screenResults 'derpyNo Carbon Black agent installed!'
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
                        Write-Host -f GREEN ' Select a ' -NoNewline;
                        Write-host -f CYAN 'NEW HOST #' -NoNewline;
                        Write-Host -f GREEN ' to query Carbon Black, or hit ENTER to skip: ' -NoNewline;
                        $dyrl_myl_Z1 = Read-Host
                        if($dyrl_myl_Z1 -Match "^[0-9]+$"){

                            $dyrl_myl_HH = $dyrl_myl_sensors[$dyrl_myl_Z1]
                            
                            if( $dyrl_myl_HH ){
                                hActivity  $dyrl_myl_HH
                                Write-Host '
                                '
                                foreach($key in $dyrl_myl_arrayh.keys){
                                    #$dyrl_myl_arraynn++
                                    if($key -in $dyrl_myl_sensors.keys){
                                        screenResults "derpNEW HOST $key" $dyrl_myl_arrayh[$key]
                                    }
                                    else{
                                        screenResults "NEW HOST $key" ' (no cb agent installed)'
                                    }
                                }
                                screenResults 'endr'
                                ''
                            }
                            else{
                                Write-Host -f CYAN ' That host does not have CB installed.'
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
                ''
                ''

                Write-Host -f GREEN ' Continue to new user search?  ' -NoNewLine;
                $dyrl_myl_Z1 = Read-Host

                if( ($dyrl_myl_Z1 -notMatch "^y") -or ($dyrl_myl_Z1 -eq '') ){
                    Remove-Variable dyrl_myl_*
                    Exit
                }

            }
        }
        

    


        while( $dyrl_myl_C2F -ne 'retarded' ){
            ''
            Write-Host -f GREEN ' Enter a username (you can wildcard ' -NoNewline;
            Write-Host -f YELLOW '*' -NoNewline;
            Write-Host -f GREEN " if you don't have the full name) OR"
            Write-Host -f GREEN ' "' -NoNewline;
            Write-Host -f YELLOW 'd' -NoNewline;
            Write-Host -f GREEN '" to search by user Description objects, OR how many days back'
            Write-Host -f GREEN " you want to search for new accounts (max 30), OR " -NoNewline;
            Write-Host -f YELLOW 'q' -NoNewline;
            Write-Host -f GREEN " to quit:  " -NoNewLine; 
            $dyrl_myl_Z = Read-Host
    
    
            if( $dyrl_myl_Z -eq 'q' ){
                if( $CALLER ){
                    Remove-Variable dyrl_myl_*
                    Return
                }
                elseif( $CALLHOLD ){
                    Remove-Variable dyrl_myl_*
                    Return
                }
                else{
                    Remove-Variable dyrl_myl_*
                    Exit
                }
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
                if( $dyrl_myl_Z.toString.Length -ne 1 ){  ## WHY DOES POWERSHELL RANDOMLY REQUIRE ADDING A '0' FOR SINGLE DIGITS?!?!?!?!
                    while( $dyrl_myl_Z -gt 30 ){
                        Write-Host "  $dyrl_myl_Z is not less than 30. Please enter a new number:  " -NoNewline;
                        $dyrl_myl_Z = Read-Host
                    }
                }
                $dyrl_myl_C2F = 'retarded'
                $dyrl_myl_DATE = (Get-Date).AddDays(-$dyrl_myl_Z)
            }
            else{
                Write-Host -f CYAN '  What?
                '
                slp 2
            }
    

        }
        ''
        Write-Host -f GREEN '
     If you get a large amount of results, you can click anywhere in the window
     to pause the script, then hit "Backspace" or the back arrow key to resume.
                          
     Polling AD...
        '


        ##########
        ## Parse out user properties as needed
        ##########
        $dyrl_myl_GETNEWU = Get-ADUser -Filter * -Properties whenCreated | 
            Where {$_.whenCreated -gt $dyrl_myl_DATE} | 
            Select -ExpandProperty samAccountName

        # format the output for a quicklook
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
            $Script:dyrl_myl_LISTNUM = 0
            $Script:dyrl_myl_MULTIACCT = @()

        
            function listAccounts(){
                $Script:dyrl_myl_LISTNUM = 0
                $dyrl_myl_MULTIACCT | %{
                    Write-Progress -activity 'Expanding details...' `
                            -status "Collecting $dyrl_myl_LISTNUM of $dyrl_myl_howmany" `
                            -CurrentOperation "Details for: $($_.samAccountName)" `
                            -percentComplete (($dyrl_myl_LISTNUM / $dyrl_myl_howmany)  * 100)
                    $Script:dyrl_myl_LISTNUM++
                    cleanList $_
                }
                Write-Progress -activity "Expanding details..." -Completed
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
    

            if( Test-Path -Path "$vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_OUTNAME" ){
                Write-Host -f GREEN '  Search results (if any) have been written to text files on your Desktop'
                Write-Host -f GREEN '  in the folder ' -NoNewLine;
                Write-Host -f YELLOW 'NewUserSearches' -NoNewline;
                Write-Host -f GREEN '.'
            }
            else{
                Write-Host -f CYAN '  ERROR: ' -NoNewline;
                Write-Host -f GREEN 'Output could not be written to file.'
            }

        }
        else{
            Write-Host -f CYAN '  No users found during this time window. Press ENTER to exit... 
            '
            Read-Host
            Remove-Variable dyrl_myl_*
            Exit
        }

        function firstMenu (){ 
            Write-Host -f GREEN "
         -Enter a NEW ACCT number to view that specific user's GPO assignments; OR
         -Enter a keyword to search existing Group Policies for these users
          (example: 'admin', 'Temp', etc.); OR
         -Just hit ENTER to skip:  " -NoNewLine;
        }

        firstMenu
        $dyrl_myl_Z = Read-Host
        ''
    
        <# example of iterating through user groups
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
                Write-Host -f GREEN '  Enter another keyword if you would like to search again, "gpo"'
                Write-Host -f GREEN '  if you want to view details for a specific group policy, or'
                Write-Host -f GREEN '  just hit ENTER to reload the user list.  ' -NoNewline;
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
                keepSearching
                $dyrl_myl_Z = Read-Host
                ''
                if( $dyrl_myl_Z -eq '' ){
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
                        Write-Host -f GREEN ' Hit ENTER to continue.'
                        Read-Host
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
                firstMenu
                $dyrl_myl_Z = Read-Host
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

    
    
        if( $vf19_ATTS['KONIG'].name ){

            if( ! $dyrl_myl_SKIP1 ){
                splashPage
                listAccounts
            }


            while( $dyrl_myl_Z -notMatch "^(y|n)" ){
                Write-Host '

                '
                Write-Host -f GREEN "  Do you want to search for the presence of any files in these users'"
                Write-Host -f GREEN '  home directories?  ' -NoNewLine; 
                $dyrl_myl_Z = Read-Host
            }

            if( $dyrl_myl_Z -Match "^y" ){
                $Global:PROTOCULTURE = ''
                $dyrl_myl_MULTIACCT | %{
                    $Global:PROTOCULTURE = $_.samAccountName
                    slp 1
                    collab 'KONIG.ps1' 'MYLENE'
                    $dyrl_myl_GETNEWFILE = Split-Path $RESULTFILE -leaf
                    Move-Item -Path "$RESULTFILE" -Destination "$vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_GETNEWFILE"
                }
                $dyrl_myl_KONIGFILES = Get-ChildItem "$vf19_DEFAULTPATH\NewUserSearches\*"
                $dyrl_myl_Z = $null

                listAccounts

            }
        
            else{
                Write-Host -f GREEN '  Skipping file searches...
                '
                $dyrl_myl_SKIP2 = $true  ## No need to reload the list if the screen isn't changing
            }
        }
        else{
            $dyrl_myl_SKIP2 = $true
        }

        ''
        if( $vf19_C8 ){
            $dyrl_myl_Z = $null
            if( ! $dyrl_myl_SKIP2 ){
                listAccounts
            }
            while($dyrl_myl_Z -ne ''){
                Write-Host -f GREEN '  Select a number to search Carbon Black on any of these usernames,'
                Write-Host -f GREEN '  or hit ENTER to skip:  ' -NoNewLine; 
                $dyrl_myl_Z = Read-Host
                if($dyrl_myl_Z -Match "^[0-9]+$"){
                    $dyrl_myl_Z = $dyrl_myl_Z - 1
                    $CUSER = $dyrl_myl_MULTIACCT[$dyrl_myl_Z].samAccountName
                    uActivity $CUSER
                    Remove-Variable CUSER
                    $dyrl_myl_Z = $null
                
                    splashPage
                    listAccounts
                }
                ''
            }
        }



        $dyrl_myl_Z = $null

        if( $dyrl_myl_GETNEWFILE ){
            Write-Host -f GREEN '  Search results (if any) have been written to text files on your Desktop'
            Write-Host -f GREEN '  in the folder ' -NoNewLine;
            Write-Host -f YELLOW 'target-pkgs' -NoNewLine;
            Write-Host -f GREEN '.
            '
        }


        ## Prevent user accidentally clearing the screen if they've been hitting ENTER during slow searches
        while( $dyrl_myl_Z -notMatch "^(c|q)$" ){
            Write-Host -f GREEN '  Type "' -NoNewline;
            Write-Host -f YELLOW 'c' -NoNewline;
            Write-Host -f GREEN '" to continue, or "q" to quit:   ' -NoNewline;
            $dyrl_myl_Z = Read-Host
        }

        if($dyrl_myl_Z -eq 'c'){
            $dyrl_myl_Z = $null
            $dyrl_usage++
        }

    }while($dyrl_myl_Z -ne 'q') 

}

