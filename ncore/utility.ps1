## MACROSS shared utilities
## Do not modify or delete the checks below!
<#  Add your own defaults below here (see the readme!)  9rkd4mv
tblJFBTU2NyaXB0Um9vdFxyZXNvdXJjZXM=@@@exaaHR0cDovL3lvdXIud2ViLmZpbGUvZXhhbXBs
ZS50eHQ=@@@gbgJHZmMTlfVE9PTFNST09UXG5jb3JlXHB5X2NsYXNzZXNcZ2FyYmFnZV9pbw==@@@
nreaHR0cDovLzE5Mi4xNjguMTAwLjEwL3JlcG8v@@@geraHR0cHM6Ly95b3VyLmNhcmJvbmJsYWNr
c2VydmVyLmxvY2Fs
#>


## Change the message output for errors
function debugMacross(){
    splashPage
    $current = $ErrorActionPreference
    $e = @('SilentlyContinue','Continue','Inquire')

    while($z -notMatch "^(1|2|3)$"){
        Write-Host -f CYAN '
        ERROR DEBUGGING:
        (select 1-3, default is 1, current is ' -NoNewline;
        Write-Host -f YELLOW "$current" -NoNewline;
        Write-Host -f CYAN ')
            1. Suppress error messages
            2. Display errors but continue execution
            3. Display errors and ask whether to continue

            > ' -NoNewline;

        $z = Read-Host
    }

    $z = $z - 1
    $Script:ErrorActionPreference = $e[$z]
    $new = $ErrorActionPreference
    splashPage
    Write-Host -f CYAN '
    Error messaging is now set to ' -NoNewline;
    Write-Host -f YELLOW "$new" -NoNewline;
    Write-Host -f CYAN '.'
    slp 2
}


## Make sure the GBIO folder is cleaned out
function cleanGBIO(){
    ## Make sure the GBIO directory is clean
    if(Get-ChildItem "$vf19_GBIO\*.eod"){
        Get-ChildItem "$vf19_GBIO\*.eod" | %{
            try{
                Remove-Item -Force $_
            }
            catch{
                Write-Host -CYAN " Could not delete $_ !"
            }
        }
    }
}

## Pause the console so user can run their own commands
function runSomething(){
    cls
    Write-Host "
    "
    Write-Host -f GREEN "  Pausing MACROSS: type " -NoNewline;
        Write-Host -f YELLOW "exit" -NoNewline;
            Write-Host -f GREEN " to close your session and return to"
    Write-Host -f GREEN "  the tools menu.
    "

    powershell.exe

    Return
}

## Simple deobfuscation for investigating events
##  Call with a '1' to encode strings to base64
function decodeSomething($1){
    cls
    if($1 -eq 1){
        Write-Host -f GREEN "
        Enter a plaintext string you want to ENCODE to Base64:
        
        > " -NoNewline;
        $Z = Read-Host
        getThis $Z 0
    }
    else{
        Write-Host -f GREEN "
        Enter a string beginning with '0x' if decoding a hexadecimal value, otherwise
        enter a Base64 string to decode:

        > " -NoNewline; $Z = Read-Host

        if( $Z -Match "^0x" ){
            $Z = $Z -replace "^0x",''
            getThis $Z 1
        }
        else{
            getThis $Z
        }
    }

    Write-Host -f YELLOW "
    $vf19_READ
    "
    if($1 -eq 1){
        Write-Host -f GREEN '
        Encode another? ' -NoNewline; $Z = Read-Host
        if( $Z -Match "^y" ){
            decodeSomething 1
        }
    }
    else{
        Write-Host -f GREEN '
        Decode another? ' -NoNewline; $Z = Read-Host
        if( $Z -Match "^y" ){
            decodeSomething
        }
    }
}

## Run this to get a quick version check of a tool
## $1 is the name of the script w/o the extension
function disVer($1){
    $Global:VER = Get-Content "$vf19_TOOLSROOT\nmods\$1.ps1" | Select -Index 1
    $Global:VER = $VER -replace "^#_ver ",''
}


## Let user choose a file for whatever the script needs
##  Opens dialog to user's desktop where they can navigate to wherever their file is
##  You can pass an optional filter to only show specific filetypes
##  Usage:    $var = getFile  'Text Document (.txt)| *.txt'
##                               ^^ optional value that limits visible files to ".txt" only
Function getFile($filter)
{  
    [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) |
        Out-Null

    $o = New-Object System.Windows.Forms.OpenFileDialog
    $o.initialDirectory = $vf19_DEFAULTPATH   ## Default location is the user's desktop
    if($filter){
        $o.filter = $filter
    }
    else{
        $o.filter = “All files (*.*)| *.*”
    }
    $o.ShowDialog() | Out-Null
    $o.filename
}


## When a python script calls a powershell script to find or eval something, it currently
## can't read the results straight from powershell without extra coding. This function
## lets powershell write results to a file in the directory "MACROSS\ncore\py_classes\garbage_io"
## so that the calling python script can read and ingest the contents of that file more
## easily. Eventually the mcdefs library will contain a method to better handle this.
##
##  REQUIRED:  Your script name the file to write to ($filenm), as well as the value
##  you want written to that file($val1). Example usage:
##
##                    if( $python_called ){
##
##                       # Write the location of the powershell script's normal output
##                       pyCross 'myscriptname' $RESULTFILE
##
##                       # Or you can just write all the results the script found
##                       foreach($line in $eval){
##                          pyCross 'myscriptname' $line
##                       }
##
##                    }
##
##  The file outputs are written with the extension "*.eod" to aid in accurate cleanup
##  (see the "cleanGBIO" function elsewhere in this file).
function pyCross(){
    param(
        [Parameter(Mandatory)]
        [string]$filenm,
        [Parameter(Mandatory)]
        $val1
    )

    $filenm = $filenm + '.eod'  ## Append custom extension

    $val1 | Out-File -FilePath "$vf19_GBIO\$filenm" -Encoding UTF8 -Append  ## Write results to file
    
}


<## Delete stale reports generated by various tools
  $1 = the calling tool's filepath to reports, $2 is the tool name that generated the reports.
  Be kind! Design your scripts to write reports to a specific directory, so
  when calling this function you aren't offering users the option to mistakenly
  wipe out their desktop or documents folders...#>
function houseKeeping($1,$2){
    $reports = $1
    function listFiles(){
        $Script:fpath = (Get-ChildItem -File -Path "$reports" )
        $Script:countf = ($fpath.count)
        $Script:a = @()
        $b = 0
        if(($countf).count -gt 0){
        Write-Host -f YELLOW "       EXISTING $2 REPORTS
    
        "
        $fpath | ForEach-Object{  ## Create a list of the filenames to display onscreen
            $b++
            $n = $_.Name
            $m = $_.LastWriteTime
            $Script:a += $n
            Write-Host "   $b. $n" -NoNewline;  ## display the filename and its last modified time
            Write-Host ":  $m"
        }
        Write-Host '
        '
        Write-Host -f GREEN "  Select a file to delete, 'a' to delete all of them,  "
        Write-Host -f GREEN "  or 's' to skip:  " -NoNewline;
        }
    }
    function rmFiles($del){
        $reportdir = $reports -replace "\\\*.[a-z0-9*]+$",''  ## If wildcards were sent in $1, remove them to get the report directory
        Remove-Item -Path "$reportdir\$del"
        if( Test-Path -Path "$reportdir\$del" ){
            Write-Host -f CYAN "  ERROR! File was not deleted! Maybe directory is read-only?"
        }
        else{
            Write-Host -f YELLOW "  $del" -NoNewline;
            Write-Host -f GREEN ' was deleted...'
            if($countf){
                $Script:countf = $countf - 1
                if($countf -eq 0){
                    $Z = 9999
                }
            }
        }
    }
    
    Write-Host ''
    while( $Z -notMatch "^[0-9]+$" ){
        listFiles
        $Z = Read-Host
        Write-Host ''
        if( $Z -eq 's' ){    ##  Setting to 9999 skips the final task of selecting files to delete
            $Z = 9999
        }
        elseif( $Z -eq 'a' ){  ## Delete all files in the provided directory if user selects 'a'
            $Z = 9999
            $fpath |
                Foreach-Object{
                    $dn = $_.Name
                    Write-Host -f CYAN "  Deleting $dn...."
                    rmFiles $dn
                    slp 1
                }
        }
    
     
        if($Z -ne 9999){
            $Z = $Z - 1
            $fpath |
                Foreach-Object{
                    if($a[$Z] -eq $_.Name){
                        $dn = $_.Name
                        Write-Host -f CYAN "  Deleting $dn...."
                        rmFiles $dn
                        slp 1 
                    }
            }
            if($countf -gt 0){
                Write-Host -f GREEN '
                Delete another? (y/n) ' -NoNewline;
                $Z = Read-Host
                if($Z -eq 'y'){
                    Remove-Variable Z
                }
                else{
                    $Z = 9999
                }
            }
        }
    }

    Write-Host ''
    slp  1

    Remove-Variable -Force fpath,a
}
