#_sdf1 Front end for MACROSS toolset
#_ver 4.5.1

<#
    v4.5.1
    -Bug fixes with log handling

    
    Multi-API-Cross-Search (MACROSS) Console
    Automated powershell framework for blue teams
    With a little tweaking, you can link all your automation scripts
    together with MACROSS to give your team quick and easy access
    to any data that can help their investigations.
    
    https://github.com/hisurfadvisory/MACROSS
    
    Author: HiSurfAdvisory
    
    'Script' & 'Tool' are used interchangebly in my comments. Sorry.

    MACROSS functions are in the core\utility.ps1 file for powershell, and
    the core\macross_py\valkyrie.py file for python. You can type "debug" in
    the main menu to get a listing and help files for all of these.

    Commenting in MACROSS powershell scripts is non-standard. I wrote my core
    tools specifically to be unusable if executed outside of MACROSS, since
    they can involve accessing APIs or sensitive data.

	ADDING AUTOMATIONS TO MACROSS:
		1a. To include your automation ps1 or py scripts, you need to add three
            specific lines to your script. First:
		
			    #_sdf1 <your description of the script>

            The "#_sdf1" is necessary to easily identify scripts created
            for MACROSS and display them in the main menu.

        1b. The second line is used for version control. It should begin
            "#_ver 0.1" or whatever number you want to use. MACROSS
            strips out the "#_ver " to get the version number from the
            local copy of the script, and compares it to the version
            number in the master copy that should be kept in your master
            repo (if you are using one). If the master copy is a higher 
            number, MACROSS can grab the updated version.

        1c. The third line must contain "_class " followed by custom [macross] class 
            attributes, in a specific order. An example from my ELINTS tool:

                     FIELD1,FIELD2,     FIELD3,      FIELD4,     FIELD5, FIELD6, FIELD7
             #_class 0,user,document string search,powershell,HiSurfAdvisory,1,onscreen

            This helps MACROSS determine when to provide tools to users at any point
            during investigations. 
                FIELD1 (Access): Tier level 0 - 3
                FIELD2 (Privilege): the lowest privilege level required (admin or user)
                FIELD3 (Descriptor): Add a BRIEF description of what your script handles.
                 Examples:
                    "parse office documents", "firewall api", "verify ip addresses".
                    This attribute can be used by MACROSS to load multiple tools to 
                    investigate the same IOCs if you write your scripts to take advantage 
                    of this. It is important to be consistent with these descriptors!
                FIELD4 (Language): powershell vs. python
                FIELD5 (Author): who wrote the script
                FIELD6 (How Many Params): tell MACROSS how many parameters can be passed 
                    to the script for evaluation. If your script is written to automatically 
                    act on the global variable $PROTOCULTURE, this value should be 1. If your 
                    script can *also* accept an additional param or arg, set it to 2. MACROSS 
                    can only pass 1 parameter or argument to any script. See notes in 
                    "validation.ps1" under the function "collab" if you want to modify this
                    behavior, but I limited it to 1 to keep things simple.
                FIELD7 (Response Type): what kind of data gets sent back -- json, onscreen, 
                    none, etc.

            Review the "classes.ps1" file for more info, and use MACROSS' debugger to see
            how the functions "availableTypes" and "collab" can connect your tools!

		2. Keep the script name under 11 characters to preserve the menu's
		    uniformity (not including the '.py' or '.ps1' file extensions, MACROSS
		    automatically ignores them). Names exceeding 11 chars get truncated.
		
		3. Where possible, prepend your variables with 'dyrl_', for example $dyrl_var1.
		    Because multiple scripts can be running at once and sharing data, MACROSS
            flushes all variables beginning with 'dyrl_' in all scopes each time the 
            main menu loads to make sure the tools are "zeroed" and always work as expected.
			
		4. Include a function that displays any help or extended description of your
            scripts for analysts to view. Set the function to run FIRST if the global
            variable $HELP is true, and automatically exit after the function finishes. 
            $HELP automatically gets reset by MACROSS. Users set $HELP by typing 'help' 
            in the main menu along with the tool # they want to view help for.

        5. MACROSS handles auto-clearing these custom GLOBAL values that can be used 
            in your scripts:

			$USR is the local user (set by MACROSS)
			$HOWMANY is what I used to track things like the total number of search
                results between scripts (set by your scripts)
			$CALLER is used when one script calls functions in another script;
                it passes the name of the current script to the one that is
                being called (set by MACROSS)
			$RESULTFILE is the filepath to any file output generated by any of the 
                scripts. Multiple scripts can then reference this filepath to read
                or change its contents. This value gets flushed everytime the main
                menu loads. (set by your scripts)
			$GOBACK and $COMEBACK are true/false and used when scripts need to jump 
                back and forth between each other without using the collab function
                (I used this in early versions of MACROSS, you may not have a need 
                for them. Set by your scripts)
            $vf19_OPT1 gets set when a user appends an 's' to their tool selection
                (e.g. 1s). This allows your tool to switch modes or provide added
                functionality that normally wouldn't be used/needed. For example,
                my BASARA tool is used to digitally sign scripts, but when selected
                with 's', it instead lets you inspect the digital signatures of any 
                signed files. (set by MACROSS)
            $vf19_RSR is the location of the MACROSS\resources folder, which you
                can change in the configuration wizard. This location is where you
                can store any files regularly used by your scripts.
            $vf19_MPOD contains the encrypted values that you created during MACROSS' 
                setup. Retrieve your plaintext value using:

                    getThis $vf19_MPOD[$id]; $myVar = $vf19_READ

                ...where $id is the 3-char ID you set during the initial config setup.
                (set by MACROSS)

            $PROTOCULTURE is the IOC (or any value) that is the current focus of your
                investigation. Write your scripts to automatically act on $PROTOCULTURE
                if it has a value. (set by your script)

        6. Type "debug" in the main menu to view MACROSS utilities that can be added
            to your scripts. The "collab" and "availableTypes" functions in particular
            are the primary advantages for MACROSS use.

        7. Place your script in the "MACROSS\modules" folder. It will automatically
            be added to the menu if you've set the #_sdf, #_ver and #_class headers.
        
        8. MACROSS provides most of its powershell utilities in a python module called
            "valkyrie". This module also converts the above global values for you; simply
            import valkyrie into your python scripts to make use of them. You can review
            the valkyrie module in the core\macross_py folder, or just use valkyrie.help()
            after importing it.
        
