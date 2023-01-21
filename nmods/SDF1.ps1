#_superdimensionfortress Basic port scanner if nmap is unavailable
#_ver 1.8
#_class Admin,IP and ports,Powershell,HiSurfAdvisory,1

<#
    Author: HiSurfAdvisory

    It's SDF-1... not NMAP
    Basic port scanner

    Written on a closed network that had restrictions on
    installing utilities. SDF-1 is only useful if REAL Nmap
    is not an option.

    TO-DO:
    Would be nice to have more functionality like NMAP,
    but not sure if it's worth the hassle of handjamming
    code like that onto airgapped networks.

    v1.8
    Rewritten to integrate with MACROSS; streamlined functions,
    got rid of redundant crap from the original version
    
#>


if( $HELP ){
 cls
 $vf19_ATTS['SDF1'].toolInfo() | %{
   Write-Host -f YELLOW $_
 }
 Write-Host -f YELLOW "  
                             =============================   
                                     SDF-1 v$VER
                             =============================
 
  SDF-1 performs a basic portscan on any IP/port(s) you specify, and only checks
  to see if the port is open. You can scan single IPs as well as IP ranges & hostnames, 
  and save your results to text file if needed.

  This is a copy-pasta solution for cases when installing software and utilities like
  NMAP is severely restricted.
 
  Hit ENTER to return.
  "

 Read-Host
 Return
}


## I sincerely hope you don't let non-admins perform port-scans on your network...
SJW 'deny'


function splashPage(){
    cls
    disVer 'SDF1'
    Write-Host '
    '
    Write-Host -f YELLOW '           ███████╗██████╗ ███████╗        ██╗'
    Write-Host -f YELLOW '           ██╔════╝██╔══██╗██╔════╝       ███║'
    Write-Host -f YELLOW '           ███████╗██║  ██║█████╗  █████╗ ╚██║'
    Write-Host -f YELLOW '           ╚════██║██║  ██║██╔══╝  ╚════╝  ██║'
    Write-Host -f YELLOW '           ███████║██████╔╝██║             ██║'
    Write-Host -f YELLOW '           ╚══════╝╚═════╝ ╚═╝             ╚═╝'
    Write-Host -f YELLOW '   ================================================'
    Write-Host -f CYAN   "               SDF-1 (poor man's nmap) $VER
    "
}

function resultOutput(){
    if( $dyrl_sdf_TEXTOUT ){
        if( (Test-Path $dyrl_sdf_TEXTOUT -PathType Leaf) ){
            if( $CALLER ){
                $Global:RESULTFILE = $dyrl_sdf_TEXTOUT
            }
            Write-Host -f GREEN "    Results have been recorded in '$dyrl_sdf_FN' on your desktop.
            "
        }
        else{
            Write-Host -f YELLOW "    No results were written to file.
            "
        }
    }
    while($z -ne 'c'){
        Write-Host '
        '
        Write-Host -f GREEN "    Type 'c' to continue. " -NoNewline;
        $z = Read-Host
    }
}

## Ask user to specify which host(s) to scan
function getHost(){
    while( $Z -notMatch $dyrl_sdf_IPPATTERN ){
        Write-Host -f GREEN "    Enter a hostname, IP, or " -NoNewline;
        Write-Host -f YELLOW "c" -NoNewline;
        Write-Host -f GREEN " to cancel:"
        Write-Host -f GREEN "      -Use a '-' to scan IP ranges"
        Write-Host -f GREEN "      -Append '/24' to scan a full class C"
        Write-Host -f GREEN "      -Append '/16' to scan a full class B"
        Write-Host -f GREEN "      -Enter a partial hostname to scan all hostnames that match
        "
        Write-Host -f GREEN "    >  " -NoNewline;
        $Z = Read-host

        if( $Z -eq 'c' ){
            $Script:sdf_LOOP = $false
        }
        elseif( $Z -Match "[a-z]" ){
            if( $vf19_NOPE ){         ## hostname scans require active-directory; I hope non-priv'd accounts can't query AD!
                $Z = $null
                Write-Host -f CYAN "  You need to be an admin to search by hostname.
                "
            }
            else{
                $Global:dyrl_sdf_HN = $Z
                $Global:dyrl_sdf_ADQ = Get-ADComputer -Filter * | where{$_.name -Match "$dyrl_sdf_HN"}
            }
        }
        elseif($Z -Match "/"){
            if($Z -notMatch "(16|24)$"){
                Write-Host -f CYAN "  Sorry, I don't actually do CIDR calculations, I only recognize"
                Write-Host -f CYAN "  /24 and /16. You can specify a range using '-'.
                "
                $Z = $null
            }
        }
    }

    $Global:dyrl_sdf_IPA = $Z
}

