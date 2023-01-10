#_wut CarbonBlack EDR quick queries
#_ver 1.0

<#

    GERWALK Carbon Black module for MACROSS
    Designed for VMWare Carbon Black EDR

    Run quick & dirty queries between MACROSS modules to gather
    info on usernames, files, processes, etc.

    Go to the findThese() function to see examples where I used my $CALLER
    scripts to set specific queries. Add your own "if" statements to build
    queries based on your own scripts so they can use this to query
    your Carbon Black deployment.


    ***************!!! AUTHENTICATION !!!***************
    You will need to develop a secure method for passing in your
    API keys, this script does not contain any built-in methods
    for you. See the 'findThese' function in this script for creating
    your API key's variables.

    Also, I HIGHLY recommend you remove all of the "how this works" 
    comments before running this in your prod environments.


    AUTHOR: HiSurfAdvisory

    v1.0
    Runs basic queries and accepts inputs from other MACROSS scripts

    TO DO:
        Enable searching via local time windows

#>



function splashPage(){
    cls
    $i = 'ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgciAgICAgICAgI
    CAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICDGkiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICA
    gICAgICAgICAgICAgICAgICAgICDilZPilabilaYsICAgICAgICDilZIgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgzrQg4paT4paRI
    iwgICws4pWTLCzOkyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgLlUiauKWiOKWjOKVn+KWhOKWiOKWjCLigb/ilad0xpJkPSDDpyJe4pW
    QfiwgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    zDp+KWk+KWk+KWk+KWk+KWgOKWgOKWgOKWgOKWiOKWiOKWiF3Ok+KWkOKBvyAgICLijILiloTigb8iI
    CAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgLGfiloTi
    loTiloDiloDilojiloDiloAwUeKWhOKWhOKWhOKWiE0i4paA4paAXmAsLuKMkMKs4pWYICAiLSAgICA
    gICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICzilZDDkeKWhOKWgOKWgO
    KWkOKWiOKWk+KWiGDOpl3ijJDiloDilojiloggdzbilahq4paE4pWZIiAgICBdLOKVkywgLOKVkCIiX
    l7ilZDilZDilZDCrH4uLiwsLCAgICAgICAgCiAgICAgICAgICAgICAgICAgICAuw4fiiJ7ilZ3ilZzD
    heKWkuKVouKWk+KWiOKWgOKUlCAgwr/iloTiloTiloQ7IOKVmeKWgOKWgOKWgOKWgOKWgOKWgOKWiFw
    g4oyQ4paA4paA4paA4paA4paA4paA4paA4paA4paA4paA4paAUFDiloDiloDiloDiloDilajilpPilp
    PDkeKInuKInsOE4oieNMOF4pWdICAKICAgICAgICAgICAgICAgLOKWhOKWiOKWiOKWiOKWiOKWhOKWh
    OKWiOKWgOKWgCnDsSLiloTiloTilogq4pSU4oG/4paA4paA4paA4paA4paA4paIIiAs4paE4oyQ4paA
    IuKWiOKWkuKUlH7iiJp+4pWlw6p+fn4t4pSA4pWQ4pWQ4pWQ4pWQ4pSA4pSA4pWQ4pWQ4oG/Xl5eXl4
    iIiIgIAogICAgICAgICAgICzilZBg4paA4paA4paA4paI4paA4paA4paA4paAICAs4paE4paEfuKWhO
    KWk+KVoeKWgOKWiE3ilaXilZPDpiVNU+KWhCwswqzijJDilZBA4paAWyAgIEx34pWnICAgICAgLCAgI
    CAgICAgICAgICAgICAgIAogICAgICAgLOKMkCIgICAgICBg4paAXOKWhOKWiOKWjOKWgOKWgOKVk+KM
    kCriloA+cOKVpyJgIMKyXSAgTCDilojilojiloDilozilZAi4pWZd2Digb/Dh8KsXUjiloAg4pSA4pW
    S4paI4paI4paMICAgICAgICAgICAgICAgICAgIAogICAs4oyQIiAgICAgICAgIOKVkCLilLQsbOKWgC
    rijKDilJQgICAgICAgICBW4paE4paIICBd4pWTL+KWiOKMkOKWkCAgIMK64paI4paI4paAeinDpyzCv
    OKVoz3ilpDilojiloQgICAgICAgICAgICAgICAgICAgCiBDIiAgICAgLC4u4oyQ4pWp4pWnwqrilZAi
    YCAgICAgICAgICAgICAgICAi4paA4paIKuKVllwgLV0od+KWhOKWgMKq4paI4paEYCDilojiloAiLMK
    yIOKWiOKWjOKWgOKWjCAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgIMOGLOKVk2DiloDCv+KImuKWiOKWjC/iloAgICAgIMOFICDilIzilZsg4paE4paIICAgI
    CAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIMK/YCDGkuKV
    mOKBv+KVkOKWiOKWiOKWiOKWiOKUmCAgL+KVmyAo4pWT4paE4paE4paE4paE4paE4paIICDilJggICA
    gICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgwqIgIMOc4paE4p
    aE4paE4paI4paA4paA4paAYCAg4paQ4paMIOKWhOKWiOKWgCAgIOKUlOKWiOKMkCDilZIgICAgICAgI
    CAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg4pWZ4pSUwqwgICAg
    IOKMkCAg4pWS4paAIOKWhOKWgOKBvyzCvyAgIF3iloTiloTilojilojilojilojilojilojilojiloj
    ilojilojilojilojilojilojilojilojiloDiloAgICAKICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICDCv+KUlCLilZXiloAgKsKsw58i4oG/SCAg4paE4paI4paI4paI4paI4paI4
    paI4paI4paI4paI4paI4paI4paI4paA4paA4paALSAgICAgICAgCiAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICDilZsgIC/ilpBb4paE4paE4pWT4paA4paI4paE4paI4paI4paI4pa
    I4paI4paI4paI4paI4paI4paI4paI4paI4paALSAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAgL+KUlOKBv1nDhMOnLOKWhOKWiOKWiOKWhOKWhOKWiOKWiOKWi
    OKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWgOKWgGAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgYCAgKGAgIOKWiOKWiOKWiOKWiOKWiOKWiOKWgOKWgOKWgOK
    WgOKWgOKUlGAiICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICDOpn4sz4bilKziloTiloTiloDiloDiloDiloAtICAgICAgICAgICAgICAgICAgICAgI
    CAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgYOKMkCAg'

    $b = 'ICAgICAgICDilojilojilojilojilojilojilZcg4paI4paI4paI4paI4paI4paI4paI4pWX4
    paI4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKVlyAgICDilojilojilZcg4paI4paI4paI4paI4paI
    4pWXIOKWiOKWiOKVlyAgICAg4paI4paI4pWXICDilojilojilZcKICAgICAgIOKWiOKWiOKVlOKVkOK
    VkOKVkOKVkOKVnSDilojilojilZTilZDilZDilZDilZDilZ3ilojilojilZTilZDilZDilojilojilZ
    filojilojilZEgICAg4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4paI4paI4pWRICAgI
    CDilojilojilZEg4paI4paI4pWU4pWdCiAgICAgICDilojilojilZEgIOKWiOKWiOKWiOKVl+KWiOKW
    iOKWiOKWiOKWiOKVlyAg4paI4paI4paI4paI4paI4paI4pWU4pWd4paI4paI4pWRIOKWiOKVlyDiloj
    ilojilZHilojilojilojilojilojilojilojilZHilojilojilZEgICAgIOKWiOKWiOKWiOKWiOKWiO
    KVlOKVnQogICAgICAg4paI4paI4pWRICAg4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4pWdICDilojil
    ojilZTilZDilZDilojilojilZfilojilojilZHilojilojilojilZfilojilojilZHilojilojilZTi
    lZDilZDilojilojilZHilojilojilZEgICAgIOKWiOKWiOKVlOKVkOKWiOKWiOKVlwogICAgICAg4pW
    a4paI4paI4paI4paI4paI4paI4pWU4pWd4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWRIC
    DilojilojilZHilZrilojilojilojilZTilojilojilojilZTilZ3ilojilojilZEgIOKWiOKWiOKVk
    eKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKVkSAg4paI4paI4pWXCiAgICAgICAg4pWa4pWQ
    4pWQ4pWQ4pWQ4pWQ4pWdIOKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pW
    dIOKVmuKVkOKVkOKVneKVmuKVkOKVkOKVnSDilZrilZDilZ0gIOKVmuKVkOKVneKVmuKVkOKVkOKVkO
    KVkOKVkOKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWd'
    if( $CALLER ){
        getThis $b
    }
    else{
        getThis $i
    }
    Write-Host ''
    Write-Host -f YELLOW $vf19_READ
    Write-Host -f CYAN   '        =============================================================
                    Automated Carbon Black Response queries
    '
}



