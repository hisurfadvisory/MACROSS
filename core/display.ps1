## Functions controlling MACROSS's display

<#
$vf19_CONSOLEH = (Get-Host).UI.RawUI.MaxWindowSize.Height
$vf19_CONSOLEW = (Get-Host).UI.RawUI.MaxWindowSize.Width
#>

$Global:vf19_colors = @{
    'w'='white'
    'b'='blue'
    'k'='black'
    'g'='green'
    'r'='red'
    'y'='yellow'
    'm'='magenta'
    'c'='cyan'
}

######################################
## MACROSS banner
######################################
function splashPage(){
    $vr = (Get-Content "$vf19_TOOLSROOT\MACROSS.ps1" | Select -Index 1) -replace "^#_ver "
    $b = 'ICAgICAgIOKWiOKWiOKWiOKVlyAgIOKWiOKWiOKWiOKVlyDilojilojilojilojilojilZcgIOKWiOKWiOKWiOKWiOK
    WiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKVlyAg4paI4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKW
    iOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKVlwogICAgICAg4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKVkeKWiOKWi
    OKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKVkOKVkOKVneKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiO
    KVlOKVkOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKVkOKVkOKVneKWiOKWiOKVlOKVkOKVkOKVkOKVkOKVnQogICA
    gICAg4paI4paI4pWU4paI4paI4paI4paI4pWU4paI4paI4pWR4paI4paI4paI4paI4paI4paI4paI4pWR4paI4paI4pWRICAg
    ICDilojilojilojilojilojilojilZTilZ3ilojilojilZEgICDilojilojilZHilojilojilojilojilojilojilojilZfil
    ojilojilojilojilojilojilojilZcKICAgICAgIOKWiOKWiOKVkeKVmuKWiOKWiOKVlOKVneKWiOKWiOKVkeKWiOKWiOKVlO
    KVkOKVkOKWiOKWiOKVkeKWiOKWiOKVkSAgICAg4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4paI4paI4pWRICAg4paI4paI4pW
    R4pWa4pWQ4pWQ4pWQ4pWQ4paI4paI4pWR4pWa4pWQ4pWQ4pWQ4pWQ4paI4paI4pWRCiAgICAgICDilojilojilZEg4pWa4pWQ
    4pWdIOKWiOKWiOKVkeKWiOKWiOKVkSAg4paI4paI4pWR4pWa4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWRICDilojil
    ojilZHilZrilojilojilojilojilojilojilZTilZ3ilojilojilojilojilojilojilojilZHilojilojilojilojilojilo
    jilojilZEKICAgICAgIOKVmuKVkOKVnSAgICAg4pWa4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ0g4pWa4pWQ4pWQ4pWQ4pW
    Q4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ0g4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWdIOKVmuKVkOKVkOKVkOKVkOKVkOKVkOKV
    neKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVnQ=='
        ## $ip ignores the local APIPA range
        $ip = $(ipconfig | Select-String "IPv4 Address" | where{$_ -notLike "* 169.254*"}) -replace "^.* : "
        $hn = $env:COMPUTERNAME
        $psv = $PSVersionTable.PSVersion -Join ''
        $vl = $vr.length; if( $vl -lt 3){$vc=4}elseif( $vl -le 4 ){$vc=3}
        elseif( $vl -le 5 ){$vc=1}else{$vc=0}
        cls
        Write-Host '
        '
        getThis $b
        Write-Host -f CYAN "$vf19_READ"
        Write-Host ' ' -NoNewline; sep '=' 70 c
        Write-Host -f YELLOW "               Welcome to Multi-API-Cross-Search, " -NoNewline;
        Write-Host -f CYAN "$USR"
        Write-Host -f YELLOW "   Host: $hn  ||  IP: $ip ||  Powershell $psv"
        Write-Host ' ' -NoNewline; sep '=' 70 c
        getThis 4pWR; $va = ''; $vb = $vf19_READ
        1..62 | %{$va += $vf19_READ}
        if($vc -gt 0){1..$vc | %{$vb += $vf19_READ}}
        Write-Host -f CYAN "  $va" -NoNewline;
        Write-Host -f YELLOW "v$vr" -NoNewline;
        Write-Host -f CYAN "$vb"
                                                                         
    }
    
    

    function macrossHelp($1){
        <#
        Display HELP for internal MACROSS functions. Send the tool name as parameter 1
        for its details and usage, or send "dev" to get a full list of descriptions.
        Calling without parameters just lists the Local Attributes table.
        #>
        $helps = @{
            'w'= @{'d'="Alias for 'Write-Host'. Send your string as the first parameter, and the first letter of the color you want to use ('k' for black, 'b' for blue) with -f (the default text color is white). Send another letter with -b to set a highlight color. If you want to set the 'NoNewline' option, use -i. Underline with -u.";'u'='Usage: w "your text" [-f b|c|g|k|m|r|y] [-b b|c|g|k|m|r|y] [-u] [-i]'}
            'screenResults'= @{'d'="Display large outputs to screen in a table format. Colorize the text by adding '<color letter>~' to the beginning of your value, i.e. `"g~`$value`" will write green text. Send a single param, -e to create the closing border after your final values.";'u'='Usage: screenResults $VALUE1 $OPTIONAL_VALUE2 $OPTIONAL_VALUE3'}
            'screenResultsAlt'= @{'d'="Similar to screenResults; send a 'header' item along with your list elements.";'u'='Usage: screenResultsAlt -h $HEADER -k $KEY1 -v $VALUE1'}
            'ord'= @{'d'='Get the decimal value of a text character';'u'='Usage: ord [text char]'}
            'chr'= @{'d'='Get the text character of a decimal value';'u'='Usage: chr [decimal value]'}
            'sheetz'= @{'d'="Output results to an excel worksheet. The -f parameter is the name of your spreadsheet. The -v parameter is the values you're writing, separated by commas. The -r parameter is the row to start writing in. If you are adding values to an existing sheet, set this to the next empty row, otherwise set to 1. The -h parameter is comma-separated column names, OR if you are editing an existing sheet/don't need column headers, you can send the number of columns you require. You can colorize text by adding a 'color~' to the beginning of any field in the first parameter's comma-separated list, or colorize the cell by adding 'cellColor~textColor~' to the value.";'u'='Usage: sheetz [-f $file] [-v $values] [-r $row] [-h total columns|comma-separated column names]'}
            'getThis'= @{'d'="Decode base64 and hex values to plaintext in the global variable `$vf19_READ; encode plaintext to base64 or hex string";'u'='Usage: getThis $string [-h HEX|-b BASE64] [-e ENCODE]'}
            'getFile'= @{'d'='Open a dialog window to let analysts select a file from any local/network location. Use -t to force only selecting specific filetypes.';'u'='Usage: $file = getFile [-t FILETYPE]'}
            'yorn'= @{'d'='Open a "yes/no" dialog to get response from analysts so your script can perform an action they choose. You must supply your scriptname with -s, and either a -t running task or a -q custom message. Use -b to specify an alternate button map. Use -i to change the icon displayed in the popup.';'u'='Usage: yorn [-t TASKNAME|-q QUESTION] [-s MYSCRIPTNAME] [-b BUTTON_MAP] [-i ICON_MAP]'}
            'pyCross'= @{'d'="Write your powershell script's results to a json file (PROTOCULTURE.eod) that can later be read by MACROSS python scripts. This file is written to a folder, 'core\macross_py\garbage_io', that MACROSS regularly empties. You only need to send the name of your script as param1 and your values as param2. If you need to write something other than the default json, send an alternate filename in param3, and your data will be written as-is to another .eod file.";'u'='Usage: pyCross "myScriptName" $VALUES_TO_WRITE $optional_alt_filename'}
            'stringz'= @{'d'="Extract ASCII characters from binary files. Call this function without parameters to open a nav window and select a file. Use -s to save outputs to a text file.";'u'="Usage: stringz [-s OUTPUT_FILE]"}
            'eMsg'= @{'d'="Send an integer 0-3 as the first parameter to display a canned message, or send your own message as the first parameter.  The second parameter is optional and will change the text color (send the first letter or 'k' for black)";'u'='Usage: eMsg [message number|your custom msg] [-c TEXT COLOR]'}
            'errLog'= @{'d'="Write messages to MACROSS' log folder. Timestamps are added automatically. You can read these logs by typing 'debug' into MACROSS' main menu.";'u'='Usage: errLog ["INFO"|"WARN"|"ERROR"] [message field 1] [message field 2]'}
            'availableTypes'= @{'d'='Search MACROSS tools by their .valtype attribute';'u'='Usage: availableTypes [-v SEARCH TERM(S)] [-l powershell|python] [-r RESPONSE TYPE] [-e FORCE EXACT MATCHES]'}
            'collab'= @{'d'="Enrich or collect data from other MACROSS scripts. An optional value can be sent as parameter three if the called script's .evalmax value is 2.";'u'='Usage: collab [SCRIPTNAME] [MYSCRIPTNAME] [OPTIONAL_PARAM]'}
            'getHash'= @{'d'='Get the hash of a file.';'u'='Usage: getHash [FILEPATH] [-a MD5|SHA256]'}
            'houseKeeping'= @{'d'="Displays a list of existing reports your script has created, and gives the option of deleting one or more of them if no longer needed.";'u'="Usage: houseKeeping [PATH_TO_FILES] [MYSCRIPTNAME]"}
            'sep'= @{'d'='Create a separator line to write on screen if you want to separate simple outputs being displayed. Use optional -c to change text color.';'u'='Usage: sep [ASCII_CHARACTER(S)] [LENGTH] [-c b|k|c|m|r|y|w]'}
            'slp'= @{'d'="Alias for 'start-sleep' to pause your scripts. Send the number of seconds to pause as parameter one. Use -m if you want to pause in milliseconds instead.";'u'='Usage: slp [LENGTH] [-m USE_MILLISECONDS]'}
            'transitionSplash'= @{'d'='This function contains various ASCII art from the MACROSS anime. You can add your own ASCII art here.';'u'='Usage: transitionSplash [1-8]'}
        }
        
        function longHelps($fct){
            $long = ''; $ex = ''; $cores = @('utility.ps1','display.ps1','validation.ps1','splashes.ps1')
            foreach($core in $cores){
                $f = "$vf19_TOOLSROOT\core\$core"
                $p = (gc $f | Select-String -Pattern "^function $fct\(")
                    
                if($p){
                    $x = (Select-String -Pattern "^function $fct\(" $f | Select-Object -ExpandProperty LineNumber) + 2
                    Break
                }
            }
            
            while($g -notlike "*||examples||"){
                $g = $(Get-Content $f | Select -Index $x)
                $x++
                if($g -like "*||examples||"){$long = " $1" + ":`n" + $long}
                else{$long += "$g`n"}
            }
            rv g
            while($g -notlike "*#>"){
                $g = $(Get-Content $f | Select -Index $x)
                $x++
                $ex += "$g`n"
            }
            $ex = $ex -replace "#>"; Return @($long,$ex)
        }
        
        if($1 -eq 'show'){
            screenResults 'UTILITIES LIST' $(($helps.keys | Sort) -join(', '))
            screenResults "w~Type help, or help + one of the above to view details. Type TL to view all MACROSS tool attributes."
            screenResults -e
            Return
        }
        if($1 -in $helps.keys){
            ''
            $lh = longHelps $1
            $lh[0]
            w '
            Hit ENTER for example usage.' 'y'; Read-Host
            $lh[1]
            ''
        }
        elseif($1 -eq 'dev'){
            1..33 | %{$m += ' '}
            screenResults "c~$m MACROSS FUNCTIONS"
            $helps.keys | Sort | %{
                screenResults $_ $($helps[$_]['d'])
                screenResults "c~$($helps[$_]['u'])"
                screenResults -e
            }
            ''
        }
        else{
            w "`n`n"
            screenResults 'c~     MACROSS Tool' 'c~          Tool Function'
            $vf19_LATTS.keys | %{
                screenResults $_ $($vf19_LATTS[$_].valtype)
            }
            screenResults -e
    
            w '
      If MACROSS crashes or you kill the session with CTRL+C, you may need to
      close the powershell window and open a new one to launch MACROSS again.
      
      ' g
        }
        ''
        w ' Hit ENTER to continue.' g; Read-Host
        
    }
    