## Set the port(s)/protocol to scan
function getPorts(){
    while( $Z1 -notMatch $dyrl_sdf_GOODPORT ){
        Write-Host ''
        Write-Host -f GREEN "    Enter a port number, range of ports separated with a '" -NoNewline;
            Write-Host -f YELLOW "-" -NoNewline;
                Write-Host -f GREEN "',"
        Write-Host -f GREEN "    or a set of ports separated by commas (no spaces):  " -NoNewline;
            $Z1 = Read-Host
    }

    Write-Host ''

    ## Set the protocol
    while( $Z2 -notMatch "^(t|u)$" ){
        Write-Host -f GREEN "    Are you scanning (" -NoNewline;
        Write-Host -f YELLOW "t" -NoNewline;
        Write-Host -f GREEN ")cp or (" -NoNewline;
        Write-Host -f YELLOW "u" -NoNewline;
        Write-Host -f GREEN ")dp?  " -NoNewline;
        $Z2 = Read-Host
    }
    $Global:dyrl_sdf_PROTO = $Z2

    
    ## Set the default variable R1 based on number of ports entered:
    if( $Z1 -Match $dyrl_sdf_SINGLEPORT ){
        $Global:dyrl_sdf_R1 = $Z1
    }
    ## If searching by range, format the first and last ports so PS sees it as a range
    elseif( $Z1 -Match $dyrl_sdf_RANGEPORTS ){
        $R0a = $Z1 -replace("\-.*$","")
        $R0b = $Z1 -replace("^.*\-","")
        $Global:dyrl_sdf_R1 = ([int]$R0a..[int]$R0b)
    }
    ## If searching multiple ports, create a list from the user's input
    elseif( $Z1 -Match $dyrl_sdf_ARRAYPORTS ){
        $Global:dyrl_sdf_R1 = $Z1.Split(",")
    }
    else{
        Write-Host -f CYAN  "    Unknown error. Quitting scan..."
        Write-Host -f CYAN  "    Hit ENTER to continue.
        "
        Remove-Variable dyrl_sdf_* -Scope Global

        if( $GOBACK ){
            Remove-Variable CALLER -Scope Global
            Remove-Variable GOBACK -Scope Global
            cls
            Return
        }
        else{
            Exit
        }

    }
}


## $1 = the targeted host, $2 = the port(s) being scanned
## $3 = the protocol
function scanIt($1,$2,$3){
    if( (Test-Connection -BufferSize 32 -Count 1 -Quiet -ComputerName $1) ){
        foreach( $port in $2 ){
            if( $3 -Match 'u' ){
                $socket = New-Object System.Net.Sockets.UdpClient($1, $port)
                if( $socket ){
                    $open_s = $true
                }
            }
            elseif( $3 -Match 't' ){
                $socket = New-Object System.Net.Sockets.TcpClient($1, $port)
                if( $socket.Connected ){
                    $open_s = $true
                    $socket.Close()
                }
            }

            $socktxt = "$1" + "[" + "$port" + "]"
            Write-Host -f GREEN "    $socktxt is " -NoNewline;

            if( $open_s ){
                $Global:HOWMANY++
                Write-Host -f YELLOW "open..."
                if( Test-Path $dyrl_sdf_TEXTOUT ){
                    "$socktxt  is OPEN" | Out-File -FilePath $dyrl_sdf_TEXTOUT -Append
                }
            }
            else{
                Write-Host -f CYAN "closed/unresponsive..."
            }

            $open_s = $null
        }
    }
    else{
        Write-Host -f YELLOW "        $1 is unreachable..."
    }
    Return
}


