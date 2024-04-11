## Functions controlling MACROSS's display


######################################
## MACROSS banner
######################################
function splashPage(){
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
    $ip = $(ipconfig | Select-String "IPv4 Address") -replace "^.* : "
    $hn = hostname
    $vl = $vf19_VERSION.length
    cls
    Write-Host "
    "
    getThis $b
    Write-Host -f CYAN "$vf19_READ"
    Write-Host -f CYAN "  ======================================================================" 
    Write-Host -f YELLOW "               Welcome to Multi-API-Cross-Search, " -NoNewline;
    Write-Host -f CYAN "$USR"
    Write-Host -f YELLOW "             Host: $hn  ||  IP: $ip"
    Write-Host -f CYAN "  ======================================================================"
    Write-Host -f CYAN "  ║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║" -NoNewline;
    Write-Host -f YELLOW "v$vf19_VERSION" -NoNewline;
    if( $vl -lt 3){
        Write-Host -f CYAN "║║║║║"
    }
    elseif( $vl -le 4 ){
        Write-Host -f CYAN "║║║║"
    }
    elseif( $vl -le 5 ){
        Write-Host -f CYAN "║║"
    }
    elseif( $vl -ge 6 ){
        Write-Host '
        '
    }
                                                                     
}

## I got sick of typing "Write-Host", gimme a break powershell
## $1 = the text you want to print to screen
##
## $2 = Send a 1 char (or 2 -- "bl" for black) letter to set your preferred 
## text color (optional, default is white).
##
## $3 = your preferred background color (optional)
##
##  ** Not supported yet -- underlining: Write-Host "$([char]27)[4m Underlined Word $([char]27)[24m"
function w($1,$2,$3){
    $colors = @{
        'w'='white'
        'b'='blue'
        'bl'='black'
        'g'='green'
        'r'='red'
        'y'='yellow'
        'm'='magenta'
        'c'='cyan'
    }
    $colors.keys | %{
        if($2 -eq $_){
            $f = $2
        }
        if($3 -eq $_){
            $b = $3
        }
    }
    if($b -and $f){
        Write-Host -f $colors[$f] -b $colors[$b] "$1"
    }
    elseif($f){
        Write-Host -f $colors[$f] "$1"
    }
    else{
        Write-Host "$1"
    }
}



<######################################
## Set the default startup object
    When you have resources like tables/arrays to be built from text or
    JSON or whatever files, you can base64 encode the file path, add a
    3-letter identifier so that you can easily decode them when necessary,
    then add them to the opening comments in 'utility.ps1'. Make sure to
    separate your strings using '@@@' as delimiters. (or come up with a
    better way to store your default values outside of MACROSS, see the
    utility.ps1 readme).

    The startUp function reads the opening comment from 'utility.ps1' and creates 
    an array of base64 values with the 3-letter identifier as its index. When you
    need to call your encoded filepath, you use the 'getThis' function,
    which returns $vf19_READ as your decoded filepath:

        getThis $vf19_MPOD['abc']
        $your_variable = $vf19_READ

    Additionally, it reads the registry to look for the presence of Wireshark,
    Nmap, and Python. You can add your own checks for programs your scripts
    may require to function.
