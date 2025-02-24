#_sdf1 Demo - Review My Code
#_ver 0.2
#_class 0,user,demo script,powershell,HiSurfAdvisory,0,none

<#

    This script is a simple demonstration of collecting information
    from one script and passing it others that could add more detail
    or uncover more indicators related to your SOC investigations.

#>

###################################################################################
###       README ~~~~~~~~~ MACROSS PYTHON INTEGRATION EXAMPLE
###################################################################################
## If you want your powershell scripts to work with MACROSS python scripts,
## you need to add a param named $pythonsrc with the value $null, and
## copy-paste the "if( $pythonsrc ){ }" check below. This allows MACROSS core functions
## to be loaded, and executing the "restoreMacross" function will reload all
## the default values your script might need, including $PROTOCULTURE.
param(
    ## If you want your scripts to accept non-$PROTOCULTURE values, use the param name 
    ##  "$spiritia"; this is the name used by MACROSS' collab function to pass parameter values.
    $spiritia,
    $pythonsrc = $null  ## The python valkyrie.collab() function will set this value
)
if( $pythonsrc ){

    ## This will be the name of the python script calling this one
    $Global:CALLER = $pythonsrc

    ## This is a unique temporary session, so launch the core scripts to access their functions
    foreach( $core in gci "core\*.ps1" ){ . $core.fullname }

    ## Now that the core files are loaded, this function can restore all the MACROSS 
    ## defaults your powershell script might need
    restoreMacross
    
    ## Note that just like the powershell version, the python collab function can also
    ## send an alternate param to your scripts when relevant. So, you can write your  
    ## scripts to accept a value called "$spiritia" in addition to (or instead of) $PROTOCULTURE, 
    ## if necessary.
}

function rdh(){ 
    w "`n Hit ENTER to continue.`n" g; Read-Host 
}
function splashPage(){
    param([switch]$h=$false)
    cls
    if($h){
        ''
        screenResults '[macross] attributes:' ' .access | .priv | .valtype | .lang | .auth | .evalmax | .rtype | .ver | .fname'
        screenResults 'Variables to remember' '$PROTOCULTURE, $CALLER, $RESULTFILE, $vf19_MPOD, $vf19_LATTS'
        screenResults -e
    }
    else{
    $b = 'ICAgICAgIOKWiOKWiOKVlyAg4paI4paI4pWX4paI4paI4pWX4paI4paI4pWXICDilojiloj
    ilZcg4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKVlyDilojilojilZcgICDi
    lojilojilZcKICAgICAgIOKWiOKWiOKVkSAg4paI4paI4pWR4paI4paI4pWR4paI4paI4pWRIOKWi
    OKWiOKVlOKVneKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+
    KWiOKWiOKVkSAgIOKWiOKWiOKVkQogICAgICAg4paI4paI4paI4paI4paI4paI4paI4pWR4paI4pa
    I4pWR4paI4paI4paI4paI4paI4pWU4pWdIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkeKWiOKWiOKW
    iOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVkSAgIOKWiOKWiOKVkQogICAgICAg4paI4paI4pWU4pWQ4
    pWQ4paI4paI4pWR4paI4paI4pWR4paI4paI4pWU4pWQ4paI4paI4pWXIOKWiOKWiOKVlOKVkOKVkO
    KWiOKWiOKVkeKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVkSAgIOKWiOKWiOKVkQogICA
    gICAg4paI4paI4pWRICDilojilojilZHilojilojilZHilojilojilZEgIOKWiOKWiOKVl+KWiOKW
    iOKVkSAg4paI4paI4pWR4paI4paI4pWRICDilojilojilZHilZrilojilojilojilojilojilojil
    ZTilZ0KICAgICAgIOKVmuKVkOKVnSAg4pWa4pWQ4pWd4pWa4pWQ4pWd4pWa4pWQ4pWdICDilZrilZ
    DilZ3ilZrilZDilZ0gIOKVmuKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWdIOKVmuKVkOKVkOKVkOK
    VkOKVkOKVnSA='
    getThis $b
    Write-Host '
    '
    Write-Host -f YELLOW $vf19_READ
    Write-Host -f CYAN '       A demo of MACROSS as an automation hub
    
    '
    }
    
}

function header(){
    screenResults 'Unlisted options in the MACROSS menu:' 
    screenResults '"config" opens the MACROSS configuration wizard. You can add or change configs after supplying the admin password.' `
    '"debug" opens the MACROSS debugger. You can view the core help files and run test commands using MACROSS functions, including its python library.' `
    '"splash" quickly cycles through the various ascii images of MACROSS characters.'
    screenResults -e
}


## It is recommended that you include a check for the $HELP variable, and display a
## help/description if it is $true. MACROSS clears this variable when your script exits.
if($HELP){
    splashPage
    $vf19_LATTS.HIKARU.toolInfo() | %{
        w $_ y
    }
    w "
      ======================================================================
  HIKARU is a simple demo on how to use the MACROSS base to connect your
  scripts together. The main goal of MACROSS is to automate your automations;
  give even your most junior analysts the ability to get as much information as
  quickly and easily as any crusty ol' command-line junkie -- on a budget!
  
  HIKARU will talk to the tools MISA and GUBABA. MISA is a python script that
  performs a similar demonstration. Review the code for both demo scripts to see
  how you need to write or modify your own tools to make full use of MACROSS.

  Hit ENTER to exit.
  " y
    Read-Host
    Exit
}

