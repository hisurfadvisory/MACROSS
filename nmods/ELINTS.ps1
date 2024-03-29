#_sdf1 String-search documents
#_ver 3.1
#_class User,Strings,Powershell,HiSurfAdvisory,1

<#
    Author: HiSurfAdvisory
    ELINT-SEEKER (Automated String Search): Part of the MACROSS blue-team
    automation framework
    
    -- *REQUIRES* being launched from the MACROSS console! --
	
    Uses Get-Content and/or .NET methods to search files for user-supplied
    keywords; automatically uncompresses MS Office documents to scan XML files
	and detect vbs macros.
	
    Can work with single files, or a list of files from a .txt that
    was generated beforehand (this script was created alongside KONIG.ps1
    for that purpose).
	
    This script does NOT incorporate iTextSharp for scanning PDF files
    at this time, instead it uses Didier Stevens' pdf-parser (see the 
    peeDeeEff function later in this script for details.)
	
    Many customer networks I investigate do not have access to
    whatever 3rd-party utils that make life easy, so MACROSS tries to
    work with what's available. Also, integratrating that dll into
    MACROSS is more work than I have time for right now.
	
    There are a few variables in this script that are not used by
    default. They exist for infosec purposes. You can tweak this script
    to set them based on inputs from your own scripts:
	
        $dyrl_eli_nocopy -- when this is set to true, all copy functions
        and dialogs are disabled, preventing the $CALLER script from being
        able to copy files being investigated. If you've found a mistakenly
        leaked document, for example, you don't want analysts to make it worse
        by creating more copies of it.
		
        $dyrl_eli_norecord -- when this is set to true, the filenames and
        their string-matches (if any) will NOT be written to the
        ~\Desktop\strings-found.txt file
#>

