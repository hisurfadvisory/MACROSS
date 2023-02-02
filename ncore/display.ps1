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
    $ip = $(ipconfig | Select-String "IPv4 Address") -replace "^.* : ",""
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


## Function to pause your scripts for $1 seconds
function slp(){
    param(
        [Parameter(Mandatory=$true)]
        [int]$sec
    )
    Start-Sleep -Seconds $sec
}



<######################################
## Set the default startup object
    When you have resources like tables/arrays to be built from text or
    JSON or whatever files, you can base64 encode the file path, add a
    3-letter identifier so that you can easily decode them when necessary,
    then add them to the opening comments in 'utility.ps1'. Make sure to
    separate your strings using '@@@' as delimiters.

    This function reads the opening comment from 'utility.ps1' and creates an 
    array of base64 values with the 3-letter identifier as its index. When you
    need to call your encoded filepath, you use the 'getThis' function,
    which returns $vf19_READ as your decoded filepath:

        getThis $vf19_MPOD['abc']
        $your_variable = $vf19_READ

    Additionally, it reads the registry to look for the presence of Wireshark,
    Nmap, and Python. You can add your own checks for programs your scripts
    may need to function.

######################################>
function startUp(){
    ## Check if necessary programs are available; add as many as you need
    #$INST = Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
    $INST = Get-ChildItem 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    foreach($i in $INST){
        $prog = $i.GetValue('DisplayName')
        if($prog -match 'python'){
            $Global:MONTY = $true              ## Confucious say: 'Python is less stressful than powershell'
            #getThis $Global:vf19_MPOD['gbg']
            #$Global:vf19_GBIO = $vf19_READ     ## Set the garbage-in-garbage-out directory for python scripts
            $Global:vf19_PYOPT = ''            ## Prep string values for passing to python scripts
            $p = @()
        }
        if($prog -match 'nmap'){
            $Global:MAPPER = $true  ## Can use nmap, yay!
        }
        if($prog -match 'wireshark'){
            $Global:SHARK = $true  ## Can use wireshark, yay!
        }
    }

    ## Arm the missile pod (although Basara's VF-19 only carried missiles once);
    ## populate this global array with any Base64-encoded filepaths that you want shared with your scripts
    ## The contents of vf19_MPOD get read in from the opening comments in utility.ps1
    $Global:vf19_MPOD = @{}
    $aa = @()
    $x = Select-String $vf19_TAG "$vf19_TOOLSROOT\ncore\utility.ps1" |
        Select-Object -ExpandProperty LineNumber
    while($a -ne '#>'){
        $a = Get-Content "$vf19_TOOLSROOT\ncore\utility.ps1" | Select -Index $x
        $aa += $a
        $x++
    }
    $b = $aa -Join ''
    $b = $b -replace "#>$",''
    $b = $b -Split '@@@'
    foreach($c in $b){
        $d = $c.substring(0,3)
        $e = $c -replace "^...",''
        $Global:vf19_MPOD.Add($d,$e)
        if($MONTY){
            $p += $c  ## Create a parallel options list that python can read
        }
    }
    if($p.length -gt 0){
        $Global:vf19_PYOPT = $p -join(',')
    }

}





<################################
## Display tool menu to user

    You will notice an 'if' statement in this chooseMod function:

        if( $_ -Match 'GERWALK' )

    This is setting a global variable that lets all MACROSS scripts
    know that the Carbon Black API script is available to be queried
    (and by extension, if you have GERWALK in the nmods folder, that
    assumes you also have Carbon Black).

    You can tweak this to set different global values that will let
    your scripts know that other scripts they might want to interact
    with are available for use... very helpful for any other APIs you
    want to integrate into MACROSS.

    The planned improvement is to rewrite this function so it can
    accomodate more than 20 scripts in the /nmods folder. Right
    now, for example, if you have 40 scripts in /nmods, the
    scrollPage function will show the first 9 tools in $FIRSTPAGE,
    but would show tools 10-40 in $NEXTPAGE because chooseMods
    only generates two hashtables based on the nmods folder file-count
    (single-digit vs. double-digit).

    I also need to auto-truncate if filename is longer than 7 characters
    to keep the menu uniform. Currently, it only adds whitespace to names
    less than 7 characters long.