function scanHostname(){
    foreach($hn in $dyrl_sdf_ADQ.name.replace(" ","")){
        scanIt $hn $dyrl_sdf_R1 $dyrl_sdf_PROTO 
    }
}


## $1 is the first IP, $2 can be the ending IP *or* the pseudo-CIDR notation
function scanRange($1,$2){
    $a = $1 -Split("\.")  ## split IP by octets
    
    if($2 -eq '24'){
        $o3 = [string]$a[2]    # keep third octet for class A scan
        $o4 = [string]1        # set last octet
        $c1 = 254              # set number of IPs to scan
        $c2 = $false           # only scanning last octet
    }
    elseif($2 -eq '16'){
        $o3 = [string]0        # set third octet for class B scan
        $o4 = [string]1        # set last octet
        $c1 = 254              # scan this many in the last octet
        $c2 = 256              # scan this many in the third octet
    }
    elseif($2 -Match "^[0-9.]+$"){              # if user specified custom range;
        $b = $2 -Split("\.")                    # get the last IP user wants to scan
        $c1 = [int]$b[3] - [int]$a[3] + 1       # scan this many in the 4th octet
        $o3 = $a[2]                             # keep third octet for the first IP
        $o4 = $a[3]                             # keep last octet for the first IP
        if($b[2] -ne $a[2]){                    # compare third octet from first and last IPs
            $c2 = [int]$b[2] - [int]$a[2] + 1   # if different, scan this many subnets
        }
        else{
            $c2 = $false                        # if equal, don't increment third octet
        }
    }
    
    $o1 = $a[0]  # set first octet
    $o2 = $a[1]  # set second octet

    
    ## Keep scanning until c1 & c2 are both zero or false
    while( $c1 -ne 0 ){
        [string]$ipaddr = $o1 + '.' + $o2 + '.' + $o3 + '.' + $o4
        scanIt $ipaddr $dyrl_sdf_R1 $dyrl_sdf_PROTO

        if( $c2 ){              ## if scanning multiple subnets;
            if($c1 -eq 0 ){     ## when the /24 is finished, check if we need to move to the next subnet
                if($c2 -eq 0){  ## stop incrementing subnets if we've reached the last one
                    $c2 = $false
                }
                else{
                    $o3 = [int]$o3      ## mathify the 3rd octet
                    $o3++
                    $o3 = [string]$o3   ## restring the 3rd octet
                    $o4 = 0             ## reset the /24 if we've moved to the next subnet
                    $c2--
                    $c1 = 254
                }
            }
        }

        slp 1
        $o4 = [int]$o4     ## mathify the 4th octet
        $o4++
        $o4 = [string]$o4  ## restring the 4th octet
        $c1--

    }

}



#############
## Input validation
#############
$dyrl_sdf_IPPATTERN = [regex]"(^[a-z0-9-]+$|^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(\-[0-9.]+|/(24|16))?)"
$dyrl_sdf_SINGLEHN = [regex]"^[a-z0-9_-]+$"
$dyrl_sdf_GOODPORT = [regex]"^[0-9][0-9,-]*$"
$dyrl_sdf_SINGLEPORT = [regex]"^[0-9]{1,65535}$"
$dyrl_sdf_RANGEPORTS = [regex]"^[0-9]+\-[0-9]+$"
$dyrl_sdf_ARRAYPORTS = [regex]"[0-9]+,[0-9,]+"

#############
## Default vars
#############
$Script:sdf_LOOP = $true
$Global:HOWMANY = 0

