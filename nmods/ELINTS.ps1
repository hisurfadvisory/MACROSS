#_wut String-search documents
#_ver 3.0

<#
    Author: HiSurfAdvisory
    ELINT-SEEKER (Automated String Search)

    Uses Get-Content to search files for user-supplied keywords;
    automatically uncompresses MS Office files to scan XML files.

    Can work with single files, or a list of files from a .txt that
    was generated beforehand.


#>


function splashPage(){
    cls
    $b = 'ICAgICDilojilojilojilojilojilojilojilZfilojilojilZcgICAgIOKWiOKWiOKVl+KWiOKWiOKWiOKVlyAgIOKWiOKWiOKVl+KWiOKWiOKWiOKW
    iOKWiOKWiOKWiOKWiOKVlwogICAgIOKWiOKWiOKVlOKVkOKVkOKVkOKVkOKVneKWiOKWiOKVkSAgICAg4paI4paI4pWR4paI4paI4paI4paI4pWXICDilojilo
    jilZHilZrilZDilZDilojilojilZTilZDilZDilZ0KICAgICDilojilojilojilojilojilZcgIOKWiOKWiOKVkSAgICAg4paI4paI4pWR4paI4paI4pWU4paI
    4paI4pWXIOKWiOKWiOKVkSAgIOKWiOKWiOKVkSAgIAogICAgIOKWiOKWiOKVlOKVkOKVkOKVnSAg4paI4paI4pWRICAgICDilojilojilZHilojilojilZHilZ
    rilojilojilZfilojilojilZEgICDilojilojilZEgICAKICAgICDilojilojilojilojilojilojilojilZfilojilojilojilojilojilojilojilZfiloji
    lojilZHilojilojilZEg4pWa4paI4paI4paI4paI4pWRICAg4paI4paI4pWRICAgCiAgICAg4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWQ4pWQ4p
    WQ4pWQ4pWQ4pWd4pWa4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZDilZDilZ0gICDilZrilZDilZ0='

    getThis $b
    Write-Host '
    '
    Write-Host -f YELLOW "$vf19_READ
    
    "

    Write-Host -f YELLOW '   ============================================================================'
    Write-Host -f YELLOW '                    ELINT-SEEKER automated string-search'


}