######################################>
function startUp(){
    ## Check if necessary programs are available; add as many as you need
    #$INST = Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
    $INST = Get-ChildItem 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    foreach($i in $INST){
        $prog = $i.GetValue('DisplayName')
        if($prog -match 'python'){
            $Global:MONTY = $true
            $Global:vf19_pylib = "$vf19_TOOLSROOT" + '\core\py_classes'
            $Global:vf19_GBIO = "$vf19_pylib\garbage_io"      ## Set the garbage-in-garbage-out directory for python scripts
            $Global:vf19_PYPOD = ''                             ## Prep string values for passing to python scripts
            $p = @()
        }
        if($prog -match 'nmap'){
            $Global:MAPPER = $true      ## Can use nmap, yay!
        }
        if($prog -match 'wireshark'){
            $Global:SHARK = $true       ## Can use wireshark, yay!
        }
        if($prog -Match 'excel'){
            $Global:MSXL = $true        ## Can use excel for MACROSS' sheetResults function, yay!
        }
    }


    
    ## Use the integer $N_ in conjunction with $M_ (see validation.ps1) for performing
    ## math, permission checks, obfuscating values, writing hexadecimal strings, etc. without writing
    ## out the actual integers in plaintext. If you deploy MACROSS for multiple users, delete this
    ## comment section. This is NOT a security feature, but sometimes you just need to obfuscate things.
    ##
    ## This value is currently calculated using the first line in MACROSS.ps1. However, If you plan
    ## to perform sensitive mathing, I recommend changing the get-content location to somewhere
    ## external to MACROSS that you control access to.
    ##
    ## To see the default values, from the main menu, enter "debug $N_" or "debug $M_"
    $i = 0
    $mio = (Get-Content "$vf19_TOOLSROOT\MACROSS.ps1" | Select -Index 2) -replace "^..."
    $mio = Get-Content "$vf19_TOOLSROOT\MACROSS.ps1" | Select -Index 0
    $mio -Split('') | %{
        $i = $i + $(ord "$_")
    }
    $Global:N_ = 671042 + ($i * 39)



    ## Arm the missile pod (although Basara's VF-19 only carried missiles once);
    ## populate this global array with any Base64-encoded filepaths that you want shared with your scripts
    ## The contents of vf19_MPOD get read in from the opening comments in temp_config.txt; I recommend
    ## you create your own file to store your values and keep it in a better-secured location. Don't forget
    ## to modify the lines below with your new filepath!
    $Global:vf19_MPOD = @{}
    $a = ''
    $x = Select-String $vf19_TAG "$vf19_TOOLSROOT\core\temp_config.txt" |
        Select-Object -ExpandProperty LineNumber
    while($aa -ne "~~~#>"){
        $aa = $(Get-Content "$vf19_TOOLSROOT\core\temp_config.txt" | Select -Index $x)
        $x++
        $a += $aa
    }
    $b = $($a -replace "~~~#>$") -Split '@@@'
    foreach($c in $b){
        $d = $c.substring(0,3)
        $e = $c -replace "^..."
        $Global:vf19_MPOD.Add($d,$e)
        if($MONTY){
            $p += $c  ## Create a parallel MPOD list that python can read
        }
    }
    if($p.length -gt 0){
        $Global:vf19_PYPOD = $p -join(',')
    }

}


## When writing outputs to screen and you're not using screenResults(), this
## function can write a simple separator if you need to break up lines.
## $1 = the character that makes up the separator
## $2 = the length of the separator line
## $3 = (optional) the color of the separator
##
##  Usage:   sep '*' 16 'yellow'    ## Create a 16 char-length line of "*" in
##                                     yellow text
function sep(){
    Param(
        [Parameter(Mandatory=$true)]
        [string]$1,
        [Parameter(Mandatory=$true)]
        [int]$2,
        [string]$3 = 'WHITE'
    )
    $b = ' '
    1..$2 | %{$b += $1}
    Write-Host -f $3 $b
}


