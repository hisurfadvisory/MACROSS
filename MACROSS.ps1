#_SDF1 Front end for MACROSS toolset
#_ver 2.0
<#

    MACROSS
    Threat-Hunting & Investigation automations


    .AUTHOR
    HiSurfAdvisory
    github.com/hisurfadvisory/MACROSS

    .SYNOPSIS
    Written for cybersecurity-focused tasks, but enables cross-processing of data
    across multiple scripts no matter the job. Also provides several automation
    utilities to speed up collection/formatting.

    .DESCRIPTION
	MACROSS is a script manager that provides numerous utilities to allow automation
    scripts to communicate with each other and format different forms of data.

    Type "debug" in the main menu for a list of quality-of-life utilities; type
    "config" in the main menu to view/change configurations after initial setup
    (requires the password you created at setup).

    HOW IT WORKS:
    =====================================================================
    FIRST RUN:
    The first time you launch MACROSS, you need to create a password. This is only used
    for restricting the debugger (optional) and updating the configurations later if you
    need to. There are no requirements for the password, make it as crazy or simple as
    you want. MACROSS encrypts its configuration to your profile regardless of what the
    password is. Keep it simple & easy if MACROSS is for single-use; if you are sharing
    MACROSS resources with a team, your password should probably be more industry-standard
    because you'll need to export your configuration for them (covered later down below).

    Anytime you update the config, a backup is created in the same directory. To reload it,
    just rename it to "macross.conf".


    At first run, you are prompted to create a password, and enter values that will be used
    in MACROSS's default configuration, notably:
        -the location of a master MACROSS fileshare, if you want to use one to automatically
            push updates to users; the default behavior assumes MACROSS will only have a
            single user, so a central "repository" is unnecessary. I played around with
            being able to set a web server as the repo, but at this time it only accesses
            fileshares. Feel free to tweak this in the update.ps1 file.
        -the location of a content folder, if you want to use one external to MACROSS for
            storing non-executable files that may be needed for your scripts (default is the local
            macross_core\corefuncs\resources folder, but you can specify a share or file server instead)
        -lists of usernames or group-policy names, used for basic access-control. MACROSS allows
            using 3 levels of access: tier1, tier2, and tier3, and can specify usernames for both
            user-level and admin-level accounts. This can be used to determine which users will
            access and execute scripts or functions you specify. The default behavior is to
            disable access control unless you enter one or more of these values. Note that this
            is a convenience feature, not a security one! MACROSS's role-based access control is only
            a control if digitally-signed code is policy-enforced.

    The key utilities for processing data across multiple scripts are "availableTypes"
    and "collab". See the macross_core\corefuncs\validation.ps1 script for details on these, or type
    "debug" in the main menu, and then "help <function name>".

    #################################### BACKUP CONFIG #############################################
    MACROSS encrypts its configuration to your profile. Unfortunately, this means that any Windows
    update has the potential to break the decryption method, making the config file useless. Type
    "export" in the main menu to create a backup configuration that is not locked to your profile,
    and place it somewhere secure. Just put a copy in the macross_core\corefuncs folder if your original
    file gets borked by an update.


    ################################## MULTI-USER ACCESS ###########################################
    If you would like to have multiple people using MACROSS while sharing the same resource files and
    encrypted keys, you need to export your configuration and have your users place it in their
    macross_core\corefuncs folder. Type "export" in the main menu to create a shared macross.config file.
    (You cannot just copy your file to other users, configs are locked to specific profiles.) Then,
    store your encrypted keys (see the kawamori function; description below, or type "debug" in
    the main menu) and other resource files in the location you configured as your content folder
    ($dyrl_CONTENT) during setup. It should be a central directory everyone has access to, not your
    default local resources folder. The exported configuration files will be locked to each user the
    first time they launch MACROSS, and they will then be able to decrypt any shared kawamori keys.


    ############# ADDING NEW SCRIPTS (or modifying existing scripts to work with MACROSS) ############
    USAGE:
    Your custom scripts should be coded to both 1) assign your investigation/processing values
    to a global variable, $PROTOCULTURE, and 2) to automatically act on that variable if it
    already contains a value when the script executes.

        -Your powershell & python scripts (diamonds) go in the macross_core\diamonds folder
        -Files containing common classes, powershell modules, or extra functionality
            need to go in the corefuncs\plugins folder. You can reference this
            folder with the global $dyrl_PLUGINS variable.

		1. For your ps & python diamonds to work in MACROSS, reserve the first 3 lines;
		    for the FIRST line of your script, add

			    #_SDF1 <your description of the script>

            This diamond description gets written to the main menu.

        2. The second line is used for version control. It should begin "#_ver 0.1" or whatever
            number you want to use. MACROSS compares local version numbers to the master copy
            that should be kept in the master repo (if you specified one during setup). If the
            master copy is a higher number, MACROSS will grab the latest version and overwrite
            the outdated local one.

		3. The third line must contain "#_class" followed by seven comma-separated values that
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
                    use "active directory" in this field or MACROSS may execute every
                    script that equals this valtype when you are using the availableTypes
                    and collab functions).
                lang = powershell vs. python
                author = who wrote the code
                evalmax = the maximum number of args accepted by your script;
                    this does NOT count the global $PROTOCULTURE value that MACROSS scripts
                    should hunt for. If your script is coded to process $PROTOCULTURE
                    but does not accept params, your evalmax should be 0. The collab
                    function only forwards a single extra param, "-deculture", so scripts
                    that require multiple parameters may need some reworking to combine or
                    split values. Otherwise, you'll need to manually call other diamonds
                    without using collab, e.g.  '& "$dyrl_DIAMONDS\myscript.ps1" '
                rtype = the type of response your diamond returns or the filetype it
                    writes to (json, csv, doc, xlsx, etc.); 'none' if no response
                    is generated.

            This is what enables quick jumping between all the diamonds via the availableTypes
            function, which can filter based on these values. See the classes.ps1 file in the
            corefuncs folder for more details on the [macross] class.

            !!! If the "#_SDF1", "#_ver" and "#_class" lines are not present, your script
            is ignored. If the "#_class" line does not contain exactly 7 fields in the order
            specified above, MACROSS's collab function may not be able to execute it correctly.


        ############## FOR EXISTING AUTOMATIONS ###################
        One thing to note is that MACROSS's collab function, which is what your diamond would use to collaborate
        with other MACROSS scripts, only accepts a single parameter to pass along to other diamonds as -deculture,
        so if you have existing automations that take multiple parameters (what would be your diamond's .evalmax
        value in MACROSS), your code would need to be modified to accept a -deculture parameter, and split it into
        the values you use. Also remember that I coded MACROSS with the global $PROTOCULTURE value intended as
        the primary item for everything to act on *without using any parameters*. Alternately, you can just
        jump from script to script manually without using the collab function at all.


        4. Keep the diamond's filename under 15 characters to preserve the menu's
		    uniformity (not including the file extension).

		5. Where it makes sense, prefix your powershell variables with "vf_", for example
		    "$vf_var1". MACROSS flushes all scoped variables beginning with "vf_" each time the
		    menu loads to make sure the tools function as expected, and no leftover
            values are sitting in memory to muck up the next task.

		6. Include a function that displays any help or extended description of your
            diamonds. Set the function to run if the global variable $HELP is true, and
            automatically return to MACROSS after the function finishes. The $HELP value
            is managed within MACROSS, no need to worry about clearing it. I wrote these
            help files outside the normal conventions because the my automations weren't
            meant to be executable outside of MACROSS.

        7. The following variables are recognized globally within MACROSS for reference in your scripts,
            and are automatically cleared out when necessary (items with an asterisk need to be set by
            your scripts, and get deleted the next time the main menu loads; items without an asterisk
            are managed internally):

                $USR is the local user
                $dyrl_HN0 is the local hostname
                $dyrl_DIAMONDS is the filepath to your automation scripts
                $dyrl_MACROSS is the root folder path for MACROSS
                $ROBOTECH is set 'True' when users do not have admin privilege. This allows
                    disabling functions that do not work without administrive privs.
                $HELP is set to 'true' if a user enters 'help' with their script selection
                    in the main menu. Your script should be coded to present a help
                    message if this value is set.
                $CALLER is used when one script calls functions in another script;
                    it passes the name of the current script to the one that is
                    being called. This way, a called script can use the availableTypes
                    function to determine the characteristics of the caller script,
                    and adjust its behavior as necessary.
                $dyrl_PT is used by MACROSS's "gerwalk" function, which decodes encoded
                    strings. The plaintext is written to $dyrl_PT; it gets overwritten when
                    gerwalk is called again, or deleted when the main menu loads (whichever
                    comes first)
                $dyrl_PLUGINS is the $MACROSS_ROOT\corefuncs\plugins folder where you can execute
                    any custom modules you created. (doesn't get cleared until exit)
                $dyrl_CONTENT is the location of the content folder you specify during
                    initial setup (doesn't get cleared until exit)
                $dyrl_RESOURCES is the local $MACROSS_ROOT\corefuncs\resources folder where you store
                    any extra files needed (images, etc.; doesn't get cleared until exit)
                $dyrl_OUTFILES is the local MACROSS\outputs folder you can use for writing
                    common files into (doesn't get cleared until exit)
                $dyrl_OPT1 gets set when a user appends an 's' to their module selection
                    (e.g. 1s). This allows your script to switch modes or provide added
                    functionality that normally wouldn't be used/needed. For example,
                    my LEGIT tool is used to digitally sign scripts, but if $dyrl_OPT1 is
                    set to $true, it instead lets you inspect the digital signatures
                    of any signed files.
                $dyrl_TMP is set by MACROSS; it is a folder path for writing temporary files to
                    %localappdata%\Temp\MACROSS (this folder gets cleaned out at exit)
                $dyrl_LATTS is a hashtable containing all of the diamonds and their [macross]
                    properties
                $dyrl_ASCII is a regex pattern that lets you strip non-ascii chars from a string
                $dyrl_PYNET is the path to MACROSS's python executable. This is given preference
                    over any python versions installed on the system.

                *$PROTOCULTURE is the data your diamond scripts should automatically act on if
                    it has a value assigned (when applicable)
                *$HOWMANY is what I used to track the number of search results or successful
                    executions between scripts working through a $PROTOCULTURE value
                *$RESULTFILE is for any output file generated by any of the diamonds, so that
                    they all know when it exists and can read or write to it as necessary.
                    You can either look at the $RESULTFILE file's extension or use the $dyrl_LATTS
                    object to determine the format. If the diamond ID is MYSCRIPT:

                        $dyrl_LATTS.MYSCRIPT.rtype = should tell you what kind of file
                            MYSCRIPT writes to, if any


        8. These are some of the utilities MACROSS provides to make life easier (type "debug" in the
            main menu for a full list):

                -w: quickly format the way text is presented on screen
                -skyWriter: format a word into the blocky ascii-art used in MACROSS's main
                    menu
                -screenResults: formats your outputs in a colorized table on screen, allows
                    highlighting items of interest. Handles large blocks of text, and you
                    can create up to three separate columns within the table.
                -sheetz: writes outputs to a formatted Excel document. Allows colorizing
                    cells and text, and writing to multiple sheets within a document
                -kawamori: a keygen that stores data needed by scripts in a protected format
                    as ".mori" keys in the $dyrl_RESOURCES folder. These keys can only be
                    decrypted by the configuration that encrypted them. If your macross.conf file
                    gets deleted and you create a new one, you will need to generate new keys
                    to replace the old ones!
                -uniStrip: strips out all non-ascii characters from a block of text
                -gerwalk: encode or decode strings using Base64 or hexadecimal
                -errLog: record custom information or error messages to a MACROSS logfile
                    (requires configuring a logging location at setup)
                -decodePdf: extracts plaintext from a PDF document
                -getFile: opens an explorer dialog for users to select a file or folder
                -getBlox: opens an input box for users to paste large blocks of text for
                    processing
                -yorn: opens a dialog with a selection of buttons for users to supply
                    simple responses like "Yes" or "No". Allows custom selections & messages
                -houseKeeping: scans a specified directory for output files generated by your
                    diamond, offers to delete old/unnecessary outputs.

        9. MACROSS provides its own python library, macross, that replicates most of the
            powershell utilities and variables listed above for use in python scripts. Its
            collab() function handles passing and retrieving PROTOCULTURE data between
            python and powershell.

            In python, global variable names do not bother with a "dyrl_" prefix, since the
            entire python session is torn down as soon as the script finishes, whereas powershell
            performs a blanket "rv dyrl_*" at exit. So, in python, $dyrl_CONTENT is just CONTENT,
            $ROBOTECH is just ROBOTECH, etc.

        10. To modify the macross.conf file, type "config" in the main menu. This requires your
            MACROSS admin password. Your existing config gets backed up, so if you ever need to
            reload it, just rename it back to "macross.conf".

        11. The local resources folder contains a json file called "installed_programs". By default
            it only looks for Excel & python, but you can add whatever progams & var names you need to.
            MACROSS searches the local system to see if the programs named in this file are installed,
            and sets a global variable to $true so that if your diamond requires that program, it can do
            a quick check instead of throwing errors when the program isn't found. (You'll need to
            move this file if you specified an alternate $dyrl_CONTENT location during setup.)


#>


## If using a portable python instance, send the path as -portable
param(
    [Parameter(Mandatory=$false)]
    [string]$portable
)


##################################
## Start fresh & >/dev/null any errors
##################################
[console]::WindowWidth = 120
$Script:ErrorActionPreference = 'SilentlyContinue'
$rn = $(Get-Random -Minimum 0 -Maximum 11)
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
foreach( $cf in $ncores.keys ){
    if( Test-Path "$PSScriptRoot\corefuncs\$cf" ){
        Unblock-File "$PSScriptRoot\corefuncs\$cf"
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



################################
## Set primary global defaults
################################
$Global:dyrl_CHOICE = [regex]"^(help[\s\w]*|[\drsw]{1,3})$"
lockIn -n dyrl_MACROSS -v "$PSScriptRoot"                       ## The local root path $dyrl_MACROSS
$dyrl_VERSION = (Get-Content "$dyrl_MACROSS\MACROSS.ps1" | Select -Index 1) -replace "^#_ver "
$dyrl_SCF = "macross$($dyrl_VERSION[0])`.conf"
lockIn -n dyrl_HN0 -v "$([string]$env:COMPUTERNAME)"            ## The local hostname $dyrl_HN0
lockIn -n dyrl_DIAMONDS -v "$dyrl_MACROSS\diamonds"               ## Your primary automations go in $dyrl_DIAMONDS
lockIn -n dyrl_PLUGINS -v "$dyrl_MACROSS\corefuncs\plugins"       ## Additional custom modules/functions go in $dyrl_PLUGINS
lockIn -n dyrl_RESOURCES -v "$dyrl_MACROSS\corefuncs\resources"   ## Any common csv/json/whatever files your scripts might need go in $dyrl_RESOURCES
gerwalk $(Get-Content "$dyrl_RESOURCES\template.conf") -h
lockIn -n dyrl_CONFIG -v @("$dyrl_MACROSS\corefuncs\$dyrl_SCF",
    "$dyrl_PT")                                             ## If you don't already have a configuration, the setup wizard will auto-launch
if($outfolder){ $o = $outfolder }
else{ $o = "$dyrl_MACROSS" }
lockIn -n dyrl_OUTFILES -v "$dyrl_MACROSS\outputs"          ## Use $dyrl_OUTFILES for default outputs
cls
minmay $rn; rv rn
w '
       Final checks complete! Generating menu...
       ' g; slp 2
$mac_host_ip = setLocal -m

## $dyrl_PYNET is MACROSS's python executable (ignores host python, if any is installed).
lockIn -n dyrl_PYNET -v $portable

if(! (Test-Path -Path $dyrl_OUTFILES)){
    New-Item -ItemType directory -Name outputs -Path "$dyrl_MACROSS" | Out-Null
}



startUp -i
gerwalk $dyrl_CONF.hre
$hre = $dyrl_PT
gerwalk $dyrl_CONF.cre
if($dyrl_PT -in @('none',$dyrl_MACROSS)){ $ir = @($false,$false) }
else{
    if($hre -ne 'none'){ $ir = @($dyrl_PT,$hre) }
    else{ $ir = @($dyrl_PT,"$dyrl_PT\diamonds")  }
}
lockIn -n dyrl_REPOCORE -v $ir[0]
lockIn -n dyrl_REPOTOOLS -v $ir[1]
Remove-Variable o,outfolder,portable,hre ir
if($dyrl_REPOCORE){ lockIn -n dyrl_CHECKUPDATES -v $true }          ## If external repo is configured, make regular update checks
else{lockIn -n dyrl_CHECKUPDATES -v $false}
gerwalk $dyrl_CONF.con
lockIn -n dyrl_CONTENT -v $dyrl_PT
gerwalk $dyrl_CONF.log
lockIn -n dyrl_LOG -v $dyrl_PT
setUser -i
cleanGBIO


## Check if necessary programs are available; add as many as you need
if(Test-Path "$dyrl_CONTENT\installed_programs.json"){
    $proglist = (Get-Content -raw "$dyrl_CONTENT\installed_programs.json" | ConvertFrom-Json)
    if(! $proglist.keys){
        $pr = @{}
        $proglist.PSObject.Properties | %{$pr[$_.Name] = $_.Value}
        $proglist = $pr
    }
    $INST = (Get-ChildItem 'HKLM:Software').Name + `
        $((Get-ChildItem 'HKLM:Software\Microsoft\Office').Name) + `
        $((Get-ChildItem 'HKCU:Software').Name)
    foreach($i in $INST){
        ## Add programs and variable names to the "installed_programs.json" file
        ## in the resources folder (or wherever you set the value for $dyrl_CONTENT)
        ## to verify programs your diamond scripts may need.
        foreach($prog in $proglist.keys){
            if($i | Select-String $prog){
                Set-Variable -name "$($proglist.$prog)" -value $true -scope Global
            }
        }
    }
    Remove-Variable proglist,prog,pr,i,INST
}




################################
## MAIN
################################


while( $true ){
    varCleanup
    setUser -c
    toolCount
    if($dyrl_CHECKUPDATES){
        if( ($dyrl_FILECT -gt $dyrl_REPOCT) -and -not $dyrl_SILENCED ){
            $Global:dyrl_MISMATCH = $true
        }
    }

    $Global:dyrl_MPAGE = 0

    splashBanner
    if($dyrl_CHECKUPDATES -and $dyrl_REPOCORE -ne 'none'){
        verChk MACROSS       ## Check for updates before loading anything
        look4New
    }
    diamondSelect            ## load the menu with available tools for user to select

}




