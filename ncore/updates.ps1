
## Functions to automate checking for tool updates
## If you use a local git or fileshare to store your master scripts, see the utility.ps1 file
##  for instructions on pointing these functions to that repository.

################################
##  toolCount func:
##  Check if local nmods folder has all the necessary scripts; includes python scripts
##   only if python is installed.
##  Generates the $vf19_ATTS array that contains class attributes for
##   each MACROSS script
################################
function toolCount(){
    Remove-Variable -Force vf19_ATTS,vf19_LIST0,vf19_LIST1 -Scope Global   ## Clear old lists from memory
    $Global:vf19_ATTS = @{}   ## Collect MACROSS class info for each tool
    $Global:vf19_LIST0 = @{}  ## Collect local versions for verChk function
    $Global:vf19_LIST1 = @{}  ## Collect master versions for verChk function
    $Global:vf19_FILECT = 0
    $Global:vf19_REPOCT = 0
    if( $MONTY ){
        $ext = "*.p*"  ## count python tools
    }
    else{
        $ext = "*.ps*" ## ignore python tools if python not installed
    }
    foreach( $fc in (Get-ChildItem -File "$vf19_TOOLSDIR\$ext" | Sort)){
        if( Get-Content $fc | Select -Index 0 | Select-String 'superdimensionfortress' ){
            $Global:vf19_FILECT++
            $v = $(gc $fc | Select -Index 1) -replace '#_ver '
            $Global:vf19_LIST0.Add($fc.Name,$v)
        }
    }
    foreach( $rc in (Get-ChildItem -File "$vf19_REPOTOOLS\$ext" | Sort)){
        if( Get-Content $rc | Select -Index 0 | Select-String 'superdimensionfortress' ){
            $n = $rc -replace "^.*\\" -replace "\.p.*$"                   ## Get the script name, strip the extension
            $v = (gc $rc | Select -Index 1) -replace "^#_ver "            ## Get the script version
            $c1 = (gc $rc | Select -Index 2) -replace "^#_class ","$n,"   ## Get the class/attribute line
            $c1 = $c1 + ",$v"                                             ## Cat all the script attributes into 1 string
            [MACROSS]$c2 = ($c1)                                          ## Create new object with the script's class
            $Global:vf19_ATTS.Add($n,$c2)                                 ## Add the script's attributes to global array
            

            <# 
               If script attributes indicate that they require admin privilege, and
               MACROSS is set up to recognize admin vs. non-admin users, it will not
               bother loading scripts marked as 'Admin' for standard user accounts.
               The framework is not designed to operate in a 'sudo' or 'run-as' fashion,
               it's all-or-nothing.
            #>
            if($vf19_ATTS[$n].priv -eq 'User'){
                $Global:vf19_REPOCT++
                $vv = $(gc $rc | Select -Index 1) -replace '#_ver '
                $Global:vf19_LIST1.Add($rc.Name,$vv)
            }
            elseif( ! $vf19_ROBOTECH -and $vf19_ATTS[$n].priv -eq 'Admin' ){
                $Global:vf19_REPOCT++
                $vv = $(gc $rc | Select -Index 1) -replace '#_ver '
                $Global:vf19_LIST1.Add($rc.Name,$vv)
            }
        }
    }
}


## Check the repo for new scripts that need to be downloaded
<#

   If using a master repository to maintain your custom scripts, store them
   separately from the MACROSS root folder you share out to users. Let them copy
   MACROSS, the ncore folder and its contents, and an empty nmods folder to their
   desktop. When they run MACROSS for the first time, the tools they have permissions
   to will download from your script repo, i.e. admin-only scripts will not get
   downloaded for standard users, and scripts that don't contain MACROSS attributes
   will be completely ignored.

   This is for SOC environments that may have separation between junior analysts who
   monitor dashboards or gather intel, and Tier-2/3 incident responders who perform
   deep-dives with more sensitive access.

