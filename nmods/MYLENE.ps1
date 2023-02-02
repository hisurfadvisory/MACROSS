#_superdimensionfortress User lookup + audit new accounts
#_ver 2.0
#_class User,User_lookups,Powershell,HiSurfAdvisory,1

<#
    Author: HiSurfAdvisory
    
    MYLENE: Target recently-created accounts for inspection; look up AD info
    on users of interest

    This script uses the net utility and Active-Directory cmdlets to gather
    data on enterprise users and hosts -- primarily accounts and devices
    that are newly-joined to your domain.

    MYLENE is part of the MACROSS framework, so many tasks or functions may
    not be available to a user if they've been ID'd as not having admin-
    level privilege to perform these lookups.



    v2.0
    Improved the output method when multiple users match a wildcard search

    v1.5
    Integrated into MACROSS, removed functions and values that are now handled
    by the main console.


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
 $vf19_ATTS['MYLENE'].toolInfo() | %{
   Write-Host -f YELLOW $_
 }
 Write-Host -f YELLOW "
 MYLENE's recent account search lets you perform user lookups by name or creation
 date. As an admin, you can query Active Directory for partial name matches. If you 
 don't know the entire username, you can search with wildcards (*), but it might 
 return several results. If you wildcard the front  of your searches, you must 
 wildard the end (ex. *partname will not work, but *partname* and partname* will).
 
 MYLENE also lets you search for new hosts recently added to the network by choosing
 this tool from the menu with the 's' option if you are running as admin.

 If you are NOT admin, your user searches will be performed with the " -NoNewline;
 Write-Host -f GREEN "net" -NoNewline;
 Write-Host -f YELLOW " utility,"
 Write-Host -f YELLOW " and you cannot wildcard. You must search for exact names.
 
 MYLENE can interact with other MACROSS tools:
    -If MYLENE collects a list of new accounts, it can automatically be forwarded
    to KÖNIG which will scan their roaming profile for all existing files in
    any of their folders


 Hit ENTER to return.
 "

 Read-Host
 Return
}


############################################
##  BEGIN FUNCTIONS
############################################
## Display tool banner
function splashPage (){
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
    if( $dyrl_myl_FCOUNT -ge 1 ){
        Write-Host -f YELLOW " You have $dyrl_myl_FCOUNT MYLENE reports on your desktop.
        "
    }
}

function noFind($1){
    Write-Host -f YELLOW " $1" -NoNewline;
    Write-Host -f GREEN " not found!
    "
}


## Load Carbon Black plugin if applicable
if( $vf19_C8 ){
    function epActivity($1){
        Write-Host -f GREEN " Do you want to view Carbon Black info for $1? " -NoNewline;
        $Z = Read-Host
        if($Z -Match "^y"){
            $Global:PROTOCULTURE = $1
            collab 'GERWALK.ps1' 'MYLENE'
        }
    }
}


## Make the "memberOf" field readable
function listGroups($1){
    (Get-ADUser -Filter "samAccountName -eq '$1'" -Properties memberOf |
    Select -ExpandProperty memberOf) |
    %{Write-Host -f YELLOW $_}
}

