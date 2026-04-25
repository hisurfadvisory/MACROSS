## Custom classes for MACROSS


## Classify MACROSS diamonds:
## The 3rd line in every script in the \diamonds folder must be the classifier:
##
##      #_class $priv,$access,$valtype,$lang,$author,$evalmax,$rtype
##
## -Users get access to their intended diamond; admin diamonds won't be copied to user profiles,
##      tier 1 diamonds won't get copied to tier 3 profiles, etc.
## -MACROSS diamonds will be able to determine the capabilities and params of other diamonds, i.e.
##      "are you a python script" or "can you accept more than one value to search on?"
## ======================================================================================================
##                                              IMPORTANT
## Custom scripts in the diamonds\ folder need to have the $priv thru $rtype values in a comma-
## separated line (in-order!) beginning with "#_class " in line 3. Do not leave any field empty!
## The remaining class fields are all automatically assigned within MACROSS ($fname, $pos, etc.)
## Make sure to write your $valtypes concise but distinct, example: many diamonds might contain "IP" in their
## $valtypes, so differentiate them like "threat IP lookup" vs. "local IP search", etc.
## ======================================================================================================
class macross {

    [string]$name     ## Common name of the diamond
    [string]$priv     ## *Lowest* privilege level required, admin vs. user; diamonds can contain admin-only functions while still mostly working in userland
    [string]$access   ## The diamond's intended group: common (everybody) vs. tier1 vs. tier2 vs. tier3
    [string]$valtype  ## The type of data a diamond is meant to process (IP, strings, logs, etc)
    [string]$lang     ## The diamond language, powershell vs. python
    [string]$author   ## Script author
    [int]$evalmax     ## How many values a diamond can accept; max is 2 if you intend to use the macross.collab function!
    [string]$rtype    ## What kind of response your diamond generates; example types are 'json', 'file', 'string' or 'none'
    [string]$ver      ## The diamond version
    [string]$fname    ## The diamond's full filename + extension
    [string]$desc     ## Description from the diamond's #_sdf1 line
    [int]$pos         ## Position in the MACROSS menu; used for selection. This value dynamically changes when diamonds are added/removed.
                      ## (Scripts are passed in alpha order)

    <#
    ** Make sure to be distinct and consistent when assigning an attribute to your diamonds, so that
    the findDF function gives you the correct diamonds every time! For example, if there are diamonds
    that return streamed json vs. writing json to a file, you should use separate .rtypes, like 'json'
    and 'json file'.
    #>

    macross($scriptvalues){ $this.classifyDiamond($scriptvalues) }

    ## The diamondCount function in updates.ps1 will feed diamond values here;
    ## Once the macross object has been created, it will be stored in the global
    ## dictionary $dyrl_ATTS to be used by functions that control RBAC and 
    ## collaborations
    [void]classifyDiamond($scriptvalues){
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

    ## Attributes are collected automatically, shouldn't need the manual process but it's here for funsies
    [void]classifyDiamond(
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


    ## Method checks to automatically divvy out the diamonds by user role or valkyrie requirement
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