if( $HELP ){
    disVer 'GERWALK'
    splashPage
    Write-Host -f YELLOW "

                         GERWALK v$VER
  ===================================================================
    
    This script's primary purpose is to perform Carbon Black lookups
    based on values passed to it from other MACROSS tools, but it can
    also perform a basic CB query for you. This is quicker than logging
    into the web UI, but you'll get better details there than here.

    EXAMPLES:
        -After performing an IP lookup in SDF-1, you can pass
        IP or hostname info to GERWALK for extra details on
        who is logged in, running processes, etc.

        -After performing a user lookup with MYLENE, you can pass
        the username to GERWALK to review the latest hosts they
        were logged into, websites visited, etc.

        -After performing file searches in EXSEDOL, you can pass
        filenames to GERWALK to find any info CB may have on them,
        such as which hosts executed/loaded them, which users have
        accessed them, etc.

    Hit ENTER to continue.
    "

    Read-Host
    Exit
}



<#  UNCOMMENT TO USE RESTRICTED PERMISSION CHECKS
try{
    adminChk 'deny'
    getHelp1 $vf19_UCT
    getHelp2 $vf19_UCT
}
catch{
    Exit
}
#>


$C = @(
    'username',
    'process_name',
    'hostname',
    'cmdline',
    'fileless_scriptload_cmdline',
    'process_md5',
    'parent_name',
    'childproc_name',
    'path',
    'os_type',
    'host_type',
    'group'
)



