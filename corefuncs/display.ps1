## Functions controlling MACROSS's display

<#
$dyrl_CONSOLEH = (Get-Host).UI.RawUI.MaxWindowSize.Height
$dyrl_CONSOLEW = (Get-Host).UI.RawUI.MaxWindowSize.Width
#>

$Global:dyrl_colors = @{
    'a'='gray'
    'w'='white'
    'b'='blue'
    'k'='black'
    'g'='green'
    'r'='red'
    'y'='yellow'
    'm'='magenta'
    'c'='cyan'
}

function minmay($s){    #mp
    <#
    ||shorthelp||
    minmay -s <0 - 11>

    ||longhelp||
    Display Macross ascii art. There are 12 images available,
    0 - 11. Add more in the corefuncs\resources\macross_art.json
    file.

    Anime note: Lynn Minmay helped defeat the overwhelming military forces
    of the giant Zentradi military fleets using... 80s JPOP music!

    ||examples||
    
    ## Display VF-1 Skull Leader portrait:
        minmay 0

    #>
    $json = "$dyrl_RESOURCES\macross_art.json"
    $emsg = "Missing required $json file"
    if(Test-Path $json){
        $screens = Get-Content $json | ConvertFrom-Json
        gerwalk $screens.art[$s]
        w $dyrl_PT c -n
        w "`n$($screens.titles[$s])" c
    }
    else{ errMsg $emsg -c y -f 'MACROSS.minmay' }
}

function splashBanner(){
    $welcome = ''
    @(31361,25731,12521,12502,12495,12540,12488) | %{
        $welcome = "$welcome$(chr $_)"
    }
    $mip = setLocal -m
    $vl = "$dyrl_VERSION".length
    if(! $pver){
        $Script:pver = $(($PSVersionTable.PSVersion -Join '.').substring(0,3))
    }

    $b1 = battroid '      MACROSS'

    cls
    "`n"
    $bar = battroid -bar
    $p = "Powershell $pver, $dyrl_PYVERS"
    $hinfo =  " HOST: $dyrl_HN0 $bar  IP: $mip"
    while($hinfo.length -lt 72){$hinfo += ' '}
    $sep = 67 - $p.length
    w $b1 c -i -n
    w " v$dyrl_VERSION" c
    w '' -i; sep '=' 72 c
    w "               $welcome," y -i
    w $USR
    w '' -i; w $hinfo c -u
    w '' -i; sep $bar $sep c -i -u; w $p c -i -u; sep $bar 3 c -u

}


function battroid($alpha,[switch]$bar=$false){   #mp
    <#
    ||shorthelp||
    battroid [-a TEXT_TO_WRITE] [-b BAR_CHARACTER <exclusive from -a>]

    ||longhelp||
    Convert a single word or letter into ascii block art. Only works with alpahumeric
    chars and limited special characters. If your text has preceding whitespace, it will
    be preserved. send your text using the -alpha parameter.

    Use -b (without sending any text) to get the non-standard separator character used
    in MACROSS's main menu.

    This function relies on the alphanum.json file located in the $dyrl_RESOURCES
    folder. If you delete it, this function no longer works.

    Accepted punctuation/special chars:  ? ! . : - _ @

    ||examples||

    Get a bar and a block title for your script:

        $bar = battroid -b
        $title = battroid '  MYSCRIPT'

        write-host $title
        write-host $bar

    #>

    if($bar){ Return $(chr 9553) }
    $json = "$dyrl_RESOURCES\alphanum.json"       ## This file contains the block text-art
    if(! (Test-Path $json)){ Return $alpha }
    $filter = New-Object System.Collections.Arraylist
    $title = ''
    $buffer = ''
    $alpha = $alpha -Split ''
    0..$(($alpha | ?{$_ -eq ' '}).count) | %{$buffer += ' '}
    $filter = New-Object System.Collections.Arraylist
    $blocks = $(Get-Content $json | ConvertFrom-Json)
    $blocks = $($blocks.alpha -Join '')
    gerwalk $blocks
    try{ $ref = $dyrl_PT | ConvertFrom-Json }
    catch{ Read-Host $error[0] }
    foreach($a in $alpha){
        if($a -in $ref.PSObject.Properties.Name){
            $filter.Add($a) | Out-Null
        }
    }
    0..5 | %{
        $title += $buffer
        foreach($f in $filter){
            $title += $ref.$f[$_]
        }
        if($_ -lt 5){ $title += "`n" }
    }

    Return $title
}

function toolInfo($tool){   #mp
    <#
    ||shorthelp||
    Tool attribute summary for help pages
    Usage:
        toolInfo -t <tool name>

    ||longhelp||
    Displays a tool's summary for its help pages.

    ||examples||

    Display the .valtype, .author and .ver attributes of MYSCRIPT:

        toolInfo MYSCRIPT

    #>
    w "`n VERSION: " -i
    w "$($dyrl_LATTS.$tool.ver)" y -u -n
    w "AUTHOR:  " -i
    w "$($dyrl_LATTS.$tool.author)" y -u -n
    w "PURPOSE: " -i
    w "$($dyrl_LATTS.$tool.valtype)`n" y -u -n
}


## Names of the MACROSS functions that have help pages (marked "#mp" in the core files)
function macrossFuncList_(){
    $cores = @('utility.ps1','display.ps1','validation.ps1','kawamoriNG.ps1','configurations.ps1')
    $list = foreach($core in $cores){
        $f = "$dyrl_MACROSS\corefuncs\$core"
        if(Test-Path $f){
            Select-String -Pattern "^function \w+\(.+mp$" $f | %{ $_.Line -replace "^function " -replace "\(.+" }
        }
    }
    Return @($list | ?{ $_ })
}

