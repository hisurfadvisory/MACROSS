#_superdimensionfortress Windows Event ID reference
#_ver 1.0

<# 
    GUBABA is an offline index of Windows Event IDs. You can perform manual
    lookups based on keywords or event IDs; however it is really meant to
    accept input from other scripts (like text parsers) to return Event ID
    definitions for quick lookups. 

    NOTE 1:
        This script requires the file "gubaba.txt" located in the /resources folder.
        That text file needs to be in whatever directory that gets set as $vf19_TABLES
        during MACROSS's start up.

    NOTE 2:
        GUBABA does not accept optional eval parameters, it will only lookup the
        global $PROTOCULTURE value (or the third argument from a python script),
        which can be an integer (an event ID) or a string.

#>


## Accept values from other scripts
param(
    [Parameter(position = 0)]
    [string]$PYCALL,
    [Parameter(position = 1)]
    [string]$dyrl_gub_TABLE,
    [Parameter(position = 2)]
    $PROTOCULTURE
)


## Gubaba!
if( ! $PYCALL -or ! $CALLER ){
    transitionSplash 4
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
    disVer 'GUBABA'
    Write-Host -f YELLOW "
                               GUBABA v$VER
    
    A quick offline reference for researching Windows Security Events.
    You can search by keywords or ID numbers. 

    Hit ENTER to continue.
    "
    Read-Host
    Exit
}




function idLookup($1){
    Write-Host ''
    if( $1 -eq 'q' ){
        Remove-Variable -Force dyrl_gub_*
        Exit
    }
    elseif( $1 -Match $dyrl_gub_VALIDID ){
        if( $1 -in $dyrl_gub_INDEX.keys){
            $a = $dyrl_gub_INDEX.Item($1)
            Write-Host -f GREEN "      Event $1 :" -NoNewline;
                Write-Host -f CYAN " $a"
        }
        else{
            Write-Host -f YELLOW "      Couldn't find that ID!"
        }
    }
    elseif( $1 -Match $dyrl_gub_VALIDWD ){
        $a = $dyrl_gub_INDEX.GetEnumerator() | ? {$_.value -Match $1}
        if( $a ){

            ## External scripts likely won't need screen output, they can parse the return themselves.
            if ( ! $CALLER ){
                Write-Host -f GREEN "            Events with the keyword " -NoNewline;
                Write-Host -f CYAN $1 -NoNewline;
                Write-Host -f GREEN ':
                '
            }


            foreach($i in $a){
                $eid = $i.Name
                $eiv = $i.Value
                Write-Host -f GREEN "    $eid" -NoNewline;
                Write-Host -f CYAN " ::: $eiv"
            }

        }
        else{
                Write-Host -f YELLOW "      Couldn't find that event keyword!"
        }
    }

    else{
        Write-Host -f YELLOW "      That query is invalid."
    }
}




## Input validation
$dyrl_gub_VALIDID = [regex]"^[0-9]{1,4}$"
$dyrl_gub_VALIDWD = [regex]"^[a-zA-Z][a-zA-Z0-9 -]+"


if( $PYCALL ){
    if( ! (Test-Path "$dyrl_gub_TABLE") ){
        Read-Host '  Error... you did not pass me a file location to build my reference table.'
        Exit
    }
    else{
        $CALLER = $PYCALL
    }
}
elseif( Test-Path "$vf19_TABLES\gubaba.txt" ){  ## Check if there is an alternate path to the resources folder
    $dyrl_gub_TABLE = "$vf19_TABLES\gubaba.txt"
}
elseif( Test-Path "$vf19_TOOLSROOT\resources\gubaba.txt" ){   ## Check if the resources folder is in MACROSS root
    $dyrl_gub_TABLE = "$vf19_TOOLSROOT\resources\gubaba.txt"
}
else{
    Write-Host -f CYAN '
    ERROR! Cannot find the required lookup table. Exiting...
    '
    slp 2
    Exit
}



if( ! $CALLER ){  ## GUBABA is running by itself, go ahead and throw the splashpage
    splashPage1a
    splashPage1b
}


## Collect the list of Event IDs into a lookup table
$dyrl_gub_INDEX = Get-Content -Raw "$dyrl_gub_TABLE" | ConvertFrom-StringData


## Accept ID or descriptor from other MACROSS tools to perform automatic lookups
if( $PROTOCULTURE ){

    $dyrl_gub_R = idLookup $PROTOCULTURE

    ## Prep an output that the calling python script can parse; it can't natively use the value
    ## sent back in the Return instruction below.
    if( $PYCALL ){
        $dyrl_gub_R | Out-File -Path "$vf19_GBIO\gubaba.eod" -Encoding UTF8 -Append
    }

    Return $dyrl_gub_R
}


## Perform manual lookups straight from MACROSS console
while( $dyrl_gub_Z -ne 'q' ){
    $dyrl_gub_Z = $null
    Write-Host ''
    Write-Host -f GREEN '  What Event ID or keywords are you looking up ('-NoNewline;
    Write-Host -f YELLOW 'q' -NoNewline;
    Write-Host -f GREEN ' to quit)?  ' -NoNewline;
    $dyrl_gub_Z = Read-Host
    if($dyrl_gub_Z -ne 'q'){
        idLookup $dyrl_gub_Z
    }
}
