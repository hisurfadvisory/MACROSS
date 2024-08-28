#_sdf1 Windows Event ID reference
#_ver 1.0
#_class 0,user,windows eventID reference,powershell,HiSurfAdvisory,1,hashtable

<# 
    GUBABA is an offline index of Windows Event IDs. You can perform manual
    lookups based on keywords or event IDs; however it is really meant to
    accept input from other scripts (like text parsers) to return Event ID
    definitions for quick lookups.

    NOTE 1:
        This script requires the file "gubaba.json" located in the resources/ folder.
        That file needs to be in whatever directory that gets set as $vf19_TABLES
        during MACROSS's start up, so if you've changed the default location of
        resources/ from MACROSS' root to someplace else, make sure MACROSS knows
        how to find it!

    NOTE 2:
        GUBABA does not accept optional eval parameters, it will only lookup the
        global $PROTOCULTURE value (or the third argument from a python script),
        which can be an integer (an event ID) or a string.
#>



## If you want your powershell scripts to by callable by MACROSS python scripts,
## Copy-Paste this check anf make use o f th globaal vars it sets.
param(
    [string]$pythonsrc=$null
)
if($pythonsrc){
    $Script:ErrorActionPreference = 'SilentlyContinue'
    $p_ = @(); $b_ = @{}
    $pythonsrc -Split '~' | %{$p_ += $_}
    $PYCALL = $p_[0]; $d_ = $env:MACROSS -Split ';'
    $env:MPOD -Split ';' | %{$b_.Add($($_ -Split ':')[0],$($_ -Split ':')[1])}
    $Global:vf19_TOOLSROOT = $d_[0]; $Global:vf19_TOOLSDIR = $d_[1]; $Global:vf19_DTOP = $d_[2]
    $Global:vf19_GBIO = "$vf19_TOOLSROOT\core\py_classes\garbage_io"; $Global:vf19_MPOD = $b_
    1..3 | %{$core = $p_[$_]; . "$vf19_TOOLSROOT\core\$core"}
    $Global:PROTOFILE = "$vf19_GBIO\PROTOCULTURE.eod"
    $Global:PROTOCULTURE = $((Get-Content $PROTOFILE | ConvertFrom-Json)."$PYCALL".target)

    ## If you write a script that can accept a value in addition to (or instead of) $PROTOCULTURE,
    ## then add a line like this:
    #  if($p_[4]){ $optional_var = $p_[4] }
}

## Gubaba!
if( ! $PYCALL -and ! $CALLER ){
    transitionSplash 4 2
}

## ASCII splashes
function splashPage1a(){
    cls
    if( ! $PYCALL ){
        disVer 'GUBABA'
    
    $b = 'ICAgICAg4paI4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKVlyAgIOKWiOKWiOKVl+KWiOKWiOKWi
    OKWiOKWiOKWiOKVlyAg4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKVlyAg4paI4paI
    4paI4paI4paI4pWXCiAgICAg4paI4paI4pWU4pWQ4pWQ4pWQ4pWQ4pWdIOKWiOKWiOKVkSAgIOKWiOKWiOK
    VkeKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkO
    KVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVlwogICAgIOKWiOKWiOKVkSAg4paI4paI4paI4
    pWX4paI4paI4pWRICAg4paI4paI4pWR4paI4paI4paI4paI4paI4paI4pWU4pWd4paI4paI4paI4paI4paI
    4paI4paI4pWR4paI4paI4paI4paI4paI4paI4pWU4pWd4paI4paI4paI4paI4paI4paI4paI4pWRCiAgICA
    g4paI4paI4pWRICAg4paI4paI4pWR4paI4paI4pWRICAg4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4p
    aI4pWX4paI4paI4pWU4pWQ4pWQ4paI4paI4pWR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4paI4paI4pWU4
    pWQ4pWQ4paI4paI4pWRCiAgICAg4pWa4paI4paI4paI4paI4paI4paI4pWU4pWd4pWa4paI4paI4paI4paI
    4paI4paI4pWU4pWd4paI4paI4paI4paI4paI4paI4pWU4pWd4paI4paI4pWRICDilojilojilZHilojiloj
    ilojilojilojilojilZTilZ3ilojilojilZEgIOKWiOKWiOKVkQogICAgICDilZrilZDilZDilZDilZDilZ
    DilZ0gIOKVmuKVkOKVkOKVkOKVkOKVkOKVnSDilZrilZDilZDilZDilZDilZDilZ0g4pWa4pWQ4pWdICDil
    ZrilZDilZ3ilZrilZDilZDilZDilZDilZDilZ0g4pWa4pWQ4pWdICDilZrilZDilZ0='
    getThis $b
    Write-Host '
    '
    Write-Host -f YELLOW $vf19_READ
    }
    else{
    Write-Host '
    '
    }
}
function splashPage1b(){
    ''
    Write-Host -f YELLOW '   ======================================================='
    Write-Host -f CYAN   "              Gubaba (Windows Event Lookups) $VER
    
    "
}


if( $HELP ){
    splashPage1a
    splashPage1b
    $vf19_LATTS['GUBABA'].toolInfo() | %{
        Write-Host -f YELLOW $_
    }
    Write-Host -f YELLOW "
    
    GUBABA is a quick offline reference for researching Windows Events.
    It includes IDs for Windows, SQL server, Sysmon, Exchange, and Sharepoint.

    You can search by keywords or ID numbers. Example:
    
    Find an ID number for events that have to do with the user account changes,
    then search your logs for that ID to begin your threat-hunting.

    Hit ENTER to continue.
    "
    Read-Host
    Exit
}