function screenResults(){
    <#
    ||longhelp||

    screenResults [-c1 STRING] [-c2 STRING] [-c3 STRING] [-e END ROW]

    Format up to three columns of outputs to the screen; parameters you send will be wrapped 
    to fit in their columns. Call this function with -e as the *only* parameter to write the 
    closing "end of row" after all your results have been displayed.
    
    If you send a value that begins with "r~", for example "r~Windows PC", the value 
    "Windows PC" will be written to screen in red-colored text. Available colors are:
     
    "g"reen, "y"ellow, "c"yan, "m"agenta, "b"lue, "bl"ack, and "r"ed

    
    ||examples||
    Basic example of usage:

        screenResults -c1 'Title of first result' -c2 'Title of 2nd result' -c3 'Title of 3rd result'
        screenResults -c1 'First large paragraph' -c2 'Second large paragraph' -c3 'Third large paragraph'
        screenResults -e
    
    Example usage for displaying hashtable contents:

        foreach($i in $results.keys){ screenResults -c1 $i -c2 $results[$i] }
        screenResults -e

    #>
    Param(
        [string]$c1,
        [string]$c2,
        [string]$c3,
        [switch]$e=$false,
        [int]$L
    )

    ## Set default colors
    $ncolor = 'yellow'
    $v2color = 'green'
    $ht = [regex]"^[a-z]{1,2}~"
    ## Set border sizes; resizing with $4 is not implemented yet!
    if($4 -and $4 -gt 90){
        $tw = $4
    }
    else{
        $tw = 90
    }
    getThis 4pWR; $c = $vf19_READ
    $r = $c
    getThis 4omh
    1..$tw | %{$r = $r + $vf19_READ}; $r = $r + $c
    if($e){
        Write-Host -f GREEN $r
        Return
    }
    if($c1 -Match $ht){
        $ncolor = $vf19_colors[$($c1 -replace "~(.|`n)+")]
        $c1 = $c1 -replace "^([a-z]{1,2}~)?"
    }
    

    
    ## This function counts characters to create borders based on string-length
    ## and the number of inputs. It tries not to split words but create \newlines
    ## based on whitespace.
    function genBlocks($outputs,$max,$min){
        $o1 = @()
        $o2 = @()
        $o3 = $outputs.length
        if($o3 -gt $max){
            if($outputs -Match ' '){
                $outputs = $outputs -replace '(\s\s+|\t|`n)',' '
                $p = $outputs -Split(' ')
                $wide = 0
            }
            else{
                $cut = $max - $o3
                $o2 += $last.Substring(0,$max)
                $o2 += $last.Substring($cut,-1)
            }
        }
        else{
            while($o3 -ne $max){
                $outputs = $outputs + ' '
                $o3++
            }
            $o2 += $outputs
        }

        if($p){
            $p | ForEach-Object {
                $l = $($_.length)
                $wide = $wide + ($l + 1)
                    
                if($wide -lt $min){
                    $o1 += $($_ + ' ')
                }
                else{
                    $block = $o1 -Join(' ')
                    $block = $block -replace "\s\s+",' '
                    $bl = $($block.length)
                    if($bl -gt $max){                   ## Cut extra long strings without whitespace
                        $cut = $max - $bl
                        $o2 += $last.Substring(0,$max)
                        $o2 += $last.Substring($cut,-1)
                    }
                    else{
                        if($bl -lt $max){
                            while($bl -ne $max){
                                $block = $block + ' '   ## Add whitespace if the line is < $max
                                $bl++
                            }
                        }                        
                        $o2 += $block
                    }
                    Clear-Variable o1                   ## Reset the list
                    $o1 += $($_ + ' ')                  ## Add the current word to the list
                    $wide = ($l + 1)                    ## Reset the line length
                    
                }
                    
                ## If the current $o1 item is the last item from $outputs, add it to
                ## the $o2 response
                if($_ -eq $p[-1]){
                        $last = $o1 -Join(' ')
                        $l = $last.length
                        if($l -gt $max){                   ## The last item might be > $max
                            $cut = $max - $l
                            $o2 += $last.Substring(0,$max)
                            $o2 += $last.Substring($cut,-1)
                        }
                        else{
                            if($l -lt $max){
                                while($l -ne $max){
                                    $last = $last + ' '    ## Add spaces if the line is < $max
                                    $l++
                                }
                            }
                            $o2 += $last
                        }
                }
                    
                    
            }
        }
        Return $o2
    }

    $NAME = $c1
    $wide1 = $NAME.length

    if($c2){
        if($c2 -Match $ht){
            $v1color = $vf19_colors[$($c2 -replace "~(.|`n)+")]
            $c2 = $c2 -replace "^([a-z]{1,2}~)?"
        }
        $VAL1 = $c2
        $wide2 = $c2.length
        
    
        if($c3){
            if($c3 -Match $ht){
                $v2color = $vf19_colors[$($c3 -replace "~(.|`n)+")]
                $c3 = $c3 -replace "^([a-z]{1,2}~)?"
            }
            $VAL2 = $c3
            $wide3 = $c3.length
        }
        
        

        [array]$BLOCK1 = genBlocks $NAME 23 23
        $ct1 = $BLOCK1.count
        if($VAL2){
            [array]$BLOCK2 = genBlocks $VAL1 34 32
            [array]$BLOCK3 = genBlocks $VAL2 28 25
            $ct3 = $BLOCK3.count
        }
        else{
            [array]$BLOCK2 = genBlocks $VAL1 64 62
        }
        $ct2 = $BLOCK2.count

    }
    else{
        [array]$BLOCK1 = genBlocks $NAME 89 87
    }

    
    ## Generate empty lines to keep columns uniform-ish (fonts are not usually monospace,
    ## but this will get close enough)
    1..$($tw-66) | %{$empty1 += ' '}                       ## 25 char length 1st column
    if($ct3){
        1..$($tw-55) | %{$empty2 += ' '}                   ## 35 char length 2nd column with 3rd column
        1..$($tw-61) | %{$empty3 += ' '}                   ## 28 char length 3rd column
    }
    elseif($ct2){
        1..$($tw-25) | %{$empty2 += ' '}                   ## 64 char length 2nd column WITHOUT 3rd column
    }


    $index1 = 0
    $index2 = 0
    $index3 = 0
    $linenum = 0
    Write-Host -f GREEN $r

    <#
    Outputs will get formatted to screen based on:
        -how many values got passed in (1, 2, or 3)
        -how many words/chars are in each output
        -which outputs have the most words in them
        -I hate math
    #>
    if($ct3){
        $countdown = $ct1 + $ct2 + $ct3
        while($countdown -ne 0){
            Write-Host -f GREEN $c -NoNewline;
            if($BLOCK1[$index1]){
                Write-Host -f $ncolor " $($BLOCK1[$index1])" -NoNewline;
                $index1++
                $countdown = $countdown - 1
            }
            else{
                Write-Host $empty1 -NoNewline;
            }
            Write-Host -f GREEN $c -NoNewline;
            if($BLOCK2[$index2]){
                if($v1color){
                    Write-Host -f $v1color " $($BLOCK2[$index2])" -NoNewline;
                }
                else{
                    Write-Host " $($BLOCK2[$index2])" -NoNewline;
                }
                $index2++
                $countdown = $countdown - 1
            }
            else{
                Write-Host $empty2 -NoNewline;
            }
            Write-Host -f GREEN $c -NoNewline;
            if($BLOCK3[$index3]){
                Write-Host -f $v2color " $($BLOCK3[$index3])" -NoNewline;
                $index3++
                $countdown = $countdown - 1
            }
            else{
                Write-Host $empty3 -NoNewline;
            }
            Write-Host -f GREEN $c

        }


    }
    elseif($ct2){
        if($ct1 -gt $ct2){
            if($ct2 -eq 1){
                $middle = ([int][Math]::Ceiling($ct1/2) - 1)
            }
            else{
                $middle = ([int][Math]::Ceiling($ct1/$ct2) - 1)
            }

            $BLOCK1 | %{
                if($linenum -lt $middle){
                    Write-Host -f GREEN "$c " -NoNewline;
                    Write-Host -f $ncolor $_ -NoNewline;
                    Write-Host -f GREEN $c -NoNewline;
                    Write-Host $empty2 -NoNewline;
                    Write-Host -f GREEN $c
                    $linenum++
                }
                else{
                    Write-Host -f GREEN "$c " -NoNewline;
                    Write-Host -f $ncolor "$_" -NoNewline;
                    Write-Host -f GREEN $c -NoNewline;
                    if($BLOCK2[$index2]){
                        if($v1color){
                            Write-Host -f $v1color " $($BLOCK2[$index2])" -NoNewline;
                        }
                        else{
                            Write-Host " $($BLOCK2[$index2])" -NoNewline;
                        }
                        Write-Host -f GREEN $c
                        $index2++
                    }
                    else{
                        $linenum = -1
                        Write-Host $empty2 -NoNewline;
                        Write-Host -f GREEN $c
                    }
                }
            }

        }
        elseif($ct2 -gt $ct1){
            if($ct1 -eq 1){
                $middle = ([int][Math]::Ceiling($ct2/2) - 1)
            }
            else{
                $middle = ([int][Math]::Ceiling($ct2/$ct1) - 1)
            }

            $BLOCK2 | %{
                Write-Host -f GREEN $c -NoNewline;
                if($linenum -lt $middle){
                    Write-Host $empty1 -NoNewline;
                    $linenum++
                }
                else{
                    if($BLOCK1[$index1]){
                        Write-Host -f $ncolor " $($BLOCK1[$index1])" -NoNewline;
                        $index1++
                    }
                    else{
                        $linenum = -1
                        Write-Host $empty1 -NoNewline;
                    }
                }
                Write-Host -f GREEN $c -NoNewline;
                if($v1color){
                    Write-Host -f $v1color " $_" -NoNewline;
                }
                else{
                    Write-Host " $_" -NoNewline;
                }
                Write-Host -f GREEN $c
            }
        }
        else{
            $BLOCK2 | %{
                Write-Host -f GREEN $c -NoNewline;
                Write-Host -f $ncolor " $($BLOCK1[$index1])" -NoNewline;
                $index1++
                Write-Host -f GREEN $c -NoNewline;
                if($v1color){
                    Write-Host -f $v1color " $_" -NoNewline;
                }
                else{
                    Write-Host " $_" -NoNewline;
                }
                Write-Host -f GREEN $c
            }
        }

            
        
    }
    else{
        $BLOCK1 | %{
            Write-Host -f GREEN "$c " -NoNewline;
            Write-Host -f $ncolor $_ -NoNewline;
            Write-Host -f GREEN $c
        }
    }

}