function callSplash(){
    cls
    
    Write-Host '
    '
    $b = 'ICAgICAgICAgICAgICAgICAgICAsLuKVkF4iYCAgICAgIOKWhOKWiOKWiOKWiOKWiOKVnCJgIuKVmSrilZDilZMsICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgIMKrwqwuXi7ijJDilJheIiIgICAgICLiloTilojilojilojilojilojiloDilIAgIC
    AgICAsLCwgwrLilpLilojilpPilZzCsuKVlSAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgIFwidyAgICAgICAgIOKWhO
    KWiOKWiOKWiOKWiOKWiOKWiOKWjCAgICAgICAgICAgYCAsIOKWk+KWk1LilpNMICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgIC
    AgICAgIGBefi4g4pSAfjpe4paI4paI4paI4paI4paI4paI4paI4paIICwgICAgIC0gYCAs4paE4paE4paI4paI4paI4paI4paI4paI4pWbICAgIC
    AgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgYCDilZrilpPilojiloTiloTiloTiloTiloTiloTiloTiloTiloRt4p
    aE4paE4paI4paI4paI4paI4paI4paI4paI4paE4paE4paE4paELCIiXirilaniloA9Li4sLCAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgIC
    AgICAgICAgICAs4pWWICzilpPilpDilojilojilogsLOKWk+KWgCAgYCzilZPilpPiloAg4paT4pWi4pWi4pWT4paSTeKWkuKWk+KWiOKWiOKWiO
    KWiOKWiOKWiOKWgCBgYGAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgIGDDkeKVnOKWk+KWiOKWgGfilpPilaLilpLCq+
    KWkiAgICzilZMs4paQaGfilpPilojilojilpLilZbiloDilpPilojilojilojilojilojilpNB4paA4paA4oie4pWlwqwsLOKVk+KVk+KVkywsIC
    AgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICzilZTilpPilazilojilpPilpPilogg4pWZ4paEIOKWk+KWk+KVqeKWkuKWk+KWiOKWiO
    KWiOKWiOKWiOKWk+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWgOKWgOKWhCws4pWTZ+KVqeKWk+KWk+KWjGrilpPilpPilojilojilojilowgIC
    AgICAgICAKICAgICAgICAgICAgICAgICAgICDDp+KVrOKWk+KWk+KWk+KWiOKWiOKWiOKWkyDilIzilZDiloDiloDiloDiloDiloDilojilojilo
    jilojilpPilpPilojilojilojilojiloDiloDilpPilojilpPilpPilpPilojilojilpNgLCwi4pWpw4XilojilojilojilpPilpPilojiloggIC
    AgICAgICAgCiAgICAgICAgICAgICAgICAgIF7iloTilojilojilpPilpPilpPilojiloggLCziloTDpuKWhOKWhOKWhOKWhCwgICAgIOKWhM+E4p
    aQ4paI4paM4pWTw6cgIGBgICAgfizilIBgYGAgYOKWgOKWgOKVq+KWgOKWiOKWgCAgICAgICAgICAKICAgICAgICAgICAgICAgIOKVk+KImuKWk+
    KVmeKWiOKWk+KWk+KVqeKWgGB24paT4paEIGBgYCwsO+KWhOKWhOKWhOKWhE3igb/iloDiloDilojilojilojilojilojilojilojiloht4paE4p
    aELDvilpLilIDilIAuLuKWgOKWgOKVkG3ilpNOICBeYCrilIA9dywgICAKICAgICAgICAgICAgICw04paI4paI4paI4paI4paA4paA4pWZIOKWiF
    3ilpDiloTilojiloDilZxg4oyQ4paE4paI4paI4paI4paI4paI4paI4paI4paM4paA4paMXeKVo+KWjCAgICDilpAgc+KVk+KWiOKWiOKWjOKWiC
    Ag4paA4paA4paT4paI4paI4paI4pWc4pWQ4pWk4pWQXuKUgOKUgOKUgD1v4paT4pSAIiAKICAgICAgICAgIMK/XiAgICDilJTiloAg4paMwrLilp
    LDkeKWgOKWgOKWgCDilZPOpiAs4pWT4pWo4paT4paI4paA4paI4paI4paI4paT4paI4paT4paE4paE4paI4paI4paI4paI4paI4paA4paA4paAIu
    KWgOKWgOKWgOKWgOKWgCIi4paAYCwg4paAICAgICBgIiJeIiAgICAgCiAgICAgICDijJAiICAgICAgICAs4paE4paIIOKVnOKVnCAgIMOW4pWo4p
    aT4paQ4paM4paE4paMYCwgICrilojilpPilojiloDiloDiloAiImAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgIC4iICAgIC
    As4pWTZ0Qsw5HilZwgICAgICAgICDilJQuICAgIuKWk+KWk+KWiOKVneKWhOKVmeKWiCwgICAsICAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAKICDilZMsLOKVk+KVpcOmSF4iICAgICAgICAgICAgICAgICAgfuKVmU53WyAg4paQ4paE4paI4paM4paMIiriiaHilpAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIiAg4pWj4paT4paI4paT4paI4paM4paMIC
    AgICBgKuKVkCwgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg4paM4paT4p
    aT4paI4paMIGAqbX4sICAgIGAi4pWQ4pWVICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICDilpEgIOKWkFsgICBgICAgICAgYF7ilKzilZzilaUsICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAg4paRICBqWyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICBgICAgzpMgICA='

    $c = getThis $b
    Write-Host -f YELLOW "$c
    "
    Write-Host -f YELLOW '   ============================================================================'
    Write-Host -f YELLOW '                    ELINT-SEEKER automated string-search'
}


if( $HELP ){
    cls
    callSplash
    Write-Host -f YELLOW "
    Named after the VE-1 Electronic Surveillance Valkyrie from the Macross series, ELINTS
    can perform a string search for words or phrases on any documents you specify. If you
    run ALTO first (the file-search script), you can generate a list of filepaths that
    ELINTS can use to scan automatically.
 
    All search results get recorded to a file called 'strings-found.txt' on your desktop.
    You don't need to delete or rename this file, ELINTS will append your new findings
    without modifying any previous search results.

    ELINTS can also copy any files that you find for further investigation. Found a python
    script with sus' strings in it, or a docx with sus' text? Copy it to your desktop and
    get forensicating!

    **Note this script assumes 'iTextSharp' is not available (it usually isn't on networks I
    investigate), so PDF scanning doesn't work very well. It will be a future improvement.
 
    Hit ENTER to return.
    "

    Read-Host
    Return
}


