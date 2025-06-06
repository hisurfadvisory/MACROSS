
## Functions to automate checking for tool updates
## If you use a local git or fileshare to store your master scripts, enter "config"
## in the main menu and select the "Update configs" option. You will need to specify the
## key as "rep", and then enter the path to the master repository you wish to use (you'll
## get a warning that you're about to overwrite the existing "rep" value.)


## Convert bytes pulled from web servers into strings; send back contents as a list of lines
function parseFromWebServer($1){
    Return ((([Text.Encoding]::UTF8.GetString($(Invoke-WebRequest -UseBasicParsing "$1").Content) -Join '') -replace "`r") -split "`n")
}

################################
##  toolCount func:
##  Check if local modules folder has all the necessary scripts; includes python scripts
##   only if python is installed.
##  Generates the $vf19_ATTS array that contains class attributes for
##   each MACROSS script
################################
function toolCount(){
    Remove-Variable -Force vf19_LATTS -Scope Global                 ## Clear old array for refresh
    $Global:vf19_LATTS = [ordered]@{}                               ## Collect MACROSS class info for locally installed tools
    if(! $Global:vf19_ATTS){ $Global:vf19_ATTS = [ordered]@{} }     ## Collect MACROSS class info for tools in the repo
    $Global:vf19_FILECT = 0
    $Global:vf19_REPOCT = 0
    $menunum = 0
    if($vf19_ACCESSTIER.Item3){ $t3 = $true }
    if($vf19_ACCESSTIER.Item2){ $t2 = $true }
    if($vf19_ACCESSTIER.Item1){ $t1 = $true }
    if( $MONTY ){ $ext = "*.p*"; $pa = '' }     ## count python tools
    else{ $ext = "*.ps*" }                      ## ignore python tools if python not installed
    
    $rgx = [regex]"^#_\S+ "
    foreach($lscript in (Get-Childitem "$vf19_TOOLSDIR\$ext" | Sort Name)){
        $menunum++
        $ln = $lscript.name                                                         ## Record the fullname with extension
        $lfn = $ln -replace "\..+"                                                  ## Set common name (no ext.)
        $ldesc = (Get-Content $lscript.FullName | Select -Index 0) -replace $rgx    ## This is the tool description
        $lver = (Get-Content $lscript.FullName | Select -Index 1) -replace $rgx     ## This is the tool version
        $lclass = (Get-Content $lscript.FullName | Select -Index 2) -replace $rgx   ## These are the class attributes
        [macross]$latts = $lfn + ",$lclass" + ",$lver" + ",$ln,$ldesc,$menunum"     ## Use the above lines to create the macross object
        $Global:vf19_LATTS.Add($lfn,$latts)                         ## Add the tool and its details to the local tracking list
        $Global:vf19_FILECT++                                       ## Track how many tools are installed
    }
    
    ## Write a temp file for the valkyrie module
    if($MONTY){ pyATTS }
    $menunum = 0

    ##################################################################
    ##  MOD SECTION
    ##      If you are using git or some other master repository that isn't
    ##      a networked share or http server, you'll need to add a method
    ##      to create the $masterlist value below.
    ##################################################################
    if($vf19_VERSIONING){
    
    ## For web-hosted scripts, just perform one initial check at startup; no need to spam IWR every time the menu loads
    if(! $webrepo -or ($webrepo -and $vf19_ATTS.count -eq 0)){

    ##################
    ## Depending where and how your web server is hosting scripts, you may need to tweak this, as well.
    ##################
    if($vf19_REPOTOOLS -Like "http*"){
        ## MOD SECTION ##
        ## Uncomment this line if you are storing config files on a local server that is using 
        ## self-signed TLS certs; ONLY DO THIS IF YOU FULLY TRUST THE CERTIFICATE CHAIN!

        #[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

        battroid -N webrepo -V $true   ## Tell macross your repo isn't a local fileshare

        $masterlist = New-Object System.Collections.ArrayList

        ## MOD SECTION ##
        ## Make sure your fileserver allows indexing so MACROSS knows what scripts are in the directory!
        (((Invoke-WebRequest -UserAgent MACROSS -UseBasicParsing "$vf19_REPOTOOLS/").content -Split "`n") | 
            ?{$_ -Like "*$ext*"}) -replace "^.+=`"" -replace "`".+" | Sort | %{
            $masterlist.Add("$vf19_REPOTOOLS/$_") > $null
        }

    }
    ##################
    ## Reading from a repo hosted on a network share is the simplest method
    ##################
    else{
        $masterlist = (Get-Childitem "$vf19_REPOTOOLS\$ext" | Sort Name -Descending)
    }

    
    foreach($rscript in $masterlist){
        ## Based on whether $webrepo is true, doing a lookup for master files will be different...
        if( $webrepo ){ $rn = $rscript -replace "^.+/" }
        else{ $rn = $rscript.name }

        $rfn = $rn -replace "\..+"

        if( $webrepo ){ 
            $magiclines = parseFromWebServer $rscript | Select -Index 0,1,2
            #$magiclines = (Invoke-WebRequest $rscript -UseBasicParsing) -Split "`n" | Select-String -Pattern "^#_"
        }
        else{ $magiclines = Get-Content $rscript.FullName | Select -Index 0,1,2 }

        $rdesc = $magiclines[0] -replace $rgx 
        $rver = $magiclines[1] -replace $rgx
        $rclass = $magiclines[2] -replace $rgx 
        [macross]$ratts = $rfn + ",$rclass" + ",$rver" + ",$rn,$ldesc,$menunum" 
        $Global:vf19_ATTS.Add($rfn,$ratts)

        <# 
            If script attributes indicate that they require admin privilege, and you
            configured MACROSS to recognize admin vs. non-admin users, it will not
            bother loading scripts with a .priv value 'admin' for standard user 
            accounts. MACROSS is not designed to operate in a 'sudo' or 'run-as'
            fashion, it's all-or-nothing.

            If you've set Tier/GPO restrictions and configured a central repo, analysts
            will only be able to download scripts applicable to their Tier level, as well
            as their user/admin privilege level.
        #>
        
        if($vf19_ATTS[$rfn].priv -eq 'user'){
            if($t3 -or ($vf19_ATTS[$rfn].access -Match "tier[1-2]" -and $t2) -or `
            ($vf19_ATTS[$rfn].access -eq 'tier1' -and $t0) -or `
            $vf19_ATTS[$rfn].access -notLike "tier*"
            ){
                $Global:vf19_REPOCT++
            }
        }
        elseif( ! $vf19_ROBOTECH -and $vf19_ATTS[$rfn].priv -eq 'admin' ){
            if($t3 -or ($vf19_ATTS[$rfn].access -Match "tier[1-2]" -and $t2) -or `
            ($vf19_ATTS[$rfn].access -eq 'tier1' -and $t1) -or `
            $vf19_ATTS[$rfn].access -notLike "tier*"
            ){
                $Global:vf19_REPOCT++
            }
        }
    }}}
}


