## Read configurations based on location; local drive/share vs. remote server
function whereConfigs(){

    ########################################
    ##                    MOD SECTION
    ## If you're storing your .conf files on a web server but MACROSS can't see them,
    ## doublecheck your locations in the MACROSS.ps1 file; you can also temporarily 
    ## change "-sk" to "--verbose" below to see what errors are occuring.
    ##
    ## $vf19_CONFIG[0] - config.conf
    ## $vf19_CONFIG[1] - launch.conf
    ## $vf19_CONFIG[2] - analyst.conf
    ########################################
    $2 = New-Object System.Collections.ArrayList
    $vf19_CONFIG | %{
        if($_ -Like "http*"){ $2.Add($(curl.exe -sk -A MACROSS $_)) > $null }
        else{ $2.Add($(Get-Content $_)) > $null }
    }
    if($2[0] -ne $null){ Return $2.toArray() }
    else{ Return $false }
}


## Allow configuration set/change from the main menu
function setConfig(){
    param(
        [switch]$a = $false,
        [switch]$s = $false,
        [switch]$u = $false
    )
    
    
    if(-not $vf19_UNSPACY){
        $Global:vf19_UNSPACY = whereConfigs
        if($vf19_UNSPACY){
            <#if($vf19_UNSPACY[1] -notMatch "\w"){
                w "`n"; eMsg -m " Configuration checksums missing! Cannot load configurations." -c y
                Exit
            }
            $sigchk = [IO.MemoryStream]::New([byte[]][char[]]$($vf19_UNSPACY[0] -Join '')); slp 400 -m
            if((Get-FileHash -InputStream $sigchk -Algorithm SHA256).hash -ne $vf19_UNSPACY[1]){
                w "`n"; eMsg -m " Configuration checksums do not match! Cannot load configurations." -c y
                Exit
            }
            else{#>
                $ccfg=($vf19_UNSPACY[0]).count;$current_config = $vf19_UNSPACY[0][2..$ccfg_]
                if($vf19_UNSPACY[2]){$acfg_ = $vf19_UNSPACY[2]}
            #}
        }
    }
    if($acfg_){ $current_analyst=$true }
    $ml = setML;if($current_config){ startUp }
    $Script:list=@{};$e_=$vf19_GPOD.Item1;$f_=$vf19_GPOD.Item2;$ef_=$e_+$f_
    if($($vf19_MPOD.a2z)){getThis $vf19_MPOD.a2z -h;$Script:init=$($vf19_READ);varCleanup}
    elseif($vf19_UNSPACY[0]){$Script:init=$($vf19_UNSPACY[0][1].Substring(32))}
    getThis 'LiooKChbZ0ddW3ZWXXxbZ0ddZXQtW3ZWXWFyaWFibGUpKCB8XFxzKSsoKHZmfFZGfFZmfHZGKShb
    XHdfXSspPyk/XCopfFtvT11bZERdKFxbKCJ8Jyl8XC4pKG1hZHxNQUR8QkwwfGJsMCkoKCJ8JylcXSkqKS4q'
    $bv = $vf19_READ
    function toNext($1){
        getThis $1
        w " $vf19_READ
        " c
        slp 2
    }
    function byter($1){
        Return $([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($1)))
    }
    function setFromMem($1){
        getThis "$($ml[7] + $ml[10] + $ml[11] + $ml[12])"; getThis $vf19_READ -h
        $sfm = [scriptblock]::Create("$vf19_READ"); . $sfm
    }
    function setInMem($1){
        $csec = Read-Host "`n $1" -AsSecureString;$cplain=byter $csec
        $cmem = setFromMem $([IO.MemoryStream]::New([byte[]][char[]]$cplain))
        if($cmem -eq $Script:init){Return $e_}
    }
    function setPerms(){
        getThis $ml[5]
        if($u){$memspaces = setInMem $vf19_READ}

        function rg($k,$g){
            if($g -eq ''){ $g = 'none' }
            if($list[$k]){$Script:list.Remove($k)}
            $Script:list.Add($k,$(getThis $g -e))
        }

        if(($memspaces+$f_ -eq $ef_) -or ($memspace+$e_ -eq $ef_)){
            $z=$null; $gk = setCC
            if(! $mod ){ 
                if(! $vf19_MPOD){startUp};$vf19_MPOD.keys | Sort | %{ $Script:list.Add($_,$($vf19_MPOD[$_])) } 
            }
            if($current_analyst){
                $perma = [string]$(setReset -d "$acfg_" $gk)
            }
            $z=$null;$v=$true
            while($v){
            while($z -notIn 1..4){
                w "`n  1. View current users and Tiers`n  2. Set Tier/GPO names (requires Active-Directory)`n  3. Set a user access list" g
                w "  4. Exit" g
                w "      Select 1-4 > " g -i; $z = Read-Host
            }

            if($z -eq 4){ $v=$false;Return }
            elseif($z -eq 3){
                if($firstrun){$Script:mod=$true}
                $v=$false; setNewRole -c
                w '----------------------------------------------------------------------' c
                w ' You can provide text files with lists of usernames, but you will' c
                w ' need 1 file for each Tier you intend to create (Tiers 1-3). If you' c
                w ' do not have files, MACROSS will just use the GPO names you set up' c
                w ' during inital configuration, if any.
                ' c
                
                1..3 | %{
                    $pq = " Do you want to provide (Tier $_ of 3) files? (y/n) "
                    $z=$null; while($z -notIn @('y','n')){
                        w $pq g -i; $z = Read-Host
                    }
                    if($z -eq 'y'){
                        if( ! $fl){ $fl = @{} }
                        $uf = getFile
                        if($uf -eq ''){ Break }else{ $fl.Add("Tier$_",$uf); w " $uf" y }
                    }
                    else{ 
                        if($fl.count -eq 0 ){
                            if( ! $vf19_USERAUTH){ w "`n Then you must set GPO names first.`n" c; slp 3; setPerms}
                            else{ setNewRole }
                        }
                        Continue
                    }
                }
                if(! $fl){ setNewRole }
                else{
                    setNewRole -a $fl
                    Set-Content -Path "$tat" -Value '0_0'; Remove-Item -Path "$tat"
                    Break
                }
            }
            elseif($z -eq 2){
                $v=$false; $qn=1
                $qq = ' Enter the name of the GPO or .access Tier you want to allow'
                function qr(){w " level Tier $qn access (hit ENTER to skip): " g -i}
                function qp($1){w $qq g -i; w " $1" y -i; w '-' g; qr; Return $(Read-Host)}
                ''
                screenResults "You can add up to 6 group-policy/Tier names: one each for your tier 1-3 analysts' user and admin profiles."
                screenResults -e
                ''
                $g1 = qp USER; rg tr1 $g1
                $g2 = qp ADMIN; if($g1 -ne '' -and $g2 -ne ''){
                    rg ta1 $g2; $qn++
                    $g3 = qp USER; tr2 $g3
                    $g4 = qp ADMIN; if($g3 -ne '' -and $g4 -ne ''){
                        rg ta2 $g4; $qn++
                        $g5 = qp USER; rg tr3 $g5
                        $g6 = qp ADMIN; rg ta3 $g6
                    }
                }
				w '
				'
				w ' Tiers are configured. You will need to run the wizard again and select the "set user access"' c
				w ' list" option to complete the access control. Hit ENTER to continue.
				' c; Read-Host
                $Script:mod = $true
            }
            elseif($z -eq 1){$z=$null;setNewRole -c}
            }
        }
        else{
            toNext $ml[6]
        }
    }

    function setAuth(){
        param(
            [switch]$n=$false
        )
        function subSetAuth(){
            getThis $ml[1]
            $n1 = Read-Host "$vf19_READ" -AsSecureString;
            $n1a = byter $n1
            getThis $ml[2]
            $n2 = Read-Host "$vf19_READ" -AsSecureString;
            $n2a = byter $n2
            if($n1a -ceq $n2a){
                $nmem = setFromMem $([IO.MemoryStream]::new([byte[]][char[]]$n1a))
                if($list['a2z']){$Script:list.Remove('a2z')}
                $Script:init = $nmem; $Script:mod = $true; $Script:list.Add('a2z',$(getThis -e -h $nmem))
                if($current_analyst){
                    $ka = setCC; $kb = altBye $nmem
                    $perma = "$(setReset -d "$acfg_" $ka)"
                    $(setReset $perma $kb) | Out-File "$vf19_TOOLSROOT\analyst.conf"
                }
            }
            else{
                getThis $ml[4]
                w "$vf19_READ " w r
                w ''
                subSetAuth
            }
			
        }
        
        if($n){
            subSetAuth
        }
        else{
            $attempt = 0
            while($attempt -lt 3){
                getThis $ml[5]
                $csec = Read-Host "$vf19_READ" -AsSecureString
                $cplain = byter $csec
                $cmem = setFromMem $([IO.MemoryStream]::new([byte[]][char[]]$cplain))
                if($cplain -eq 'q'){
                    Return
                }
                elseif($cmem -ceq $init){
                    if(! $mod ){ 
                        if(! $vf19_MPOD){startUp}; $vf19_MPOD.keys | Sort | %{ $Script:list.Add($_,$($vf19_MPOD[$_])) } 
                    }
                    subSetAuth; $script:pwupd = $true
                    $attempt = 9
                }
                else{
                    $attempt++
                    getThis $ml[3]
                    w "  $vf19_READ  " r bl
                    ''
                }
            }
            if($attempt -eq 3){
                errLog 'WARN' "$USR -- $vf19_READ"
                toNext  $ml[6]
            }
        }
    }
    getThis -h $ml[14]; . $([scriptblock]::Create("$vf19_READ"))
    function setDefaultKeys($1,$2){
        getThis $ml[5]
        if($u){ w "`n`n"; $memspaces = setInMem $vf19_READ}
        if(($memspaces+$f_ -eq $ef_) -or ($memspace+$e_ -eq $ef_)){


            if($1 -eq 'update'){
                if( ! $mod ){
                    if(! $vf19_MPOD){startUp};$vf19_MPOD.keys | where {$_ -ne 'a2z'} | 
                    Sort | %{ $Script:list.Add($_,$($vf19_MPOD[$_])) }
                }
                w '
                '
                screenResults '                           CURRENT CONFIGURATION KEYS'
                screenResults -e
                $list.keys | Sort | where{$_ -ne 'a2z'} | %{
                    getThis "$($list[$_])"; $td = "$([string]$vf19_READ)"
                    w " $_`:" g -i;  w "$td" y
                    rv td
                    sep '=' 90 g
                }
                
            }

            else{
                getThis 'QWNjZXNzIENvbnRyb2xz';$99=$vf19_READ
                $required = @{'rep'=@('path to your MACROSS repository','ICAgU0VUIEEgUkVQTzogSWYgeW91IHdhbnQgdG8gdXNlIGEgY2VudHJhbCByZXBvc2l0b3J5IHRvIGF1dG8tCiAgIG1hdGljYWxseSBkaXN0cmlidXRlIHVwZGF0ZWQgc2NyaXB0cywgZW50ZXIgdGhlIHBhdGggeW91IHdhbnQKICAgdG8gdXNlIGZvciB0aGUgTUFDUk9TUyBtYXN0ZXIgcm9vdCBkaXJlY3RvcnkuIEVudGVyICJuIiB0bwogICBkaXNhYmxlLg==');
                    'bl0'=@('MACROSS debugging blacklist','ICAgU0VUIEJMQUNLTElTVDogRW50ZXIgYSByZWd1bGFyIGV4cHJlc3Npb24gdG8gcHJldmVudCBjZXJ0YWluIGNvbW1hbmRzIAogICBmcm9tIGV4ZWN1dGluZyBpbiBkZWJ1ZyBtb2RlIHdpdGhvdXQgdGhlIGFkbWluIHBhc3N3b3JkLiBBbGwgdXNlcnMgaGF2ZQogICBhY2Nlc3MgdG8gdGhlIGRlYnVnZ2VyICh0aGUgaWRlYSB0byBsZXQgYW55b25lIHdyaXRlIGF1dG9tYXRpb25zIHRoYXQKICAgdGhleSBjYW4gdGVzdCBhbmQgYWRkIHRvIE1BQ1JPU1MpLCBzbyB0aGUgYmxhY2tsaXN0IGtlZXBzIG5vbi1hZG1pbnMgZnJvbQogICBleGVjdXRpbmcgYW55dGhpbmcgeW91IGRlZW0gc2Vuc2l0aXZlLiBFbnRlciAibiIgdG8ga2VlcCB0aGUgZGVmYXVsdCAKICAgYmxhY2tsaXN0IChwcmV2ZW50cyBkZWNyeXB0aW5nIE1BQ1JPU1MgY29uZmlncyB3aXRob3V0IHRoZSBwYXNzd29yZCku');
                    'elc'=@('IP or URL of your log collection server','ICAgVGhlIGxvZ2dpbmcgZnVuY3Rpb25zIGNhbiBmb3J3YXJkIGFueSBtZXNzYWdlcyB5b3Ugc3BlY2lmeSB0byB5b3VyIAogICBsb2NhbCBsb2cgY29sbGVjdG9ycyBhcyBzeXNsb2cgZGF0YS4gRW50ZXIgdGhlIGZ1bGwgImh0dHBzOi8vLi4uIgogICBhZGRyZXNzLCBvciAnbm9uZScgdG8gc2tpcCB0aGlzIGFuZCBkaXNhYmxlIGxvZyBmb3J3YXJkaW5nLg==')
                    'enr'=@('path to MACROSS enrichment files','ICAgU0VUIENPTlRFTlQgRElSOiBZb3UgY2FuIHNwZWNpZnkgYSBsb2NhdGlvbiB3aGVyZSBjb250ZW50IG9yIGVucmljaG1lbnQgCiAgIGZpbGVzIChqc29uLCB4bWwsIGNzdiwgZXRjLikgY2FuIGJlIHJlZ3VsYXJseSBhY2Nlc3NlZCBieSBNQUNST1NTIHNjcmlwdHMuCiAgIFRoZSBkZWZhdWx0IGlzICJNQUNST1NTXHJlc291cmNlcyIu');
                    'int'=@('MACROSS mathing obfuscation','ICAgU0VUIEhJRERFTiBJTlRFR0VSOiBFbnRlciBhIG51bWJlciBiZXR3ZWVuIDEwMDAgYW5kIDk5OTk5LgogICBUaGlzIGFsbG93cyB5b3UgdG8gd3JpdGUgZXF1YXRpb25zIGluIHlvdXIgc2NyaXB0cyB3aGlsZSAKICAgbWFza2luZyB0aGUgbnVtYmVycyBieSB1c2luZyB0aGUgbGlzdCAiJE5fIi4=');
                    'log'=@('path to MACROSS logs','ICAgU0VUIExPRyBESVI6IEVudGVyIGEgbG9jYXRpb24gZm9yIE1BQ1JPU1MgdG8gd3JpdGUgbG9ncyB0by4KICAgTG9ncyBjYW4gYmUgdmlld2VkIGJ5IHR5cGluZyAiZGVidWciIGluIHRoZSBtYWluIE1BQ1JPU1MgbWVudS4KICAgRW50ZXIgIm4iIHRvIGRpc2FibGUgbG9nZ2luZy4=');
                    'tr1'=@($99,0);'tr2'=@($99,0);'tr3'=@($99,0);
                    'ta1'=@($99,0);'ta2'=@($99,0);'ta3'=@($99,0)}
                
                w "
    ** REQUIRED CONFIGURATION SETUP **
                " c
                                
                $logo64 = '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GTRokAAycuTIfXZaTU1NYVctXry4cP3444+XkSNHyXljx8nGjRsLqnG3dPbo0UP6/epX0v/QQ+XwI46Q8rIy+Xbt2kL/l19+WQAZNWpUm3EPpF166aUCyEcffVS4dv755/9bFOjCCy8UrXVBikrLygSQTz755D9aw7x582T27Nnicrlk5cqVbX5Lp9OSzWYlk8lIJpORdDotqVRKrL3U75VXXiWz58wRQGpqagq0bGlpkYaGBmloaJDGxkapr6+X+vp6qaurk7q6ujbmZs2aNfL4Y4/LAw88INx4443y008/iYjI999/X7Bjzz77nKxfv77Q6fPPP5d27doViLNly5Zcnx9+KFzb/VC2bcuf//znf0vcCZdfXhi7ublZnE6XAHLdpEkFX+CXtnXr1hXGXbNmTWENRx9zjEyZMkXWrl0ra9askTVr1sjq1atl5apV8vTTTwsgCxa8VRjnpZdeEkAmTZok6XT6gNaQTCbl3HPPleeee14Auebqaw54DBGROXPmyITLrxBApk6Z0oZxv7SlUqmC2VMzZ86UB2c8SDKVpqk5V1W0aNEiOnbsyKBBg+h90EHEowlqa6tz6NWVVzJq5EhmzJiB3+9n6RefoyXnvfr9Qeobm0lEmrHydUzPPPMMhx12WBsoTwGVlZXcdddddOzYEcMwWbp0aQE8ADj55JPxeLwoQ2EoVVDzrZGkdDpNLBbj888/zwMImv79+1NaWopt23z55ZfMmjWLdu3ace6557ZRb2+++SY1NTVcf/31jD79DFLJBNFolK9bvbF3+ulnYJpGHlzI5XEF8uiZC6dpgoKsZfHWggVMmjyZG66/nkFHHkm0Ofc/I9deey1OlwulFE6HA61zf5+USCQIhUIY+b9v0tpGRHjhry+zcOHfOeboo/Ne9vGccMLxmKaJyiNZu8GPNsV1hoFlWZimyfbt28laFpdeeim8/vrrMnLkqIIEHHX0MbJhwwY544wz9gmab7/9Dvnxxx/lqaeekjl5NQLI8BNP2i9IPmfOHFm7du1+JXj27Nly+x2373P90AEDZfpttx8w0F9aWiqvvPKKHH300W2uv/HGGzJr1qz99nnttdfaJguUkvkLFshJJ598wPOPHTdONmzYINOmTZP169fLr351yAGP0a17d3n3vXdl4TvvyJo1a8TlCfxHSY/TRoySH374QSZNniyqV69e8tjjj1NcXIxojdPpZPHixcyYMYO5c+fmgI88TKa1Zs6cObz55pvMmTOHgw8+GNu2cblcNDQ0UFJS0gYASCQSXH755W0gztbthRdeoFevXm0wX8MwsHY7ZvLL/8LL6XRSWVlJaWkpwWCwAO253W6mTZu23z8uOeecc7jxxhsLgINhGFRu2oTX56Njx45tChv+L6BF2zb/+PBDHnroIc4++2yu+e1v8Xo8v3iM3fNv3ryZyy+/nEmTJnHmmWfidrsPaIzd43yxdCl33H47/w+7b81hp3zaRgAAAABJRU5ErkJggg=='
                $logod = [Convert]::FromBase64String($logo64)
                Add-Type -AssemblyName System.Windows.Forms
                [System.Windows.Forms.Application]::EnableVisualStyles()

                $cfgwiz = New-Object System.Windows.Forms.Form
                $logo = New-Object Windows.Forms.PictureBox

                $cfgwiz.Text = "MACROSS Configuration Wizard"
                $cfgwiz.Font = [System.Drawing.Font]::new("Tahoma", 10.5)
                $cfgwiz.ForeColor = 'WHITE'
                $cfgwiz.Size = New-Object System.Drawing.Size(810,400)
                $cfgwiz.BackColor = 'BLACK'
                $cfgwiz.StartPosition = "CenterScreen"

                $logo.Width = 120
                $logo.Height = 72 
                $logo.Location = New-Object System.Drawing.Point(10,2)
                $logo.Image = $logod
                $cfgwiz.Controls.Add($logo)

                $info = New-Object System.Windows.Forms.Label
                $info.Location = New-Object System.Drawing.Point(135,5)
                $info.ForeColor = 'yellow'
                $info.Size = New-Object System.Drawing.Size(900,35)
                $info.Font = [System.Drawing.Font]::new("Consolas",9)
                $info.Text = "INITIAL RUN: You must create a pair of config.conf and launch.conf files and place them in:`n $($vf19_CONFIG[0] -replace "\\\w+\.conf$")"
                $cfgwiz.Controls.Add($info)

                $mandated = New-Object System.Windows.Forms.Label
                $mandated.Location = New-Object System.Drawing.Point(10,73)
                $mandated.Size = New-Object System.Drawing.Size(800,35)
                $mandated.Font = [System.Drawing.Font]::new("Consolas",10)
                $mandated.Text = "These values are all REQUIRED. You may change the defaults or keep them, but they cannot be empty!"
                $cfgwiz.Controls.Add($mandated)

                $labelrepo = New-Object System.Windows.Forms.Label
                $labelrepo.Location = New-Object System.Drawing.Point(10,105)
                $labelrepo.Size = New-Object System.Drawing.Size(175,15)
                $labelrepo.Font = [System.Drawing.Font]::new("Consolas",10)
                $labelrepo.ForeColor = 'CYAN'
                $labelrepo.Text = "Master Repository:"
                $cfgwiz.Controls.Add($labelrepo)

                $keyrepo = New-Object System.Windows.Forms.TextBox
                $keyrepo.Location = New-Object System.Drawing.Point(200,105)
                $keyrepo.Size = New-Object System.Drawing.Size(530,20)
                $keyrepo.Font = [System.Drawing.Font]::new("Consolas",11)
                $keyrepo.Text = 'None'
                $cfgwiz.Controls.Add($keyrepo)

                $labelblacklist = New-Object System.Windows.Forms.Label
                $labelblacklist.Location = New-Object System.Drawing.Point(10,135)
                $labelblacklist.Size = New-Object System.Drawing.Size(175,15)
                $labelblacklist.Font = [System.Drawing.Font]::new("Consolas",10)
                $labelblacklist.ForeColor = 'CYAN'
                $labelblacklist.Text = "Debugging blacklist:"
                $cfgwiz.Controls.Add($labelblacklist)

                $keyblacklist = New-Object System.Windows.Forms.TextBox
                $keyblacklist.Location = New-Object System.Drawing.Point(200,135)
                $keyblacklist.Size = New-Object System.Drawing.Size(530,20)
                $keyblacklist.Font = [System.Drawing.Font]::new("Consolas",11)
                $keyblacklist.Text = "$bv"
                $cfgwiz.Controls.Add($keyblacklist)

                $labellogc = New-Object System.Windows.Forms.Label
                $labellogc.Location = New-Object System.Drawing.Point(10,165)
                $labellogc.Size = New-Object System.Drawing.Size(190,15)
                $labellogc.Font = [System.Drawing.Font]::new("Consolas",10)
                $labellogc.ForeColor = 'CYAN'
                $labellogc.Text = "Log Server (host:port):"
                $cfgwiz.Controls.Add($labellogc)

                $keylogc = New-Object System.Windows.Forms.TextBox
                $keylogc.Location = New-Object System.Drawing.Point(200,165)
                $keylogc.Size = New-Object System.Drawing.Size(530,20)
                $keylogc.Font = [System.Drawing.Font]::new("Consolas",11)
                $keylogc.Text = 'None'
                $cfgwiz.Controls.Add($keylogc)

                $labelint = New-Object System.Windows.Forms.Label
                $labelint.Location = New-Object System.Drawing.Point(10,195)
                $labelint.Size = New-Object System.Drawing.Size(190,15)
                $labelint.Font = [System.Drawing.Font]::new("Consolas",10)
                $labelint.ForeColor = 'CYAN'
                $labelint.Text = "Mathing Obfuscation Key:"
                $cfgwiz.Controls.Add($labelint)

                $keyint = New-Object System.Windows.Forms.TextBox
                $keyint.Location = New-Object System.Drawing.Point(200,195)
                $keyint.Size = New-Object System.Drawing.Size(530,20)
                $keyint.Font = [System.Drawing.Font]::new("Consolas",11)
                $keyint.Text = 1111
                $cfgwiz.Controls.Add($keyint)

                $labelenr = New-Object System.Windows.Forms.Label
                $labelenr.Location = New-Object System.Drawing.Point(10,225)
                $labelenr.Size = New-Object System.Drawing.Size(175,15)
                $labelenr.Font = [System.Drawing.Font]::new("Consolas",10)
                $labelenr.ForeColor = 'CYAN'
                $labelenr.Text = "Enrichments Folder:"
                $cfgwiz.Controls.Add($labelenr)

                $keyenr = New-Object System.Windows.Forms.TextBox
                $keyenr.Location = New-Object System.Drawing.Point(200,225)
                $keyenr.Size = New-Object System.Drawing.Size(530,20)
                $keyenr.Font = [System.Drawing.Font]::new("Consolas",11)
                $keyenr.Text = "$vf19_TOOLSROOT\resources"
                $cfgwiz.Controls.Add($keyenr)

                $labellogs = New-Object System.Windows.Forms.Label
                $labellogs.Location = New-Object System.Drawing.Point(10,255)
                $labellogs.Size = New-Object System.Drawing.Size(175,15)
                $labellogs.Font = [System.Drawing.Font]::new("Consolas",10)
                $labellogs.ForeColor = 'CYAN'
                $labellogs.Text = "Location for logs:"
                $cfgwiz.Controls.Add($labellogs)

                $keylogs = New-Object System.Windows.Forms.TextBox
                $keylogs.Location = New-Object System.Drawing.Point(200,255)
                $keylogs.Size = New-Object System.Drawing.Size(530,20)
                $keylogs.Font = [System.Drawing.Font]::new("Consolas",11)
                $keylogs.Text = "$vf19_TOOLSROOT\resources\logs"
                $cfgwiz.Controls.Add($keylogs)

                $confirm = New-Object System.Windows.Forms.Button
                $confirm.Location = New-Object System.Drawing.Point(275,310)
                $confirm.Size = New-Object System.Drawing.Size(250,30)
                $confirm.ForeColor = 'YELLOW'
                $confirm.BackColor = 'BLUE'
                $confirm.Text = 'CONFIRM SETTINGS'
                $confirm.Add_Click({
                    ## For log server/SEIM, the errLog function needs the IP/hostname WITHOUT any protocol prefix
                    if($keylogc.Text -Like "http*"){
                        $keylogc.Text = ($keylogc.Text) -replace "http[s]*://"
                    }
                    $Script:clicked = $true
                    $Script:list.Add('rep',$(getThis -e $keyrepo.Text))
                    $Script:list.Add('int',$(getThis -e $keyint.Text))
                    $Script:list.Add('log',$(getThis -e $keylogs.Text))
                    $Script:list.Add('elc',$(getThis -e $keylogc.Text))
                    $Script:list.Add('enr',$(getThis -e $keyenr.Text))
                    $Script:list.Add('bl0',$(getThis -e $keyblacklist.Text))
                    $cfgwiz.Close()
                })
                $cfgwiz.Controls.Add($confirm)
                $a = $cfgwiz.ShowDialog()

            }
            if(-not $clicked){Exit}else{rv clicked -Scope Script}
            $z = $null
            while(-not $fin){
                while($z -notMatch "^[yn]$"){
                    w '

  Do you need to add or change any default configs? (y/n) ' g -i; $z = Read-Host
                }
                if($z -Like "n*"){ Break }
                $k = $null
                while($k -notMatch "^\w{3}$"){
                    w ' Enter a three-character key ("c" to cancel): ' g -i; $k = Read-Host
                    if($k -eq 'c'){$fin = $true; $k = 'XQX'}
                    elseif($k -ceq 'XQX'){
                        w ' Sorry, that key is reserved.' c; ''
                    }
                    if($k -in @('0a1','a2z')){
                        $k = 'XQX'; w "
    That is a reserved key, you need to choose another." c
                    }
                    elseif($k -in $required.keys){
                        w "
    WARNING! That is a reserved key for MACROSS ($($required[$k][0])), are you sure you 
    want to overwrite it? (y/n) " c -i; $z = Read-Host
                        if($z -ne 'y'){ $k = 'XQX'; '' }
                        else{ $Script:list.Remove($k) }
                    }
                    elseif($k -in $vf19_MPOD.keys){
                        while($z -notMatch "^[nod]$"){
                        getThis $($vf19_MPOD[$k])
                        w "
    WARNING! That key is already in use as 
    
    `"$vf19_READ`", 
    
    do you want to (d)elete or (o)verwrite it? ('n' for 'no') " c -i; $z = Read-Host
                        if($z -eq 'n'){ $k = $null; '' }
                        else{
                            $Script:list.Remove($k)
                            $Script:mod = $true
                            if($z -eq 'd'){ $k = 'XQX' }
                        }}
                    }
                }
                if($k -cne 'XQX'){
                    w '     Enter a value for that key or "c" to cancel:' y; $v = Read-Host " >"
                    if($v -ne 'c'){$Script:list.Add($k,"$(getThis $v -e)");$Script:mod=$true;w "`n"}
                }
                
            }
        }
        else{
            toNext $ml[6]
        }
    }

    function options(){
        splashPage
        getThis 'ICAgICAgICAgICAgICAgICAgICAgICAgICAgIE1BQ1JP
        U1MgQ09ORklHIE1FTlUgICAgICAgICAgICAgICAgICAgICAgICAgICA='
        w '
        '
        sep '>' 79 g
        w ' >> ' g -i 
        w $vf19_READ c -i
        w '>>' g
        sep '>' 79 g
        getThis 'ID4+ICAxLiBSZXZpZXcvdXBkYXRlIGNvbmZpZyBkZWZhdWx0cyAgICAgICAgICAgICAgICAgICAgI
        CAgICAgICAgICAgICAgICAgICAgPj4KID4+ICAyLiBVcGRhdGUgYWRtaW4gcGFzc3dvcmQgICAgICAgICAgICA
        gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPj4KID4+ICAzLiBSZXZpZXcvdXBkYXRlIHVzZ
        XJsaXN0IG9yIEdQTy1iYXNlZCBwZXJtaXNzaW9ucyAgICAgICAgICAgICAgICAgICAgICAgPj4KID4+ICA0LiB
        GaW5pc2hlZCAoZ2VuZXJhdGVzIG5ldyBjb25maWcgaWYgY2hhbmdlcyB3ZXJlIG1hZGUsIG90aGVyd2lzZSBle
        Gl0cykgPj4='
        w $vf19_READ g
        sep '>' 79 g
        w "`n>>     SELECT AN OPTION 1-4: " g -i; Return $(Read-Host)
    }

    
    if($Global:vf19_UNSPACY[0][0] -notLike "*MACROSS*"){
        if(! $s){ cls }
        $memspace = $f_
        $firstrun = $true
        transitionSplash 0 #$(Get-Random -Minimum 0 -Maximum 11)
        w "`n"
        screenResults 'm~                               MACROSS INITIAL SETUP'
        screenResults -e
        w "`n`n"
        setAuth -n
        setDefaultKeys
		$z=$null
        $p = $(getThis unused -e); $Script:list.Add('tr1',"$p"); $Script:list.Add('ta1',"$p"); rv p
		$Script:mod=$true
    }
    if($a){
        startUp
        getThis $ml[5]
        Return $(setInMem $vf19_READ)
    }
    elseif($u){
        startUp
        while($z -ne 4){
            $clicked = $true; $z = options
            if($z -eq 1){setDefaultKeys 'update'}
            elseif($z -eq 2){setAuth}#{" Sorry, this option is disabled (needs fixing)"} #{setAuth} ## Config breaks when changing pass; need to fix
            elseif($z -eq 3){setPerms}
        }
    }
	
    if($mod){
        if($perma){
            $(setReset $perma $(setCC)) | Out-File "$vf19_TOOLSROOT\analyst.conf" -NoNewline
        }
        if($list.count -gt 0){
            $updated = @(); getThis QEBA; $dl = $vf19_READ
            if($vf19_MPOD.count -gt 0){
                $list.keys | Sort | where{$_ -ne 'a2z'} | %{
                    if($_ -notIn $vf19_MPOD.keys){$updated += $_}
                    elseif($list[$_] -ne $vf19_MPOD[$_]){$updated += $_}
                }
                $vf19_MPOD.keys | Sort | where{$_ -ne 'a2z'} | %{
                    if($_ -notIn $list.keys){$updated += $_}
                }
                $updated | Sort | %{
                    if($vf19_MPOD[$_]){getThis $vf19_MPOD[$_]; $old = $vf19_READ}else{$old='None'}
                    getThis $list[$_]; $new = $vf19_READ
                    screenResultsAlt -h "KEY: $_" -k 'OLD VALUE' -v $old 
                    screenResultsAlt -k 'NEW VALUE' -v $new
                }
                if($pwupd){getThis $ml[9]; screenResultsAlt -k 'NEW PWD' -v "c~$vf19_READ"}
                screenResultsAlt -e
                ''
                $z = $null; while($z -notMatch "(a|c)"){
                    w ' Review your changes above, and Enter "a" to accept or "c" to cancel: ' g -i; $z = Read-Host
                }
            }else{$z = 'a'}

            if($z -eq 'a'){
            $Script:init | Out-File "$vf19_TMP\macross_cfg.temp"
            $i = $list.count; $list.keys | Sort | %{ 
                $nk = $_; $i = $i - 1
                if($nk -Match "\w"){
                    $conf = "$nk" + "$($list[$nk])"; if($i -gt 0){$conf = $conf + "$dl"}
                    $conf | Out-File "$vf19_TMP\macross_cfg.temp" -Append -NoNewLine
                }
            }}
            else{ rv -Force init,list,mod -Scope Script }
            
        }
    }
    else{ Return }

    Remove-Variable init,list,mod -Scope Script

    if(Test-Path -Path "$vf19_TMP\macross_cfg.temp"){
        getThis QEBA; $dl = $vf19_READ
        $write = Get-Content "$vf19_TMP\macross_cfg.temp"
        $of = "$vf19_TOOLSROOT\config.conf"; $ol = ''
        '   ############  MACROSS CONFIG: DO NOT MODIFY  ############' | Out-File $of
        if($write[0].length -eq 64){ $np = $($write[0]) }
        elseif(Select-String -Pattern "($("$dl")a2z|^a2z)" "$vf19_TMP\macross_cfg.temp"){
            $np = $(Get-Content -raw "$vf19_TMP\macross_cfg.temp" -replace "^.$("$dl" + 'a2z')" -replace "$("$dl").+")
        }
        else{ getThis $vf19_MPOD.a2z -h; $np = $vf19_READ }
        $kk = altByte $np $d9[0] $d9[1]
        $("$((1..32 | %{$(Get-Random -min 0 -max 9)}) -Join '')" + "$np" ) | Out-File $of -Append
        setBlocks "$($write[1])" $kk 'config.conf'
        Remove-Item -Path "$vf19_TMP\macross_cfg.temp" -Force
        $sigwrt = [IO.MemoryStream]::New([byte[]][char[]]$((gc $of) -Join '')); slp 400 -m
        ((Get-FileHash -InputStream $sigwrt -Algorithm SHA256).hash).toUpper() | Out-File "$vf19_TOOLSROOT\launch.conf"
        #(getHash $of sha256).toUpper() | Out-File "$vf19_TOOLSROOT\launch.conf"

        sep '=' 72 g; sep '=' 72 g

        if((Get-Content $of) -Match "\d$"){
            ''
            w ' Your new configuration files have been created here:' g
            w " $of`n $($of -replace "config\.c","launch.c")"
            if(Test-Path "$TOOLSROOT\analyst.conf"){
                w " $TOOLSROOT\analyst.conf"
            }
            ''
            w ' Your default configuration folder is:' g
            w " $($vf19_CONFIG[0] -replace ".config\.conf$")"
            if($firstrun){
                w "
 You need to place the new configuration files there.
 
 If you specified GPO or Tier-level permission groups, enter `"config`" in the 
 MACROSS menu and select the `"Set user access...`" option. This will let you set 
 your user permissions by generating an analyst.conf file that needs to be placed 
 in the same location as config.conf. If you used text files to set users, an
 analyst.conf file should already be generated. If you did neither of these things,
 MACROSS won't care who executes what.
 
 It is recommended that you store these configuration files in a central, access-
 controlled location so that they are not downloaded with every copy of MACROSS.
 You can modify the location by changing the `$vf19_CONFIG values in the MACROSS.ps1 
 file.

 To view MACROSS' utility help files and run test commands, type `"debug`" in the
 main menu. You can view the decrypted configurations you just set by using
 " g
            w ' getThis $vf19_MPOD["key"]; $vf19_READ' y
            w "
 where `"key`" is the three-character ID you created for that value.
 
 Hit ENTER to exit.
 " g
            }
            else{
            w "
 You need to place the new .conf files there.
 
 NOTE: if you changed your admin password and backed up your old config files, 
 they are encrypted with your *old* password and cannot be modified with your 
 new password!

 Hit ENTER to exit.
 " g
            }
            varCleanup -c
            Read-Host
            Exit
        }
        else{
            $e = 'Failed to write new configurations!'
            eMsg $e -c r
            errLog ERROR "$USR -- $e"
        }
    }
}
function setCC([switch]$c=$false,[switch]$b=$false){
    if(! $Global:vf19_UNSPACY){$Global:vf19_UNSPACY=whereConfigs}
    $sigchk = [IO.MemoryStream]::New([byte[]][char[]]$($vf19_UNSPACY[0] -Join '')); slp 400 -m
    if((Get-FileHash -InputStream $sigchk -Algorithm SHA256).hash -ne $vf19_UNSPACY[1]){
        w "`n"
        eMsg -m " Configuration checksum mismatched or null! Cannot load configurations." -c y; Exit
    }
    if($b){startUp;getThis $vf19_MPOD.bl0
    rv -Force vf19_MPOD,vf19_PYPOD -Scope Global;Return $vf19_READ}
    $cc=$vf19_UNSPACY[0][1].Substring(32)
    if($c){Return @($vf19_UNSPACY[0][2..$vf19_UNSPACY[0].count] -Join '')}
    else{Return $(altByte $cc $d9[0] $d9[1])}
}
function setBlocks($1,$2,$3){
    $di=0;$en=setReset "$1" $2;$de="$en".length;$f="$vf19_TOOLSROOT\$3"
    while($di -le $de){
        if($di+95 -ge $de){ $($en[$di..$($di+95)] -Join '') -replace "\D$" | Out-File $f -Append; Break }
        else{ $($en[$di..$($di+95)] -Join '') | Out-File $f -Append; $di=$di+96 }
    }
}
function setML($1){
    if($1 -eq 1){ getThis -h 5B696E745D245F202D62786F7220246E }
    elseif($1 -eq 2){ getThis -h 24785B24695D202D62786F7220246E }
    else{
    Return @('IEVudGVyIHRoZSBjdXJyZW50IE1BQ1JPU1MgYWRtaW4gcGFzc3dvcmQsIG9yICJxIiB0byBxdWl0','RW50ZXIgYSBuZXcgTUFDUk9TUyBhZG1pbiBwYXNzd29yZA==',
    'ICAgICAgRW50ZXIgdGhlIG5ldyBwYXNzd29yZCBhZ2Fpbg==','SU5DT1JSRUNUIE1BQ1JPU1MgQURNSU4gUEFTU1dPUkQ=','UGFzc3dvcmRzIGRvIG5vdCBtYXRjaCE=',
    'IEVudGVyIHRoZSBjdXJyZW50IE1BQ1JPU1MgYWRtaW4gcGFzc3dvcmQsIG9yICJxIiB0byBxdWl0','IFBlcm1pc3Npb24gZGVuaWVkLg==',
    'NTI2NTc0NzU3MjZlMjAyNDI4Mjg0NzY1NzQyZDQ2Njk2YzY1NDg2MTczNjgyMDJkNDk2ZTcwNzU3ND','UGFzc3dvcmQgaXMgdG9vIHNob3J0IQ==',
    'WW91ciBhZG1pbiBwYXNzd29yZCB3YXMgdXBkYXRlZA==','UzNzQ3MjY1NjE2ZDIwMjQzMTIwMmQ0MTZjNjc2ZjcyNjk3NDY4NmQyMDUzNDg0MTMyMzUzNjI5MmU2',
    'ODYxNzM2ODIwMmQ3MjY1NzA2YzYxNjM2NTIwMjc0NjI3MmMyNzQyMjcyMDJkNzI2NTcwNmM2MTYzNj',
    'UyMDI3MzEyNzJjMjc0NjI3MjAyZDcyNjU3MDZjNjE2MzY1MjAyNzMzMjcyYzI3MzEyNzI5',
    'WW91ciBwYXNzd29yZCBtdXN0IGJlIGEgbWluaW11bSBvZiAxOCBjaGFyYWN0ZXJzIHdpdGggYXQgbGVhc3Qg',
    '24476C6F62616C3A64393D402824286F7264206027292C24286F726420602D2929')
    }
}
function setNewRole($file,$role,$array,[switch]$c=$false){
    function gg($1){
        $a = (Get-ADGroup -filter "Name -eq '$1'" -properties Members | 
        Select -ExpandProperty Members) -replace ",OU=.+" -replace "CN=" | %{
            $n = $_ -replace "\\,",','
            Get-ADUser -filter "displayName -eq '$n' -or Name -eq '$n'" | 
            Select samAccountName
        } | Select -ExpandProperty samAccountName | Sort -u
        Return $a
    }
    $gj = setCC
    if($vf19_CONFIG[2] -Like "http*"){$ga=((curl.exe -sk -A MACROSS $vf19_CONFIG[2]) -Join '')}
    else{$ga=(gc $vf19_CONFIG[2]) -Join ''}
    if($c -and $ga){
        $current = $((setReset -d $ga $gj) | ConvertFrom-Json)
        $i=0; w '    CURRENT TIER 1:' g; $current.Tier1 | %{if($i -le 5){w "$_," -i; $i++}else{w "$_,"; $i = 0}}
        ''
        $i=0; w "`n    CURRENT TIER 2:" g; $current.Tier2 | %{if($i -le 5){w "$_," -i; $i++}else{w "$_,"; $i = 0}}
        ''
        $i=0; w "`n    CURRENT TIER 3:" g; $current.Tier3 | %{if($i -le 5){w "$_," -i; $i++}else{w "$_,"; $i = 0}}
        w '
        '; Return
    }
    elseif($c){ w ' NOTICE: ' r bl -i; w 'Could not find any analyst.conf file.' c bl; Return}
    if($array){
        $json = New-Object System.Collections.Generic.List[string]
        $json.Add('{'); foreach($tk in $array.keys | Sort){
            $json.Add("`"$tk`": [")
            gc $array[$tk] | %{
                $json.Add("`"$_`",")
            }
            $json.Add("],")
        }
        $json.Add("}"); $json = ($json -Join '').toString()
        $json = $json -replace ",]",']' -replace ",}",'}'
    }
    elseif($file -and $role){
        $at="$vf19_TMP\analyst.temp"
        if(Test-Path $at){$c="$(gc -raw $at);"}else{$c = ''}
        $c += "$($role+'='+$((gc $file) -Join ','))"
        Set-Content -Path $at "$c" -NoNewline
        Return
    }
    elseif( $vf19_ROBOTECH ){
        w ' You must be admin to perform this action.
        ' c
    }
    else{
        if(! $json){ $Script:json = New-Object System.String }
        if($vf19_MPOD.tr3){ getThis $vf19_MPOD.tr3;$tier3=$vf19_READ }
        if($vf19_MPOD.tr2){ getThis $vf19_MPOD.tr2;$tier2=$vf19_READ }
        if($vf19_MPOD.tr1){ getThis $vf19_MPOD.tr1;$tier1=$vf19_READ }
        if($vf19_MPOD.ta3){ getThis $vf19_MPOD.ta3;$admin3=$vf19_READ }
        if($vf19_MPOD.ta2){ getThis $vf19_MPOD.ta2;$admin2=$vf19_READ }
        if($vf19_MPOD.ta1){ getThis $vf19_MPOD.ta1;$admin1=$vf19_READ }
        if($tier1){
            $Script:json += '{"Tier1": ['
            gg $tier1 | %{ $Script:json += $('"' + $_ + '",') }
            if($admin1){
                gg $admin1 | %{ $Script:json += $('"' + $_ + '",') }
            }
            $Script:json = $json -replace ",$",']'
        }
        if($tier2){
            $Script:json += ',"Tier2": ['
            gg $tier2 | %{ $Script:json += $('"' + $_ + '",') }
            if($admin2){
                gg $admin2 | %{ $Script:json += $('"' + $_ + '",') }
            }
            $Script:json = $json -replace ",$",']'
        }
        if($tier3){
            $Script:json += ',"Tier3": ['
            gg $tier3 | %{ $Script:json += $('"' + $_ + '",') }
            if($admin3){
                gg $admin3 | %{ $Script:json += $('"' + $_ + '",') }
            }
            $Script:json = $json -replace ",$",']'
        }
        if($json){
            $Script:json += '}'
        }
        
    }
    if($json){
        setBlocks "$json" $gj 'analyst.conf'
        slp 2; if(Test-Path "$vf19_TOOLSROOT\analyst.conf"){
            w "`n`n"
            w ' A new analyst.conf was created. You need to move it from your MACROSS' y
            w ' folder to the same location as the config.conf file.
            ' y
            w ' Hit ENTER to continue.
            ' y; Read-Host
        }
    }

}
