#_sdf1 Code-signing & Cert inspection
#_ver 1.5
#_class 0,user,digital certificates,powershell,HiSurfAdvisory,1,onscreen

## Watch for alt filenames requested from python scripts via 'collab'
param(
    [string]$dyrl_bas_NOPROTO
)

function splashPage(){
    cls
    $b = 'ICAgICAgICDilojilojilojilojilojilojilZcgIOKWiOKWiOKWiOKWiOKWiOKVlyDilojiloj
    ilojilojilojilojilojilZcg4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKVlyAg
    4paI4paI4paI4paI4paI4pWXIAogICAgICAgIOKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVl
    OKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKVkOKVkOKVneKWiOKWiOKVlOKVkOKVkOKWiOKWiO
    KVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVlwogICAgICAgIOK
    WiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKW
    iOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKWi
    OKWiOKWiOKWiOKWiOKWiOKWiOKVkQogICAgICAgIOKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiO
    KVlOKVkOKVkOKWiOKWiOKVkeKVmuKVkOKVkOKVkOKVkOKWiOKWiOKVkeKWiOKWiOKVlOKVkOKVkOKWiOK
    WiOKVkeKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVkQogICAgICAg
    IOKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVkSAg4paI4paI4pWR4paI4paI4paI4paI4paI4
    paI4paI4pWR4paI4paI4pWRICDilojilojilZHilojilojilZEgIOKWiOKWiOKVkeKWiOKWiOKVkSAg4p
    aI4paI4pWRCiAgICAgICAg4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWdIOKVmuKVkOKVnSAg4pWa4pWQ4pWd4pW
    a4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ3ilZrilZDilZ0gIOKVmuKVkOKV
    neKVmuKVkOKVnSAg4pWa4pWQ4pWdCiAgICAgID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09P
    T09PT09PT09PT09PT09PT09PT0='
    getThis $b
    Write-Host '
    '
    Write-Host -f YELLOW $vf19_READ
    Write-Host -f YELLOW '    ===================================================
           Code-signing + Certificate inspection
    '
}


################################
## Expanded info
################################
if( $HELP ){
 splashPage
 $vf19_LATTS['BASARA'].toolInfo() | %{
   Write-Host -f YELLOW $_
 }
 Write-Host -f YELLOW "
     Code-signing may be enforced for security. If you have a signing certificate,
     you can use this tool to quickly sign your new scripts so they will be
     allowed to run, or re-sign expired/updated code.

     Simply put your script in the \modules folder, or let BASARA prompt you
     for the file location.
 
     If you run BASARA with the 's' option (ex '1s'), it disables the code-
     signing function and instead lets you inspect the details for a file's
     digital signature.

     BASARA can also be sent the filepath to a signed binary from other scripts,
     scan it and then report the digital cert information to you.

     Hit ENTER to continue.
 "
 Read-Host
 Return
}

function peekCert($1){
    if( (Test-Path -Path "$1") ){
        Get-AuthenticodeSignature $1
        Get-PfxCertificate $1 | Select-String -Pattern "CN"
    }
    else{
        Write-Host -f CYAN ' File not found!
        '
    }
}


splashPage

## Alternate mode to inspect files instead of signing them
if( $vf19_OPT1 ){
    Write-Host ''
    while( $dyrl_bas_Z -ne 'q' ){
        Write-Host '
        '
        Write-Host -f GREEN " Type 'f' to select a file for inspection, or " -NoNewline;
        Write-Host -f YELLOW 'q' -NoNewline;
        Write-Host -f GREEN ' to quit: ' -NoNewline;
        $dyrl_bas_Z = Read-Host

        if( $dyrl_bas_Z -ne 'q' ){
            $dyrl_bas_Z = getFile
            if($dyrl_bas_Z -ne ''){
                peekCert $dyrl_bas_Z
                Clear-Variable dyrl_bas_Z
            }
        }
    }
    Remove-Variable dyrl_hik*
    Return
}
if( $CALLER ){
    if( $dyrl_bas_NOPROTO ){
        $dyrl_bas_v = $dyrl_bas_NOPROTO
    }
    elseif($PROTOCULTURE){
        $dyrl_bas_v = $PROTOCULTURE
    }
    if($dyrl_bas_v){
    peekCert $dyrl_bas_v
    }
    else{
        Write-Host -f CYAN '
    ERROR! No filename given...'
    }
    Write-Host -f GREEN "
    Hit ENTER to return to $CALLER.
    "
    Read-Host
    Return
}


#################################
## Remove old signatures
#################################
function unSign($spath){
    ## Find the entire certificate block
    $CERTCONTENT = '(?ms)^().*?\r?\n()'

    Set-Content -Path $spath -Value ((gc -raw $spath) -replace $CERTCONTENT, '$1$2')
    Set-Content -Path $spath -Value ((gc -raw $spath) -replace("",""))
    Set-Content -Path $spath -Value ((gc -raw $spath) -replace("",""))

    if( Get-AuthenticodeSignature -FilePath $spath | where{$_.Status -eq 'NotSigned'} ){
        Write-Host -f YELLOW " Signature has been removed! Re-signing with your cert..."
        slp 2
    }
    else{
        if($vf19_MPOD["log"]){  ## If running in MACROSS, log the fails
            errLog 'ERROR' "$USR/BASARA" "Remove-signature failed for $spath"
        }
        Write-Host -f CYAN " Whoops! Something went wrong. Better check that script, sorry!
        "
        Write-Host -f GREEN " Running " -NoNewline;
            Write-Host -f YELLOW "Get-AuthenticodeSignature -FilePath <your file>" -NoNewline;
                Write-Host -f GREEN " returned a SIGNED value.
                "
        Write-Host -f GREEN " Hit ENTER to exit and prevent the apocalypse..."
        Read-Host
        Remove-Variable dyrl_bas_* -Scope Global
        if( $CALLHOLD ){
            Return
        }
        else{
            Exit
        }
    }
}

