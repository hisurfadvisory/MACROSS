#_sdf1 String-search documents
#_ver 1.5
#_class 0,user,document string search,powershell,HiSurfAdvisory,1,onscreen

<#
    Author: HiSurfAdvisory
    ELINT-SEEKER (Document-File String Searches)
    
    Uses Get-Content and/or .NET methods to search files for user-supplied
    keywords; automatically uncompresses MS Office documents to scan XML files
	and detect vbs macros.
	
    Can work with single files, or a list of files from a .txt that
    was generated beforehand.
	
    ================= Note on PDFs =================
    This script does NOT incorporate iTextSharp for scanning PDF files
    at this time, instead it uses Didier Stevens' pdf-parser python
    script (see the pdfScan function later in this script for details.)
	
	I've used what can be copy-pasted rather than installed, because you
    can't assume you'll be able to install whatever you like on a 
    given customer's network. Unfortunately, this makes things more
    janky than I'd like, too.
	
    ================= Note on unused settings =================
    There are a few variables in this script that are not used by
    default. They exist for infosec purposes. You can tweak this script
    to set them based on inputs from your own scripts:
	
        $dyrl_eli_nocopy -- when this is set to true, all copy functions
        and dialogs are disabled, preventing the $CALLER script from being
        able to copy files being investigated. If you've found a mistakenly
        leaked document, for example, you don't want analysts to make it worse
        by creating more copies of it.
		
        $dyrl_eli_norecord -- when this is set to true, the filenames and
        their string-matches (if any) write to screen, but will NOT be written
        to the ~\Desktop\strings-found.txt file. Again, this is to prevent
        making leaks worse.
#>


###################################################################################
###       README ~~~~~~~~~ MACROSS PYTHON INTEGRATION EXAMPLE
###################################################################################
## If you want your powershell scripts to work with MACROSS python scripts,
## copy-paste this check to restore all the values that get lost when transitioning
## via both the powershell and python versions of the collab function.
param(
    [string]$pythonsrc = $null  ## The python collab function will set this value
)
if( $pythonsrc ){

    ## This will be the name of the python script calling this one
    $Global:CALLER = $pythonsrc

    ## This is a unique temporary session, so launch the core scripts to get their functions
    foreach( $core in gci "core\*.ps1" ){ . $core.fullname }

    ## Now that the core files are loaded, this function can restore all the MACROSS 
    ## defaults your powershell script might need:
    restoreMacross

    ## ELINTS is expecting a list of filepaths when called
    $Global:PROTOCULTURE = $PROTOCULTURE | ConvertTo-Json | ConvertFrom-Json
    
    ## Note that just like the powershell version, the python collab function can also
    ## send an alternate param to your scripts when relevant. So, you can write your  
    ## scripts to accept a value in addition to (or instead of) $PROTOCULTURE, if necessary.
}



## ASCII art for launching the script
function splashPage($1){
    cls
    if($1 -eq 'text'){
    $b = 'ICAgICAgIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKVlyAgICAg4paI4paI4pWX4paI4paI4paI4pWXICAg4paI4paI4pWX4
    paI4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4paI4paI4paI4paI4paI4pWXCiAgICAgICDilojilojilZTilZDilZDilZDilZDilZ3i
    lojilojilZEgICAgIOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKVlyAg4paI4paI4pWR4pWa4pWQ4pWQ4paI4paI4pWU4pWQ4pWQ4pWd4paI4paI4pW
    U4pWQ4pWQ4pWQ4pWQ4pWdCiAgICAgICDilojilojilojilojilojilZcgIOKWiOKWiOKVkSAgICAg4paI4paI4pWR4paI4paI4pWU4paI4paI4p
    WXIOKWiOKWiOKVkSAgIOKWiOKWiOKVkSAgIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVlwogICAgICAg4paI4paI4pWU4pWQ4pWQ4pWdICDilojil
    ojilZEgICAgIOKWiOKWiOKVkeKWiOKWiOKVkeKVmuKWiOKWiOKVl+KWiOKWiOKVkSAgIOKWiOKWiOKVkSAgIOKVmuKVkOKVkOKVkOKVkOKWiOKW
    iOKVkQogICAgICAg4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWR4paI4paI4pWRIOKVmuK
    WiOKWiOKWiOKWiOKVkSAgIOKWiOKWiOKVkSAgIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkQogICAgICAg4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4p
    Wd4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZDilZDilZ0gICDilZrilZDilZ0gICDilZrilZDil
    ZDilZDilZDilZDilZDilZ0='
    }
    elseif($1 -eq 'img'){
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
    }
    getThis $b
    Write-Host '
    '
    Write-Host -f YELLOW "$vf19_READ
    "
    Write-Host -f YELLOW '   =========================================================='
    Write-Host -f YELLOW '               ELINT-SEEKER automated string-search'


}

## Help/descriptions for script usage 
if( $HELP ){
  cls
  splashPage 'text'
  $vf19_LATTS['ELINTS'].toolInfo() | %{
    Write-Host -f YELLOW $_
  }
  Write-Host -f YELLOW "
  
  ELINT-SEEKER can perform a scan for words or phrases in files from any accesible
  location. This importantly doesn't require opening MS office documents and PDFs, 
  which risks triggering any exploits.
  
  This script:
    -Can accept lists to search multiple files at once
    -Can accept manual input of a single file for string-searching
    -Will notify you if macros are detected in MS Office documents & spreadsheets
    -Can copy files you find onto your desktop for investigation
 
  All search results get saved into a file called 'strings-found.txt' on your desktop. 
  You don't need to delete or rename this file, ELINTS will append your new findings 
  without modifying any previous search results.

  In order to scan through PDF files, you'll need python installed, and Didier Steven's
  pdf-parser script copied into your local core folder.

  hxxps://github.com/DidierStevens/DidierStevensSuite/blob/master/pdf-parser.py
  
  I will admit my PDF scanner isn't the best, so use something else if you have it.
  (I haven't been able to get regular expression searches to work reliably so far, and
  I don't have every type of formatting accounted for when trying to extract plaintext 
  from PDF stream objects...)


 
  Hit ENTER to return.
  "

  Read-Host
  Return
}


####################################
## Let user choose whether to quit after each match
####################################
function reacquire($1){
    if( $1 -eq 'p' ){
        Write-Host -f GREEN '   Continue parsing this file (y/n)?  ' -NoNewline;
        $Z = Read-Host
    }
    else{
        $Z = $false
    }
    Return $Z
}



