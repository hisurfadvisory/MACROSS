## Functions to automate checking for diamond updates

<################################
    Check if local nmods folder has all relevant tools; checks for python scripts
     if python is installed.
    Generates the $dyrl_ATTS & $dyrl_LATTS arrays that contains class attributes for
     each MACROSS script
################################>
function diamondCount(){
    $valid = @('#_sdf1','#_ver','#_class')
    Remove-Variable -Force dyrl_ATTS,dyrl_LATTS -Scope Global   ## Clear old lists from memory
    $Global:dyrl_ATTS = [ordered]@{}              ## Collect MACROSS class info for repo tools
    $Global:dyrl_LATTS = [ordered]@{}             ## Collect MACROSS class info for local tools
    $Global:dyrl_FILECT = 0                       ## Track how many tools are installed locally
    $Global:dyrl_REPOCT = 0                       ## Track how many tools are available in each dynamic repo's path
    $menunum = 0                                ## Create selector for the main menu
    if( $MONTY ){ $ext = "*.p*"; $pa = '' }     ## Count python tools
    else{ $ext = "*.ps*" }                      ## Ignore python tools if python not installed
    
    ## Record the local toolset
    foreach( $lc in (Get-ChildItem -File "$dyrl_MODS\$ext" | Sort -Property Name)){
        $check = gc $lc -First 3
        $lclassed = $true
        0..2 | %{
            if(-not ($check[$_] | sls $valid[$_])){ $lclassed = $false }
        }
        if($lclassed){
            $menunum++
            $ldesc = $check[0] -replace "^\S+ " -replace ',',' '
            $lver = $check[1] -replace "^\S+ "
            $lclass = $check[2] -replace "^\S+ "
            $lname = $lc.Name -replace "\..+$"                      ## Strip the file extension
            $Global:dyrl_FILECT++                                     ## Increment total file count
            [macross]$lsc = $lname + ",$lclass" + ",$lver" + ",$($lc.Name)" + ",$ldesc,$menunum"   ## Create custom [macross] object
            $Global:dyrl_LATTS.Add($lname,$lsc)                       ## Only collect macross attributes for the user's scripts
        }
    }
    $menunum = 0; if( $MONTY ){ pyATTS }  ## python iz yer frend

    ## Record the master toolset
    if($dyrl_CHECKUPDATES){
    foreach( $rc in (Get-ChildItem -File "$dyrl_REPOTOOLS\$ext" | Sort -Property Name)){
        $check = gc $rc -First 3
        $rclassed = $true
        0..2 | %{
            if(-not ($check[$_] | sls $valid[$_])){ $rclassed = $false }
        }
        if($rclassed){
            $rdesc = $check[0] -replace "^\S+ " -replace ',',' '
            $rver = $check[1] -replace "^\S+ "
            $rclass = $check[2] -replace "^\S+ "
            $rname = $rc.Name -replace "\..+$"
            [macross]$rsc = $rname + ",$rclass" + ",$rver" + ",$($rc.Name)" + ",$rdesc,$menunum"
            $Global:dyrl_ATTS.Add($rname,$rsc)
            
            
            ## Track the number of master scripts relevant to the user, to compare against local count
            ## and make sure they download all available tools
            if($dyrl_ACCESSTIER.Item3 -and $dyrl_ATTS[$rname].access -In @('common','tier3')){
                if($dyrl_ATTS[$rname].priv -eq 'user'){
                    $Global:dyrl_REPOCT++
                }
                elseif( ! $ROBOTECH -and $dyrl_ATTS[$rname].priv -eq 'admin' ){
                    $Global:dyrl_REPOCT++
                }
            }
            elseif($dyrl_ACCESSTIER.Item2 -and $dyrl_ATTS[$rname].access -In @('common','tier2')){
                if($dyrl_ATTS[$rname].priv -eq 'user'){
                    $Global:dyrl_REPOCT++
                }
                elseif( ! $ROBOTECH -and $dyrl_ATTS[$rname].priv -eq 'admin' ){
                    $Global:dyrl_REPOCT++
                }
            }
            elseif($dyrl_ACCESSTIER.Item1 -and $dyrl_ATTS[$rname].access -notIn @('tier2','tier3')){
                if($dyrl_ATTS[$rname].priv -eq 'user'){
                    $Global:dyrl_REPOCT++
                }
                elseif( ! $ROBOTECH -and $dyrl_ATTS[$rname].priv -eq 'admin' ){
                    $Global:dyrl_REPOCT++
                }
            }
            
        }
    }
    }
}

