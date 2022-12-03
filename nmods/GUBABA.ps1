#_wut Windows Event ID reference
#_ver 1.0

<# 
    
    Author: HiSurfAdvisory
    
    This script requires the file "gubaba.txt" located in the /resources folder.
    That text file needs to be in whatever directory that gets set as $vf19_TABLES
    during MACROSS's start up.
#>


## Accept values from other scripts
param(
    [Parameter(position = 0)]
    [string]$PYCALL,
    [Parameter(position = 1)]
    [string]$dyrl_gub_TABLE,
    [Parameter(position = 2)]
    [string]$PROTOCULTURE
)


if( ! $PYCALL -or ! $CALLER ){
    transitionSplash 4
}

function splashPage(){
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
    Write-Host -f YELLOW '   ======================================================='
    Write-Host -f CYAN   "              Gubaba (Windows Event Lookups) $VER
    
    "
}



if( $HELP ){
    splashPage
    disVer 'GUBABA'
    Write-Host -f YELLOW "
                               GUBABA v$VER
    
    A quick offline reference for researching Windows Security Events by
    description or ID numbers.

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
            Write-Host -f GREEN "            Events with the keyword " -NoNewline;
            Write-Host -f CYAN $1 -NoNewline;
            Write-Host -f GREEN ':
            '
            foreach($i in $a){
                $eid = $i.Name
                $eiv = $i.Value
                Write-Host -f GREEN "    $eid" -NoNewline;
                Write-Host -f CYAN " - $eiv"
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



splashPage

## Input validation
$dyrl_gub_VALIDID = [regex]"^[0-9]{1,4}$"
$dyrl_gub_VALIDWD = [regex]"^[a-zA-Z][a-zA-Z0-9 -]+"


if( $PYCALL ){
    $CALLER = $PYCALL
    if( Test-Path "$dyrl_gub_TABLE" ){
        Write-Host -f GREEN "    $CALLER -> GUBABA:"
    }
    else{
        read-host 'nope'
    }
}
elseif( Test-Path "$vf19_TABLES\gubaba.txt" ){
    $dyrl_gub_TABLE = "$vf19_TABLES\gubaba.txt"
}
elseif( Test-Path "$vf19_TOOLSROOT\resources\gubaba.txt" ){
    $dyrl_gub_TABLE = "$vf19_TOOLSROOT\resources\gubaba.txt"
}
else{
    Write-Host -f CYAN "
    ERROR! Cannot find the required lookup table. Exiting...
    "
    ss 2
    Exit
}

$dyrl_gub_INDEX = Get-Content -Raw "$dyrl_gub_TABLE" | ConvertFrom-StringData

if( $PROTOCULTURE ){           ## Accept ID or descriptor from other tools to perform lookup
    idLookup $PROTOCULTURE
    Write-Host -f GREEN "
    Hit ENTER to return to $CALLER.
    "
    Read-Host
    Return
}

while( $dyrl_gub_Z -ne 'q' ){
    $dyrl_gub_Z = $null
    Write-Host ''
    Write-Host -f GREEN "  What Event ID or keywords are you looking up ("-NoNewline;
        Write-Host -f YELLOW "q" -NoNewline;
            Write-Host -f GREEN " to quit)?  " -NoNewline;
                $dyrl_gub_Z = Read-Host
    idLookup $dyrl_gub_Z
}
