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

    ## This is a unique temporary session, so launch the core scripts to get their functions
    foreach( $core in gci "core\*.ps1" ){ . $core.fullname }

    ## Now that the core files are loaded, this function can restore all the MACROSS 
    ## defaults your powershell script might need
    restoreMacross
    
    ## Note that just like the powershell version, the python collab function can also
    ## send an alternate param to your scripts when relevant. So, you can write your  
    ## scripts to accept a value in addition to (or instead of) $PROTOCULTURE, if necessary.
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
## help/description if it is true. MACROSS clears this variable when your script exits.
if($HELP){
    splashPage
    $vf19_LATTS['HIKARU'].toolInfo() | %{
        w $_ y
    }
    w "
      ======================================================================
  HIKARU is a simple demo on how to use the MACROSS base to connect your
  scripts together. The main goal of MACROSS is to automate your automations;
  give even your most junior analysts the ability to get as much information as
  quickly and easily as any crusty ol' command-line junkie -- on a budget!
  
  HIKARU will talk to the tools MINMAY and GUBABA. MINMAY is a python script that
  performs a similar demonstration. Review the code for both demo scripts to see
  how you need to write or modify your own tools to make full use of MACROSS.

  Hit ENTER to exit.
  " y
    Read-Host
    Exit
}

## When MACROSS' collab() function is used, it sets the calling script's name as $CALLER.
## In this way, you can both track what script is calling, and what the $CALLER's [macross]
## class attributes are so you can automatically tailor responses.
if($CALLER){
    $j = Get-Content -raw "$vf19_TOOLSROOT\resources\hikaru_demo.txt" | ConvertFrom-Json
    $j | %{
        $j."$_" = "$($_ -replace "smithj","$PROTOCULTURE")"
    }
    screenResultsAlt -h $j.samAccountName -k 'Created' -v "$($j.Created)"
    screenResultsAlt -k 'Last Logon' -v "$($j.LastLogonDate)"
    screenResultsAlt -k "Password Expired" -v "$($j.PasswordExpired)"
    screenResultsAlt -k "r~Passw Never Expires" -v "$($j.PasswordNeverExpires)"
    screenResultsAlt -k "Email" -v "$($j.EmailAddress)"
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
    you enter here will be sent to the MINMAY python script, which will then forward it to 
    the GUBABA.ps1 script and retrieve GUBABA's results.

    This is a very simple demonstration of how you can connect your scripts together. View
    the code in HIKARU.ps1 and MINMAY.py to see how the `"availableTypes`" and `"collab`"
    functions are used to connect scripts wherever you find it useful to do so.
    " g

    while($z -notMatch "\w{3,}"){
        w "Enter a keyword or ID number to search for an event ID: " g -i
        $z = Read-Host
    }

    ## Where it makes sense, have your scripts automatically act on $PROTOCULTURE any time it has a value
    $Global:PROTOCULTURE = $z

    ## The availableTypes function collects all of the scripts in the modules folder that match
    ## your [macross] criteria. In this example, I search for the .valtype "demo" and the  
    ## .lang value "python"
    $list = availableTypes -v 'demo' -l python

    ## The collab function loads whatever script you require next, within your MACROSS session
    ## In this basic demo, I'm just pushing your search over to the python script MINMAY, who
    ## will then forward it to GUBABA. This is only meant to demonstrate how to get data from
    ## one script to the next for evaluation or enrichment.
    $list | Foreach-Object{
        $pytool = $_
        collab $pytool 'HIKARU'
        $json = (Get-Content $vf19_PYG[1] | ConvertFrom-Json).HIKARU.result
        ''
        ## When values are forwarded to python scripts, the MACROSS valkyrie python library provides
        ## its own collab function. Instead of writing $Global variables, it writes search results
        ## to a basic json file at $vf19_PYG[1]. If the response is a list or hashtable, MACROSS
        ## converts it into a string separated by '@@' that you can split.
        if(Test-Path -Path $vf19_PYG[1]){
            w "HIKARU is now reading MINMAY's response from 
            " g
            w " $($vf19_PYG[1])
            "
            $Result = $json -Split '@@'
            $Result | Foreach-Object{
                $k = ($_ -Split ':')[0]
                $v = ($_ -Split ':')[1]

                ## MACROSS offers a few different ways to display your data. "screenResults" Can take large
                ## blocks of info and split them evenly into columns.
                screenResults "c~$k" $v
            }
            screenResults -e
        }
    }
    w '
    '
    if(Test-Path -Path $vf19_PYG[1]){

        ## The "sep" function lets you quickly generate division lines to break up
        ## blocks of text.
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
            w "Enter `"e`" to exit: " g
            $z = Read-Host
        }
    }
}


Exit