<################################
   Check the repo for new scripts that need to be downloaded
   Match the $script.access to the user's $dyrl_IR/$dyrl_DCO assignment
   On initial run, the nmods folder will be empty, so just add all the
   repo tools to the $mismatch_list.
################################>
function look4New(){
    ## Perform final check and copy scripts
    function copyScript($a,$b){
        if($a -eq 'MACROSS.ps1'){ $dir = $dyrl_REPOCORE }
        else{ $dir = $dyrl_REPOTOOLS }
        
        splashPage
        w "`n`n     You are missing '$a'. Installing it now...`n" y
        Copy-Item -Path "$dir\$a" "$dyrl_MODS\$a"
        if( Test-Path -Path "$dyrl_MODS\$a" ){
            w "        ...$a has been installed in the console!`n" g
            if($a -eq $dyrl_ATTS.TIPPER.fname){
                Copy-Item -Path "$dir\corefuncs\plugins\$($tippers[0])" "$dyrl_MACROSS\corefuncs\plugins\$($tippers[0])"
                Copy-Item -Path "$dir\corefuncs\plugins\$($tippers[1])" "$dyrl_MACROSS\corefuncs\plugins\$($tippers[1])"
            }
        }
        else{
            w "        ERROR - $a could not be installed!`n" c
            errLog 'ERROR' $USR "Failed to copy $a from master repo."
        }
        sleep 1
    }

    $LIST0=@{}; $LIST1=@{}
    $dyrl_LATTS.keys | %{ $LIST0.Add($dyrl_LATTS[$_].fname,$dyrl_LATTS[$_].ver) }
    if($ROBOTECH){$dyrl_ATTS.keys | ?{$dyrl_ATTS[$_].priv -ne 'admin'} | %{$LIST1.Add($dyrl_ATTS[$_].fname,$dyrl_ATTS[$_].ver)}}
    else{ $dyrl_ATTS.keys | %{ $LIST1.Add($dyrl_ATTS[$_].fname,$dyrl_ATTS[$_].ver) }}
    $LIST1.keys | %{
        $k = $_ -replace "\..+$"
        if( ! $dyrl_ACCESSTIER.Item3 -and $dyrl_LATTS[$k].access -eq 'tier3' ){ $LIST1.Remove($_) }
        if( ! $dyrl_ACCESSTIER.Item2 -and $dyrl_LATTS[$k].access -eq 'tier2' ){ $LIST1.Remove($_) }
        if( ! $dyrl_ACCESSTIER.Item1 ){ $LIST1.Remove($_) }
    }
    
    

    ## Check if local diamond copies already exist
    if($dyrl_FILECT -eq 0){
        $tool_diff = @()
        $LIST1.keys | %{
            $tool_diff += $_
        }
    }
    else{
        $tool_diff = Compare-Object -ReferenceObject $($LIST1.keys) -DifferenceObject $($LIST0.keys)
    }
    $tt=0;$tool_diff | %{$tt++}
    if($tt -gt 0){
        Foreach($t0 in $tool_diff){
            if($dyrl_FILECT -eq 0){
                copyScript $t0
            }
            elseif($t0.SideIndicator -eq '<='){
                copyScript $($t0.InputObject)
            }
        }
        diamondCount
    }
    

    if( $dyrl_MISMATCH -and ! $dyrl_SILENCED){
        Remove-Variable -Force dyrl_MISMATCH -Scope Global
        $mismatch_list = Compare-Object -ReferenceObject $($LIST0.keys) -DifferenceObject $($LIST1.keys)
        w "`n    You have scripts that are not in the master repository:`n" y
        foreach( $a in $mismatch_list ){
            w "      $($a.InputObject)" c
        }
        w "`n  Do you want to delete these? " g -i
        $z = Read-Host
        if($z -Match "^y"){
            $mismatch_list | %{
                w "  Deleting $($_.InputObject)" y
                Remove-Item -Path "$dyrl_MODS\$($_.InputObject)"
                sleep 1
            }
        }
        else{
            w '  Got it, this check will be silenced for the rest of this MACROSS session.' g
            $Global:dyrl_SILENCED = $true
            sleep 2
        }
    }
}

