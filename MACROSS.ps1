#_sdf1 Front end for MACROSS toolset
#_ver 4.5

<#
    Multi-API-Cross-Search (MACROSS) Console
    Automated powershell framework for blue teams
    With a little tweaking, you can link all your automation scripts
    together with MACROSS to give your team quick and easy access
    to any data that can help their investigations.
    
    https://github.com/hisurfadvisory/MACROSS
    
    Author: HiSurfAdvisory
    
    'Script' & 'Tool' are used interchangebly in my comments. Sorry.

    MACROSS community functions are in the core\utility.ps1 file for powershell,
    and the core\py_classes\mcdefs.py file for python. You can type "debug" in
    the main menu to get a listing and help files for all of these.

    Commenting in MACROSS powershell scripts is non-standard. I wrote my core
    tools specifically to be unusable if executed outside of MACROSS since
    they can involve accessing APIs or sensitive data.

	ADDING AUTOMATIONS TO MACROSS:
		1a. To include your automation ps or py scripts, just add this
		    as the FIRST line of your script, and put the script in
		    the modules\ folder: 
		
			    #_sdf1 <your description of the script>

            The "#_sdf1" is necessary to easily identify scripts created
            for MACROSS and display them in the main menu.

        1b. The second line is used for version control. It should begin
            "#_ver 0.1" or whatever number you want to use. MACROSS
            strips out the "#_ver " to get the version number from the
            local copy of the script, and compares it to the version
            number in the master copy that should be kept in your master
            repo (if you are using one; see the verChk function below). If
            the master copy is a higher number, MACROSS can grab the 
            updated version.

        1c. The third line must contain custom [macross] class attributes in order.
            An example from my ELINTS tool:

                     FIELD1,FIELD2,     FIELD3,           FIELD4,     FIELD5, FIELD6, FIELD7
             #_class 0,user,document string search,powershell,HiSurfAdvisory,1,onscreen

            This helps MACROSS determine when to provide tools to users. 
                FIELD1 (Access): if your SOC has different levels of users (analysts vs. investigators),
                    you can specify it here so that certain users can only use certain scripts.
                    The only valid values you can put here are 1, 2, or 3. Any other value
                    will tell MACROSS to make the script executable by anyone.
                FIELD2 (Privilege): does the script require admin or user priv?
                FIELD3 (Descriptor): Add a BRIEF description of what your script handles. Examples:
                    "Parse office documents", "Access SEIM logs", "Verify IP addresses".
                    This attribute can be used by MACROSS to load multiple tools to investigate
                    the same IOCs if you write your scripts to take advantage of this.
                FIELD4 (Language): Powershell vs. Python
                FIELD5 (Author): who wrote the script
                FIELD6 (How Many Params): tell MACROSS how many parameters can be passed to the script 
                    for evaluation. As of version 2, MACROSS only passes 1 param to any script. 
                    See notes in "validation.ps1" under the function "collab" if you need to 
                    modify this.
                FIELD7 (Response Type): what kind of data gets sent back -- json, onscreen, none, etc.

            Review the "classes.ps1" file for more info, and use MACROSS' debugger to see
            how the functions "availableTypes" and "collab" can connect your tools!

		2. Keep the script name under 11 characters to preserve the menu's
		    uniformity (not including the '.py' or '.ps1' file extensions, MACROSS
		    automatically ignores them).
		
		3. Where possible, prepend your variables with 'dyrl_', for example $dyrl_var1.
		    Because multiple scripts can be running at once and sharing data, MACROSS
            flushes all variables beginning with 'dyrl_' each time the main menu loads
            to make sure the tools are "zeroed" and always work as expected.
			
		4. Include a function that displays any help or extended description of your
            scripts for analysts to view. Set the function to run FIRST if the variable
            $HELP is true, and automatically exit after the function finishes. $HELP 
            automatically gets reset by MACROSS.

        5. Make sure your script recognizes these GLOBAL values:
			$USR is the local user
			$HOWMANY is typically the number of search results that gets tracked
                between scripts
			$CALLER is used when one script calls functions in another script;
                it passes the name of the current script to the one that is
                being called
			$RESULTFILE is any file output generated by any of the scripts.
                This value gets flushed everytime the main menu loads.
			$GOBACK and $COMEBACK are true/false and used when scripts need to jump 
                back and forth between each other (I used this in early versions of 
                MACROSS, you may not have a need for them).
            $vf19_OPT1 gets set when a user appends an 's' to their module selection
                (e.g. 1s). This allows your tool to switch modes or provide added
                functionality that normally wouldn't be used/needed. For example,
                my BASARA tool is used to digitally sign scripts, but with 's' set,
                it instead lets you inspect the digital signatures of any signed files.
            $vf19_MPOD contains any values your scripts regularly make use of, but that
                you don't want stored in plaintext. Retrieve your value using:

                    getThis $vf19_MPOD[$id]; $myVar = $vf19_READ

                ...where $id is the 3-char ID you set during the initial config setup.

            $PROTOCULTURE is the IOC (or any value) that is the current focus of your
                investigation.
        