#################################
## Use the provided info to sign the code
#################################
function certSign($spath,$cert){
    Set-AuthenticodeSignature -FilePath $spath -Certificate $cert
    Write-Host "
    "
    if( (Get-AuthenticodeSignature -FilePath $spath).status -eq 'Valid' ){
        Write-Host -f GREEN " Success! Do you need to sign another (" -NoNewline;
            Write-Host -f YELLOW "y" -NoNewline;
                Write-Host -f GREEN "/" -NoNewline;
                    Write-Host -f YELLOW "n" -NoNewline;
                        Write-Host -f GREEN ")?  " -NoNewline;
    }
    else{
        if($vf19_MPOD["log"]){  ## If running in MACROSS, log the fails
            errLog 'ERROR' "$USR/BASARA" "Failed to sign $spath"
        }
        Write-Host -f CYAN " Certificate signing failed! " -NoNewline;
            Write-Host -f GREEN " Do you want to try again?  " -NoNewline;
    }
     

}

<#
## WORK IN PROGRESS -- sign python code
function pySign($spath,$cert){
    $pathToScript = "C:\path\to\your_script.py"
    $timestampServer = "http://local.ntp.server"  # Example timestamp server
    $certificateThumbprint = "YOUR_CERTIFICATE_THUMBPRINT"
    if(Test-Path 'C:\Program Files (x86)\Windows Kits\10\bin\<SDKVersion>\x64\SignTool.exe'){
        ST = 'C:\Program Files (x86)\Windows Kits\10\bin\<SDKVersion>\x64\SignTool.exe'
    }
    else{
        ST = $(Get-ChildItem -Path "C:\Program Files (x86)\Windows Kits" -Recurse -Filter "SignTool.exe")
    }
    try{
        SignTool sign /tr $timestampServer /td SHA256 /fd SHA256 /a /sm /s "My" /n "Your Certificate Name" /t $timestampServer $pathToScript
    }
    catch{
        ST sign /tr $timestampServer /td SHA256 /fd SHA256 /a /sm /s "My" /n "Your Certificate Name" /t $timestampServer $pathToScript
    }
        
}#>





## Default vars
$ErrorActionPreference = 'SilentlyContinue'
$dyrl_bas_DEFPATH = "$PSScriptRoot\.\"  ## This script can be used with or without MACROSS

## Valid inputs
$dyrl_bas_FNMATCH = [regex]"^[a-zA-Z0-9_.]*\.[a-z0-9]+$"
$dyrl_bas_YN = [regex]"^(y|n)"

## Let's kick it off!
$dyrl_bas_Z = $null


splashPage


#################
## MAIN SCRIPT ##
#################
while ( $dyrl_bas_Z -ne 'c' ){
    Write-Host -f GREEN "
    Write the script name if it is in the the same folder as BASARA, OR hit ENTER to
    select your file, OR type 'c' to cancel:
        
    >  " -NoNewline;
    $dyrl_bas_Z = Read-Host

    if( $dyrl_bas_Z -ne 'c' ){
        if( $dyrl_bas_Z -eq '' ){
            $dyrl_bas_SPATH = getFile
            if($dyrl_bas_SPATH = ''){
                Write-Host -f CYAN '    Action cancelled...'
                slp 2
                Exit
            }
        }
        elseif( $dyrl_bas_Z -Match $dyrl_bas_FNMATCH ){
            $dyrl_bas_SPATH = "$dyrl_bas_DEFPATH\$dyrl_bas_Z"
        }
    }
    else{
        Exit
    }

    if( (Test-Path -Path "$dyrl_bas_SPATH") ){
        ## Get the signing cert!
        $dyrl_bas_CERT = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert


        ## Check to see if code is already signed
        if( Get-AuthenticodeSignature -FilePath $dyrl_bas_SPATH | where{$_.Status -eq 'Valid'} ){
            $dyrl_bas_BSURE = $true
            while( $dyrl_bas_Z -notMatch $dyrl_bas_YN ){
                Write-Host ""
                Write-Host -f CYAN " Warning! " -NoNewline;
                Write-Host -f GREEN "The file you entered is already signed!
                "
                Write-Host -f GREEN " Overwrite the existing cert (y/n)?  " -NoNewline;
                $dyrl_bas_Z = Read-Host
                $dyrl_bas_A = $true
            }
        }
        else{
            $dyrl_bas_Z = 'y'
        }


        if( $dyrl_bas_Z -eq 'y' ){
            if( $dyrl_bas_BSURE ){
                unSign $dyrl_bas_SPATH
            }

            certSign $dyrl_bas_SPATH $dyrl_bas_CERT
            $dyrl_bas_Z = Read-Host

        }


        if( ($dyrl_bas_Z -eq 'y') -or ($dyrl_bas_A) ){
            Clear-Variable -Force dyrl_bas_SPATH
            Clear-Variable -Force dyrl_bas_CERT
            Clear-Variable -Force dyrl_bas_Z
            Remove-Variable dyrl_bas_A -Scope Global
        }
        else{
            Remove-Variable dyrl_bas_* -Scope Global
            Exit
        }
    }
    else{
        Write-Host -f CYAN ' File not found!
        '
        Clear-Variable -Force dyrl_bas_SPATH
        Clear-Variable -Force dyrl_bas_CERT
        Clear-Variable -Force dyrl_bas_Z
    }
}



