#_sdf1 Windows Event ID reference
#_ver 1.0
#_class 0,user,windows event id lookup,powershell,HiSurfAdvisory,1,hashtable

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


###################################################################################
###       README ~~~~~~~~~ MACROSS PYTHON INTEGRATION EXAMPLE
###################################################################################
## If you want your powershell scripts to work with MACROSS python scripts,
## copy-paste this check to restore all the values that get lost when transitioning
## via both the powershell and python versions of the collab function.
param(
    $pythonsrc = $null  ## The python collab function will set this value
)
if( $pythonsrc ){
    ## This will be the name of the python script calling this one
    $Global:CALLER = $pythonsrc

    ## This is a unique temporary session, so launch the core scripts to get their functions
    foreach( $core in gci "$(($env:MACROSS -Split ';')[0])\core\*.ps1" ){ . $core.fullname }

    ## Now that the core files are loaded, this function can restore all the MACROSS 
    ## defaults your powershell script might need
    restoreMacross
    
    ## Note that just like the powershell version, the python collab function can also
    ## send an alternate param to your scripts when relevant. So, you can write your  
    ## scripts to accept a value in addition to (or instead of) $PROTOCULTURE, if necessary.
}


## Gubaba!
if( ! $CALLER ){ transitionSplash 4 2 }

## ASCII splashes
function splashPage1a(){
    cls
    if( ! $pythonsrc ){
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
    w '
    '
    w $vf19_READ y
    }
    else{
    w '
    '
    }
}
function splashPage1b(){
    ''
    w '   =======================================================' y
    w   "              Gubaba v$($vf19_LATTS['GUBABA'].ver) (Windows Event Lookups) 
    
    " c
}


if( $HELP ){
    splashPage1a
    splashPage1b
    $vf19_LATTS['GUBABA'].toolInfo() | %{
        w $_ y
    }
    w "
    
    GUBABA is a quick offline reference for researching Windows Events.
    It includes IDs for Windows, SQL server, Sysmon, Exchange, and Sharepoint.

    You can search by keywords or ID numbers. Example:
    
    Find an ID number for events that have to do with the user account changes,
    then search your logs for that ID to begin your threat-hunting.

    Hit ENTER to continue.
    " y
    Read-Host
    Exit
}



## Pass in an ID number or string keyword(s), this function will search
## the gubaba.json file and return any IDs that match
function idLookup($1){
    
    function sendBack($result){
        if( $pythonsrc ){ pyCross -c $CALLER -r $result }
        else{ Return $result }
    }
    
    $types = @('Exchange','SQLServer','Sysmon','SharePoint','Windows')
    ''
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
            w "      Couldn't find that ID!" y
        }
    }
    elseif( $1 -Match $dyrl_gub_VALIDWD ){
        $werdz = $1 -replace ", ","," -replace ","," " -replace "\s\s+"," "
        $werdz = $werdz -Split(' ')
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
                    $a = $event.desc | sls "$werd"
                    if( $a ){
                        $b = [int]$($event.id -replace "\W")
                    }
                    else{
                        $match = $false
                        Break inner      ## Don't keep searching an event unless ALL the keywords match
                    }
                    
                }
                if($match){
                    ## Return a hashtable with IDs as the key, event type + description as the value
                    $c.Add("$b",@($type,$a))    
                }
            }
        }
        if($c.count -eq 0){
            $c = $false
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
        w "      That query is invalid." y
    }
}




## Input validation; enter a digit or a string of words, no non-alphanumerics except '-' and ','
$dyrl_gub_VALIDID = [regex]"^\d+$"
$dyrl_gub_VALIDWD = [regex]"^[a-zA-Z][\w ,-]+$"


if( $pythonsrc ){
    getThis $vf19_MPOD['enr']; $dyrl_gub_TABLE = "$vf19_READ\gubaba.json"
    if( ! (Test-Path "$dyrl_gub_TABLE") ){
        Write-Host "  Error... MACROSS hasn't specified a location to build my reference table!"
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
    w '
    ERROR! Cannot find the required lookup table. Exiting...
    ' c
    slp 2
    Exit
}


## Collect the list of Event IDs into a lookup table
$dyrl_gub_INDEX = Get-Content -Raw "$dyrl_gub_TABLE" | ConvertFrom-Json


if( $PROTOCULTURE ){ $dyrl_gub_QUERY = $PROTOCULTURE }

## Accept ID or descriptor from other MACROSS tools to perform automatic lookups
if( $dyrl_gub_QUERY ){
    ## Make sure your script knows it is getting back a hashtable result!
    idLookup $dyrl_gub_QUERY
}
else{
    if( ! $pythonsrc ){
        splashPage1a
    }
    splashPage1b


    ## Perform manual lookups straight from MACROSS console
    while( $dyrl_gub_Z -ne 'q' ){
        $dyrl_gub_Z = $null
        ''
        w '  What Event ID or keywords are you looking up? If you enter' g
        w "  more than one keyword, you'll only get results that contain ALL" g
        w '  of those words. Type "' -i g
        w 'q' -i y
        w '" to quit.
    
        SEARCH:  ' -i g
        $dyrl_gub_Z = Read-Host
        if($dyrl_gub_Z -ne 'q'){
            idLookup $dyrl_gub_Z
        }
    }
}
