## Custom classes for MACROSS


## Classify MACROSS tools:
## -Users get access to their intended toolsets; admin tools won't be copied to user profiles,
##  tier 3 diamonds won't get copied to tier 1 profiles, etc.
## -MACROSS diamonds will be able to determine the capabilities and params of other scripts, i.e.
##  "are you a python script" or "can you accept more than one value to search on?"
## ======================================================================================================
##                                              IMPORTANT
## Custom scripts in the diamonds\ folder need to have the $priv thru $rtype values in a comma-
## separated line (in-order!) beginning with "#_class " in line 3.
## Make sure to write your $valtypes concise but distinct, example: many scripts might contain "IP" in their
## $valtypes, so differentiate them like "threat IP lookup" vs. "local IP search", etc.
## ======================================================================================================
class macross {

    [string]$name     ## Common name of the script
    [string]$priv     ## *Lowest* privilege level required, admin vs. user; scripts can contain admin-only functions while still mostly working in userland
    [string]$access   ## The script's intended analyst: common (everybody) vs. tiers 1-3
    [string]$valtype  ## The type of data a script is meant to process (IP, strings, logs, etc)
    [string]$lang     ## The script language, powershell vs. python
    [string]$author   ## Script author
    [int]$evalmax     ## How many values a script can accept; max is 2 if you intend to use the macross.collab function!
    [string]$rtype    ## What kind of response your script generates; example types are 'onscreen', 'json', 'file', 'string' or leave empty
    [string]$ver      ## The script version
    [string]$fname    ## The script's full filename + extension
    [string]$desc     ## Description from the script's #_SDF1 line
    [int]$pos         ## Position in the MACROSS menu; used for selection. This value dynamically changes when scripts are added/removed.
                      ## (Scripts are passed in alpha order)

    macross($scriptvalues){ $this.classifyScript($scriptvalues) }

    ## The toolCount function in updates.ps1 will feed script values here;
    ## Once the macross object has been created, it will be stored in the global
    ## dictionary $dyrl_ATTS to be used by functions that control RBAC and
    ## collaborations
    [void]classifyScript($scriptvalues){
        $this.name    = ($scriptvalues -Split ',')[0]
        $this.priv    = ($scriptvalues -Split ',')[1]
        $this.access  = ($scriptvalues -Split ',')[2]
        $this.valtype = ($scriptvalues -Split ',')[3]
        $this.lang    = ($scriptvalues -Split ',')[4]
        $this.author  = ($scriptvalues -Split ',')[5]
        $this.evalmax = ($scriptvalues -Split ',')[6]
        $this.rtype   = ($scriptvalues -Split ',')[7]
        $this.ver     = ($scriptvalues -Split ',')[8]
        $this.fname   = ($scriptvalues -Split ',')[9]
        $this.desc    = ($scriptvalues -Split ',')[10]
        $this.pos     = ($scriptvalues -Split ',')[11]
    }

    ## Attributes are collected automatically, shouldn't need the manual process but who knows
    [void]classifyScript(
            [string]$name,
            [string]$priv,
            [string]$access,
            [string]$valtype,
            [string]$lang,
            [string]$author,
            [int]$evalmax,
            [string]$rtype,
            [string]$ver,
            [string]$fname,
            [string]$desc,
            [int]$pos){
        $this.name    = $name
        $this.priv    = $priv
        $this.access  = $access
        $this.valtype = $valtype
        $this.lang    = $lang
        $this.author  = $author
        $this.evalmax = $evalmax
        $this.rtype   = $rtype
        $this.ver     = $ver
        $this.fname   = $fname
        $this.desc    = $desc
        $this.pos     = $pos
    }


    ## Method checks to automatically divvy out the tools by user role
    [string]toolInfo(){
        $nm = ' MACROSS: ' + $this.name
        $ve = ' Version:                     ' + $this.ver
        $au = ' Author:                      ' + $this.author
        $el = ' Evaluates:                   ' + $this.valtype
        $ac = ' Group:                       ' + $this.access
        $pr = ' Privilege required:          ' + $this.priv
        $la = ' Language:                    ' + $this.lang
        $ev = ' Max # of simultaneous evals: ' + [string]$this.evalmax
        $rt = ' Response type:               ' + $this.rtype
        $fn = ' Filename:                    ' + $this.fname
        $ds = ' Description                  ' + $this.desc
        $info = "
 $nm
    $ve
    $fn
    $au
    $ds
    $el
    $ac
    $pr
    $la
    $rt
    $ev
        "
        Return $info
    }

}



