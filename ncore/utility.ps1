## MACROSS shared utilities
## Do not modify or delete the checks below!
<#  Add your own defaults below here (see the readme!)  9rkd4mv
tblJFBTU2NyaXB0Um9vdFxyZXNvdXJjZXM=@@@exaaHR0cDovL3lvdXIud2ViLmZpbGUvZXhhbXBs
ZS50eHQ=@@@gbgJHZmMTlfVE9PTFNST09UXG5jb3JlXHB5X2NsYXNzZXNcZ2FyYmFnZV9pbw==@@@
nreJGRhc2hfVE9PTFNESVI=@@@geraHR0cHM6Ly95b3VyLmNhcmJvbmJsYWNr
c2VydmVyLmxvY2Fs
#>

<#
    MPOD ALERT!!
    The above lines 3-7 contain base64 encoded strings separated with '@@@'.
    The first three letters of each string are stripped by the function "startUp"
    located in the display.ps1 script (it is the first core script to run, since it
    has to know where everything is so it can build the main menu). Those three-letter
    strings are used as index keys in an array called $vf19_MPOD, and each base64 is
    the value for those keys.

    These have been stored here as a self-contained example of setting global
    default variables used by MACROSS and its tools, but I recommend you store
    these in a location outside of MACROSS that is only accessible by you or
    your SOC.
    
    For example, the very first index, 'tbl', contains the encoded location of a
    text file in the MACROSS resources folder, while the last index in the list,
    'ger', contains the encoded URL of a fictional Carbon Black server. These can
    be retrieved by your custom scripts by using the "getThis" function (located
    in the validation.ps1 script), which writes decoded plaintext to $vf19_READ:

        getThis $vf19_MPOD['tbl'] 
        $list_of_events = $vf19_READ   ## Now your script can read this text file
        getThis $vf19_MPOD['ger']
        $edr = $vf19_READ              ## Now your script knows where to access an API

    If you have a more secure place to store these types of common values, I recommend you
    write them all to a text file or json, and then modify the "startUp" function in
    display.ps1 to look at that file instead of this one in order to build the $vf19_MPOD
    array that all the scripts will use to find stuff.

#>

<# Unlisted MACROSS menu option --
## Change the message output for errors so you can 
## troubleshoot scripts. Type 'debug' in the MACROSS
## menu to call this function; enter a command to test your scripts or
## functions. Example:
        debug getThis $dyrl_MYVARIABLE; $vf19_READ
        ^^ This will decode some base64 value and display it onscreen for you
        debug
        ^^ This will just open the menu that lets you choose whether to show or
            hide error messages