################################>
function chooseMod(){
    $Global:vf19_FIRSTPAGE = @{}
    $Global:vf19_NEXTPAGE = @{}
    $Global:vf19_MODULENUM = @()
    if( $MONTY ){
        $Global:vf19_pylib = "$vf19_TOOLSROOT\ncore\py_classes"  ## Filepath to the MACROSS py library
        $ftypes = "*.p*"                                         ## Integrate python scripts if Python3 is installed
    }
    else{
        $ftypes = "*.ps*"                                        ## Ignore py files if Python3 not installed
    }
    $vf19_LISTDIR = Get-ChildItem "$vf19_TOOLSDIR\$ftypes" | Sort Name     ## Get the names of all the scripts in alpha-order

    # Enumerate the nmods\ folder to find all scripts; all of my scripts  
    # contain a descriptor on the first line beginning with '_superdimensionfortress'
    $vf19_LISTDIR |
    Select -First 9 | 
    ForEach-Object{
        if( Get-Content $_.FullName | Select-String -Pattern "^#_superdimensionfortress.*" ){   # Verify the script is meant for MACROSS
            if( $_ -Match 'GERWALK' ){
                $Global:vf19_G1 = $true   ## Tells other scripts Carbon-Black script is available for queries
            }
            if( $_ -Match 'ELINTS' ){
                $Global:vf19_E1 = $true   ## Tells other scripts String-Search script is available for queries
            }
            $d1 = Get-Content $_.FullName -First 1         # Grab the first line of the script
            $d1 = $d1 -replace("^#_superdimensionfortress[\S]* ",'')          # Remove the 'superdimensionfortress'
            $d2 = $_ -replace("\.p.+$",'')    # Remove the file extension, only care about the name
            $d2 = $d2 -replace("^.+\\",'')    # Remove the filepath
            $d3 = $d2.Length                  # Count how many characters in the filename
            if($d3 -lt 7){
                $d4 = (7 - $d3)
                while($d4 -gt 0){
                    $d2 = $d2 + ' '      # Format the name to append whitespaces so the length adds up to 7 characters; 
                    $d4--                # this keeps the list uniform on the screen
                }
            }
            # Create an array containing each script name and its description
            $Global:vf19_FIRSTPAGE.Add("$d2","$d1")
        }

        
    }

    ## Repeat the above to create a new menu page if there are more than 9 tools available
    if( $vf19_FILECT -gt 9 ){
        $Global:vf19_MULTIPAGE = $true
        $vf19_LISTDIR |
        Select -Skip 9 | 
        ForEach-Object{
            if( Get-Content $_.FullName | Select-String -Pattern "^#_superdimensionfortress.*" ){
                if( $_ -Match 'GERWALK' ){
                    $Global:vf19_G1 = $true   ## Tells other scripts Carbon-Black script is available for queries
                }
                if( $_ -Match 'ELINTS' ){
                    $Global:vf19_E1 = $true   ## Tells other scripts String-Search script is available for queries
                }
                $d5 = Get-Content $_.FullName -First 1
                $d5 = $d5 -replace("^#_superdimensionfortress[\S]* ","")
                $d6 = $_ -replace("\.p.+$",'')
                $d6 = $d6 -replace("^.+\\",'')
                $d7 = $d6.Length
                if($d7 -lt 7){
                    $d8 = (7 - $d7)
                    while($d8 -gt 0){
                        $d6 = $d6 + " "
                        $d8--
                    }
                }
            }

            # Create an array containing each script name and its description
            $Global:vf19_NEXTPAGE.Add("$d6","$d5")
        }
    }

    $vf19_MODCT = 0

    ####################
    # Use the arrays to generate the list of active scripts/modules for the user to choose from
    ####################
    if( $Global:vf19_PAGE -eq 'X' -or $Global:vf19_PAGE -eq $null ){
        $vf19_FIRSTTOOL = '1'
        foreach($vf19_STUFF in $Global:vf19_FIRSTPAGE.GetEnumerator()){
            $vf19_MODCT++
            $d_a = $vf19_STUFF.Key

            # The names formatted for the MODULES array need to have their whitespaces stripped
            $d_a1 = $d_a -replace("\s*",'')

            # figure out what the extension is...
            $ext = (Get-ChildItem $vf19_TOOLSDIR | where{$_ -Match "$d_a1"}) -replace "^.+\.p",'.p'

            # ...and add the correct extension back in for a new array
            $d_a1 = $d_a1 -replace("$", "$ext")

             # This array tracks the scripts with an index for the availableMods function
            $Global:vf19_MODULENUM += $d_a1
            $d_b = $vf19_STUFF.Value

            # Write the script number, name, and description together
            $d_c = "   $vf19_MODCT. " + $d_a + "|| " + $d_b

            ## Iterate through the key-value pairs in vf19_MODULES table and write them to the screen
            Write-Host -f CYAN "  ======================================================================"
            Write-Host -f YELLOW "   $d_c"
    
        }
    }
    ## Build the $NEXTPAGE menu if user selected 'p'; mirrors previous instructions but with new vars
    else{
        $vf19_FIRSTTOOL = '10'
        $vf19_MODCT = 9
        splashPage
        foreach($vf19_STUFF in $Global:vf19_NEXTPAGE.GetEnumerator()){
            $vf19_MODCT++
            $d_d = $vf19_STUFF.Key
            $d_d1 = $d_d -replace("\s*",'')
            $ext = (Get-ChildItem $vf19_TOOLSDIR | where{$_ -Match "$d_a1"}) -replace "^.+\.p",'.p'
            $d_d1 = $d_d1 -replace("$", "$ext")
            $Global:vf19_MODULENUM += $d_d1
            $d_e = $vf19_STUFF.Value
            $d_f = "   $vf19_MODCT. " + $d_d + "|| " + $d_e
            Write-Host -f CYAN "  ======================================================================"
            Write-Host -f YELLOW "   $d_f"
    
        }
    }

    Write-Host -f CYAN "  ======================================================================
    "

    SJW 'menu'     ## check user's privilege LOL
    if( $PROTOCULTURE ){
        Write-Host -f RED "   PROTOCULTURE IS HOT (enter 'proto' to view & clear it)"
    }
    Write-Host ''

    if( $vf19_MULTIPAGE ){
        Write-Host -f GREEN '   -There are more than 9 tools available. Hit ' -NoNewline;
        Write-Host -f YELLOW 'p' -NoNewline;
        Write-Host -f GREEN ' for the next Page.'
    }
    Write-Host -f GREEN '   -Select the module for the tool you want (' -NoNewline;
    Write-Host -f YELLOW "$vf19_FIRSTTOOL-$vf19_MODCT" -NoNewline;
    Write-Host -f GREEN '). Add an ' -NoNewline;
    Write-Host -f YELLOW 'h' -NoNewline;
    Write-Host -f GREEN ' to view'
    Write-Host -f GREEN "      a help/description of the tool (ex. '1h')."
    Write-Host -f GREEN '   -Type ' -NoNewline;
    Write-Host -f YELLOW 'shell' -NoNewline;
    Write-Host -f GREEN ' to pause and run your own commands.'
    Write-Host -f GREEN '   -Type ' -NoNewline;
    Write-Host -f YELLOW 'dec' -NoNewline;
    Write-Host -f GREEN ' or ' -NoNewline;
    Write-Host -f YELLOW 'enc' -NoNewline;
    Write-Host -f GREEN ' to do Hex/B64 evals.'
    Write-Host -f GREEN '   -Type ' -NoNewline;
    Write-Host -f YELLOW 'q' -NoNewline;
    Write-Host -f GREEN ' to quit.
    '

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


    if( $vf19_Z -eq 'dec' ){
        decodeSomething 0 ## function to decode obfuscated strings; see utility.ps1
    }
    elseif( $vf19_Z -eq 'enc' ){
        decodeSomething 1 ## function to encode plaintext strings; see utility.ps1
    }
    elseif( $vf19_Z -eq 'shell' ){
        runSomething     ## pauses the console so user can run commands; see utility.ps1
    }
    elseif( $vf19_Z -Match "^debug" ){
        if($vf19_Z -Match ' '){
            $p = $vf19_Z -replace "^debug "
        }
        else{
            $p = $null
        }
        debugMacross $p      ## Enables setting error message display or suppression
    }
    
    elseif( $vf19_Z -eq 'proto' ){
        $sp = $(Get-Random -min 0 -max 9)
        transitionSplash $sp 1
        [string]$proto = $PROTOCULTURE
        $proto = $proto.Substring(0,20)
        Write-Host "
        PROTOCULTURE == $proto...
        Do you want to clear it?  " -NoNewline;
        $z = Read-Host
        if($z -Match "^y"){
            $Global:PROTOCULTURE = $null     ## clear the primary investigation value
        }
        Remove-Variable -Force z,sp,proto
    }
    elseif( $vf19_Z -eq 'splash' ){  ## Easter egg
        $Global:vf19_Z = 0
        $screens = [int](gc "$vf19_TOOLSROOT\ncore\splashes.ps1" | Select-String 'b =').count
        while( $vf19_Z -lt $screens ){
            transitionSplash $vf19_Z
            $Global:vf19_Z++
        }
        $Global:vf19_Z = $null
        Remove-Variable screens

    }
    elseif( $vf19_Z -Match $vf19_CHOICE ){
        if( $vf19_Z -Match "[0-9]{1,2}h" ){
            $Global:vf19_Z = $vf19_Z -replace('h','')
            $Global:HELP = $true   ## Launch the selected script's man page/help menu
        }
        elseif( $vf19_Z -eq 'p' ){
            if( $vf19_MULTIPAGE ){
                scrollPage   ## Changes menu to show 1-9 vs 10-20
            }
            $Global:vf19_Z = $null  ## scrollPage only works if there's more than 9 tools in the nmods folder
        }
        elseif( $vf19_Z -eq 'q' ){
            $Global:vf19_Z = $null
            Break                    ## User chose to quit MACROSS
        }
        elseif( $vf19_Z -Match "[0-9]{1,2}r" ){
            $Global:vf19_Z = $vf19_Z -replace('r','')
            $Global:vf19_REF = $true      ## Triggers the dlNew function (updates.ps1) to download fresh copy of the selected script before executing it
        }
        elseif( $vf19_Z -Match "[0-9]{1,2}s" ){
            $Global:vf19_Z = $vf19_Z -replace('s','')
            $Global:vf19_OPT1 = $true     ## Triggers the selected script to switch modes/enable added functions
        }
        elseif( $vf19_Z -Match "[0-9]{1,2}w" ){
            $Global:vf19_Z = $vf19_Z -replace('w','')
            $Global:vf19_NEWWINDOW = $true   ## Triggers the availableMods function to launch the selected script in a new powershell window
        }
        elseif( $vf19_Z -eq 'refresh' ){
            dlNew "MACROSS.ps1" $vf19_LVER  ## Downloads a fresh copy of MACROSS and the ncore files, then exits
        }
        else{
            $Global:HELP = $false
            $Global:vf19_OPT1 = $false
        }


        ## availableMods (validation.ps1) checks to see if script exists, then launches with any selected options
        if( $vf19_Z -Match "[0-9]"){
            availableMods $vf19_Z
        }
    }
    Clear-Variable -Force vf19_Z

}

################################
## If more than 9 tools are available, split into two menus
################################
function scrollPage(){
    ##  X = 1st page, Y= 2nd page
    if( $vf19_FILECT -gt 9 ){
        if( $vf19_PAGE -eq 'X' ){
            $Global:vf19_PAGE = 'Y'
        }
        elseif( $vf19_PAGE -eq 'Y' ){
            $Global:vf19_PAGE = 'X'
        }
        splashPage
        chooseMod
    }
}