## Pass in an ID number or string keyword(s), this function will search
## the gubaba.json file and return any IDs that match
function idLookup($1){

    function sendBack($result){
        if( $PYCALL ){
            pyCross 'gubaba' $result
        }
        else{
            Return $result
        }
    }
    
    $types = @('Exchange','SQLServer','Sysmon','SharePoint','Windows')
    Write-Host ''
    if( $1 -eq 'q' ){
        Remove-Variable -Force dyrl_gub_*
        Exit
    }
    elseif( $1 -Match $dyrl_gub_VALIDID ){
        foreach($type in $types){
            foreach($event in $dyrl_gub_INDEX.events.$type){
                if( $1 -eq $event.id){
                    $a = $event.desc
                    $found = $true
                    if($CALLER){
                        sendBack @{$1=$a}
                    }
                    else{
                        screenResults $type "Event $1" $a
                        screenResults -e
                    }
                }
            }
        }
        if( ! $found ){
            Write-Host -f YELLOW "      Couldn't find that ID!"
        }
    }
    elseif( $1 -Match $dyrl_gub_VALIDWD ){
        if($1 -Match ", "){
            $werdz = $1 -Split(', ')
        }
        elseif($1 -Match ","){
            $werdz = $1 -Split(',')
        }
        else{
            $werdz = $1 -Split(' ')
        }
        $c = @{}

        foreach($type in $types){
            foreach($event in $dyrl_gub_INDEX.events.$type){
                :inner
                foreach($werd in $werdz){
                    $match = $true
                        ## Avoid grabbing all descriptions for MS Exchange IDs
                        if($werd -like "*change*" -and $werd -notLike "*exchange*"){
                            $werd =  ' ' + $werd
                        }
                        $a = $event.desc | Select-String "$werd"
                        if( $a ){
                            $b = [int]$($event.id -replace "\W")
                        }
                        else{
                            $match = $false
                            Break inner      ## Don't keep searching an event unless ALL the keywords match
                        }
                    
                }
                if($match){
                    $matched_event = [string]$type + ' Event || ' + $a
                    $c.Add($b,$matched_event)
                }
            }
        }
        
        
        ## External scripts likely won't need screen output, they can parse the response themselves.
        if ( $CALLER ){
            sendBack $c   
        }
        else{
            screenResults "            Events with the keyword(s) $1"
            $c.keys | Sort | %{
                $eiv = $c[$_]
                screenResults $_ $eiv
            }
            screenResults -e
        }
    
    }
    else{
        Write-Host -f YELLOW "      That query is invalid."
    }
}




## Input validation; enter a digit or a string of words, no non-alphanumerics except '-' and ','
$dyrl_gub_VALIDID = [regex]"^[0-9]+$"
$dyrl_gub_VALIDWD = [regex]"^[a-zA-Z][a-zA-Z0-9 ,-]+"


if( $PYCALL ){
    $Global:CALLER = $PYCALL
    getThis $vf19_MPOD['enr']; $dyrl_gub_TABLE = "$vf19_READ\gubaba.json"
    if( ! (Test-Path "$dyrl_gub_TABLE") ){
        Read-Host '  Error... you did not pass me a file location to build my reference table.'
        slp 2
        Exit
    }
}
elseif( Test-Path "$vf19_TABLES\gubaba.json" ){  ## Check if there is an alternate path to the resources folder
    $dyrl_gub_TABLE = "$vf19_TABLES\gubaba.json"
}
elseif( Test-Path "$vf19_TOOLSROOT\resources\gubaba.json" ){   ## Check if the resources folder is in MACROSS root
    $dyrl_gub_TABLE = "$vf19_TOOLSROOT\resources\gubaba.json"
}
else{
    Write-Host -f CYAN '
    ERROR! Cannot find the required lookup table. Exiting...
    '
    slp 2
    Exit
}


if($PROTOCULTURE){
    $dyrl_gub_QUERY = $PROTOCULTURE
}


    ## Collect the list of Event IDs into a lookup table
    #$dyrl_gub_INDEX = Get-Content -Raw "$dyrl_gub_TABLE" | ConvertFrom-StringData
    $dyrl_gub_INDEX = Get-Content -Raw "$dyrl_gub_TABLE" | ConvertFrom-Json


## Accept ID or descriptor from other MACROSS tools to perform automatic lookups
if( $dyrl_gub_QUERY ){
    ## Make sure your script knows it is getting back a hashtable result!
    if($PYCALL){
        pyCross GUBABA $(idLookup $dyrl_gub_QUERY)
    }
    else{
        Return $(idLookup $dyrl_gub_QUERY)
    }
}
else{
    if( ! $PYCALL ){  ## No python, go ahead and throw the ascii up
        splashPage1a
    }
    splashPage1b


    ## Perform manual lookups straight from MACROSS console
    while( $dyrl_gub_Z -ne 'q' ){
        $dyrl_gub_Z = $null
        Write-Host ''
        Write-Host -f GREEN '  What Event ID or keywords are you looking up? If you enter'
        Write-Host -f GREEN "  more than one keyword, you'll only get results that contain ALL"
        Write-Host -f GREEN '  of those words. Type "' -NoNewline;
        Write-Host -f YELLOW 'q' -NoNewline;
        Write-Host -f GREEN '" to quit.
    
        SEARCH:  ' -NoNewline;
        $dyrl_gub_Z = Read-Host
        if($dyrl_gub_Z -ne 'q'){
            idLookup $dyrl_gub_Z
        }
    }
}