####################################
## Task complete notification
####################################
function completeMsg (){
    if( $dyrl_eli_norecord ){
        Write-Host ''
        Write-Host -f GREEN ' Hit ENTER to view ' -NoNewline;
        Write-Host -f YELLOW "$HOWMANY" -NoNewline;
        Write-Host -f GREEN ' string matches.'
        Read-Host
        cls
    }
    else{
        cls
        Write-Host ''
        Write-Host -f GREEN ' Search complete!'
        Write-Host -f YELLOW " $HOWMANY" -NoNewLine; 
        Write-Host -f GREEN  ' results for ' -NoNewLine; 
        Write-Host -f YELLOW "$dyrl_eli_TARGETS" -NoNewLine; 
        Write-Host -f GREEN ' have been appended to ' -NoNewLine; 
        Write-Host -f CYAN 'strings-found.txt' -NoNewLine; 
        Write-Host -f GREEN ' on your Desktop.
    
        '
    }
}

####################################
## Scan MS Office files for the user's keywords (requires the unzip util):
## $1 is the filepath, $2 is the keyword, $3 determines the scan mode,
## whether the scan quits after the first match or not -- if $3 is set
## to '1', it auto-quits. if set to '2', it lets the user choose
## when to quit.
##
## This function returns an array of string matches ($a), even if there is
## only one match.
####################################
function msOffice($1,$2,$3){
    Add-Type -Assembly System.IO.Compression.FileSystem        ## Need to uncompress MSOffice stuff
    Set-Variable -Name a,n -Option AllScope                    ## Let nested functions control these values
    $encode = "[^\x00-\x7F]"                                   ## Ignore non-ASCII blocks
    $n = 0                                                     ## Track number of matches PER FILE
    $a = @('')                                                 ## Only care if matches get written to $a

    if( $3 -eq 2 ){

        function go(){
            Write-Host -f GREEN '   Continue parsing this file (y/n)?  ' -NoNewline;
        }

        Write-Host -f GREEN " Type 'p' if you want to pause after every match, otherwise hit ENTER: " -NoNewline;
        $type = Read-Host

    }

    
    function grabXML($xml){
        $s = $xml.Open()
        $r = New-Object -TypeName System.IO.StreamReader($s)
        $t = $r.ReadToEnd()
        #$s.Close()
        #$r.Close()
        Return $t
    }
    

    #$str = $CONTENTS.Open()
    #$srdr = New-Object -TypeName System.IO.StreamReader($str)
    #$PLAINTEXT = $srdr.ReadToEnd()


    ## Scan the extracted plaintext for user's keywords
    function keyWordScan($pt){
        $pt |
            %{
                $L++
                $b = $_ -replace "<.*?>","`n" -split("`n")          ## Remove office/xml tags, then ignore empty lines
                $b | where{ $_ -ne ''} |
                %{
                    Write-Host -f CYAN "   SCANNING $dyrl_eli_DOCFILE"
                    if( $_ -cMatch $encode ){                             ## Ignore non-ASCII strings
                        Write-Host -f GREEN "    Searching line $L..."
                    }
                    else{
                        if( $dyrl_eli_CASE -eq 'y' ){   ## If the user specified case-sensitive
                            if($_ -cMatch "$2"){
                                $a += $_
                                $n++
                                $Script:dyrl_eli_CTR++
                                if( $3 -eq 1){
                                    Return
                                }
                                elseif($3 -eq 2){
                                    Write-Host "  $_
                                    "
                                    if( $type -eq 'p' ){
                                        go
                                        $Z = Read-Host
                                        if( $Z -eq 'n' ){
                                            Return
                                        }
                                    }
                                }
                            }
                        }
                        elseif($_ -Match "$2"){        ## If case doesn't matter
                                $a += $_
                                $n++
                                $Script:dyrl_eli_CTR++
                                if( $3 -eq 1){
                                    Return
                                }
                                elseif($3 -eq 2){
                                    Write-Host "  $_
                                    "
                                    if( $type -eq 'p' ){
                                        go
                                        $Z = Read-Host
                                        if( $Z -eq 'n' ){
                                            Return
                                        }
                                    }
                                }
                        }
                        else{
                            Write-Host -f YELLOW "   $dyrl_eli_DOCFILE" -NoNewline;
                            Write-Host ": line $L - NO MATCH"
                        }
                    }
                }  
            }
        }

    ##  Compressed office documents have multiple directories and files;
    ##  Only care about the XML containing document contents
    $doc = [IO.Compression.ZipFile]::OpenRead("$1")

    ## Excel contents are *typically* in "xl\worksheets\Sheet[0-9].xml" and ".\sharedStrings.xml" paths,
    ##  but we'll search the whole thing anyway
    if("$1" -Match "xlsx$"){
        $doc.Entries |
            Where-Object{
                $_.Name -Match "\.xml$"
            } |
                %{
                    $PLAINTEXT = grabXML $_
                    keyWordScan $PLAINTEXT
                }
    }
    ##  MS Word contents are in "word\Document.xml" path
    elseif("$1" -Match "docx$"){
        $CONTENTS = $doc.Entries |
        Where-Object{
            $_.Name -Match "Document\.xml$"
        }
        $PLAINTEXT = grabXML $CONTENTS
        keyWordScan $PLAINTEXT
    }


    Write-Host '
    '
    Write-Host -f YELLOW "   $dyrl_eli_DOCFILE" -NoNewline;
    Write-Host -f GREEN ": FOUND $n matches for '$2'
    "

    #$str.Close()
    #$srdr.Close()
    $doc.Dispose()


    if($a.length -gt 1){
        cls
        Return $a
    }
    else{
        Return $false
    }

}