function macrossHelp($1,[switch]$full=$false,[switch]$help=$false){
    <#
    Display HELP for internal MACROSS functions. Send the tool name as parameter 1
    for its details and usage, or send "dev" to get a full list of descriptions.
    Calling without parameters just lists the Local Attributes table.
    #>
    $cores = @('utility.ps1','display.ps1','validation.ps1','kawamoriNG.ps1','configurations.ps1')
    if($full){
        $dyrl_LATTS.keys | %{
            screenResults "$($dyrl_LATTS[$_].name) v$($dyrl_LATTS[$_].ver)" "Evaluates $($dyrl_LATTS[$_].valtype)"
        }
        screenResults -e

        w "`n`n
        -MACROSS uses no-tamper session tokens. If your session crashes or
        you exit by hitting CTRL+C, you will need to completely close powershell,
        open a new window and launch MACROSS again to generate a new token, otherwise
        you will get a 'security group' error.

        -When a script is running, it will pause if you click anywhere in
        the powershell window. Hitting any key will resume the script, but
        will also enter that key into the next available prompt. Use the
        BACKSPACE or back-arrow keys to avoid getting errors.

        -If you are the MACROSS admin controlling configurations, you need to export
        your configurations for your team any time you make changes. Type `"export`"
        in the main menu. Users will need to place your exported file in their corefuncs
        folder.

        -To add your own automations in MACROSS, reference the first three lines
        in any diamond script located in the diamonds folder. Your automation will
        need to mirror the information types in those lines. You can type `"debug`"
        in the main menu to test how MACROSS's functions would work in your script.
        When your code is finished, place it in the diamonds folder (it may need
        to be digitally signed using the LEGIT diamond script).

        -If you experience any bugs or issues, notify the MACROSS admin.

        Hit ENTER to go back." y
        Read-Host; Return
    }
    elseif($help){
        gerwalk $dyrl_CONF.cre
        $error[0]
        w "`n  Looks like the last task did not complete smoothly. If you are experiencing
  issues with MACROSS, and using the refresh `"r`" option with tools is not
  resolving them: exit MACROSS, replace the local MACROSS folder with a fresh
  copy, and run MACROSS.ps1 again." y
        w "`n  Hit ENTER to close this message." y
        Read-Host
        Return
    }

    function manPages_($fct){
        foreach($core in $cores){
            $f = "$dyrl_MACROSS\corefuncs\$core"
            $line = (Select-String -Pattern "^function $fct\(" $f).lineNumber
            if($line){
                $i = 0
                $key = 'k'
                $helpfile = @{}
                $short = @(); $long = @(); $example = @()
                (Get-Content $f) | Select -Skip $($line) | %{
                    if($_ -Like "*#>*"){ Break }
                    else{
                        $skip = $false
                        if($_ -Like "*||shorthelp||*"){$key = 's'; $skip = $true}
                        elseif($_ -Like "*||longhelp||*"){$key = 'l'; $skip = $true}
                        elseif($_ -Like "*||examples||*"){$key = 'e'}
                        if(! $skip){
                            if($key -in $helpfile.keys){ $helpfile.$key += $_ }
                            else{ $helpfile.Add($key,@($_)) }
                        }
                     }
                     $i++
                }
            }
        }
        $short = ($helpfile.s) -Join "`n"
        $long = ($helpfile.l) -Join "`n"
        $example = ($helpfile.e) -Join "`n"
        Return @($short,$long,$example)
    }

    $functions = macrossFuncList_

    if($1 -eq 'show'){
        screenResults 'w~MACROSS FUNCTIONS' "y~$(($functions | ?{$_ -ne ''} | Sort) -join(', '))"
        screenResults "w~Type help, or help + one of the above to view details. Type TL to list all MACROSS tool properties, or TL + the toolname to view a specific tool."
        screenResults -e
        Return
    }

    cls
    if($1 -in $functions){
        $manual = manPages_ $1
            if($manual[0]){
            "`n`n$($manual[0])"
            w '

            Enter "more" for more details, or ENTER to quit: ' y -i
            $hz = Read-Host
            if($hz -eq 'more'){
                $manual[1]
                "`n`n$($manual[2])`n`n"
            }
        }
    }
    elseif($1 -eq 'dev'){
        screenResults "c~$(' '*33) MACROSS FUNCTIONS"
        foreach($f in $functions){
            try{ $h = manPages_ $f }
            catch{ $h = $false }
            if($h){ screenResults $f $($h[0]) }
        }
        screenResults -e
        ''
    }
    else{
        TL
    }

    w "`n  Hit ENTER to go back." g
    Read-Host

}


