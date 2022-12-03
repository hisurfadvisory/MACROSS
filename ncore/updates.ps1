## Functions to automate checking for tool updates

## Analysts will copy the MACROSS tools to their own desktop/documents folder; these
## functions ensure they always have the latest versions and scripts
################################
##  Check if local nmods has all the tools
################################
function toolCount(){
    $Global:vf19_FILECT = 0
    $Global:vf19_REPOCT = 0
    if( $MONTY ){
        $ext = "*.p*"
    }
    else{
        $ext = "*.ps*"
    }

    foreach( $fc in (Get-ChildItem "$vf19_TOOLSDIR\$ext")){
        if( Get-Content $fc | Select -Index 0 | Select-String "wut" ){
            $Global:vf19_FILECT++
        }
    }
    foreach( $rc in (Get-ChildItem "$vf19_REPO\nmods\$ext")){
        if( Get-Content $rc | Select -Index 0 | Select-String "wut" ){
            $Global:vf19_REPOCT++
        }
    }
}
function look4New(){
    $local_tools = $(Get-ChildItem -Path $vf19_TOOLSDIR)     ## collect local script names
    $repo_tools = $(Get-ChildItem -Path "$vf19_REPO\nmods")  ## collect master script names
    $tool_diff = $(Compare-Object -ReferenceObject $repo_tools -DifferenceObject $local_tools)  ## compare the two previous lists
    $mismatch_list = @()  ## collect all the mismatched files from $tool_diff
    $i = 0
    splashPage
    Write-Host '
    '
    foreach( $t0 in $tool_diff ){
        $t1 = $tool_diff[$i].InputObject.Name
        $mismatch_list += $t1
        $i++
    }



    if( $vf19_MISMATCH ){
        Write-Host -f YELLOW '   You have scripts that are not in the master folder:
        '
        foreach( $a in $mismatch_list ){
            Write-Host -f CYAN "      $a"
        }
        Write-Host ''
        Write-Host -f YELLOW '   Updates are disabled until these are removed, or approved for'
        Write-Host -f YELLOW '   including in the main MACROSS repository.'
    }
    else{
        foreach( $a in $mismatch_list ){
            Write-Host -f YELLOW "    You are missing '$a'. Installing it now...
            "
            Start-Sleep -Seconds 2
            try{
                Copy-Item -Path "$vf19_REPO\nmods\$a" "$vf19_TOOLSDIR\$a"
                Write-Host -f GREEN "        ...$a has been installed in the console!
                "
                Start-Sleep -Seconds 1
            }
            catch{
                ## the tool menu and updater will get borked up if there is a file mismatch
                cls
                Write-Host -f CYAN '  FATAL ERROR!' -NoNewline;
                    Write-Host -f GREEN ' Could not copy the new files. The console will not'
                Write-Host -f GREEN '  work properly without them.
                '
                Write-Host -f GREEN '  Please ' -NoNewline;
                    Write-Host -f CYAN 'DELETE' -NoNewline;
                        Write-Host -f GREEN ' this copy of MACROSS and get a fresh copy from the'
                Write-Host -f GREEN '  master folder:
                '
                Write-Host $vf19_REPO
                Write-Host ''
                Write-Host -f GREEN '  You only need to copy these to your desktop:'
                Write-Host -f YELLOW '    -MACROSS.ps1'
                Write-Host -f YELLOW "    -The 'nmods' folder"
                Write-Host -f YELLOW "    -The 'ncore' folder"
                varCleanup 1
                Exit
            }
        }
    }
    Write-Host ''
    Write-Host -f GREEN '    Hit ENTER to continue.'
    Read-Host
}

