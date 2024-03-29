#_sdf1 Front end for investigation toolset
#_ver 3.1
<#
    Multi-API-Cross-Search (MACROSS) Console
    Automated powershell framework for blue teams
    With a little tweaking, you can link all your automation scripts
    together with MACROSS to give your team quick and easy access
    to any data that can help their investigations.
    
    Author: HiSurfAdvisory
    
    'Script' & 'Tool' are used interchangebly in my comments. Sorry.
	
    v3.1
    :Modified the update functions to:
        -allow automatically refreshing scripts if they get borked
    :Also made performance optimizations; scripts can now check for
        $vf19_ROBOTECH to descriminate users vs. admins to restrict when
        certain functions get loaded to save on resources.
    :Cleaned up the mcdefs python library
	
    TO DO:
		-Clean up and condense repeating instructions
		-Automate the creation of multiple menu hashtables
			to keep the screen from cluttering as more tools
			get added. Currently using $FIRSTPAGE and $NEXTPAGE
			to limit the menu to 10 tools at a time (max 20
			until I can rework the "chooseMod" function to
			handle more).
		-Improve integration with python scripts
	
	ADDING NEW SCRIPTS:
    1. Any new ps or py tools you want added to MACROSS, just add
        this as the FIRST line of your script, and put the script
        in the \nmods folder: 
		
			#_sdf1 <your brief description of the script>
				
        The "#_sdf1 " is necessary to identify scripts
        created for MACROSS (don't forget the whitespace). The description
        line is what gets written to the menu for users to see.
        Scripts without this line will be ignored.
		
    2. The second line is used for version control. It should begin
        "#_ver 0.1" or whatever number you want to use. MACROSS
        strips out the "#_ver " to get the version number from the
        local copy of the script, and compares it to the version number
        in the master copy (See the verChk function in updates.ps1).
        If the master copy is a higher number, MACROSS will grab the updated 
        version.
		
	3. The third line describes your script. MACROSS uses its own custom powershell
		class 'macross' to identify what scripts do. Review the classes.ps1 file
		for how this works in detail, but your third line should contain
		
			#_class
			
		followed by your [macross] class attributes.
		
	4. Keep the script name under 7 characters to preserve the menu's
		uniformity (not including the '.ps1' file extension, MACROSS
		automatically ignores it).
		
	5. Where possible, begin your variables (especially global ones) with 'dyrl_',
        for example $dyrl_var1.

		MACROSS flushes all variables beginning with 'dyrl_' each time it
		loads to make sure the tools function as expected. I also added
		other identifiers for each script's variables to be able to handle
		clearing and keeping them when necessary, but this is entirely
		dependent on your scripts and what you want them to do and how you
		want them to interact with other MACROSS functions.
		
	6. To jump back into MACROSS after your script is finished while
        retaining your script's variable values for further evals, add
        this line wherever appropriate:
		
			if( $CALLHOLD ){ Return }
			
                 ******THIS IS DEPRECATED AS OF v2.1******
		You only need use a 'Return' or 'Exit' now that MACROSS handles all
		default behaviors, including default var management
			
	7a. Include a function that displays any help or extended description
        of your scripts. Set the function to run FIRST if the variable
        $HELP is true, and automatically return to MACROSS after the
        function finishes. $HELP automatically gets reset by the console.
		
    7b. See the 'mcdefs.py' library file in the ncore\py_classes folder for
        working python scripts into MACROSS.
		
    8. MACROSS was designed on a closed network that enforced digitally signed
        code. This made it possible to semi-restrict it against non-security users
        being able to make use of the automation. See the \ncore\validation.ps1
        file for notes on how this is accomplished. The methods can still be
        used on networks without enforced digital signatures, but savvy users
        could just comment out the permission checks. This feature is default-
        disabled (the functions are commented out).
		
	9. These variables are used GLOBALLY across all the tools:
		$USR is the local user
		$PROTOCULTURE is the file/user/thing of interest that gets passed to
			other scripts for evaluations. Example, I had a script that
			scanned for newly-created user accounts. Each username was passed
			as $PROTOCULTURE to one script that collected logs related to
			the account, while another script used $PROTOCULTURE
			to simultaneously perform keyword searches on PDFs, txt, and
			other document files in that user's workstation and shares.
		$HOWMANY is typically the number of search results that gets tracked
			between scripts
		$CALLER is used when one script calls functions in another script;
			it passes the name of the current script to the one that is
			being called
		$RESULTFILE is any txt output generated by any of the scripts; pass it
            back and forth to perform manipulations and formatting as needed
		$GOBACK and $COMEBACK are used when scripts need to jump back and
			forth between each other
		$vf19_NOPE gets set to 'true' when the logged in user is not an admin (see
            the ncore/validation.ps1 file's "setUser" function to configure this)
		$vf19_DEFAULTPATH is the user's Desktop; you may need to tweak this in the
            validation.ps1 file
		$vf19_OPT1 gets set when a user appends an 's' to their module selection
			(e.g. 1s). This allows your script to switch modes or provide added
			functionality that normally wouldn't be used/needed. For example,
			my LEGIT tool is used to digitally sign scripts, but with 's' 
			selected, it instead lets you inspect the digital signatures of
			any signed scripts or binaries.
		$vf19_Z is the current user input.
		
    10.  If you want to set your default shared values in the utility.ps1 file (see
         the readme), the following indexes are already reserved:
            "tbl" = the location of the resources folder
            "nre" = the location of the master MACROSS repository (you need to set this)
        
#>

##################################
## Start fresh  &  >/dev/null all the expected errors
##################################
[console]::WindowWidth = 105  ## We want to avoid line-wrapping in script outputs
$Script:ErrorActionPreference = 'SilentlyContinue'
Remove-Variable vf19_* -Scope Global
cls
Write-Host -f GREEN '
    Loading defaults...
    '


## Use this integer in conjunction with $vf19_M (see validation.ps1) for performing math,
## permission checks, obfuscating values, writing hexadecimal strings, etc.
## If you plan to perform sensitive mathing, I recommend changing and storing this value somewhere
## other than this script (but this value needs to be set before the validation.ps1 script gets
## executed below, otherwise $vf19_M will break!!)
$Global:vf19_numchk = 864351   

##################################
## Import core functions
## Iterate through the ncore folder, quit if a file is missing
##################################

$dir = "$PSScriptRoot\ncore"
$v = 'validation.ps1'
$d = 'display.ps1'
$c = 'classes.ps1'
$e = 'utility.ps1'
$u = 'updates.ps1'
$s = 'splashes.ps1'
if(Test-Path -Path "$dir\$v"){
if(Test-Path -Path "$dir\$d"){
if(Test-Path -Path "$dir\$e"){
if(Test-Path -Path "$dir\$u"){
if(Test-Path -Path "$dir\$c"){
    # load functions: varCleanup, setUser, setUserCt, availableMods, getHelp1,
    #  getHelp2, getThis, SJW, adminChk, errMsg
    . "$PSScriptRoot\ncore\$v"
    Write-Host -f GREEN '  core security functions loaded...'

    # load functions: startUp, splashPage, chooseMod, scrollPage
    . "$PSScriptRoot\ncore\$d"
    Write-Host -f GREEN '  core display functions loaded...'

    #load functions: decodeSomething, runSomething, disVer, houseKeeping
    . "$PSScriptRoot\ncore\$e"
    Write-Host -f GREEN '  core utility functions loaded...'

    # load functions: look4New, toolCount, dlNew, verChk
    . "$PSScriptRoot\ncore\$u"
    Write-Host -f GREEN '  core update functions loaded...'
    # load custom classes
    . "$PSScriptRoot\ncore\$c"
    Write-Host -f GREEN '  custom classes loaded...'
}else{$f=$c}}else{$f=$u}}else{$f=$e}}else{$f=$d}}else{$f=$v}

if($f){
    Write-Host -f CYAN "
    ERROR -- Couldn't find required file $f"
    Exit
}


if(Test-Path -Path "$dir\$s"){
    # load functions: transitionSplash
    . "$PSScriptRoot\ncore\$s"
    Write-Host -f GREEN '  ascii screens loaded...'
    Start-Sleep -Seconds 1
}

Remove-Variable -Force dir,v,d,e,u,c,s



################################
## Input validation
################################
$vf19_CHOICE = [regex]"^(p|q|refresh|[0-9hrsw]{1,3})$"
$vf19_TAG = '9rkd4mv'               ## This is necessary for the startUp function to find its data

################################
## Set default vars for local MACROSS directories
################################
$Global:vf19_TOOLSROOT = $PSScriptRoot
$Global:vf19_TOOLSDIR = "$vf19_TOOLSROOT\nmods\"
$Global:vf19_REPOTOOLS = $vf19_TOOLSDIR  ## Delete this after you've set a master repo location
startUp                                  ## see the display.ps1 file
setUser                                  ## see the validation.ps1 file
#getThis $vf19_MPOD['nre']
#$Global:vf19_REPOTOOLS = $vf19_READ       ## This sets the main repo for MACROSS that users can pull updates from
getThis $vf19_MPOD['tbl']
$Global:vf19_TABLES = $vf19_READ           ## This sets the location of txt/xml files used for your custom scripts


$vf19_VERSION = Get-Content "$vf19_TOOLSROOT\MACROSS.ps1" | Select -Index 1
$vf19_VERSION = $vf19_VERSION -replace "^#_ver ",""  ## This gets the current version of MACROSS to write on-screen

## Need a temp-file dump so python can read MACROSS' powershell stuff
## All .eod temp files are deleted at MACROSS start (here) & at MACROSS quit (see varCleanup function in validation.ps1)
if( $MONTY ){
    $Global:vf19_GBIO = "$vf19_TOOLSROOT\ncore\py_classes\garbage_io"
    cleanGBIO
}



################################
## MAIN
################################

while( $Global:vf19_Z -ne 'q' ){
    
    varCleanup 0 ## Start with a clean slate! See the validation.ps1 file


    
    toolCount  ## Menu changes based on the tool count. See the updates.ps1 file

    <#  UNCOMMENT TO USE CENTRAL SCRIPT DISTRIBUTION
    #   MASTER REPO IS CURRENTLY SET TO SAME DIRECTORY AS YOUR LOCAL MACROSS ROOT FOLDER
    ## Consult the updates.ps1 file for setting your default configs
    $vf19_VERSIONING = $true   ## Enables the verChk function to auto-update scripts
    ##  Verify toolsets; see the updates.ps1 file
    if( $vf19_MISMATCH ){
        if( $vf19_FILECT -eq $vf19_REPOTOOLSCT ){
            Remove-Variable vf19_MISMATCH -Scope Global
        }
    }
    elseif( $vf19_FILECT -lt $vf19_REPOTOOLSCT ){
        look4New
    }
    elseif( $vf19_FILECT -gt $vf19_REPOTOOLSCT ){
        $Global:vf19_MISMATCH = $true
        look4New
    }#>
    
    
    if( $USR -ne $vf19_USRCHK ){  ## Fix var if it was modified by another script
        setUser
    }


    $CALLHOLD = 'MACROSS'   ## Holdover from original toolset, was originally meant to tell a script to return to the console without clearing vars
    $Global:vf19_PAGE = 'X'

    splashPage              ## load the MACROSS banner
    verChk 'MACROSS.ps1'    ## Check for updates before loading anything
    chooseMod               ## load the menu with available tools for user to select
}



Write-Host -f GREEN '
   Goodbye.
'
varCleanup 1  ## Can't be too careful


Exit