## Might irritate people, but I'm a Macross nut
if( ! $CALLER ){
    transitionSplash 2
}

splashPage


## Ensure vars don't persist
function cleanQuit(){
    Remove-Variable GOBACK
    Remove-Variable -Force dyrl_sdf_* -Scope Global
}

##########################
##                 MAIN
##########################

do{
    ## Set the IP to scan

    if( $CALLER ){           ## Import host to scan from other script
        if( $PROTOCULTURE ){
            $GOBACK = $true
            $Script:sdf_LOOP = $false
            $dyrl_sdf_IPA = $PROTOCULTURE
            Write-Host -f GREEN "    Importing " -NoNewline;
                Write-Host -f YELLOW "$PROTOCULTURE" -NoNewline;
                    Write-Host -f GREEN " from " -NoNewline;
                        Write-Host -f YELLOW "$CALLER" -NoNewline;
                            Write-Host -f GREEN "..."
            slp 1
        }
    }
    else{                    ## Manually input host(s) to scan

        getHost

    }

    

    if( $dyrl_sdf_IPA -eq 'c' ){  ## User cancelled out
        Break
    }

    
    
    Write-Host ''

    getPorts
    
    Write-Host ''

    ## Set optional output file
    Write-Host -f GREEN "    Enter a filename to save results to, or ENTER to skip:  " -NoNewline;
        $dyrl_sdf_FN = Read-Host

    if( $dyrl_sdf_FN -Match "^[a-zA-Z0-9]" ){
        $dyrl_sdf_FN = $dyrl_sdf_FN + ".txt"
        $dyrl_sdf_TEXTOUT = "$vf19_DEFAULTPATH\$dyrl_sdf_FN"
        New-Item -Path $dyrl_sdf_TEXTOUT -ItemType file
        $Global:RESULTFILE = $dyrl_sdf_TEXTOUT
    }
    else{
        $dyrl_sdf_TEXTOUT = $false
    }



    if( $dyrl_sdf_HN ){
        scanHostname                                  ## scan all matching hostnames
    }
    elseif($dyrl_sdf_IPA -Match "/16$"){
        $dyrl_sdf_IPA = $dyrl_sdf_IPA -replace "/16$",""
        scanRange $dyrl_sdf_IPA '16'                    ## scan a class B
    }
    elseif($dyrl_sdf_IPA -Match "/24$"){
        $dyrl_sdf_IPA = $dyrl_sdf_IPA -replace "/24$",""
        scanRange $dyrl_sdf_IPA '24'                    ## scan a class C
    }
    elseif($dyrl_sdf_IPA -Match "[0-9]\-[0-9]"){
        $dyrl_sdf_IP1 = $dyrl_sdf_IPA -replace "\-.+$",""
        $dyrl_sdf_IP2 = $dyrl_sdf_IPA -replace "^.+\-",""
        scanRange $dyrl_sdf_IP1 $dyrl_sdf_IP2               ## scan a custom range
    }
    else{
        scanIt $dyrl_sdf_IPA $dyrl_sdf_R1 $dyrl_sdf_PROTO      ## scan a single IP
        $dyrl_sdf_PROTO = $null
    }
    

    if( $GOBACK ){
        cleanQuit
        Write-Host -f GREEN "    Hit ENTER to continue.
        "
        Read-Host
        cls
        Return
    }
    else{
        resultOutput
        Write-Host -f GREEN "    Do you need to scan another IP?  " -NoNewline;
            $dyrl_sdf_Z = Read-Host

        if( $dyrl_sdf_Z -notMatch "^y" ){
            $Script:sdf_LOOP = $false
        }
        else{
            $dyrl_sdf_Z = $null
            $dyrl_sdf_IPA = $null
            $dyrl_sdf_IPP = $null
            $dyrl_sdf_PROTO = $null
            $dyrl_sdf_FN = $null
            $dyrl_sdf_TEXTOUT = $null
            splashPage
        }
    }

}until( ! $sdf_LOOP )

cleanQuit
Exit 0