#>




##################################
## Start fresh & >/dev/null any errors
##################################
$Script:ErrorActionPreference = 'SilentlyContinue'
function battroid(){
    param([string]$n,$v)
    Set-Variable -Name $n -Value $v -Scope Global -Option ReadOnly
}
[console]::WindowWidth = 120                        ## Modify the window size to your preference
Remove-Variable -Force vf19_* -Scope Global
cls
Write-Host -f GREEN '
       Setting console defaults:
'



##################################
## Import core functions
## Iterate through the core folder, quit if a file is missing or can't execute
##################################
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
battroid -n vf19_TOOLSDIR -v "$vf19_TOOLSROOT\modules"


## The ASCII art is not critical, keep loading even if it's missing
if(Test-Path -Path "$PSScriptRoot\core\splashes.ps1"){
    . "$PSScriptRoot\core\splashes.ps1"
}
Remove-Variable c,mcores,script


## MOD SECTION! ##
################### MODIFY THESE VALUES AS NEEDED ###############
## UPDATE THESE LINES IF YOU MOVE THE .conf FILES ELSEWHERE!
## By default these files need to be placed in your MACROSS\core
## folder, but it is highly recommended that you keep your .conf 
## files in a separate access-controlled location if you will have
## multiple users.
## If MACROSS isn't loading properly after you change these paths,
## check the MOD SECTION in configurator.ps1

battroid -n vf19_CONFIG -v  @(
    "$vf19_TOOLSROOT\core\config.conf",
    "$vf19_TOOLSROOT\core\launch.conf",
    "$vf19_TOOLSROOT\core\analyst.conf"
)

## Input validation for menu choices
$vf19_CHOICE = [regex]"^([\drsw]{1,3})$"

## MOD SECTION! ##
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

splashPage
while( $Global:vf19_Z -ne 'q' ){
    
    varCleanup
    setUser -c
    
    ## When you run the initial MACROSS configuration wizard and it asks for a repository
    ## path, enter "n" if you are not using a central repo to store your master copies.
    ## If you *are* using a master repo and set the path in the MACROSS config, it will be
    ## referenced in these functions to auto-download new or updated scripts.

    toolCount
    if("$vf19_VERSIONING"){
        verChk 'MACROSS.ps1'
        look4New
        toolCount
    }
    
    $Global:vf19_PAGE = 0
    splashPage
    chooseMod
    varCleanup -t

}

varCleanup -c