################################
## Update latest tool versions
## $1 is the filepath passed in from verChk function (mandatory)
## $2 is the latest tool version found by verChk (mandatory)
################################
function dlNew($1,$2){
    if( ! $1 -or ! $2 ){
        errmsg 3
    }
    else{
        $3 = $1 -replace "\.ps1",''    ## Strip the extension for writing $3 to screen
        $3 = $3 -replace "nmods\\",''  ## Strip the directory for writing $3 to screen
        $4 = $1 -replace "nmods\\",''  ## Strip the directory for $4 to be sent back to verChk function
        if( $3 -eq 'MACROSS' ){
            $NC_CHK = $true         ## If updating MACROSS itself, also download the ncore folder and its files
        }
        <#
        elseif( $3 -eq 'LOOKUP' ){
            $NC_XTRA = $true
        }
        
        
        This 'elseif' was used for one of my host-lookup scripts, it told MACROSS to also download modified
        copies of powercat and sharphound to incorporate into that script. These are awesome network
        investigation/pentesting tools you can find at

        https://github.com/besimorhino/powercat
                            &
        https://github.com/BloodHoundAD/SharpHound

        Mad props to the people behind those, they're super useful!!
        
        #>

        splashPage

        Write-Host -f GREEN "     Updating $3...
        "
        Copy-Item -Force -Path "$Global:vf19_REPO\$1" "$vf19_TOOLSROOT\$1"
        if( $NC_CHK ){
            Get-ChildItem -Path "$Global:vf19_REPO\ncore" | 
                ForEach-Object{
                    Copy-Item -Force -Path "$Global:vf19_REPO\ncore\$_" "$vf19_TOOLSROOT\ncore\"
                }
        }
        <#elseif( $NC_XTRA ){
            Copy-Item -Force -Path "$Global:vf19_REPO\addons\powercat.ps1" "$vf19_TOOLSROOT\addons\powercat.ps1"
            Copy-Item -Force -Path "$Global:vf19_REPO\addons\sharphound.ps1" "$vf19_TOOLSROOT\addons\sharphound.ps1"
        }#>
        verChk $4 'verify'  ## Verify that the requested script was actually downloaded
        Write-Host '
        '
        if( $vf19_REF ){  ## If user needed to download a fresh copy vs. an update
            Write-Host -f GREEN "  ...$3 has been refreshed.
            "
            Remove-Variable vf19_REF -Scope Global
        }
        else{
            Write-Host -f GREEN "     ...$3 has been updated to version $2!"
        }
        Start-Sleep -Seconds 3
        if( $NC_CHK ){             ## Kill MACROSS and force the user to restart so updates take effect
            cls
            Write-Host ''
            Write-Host -f YELLOW "     $3 needs to be restarted. Run it again after it closes. Exiting...
            "
            Start-Sleep -Seconds 2
            varCleanup 1
            Exit
        }
    }
}



<###############################
 Update to the latest tool versions---
   $1 is a mandatory value: the tool name passed in from the functions 'availableMods' & 'dlNew'
   $2 is an optional verification check passed in from those same functions
################################>
function verChk($1,$2){
    if( ! $1 ){
        errmsg 3
    }
    else{
        $3 = $1 -replace "\.ps1",''
        if( $3 -ne 'MACROSS' ){
            $1 = "nmods\$1"
        }

        ## Read the local version no. of the script
        $vf19_CVER = Get-Content "$vf19_TOOLSROOT\$1" | Select -Index 1
            $vf19_CVER = $vf19_CVER -replace "^#_ver ",''

        ## Read the master version no. of the script
        $Global:vf19_LVER = Get-Content "$vf19_REPO\$1" | Select -Index 1
            $Global:vf19_LVER = $vf19_LVER -replace "^#_ver ",''
    
        if( $2 -eq 'refresh' ){
            dlNew $1 $vf19_LVER  ## This is triggered by the user wanting to d/l a fresh copy
        }
        elseif( $vf19_CVER -lt $vf19_LVER ){
            if( $2 -eq 'verify' ){   ## This is an automatic check after dlNew runs to alert if download failed
                splashPage
                Write-Host '
                '
                Write-Host -f YELLOW '     UPDATE FAILED!
                '
                Start-Sleep -Seconds 3
                $Global:vf19_Z = 'GO'
                Break
            }
            elseif( $3 -eq 'MACROSS' ){  ## MACROSS will automatically download updates before starting up for the user
                Write-Host -f YELLOW "     $3 needs to update to v" -NoNewline;
                    Write-Host -f MAGENTA "$vf19_LVER" -NoNewline;
                        Write-Host -f YELLOW ". Hit ENTER to continue."
                Read-Host
                dlNew $1 $vf19_LVER
            }
            else{
                ## If the user selects a script and there is a newer version available, it automatically downloads before
                ##  executing. Make sure your updates are good before commiting them to the master repo, or everybody
                ##  gets a broken copy!
                splashPage
                Write-Host '
                '
                Write-Host -f YELLOW "     $3 v$vf19_LVER is live. Hit ENTER to update." -NoNewline;
                Read-Host

                dlNew $1 $vf19_LVER
            }
        }
    }
}
