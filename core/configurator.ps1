## Allow configuration set/change from the main menu
function setConfig(){
    param(
        [switch]$a = $false,
        [switch]$s = $false,
        [switch]$u = $false
    )
    $ccfg_ = Test-Path "$($vf19_CONFIG[0])"
    if($ccfg_){if($(gethash $vf19_CONFIG[0] sha256 | Select -Index 1) -eq $(gc $vf19_CONFIG[1])){$current_config=$ccfg_}}
    $current_analyst = Test-Path "$($vf19_CONFIG[2])"
    $ml = setML;if($current_config){ startUp }
    $Script:list=@{};$e_=$vf19_GPOD.Item1;$f_=$vf19_GPOD.Item2;$ef_=$e_+$f_
    if($($vf19_MPOD['mad'])){getThis $vf19_MPOD['mad'] -h;$Script:init=$($vf19_READ);varCleanup}
    elseif($current_config){$Script:init=$((gc "$($vf19_CONFIG[0])")[0..63] -Join(''))}
    getThis 'LiooKChbZ0ddW3ZWXXxbZ0ddZXQtW3ZWXWFyaWFibGUpKCB8XFxzKSsoKHZmfFZG
    fFZmfHZGKShbXHdfXSspPyk/XCopfFtvT11bZERdXFsnKG1hZHxNQUR8QkwwfGJsMCknXF0pLio='
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
        $csec = Read-Host "`n $1" -AsSecureString; $cplain = byter $csec
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
                $perma = [string]$(setReset -d "$(gc $($vf19_CONFIG[2]))" $gk)
            }
            $z=$null;$v=$true
            while($v){
            while($z -notIn 1..4){
                w "`n  1. View current Tier lists`n  2. Set GPO/Tier access list`n  3. Set a user access list" g
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
                    $z=$null; while($z -notMatch "^[yn]$"){
                        w " Do you want to provide (Tier $_ of 3) files? (y/n) " g -i; $z = Read-Host
                    }
                    if($z -eq 'y'){
                        if( ! $fl){ $fl = @{} }
                        $uf = getFile
                        if($uf -eq ''){ Break }else{ $fl.Add("Tier$_",$uf) }
                    }
                    else{ 
                        if(! $fl ){
                            if( ! $vf19_USERAUTH){ w "`n Then you must set GPO names first.`n" c; slp 3; setPerms}
                            else{ setNewRole }
                        }
                        Break
                    }
                }
                if($fl){
                    $fl.keys | Sort | %{ setNewRole -f $fl[$_] -r $_ }
                    Set-Content -Path "$vf19_TMP\analyst.tmp" -Value '0_0'; Remove-Item -Path "$vf19_TMP\analyst.tmp"
                    if(Test-Path "$vf19_TOOLSROOT\analyst.conf"){
                        w "`n You need to move the file analyst.conf from your MACROSS folder to the same" c
                        w " location as the config.conf file. Hit ENTER to continue.`n" c; Read-Host
                    }
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
                if($list['mad']){$Script:list.Remove('mad')}
                $Script:init = $nmem; $Script:mod = $true; $Script:list.Add('mad',$(getThis -e -h $nmem))
                if($current_analyst){
                    $ka = setCC; $kb = altBye $nmem
                    $perma = "$(setReset -d "$($vf19_CONFIG[2])" $ka)"
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
                    if(! $vf19_MPOD){startUp};$vf19_MPOD.keys | where {$_ -ne 'mad'} | 
                    Sort | %{ $Script:list.Add($_,$($vf19_MPOD[$_])) }
                }
                w '
                '
                screenResults '                           CURRENT CONFIGURATION KEYS'
                screenResults -e
                $list.keys | Sort | where{$_ -ne 'mad'} | %{
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
                    'enr'=@('path to MACROSS enrichment files','ICAgU0VUIENPTlRFTlQgRElSOiBZb3UgY2FuIHNwZWNpZnkgYSBsb2NhdGlvbiB3aGVyZSBjb250ZW50IG9yIGVucmljaG1lbnQgCiAgIGZpbGVzIChqc29uLCB4bWwsIGNzdiwgZXRjLikgY2FuIGJlIHJlZ3VsYXJseSBhY2Nlc3NlZCBieSBNQUNST1NTIHNjcmlwdHMuCiAgIFRoZSBkZWZhdWx0IGlzICJNQUNST1NTXHJlc291cmNlcyIu');
                    'int'=@('SKYNET mathing obfuscation','ICAgU0VUIEhJRERFTiBJTlRFR0VSOiBFbnRlciBhIG51bWJlciBiZXR3ZWVuIDEwMDAgYW5kIDk5OTk5LgogICBUaGlzIGFsbG93cyB5b3UgdG8gd3JpdGUgZXF1YXRpb25zIGluIHlvdXIgc2NyaXB0cyB3aGlsZSAKICAgbWFza2luZyB0aGUgbnVtYmVycyBieSB1c2luZyB0aGUgbGlzdCAiJE5fIi4=');
                    'log'=@('path to MACROSS logs','ICAgU0VUIExPRyBESVI6IEVudGVyIGEgbG9jYXRpb24gZm9yIE1BQ1JPU1MgdG8gd3JpdGUgbG9ncyB0by4KICAgTG9ncyBjYW4gYmUgdmlld2VkIGJ5IHR5cGluZyAiZGVidWciIGluIHRoZSBtYWluIE1BQ1JPU1MgbWVudS4KICAgRW50ZXIgIm4iIHRvIGRpc2FibGUgbG9nZ2luZy4=');
                    'tr1'=@($99,0);'tr2'=@($99,0);'tr3'=@($99,0);
                    'ta1'=@($99,0);'ta2'=@($99,0);'ta3'=@($99,0)}
                
                w "
    ** REQUIRED CONFIGURATION SETUP **
                " c
                foreach($r in ($required.keys | Sort)){
                    if($r -notLike "t*"){
                        getThis $required[$r][1]; w $vf19_READ c
                        ''
                        w " Please enter a default value for the " g -i
                        w "$($required[$r][0])" y
                        w " or `"n`"" g -i
                        w " to keep the default: " g -i; $z = Read-Host
                        ## The python integration will break if there is no 'int' key:
                        if($r -eq 'rep' -and $z -eq 'n'){ w ' Central repo will not be used.' c }
                        if($r -eq 'int' -and $z -eq 'n'){ w ' Default number "1111" has been set.' c; $z = 1111 }
                        if($r -eq 'enr' -and $z -eq 'n'){
                            $z = "$vf19_TOOLSROOT\resources"; w " Default has been set to $z" c
                        }
                        if($r -eq 'log' -and $z -eq 'n'){
                            $z = "$vf19_TOOLSROOT\resources\logs"; w " Default has been set to $z" c
                        }
                        ## Debugging will break if you leave 'bl0' empty
                        if($r -eq 'bl0' -and $z -eq 'n'){ w ' Default blacklist has been set.' c; $z = "$bv" }
                        $Script:list.Add($r,"$(getThis $z -e)")
                        w '
                        '
                        $Script:mod = $true
                    }
                }
            }
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
                    if($k -in @('0a1','mad')){
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
                    w ' Enter a value for that key or "c" to cancel: ' y -i; $v = Read-Host
                    if($v -ne 'c'){$Script:list.Add($k,"$(getThis $v -e)");$Script:mod=$true}
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
        sep '>' 79 'g'
        w ' >> ' 'g' -i 
        w $vf19_READ 'c' -i
        w '>>' 'g'
        sep '>' 79 'g'
        getThis 'ID4+ICAxLiBSZXZpZXcvdXBkYXRlIGNvbmZpZyBkZWZhdWx0cyAgICAgICAgICAgICAgICAgICAgI
        CAgICAgICAgICAgICAgICAgICAgPj4KID4+ICAyLiBVcGRhdGUgYWRtaW4gcGFzc3dvcmQgICAgICAgICAgICA
        gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPj4KID4+ICAzLiBSZXZpZXcvdXBkYXRlIHVzZ
        XJsaXN0IG9yIEdQTy1iYXNlZCBwZXJtaXNzaW9ucyAgICAgICAgICAgICAgICAgICAgICAgPj4KID4+ICA0LiB
        GaW5pc2hlZCAoZ2VuZXJhdGVzIG5ldyBjb25maWcgaWYgY2hhbmdlcyB3ZXJlIG1hZGUsIG90aGVyd2lzZSBle
        Gl0cykgPj4='
        w $vf19_READ 'g'
        sep '>' 79 'g'
        w ''
        w '>>     SELECT AN OPTION 1-4: ' g -i; Return $(Read-Host)
    }

    
    if(! $current_config){
        if(! $s){ cls }
        $memspace = $f_
        $firstrun = $true
        transitionSplash $(Get-Random -Minimum 0 -Maximum 11)
        w '
        '
        screenResults 'm~                               MACROSS INITIAL SETUP'
        screenResults -e
        w '
        
        '
        setAuth -n
        setDefaultKeys
		$z=$null; while($z -notMatch "^[yn]$"){
        	w "`n  Do you want to set a userlist/role-based access? (y/n) " g -i; $z = Read-Host
		}
        if($z -eq 'y'){ setPerms }
		else{$p = $(getThis none -e); $Script:list.Add('tr1',$p); $Script:list.Add('ta1',$p); rv p }
		$Script:mod=$true
    }
    elseif($a){
        startUp
        getThis $ml[5]
        Return $(setInMem $vf19_READ)
    }
    elseif($u){
        startUp
        while($z -ne 4){
            $z = options
            if($z -eq 1){setDefaultKeys 'update'}
            elseif($z -eq 2){setAuth}
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
                $list.keys | Sort | where{$_ -ne 'mad'} | %{
                    if($_ -notIn $vf19_MPOD.keys){$updated += $_}
                    elseif($list[$_] -ne $vf19_MPOD[$_]){$updated += $_}
                }
                $vf19_MPOD.keys | Sort | where{$_ -ne 'mad'} | %{
                    if($_ -notIn $list.keys){$updated += $_}
                }
                screenResults 'KEY' 'OLD VALUE' 'NEW VALUE'
                $updated | Sort | %{
                    if($vf19_MPOD[$_]){getThis $vf19_MPOD[$_]; $old = $vf19_READ}else{$old='None'}
                    getThis $list[$_]; $new = $vf19_READ
                    screenResultsAlt -h "KEY: $_" -k "OLD" -v $old
                    screenResultsAlt -k "NEW" -v $new
                }
                if($pwupd){getThis $ml[9]; screenResults "c~   $vf19_READ"}
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
        if($write[0].length -eq 64){
            $np = $($write[0])
        }
        elseif(Select-String -Pattern "($("$dl")mad|^mad)" "$vf19_TMP\macross_cfg.temp"){
            $np = $(Get-Content "$vf19_TMP\macross_cfg.temp" -replace "^.$("$dl" + 'mad')" -replace "$("$dl").+")
        }
        else{
            getThis $vf19_MPOD['mad'] -h; $np = $vf19_READ
        }
        $kk = altByte $np $d9[0] $d9[1]
        $np | Out-File $of -NoNewline
        $(setReset $write[1] $kk) | Out-File $of -NoNewline -Append
        Remove-Item -Path "$vf19_TMP\macross_cfg.temp" -Force
        (getHash $of sha256 | Select -Index 1).toUpper() | Out-File "$vf19_TOOLSROOT\launch.conf"

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
            w " $($vf19_CONFIG[0] -replace "\\config\.conf$")"
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
            eMsg $e 'r'
            errLog 'ERROR' "$USR -- $e"
        }
    }

}
function setCC([switch]$c=$false,[switch]$b=$false){
    if($b){startUp;getThis $vf19_MPOD['bl0']
    rv -Force vf19_MPOD,vf19_PYPOD -Scope Global;Return $vf19_READ}
    $cc=$((gc $($vf19_CONFIG[0]))[0..63] -Join(''))
    if($c){Return @($(gc $($vf19_CONFIG[0])) -replace $cc)}
    else{Return $(altByte $cc $d9[0] $d9[1])}
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
function setNewRole($file,$role,[switch]$check=$false){
    function gg($1){
        $a = (Get-ADGroup -filter "Name -eq '$1'" -properties Members | 
        Select -ExpandProperty Members) -replace ",OU=.+" -replace "CN=" | %{
            $n = $_ -replace "\\,",','
            Get-ADUser -filter "displayName -eq '$n' -or Name -eq '$n'" | 
            Select samAccountName
        } | Select -ExpandProperty samAccountName | Sort -u
        Return $a
    }
    $gj = setCC; $ga = $vf19_CONFIG[2]
    if($check -and (Test-Path "$ga")){
        $current = setReset -d $(gc "$ga") $gj | ConvertFrom-Json
        $i=0; w '    CURRENT TIER 1:' g; $current.Tier1 | %{if($i -le 5){w "$_," -i; $i++}else{w "$_,"; $i = 0}}
        ''
        $i=0; w "`n    CURRENT TIER 2:" g; $current.Tier2 | %{if($i -le 5){w "$_," -i; $i++}else{w "$_,"; $i = 0}}
        ''
        $i=0; w "`n    CURRENT TIER 3:" g; $current.Tier3 | %{if($i -le 5){w "$_," -i; $i++}else{w "$_,"; $i = 0}}
        w '
        '; Return
    }
    elseif($check){ w ' NOTICE: ' r bl -i; w 'Could not find any analyst.conf file.' c bl; Return}
    if($file -and $role){
        if(Test-Path "$vf19_TMP\analyst.tmp"){
            $json = (gc "$vf19_TMP\analyst.tmp") -replace "\}$","$(',"' + $role + '": [')"
        }
        else{
            $json = [string]"{$('"' + $role + '": [')"
        }
        Get-Content $file | %{
            $json += $('"' + $_ + '",')
        }
        $json = $json -replace ",$",']}'; $json | Out-File "$vf19_TMP\analyst.tmp"
    }
    elseif( $vf19_ROBOTECH ){
        w ' You must be admin to perform this action.
        ' c
    }
    else{
        if($vf19_MPOD['tr3']){ getThis $vf19_MPOD['tr3'];$tier3=$vf19_READ }
        if($vf19_MPOD['tr2']){ getThis $vf19_MPOD['tr2'];$tier2=$vf19_READ }
        if($vf19_MPOD['tr1']){ getThis $vf19_MPOD['tr1'];$tier1=$vf19_READ }
        if($vf19_MPOD['ta3']){ getThis $vf19_MPOD['ta3'];$admin3=$vf19_READ }
        if($vf19_MPOD['ta2']){ getThis $vf19_MPOD['ta2'];$admin2=$vf19_READ }
        if($vf19_MPOD['ta1']){ getThis $vf19_MPOD['ta1'];$admin1=$vf19_READ }
        if($tier1){
            $json = [string]'{"Tier1": ['
            gg $tier1 | %{ $json += $('"' + $_ + '",') }
            if($admin1){
                gg $admin1 | %{ $json += $('"' + $_ + '",') }
            }
            $json = $json -replace ",$",']'
        }
        if($tier2){
            $json = $json + [string]',"Tier2": ['
            gg $tier2 | %{ $json += $('"' + $_ + '",') }
            if($admin2){
                gg $admin2 | %{ $json += $('"' + $_ + '",') }
            }
            $json = $json -replace ",$",']'
        }
        if($tier3){
            $json = $json + [string]',"Tier3": ['
            gg $tier3 | %{ $json += $('"' + $_ + '",') }
            if($admin3){
                gg $admin3 | %{ $json += $('"' + $_ + '",') }
            }
            $json = $json -replace ",$",']'
        }
        if($json){
            $json += '}'
        }
        
    }
    if($json){
        $(setReset $json $gj) -replace "$(chr 83)$" | Out-File "$vf19_TOOLSROOT\analyst.conf"
    }

}