## Make sure sensitive vars get cleaned up
function wrapItUp($1){
    Remove-Variable -Force dyrl_ger_APK,dyrl_ger_WORKSPACE,dyrl_ger_RESLIST
    if($1 -eq 1){
        Exit
    }
}



## Hash a file and see if CB has info on it
##  $1 is the filepath, $2 is the hashing method
##  (MD5 or SHA256)
## If second param is empty, it performs a search
##  on the filename itself using the binary API
function inspectBin($1,$2){
    $module = 'v1/binary?facet=true'
    

    if( $2 -ne $null ){
        $gh = $(CertUtil -hashfile $1 $2) -split("\n")  ## Windows utility gives back the hash value + 2 useless lines
        $gh = $gh[1]                                    ## only care about the second line that gets returned
        if($2 -eq 'sha256'){
            $file = "sha256%3A$gh"                      ## build query for the file's sha256 val
        }
        elseif($2 -eq 'md5'){
            $file = "md5%3A$gh"                         ## or build query for the file's md5 val
        }
        else{
            errMsg 4 $2
        }
    }
    else{
        $file = 'observed_filename%3A*' + [string]$1    ## if no hash method was provided, buid query for the filename
    }

    $Script:dyrl_ger_BINARYQ = $true
    findThese $module $file

}


########################
##  Build additional queries based on these values (not in use yet)
function reviewResults($1,$2){
    $r = $dyrl_ger_WORKSPACE.results[$1]

    $uname = $r.username
    $proc = $r.process_name
    $dad = $r.parent_name
    $kid = $r.childproc_name
    $hname = $r.hostname
    $htype = $r.host_type
    $hash5 = $r.process_md5
    $hash6 = $r.process_sha256
    $conns = $r.netconn_count
    $start = $r.start
    $last = $r.last_update

}




<# 
 Carbon black sucks at localizing timestamps --
 $1 is the time to adjust; this func automatically modifies CB's default format,
 but needs to specifically be "MM/dd hh:mm" when analyst is entering a time
 manually

 $2 must be set to 0 for adjusting Carbon Black's result time (this is for display only)
    OR
 $2 must be set to 1 for adjusting analysts's search windows (NOT YET IMPLEMENTED)
