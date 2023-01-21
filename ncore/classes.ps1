
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
    
    The 'macross' class relies on the third line, it must begin with  "#_class " followed by a
    comma separated string of attributes for your script:

        your scriptname (no extension),
        level of privilege required,
        the type of data it works with,
        the script's langauge,
        the script's author,
        the number of values it can handle being passed

    You should not need to worry about generating objects in the macross class, MACROSS does it
    automatically every time it builds out its menu. You just need to make sure you're following
    the commenting convention described above in the first three lines of your scripts.
   
    Example attributes: 'Allusers' might be used to let everyone load your script, while 'Tier2'
    could limit the script to just senior SOC analysts.
#>
class macross {
    

    [string]$name   ## Attribute 1: Name of the script
    [string]$priv   ## Attribute 2: Privilege level required, admin vs. user
    [string]$valtype  ## Attribute 3: What kind of values the script can accept (strings, filenames, etc).
    [string]$lang   ## Attribute 4: The script language
    [string]$author ## Attribute 5: Script author
    [int]$evalmax   ## Attribute 6: How many values a script can accept from other tools
    [string]$ver    ## Attribute 7: The script version

    
    <# 
       Examples for classifying MACROSS tools:

       $gerwalk = [macross]::new('GERWALK,Admin,Tier3,endpoint artifacts,Powershell,HiSurfAdvisory,1,4.5')
                                   ^^ The GERWALK script now gets described with all of these attributes

       $gerwalk.access --> will return 'Tier3' so only forensics people can execute it
       $gerwalk.priv --> will return 'admin', so it will only be visible to someone logged in
            with admin credentials (provided you are using a master repo and version checks)

       You can then craft your scripts to search through the $vf19_ATTS hashtable to find
       relevant scripts to perform further evals, for example:

            Get-ChildItem -file $vf19_TOOLSDIR | %{
            foreach($tool in $vf19_ATTS){
                if($vf19_ATTS[$tool.Keys].lang -eq 'Powershell' -and `
                    $vf19_ATTS[$tool.Keys].evals -Like '*ip addresses*'){
                    Write-Host 'Do you want to pass $PROTOCULTURE to $tool for processing?'
                }
            }
            }
            .ver
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
        $this.valtype = ($scriptvalues -Split ',')[2]
        $this.lang = ($scriptvalues -Split ',')[3]
        $this.author = ($scriptvalues -Split ',')[4]
        $this.evalmax = ($scriptvalues -Split ',')[5]
        $this.ver = ($scriptvalues -Split ',')[6]
    }

    [void]setAttributes(
            [string]$name,
            [string]$priv,
            [string]$valtype,
            [string]$lang,
            [string]$author,
            [int]$evalmax,
            [string]$ver){
        $this.name = $name
        $this.priv = $priv
        $this.valtype = $valtype
        $this.lang = $lang
        $this.author = $author
        $this.evalmax = $evalmax
        $this.ver = $ver
    }


    ## Method checks to automatically divvy out the tools
    [string]toolInfo(){
        $nm = ' MACROSS: ' + $this.name
        $ve = ' Version:                     ' + $this.ver
        $au = ' Author:                      ' + $this.author
        $el = ' Evaluates:                   ' + $this.valtype
        $pr = ' Privilege required:          ' + $this.priv
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