####################################
## Task complete notification
####################################
function completeMsg (){
    if( $dyrl_eli_norecord ){
        ''
        Write-Host -f GREEN ' Hit ENTER to view ' -NoNewline;
        Write-Host -f YELLOW "$HOWMANY" -NoNewline;
        Write-Host -f GREEN ' string matches.'
        Read-Host
        cls
    }
    else{
        cls
        ''
        if($dyrl_eli_CONFIRMED -gt 0){
            $dyrl_eli_SENSOR1.keys | Sort | %{
                if($dyrl_eli_SENSOR1[$_] -ne ''){
                    $r = $dyrl_eli_SENSOR1[$_] -Split '::'
                    screenResults "$([string]$_ + ". $($r[1])")" $r[0]
                }
            }
            screenResults -e
            ''
        
        Write-Host -f GREEN ' Search complete!'
        Write-Host -f YELLOW " $HOWMANY" -NoNewLine; 
        Write-Host -f GREEN  ' results for ' -NoNewLine; 
        Write-Host -f YELLOW "$dyrl_eli_TARGET" -NoNewLine; 
        Write-Host -f GREEN ' have been appended to ' -NoNewLine; 
        Write-Host -f CYAN 'strings-found.txt' -NoNewLine; 
        Write-Host -f GREEN ' on your Desktop' -NoNewline;
        if($dyrl_eli_VBA -gt 0){
            Write-Host -f GREEN ','
            Write-Host -f GREEN ' as well as ' -NoNewline;
            Write-Host -f YELLOW "$dyrl_eli_VBA" -NoNewline;
            Write-Host -f GREEN ' macro name' -NoNewline;
            if($dyrl_eli_VBA -gt 1){
                Write-Host -f GREEN 's' -NoNewline;
            }
        }
        Write-Host -f GREEN '.
        '
        }
        else{
            w "    Nothing found for $($dyrl_eli_TARGET + '.')" c
        }
    }
}


####################################
## Scan MS Office files for the user's keywords (requires uncompressing):
## $1 is the filepath, $2 is the keyword, $3 determines the scan mode,
## whether the scan quits after the first match or not -- if $3 is set
## to '1', it auto-quits. if set to '2', it lets the user choose
## when to quit.
##
## This function returns an array of string matches ($a), even if there is
## only one match.
####################################
function msOffice($1,$2,$3){
    Set-Variable -Name a,n -Option AllScope         ## Let nested functions control these values
    $Script:a = New-Object -TypeName System.Collections.ArrayList   ## Collect all matches in $a
    $n = 0                                          ## Track number of matches PER FILE
    $fn = $1 -replace "^.*\\"                       ## Cut filepath for display
    $Script:dyrl_eli_VBA = 0                        ## Count of any vba scripts found

    if( $3 -eq 2 ){
        Write-Host -f GREEN " Type 'p' if you want to pause after every match, otherwise hit ENTER: " -NoNewline;
        $type = Read-Host
    }

    ## Create "or" search for comma-separated words
    if($2 -Like "*,*"){
        $2 = [regex]$('(' + $($2 -replace ",(\s)?",'|' -replace "\|$") + ')')
    }
    
    function grabXML($xml){
        $s = $xml.Open()
        $r = New-Object -TypeName System.IO.StreamReader($s)
        $t = $r.ReadToEnd()
        $s.Close()
        $r.Close()
        Return $t
    }


    ## Scan the extracted plaintext for user's keywords
    function keyWordScan($pt,$macroname){
        $L = 0                                                      ## Count number of lines scanned
        Write-Host -f CYAN "   SCANNING $fn"
        $pt |
            %{
                if($macroname -eq 'notvba'){
                    $b = $_ -replace "<.*?>","`n" -split("`n")          ## Remove office/xml tags, then ignore empty lines
                }
                else{
                    $b = $_ -replace "<.*$macroname"                    ## Look for the line with the macro name
                    $b >> $dyrl_eli_intelpkg
                    '' >> $dyrl_eli_intelpkg
                    '' >> $dyrl_eli_intelpkg
                    Return
                }
                $b | where{ $_ -ne ''} |
                %{
                    $L++
                    if( ! $quit ){
                        if( !($_ -cMatch $enc) ){
                            if( $dyrl_eli_CASE -eq 'y' ){   ## If the user specified case-sensitive
                                if($_ -cMatch "$2"){
                                    $Script:a.Add($_) | Out-Null #$a += $_
                                    $n++
                                    if( $3 -eq 1){
                                        $quit = $true
                                    }
                                    elseif($3 -eq 2){
                                        Write-Host -f YELLOW " Line $L" -NoNewline;
                                        Write-Host ":  $_
                                        "
                                        $Z = go $type
                                        if( $Z -eq 'n' ){
                                            $quit = $true
                                        }
                                    }
                                }
                            }
                            elseif($_ -Match "$2"){        ## If case doesn't matter
                                    $Script:a.Add($_) | Out-Null #$a += $_
                                    $n++
                                    if( $3 -eq 1){
                                        $quit = $true
                                    }
                                    elseif($3 -eq 2){
                                        Write-Host -f YELLOW " Line $L" -NoNewline;
                                        Write-Host ":  $_
                                        "
                                        $Z = go $type
                                        if( $Z -eq 'n' ){
                                            $quit = $true
                                        }
                                    }
                            }
                            else{
                                Write-Host -f YELLOW "   $fn" -NoNewline;
                                Write-Host ": line $L - NO MATCH"
                            }
                        }
                    }
                    else{
                        Return
                    }
                }  
            }
        }

    ##  Compressed office documents have multiple directories and files;
    ##  Only care about the XMLs containing text or vbs contents
    if( $1 -Match "(m|x)$"){
        Add-Type -Assembly System.IO.Compression.FileSystem        ## Need to uncompress MSOffice stuff
        $doc = [IO.Compression.ZipFile]::OpenRead("$1")
    }

    ## Excel contents are *typically* in "xl\worksheets\Sheet[0-9].xml" and ".\sharedStrings.xml" paths,
    ## and MSWord contents are in the Document.xml... but we'll search the whole thing anyway. If there is
    ## noticeable lag you can modify this to just grab Document.xml from Word files
    if( $doc ){
        $doc.Entries |
            ?{ $_.Name -Match "\.xml$"} | %{
                if($_.name -Match "^vba"){
                    $Script:dyrl_eli_VBA++
                    'VBA Script found: ' >> $dyrl_eli_intelpkg
                    '' >> $dyrl_eli_intelpkg
                    $PLAINTEXT = grabXML $_ 
                    keyWordScan $PLAINTEXT 'wne:macroName=' ## uncompressed file has VBA info
                }
                else{
                    $PLAINTEXT = grabXML $_
                    keyWordScan $PLAINTEXT 'notvba'
                }
            }
    }

    ## If doc is old 97-2003 non-compressed format, can't use keyWordScan function
    ## because it is for parsing extracted XML files.
    else{
        $findvba = Get-Content $1
        #$findstr = New-Object -TypeName System.IO.StreamReader -ArgumentList $1
        $findstr = [IO.File]::ReadLines($1)

        ## If 'VBA...DLL' and 'Sub ' are in the same doc, likely a macro
        if( $findvba | Select-String -CaseSensitive 'VBA' | Select-String 'dll' ){
            $mac = (($findvba | Select-String -Pattern "Sub .+\(\)") -replace $enc) -replace "^Sub " -replace "\(\)"
            #$mac = $mac -replace "^Sub " -replace "\(\)"
            Write-Host -f CYAN '  Possible macro found  : ' -NoNewline;
            Write-Host -f YELLOW $mac
            ''
            slp 3
            $Script:dyrl_eli_VBA++
            "VBA Script found: $mac" | Out-File -Append $dyrl_eli_intelpkg
            '' | Out-File -Append $dyrl_eli_intelpkg
        }

        $findstr | %{
            if($dyrl_eli_CASE -eq 'y'){
                if($_ | Select-String -CaseSensitive $2){
                    $Script:a.Add("$($_ -replace $nc)") | Out-Null #$a += $_ -replace $enc
                    $n++
                }
            }
            elseif($_ | Select-String $2){
                $Script:a.Add("$($_ -replace $enc)") #$a += $_ -replace $enc
                $n++
            }
        }
        Remove-Variable findstr,findvba,mac
    }

    cls
    if( $n -gt 0 ){
        $Script:dyrl_eli_CONFIRMED = $dyrl_eli_CONFIRMED + $n
        $n2 = $true
        if($Script:a.count -gt 1){
            ## Dedup results into new array, remove empty placeholder
            $stringsfound = $Script:a | Select -Unique | ?{$_ -ne ''} 
        }
    }

    w "
    
    $fn" -i y
    w ": FOUND $n matches for '$2'
    " g
    slp 2


    ## Cleanup
    $doc.Dispose()
    Remove-Variable -Force a,n


    if( $n2 ){
        Return $stringsfound
    }
    else{
        Return $false
    }

}


