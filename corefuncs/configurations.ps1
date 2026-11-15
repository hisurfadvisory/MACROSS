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
function updateSKY($new,$old){
    $current_conf = mkList
    $current_conf.add("sky$(gerwalk -e $new)") | Out-Null
    $old.keys | %{
        if($_ -ne 'sky'){$current_conf.add("$_$($old.$_)") | Out-Null}
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

    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Location = New-Object System.Drawing.Point(10,400)
    $textbox.Size = New-Object System.Drawing.Size(200,12)
    $textbox.Visible = $true
    $form.Controls.Add($textbox)

    $addButton = New-Object System.Windows.Forms.Button
    $addButton.Location = New-Object System.Drawing.Point(225,400)
    $addButton.Size = New-Object System.Drawing.Size(175,23)
    $addButton.Text = '<- Add an unlisted user ("none" to clear)'
    $form.Controls.Add($addButton)

    $addButton.Add_Click({
        $newUser = $textbox.Text
        if( $ulist -notContains $newUser ){
            [void]$checkedlist.Items.Add($newUser)
            [void]$checkedlist.Items[$checkedlist.Items.Count - 1].SubItems.Add($newUser)
            $checkedlist.Items[$checkedlist.Items.Count - 1].Checked = $true
        }
    })


    [void]$form.Controls.Add($checkedlist)
    $form.Topmost = $true
    $form.Add_Shown({$checkedlist.Select()})
    $formResult = $form.ShowDialog()

    if($formResult -eq [System.Windows.Forms.DialogResult]::OK){
        $confirmed = mkList
        for($i = 0; $i -lt $checkedlist.Items.Count; $i++){
            if ($checkedlist.Items[$i].Checked -eq $true) {
                $add_user = [string]$checkedlist.Items[$i].SubItems[0].Text
                if($add_user -eq 'none'){ Return $false }
                else{ [void]$confirmed.Add($add_user) }
            }
        }
        Return $confirmed
    }
    else{
        Return $false
    }

}
function wizard([switch]$tiers,[string]$adminpw){
    $list = @{}
    if(-not $tiers){
        $required = @{
            'a'=@('Default Python','ICAgU2V0IGEgY3VzdG9tIGRlZmF1bHQgcGF0aCB0byB0aGUgcHl0aG9uIGV4ZWN1dGFibGUKICAgeW91IHdpc2ggdG8gdXNlLiBNQUNST1NTIHdpbGwgaW5jbHVkZSBpdCBhbG9uZyB3aXRoCiAgIGFueSBzeXN0ZW0gcHl0aG9uIHRoYXQgaXMgaW5zdGFsbGVkIG9uIHRoZSBzeXN0ZW0gc28KICAgdGhhdCB5b3VyIGF1dG9tYXRpb25zIGNhbiBzZWxlY3QgdGhlIGFwcHJvcHJpYXRlIG9uZS4=');
            'b'=@('AI URL','ICAgVGhlIGJhc2UgVVJMIGZvciB5b3VyIEFJIHNlcnZpY2UvQVBJ')
            'c'=@('Debugging restricted','ICAgUkVTVFJJQ1QgQ09NTUFORFM6IEFsbCB1c2VycyBoYXZlIGFjY2VzcyB0byB0aGUgZGVidWdnZXIgKHNvIAogICB0aGF0IGFueW9uZSBjYW4gd3JpdGUgYXV0b21hdGlvbnMgdGhhdCB0aGV5IGNhbiB0ZXN0IGFuZCBhZGQgdG8gCiAgIFNLWU5FVCkuIFRoZSBkZWZhdWx0IHdpbGwgcmVxdWlyZSB0aGUgYWRtaW4gcGFzc3dvcmQgdG8gdXNlCiAgIGNlcnRhaW4gY29tbWFuZHMgJiBmdW5jdGlvbi4gVW5jaGVjayB0byBkaXNhYmxlIHJlc3RyaWN0aW9uLg==');
            'd'=@('Content path','ICAgQ09OVEVOVCBQQVRIOiBZb3UgY2FuIHNwZWNpZnkgYSBzaGFyZS9zZXJ2ZXIgd2hlcmUgY29udGVudCANCiAgIG9yIGVucmljaG1lbnQgZmlsZXMgKGpzb24sIHhtbCwgY3N2LCBldGMuKSBjYW4gYmUgcmVndWxhcmx5IA0KICAgYWNjZXNzZWQgYnkgU0tZTkVUIGh1bnRlciBzY3JpcHRzLiBUaGUgZGVmYXVsdCBpcyBTS1lORVQncw0KICAgbG9jYWwgcmVzb3VyY2VzIGZvbGRlci4=');
            'e'=@('Logs folder','ICAgU0tZTkVUIExPR1M6IEVudGVyIGEgbG9jYXRpb24gZm9yIFNLWU5FVCB0byB3cml0ZSBsb2dzIHRvLiAKICAgVGhlIGRlZmF1bHQgbG9jYXRpb24gaXMgaW4gU0tZTkVUJ3MgbG9jYWwgcmVzb3VyY2VzIGZvbGRlci4KICAgRW50ZXIgIm5vbmUiIHRvIGRpc2FibGUgbG9nZ2luZy4=');
            'f'=@('Log server','ICAgU0VJTS9Mb2cgc2VydmVyOiBFbnRlciBhIDxob3N0bmFtZXxpcD46cG9ydCB2YWx1ZSB0byBlbmFibGUKICAgc2VuZGluZyBNQUNST1NTIGxvZ3MgdG8geW91ciBsb2cgY29sbGVjdG9yLiBJZiB5b3Ugc2V0ICJMb2dzCiAgIEZvbGRlciIgdG8gIm5vbmUiLCB0aGlzIHdpbGwgYmUgaWdub3JlZC4=');
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
    Add-Type -AssemblyName System.Drawing
    $icon = [System.Drawing.Image]::FromStream([IO.MemoryStream]::new([Convert]::FromBase64String($icon64))); rv icon64
    $bg = [System.Drawing.Image]::FromStream([IO.MemoryStream]::new([Convert]::FromBase64String($bg64))); rv bg64,hnr
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
        $itxt = 'Enter comma-separated usernames, OR a single GPO name per field.'
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
            'f'='none';
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

        ## Team passphrase (required): protects key recovery/enrollment for kawamoriNG.
        ## CONFIRM SETTINGS stays disabled until it's valid.
        $tpRows = foreach($t in 'Team passphrase','Confirm passphrase'){
            $label = New-Object System.Windows.Forms.Label
            $label.Location = New-Object System.Drawing.Point(10,$location)
            $label.Size = New-Object System.Drawing.Size(180,15)
            $label.Font = [System.Drawing.Font]::new("Consolas",10)
            $label.ForeColor = 'YELLOW'
            $label.Text = $t
            $cfgwiz.Controls.Add($label)
            $box = New-Object System.Windows.Forms.TextBox
            $box.Location = New-Object System.Drawing.Point(200,$location)
            $box.Size = New-Object System.Drawing.Size(300,20)
            $box.Font = [System.Drawing.Font]::new("Consolas",11)
            $box.UseSystemPasswordChar = $true
            $cfgwiz.Controls.Add($box)
            $location = $location + 30
            $box
        }
        $tp1 = $tpRows[0]; $tp2 = $tpRows[1]
        $tpStatus = New-Object System.Windows.Forms.Label
        $tpStatus.Location = New-Object System.Drawing.Point(515,($location - 58))
        $tpStatus.Size = New-Object System.Drawing.Size(270,52)
        $tpStatus.Font = [System.Drawing.Font]::new("Consolas",9)
        $tpStatus.ForeColor = 'ORANGE'
        $cfgwiz.Controls.Add($tpStatus)
        $checkTp = {
            $p = $tp1.Text
            if($p.Length -lt 12){ $msg = "Needed to enroll local accounts and recover keys. 12+ characters ($($p.Length) so far)."; $ok = $false }
            elseif($adminpw -and $p -ceq $adminpw){ $msg = 'Must be different from the admin password.'; $ok = $false }
            elseif($p -cne $tp2.Text){ $msg = 'Type it again in "Confirm passphrase".'; $ok = $false }
            else{ $msg = 'OK. Keep it somewhere safe.'; $ok = $true }
            $tpStatus.Text = $msg
            $tpStatus.ForeColor = $(if($ok){ 'LIGHTGREEN' }else{ 'ORANGE' })
            $confirm.Enabled = $ok
        }
        $tp1.Add_TextChanged($checkTp)
        $tp2.Add_TextChanged($checkTp)
        $cfgwiz.Size = New-Object System.Drawing.Size(810,($location + 110))
    }

    $confirm = New-Object System.Windows.Forms.Button
    $confirm.Location = New-Object System.Drawing.Point(275,$(if($tiers){ 310 }else{ $location + 15 }))
    $confirm.Size = New-Object System.Drawing.Size(250,30)
    $confirm.ForeColor = 'YELLOW'
    $confirm.BackColor = 'BLUE'
    $confirm.Text = 'CONFIRM SETTINGS'
    $confirm.Add_Click({
        if(-not $tiers){
            ## Log server must be "none" (or blank) or <hostname|ip>:port
            $fwdv = "$($cfgfields[5][1].Text)".Trim()
            if($fwdv -eq ''){ $fwdv = 'none' }
            if($fwdv -ne 'none' -and $fwdv -notMatch '^[\w\.\-]+:\d{1,5}$'){
                [void][System.Windows.Forms.MessageBox]::Show(
                    "Log server must be <hostname|ip>:port (e.g. siem.corp.local:514), or `"none`".",
                    'MACROSS Configuration Wizard')
                Return
            }
        }
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
            #if($logs[1].Text -eq 'keep'){ $log = returnDefault log }
            #else{ $log = $logs[1].Text }
            $log = $logs[1].Text
            #if($content[1].Text -eq 'keep'){ $con = returnDefault con }
            #else{ $con = $content[1].Text }
            $con = $content[1].Text
            $list.Add('cre',$repo1[1].Text)
            $list.Add('hrn',$repo2[1].Text)
            $list.Add('log',$log)
            $list.Add('con',$con)
            $list.Add('bl0',$bl0)
            $list.Add('dbg',$dbg)
            $list.Add('fwd',$fwdv)          ## SIEM/log collector <host|ip>:port, or 'none'
            $list.Add('tpw',$tp1.Text)     ## team passphrase; turned into the team key by runStart, never stored
        }
        $cfgwiz.Close()
    })
    $cfgwiz.Controls.Add($confirm)
    if(-not $tiers){ & $checkTp }           ## start disabled until the team passphrase is valid
    $a = $cfgwiz.ShowDialog()

    if(-not $clicked){Exit}
    else{ rv clicked -Scope Script; Return $list }
}
function returnDefault($ix,[switch]$bdis){
    if($bdis){
        $r = @("bm9fbmVlZDRibGFja2xpc3Qu",'0')
    }
    else{
        $conf = @{
            'dbg'=@("$(setLocal -i)",'1');
            'cre'='none';
            'hrn'='none';
            'con'="$dyrl_RESOURCES";
            'log'="$dyrl_RESOURCES\logs";
            'fwd'='none'
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
        w  '(Enter "none" to skip this tier) ' g -i
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
function stringHash($string){
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($string)
    $shaBytes = $sha256.ComputeHash($bytes)
    Return $([System.BitConverter]::ToString($shaBytes) -replace '-')
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
    if($on){ Return (gerwalk ($(gerwalk "$bside`macross.conf" -h -e) * 2) -e).Substring(0,$eside) }
    gerwalk $bside.Substring($eside)
    Return $(($dyrl_PT -split '\D\D' | ?{$_ -Match '\d'} | %{chr $_} ) -join '' -replace '[^\w=/\.]')
}
## LEGACY (v1) config writer. Only used to repair a v1 config so it can be read and migrated;
## all new writes go through upWrite -> confSave_ (see "CONFIG PROTECTION v2" below).
function upWriteLegacy_($n,$conf,$o_file='macross.conf',[switch]$xe,[switch]$fin){
    function wut_($1){
        errMsg -f 'MACROSS.upWrite' "upWrite: $1"
        $error[0]
        varCleanup -c
        Exit
    }
    function bkup_(){
        if(Test-Path $ofile){
            $rename = $(Get-Date -f "yyMMdd-HHmmss")
            $b_file = Join-Path (Split-Path $ofile) "$rename`_$o_file`.backup"
            Copy-Item -Path $ofile -Destination $b_file
        }
    }
    function add_($10){
        Return $add[$(Get-Random -Min 0 -Max $10)]
    }

    $selected_choice = $false
    $ofile = "$dyrl_MACROSS\corefuncs\$o_file"
    $sfile = "$dyrl_OUTFILES\$o_file"
    $sdc = "$('#'*8) MACROSS DATA CONFIGURATION $('#'*9)"
    $dbt = "$('#'*10)   DEFAULT BASE TEMPLATE   $('#'*13)"
    $dfc = $dyrl_CONFIG[1]
    $template_m = @(
        $dbt,
        "Initialized: $(Get-Date -f 'yyyy.MM.dd hh:mm:ss')",
        "MACROSS Version: $dyrl_VERSION",
        "Python: $dyrl_PYVERS"
    )

    if($xe){
        w 'Reading template...' g
        try{
            $versioned = $(Get-Content -Stream $dfc -Path $ofile -ErrorAction Stop | Select -First 5)
            $selected_choice = ((Get-Content -Stream $dfc -Path $ofile -ErrorAction Stop | Select -Skip 5) -Join '').Trim()
        }
        catch{
            w 'There are no templates to load. Starting setup wizard...' y
            if(Test-Path $ofile){ Remove-Item $ofile -Force }
            wizard
        }
    }
    else{ bkup_ }
    if(! $selected_choice){
        $add = (alphanum)[0]
        $c,$d = '',''
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
        $default = $conf | ConvertTo-SecureString -AsPlainText -Force
        $default = "$($default | ConvertFrom-SecureString -Key $k)"
        $selected_choice = "$c$d=00$default"
        $default = blockWriter -b "$selected_choice" -m 50 -n
        $id = stringHash $default
        $template_m += "Signature: $id"
        $versioned = $template_m
        $template_m += $default; $template_m = $template_m -Join "`n"
        $versioned[0] = $sdc
    }

    $selected_choice = localWriteP "$selected_choice"
    $sc = blockWriter -b "$selected_choice" -m 45 -n
    $versioned += $sc
    Set-Content -Path $ofile -Value $($versioned -Join "`n")

    if(! (Test-Path -Path $ofile)){
        wut_ "Unknown error: failed to create new $o_file file"
    }
    if($xe){ Return }
    Set-Content -Path $ofile -Stream $dfc -Value $template_m
    w "`n`n Setup is complete. Run the MACROSS.ps1 script to start MACROSS.`n" g
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
    $k = 'k'; $v,$z = $null,$null
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
            gerwalk $dyrl_CONF.$k
            $z = yorn -q "Do you want to replace `"$dyrl_PT`"?" -b 4 -i 32 -l $skycf
            if($z -eq 'No'){ $k = $null }
            else{ $modified = $true }
        }

    }
    if($modified -and -not $v){
        w "`n Enter the value you want to set for this index:`n > " g -i
        $z = Read-Host
        if($z -eq 'keep'){ $v = returnDefault $k }
        else{ $v = "$z" }
    }
    errLog INFO 'MACROSS.addWrites' "Config $k was updated"
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
    $valid = mkList; $bar = battroid -b; $mod = $false
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
    if($update -eq 1){ $valid = updateSKY $nap $reform }
    elseif($update -eq 2){
        $ixlabels = @{
            'cre'='URL for your code repository';
            'hrn'='URL for your AI services/API';
            'con'='Content files (enter a custom location or "keep" to set the default)';
            'dbg'='Debugging is restricted ("keep" to restrict or "none" to disable)';
            'log'='Path to logs (enter custom path, "keep" for default or "none" to disable)';
            'fwd'='SIEM/log server for forwarded logs (<hostname|ip>:port, or "none" to disable)'
        }
        $ulabels = @{
            'r'='users';
            'a'='admins'
        }
        $hkm = mkList
        $micro | %{
            gerwalk $_
            [void]$hkm.add($dyrl_PT)
        }

        $conf = @{}; $ci = 0
        $reform.keys | ?{"$_" -notIn $hkm -and $_ -notMatch "t[ar][1-3]" -and $_ -notIn @('tpk','tsk')} | Sort | %{
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
                $new = addWrites -m @(@('uac','tpk','tsk') + $hkm)   ## decoded names: sky,bl0,di1,di2,uac (+ team key, managed by option 4)
                if($new[2]){
                    $mod = $new[2]
                    $conf.add($new[0],$new[1])
                    if($new[3] -and $new[4]){ $conf.add($new[3],$new[4]) }
                    w "$($new[0]) update pending..." c
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
                ## Update exsiting config values
                foreach($ck in $reform.keys){
                    try{ $newval = gerwalk -e $conf.$ck }
                    catch{ $newval = $reform.$ck }
                    $newconfs.add($ck,$newval)
                }
                ## Add new config keys
                foreach($ck in $conf.keys){
                    if($ck -notIn $newconfs.keys){
                        $newval = gerwalk -e $conf.$ck
                        $newconfs.add($ck,$newval)
                    }
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
        $wiz = wizard -adminpw $nap
        "`n"
        $tr = runUserTier -i

        $required = @{
            'sky' = gerwalk -e "$(in_ $nap)";
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
            'hrn',
            'bl0',
            'con',
            'dbg',
            'log',
            'fwd'
            ) | %{ $required.add($_,$(gerwalk -e $wiz.$_)) }

        ## Team passphrase for protected keys (kawamoriNG), set here so it's chosen by the admin
        ## Team key from the passphrase entered in the setup form (the form requires 12+ characters)
        $tpw = "$($wiz.tpw)"
        if($tpw.Length -ge 12){
            w ' Creating the team key...' g
            $tpb = kngUtf8_ $tpw
            try{ $team = kngTeamCreate_ $tpb }
            catch{
                $team = $null
                w " The team key could not be created: $($_.Exception.Message)" r
                w ' Setup will continue; set the team passphrase later from config > 4. Hit ENTER.' y
                Read-Host | Out-Null
            }
            finally{ kngWipe_ $tpb; Remove-Variable tpw }
        }
        else{ $team = confTeamNew_ $nap }       ## (form not used, e.g. scripted setup)
        if($team){ $required['tpk'] = $team.tpk; $required['tsk'] = $team.tsk }

        $required.keys | %{ [void]$valid.add("$_$($required.$_)") }
    }
    if($mod){
        w "`n Formatting and encrypting configurations...`n" g
        gerwalk QEBA
        ## $static is the admin password entered to open the config menu (the old password when changing it)
        upWrite -n $nap -c $($valid -Join "$dyrl_PT") -f -oldpass $static
    }
}
function runContinue($continue=$null,[switch]$update){
    function e_(){
        $e = @('ERROR','Config unreadable')
        errLog $e[0] $e[1]
        w "$($e -Join ": ") " -b r -f k
        Return $null
    }
    function u_($fn='corrupted.deleteme'){
        Copy-Item -Path $dyrl_CONFIG[0] -Destination "$($dyrl_CONFIG[0])`.$fn" -Force
        if(-not $update){
            w "NOTICE: MACROSS config is corrupted. Please wait while I attempt to rebuild it... `n" -b y -f k
            upWriteLegacy_ -x
            slp 3
            Return $true    ## rebuilt; caller re-reads the config
        }
        Return $false
    }
    if($update){ [void](u_ "old.$(Get-Date -f 'mm-ss')"); Return }
    gerwalk PTAw
    $raw = ((Get-Content -Path $dyrl_CONFIG[0] | Select -Skip 5) -Join '').Trim()
    $raw = localReadP $raw
    if($raw | sls $dyrl_PT){$divraw = $raw -Split $dyrl_PT}
    elseif(-not $script:rebuilt_ -and (u_)){
        ## Only try rebuilding once so a config that can't be repaired doesn't loop forever
        $script:rebuilt_ = $true
        try{ Return (runContinue $continue) }
        finally{ Remove-Variable rebuilt_ -Scope Script -ErrorAction SilentlyContinue }
    }
    else{ Return (e_) }
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
            w  'Does this look correct? (y/n) ' g
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
    elseif($update -and $update -in $dyrl_CONF.keys){
        if($update -Like "ta*"){ $cu = 'admin' }
        else{ $cu = 'user' }
        [int]$ti = $($update -replace "\D")
        gerwalk $dyrl_CONF.$update
        $compare1 = $dyrl_PT
        $current = $compare1 -Split ','
        $compare2 = confirmUsers $current $cu $ti
        if($compare2){ $array = $($compare2 -Join ',') }
        else{ $array = $null }
    }
    else{
        while($true){
            $tierlists = wizard -t
            $array = rt_ $tierlists
            if($array){ Break }
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
    w "4. $(if($upconf['tpk']){ 'Change team passphrase / create new team key' }else{ 'Set up the team passphrase (needed before keys can be created)' })" g
    w 'or "q" to quit.' g
    while($select -notIn @(1,2,3,4,'q')){
        w "`n   Selection: " g -i
        $select = Read-Host
    }
    if($select -eq 'q'){ Return }
    if($select -eq 4){ confTeamMenu_ $actual; Return }
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
            while($z -ne 'f'){
                w 'Enter the index to update (ex. "ta2" for tier 2 admins), or "f" to finish: ' g -i
                $z = Read-Host
                if($z -Match "t[ar]\d"){
                    $tu = runUserTier -u $z
                    if($tu[1]){
                        $upconf[$z] = $(gerwalk -e $tu[1]); $chg++; $upconf['uac'] = $(gerwalk -e "1")
                        w "Updated $z`." g
                    }
                }
            }
            if($chg -eq 0){ Return }
            $newcon = mkList
            $upconf.keys | %{[void]$newcon.add("$_$($upconf[$_])")}
            gerwalk QEBA
            upWrite -n $actual -c "$($newcon -join $dyrl_PT)" -f
        }
    }
    else{ runStart -u $select -s $actual }
}



################################################################################################
##                                CONFIG PROTECTION v2
##
## macross.conf (and a central copy, if site.ps1 sets one) is stored as:
##     ### MACROSS CONFIG v2 ###
##     { JSON: data = the settings, encrypted once with a random key (AES-256 + HMAC tamper check),
##             slots = copies of that key, each unlockable a different way }
##
##   machine  Windows DPAPI, machine scope: any account on this computer, no AD or profile
##            needed. Always present in a local config (and in the local cache of a central one).
##   domain   DPAPI-NG to the tier groups from site.ps1 plus any domain accounts in the tier
##            lists: tier members can read it from any domain computer (survives VDI rebuilds).
##   pass     the MACROSS admin password (PBKDF2). Always present; used for config changes and
##            for recovery (e.g. after a machine rebuild, the next start asks for it once and
##            adds a new machine slot).
##   signkey  optional: the admin's RSA signing key, locked with the admin password. When
##            site.ps1 has an AdminPubKey, configs without a valid admin signature are refused.
##
## The admin password check is "can it unlock the pass slot" -- no password hash is stored.
## Legacy (v1) configs keep loading the old way until the admin password is entered (startup
## prompt or the config menu); they are then upgraded and the old file is kept as a backup
## (without its unprotected alternate data stream).
##
## Uses the crypto helpers in kawamoring.ps1.
################################################################################################

function confHeader_(){ '### MACROSS CONFIG v2 ###' }

## Ask the admin for a new team passphrase and create the team key pair (see kawamoring.ps1).
## Returns @{tpk;tsk} config values, or $null if skipped. $adminpw is only used to warn when
## the same password is reused.
function confTeamNew_([string]$adminpw,[switch]$replacing){
    w "`n TEAM PASSPHRASE" c
    w ' Protected keys (kawamoriNG) are created with a team key, so analysts never choose a' g
    w ' passphrase themselves. The team passphrase you set here is only needed to give' g
    w ' access to local/non-AD accounts (enroll) and to recover keys. Keep it somewhere safe,' g
    w ' and use something different from the admin password.' g
    if($replacing){ w ' A NEW team key will be created: run "kawamoriNG all -rewrap" afterwards to move every key to it.' y }
    while($true){
        $a = kngReadPass_ 'New team passphrase (12+ characters; ENTER to skip for now)'
        if($a.Length -eq 0){
            w ' Skipped. Keys can''t be created until a team passphrase is set (config > 4).' y
            Return $null
        }
        if($a.Length -lt 12){ w ' The team passphrase must be at least 12 characters.' y; kngWipe_ $a; Continue }
        if($adminpw -and [Text.Encoding]::UTF8.GetString($a) -ceq $adminpw){
            w ' Please use a different passphrase from the admin password.' y; kngWipe_ $a; Continue
        }
        $b = kngReadPass_ 'Enter the team passphrase again'
        if(-not (kngSame_ $a $b)){ w ' The passphrases do not match.' y; kngWipe_ $a; kngWipe_ $b; Continue }
        kngWipe_ $b
        w ' Creating the team key...' g
        try{ Return (kngTeamCreate_ $a) }finally{ kngWipe_ $a }
    }
}

## Config menu option 4: change the team passphrase (same team key, nothing else to update),
## or create a new team key (forgotten passphrase, or someone who knew it has left).
function confTeamMenu_([string]$adminpw){
    gerwalk QEBA; $sep = $dyrl_PT
    $conf = @{}; foreach($k in $dyrl_CONF.Keys){ $conf[$k] = $dyrl_CONF[$k] }
    if(-not $conf['tpk'] -or -not $conf['tsk']){
        w "`n No team passphrase has been set up yet." y
        $team = confTeamNew_ $adminpw
        if(-not $team){ Return }
        $conf['tpk'] = $team.tpk; $conf['tsk'] = $team.tsk
    }
    else{
        w "`n 1. Change the team passphrase (keys keep working; nothing else to update)" g
        w ' 2. Create a NEW team key (forgotten passphrase, or someone who knew it has left)' g
        w ' or "q" to go back.' g
        $c = $null
        while($c -notIn @('1','2','q')){ $c = Read-Host "`n   Selection" }
        if($c -eq 'q'){ Return }
        if($c -eq '1'){
            $priv = $null
            for($i = 1; $i -le 3 -and -not $priv; $i++){
                $old = kngReadPass_ "Current team passphrase (attempt $i of 3)"
                try{ $priv = kngTeamOpen_ $old $conf['tsk'] }finally{ kngWipe_ $old }
                if(-not $priv){ w ' That is not the team passphrase.' y }
            }
            if(-not $priv){ w ' Forgot it? Choose option 2 to create a new team key.' y; Return }
            try{
                while($true){
                    $a = kngReadPass_ 'New team passphrase (12+ characters)'
                    if($a.Length -lt 12){ w ' The team passphrase must be at least 12 characters.' y; kngWipe_ $a; Continue }
                    $b = kngReadPass_ 'Enter it again'
                    if(kngSame_ $a $b){ kngWipe_ $b; Break }
                    w ' The passphrases do not match.' y; kngWipe_ $a; kngWipe_ $b
                }
                $conf['tsk'] = kngTeamSeal_ $priv $a
                kngWipe_ $a
            }
            finally{ kngWipe_ $priv }
            try{ errLog INFO 'MACROSS.config' "Team passphrase changed by $env:USERDOMAIN\$env:USERNAME" }catch{ }
        }
        else{
            $team = confTeamNew_ $adminpw -replacing
            if(-not $team){ Return }
            $conf['tpk'] = $team.tpk; $conf['tsk'] = $team.tsk
            try{ errLog WARN 'MACROSS.config' "New team key created by $env:USERDOMAIN\$env:USERNAME; keys need kawamoriNG all -rewrap" }catch{ }
            w "`n After MACROSS restarts, run:  kawamoriNG all -rewrap" y
            w ' (from an account that can open the keys: a tier member, or an enrolled account).' y
        }
    }
    upWrite -n $adminpw -c (($conf.Keys | %{ "$_$($conf[$_])" }) -join $sep) -f
}
## "Last saved" stamp, covered by the admin signature. Plain digits (UTC yyyyMMddHHmmssfffffff)
## on purpose: PowerShell 7's ConvertFrom-Json turns ISO date strings into DateTime objects,
## which would change the signed text when the file is read back.
function confStamp_(){ [DateTime]::UtcNow.ToString('yyyyMMddHHmmssfffffff') }

## Where things live. site.ps1 ($dyrl_SITE) can set a central ConfigPath.
function confPaths_(){
    $local = $dyrl_CONFIG[0]
    $central = $null
    if($Global:dyrl_SITE -and $dyrl_SITE.ConfigPath){ $central = "$($dyrl_SITE.ConfigPath)" }
    [pscustomobject]@{
        local     = $local
        central   = $central
        cache     = "$local.cache"
        overrides = Join-Path (Split-Path $local) 'macross.local.json'
    }
}
function confIsV2_([string]$file){
    try{
        $sr = New-Object IO.StreamReader($file)
        try{ Return ($sr.ReadLine() -eq (confHeader_)) }finally{ $sr.Dispose() }
    }
    catch{ Return $false }
}
function confExists_(){
    $p = confPaths_
    if($p.central){ Return ((Test-Path -PathType Leaf $p.central) -or (Test-Path -PathType Leaf $p.cache) -or (Test-Path -PathType Leaf $p.local)) }
    Return (Test-Path -PathType Leaf $p.local)
}
function confRead_([string]$file){
    $raw = [IO.File]::ReadAllText($file)
    $parts = $raw -split "`r?`n",2
    if($parts[0].Trim() -ne (confHeader_) -or $parts.Count -lt 2){ throw "$file is not a v2 MACROSS config" }
    $o = $parts[1] | ConvertFrom-Json
    $o | Add-Member -NotePropertyName '_file' -NotePropertyValue $file -Force
    Return $o
}
## Copy only the main content of a file (never its alternate data streams)
function confBackup_([string]$file,[string]$tag){
    if(-not (Test-Path -PathType Leaf $file)){ Return $null }
    $b = "$file.$tag-$(Get-Date -Format 'yyMMdd-HHmmss').backup"
    [IO.File]::WriteAllText($b,[IO.File]::ReadAllText($file))
    Return $b
}
## Replace a file completely (deleting it first also removes any alternate data streams)
function confWrite_($obj,[string]$file){
    $dir = Split-Path $file
    if($dir -and -not (Test-Path $dir)){ New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $json = $obj | Select-Object * -ExcludeProperty '_file' | ConvertTo-Json -Depth 8
    $tmp = "$file.tmp-$PID"
    [IO.File]::WriteAllText($tmp,"$(confHeader_)`n$json`n",[Text.UTF8Encoding]::new($false))
    if(Test-Path -LiteralPath $file){ Remove-Item -LiteralPath $file -Force }
    Move-Item -LiteralPath $tmp -Destination $file -Force
}

## Settings <-> plaintext. Settings are MACROSS' usual 3-letter keys -> base64 values.
function confToBytes_([hashtable]$h){ kngUtf8_ ($h | ConvertTo-Json -Compress) }
function confFromBytes_([byte[]]$b){
    $h = @{}
    ([Text.Encoding]::UTF8.GetString($b) | ConvertFrom-Json).PSObject.Properties | %{ $h[$_.Name] = "$($_.Value)" }
    Return $h
}

## Domain accounts/groups that get a domain slot: site.ps1 tier groups + domain entries in the tier lists
function confPrincipals_([hashtable]$h){
    $names = New-Object System.Collections.ArrayList
    if($Global:dyrl_SITE -and $dyrl_SITE.TierGroups){
        foreach($g in @($dyrl_SITE.TierGroups.Values)){ if("$g".Trim()){ [void]$names.Add("$g".Trim()) } }
    }
    foreach($k in 'tr1','tr2','tr3','ta1','ta2','ta3'){
        if($h[$k]){
            try{ $v = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($h[$k])) }catch{ $v = '' }
            foreach($nm in ($v -split ',')){ $nm = $nm.Trim(); if($nm -and $nm -ne 'none'){ [void]$names.Add($nm) } }
        }
    }
    $seen = @{}
    foreach($nm in $names){
        if($seen.ContainsKey($nm.ToLower())){ Continue }
        $seen[$nm.ToLower()] = $true
        $r = kngResolve_ $nm
        if($r -and $r.kind -eq 'domain'){ $r }
    }
}

function confMachineSlot_($obj,[byte[]]$dek){
    $blob = kngMachineProtect_ $dek (kngUtf8_ (kngAad_ $obj 'machine'))
    [pscustomobject][ordered]@{ type='machine'; host=[Environment]::MachineName; created=(Get-Date -Format 's'); blob=(kngB64_ $blob) }
}

## Seal/open arbitrary bytes with the admin password (used for the signing key)
function confPassSeal_($obj,[byte[]]$bytes,[byte[]]$pw,[string]$part){
    $salt = kngRandom_ 16; $iter = 600000
    $pk = kngPassKey_ $pw $salt $iter
    try{ $box = kngSeal_ $pk $bytes (kngAad_ $obj $part) }finally{ kngWipe_ $pk }
    [pscustomobject][ordered]@{ type=$part; salt=(kngB64_ $salt); iter=$iter; iv=$box.iv; ct=$box.ct; mac=$box.mac }
}
function confPassOpen_($obj,$slot,[byte[]]$pw,[string]$part){
    $pk = kngPassKey_ $pw (kngUnB64_ $slot.salt) ([int]$slot.iter)
    try{ kngOpen_ $pk $slot (kngAad_ $obj $part) }finally{ kngWipe_ $pk }
}

## Admin signature over the encrypted settings (RSA-SHA256)
function confSigBytes_($obj){ kngUtf8_ "MACROSS-CONFIG-v2|$($obj.updated)|$($obj.data.iv)|$($obj.data.ct)|$($obj.data.mac)" }
function confSign_($obj,[string]$privXml){
    $rsa = [Security.Cryptography.RSA]::Create()
    try{
        $rsa.FromXmlString($privXml)
        $s = $rsa.SignData((confSigBytes_ $obj),[Security.Cryptography.HashAlgorithmName]::SHA256,[Security.Cryptography.RSASignaturePadding]::Pkcs1)
        [pscustomobject][ordered]@{ alg='RSA-SHA256'; value=(kngB64_ $s) }
    }
    finally{ $rsa.Dispose() }
}
## $true if no signature is required, or the signature is valid
function confSigOk_($obj){
    if(-not ($Global:dyrl_SITE -and $dyrl_SITE.AdminPubKey)){ Return $true }
    if(-not $obj.sig -or -not $obj.sig.value){ Return $false }
    $rsa = [Security.Cryptography.RSA]::Create()
    try{
        $rsa.FromXmlString("$($dyrl_SITE.AdminPubKey)")
        Return $rsa.VerifyData((confSigBytes_ $obj),(kngUnB64_ $obj.sig.value),
            [Security.Cryptography.HashAlgorithmName]::SHA256,[Security.Cryptography.RSASignaturePadding]::Pkcs1)
    }
    catch{ Return $false }
    finally{ $rsa.Dispose() }
}

## Get the data key. With -password: only the pass slot (this is how the admin password is
## verified). Otherwise: domain slot, then this computer's machine slot, then (with -prompt)
## ask for the admin password. $how is set to domain/machine/pass.
function confUnlock_($obj,[string]$password,[switch]$prompt,[ref]$how,[ref]$why){
    $reasons = New-Object System.Collections.ArrayList
    if($why){ $why.Value = $reasons }
    if($password){
        $pw = kngUtf8_ $password
        try{ $dek = kngTryPass_ $obj $pw }finally{ kngWipe_ $pw }
        if($dek){ if($how){ $how.Value = 'pass' }; ,$dek }
        Return
    }
    ## A slot that opens but whose key fails the tamper check means the file was altered:
    ## report that ($how = 'altered') instead of asking for the admin password.
    $altered = $false
    $all = @($obj.slots)
    foreach($s in @($all | ?{ $_.type -eq 'domain' })){
        try{
            $dek = kngNGUnprotect_ (kngUnB64_ $s.blob)
            if(kngVerify_ $dek $obj.data (kngAad_ $obj 'data')){ if($how){ $how.Value = 'domain' }; ,$dek; Return }
            $altered = $true
        }
        catch{ [void]$reasons.Add("domain slot: $($_.Exception.Message)") }
    }
    $me = [Environment]::MachineName
    $mine = @($all | ?{ $_.type -eq 'machine' -and "$($_.host)" -eq $me })
    if(-not $mine.Count){
        $others = @($all | ?{ $_.type -eq 'machine' } | %{ "$($_.host)" })
        [void]$reasons.Add("no machine slot for $me (machine slots: $(if($others.Count){ $others -join ', ' }else{ 'none' }); slot types in file: $((@($all | %{ "$($_.type)" }) -join ',')))")
    }
    foreach($s in $mine){
        try{
            $dek = kngMachineUnprotect_ (kngUnB64_ $s.blob) (kngUtf8_ (kngAad_ $obj 'machine'))
            if(kngVerify_ $dek $obj.data (kngAad_ $obj 'data')){ if($how){ $how.Value = 'machine' }; ,$dek; Return }
            $altered = $true
        }
        catch{ [void]$reasons.Add("machine slot for ${me}: $($_.Exception.Message)") }
    }
    if($altered){ if($how){ $how.Value = 'altered' }; Return }
    if(-not $prompt){ Return }
    w "`n This computer can't open the MACROSS config on its own (new or rebuilt computer?)." y
    w "   Config: $($obj._file)" a
    foreach($r in $reasons){ w "   ($r)" a }
    try{ errLog WARN 'MACROSS.config' "Config needed the admin password on $me ($env:USERDOMAIN\$env:USERNAME): $($reasons -join '; ')" }catch{ }
    w " Enter the MACROSS admin password once to restore access (ENTER to cancel)." y
    for($i = 1; $i -le 3; $i++){
        $ss = Read-Host "  Admin password (attempt $i of 3)" -AsSecureString
        $pw = kngUtf8_ ([Net.NetworkCredential]::new('',$ss).Password)
        if($pw.Length -eq 0){ Break }
        try{ $dek = kngTryPass_ $obj $pw }finally{ kngWipe_ $pw }
        if($dek){ if($how){ $how.Value = 'pass' }; ,$dek; Return }
        w ' That password did not unlock the config.' y
    }
}

## Write the settings. New data key every save; slots are rebuilt from the current tier
## groups/lists. $password becomes the admin password (pass slot); $oldpass is only needed
## when the password is being changed and a signing key exists.
function confSave_([hashtable]$h,[string]$password,[string]$oldpass){
    if(-not $password){ throw 'The admin password is required to save the MACROSS config.' }
    $p = confPaths_
    $target = if($p.central){ $p.central }else{ $p.local }
    $existing = $null
    if((Test-Path -PathType Leaf $target) -and (confIsV2_ $target)){ $existing = confRead_ $target }

    $h = $h.Clone(); [void]$h.Remove('sky')      ## the admin password check is the pass slot now
    $obj = [pscustomobject][ordered]@{
        v=2; id='macross.conf'; created=$(if($existing){ $existing.created }else{ Get-Date -Format 's' })
        updated=(confStamp_); by="$env:USERDOMAIN\$env:USERNAME"
        data=$null; slots=@(); signkey=$null; sig=$null; _file=$target
    }
    $dek = kngRandom_ 32
    $pt = confToBytes_ $h
    $pw = kngUtf8_ $password
    $slots = New-Object System.Collections.ArrayList
    $notes = New-Object System.Collections.ArrayList
    try{
        $obj.data = kngSeal_ $dek $pt (kngAad_ $obj 'data')
        [void]$slots.Add((kngPassSlot_ $obj $dek $pw))

        $dom = @(confPrincipals_ $h)
        if($dom.Count){
            $rule = ($dom | %{ "SID=$($_.sid)" }) -join ' OR '
            try{
                [void]$slots.Add([pscustomobject][ordered]@{
                    type='domain'; rule=$rule; names=(($dom | %{ $_.name }) -join ', '); blob=(kngB64_ (kngNGProtect_ $rule $dek)) })
            }
            catch{ [void]$notes.Add("No domain slot: $($_.Exception.Message)") }
        }
        if(-not $p.central){
            try{ [void]$slots.Add((confMachineSlot_ $obj $dek)) }
            catch{ [void]$notes.Add("No machine slot: $($_.Exception.Message)") }
        }
        $obj.slots = @($slots)

        ## Admin signature (keep the existing signing key, re-locked with the current password)
        if($existing -and $existing.signkey){
            $old = if($oldpass){ kngUtf8_ $oldpass }else{ kngUtf8_ $password }
            try{ $priv = confPassOpen_ $existing $existing.signkey $old 'signkey' }
            catch{ throw 'The admin password did not unlock the config signing key; nothing was saved.' }
            finally{ kngWipe_ $old }
            try{
                $obj.signkey = confPassSeal_ $obj $priv $pw 'signkey'
                $obj.sig = confSign_ $obj ([Text.Encoding]::UTF8.GetString($priv))
            }
            finally{ kngWipe_ $priv }
        }
        elseif($Global:dyrl_SITE -and $dyrl_SITE.AdminPubKey){
            throw 'site.ps1 requires signed configs, but this config has no signing key. Remove AdminPubKey from site.ps1, save, then run confSigningKey.'
        }

        $bk = confBackup_ $target 'prev'
        confWrite_ $obj $target
        if($p.central){ confCache_ $obj $dek }
    }
    finally{ kngWipe_ $dek; kngWipe_ $pt; kngWipe_ $pw }
    foreach($n in $notes){ w " $n" y }
    if(-not $p.central -and -not @($obj.slots | ?{ $_.type -eq 'machine' }).Count){
        ## Without a machine slot this computer will ask for the admin password at every start
        w "`n WARNING: this computer could not be given its own access to the config (see above)." r
        w ' MACROSS will ask for the admin password at startup until that is fixed.' r
        try{ errLog ERROR 'MACROSS.config' "No machine slot created on $([Environment]::MachineName): $($notes -join '; ')" }catch{ }
        w ' Hit ENTER to continue.' g; Read-Host | Out-Null
    }
    if($bk){ w " Previous config saved as $bk" g }
    errLog INFO 'MACROSS.config' "Config saved to $target by $env:USERDOMAIN\$env:USERNAME (slots: $((@($obj.slots) | %{ $_.type }) -join ','); signed: $([bool]$obj.sig))"
}

## Local cached copy of the central config, with a machine slot for this computer
function confCache_($central,[byte[]]$dek){
    $p = confPaths_
    try{
        $c = $central | Select-Object * -ExcludeProperty '_file'
        $c.slots = @(@($central.slots | ?{ $_.type -ne 'machine' }) + (confMachineSlot_ $central $dek))
        confWrite_ $c $p.cache
    }
    catch{ w " Could not update the local config cache: $($_.Exception.Message)" y }
}

## Add (or replace) this computer's machine slot after an unlock with the admin password
function confAddMachineSlot_($obj,[byte[]]$dek){
    $eap = $ErrorActionPreference; $ErrorActionPreference = 'Stop'     ## surface every failure here
    try{
        $obj.slots = @(@($obj.slots | ?{ -not ($_.type -eq 'machine' -and $_.host -eq [Environment]::MachineName) }) + (confMachineSlot_ $obj $dek))
        confWrite_ $obj $obj._file
        $chk = confRead_ $obj._file
        if(-not @($chk.slots | ?{ $_.type -eq 'machine' -and $_.host -eq [Environment]::MachineName }).Count){
            throw "the file was written but has no machine slot when read back (slot types: $((@($chk.slots) | %{ "$($_.type)" }) -join ','))"
        }
        w ' Access restored for this computer.' g
    }
    catch{
        w "`n Could not save access for this computer: $($_.Exception.Message)" r
        w " (at $($_.InvocationInfo.ScriptName) line $($_.InvocationInfo.ScriptLineNumber))" a
        w ' Run confDiag from the debug menu for details. Hit ENTER to continue.' g
        try{ errLog ERROR 'MACROSS.config' "Machine slot repair failed on $([Environment]::MachineName): $($_.Exception.Message)" }catch{ }
        Read-Host | Out-Null
    }
    finally{ $ErrorActionPreference = $eap }
}

## Machine-specific settings that should not come from a central config (plain JSON, e.g.
## {"cre":"C:\\Tools\\python\\python.exe"}). Access-control keys can't be overridden.
function confOverrides_([hashtable]$h){
    $p = confPaths_
    if(-not (Test-Path -PathType Leaf $p.overrides)){ Return }
    try{
        $o = Get-Content -Raw $p.overrides | ConvertFrom-Json
        foreach($pr in $o.PSObject.Properties){
            if($pr.Name -in @('sky','di1','di2','uac','bl0','dbg','tr1','tr2','tr3','ta1','ta2','ta3','tpk','tsk')){ Continue }
            $h[$pr.Name] = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("$($pr.Value)"))
        }
    }
    catch{ w " Ignoring $($p.overrides): $($_.Exception.Message)" y }
}

## LEGACY (v1): load the old way; upgrade when the admin password is available
function confLegacy_([string]$password){
    $s = if($password){ runContinue $password }else{ runContinue $null }    ## v1 treats '' as a (wrong) password
    if(-not $s){ Return $null }
    gerwalk QEBA; $sep = $dyrl_PT
    $h = @{}
    foreach($c in ($s -split [regex]::Escape($sep))){ if($c.Length -ge 3){ $h[$c.Substring(0,3)] = $c.Substring(3) } }

    $pw = $password
    if(-not $pw -and -not $Global:dyrl_CONFASKED){
        $Global:dyrl_CONFASKED = $true      ## ask once per session
        w "`n MACROSS can upgrade its configuration protection now." c
        w " Enter the admin password to upgrade, or press ENTER to skip (you'll be asked next time)." c
        $ss = Read-Host '  Admin password' -AsSecureString
        $try = [Net.NetworkCredential]::new('',$ss).Password
        if($try){
            if(runContinue $try){ $pw = $try }      ## v1 only decrypts with the right password
            else{ w ' That password is not correct; the upgrade was skipped.' y }
        }
    }
    if($pw){
        try{
            $p = confPaths_
            $old = $p.local
            $bk = confBackup_ $old 'v1'
            confSave_ $h $pw
            if($p.central -and (Test-Path -LiteralPath $old)){ Remove-Item -LiteralPath $old -Force }
            w " Config upgraded. The old config was kept as $bk (without its unprotected template stream)." g
            $legacy = @(Get-ChildItem -Path (Split-Path $old) -Filter '*macross.conf.backup' -ErrorAction SilentlyContinue)
            if($legacy.Count){
                w ' These older backups still contain the unprotected template; delete them once you have tested:' y
                $legacy | %{ w "   $($_.FullName)" y }
            }
        }
        catch{ w " The config could not be upgraded: $($_.Exception.Message)" y }
    }
    Return $h
}

## Load the settings (used by startUp). With $password, only the admin password slot is tried
## (that is how the config menu verifies the admin password). Returns a hashtable or $null.
function confLoad_([string]$password){
    $p = confPaths_
    $src = $null; $file = $null
    if($p.central){
        if(Test-Path -PathType Leaf $p.central){ $src = 'central'; $file = $p.central }
        elseif(Test-Path -PathType Leaf $p.cache){
            $src = 'cache'; $file = $p.cache
            if(-not $Global:dyrl_CONFWARNED){
                w " The central MACROSS config ($($p.central)) can't be reached; using this computer's cached copy." y
                $Global:dyrl_CONFWARNED = $true
            }
        }
        elseif((Test-Path -PathType Leaf $p.local) -and -not (confIsV2_ $p.local)){ Return (confLegacy_ $password) }
        else{ w " The central MACROSS config ($($p.central)) can't be reached and there is no cached copy." r; Return $null }
    }
    else{
        if(-not (Test-Path -PathType Leaf $p.local)){ Return $null }
        if(-not (confIsV2_ $p.local)){ Return (confLegacy_ $password) }
        $src = 'local'; $file = $p.local
    }

    try{ $obj = confRead_ $file }
    catch{ w " The MACROSS config ($file) is damaged: $($_.Exception.Message)" r; Return $null }
    if(-not (confSigOk_ $obj)){
        w " The MACROSS config ($file) is not signed by the admin key in site.ps1 (changed outside MACROSS?). It will not be used." r
        try{ errLog ERROR 'MACROSS.config' "Rejected ${file}: missing or invalid admin signature" }catch{ }
        Return $null
    }
    $how = $null; $dek = $null
    ## Already unlocked earlier this session (any method)? Reuse that, so MACROSS' frequent reloads
    ## don't ask again. Kept protected with this account's DPAPI and cleared when MACROSS exits.
    if(-not $password -and $Global:dyrl_CONFSESS -and $dyrl_CONFSESS.file -eq $file -and $dyrl_CONFSESS.updated -eq "$($obj.updated)"){
        try{
            $d = kngUserUnprotect_ (kngUnB64_ $dyrl_CONFSESS.blob) (kngUtf8_ "MACROSS-CONFSESS|$file")
            if(kngVerify_ $d $obj.data (kngAad_ $obj 'data')){ $dek = $d; $how = 'session' }
        }
        catch{ }
    }
    if(-not $dek -and $password){ $dek = confUnlock_ $obj $password -how ([ref]$how) }
    if(-not $dek -and -not $password){
        ## 1) the config's own domain/machine slots, without prompting
        $dek = confUnlock_ $obj -how ([ref]$how)
        ## 2) central config this account can't open directly (e.g. local accounts): this computer's
        ##    cached copy has the same data and key until the central config changes, and has a
        ##    machine slot for this computer
        if(-not $dek -and $how -ne 'altered' -and $src -eq 'central' -and (Test-Path -PathType Leaf $p.cache)){
            try{
                $c = confRead_ $p.cache
                if("$($c.updated)" -eq "$($obj.updated)"){
                    $d = confUnlock_ $c
                    if($d -and (kngVerify_ $d $obj.data (kngAad_ $obj 'data'))){ $dek = $d; $how = 'machine' }
                }
                else{ w "`n The central MACROSS config was changed since this computer's cached copy was made." y }
            }
            catch{ }
        }
        ## 3) ask for the admin password (repairs this computer's access afterwards)
        if(-not $dek -and $how -ne 'altered'){ $dek = confUnlock_ $obj -prompt -how ([ref]$how) }
    }
    if(-not $dek){
        if($how -eq 'altered'){
            w " The MACROSS config ($file) appears to have been altered outside MACROSS. It will not be used." r
            w ' Restore it from a backup, or re-save it from the config menu on a computer that can still open it.' r
            try{ errLog ERROR 'MACROSS.config' "POSSIBLE TAMPERING: $file failed its integrity check ($env:USERDOMAIN\$env:USERNAME on $([Environment]::MachineName))" }catch{ }
        }
        elseif(-not $password){ w " The MACROSS config ($file) could not be unlocked." r }
        Return $null
    }
    try{
        $h = confFromBytes_ (kngOpen_ $dek $obj.data (kngAad_ $obj 'data'))
        if($how -eq 'pass' -and -not $password -and $src -ne 'central'){ confAddMachineSlot_ $obj $dek }
        if($how -ne 'session'){
            try{
                $Global:dyrl_CONFSESS = @{ file = $file; updated = "$($obj.updated)"
                    blob = (kngB64_ (kngUserProtect_ $dek (kngUtf8_ "MACROSS-CONFSESS|$file"))) }
            }
            catch{ }
        }
        if($src -eq 'central'){
            ## keep a cached copy for when the share is unreachable (only rewritten when it changes)
            $cached = $null
            if(Test-Path -PathType Leaf $p.cache){ try{ $cached = confRead_ $p.cache }catch{ } }
            if(-not $cached -or $cached.updated -ne $obj.updated -or
               -not @($cached.slots | ?{ $_.type -eq 'machine' -and $_.host -eq [Environment]::MachineName }).Count){
                confCache_ $obj $dek
            }
        }
    }
    finally{ kngWipe_ $dek }
    $Global:dyrl_CONFSRC = "$src ($file)"
    confOverrides_ $h
    Return $h
}

## Replaces the v1 writer. Same parameters as before: -n admin password, -c settings joined
## with @@@ (as built by runStart/runModify). Like before, MACROSS exits afterwards so the
## new settings load cleanly.
function upWrite($n,$conf,$o_file='macross.conf',[switch]$xe,[switch]$fin,$oldpass=$null){
    if($xe){ upWriteLegacy_ -x; Return }
    gerwalk QEBA; $sep = $dyrl_PT
    $h = @{}
    foreach($c in ("$conf" -split [regex]::Escape($sep))){ if($c.Length -ge 3){ $h[$c.Substring(0,3)] = $c.Substring(3) } }
    try{ confSave_ $h "$n" "$oldpass" }
    catch{
        w "`n The configuration was NOT saved: $($_.Exception.Message)" r
        w ' Hit ENTER to continue.' g; Read-Host | Out-Null
        Return
    }
    w "`n`n Setup is complete. Run the MACROSS.ps1 script to start MACROSS.`n" g
    Remove-Variable dyrl_* -Force -Scope Global
    Exit
}

## Show where the config comes from and how it's protected (no settings are shown)
function confInfo(){   #mp
    <#
    ||shorthelp||
    Show which MACROSS config is in use and how it's protected (never shows settings).
    Usage:
        confInfo

    ||longhelp||
    Lists the local config, the central config and this computer's cached copy (when
    site.ps1 sets a central ConfigPath), which one was loaded this session, any
    macross.local.json overrides, when the config was last saved and by whom, its
    slots (machine slots and their computers, the domain slot's accounts/groups, the
    admin password slot), and whether it's signed.

    Start here when MACROSS asks for the admin password unexpectedly: it shows
    whether this computer has a machine slot, and which file is actually being used.

    ||examples||
    From the debug menu:

        confInfo

    #>
    $p = confPaths_
    w "`n MACROSS CONFIG" c
    w " Local:     $($p.local)$(if(Test-Path $p.local){ if(confIsV2_ $p.local){' (v2)'}else{' (v1, not upgraded yet)'} }else{' (none)'})"
    if($p.central){
        w " Central:   $($p.central)$(if(Test-Path $p.central){''}else{' (not reachable)'})"
        w " Cache:     $($p.cache)$(if(Test-Path $p.cache){''}else{' (none)'})"
    }
    if($Global:dyrl_CONFSRC){ w " Loaded from: $dyrl_CONFSRC" g }
    if(Test-Path $p.overrides){ w " Overrides: $($p.overrides)" }
    $f = if($p.central -and (Test-Path $p.central)){ $p.central }elseif($p.central -and (Test-Path $p.cache)){ $p.cache }else{ $p.local }
    if((Test-Path $f) -and (confIsV2_ $f)){
        $o = confRead_ $f
        $when = try{ [DateTime]::ParseExact("$($o.updated)",'yyyyMMddHHmmssfffffff',$null).ToLocalTime().ToString('yyyy-MM-dd HH:mm') }catch{ "$($o.updated)" }
        w " Updated:   $when by $($o.by)"
        foreach($s in @($o.slots)){
            switch($s.type){
                'machine' { w "   machine slot for $($s.host)" }
                'domain'  { w "   domain slot: $($s.names)" }
                'pass'    { w '   admin password slot' }
            }
        }
        $req = [bool]($Global:dyrl_SITE -and $dyrl_SITE.AdminPubKey)
        w " Signed:    $([bool]$o.sig)$(if($req){ "  (required by site.ps1; valid: $(confSigOk_ $o))" })"
    }
    w ''
}

## Create the admin signing key. Prints the public key to put in site.ps1 (as AdminPubKey);
## once it's there (and site.ps1 is re-signed), unsigned or altered configs are refused.
function confSigningKey(){   #mp
    <#
    ||shorthelp||
    Create the admin signing key for the MACROSS config (admin password required).
    Usage:
        confSigningKey

    ||longhelp||
    Creates an RSA signing key, locks its private half with the admin password inside
    the config, signs the config, and prints the public key. Paste that public key
    into site.ps1 as AdminPubKey and re-sign site.ps1. From then on MACROSS refuses
    any config that wasn't saved through MACROSS with the admin password, even by
    someone with write access to the config file or share.

    Every later save from the config menu re-signs the config automatically. Running
    this again replaces the key (asks first), and site.ps1 must then be updated.

    The config must already be in the v2 format (it's upgraded automatically the
    first time the admin password is entered).

    ||examples||
    From the debug menu:

        confSigningKey

    #>
    $p = confPaths_
    $f = if($p.central){ $p.central }else{ $p.local }
    if(-not ((Test-Path $f) -and (confIsV2_ $f))){ w ' The config must be upgraded to v2 first.' y; Return }
    $obj = confRead_ $f
    if($obj.signkey){
        $a = Read-Host ' This config already has a signing key. Replace it? (y/N)'
        if($a -notlike 'y*'){ Return }
    }
    $ss = Read-Host ' Admin password' -AsSecureString
    $password = [Net.NetworkCredential]::new('',$ss).Password
    $dek = confUnlock_ $obj $password
    if(-not $dek){ w ' That password did not unlock the config.' y; Return }
    $rsa = kngRsaNew_ 3072
    try{
        $priv = kngUtf8_ $rsa.ToXmlString($true)
        $pub = $rsa.ToXmlString($false)
        $pw = kngUtf8_ $password
        $obj.updated = (confStamp_)
        $obj | Add-Member -NotePropertyName signkey -NotePropertyValue (confPassSeal_ $obj $priv $pw 'signkey') -Force
        $obj | Add-Member -NotePropertyName sig -NotePropertyValue (confSign_ $obj ([Text.Encoding]::UTF8.GetString($priv))) -Force
        confWrite_ $obj $f
        if($p.central){ confCache_ $obj $dek }
    }
    finally{ $rsa.Dispose(); kngWipe_ $priv; kngWipe_ $pw; kngWipe_ $dek }
    errLog INFO 'MACROSS.config' "Config signing key created by $env:USERDOMAIN\$env:USERNAME"
    w "`n Signing key created and the config is signed. Put this in site.ps1 as AdminPubKey, then re-sign site.ps1:`n" g
    Write-Host $pub
    w ''
}

## Troubleshooting: run each step of config loading/saving with errors visible. Shows setting
## NAMES only (never values) and never writes to the real config (tests use a temp file).
function confDiag(){   #mp
    <#
    ||shorthelp||
    Troubleshoot config loading/saving: runs each step and shows PASS/FAIL with errors.
    Usage:
        confDiag

    ||longhelp||
    Runs every step MACROSS uses to open and save its config, with error messages
    visible (MACROSS normally hides them), and reports PASS or FAIL for each:

        -the config file is v2 and readable (and which slots it has)
        -the settings are loaded this session, and whether the team key exists
        -this account can write to the config folder
        -the Windows encryption functions load (DPAPI / DPAPI-NG)
        -machine-scope DPAPI works, and a machine slot can be created
        -a config file with a machine slot survives being written and read back
        -RSA (team/signing keys), PBKDF2 (passphrases) and AES work
        -the domain slot opens for this account (when there is one)

    A FAIL line includes the error and the file/line it came from. It also prints
    the PowerShell and .NET versions, computer and account, which helps when
    reporting a problem.

    Safe to run: it never shows setting values and never changes the real config
    (the write test uses a temporary file).

    ||examples||
    From the debug menu:

        confDiag

    #>
    $eap = $ErrorActionPreference; $ErrorActionPreference = 'Stop'
    $script:diagFail = 0
    function step_($label,[scriptblock]$sb){
        try{
            $r = & $sb
            w "  PASS  $label$(if($r){ ": $r" })" g
        }
        catch{
            $script:diagFail++
            w "  FAIL  $label" r
            w "        $($_.Exception.Message)" y
            if($_.InvocationInfo.ScriptName){ w "        at $(Split-Path -Leaf $_.InvocationInfo.ScriptName) line $($_.InvocationInfo.ScriptLineNumber): $("$($_.InvocationInfo.Line)".Trim())" a }
        }
    }
    try{
        w "`n MACROSS CONFIG DIAGNOSTICS" c
        $fw = try{ [Runtime.InteropServices.RuntimeInformation]::FrameworkDescription }catch{ ".NET CLR $([Environment]::Version)" }
        w "  PowerShell $($PSVersionTable.PSVersion) ($($PSVersionTable.PSEdition)); $fw; $(if([Environment]::Is64BitProcess){'64'}else{'32'})-bit"
        w "  Computer: $([Environment]::MachineName)   Account: $env:USERDOMAIN\$env:USERNAME   Language mode: $($ExecutionContext.SessionState.LanguageMode)"
        w "  MACROSS error preference: $eap"
        $p = confPaths_
        w "  Config: $($p.local)$(if($p.central){ "   Central: $($p.central)" })"
        w ''

        $f = if($p.central -and (Test-Path $p.central)){ $p.central }elseif($p.central -and (Test-Path $p.cache)){ $p.cache }else{ $p.local }
        $obj = $null
        step_ 'config file is v2 and readable' { if(-not (confIsV2_ $f)){ throw "$f is missing or not v2" }; $script:dobj = confRead_ $f; "slots: $((@($dobj.slots) | %{ if($_.type -eq 'machine'){ "machine($($_.host))" }else{ "$($_.type)" } }) -join ', ')" }
        $obj = $script:dobj
        step_ 'settings loaded in this session' {
            if(-not $dyrl_CONF){ throw 'no config is loaded right now' }
            $k = @($dyrl_CONF.Keys | Sort-Object)
            "$($k.Count) settings; team key: $(if($dyrl_CONF.ContainsKey('tpk') -and $dyrl_CONF.ContainsKey('tsk')){'present'}else{'MISSING (set it with config > 4)'})"
        }
        step_ 'config folder writable by this account' {
            $dir = Split-Path $f
            $probe = Join-Path $dir ".diag-write-$PID"
            [IO.File]::WriteAllText($probe,'x'); Remove-Item -LiteralPath $probe -Force
            $ro = (Get-Item -LiteralPath $f -ErrorAction SilentlyContinue).IsReadOnly
            if($ro){ throw "$f is marked read-only" }
            $dir
        }
        step_ 'Windows API bindings' { $t = kngNative_; "$(@($t.GetMethods() | ?{ $_.IsStatic -and $_.DeclaringType -eq $t }).Count) functions" }
        step_ 'machine-scope DPAPI round trip' {
            $b = kngMachineProtect_ (kngUtf8_ 'diag') (kngUtf8_ 'x')
            if([Text.Encoding]::UTF8.GetString((kngMachineUnprotect_ $b (kngUtf8_ 'x'))) -ne 'diag'){ throw 'value came back different' }
            "$($b.Length)-byte blob"
        }
        step_ 'machine slot creation (as config save does)' {
            if(-not $obj){ throw 'skipped (no config object)' }
            $dek = kngRandom_ 32
            $s = confMachineSlot_ $obj $dek
            $back = kngMachineUnprotect_ (kngUnB64_ $s.blob) (kngUtf8_ (kngAad_ $obj 'machine'))
            if(-not (kngSame_ $back $dek)){ throw 'unwrapped key differs' }
            "type=$($s.type) host=$($s.host)"
        }
        step_ 'write + read back a config file with a machine slot (temp copy)' {
            if(-not $obj){ throw 'skipped (no config object)' }
            $dek = kngRandom_ 32
            $tmp = Join-Path ([IO.Path]::GetTempPath()) "macross-diag-$PID.conf"
            $c = $obj | Select-Object * -ExcludeProperty '_file'
            $c.slots = @(@($obj.slots | ?{ $_.type -ne 'machine' }) + (confMachineSlot_ $obj $dek))
            try{
                confWrite_ $c $tmp
                $r = confRead_ $tmp
                $types = (@($r.slots) | %{ "$($_.type)" }) -join ','
                if($types -notmatch 'machine'){ throw "machine slot lost on write/read (slot types: $types; raw slots JSON starts: $(((Get-Content -Raw $tmp) -split 'slots')[1].Substring(0,60)))" }
                "slot types after read-back: $types"
            }
            finally{ Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
        }
        step_ 'RSA-3072 team key create/encrypt/decrypt' {
            $r = kngRsaNew_ 3072
            try{
                $x = $r.ToXmlString($true)
                $e = $r.Encrypt((kngUtf8_ 'diag'),[Security.Cryptography.RSAEncryptionPadding]::OaepSHA1)
                $d = $r.Decrypt($e,[Security.Cryptography.RSAEncryptionPadding]::OaepSHA1)
                if([Text.Encoding]::UTF8.GetString($d) -ne 'diag'){ throw 'round trip failed' }
                "$($r.GetType().Name), $($r.KeySize) bits"
            }
            finally{ $r.Dispose() }
        }
        step_ 'PBKDF2-SHA256 (passphrases)' { $k = kngPassKey_ (kngUtf8_ 'diag') (kngRandom_ 16) 1000; "$($k.Length)-byte key" }
        step_ 'AES + tamper check' { $k = kngRandom_ 32; $b = kngSeal_ $k (kngUtf8_ 'diag') 'x'; [Text.Encoding]::UTF8.GetString((kngOpen_ $k $b 'x')) }
        if($obj -and @($obj.slots | ?{ $_.type -eq 'domain' }).Count){
            step_ 'domain slot opens for this account' {
                $s = @($obj.slots | ?{ $_.type -eq 'domain' })[0]
                $dek = kngNGUnprotect_ (kngUnB64_ $s.blob)
                if(-not (kngVerify_ $dek $obj.data (kngAad_ $obj 'data'))){ throw 'opened, but failed the tamper check' }
                'ok'
            }
        }
        w "`n  $(if($script:diagFail){ "$($script:diagFail) step(s) failed; please send this output." }else{ 'All steps passed.' })`n" $(if($script:diagFail){ 'y' }else{ 'g' })
    }
    finally{ $ErrorActionPreference = $eap; Remove-Variable dobj,diagFail -Scope Script -ErrorAction SilentlyContinue }
}

## Give this computer its own access to the config (machine slot), with every step shown.
## Needs the admin password. Use it when MACROSS keeps asking for the admin password at startup.
function confRepair(){   #mp
    <#
    ||shorthelp||
    Give this computer its own access to the config again (admin password required).
    Usage:
        confRepair

    ||longhelp||
    Adds (or replaces) this computer's machine slot, so MACROSS can open its config
    at startup without asking for the admin password. Use it after a computer or VM
    is rebuilt, re-imaged or renamed, or whenever MACROSS keeps asking for the admin
    password at startup. It shows the slots before and after, and any error.

    With a central config (site.ps1 ConfigPath), it repairs this computer's cached
    copy, which is what local accounts open the central config through. Domain
    accounts in the tier lists or groups don't need it: they use the domain slot.

    MACROSS also does this automatically when the admin password is entered at
    startup; confRepair is the same thing as a separate, visible step.

    ||examples||
    From the debug menu:

        confRepair

    #>
    $p = confPaths_
    $f = if($p.central){ $p.cache }else{ $p.local }
    if($p.central){ w " (Central config: repairing this computer's cached copy, $f)" c }
    if(-not ((Test-Path -LiteralPath $f) -and (confIsV2_ $f))){ w " $f is missing or not a v2 config." y; Return }
    $show = { param($o) (@($o.slots) | %{ if($_.type -eq 'machine'){ "machine($($_.host))" }else{ "$($_.type)" } }) -join ', ' }
    $obj = confRead_ $f
    w "`n Config:   $f" g
    w " Computer: $([Environment]::MachineName)" g
    w " Slots before: $(& $show $obj)" g
    $dek = $null
    for($i = 1; $i -le 3 -and -not $dek; $i++){
        $ss = Read-Host "  Admin password (attempt $i of 3, ENTER to cancel)" -AsSecureString
        $pw = [Net.NetworkCredential]::new('',$ss).Password
        if(-not $pw){ Return }
        $dek = confUnlock_ $obj $pw
        if(-not $dek){ w ' That password did not unlock the config.' y }
    }
    if(-not $dek){ Return }
    try{ confAddMachineSlot_ $obj $dek }finally{ kngWipe_ $dek }
    w " Slots after:  $(& $show (confRead_ $f))`n" g
}