function screenResults(){   #mp
    <#
    ||shorthelp||
    Display large paragraphs to screen in a table format. Colorize the text by adding
    '<color letter>~' to the beginning of your value, i.e. `"g~`value`" will write
    green text. Use -e to create the closing border after your final values.
    Usage:
        screenResults [-c1 STRING | -c2 STRING | -c3 STRING | -e]
            [-o OUT_FILENAME]

    ||longhelp||
    Format up to three columns of outputs to the screen; parameters you send will be
    wrapped to fit in their columns (up to 3 separate columns). Call this function
    with -e as the *only* parameter to write the closing "end of row" after all your
    results have been displayed.

    Note that this parses sentences & words; trying to format a huge unbroken string
    of characters with no whitespace or newlines will probably not work. Things like
    file hashes are okay.

    If you send a value that begins with "r~", for example "r~Windows PC", the value
    "Windows PC" will be written to screen in red-colored text. You can use any color
    recognized by powershell's "write-host -f" option ("g"reen, "y"ellow, "b"lue, etc.,
    or "k" for black)

    To write this output to a file instead of on the screen, use -o and provide a
    filename. The data will be written to the $dyrl_OUTPUTS folder as a txt file.

    ||examples||
    Basic example of usage:

        screenResults -c1 'Title one' -c2 'Title two' -c3 'Title three'
        screenResults -c1 'First results' -c2 'Second results' -c3 'Third results'
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
        [int]$L,
        [string]$outfile
    )

    ## Set default colors
    $ncolor = 'yellow'
    $v2color = 'green'
    $ht = [regex]"^[a-z]{1,2}~"
    $tw = 90

    if($outfile){ $write_to = "$dyrl_OUTFILES\$outfile`.txt"}
    else{ $write_to = $false }

    function saveOrShow_($100,$cy='GREEN',[switch]$nnl,[switch]$endline){
        if($write_to){
            if($100 -eq $r){$100 = "$fr$c"}
            if(! (Test-Path $write_to)){ noBOM -t "$100`n" -f $write_to }
            elseif($endline){ noBOM -t "$100`n" -f $write_to -a }
            elseif($nnl){ noBOM -t $100 -f $write_to -a }
            else{ noBOM -t "$100" -f $write_to -n }
        }
        else{
            if($nnl){ Write-Host -f $cy $100 -NoNewline}
            else{ Write-Host -f $cy $100 }
        }
    }

    ## Clean up trailing empty space
    $strip = [regex]"(\s|\t|\n|\r)+$"
    $c1 = $c1 -replace $dyrl_ASCII -replace $strip,' ' -replace "`n",' ' -replace "`r",' '
    if($c2){ $c2 = $c2 -replace $dyrl_ASCII -replace $strip,' ' -replace "`n",' ' -replace "`r",' ' }
    if($c3){ $c3 = $c3 -replace $dyrl_ASCII -replace $strip,' ' -replace "`n",' ' -replace "`r",' ' }

    gerwalk '4pWR'; $c = $dyrl_PT
    $r = $c
    gerwalk '4omh'; $hb = $dyrl_PT
    1..$tw | %{$r += $hb}; $r = "$r$c"
    $fr = $r -replace ".{26}$","$hb"     ## Have to play around with the border length when writing to file
    if($e){
        saveOrShow_ $r -n
        Return
    }
    if($c1 -Match $ht){
        $ncolor = $dyrl_colors[$($c1 -replace "~(.|\n)+")]
        $c1 = $c1 -replace "^([a-z]{1,2}~)?"
    }



    ## This function counts characters to create borders based on string-length
    ## and the number of inputs. It tries not to split words but create \newlines
    ## based on whitespace.
    function genBlocks($outputs,$max,$min){
        if(-not $last){ $last = ' '*($max+1) }
        $o1 = @()
        $o2 = @()
        $o3 = $outputs.length
        if($o3 -gt $max){
            if($outputs -Match ' '){
                $outputs = $outputs -replace "(\s\s+|\t|\n)",' '
                $p = $outputs -Split(' ')
                $wide = 0
            }
            else{
                $o2 += $last.Substring(0,$max)
                if($max -gt $o3){ $o2 += $last.Substring($($max-$o3)) }
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
                        #$cut = $max - $bl
                        $cut = [math]::max(0,$max - $bl)
                        $o2 += $block.Substring(0,$max)
                        if($cut -gt 0){ $o2 += $block.Substring($cut) }
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
                            #$cut = $max - $l
                            $cut = [math]::max(0,$max - $l)
                            $o2 += $last.Substring(0,$max)
                            if($cut -gt 0){$o2 += $last.Substring($cut) }
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
            $v1color = $dyrl_colors[$($c2 -replace "~(.|\n)+")]
            $c2 = $c2 -replace "^([a-z]{1,2}~)?"
        }
        $VAL1 = $c2
        $wide2 = $c2.length


        if($c3){
            if($c3 -Match $ht){
                $v2color = $dyrl_colors[$($c3 -replace "~(.|\n)+")]
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
    saveOrShow_ $r -e #Write-Host -f GREEN $r

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
            saveOrShow_ $c -n
            if($BLOCK1[$index1]){
                saveOrShow_ " $($BLOCK1[$index1])" -c $ncolor -n
                $index1++
                $countdown = $countdown - 1
            }
            else{
                saveOrShow_ $empty1 -n
            }

            saveOrShow_ $c -n

            if($BLOCK2[$index2]){
                if($v1color){
                    saveOrShow_ " $($BLOCK2[$index2])" -c $v1color -n
                }
                else{
                    saveOrShow_ " $($BLOCK2[$index2])" -c WHITE -n
                }
                $index2++
                $countdown = $countdown - 1
            }
            else{
                saveOrShow_ $empty2 -n
            }

            saveOrShow_ $c -n

            if($BLOCK3[$index3]){
                saveOrShow_ -c $v2color " $($BLOCK3[$index3])" -n
                $index3++
                $countdown = $countdown - 1
            }
            else{
                saveOrShow_ $empty3 -n
            }
            saveOrShow_ $c -e

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
                    saveOrShow_ "$c " -n #Write-Host -f GREEN "$c " -NoNewline;
                    saveOrShow_ $_ -c $ncolor -n #Write-Host -f $ncolor $_ -NoNewline;
                    saveOrShow_ $c -n #Write-Host -f GREEN $c -NoNewline;
                    saveOrShow_ $empty2 -n  #Write-Host $empty2 -NoNewline;
                    saveOrShow_ $c #Write-Host -f GREEN $c
                    $linenum++
                }
                else{
                    saveOrShow_ "$c " -n #Write-Host -f GREEN "$c " -NoNewline;
                    saveOrShow_ "$_" -c $ncolor -n #Write-Host -f $ncolor "$_" -NoNewline;
                    saveOrShow_ $c -n #Write-Host -f GREEN $c -NoNewline;
                    if($BLOCK2[$index2]){
                        if($v1color){
                            saveOrShow_ " $($BLOCK2[$index2])" -c $v1color -n #Write-Host -f $v1color " $($BLOCK2[$index2])" -NoNewline;
                        }
                        else{
                            saveOrShow_ " $($BLOCK2[$index2])" -c WHITE -n #Write-Host " $($BLOCK2[$index2])" -NoNewline;
                        }
                        saveOrShow_ $c -e #Write-Host -f GREEN $c
                        $index2++
                    }
                    else{
                        $linenum = -1
                        saveOrShow_ $empty2 -n  #Write-Host $empty2 -NoNewline;
                        saveOrShow_ $c -e #Write-Host -f GREEN $c
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
                saveOrShow_ $c -n #Write-Host -f GREEN $c -NoNewline;
                if($linenum -lt $middle){
                    saveOrShow_ $empty1  -n #Write-Host $empty1 -NoNewline;
                    $linenum++
                }
                else{
                    if($BLOCK1[$index1]){
                        saveOrShow_ " $($BLOCK1[$index1])" -c $ncolor -n #Write-Host -f $ncolor " $($BLOCK1[$index1])" -NoNewline;
                        $index1++
                    }
                    else{
                        $linenum = -1
                        saveOrShow_ $empty1 -n  #Write-Host $empty1 -NoNewline;
                    }
                }
                saveOrShow_ $c -n #Write-Host -f GREEN $c -NoNewline;
                if($v1color){
                    saveOrShow_ " $_" -c $v1color -n #Write-Host -f $v1color " $_" -NoNewline;
                }
                else{
                    saveOrShow_ " $_" -n #Write-Host " $_" -NoNewline;
                }
                saveOrShow_ $c -e #Write-Host -f GREEN $c
            }
        }
        else{
            $BLOCK2 | %{
                saveOrShow_ $c -n #Write-Host -f GREEN $c -NoNewline;
                saveOrShow_ " $($BLOCK1[$index1])" -c $ncolor -n #Write-Host -f $ncolor " $($BLOCK1[$index1])" -NoNewline;
                $index1++
                saveOrShow_ $c -n #Write-Host -f GREEN $c -NoNewline;
                if($v1color){
                    saveOrShow_ " $_" -c $v1color -n #Write-Host -f $v1color " $_" -NoNewline;
                }
                else{
                    saveOrShow_ " $_" -n #Write-Host " $_" -NoNewline;
                }
                saveOrShow_ $c -e #Write-Host -f GREEN $c
            }
        }



    }
    else{
        $BLOCK1 | %{
            saveOrShow_ "$c " -n #Write-Host -f GREEN "$c " -NoNewline;
            saveOrShow_ $_ -c $ncolor -n #Write-Host -f $ncolor $_ -NoNewline;
            saveOrShow_ $c -e #Write-Host -f GREEN $c
        }
    }

}




function screenResultsAlt($h,$k,$v,[switch]$e=$false){   #mp
    <#
    ||shorthelp||
    Similar to screenResults; send the 'header' items of your list first, followed by
    $KEY1 and $VALUE1.
    If you have more than 2 key-values under each 'header', omit the -h header. Use -e
    to create the closing border after your final values.
    Usage:
        screenResultsAlt -h [header item] -k [item name] -v [item value]

    ||longhelp||
    Alternate output format for MACROSS results; don't use this for large outputs, use
    screenResults instead!

    The first parameter -h is the header for each item. When beginning your output,
    send the -h, -k and -v values together. Subsequent outputs under the same item
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

        ║║║║║║ rundll32.exe
        ============================================================================
        Parent    ║  acrobat.exe
        ParentID  ║  2351
        ============================================================================



    #>
    $hcolor = 'CYAN'
    $kcolor = 'GREEN'
    $vcolor = 'YELLOW'
    $r = '  '
    $ht = [regex]"^[a-z]~"
    1..76 | %{$r += '='}
    $c1 = chr 9553
    $c6 = $c1; 1..5 | %{$c6 += $c1}


    if($h -Match $ht){
        $hcolor = $dyrl_colors[$($h -replace "~.+")]
        $h = $h -replace "^([a-z]+~)?"
    }
    if($k -Match $ht){
        $kcolor = $dyrl_colors[$($k -replace "~.+")]
        $k = $k -replace "^([a-z]+~)?"
    }
    if($v -Match $ht){
        $vcolor = $dyrl_colors[$($v -replace "~.+")]
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
            Write-Host -f $kcolor $k -NoNewline;
            Write-Host -f GREEN $c1 -NoNewline;
            Write-Host -f $vcolor " $v"
        }
        elseif($k){ Write-Host -f $kcolor $k }
        elseif($v){ Write-Host -f $kcolor $v }
    }
}



################################
## screenResultsForm helpers: turn markdown/plain text into a list of styled "runs"
## ({t=text; s=style}) that the form renders. Kept separate from the form so it can
## be tested anywhere. Nothing here interprets HTML or follows links.
################################
function srfAdd_($runs,[string]$t,[string]$s='normal'){
    if($t -ne ''){ [void]$runs.Add([pscustomobject]@{ t=$t; s=$s }) }
}
function srfStrip_([string]$t){
    ## Remove inline markdown markers (used where styling isn't applied, e.g. table cells)
    $t = $t -replace '\[([^\]]+)\]\(([^)\s]+)\)','$1 ($2)'
    $t = $t -replace '(\*\*\*|\*\*|__|~~|`)',''
    $t = $t -replace '(?<![\w*])\*([^*\s][^*]*?)\*(?![\w*])','$1'
    $t -replace '(?<!\w)_([^_\s][^_]*?)_(?!\w)','$1'
}
function srfInline_($runs,[string]$line,[string]$base='normal'){
    $rx = '(`[^`]+`)|(\*\*\*[^*]+\*\*\*)|(\*\*[^*]+\*\*)|(__[^_]+__)|(~~[^~]+~~)|(\[[^\]]+\]\([^)\s]+\))|((?<![\w*])\*[^*\s][^*]*?\*(?![\w*]))|((?<!\w)_[^_\s][^_]*?_(?!\w))'
    $pos = 0
    foreach($m in [regex]::Matches($line,$rx)){
        if($m.Index -gt $pos){ srfAdd_ $runs $line.Substring($pos,$m.Index - $pos) $base }
        $v = $m.Value
        if($v.StartsWith('`')){ srfAdd_ $runs $v.Trim('`') 'code' }
        elseif($v.StartsWith('***')){ srfAdd_ $runs $v.Substring(3,$v.Length - 6) 'bolditalic' }
        elseif($v.StartsWith('**') -or $v.StartsWith('__')){ srfAdd_ $runs $v.Substring(2,$v.Length - 4) 'bold' }
        elseif($v.StartsWith('~~')){ srfAdd_ $runs $v.Substring(2,$v.Length - 4) 'strike' }
        elseif($v.StartsWith('[')){
            $lm = [regex]::Match($v,'^\[([^\]]+)\]\(([^)\s]+)\)$')
            srfAdd_ $runs $lm.Groups[1].Value 'link'
            srfAdd_ $runs " ($($lm.Groups[2].Value))" 'url'
        }
        else{ srfAdd_ $runs $v.Substring(1,$v.Length - 2) 'italic' }
        $pos = $m.Index + $m.Length
    }
    if($pos -lt $line.Length){ srfAdd_ $runs $line.Substring($pos) $base }
}
function srfTable_($runs,$rows){
    ## Pipe table -> aligned monospace columns (separator rows like |---|:--:| are dropped)
    $cells = @(foreach($r in $rows){
        if($r -match '^\s*\|?\s*:?-{2,}:?\s*(\|\s*:?-{2,}:?\s*)*\|?\s*$'){ Continue }
        ,@(($r.Trim() -replace '^\|','' -replace '\|$','') -split '\|' | %{ srfStrip_ $_.Trim() })
    })
    if(-not $cells.Count){ Return }
    $cols = ($cells | %{ $_.Count } | Measure-Object -Maximum).Maximum
    $wid = @(for($c = 0; $c -lt $cols; $c++){ ($cells | %{ if($c -lt $_.Count){ $_[$c].Length }else{ 0 } } | Measure-Object -Maximum).Maximum })
    for($i = 0; $i -lt $cells.Count; $i++){
        $line = (@(for($c = 0; $c -lt $cols; $c++){
            $v = if($c -lt $cells[$i].Count){ $cells[$i][$c] }else{ '' }
            $v.PadRight($wid[$c])
        }) -join ' | ')
        srfAdd_ $runs $line $(if($i -eq 0){ 'tablehead' }else{ 'table' })
        srfAdd_ $runs "`n"
        if($i -eq 0 -and $cells.Count -gt 1){
            srfAdd_ $runs ((@($wid | %{ '-' * $_ }) -join '-+-')) 'table'
            srfAdd_ $runs "`n"
        }
    }
}
function srfParse_([string]$text,[string]$format='auto'){
    $runs = New-Object System.Collections.ArrayList
    $esc = [string][char]27     ## (PS 5.1 has no `e escape)
    $text = $text -replace "$esc\[[0-9;?]*[ -/]*[@-~]",'' -replace "`r`n","`n" -replace "`r","`n"   ## strip terminal color codes
    if($format -eq 'auto'){
        $mdHint = '(?m)^(#{1,6}\s|\s*[-*+]\s+\S|\s*\d+[.)]\s+\S|>\s?|```|\s*\|.*\|\s*$)|\*\*[^*\n]+\*\*|\[[^\]\n]+\]\([^)\s]+\)'
        $format = if($text -match $mdHint){ 'markdown' }else{ 'text' }
    }
    if($format -eq 'text'){ srfAdd_ $runs $text 'mono'; Return ,$runs }

    $lines = $text -split "`n"
    $fence = $false; $table = New-Object System.Collections.ArrayList
    for($i = 0; $i -lt $lines.Count; $i++){
        $l = $lines[$i]
        if($l -match '^\s*(```|~~~)'){                       ## code fence open/close
            $fence = -not $fence; Continue
        }
        if($fence){ srfAdd_ $runs " $l " 'codeblock'; srfAdd_ $runs "`n"; Continue }

        if($l -match '^\s*\|.*\|\s*$'){ [void]$table.Add($l); Continue }   ## collect table rows
        if($table.Count){ srfTable_ $runs $table; $table.Clear() }

        if($l -match '^\s*(#{1,6})\s+(.*?)\s*#*\s*$'){
            $lvl = [Math]::Min($Matches[1].Length,3)
            srfAdd_ $runs (srfStrip_ $Matches[2]) "h$lvl"
        }
        elseif($l -match '^\s*([-*_])(\s*\1){2,}\s*$'){ srfAdd_ $runs ([string][char]0x2500 * 60) 'hr' }
        elseif($l -match '^\s*>\s?(.*)$'){ srfAdd_ $runs "$([char]0x2502) " 'quote'; srfInline_ $runs $Matches[1] 'quote' }
        elseif($l -match '^(\s*)[-*+]\s+(\[[ xX]\]\s+)?(.*)$'){
            $lead = $Matches[1]; $chk = $Matches[2]; $item = $Matches[3]    ## save before any other -match
            $ind = '    ' * [Math]::Floor($lead.Length / 2)
            $box = if($chk){ if($chk.Contains('x') -or $chk.Contains('X')){ "[$([char]0x2713)] " }else{ '[ ] ' } }else{ '' }
            srfAdd_ $runs "$ind  $([char]0x2022) $box"
            srfInline_ $runs $item
        }
        elseif($l -match '^(\s*)(\d+)([.)])\s+(.*)$'){
            $ind = '    ' * [Math]::Floor($Matches[1].Length / 2)
            srfAdd_ $runs "$ind  $($Matches[2])$($Matches[3]) "
            srfInline_ $runs $Matches[4]
        }
        else{ srfInline_ $runs $l }
        if($i -lt $lines.Count - 1){ srfAdd_ $runs "`n" }
    }
    if($table.Count){ srfTable_ $runs $table }
    Return ,$runs
}

## Accepts a file path, byte[], base64 string (optionally "data:image/...;base64,"), or an
## Image object. Returns @{img=; stream=; name=} or throws. Never downloads anything.
function srfImage_($src,[int]$n){
    if($src -is [System.Drawing.Image]){ Return @{ img=$src; stream=$null; name="image $n" } }
    if($src -is [byte[]]){ $bytes = $src; $name = "image $n" }
    else{
        $s = "$src".Trim()
        if($s -match '^[a-z]+://'){ throw "image $n is a URL; download it first (screenResultsForm never fetches remote content)" }
        if($s.Length -lt 260 -and (Test-Path -PathType Leaf -LiteralPath $s)){
            $bytes = [IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $s).Path); $name = Split-Path $s -Leaf
        }
        else{
            $b64 = $s -replace '^data:image/[\w.+-]+;base64,','' -replace '\s',''
            try{ $bytes = [Convert]::FromBase64String($b64) }
            catch{ throw "image $n is not a file path, base64 image, or image object" }
            $name = "image $n"
        }
    }
    $ms = New-Object IO.MemoryStream(,$bytes)
    try{ $img = [System.Drawing.Image]::FromStream($ms) }
    catch{ $ms.Dispose(); throw "image $n could not be read as an image" }
    Return @{ img=$img; stream=$ms; name=$name }
}