####################################
## Draft a Get-Content query based on case
####################################
function setCase($1){
    if( $dyrl_eli_CASE -eq 'y' ){
        $a = Get-Content $1 | Select-String -CaseSensitive $dyrl_eli_TARGETS
    }
    else{
        $a = Get-Content $1 | Select-String $dyrl_eli_TARGETS
    }
    if( $a ){
        Return $a
    }
}


####################################
## Read the most recent search results and ask if the user wants to copy the files
####################################
function fileCopy(){
    $TEMPARRAYINDEX = 0
    $WRITE = $true

    foreach( $i in $dyrl_eli_SENSOR1 ){
        $TEMPARRAYINDEX++
        Write-Host -f YELLOW " $TEMPARRAYINDEX.  " -NoNewline;
            Write-Host "$i
            "
    }


    ## Scripts that can't copy may need more info from Carbon Black
    if( $dyrl_eli_nocopy ){
        while( ! $probe ){
            Write-host ''
            Write-Host -f GREEN ' Select a file # to research in GERWALK, or Hit ENTER to continue: ' -NoNewline;
            $mz = Read-Host

            if($mz -Match "[0-9]"){
                $mz = $mz - 1
                if( $dyrl_eli_SENSOR2[$mz] ){
                    $probe = $dyrl_eli_SENSOR2[$mz] -replace("^.*\\",'')
                    $Global:external_NM = $probe
                    ## Don't lose the original caller, if any
                    if( $CALLER ){
                        $dyrl_eli_callerhold = $CALLER
                    }
                    
                    collab 'GERWALK.ps1' 'ELINT' ## Carbon Black needs to know how to eval the $external_NM
                    Write-Host '

                    '
                    while($mz -notMatch "^(y|n)"){
                        Write-Host -f GREEN ' Do you want to search GERWALK for another file? ' -NoNewline;
                        $mz = Read-Host
                    }
                    if( $mz -Match "^y" ){
                        Clear-Variable -Force mz,probe
                        fileCopy
                    }
                    else{
                        $Global:CALLER = $dyrl_eli_callerhold  ## Reinstate the original caller
                    }
                    
                }
                else{
                    Write-Host -f CYAN ' ERROR! That is not a valid selection.'
                    Clear-Variable -Force mz
                }
            }
            else{
                $probe = $true
            }
        }
    }
    else{
    ##  Skip this notice if string search wasn't needed
    if( ! $dyrl_eli_JUSTCOPY ){
        Write-Host -f GREEN " Large strings are truncated for readability, so you may not see your exact match above."
        Write-Host -f GREEN " Do you want to copy any of these files to your desktop for further investigation (y/n)?  " -NoNewline;
            $COPYIT = Read-Host
    }

    while( $COPYIT -notMatch "^(n|N).*" ){
        
        while( $WRITE ){
            Write-Host ''
            while( $Z -notMatch "[0-9n]{1,4}" ){
                Write-Host -f GREEN " Enter the # of the file you want to copy, or 'n' to cancel:  " -NoNewline;
                    $Z = Read-Host
            }
            if( $Z -eq 'n' ){
                Return
            }

            $Z = ($Z - 1)  ## Arrays start at index 0

            if( $dyrl_eli_SENSOR2[$Z] ){
                $COPYFROM = $dyrl_eli_SENSOR2[$Z]
                $dyrl_eli_j = $COPYFROM -replace("^.*\\",'')

                Write-Host -f GREEN " Clenching..."
                slp 2

                try{
                    Copy-Item -Path "$COPYFROM" "$vf19_DEFAULTPATH\$dyrl_eli_j"
                }
                catch{
                    $dyrl_eli_FAIL = $true
                    Write-Host -f CYAN " RADAR JAMMING!" -NoNewline;
                        Write-Host -f GREEN " Something went wrong, file was not copied."
                }
                
                if( ! $dyrl_eli_FAIL ){
                    Write-Host -f YELLOW " Complete!" -NoNewline;
                    $COPYIT = $null
                    $Z = $null
                    while( $COPYIT -notMatch "[y|n]" ){
                        Write-Host -f GREEN " $dyrl_eli_j has been copied to your desktop. Copy another (y/n)?  " -NoNewline;
                            $COPYIT = Read-Host
                    }

                    if( $COPYIT -eq 'n' ){
                        $WRITE = $false
                    }
                    else{
                        $TEMPARRAYINDEX = 0
                    }
                }

            }
            else{
                Write-Host -f CYAN " That file doesn't exist...
                "
            }
                
        }
    }    
    }
}