## Display HELP for internal MACROSS functions. Send the tool name as parameter 1
## for its details and usage, or send "dev" to get a full list of descriptions.
## Calling without parameters just lists the Local Attributes table.
function macrossHelp($1){
    $helps = @{
        'w'= @{'d'="Alias for 'Write-Host'. Send your string as the first parameter, and the first letter of the color you want to use ('bl' for black, 'b' for blue). Send another letter as the third parameter to set a highlight color. The default text color is white.";'u'='Usage: w "your text" "[b|bl|c|g|m|r|y]" "[b|bl|c|g|m|r|y]"'}
        'screenResults'= @{'d'="Display large outputs to screen in a table format. Colorize the text by adding '<color>~' to the beginning of your value, i.e. green~$('$'+'value'). Send a single param, 'endr' to create the closing border after your final values.";'u'='Usage: screenResults $VALUE1 $OPTIONAL_VALUE2 $OPTIONAL_VALUE3'}
        'screenResultsAlt'= @{'d'="Similar to screenResults; send the 'header' items of your list first, followed by $('$'+'KEY1') and $('$'+'VALUE1'). If you have more than 2 key-values under each 'header', make the first parameter of each subsequent call 'next'.";'u'='Usage: screenResultsAlt $HEADER $KEY1 $VALUE1; screenResultsAlt "next" $KEY2 $VALUE2'}
        'ord'= @{'d'='Get the decimal value of a text character';'u'='Usage: ord [text char]'}
        'chr'= @{'d'='Get the text character of a decimal value';'u'='Usage: chr [decimal value]'}
        'sheetz'= @{'d'="Output results to an excel worksheet. First parameter is the name of your spreadsheet. Second parameter is the values you're writing, separated by commas. Third parameter is the row to start writing in. If you are adding values to an existing sheet, set this to the next empty row, otherwise set to 1. -Fourth parameter is comma-separated column names, OR if you are editing an existing sheet/don't need column headers, you can send the number of columns you require. -You can colorize text by adding a 'color~' to the beginning of any field in the first parameter's comma-separated list, or colorize the cell by adding 'cellColor~textColor~' to the value.";'u'='Usage: sheetz "myspreadsheet.xlsx"  [comma separated values]  [the next empty row number]  [total number of columns to write|comma-separated column names]'}
        'getThis'= @{'d'="Decode base64 and hex values to plaintext in the global variable $('$'+'vf19_READ'); encode plaintext to base64 string";'u'='Usage: getThis $string [1 to decode hex|0 to encode base64|none to decode base64]'}
        'getFile'= @{'d'='Open a dialog window to let analysts select a file from any local/network location';'u'='Usage: $file = getFile'}
        'yorn'= @{'d'='Open a "yes/no" dialog to get response from analysts so your script can perform an action they choose.';'u'='Usage: if( $( yorn "SCRIPTNAME" $CURRENT_TASK ) -eq "No") { $STOP_DOING_TASK }'}
        'pyCross'= @{'d'="Write your powershell script's results to a generic file that can later be read by MACROSS python scripts. This file is written to a folder, 'core\py_classes\garbage_io', that MACROSS regularly empties.";'u'='Usage: pyCross "myScriptName" $VALUES_TO_WRITE'}
        'stringz'= @{'d'="Extract ASCII characters from binary files. Call this function without parameters to open a nav window and select a file. You can also send a filepath as parameter one. If you do not want to keep the output text file, send 1 as parameter two.";'u'="Usage: stringz ['path\to\file' (optional)] [1 (optional)]"}
        'eMsg'= @{'d'="Send an integer 1-4 as the first parameter to display a canned message, or send your own message as the first parameter.  The second parameter is optional and will change the text color (It must be a color recognized by 'write-host')";'u'='Usage: eMsg [message number|your custom msg] [text color (optional)]'}
        'errLog'= @{'d'="Write messages to MACROSS' log folder. Timestamps are added automatically. You can read these logs by typing 'debug' into MACROSS' main menu.";'u'='Usage: errLog [message level, examples: "INFO"|"WARN"|"ERROR"] [message field 1] [message field 2]'}
        'collab'= @{'d'="Enrich or collect data from other MACROSS scripts. An optional value can be sent as parameter three if the called script's .evalmax value is 2.";'u'='Usage: collab [scriptToCall.extension] [yourScriptName] [optional value]'}
        'getHash'= @{'d'='Get the hash of a file.';'u'='Usage: getHash [filepath] [md5|sha256]'}
        'houseKeeping'= @{'d'="Displays a list of existing reports your script has created, and gives the option of deleting one or more of them if no longer needed.";'u'="Usage: houseKeeping [directory containing your script's report outputs] [yourScriptName]"}
        'sep'= @{'d'='Create a separator line to write on screen if you want to separate simple outputs being displayed.';'u'='Usage: sep [character you want to create line from] [length you want the line to be] [text color of the line (optional)]'}
        'slp'= @{'d'="Alias for 'start-sleep' to pause your scripts. Send the number of seconds to pause as parameter one, and 'm' as the second parameter if you want to pause in milliseconds instead.";'u'='Usage: slp [number of seconds] ["m" (changes seconds to milliseconds)]'}
        'transitionSplash'= @{'d'='This function contains various ASCII art from the MACROSS anime. You can add your own ASCII art here.';'u'='Usage: transitionSplash [1-8]'}
    }
    cls
    if($1 -in $helps.keys){
        w "`n`n`n`n"
        screenResults $1 "$($helps[$1]['d'])"
        screenResults "$($helps[$1]['u'])"
        screenResults 'endr'
        ''
    }
    elseif($1 -eq 'dev'){
        1..33 | %{$m += ' '}
        screenResults "cyan~$m MACROSS FUNCTIONS"
        $helps.keys | Sort | %{
            screenResults $_ $($helps[$_]['d'])
            screenResults "cyan~$($helps[$_]['u'])"
        }
        screenResults 'endr'
        ''
    }
    else{
        TL
    }
    ''
    w 'Hit ENTER to go back.' 'g'; Read-Host
    
}

