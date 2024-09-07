## Custom MACROSS classes go here



class macross {
<#
.description
Classify MACROSS tools: this class helps you manage where scripts need to go and what
they can query.
    -Users get access to their intended toolsets; admin tools won't be copied to user profiles,
        SOC tools won't get copied to forensic investigator profiles, etc.
    -MACROSS tools will be able to determine the capabilities and params of other scripts, i.e.
        "are you a python script" or "can you accept more than one value to search on?"
        When you write a custom script for use in MACROSS, the first three lines are reserved for
        MACROSS tags:

            #_sdf1 <description of your script>
            #_ver <your script version number>
            #_class <your script's attributes> 
        
The 'macross' class relies on the third line of each script in the nmods folder, it must begin 
with "#_class " followed by a comma separated string of attributes for your script. Example:

    #_class tier1,user,file hashes,python3,HiSurfAdvisory,2

IN ORDER, these attributes are applied for MACROSS to recognize:
    the level of access,*
    level of privilege required,
    the type of data it works with,
    the script's language,
    the script's author,
    the number of values it can handle being passed
    the type of response it gives back**

All 7 of these fields are REQUIRED. In addition, the script's name and version are 
automatically applied when MACROSS starts up.

* MACROSS only recognizes three ".access" types: tiers 1, 2, & 3, with "tier 1" 
being reserved for the most junior analysts, "tier3" the most senior. Putting 
anything else in this field tells MACROSS that everyone can execute the script. 
The tier1 - tier3 attributes are determined by the user's GPO membership; if you 
want to use a different method than GPO, you'll need to modify the "setUser" 
function in validation.ps1.

** Suggested .rtype values are "onscreen" for results that only show on screen,
"file" if your script outputs results to any kind of file, where you store the
filepath as $global:RESULTFILE, and "none" if your script just performs a task
without responding. Other than those, specify json, txt, or whatever else your 
script creates.

            
Example .access attribute that ignores tier restrictions:

    #_class allusers,user,file hashes,python3,HiSurfAdvisory,2,
        
You need to specify the GPO names by running "config" from the main menu, and specifying
the name of the groups your analysts belong to ("SOC", "Incident-Responder", etc.).
            
You should not need to worry about generating objects in the macross class, MACROSS does it
automatically every time it builds out its menu. You just need to make sure you're following
the commenting convention described above in the first three lines of your scripts.


.example
Examples for manually classifying MACROSS tools (you shouldn't ever need to do manually this):

$gerwalk = [macross]::new('GERWALK,3,Admin,endpoint artifacts,powershell,HiSurfAdvisory,1,json,4.5,GERWALK.ps1')
^^ The GERWALK script now gets described with all of these attributes

Example of the above macross class "$gerwalk" in use:

    $gerwalk.access   --> will return '3', meaning only your Tier 3 people can execute it
    $gerwalk.priv     --> will return 'admin', meaning it will only be visible to someone logged in
                            with admin privilege (provided you are using a master repo and version 
                            checks)

You can then craft your scripts to search through the $vf19_LATTS hashtable to find relevant tools 
to perform further evals, using MACROSS' availableTypes function. For example:

    $PROTOCULTURE = '9.9.9.9'
    $tools = availableTypes 'ip, firewall api' 
            
The above scriptblock would iterate through all the MACROSS tools listed in $vf19_LATTS, and 
returns a list of tools matching the .valtype 'ip' or 'firewall api'. That list can then be 
used to auto-execute MACROSS' collab function to further process the $PROTOCULTURE value.

Reference the "toolCount" and "look4New" functions in updates.ps1 if you want to see how MACROSS
automatically classifies scripts for you.
#>

    [string]$name     ## Attribute 1: Name of the script
    [string]$access   ## Attribute 2: Level of analyst access (Tier 1, Tier 2, or Tier 3)
    [string]$priv     ## Attribute 3: Privilege level required, admin vs. user
    [string]$valtype  ## Attribute 4: the type of data processed, or type of task performed
    [string]$lang     ## Attribute 5: The script language
    [string]$author   ## Attribute 6: Script author
    [int]$evalmax     ## Attribute 7: How many values a script can accept from other tools
    [string]$rtype    ## Attribute 8:The type response your script returns (onscreen, json, etc.)
    [string]$ver      ## Attribute 9: The script version
    [string]$fname    ## Attribute 10:The full filename for use with MACROSS' collab function


    macross($scriptvalues){
        $this.setAttributes($scriptvalues)
    }

    ## The toolCount function in updates.ps1 will feed script values here;
    ## Once the macross object has been created, it will be stored in the global
    ## array $vf19_LATTS to be used by functions in updates.ps1 that handle
    ## script distribution
    [void]setAttributes($scriptvalues){
        $this.name = ($scriptvalues -Split ',')[0]
        $this.access = ($scriptvalues -Split ',')[1]
        $this.priv = ($scriptvalues -Split ',')[2]
        $this.valtype = ($scriptvalues -Split ',')[3]
        $this.lang = ($scriptvalues -Split ',')[4]
        $this.author = ($scriptvalues -Split ',')[5]
        $this.evalmax = ($scriptvalues -Split ',')[6]
        $this.rtype = ($scriptvalues -Split ',')[7]
        $this.ver = ($scriptvalues -Split ',')[8]
        $this.fname = ($scriptvalues -Split ',')[9]
    }

    [void]setAttributes(
            [string]$name,
            [string]$access,
            [string]$priv,
            [string]$valtype,
            [string]$lang,
            [string]$author,
            [int]$evalmax,
            [string]$rtype,
            [string]$ver,
            [string]$fname
            ){
        $this.name = $name
        $this.access = $access
        $this.priv = $priv
        $this.valtype = $valtype
        $this.lang = $lang
        $this.author = $author
        $this.evalmax = $evalmax
        $this.rtype = $rtype
        $this.ver = $ver
        $this.fname = $fname
    }


    ## Method checks to automatically divvy out the tools to appropriate users
    [string]toolInfo(){
        $info = "
    MACROSS: $($this.name)
        $(' Version:       ' + $this.ver)
        $(' Author:        ' + $this.author)
        $(' Evaluates:     ' + $this.valtype)
        $(' Max arguments: ' + [string]$this.evalmax)
        $(' Response type: ' + $this.rtype)
        $(' Privilege:     ' + $this.priv)
        $(' Tier:          ' + $this.access)
        $(' Language:      ' + $this.lang)
        $(' Filename:      ' + $this.fname)
        "
        Return $info
    }
    
}