<################################
   Update latest diamond versions
   $1 is the filepath passed in from verChk function (mandatory)
   $2 is the latest diamond version found by verChk (mandatory)
   $plugin will download additional files required by certain tools,
   if any, to the local corefuncs\plugins folder; use -plugin @(list,of,files)
################################>
function dlNew($1,$2,$plugin){
    
    ## $addons must be a list
    function addOn($p){
        $pluginsR = "$dyrl_REPOCORE\corefuncs\plugins"
        $pluginsL = "$dyrl_MACROSS\corefuncs\plugins"
        Get-ChildItem -Path $pluginsR | ForEach-Object{
            if($_ -in $p){
                Copy-Item -Force -Recurse -Path "$pluginsR\$_" "$pluginsL"
            }
        }
    }

    if($plugin){
        addOn $plugin
    }
    else{
        if( ! $1 -or ! $2 ){
            errMsg 3
        }
        else{
            if( $1 -eq "MACROSS" ){
                $dir = $Global:dyrl_REPOCORE
                Copy-Item -Force -Path "$dir\$1.ps1" "$dyrl_MACROSS"
                Copy-Item -Recurse -Force -Path "$dir\corefuncs\*" "$dyrl_MACROSS\corefuncs\"
                w "`n      $1 needs to be restarted. Run it again after it closes. Exiting...`n" y
                varCleanup -c
                sleep 2
                Exit
            }
            else{
                $dir = $Global:dyrl_REPOTOOLS
                $fn = $dyrl_LATTS[$1].fname

                splashPage

                w "     Updating $1...`n" g

                Copy-Item -Force -Path "$dir\$fn" "$dyrl_MODS\$fn"
                
                ## Update all the Tipperer files when necessary
                if( $1 -eq 'TIPPER' ){ addOn -t }
                
                diamondCount           ## Refresh the list of diamond versions
                verChk $1 'verify'  ## Make sure the new version downloaded correctly
                w "`n"
                if( $dyrl_REF ){
                    w "  ...$1 has been refreshed.`n" g
                    Remove-Variable dyrl_REF -Scope Global
                }
                else{
                    w "     ...$1 has been updated to version $2!" g
                }
                sleep 3
            }
        }
    }
}



################################
## Update latest diamond versions
## $1 is a mandatory value, the diamond name passed in from the functions 'chooseMod' & 'dlNew'
## $2 is an optional verification check passed in from the function 'dlNew'
################################
function verChk($1,$2){
    if( ! $1 ){
        errMsg 3
    }
    elseif($dyrl_CHECKUPDATES){
        #$3 = $1 -replace "\.p*"
        if($1 -ne 'MACROSS'){ 
            $fn = $dyrl_LATTS[$1].fname
            $local = "$dyrl_MODS\$fn"
            $dir = $Global:dyrl_REPOTOOLS
            $Global:dyrl_LATESTVER = $dyrl_ATTS[$1].ver
            $LOCALVER = $dyrl_LATTS[$1].ver
        }
        else{
            $fn = "$1.ps1"
            $local = "$dyrl_MACROSS\$fn"
            $dir = $Global:dyrl_REPOCORE
            $Global:dyrl_LATESTVER = (sls '#_ver' "$dir\$fn")[0] -replace "^.+ "
            $LOCALVER = (sls '#_ver'  "$local")[0] -replace "^.+ "
        }


        if( $2 -eq 'refresh' ){
            dlNew $fn $dyrl_LATESTVER
        }
        elseif( $LOCALVER -lt $dyrl_LATESTVER ){
            if( $2 -eq 'verify' ){
                splashPage
                w "`n      UPDATE FAILED!" y
                sleep 3
                $Global:dyrl_Z = 'GO'
                Return
            }
            elseif( $1 -ne "MACROSS" ){
                w "     $1 needs to update to v" y -i
                w "$dyrl_LATESTVER" m -i
                w ". Hit ENTER to continue." y
                Read-Host
                dlNew $1 $dyrl_LATESTVER
            }
            else{
                splashPage
                w "`n"
                w "     MACROSS v$dyrl_LATESTVER is live. Hit ENTER to update." y -i
                Read-Host

                dlNew $1 $Global:dyrl_LATESTVER
            }
        }
    }
}