## Import Didier Stevens' pdf-parser python script
## $1 is the filepath, $2 is the search term(s)
## Only load if python is installed.
if($MONTY){
    $pdfp = "$vf19_TOOLSROOT\core\pdf-parser.py"
    function pdfScan($1,$2,$3){
    
        ##  Ensure cleanup of all temp files
        if($1 -eq 'fin'){
            Get-ChildItem -File -Path "$dumps\*" | %{
                Set-Content "SEFWRSBBIE5JQ0UgREFZ" $_.Fullname
                Remove-Item -Path $_.Fullname
            }
            Return
        }
        
        
        ## Temp files created in $outf don't get deleted until ELINTS exits, so only need to dump once.
        $outf = $($1 -replace ".*\\" -replace "\.pdf") + '-plaintext.txt'
    
        #$20 = @()  ## Use this to rewrite words with whitespace-regex
        #$22 = @()  ## This is the list of exact words + whitespace-regex to search on
        
        if($dyrl_eli_re){
            $23 = [regex]$2  ## $23 value means user entered a specific regex pattern
        }
        else{
            @('20','22') | %{Set-Variable -Name "$_" -Value $(New-Object System.Collections.ArrayList)}
        
            ## User may separate exact words with either spaces or commas or both
            ## $21 value means user is looking for exact words
            if($2 -Match ', '){
                $21 = $2 -Split(', ')
            }
            <#
            ## User might be looking for a phrase, so don't split without commas;
            ## be aware that phrase-searching may not work because things get broken
            ## up unpredictably while decoding
            elseif($2 -Match ' '){
                $21 = $2 -Split(' ')
            }#>
            else{
                $21 = $2 -Split(',')
            }
        }
    
        if($21 -and ! $23){
            ## PDF streams often break words apart; take all of the user's search
            ## keywords, split them into separate characters and add a regex for
            ## "match even if there is whitespace between letters". Also add 
            ## escapes for special characters
            #$22 = @()
            $21 | %{
                foreach($char in ($_ -Split(''))){
                    if($char -Match "(\\|\$|\(|\)\|\[|\]|\{|\}|\.|\?|\*|\^|\&)"){
                        $char = '\' + $char
                    }
                    $sp = $char + '\s*'
                    $20.Add($sp) | Out-Null #$20 += $sp
                }
                $22.Add($($20.toArray() -Join '')) #$22 += $($20 -Join(''))
                rv -Force 20,21
            }
            $22 = $22.toArray()
        }
        if($23){
            $22 = $23
        }
        elseif($22.count -gt 1){
            $23 = $22 -Join('|')  ## Join all array items into 1 regex "or" string
            [regex]$22 = "($23)"
        }
        else{
            [string]$22 = $22
        }
    
        ## "quickScan" is a simple best-effort that will filter out the most common noise IF the contents
        ## are easily decoded in memory; if this fails to find any keywords we can try dumping all the
        ## streams next.
        function quickScan($doc,$search){
            $f0 = (py $pdfp -f --searchstream="$search" --regex $doc)
            if($f0 | sls 'R/S/Span/Type/StructElem/ActualText'){
                $a = ((($f0 -split 'R/S/Span/Type/StructElem/ActualText' | 
                    where{
                        $_ -notMatch "\\x.+\\"
                    }) -replace "/K.+" -replace "(\(|\))") -join ' ') -replace "(\d+(\.\d+)? ){2,}"
            }
            else{
                $a = ((($f0 -split "\)" | 
                    where{
                        $_ -notMatch "\\x.+\\"
                    }) -replace "(\(|\))") -join ' ') -replace "(\d+(\.\d+)? ){2,}" -replace "\\\\"
            }
            if(sls " and " $a){
                Return $a
            }
        }
    
        if( ! (gci -File "$dumps\$outf")){
            $pdfblock = quickScan $1 $22
        }
    
    
            if($pdfblock.Length -gt 0){
    
                ## PDF streams aren't uniform; going to have to add multiple patterns based
                ## on how plaintext gets split up for coordinates.
                ## It would be easier to create an array of words, but words can get split
                ## into letters when decoded from the PDF object... so matches would potentially miss.
                if($pdfblock -Match "<<.*>>"){
                    $Script:pdfJoin = ($pdfblock -Split('<<') | %{$_ -replace ">>.*"}) -Join('  ')
                }
                elseif($pdfblock -Match "\\n\("){
                    $Script:pdfJoin = ($pdfblock -Split('\(') | %{$_ -replace "\).*"}) -Join('  ')
                }
                elseif($pdfblock -Like "* the *"){
                    $Script:pdfJoin = $pdfblock
                }
    
                
                if($pdfJoin){
                    Remove-Variable pdfblock -Scope Script
                    
                    function highlightMatches{
                        param(
                            #[Parameter(Mandatory = $true,ValueFromPipeline = $true)]
                            [Parameter(Mandatory = $true)]
                            [string]$textblk,
                            [Parameter(Mandatory = $true)]
                            [string]$pattern
                        )
    
                        begin{ 
                            $r = [regex]$pattern
                        }
                        process{
                            $matched = $r.Matches($textblk)
                            $Script:m = $matched.count
                            $startIndex = 0
    
                            if($m -gt 0){
                                #$Script:pdfReturn = @()
                                $Script:pdfReturn = New-Object System.Collections.ArrayList
                                ## Pull the matching keyword(s) along with some of the surrounding text
                                foreach($match in $matched){
                                    $Script:dyrl_eli_CONFIRMED++
                                    $Global:HOWMANY++                       ## track the total search hits
                                    #$Script:pdfReturn += "$( (($textblk.substring($($match.index - 10))) -split (' '))[0..35])"
                                    $m_ = "$( (($textblk.substring($($match.index - 10))) -split (' '))[0..35])"
                                    $Script:pdfReturn.Add($m_)
                                }
                                rv m_; $Script:pdfReturn = $pdfReturn.toArray()
                            }
                            ''
                        }
                    }
                    highlightMatches $pdfJoin $22
                    if($pdfReturn){
                        $p = $pdfReturn
                    }
    
                }
                else{
                    if($pdfReturn){
                        $p = $pdfReturn
                    }
                }
                Remove-Variable m,pdfReturn -Scope Script
                Return $p
            }
            
    
            <#======================================================================
                This method is a "best-effort"; if it doesn't find your keywords,
                that doesn't mean they aren't present in the document.
                
                If content streams could not be decoded with "quickScan", this
                will dump all the PDF objects to disk & decodes them to plaintext.
                This is more reliable, but takes a lot longer than quickScan depending
                on the size of the file, even with runspaces.
            ========================================================================#>
            #elseif( (Test-Path -Path "$dumps\$outf") -or (( $3 -ne 'multi' ) -and ! $pdfJoin -and ! $pdfblock) ){
            else{
                $outf = $1 -replace ".*\\" -replace "\.\w+$",'-plaintext.txt'
                ## This section of pdfScan can get called whether or not a dump file exists;
                ## if dump file does exist, the user is performing a follow-up search on the same dump so we skip this part
                if( ! (gci -File "$dumps\$outf")){
    
                    ## Make sure we have a temp folder to dump into
                    if( ! (Test-Path -Path $dumps)){
                        New-Item -ItemType directory -Path "$($dumps -replace "\\pdf-dumps")" -Name 'pdf-dumps'
                    }
    
                    
                    
                    ## Try to speed things up with some Runspaces (is 20 too much or too little?)
                    $SensorArray = [runspacefactory]::CreateRunspacePool(2,20)
                    $SensorArray.Open()
    
                    ## Get the indirect object names & dump them all to file
                    $objects = ((py $pdfp -a $1 | 
                        sls 'Indirect objects with a stream:') -replace '^.+: ') -split(', ')
                    $indexer = 0
                    $SpacialSweep = foreach($obj in $objects){
                        $indexer++
                        ## Runspace template to generate scriptblocks running in parallel:
                        $RadarLock = [powershell]::Create().AddScript({
                            param(
                                $obj,
                                $dumps,
                                $pdfp,
                                $document,
                                $id
                            )
                            
                            ## Help sorting by making all indexes 4 digits
                            if($id -lt 10){$id = '000' + [string]$id}
                            elseif($id -lt 100){$id = '00' + [string]$id}
                            elseif($id -lt 1000){$id = '0' + [string]$id}
                            else{$id = [string]$id}
                            
                            ## Run the pdf-parser python script with the -o flag to dump objects
                            py "$pdfp" -o $obj -f -d "$dumps\$('object' + $id + '.dump')" $document
                            
                            #$imgs = 0  ## Count extracted images (future feature)
                            
                        }).AddParameter(
                            'obj',$obj
                        ).AddParameter(
                            'dumps',$dumps
                        ).AddParameter(
                            'pdfp',$pdfp
                        ).AddParameter(
                            'document',$1
                        ).AddParameter(
                            'id',$indexer
                        )
                        
                        ## Populate the array with $RadarLock scriptblocks
                        $RadarLock.RunspacePools = $SensorArray; New-Object psObject -Property @{
                            Instance = $RadarLock
                            Result = $RadarLock.BeginInvoke()
                        }
                    }
    
                    $searches = 0
                    while( $SpacialSweep | where{ -not $_.Result.IsCompleted } ){
                        cls
                        $searches++
                        w '
        Quick recon failed for:' g
            w "        $($1 -replace ".*\\")" 'y'
            w '        Increasing scanners...' g
                        w "
                        
            Scanners deployed: $([string]$searches)" g
                        slp 1
                    }
                    
                    ## Power down the sensor arrays
                    $SensorArray.powershell.EndInvoke($RadarLock.Runspace) | Out-Null
                    $RadarLock.powershell.Runspace.Dispose()
                    $RadarLock.powershell.dispose()
                    ## Cleanup the runspace pools
                    $SensorArray.Dispose()
                    Remove-Variable objects,SensorArray,SpacialSweep
                    
                    ''
                    Write-Host '            '; -NoNewline;
                    w " INTEL ASSESSMENT: $((gci "$dumps\*dump").count) potential targets. " -f y -b bl
                    w '
                    '
                    
                    
                    ## Extract plaintext from dumps to '-plaintext.txt' & format to remove as much noise
                    ## as possible. I've left a few variations of "-Match" commented so you can tweak if
                    ## you need to, but these are the patterns I usually see in PDF dumps.
                    ##
                    ## This can be hit or miss. It *usually* works, but I know it doesn't account 
                    ## for every kind of formatting that gets spit out by pdf-parser's object dump.
                    ## The "-replace" tasks are set in a specific order to try and make sure I'm only
                    ## cutting the non-plaintext of the document. The very first task is to replace any
                    ## null-bytes (`0).
                    ##
                    ## Sometimes this function only writes one word per line, which is why I started with the 
                    ## commented "-Join" line. But it seems to work better without it more often than not.
                    ##
                    ## REPEATING DISCLAIMER: just because this scan doesn't find a match doesn't mean that
                    ## no match exists!! This is meant for environments where no better option is available
                    ## without just launching a PDF reader and detonating potential malware.
                    ##
                    foreach($file in Get-ChildItem -Path "$dumps\*.dump" | Sort -Property Name){
                        Write-Host -f YELLOW "  CONVERTING $($file.Name) TO READABLE FORMAT"
                       (Get-Content $file | where{
                            #$_ -Match "\(.+\)\-" -and ! ($_ -cMatch $enc)
                            #$_ -Match "\(.+\)(\-| Tj| Td)" -and ! ($_ -cMatch $enc)
                            $_ -Match "\[?\(.+\)\]?(\-| ?Tj| Td)" -and ! ($_ -cMatch $enc)
                            }) `
                            -replace "`0" `
                            -replace "(\)\-?\d+\()" `
                            -replace "\)\]" `
                            -replace "\[\(" `
                            -replace "\-?\d+\(" `
                            -replace "\)$" `
                            -replace "TJ$" `
                            -replace "\)\-?\d$" `
                            -replace "^q .+T(d|j)\s+\(" `
                            -replace "\) T(d|j).*"`
                            -replace "\( \)" `
                            -replace "\)\-?\d+\.\d+ \(" `
                            -replace "\)\d+ ",' ' | Out-File "$dumps\$outf" -Append  # -Join ' ') | Out-File "$dumps\$outf" -Append
                            
                        
                        Set-Content "SEFWRSBBIE5JQ0UgREFZ" $file  ## Sanitize & erase the dumps
                        Remove-Item -Force $file
                        
                    }
    
                }
                
                ## Scan the total plaintext for the user's keywords; collect all matches in a list.
                ## When a match is found, get the lines before and after the match for context
                ## Also, exact string searches work fine, but I rarely get results using regular-
                ## expression searches. I haven't figured out why yet, a pattern is a pattern, right?
                $finds = New-Object System.Collections.Generic.List[string]
                $i = 0
                $pt = Get-Content "$dumps\$outf"
                $pt | %{
                    if($_ -cMatch "$22"){
                        $Global:HOWMANY++                       ## Track the MACROSS total
                        $Script:dyrl_eli_CONFIRMED++            ## Track ELINTS' total
                        $find = (([string]$($pt[$($i-1)..$($i+1)]) -join '') -replace "\s{2,}",' ')
                        #$finds += $(($find -join '') -replace "\s{2,}",' ')
                        $finds.Add($find)
                    }
                    $i++
                }
                
                if($finds.count -gt 0){
                    Return $($finds -Join '')
                }
        }
    }
    }


####################################
## Draft a Get-Content query based on case sensitivity
## $1 is the filepath to search, $2 is the keyword(s)
####################################
function setCase($1,$2){
    ## Convert comma-separated words to regex "OR" list
    if($2 -Like "*,*"){
        $2 = '(' + $($2 -replace ",\s+",'|' -replace ",",'|') + ')'
    }
    if( $dyrl_eli_CASE -eq 'y' ){
        $a = Get-Content $1 | where{$_ -cMatch $2} #| Select-String -CaseSensitive $2
    }
    else{
        $a = Get-Content $1 | where{$_ -Match $2} #| Select-String $2
    }
    if( $a ){
        $Script:dyrl_eli_CONFIRMED++
        $a = $a -replace $enc  ## Remove non-ascii chars
        Return @($a)
    }
}


####################################
## Read the most recent search results and ask if the user wants to copy the files
####################################
function fileCopy(){
    $TEMPARRAYINDEX = 0
    $WRITE = $true
    
    cls
    if($dyrl_eli_SENSOR1.count -gt 0){
        screenResults "w~  ELINTS SEARCH RESULTS ($dyrl_eli_CONFIRMED total)"
        $dyrl_eli_SENSOR1.keys | Sort | %{
            $k1 = $_; $dyrl_eli_SENSOR1[$k1] | %{
                $r = $_ -Split('::')
                $item = ($r[1] -replace "^0+") + " ($($r[0]))"
                screenResults $item $r[2]
            }
        }
        screenResults -e
    }
    else{
        w ' 
    No results found. Hit ENTER to continue.' c
        Read-Host
    }

    ''


    ## If this investigation shouldn't copy files, you may need more info from EDR, if your
    ## org uses one and you have a MACROSS script to access its API
    if( $dyrl_eli_nocopy ){
        
        while( ! $probe ){
            $vf19_LATTS.keys | %{
                if($vf19_LATTS[$_].valType -eq 'EDR'){
                    $dyrl_eli_EDR = $vf19_LATTS[$_].fname
                    $edr = $vf19_LATTS[$_].name
                    ''
                    Write-Host -f GREEN " Select a file # to research in $edr, or Hit ENTER to continue: " -NoNewline;
                    $mz = Read-Host

                    if($mz -Match "^\d+$"){
                        if( $dyrl_eli_SENSOR2[$mz] ){
                            $probe = $dyrl_eli_SENSOR2[$mz] -replace "^.*\\"
                            
                            ## Don't lose the original caller & protoculture, if any
                            if( $CALLER ){
                                $dyrl_eli_callerhold = $CALLER
                            }
                            if($PROTOCULTURE){
                                $dyrl_eli_holdPROTO = $PROTOCULTURE
                            }
                            $Global:PROTOCULTURE = $probe
                            collab $dyrl_eli_EDR 'ELINTS' ## EDR script will read ELINTS' .valtype to know what $PROTOCULTURE is
                            Write-Host '
                            '
                            while($mz -notMatch "^[yn]"){
                                Write-Host -f GREEN " Do you want to search $edr for another file? " -NoNewline;
                                $mz = Read-Host
                            }
                            if( $mz -Match "^y" ){
                                Clear-Variable -Force mz,probe
                                fileCopy
                            }
                            else{
                                ## Reinstate the original values
                                if($dyrl_eli_callerhold){
                                    $Global:CALLER = $dyrl_eli_callerhold
                                }
                                if($dyrl_eli_holdPROTO){
                                    $Global:PROTOCULTURE = $dyrl_eli_holdPROTO
                                }
                            }
                            Remove-Variable edr,dyrl_eli_EDR
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
        }
    }
    else{
    ##  Skip this notice if string search wasn't needed
    if( ! $dyrl_eli_JUSTCOPY ){
        w ' Large strings are truncated for readability, and decoding PDFs can introduce weirdness, so ' g
        w ' you may not see your exact match above (but the match does exist).' g
        w ' Do you want to copy any of these files to your desktop for further investigation (y/n)?  ' g -i
        $COPYIT = Read-Host
    }

    while( $COPYIT -notMatch "^n" ){
        
        while( $WRITE ){
            ''
            while( $Z -notMatch "^\d{1,4}$" ){
                w ' Enter the # of the file you want to copy, or "n" to cancel:  ' g -i
                $Z = Read-Host
                if( $Z -eq 'n' ){
                    Return
                }
            }

            if( $dyrl_eli_SENSOR2[$Z] ){
                $COPYFROM = $dyrl_eli_SENSOR2[$Z]
                $dyrl_eli_j = $COPYFROM -replace "^.*\\"

                w ' Copying...' g
                slp 2

                try{
                    Copy-Item -Path "$COPYFROM" "$vf19_DTOP\$dyrl_eli_j"
                }
                catch{
                    $dyrl_eli_FAIL = $true
                    Write-Host -f CYAN ' RADAR JAMMING!' -NoNewline;
                    Write-Host -f GREEN ' Something went wrong, file was not copied.'
                    errLog 'ERROR' "$USR/ELINTS" "Failed to perform copy actions on $COPYFROM"
                    errLog 'ERROR' "$USR/ELINTS" "$($Error[0])"
                }
                
                if( ! $dyrl_eli_FAIL ){
                    $COPYIT = $null
                    $Z = $null
                    Write-Host -f YELLOW " Complete!" -NoNewline;
                    while( $COPYIT -notMatch "^(y|n)" ){
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
                w " That file doesn't exist...
                " c
            }
                
        }
    }    
    }
}


####################################
## DEFAULT VARS
####################################
$dyrl_eli_DATE = date
$Script:enc = "[^\x00-\x7F]"                ## Ignore non-ASCII bytes
$msx = [regex]"\.(doc|xls|ppt)(m|x)?$"      ## MS office docs require specific parsing

## Intel collection
$Script:dyrl_eli_SENSOR1 = @{} ## Collects formatted info for displaying to screen
$Script:dyrl_eli_SENSOR2 = @{} ## Collects filepaths that can be used for copying files that match searches



#############################################
##  MAIN
#############################################
## If running ELINTS script by itself, get the user to  manually enter a filepath or list
if( ! $RESULTFILE -and ! $PROTOCULTURE){
    $dyrl_eli_DELTA = $null
    splashPage 'img'
    ''
    w ' ELINTS can search multiple files if you have a list of filepaths in a txt' g
    w ' file. Do you have a txt? Type ' g -i
    w 'y' y -i
    w ', ' g -i
    w 'n' y -i
    w ' or ' g -i
    w 'c' y -i
    w ' to cancel:  ' g -i
    $dyrl_eli_YNC = Read-Host

    w '
    '

    if( $dyrl_eli_YNC -eq 'c' ){
        Remove-Variable dyrl_eli*
        Remove-Variable dash_MPOD
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
# Use auto-generated list from another tool; $RESULTFILE must be set as a global var from the calling script!
elseif( $RESULTFILE ){
    $GOBACK = $true  ## Avoid issues if $CALLER gets set later
    $dyrl_eli_FLIST = Get-Content $RESULTFILE
    $dyrl_eli_RFNAME = Split-Path -Path $RESULTFILE -Leaf -Resolve
    splashPage 'text'
    ''
}
## If there is no $RESULTFILE, $PROTOCULTURE should be a list of filepaths, even if just one file.
elseif($PROTOCULTURE.getType().BaseType.Name -eq 'Array'){
    $dyrl_eli_FLIST = $PROTOCULTURE
    $dyrl_eli_RFNAME = '$PROTOCULTURE'
    splashPage 'text'
    ''
}




''
Write-Host -f CYAN ' DISCLAIMER: ' -NoNewLine;
Write-Host -f GREEN 'Depending on your search, this might not be a quick task.
'




do{
    $dyrl_eli_ACTIVE = $true


    if( ! $dyrl_eli_PATH ){
    #==============================================================
    # Set the output path and start a counter
    #==============================================================
        if( $dyrl_eli_FLIST ){
            ''
            Write-Host -f CYAN " $USR/$CALLER " -NoNewLine;
            Write-Host -f GREEN 'needs to search thru ' -NoNewLine;
            Write-Host -f CYAN "$dyrl_eli_RFNAME" -NoNewLine;
            w '...
            ' g
        }
        else{
            $dyrl_eli_FLIST = Get-Content $dyrl_eli_ULIST   ## Set a user-supplied list
        }
    }

    if( $CALLER ){
        if( $CALLER -eq 'Example script' ){     ## Insert your script name here as needed to restrict copy/writing tasks
            $dyrl_eli_Z = 's'                   ## Some scripts may only need string-search without filecopy
            $dyrl_eli_nocopy = $true            ## Do not allow copy for potential *sensitive* files
            $dyrl_eli_norecord = $true          ## Do NOT write potentially *sensitive* results to file!!!
        }
        while( $dyrl_eli_Z -notMatch "^(c|s)$" ){
            Write-Host -f GREEN " Are you running a (" -NoNewline;
            Write-Host -f YELLOW "s" -NoNewline;
            Write-Host -f GREEN ")tring search, or do you just want to (" -NoNewline;
            Write-Host -f YELLOW "c" -NoNewline;
            Write-Host -f GREEN ")opy file(s) to your desktop? " -NoNewline;
            $dyrl_eli_Z = Read-Host
            ''
        }
    }


    <#================================================
      If user just wants to copy from file list (need to clean this up)
    ================================================#>
    if( $dyrl_eli_Z -eq 'c' ){
        $dyrl_eli_Z = $null            ## Clear this out for the next while-loop
        $dyrl_eli_JUSTCOPY = $true
        $num = 1
        foreach( $dyrl_eli_RADARCONTACT in $dyrl_eli_FLIST ){
            $fsize = [string]::Format("{0:n2} MB", ((Get-ChildItem -Path $dyrl_eli_RADARCONTACT).length) / 1MB)
            $dyrl_eli_BOGEY = Split-Path -Path "$dyrl_eli_RADARCONTACT" -Leaf -Resolve
            $meta = "($fsize)" + '::' + $([string]$num + ".  $dyrl_eli_BOGEY::") + ' '
            $Script:dyrl_eli_SENSOR1.Add($num,$meta)
            $Script:dyrl_eli_SENSOR2.Add($num,$dyrl_eli_RADARCONTACT)
            $num++
        }
        Remove-Variable num,meta,fsize

        Write-Host -f GREEN ' Getting file list...
        '
        slp 1

        fileCopy

        ## Keep user from exiting prematurely if they're hitting ENTER during slow actions
        while( $dyrl_eli_Z -ne 'c' ){
            ''
            Write-Host -f GREEN ' All done. Type "c" to continue.  ' -NoNewline;
            $dyrl_eli_Z = Read-Host
        }
        Remove-Variable CALLER,dyrl_eli_* -Scope Global
        Return
    }
    <#================================================
      If user needs to search for strings
    ================================================#>
    else{
        $dyrl_eli_Z = $null
        $Script:dyrl_eli_CTR = 0        ## Track the files searched
        $Global:HOWMANY = 0             ## Track the total MACROSS results for investigation
        $Script:dyrl_eli_CONFIRMED = 0  ## Track the number of matches found by ELINTS
        if( $dyrl_eli_norecord ){
            $dyrl_eli_intelpkg = $null
        }
        else{
            $dyrl_eli_intelpkg = "$vf19_DTOP\strings-found.txt"  ## Output all results to this file
        }


        # Get required vars and run the search
        w '======         ~~ PDF SEARCHES ARE *ALWAYS* CASE-SENSITIVE ~~       ======' -f y -b bl
        w '======           ~~ REGEX IS UNRELIABLE FOR PDF SEARCHES ~~         ======' -f y -b bl
        w ' Type "regex " (without quotes) followed by your expression to match a' g
        w ' pattern, otherwise just enter your string or comma-separated keywords:' g
        w '  >  ' -i 
        $dyrl_eli_TARGET = Read-Host 

        ## Process special chars as literals if user didn't specify 'regex'
        if($dyrl_eli_TARGET -notMatch "^regex "){
            $dyrl_eli_TARGET = $dyrl_eli_TARGET -replace '\\','\\' `
                -replace '\.','\.' `
                -replace '\*','\*' `
                -replace '\$','\$' `
                -replace '\^','\^' `
                -replace '\?','\?' `
                -replace '\(','\(' `
                -replace '\)','\)' `
                -replace '\[','\[' `
                -replace '\]','\]' `
                -replace '\{'.'\{' `
                -replace '\}','\}'
            
            while($dyrl_eli_CASE -notMatch "^(y|n)$"){
                w ' Does case matter for non-PDFs? (' -i g
                w 'y' -i y
                w '/' -i g
                w 'n' -i y
                w ')  ' -i g
                $dyrl_eli_CASE = Read-Host
            }
        }
        else{
            $dyrl_eli_TARGET = $dyrl_eli_TARGET -replace "^regex "
            $dyrl_eli_CASE = 'y'
        }
        

        ''


        slp 1  ## pause script



        #==============================================================
        # Prep the output file, append new results if file already exists
        #==============================================================
        if( ! $dyrl_eli_norecord ){
            
            ## Change this write-to location if you feel the temporary PDF dumps should not be 
            ## written to analyst profiles. (But don't change the folder name, "pdf-dumps")
            $dumps = "C:\Users\$USR\AppData\Local\Temp\pdf-dumps"
                               
            $dyrl_eli_BKMARK = "===== KEYWORD: $dyrl_eli_TARGET SEARCHED: $dyrl_eli_DATE"                   
            $dyrl_eli_LINETOTAL = (Get-Content $dyrl_eli_intelpkg).count        ## Total sum of lines in intelpkg file
            $dyrl_eli_LINESTART = Get-Content $dyrl_eli_intelpkg |              ## Line number of latest search string
                Select-String "$dyrl_eli_BKMARK" | 
                Select-Object -ExpandProperty lineNumber
            $dyrl_eli_LINESUBTRACT = ($dyrl_eli_LINETOTAL - $dyrl_eli_LINESTART)    ## Number of new lines containing search results


            ## Create a bookmark where the next search results will start
            ' ' >> $dyrl_eli_intelpkg
            '============================================================'  >> $dyrl_eli_intelpkg
            $dyrl_eli_BKMARK >> $dyrl_eli_intelpkg
            '============================================================'  >> $dyrl_eli_intelpkg
        }


        ########################  Scan a list of files from a .txt or $PROTOCULTURE
        if( $dyrl_eli_FLIST ){
            $dyrl_eli_COLLECTIONS = @{}
            $dyrl_eli_NUMF = ($dyrl_eli_FLIST).count   ## How many files are in the list supplied?
            w " Scanning $dyrl_eli_NUMF files...
            " g
            slp 2
            foreach( $dyrl_eli_RADARCONTACT in $dyrl_eli_FLIST ){
                ## Cut the path from the filename for display
                $Script:dyrl_eli_BOGEY = $dyrl_eli_RADARCONTACT -replace "^.*\\"

                ## Get the filesize in MB
                $dyrl_eli_FSIZE = [string]::Format("{0:n2} MB", ((Get-ChildItem -Path $dyrl_eli_RADARCONTACT).length) / 1MB)
                cls
                $Script:dyrl_eli_CTR++                         ## Track the no. of files searched
                
                ''
                w " $dyrl_eli_CONFIRMED MATCHES FOUND ($dyrl_eli_CTR/$dyrl_eli_NUMF files)
                
                "
                w " TARGETING $dyrl_eli_BOGEY ($dyrl_eli_FSIZE)" c
                ## Determine scan method -- MS Office docs and PDFs require different methods
                if( $dyrl_eli_RADARCONTACT -Match $msx ){
                    $dyrl_eli_COLLECTIONS.Add($dyrl_eli_RADARCONTACT,$(msOffice $dyrl_eli_RADARCONTACT $dyrl_eli_TARGET))
                }
                
                ## Use pdf-parser only if python is installed
                elseif($dyrl_eli_RADARCONTACT -Like "*pdf"){
                    if($MONTY){
                        if( ! (gci -File $pdfp)){
                            errLog 'INFO' "$USR/ELINTS" "ELINTS failed to parse $($dyrl_eli_BOGEY + ':') pdf-parser.py missing."
                            eMsg "ELINTS failed to parse $($dyrl_eli_BOGEY + ':') pdf-parser.py missing."
                            $Script:dyrl_eli_CTR--  ## Don't count this as a searched file
                            slp 2
                        }
                        else{
                            $dyrl_eli_COLLECTIONS.Add($dyrl_eli_RADARCONTACT,$(pdfScan $dyrl_eli_RADARCONTACT $dyrl_eli_TARGET))
                        }
                    }
                    else{
                        errLog 'INFO' "$USR/ELINTS" "ELINTS failed to parse $($dyrl_eli_BOGEY + ':') python not installed."
                        eMsg "ELINTS failed to parse $($dyrl_eli_BOGEY + ':') python not installed."
                        $Script:dyrl_eli_CTR--  ## Don't count this as a searched file
                        slp 2
                    }
                }
                else{
                    $dyrl_eli_COLLECTIONS.Add($dyrl_eli_RADARCONTACT,$(setCase $dyrl_eli_RADARCONTACT $dyrl_eli_TARGET))
                }
            }
            
            
            if( $dyrl_eli_COLLECTIONS.count -gt 0 ){
                ## Write the matching keywords to the strings-found.txt file
                function matchRecord($1){
                    if( ! $dyrl_eli_norecord ){
                        $dyrl_eli_RADARCONTACT |  Out-File -FilePath $dyrl_eli_intelpkg -Append
                        $1 | Out-File -FilePath $dyrl_eli_intelpkg -Append
                    }
                }
                
                ## Format string matches and filenames for the results/selection menu
                function collectRecord($fp,$str,$num){
                    $fn = $fp -replace ".*\\"
                    if( $fn.Length -gt 19 ){$fn = $fn.Substring(0,19)}          ## Truncate long filenames
                    if( $str.Length -gt 200 ){$str = $str.Substring(0,196)}     ## Truncate long match strings
                    if($num -lt 10){$i = '000' + [string]$num}                  ## Stringify item number; lets user select files to copy
                    elseif($num -lt 100){$i = '00' + [string]$num}
                    elseif($num -lt 1000){$ = '0' + [string]$num}
                    else{$i = [string]$num}
                    $fn = "$i. $fn"
                    matchRecord $str
                    $Global:HOWMANY++           ## Track the total number of search hits
                    
                    ## cat the filesize, filename, and string sample into one variable
                    $meta = "($dyrl_eli_FSIZE)::" + $fn + "::" + $str
                    $Script:dyrl_eli_SENSOR1.Add($num,$meta)        ## record the filename, size and strings
                    $Script:dyrl_eli_SENSOR2.Add($num,$fp)          ## record the filepath of search hits for copying

                }
                    
                ## Keep the strings under 100 chars for the screen; the scanning functions return an 
                ## array of strings so we need to iterate each item
                $num = 1
                $dyrl_eli_COLLECTIONS.keys | %{
                    $k = $_; $dyrl_eli_COLLECTIONS[$k] | where{$_ -ne ''} | %{
                        $cstr = $_
                        $dyrl_eli_MATCHLEN = $cstr.Length
                        if( $dyrl_eli_MATCHLEN -gt 100 ){
                            $cstr = $cstr.Substring(0,96)
                        }
                        collectRecord $k $cstr $num
                        $num++
                    }
                }
                Remove-Variable num,cstr,dyrl_eli_COLLECTIONS
                
            }
            else{
                Write-Host " Document #$dyrl_eli_CTR/$dyrl_eli_NUMF - NO MATCH"
            }
        }
        ########################  Scan a single file
        elseif( $dyrl_eli_SINGLE ){
            $Script:dyrl_eli_BOGEY = Split-Path -Path "$dyrl_eli_PATH" -Leaf -Resolve
            $dyrl_eli_Z1 = $null
            ''
            if( $dyrl_eli_PATH -Match $msx ){
                $dyrl_eli_setCase = msOffice $dyrl_eli_PATH $dyrl_eli_TARGET 2
            }
            elseif($dyrl_eli_PATH -Like "*pdf" -and $MONTY){
                ''
                w ' Matching plaintext within PDF streams is touch & go; your results may vary...
                ' y
                slp 1
                $dyrl_eli_setCase = pdfScan $dyrl_eli_PATH $dyrl_eli_TARGET
            }
            elseif( ! $CALLER ){
                $dyrl_eli_setCase = setCase $dyrl_eli_PATH $dyrl_eli_TARGET
                Write-Host -f GREEN " Type 'p' if you want to pause after every match, otherwise hit ENTER: " -NoNewline;
                $type = Read-Host
            }

            if( $dyrl_eli_setCase ){
                $dyrl_eli_MCTR = 0
                foreach($dyrl_eli_i in $dyrl_eli_setCase){
                    Write-Host -f CYAN '   MATCH: ' -NoNewline;
                    w "$dyrl_eli_i
                    "
                    if( ! $dyrl_eli_norecord ){
                        $dyrl_eli_PATH |  Out-File -FilePath $dyrl_eli_intelpkg -Append
                        $dyrl_eli_i | Out-File -FilePath $dyrl_eli_intelpkg -Append
                        "`n`n" | Out-File -FilePath $dyrl_eli_intelpkg -Append
                    }
                    $Global:HOWMANY++   ## Total overall hits including other MACROSS tools
                    $dyrl_eli_MCTR++    ## Total hits for this document
                    $Script:dyrl_eli_SENSOR1.Add($dyrl_eli_MCTR,$dyrl_eli_i)
                    $dyrl_eli_Z1 = reacquire $type
                    if( $dyrl_eli_Z1 -eq 'n'){
                        Break
                    }
                }
            }
        }

        ## Offer to copy files
        if( ! $dyrl_eli_SINGLE ){
            if( $dyrl_eli_CONFIRMED -ne 0 ){
                fileCopy
            }
        }
        else{
            ''
            completeMsg
        }

        
        pdfScan 'fin'  ## Ensure temp files get cleaned up
        
        Remove-Variable dyrl_eli_COLLECTIONS,dyrl_eli_setCase
        ## Offer to perform new search on same files
        while( $dyrl_eli_YN -notMatch "^(y|n)" ){
            w "`n"
            w " Do you want to search the same file(s) for a different string?  " -i g
                $dyrl_eli_Z = Read-Host

            if( $dyrl_eli_Z -eq 'n' ){
                $dyrl_eli_YN = $dyrl_eli_Z
                $dyrl_eli_ACTIVE = $false
                $Script:dyrl_eli_SINGLE = $null
            }
            elseif( $dyrl_eli_Z -eq 'y' ){
                $dyrl_eli_YN = $dyrl_eli_Z
                $Script:dyrl_eli_SENSOR1 = @{}
                $Script:dyrl_eli_SENSOR2 = @{}
            }
        }

        $dyrl_eli_YN = $null

    }
        



}while( $dyrl_eli_ACTIVE -eq $true )

pdfScan 'fin'  ## Make sure temp files get deleted

if( $GOBACK ){
    ''
    w ' Hit ENTER to return to ' -i g
    w $CALLER c
    Read-Host
}
Remove-Variable dyrl_eli_*,GOBACK,COMEBACK
Remove-Variable dyrl_eli_* -Scope Script
Return