function screenResultsAlt($h,$k,$v,[switch]$e=$false){
    <#
    ||longhelp||

    screenResultsAlt [-h HEADER] [-k ITEM NAME] [-v ITEM VALUE]

    Alternate output format for MACROSS results; don't use this for outputs with long
    string values; use screenResults instead!

    The first parameter -h is the header for each item. When beginning your output,
    send the -h, -k and -v values together. Subsequent outputs under the same header
    should only contain -k and -v.

    The second and third parameters (-k and -v) are written below the header like a 
    key-value pair. The -k value will get truncated if longer than 14 chars.

    As with screenResults, you can use "<COLOR FIRST LETTER>~" to highlight your values. 
    Send a single parameter, -e, to close out the table.
        
    ||examples||
    Example usage:
        $process = 'rundll32.exe'
        $name1 = 'Parent'
        $value1 = 'r~acrobat.exe'
        $name2 = 'ParentID'
        $value2 = '2351'

        screenResultsAlt -h $process -k $name1 -v $value1
        screenResultsAlt -k $name2 -v $value2
        screenResultsAlt -e

    The above will write to screen, with acrobat.exe in red:

        |||||| rundll32.exe
        ============================================================================
        Parent    |  acrobat.exe
        ParentID  |  2351
        ============================================================================



    #>
    $hcolor = 'CYAN'
    $kcolor = 'GREEN'
    $vcolor = 'YELLOW'
    $r = '  '
    $ht = [regex]"^[a-z]{1,2}~"
    1..76 | %{$r += '='}
    getThis 4pWR4pWR4pWR4pWR4pWR4pWR; $c6 = $vf19_READ
    getThis 4pWR; $c1 = $vf19_READ
    

    if($h -Match $ht){
        $hcolor = $vf19_colors[$($h -replace "~.+")]
        $h = $h -replace "^([a-z]+~)?"
    }
    if($k -Match $ht){
        $kcolor = $vf19_colors[$($k -replace "~.+")]
        $k = $k -replace "^([a-z]+~)?"
    }
    if($v -Match $ht){
        $vcolor = $vf19_colors[$($v -replace "~.+")]
        $v = $v -replace "^([a-z]+~)?"
    }



    if($e){
        Write-Host -f GREEN $r
    }
    else{
        [string]$k = '  ' + $k
        if($v){
            [int]$kl = $($k.length)
            if($kl -gt 19){
                $k = $k.Substring(0,15)
                $k = $k + '... '
            }
            else{
                while($kl -ne 19){
                    $k = $k + ' '
                    $kl++
                }
            }
        }
        if($h){
            Write-Host -f $hcolor "  $c6 $h"
            Write-Host -f GREEN $r
        }
        if($k -and $v){
            Write-Host -f $kcolor "$k" -NoNewline;
            Write-Host -f GREEN "$c1" -NoNewline;
            Write-Host -f $vcolor " $v"
        }
        elseif($k){ Write-Host -f $kcolor "$k" }
        elseif($v){ Write-Host -f $kcolor "$v" }
    }
}