#>




##################################
## Start fresh & >/dev/null any errors
##################################
$Script:ErrorActionPreference = 'SilentlyContinue'
function battroid(){
    param([string]$n,$v)
    Set-Variable -Name $n -Value $v -Scope Global -Option ReadOnly
}
[console]::WindowWidth = 105                        ## Modify the window size to your preference
Remove-Variable -Force vf19_* -Scope Global
cls
Write-Host -f GREEN '
       Setting console defaults:
'



##################################
## Import core functions
## Iterate through the core folder, quit if a file is missing or can't execute
##################################
$Global:mstart = 70
$mcores = @(
    'display',
    'configurator',
    'utility',
    'validation',
    'classes',
    'updates'
)
''
battroid -n vf19_TOOLSROOT -v "$PSScriptRoot"
foreach($c in $mcores){
    $script = ("$($PSScriptRoot)\core\" + $c + '.ps1')
    if(Test-Path -Path "$script"){
        try{
            . $script
        }
        catch{
            Write-Host -f CYAN "
    ERROR -- $script is present but cannot load!
    
    $($Error[0])"
            Exit
        }
        Write-Host -f GREEN "   core $c functions loaded..."
    }
    else{
        Write-Host -f CYAN "
    ERROR -- Couldn't find required file $($c + '.ps1')"
        Exit
    }
}
if(! (Test-Path "$vf19_TOOLSROOT\modules")){
    New-Item -Type directory -Path $vf19_TOOLSROOT -Name modules | Out-Null
}


## The ASCII art is not critical, keep loading even if it's missing
if(Test-Path -Path "$PSScriptRoot\core\splashes.ps1"){
    . "$PSScriptRoot\core\splashes.ps1"
}
Remove-Variable c,mcores,script


## Input validation
$vf19_CHOICE = [regex]"^([\drsw]{1,3})$"


## Set default local MACROSS tools folder
battroid -n vf19_TOOLSDIR -v "$vf19_TOOLSROOT\modules"


################### MODIFY THESE VALUES AS NEEDED ###############
## UPDATE THESE LINES IF YOU MOVE THE config.conf FILE ELSEWHERE!
## By default these files need to be placed in your MACROSS\core
## folder, but it is highly recommended that you keep your .conf 
## files in an access-controlled location.

battroid -n vf19_CONFIG -v  @(
    "$vf19_TOOLSROOT\core\config.conf",
    "$vf19_TOOLSROOT\core\launch.conf",
    "$vf19_TOOLSROOT\core\analyst.conf"
)


## UNCOMMENT AND UPDATE THIS LINE IF YOU HAVE LOCAL SYSINTERNALS!
## Your scripts can then quickly load them via $SI[$app]
#$Global:vf19_SYSINT = 'C:\Program Files\Microsoft Sysinternals Suite'

#################################################################



################################
## MAIN
################################

startUp -i
setUser -i
finalSet


while( $Global:vf19_Z -ne 'q' ){
    
    varCleanup
    setUser -c
    
    ## When you run the initial MACROSS configuration wizard and it asks for a repository
    ##  path, enter "none" if you are not using a central repo to store your master copies.
    ## If you are using a master repo and set the path in the MACROSS config, it will be
    ## referenced in these functions to auto-download new or updated scripts.

    toolCount  ## The main menu adds extra pages based on the tool count.
    if("$vf19_VERSIONING"){
        verChk 'MACROSS.ps1'       ## Check for updates before loading anything
        look4New                   ## Check for new tools
	toolCount
    }
    
    $Global:vf19_PAGE = 0   ## Start on the first page
    splashPage              ## Load the MACROSS banner
    chooseMod               ## Load the menu with available tools for user to select

}

varCleanup -c