## When MACROSS' collab() function is used, it sets the calling script's name as $CALLER.
## In this way, you can both track what script is calling, and what the $CALLER's [macross]
## class attributes are so you can automatically tailor responses. All tools and their
## attributes are tracked in the array $vf19_LATTS in powershell, or LATTS in python.
if($CALLER -and $vf19_LATTS.$CALLER.valtype -Like "*user*"){
    w " Congratulations Caller! " g
    w " Hit ENTER to continue." -i g; Read-Host
}
else{
    transitionSplash 8  ## Displays the number 8 ascii art
    splashPage          ## Displays HIKARU's title in block-text
    header

    ## The "w" function is an alias for write-host, and allows changing text color,
    ## underlining and highlighting.
    w "

    This demo will ask you for a search term to find a Windows event ID. The keyword(s) 
    you enter here will be sent to the MISA python script, which will then forward it to 
    the GUBABA.ps1 script and retrieve GUBABA's results.

    This is a very simple demonstration of how you can connect your scripts together. View
    the code in HIKARU.ps1 and MISA.py to see how the `"availableTypes`" and `"collab`"
    functions are used to connect scripts wherever you find it useful to do so.
    " g

    while($z -notMatch "\w{3,}"){
        w "Enter a keyword or ID number to search for an event ID: " g -i
        $z = Read-Host
    }

    ## Where it makes sense, have your scripts automatically act on $PROTOCULTURE any time it has a value
    $Global:PROTOCULTURE = $z

    ## The availableTypes function collects all of the scripts in the modules folder that match
    ## your [macross] criteria. In this example, I search for the .valtype "demo script" and the  
    ## .lang value "python" (MISA is the only script that will match).  The -e option forces exact
    ## matches, otherwise you'll get back tools that match all the words you use in -v.
    ## You can also search by response types (.rtype).
    $list = availableTypes -v 'demo script' -l python -e

    ## The collab function loads whatever script you require next, within your MACROSS session.
    ## In this basic demo, I'm just calling the python script MISA, who will see the $PROTOCULTURE
    ## and forward it to the GUBABA powershell script. This is only meant to demonstrate how to get
    ## data from one script to the next for evaluations.
    Foreach($pytool in $list){
        
        collab $pytool HIKARU

        ## When values are forwarded to python scripts, the MACROSS valkyrie python library provides
        ## its own collab function. Instead of writing $global variables, it writes search results
        ## to a json-format file called PROTOCULTURE.eod (which can always be referenced as $vf19_PYG[1]
        ## in powershell scripts).

        if(Test-Path -Path $vf19_PYG[1]){
            w "`n HIKARU is now reading MISA's response from `n" g
            w "  $($vf19_PYG[1])`n"
            w " and will show you the same results:" g


            ## When your script is going to read a python response from PROTOCULTURE.eod, the top-level item
            ## should be your script's name. The "result" item is where you'll find the python script's response
            ## to your collab query. Make sure you know what the previous script's output or ".rtype" is,  
            ## if it's a large hashtable it may get written to PROTOCULTURE.eod as one or more nested json objects!
            ## The file is located in "core\macross_py\garbage_io\" and gets regularly deleted after use.
            $readFromPy = (Get-Content $vf19_PYG[1] | ConvertFrom-Json).HIKARU.result
            
            Foreach($k in $readFromPy.PSObject.Properties.Name){

                if(($readFromPy.$k).getType().Name -eq 'String'){
                    $v = $readFromPy.$k
                }
                else{
                    $v = "$($readFromPy.$k[0]) -- $($readFromPy.$k[1])"
                }
                

                ## MACROSS offers a few different ways to display your data. "screenResults" Can take large
                ## blocks of info and split them evenly into rows & columns. If you begin your string with 
                ## the first letter of a color, like "c" for cyan, along with the ~ character, it tells 
                ## screenResults to colorize the text with colors other than the default. This is useful for 
                ## highlighting data that matches parameters you may be interested in. (There is also 
                ## "screenResultsAlt" which writes smaller outputs in a header-list format.)
                screenResults "c~$k" $v
            }
            screenResults -e
        }
    }

    "`n"

    if(Test-Path -Path $vf19_PYG[1]){

        ## The "sep" function lets you quickly generate division lines to break up
        ## blocks of text. You can use any character or pattern of characters you like!
        sep '~@~' 25 -c g; sep '~@~' 25 -c g
        w "
    The garbage_io folder can be referenced by your scripts as `$vf19_PYG[0] if
    necessary, and it gets cleaned out every time MACROSS starts & exits. The function 
    `"pyCross`" can be used by your powershell scripts to write values to this folder 
    for python scripts to read, and vice versa.

    The default file used is a json-format PROTOCULTURE.eod, but pyCross will create
    files with different names if you choose.

    Type `"debug`" in the main menu to load the debugger, where you can read help files
    for all of MACROSS' utility functions, and test them out in a mini-playground
    (including python).
    " g
        while($z -ne 'e'){
            w "Enter `"e`" to exit: " -i y
            $z = Read-Host
        }
    }
}


Exit