#>
function look4New(){
    ## Check if local tool copies already exist
    if($vf19_FILECT -gt 0){
        $tool_diff = $(Compare-Object -ReferenceObject $($vf19_LIST1.keys) -DifferenceObject $($vf19_LIST0.keys))
    }
    else{
        $tool_diff = @()
        $vf19_LIST.keys | %{
            $tool_diff += $_
        }
    }
    
    ## Perform final check and copy scripts
    function copyScript($a,$b){
        if($a -eq 'MACROSS.ps1'){
            $dir = $vf19_REPOCORE
        }
        else{
            $dir = $vf19_REPOTOOLS
        }
        
        splashPage
        Write-Host '

        '
        Write-Host -f YELLOW "    You are missing '$a'. Installing it now...
        "
        try{
            Copy-Item -Path "$dir\$a" "$vf19_TOOLSDIR\$a"
            if( Test-Path -Path "$vf19_TOOLSDIR\$a" ){
                Write-Host -f GREEN "        ...$a has been installed in the console!
                "
            }
            else{
                Write-Host -f CYAN "        ERROR - $a could not be installed!
                "
            }
            slp 1
        }

        ## the tool menu and updater will get borked up if there is a file mismatch
        catch{
            cls
            Write-Host -f CYAN '  FATAL ERROR!' -NoNewline;
            Write-Host -f GREEN ' Could not copy the new files. The console will not'
            Write-Host -f GREEN '  work properly without them.
            '
            Write-Host -f GREEN '  Please ' -NoNewline;
            Write-Host -f CYAN 'DELETE' -NoNewline;
            Write-Host -f GREEN ' this copy of MACROSS and get a fresh copy from the'
            Write-Host -f GREEN "  'MACROSS' folder in the J63 share:"
            ''
            Write-Host "$vf19_REPOCORE
            "
            Remove-Variable vf19_* -Scope Global
            Exit
        }
    }
    


    if( $vf19_MISMATCH ){
        Write-Host -f YELLOW '   You have scripts that are not in the master folder:
        '
        foreach( $a in $mismatch_list ){
            Write-Host -f CYAN "      $a"
        }
        ''
        Write-Host -f YELLOW '   Updates are disabled until these are removed, or approved for'
        Write-Host -f YELLOW '   inclusion in the main MACROSS repository.'
        ''
        Write-Host -f GREEN '
        Hit ENTER to continue.'
        Read-Host
    }
    elseif($tool_diff){
        Foreach($t0 in $tool_diff){
            if($vf19_FILECT -eq 0){
                copyScript $t0
            }
            if($t0.SideIndicator -eq '<='){
                copyScript $($t0.InputObject)
            }
        }
    }

}