## Only load AD functions if user is admin -- see the setUser function in validation.ps1
if( ! $vf19_GAVIL ){
## Tailor AD query based on user input
function singleUser($1){
    if( $1 -Match $dyrl_myl_WILDC ){
        $sU_FILTER = "displayName -Like '$1' -or samAccountName -Like '$1'"
    }
    else{
        $sU_FILTER = "samAccountName -eq '$1'"
        $sU_SPECIFIC = $true
    }

    $sU_Q1 = $(Get-ADUser -Filter $sU_FILTER -Properties displayName,samAccountName | Select samAccountName,displayName)
    $sU_QCT = $sU_Q1.count
    $sU_QUERY = Get-ADUser -Filter $sU_FILTER -Properties *

    if( $sU_Q1 ){
        ''
        if( $sU_QCT -gt 1 ){
            Write-Host -f GREEN " Found multiple users matching that search:
            "
            foreach( $n in $sU_Q1 ){
                $n = $n -replace "^.+samAccountName=","" -replace "; displayName=",":  " -replace "}$",""
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
            Write-Host -f GREEN " Pay special attention to the " -NoNewline;
                Write-Host -f YELLOW "lastLogonDate" -NoNewline;
                    Write-Host -f GREEN " and " -NoNewline;
                        Write-Host -f YELLOW "whenChanged" -NoNewline;
                            Write-Host -f GREEN " fields."
            Write-Host -f GREEN " There should not usually be a huge gap between the two.
    
            "
        
            $sU_QUERY |
                Format-List displayName,`
                    created,`
                    homePostalAddress,`
                    roomNumber,`
                    emailAddress,`
                    info,`
                    Description,`
                    lastLogonDate,`
                    whenChanged
        
            'GPO ASSIGNMENTS:'
            listGroups $1
            if( $sU_SPECIFIC ){
                Write-Host -f GREEN " Do you need extra detail for this user? (y/n)  " -NoNewline;
                    $Z = Read-Host

                if( $Z -eq 'y' ){
                    $sU_QUERY
                    $Z = $null
                    Write-Host -f GREEN " Press ENTER to continue." -NoNewline;
                    Read-Host
                }
                $sU_SPECIFIC = $null
            }
        }

        if( $vf19_C8 ){
            epActivity $1
        }
    }
    else{
        noFind $1
        Write-Host -f GREEN " Press ENTER to continue." -NoNewline;
        Read-Host
    }
        
    splashPage

}


## Format the output to focus on user's GPO
function getNewList($1){
    $GPO1 = Get-ADUser -Filter * -Properties samAccountName,whenCreated,memberOf |
        Where{$_.whenCreated -gt $dyrl_myl_DATE}

    foreach( $h in $GPO1 ){
        $NAME = $h.samAccountName
        $GROUP = $h.memberOf
        $ADSEARCH = Get-ADUser -Filter "samAccountName -eq '$NAME'" -Properties memberOf | Select-Object -ExpandProperty memberOf
        $ADFOUND = @()

        if( $NAME -notMatch "^[0-9].*" ){
            Write-Host -f GREEN " Searching $NAME for $1..."
            slp 2
            $ADSEARCH | foreach( $_.memberOf ){
                if( $_ -Like "*$1*" ){
                    $ADFOUND += $_
                }
            }
            if( $ADFOUND.count -gt 0 ){
                Write-Host ""
                Write-Host -f YELLOW " $NAME " -NoNewline;
                Write-Host -f GREEN "is a member of: "
                $ADFOUND | Format-List

                Start-Sleep 3
                $ADFOUND = @()
            }
        }
    }
}
}
############################################
##  END FUNCTIONS
############################################


## >/dev/null any errors
$ErrorActionPreference = 'SilentlyContinue'



## Perform quick user lookup for other scripts
if( $PROTOCULTURE ){
    if( $vf19_GAVIL ){
        $dyrl_myl_EX = net user $PROTOCULTURE /domain
        if( $dyrl_myl_EX ){
            $dyrl_myl_EX
        }
        else{
            noFind $PROTOCULTURE
        }
    }

    else{
        singleUser $PROTOCULTURE
    }

    Write-Host -f GREEN "
    Hit ENTER to return to $CALLER.
    "
    Read-Host
    Remove-Variable -Force CALLER -Scope Global
    Return
}


if( ! $CALLER ){
    transitionSplash 6
    slp 2
}


## Non-admins use the net command
if( $vf19_GAVIL ){
    if( $vf19_OPT1 ){
        $vf19_OPT1 = $false  ## Cancel user's attempt to find new devices on the network
        Write-Host -f CYAN ' You do not have requisite privilege, you cannot search for recent hosts.
        '
    }
    $dyrl_myl_Z = $null
    while( $dyrl_myl_Z -ne 'q' ){
        splashPage
        Write-Host -f GREEN ' What username are you searching on? Enter captial ' -NoNewline;
        Write-Host -f YELLOW 'Q' -NoNewline;
        Write-Host -f GREEN ' to quit:  ' -NoNewline;
        $dyrl_myl_Z = Read-Host
        if(-not( $dyrl_myl_Z | Select-String -CaseSensitive 'Q')){
            $dyrl_myl_U = net user $dyrl_myl_Z /domain
            if( $dyrl_myl_U ){
                $dyrl_myl_U
            }
            else{
                noFind $dyrl_myl_Z
            }
            Write-Host -f GREEN ' Hit ENTER to continue.  '
            Read-Host
        }
        else{
            Remove-Variable dyrl_myl_*
            Exit
        }
    }
}
## Admins use Get-ADUser cmdlets
else{
    ## Set default vars
    $dyrl_myl_FTMP = "C:\Users\$USR\AppData\Local\Temp\mylene.txt"
    ## ^This temp file can be passed to other scripts as needed, but it is sanitized and deleted when MYLENE finishes
    $dyrl_myl_CHKWRITE = Test-Path $dyrl_myl_FTMP -PathType Leaf
    $dyrl_myl_SINGLENAME = [regex]"[a-zA-Z][a-zA-Z0-9].*"
    $dyrl_myl_WILDC = [regex]"^*?.*\*$"

    ## Verify paths
    $dyrl_myl_DIREXISTS = Test-Path "$vf19_DEFAULTPATH\NewUserSearches\"
    $dyrl_myl_REPORTS = (Get-ChildItem -Path "$vf19_DEFAULTPATH\NewUserSearches\*.txt")

    ## Clean up old reports if not needed anymore
    if($dyrl_myl_REPORTS.count -gt 0){
        houseKeeping $dyrl_myl_REPORTS 'MYLENE'
    }

    ## Format the output filenames; generate new filenames if previous outputs exist
    ## Currently appends a-z at the end of the filename, then goes back and appends two letters
    ##     (ab, ac, ad, etc.) if the whole alphabet was already used once. Hopefully nobody
    ##     needs more than 50 reports at a time.
    $dyrl_myl_FDATE = (Get-Date).DateTime -replace("^[a-zA-Z]*, ","") -replace(", .*$","") -replace(" ","-")
    $dyrl_myl_REPAL = 'abcdefghijklmnopqrstuvwxyz'
    $dyrl_myl_REPNO = 0
    $dyrl_myl_OUTNAME = "MYLENE_" + $dyrl_myl_FDATE + $dyrl_myl_REPAL[$dyrl_myl_REPNO]
    do{
        if( $dyrl_myl_REPNO -le 25 ){
            $dyrl_myl_REPNO++
            $dyrl_myl_OUTNAME = "MYLENE_" + $dyrl_myl_FDATE + $dyrl_myl_REPAL[$dyrl_myl_REPNO] + ".txt"
        }
        else{
            $dyrl_myl_REPNO++
            $dyrl_myl_REPNO2 = $dyrl_myl_REPNO + 1
            $dyrl_myl_OUTNAME = "MYLENE_" + $dyrl_myl_FDATE + $dyrl_myl_REPAL[$dyrl_myl_REPNO] + $dyrl_myl_REPAL[$dyrl_myl_REPNO2] + ".txt"
        }
    }while( Test-Path "$vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_OUTNAME*" )


    
    splashPage


    if( $vf19_OPT1 ){
        Write-Host -f CYAN '
        Searching for recent devices joined to the domain:'
        while($dyrl_myl_Z1 -notMatch "^[0-9]{1,2}$"){
                Write-Host -f GREEN "        How many days back?  " -NoNewLine;
                $dyrl_myl_Z1 = Read-Host
            }
            $dyrl_myl_DATE = (Get-Date).AddDays(-$dyrl_myl_Z1)

            $dyrl_myl_GAD = Get-ADComputer -Filter * -Properties whenCreated | 
                Where {$_.whenCreated -ge $dyrl_myl_DATE}
        
            Write-Host '
            '
            foreach( $dyrl_myl_i in $dyrl_myl_GAD ){
                $dyrl_myl_ipadd0 = $dyrl_myl_i.name
                $dyrl_myl_ipadd0 = $dyrl_myl_ipadd0.toUpper()
                $dyrl_myl_ipadd1 = nslookup $dyrl_myl_ipadd0 | Select-String "Address.*$dyrl_myl_FO"
                $dyrl_myl_ipadd2 = $dyrl_myl_ipadd0 + " resolves to " + $dyrl_myl_ipadd1 -replace("Address.*$dyrl_myl_FO","$dyrl_myl_FO")
                if( $dyrl_myl_ipadd1 ){
                    Write-Host -f GREEN "        $dyrl_myl_ipadd2"
                }
                else{
                    Write-Host -f YELLOW "        $dyrl_myl_ipadd0 does not resolve!"
                }

                $dyrl_myl_i | 
                    Format-Table Name,`
                        whenCreated,`
                        distinguishedName -Autosize -Wrap

                Write-Host -f GREEN '=======================================================
                
                '
            }

            Remove-Variable -Force dyrl_myl_DATE

            Write-Host -f GREEN '        ...search complete.'
            Write-Host -f GREEN '        Do you want to continue to user searches?  ' -NoNewLine;
                $dyrl_myl_Z1 = Read-Host

            if( ($dyrl_myl_Z1 -ne 'y') -or ($dyrl_myl_Z1 -eq $null) ){
                Remove-Variable dyrl_myl_*
                Exit
            }

        }

    


    while( $dyrl_myl_LOOP1 -ne 'forward' ){
        $dyrl_myl_LOOP1 = 'backward'
        ''
        Write-Host -f GREEN ' Enter a username (you can wildcard ' -NoNewline;
        Write-Host -f YELLOW '*' -NoNewline;
        Write-Host -f GREEN " if you don't have the full name) OR"
        Write-Host -f GREEN " how many days back you want to search for new accounts (max 30). '" -NoNewline;
        Write-Host -f YELLOW "Q" -NoNewline;
        Write-Host -f GREEN "' to quit:  " -NoNewLine; 
        $dyrl_myl_Z = Read-Host
    
        
        if( $dyrl_myl_Z -eq 'q' ){
            $dyrl_myl_LOOP1 = 'forward'
            if( $CALLER ){
                Remove-Variable dyrl_myl_*
                Return
            }
            else{
                Remove-Variable dyrl_myl_*
                Exit
            }
        }
        elseif( $dyrl_myl_Z -Match $dyrl_myl_SINGLENAME ){
            singleUser $dyrl_myl_Z
        }
        elseif( $dyrl_myl_Z -Match "^[0-9]+$" ){
            if( $dyrl_myl_Z.toString.Length -ne 1 ){  ## WHY DOES POWERSHELL 5 RANDOMLY REQUIRE PREPENDING A '0' FOR SINGLE DIGITS?!?!?!?!
                while( $dyrl_myl_Z -gt 30 ){
                    Write-Host "  $dyrl_myl_Z is not less than 30. Please enter a new number:  " -NoNewline;
                    $dyrl_myl_Z = Read-Host
                }
            }
            $dyrl_myl_LOOP1 = 'forward'
            $dyrl_myl_DATE = (Get-Date).AddDays(-$dyrl_myl_Z)
        }
        else{
            Write-Host -f CYAN '  What?
            '
            slp 2
        }
    

    }


    ##########
    ## Parse out user properties as needed
    ##########
    $dyrl_myl_GETNEWU = Get-ADUser -Filter * -Properties whenCreated | 
        Where {$_.whenCreated -gt $dyrl_myl_DATE} | 
        Select -ExpandProperty samAccountName

    # format the output for a quicklook
    $dyrl_myl_GETNEWTABLE = Get-ADUser -Filter * -Properties samAccountName,displayName,whenCreated,Description | 
        Where {$_.whenCreated -gt $dyrl_myl_DATE} | 
        Where {$_.samAccountName -Match "^[a-z][a-z0-9.]+"} |
        Sort -Property samAccountName | 
        Format-Table samAccountName,displayName,whenCreated,Description

    






    ##########
    ## Make sure we have a directory to collect search result files into
    ##########
    if( ! $dyrl_myl_DIREXISTS ){
        New-Item -Path $vf19_DEFAULTPATH -Name "NewUserSearches" -ItemType "directory"
    }


    <#
        Iterate through non-service accounts and record them to the user's
        "Desktop\NewUserSearches" folder
    #>

    if( $dyrl_myl_GETNEWTABLE -ne $null ){
        $dyrl_myl_GETNEWTABLE | Out-Host
        
        Get-ADUser -Filter * -Properties WhenCreated | 
            Where {$_.whenCreated -gt $dyrl_myl_DATE} | 
            Format-Table Name, SamAccountName, whenCreated |
            Out-File -Filepath "$vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_OUTNAME"

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
        Write-Host -f CYAN '  No new accounts found during this time window. Press ENTER to exit... 
        '
        Read-Host
        Remove-Variable dyrl_myl_*
        Exit
    }

    Write-Host -f GREEN "
     Enter a keyword to search for group memberships for these users 
     (example: 'admin', 'developer', etc.) or just hit ENTER to skip.  " -NoNewLine; 
        $dyrl_myl_Z = Read-Host
    
    <# example of iterating through user groups
    get-aduser -filter "samaccountname -eq '$USR'" -properties memberof | 
    select-object -expandproperty memberof | 
    foreach( $_.memberof ){
        if($_ -Match "$GROUP"){write-host $_}
    }
    #>

    while( $dyrl_myl_Z -Match "^[a-zA-Z0-9]+" ){
        getNewList $dyrl_myl_Z
        $dyrl_myl_Z = $null
        Remove-Variable dyrl_myl_Z
        Remove-Variable dyrl_myl_GRPMEM
        ''
        Write-Host -f GREEN "  Enter another group description if you would like to search again,"
        Write-Host -f GREEN "  or just hit ENTER to skip.  " -NoNewline;
        $dyrl_myl_Z = Read-Host
    }



    <#
        This section contains instructions that interact with other MACROSS scripts to perform
        file scans in the searched-for users' profiles, particularly newly-created users.

            -KONIG will use Active-Directory to look for user's roaming profiles, and collect
                any filenames it finds.

            -If KONIG returns results, those filenames can be forwarded to ELINTS, which lets
                you string-search those files for keywords/phrases.

        This would be a good spot to add your own scripts using MACROSS' collab function.
    #>


    ## If the KONIG filesearch tool is available, offer option to launch it with MYLENE's findings
    if( $vf19_K1 ){
        while( $dyrl_myl_Z -notMatch "^[yn]" ){
            Write-Host '

            '
            Write-Host -f GREEN "  Do you want to search for the presence of any files in these users'"
            Write-Host -f GREEN "  home directories?  " -NoNewLine; 
            $dyrl_myl_Z = Read-Host
        }

        if( $dyrl_myl_Z -eq 'y' ){
            $dyrl_myl_OUTFILE = $true
            $dyrl_myl_OVERWRITE = '6d6163726f737364656c7461737578'  ## Overwrites $dyrl_myl_FTMP when that file is no longer needed
            $dyrl_myl_GETNEWU | Out-File -FilePath $dyrl_myl_FTMP

            ## Parse the temp file written for this purpose
            $dyrl_myl_PARSEFTMP = Get-Content $dyrl_myl_FTMP |
                Select-String "^[a-z].*"

        
            ## Send results to KONIG one at a time to see what files exist in the user profiles
            foreach( $dyrl_myl_ACCT in $dyrl_myl_PARSEFTMP ){
                $Global:PROTOCULTURE = $dyrl_myl_ACCT
                Start-Sleep -Seconds 2

                collab 'KONIG.ps1' 'MYLENE'  

                $dyrl_myl_GETNEWFILE = Split-Path $RESULTFILE -leaf
                Move-Item -Path "$RESULTFILE" -Destination "$vf19_DEFAULTPATH\NewUserSearches\$dyrl_myl_GETNEWFILE"
            }
            $dyrl_myl_OVERWRITE | Set-Content -Force $dyrl_myl_FTMP   # sanitize the tmp file
            Remove-Item -Force -Path $dyrl_myl_FTMP                   # delete the tmp file
            $dyrl_myl_KONIGFILES = Get-ChildItem "$vf19_DEFAULTPATH\NewUserSearches\*"
            $dyrl_myl_Z = $null
        
                
            ## If KONIG found files, and the ELINTS script is available, offer option to launch it for keyword-searching
            if( ($vf19_E1 ) -and ($HOWMANY -gt 0) ){
                while( $dyrl_myl_Z -notMatch "^[yn]" ){
                    Write-Host -f GREEN " Do you want to run" -NoNewLine;
                    Write-Host -f YELLOW " ELINTS" -NoNewLine;
                    Write-Host -f GREEN " (automated string-search) to scan the files you just found? (y/n)  " -NoNewLine;
                    $dyrl_myl_Z = Read-Host
                }


                if( $dyrl_myl_Z -Match "^y" ){
                    $COMEBACK = $true
                    Clear-Variable -Force RESULTFILE -Scope Global
                    foreach( $RESULTFILE in $dyrl_myl_KONIGFILES ){
                        
                        collab 'ELINTS.ps1' 'MYLENE'   ## Send KONIG results to ELINTS for keyword search
                        
                        Write-Host -f GREEN '  All results can be found on your Desktop: ' -NoNewline;
                        Write-Host -f YELLOW 'NewUserSearches' -NoNewline;
                        Write-Host -f GREEN ', '
                        Write-Host -f YELLOW 'target-pkgs' -NoNewline;
                        Write-Host -f GREEN ', '
                        Write-Host -f GREEN 'and ' -NoNewline;
                        Write-Host -f YELLOW 'strings-found.txt' -NoNewline;
                        Write-Host -f GREEN '.
                        '
                        Write-host -f GREEN '  Hit ENTER to exit.'
                        Read-Host

                        Remove-Variable dyrl_myl_*

                        Exit
                    }
                }
            }
            
        }
        else{
            Write-Host -f GREEN '  Skipping file searches...
            '
            slp 2
        }
    }

    $dyrl_myl_Z = $null

    if( $dyrl_myl_OUTFILE ){
        Write-Host -f GREEN '  Search results (if any) have been written to text files on your Desktop'
        Write-Host -f GREEN '  in the folder ' -NoNewLine;
        Write-Host -f YELLOW 'target-pkgs' -NoNewLine;
        Write-Host -f GREEN '.
        '
    }




    ## Prevent user accidentally clearing the screen if they've been hitting keys during slow searches
    while( $dyrl_myl_Z -ne 'c' ){
        Write-Host -f GREEN '  Type ' -NoNewline;
        Write-Host -f YELLOW 'c' -NoNewline;
        Write-Host -f GREEN ' to continue...   ' -NoNewline;
        $dyrl_myl_Z = Read-Host
    } 
}