#>
function adjustTime($1,$2){
    $clock = 0..23
    $calendar = @{
    '01'=31
    '02'=28
    '03'=31
    '04'=30
    '05'=31
    '06'=30
    '07'=31
    '08'=31
    '09'=30
    '10'=31
    '11'=30
    '12'=31
    }
    # $1 CB time format > 2022-11-16T13:53:42.764Z
    # do subtractions to account for daylight savings
    $dschk = (Get-Date).IsDaylightSavingTime()
    $local = Get-Date -Format 'YYYY-MM-ddThh:mm:ss' # Preformat date/time for CB queries
    $year = Get-Date -Format YYYY
    
    if($dschk){
        $offset = 0  # $offset is the number of hours you're behind GMT before and after daylight savings
    }
    else{
        $offset = 0
    }

    
    ## If time is less or greater than the 24hr clock, shift the date +1 or -1
    if($2 -eq 0){
        $zh = $1 -replace "^.+T",'' -replace ":.+$",''
        $zmins = $1 -replace "^.+T[0-9]{2}:",'' -replace ":[0-9]{2}.+$",''
        $zd = $1 -replace "T.+$",'' -replace "^.+-",''
        $zm = $1 -replace "^[0-9]{4}-",'' -replace "-.+$",''
        $hour_diff = [int]$zh - $offset
        if($hour_diff -lt 0){
            $hour_diff = 24 - [math]::abs($hour_diff)
            $day_diff = [int]$zd - 1
            if( $day_diff -lt 0 ){
                $m = [int]$zm - 1
                if($m -lt 0){
                    $m = 12
                }
                $day_diff = [int]$calendar[$m] - [int]$day_diff
            }
        }
        else{
            $m = $zm
            $day_diff = $zd
        }

        $day_diff = $m + '/' + $day_diff
        $Script:dyrl_ger_LOCAL = $day_diff + ' ' + $hour_diff + ':' + $zmins

    }
    elseif($2 -eq 1){
        $lh = $1 -replace "^.+ ",'' -replace ":.+$",''
        $ld = $1 -replace "^../",'' -replace " .+$",''
        $lm = $1 -replace "/.+$",''
        $hour_diff = $lh + $offset
        if($hour_diff -gt 23){
            $day_max = $calendar[$lm]
            $hour_diff = $hour_diff - 24
            $day_diff = $ld + 1
            if($day_diff -gt $day_max){
                $m = [int]$lm + 1
                if($m -gt 12){
                    $m = 01
                    $day_diff = 01
                }
                $day_diff = '-' + $m + '-' + $day_diff
            }
        }
        else{
            $day_diff = $ld
        }



        # time format for queries windows =     start:[2021-11-12T23:01:12 TO 2021-11-15T23:01:12]
        # ^^ URL formatted =                    start%3A%5B2021-11-12T23%3A01%3A12%20TO%202021-11-15T23%3A01%3A12%5D
        # time format for same-day searches =   start:-15m

        $Script:tw = 'start:[' + $year + $day_diff + 'T' + $hour_diff + ':00:00 TO ' + $local + ']'

    }
    
}



<# Searches are done with the 'process' API by default. If another is needed, 2
  arguments need to be passed; the first is the opening for the API query...

                        'v1/process?'

  ...change 'process' to the required API, like 'binary'. The second argument is
  the actual query WITHOUT the preceding '&q='