## Format up to three rows of outputs to the screen; parameters you send will be
## wrapped to fit in their columns (up to 3 separate columns).
## Call this function with "endr" as the only parameter to add the final
## separator $c after all your results have been displayed.
##
## $1 is required, $2 and $3 are optional.
##
##    Example usage for displaying an array of results:
##
##         foreach($i in $results.keys){ screenResults $i $results[$i] }
##         screenResults 'endr'
##
## If you send a value that begins with "red~", for example "red~Windows PC", the
## value "Windows PC" will be written to screen in red-colored text. You can use any
## color recognized by powershell's "write-host -f" option (green, yellow, cyan, etc.)
##
function screenResults(){
    Param(
        [Parameter(Mandatory=$true)]
        [string]$1,
        [string]$2,
        [string]$3,
        [int]$4
    )

    ## Set default colors
    $ncolor = 'YELLOW'
    $v2color = 'GREEN'

    ## Set border sizes; resizing with $4 is not implemented yet!
    if($4 -and $4 -gt 90){
        $tw = $4
    }
    else{
        $tw = 90
    }
    getThis '4oCW'; $c = $vf19_READ
    $r = $c
    getThis '4omh'
    1..$tw | %{$r = $r + $vf19_READ}; $r = $r + $c
    if($1 -Match "^[a-z]+~"){
        $ncolor = $1 -replace "~(.|`n)+"
        $1 = $1 -replace "^([a-z]+~)?"
    }
    elseif($1 -eq 'endr'){
        Write-Host -f GREEN $r
        Return
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

    $NAME = $1
    $wide1 = $NAME.length

    if($2){
        if($2 -Match "^[a-z]+~"){
            $v1color = $2 -replace "~(.|`n)+"
            $2 = $2 -replace "^([a-z]+~)?"
        }
        $VAL1 = $2
        $wide2 = $2.length
        
    
        if($3){
            if($3 -Match "^[a-z]+~"){
                $v2color = $3 -replace "~(.|`n)+"
                $3 = $3 -replace "^([a-z]+~)?"
            }
            $VAL2 = $3
            $wide3 = $3.length
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


<# Alternate output format for MACROSS results; don't use this for large outputs, use
        screenResults instead!

    $1 is the header for each item; set it to 'next' if you want to
    write additional values to the table without a row separator.
    
    $2 and $3 are written below the header.
    $2 will get truncated if longer than 14 chars.

    As with screenResults, send a single parameter, '0', to close out the table.

    Example usage:
        $1 = 'rundll32.exe'
        $2 = 'Parent'
        $3 = 'acrobat.exe'
        $4 = 'ParentID'
        $5 = '2351'

    screenResultsAlt $1 $2 $3
    screenResultsAlt 'next' $4 $5
    screenResultsAlt 'endr'

        The above will write to screen:

    ║║║║║║ rundll32.exe
    ============================================================================
    Parent    ║  acrobat.exe
    ParentID  ║  2351
    ============================================================================

    As with the "screenResults" function, use "<COLOR>~" to highlight your values.

#>
function screenResultsAlt($1,$2,$3){
    
    $1color = 'CYAN'
    $2color = 'GREEN'
    $3color = 'YELLOW'
    $r = '  '
    foreach($i in 1..76){$r += '='};Remove-Variable i
    getThis '4pWR4pWR4pWR4pWR4pWR4pWR'; $c6 = $vf19_READ
    getThis '4pWR'; $c1 = $vf19_READ
    

    if($1 -Match "^[a-z]+~"){
        $1color = $1 -replace "~.+"
        $1 = $1 -replace "^([a-z]+~)?"
    }
    if($2 -Match "^[a-z]+~"){
        $2color = $2 -replace "~.+"
        $2 = $2 -replace "^([a-z]+~)?"
    }
    if($3 -Match "^[a-z]+~"){
        $3color = $3 -replace "~.+"
        $3 = $3 -replace "^([a-z]+~)?"
    }



    if($1 -eq 'endr'){
        Write-Host -f GREEN $r
    }
    else{
        [string]$2 = '  ' + $2
        if($3){
            [int]$2l = $($2.length)
            if($2l -gt 19){
                $2 = $2.Substring(0,15)
                $2 = $2 + '... '
            }
            else{
                while($2l -ne 19){
                    $2 = $2 + ' '
                    $2l++
                }
            }
        }
        if($1 -ne 'next'){
            Write-Host -f $1color "  $c6 $1"
            Write-Host -f GREEN $r
        }
        if($3){
            Write-Host -f $2color "$2" -NoNewline;
            Write-Host -f GREEN "$c1" -NoNewline;
            Write-Host -f $3color " $3"
        }
        else{
            Write-Host -f $2color "$2"
        }
    }
}




## Function to pause your scripts for $1 seconds
##  Send 'm' as a second parameter if you want to change the span to milliseconds
function slp(){
    param(
        [Parameter(Mandatory=$true)]
        [int]$sec,
        [string]$span
    )
    if($span -eq 'm'){
        Start-Sleep -Milliseconds $sec
    }
    else{
        Start-Sleep -Seconds $sec
    }
}



<################################
## Display tool menu to user
    The planned improvement is to rewrite this function so it can
    accomodate more than 20 scripts in the /modules folder. Right
    now, for example, if you have 40 scripts in /modules, the
    scrollPage function will show the first 9 tools in $FIRSTPAGE,
    but would show tools 10-40 in $NEXTPAGE because chooseMods
    only generates two hashtables based on the modules folder file-count
    (single-digit vs. double-digit).
    I also need to standardize scripts' filename length to keep the menu uniform.
    Currently, it only adds whitespace to names less than 7 characters long.
################################>
function chooseMod(){
    $Global:vf19_MENULIST = @{}
    $Global:vf19_MODULENUM = @{}
    $extralist = @(
        'dec',
        'enc',
        'shell',
        'proto',
        'splash',
        'refresh'
    )

    $ct = 1
    $brdr = '  '; 1..70 | %{$brdr += '='}
    $vf19_MENU.keys | Sort |
        %{
            $k1 = $_
            $menuNum = [string]$ct
            if($ct -lt 10){
                $menuNum = '0' + $menuNum
            }
            $desc = $vf19_MENU[$k1].keys
            $fname = $($vf19_MENU[$k1][$desc].fname)
            
            $d0 = $k1.Length
            $d1 = " $menuNum" + ". $k1"
            if($d0 -lt 15){
                $d2 = (15 - $d0)
                while($d2 -gt 0){
                    $d1 += ' '
                    $d2--
                }
            }
            elseif($d0 -gt 15){
                $d1 = $a.substring(0,15)
            }
            $Global:vf19_MODULENUM.Add($ct,$fname)
            $Global:vf19_MENULIST.Add($d1,$desc)
            $ct++
        }
    
        $toolcount = $vf19_MENULIST.count
        $Global:vf19_PAGECT = [math]::Truncate(($toolcount/10) + 1)  ## Generate a new page for every 10 tools in "/modules"

        $vf19_MENULIST.GetEnumerator() | Sort -Property Name | Select -Skip $($vf19_PAGE * 10) | %{
            Write-Host -f CYAN $brdr
            Write-Host -f YELLOW "   $($_.Name -replace "^ 0",'  ') || $($_.Value)"
        }
        Write-Host -f CYAN "$brdr
        "

    SJW 'menu'     ## check user's privilege LOL
    if( $PROTOCULTURE ){
        Write-Host '      ' -NoNewline; w ' PROTOCULTURE IS HOT (enter "proto" to view & clear it) ' 'r' 'bl'
    }
    Write-Host ''

    if( $vf19_MULTIPAGE ){
        Write-Host -f GREEN "   -There are $toolcount tools available. Enter " -NoNewline;
        Write-Host -f YELLOW 'p' -NoNewline;
        w ' for the next Page.' 'g'
    }
    Write-Host -f GREEN '   -Select the module you want (' -NoNewline;
    Write-Host -f YELLOW "1 - $toolcount" -NoNewline;
    w ').' 'g'
    Write-Host -f GREEN '   -Enter "' -NoNewline;
    Write-Host -f YELLOW 'help' -NoNewline;
    w '" and the number of the tool to view its help page' 'g'
    Write-Host -f GREEN '   -Type ' -NoNewline;
    Write-Host -f YELLOW 'shell' -NoNewline;
    w ' to pause and run your own commands' 'g'
    Write-Host -f GREEN '   -Type ' -NoNewline;
    Write-Host -f YELLOW 'dec' -NoNewline;
    Write-Host -f GREEN ' or ' -NoNewline;
    Write-Host -f YELLOW 'enc' -NoNewline;
    w ' to do Hex/B64 evals.' 'g'
    Write-Host -f GREEN '   -Type ' -NoNewline;
    Write-Host -f YELLOW 'q' -NoNewline;
    w ' to quit.
    ' 'g'

    ## If version control is in use, offer options to pull fresh or updated
    ## copies of all the scripts.
    if( $vf19_VERSIONING ){
    Write-Host -f GREEN '                               TROUBLESHOOTING:
   If the console is misbehaving, you can enter ' -NoNewline;
    Write-Host -f CYAN 'refresh' -NoNewline;
    Write-Host -f GREEN ' to automatically
   pull down a fresh copy. Or, if one of the tools is not working as you
   expect it to, enter the module # with an ' -NoNewline;
    Write-Host -f CYAN 'r' -NoNewline;
    Write-Host -f GREEN " to refresh that script
   (ex. '3r').
   
   "
   }



    Write-Host -f GREEN '                        SELECTION: ' -NoNewline;
        $Global:vf19_Z = Read-Host

        
        if( $vf19_Z -in $extralist ){
            extras $vf19_Z            ## Access extra tasks
        }
        elseif( $vf19_Z -Like "help*" -and $vf19_Z -Match "\d"){
            $Global:HELP = $true   ## Launch the selected script's man page/help menu
            $Global:vf19_Z = $vf19_Z -replace "help(\s)?"
            availableMods $([int]$vf19_Z)
        }
        elseif( $vf19_Z -Like "help*"){
            macrossHelp "$($vf19_Z -replace "help(\s)?")"
        }
        elseif( $vf19_Z -Match $vf19_CHOICE ){
            if( $vf19_Z -Like "*r" ){
                $Global:vf19_Z = $vf19_Z -replace 'r'
                $Global:vf19_REF = $true      ## Triggers the dlNew function (updates.ps1) to download fresh copy of the selected script before executing it
            }
            elseif( $vf19_Z -Like "*s" ){
                $Global:vf19_Z = $vf19_Z -replace 's' 
                $Global:vf19_OPT1 = $true     ## Triggers the selected script to switch modes/enable added functions
            }
            elseif( $vf19_Z -Like "*w" ){
                $Global:vf19_Z = $vf19_Z -replace 'w'
                $Global:vf19_NEWWINDOW = $true   ## Triggers the availableMods function to launch the selected script in a new powershell window
            }
            else{
                $Global:HELP = $false
                $Global:vf19_OPT1 = $false
            }
            ## availableMods (validation.ps1) checks to see if script exists, then launches with any selected options
            availableMods $([int]$vf19_Z)
        }
        elseif( $vf19_Z -eq 'p' ){
            if( $vf19_MULTIPAGE ){
                scrollPage          ## Changes menu to show 1-9 vs 10-20
            }
            $Global:vf19_Z = $null  ## scrollPage only works if there's more than 9 tools in the modules folder
        }
        elseif( $vf19_Z -eq 'q' ){
            varCleanup 1
            Exit                    ## User chose to quit MACROSS
        }
        elseif( $vf19_Z -Match "^debug" ){
            if($vf19_Z -Match ' '){
                $p = $($vf19_Z -replace "^debug ")
            }
            else{
                $p = $null
            }
            debugMacross $p      ## Enables setting error message display or suppression
        }
        Clear-Variable -Force vf19_Z

}

################################
## Menu will dynamically add a page for every 10 tools
## This function lets users sequentially "flip pages"
################################
function scrollPage(){
    if( $vf19_PAGECT -gt 1 ){
        $Global:vf19_PAGE++
        if( $vf19_PAGE -ge $vf19_PAGECT ){
            $Global:vf19_PAGE = 0
        }
        splashPage
        chooseMod
    }
}