function sep(){
    <#
    ||longhelp||

    sep -a [char/string] -L [count] -c [text color]

    When writing outputs to screen and you're not using screenResults(), this
    function can write a simple separator if you need to break up lines.

    
    ||examples||
    Examples -- Create a 72 char-length line of "*":
    
        sep * 72

    Create 16 blocks of "~ * ~" in yellow text:

        sep -a "~ * ~" -L 72 -c y

        OR

        sep "~ * ~" 72 y

                                        
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [string]$a,
        [Parameter(Mandatory=$true)]
        [int]$L,
        [string]$c = 'w'
    )
    $b = ' '
    1..$L | %{$b += $a}
    Write-Host -f $($vf19_colors[$c]) $b
}



function w(){
    <#
    ||longhelp||

    w [-t TEXT] [-f TEXT COLOR] [-b BACKGROUND COLOR] [-i INLINE] [-u UNDERLINE]

    I got sick of typing "Write-Host", gimme a break powershell.

    Send your text as the first param, and the **first letter** of the text color you 
    want to colorize with ("k" for black, "b" for blue) with -f.
    
    You can set the background color for the text with -b, and use -i to set the 
    "-NoNewLine" option (continue writing more text on the same line).
    
    
    ||examples||
    Write green text:
    
        w "A string of text." g
    
    Write a multi-color string where "test" is yellow and underlined with red background:
    
        w "A string of " g -i; w 'test' -f y -b r -u -i; w "words" g

    Set background color to black with default text color white:
    
        w "A string of text." -b k


    #>
    param(
        [Parameter(Mandatory=$true)]$t,
        [string]$f='w',
        [string]$b=$null,
        [switch]$i=$false,
        [switch]$u=$false
    )
    $fg = $($vf19_colors[$f])
    if($f -in $vf19_colors.keys){ $fg = $($vf19_colors[$f]) }
    if($b -in $vf19_colors.keys){ $bg = $($vf19_colors[$b]) }
    if($i -and $u -and $bg){
        Write-Host -b $bg -f $fg "$([char]27)[4m$t$([char]27)[24m" -NoNewline;
    }
    elseif($i -and $bg){
        Write-Host -b $bg -f $fg "$t" -NoNewline;
    }
    elseif($u -and $bg){
        Write-Host -b $bg -f $fg "$([char]27)[4m$t$([char]27)[24m"
    }
    elseif($bg){
        Write-Host -f $fg -b $bg "$t"
    }
    elseif($i -and $u){
        Write-Host -f $fg "$([char]27)[4m$t$([char]27)[24m" -NoNewline;
    }
    elseif($u){
        Write-Host -f $fg "$([char]27)[4m$t$([char]27)[24m"
    }
    elseif($i){
        Write-Host -f $fg "$t" -NoNewline;
    }
    else{
        Write-Host -f $fg "$t"
    }


}



