## MACROSS configuration management

function findUsers($gpnm){
    try{
        $l = (Get-ADGroup -filter "Name -eq '$gpnm'" -properties Members |
            Select -ExpandProperty Members) -replace ",OU=.+" -replace "CN="
    }
    catch{
        w "$($error[0])"
        Return @()
    }
    if($l.count -lt 1){ Return $null }
    $ll = @()
    $l | %{
        $n = $_ -replace "\\,",','
        $san = (Get-ADUser -filter "samAccountName -eq '$n' -or Name -eq '$n' -or displayName -eq '$n'").samAccountName
        $ll += $san
    }
    $ll = $ll | Sort -u
    Return $ll
}
function updateMAC($new,$old){
    $current_conf = mkList
    $current_conf.add("mac$(gerwalk -e $new)") | Out-Null
    $old.keys | %{
        if($_ -ne 'mac'){$current_conf.add("$_$($old.$_)") | Out-Null}
    }
    return $current_conf
}
function confirmUsers($ulist,[string]$utype,[int]$tier){

    $ucount = $ulist.count

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Select/deselect from $ucount Tier-$tier $utype`s"
    $form.Size = New-Object System.Drawing.Size(500,500)
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(10,430)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(85,430)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $checkedlist = New-Object System.Windows.Forms.ListView
    $checkedlist.CheckBoxes = $true
    $checkedlist.Location = New-Object System.Drawing.Point(10,40)
    $checkedlist.Size = New-Object System.Drawing.Size(465,355)
    $checkedlist.Scrollable = $true
    $checkedlist.TabIndex = 0
    $checkedlist.Alignment = "Left"
    $checkedlist.View = "List"
    $checkedlist.ShowItemToolTips = $True
    $checkedlist.HideSelection = $false
    [void]$checkedlist.Add_SelectedIndexChanged({
        If($checkedlist.SelectedItems -ne $Null){
            $urlbox.Text = [string]$checkedlist.SelectedItems[0].SubItems.Text[0]
            if ($checkedlist.SelectedItems.SubItems.Get(2).Text -eq "False"){
                $urlcheckbox.Checked = $false
            }
            else{
                $urlcheckbox.Checked = $true
            }

        }
    })

    for($i = 0; $i -lt $ucount; $i++){
        [void]$checkedlist.Items.Add("$($ulist[$i])")
        [void]$checkedlist.Items[$i].SubItems.Add([string]$ulist[$i])
    }


    for($i = 0; $i -lt $checkedlist.Items.Count; $i++){
        $checkedlist.Items[$i].Checked = $true
        $item = $checkedlist.Items[$i].SubItems[0].Text
        if($item -eq 'none'){
            $checkedlist.Items[$i].ForeColor = "Red"
        }
    }

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(310,20)
    $label.Text = 'If you did not enter users for this tier, leave "none" checked.'
    $form.Controls.Add($label)


    [void]$form.Controls.Add($checkedlist)
    $form.Topmost = $true
    $form.Add_Shown({$checkedlist.Select()})
    $formResult = $form.ShowDialog()

    if($formResult -eq [System.Windows.Forms.DialogResult]::OK){
        $confirmed = mkList
        for($i = 0; $i -lt $checkedlist.Items.Count; $i++){
            if ($checkedlist.Items[$i].Checked -eq $true) {
                [void]$confirmed.Add([string]$checkedlist.Items[$i].SubItems[0].Text)
            }
        }
        Return $confirmed
    }
    else{
        Return $false
    }

}
function wizard([switch]$tiers){
    $list = @{}
    if(-not $tiers){
        $required = @{
            'a'=@('MACROSS master path','ICAgQ0VOVFJBTCBNQVNURVI6IElmIHlvdSB3YW50IHRvIHVzZSBhIGNlbnRyYWwgbG9jYXRpb24gdG8ga2VlcAogICBhIG1hc3RlciBjb3B5IG9mIFNLWU5FVCB0aGF0IGNhbiBhdXRvLWRpc3RyaWJ1dGUgdXBkYXRlcywgZW50ZXIKICAgdGhlIHBhdGggaGVyZS4gRW50ZXIgIm5vbmUiIHRvIGRpc2FibGUgdXBkYXRlcy4=');
            'b'=@('Diamond master path','ICAgTUFTVEVSIFNDUklQVFM6IElmIHlvdSBzZXQgYSBtYXN0ZXIgbG9jYXRpb24gZm9yIFNLWU5FVCwgeW91CiAgIGNhbiBzZXQgYW4gYWx0ZXJuYXRlIHBhdGggd2hlcmUgeW91ciBodW50ZXIgc2NyaXB0cyBjYW4gYmUKICAgZGlzdHJpYnV0ZWQgZnJvbS4gRW50ZXIgIm5vbmUiIGlmIHlvdSBhcmUgdXNpbmcgdGhlIHNhbWUKICAgbG9jYXRpb24gYXMgdGhlIFNLWU5FVCBtYXN0ZXIsIG9yIHRvIGRpc2FibGUgdGhpcy4=')
            'c'=@('Debugging blacklist','ICAgUkVTVFJJQ1QgQ09NTUFORFM6IEFsbCB1c2VycyBoYXZlIGFjY2VzcyB0byB0aGUgZGVidWdnZXIgKHNvIAogICB0aGF0IGFueW9uZSBjYW4gd3JpdGUgYXV0b21hdGlvbnMgdGhhdCB0aGV5IGNhbiB0ZXN0IGFuZCBhZGQgdG8gCiAgIFNLWU5FVCkuIFRoZSBkZWZhdWx0IHdpbGwgcmVxdWlyZSB0aGUgYWRtaW4gcGFzc3dvcmQgdG8gdXNlCiAgIGNlcnRhaW4gY29tbWFuZHMgJiBmdW5jdGlvbi4gVW5jaGVjayB0byBkaXNhYmxlIHJlc3RyaWN0aW9uLg==');
            'd'=@('Content folder','ICAgQ09OVEVOVCBQQVRIOiBZb3UgY2FuIHNwZWNpZnkgYSBsb2NhdGlvbiB3aGVyZSBjb250ZW50IG9yIAogICBlbnJpY2htZW50IGZpbGVzIChqc29uLCB4bWwsIGNzdiwgZXRjLikgY2FuIGJlIHJlZ3VsYXJseSAKICAgYWNjZXNzZWQgYnkgU0tZTkVUIGh1bnRlciBzY3JpcHRzLiBUaGUgZGVmYXVsdCBpcyBTS1lORVQncwogICBsb2NhbCByZXNvdXJjZXMgZm9sZGVyLg==');
            'e'=@('Logs folder','ICAgU0tZTkVUIExPR1M6IEVudGVyIGEgbG9jYXRpb24gZm9yIFNLWU5FVCB0byB3cml0ZSBsb2dzIHRvLiAKICAgVGhlIGRlZmF1bHQgbG9jYXRpb24gaXMgaW4gU0tZTkVUJ3MgbG9jYWwgcmVzb3VyY2VzIGZvbGRlci4KICAgRW50ZXIgIm5vbmUiIHRvIGRpc2FibGUgbG9nZ2luZy4=')
        }
        $required.keys | Sort | %{
            gerwalk $required.$_[1]
            w "$($required.$_[0])`:" g
            w "$dyrl_PT`n"
        }
    }
    "`n"

    $hnr = "$dyrl_MACROSS\corefuncs\resources"
    $icon64 = Get-Content -raw "$hnr\icon.bimg"
    $bg64 = Get-Content -raw "$hnr\background.bimg"
    $icon = [Convert]::FromBase64String($icon64); rv icon64
    $bg = [Convert]::FromBase64String($bg64); rv bg64,hnr
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $cfgwiz = New-Object System.Windows.Forms.Form
    $logo = New-Object Windows.Forms.PictureBox

    $cfgwiz.Text = "MACROSS Configuration Wizard"
    $cfgwiz.Font = [System.Drawing.Font]::new("Tahoma",10.5)
    $cfgwiz.ForeColor = 'WHITE'
    $cfgwiz.BackColor = 'BLACK'
    $cfgwiz.BackgroundImage = $bg
    $cfgwiz.BackgroundImageLayout = "Stretch"
    $cfgwiz.Size = New-Object System.Drawing.Size(810,400)
    $cfgwiz.StartPosition = "CenterScreen"

    $logo.Width = 100
    $logo.Height = 72
    $logo.Location = New-Object System.Drawing.Point(10,2)
    $logo.Image = $icon
    $cfgwiz.Controls.Add($logo)



    if($tiers){
        $loc = 118
        $sz = @(775,34)
        $itxt = $tiermsg[2..3] -Join ' '
        $mtxt = $tiermsg[0] -Join ' '
    }
    else{
        $loc = 135
        $sz = @(890,35)
        $itxt = "INITIAL RUN: This wizard will create your config file in:`n $($dyrl_CONFIG[0])"
        $mtxt = $tiermsg[2..3] -Join ' '
    }

    $info = New-Object System.Windows.Forms.Label
    $info.Location = New-Object System.Drawing.Point($loc,5)
    $info.ForeColor = 'yellow'
    $info.Size = New-Object System.Drawing.Size($sz[0],$sz[1])
    $info.Font = [System.Drawing.Font]::new("Consolas",9)
    $info.Text = $itxt
    $cfgwiz.Controls.Add($info)

    $mandated = New-Object System.Windows.Forms.Label
    $mandated.Location = New-Object System.Drawing.Point(10,73)
    $mandated.Size = New-Object System.Drawing.Size(800,35)
    $mandated.Font = [System.Drawing.Font]::new("Consolas",10)
    $mandated.Text = $mtxt
    $cfgwiz.Controls.Add($mandated)


    if($tiers){

        $tierfields = mkList
        $renum = @(1,2,3,1,2,3)
        $location = 105

        0..5 | %{
            if($_ -lt 3){$u = 'users'}else{$u = 'admins'}
            $num = $renum[$_]
            $line = mkList
            $label = New-Object System.Windows.Forms.Label
            $label = New-Object System.Windows.Forms.Label
            $label.Location = New-Object System.Drawing.Point(10,$location)
            $label.Size = New-Object System.Drawing.Size(110,15)
            $label.Font = [System.Drawing.Font]::new("Consolas",10)
            $label.ForeColor = 'YELLOW'
            $label.Text = "Tier $num $u"
            [void]$line.add($label)

            $text = New-Object System.Windows.Forms.TextBox
            $text.Location = New-Object System.Drawing.Point(130,$location)
            $text.Size = New-Object System.Drawing.Size(530,20)
            $text.Font = [System.Drawing.Font]::new("Consolas",11)
            $text.Text = 'none'
            [void]$line.add($text)

            $checkm = New-Object System.Windows.Forms.Checkbox
            $checkm.Location = New-Object System.Drawing.Size(685,$location)
            $checkm.Size = New-Object System.Drawing.Size(99,25)
            $checkm.Checked = $false
            $checkm.ForeColor = 'YELLOW'
            $checkm.Text = "GPO"
            [void]$line.add($checkm)

            [void]$tierfields.add($line)

            $line | %{ $cfgwiz.Controls.Add($_) }

            $location = $location + 30

        }
    }
    else{

        $cfgfields = mkList
        $location = 105
        $defaults = @{
            'e'="$dyrl_RESOURCES\logs";
            'd'="$dyrl_RESOURCES";
            'c'='keep';
            'b'='none';
            'a'='none' }

        $defaults.keys | sort | %{
            $line = mkList
            $label = New-Object System.Windows.Forms.Label
            $label = New-Object System.Windows.Forms.Label
            $label.Location = New-Object System.Drawing.Point(10,$location)
            $label.Size = New-Object System.Drawing.Size(153,15)
            $label.Font = [System.Drawing.Font]::new("Consolas",10)
            $label.ForeColor = 'YELLOW'
            $label.Text = $required.$_[0]
            [void]$line.add($label)

            if($_ -eq 'c'){
                gerwalk -h 52657374726963742066756C6C20646562756767696E672061636365737320776974682061646D696E2070617373776F7264
                $checkm = New-Object System.Windows.Forms.Checkbox
                $checkm.Location = New-Object System.Drawing.Size(200,$location)
                $checkm.Size = New-Object System.Drawing.Size(530,25)
                $checkm.Checked = $true
                $checkm.ForeColor = 'YELLOW'
                $checkm.Text = $dyrl_PT
                [void]$line.add($checkm)
            }
            else{
                $text = New-Object System.Windows.Forms.TextBox
                $text.Location = New-Object System.Drawing.Point(200,$location)
                $text.Size = New-Object System.Drawing.Size(530,20)
                $text.Font = [System.Drawing.Font]::new("Consolas",11)
                $text.Text = $defaults.$_
                [void]$line.add($text)
            }

            [void]$cfgfields.add($line)

            $line | %{ $cfgwiz.Controls.Add($_) }

            $location = $location + 30

        }
    }

    $confirm = New-Object System.Windows.Forms.Button
    $confirm.Location = New-Object System.Drawing.Point(275,310)
    $confirm.Size = New-Object System.Drawing.Size(250,30)
    $confirm.ForeColor = 'YELLOW'
    $confirm.BackColor = 'BLUE'
    $confirm.Text = 'CONFIRM SETTINGS'
    $confirm.Add_Click({
        $Script:clicked = $true
        if($tiers){
            $tr1 = $tierfields[0]
            $tr2 = $tierfields[1]
            $tr3 = $tierfields[2]
            $ta1 = $tierfields[3]
            $ta2 = $tierfields[4]
            $ta3 = $tierfields[5]
            if($tr1[2].Checked){$tr1c='true'}else{$tr1c='false'}
            if($tr2[2].Checked){$tr2c='true'}else{$tr2c='false'}
            if($tr3[2].Checked){$tr3c='true'}else{$tr3c='false'}
            if($ta1[2].Checked){$ta1c='true'}else{$ta1c='false'}
            if($ta2[2].Checked){$ta2c='true'}else{$ta2c='false'}
            if($ta3[2].Checked){$ta3c='true'}else{$ta3c='false'}
            $list.add('tr1',@("$($tr1[1].Text)",$tr1c))
            $list.add('tr2',@("$($tr2[1].Text)",$tr2c))
            $list.add('tr3',@("$($tr3[1].Text)",$tr3c))
            $list.add('ta1',@("$($ta1[1].Text)",$ta1c))
            $list.add('ta2',@("$($ta2[1].Text)",$ta2c))
            $list.add('ta3',@("$($ta3[1].Text)",$ta3c))
        }
        else{
            $repo1 = $cfgfields[0]
            $repo2 = $cfgfields[1]
            $blacklist = $cfgfields[2]
            $content = $cfgfields[3]
            $logs = $cfgfields[4]
            if($blacklist[1].Checked){ $blist = returnDefault dbg }
            else{ $blist = returnDefault -b }
            $bl0 = $blist[0]
            $dbg = [string]$blist[1]
            if($logs[1].Text -eq 'keep'){ $log = returnDefault log }
            else{ $log = $logs[1].Text }
            if($content[1].Text -eq 'keep'){ $con = returnDefault con }
            else{ $con = $content[1].Text }
            $list.Add('cre',$repo1[1].Text)
            $list.Add('hre',$repo2[1].Text)
            $list.Add('log',$log)
            $list.Add('con',$con)
            $list.Add('bl0',$bl0)
            $list.Add('dbg',$dbg)
        }
        $cfgwiz.Close()
    })
    $cfgwiz.Controls.Add($confirm)
    $a = $cfgwiz.ShowDialog()

    if(-not $clicked){Exit}
    else{ rv clicked -Scope Script; Return $list }
}
function addDefaults($current=$null){
    $add = mkList; $z=$null
    $t = 'CUSTOM CONFIGURATIONS (use CTRL+ENTER to add a new line)'
    $i = @('Once per line, enter a 3-character index and the value it references, separated with ":::"',
        'Example -- abc:::https://www.google.com') -Join "`n"
    while($z -ne 'n'){
        w 'Do you want to enter additional default configurations? ("n" to finish) ' g -i
        $z = Read-Host
        if($z -ne 'n'){
            $gb = getBlox -t $t -i $i -p $current
            $gb -Split "`n" | %{
                if($_ | sls ":::"){ [void]$add.add($_) }
            }
        }
    }
    if($add.count -eq 0){ $add = $false }
    Return $add
}
function returnDefault($ix,[switch]$bdis){
    if($bdis){
        $r = @("bm9fbmVlZDRibGFja2xpc3Qu",'0')
    }
    else{
        $conf = @{
            'dbg'=@("$(setLocal -i)",'1');
            'cre'='none';
            'hre'='none';
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
        w '(Enter "none" to skip this tier) ' g -i
        $z = Read-Host
    }
    if($z -eq 'g'){
        $l = 2
        w "Tier $($t[2])`: Enter the group-policy name: " g -i
        $z = Read-Host
        $members = e_ $z
        #Return @($members,$l)
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
    if($on){ Return (gerwalk ($(gerwalk "$bside$dyrl_SCF" -h -e) * 2) -e).Substring(0,$eside) }
    gerwalk $bside.Substring($eside)
    Return $(($dyrl_PT -split '\D\D' | ?{$_ -Match '\d'} | %{chr $_} ) -join '' -replace '[^\w=/\.]')
}
function upWrite($n,$conf,$o_file=$dyrl_SCF,[switch]$ex,[switch]$xe,[switch]$fin){
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
        $d = "$(gerwalk -e $d)"
        $master = $conf | ConvertTo-SecureString -AsPlainText -Force
        $master = "$($master | ConvertFrom-SecureString -Key $k)"
        $master = "$c$d=00$master"
    }

    $title = ' MACROSS DATA CONFIGURATION '
    $top1 = "$('#'*8)$title$('#'*9)"
    $top2 = "$('#'*10)$title$('#'*12)"

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
function addWrites($m,$maccf='MACROSS CONFIGURATION'){
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
                -b 0 -i 16 -l $maccf
        }
        elseif($k -in $gpc){
            $k = yorn -q 'This index can only be changed when updating GPO or userlists.' `
                -b 0 -i 48 -l $maccf
        }
        elseif($dyrl_CONF[$k]){
            gerwalk $dyrl_CONF.$k
            $z = yorn -q "Do you want to replace `"$dyrl_PT`"?" -b 4 -i 32 -l $maccf
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
                gerwalk -h 456E7465722061206E65772061646D696E2070617373776F7264
                $n0 = Read-Host "         $dyrl_PT" -AsSecureString
                $n1 = byter $n0
                gerwalk -h 456E74657220746865206E65772061646D696E2070617373776F726420616761696E
                $n2 = Read-Host " $dyrl_PT" -AsSecureString
                $n3 = byter $n2
                if($n1 -ne $n3){ w "$nomsg`n" y }
            }
            gerwalk 'NTk2Rjc1MjA3NzY5NkM2QzIwNkU2NTY1NjQyMDc0Njg2OTczMjA3MDY
            xNzM3Mzc3NkY3MjY0MjA2OTY2MjA3OTZGNzUyMDc3NjE2RTc0MjA3NDZGMjA2MzY4
            NjE2RTY3NjUyMDUzNEI1OTRFNDU1NDI3NzMyMDYzNkY2RTY2Njk2Nzc1NzI2MTc0N
            jk2RjZFNzMyMDZDNjE3NDY1NzIyRQ=='
            gerwalk -h $dyrl_PT
            w "`n $dyrl_PT`n`n" y
            $gnh = $n3
        }
        Return $gnh
    }
    $valid = mkList; $bar = skyWriter -b; $mod = $false
    $Global:dyrl_LOG = 'none'; $env:MACROSS = "$dyrl_MACROSS"
    $bar = " your value >$(' '*5)$bar "

    if($update -eq 0){
        gerwalk 50617373776F72647320646F206E6F74206D6174636821 -h
        $nomsg = $dyrl_PT
        $di = @($(Get-Random -Min 11111 -Max 99999),$(Get-Random -Min 11111 -Max 99999))
        $Global:N_ = $(startUp -new $di)
        $di1 = $di[0]
        $di2 = $di[1]
    }
    gerwalk "$('20'*31)534B594E455420494E495449414C205345545550" -h
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
        gerwalk $micro[0]
    }
    if($update -eq 1){ $valid = updateMAC $nap $reform }
    elseif($update -eq 2){
        $ixlabels = @{
            'cre'='Path to master MACROSS launcher (enter a custom path or "none" to disable)';
            'hre'='Path to master scripts (enter a custom path or "none" to use "cre" path)';
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
            gerwalk $_
            $hkm.add($dyrl_PT) | Out-Null
        }

        $conf = @{}; $ci = 0
        $reform.keys | ?{"$_" -notIn $hkm -and $_ -notMatch "t[ar][1-3]"} | Sort | %{
            $c1 = "w~$_"
            if($_ -eq 'dbg'){ $c3 = $dyrl_BLD }
            else{
                gerwalk $reform.$_
                $c3 = $($dyrl_PT -replace ',',', ')
            }
            if($_ -in $ixlabels.keys){ $c2 = "$($ixlabels[$_])" }
            else{$ci++; $c2 = "CUSTOM CONFIGURATION VALUE $ci" }
            screenResultsAlt -h "$c2" -k "INDEX" -v $c1
            screenResultsAlt -k "VALUE" -v $c3
            screenResultsAlt -e
        }
        screenResultsAlt -e

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
            gerwalk $micro[1]
            $cl = $dyrl_PT
            $nap = $static
            $originals = @{}
            $z = $null
            foreach($ck in $conf.keys){
                if($ck -ne $cl){if($ck -in $reform.keys){
                    gerwalk $reform.$ck
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
                    try{ $newval = gerwalk -e $conf.$ck }
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
        screenResults -e
        "`n"
        $wiz = wizard
        "`n"
        $custom = addDefaults
        "`n"
        $tr = runUserTier -i

        if($custom){
            foreach($ckv in $custom){
                $ckv = $ckv -Split ':::'
                $customk = $ckv[0]
                $customv = gerwalk -e $ckv[1]
                [void]$valid.add("$customk$customv")
            }
        }

        $required = @{
            'mac' = gerwalk -e "$(in_ $nap)";
            'di1' = gerwalk -e $di1;
            'di2' = gerwalk -e $di2;
            'tr1' = gerwalk -e $tr.tr1;
            'tr2' = gerwalk -e $tr.tr2;
            'tr3' = gerwalk -e $tr.tr3;
            'ta1' = gerwalk -e $tr.ta1;
            'ta2' = gerwalk -e $tr.ta2;
            'ta3' = gerwalk -e $tr.ta3
        }
        @(
            'cre',
            'hre',
            'bl0',
            'con',
            'dbg',
            'log'
            ) | %{ $required.add($_,$(gerwalk -e $wiz.$_)) }

        $required.keys | %{ [void]$valid.add("$_$($required.$_)") }
    }
    if($mod){
        w "`n Formatting and encrypting configurations...`n" g
        gerwalk QEBA
        upWrite -n $nap -c $($valid -Join "$dyrl_PT") -f
    }
}
function runContinue($continue=$null,[switch]$update){
    gerwalk PTAw
    function e_(){
        $e = @('ERROR','Config unreadable')
        errLog $e[0] $e[1]
        w "$($e -Join ": ") " -b r -f k
        Return $null
    }
    function u_($fn='corrupted.deleteme'){
        Move-Item -Path $dyrl_CONFIG[0] -Destination "$($dyrl_CONFIG[0])`.$fn" -Force
        Copy-Item -Path $dyrl_CONFIG[1] -Destination $dyrl_CONFIG[0] -Force
        if(-not $update){
            w "NOTICE: MACROSS config reverted to default. Please wait while I rebuild the config... `n" -b y -f k
            slp 3
            runContinue $continue
        }
    }
    if($update){ u_ "old.$(Get-Date -f 'mm-ss')"; Return }
    if((Get-Content $dyrl_CONFIG[0])[0].length -gt 48){ upWrite -x }
    $raw = ((Get-Content -Path $dyrl_CONFIG[0] | Select -Skip 1) -Join '').Trim()
    $raw = localReadP $raw
    if($raw | sls $dyrl_PT){$divraw = $raw -Split $dyrl_PT}
    else{ u_ }
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
            w 'Does this look correct? (y/n) ' g -i
            $affirm = Read-Host
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
    function rt_($1,[switch]$save){
        $sl = @{}
        foreach($tk in ($1.keys | sort)){
            $glkup = $1.$tk[1]
            $gval = $1.$tk[0]
            $tr = [int]$tk.substring(2)
            if($tk -Like "ta*"){ $type = 'admin' }
            else{ $type = 'user' }
            if($glkup -eq 'true'){
                $g = $(findUsers $gval)
                $confirm = confirmUsers $g $type $tr
                if($confirm){ $confirm = $confirm -Join ',' }
            }
            else{ $confirm = [array]($gval -replace ', ',',') }
            if($confirm){ $sl.add($tk,$confirm) }
            else{ $sl = $false; Break }
        }
        Return $sl
    }
    gerwalk 'U0tZTkVUIGNhbiB1c2UgYmFzaWMgYWNjZXNzIGNvbnRyb2wgZm9yIHlvdXIgYXV0b21hdGl
    vbnMuIFlvdSBoYXZlIHR3byBvcHRpb25zIHRvIGNyZWF0ZSBhY2Nlc3MgbGlzdHM6IDEgLSBZb3UgY2F
    uIGJlZ2luIHByb3ZpZGluZyB0aGUgbmFtZXMgb2YgR3JvdXAgUG9saWNpZXMgeW91ciB1c2VycyBiZWx
    vbmcgdG8gKHRoaXMgcmVxdWlyZXMgYWRtaW4gcHJpdmlsZWdlcyk7IDIgLSB5b3UgY2FuIG1hbnVhbGx
    5IGVudGVyL3Bhc3RlIHVzZXJuYW1lcy4gWW91IGNhbiBhZGQgdXNlcnMgaW4gdXAgdG8gdGhyZWUgZ3J
    vdXBzIC0gdGllcnMgMSB0aHJ1IDMuIERvIHlvdSB3YW50IHRvIHVzZSBhY2Nlc3MgY29udHJvbD8lWW9
    1IGNhbiBkbyB0aGUgc2FtZSBmb3IgYWRtaW4gdXNlcnMsIGlmIHRoZXkgaGF2ZSBzZXBhcmF0ZSBhY2N
    vdW50cyB3aXRoIGFkbWluaXN0cmF0aXZlIHByaXZpbGVnZXMuIERvIHlvdSBuZWVkIHRvIHNldCBhZG1
    pbiB1c2Vycz8='
    $yq = $dyrl_PT -Split '%'
    if($init){ $yorn = yorn -q $yq[0] -b 4 -i 32 -l 'USER ROLES' }
    elseif(-not $update){ $yorn = 'Yes' }
    w "`n"
    $array = @{}
    if($yorn -eq 'No'){
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
        $valid = $false
        while(-not $valid){
            $tierlists = wizard -t
            $array = rt_ $tierlists
            if($array){ $valid = $true }
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
        gerwalk -h $_
        w "$mu`. $dyrl_PT" g
        $mu++
    }
    w 'or "q" to quit.' g
    while($select -notIn @(1,2,3,'q')){
        w "`n   Selection: " g -i
        $select = Read-Host
    }
    if($select -eq 'q'){ Return }
    if($select -eq 3){
        foreach($tv in @('tr1','tr2','tr3','ta1','ta2','ta3')){
            try{
                gerwalk $upconf.$tv
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
                        $upconf[$z] = $(gerwalk -e $tu[1]); $chg++; $upconf['uac'] = $(gerwalk -e "1")
                    }
                }
            }
            if($chg -eq 0){ Return }
            $newcon = mkList
            $upconf.keys | %{$newcon.add("$_$($upconf[$_])") | Out-Null }
            gerwalk QEBA
            upWrite -n $actual -c "$($newcon -join $dyrl_PT)" -f
            w 'If you are controlling the configuration for multiple users, you need to export' y
            w 'your configuration (type "export" in the main menu). Users need to place your' y
            w "exported file in their corefuncs folder.`n`n`n" y
        }
    }
    else{ runStart -u $select -s $actual }
}





