################################
## Update latest tool versions
## $1 is the filepath passed in from verChk function (required)
## $2 is the latest tool version found by verChk (required)
################################
function dlNew($1,$2){
    <#Params(
        [Parameter(Mandatory=$true)]
        $1,
        [Parameter(Mandatory=$true)]
        $2
    )#>
    if( ! $1 -or ! $2 ){
        errMsg 3
    }
    else{
        $dir = $Global:vf19_REPOTOOLS
        $3 = $1 -replace "\.p*"
        $3 = $3 -replace "nmods\\"
        $4 = $1 -replace "nmods\\"
        if( $3 -eq "MACROSS" ){
            $NC_CHK = $true
            $dir = $Global:vf19_REPOCORE
        }
        elseif( $3 -eq 'C2EFFD' ){  ## Make sure to grab C2EFFD's NTRCEPT functions
            if( $vf19_IR ){
                $NC_XTRA = $true
            }
        }
        elseif( $3 -eq 'URLBLK' ){  ## Make sure all the required Tipper files get updated
            $tipr = $true
        }

        splashPage

        Write-Host -f GREEN "     Updating $3...
        "

        ## Update the main console and all its files
        if( $NC_CHK ){
            Copy-Item -Force -Path "$dir\$1" "$vf19_TOOLSROOT\$1"
            Get-ChildItem -Recurse -Path "$dir\ncore\*" | 
                ForEach-Object{
                    Copy-Item -Recurse -Force -Path "$dir\ncore\$_" "$vf19_TOOLSROOT\ncore\"
                }
        }
        ## Install powercat & bloodhound for NTRCEPT
        elseif( $NC_XTRA ){
            Copy-Item -Force -Path "$Global:vf19_REPOTOOLS\core_addons\powercat.ps1" "$vf19_TOOLSROOT\ncore\powercat.ps1"
            Copy-Item -Force -Path "$Global:vf19_REPOTOOLS\core_addons\sharphound.ps1" "$vf19_TOOLSROOT\ncore\sharphound.ps1"
        }
        else{
            Copy-Item -Force -Path "$dir\$1" "$vf19_TOOLSDIR\$1"
        }
        ## Update all the Tipperer files when necessary
        if( $tipr ){
            Get-ChildItem -Path "$dir\Tipperer" | 
                ForEach-Object{
                    Copy-Item -Force -Recurse -Path "$dir\Tipperer\$_" "$vf19_TOOLSROOT\Tipperer\"
                }
            Remove-Variable tipr
        }
        toolCount           ## Refresh the list of tool versions
        verChk $4 'verify'  ## Make sure the new version downloaded correctly
        Write-Host '
        '
        if( $vf19_REF ){
            Write-Host -f GREEN "  ...$3 has been refreshed.
            "
            Remove-Variable vf19_REF -Scope Global
        }
        else{
            Write-Host -f GREEN "     ...$3 has been updated to version $2!"
        }
        slp 3
        if( $NC_CHK ){
            cls
            ''
            Write-Host -f YELLOW "     $3 needs to be restarted. Run it again after it closes. Exiting...
            "
            slp 2
            Remove-Variable vf19_* -Scope Global
            Exit
        }
    }
}



################################
## Update latest tool versions
## $1 is a required value, the tool name passed in from the functions 'chooseMod' & 'dlNew'
## $2 is an optional verification check passed in from the function 'dlNew'
################################
function verChk($1){
    <#Params(
        [Parameter(Mandatory=$true)]
        [string]$1,
        [string]$2
    )#>
    if( ! $1 ){
        errMsg 3
    }
    else{
        $3 = $1 -replace "\.ps1"
        if( $3 -ne 'MACROSS' ){
            $local = "$vf19_TOOLSDIR\$1"
            $dir = $Global:vf19_REPOTOOLS
            $Global:vf19_LVER = $vf19_LIST1[$1]
            $vf19_CVER = $vf19_LIST0[$1]
        }
        else{
            $local = "$vf19_TOOLSROOT\$1"
            $dir = $Global:vf19_REPOCORE
            $Global:vf19_LVER = (Get-Content "$dir\$1" | Select -Index 1) -replace "^.+ "
            $vf19_CVER = (Get-Content "$local" | Select -Index 1) -replace "^.+ "
        }


        if( $2 -eq 'refresh' ){
            dlNew $1 $vf19_LVER
        }
        elseif( $vf19_CVER -lt $vf19_LVER ){
            if( $2 -eq 'verify' ){
                splashPage
                Write-Host '
                '
                Write-Host -f YELLOW '     UPDATE FAILED!
                '
                slp 3
                $Global:vf19_Z = 'GO'
                Return
            }
            elseif( $3 -eq "MACROSS" ){
                Write-Host -f YELLOW "     $3 needs to update to v" -NoNewline;
                Write-Host -f MAGENTA "$vf19_LVER" -NoNewline;
                Write-Host -f YELLOW ". Hit ENTER to continue."
                Read-Host
                dlNew $1 $vf19_LVER
            }
            else{
                splashPage
                Write-Host "
                "
                Write-Host -f YELLOW "     $3 v$vf19_LVER is live. Hit ENTER to update." -NoNewline;
                Read-Host

                dlNew $1 $Global:vf19_LVER
            }
        }
    }
}