## Check the repo for new scripts that need to be downloaded
<#

   If using a master repository to maintain your custom scripts, store them
   separately from the MACROSS root folder you share out to users. Let them copy
   MACROSS, the core folder and its contents, and an empty modules folder to their
   desktop. When they run MACROSS for the first time, the tools matching their tier
   level will download from your script repo, i.e. admin-only scripts will not get
   downloaded for standard users, and scripts that don't contain MACROSS attributes
   will be completely ignored.

   This is for SOC environments that may have separation between junior analysts who
   monitor dashboards or gather intel, and Tier-2/3 incident responders who perform
   deep-dives with more sensitive access to API automations.

#>
function look4New(){
    ## Check if local tool copies already exist
    if($vf19_FILECT -gt 0){
        $tool_diff = $(Compare-Object -ReferenceObject $($vf19_ATTS.keys) -DifferenceObject $($vf19_LATTS.keys))
    }
    else{
        $tool_diff = $($vf19_ATTS.keys)
    }

    if( $vf19_FILECT -gt $vf19_REPOCT ){ 
        $Global:vf19_MISMATCH = $true; $mismatch_list = New-Object System.Collections.ArrayList
        $tool_diff | ?{$_.SideIndicator -eq '=>'} | Select -ExpandProperty InputObject | %{
            $mismatch_list.Add($vf19_LATTS[$_].fname)
        }
    }
    
    ## Perform final check and copy scripts
    function copyScript($a,$b){
        if($a -eq 'MACROSS.ps1'){ $dir = $vf19_REPOCORE }
        else{ $dir = $vf19_REPOTOOLS }
        
        splashPage
        w "`n`n    You are missing '$a'. Installing it now...`n" y

        ##################################################################
        ##  MOD SECTION
        ##      This is where new or updated scripts get copied from the repo
        ##      to your local modules folder. Depending on where your master
        ##      scripts are hosted, you might need to modify this along with
        ##      the mod sections elsewhere in this file.
        ##################################################################
        if( $webrepo ){ parseFromWebServer "$dir/$a" > "$vf19_TOOLSDIR\$a" }

        ## Using network shares to host the repo is easiest...
        else{ Copy-Item -Path "$dir\$a" "$vf19_TOOLSDIR\$a" }
        if( Test-Path -Path "$vf19_TOOLSDIR\$a" ){
            w "        ...$a has been installed in the console!`n" g
        }
        else{
            eMsg "ERROR - $a could not be installed for $USR!"
        }
        slp 1
    }
    


    if( $vf19_MISMATCH -and ! $vf19_SILENCE ){
        w "   You have scripts that are not in the master folder:`n" y
        foreach( $a in $mismatch_list ){
            w "      $a" c
        }
        ''
        w '   Do you want to delete these? (y/n) ' y -i
        $yn = Read-Host
        ''
        if($yn -ne 'y'){
            w ' This check will be silenced until the next time you launch MACROSS.' g
            $Global:vf19_SILENCE = $true; slp 2
        }
        else{
            $yn=$null; while($yn -notMatch "^(yes|n.)$"){
                w ' Are you sure? This will delete the files from your modules folder. (yes/no) ' c -i
                $yn = Read-Host
            }
            if($yn -eq 'yes'){
                $mismatch_list | %{
                    w " Deleting $_`..." c
                    Remove-Item "$vf19_TOOLSDIR\$_"
                }
                Remove-Variable -Force $vf19_MISMATCH -Scope Global
            }   
        }
    }

    ## If you're using a central repo separate from MACROSS that may contain non-MACROSS scripts,
    ## your analysts should be given an empty "modules" folder at first-use. This check will automatically
    ## search your repo for the appropriate MACROSS tools and download them based on their .access level.
    elseif(($tool_diff).count -gt 0){
        Foreach($t0 in $tool_diff){
            if($vf19_FILECT -eq 0){ 
                $t1 = $t0 -replace "\..*"
                $tfn = $vf19_ATTS[$t1].fname 
                $lang = $vf19_ATTS[$t1].lang
            }
            elseif($t0.SideIndicator -eq '<='){ 
                $tfn = $vf19_ATTS[$t0.InputObject].fname 
                $lang = $vf19_ATTS[$t0.InputObject].lang
            }

            if($MONTY -and $lang -eq 'python'){ copyScript $tfn }
            elseif($lang -eq 'powershell'){ copyScript $tfn }
        }
        toolCount
    }

}

