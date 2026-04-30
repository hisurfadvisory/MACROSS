#_sdf1 Front end for MACROSS toolset
#_ver 2.0
<#

    .AUTHOR
    HiSurfAdvisory

    .SYNOPSIS
    Written for cybersecurity-focused tasks, but enables cross-processing of data
    across multiple scripts no matter the job. Also provides several automation 
    utilities to speed up tasks.

    In MACROSS, your automation scripts are referred to as "diamonds" in these
    comments and functions.


    .DESCRIPTION
	MACROSS is a script manager that provides numerous utilities to allow automation
    scripts to communicate with each other and format different forms of data.

    Type "debug" in the main menu for a list of quality-of-life utilities; type
    "config" in the main menu to view/change configurations after initial setup.

    There are two example scripts included, BASARA and HIKARU. They each contain 
    comments explaining how MACROSS's functions can you automate your automations.


    HOW IT WORKS:
    =====================================================================
    Scripts (diamonds in MACROSS) should be coded to both assign your investigation/processing 
    values to a global variable, $PROTOCULTURE, and also to automatically act on that variable 
    if it already contains a value when the diamond executes.

    At first run, you are prompted to create a password, and enter values that will be used
    in MACROSS' default configuration, notably:
        -the location of a master MACROSS repository, if you want to use one to automatically
            push updates to users; the default behavior assumes MACROSS will only have a
            single user, so a repo is unnecessary.
        -the location of a content folder, if you want to use one external to MACROSS for
            storing non-executable files that may be needed for your diamonds (default is the local
            macross_core\corefuncs\resources folder, but you can specify a share or web server instead)
        -lists of usernames or group-policy names, used for basic access-control. MACROSS allows 
            using 3 levels of access: tier1, tier2, and tier3, and can specify usernames for both
            user-level and admin-level accounts. This can be used to determine which users will
            access and execute diamonds or functions you specify. The default behavior is to
            disable access control unless you enter one or more of these values. Note that this
            is a convenience feature, not a security one! MACROSS' role-based access control is only 
            a control if digitally-signed code is policy-enforced.
    
    The key utilities for processing data across multiple diamonds/scripts are "findDF"
    and "collab". See the macross_core\corefuncs\validation.ps1 file for details on these, or type
    "debug" in the main menu, and then "help <function name>".


    ##################################    PYTHON USAGE   ###########################################
    MACROSS looks for the static path to Python3 to determine whether or not to bother with python
    diamonds. You can modify this check for your system in the validation.ps1 file, line 884.


    ###############################  CENTRAL REPO/DISTRIBUTION  ####################################
    An earlier version of macross allowed setting web/file servers as a repository to host the master
    files, so that updated scripts could be pushed to users. This version (2.0) is missing that feature,
    it only looks in network or file shares. I'll update this when I can.


    ################################## MULTI-USER ACCESS ###########################################

    If you would like to have multiple people using MACROSS but sharing the same resource files and
    encrypted keys, you need to export your configuration and have your users place it in thier
    macross_core\corefuncs folder. Type "export" in the main menu to create a shared macross.config file.
    (You cannot just copy your file to other users, configs are locked to specific profiles.) Then,
    store your encrypted keys (see the gerwalk function; description below, or type "debug" in
    the main menu) and other resource files in the location you configured as your content folder 
    ($dyrl_CONTENT) during setup.


    ############# ADDING NEW SCRIPTS (or modifying existing scripts to work with MACROSS) ############

        -Your powershell & python diamonds go in the macross_core\diamonds folder
        -Files containing common classes, powershell modules, or extra functionality
            need to go in the macross_core\corefuncs\plugins folder. You can reference this
            folder with the global $dyrl_PLUGINS variable.

		1. For your ps & python scripts to work in MACROSS, reserve the first 3 lines;
		    for the FIRST line of your script, add
		
			    #_sdf1 <your description of the script>

            This description gets written to the main menu.

        2. The second line is used for version control. It should begin "#_ver 0.1" or whatever 
            number you want to use. MACROSS compares local version numbers to the master copy 
            that should be kept in the master repo (if you specified one during setup). If the 
            master copy is a higher number, MACROSS will grab the latest version and overwrite 
            the outdated local one.

		3. The third line must contain "#_class" follwed by seven comma-separated values that 
            are used to classify your script using the [macross] class (each field requires a 
            non-empty value):

                #_class $priv,$access,$valtype,$lang,$author,$evalmax,$rtype

                priv = the LOWEST level of privilege required for your script
                    to run (user vs. admin)
                access = tier1, tier2, tier3, or common; this is used for distributing
                    scripts or resources based on roles. This field is required even
                    if you aren't using the access control. NOTE: this is a convenience
                    feature, **NOT** a security control! Without strict code-signing
                    enforcement, anybody can bypass this.
                valtype = the task or type of data your script is meant to process; be
                    brief but descriptive with this field, as it is the main filter
                    used by MACROSS to automatically forward data (i.e. if you have
                    multiple scripts that do things with active directory, don't just
                    use "active directory" in this field or MACROSS might execute every
                    script that equals this valtype).
                lang = powershell vs. python
                author = who wrote the code
                evalmax = the maximum number of args accepted by your script; 
                    this does NOT count the global $PROTOCULTURE value that MACROSS scripts
                    should hunt for. If your script is coded to process $PROTOCULTURE
                    but does not accept params, your evalmax should be 0. The collab
                    function only forwards a single extra param, "-spiritia", so scripts
                    that require multiple parameters may need some reworking to combine or 
                    split values.
                rtype = the type of response your script returns or the filetype it
                    writes to (json, csv, doc, xlsx, etc.); 'none' if no response 
                    is generated.

            This is what enables quick jumping between all the scripts via the findDF
            function, which can filter based on these values. See the classes.ps1 file in the 
            corefuncs folder for more details on the [macross] class.
        
            !!! If the "#_sdf1", "#_ver" and "#_class" lines are not present, your script
            is ignored. If the "#_class" line does not contain exactly 7 fields in the order
            specified above, MACROSS' valkyrie function may not be able to execute it correctly.


        ############## FOR EXISTING AUTOMATIONS ###################
        One thing to note is that MACROSS' valkyrie function, which is what your script would use to collaborate
        with other MACROSS scripts, only accepts a single parameter to pass along to other scripts as -spiritia, 
        so if you have existing automations that take multiple parameters (what would be your script's .evalmax
        value in MACROSS), your code would need to be modified to accept a -spiritia parameter, and split it into 
        the values you use. Also remember that I coded MACROSS with the global $PROTOCULTURE value intended as 
        the primary item for everything to act on *without using any parameters*.

        Alternately, you can manually execute other diamonds without using collab.


        4. Keep the diamond's filename under 15 characters to preserve the menu's
		    uniformity (not including the file extension).
		
		5. Where it makes sense, prefix your powershell variables with "vf_", for example 
		    "$vf_var1". MACROSS flushes all scoped variables beginning with "vf_" each time the
		    menu loads to make sure the diamonds function as expected, and no leftover
            values are sitting in memory to muck up the next task.
			
		6. Include a function that displays any help or extended description of your
            diamonds. Set the function to run if the global variable $HELP is true, and 
            automatically return to MACROSS after the function finishes. The $HELP value
            is managed within MACROSS, no need to worry about clearing it. I wrote these 
            help files outside the normal conventions because the CYOC automations aren't 
            meant to be executable outside of MACROSS.

        7. The following variables are recognized globally within MACROSS for reference in your diamonds,
            and are automatically cleared out when necessary (items with an asterisk need to be set by 
            your diamonds, and get deleted the next time the main menu loads; items without an asterisk
            are handled internally):

                $USR is the local user
                $dyrl_HN0 is the local hostname
                $ROBOTECH is set 'True' when users do not have admin privilege. This allows
                    disabling functions that do not work without administrive privs.
                $HELP is set to 'true' if a user enters 'help' with their diamond selection
                    in the main menu. Your diamond should be coded to present a help
                    message if this value is set.
                $CALLER is used when one diamond calls functions in another diamond;
                    it passes the name of the current diamond to the one that is
                    being called. This way, a called automation can use the findDF
                    function to determine the characteristics of the caller diamond,
                    and adjust its behavior as necessary.
                $dyrl_CONF is a hashtable containing all of the configurations you
                    created during initial setup, or added later through the config
                    menu
                $dyrl_PT is used by MACROSS' "reString" function, which decodes encoded
                    strings. The plaintext is written to $dyrl_PT, and deleted either when
                    reString is called again, or when the main menu loads (whichever
                    comes first)
                $dyrl_PLUGINS is the macross_core\corefuncs\plugins folder where you can execute
                    any custom modules you created. (doesn't get cleared until exit)
                $dyrl_CONTENT is the location of the content folder you specify during
                    initial setup (doesn't get cleared until exit)
                $dyrl_RESOURCES is the local macross_core\corefuncs\resources folder where you store 
                    any extra files needed (images, etc.; doesn't get cleared until exit)
                $dyrl_OUTFILES is the local MACROSS\outputs folder you can use for writing 
                    common files into
                $dyrl_OPT1 gets set when a user appends an 's' to their module selection
                    (e.g. 3s). This allows your diamond to switch modes or provide added
                    functionality that normally wouldn't be used/needed.
                $dyrl_TMP is a folder path for writing temporary files to 
                    %localappdata%\Temp\MACROSS (MACROSS empties this folder at startup & exit)
                $dyrl_LATTS is a hashtable containing all of the diamonds and their [macross]
                    properties

                *$PROTOCULTURE is the data your diamonds should automatically act on if it
                    has a value assigned
                *$HOWMANY is what I used to track the number of search results or successful 
                    executions between diamonds working through a $PROTOCULTURE value
                *$RESULTFILE is used to reference any output file generated by any of the diamonds, 
                    so that they all know when it exists and can read or write to it as necessary.
                    Your code can either look at the $RESULTFILE file's extension or use the $dyrl_LATTS 
                    object to determine the format. If the writing diamond's ID is MYSCRIPT:

                        $dyrl_LATTS.MYSCRIPT.rtype  
                    
                    ...should tell you what kind of file MYSCRIPT has written to.
                    
        
        8. These are some of the utilities MACROSS provides to make life easier (type "debug" in the 
            main menu for a full list):

                -w: quickly format the way text is presented on screen
                -battroid: transform screen text into the blocky ascii-art used in MACROSS' 
                    main menu
                -screenResults: formats your outputs in a colorized table on screen, allows
                    highlighting items of interest. Handles large blocks of text, and you
                    can create up to three separate columns within the table.
                -screenResultsAlt: the same as the previous function, but meant for smaller
                    data sets. Writes outputs in a structured list format instead of a table.
                -sheetz: writes outputs to a formatted Excel document. Allows colorizing
                    cells and text, and writing to multiple sheets within a document
                -gerwalk: a keygen that can store data needed by diamonds in a
                    protected format
                -uniStrip: strips out all non-ascii characters from a block of text
                -reString: encode or decode strings using Base64 or hexadecimal
                -errLog: record custom information or error messages to a MACROSS logfile
                    (requires configuring a logging location at setup)
                -decodePdf: extracts plaintext from a PDF document
                -getFile: opens an explorer dialog for users to select a file or folder
                -getBlox: opens an input box for users to paste large blocks of text for
                    processing
                -yorn: opens a dialog with a selection of buttons for users to supply
                    responses like "yes" or "no". Allows custom selections & messages
                -houseKeeping: scans a specified directory for output files generated by your
                    diamond, offers to delete old/unnecessary outputs.
        
        9. MACROSS provides its own python library, macross, that replicates most of the
            powershell utilities and variables listed above for use in python diamonds. Its
            valkyrie() function handles passing and retrieving PROTOCULTURE data between
            python and powershell.
        
            In python, global variable names do not bother with a "dyrl_" prefix, since the
            entire python session is torn down as soon as the diamond finishes. So, 
            $dyrl_CONTENT is just CONTENT, hk_OUTFILES is just OUTFILES, etc. 
        
        10. To modify the macross.conf file, type "config" in the main menu.

        
#>

##################################
## Start fresh & >/dev/null any errors
##################################
[console]::WindowWidth = 120
$Script:ErrorActionPreference = 'SilentlyContinue'
Remove-Variable dyrl_* -Scope Global
cls

Write-Host -f GREEN "`n       Loading core functions:`n"

##################################
## Import core functions; quit if requirements not met
##################################
$ncores = @{
    'display.ps1'='display functions loaded...';
    'updates.ps1'='updater functions loaded...';
    'utility.ps1'='utilities loaded...';
    'validation.ps1'='validation functions loaded...';
    'configurations.ps1'='configurations set...';
    'classes.ps1'='custom classes loaded...'
}
Foreach( $cf in $ncores.keys ){
    if( Test-Path "$PSScriptRoot\corefuncs\$cf" ){
        try{
            . "$PSScriptRoot\corefuncs\$cf"
            Write-Host -f GREEN "       $($ncores[$cf])"
        }
        catch{
            Write-Host -f CYAN "
            ERROR! The core file $cf failed to load. Exiting.
        
            $($Error[0])"
            Remove-Variable dyrl_* -Scope Global
            Exit
        }
    }
    else{
        Write-Host -f CYAN "
        ERROR! Required file $cf not found! Exiting...
        
        "
        Remove-Variable dyrl_* -Scope Global
        Exit

    }
}
Remove-Variable -Force cf,ncores





Write-Host -f GREEN '
       Final checks complete! Generating menu...
       '
## Set session-permanent values
function lockIn(){
    param(
        [Parameter(Mandatory=$true)]
        [string]$n,
        [Parameter(Mandatory=$true)]
        $v
    )
    Set-Variable -Name $n -Value $v -Scope Global -Option ReadOnly
}


## Input validation:
$dyrl_CHOICE = [regex]"^(help[\s\w]*|[\drsw]{1,3})$"


################################
## Set main global defaults
################################
lockIn -n dyrl_MACROSS -v "$PSScriptRoot"                           ## The local root path $dyrl_MACROSS
lockIn -n dyrl_HN0 -v "$([string]$env:COMPUTERNAME)"                ## The local hostname $dyrl_HN0
lockIn -n dyrl_MODS -v "$dyrl_MACROSS\diamonds"                      ## Your primary automations go in $dyrl_MODS
lockin -n dyrl_PYLIB -v "$dyrl_MACROSS\corefuncs\pycross"           ## The macross python library
lockIn -n dyrl_PLUGINS -v "$dyrl_MACROSS\corefuncs\plugins"         ## Additional custom modules/functions go in $dyrl_PLUGINS
lockIn -n dyrl_RESOURCES -v "$dyrl_MACROSS\corefuncs\resources"     ## Any common csv/json/whatever files your diamonds might need go in $dyrl_RESOURCES
lockIn -n dyrl_OUTFILES -v  "$dyrl_MACROSS\outputs"                 ## Use $dyrl_OUTFILES for writing file outputs
lockIn -n dyrl_CONFIG -v "$dyrl_MACROSS\corefuncs\macross.conf"     ## The core configuration file
lockIn -n sn99 -v 'macross_pad99'
cls 

$rn = $(Get-Random -Minimum 0 -Maximum 11)
minmay $rn 3; rv rn


if(! (Test-Path -Path $dyrl_SKYFOLDER)){
    New-Item -ItemType directory -Name outputs -Path "$dyrl_MACROSS" | Out-Null
}


startUp -i
reString $dyrl_CONF.cre
if($dyrl_PT -in @('none',$dyrl_MACROSS)){ $ir = @($false,$false) }
else{ $ir = @($dyrl_PT,"$dyrl_PT\diamonds") }
lockIn -n dyrl_REPOCORE -v $ir[0]
lockIn -n dyrl_REPOTOOLS -v $ir[1]; rv ir
if($dyrl_REPOCORE){ lockIn -n dyrl_CHECKUPDATES -v $true }      ## If external repo is configured, make regular update checks
else{lockIn -n dyrl_CHECKUPDATES -v $false}
reString $dyrl_CONF.con
lockIn -n dyrl_CONTENT -v $dyrl_PT
reString $dyrl_CONF.log
lockIn -n dyrl_LOG -v $dyrl_PT
$dyrl_VERSION = (Get-Content "$dyrl_MACROSS\MACROSS.ps1" | 
    Select -Index 1) -replace "^#_ver "
setUser -i
cleanGBIO
setPY



## Verify any desired programs are installed: add program names and a descriptive
## variable name for it in the corefuncs\resources\installed_programs.json file
if(Test-Path "$dyrl_CONTENT\installed_programs.json"){
    $proglist = @{}
    (Get-Content -raw "$dyrl_CONTENT\installed_programs.json" | 
        ConvertFrom-Json).PSObject.Properties | %{
            $proglist[$_.Name] = $_.Value
        }
    $installed = mkList
    foreach($hk in @(
        'HKLM:\SOFTWARE\WOW6432Node\*',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')){
        foreach($name in (gci $hk).name){[void]$installed.add($name)}
    }
    foreach($i in $installed){
        foreach($prog in $proglist.keys){
            if($i | sls $prog){
                lockIn -n "$($proglist.$prog)" -v $true 
            }
        }
    }
    rv hk,name,installed
}



################################
## MAIN
################################


while( $true ){
    # Start with a clean slate!
    varCleanup
    setUser -c
    diamondCount
    if($dyrl_CHECKUPDATES){ 
        if( ($dyrl_FILECT -gt $dyrl_REPOCT) -and -not $dyrl_SILENCED ){
            $Global:dyrl_MISMATCH = $true
        }
    }
    
    $Global:dyrl_MPAGE = 0

    splashBanner                ## write the MACROSS banner

    if($dyrl_CHECKUPDATES -and $dyrl_REPOCORE -ne 'none'){

        verChk MACROSS          ## Check for updates before loading anything
        look4New
    }
    diamondSelect                ## load the menu with available tools for user to select

}