#>
function findThese($1,$2){
    <# If needed, use vars to modify qsection with "facet.field=<FIELD>"
        ACCEPTED FIELDS:
        process_md5: the top unique process_md5s for the processes matching the search
        hostname: the top unique hostnames matching the search
        group: the top unique host groups for hosts matching this search
        path_full: the top unique paths for the processes matching this search
        parent_name: the top unique parent process names for the processes matching this search
        process_name: the top unique process names for the processes matching this search
        host_type: the distribution of host types matching this search: one of workstation,
            server, domain_controller
        hour_of_day: the distribution of process start times by hour of day in computer local time
        day_of_week: the distribution of process start times by day of week in computer local time
        start: the distribution of process start times by day for the last 30 days
        username_full: the username context associated with the process
    #>
    $qbuild = '&q='
    $qsection = 'v1/process?facet=true'  ## Default API call
    $startt = 'start:-168h '             ## Default time window is 1 week
    $onlyusers = '-(username:*SERVICE OR username:root OR username:*SYSTEM OR username:' + "$USR) "

    if($2 -ne $null){
        if( $1 -ne $qsection ){
            $qsection = $1               ## Use this API instead of default
            $qbuild = $qbuild + $2       ## Use the second argument for query
        }
        else{
            
            ## Build query using $PROTOCULTURE from other tools
            $Z = $null
            if($1 -eq 'ISAMU'){            ## ISAMU script passes IPs or hostnames for user lookups
                if($2 -Match "^[0-9]+\."){
                    $qbuild = $qbuild + "ipaddr:$2 "
                }
                elseif($2 -Match "^[a-z]"){
                    $qbuild = $qbuild + "hostname:$2 "
                    $qbuild = $qbuild + $onlyusers
                    $skipsys = $true
                    $skipres = $true
                    $Script:dyrl_ger_RES = 1
                    $res ="&rows=1"
                }
            }
            elseif($1 -eq 'SDF1'){         ## SDF1 script passes IPs
                $qbuild = $qbuild + "ipaddr:$2 "
            }
            elseif($1 -eq 'MYLENE'){          ## MYLENE script passes usernames
                $qbuild = $qbuild + "username:$2 "
                $oneuser = $true
            }
            elseif($1 -eq 'ELINT' -or $1 -eq 'ALTO'){  ## ALTO & ELINT scripts pass filenames
                $qbuild = $qbuild + "(cmdline:*$2* OR fileless_scriptload_cmdline:*$2*) "
                $skipsys = $true
                $skipres = $true
                $Script:dyrl_ger_RES = 15
                $res ="&rows=15"
            }
            
            
            # $skipsys is set by other scripts that already specify usernames
            if( ! $skipsys ){
                Write-Host -f GREEN '        Omit SYSTEM accounts?  ' -NoNewline;
                if($Z -Match "^y"){
                    $skipsys = $true
                    $qbuild = $qbuild + $onlyusers
                }
            }
            # $skipres gets set by other scripts that want specific maximum results
            if( ! $skipres ){
                Write-Host -f GREEN '        Display how many results? (1-50)  ' -NoNewline;
                $Z = Read-Host
                if($Z -notMatch "^[0-9]+$"){
                    $Script:dyrl_ger_RES = 10
                    $res ="&rows=10"
                }
                else{
                    $Script:dyrl_ger_RES = $Z
                    $res ="&rows=$Z"
                }
                $skipres = $true
            }

            $Z = $null

        }
    }
    else{   ## Build CB queries manually with user input; best for quick lookups that don't
            ##  immediately need tons of details. For that reason "OR" operators aren't
            ##  allowed in this script; the filter terms specified below can each be used
            ##  ONCE in any query, connected by "AND" operators.
        
        $qbuild = $qbuild + $startt

        while($Z2 -notMatch "^n"){

        splashPage
        $Z2 = ''
        Write-Host -f GREEN '
        Enter your search term(s) ONE AT A TIME as indicated (' -NoNewline;
        Write-Host -f YELLOW '*' -NoNewline
        Write-Host -f GREEN " wildcards
        are OK except for IPs & ports):

            -begin with 'u' if searching for a user
            -begin with a 'c' if searching for a commandline arg
            -begin with a 'p' if searching by running process
            -begin with an 'h' if searching by local hostname
            -begin with a 'd' if searching for visits to a website
            -'e' to exit

            Example:  usuzyq*            = prepend 'u' to search for user suzyque;
                      pRundll32.exe      = prepend 'p' to search for RunDLL32 process;
                      3389               = search for a TCP/UDP port 3389;
                      8.8.8.8            = search for an IP
                      dwww.google.c*     = prepend 'd' to search for a website;
                      c*force*           = prepend 'c' to search for the '-force'
                                             flag in command-line execution

            Current query: " -NoNewline;
            Write-Host -f CYAN "$qbuild"
            Write-Host -f GREEN "
                Enter a search term >  " -NoNewline;

            $Z1 = Read-Host

            if($Z1 -Match "^u"){
                $c_username = $Z1 -replace "^u",''
            }
            elseif( $Z1 -Match "^[0-9]{1,5}$" ){
                $c_ipport = $Z1
            }
            elseif($Z1 -Match "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$") {
                $c_ipaddr = $Z1
                Write-Host ''
                Write-Host -f YELLOW '        Search results will be for hosts/users/processes that have connected'
                Write-Host -f YELLOW "        to $Z1; the IP won't be visible in your results
                "
            }
            elseif($Z1 -Match "^c"){
                $c_cmdline = $Z1 -replace "^c",''
                $c_fsc = $c_cmdline
            }
            elseif($Z1 -Match "^p"){
                $c_process_name = $Z1 -replace "^.",''
            }
            elseif($Z1 -Match "^d"){
                $c_domain = $Z1 -replace "^.",''
                Write-Host ''
                Write-Host -f YELLOW '        Search results will be for hosts/users/processes that have connected'
                Write-Host -f YELLOW "        to $Z1; the URL won't be visible in your results
                "
            }
            elseif($Z1 -Match "^h"){
                $c_hostname = $Z1 -replace "^.",''
            }
            elseif($Z1 -eq 'e'){
                wrapItUp 1
            }
            else{
                Write-Host -f CYAN '
            That is not a valid choice.
            '
            $Z1 = ''
            }

        
            if($c_username){
                if($oneuser){
                    Write-Host -f CYAN '
                    You already have a username.
                    '
                }
                else{
                    $qbuild = $qbuild + "username:$c_username "
                    $oneuser = $true
                }
            }
            if($c_hostname){
                if($onehost){
                    Write-Host -f CYAN '
                    You already have a host.
                    '
                }
                else{
                    $qbuild = $qbuild + "hostname:$c_hostname "
                    $onehost = $true
                }
            }
            if($c_domain){
                if($onedom){
                    Write-Host -f CYAN '
                    You already have a URL.
                    '
                }
                else{
                    $qbuild = $qbuild + "domain:$c_domain "
                    $onedom = $true
                }
            }if($c_process_name){
                if($oneproc){
                    Write-Host -f CYAN '
                    You already have a proc.
                    '
                }
                else{
                    $qbuild = $qbuild + "process_name:$c_process_name "
                    $oneproc = $true
                }
            }
            elseif($c_ipaddr){
                if($oneip){
                    Write-Host -f CYAN '
                    You already have an IP.
                    '
                }
                else{
                    $qbuild = $qbuild + "ipaddr:$c_ipaddr "
                    $oneip = $true
                }
            }
            elseif($c_cmdline){
                if($onecmd){
                    Write-Host -f CYAN '
                    You already have a command query.
                    '
                }
                else{
                    $a = '"' + $c_cmdline + '"'
                    $b = '"' + $c_fsc + '"'
                    $qbuild = $qbuild + "cmdline:$a OR fileless_scriptload_cmdline:$b "
                    $onecmd = $true
                }
            }

            while($Z2 -eq ''){
                Write-Host -f GREEN "
                Add another search item? (y/n) " -NoNewline;
                $Z2 = Read-Host
                Clear-Variable -Force c_*
                if( $Z2 -eq 'y' ){
                    cls
                }
                else{
                    $Z2 = 'n'
                }
            }
        
        }
    }

    
    ## Get input if analyst is querying manually; Helps narrow their searches if
    ##  they only care about user activity 
    if( ! $oneuser -and ! $skipsys ){
        Write-Host -f GREEN "
        Do you want to omit results for SYSTEM/ROOT accounts? (also ignores your username) " -NoNewline;
        $Z = Read-Host
        if($Z -Match "^y"){
            $qbuild = $qbuild + $onlyusers
        }
        Clear-Variable -Force Z
    }
    
    
    ## Limit the search results to 50; if more are needed they can log into the web UI
    if( ! $skipres ){
        Write-Host -f GREEN "
        By default I'll only grab the 10 most recent results for you, but you can change
        this (be aware that increasing results can make your search slower). Enter a new
        max threshold up to 50, or ENTER to keep the default of 10:  " -NoNewline;
        $Z = Read-Host

        if($Z -Match "[0-9]{1,2}"){
            if($Z -gt 50){
                Write-Host ''
                Write-Host -f CYAN "    The limit is currently 50. Setting max results to 50.
                "
                $Z = 50
                ss 2
            }
            $Script:dyrl_ger_RES = $Z
            $res ="&rows=$Z"
        }
        else{
            $Script:dyrl_ger_RES = 10
            $res='&rows=10'
        }
    }

    Write-Host '

    '
    
    ## URL encode the query
    $Script:qdisplay = $qbuild
    $qbuild = $qbuild -replace ' ','%20'
    $qbuild = $qbuild -replace ':','%3A'
    $qbuild = $qbuild -replace "[",'%5B'
    $qbuild = $qbuild -replace "]",'%5D'
    $qbuild = $qbuild + $res
    $qbuild = $qbuild + '&sort=server_added_timestamp%20desc&start=0'

    ## $dyrl_ger_APK is your API key. You'll need to figure out a secure way to
    ## pass it in here, where it will get plugged in by the "craftQuery" function


    craftQuery $qbuild $qsection $dyrl_ger_APK $max
    
    
}