function slp($s,[switch]$m=$false){
    <#
    ||longhelp||

    slp [number of seconds] -m

    Alias for "start-sleep". Pass a number of seconds as your first parameter, and
    -m if you want to pause in milliseconds instead.

    ||examples||
    Pause for 5 seconds:

        slp 5
    
    Pause for 500 milliseconds:

        slp 500 -m


    #>
    if($m){
        Start-Sleep -Milliseconds $s
    }
    else{
        Start-Sleep -Seconds $s
    }
}




######################################
## Perform startup checks
######################################
function startUp([switch]$init=$false){
    if($init){
        function e(){ Return $(Get-Random -min 10000000000000 -max 99999999999999)}
        if(! (Test-Path "$env:LOCALAPPDATA\Temp\MACROSS")){
            New-Item -Path "$env:LOCALAPPDATA\Temp\" -Type Directory -Name MACROSS | Out-Null
        }$ml=setML;getThis -h $ml[13]; . $([scriptblock]::Create("$vf19_READ"))
        battroid -n vf19_TMP -v "$([string]$env:LOCALAPPDATA)\Temp\MACROSS"
        battroid -n vf19_GPOD -v $([System.Tuple]::Create($(e),$(e)))

        ## MOD SECTION ##
        ## You can set additional user default preferences here, but you'll also need to add extra
        ## code where appropriate for those preferences to take effect (see the validation.ps1 file for
        ## the "persist_protoculture" setting, for example)
        if( ! (Test-Path "$vf19_TOOLSROOT\core\preferences.txt")){
            "persist_protoculture=true`nuse_pythonv2=false" | Out-File "$vf19_TOOLSROOT\core\preferences.txt"
        }
        
        ## Verify required config files
        if($vf19_CONFIG[0] -Like "http*"){ if( -not (curl.exe -sk $vf19_CONFIG[0] | sls 'MACROSS') ){setConfig} }
        elseif(! (Test-Path $($vf19_CONFIG[0]))){ setConfig }
        
        userPrefs

        ## MOD SECTION! ##
        ####################################################################################################
        ## Check if necessary programs are available; add as many as you need below after the 'wireshark' check
        ####################################################################################################
        #$INST = Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
        $INST = Get-ChildItem 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
        foreach($i in $INST){
            $prog = $i.GetValue('DisplayName')
            if($prog -Like 'python*'){
                $Global:MONTY = $true
                battroid -n vf19_pylib -v "$vf19_TOOLSROOT\core\macross_py"
                cleanGBIO                                               ## Make sure any temp .eod files are disposed of
                if($vf19_pylib -notIn $env:PYTHONPATH){ $env:PYTHONPATH = $vf19_pylib + $env:PYTHONPATH }
            }
            if($prog -match 'nmap'){ $Global:MAPPER = $true }        ## Can use nmap, yay!
            if($prog -match 'wireshark'){ $Global:SHARK = $true }    ## Can use wireshark, yay!

        }; rv i,INST,prog
    }


	## Arm the missile pod $vf19_MPOD (although Basara's VF-19 only carried missiles once):
    ## The contents of $vf19_MPOD are the values you added to the config.conf file via the
    ## MACROSS configuration wizard (which runs the first time you load MACROSS or when
    ## you type "config" in the main menu). When your script needs one of these values,
    ## you can access it via
    ##
    ##       getThis vf19_MPOD['key']; $value = $vf19_READ
    ##
    ## where 'key' is the 3-character ID you created when adding values to the config.conf
    ## file.
    ##
    if(! $vf19_PYG){
        battroid -n vf19_PYG -v @("$vf19_pylib\garbage_io","$vf19_pylib\garbage_io\PROTOCULTURE.eod")
    }
    if(! $vf19_MPOD){
        $defs=@{};$Global:vf19_PYPOD='';getThis -h $((setML)[14])
        . $([scriptblock]::Create("$vf19_READ"));$p=@()
        $y = setCC -c; getThis QEBA; $9d = "$vf19_READ"
        $j = setCC
        $b = $(setReset -d $y $j) -Split $9d
        
        foreach($c in $b){
            $d = $c.Substring(0,3)
            $e = $c -replace "^$d"
            $defs.Add($d,$e)
            if($MONTY -and $d -ne 'a2z'){ $p += $c }
        }
        battroid -n vf19_MPOD -v $defs; getThis $vf19_MPOD.int
        battroid -n N_ -v @($vf19_READ,$([int[]](($vf19_READ -split '') -ne '')))
        if($p.length -gt 0){ $Global:vf19_PYPOD = $p -join(',') }

    }
}