################################
## Update latest tool versions
## $1 is the filepath passed in from verChk function (required)
## $2 is the latest tool version found by verChk (required)
################################
function dlNew($1,$2){
    if( ! $1 -or ! $2 ){
        eMsg 3
        errLog ERROR "$USR - dlNew function failed to check for new scripts."
    }
    else{
        $3 = $1 -replace "\..*"
        $3 = $3 -replace "modules\\"
        $4 = $1 -replace "modules\\"
        if( $3 -eq "MACROSS" ){ $CONSOLE = $true; $dir = $vf19_REPOCORE }
        else{ $dir = $vf19_REPOTOOLS }

        splashPage

        w "     Updating $3...`n" g

        ##################################################################
        ##  MOD SECTION
        ##      More sections where MACROSS needs to copy from the master
        ##      repo to the local folders.
        ##################################################################

        ## Update the main console and all its files
        if( $CONSOLE ){
            if( $webrepo ){ 
                parseFromWebServer "$dir/MACROSS.ps1" > "$vf19_TOOLSROOT/MACROSS.ps1"
                gci -file "$vf19_TOOLSROOT/core/*" | %{
                    $core = $_.name
                    parseFromWebServer "$dir/core/$core" > "$vf19_TOOLSROOT/core/$core"
                }
                gci -file "$vf19_TOOLSROOT/core/macross_py/*" | %{
                    $pycore = $_.name
                    parseFromWebServer "$dir/core/macross_py/$pycore" > "$vf19_TOOLSROOT/core/$pycore"
                }
            }
            else{ Copy-Item -Force -Path "$dir\$1" "$vf19_TOOLSROOT\$1" }
            Get-ChildItem -Recurse -Path "$dir\core\*" | 
                ForEach-Object{
                    Copy-Item -Recurse -Force -Path "$dir\core\$_" "$vf19_TOOLSROOT\core\"
                }
        }
        else{
            if( $webrepo ){parseFromWebServer "$dir/$1" > "$vf19_TOOLSDIR/$1" }
            else{ Copy-Item -Force -Path "$dir\$1" "$vf19_TOOLSDIR\$1" }
        }
        toolCount           ## Refresh the list of tool versions
        verChk $4 'verify'  ## Make sure the new version downloaded correctly
        w "`n"
        if( $vf19_REF ){
            w "  ...$3 has been refreshed.`n"
            Remove-Variable vf19_REF -Scope Global
        }
        else{
            w "     ...$3 has been updated to version $2!" g
        }
        slp 3
        if( $CONSOLE ){
            cls
            ''
            w "     $3 needs to be restarted. Run it again after it closes. Exiting...`n" y
            slp 2
            Remove-Variable vf19_* -Scope Global
            Exit
        }
    }
}



