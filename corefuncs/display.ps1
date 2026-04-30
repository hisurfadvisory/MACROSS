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

function minmay([int]$a=0,[int]$s){ #mp
    <#
    ||shorthelp||
    minmay [-a (int) ART_INDEX] [-s NUMBER OF SECONDS TO DISPLAY]

    ||longhelp||
    This function requires the macart.json file in the local resources folder.
    
    Select one of these numbers to get ascii art:
    
        0 = VF-1S Battroid "Skull Leader" (default)
        1 = VF-19 Gerwalk
        2 = SDF-1
        3 = VF-1J Fighter
        4 = Gubaba
        5 = Lynn Minmay
        6 = Mylene Jenius
        7 = Nekki Basara
        8 = Hikaru Ichijo
        9 = Sheryl Nome
        10 = VF-25 Messiah Fighter
        11 = Konig Monster
    
    Use -s <number of seconds> to clear the screen after that many seconds, otherwise 
    the art will remain for the duration of the next task.

    You can get a slideshow preview of all these images by typing "splash" in the main
    menu.

    *otaku note: Lynn Minmay helped defeat the massive Zeltran armada by overwhelming
    the war-like aliens with music, which had never been heard by Zeltran before!
    
    ||examples||
    Display the VF-25 Messiah onscreen for 2 seconds:
    
        minmay -a 10 -s 2
    
    Do the same without clearing the screen:
    
        minmay 10 
        
    
    #>

    cls
    $jsonart = "$dyrl_RESOURCES\macross_art.json"
    $emsg = "Missing required $jsonart file"
    
    if(Test-Path $jsonart){
        $j = Get-Content $jsonart | ConvertFrom-Json
        reString $j.art[$a]
        w "$dyrl_PT`n" y -n
        w $j.titles[$a] y -n
        if( [int]$s ){ sleep $s; cls }
    }
    else{ errMsg $emsg -c y -f 'MACROSS.minmay' }
    
}

function splashBanner(){
    function tod_($t){
        $t = $(Get-Date -f 'h tt') -Split ' '
        if($t[1] -eq 'AM'){ Return 'Morning' }
        if([int]$t[0] -ge 5){ Return 'Evening' }
        Return 'Afternoon'
    }
    function splitInf_($inf,[switch]$h,[switch]$i){
        if($h){ $inf = " HOST: $inf" }
        elseif($i){ $inf = " IP: $inf" }
        while($inf.length -lt 34){
            $inf = $inf + ' '
        }
        Return $inf.substring(0,34)
    }
    $welcome = '    '
    $tod = tod_ 
    @(37504,27827,27969,39746,32,12458,12524,12494,12454,12479,12530,12461,12465) | %{
        $welcome = "$welcome$(chr $_)"
    }
    if($env:COMPUTERNAME){ 
        $hn = $env:COMPUTERNAME
        if($env:CLIENTNAME){ $hn = "$hn($env:CLIENTNAME)"}
    }
    elseif($env:CLIENTNAME){ $hn = "      $env:CLIENTNAME" }
    elseif($env:ViewClient_Launch_ID){ $hn = "      $env:ViewClient_Launch_ID" }
    $vl = "$dyrl_VERSION".length
    if(! $dyrl_PSVER){ 
        $Global:dyrl_PSVER = $(($PSVersionTable.PSVersion -Join '.').substring(0,3))
    }
    
    $b1 = battroid '      MACROSS'
    $m_ip = setLocal -m
    
    cls
    "`n"
    $bar = battroid -bar
    $p = "Powershell $dyrl_PSVER, $dyrl_PYVERS"
    #$infoL = $hn.length + $m_ip.length
    $hn = splitInf_ "$hn" -h
    $m_ip = splitInf_ "$m_ip" -i
    $hinfo = "$hn$bar$m_ip"
    while($hinfo.length -lt 72){$hinfo += ' '}
    $sep = 67 - $p.length
    w $b1 c -i -n
    w " v$dyrl_VERSION" c
    w '' -i; sep '=' 72 c
    w "  $(splitInf_ "  Good $tod, $USR`!")" y -i -n
    w "$welcome`!" y
    w '' -i; sep '=' 72 c
    w '' -i; w $hinfo c -u
    w '' -i; sep $bar $sep c -i -u; w $p c -i -u; sep $bar 3 c -u
}

