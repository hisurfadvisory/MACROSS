## MACROSS configuration management

function findUsers($gpo){
    try{
        $l = (Get-ADGroup -filter "Name -eq '$gpo'" -properties Members | 
            Select -ExpandProperty Members) -replace ",OU=.+" -replace "CN=" 
    }
    catch{
        w "$($error[0])"
        Return $null
    }
    if($l.count -lt 1){ Return $null }
    $ll = @()
    $l | %{
        $n = $_ -replace "\\,",','
        $san = (Get-ADUser -filter "displayName -eq '$n' -or Name -eq '$n' -or samAccountName -eq '$n'").samAccountName
        $ll += $san
    }
    $ll = $ll | Sort -u
    Return $ll
}
function updateSKY($new,$old){
    $current_conf = mkList
    $current_conf.add("sky$(reString -e $new)") | Out-Null
    $old.keys | %{
        if($_ -ne 'sky'){$current_conf.add("$_$($old.$_)") | Out-Null}
    }
    return $current_conf
}
function wizard(){
    $list = @{}
    $required = @{
        'a'=@('Master Files location:','ICAgU0VUIEEgUkVQTzogSWYgeW91IHdhbnQgdG8gdXNlIGEgY2VudHJhbCByZXBvc2l0b3J5IHRvIGF1dG8tCiAgIG1hdGljYWxseSBkaXN0cmlidXRlIHVwZGF0ZWQgc2NyaXB0c3RvIG11bHRpcGxlIHVzZXJzLCBlbnRlciAKICAgdGhlIHBhdGggeW91IHdhbnQgdG8gdXNlIGZvciB0aGUgU0tZTkVUIG1hc3RlciBmaWxlcyBkaXJlY3RvcnkuCiAgIEVudGVyICJub25lIiB0byBkaXNhYmxlLg==');
        'b'=@('Debugging blacklist','ICAgU0VUIEJMQUNLTElTVDogQWxsIHVzZXJzIGhhdmUgYWNjZXNzIHRvIHRoZSBkZWJ1Z2dlciAoc28gdGhhdCBhbnlvbmUgY2FuCiAgIHdyaXRlIGF1dG9tYXRpb25zIHRoYXQgdGhleSBjYW4gdGVzdCBhbmQgYWRkIHRvIFNLWU5FVCkuIEVudGVyICJrZWVwIiB0byAKICAgYmxhY2tsaXN0IGNlcnRhaW4gc2Vuc2l0aXZlIGNvbW1hbmRzIHdpdGhvdXQgdGhlIGFkbWluIHBhc3N3b3JkLiBFbnRlciAKICAgIm5vbmUiIHRvIGRpc2FibGUgdGhpcyBibGFja2xpc3Qu');
        'c'=@('Content folder','ICAgU0tZTkVUIENPTlRFTlQgUEFUSDogWW91IGNhbiBzcGVjaWZ5IGEgbG9jYXRpb24gd2hlcmUgY29udGVudCBvciBlbnJpY2htZW50IAogICBmaWxlcyAoanNvbiwgeG1sLCBjc3YsIGV0Yy4pIGNhbiBiZSByZWd1bGFybHkgYWNjZXNzZWQgYnkgbXVsdGlwbGUgdXNlcnMgd2l0aAogICB0aGVpciBTS1lORVQgc2NyaXB0cy4gVGhlIGRlZmF1bHQgaXMgU0tZTkVUJ3MgbG9jYWwgcmVzb3VyY2VzIGZvbGRlci4=');
        'd'=@('Logs folder','ICAgU0tZTkVUIExPR1M6IEVudGVyIGEgbG9jYXRpb24gZm9yIFNLWU5FVCB0byB3cml0ZSBsb2dzIHRvLiAKICAgVGhlIGRlZmF1bHQgbG9jYXRpb24gaXMgaW4gU0tZTkVUJ3MgbG9jYWwgcmVzb3VyY2VzIGZvbGRlci4KICAgRW50ZXIgIm5vbmUiIHRvIGRpc2FibGUgbG9nZ2luZy4=');
    }
    $required.keys | Sort | %{
        reString $required.$_[1]
        w "$($required.$_[0])`:" g
        w "$dyrl_PT`n" 
    }
    "`n"
    
    $logo64 = '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GTRokAAycuTIfXZaTU1NYVctXry4cP3444+XkSNHyXljx8nGjRsLqnG3dPbo0UP6/epX0v/QQ+XwI46Q8rIy+Xbt2kL/l19+WQAZNWpUm3EPpF166aUCyEcffVS4dv755/9bFOjCCy8UrXVBikrLygSQTz755D9aw7x582T27Nnicrlk5cqVbX5Lp9OSzWYlk8lIJpORdDotqVRKrL3U75VXXiWz58wRQGpqagq0bGlpkYaGBmloaJDGxkapr6+X+vp6qaurk7q6ujbmZs2aNfL4Y4/LAw88INx4443y008/iYjI999/X7Bjzz77nKxfv77Q6fPPP5d27doViLNly5Zcnx9+KFzb/VC2bcuf//znf0vcCZdfXhi7ublZnE6XAHLdpEkFX+CXtnXr1hXGXbNmTWENRx9zjEyZMkXWrl0ra9askTVr1sjq1atl5apV8vTTTwsgCxa8VRjnpZdeEkAmTZok6XT6gNaQTCbl3HPPleeee14Auebqaw54DBGROXPmyITLrxBApk6Z0oZxv7SlUqmC2VMzZ86UB2c8SDKVpqk5V1W0aNEiOnbsyKBBg+h90EHEowlqa6tz6NWVVzJq5EhmzJiB3+9n6RefoyXnvfr9Qeobm0lEmrHydUzPPPMMhx12WBsoTwGVlZXcdddddOzYEcMwWbp0aQE8ADj55JPxeLwoQ2EoVVDzrZGkdDpNLBbj888/zwMImv79+1NaWopt23z55ZfMmjWLdu3ace6557ZRb2+++SY1NTVcf/31jD79DFLJBNFolK9bvbF3+ulnYJpGHlzI5XEF8uiZC6dpgoKsZfHWggVMmjyZG66/nkFHHkm0Ofc/I9deey1OlwulFE6HA61zf5+USCQIhUIY+b9v0tpGRHjhry+zcOHfOeboo/Ne9vGccMLxmKaJyiNZu8GPNsV1hoFlWZimyfbt28laFpdeeim8/vrrMnLkqIIEHHX0MbJhwwY544wz9gmab7/9Dvnxxx/lqaeekjl5NQLI8BNP2i9IPmfOHFm7du1+JXj27Nly+x2373P90AEDZfpttx8w0F9aWiqvvPKKHH300W2uv/HGGzJr1qz99nnttdfaJguUkvkLFshJJ598wPOPHTdONmzYINOmTZP169fLr351yAGP0a17d3n3vXdl4TvvyJo1a8TlCfxHSY/TRoySH374QSZNniyqV69e8tjjj1NcXIxojdPpZPHixcyYMYO5c+fmgI88TKa1Zs6cObz55pvMmTOHgw8+GNu2cblcNDQ0UFJS0gYASCQSXH755W0gztbthRdeoFevXm0wX8MwsHY7ZvLL/8LL6XRSWVlJaWkpwWCwAO253W6mTZu23z8uOeecc7jxxhsLgINhGFRu2oTX56Njx45tChv+L6BF2zb/+PBDHnroIc4++2yu+e1v8Xo8v3iM3fNv3ryZyy+/nEmTJnHmmWfidrsPaIzd43yxdCl33H47/w+7b81hp3zaRgAAAABJRU5ErkJggg=='
    $logod = [Convert]::FromBase64String($logo64)
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $cfgwiz = New-Object System.Windows.Forms.Form
    $logo = New-Object Windows.Forms.PictureBox

    $cfgwiz.Text = "MACROSS Configuration Wizard"
    $cfgwiz.Font = [System.Drawing.Font]::new("Tahoma",10.5)
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
    $info.Text = "INITIAL RUN: This wizard will create your config file in:`n $dyrl_CONFIG"
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
    $labelrepo.Text = $required.a[0]
    $cfgwiz.Controls.Add($labelrepo)

    $keyrepo = New-Object System.Windows.Forms.TextBox
    $keyrepo.Location = New-Object System.Drawing.Point(200,105)
    $keyrepo.Size = New-Object System.Drawing.Size(530,20)
    $keyrepo.Font = [System.Drawing.Font]::new("Consolas",11)
    $keyrepo.Text = 'none'
    $cfgwiz.Controls.Add($keyrepo)

    $labelblacklist = New-Object System.Windows.Forms.Label
    $labelblacklist.Location = New-Object System.Drawing.Point(10,135)
    $labelblacklist.Size = New-Object System.Drawing.Size(175,15)
    $labelblacklist.Font = [System.Drawing.Font]::new("Consolas",10)
    $labelblacklist.ForeColor = 'CYAN'
    $labelblacklist.Text = $required.b[0]
    $cfgwiz.Controls.Add($labelblacklist)

    $keyblacklist = New-Object System.Windows.Forms.TextBox
    $keyblacklist.Location = New-Object System.Drawing.Point(200,135)
    $keyblacklist.Size = New-Object System.Drawing.Size(530,20)
    $keyblacklist.Font = [System.Drawing.Font]::new("Consolas",11)
    $keyblacklist.Text = 'keep'
    $cfgwiz.Controls.Add($keyblacklist)

    $labelenr = New-Object System.Windows.Forms.Label
    $labelenr.Location = New-Object System.Drawing.Point(10,225)
    $labelenr.Size = New-Object System.Drawing.Size(175,15)
    $labelenr.Font = [System.Drawing.Font]::new("Consolas",10)
    $labelenr.ForeColor = 'CYAN'
    $labelenr.Text = $required.c[0]
    $cfgwiz.Controls.Add($labelenr)

    $keyenr = New-Object System.Windows.Forms.TextBox
    $keyenr.Location = New-Object System.Drawing.Point(200,225)
    $keyenr.Size = New-Object System.Drawing.Size(530,20)
    $keyenr.Font = [System.Drawing.Font]::new("Consolas",11)
    $keyenr.Text = "$dyrl_RESOURCES"
    $cfgwiz.Controls.Add($keyenr)

    $labellogs = New-Object System.Windows.Forms.Label
    $labellogs.Location = New-Object System.Drawing.Point(10,255)
    $labellogs.Size = New-Object System.Drawing.Size(175,15)
    $labellogs.Font = [System.Drawing.Font]::new("Consolas",10)
    $labellogs.ForeColor = 'CYAN'
    $labellogs.Text = $required.d[0]
    $cfgwiz.Controls.Add($labellogs)

    $keylogs = New-Object System.Windows.Forms.TextBox
    $keylogs.Location = New-Object System.Drawing.Point(200,255)
    $keylogs.Size = New-Object System.Drawing.Size(530,20)
    $keylogs.Font = [System.Drawing.Font]::new("Consolas",11)
    $keylogs.Text = "$dyrl_PLUGINS\logs"
    $cfgwiz.Controls.Add($keylogs)

    $confirm = New-Object System.Windows.Forms.Button
    $confirm.Location = New-Object System.Drawing.Point(275,310)
    $confirm.Size = New-Object System.Drawing.Size(250,30)
    $confirm.ForeColor = 'YELLOW'
    $confirm.BackColor = 'BLUE'
    $confirm.Text = 'CONFIRM SETTINGS'
    $confirm.Add_Click({
        $Script:clicked = $true
        if($keyblacklist.Text -eq 'keep'){ $blist = returnDefault dbg }
        else{ $blist = returnDefault -b }
        $bl0 = $blist[0]
        $dbg = [string]$blist[1]
        if($keylogs.Text -eq 'keep'){ $log = returnDefault log }
        else{ $log = $keylogs.Text }
        if($keyenr.Text -eq 'keep'){ $con = returnDefault con }
        else{ $con = $keyenr.Text }
        $list.Add('cre',$keyrepo.Text)
        $list.Add('log',$log)
        $list.Add('con',$con)
        $list.Add('bl0',$bl0)
        $list.Add('dbg',$dbg)
        $cfgwiz.Close()
    })
    $cfgwiz.Controls.Add($confirm)
    $a = $cfgwiz.ShowDialog()
    
    if(-not $clicked){Exit}
    else{ rv clicked -Scope Script; Return $list }
}
function returnDefault($ix,[switch]$bdis=$false){
    if($bdis){
        $r = @("bm9fbmVlZDRibGFja2xpc3Qu",'0')
    }
    else{
        $conf = @{
            'dbg'=@("$(setLocal -i)",'1');
            'cre'='none';
            'con'="$dyrl_RESOURCES";
            'log'="$dyrl_PLUGINS\logs"
        }
        $r = $conf[$ix]
    }
    Return $r
}
function configAccess($t){
    function e_($e){
        try{ $e = findUsers $e.Trim() }
        catch{ $e = $false }
        if(! $e){w "$z not found!" y; $e = $null }
        Return $e
    }
    while($z -notMatch "^[gun]"){
        w "Tier $($t[2])`: Do you want to enter a (u)ser list or use a (g)roup-policy name?" g
        $z = _ftn_ '(Enter "none" to skip this tier) '
    }
    if($z -eq 'g'){
        $l = 2
        $z = _ftn_ "Tier $($t[2])`: Enter the group-policy name: "
        $members = e_ $z
    }
    elseif($z -eq 'u'){
        $l = 1
        $members = (getBlox -t 'MACROSS USER LIST' -i 'Paste a list of usernames (one per line); use CTRL+ENTER to manually add newlines') | ?{$_ -Match "\w"}
        if($members[0] -eq ''){ $z = 'none' }
    }
    "`n"
    if($z -eq 'none'){ Return @($z,0) }
    else{ Return @($members,$l) }
}
function localWriteP($xtext){
    Add-Type -AssemblyName System.Security
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($xtext)
    $scp = [Security.Cryptography.ProtectedData]::Protect(
        $bytes,
        $null,
        [Security.Cryptography.DataProtectionScope]::CurrentUser
    )
    $et = [System.Convert]::ToBase64String($scp)
    Return $et
}
function localReadP($ytext){
    Add-Type -AssemblyName System.Security
    $scfb = [System.Convert]::FromBase64String($ytext)
    $bytes = [Security.Cryptography.ProtectedData]::Unprotect(
        $scfb,
        $null,
        [Security.Cryptography.DataProtectionScope]::CurrentUser
    )
    $dt = [System.Text.Encoding]::Unicode.GetString($bytes)
    Return $dt
}
function sideWrite($bside,$eside=16,[switch]$on){
    if($on){ Return (reString ($(reString "$bside`macross.conf" -h -e) * 2) -e).Substring(0,$eside) }
    reString $bside.Substring($eside)
    Return $(($dyrl_PT -split '\D\D' | ?{$_ -Match '\d'} | %{chr $_} ) -join '' -replace '[^\w=/\.]')
}
function upWrite($n,$conf,$o_file="macross.conf",[switch]$ex,[switch]$xe,[switch]$fin){
    function wut_($1){
        errMsg -f 'MACROSS.upWrite' "upWrite: $1"
        $error[0]
        varCleanup -c
        Exit
    }
    function bkup_(){
        if(Test-Path $ofile){
            $rename = $(Get-Date -f "%y%M%d-%h%m%s")
            $b_file = $ofile -replace $o_file,"$rename`_$o_file`.backup"
            Move-Item -Path $ofile -Destination $b_file
        }
    }
    function add_($10){
        Return $add[$(Get-Random -Min 0 -Max $10)]
    }
    $ofile = "$dyrl_MACROSS\corefuncs\$o_file"
    $sfile = "$dyrl_OUTFILES\$o_file"
    if(-not $conf -and ($ex -or $xe)){
        $master = ((gc $ofile | Select -Skip 1) -Join '').Trim()
        if($ex){ $master = localReadP $master }
    }

    if($ex){ w 'Exporting config...' g}
    elseif($xe){ w 'Importing config...' g }
    else{ bkup_ }
    if(! $master){
        $add = (alphanum)[0]
        $c = ''
        $d = ''
        $transformer = sideWrite $n -o 
        $k = byter $transformer -b
        0..15 | %{
            $a = add_ 51
            $b = add_ 51
            $c += add_ 61
            $cc = ord $transformer[$_]
            $d += "$cc$a$b"
        }
        $d = "$(reString -e $d)"
        $master = $conf | ConvertTo-SecureString -AsPlainText -Force
        $master = "$($master | ConvertFrom-SecureString -Key $k)"
        $master = "$c$d=00$master"
    }
    
    $title = ' MACROSS DATA CONFIGURATION '
    $top1 = "$('#'*8)$title$('#'*9)"
    $top2 = "$('#'*11)$title$('#'*11)"

    if($ex){ 
        blockWriter -f $o_file -b "$top2$master" -m 50
        $ofile = $sfile
    }
    else{
        $master = localWriteP "$master"
        blockWriter -f $o_file -b "$top1$master" -m 45
        $import = getHash $sfile md5
        Move-Item -Path $sfile -Destination $ofile -Force
        $replace = getHash $ofile md5
        if($import -ne $replace){
            if($import){
                "`n"
                w 'Something went wrong, the file did not import correctly.' y
                w 'You can manually move the file, it is located in' y
                w $sfile
                w 'Use it to replace' y
                w $ofile
            }
            else{
                errMsg "$($error[0])" -f 'MACROSS.upWrite'
            }
            exit
        }
    }
    
    if(! (Test-Path -Path $ofile)){
        wut_ "Unknown error: failed to create new $o_file file"
        w 'Hit ENTER exit.' g
        Read-Host
    }
    elseif($ex){
        w 'Your export file is located in' g
        w "`n $ofile`n"
        w 'Have your user copy it to their corefuncs folder.' g
        w 'Hit ENTER continue.' g; Read-Host; Return
    }
    if($xe){ Return }
    else{
        Remove-Item $tfile
        w "`n`n Setup is complete. Run the Launch.ps1 script to start MACROSS.`n" g
        
    }
    Remove-Variable dyrl_* -Force -Scope Global
    Exit
}
function downWrite($a,$b,$c=0,$k='',[switch]$l){
    if($l){ $a = sideWrite $a -o } 
    else{ $a = sideWrite $a }
    $k = byter $a -b
    $config = ConvertTo-SecureString -String $b -Key $k
    $ptr = byter $config
    Return $ptr
}
function addWrites($m,$skycf='MACROSS CONFIGURATION'){
    $k = 'k'; $z = $null
    $modified = $false
    $gpc = @('tr1','tr2','tr3','ta1','ta2','ta3')
    $extra = @($null,$null)
    while($k -notIn $dyrl_CONF.keys){
        w "`n Enter the 3-character index key or `"c`" to cancel: " g -i
        $k = Read-Host
        if($k -eq 'c'){ Return @(0,0,$false,$extra[0],$extra[1]) }
        elseif($k -eq 'dbg'){
            $modified = $true
            $switches = @('disabled','enabled')
            if($dyrl_BLD -eq 'False'){ $def = returnDefault $k }
            else{ $def = returnDefault -b }
            $v = $def[1]
            $extra = @('bl0',$def[0])
            w "Debug restriction has been $($switches[[int]$v])`.`n" g
        }
        elseif($k -in $m){ 
            $k = yorn -q 'That is a reserved index, you cannot change it.' `
                -b 0 -i 16 -l $skycf
        }
        elseif($k -in $gpc){
            $k = yorn -q 'This index can only be changed when updating GPO or userlists.' `
                -b 0 -i 48 -l $skycf
        }
        elseif($dyrl_CONF[$k]){
            reString $dyrl_CONF.$k
            $z = yorn -q "Do you want to replace `"$dyrl_PT`"?" -b 4 -i 32 -l $skycf
            if($z -eq 'No'){ $k = $null }
            else{ $modified = $true }
        }
        
    }
    if(! $v){
        w "`n Enter the value you want to set for this index:`n > " g -i
        $z = Read-Host
        if($z -eq 'keep'){ $v = returnDefault $k }
        else{ $v = "$z" }
    }
    errLog INFO 'MACROSS.addWrites' "$k was updated to $v"
    Return @($k,$v,$modified,$extra[0],$extra[1])
}
function runStart($update=0,$micro=@('c2t5','Ymww','ZGkx','ZGky','dWFj'),$static){
    function in_($n0=$null){
        if($n0){$gnh = $(getHash $n0 -s)}
        else{
            $n1 = 100; $n3 = 101
            while($n1 -ne $n3){
                reString -h 456E7465722061206E65772061646D696E2070617373776F7264
                $n0 = Read-Host "         $dyrl_PT" -AsSecureString
                $n1 = byter $n0
                reString -h 456E74657220746865206E65772061646D696E2070617373776F726420616761696E
                $n2 = Read-Host " $dyrl_PT" -AsSecureString
                $n3 = byter $n2
                if($n1 -ne $n3){ w "$nomsg`n" y }
            }
            reString 'NTk2Rjc1MjA3NzY5NkM2QzIwNkU2NTY1NjQyMDc0Njg2OTczMjA3MDY
            xNzM3Mzc3NkY3MjY0MjA2OTY2MjA3OTZGNzUyMDc3NjE2RTc0MjA3NDZGMjA2MzY4
            NjE2RTY3NjUyMDUzNEI1OTRFNDU1NDI3NzMyMDYzNkY2RTY2Njk2Nzc1NzI2MTc0N
            jk2RjZFNzMyMDZDNjE3NDY1NzIyRQ=='
            reString -h $dyrl_PT
            w "`n $dyrl_PT`n`n" y
            $gnh = $n3
        }
        Return $gnh
    }
    $valid = mkList; $bar = battroid -b; $mod = $false
    $Global:dyrl_LOG = 'none'; $env:MACROSS = "$dyrl_MACROSS"
    $bar = " your value >$(' '*5)$bar " 
    
    if($update -eq 0){
        reString 50617373776F72647320646F206E6F74206D6174636821 -h
        $nomsg = $dyrl_PT
        $di = @($(Get-Random -Min 11111 -Max 99999),$(Get-Random -Min 11111 -Max 99999))
        $Global:N_ = $(startUp -new $di)
        $di1 = $di[0]
        $di2 = $di[1]
    }
    reString "$('20'*31)534B594E455420494E495449414C205345545550" -h
    screenResults $dyrl_PT
    screenResults -e
    "`n"
    if($update -lt 2){ 
        $nap = in_
        $mod = $true 
    }
    if($update -gt 0){
        startUp
        $reform = $dyrl_CONF
        reString $micro[0]
    }
    if($update -eq 1){ $valid = updateSKY $nap $reform }
    elseif($update -eq 2){
        $ixlabels = @{
            'cre'='Master/Repo path (enter a custom path or "none" to disable)';
            'con'='Content files path (enter a custom path or "keep" to set the default)';
            'dbg'='Debugging is restricted (enter "keep" to enable or "none" to disable)';
            'log'='Path to logs (enter custom path, "keep" for default or "none" to disable)'
        }
        $ulabels = @{
            'r'='users';
            'a'='admins'
        }
        $hkm = mkList
        $micro | %{
            reString $_
            $hkm.add($dyrl_PT) | Out-Null
        }
        
        $conf = @{}
        $reform.keys | ?{"$_" -notIn $hkm} | Sort | %{
            $c1 = "w~$_"
            if($_ -eq 'dbg'){ $c3 = $dyrl_BLD }
            else{
                reString $reform.$_
                $c3 = $($dyrl_PT -replace ',',', ')
            }
            if($_ -Like "t*"){
                if(! $tierbreak){
                    $tierbreak = 'USER ACCESS TIERS (You must use the "Update users" option to modify these)'
                    screenResults "c~$tierbreak"
                }
                $i1 = $_.substring(2)
                $i2 = $_.substring(1,1)
                $c2 = "Tier $i1 $($ulabels[$i2])"
                screenResults $c2
                screenResults $c1 $c3
            }
            else{
                $c2 = "$($ixlabels[$_])"
                screenResultsAlt -h "$c2" -k "INDEX" -v $c1
                screenResultsAlt -k "VALUE" -v $c3
                screenResultsAlt -e
            }
        }
        screenResults -e
        
        "`n"
        $new = $false
        $any = @('of these','other')
        $ch = 0
        while($z -ne 'n'){
            while($z -notIn @('y','n')){
                w "Do you want to modify any $($any[$ch]) configs? (y/n) " g -i
                $z = Read-Host
            }
            if($z -Like "y*"){ 
                if($ch -eq 0){ $ch++ }
                $z = $null
                $new = addWrites -m @('uac',$micro)
            }
            if($z -ne 'n' -and $new[2]){ 
                $mod = $new[2]
                $conf.add($new[0],$new[1]) 
                if($new[3] -and $new[4]){
                    $conf.add($new[3],$new[4])
                }
            }
        }
        if($conf.count -gt 0){
            "`n"
            reString $micro[1]
            $cl = $dyrl_PT
            $nap = $static
            $originals = @{}
            $z = $null
            foreach($ck in $conf.keys){
                if($ck -ne $cl){if($ck -in $reform.keys){
                    reString $reform.$ck
                    $originals.add($ck,$dyrl_PT)
                }
                else{
                    $originals.add($ck,$null)
                }
                screenResults "$ck Original Value" $originals.$ck
                screenResults "$ck New Value" $conf.$ck }
            }
            screenResults -e
            "`n"
            while($z -notIn @('a','c')){
                w 'Enter "a" to accept these changes, or "c" to cancel: ' g -i
                $z = Read-Host
            }
            if($z -Like 'a*'){
                $newconfs = @{}
                foreach($ck in $reform.keys){
                    try{ $newval = reString -e $conf.$ck }
                    catch{ $newval = $reform.$ck }
                    $newconfs.add($ck,$newval)
                }
                $newconfs.keys | %{ $valid.add("$_$($newconfs.$_)") | Out-Null }
                $test = $newconfs.dbg
                Remove-Variable conf,reform,newconfs
            }
            else{ Return }
        }
    }
    else{
        $mod = $true
        screenResults '      Setting Default Configs (you can modify these later if needed)'
        screenResults ' NOTE: this version of macross can only view file shares for repo/logs/content, not web or file servers. This will be updated in a future version.'
        screenResults -e
        "`n"
        $wiz = wizard
        "`n"
        $tr = runUserTier -i


        $required = @{
            'cre' = reString -e $wiz.cre;
            'bl0' = reString -e $wiz.bl0;
            'con' = reString -e $wiz.con;
            'dbg' = reString -e $wiz.dbg;
            'log' = reString -e $wiz.log;
            'sky' = reString -e "$(in_ $nap)";
            'di1' = reString -e $di1;
            'di2' = reString -e $di2;
            'tr1' = reString -e $tr.tr1;
            'tr2' = reString -e $tr.tr2;
            'tr3' = reString -e $tr.tr3;
            'ta1' = reString -e $tr.ta1;
            'ta2' = reString -e $tr.ta2;
            'ta3' = reString -e $tr.ta3;
            'uac' = reString -e "$($tr.uac)"
        }
        $required.keys | %{ $valid.add("$_$($required.$_)") | Out-Null }
    }
    if($mod){
        reString QEBA
        upWrite -n $nap -c $($valid -Join "$dyrl_PT") -f
    }
}
function runContinue($continue=$null){
    reString PTAw
    function e_(){
        $e = @('ERROR','Config unreadable')
        errLog $e[0] $e[1]
        w "$($e -Join ": ") " -b r -f k
        Return $null
    }
    if((Get-Content $dyrl_CONFIG)[0].length -gt 48){ upWrite -x }
    $raw = ((Get-Content -Path $dyrl_CONFIG | Select -Skip 1) -Join '').Trim()
    $raw = localReadP $raw
    $divraw = $raw -Split $dyrl_PT
    if($continue -ne $null){
        try{ $r = $(downWrite $continue $divraw[1] -l) }
        catch{ $r = e_ }
    }
    else{ 
        try{ $r = $(downWrite $divraw[0] $divraw[1]) }
        catch{ $r = e_ }
    }
    Return $r
}
function runUserList([switch]$t=$false){
    if($t){ $ulist = getFile -f txt }
    else{ $ulist = $(getBlox -t 'User list entry' -i 'Paste or Enter usernames, one per line') -Split "`n" }
    if($ulist.getType().Name -ne 'Object[]'){ Return $false }
    else{ Return $ulist }
}
function runUserTier([switch]$init,$update=0){
    function cfa_($t,$r){
        $lt = @('','User-','Admin-')
        if($r -ne 0){ w "$($lt[$r])level tiers: " -b g -f k }
        $a = (configAccess $t)[1..2]
        if(! $a){ Return @($false,$false) }
        $uacc = $a[1]
        if($uacc){ 
            $a[0] | %{ w "   $_" }
            $affirm = _ftn_ 'Does this look correct? (y/n) '
            if($affirm -Like "y*"){
                $uactr = $a[0] -Join ','
            }
            else{ $uactr = $null }
        }
        else{
            $uactr = 'none'
        }
        w "`n"
        Return @($t,$uactr)
    }
    reString 'U0tZTkVUIGNhbiB1c2UgYmFzaWMgYWNjZXNzIGNvbnRyb2wgZm9yIHlvdXIgYXV0b21hdGl
    vbnMuIFlvdSBoYXZlIHR3byBvcHRpb25zIHRvIGNyZWF0ZSBhY2Nlc3MgbGlzdHM6IDEgLSBZb3UgY2F
    uIGJlZ2luIHByb3ZpZGluZyB0aGUgbmFtZXMgb2YgR3JvdXAgUG9saWNpZXMgeW91ciB1c2VycyBiZWx
    vbmcgdG8gKHRoaXMgcmVxdWlyZXMgYWRtaW4gcHJpdmlsZWdlcyk7IDIgLSB5b3UgY2FuIG1hbnVhbGx
    5IGVudGVyL3Bhc3RlIHVzZXJuYW1lcy4gWW91IGNhbiBhZGQgdXNlcnMgaW4gdXAgdG8gdGhyZWUgZ3J
    vdXBzIC0gdGllcnMgMSB0aHJ1IDMuIERvIHlvdSB3YW50IHRvIHVzZSBhY2Nlc3MgY29udHJvbD8lWW9
    1IGNhbiBkbyB0aGUgc2FtZSBmb3IgYWRtaW4gdXNlcnMsIGlmIHRoZXkgaGF2ZSBzZXBhcmF0ZSBhY2N
    vdW50cyB3aXRoIGFkbWluaXN0cmF0aXZlIHByaXZpbGVnZXMuIERvIHlvdSBuZWVkIHRvIHNldCBhZG1
    pbiB1c2Vycz8='
    $yq = $dyrl_PT -Split '%'
    if($init){ $yorn = yorn -q $yq[0] -b 4 -i 32 -l 'USER-LEVEL TIERS' }
    elseif(-not $update){ $yorn = 'Yes' }
    w "`n"
    $array = @{}
    if($yorn -eq 'No'){ 
        $array.add('uac',0)
        1..3 | %{
            $array.add("tr$_",'none')
            $array.add("ta$_",'none')
        }
    }
    elseif($update){
        $tu = cfa_ $update
        return $tu
    }
    else{
        $array.add('uac',1)
        $tr = 1
        $roll = 0
        $k = 'tr'
        $z = $null
        while($roll -ne 2){
            $roll++
            while($tr -le 3){
                $tu = cfa_ "$k$tr" -r $roll
                if($tu[1]){
                    $array.add($tu[0],$tu[1])
                    $tr++
                }
            }
            if($roll -lt 2){
                $yorn = yorn -q $yq[1] -b 4 -i 32 -l 'ADMIN-LEVEL TIERS'
                if($yorn -ne 'Yes'){ $array.add('ta1','none'); $array.add('ta2','none'); $array.add('ta3','none'); Break }
                else{ $tr=1; $k='ta' }
            }
        }
    }
    "`n"
    Return $array
    
}
function runModify([switch]$resistance,$micro=@('c2t5','Ymww','ZGkx','ZGky'),$actual){
    startUp -r $actual
    if(! $dyrl_CONF){ w 'Hit ENTER to continue.' g; Read-Host; Return }
    $upconf = $dyrl_CONF
    $mu = 1
    "`n"
    @('5570646174652070617373776F7264','55706461746520636F6E66696773','557064617465207573657273') | %{
        reString -h $_
        w "$mu`. $dyrl_PT"
        $mu++
    }
    w 'or "q" to quit.'
    while($select -notIn @(1,2,3,'q')){
        w "`n   Selection: " g -i
        $select = Read-Host
    }
    if($select -eq 'q'){ Return }
    if($select -eq 3){ 
        foreach($tv in @('tr1','tr2','tr3','ta1','ta2','ta3')){
            try{ 
                reString $upconf.$tv
                screenResults $tv $($dyrl_PT -replace ',',', ')
                $shown = $true
            }
            catch{ $null }
        }
        if($shown){
            screenResults -e
            "`n"
            $chg = 0
            while($z -ne 'q'){
                w 'Enter the index to update (ex. "ta2" for tier 2 admins), or "q" to quit: ' g -i
                $z = Read-Host
                if($z -Match "t[ar]\d"){ 
                    $tu = runUserTier -u $z
                    if($tu[1]){ 
                        $upconf[$z] = $(reString -e $tu[1]); $chg++; $upconf['uac'] = $(reString -e "1") 
                    }
                }
            }
            if($chg -eq 0){ Return }
            $newcon = mkList
            $upconf.keys | %{$newcon.add("$_$($upconf[$_])") | Out-Null }
            reString QEBA
            upWrite -n $actual -c "$($newcon -join $dyrl_PT)" -f 
        }
    }
    else{ runStart -u $select -s $actual }
}