#################################
## Update latest tool versions; requires that you maintain a master repository and that its
## location can be found in $vf19_MPOD['rep'] (you specify this during initial setup).
## $1 is a required value, the tool name passed in from the functions 'chooseMod' & 'dlNew'
## $2 is an optional verification check passed in from the function 'dlNew'
################################
function verChk($1){
    if( ! $1 ){
        eMsg 3
        errLog "$USR - corrupt or non-existent modules script tried to load."
    }
    else{
        $3 = $1 -replace "\.p*"
        if( $3 -ne 'MACROSS' ){
            $local = "$vf19_TOOLSDIR\$1"
            $dir = $vf19_REPOTOOLS
            $latestv = $vf19_ATTS[$1].ver
            $runningv = $vf19_LATTS[$1].ver
        }
        else{
            $local = "$vf19_TOOLSROOT\$1"
            $dir = $vf19_REPOCORE
            ##################################################################
            ##  MOD SECTION
            ##      Another function to copy/download the latest scripts from repo
            ##      to the local folders. This gets executed each time a user
            ##      selects a tool from the main menu, to check for new versions.
            ##################################################################
            if( $webrepo ){ 
                $Global:vf19_LATESTVER = ((curl.exe -ks -A MACROSS "$dir/$1") | Select -Index 1 ) -replace "^#_ver "
                #$Global:vf19_LATESTVER = (([System.Text.Encoding]::UTF8.GetString($(Invoke-WebRequest -UseBasicParsing "$dir/$1").content) -join '') -split "`n")[1] -replace "#_ver "
            }
            else{ 
                $Global:vf19_LATESTVER = (Get-Content "$dir\$1" | Select -Index 1) -replace "^.+ " 
            }
            $latestv = $vf19_LATESTVER
            $runningv = (Get-Content "$local" | Select -Index 1) -replace "^.+ "
        }


        if( $2 -eq 'refresh' ){
            dlNew $1 $latestv
        }
        elseif( $runningv -lt $latestv ){
            if( $2 -eq 'verify' ){
                splashPage
                w "`n"
                w "     UPDATE FAILED!`n" y
                errLog ERROR "$USR - failed updating $1 to version $latestv"
                slp 3
                $Global:vf19_Z = 'GO'
                Return
            }
            elseif( $3 -eq "MACROSS" ){
                w "`n`n     $3 needs to update to v" y -i
                w "$latestv" -i m
                w ". Hit ENTER to continue." y
                Read-Host
                dlNew $1 $latestv
            }
            else{
                splashPage
                w "`n"
                w "     $3 v$latestv is live. Hit ENTER to update." -i y
                Read-Host

                dlNew $1 $latestv
            }
        }
    }
}