function battroid($alpha,[switch]$bar=$false){   #mp
    <#
    ||shorthelp||
    Convert console text to ascii-art block text
    Usage:
        skyTitles [-a TEXT_TO_WRITE] [-b BAR_CHARACTER <exclusive from -a>]

    ||longhelp||
    Convert a single word or letter into ascii block art. Only works with alpahumeric
    chars and limited special characters. If your text has preceding whitespace, it will
    be preserved. send your text using the -alpha parameter.

    Use -b (without sending any text) to get the non-standard separator character used
    in MACROSS's main menu.

    This function relies on the alphanum.json file located in the $dyrl_RESOURCES
    folder. If you delete it, this function no longer works.

    Accepted punctuation/special chars:  ? ! . : - _ @

    *otaku note: "battroid" is the mech (robot) configuration for the transforming
    valkyrie fighter jets in the Macross series.

    ||examples||

    Get a bar and a block title for your diamond, then create a separator of 65 $bar
    characters:

        $bar = battroid -b
        $title = battroid '  MYSCRIPT'

        write-host $title
        sep $bar 65

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
    reString $blocks
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

function dfInfo($tool){   #mp
    <#
    ||shorthelp||
    Tool attribute summary for help pages
    Usage:
        dfInfo -t <tool name>

    ||longhelp||
    Displays a tool's summary for its help pages.

    ||examples||

    Display the .valtype, .author and .ver attributes of MYSCRIPT:

        dfInfo MYSCRIPT

    #>
    w "`n VERSION: " -i
    w "$($dyrl_LATTS.$tool.ver)" y -u -n
    w "AUTHOR:  " -i
    w "$($dyrl_LATTS.$tool.author)" y -u -n
    w "PURPOSE: " -i
    w "$($dyrl_LATTS.$tool.valtype)`n" y -u -n
}


function macrossHelp($1,[switch]$full=$false,[switch]$help=$false){
    <#
    Display HELP for internal MACROSS functions. Send the diamond name as parameter 1
    for its details and usage, or send "dev" to get a full list of descriptions.
    Calling without parameters just lists the Local Attributes table.
    #>
    $cores = @('utility.ps1','display.ps1','validation.ps1')
    if($full){
        $dyrl_LATTS.keys | %{
            screenResults "$($dyrl_LATTS[$_].name) v$($dyrl_LATTS[$_].ver)" "Evaluates $($dyrl_LATTS[$_].valtype)"
        }
        screenResults -e

        w "`n`n
        -MACROSS uses a tamper-resistant session ID. If your session crashes or 
        you exit by hitting CTRL+C, you will need to completely close powershell, open a
        new window and launch MACROSS again to generate a new ID, otherwise
        it may give you a 'security group' error.

        -When a script is running, it will pause if you click anywhere in
        the powershell window. Hitting any key will resume the script, but
        will also enter that key into the next available prompt. Use the
        BACKSPACE key to avoid getting errors.

        -If you experience any bugs or issues, notify JD.

        Hit ENTER to go back." y
        Read-Host; Return
    }
    elseif($help){
        reString $dyrl_CONF.cre
        $error[0]
        w "`n  Looks like the last task did not complete smoothly. If you are experiencing
  issues with MACROSS, and using the refresh `"r`" option with tools is not
  resolving them: exit MACROSS, delete the local macross_core folder and
  execute Launch.ps1 to retrieve a fresh copy." y
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

    function listFunctions_(){
        $funclist = ''
        foreach($core in $cores){
            $f = "$dyrl_MACROSS\corefuncs\$core"
            $funcs = Select-String -Pattern "^function \w+\(.+mp$" $f
            $funcs | %{
                $funclist += $(($_.line -replace "^function " -replace "\(.+") + ';')
            }
        }
        Return $funclist -Split ';'
    }

    $functions = listFunctions_

    if($1 -eq 'show'){
        screenResults 'w~MACROSS FUNCTIONS' "y~$(($functions | ?{$_ -ne ''} | Sort) -join(', '))"
        screenResults "w~Type help, or help + one of the above to view details. Type dfList to list all MACROSS diamond properties, or TL + the toolname to view a specific tool."
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
    "`n"
    w '$CALLER is the name of the diamond that calls another using the valkyrie function.' g
    w '$PROTOCULTURE is the global value all diamonds should be coded to act on when necessary.' g
    w '$spiritia is a parameter/arg value that is used as an additional parameter or arg passed' g
    w ' to other diamonds.' g
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
            #if($100 -eq $r){$100 = $fr}    ## Have to play around with the border length when writing to file
            if(! (Test-Path $write_to)){ noBOM -t "$100`n" -f $write_to }
            elseif($endline){ noBOM -t "$100`n" -f $write_to -a }
            elseif($nnl){ noBOM -t $100 -f $write_to -a }
            else{ noBOM -t $100 -f $write_to -n }
        }
        else{
            if($nnl){ Write-Host -f $cy $100 -NoNewline;}
            else{ Write-Host -f $cy $100 }
        }
    }

    ## Clean up trailing empty space
    $strip = [regex]"(\s|\t|\n|\r)+$"
    $c1 = $c1 -replace $strip
    if($c2){ $c2 = $c2 -replace $strip }
    if($c3){ $c3 = $c3 -replace $strip }

    reString '4pWR'; $c = $dyrl_PT
    $r = $c
    reString '4omh'; $hb = $dyrl_PT
    1..$tw | %{$r = $r + $hb}; $r = $r + $c
    $fr = $r -replace ".{26}$","$hb"     ## Have to play around with the border length when writing to file
    if($e){
        saveOrShow_ $r
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
                        #$cut = $max - $bl
                        $cut = [math]::max(0,$max - $bl)
                        $o2 += $block.Substring(0,$max)
                        try{ $o2 += $block.Substring($cut,-1) }
                        catch{ Continue }
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
                            try{ $o2 += $last.Substring($cut,-1) }
                            catch{ Continue }
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
    saveOrShow_ $r -e

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
                    saveOrShow_ "$c " -n
                    saveOrShow_ $_ -c $ncolor -n
                    saveOrShow_ $c -n
                    saveOrShow_ $empty2 -n 
                    saveOrShow_ $c
                    $linenum++
                }
                else{
                    saveOrShow_ "$c " -n
                    saveOrShow_ "$_" -c $ncolor -n
                    saveOrShow_ $c -n
                    if($BLOCK2[$index2]){
                        if($v1color){
                            saveOrShow_ " $($BLOCK2[$index2])" -c $v1color -n
                        }
                        else{
                            saveOrShow_ " $($BLOCK2[$index2])" -c WHITE -n
                        }
                        saveOrShow_ $c -e
                        $index2++
                    }
                    else{
                        $linenum = -1
                        saveOrShow_ $empty2 -n 
                        saveOrShow_ $c -e
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
                saveOrShow_ $c -n
                if($linenum -lt $middle){
                    saveOrShow_ $empty1  -n
                    $linenum++
                }
                else{
                    if($BLOCK1[$index1]){
                        saveOrShow_ " $($BLOCK1[$index1])" -c $ncolor -n
                        $index1++
                    }
                    else{
                        $linenum = -1
                        saveOrShow_ $empty1 -n 
                    }
                }
                saveOrShow_ $c -n
                if($v1color){
                    saveOrShow_ " $_" -c $v1color -n
                }
                else{
                    saveOrShow_ " $_" -n
                }
                saveOrShow_ $c -e
            }
        }
        else{
            $BLOCK2 | %{
                saveOrShow_ $c -n
                saveOrShow_ " $($BLOCK1[$index1])" -c $ncolor -n
                $index1++
                saveOrShow_ $c -n
                if($v1color){
                    saveOrShow_ " $_" -c $v1color -n
                }
                else{
                    saveOrShow_ " $_" -n
                }
                saveOrShow_ $c -e
            }
        }



    }
    else{
        $BLOCK1 | %{
            saveOrShow_ "$c " -n
            saveOrShow_ $_ -c $ncolor -n
            saveOrShow_ $c -e
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
    if($new){
        Return $(summer_ $new[0] $new[1])
    }
    if($init){
        if(! (Test-Path "$dyrl_RESOURCES\logs")){
            New-Item -Path "$dyrl_RESOURCES" -Type Directory -Name logs | Out-Null
        }
        if(! (Test-Path "$dyrl_PYLIB\garbage_io")){
            New-Item -Path "$dyrl_PYLIB" -Type Directory -Name garbage_io | Out-Null
        }
        $Global:dyrl_TMP = "$env:LOCALAPPDATA\Temp\MACROSS"
        if(! (Test-Path $dyrl_TMP)){
            New-Item -Path "$env:LOCALAPPDATA\Temp\" -Type Directory -Name MACROSS | Out-Null
        }
        function e(){ Return $(Get-Random -min 10000000000000 -max 99999999999999) }

        #lockIn -n dyrl_HK -v $([System.Tuple]::Create($(e),$(e)))

        if(! (Test-Path "$dyrl_CONFIG")){ runStart }

    }

    if(! $dyrl_CONF){
        $defs = @{}
        reString QEBA
        $9 = "$dyrl_PT"
        $b = $(runContinue $refresh) -Split $9
        if(! $b){ Return }

        foreach($c in $b){
            $d = $c.substring(0,3)
            $e = $c -replace "^..."
            $defs.Add($d,$e)
            if($MONTY){ $p += "$($d+':'+$e);" }
        }

        lockIn -n dyrl_CONF -v $defs
        reString $dyrl_CONF.di1; $s1 = [int]$dyrl_PT
        reString $dyrl_CONF.di2; $s2 = [int]$dyrl_PT
        $di = $(summer_ $s1 $s2)
        lockIn -n N_ -v $di
        reString $dyrl_CONF.dbg
        if(! $dyrl_BLD ){ $Global:dyrl_BLD = "$([bool][int]$dyrl_PT)" }
        if($p.length -gt 0){  $env:dyrl_DL = $p -replace ";$" }
    }

}


################################
## Dynamically generate the main menu with all available scripts
################################
function diamondSelect(){
    $extras = @(
        'config',
        'dec',
        'defs',
        'export',
        'strings',
        'phone',
        'newkey',
        'passw',
        'pydev',
        'shell',
        'splash',
        'proto',
        'file',
        'refresh',
        'refreshall'
    )

    $row = '  '

    $Global:dyrl_pagecount = [math]::truncate(($($dyrl_LATTS.count)/10) + 1)  ## Add another page for every 10 tools

    $skip = $null

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
        elseif($tnv.Length -gt 15){
            $tooln = $tooln.Substring(0,15)
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
        w "       Some tools are not available without admin privilege.`n" y
    }

    if(Test-Path -Path "$($dyrl_PG[1])\PROTOCULTURE.mac7"){
        w '              Enter "proto" to clear $PROTOCULTURE.' -b r -f k
    }

    if( $dyrl_pagecount -gt 1 ){
        w "   -There are $($dyrl_LATTS.count) tools available. Enter" g -i
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
    w '   -Type' g -i
    w 'export' y -i
    w 'to export your config for a teammate' g
    w "   -Type" g -i
    w "q" y -i
    w "to quit.`n" g

    if($dyrl_REPOCORE){
    w "                          TROUBLESHOOTING:
   If the console is misbehaving, you can enter" g -i
    w "refresh" c -i
    w "to automatically
   pull down a fresh copy. Or, if one of the tools is not working as you
   expect it to, enter the module # with an" g -i
    w "r" c -i
    w "to refresh that script
   (ex. '3r'). Type `"" -i g
    w 'refreshall' c -i -n
    w "`" to download fresh copies of all tools.`n" g -n
    }

    w "                        SELECTION: " g -i
    $Global:dyrl_Z = Read-Host


    if( $dyrl_Z -eq 'q' ){ varCleanup -c; Exit }
    elseif($dyrl_Z -eq 'p'){ scrollPage }
    elseif($dyrl_Z -in $extras){ extras $dyrl_Z }
    elseif( $dyrl_Z -Match $dyrl_CHOICE ){
        if( $dyrl_Z -Match "help\s*\d" ){
            $Global:dyrl_Z = $dyrl_Z -replace "^help(\s+)?"
            $Global:HELP = $true
        }
        elseif( $dyrl_Z -Like "*r" ){  ## Update the selected script
            $Global:dyrl_Z = $dyrl_Z -replace 'r'
            $ref = $true
        }
        elseif( $dyrl_Z -Like "*s" ){  ## Enable 'special' option for the selected script
            $Global:dyrl_Z = $dyrl_Z -replace 's'
            $Global:dyrl_OPT1 = $true
        }
        elseif($dyrl_Z -Like "*w"){  ## Pop selected script in new window
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
    elseif( $dyrl_Z -Match "^debug" ){
        if($dyrl_Z -Match ' '){ $p = $dyrl_Z -replace "^debug " }
        else{ $p = $null }
        splashBanner
        consoleDebug $p -c $(returnDefault -b)[0]
        rv p
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