## Take user inputs to build query
## $1 = cb queries from "findThese" function
## $2 = the CB module to query, passed from "findThese"
## $3 is the API Key built in "findThese"
## $4 is the max number of results to fetch
function craftQuery($1,$2,$3,$4){
    Clear-Variable dyrl_ger_WORKSPACE -Force

    $ua = 'MACROSS'   ## Set this user-agent however you'd like, so this script's curl activity can be
                      ##  easily identified in logs and whitelisted if necessary

    getThis $vf19_TOOLSOPT['ger']    ## Encode your Carbon Black server's IP/URL in the extras.ps1 file (see the MACROSS README.md). There is already a 'ger' placeholder in that file.
    $SRV1 = "$vf19_READ"
    getThis 'IC1IICdYLUF1dGgtVG9rZW46IA=='  ## This is " -H 'X-Auth-Token: ", it gets decoded into $SRV2. Your API key ($3) gets appended to the $SRV2 variable
    $SRV2 = $vf19_READ

    $qopen = "curl.exe -k -A '$ua' $SRV1"  ## Recommend you configure your Carbon Black API to only accept encrypted connections
    $qmaxres = $4
    $getResults = "$qopen$2$1' -H 'accept: application/json' $SRV2$3'"  ## $getResults is your curl command to Carbon Black

    
    if( $CALLER ){
    Write-Host -f GREEN '
    Searching on ' -NoNewline;
    Write-Host -f YELLOW "$PROTOCULTURE" -NoNewline;
    Write-Host -f GREEN ', standby...
    '
    }
    else{
    Write-Host -f GREEN '
    Searching now, standby...
    '
    }

    $Script:dyrl_ger_WORKSPACE = iex "$getResults" | ConvertFrom-Json  ## JSON response gets manipulated in the MAIN body for the analyst to view
    Remove-Variable -Force 3  ## Can't be too careful with access keys
}