## ASCII art for launching the script
function splashPage($1){
    cls
    if($1 -eq 'text'){
    $b = 'ICAgICAgICAgICAgICAg4paI4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWXICAgICDilojilojilZfilojilojilojilZcgICDil
    ojilojilZfilojilojilojilojilojilojilojilojilZcKICAgICAgICAgICAgICAg4paI4paI4pWU4pWQ4pWQ4pWQ4pWQ4pWd4paI4paI4pWR
    ICAgICDilojilojilZHilojilojilojilojilZcgIOKWiOKWiOKVkeKVmuKVkOKVkOKWiOKWiOKVlOKVkOKVkOKVnQogICAgICAgICAgICAgICD
    ilojilojilojilojilojilZcgIOKWiOKWiOKVkSAgICAg4paI4paI4pWR4paI4paI4pWU4paI4paI4pWXIOKWiOKWiOKVkSAgIOKWiOKWiOKVkQ
    ogICAgICAgICAgICAgICDilojilojilZTilZDilZDilZ0gIOKWiOKWiOKVkSAgICAg4paI4paI4pWR4paI4paI4pWR4pWa4paI4paI4pWX4paI4
    paI4pWRICAg4paI4paI4pWRCiAgICAgICAgICAgICAgIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KW
    iOKWiOKVkeKWiOKWiOKVkSDilZrilojilojilojilojilZEgICDilojilojilZEKICAgICAgICAgICAgICAg4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pW
    Q4pWd4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZDilZDilZ0gICDilZrilZDilZ0='
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
  $vf19_ATTS['ELINTS'].toolInfo() | %{
    Write-Host -f YELLOW $_
  }
  Write-Host -f YELLOW "
  
  ELINT-SEEKER can perform a scan for words or phrases in files from any accesible
  location. This is like the 'strings' command in linux, and importantly doesn't
  require OPENING the file, which risks triggering any exploits.
  
  This script:
    -Can accept lists to search multiple files at once
    -Can accept manual input of a single file for string-searching
    -Will notify you if macros are detected in MS Office documents & spreadsheets
    -Can copy files you find onto your desktop for investigation
    -Can query Carbon Black* using GERWALK to find additional info on files you've scanned
        *(Requires that your organization uses Carbon Black, obviously)
 
  When ELINTS is called by another script or you give it a list of filepaths, it will only
  grab the first instance of a match for you to view. All search results get saved into a
  file called 'strings-found.txt' on your desktop. You don't need to delete or rename this
  file, ELINTS will append your new findings without modifying any previous search results.
  When you are scanning a single file from manual selection, ELINTS will display every
  instance of a match --not just the first one-- so you can get some context.

  In order to scan through PDF files, you'll need python installed, and Didier Steven's
  pdf-parser script copied into your local ncore folder.

  hxxps://github.com/DidierStevens/DidierStevensSuite/blob/master/pdf-parser.py


 
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
        if($dyrl_eli_MATCHLISTI){
            $dyrl_eli_MATCHLISTI.keys | Sort | %{ 
                screenResults $_ $dyrl_eli_MATCHLISTI[$_]
            }
            screenResults 'endr'    
        }
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
    Set-Variable -Name a,n -Option AllScope        ## Let nested functions control these values
    $fn = $1 -replace "^.*\\"                      ## Cut filepath for display
    #$encode = "[^\x00-\x7F]"                      ## Ignore non-ASCII blocks
    $n = 0                                         ## Track number of matches PER FILE
    $a = @('')                                     ## Only care if matches get written to $a
    $Script:dyrl_eli_VBA = 0                       ## Count of any vba scripts found

    if( $3 -eq 2 ){
        Write-Host -f GREEN " Type 'p' if you want to pause after every match, otherwise hit ENTER: " -NoNewline;
        $type = Read-Host
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
                    $b >> $dyrl_eli_POOP
                    '' >> $dyrl_eli_POOP
                    '' >> $dyrl_eli_POOP
                    Return
                }
                $b | where{ $_ -ne ''} |
                %{
                    $L++
                    if( ! $quit ){
                        if( !($_ -cMatch $dyrl_eli_encode) ){
                            if( $dyrl_eli_CASE -eq 'y' ){   ## If the user specified case-sensitive
                                if($_ -cMatch "$2"){
                                    $a += $_
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
                                    $a += $_
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
    ## noticeable lag we'll go back to just grabbing Document.xml from Word files
    if( $doc ){
        $doc.Entries |
            Where-Object{
                $_.Name -Match "\.xml$"
            } | %{
                if($_.name -Match "^vba"){
                    $Script:dyrl_eli_VBA++
                    'VBA Script found: ' >> $dyrl_eli_POOP
                    '' >> $dyrl_eli_POOP
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
            $mac = ($findvba | Select-String -Pattern "Sub .+\(\)") -replace $dyrl_eli_encode
            $mac= $mac -replace "^Sub " -replace "\(\)"
            Write-Host -f CYAN '  Possible macro found  : ' -NoNewline;
            Write-Host -f YELLOW $mac
            ''
            slp 3
            $Script:dyrl_eli_VBA++
            "VBA Script found: $mac" | Out-File -Append $dyrl_eli_POOP
            '' | Out-File -Append $dyrl_eli_POOP
        }

        $findstr | %{
            if($dyrl_eli_CASE -eq 'y'){
                if($_ | Select-String -CaseSensitive $2){
                    $a += $_ -replace $dyrl_eli_encode
                    $n++
                }
            }
            elseif($_ | Select-String $2){
                $a += $_ -replace $dyrl_eli_encode
                $n++
            }
        }
        Remove-Variable findstr,findvba,mac
    }

    cls
    if( $n -gt 0 ){
        $n2 = $true
        if($a.length -eq 2){
            ## If only 1 match was recorded, send it as a string instead of an array
            [string]$stringsfound = $a[1]
        }
        elseif($a.length -gt 1){
            ## Dedup results into new array, remove empty placeholder
            $stringsfound = $a | where{$_ -ne ''} | Select -Unique
        }
    }

    Write-Host -f YELLOW "
    
    $fn" -NoNewline;
    Write-Host -f GREEN ": FOUND $n matches for '$2'
    "
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
function peeDeeEff($1,$2,$3){

    $ppp = "$vf19_TOOLSROOT\ncore\pdf-parser.py"
    if( ! $ppp ){
        Write-Host -f CYAN "
    pdf-parser is not present! Grab it from 

        hxxps://github.com/DidierStevens/DidierStevensSuite/blob/master/pdf-parser.py

    and place it in MACROSS' ncore folder then run this search again. Hit ENTER to continue.
        "
        Read-Host
        Return
    }

    $20 = @()  ## Use this to rewrite words with whitespace-regex
    $22 = @()  ## This is the list of exact words + whitespace-regex to search on

    
    if($dyrl_eli_re){
        $23 = $2  ## $23 value means user entered a specific regex pattern
    }
    ## User may separate exact words with either spaces or commas or both
    ## $21 value means user is looking for exact words
    elseif($2 -Match ', '){
        $21 = $2 -Split(', ')
    }
    elseif($2 -Match ' '){
        $21 = $2 -Split(' ')
    }
    else{
        $21 = $2 -Split(',')
    }


    ## PDF streams often break words apart; take all of the user's search
    ## keywords, split them into separate characters and add a regex for
    ## "match even if there is whitespace between letters". Also add 
    ## escapes for special characters
    $21 | %{
        foreach($char in ($_ -Split(''))){
            if($char -Match "(\\|\$|\(|\)\|\[|\]|\{|\}|\.|\?|\*|\^|\&)"){
                $char = '\' + $char
            }
            $sp = $char + '\s*'
            $20 += $sp
        }
        $22 += $($20 -Join(''))
        $20 = $null
    }
    
    if($23){
        [string]$22 = $23
    }
    elseif($22.count -gt 1){
        $23 = $22 -Join('|')  ## Join all array items into 1 regex "or" string
        [string]$22 = "($23)"
    }
    else{
        [string]$22 = $22
    }


    $f0 = (& py "$ppp" -f --searchstream="$22" --regex $1)
        
    $Script:m = 0 ## Track the number of matches within the stream
        

    #$obj = $f | Select-String -Pattern "^obj \d+ "  ## If we need to start tracking the object containing the match
    
    ## PDF streams aren't uniform; going to have to add multiple patterns based
    ## on how plaintext gets split up for coordinates
    if($f0 -Match "<<.*>>"){
        $join = ($f0 -Split('<<') | %{$_ -replace ">>.*"}) -Join('  ')
    }
    elseif($f0 -Match "\\n\("){
        $join = ($f0 -Split('\(') | %{$_ -replace "\).*"}) -Join('  ')
    }


    ## If match is found, write out the whole contents for now; will clean this up later
    if($join){
        function highlightMatches{
            param(
                [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
                [string]$textblk,
                [Parameter(Mandatory = $true)]
                [string]$pattern
            )

            begin{ 
                $r = [regex]$pattern
            }
            process{
                $matches = $r.Matches($textblk)
                $Script:m = $matches.count
                $startIndex = 0

                foreach($match in $matches){
                    $nonMatchLength = $match.Index - $startIndex
                    Write-Host $textblk.Substring($startIndex, $nonMatchLength) -NoNew
                    Write-Host -f YELLOW $match.Value -NoNew
                    $startIndex = $match.Index + $match.Length
                }

                if($startIndex -lt $textblk.Length){
                    Write-Host $textblk.Substring($startIndex) -NoNew
                }

                Write-Host
            }
            

        }

        highlightMatches $join $22
        $mm = $m
        Remove-Variable m -Scope Global
        


        if($mm -eq 0 -and $join -gt 0){
            $mm = $($join.count)
        }


        if($3 -eq 'multi'){
            Return "$mm matches"  ## Only report # of matches if parsing multiple files (don't write to screen)
        }
        else{
            ''
            ''
            Write-Host -f YELLOW "   $mm" -NoNewline;
            Write-Host -f GREEN ' matches found!' -NoNewline;
            if($mm -gt 0){
                Write-Host -f GREEN ' If no text was highlighted onscreen, your match may be buried'
                Write-Host -f GREEN "   in another layer of encoding and couldn't be extracted.
                "
            }
            else{
                Write-Host '
                '
            }
            while($z -ne 'c'){  ## Prevent user exiting before they can view the results
                Write-Host -f GREEN '   Type "c" to continue: ' -NoNewline;
                $z = Read-Host
            }
        }
    }

}


####################################
## Draft a Get-Content query based on case sensitivity
## $1 is the filepath to search, $2 is the keyword(s)
####################################
function setCase($1,$2){
    if( $dyrl_eli_CASE -eq 'y' ){
        $a = Get-Content $1 | Select-String -CaseSensitive $2
    }
    else{
        $a = Get-Content $1 | Select-String $2
    }
    if( $a ){
        $a = $a -replace $dyrl_eli_encode  ## Remove non-ascii chars
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
            Write-Host "$i"
    }


    ## Scripts that can't copy may need more info from Carbon Black, or whatever
    ## other API you want to throw in here
    if( $dyrl_eli_nocopy ){

    if( $vf19_CB ){   ## Check if GERWALK is available; this gets set in display.ps1
        while( ! $probe ){
                ''
                Write-Host -f GREEN ' Select a file # to research in GERWALK, or Hit ENTER to continue: ' -NoNewline;
                $mz = Read-Host

                if($mz -Match "[0-9]"){
                    $mz = $mz - 1
                    if( $dyrl_eli_SENSOR2[$mz] ){
                        $probe = $dyrl_eli_SENSOR2[$mz] -replace("^.*\\",'')
                        $Global:PROTOCULTURE = $probe
			
                        ## Don't lose the original caller, if any; ELINTS will become the new $CALLER in the next command set
                        if( $CALLER ){
                            $dyrl_eli_callerhold = $CALLER
                        }
                    
                        $file_info = collab 'GERWALK.ps1' 'ELINTS' 'greedy'

			## GERWALK's response SHOULD be a hashtable with 2 values; but it sometimes
   			## responds with a random header in the [0] position that we don't care about.
      			## The second value received in $file_info is a list of the noisiest processes 
	 		## in most Carbon Black events, which you can use to filter out here if needed.
			if($file_info.count -eq 3){
				$fi = $file_info[1] | ConvertFrom-Json
   			}
      			else{
	 			$fi = $file_info[0] | ConvertFrom-Json
     			}

 			screenResults 'derpUSERNAMES' 'derpHOSTNAMES'
    			screenResulsts "$($fi.facets.username.name)" "$($fi.facets.hostname.name)"
       			screenResults 'endr'
   
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
                        elseif($dyrl_eli_callerhold){
                            $Global:CALLER = $dyrl_eli_callerhold      ## Reinstate the original caller
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
    }
    else{
    
    ##  Skip this notice if string search wasn't needed
    if( ! $dyrl_eli_JUSTCOPY ){
        Write-Host -f GREEN " Large strings *may* be truncated for readability, so you might not see your exact match above."
        Write-Host -f GREEN " Do you want to copy any of these files to your desktop for further investigation (y/n)?  " -NoNewline;
        $COPYIT = Read-Host
    }

    while( $COPYIT -notMatch "^(n|N).*" ){
        
        while( $WRITE ){
            ''
            while( $Z -notMatch "[0-9n]{1,4}" ){
                Write-Host -f GREEN " Enter the # of the file you want to copy, or 'n' to cancel:  " -NoNewline;
                $Z = Read-Host
            }
            if( $Z -eq 'n' ){
                Return
            }

            $Z = ($Z - 1)  ## Arrays start at index 0, but menu choices start at 1. Do the correction here.

            if( $dyrl_eli_SENSOR2[$Z] ){
                $COPYFROM = $dyrl_eli_SENSOR2[$Z]
                $dyrl_eli_j = $COPYFROM -replace("^.*\\",'')

                Write-Host -f GREEN " Copy..."
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
$Script:dyrl_eli_encode = "[^\x00-\x7F]"      ## Ignore non-ASCII blocks

## Hashtable/array for informing user of search hits
$dyrl_eli_SENSOR1 = @()
$dyrl_eli_SENSOR2 = @()




## If running ELINTS script by itself, get the user to 
## manually enter a filepath or list
if( ! $RESULTFILE ){
    $dyrl_eli_C2f = $null
    splashPage 'img'
    ''
    Write-Host -f GREEN ' ELINTS can search multiple files if you have a list of filepaths in a txt'
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
        Remove-Variabe dash_MPOD
        Return
    }
    elseif( $dyrl_eli_YNC -Match "^y" ){
        while( $dyrl_eli_ULIST -notMatch ".*\.txt" ){
            Write-Host -f GREEN ' Please select your text file:'
            slp 2
            $dyrl_eli_ULIST = getFile 'Text Document (.txt) | *.txt'   ## This should force only txt files to be available...

	    ## But just in case...
            if( $dyrl_eli_ULIST -notMatch ".*\.txt" ){
                Write-Host -f CYAN ' ERROR! You have to use a ".txt" file.
                '
            }

     	    ## User clicked "Cancel" in the selection window, does not want to continue.
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
        $Script:dyrl_eli_PATH = getFile 'Text Document (.txt) | *.txt'
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
    $GOBACK = $true  ## Avoid issues with CALLER getting set
    $dyrl_eli_FLIST = $RESULTFILE
    $dyrl_eli_TRUNCATE = Split-Path -Path $RESULTFILE -Leaf -Resolve
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
            Write-Host -f CYAN "$dyrl_eli_TRUNCATE" -NoNewLine;
            Write-Host -f GREEN '...
            '
        }
        else{
            $dyrl_eli_FLIST = $dyrl_eli_ULIST             ## Set a user-supplied list
        }
    }

    if( $CALLER ){
        if( $CALLER -eq 'Example script' ){  ## Insert your script name here as needed to restrict copy/writing tasks
            $dyrl_eli_Z = 's'             ## Some scripts may only needs string-search without filecopy
            $dyrl_eli_nocopy = $true      ## Do not allow copy for potential *sensitive* files
            $dyrl_eli_norecord = $true    ## Do NOT write potentially *sensitive* results to file!!!
        }
        while( $dyrl_eli_Z -notMatch "^(c|s)$" ){
            Write-Host -f GREEN " Are you running a (" -NoNewline;
            Write-Host -f YELLOW "s" -NoNewline;
            Write-Host -f GREEN ")tring search, or do you just want to (" -NoNewline;
            Write-Host -f YELLOW "c" -NoNewline;
            Write-Host -f GREEN ")opy file(s) to your desktop? " -NoNewline;
            $dyrl_eli_Z = Read-Host
        }
    }


    <#================================================
      If user just wants to copy from file list (need to clean this up)
    ================================================#>
    if( $dyrl_eli_Z -eq 'c' ){
        $dyrl_eli_Z = $null            ## Clear this out for the next while-loop
        $dyrl_eli_JUSTCOPY = $true
        foreach( $dyrl_eli_RADARCONTACT in $dyrl_eli_FLIST ){
            $dyrl_eli_BOGEY = Split-Path -Path "$dyrl_eli_RADARCONTACT" -Leaf -Resolve
            $dyrl_eli_SENSOR2 += $dyrl_eli_RADARCONTACT
            $dyrl_eli_SENSOR1 += $dyrl_eli_BOGEY
        }

        Write-Host -f GREEN ' Getting file list...
        '
        slp 1

        fileCopy

        ## Keep user from exiting prematurely if they're hitting ENTER during slow actions
        while( $dyrl_eli_Z -ne 'c' ){
            ''
            Write-Host -f GREEN " All done. Type 'c' to continue.  " -NoNewline;
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
        $Script:dyrl_eli_CTR = 0
        $Global:HOWMANY = 0
        if( $dyrl_eli_norecord ){
            $dyrl_eli_intelpkg = $null
        }
        else{
            $dyrl_eli_intelpkg = "$vf19_DEFAULTPATH\strings-found.txt"  ## Output all results to this file
        }


        # Get required vars and run the search
        Write-Host -f GREEN ' Type "regex " (without quotes) followed by your search string to'
        Write-Host -f GREEN ' match a pattern, otherwise just enter your keywords: '
        Write-Host '  >  ' -NoNewLine; 
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
                Write-Host -f GREEN ' Does case matter? (' -NoNewLine;
                Write-Host -f YELLOW 'y' -NoNewLine;
                Write-Host -f GREEN '/' -NoNewLine;
                Write-Host -f YELLOW 'n' -NoNewLine;
                Write-Host -f GREEN ')  ' -NoNewLine; 
                $dyrl_eli_CASE = Read-Host
            }
        }
        else{
            $dyrl_eli_TARGET = $dyrl_eli_TARGET -replace "^regex "
            $dyrl_eli_CASE = 'y'
        }
        

        ''


        slp 3  ## pause script for 3 seconds



        #==============================================================
        # Prep the output file, append new results if file already exists
        #==============================================================
        if( ! $dyrl_eli_norecord ){
            $dyrl_eli_BKMARK = "===== $dyrl_eli_TARGET found on $dyrl_eli_DATE ====="                   
            $dyrl_eli_LINETOTAL = (Get-Content $dyrl_eli_intelpkg).count        ## Total sum of lines in intelpkg file
            $dyrl_eli_LINESTART = Get-Content $dyrl_eli_intelpkg |              ## Line number of latest search string
                Select-String "$dyrl_eli_BKMARK" | 
                Select-Object -ExpandProperty lineNumber
            $dyrl_eli_LINESUBTRACT = ($dyrl_eli_LINETOTAL - $dyrl_eli_LINESTART)    ## Number of new lines containing search results


            ## Append new search results to intelpkg file
                ' ' >> $dyrl_eli_intelpkg
                $dyrl_eli_BKMARK >> $dyrl_eli_intelpkg
        }


        ########################  Scan a list of files from a .txt
        if( $dyrl_eli_FLIST ){
            $dyrl_eli_NUMF = (Get-Content $dyrl_eli_FLIST).count   ## How many files are in the list supplied?
            Write-Host -f GREEN " Scanning $dyrl_eli_NUMF files...
            "
            slp 2
            foreach( $dyrl_eli_RADARCONTACT in (Get-Content $dyrl_eli_FLIST) ){
                ## Cut the path from the filename for display
                $Script:dyrl_eli_BOGEY = $dyrl_eli_RADARCONTACT -replace "^.*\\",''

                ## Get the filesize in MB
                $dyrl_eli_FSIZE = [string]::Format("{0:n2} MB", ((Get-ChildItem -Path $dyrl_eli_RADARCONTACT).length) / 1MB)

                ## Determine scan method
                if( $dyrl_eli_RADARCONTACT -Match "(doc|xls|ppt)(m|x)?$" ){
                    $dyrl_eli_CONVSTR = msOffice $dyrl_eli_RADARCONTACT $dyrl_eli_TARGET 1
                }
                elseif($dyrl_eli_DOCFOUND -Match "pdf$"){
					## Use pdf-parser only if python is installed
                    if($MONTY){
                        $dyrl_eli_CONVSTR = peeDeeEff $dyrl_eli_DOCFOUND $dyrl_eli_TARGET 'multi'
                    }
                }
                else{
                    $dyrl_eli_CONVSTR = setCase $dyrl_eli_RADARCONTACT $dyrl_eli_TARGET
                }


                if( $dyrl_eli_CONVSTR ){

                    ## Write the matching keywords to the strings-found.txt file
                    function matchRecord($1){
                        if( ! $dyrl_eli_norecord ){
                            $dyrl_eli_RADARCONTACT |  Out-File -FilePath $dyrl_eli_intelpkg -Append
                            $1 | Out-File -FilePath $dyrl_eli_intelpkg -Append
                        }
                    }

                    ## Keep the strings under 100 chars for the screen;
                    ## the msOffice function returns an array of strings so
                    ## we need to iterate each item excluding the first one
                    if( $dyrl_eli_CONVSTR.GetType().BaseType.Name -eq 'Array'){
                        $dyrl_eli_CONVSTR | %{
                            $Global:HOWMANY++                       ## track the no. search hits
                            $dyrl_eli_MATCHLEN = $_.Length
                            if( $dyrl_eli_MATCHLEN -gt 100 ){
                                $dyrl_eli_CONVSTR_TRUNC = $_.Substring(0,96)
                            }

                            matchRecord $_

                            ## cat the filesize, filename, and string sample into one variable
                            $dyrl_eli_INTELPRODUCT = "(" + $dyrl_eli_FSIZE + ")  " + $dyrl_eli_BOGEY + ": " + $dyrl_eli_CONVSTR_TRUNC
                            $dyrl_eli_SENSOR1 += $dyrl_eli_INTELPRODUCT          ## record the filename, size and strings
                            $dyrl_eli_SENSOR2 += $dyrl_eli_RADARCONTACT      ## record the filepath of search hits
                        }
                    }
                    else{
                        $Global:HOWMANY++
                        $dyrl_eli_CONVSTR = [string]$dyrl_eli_CONVSTR
                        $dyrl_eli_MATCHLEN = $dyrl_eli_CONVSTR.Length
                        if( $dyrl_eli_MATCHLEN -gt 100 ){
                            $dyrl_eli_CONVSTR_TRUNC = $dyrl_eli_CONVSTR.Substring(0,96)
                        }
                        matchRecord $dyrl_eli_CONVSTR
                        $dyrl_eli_INTELPRODUCT = "(" + $dyrl_eli_FSIZE + ")  " + $dyrl_eli_BOGEY + ": " + $dyrl_eli_CONVSTR_TRUNC
                        $dyrl_eli_SENSOR1 += $dyrl_eli_INTELPRODUCT
                        $dyrl_eli_SENSOR2 += $dyrl_eli_RADARCONTACT
                    }

                    
                    $Script:dyrl_eli_CTR++                         ## track the no. of files searched
                    Write-Host -f YELLOW " $dyrl_eli_BOGEY" -NoNewline;
                    Write-Host ": $HOWMANY MATCHES FOUND ($dyrl_eli_CTR/$dyrl_eli_NUMF files)"
                    

                }
                else{
                    $Script:dyrl_eli_CTR++
                    Write-Host " Document #$dyrl_eli_CTR/$dyrl_eli_NUMF - NO MATCH"
                }
            }
        }
        ########################  Scan a single file
        elseif( $dyrl_eli_SINGLE ){
            $Script:dyrl_eli_BOGEY = Split-Path -Path "$dyrl_eli_PATH" -Leaf -Resolve
            $dyrl_eli_Z1 = $null
            ''
            if( $dyrl_eli_PATH -Match "(doc|xls|ppt)(m|x)?$" ){
                $dyrl_eli_setCase = msOffice $dyrl_eli_PATH $dyrl_eli_TARGET 2
            }
            elseif($dyrl_eli_PATH -Match "pdf$"){
                if($MONTY){
                    Write-Host -f YELLOW '
        Matching plaintext within PDF streams is touch & go; your results may vary...
        '
                    slp 1
                    peeDeeEff $dyrl_eli_PATH $dyrl_eli_TARGET
                }
            }
            else{
                $dyrl_eli_setCase = setCase $dyrl_eli_PATH $dyrl_eli_TARGET
                Write-Host -f GREEN " Type 'p' if you want to pause after every match, otherwise hit ENTER: " -NoNewline;
                $type = Read-Host
            }

            if( $dyrl_eli_setCase ){
                $dyrl_eli_MATCHLISTN = 0
                $dyrl_eli_MATCHLISTI = @{}
                foreach($dyrl_eli_i in $dyrl_eli_setCase){
                    Write-Host -f CYAN '   MATCH: ' -NoNewline;
                    Write-Host "$dyrl_eli_i
                    "
                    if( ! $dyrl_eli_norecord ){
                        $dyrl_eli_PATH |  Out-File -FilePath $dyrl_eli_intelpkg -Append
                        $dyrl_eli_i | Out-File -FilePath $dyrl_eli_intelpkg -Append
                    }
                    $Global:HOWMANY++
                    $dyrl_eli_MATCHLISTN++
                    $dyrl_eli_MATCHLISTI.Add($dyrl_eli_MATCHLISTN,$dyrl_eli_i)
                    $dyrl_eli_Z1 = reacquire $type
                    if( $dyrl_eli_Z1 -eq 'n'){
                        Break
                    }
                }
            }
        }

        ''
        completeMsg
    
        ## Offer to copy files
        if( ! $dyrl_eli_SINGLE ){
            if( $HOWMANY -ne 0 ){
                fileCopy
            }
        }

        

        ## Offer to perform new search on same files
        while( $dyrl_eli_YN -notMatch "^(y|n)" ){
            Write-Host '
            '
            Write-Host -f GREEN " Do you want to search the same file(s) for a different string?  " -NoNewLine;
                $dyrl_eli_Z = Read-Host

            if( $dyrl_eli_Z -eq 'n' ){
                $dyrl_eli_YN = $dyrl_eli_Z
                $dyrl_eli_ACTIVE = $false
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
        



}while( $dyrl_eli_ACTIVE -eq $true )



if( $GOBACK ){
    ''
    Write-Host -f GREEN " Hit ENTER to return to " -NoNewLine;
    Write-Host -f CYAN "$CALLER"
    Read-Host
}


Remove-Variable dyrl_eli_* -Scope Global
Return