####################################
## DEFAULT VARS
####################################
$dyrl_eli_DATE = date

## Hashtable/array for informing user of search hits
$dyrl_eli_SENSOR1 = @()
$dyrl_eli_SENSOR2 = @()
$dyrl_eli_CHEEKSZ = @()




## If running ELINT tool by itself get the user to 
##   manually enter a filepath or list
if( ! $RESULTFILE ){
    $dyrl_eli_C2f = $null
    splashPage
    Write-Host ''
    Write-Host -f GREEN ' ELINTSEEKER can search multiple files if you have a list of filepaths in a txt'
    Write-Host -f GREEN ' file. Do you have a txt? Type ' -NoNewLine;
    Write-Host -f YELLOW 'y' -NoNewLine;
    Write-Host -f GREEN ', ' -NoNewline;
    Write-Host -f YELLOW 'n' -NoNewline;
    Write-Host -f GREEN ' or ' -NoNewLine;
    Write-Host -f YELLOW 'c' -NoNewline;
    Write-Host -f GREEN ' to cancel:  ' -NoNewline;
    $dyrl_eli_YNC = Read-Host

    Write-Host '
    '

    if( $dyrl_eli_YNC -eq 'c' ){
        Remove-Variable dyrl_eli*
        Remove-Variabe vf19_MPOD
        Return
    }
    elseif( $dyrl_eli_YNC -Match "^y" ){
        while( $dyrl_eli_ULIST -notMatch ".*\.txt" ){
            Write-Host -f GREEN ' Please select your text file:'
            slp 2
            $dyrl_eli_ULIST = getFile

            if( $dyrl_eli_ULIST -notMatch ".*\.txt" ){
                Write-Host -f CYAN ' ERROR! You have to use a ".txt" file.
                '
            }
            elseif( $dyrl_eli_ULIST -eq '' ){
                Write-Host -f CYAN ' Action cancelled. Exiting...'
                slp 2
                Exit
            }
        }
    }
    else{
        Write-Host -f GREEN " Okay, I'll open a window for you to select your document:
        "
        slp 2
        $Script:dyrl_eli_PATH = getFile
        if( $dyrl_eli_path -eq '' ){
            Write-Host -f CYAN '
            Action cancelled. Exiting...'
            slp 2
            Exit
        }
        else{
            $dyrl_eli_PATHN = $dyrl_eli_PATH -replace "^.+\\",''
            Write-Host -f GREEN " Scanning $dyrl_eli_PATHN...
            "
            slp 1
            $Script:dyrl_eli_SINGLE = $true
        }
        
    }
}
# Use auto-generated list from another tool
else{
    $GOBACK = $true
    $dyrl_eli_FNAME1 = Get-Content -Path "$RESULTFILE"
    $dyrl_eli_TRUNCATE = Split-Path -Path "$RESULTFILE" -Leaf -Resolve
    callSplash
    Write-Host ''
}




Write-Host ''
Write-Host -f CYAN ' DISCLAIMER: ' -NoNewLine;
Write-Host -f GREEN 'Depending on your search, this might not be a quick task.
'