## Loop until user quits
##  $1 is automatically passed if $CALLER has any value
function searchAgain($1){
    Write-Host ''
    if( $1 -ne 1 ){
        Write-Host -f GREEN "    Hit ENTER to search again, or 'q' to quit: " -NoNewline;
        $Z = Read-Host
        if( $Z -eq 'q' ){
            $1 = 1
        }
    }

    cls

    if( $1 -eq 1 ){
        wrapItUp 1
    }
}




$r = 0  ## The result count of successful queries


while($r -Match "[0-9]"){

    splashPage

    ## Import args from other tools
    if( $CALLER ){
        if( $CALLER -eq 'MACROSS' ){
            Write-Host -f GREEN '
            Hit ENTER to select a file for hash searches, or
            type in the filename for a general search: ' -NoNewline;
            $Z1 = Read-Host

            if( $Z1 -eq '' ){
                $Z1 = getFile  ## open dialog for user to select a file; kill script if they cancel file selection
                if( $Z1 -eq '' ){
                    Write-Host -f CYAN '  No file selected. Exiting...'
                    ss 2
                    Exit
                }
                while($Z2 -notMatch "^(md5|sha256)$"){
                    Write-Host -f GREEN "
                    MD5 or SHA256? " -NoNewline;
                    $Z2 = Read-Host
                }
            }
            else{
                $Z2 = $null
            }

            inspectBin $Z1 $Z2  ## Uses Carbon Black's 'binary' API to view records of hashes and filenames
        }
        elseif( $PROTOCULTURE -ne $null ){
            findThese $CALLER $PROTOCULTURE  ## Send imported query params to the builder function
        }
        else{
            errMsg 4  # Inform user they're missing something
        }

    }
    # Run GERWALK by itself with user inputs
    else{
        findThese
    }

    $Global:HOWMANY = ($dyrl_ger_WORKSPACE.results).length

    if( $HOWMANY -gt 0){

        ## Display results as an indexed list
        function showRES(){
            cls
            $Script:dyrl_ger_RESLIST = @{}  ## This list will allow analysts to pick any event to drill down into
            Write-Host -f CYAN '  You searched:'
            Write-Host "  $qdisplay"
            Write-Host -f GREEN "
    
            Displaying the latest " -NoNewline;
            Write-Host -f YELLOW "$HOWMANY" -NoNewline;
            Write-Host -f GREEN ' results:'
            Write-Host -f YELLOW "    ======================================
            "
            $dyrl_ger_WORKSPACE.results | Foreach-Object{  ## Prettify the results by picking & choosing elements to show onscreen
                $r++
                $Script:dyrl_ger_RESLIST.Add($r,$_)
                $startt = $_.start #-replace 'T',' ' -replace "\.[0-9]+Z$",' ZULU'
                $hname = $_.hostname
                $uname = $_.username
                $proc = $_.process_name
                $dom = $_.domain
                $fname = $_.observed_filename -replace "^.+\\",'' -replace "}$",''
                $rname = $_.internal_name
                $md5 = $_.md5
                $fdesc = $_.file_desc
                $sigstat = $_.digsig_result
                $hnwithfn = $_.host_count
                $filesrc = $_.product_name

                adjustTime $startt 0  ## Get the local time from CB's GMT because you can't do it by default SMH

                ## Create menus dynamically based on API called; add more as needed

                ## BINARY API:
                if( $dyrl_ger_BINARYQ ){
                    Write-Host -f GREEN "   $r. FILE: " -NoNewline;
                    Write-Host -f YELLOW "$fname"
                    Write-Host -f GREEN "         REAL NAME: " -NoNewline;
                    Write-Host -f YELLOW "$rname"
                    Write-Host -f GREEN "         DESCRIPTION: " -NoNewline;
                    Write-Host -f YELLOW "$fdesc"
                    Write-Host -f GREEN "         PRODUCT: " -NoNewline;
                    Write-Host -f YELLOW "$filesrc"
                    Write-Host -f GREEN "         SIGNED: " -NoNewline;
                    Write-Host -f YELLOW "$sigstat"
                    Write-Host -f GREEN "         HOSTS SEEN WITH THIS FILE: " -NoNewline;
                    Write-Host -f YELLOW "$hnwithfn"
                    Write-Host -f GREEN "         MD5: " -NoNewline;
                    Write-Host -f YELLOW "$md5"
                }

                ## PROCESS API:
                else{
                    Write-Host -f GREEN "   $r. EVENT TIME: " -NoNewline;
                    Write-Host -f YELLOW "$dyrl_ger_LOCAL LOCAL"
                    Write-Host -f GREEN "         HOST: " -NoNewline;
                    Write-Host -f YELLOW "$hname"
                    Write-Host -f GREEN "         USER: " -NoNewline;
                    Write-Host -f YELLOW "$uname"
                    Write-Host -f GREEN "         PROC: " -NoNewline;
                    Write-Host -f YELLOW "$proc"
                    if( $dom ){
                        Write-Host -f GREEN "         SITE: " -NoNewline;
                        Write-Host -f YELLOW "$dom"
                    }
                }
            }
        }

        Write-Host ''
        $dyrl_ger_Z = ''
        while($dyrl_ger_Z -ne 'f'){
            showRES
            Clear-Variable -Force dyrl_ger_Z
            Write-Host ''
            Write-Host -f GREEN "    Select a result to drill down, or 'f' to finish:  " -NoNewline;
            $dyrl_ger_Z = Read-Host
            if($dyrl_ger_Z -in $dyrl_ger_RESLIST.Keys){
                Write-Host -f GREEN "   $dyrl_ger_Z. EVENT TIME: " -NoNewline;
                Write-Host -f YELLOW "$dyrl_ger_LOCAL"
                $dyrl_ger_RESLIST[[int]$dyrl_ger_Z]
                Read-Host '    Hit ENTER to continue.'
            }
            elseif($dyrl_ger_Z -ne 'f'){
                Write-Host "    $dyrl_ger_Z isn't one of the results..."
                ss 1
            }
        }

        if( $CALLER ){
            searchAgain 1  ## Return to the script that called GERWALK
        }
        else{
            searchAgain    ## Analyst can run manual searches as much as they need
            $r = 0         ## Make sure the next $dyrl_ger_RESLIST list gets numbered correctly
        }
    
    }
    else{
        
        $dyrl_ger_Z = ''
        Write-Host -f CYAN "
        No results found...
        "
        if( $CALLER ){
            ss 1
            searchAgain 1
        }
        else{
            searchAgain
        }

    }
}


wrapItUp 1

