## Custom MACROSS classes


<#
   Classify MACROSS tools: this class helps you manage where scripts need to go and what
   they can query.
       -Users get access to their intended toolsets; admin tools won't be copied to user profiles,
        SOC tools won't get copied to forensic investigator profiles, etc.
       -MACROSS tools will be able to determine the capabilities and params of other scripts, i.e.
        "are you a python script" or "can you accept more than one value to search on?"
        When you write a custom script for use in MACROSS, the first three lines are reserved for
        MACROSS tags:

            #_superdimensionfortress <description of your script>
            #_ver <your script version number>
            #_class <your script's attributes> 
    
    The 'macross' class relies on the third line of each script in the nmods folder, it must begin with
    "#_class " followed by a comma separated string of attributes for your script. Example:

        #_class User,file hashes,Python3,HiSurfAdvisory,2

        IN ORDER, these attributes are applied for MACROSS to recognize:
            level of privilege required,
            the type of data it works with,
            the script's language,
            the script's author,
            the number of values it can handle being passed

        In addition, the script's name and version are automatically applied.

    You should not need to worry about generating objects in the macross class, MACROSS does it
    automatically every time it builds out its menu. You just need to make sure you're following
    the commenting convention described above in the first three lines of your scripts.
   
    

    !!! If you'd like to include more granular user descriptions, uncomment all the "$access" lines
    in this script, and uncomment/modify the "access" section in the update.ps1 script's "toolCount"
    function. Then start using the third field in your scripts' #_class lines to tag them like
    'junior analyst' or 'Tier2' or whatever you need. Example $access attribute:

        #_class User,file hashes,Allusers,Python3,HiSurfAdvisory,2
    
    'Allusers' might be used to let everyone load your script, while 'Tier2' could limit the script to
    just senior SOC analysts. Your analysts' permissions get set in the validation.ps1 script's "setUser"
    function, (which you'll need to tweak however you need) and would typically work by using either
    Active Directory GPO or a list you maintain elsewhere.


#>
class macross {
    

    [string]$name   ## Attribute 1: Name of the script
    [string]$priv   ## Attribute 2: Privilege level required, admin vs. user
    #[string]$access  ## Level of analyst access
    [string]$valtype  ## Attribute 3: What kind of values the script can accept (strings, filenames, etc).
    [string]$lang   ## Attribute 4: The script language
    [string]$author ## Attribute 5: Script author
    [int]$evalmax   ## Attribute 6: How many values a script can accept from other tools
    [string]$ver    ## Attribute 7: The script version

    
    <# 
       Examples for manually classifying MACROSS tools (you shouldn't ever need to do this):

            $gerwalk = [macross]::new('GERWALK,Admin,Tier3,endpoint artifacts,Powershell,HiSurfAdvisory,1,4.5')
                                   ^^ The GERWALK script now gets described with all of these attributes

       Example of the above macross class "$gerwalk" in use:

           $gerwalk.access   --> will return 'Tier3', meaning only forensics people can execute it
           $gerwalk.priv     --> will return 'admin', meaning it will only be visible to someone logged in
                                   with admin credentials (provided you are using a master repo and version checks)

       You can then craft your scripts to search through the $vf19_ATTS hashtable to find
       relevant tools to perform further evals, for example:

            Get-ChildItem -file $vf19_TOOLSDIR | %{
            foreach($tool in $vf19_ATTS.keys){
                if($vf19_ATTS[$tool].lang -eq 'Powershell' -and `
                    $vf19_ATTS[$tool].evals -Like '*ip address*'){
                    if((Read-Host 'Do you want to pass $PROTOCULTURE to $tool for processing') -eq 'yes'){
                        collab "$tool.ps1" 'Myscript'
                    }

                }
            }
            }
            .ver

            The above scriptblock would iterate through all the MACROSS tools listed in $vf19_ATTS, and if the
            tool is a powershell script that focus on processing IP addresses, the user is asked if they want to
            pass their current IOC ($PROTOCULTURE) to that script.

       Reference the "toolCount" and "look4New" functions in updates.ps1 if you want to see how MACROSS
       automatically classifies scripts for you.
    #>


    ## Constructor
    macross($scriptvalues){
        $this.setAttributes($scriptvalues)
    }

    ## The toolCount function in updates.ps1 will feed script values here;
    ## Once the macross object has been created, it will be stored in the global
    ## array $vf19_ATTS to be used by functions in updates.ps1 that handle
    ## script distribution
    [void]setAttributes($scriptvalues){
        $this.name = ($scriptvalues -Split ',')[0]
        $this.priv = ($scriptvalues -Split ',')[1]
        #$this.access = ($scriptvalues -Split ',')[2] ## You'll need to adjust the below indexes if you uncomment this!
        $this.valtype = ($scriptvalues -Split ',')[2]
        $this.lang = ($scriptvalues -Split ',')[3]
        $this.author = ($scriptvalues -Split ',')[4]
        $this.evalmax = ($scriptvalues -Split ',')[5]
        $this.ver = ($scriptvalues -Split ',')[6]
    }

    [void]setAttributes(
            [string]$name,
            [string]$priv,
            #[string]$access,
            [string]$valtype,
            [string]$lang,
            [string]$author,
            [int]$evalmax,
            [string]$ver){
        $this.name = $name
        $this.priv = $priv
        #$this.access = $access
        $this.valtype = $valtype
        $this.lang = $lang
        $this.author = $author
        $this.evalmax = $evalmax
        $this.ver = $ver
    }


    ## Method checks to automatically divvy out the tools to appropriate users
    [string]toolInfo(){
        $nm = ' MACROSS: ' + $this.name
        $ve = ' Version:                     ' + $this.ver
        $au = ' Author:                      ' + $this.author
        $el = ' Evaluates:                   ' + $this.valtype
        $pr = ' Privilege required:          ' + $this.priv #+ ', ' + $this.access
        $la = ' Language:                    ' + $this.lang
        $ev = ' Max # of simultaneous evals: ' + [string]$this.evalmax
        $info = "
 $nm
    $ve
    $au
    $el
    $pr
    $la
    $ev
        "
        Return $info
    }
    
}