## Shared look for the screenResultsForm windows (fonts must be disposed by the caller)
function srfStyle_(){
    @{
        bg     = [Drawing.Color]::Black
        fg     = [Drawing.Color]::Gainsboro
        codeBg = [Drawing.Color]::FromArgb(38,38,38)
        fonts  = @{
            normal     = New-Object Drawing.Font('Segoe UI',10)
            bold       = New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold)
            italic     = New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Italic)
            bolditalic = New-Object Drawing.Font('Segoe UI',10,([Drawing.FontStyle]::Bold -bor [Drawing.FontStyle]::Italic))
            strike     = New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Strikeout)
            link       = New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Underline)
            url        = New-Object Drawing.Font('Segoe UI',9)
            quote      = New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Italic)
            h1         = New-Object Drawing.Font('Segoe UI',16,[Drawing.FontStyle]::Bold)
            h2         = New-Object Drawing.Font('Segoe UI',13.5,[Drawing.FontStyle]::Bold)
            h3         = New-Object Drawing.Font('Segoe UI',11.5,[Drawing.FontStyle]::Bold)
            code       = New-Object Drawing.Font('Consolas',9.5)
            codeblock  = New-Object Drawing.Font('Consolas',9.5)
            mono       = New-Object Drawing.Font('Consolas',9.5)
            table      = New-Object Drawing.Font('Consolas',9.5)
            tablehead  = New-Object Drawing.Font('Consolas',9.5,[Drawing.FontStyle]::Bold)
            hr         = New-Object Drawing.Font('Segoe UI',8)
        }
        colors = @{
            h1='Gold'; h2='Gold'; h3='Khaki'; link='DeepSkyBlue'; url='SteelBlue'; quote='Silver'
            code='LightGreen'; codeblock='LightGreen'; tablehead='Yellow'; hr='DimGray'; strike='Gray'
        }
    }
}
## A read-only text box that never makes links clickable
function srfBox_($st){
    $rtb = New-Object Windows.Forms.RichTextBox
    $rtb.ReadOnly = $true
    $rtb.DetectUrls = $false
    $rtb.BorderStyle = 'None'
    $rtb.BackColor = $st.bg
    $rtb.ForeColor = $st.fg
    $rtb.Dock = 'Fill'
    $rtb.ScrollBars = 'Both'
    $rtb.Font = $st.fonts.normal
    Return $rtb
}
## Render (or re-render) text into a box built by srfBox_
function srfFill_($rtb,[string]$text,[string]$format,$st){
    $rtb.SuspendLayout()
    $rtb.Clear()
    $rtb.WordWrap = ($format -ne 'text')
    foreach($r in (srfParse_ $text $format)){
        $rtb.SelectionStart = $rtb.TextLength
        $rtb.SelectionLength = 0
        $rtb.SelectionFont = if($st.fonts.ContainsKey($r.s)){ $st.fonts[$r.s] }else{ $st.fonts.normal }
        $rtb.SelectionColor = if($st.colors.ContainsKey($r.s)){ [Drawing.Color]::FromName($st.colors[$r.s]) }else{ $st.fg }
        $rtb.SelectionBackColor = if($r.s -in @('code','codeblock')){ $st.codeBg }else{ $st.bg }
        $rtb.SelectedText = $r.t
    }
    $rtb.SelectionStart = 0
    $rtb.ScrollToCaret()
    $rtb.ResumeLayout()
}