#>
function debugMacross($1){
    splashPage
    Write-Host '
    '
    if($1){
        iex "$1"
        Write-Host -f GREEN "
        Type another command for testing (don't use 'debug'), or hit ENTER
        to exit debugging:
        "
        $cmd = Read-Host
        if($cmd -ne ''){
            debugMacross $cmd
        }
    }
    else{
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
}


function runSomething(){
    cls
    Write-Host '
    '
    Write-Host -f GREEN '  Pausing MACROSS: type ' -NoNewline;
        Write-Host -f YELLOW 'exit' -NoNewline;
            Write-Host -f GREEN ' to close your session and return to'
    Write-Host -f GREEN '  the tools menu.

    '

    powershell.exe  ## Start new session outside of MACROSS

    Return
}

## Make sure the GBIO folder is cleaned out:
## this is where .eod files are written so python can 
## read powershell outputs
function cleanGBIO(){
    ## Make sure the GBIO directory is clean
    if(Get-ChildItem "$vf19_GBIO\*.eod"){
        Get-ChildItem "$vf19_GBIO\*.eod" | %{
            try{
                Remove-Item -Force $_
            }
            catch{
                $exc = $_ + '!'
                Write-Host -CYAN " Could not delete $exc"
            }
        }
    }
}


## Admin/dev function: type 'defs' into MACROSS' main menu.
## It will accept super-long strings and wrap them into a block of 100 char lines for you to then
## copy-pasta into whatever project you're working on. This is purely a cosmetic preference; 
## sometimes I don't want lines of code (like base64) that stretch longer than my screen.
function formatDefaults(){
    Write-Host -f GREEN '  Paste the string to format: ' -NoNewline;
    $z = Read-Host
    Write-Host '
    '
    $z | ForEach-Object {
        $line = $_
        for($i = 0; $i -lt $line.Length; $i += 100){
            $length = [Math]::Min(100, $line.Length - $i)
            $line.SubString($i, $length)
        }
    }
    Read-Host
}

## Decode base64 or hex string one-offs
function decodeSomething(){
    Write-Host -f GREEN "
    Enter 'hex' or 'b64' followed by your encoded string (hex strings can contain '0x'),
    or 'c' to cancel:
    >  " -NoNewline; $Z = Read-Host
    if($Z -Match "^hex"){
        $Z = $Z -replace "^hex ?",''
        getThis $Z 1
    }
    elseif($Z -Match "^b64"){
        $Z = $Z -replace "^b64 ?",''
        getThis $Z
    }
    elseif($Z -eq 'c'){
        Remove-Variable Z
    }
    else{
        Remove-Variable Z
        Write-Host -f CYAN '
        You need to specify "b64" or "hex".'
        decodeSomething
    }

    if($Z){
        Write-Host -f GREEN "
        Decoded: " -NoNewline;
        Write-Host " $vf19_READ
        "
        Write-Host -f GREEN '    Decode another? ' -NoNewline;
        $Z = Read-Host
        if($Z -Match "^y"){
            decodeSomething
        }
    }
        
}



## When a python script calls a powershell script to find or eval something, it currently
## can't read the results straight from powershell without extra coding. This function
## lets powershell write results to a file in the directory "MACROSS\ncore\py_classes\garbage_io"
## so that the calling python script can read and ingest the contents of that file more
## easily. Eventually the mcdefs library will contain a method to better handle this.
##
##  REQUIRED:  Your script name as the file to write to ($filenm), as well as the value
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
##  ...and then your python script can do whatever with it:
##
##                  open('PATH\\myscriptname.eod').read()
##
##  The file outputs are written with the extension "*.eod" to aid in accurate cleanup
##  (see the "cleanGBIO" function elsewhere in this file).
function pyCross(){
    Param(
        [Parameter(Mandatory)]
        [string]$filenm,
        [Parameter(Mandatory)]
        $val1
    )

    $filenm = $filenm + '.eod'  ## Append custom extension

    $val1 | Out-File -FilePath "$vf19_GBIO\$filenm" -Encoding UTF8 -Append  ## Write results to file
    
}


## Get a full listing of all available tools and their attributes
## Call from the main menu with debug:
##          debug TL
function TL(){
    $vf19_ATTS | %{
        $k = $vf19_ATTS.keys
        $vf19_ATTS[$k].toolInfo()
    }
}


## Select a file and extract ASCII strings, because Windows sux and doesn't have the
## strings utility by default
function stringz(){
    $f = getFile
    $n = 0
    if($f -ne ''){
        Get-Content $f | %{
            if( !($_ -cMatch "[^\x00-\x7F]")){
                $n++
                Write-Host "  Extracting line $n to stringz.txt..."
                $_ | Out-File "$vf19_DEFAULTPATH\stringz.txt" -Append
            }
        }
    }
    Get-Content "$vf19_DEFAULTPATH\stringz.txt"
    Write-Host "
    Do you want to delete $vf19_DEFAULTPATH\stringz.txt? " -NoNewline;
    $z = Read-Host
    if( $z -eq 'y'){
        Remove-Item -Path "$vf19_DEFAULTPATH\stringz.txt"
    }
}


## Get the hash of a file; must pass the filepath and hashing method
##  Usage:  $var = getHash $filepath 'md5'
##                       OR
##          $var = getHash $filepath 'sha256'
function getHash(){
    Param(
        [Parameter(Mandatory)]
        [string]$file,
        [Parameter(Mandatory)]
        [string]$alg
    )

    $type = @('md5','sha256')

    if( Test-Path -Path $file ){
        if($alg -in $type){
            $h = CertUtil -hashfile $file $alg
        }
    }
    Return $h
}


## Output tool values to spreadsheet on user's desktop;
## TO-DO: need to add instructions for grouping by rows or columns using $4
<# 

    This is very simplistic at the moment; the goal is to eventually make more useful spreadsheets when
    simple CSV files aren't good enough.


    $1 = (req'd) the name of the output file
    $2 = (req'd) output values, comma-separated
    $3 = (optional) the starting row to write to
    $4 = (optional) column values OR the number of columns you are writing across

    If only 2 parameters are sent, this function will separate the values in param $2 by removing the
    commas, and write each value as a list into column A.

    If you're adding values to an existing sheet, the $3 parameter lets you specify which row to start in. For
    example, if you know the next empty row is 200, send 200 as a 3rd parameter.

    If you send a NUMBER as the $4 parameter, it tells this function how many values to write horizontally from
    parameter $2, before it shifts to the next row and continues writing cells.

    If you send comma-separated strings as param $4, this function will write those values as the column headers
    in the worksheet, and then begin writing the values from param $2 into the appropriate row/columns.

    Usage:

            sheetResults 'myoutput' 'host 1,host 2,host 3,host 4'

    The above example will write out the hosts in a simple list to 'myoutput.xlsx'

            sheetResults 'myoutput' 'host 1,windows,11,192.168.10.10,host2,,,192.168.10.11' 1 'HOST,OS,VER,IP'

    The above will create (or open) myoutput.xlsx, and then writes 'HOST' to cell A1, 'OS' to B1, 'VER' to C1, and
    'IP' to D1.

    Next it will go through all the comma-separated values in param 2, writing values into the next row until it reaches
    column D, then jump to the next row back at column A:


                         A         B       C         D
            row 1      HOST       OS      VER        IP
            row 2      host 1   windows   11    192.168.10.10
            row 3      host 2                   192.168.10.11


    Make sure your script is sending your report values to param $2 IN ORDER, otherwise they'll get written to the wrong
    cells!

    Alternately, you could set param $4 to '4' if you don't need to label the columns:

            sheetResults 'myoutput' 'host 1,windows,11,192.168.10.10,host2,,,192.168.10.11' 1 4

                        A         B       C         D
            row 1      host 1   windows   11    192.168.10.10
            row 2      host 2                   192.168.10.11
    


#>
function sheetResults(){

    Param(
        [Parameter(Mandatory=$true)]
        [string]$1,
        [Parameter(Mandatory=$true)]
        [string]$2,
        [int]$3,
        $4
    )


    $r = 1  ## Starting row
    $c = 1  ## Starting column

    if( $3 ){
        $r = $3
    }
    
    if($4){
        if($4 -Match "[a-z]"){
            $val2 = $4 -Split(',')
            $val2c = $(($val2).count)
        }
        else{
            $val2c = $4
        }
    }

    $val1 = $2 -Split(',')  ## Scripts should be sending comma-separated values


    # Add reference to the Microsoft Excel assembly
    if( $MSXL){
        Add-Type -AssemblyName Microsoft.Office.Interop.Excel
    }
    else{
        Write-Host -f CYAN '
    Cannot write to file... excel is not installed!
        '
        slp 3
        Return
    }

    
    # Create a new Excel application
    $excel = New-Object -ComObject Excel.Application

    # Make Excel visible (optional)
    $excel.Visible = $true

    # Create a new workbook
    if(Test-Path "$vf19_DEFAULTPATH\$1.xlsx"){
        $workbook = $excel.Workbooks.Open("$vf19_DEFAULTPATH\$1.xlsx")
    }
    else{
        $workbook = $excel.Workbooks.Add()
    }

    # Select the first worksheet
    $worksheet = $workbook.Worksheets.Item(1)


    # Write values to cells; if no $4 values were passed, just write $val1 as a list in column A
    if($4){
        
        function columnVals($rr,$cc,$count){
            Foreach($v1 in $val1){
                $worksheet.Cells.Item($rr, $cc).Value2 = $v1  ## Write value to cell
                $cc++                                         ## shift to the next column
                $count++                                      ## track which column is current
                if($count -gt $val2c){                        ## stop shifting if all columns have been written
                    $rr++                                     ## shift to the next row
                    $cc = 1                                   ## go back to column A
                    $count = 1                                ## reset column tracker
                }
            }
        }


        if($val2){
            Foreach($v2 in $val2){
                $worksheet.Cells.Item($r, $c).Value2 = $v2  ## Write all the initial column values in row 1
                $c++                                        ## shift to next column
            }
            $c = 1                                          ## go back to column A
            $r++                                            ## shift to next row
            
            columnVals $r $c 1
        }
        else{
            columnVals $r 1 1
        }

    }
    else{
        Foreach($v1 in $val1){
            $worksheet.Cells.Item($r, $c).Value2 = $v1     ## Write values as a list in column A
            $r++
        }
    }
    

    #$worksheet.Cells.Item(4, 3).Value2 = 'TEST'
    #$worksheet.Cells.Item(4, 4).Value2 = 'SUCCESSFUL'



    # Save the workbook (optional)
    if( Test-Path "$vf19_DEFAULTPATH\$1.xlsx" ){
        $workbook.Save()
    }
    else{
        $workbook.SaveAs("$vf19_DEFAULTPATH\$1.xlsx")
    }

    # Close Excel
    #$excel.Quit()

    # Clean up COM objects
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}




## This func opens a dialog window so the user can specify a filepath to whatever.
## Param $filter is optional, allows you to specify a filetype to select; default is
## to show all files for selection
##    Example usage: $file_to_read = getFile 'Text Document (.txt)|*.txt'
##                                   ^^ only shows user txt files to select
function getFile($filter){
    [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) | Out-Null

    if($filter -eq 'folder'){
        $f = New-Object System.Windows.Forms.FolderBrowserDialog
    }
    else{
        $o = New-Object System.Windows.Forms.OpenFileDialog
    }
    
    if($f){
        $f.rootfolder = $wherever
        $f.Description = "Select a folder"
        $f.SelectedPath = 'C:\'

        if($f.ShowDialog() -eq "OK")
        {
            Return $f.SelectedPath
        }
        
    }
    else{
        #$o.initialDirectory = $vf19_DEFAULTPATH  ## this got annoying for selecting multiple files
        $o.InitialDirectory = $wherever
        if($filter){
            $o.filter = $filter
        }
        else{
            $o.filter = “All files (*.*)| *.*”
        }
        $o.ShowDialog() | Out-Null
        $o.filename
    }

}





<# 
   Delete stale reports generated by various tools:
   Users can choose to delete some, all, or none of the files in the directory you pass to
   this function. Make sure not to pass generic folders like 'Desktop' or 'Documents', giving
   users the opportunity to accidentally delete all their stuff!

        $1 = the filepath determined by the tool that calls this function,
        $2 = the tool name
  
        Example usage:
            houseKeeping "$filepath\*txt" 'MyScript'
#>
function houseKeeping(){
    Param(
        [Parameter(Mandatory=$true)]
        [string]$1,
        [Parameter(Mandatory=$true)]
        [string]$2
    )
    $reports = $1
    function listFiles(){
        $Script:fpath = (Get-ChildItem -File -Path "$reports")
        $Script:fcount = $fpath.count
        $Script:flist = @()
        $b = 0
        Write-Host -f YELLOW "       EXISTING $2 REPORTS
    
        "
        $fpath | ForEach-Object{  ## Create a list of the filenames to display onscreen
            $b++
            $n = $_.Name
            $m = $_.LastWriteTime
            $Script:flist += $n
            Write-Host "   $b. $n" -NoNewline;  ## display the filename and its last modified time
            Write-Host ":  $m"
        }
        Write-Host '
        '
        Write-Host -f GREEN "  Select a file to delete, 'a' to delete all of them,  "
        Write-Host -f GREEN "  or 's' to skip:  " -NoNewline;
    }
    function rmFiles($del){
        $reportdir = $reports -replace "\*.*$",''
        #Write-Host 'deleting ' -NoNewline; write-host "$reportdir\$del"  # uncomment for debugging the occasional derp
        Remove-Item -Force -Path "$reportdir\$del"
        if(Test-Path -Path "$reportdir\$del"){
            Write-Host -f CYAN '
            ...Delete action failed!
            '
        }
        else{
            $Script:fcount = $fcount - 1
        }
    }

    $Z = '';
    
    ''
    while( $Z -notMatch "^[0-9]+$" ){
        while($Z -eq ''){
            listFiles
            $Z = Read-Host
        }
        ''
        slp 1
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
                    if($flist[$Z] -eq $_.Name){
                        $dn = $_.Name
                        Write-Host -f CYAN "  Deleting $dn...."
                        rmFiles $dn
                        slp 1 
                    }
            }
            if( $fcount -gt 0 ){
                Write-Host -f GREEN '
                Delete another? (y/n) ' -NoNewline;
                $Z = Read-Host
                if($Z -eq 'y'){
                    $Z = ''
                }
                else{
                    $Script:fcount = 0
                    $Z = 9999
                }
            }
        }
    }

    ''
    slp 1
    
    Remove-Variable -Force fpath,flist
}