do {
    $dyrl_eli_ACTIVESCAN = $true


    if( ! $dyrl_eli_PATH ){
    #==============================================================
    # Set the output path and start a counter
    #==============================================================
        if( $dyrl_eli_FNAME1 ){
            $dyrl_eli_FNAME2 = $dyrl_eli_FNAME1                    ## Set a MACROSS-supplied list
            Write-Host ''
            Write-Host -f CYAN " $USR/$CALLER " -NoNewLine;
            Write-Host -f GREEN "needs to search thru " -NoNewLine;
            Write-Host -f CYAN "$dyrl_eli_TRUNCATE" -NoNewLine;
            Write-Host -f GREEN '...
            '
        }
        else{
            $dyrl_eli_FNAME2 = "$dyrl_eli_ULIST"                  ## Set a user-supplied list
        }
    }

    if( $CALLER ){
        while( $dyrl_eli_Z -notMatch "(c|s)" ){
            Write-Host -f GREEN " Are you running a (" -NoNewline;
            Write-Host -f YELLOW "s" -NoNewline;
            Write-Host -f GREEN ")tring search, or do you just want to (" -NoNewline;
            Write-Host -f YELLOW "c" -NoNewline;
            Write-Host -f GREEN ")opy file(s) to your desktop? " -NoNewline;
            $dyrl_eli_Z = Read-Host
        }
    }


    <#================================================
      If user just wants to copy from SUSHI list (need to clean this up)
    ================================================#>
    if( $dyrl_eli_Z -eq 'c' ){
        $dyrl_eli_Z = $null            ## Clear this out for the next while-loop
        $dyrl_eli_JUSTCOPY = $true
        foreach( $dyrl_eli_DOCFOUND in $dyrl_eli_FNAME2 ){
            $dyrl_eli_DOCFILE = Split-Path -Path "$dyrl_eli_DOCFOUND" -Leaf -Resolve
            $dyrl_eli_SENSOR2 += $dyrl_eli_DOCFOUND
            $dyrl_eli_SENSOR1 += $dyrl_eli_DOCFILE
        }

        Write-Host -f GREEN ' Getting file list...
        '
        slp 1

        fileCopy

        ## Keep user from exiting prematurely if they're hitting ENTER during slow actions
        while( $dyrl_eli_Z -ne 'c' ){
            Write-Host ''
            Write-Host -f GREEN " All done. Type 'c' to continue.  " -NoNewline;
                $dyrl_eli_Z = Read-Host
        }
        Remove-Variable CALLER -Scope Global
        Remove-Variable dyrl_eli* -Scope Global
        Return
    }
    <#================================================
      If user needs to search for strings
    ================================================#>
    else{
        $dyrl_eli_Z = $null
        $dyrl_eli_CTR = 0
        $Global:HOWMANY = 0
        if( $dyrl_eli_norecord ){
            $dyrl_eli_intelpkg = $null
        }
        else{
            $dyrl_eli_intelpkg = "$vf19_DEFAULTPATH\strings-found.txt"  ## Output all results to this file
        }


        # Get required vars and run the search
        Write-Host -f GREEN ' What string are you searching for?  ' -NoNewLine;

        $dyrl_eli_TARGETS = Read-Host 
        Write-Host -f GREEN ' Does case matter? (' -NoNewLine;
        Write-Host -f YELLOW 'y' -NoNewLine;
        Write-Host -f GREEN '/' -NoNewLine;
        Write-Host -f YELLOW 'n' -NoNewLine;
        Write-Host -f GREEN ')  ' -NoNewLine; 
        $dyrl_eli_CASE = Read-Host

        Write-Host ''


        ## For non-MS Office files, use 'Get-Content' cmdlet
        if( $dyrl_eli_CASE -eq 'y' ){
            Write-Host " Enforcing case. Searching...
            "
        }
        else{
            Write-Host -f GREEN ' Defaulting to case-insensitive. Searching...
            '
            $dyrl_eli_CASE = 'n'
        }

        slp 3



        #==============================================================
        # Prep the output file, append new results if file already exists
        #==============================================================
        $dyrl_eli_BKMARK = "===== $dyrl_eli_TARGETS found on $dyrl_eli_DATE ====="                   
        $dyrl_eli_LINETOTAL = (Get-Content $dyrl_eli_ipkg).count                                  ## Total sum of lines in POOP file
        $dyrl_eli_LINESTART = Get-Content $dyrl_eli_ipkg |                                        ## Line number of latest search string
            Select-String "$dyrl_eli_BKMARK" | 
            Select-Object -ExpandProperty lineNumber
        $dyrl_eli_LINESUBTRACT = ($dyrl_eli_LINETOTAL - $dyrl_eli_LINESTART)                        ## Number of new lines containing search results

        ## Alter the search based on whether case matters to the user
        #$dyrl_eli_YCASE = Get-Content $dyrl_eli_DOCFOUND | Select-String -CaseSensitive $dyrl_eli_TARGETS
        #$dyrl_eli_NCASE = Get-Content $dyrl_eli_DOCFOUND | Select-String -Pattern $dyrl_eli_TARGETS

        ## Append new search results to POOP file
        if( ! $dyrl_eli_norecord ){
            ' ' >> $dyrl_eli_ipkg
            $dyrl_eli_BKMARK >> $dyrl_eli_ipkg
        }


        ########################  Scan a list of files from a .txt
        if( $dyrl_eli_FNAME2 ){
            $dyrl_eli_NUMF = (Get-Content $dyrl_eli_FNAME2).count   ## How many files are in the list supplied?
            Write-Host -f GREEN " Scanning $dyrl_eli_NUMF files...
            "
            slp 2
            foreach( $dyrl_eli_DOCFOUND in $dyrl_eli_FNAME2 ){
                ## Cut the path from the filename for display
                $Script:dyrl_eli_DOCFILE = Split-Path -Path "$dyrl_eli_DOCFOUND" -Leaf -Resolve

                ## Determine scan method
                if( $dyrl_eli_DOCFOUND -Match "(docx|xlsx|pptx)$" ){
                    $dyrl_eli_INTELFOUND = msOffice $dyrl_eli_DOCFOUND $dyrl_eli_TARGETS 1
                }
                else{
                    $dyrl_eli_INTELFOUND += setCase $dyrl_eli_DOCFOUND
                }


                if( $dyrl_eli_INTELFOUND ){

                    ## Write the matching keywords to the strings-found.txt file
                    function matchRecord($1){
                        if( ! $dyrl_eli_norecord ){
                            $dyrl_eli_DOCFOUND |  Out-File -FilePath $dyrl_eli_intelpkg -Append
                            $1 | Out-File -FilePath $dyrl_eli_intelpkg -Append
                        }
                    }

                    ## Keep the strings under 100 chars for the screen;
                    ## the msOffice function returns array of strings so
                    ## need to iterate each item
                    if( $dyrl_eli_INTELFOUND.GetType().BaseType.Name -eq 'Array'){
                        $dyrl_eli_INTELFOUND | %{
                            $dyrl_eli_MATCHLEN = $_.Length
                            $dyrl_eli_DOCFILE = $_ -replace "^.*\\",''
                            if( $dyrl_eli_MATCHLEN -gt 100 ){
                                $dyrl_eli_INTELFOUND_TRUNC = $_.Substring(0,96)
                            }
                            if($dyrl_eli_MATCHLEN -gt 0){  ## Skip empty array positions
                                matchRecord $_
                            }
                            ## cat the filesize, filename, and string sample into one variable
                            $dyrl_eli_IMAGERY = "(" + $dyrl_eli_FSIZE + ")  " + $dyrl_eli_DOCFILE + ": " + $dyrl_eli_INTELFOUND_TRUNC
                            $dyrl_eli_SENSOR1 += $dyrl_eli_IMAGERY       ## record the filename, size and strings
                            $dyrl_eli_SENSOR2 += $dyrl_eli_DOCFOUND      ## record the filepath of search hits
                        }
                    }
                    else{
                        $dyrl_eli_INTELFOUND = [string]$dyrl_eli_INTELFOUND
                        $dyrl_eli_MATCHLEN = $dyrl_eli_INTELFOUND.Length
                        if( $dyrl_eli_MATCHLEN -gt 100 ){
                            $dyrl_eli_INTELFOUND_TRUNC = $dyrl_eli_INTELFOUND.Substring(0,96)
                        }
                        matchRecord $dyrl_eli_INTELFOUND
                        $dyrl_eli_IMAGERY = "(" + $dyrl_eli_FSIZE + ")  " + $dyrl_eli_DOCFILE + ": " + $dyrl_eli_INTELFOUND_TRUNC
                        $dyrl_eli_SENSOR1 += $dyrl_eli_IMAGERY
                        $dyrl_eli_SENSOR2 += $dyrl_eli_DOCFOUND
                    }

                    


                    Write-Host -f YELLOW " $dyrl_eli_DOCFILE" -NoNewline;
                    Write-Host ": MATCH FOUND ($dyrl_eli_CTR/$dyrl_eli_NUMF)"
                    $Global:HOWMANY++                            ## track the no. search hits
                    $Script:dyrl_eli_CTR++                       ## track the no. of files searched
                    
                    
                    slp 2

                }
                else{
                    $dyrl_eli_CTR++
                    Write-Host " Document #$dyrl_eli_CTR/$dyrl_eli_NUMF - NO MATCH"
                }
            }
        }
        ########################  Scan a single file
        elseif( $dyrl_eli_SINGLE ){
            $dyrl_eli_Z1 = $null
            Write-Host ''
            if( $dyrl_eli_PATH -Match "(docx|xlsx|pptx)$"){
                read-host $dyrl_eli_PATH
                msOffice $dyrl_eli_PATH $dyrl_eli_TARGETS 2
            }
            else{
                $dyrl_eli_setCase = setCase $dyrl_eli_PATH
                foreach($dyrl_eli_i in $dyrl_eli_setCase){
                    Write-Host -f CYAN '   MATCH: ' -NoNewline;
                    Write-Host "$dyrl_eli_i
                    "
                    $Global:HOWMANY++
                    Write-Host -f GREEN '   Continue parsing this file (y/n)?  ' -NoNewline;
                    $dyrl_eli_Z1 = Read-Host

                    if( $dyrl_eli_Z1 -eq 'n'){
                        Break
                    }
                }
            }

            Write-Host ''

        }
        ######################## Scan all files in a directory  *** DEPRECATED ***
        <#else{

            if( $dyrl_eli_CASE -eq 'y' ){
                $dyrl_eli_setCase = Get-Content $_.FullName | Select-String -CaseSensitive $dyrl_eli_TARGETS
            }
            else{
                $dyrl_eli_setCase = Get-Content $_.FullName | Select-String $dyrl_eli_TARGETS
            }




            ## $1 is the file that was scanned, $2 is the matching string
            function scanDirFiles($1,$2){
               if( ! $dyrl_eli_norecord ){
                    $1 | %{$_.FullName} | Out-File -FilePath $dyrl_eli_ipkg -Append
                }

                $Global:HOWMANY++
                $Script:dyrl_eli_CTR++
                $dyrl_eli_TRUNCATE = Split-Path "$_" -Leaf -Resolve
                $dyrl_eli_FSIZE = [string]::Format("{0:n2} MB", ((Get-ChildItem -Path $_).length) / 1MB)
                Write-Host -f YELLOW " Match #$HOWMANY - $dyrl_eli_TRUNCATE"
                $dyrl_eli_INTELFOUND = $1 | Out-String

                if( $dyrl_eli_INTELFOUND.Length -gt 100 ){
                    $dyrl_eli_INTELFOUND = $dyrl_eli_INTELFOUND.Substring(0,96)
                }

                $Script:dyrl_eli_IMAGERY = "(" + $dyrl_eli_FSIZE + ")  " + $dyrl_eli_TRUNCATE + ": " + $dyrl_eli_INTELFOUND
                $Script:dyrl_eli_SENSOR1 += $dyrl_eli_IMAGERY
                $Script:dyrl_eli_SENSOR2 += $_.FullName
                
            }


            ## Collect files from the specified directory
             Get-ChildItem -Path "$dyrl_eli_PATH\*" -Recurse -Force |
                %{
                    if( $_ -Match "(docx|xlsx|pptx)$"){
                        $dyrl_eli_DIRPATH = $_
                        $dyrl_eli_FILETYPE = msOffice $_ $dyrl_eli_TARGETS 1

                        $dyrl_eli_FILETYPE | Foreach-Object{
                            if($_.length -ne 0){
                                scanDirFiles $dyrl_eli_DIRPATH $_
                                $Script:dyrl_eli_CTR++
                                $Script:dyrl_eli_TRUNCATE = Split-Path "$_" -Leaf -Resolve
                                Write-Host -f GREEN " Checking file #$dyrl_eli_CTR - $dyrl_eli_TRUNCATE..."
                            }
                        }

                    }
                    else{
                        $Script:dyrl_eli_CTR++
                        $Script:dyrl_eli_TRUNCATE = Split-Path "$_" -Leaf -Resolve
                        Write-Host -f GREEN " Checking file #$dyrl_eli_CTR - $dyrl_eli_TRUNCATE..."
                        if( $dyrl_eli_setCase ){
                            scanDirFiles $_ $($dyrl_eli_setCase | Out-String)
                        }
                    }
                }

                
            
        }#>


        completeMsg

    
        ## Offer to copy files
        if( ! $dyrl_eli_SINGLE ){
            if( $HOWMANY -ne 0 ){
                fileCopy
            }
        }

        

        ## Offer to perform new search on same files
        while( $dyrl_eli_YN -notMatch "^(y|n)" ){
            Write-Host -f GREEN " Do you want to search the same file(s) for a different string?  " -NoNewLine;
                $dyrl_eli_Z = Read-Host

            if( $dyrl_eli_Z -eq 'n' ){
                $dyrl_eli_YN = $dyrl_eli_Z
                $dyrl_eli_ACTIVESCAN = $false
                $Script:dyrl_eli_SINGLE = $null
            }
            elseif( $dyrl_eli_Z -eq 'y' ){
                $dyrl_eli_YN = $dyrl_eli_Z
                $dyrl_eli_SENSOR1 = @()
                $dyrl_eli_SENSOR2 = @()
            }
        }

        $dyrl_eli_YN = $null

    }
        



}while( $dyrl_eli_ACTIVESCAN -eq $true )



if( $GOBACK ){
    Write-Host ''
    Write-Host -f GREEN " Press ENTER to return to " -NoNewLine;
    Write-Host -f CYAN "$CALLER"
    Read-Host
}


Remove-Variable dyrl_eli_* -Scope Global
Return