<################################
## Generate dynamic menu for tool selection
################################>
function chooseMod(){
    
    $extralist = @(
        'config',
        'dec',
        'enc',
        'shell',
        'proto',
        'splash',
        'strings',
        'refresh'
    )

    ## Check for python-generated PROTOCULTURE & count the available tools
    $c = gc -raw "$($vf19_PYG[1])" | ConvertFrom-Json
    $c = $c."$($c.psobject.properties.name)".result
    $toolcount = $vf19_LATTS.count
    if( $c -and ! $PROTOCULTURE ){ $Global:PROTOCULTURE = $c }
    if($toolcount -gt 10){$vf19_MULTIPAGE=$true}
    $Global:vf19_PAGECT = [math]::Truncate(($toolcount/10) + 1)

        
    getThis 4pWR

    $vf19_LATTS.keys | Sort | Select -Skip $($vf19_PAGE * 10) | Select -First 10 | %{
         w ' ' -i; sep '=' 70 c
        $desc = $vf19_LATTS[$_].desc
        $cname = $vf19_LATTS[$_].name
            
        if($vf19_LATTS[$_].pos -lt 10){ $d1 = " $($vf19_LATTS[$_].pos)" + ". $cname" }
        else{ $d1 = [string]$($vf19_LATTS[$_].pos) + ". $cname" }
        $d0 = $d1.Length
        if($d0 -lt 15){
            $d2 = (15 - $d0)
            while($d2 -gt 1){ $d1 += ' '; $d2-- }
        }
        elseif($d0 -gt 15){
            $d1 = $d1.substring(0,15)
        }
        w "   $d1" y -i; w $vf19_READ c -i; w " $desc" y
    }

    w ' ' -i; sep '=' 70 c
    ''

    SJW -menu     ## check user's privilege LOL
    if( $PROTOCULTURE ){
        w '      ' -i; w ' PROTOCULTURE IS HOT (enter "proto" to view & clear it) ' r k 
    }
    ''

    if( $vf19_MULTIPAGE ){
        w "   -There are $toolcount tools available. Enter " g -i; w 'p' 'y' -i; w ' for the next Page.' g
    }
    w '   -Select the module you want (' g -i; w "1 - $toolcount" 'y' -i; w ').' g
    w '   -Enter "' g -i; w 'help' 'y' -i;
    w '" and the number of the tool to view its help page' g
    w '   -Type ' g -i; w 'shell' 'y' -i;
    w ' to pause and run your own commands' g
    w '   -Type ' g -i; w 'strings' 'y' -i; w ' to extract strings from binaries (-s to save)' g
    w '   -Type ' g -i; w 'dec' 'y' -i; w ' or ' g -i; w 'enc' 'y' -i; w ' to process Hex/B64 encoding.' g
    w '   -Type ' g -i; w 'q' 'y' -i; w ' to quit.
    ' g

    ## If version control is in use, offer options to pull fresh or updated
    ## copies of all the scripts.
    if( $vf19_VERSIONING ){
        w '                               TROUBLESHOOTING:
   If the console is misbehaving, you can enter ' g -i;
        w 'refresh' 'c' -i;
        w ' to automatically
   pull down a fresh copy. Or, if one of the tools is not working as you
   expect it to, enter the module # with an ' g -i;
        w 'r' 'c' -i;
        w " to refresh that script
   (ex. '3r').
   
   " g
   }



    w '                        SELECTION: ' g -i
        $Global:vf19_Z = Read-Host

        
        if( $vf19_Z -in $extralist ){
            extras $vf19_Z
        }
        elseif( $vf19_Z -Like "help*" -and $vf19_Z -Match "\d"){
            $Global:HELP = $true
            $Global:vf19_Z = $vf19_Z -replace "help(\s)?"
            availableMods $([int]$vf19_Z)
        }
        elseif( $vf19_Z -Like "help*"){
            macrossHelp "$($vf19_Z -replace "help(\s)?")"
        }
        elseif( $vf19_Z -Match $vf19_CHOICE ){
            if( $vf19_Z -Like "*r" ){
                $Global:vf19_Z = $vf19_Z -replace 'r'
                $Global:vf19_REF = $true
            }
            elseif( $vf19_Z -Like "*s" ){
                $Global:vf19_Z = $vf19_Z -replace 's' 
                $Global:vf19_OPT1 = $true
            }
            elseif( $vf19_Z -Like "*w" ){
                $Global:vf19_Z = $vf19_Z -replace 'w'
                $Global:vf19_NEWWINDOW = $true
            }
            else{
                $Global:HELP = $false
                $Global:vf19_OPT1 = $false
            }
            availableMods $([int]$vf19_Z)
        }
        elseif( $vf19_Z -eq 'p' ){
            if( $vf19_MULTIPAGE ){
                scrollPage
            }
            $Global:vf19_Z = $null
        }
        elseif( $vf19_Z -eq 'q' ){
            varCleanup -c
            Exit
        }
        elseif( $vf19_Z -Match "^debug" ){
            if($vf19_Z -Match ' '){ $p = $($vf19_Z -replace "^debug ") }
            else{ $p = $null }
            cls; debugMacross $p
        }
        Clear-Variable -Force vf19_Z

}


################################
## If more than 9 tools available, allow changing menu pages
################################
function scrollPage(){
    if($vf19_pagecount -gt 1){
        $Global:vf19_MPAGE = $vf19_MPAGE + 1
        if($vf19_MPAGE -ge $vf19_pagecount){
            $Global:vf19_MPAGE = 0
        }
        splashPage
        chooseMod
    }
}