################################
## Saved chats (.chat files) for the screenResultsForm -chats viewer
################################
## Every .chat file under $root (including subfolders), newest first
function srfChatList_([string]$root){
    if(-not $root -or -not (Test-Path -PathType Container $root)){ Return @() }
    $base = (Resolve-Path $root).Path.TrimEnd('\','/')
    @(Get-ChildItem -Path $root -Filter '*.chat' -File -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        %{ [pscustomobject]@{
            Name     = $_.FullName.Substring($base.Length).TrimStart('\','/')
            Modified = $_.LastWriteTime
            Size     = $_.Length
            Path     = $_.FullName
        } })
}
## Turn a saved chat into displayable markdown. JSON message lists (the shape most AI APIs
## use: [{role,content}] or {messages:[...]}) become a conversation with a heading per
## speaker; anything else is shown as-is.
function srfChatText_([string]$raw){
    $t = $raw.Trim()
    if($t.StartsWith('[') -or $t.StartsWith('{')){
        try{ $j = $t | ConvertFrom-Json -ErrorAction Stop }catch{ $j = $null }
        if($j){
            $msgs = if($j.PSObject.Properties.Name -contains 'messages'){ @($j.messages) }else{ @($j) }
            $msgs = @($msgs | ?{ $_ -and $_.PSObject.Properties.Name -contains 'role' })
            if($msgs.Count){
                $out = New-Object System.Collections.ArrayList
                foreach($m in $msgs){
                    $who = "$($m.role)"
                    if($who){ $who = $who.Substring(0,1).ToUpper() + $who.Substring(1) }
                    if($m.PSObject.Properties.Name -contains 'name' -and $m.name){ $who += " ($($m.name))" }
                    $body = foreach($part in @($m.content)){
                        if($part -is [string]){ $part }
                        elseif($part.PSObject.Properties.Name -contains 'text'){ "$($part.text)" }
                        elseif($part.PSObject.Properties.Name -contains 'type'){ "*[$($part.type)]*" }
                    }
                    [void]$out.Add("### $who`n$((@($body) -join "`n").Trim())")
                }
                Return ($out -join "`n`n---`n")
            }
        }
    }
    Return $raw
}

## The chat browser window
function srfChats_([string]$root,[string]$title){
    $all = srfChatList_ $root
    if(-not $all.Count){
        w "No saved chats (.chat files) were found in $root" y
        Return
    }
    $st = srfStyle_
    $maxRead = 2MB      ## very large chats are shown truncated

    $form = New-Object Windows.Forms.Form
    $form.Text = "$title ($($all.Count))"
    $form.Size = New-Object Drawing.Size(1200,760)
    $form.MinimumSize = New-Object Drawing.Size(700,400)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = $st.bg; $form.ForeColor = $st.fg
    $form.TopMost = $true; $form.KeyPreview = $true
    $form.Add_KeyDown({ if($_.KeyCode -eq 'Escape'){ $form.Close() } })

    $split = New-Object Windows.Forms.SplitContainer
    $split.Dock = 'Fill'; $split.SplitterDistance = 380; $split.BackColor = [Drawing.Color]::DimGray
    $split.Panel1.BackColor = $st.bg; $split.Panel2.BackColor = $st.bg

    ## Left: filter + list
    $filter = New-Object Windows.Forms.TextBox
    $filter.Dock = 'Top'; $filter.BackColor = [Drawing.Color]::FromArgb(30,30,30); $filter.ForeColor = $st.fg
    $filter.Font = $st.fonts.normal
    $hint = New-Object Windows.Forms.Label
    $hint.Dock = 'Top'; $hint.Height = 20; $hint.ForeColor = [Drawing.Color]::Khaki
    $hint.Text = ' Filter by name or folder:'
    $list = New-Object Windows.Forms.ListView
    $list.Dock = 'Fill'; $list.View = 'Details'; $list.FullRowSelect = $true; $list.MultiSelect = $false
    $list.HideSelection = $false; $list.BackColor = $st.bg; $list.ForeColor = $st.fg; $list.BorderStyle = 'None'
    [void]$list.Columns.Add('Chat',220)
    [void]$list.Columns.Add('Modified',130)
    [void]$list.Columns.Add('Size',60)
    $split.Panel1.Controls.Add($list); $split.Panel1.Controls.Add($filter); $split.Panel1.Controls.Add($hint)

    ## Right: the rendered chat
    $rtb = srfBox_ $st
    $split.Panel2.Controls.Add($rtb)

    $list.ShowItemToolTips = $true
    $state = @{ text = ''; all = $all }     ## shared with the event handlers below
    function fillList_(){
        $list.BeginUpdate(); $list.Items.Clear()
        $f = $filter.Text.Trim()
        foreach($c in $state.all){
            if($f -and $c.Name -notlike "*$f*"){ Continue }
            $kb = if($c.Size -ge 1KB){ "{0:N0} KB" -f ($c.Size / 1KB) }else{ "$($c.Size) B" }
            $it = New-Object Windows.Forms.ListViewItem($c.Name)
            [void]$it.SubItems.Add($c.Modified.ToString('yyyy-MM-dd HH:mm'))
            [void]$it.SubItems.Add($kb)
            $it.Tag = $c; $it.ToolTipText = $c.Path
            [void]$list.Items.Add($it)
        }
        $list.EndUpdate()
        if($list.Items.Count){ $list.Items[0].Selected = $true }
        else{ $rtb.Clear(); $state.text = '' }
    }
    function showChat_($c){
        try{
            $fs = [IO.File]::Open($c.Path,'Open','Read','ReadWrite')
            try{
                $sr = New-Object IO.StreamReader($fs,[Text.Encoding]::UTF8,$true)
                $buf = New-Object char[] ([Math]::Min($c.Size,$maxRead) + 1)
                $n = $sr.ReadBlock($buf,0,$buf.Length)
                $raw = [string]::new($buf,0,[Math]::Min($n,$maxRead))
            }
            finally{ $fs.Dispose() }
            $txt = srfChatText_ $raw
            if($c.Size -gt $maxRead){ $txt = "*(Large chat: showing the first $([int]($maxRead / 1MB)) MB.)*`n`n$txt" }
        }
        catch{ $txt = "(!) Could not read $($c.Path): $($_.Exception.Message)"; $raw = '' }
        $state.text = $raw
        srfFill_ $rtb $txt 'auto' $st
    }
    $list.Add_SelectedIndexChanged({ if($list.SelectedItems.Count){ showChat_ $list.SelectedItems[0].Tag } })
    $filter.Add_TextChanged({ fillList_ })

    ## Buttons
    $bar = New-Object Windows.Forms.FlowLayoutPanel
    $bar.Dock = 'Bottom'; $bar.Height = 42; $bar.FlowDirection = 'RightToLeft'; $bar.Padding = New-Object Windows.Forms.Padding(6)
    function button_($label){
        $b = New-Object Windows.Forms.Button
        $b.Text = $label; $b.AutoSize = $true; $b.Height = 28
        $b.ForeColor = [Drawing.Color]::Yellow; $b.BackColor = [Drawing.Color]::MidnightBlue; $b.FlatStyle = 'Flat'
        $bar.Controls.Add($b)
        Return $b
    }
    $close = button_ 'Close'
    $close.Add_Click({ $form.Close() })
    $copy = button_ 'Copy text'
    $copy.Add_Click({ if($state.text){ [Windows.Forms.Clipboard]::SetText($state.text) } })
    $refresh = button_ 'Refresh'
    $refresh.Add_Click({
        $state.all = srfChatList_ $root
        $form.Text = "$title ($($state.all.Count))"
        fillList_
    })

    $form.Controls.Add($split)
    $form.Controls.Add($bar)
    $form.CancelButton = $close
    fillList_

    try{ [void]$form.ShowDialog() }
    finally{
        $form.Dispose()
        foreach($f in $st.fonts.Values){ $f.Dispose() }
    }
}


function screenResultsForm(){   #mp
    <#
    ||shorthelp||
    Show formatted text (markdown) and/or images such as graphs in a window.
    Usage:
        screenResultsForm [-t TEXT] [-i IMAGE(S)] [-h WINDOW_TITLE] [-f auto|markdown|text]
        screenResultsForm -chats [-r FOLDER]       (browse saved .chat files)

    ||longhelp||
    A companion to screenResults and screenResultsAlt for output that doesn't suit
    the console: AI/LLM responses written in markdown, heavily formatted tool output,
    or images like graphs and charts. The window blocks your diamond until the user
    closes it (Close button or ESC), the same as getBlox.

    -t  the text to show. Markdown is formatted: headings, bold/italic, inline code
        and code blocks, bullet/numbered/check lists, quotes, horizontal rules, and
        pipe tables (shown as aligned columns). Links are shown as "text (url)".
        Terminal color codes are removed.
    -i  one or more images: file paths, byte arrays, base64 strings (including
        "data:image/png;base64,..." as returned by many AI APIs), or image objects.
        Multiple images (or text plus images) are shown in tabs.
    -h  the window title (default "MACROSS results").
    -f  auto (default; detects markdown), markdown, or text (show as-is in a
        monospace font, for already-aligned CLI output).

    Buttons: "Copy text" copies the original text; "Save image" writes the image on
    the current tab to $dyrl_OUTFILES as a .png.

    SAVED CHATS (-chats): opens a browser of every .chat file under $dyrl_OUTFILES
    (including subfolders; use -r for another folder), newest first, with a filter
    box. Selecting one shows it formatted on the right. Users can also type "chats"
    in the main menu. A .chat file can be:
      -plain text or markdown (shown as-is), or
      -a JSON message list, the shape most AI APIs use, e.g.
          [{"role":"user","content":"..."},{"role":"assistant","content":"..."}]
       or {"messages":[...]}. These are shown as a conversation with a heading for
       each speaker (content given as a list of parts uses the "text" parts).
    To save a chat from your diamond, write it to $dyrl_OUTFILES (or a subfolder)
    with a .chat extension, e.g.
        $messages | ConvertTo-Json -Depth 10 | Set-Content "$dyrl_OUTFILES\ai\$(Get-Date -f yyyyMMdd-HHmmss).chat"

    SAFE FOR UNTRUSTED OUTPUT: nothing is rendered as HTML, no scripts can run,
    links are NOT clickable (copy them if you need them), and images are never
    downloaded; your diamond must already have them.

    If a window can't be opened (e.g. no desktop session), the text is written to
    the console instead.

    ||examples||
    Show an AI response:

        screenResultsForm -t $ai_reply -h 'Triage summary'

    Show a graph your diamond generated, with a caption:

        screenResultsForm -i "$dyrl_OUTFILES\logons_by_hour.png" -t '## Logons by hour'

    Show an image an API returned as base64, next to its explanation:

        screenResultsForm -t $resp.text -i $resp.image_b64 -h 'Analysis'

    Show CLI output exactly as-is:

        screenResultsForm -t ($raw_output -join "`n") -f text

    Review saved chats:

        screenResultsForm -chats

    #>
    param(
        [Parameter(Position=0)]
        [AllowEmptyString()]
        [string]$text = '',
        [Parameter(Position=1)]
        $images = $null,
        [string]$header = 'MACROSS results',
        [ValidateSet('auto','markdown','text')]
        [string]$format = 'auto',
        [switch]$chats,
        [string]$root = $dyrl_OUTFILES
    )

    try{
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
    }
    catch{
        if($chats){
            w "A window could not be opened. Saved chats in ${root}:" y
            srfChatList_ $root | %{ w "  $($_.Modified.ToString('yyyy-MM-dd HH:mm'))  $($_.Name)" }
            Return
        }
        w "A window could not be opened; showing the text here instead." y
        if($text){ Write-Host ($text -replace "$([char]27)\[[0-9;?]*[ -/]*[@-~]",'') }
        Return
    }

    if($chats){
        if($header -eq 'MACROSS results'){ $header = 'MACROSS saved chats' }
        srfChats_ $root $header
        Return
    }

    ## Load images first so problems can be reported in the text area
    $pics = New-Object System.Collections.ArrayList
    $notes = New-Object System.Collections.ArrayList
    $n = 0
    ## A single byte[]/string/image is one image; don't let powershell unroll a byte[] into bytes
    if($images -is [byte[]] -or $images -is [string] -or $images -is [System.Drawing.Image]){ $srcs = ,$images }
    else{ $srcs = @($images) }
    foreach($src in $srcs){
        if($null -eq $src){ Continue }
        $n++
        try{ [void]$pics.Add((srfImage_ $src $n)) }
        catch{ [void]$notes.Add("(!) $($_.Exception.Message)") }
    }
    if($notes.Count){ $text = (@($notes) -join "`n") + $(if($text){ "`n`n$text" }else{ '' }) }

    $st = srfStyle_
    $bg = $st.bg; $fg = $st.fg; $fonts = $st.fonts

    $form = New-Object Windows.Forms.Form
    $form.Text = $header
    $form.Size = New-Object Drawing.Size(1000,720)
    $form.MinimumSize = New-Object Drawing.Size(500,350)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = $bg
    $form.ForeColor = $fg
    $form.TopMost = $true
    $form.KeyPreview = $true
    $form.Add_KeyDown({ if($_.KeyCode -eq 'Escape'){ $form.Close() } })

    $rtb = $null
    if($text){
        $rtb = srfBox_ $st
        srfFill_ $rtb $text $format $st
    }

    function picBox_($p){
        $pb = New-Object Windows.Forms.PictureBox
        $pb.Image = $p.img
        $pb.SizeMode = 'Zoom'
        $pb.Dock = 'Fill'
        $pb.BackColor = $bg
        Return $pb
    }

    ## Layout: a single item fills the window; text + images or several images use tabs
    $tabs = $null
    if(($rtb -and $pics.Count) -or $pics.Count -gt 1){
        $tabs = New-Object Windows.Forms.TabControl
        $tabs.Dock = 'Fill'
        if($rtb){
            $tp = New-Object Windows.Forms.TabPage('Text'); $tp.BackColor = $bg
            $tp.Controls.Add($rtb); $tabs.TabPages.Add($tp)
        }
        foreach($p in $pics){
            $tp = New-Object Windows.Forms.TabPage($p.name); $tp.BackColor = $bg; $tp.Tag = $p
            $tp.Controls.Add((picBox_ $p)); $tabs.TabPages.Add($tp)
        }
        $form.Controls.Add($tabs)
    }
    elseif($rtb){ $form.Controls.Add($rtb) }
    elseif($pics.Count){ $form.Controls.Add((picBox_ $pics[0])) }
    else{
        $rtb = New-Object Windows.Forms.Label
        $rtb.Text = '  (nothing to display)'; $rtb.Dock = 'Fill'
        $form.Controls.Add($rtb)
    }

    ## Buttons
    $bar = New-Object Windows.Forms.FlowLayoutPanel
    $bar.Dock = 'Bottom'; $bar.Height = 42; $bar.FlowDirection = 'RightToLeft'; $bar.Padding = New-Object Windows.Forms.Padding(6)
    function button_($label){
        $b = New-Object Windows.Forms.Button
        $b.Text = $label; $b.AutoSize = $true; $b.Height = 28
        $b.ForeColor = [Drawing.Color]::Yellow; $b.BackColor = [Drawing.Color]::MidnightBlue; $b.FlatStyle = 'Flat'
        $bar.Controls.Add($b)
        Return $b
    }
    $close = button_ 'Close'
    $close.Add_Click({ $form.Close() })
    if($text){
        $copy = button_ 'Copy text'
        $copy.Add_Click({ [Windows.Forms.Clipboard]::SetText($text); $copy.Text = 'Copied' })
    }
    if($pics.Count){
        $save = button_ 'Save image'
        $save.Add_Click({
            $p = if($tabs -and $tabs.SelectedTab -and $tabs.SelectedTab.Tag){ $tabs.SelectedTab.Tag }
                 elseif(-not $tabs){ $pics[0] }else{ $null }
            if(-not $p){ [void][Windows.Forms.MessageBox]::Show('Select an image tab first.',$header); Return }
            $dir = if($dyrl_OUTFILES){ $dyrl_OUTFILES }else{ [Environment]::GetFolderPath('MyDocuments') }
            $base = ("$header-$($p.name)" -replace '[^\w-]+','_').Trim('_')
            $out = Join-Path $dir "$base-$(Get-Date -Format 'yyyyMMdd-HHmmss').png"
            try{
                $p.img.Save($out,[Drawing.Imaging.ImageFormat]::Png)
                [void][Windows.Forms.MessageBox]::Show("Saved to`n$out",$header)
            }
            catch{ [void][Windows.Forms.MessageBox]::Show("Could not save: $($_.Exception.Message)",$header) }
        })
    }
    $form.Controls.Add($bar)
    $form.AcceptButton = $close
    $form.CancelButton = $close

    try{ [void]$form.ShowDialog() }
    finally{
        $form.Dispose()
        foreach($p in $pics){ if($p.img){ $p.img.Dispose() }; if($p.stream){ $p.stream.Dispose() } }
        foreach($f in $fonts.Values){ $f.Dispose() }
    }
}



function sep(){   #mp
    <#
    ||shorthelp||
    Create a separator line to write on screen if you want to separate simple
    outputs being displayed.
    Usage:
        sep -a [CHAR|STRING] -L [COUNT] -c [COLOR] -i

    ||longhelp||
    When writing outputs to screen and you're not using screenResults(), this
    function can write a simple separator if you need to break up lines.

    Use the -i option to set the next line of text as inline (no newline).


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
        [string]$c = 'w',
        [switch]$i = $false,
        [switch]$u=$false
    )
    $b = ''
    1..$L | %{$b += $a}
    if($i){
        if($u){w $b $c -i -u}
        else{w $b -f $c -i}
    }
    elseif($u){ w $b $c -u }
    else{ Write-Host -f $($dyrl_colors[$c]) " $b" }
}



function w(){   #mp
    <#
    ||shorthelp||
    Alias for 'Write-Host'. Send your string as the first parameter, and the first letter of
    the color you want to use ('k' for black, 'b' for blue; the default text color is [w]hite).
    Use -b and a color letter to set a highlight color. Use -u to underline, and -i to continue
    writing inline.
    Usage:
        w -t [string text] -f [text color] -b [background color] [-i <no newline>]
            [-u <underline>] [-n <no preceding whitespace>]

    ||longhelp||
    I got sick of typing "Write-Host", gimme a break powershell.

    Send your text with -t; you can change the text and background
    colors with -f and -b respectively, using the first letter of the
    color you want ("k" for black). The default is (w)hite.

    Write inline (-NoNewline) using -i; underline with -u.

    By default, this function adds a single space to the front of your text to push it
    away from the edge of the window; you can disable this with -n.


    ||examples||
    Write green text:

        w "A string of text." g

    Write a multi-color string where "test" is underlined and a different color:

        w "A string of" g -i; w "test" y -u -i; w "words" g

    Write black text highlighted in red:

        w "A string of text." -b r -f k


    #>
    param(
        [Parameter(Mandatory=$true)]$t,
        [string]$f='w',
        [string]$b=$null,
        [switch]$i=$false,
        [switch]$u=$false,
        [switch]$n=$false
    )
    $fg = $($dyrl_colors[$f])
    if($n){ $x = ''}
    else{ $x = ' ' }
    if($f -in $dyrl_colors.keys){ $fg = $($dyrl_colors[$f]) }
    if($b -in $dyrl_colors.keys){ $bg = $($dyrl_colors[$b]) }
    if($i -and $u -and $bg){
        Write-Host -b $bg -f $fg "$x$([char]27)[4m$t$([char]27)[24m" -NoNewline;
    }
    elseif($i -and $bg){
        Write-Host -b $bg -f $fg "$x$t" -NoNewline;
    }
    elseif($u -and $bg){
        Write-Host -b $bg -f $fg "$x$([char]27)[4m$t$([char]27)[24m"
    }
    elseif($bg){
        Write-Host -f $fg -b $bg "$x$t"
    }
    elseif($i -and $u){
        Write-Host -f $fg "$x$([char]27)[4m$t$([char]27)[24m" -NoNewline;
    }
    elseif($u){
        Write-Host -f $fg "$x$([char]27)[4m$t$([char]27)[24m"
    }
    elseif($i){
        Write-Host -f $fg "$x$t" -NoNewline;
    }
    else{
        Write-Host -f $fg "$x$t"
    }


}



function slp($s,[switch]$m=$false){   #mp
    <#
    ||shorthelp||
    Alias for 'start-sleep' to pause your scripts. Send the number of seconds to pause;
    Use -m if you want to pause in milliseconds instead.
    Usage:
        slp [number of seconds] -m

    ||longhelp||
    Alias for "start-sleep". Pass a number of seconds as your first parameter, and
    'm' as the second parameter if you want to pause in milliseconds instead.

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
function startUp([switch]$init=$false,$refresh=$null,$new){
    function summer_($1,$2){
        $nn = $1 + $2
        $m1 = $([int[]](($nn -split '') -ne ''))[0..4]
        $m2 = $([int[]](([int]$2 -split '') -ne ''))
        Return @($nn,$m1,$m2,@($m1[0],$m2[0]))
    }
    function corefuncsPy_($ep){
        if(-not $env:PYTHONPATH){ $env:PYTHONPATH = $ep }
        elseif(($env:PYTHONPATH -Split ';') -notContains $ep){ $env:PYTHONPATH = "$ep;$env:PYTHONPATH" }
    }
    if($new){
        Return $(summer_ $new[0] $new[1])
    }
    if($init){
        if(! (Test-Path "$dyrl_RESOURCES\logs")){
            New-Item -Path "$dyrl_RESOURCES" -Type Directory -Name logs | Out-Null
        }
        $Global:dyrl_TMP = "$env:LOCALAPPDATA\Temp\MACROSS"
        if(! (Test-Path $dyrl_TMP)){
            New-Item -Path "$env:LOCALAPPDATA\Temp\" -Type Directory -Name MACROSS | Out-Null
        }
        function e(){ Return $(Get-Random -min 10000000000000 -max 99999999999999) }

        if(-not (confExists_)){ runStart }      ## local, central (site.ps1) or cached config

    }

    if(! $dyrl_CONF){
        ## $refresh = admin password (config menu / debug); without it the config opens through
        ## its domain or machine slot (see CONFIG PROTECTION v2 in configurations.ps1)
        $defs = confLoad_ $refresh
        if(-not $defs -or -not $defs.Count){
            ## Fail closed: never run without the config (that would also switch off access control).
            ## A wrong admin password ($refresh) only fails that action, as before.
            if(-not $refresh -and (confExists_)){
                w "`n MACROSS can't start without its configuration. Restart MACROSS to try again," r
                w ' or ask the MACROSS admin to restore access for this computer.' r
                w ' Hit ENTER to exit.' g; Read-Host | Out-Null
                varCleanup -c
                Exit
            }
            Return
        }
        lockIn -n dyrl_CONF -v $defs
        gerwalk $dyrl_CONF.di1; $s1 = [int]$dyrl_PT
        gerwalk $dyrl_CONF.di2; $s2 = [int]$dyrl_PT
        $di = $(summer_ $s1 $s2)
        lockIn -n N_ -v $di
        gerwalk $dyrl_CONF.dbg
        if(! $dyrl_BLD ){ lockIn -n dyrl_BLD -v "$([bool][int]$dyrl_PT)" }
    }

}


################################
## Dynamically generate the main menu with all available tools/diamonds
################################
function diamondSelect(){
    $extras = @(
        'config',
        'debug',
        'dec',
        'strings',
        'phone',
        'newkey',
        'enroll',
        'keys',
        'chats',
        'passw',
        'pydev',
        'shell',
        'proto',
        'screens'
    )

    $row = '  '

    $Global:dyrl_pagecount = [math]::Max(1,[math]::Ceiling($dyrl_LATTS.count / 10))  ## Add another page for every 10 tools

    Remove-Variable -Force skip,total

    ## Generate the menu page
    splashBanner
    $bar = chr 9553
    $dyrl_LATTS.keys  | Sort | Select -Skip $($dyrl_MPAGE * 10) | Select -First 10 | %{
        $tn = $_
        #$tnv = "$tn $($dyrl_LATTS[$tn].ver)"
        $toold = "(v$($dyrl_LATTS[$tn].ver)) $($dyrl_LATTS[$tn].desc)"
        if($dyrl_LATTS[$tn].pos -lt 10){ $tc = "  $($dyrl_LATTS[$tn].pos)"}
        else{ $tc = " $($dyrl_LATTS[$tn].pos)" }
        $tooln = "$tc`. $tn"
        if($tn.Length -lt 15){
            $l = (15 - $($tn.Length))
            while($l -gt 0){
                $tooln += ' '
                $l--
            }
        }
        elseif($tn.Length -gt 15){
            $tooln = "$tc`. $($tn.Substring(0,15))"
        }
        w '' -i
        sep '=' 72 c
        w " $tooln $bar $toold" y
    }

    w '' -i
    sep '=' 72 c
    w "`n"

    if( $ROBOTECH ){
        w '              ****YOU ARE NOT LOGGED IN AS ADMIN**** ' y
        w "    Some functions are not available without admin privilege.`n" y
    }

    if(Test-Path -Path "$($dyrl_PG[1])\PROTOCULTURE.vf1"){
        w '                   $PROTOCULTURE is active!            ' -b r -f k
        w '              Enter "proto" to clear $PROTOCULTURE.' -b r -f k
    }

    if( $dyrl_pagecount -gt 1 ){
        w "   -There are $($dyrl_LATTS.count) diamonds available. Enter" g -i
        w "p" y -i
        w "for the next Page." g
    }
    w "   -Select the module for the diamond you want (" g -i
    w "1-$($dyrl_LATTS.count)" y -i
    w ")." g
    w '   -Type' g -i
    w 'help' y -i
    w "to view the help menu, or 'help' and a diamond #." g
    w "   -Type" g -i
    w "shell" y -i
    w "to pause and run your own commands." g
    w "   -Type" g -i
    w "strings" y -i
    w "to extract text from a binary." g
    if( ! $ROBOTECH ){
        w "   -Type" g -i
        w 'phone' y -i
        w " for phone number lookups" g
        w "   -Type" g -i
        w 'passw' y -i
        w "to update your admin password" g
    }
    w "   -Type" g -i
    w "q" y -i
    w "to quit.`n" g
    w "   SELECT: " g -i
    
    $Global:dyrl_Z = Read-Host


    if( $dyrl_Z -eq 'q' ){ varCleanup -c; Exit }
    elseif($dyrl_Z -eq 'p'){ scrollPage }
    elseif($dyrl_Z -in $extras){ extras $dyrl_Z }
    elseif( $dyrl_Z -Match $dyrl_CHOICE ){
        if( $dyrl_Z -Match "help\s*\d" ){
            $Global:dyrl_Z = $dyrl_Z -replace "^help(\s+)?"
            $Global:HELP = $true
        }
        elseif( $dyrl_Z -Like "*s" ){  ## Enable 'switched' option for the selected script
            $Global:dyrl_Z = $dyrl_Z -replace 's'
            $Global:dyrl_OPT1 = $true
        }
        elseif($dyrl_Z -Like "*w"){  ## Execute selected script in new window
            $Global:dyrl_Z = $dyrl_Z -replace 'w'
            $Global:dyrl_NEWW = $true
        }
        else{
            $Global:HELP = $false
            $Global:dyrl_OPT1 = $false
        }

        if($dyrl_Z -eq 'help'){ macrossHelp -f }
        else{
            startUp
            $select = "$($dyrl_LATTS.keys | ?{$dyrl_LATTS[$_].pos -eq "$dyrl_Z"})"
            if($ref){ rv ref; flightDeck $select -r }
            else{ flightDeck $select }
        }

    }

    $Global:dyrl_Z = $null

}

################################
## If more than 9 tools available, allow changing menu pages
################################
function scrollPage(){
    if($dyrl_pagecount -gt 1){
        $Global:dyrl_MPAGE = $dyrl_MPAGE + 1
        if($dyrl_MPAGE -ge $dyrl_pagecount){
            $Global:dyrl_MPAGE = 0
        }
        splashBanner
        diamondSelect
    }
}






