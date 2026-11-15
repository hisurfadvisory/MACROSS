## kawamoriNG -- protected secrets for MACROSS diamonds (".mori" v2 format)
## Updated from the original kawamori function for protecting secrets, using  
## Claude Code assistance to improve security. As with the original version, use  
## only when no better solution is available, but this is waaay better nothing.
##
## Built only from what ships with Windows/.NET (no modules, packages or compilers):
##
##   -Every secret is encrypted once (AES-256-CBC + HMAC-SHA256) with its own random
##    data key (DEK).
##   -The DEK is then stored in "slots", each of which can unlock it for a different
##    kind of account:
##        domain  DPAPI-NG (CNG DPAPI) protected to "SID=... OR SID=..." -- every
##                domain user/group from your MACROSS tier lists plus any extra groups
##                you name. Keys come from Active Directory, so this slot survives
##                profile resets and rebuilt VDI images.
##        pass    a team passphrase (PBKDF2-SHA256). Used to enroll accounts the domain
##                slot can't cover (local/non-AD accounts) and for recovery.
##        user    per-account Windows DPAPI, written by "enrollment" to its own
##                <id>.<SID>.slot file next to the key, so simultaneous enrollments
##                never overwrite each other.
##
## Windows APIs are bound at runtime with Reflection.Emit, so this does not depend on
## Add-Type/csc.exe.

## Anime note: Shoji Kawamori is the main creator of the Macross series, along
## with Vision of Escaflowne, two of the best anime shows ever made IMHO.


function kngSay_($text,$color='Gray'){ Write-Host " $text" -ForegroundColor $color }
## Log to the MACROSS log. Inside MACROSS this uses errLog (WARN/ERROR are also forwarded to
## the SIEM if one is configured). When this file is loaded on its own (e.g. by python),
## the same base64-encoded line is written straight to the log folder from -klog.
## Values and passphrases are never logged.
function kngLog_($level,$text){
    $src = 'MACROSS.kawamori'
    if(Get-Command errLog -ErrorAction SilentlyContinue){
        try{
            if($level -in @('WARN','ERROR')){ errLog $level $src $text -forward }
            else{ errLog $level $src $text }
        }
        catch{ }
        Return
    }
    $dir = $Global:dyrl_KNGLOG
    if(-not $dir -or $dir -eq 'none' -or -not (Test-Path $dir)){ Return }
    try{
        $who = [Environment]::UserName
        $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`tMACROSS/$([Environment]::MachineName)/$who`t$level`t$src`t$text"
        $enc = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($line))
        [IO.File]::AppendAllText((Join-Path $dir "$(Get-Date -Format 'yyyy-MM-dd').txt"),"$enc$([Environment]::NewLine)")
    }
    catch{ }
}

## Byte helpers. Functions return byte[] wrapped with "," so powershell doesn't unroll them.
function kngUtf8_([string]$s){ ,[Text.Encoding]::UTF8.GetBytes($s) }
function kngB64_([byte[]]$b){ [Convert]::ToBase64String($b) }
function kngUnB64_([string]$s){ ,[Convert]::FromBase64String($s) }
function kngWipe_([byte[]]$b){ if($b){ [Array]::Clear($b,0,$b.Length) } }
function kngRandom_([int]$n){
    $b = [byte[]]::new($n)
    $r = [Security.Cryptography.RandomNumberGenerator]::Create()
    try{ $r.GetBytes($b) }finally{ $r.Dispose() }
    ,$b
}
function kngSame_([byte[]]$a,[byte[]]$b){
    if($null -eq $a -or $null -eq $b -or $a.Length -ne $b.Length){ Return $false }
    $d = 0
    for($i = 0; $i -lt $a.Length; $i++){ $d = $d -bor ($a[$i] -bxor $b[$i]) }
    Return ($d -eq 0)
}


################################################################
## Symmetric crypto (AES-256-CBC, encrypt-then-MAC with HMAC-SHA256)
################################################################
function kngSubKey_([byte[]]$key,[string]$label){
    $h = [Security.Cryptography.HMACSHA256]::new($key)
    try{ ,$h.ComputeHash((kngUtf8_ $label)) }finally{ $h.Dispose() }
}
function kngMac_([byte[]]$mk,[string]$aad,[byte[]]$iv,[byte[]]$ct){
    $h = [Security.Cryptography.HMACSHA256]::new($mk)
    try{
        $a = kngUtf8_ $aad
        [void]$h.TransformBlock($a,0,$a.Length,$null,0)
        [void]$h.TransformBlock($iv,0,$iv.Length,$null,0)
        [void]$h.TransformFinalBlock($ct,0,$ct.Length)
        ,$h.Hash
    }
    finally{ $h.Dispose() }
}
function kngSeal_([byte[]]$key,[byte[]]$plain,[string]$aad){
    $ek = kngSubKey_ $key 'enc'; $mk = kngSubKey_ $key 'mac'
    $aes = [Security.Cryptography.Aes]::Create()
    try{
        $aes.KeySize = 256; $aes.Mode = 'CBC'; $aes.Padding = 'PKCS7'
        $aes.Key = $ek; $aes.GenerateIV(); $iv = $aes.IV
        $enc = $aes.CreateEncryptor()
        try{ $ct = $enc.TransformFinalBlock($plain,0,$plain.Length) }finally{ $enc.Dispose() }
    }
    finally{ $aes.Dispose() }
    $mac = kngMac_ $mk $aad $iv $ct
    kngWipe_ $ek; kngWipe_ $mk
    [pscustomobject][ordered]@{ iv=(kngB64_ $iv); ct=(kngB64_ $ct); mac=(kngB64_ $mac) }
}
function kngVerify_([byte[]]$key,$box,[string]$aad){
    $mk = kngSubKey_ $key 'mac'
    try{ Return (kngSame_ (kngMac_ $mk $aad (kngUnB64_ $box.iv) (kngUnB64_ $box.ct)) (kngUnB64_ $box.mac)) }
    finally{ kngWipe_ $mk }
}
function kngOpen_([byte[]]$key,$box,[string]$aad){
    if(-not (kngVerify_ $key $box $aad)){ throw 'Integrity check failed (wrong key/passphrase, or the file was altered).' }
    $ek = kngSubKey_ $key 'enc'
    $aes = [Security.Cryptography.Aes]::Create()
    try{
        $aes.KeySize = 256; $aes.Mode = 'CBC'; $aes.Padding = 'PKCS7'
        $aes.Key = $ek; $aes.IV = (kngUnB64_ $box.iv)
        $dec = $aes.CreateDecryptor()
        $ct = kngUnB64_ $box.ct
        try{ ,$dec.TransformFinalBlock($ct,0,$ct.Length) }finally{ $dec.Dispose() }
    }
    finally{ $aes.Dispose(); kngWipe_ $ek }
}
function kngPassKey_([byte[]]$pw,[byte[]]$salt,[int]$iter){
    $kdf = [Security.Cryptography.Rfc2898DeriveBytes]::new($pw,$salt,$iter,[Security.Cryptography.HashAlgorithmName]::SHA256)
    try{ ,$kdf.GetBytes(32) }finally{ $kdf.Dispose() }
}


################################################################
## Windows APIs: DPAPI-NG (ncrypt.dll) and DPAPI (crypt32.dll)
################################################################
function kngNative_(){
    if($Global:dyrl_KNGN){ Return $Global:dyrl_KNGN }
    $an = [Reflection.AssemblyName]::new('MacrossKawamoriNative')
    $ab = [Reflection.Emit.AssemblyBuilder]::DefineDynamicAssembly($an,[Reflection.Emit.AssemblyBuilderAccess]::Run)
    $mb = $ab.DefineDynamicModule('MacrossKawamoriNative')
    $tb = $mb.DefineType('MacrossKawamoriNative.Methods','Public,Class,Abstract,Sealed')
    $P = [IntPtr]; $PR = [IntPtr].MakeByRefType(); $U = [uint32]; $UR = [uint32].MakeByRefType()
    $defs = @(
        @('ncrypt.dll','NCryptCreateProtectionDescriptor',[int],@($P,$U,$PR)),
        @('ncrypt.dll','NCryptCloseProtectionDescriptor',[int],@($P)),
        @('ncrypt.dll','NCryptProtectSecret',[int],@($P,$U,$P,$U,$P,$P,$PR,$UR)),
        @('ncrypt.dll','NCryptUnprotectSecret',[int],@($P,$U,$P,$U,$P,$P,$PR,$UR)),
        @('crypt32.dll','CryptProtectData',[int],@($P,$P,$P,$P,$P,$U,$P)),
        @('crypt32.dll','CryptUnprotectData',[int],@($P,$P,$P,$P,$P,$U,$P)),
        @('kernel32.dll','LocalFree',[IntPtr],@($P)),
        @('kernel32.dll','GetLastError',[uint32],@())       ## read right after a failed call, for error messages
    )
    foreach($d in $defs){
        $m = $tb.DefinePInvokeMethod($d[1],$d[0],'Public,Static,PinvokeImpl',
            [Reflection.CallingConventions]::Standard,$d[2],[Type[]]$d[3],
            [Runtime.InteropServices.CallingConvention]::Winapi,[Runtime.InteropServices.CharSet]::Unicode)
        $m.SetImplementationFlags('PreserveSig')
    }
    $Global:dyrl_KNGN = $tb.CreateType()
    Return $Global:dyrl_KNGN
}
function kngToNative_([byte[]]$b){
    $p = [Runtime.InteropServices.Marshal]::AllocHGlobal([Math]::Max(1,$b.Length))
    if($b.Length){ [Runtime.InteropServices.Marshal]::Copy($b,0,$p,$b.Length) }
    Return $p
}
function kngFreeNative_([IntPtr]$p,[int]$len){
    if($p -ne [IntPtr]::Zero){
        if($len -gt 0){ [Runtime.InteropServices.Marshal]::Copy([byte[]]::new($len),0,$p,$len) }   ## wipe first
        [Runtime.InteropServices.Marshal]::FreeHGlobal($p)
    }
}
function kngFromLocal_([IntPtr]$p,[uint32]$len){
    $n = kngNative_
    $b = [byte[]]::new($len)
    [Runtime.InteropServices.Marshal]::Copy($p,$b,0,$len)
    [Runtime.InteropServices.Marshal]::Copy([byte[]]::new($len),0,$p,$len)
    [void]$n::LocalFree($p)
    ,$b
}

## DPAPI-NG: protect $data to a rule such as "SID=S-1-5-21-... OR SID=S-1-5-21-..."
function kngNGProtect_([string]$rule,[byte[]]$data){
    $n = kngNative_
    $hDesc = [IntPtr]::Zero; $pOut = [IntPtr]::Zero; [uint32]$cb = 0
    $pRule = [Runtime.InteropServices.Marshal]::StringToHGlobalUni($rule)
    $pIn = kngToNative_ $data
    try{
        $hr = $n::NCryptCreateProtectionDescriptor($pRule,0,[ref]$hDesc)
        if($hr -ne 0){ throw ("NCryptCreateProtectionDescriptor failed (0x{0:X8})" -f $hr) }
        $hr = $n::NCryptProtectSecret($hDesc,0x40,$pIn,[uint32]$data.Length,[IntPtr]::Zero,[IntPtr]::Zero,[ref]$pOut,[ref]$cb)
        if($hr -ne 0){ throw ("NCryptProtectSecret failed (0x{0:X8}); is there a KDS root key in the domain?" -f $hr) }
        kngFromLocal_ $pOut $cb
    }
    finally{
        kngFreeNative_ $pIn $data.Length
        [Runtime.InteropServices.Marshal]::FreeHGlobal($pRule)
        if($hDesc -ne [IntPtr]::Zero){ [void]$n::NCryptCloseProtectionDescriptor($hDesc) }
    }
}
function kngNGUnprotect_([byte[]]$blob){
    $n = kngNative_
    $pOut = [IntPtr]::Zero; [uint32]$cb = 0
    $pIn = kngToNative_ $blob
    try{
        $hr = $n::NCryptUnprotectSecret([IntPtr]::Zero,0x40,$pIn,[uint32]$blob.Length,[IntPtr]::Zero,[IntPtr]::Zero,[ref]$pOut,[ref]$cb)
        if($hr -ne 0){ throw ("this account is not covered by the domain slot, or AD could not be reached (0x{0:X8})" -f $hr) }
        kngFromLocal_ $pOut $cb
    }
    finally{ kngFreeNative_ $pIn $blob.Length }
}

## Classic DPAPI (current user), used for enrolled accounts. DATA_BLOB = {DWORD cbData; BYTE* pbData}
function kngBlobIn_([byte[]]$b){
    $s = [Runtime.InteropServices.Marshal]::AllocHGlobal(2 * [IntPtr]::Size)
    $p = kngToNative_ $b
    [Runtime.InteropServices.Marshal]::WriteInt32($s,0,$b.Length)
    [Runtime.InteropServices.Marshal]::WriteIntPtr($s,[IntPtr]::Size,$p)
    ,@($s,$p,$b.Length)
}
function kngBlobOut_(){
    $s = [Runtime.InteropServices.Marshal]::AllocHGlobal(2 * [IntPtr]::Size)
    [Runtime.InteropServices.Marshal]::WriteInt32($s,0,0)
    [Runtime.InteropServices.Marshal]::WriteIntPtr($s,[IntPtr]::Size,[IntPtr]::Zero)
    Return $s
}
function kngBlobRead_([IntPtr]$s){
    $len = [Runtime.InteropServices.Marshal]::ReadInt32($s,0)
    $p = [Runtime.InteropServices.Marshal]::ReadIntPtr($s,[IntPtr]::Size)
    kngFromLocal_ $p ([uint32]$len)
}
function kngUserDpapi_([byte[]]$data,[byte[]]$entropy,[switch]$unprotect,[switch]$machine){
    $n = kngNative_
    $in = kngBlobIn_ $data; $ent = kngBlobIn_ $entropy; $out = kngBlobOut_
    ## 0x1 = never show UI; 0x4 = machine scope (any account on this computer can unprotect)
    $flags = if($machine -and -not $unprotect){ 5 }else{ 1 }
    try{
        if($unprotect){ $ok = $n::CryptUnprotectData($in[0],[IntPtr]::Zero,$ent[0],[IntPtr]::Zero,[IntPtr]::Zero,$flags,$out) }
        else{ $ok = $n::CryptProtectData($in[0],[IntPtr]::Zero,$ent[0],[IntPtr]::Zero,[IntPtr]::Zero,$flags,$out) }
        if(-not $ok){
            $code = $n::GetLastError()      ## immediately, before anything else can overwrite it
            $desc = try{ ([ComponentModel.Win32Exception]::new([int]$code)).Message }catch{ '' }
            $what = "$(if($unprotect){'CryptUnprotectData'}else{'CryptProtectData'})$(if($machine){' (machine scope)'}else{' (current user)'})"
            throw ("Windows DPAPI {0} failed: 0x{1:X8} {2}" -f $what,$code,$desc)
        }
        kngBlobRead_ $out
    }
    finally{
        foreach($x in @($in,$ent)){ kngFreeNative_ $x[1] $x[2]; [Runtime.InteropServices.Marshal]::FreeHGlobal($x[0]) }
        [Runtime.InteropServices.Marshal]::FreeHGlobal($out)
    }
}
function kngUserProtect_([byte[]]$data,[byte[]]$entropy){ kngUserDpapi_ $data $entropy }
function kngUserUnprotect_([byte[]]$blob,[byte[]]$entropy){ kngUserDpapi_ $blob $entropy -unprotect }
## Machine scope: no AD and no user profile involved, but tied to this computer
function kngMachineProtect_([byte[]]$data,[byte[]]$entropy){ kngUserDpapi_ $data $entropy -machine }
function kngMachineUnprotect_([byte[]]$blob,[byte[]]$entropy){ kngUserDpapi_ $blob $entropy -unprotect -machine }


################################################################
## Accounts, tier lists and files
################################################################
function kngMySid_(){ [Security.Principal.WindowsIdentity]::GetCurrent().User.Value }
function kngMyName_(){ [Security.Principal.WindowsIdentity]::GetCurrent().Name }

function kngMachineDomain_(){
    if($null -ne $Global:dyrl_KNGMD){ Return $Global:dyrl_KNGMD }
    $md = ''
    try{
        $a = Get-CimInstance Win32_UserAccount -Filter "LocalAccount=True" -ErrorAction Stop | Select-Object -First 1
        if($a){ $md = ([Security.Principal.SecurityIdentifier]$a.SID).AccountDomainSid.Value }
    }
    catch{ $md = '' }
    $Global:dyrl_KNGMD = $md
    Return $md
}

## Resolve a user/group name. kind = domain (can go in the DPAPI-NG rule), local (needs
## enrollment), or pending (couldn't be resolved here, e.g. a local account on another PC)
function kngResolve_([string]$name){
    $nm = "$name".Trim()
    if(-not $nm -or $nm -eq 'none'){ Return $null }
    try{ $sid = ([Security.Principal.NTAccount]::new($nm)).Translate([Security.Principal.SecurityIdentifier]) }
    catch{ Return [pscustomobject]@{ name=$nm; sid=$null; kind='pending' } }
    $dom = $sid.AccountDomainSid
    if(-not $dom -or $dom.Value -eq (kngMachineDomain_)){ $kind = 'local' }
    else{ $kind = 'domain' }
    Return [pscustomobject]@{ name=$nm; sid=$sid.Value; kind=$kind }
}

## Everyone in the requested MACROSS tiers (user and admin lists), plus extra names
function kngPrincipals_([int[]]$tiers,[string[]]$extra){
    $names = New-Object System.Collections.ArrayList
    if($Global:dyrl_CONF){
        foreach($t in $tiers){
            foreach($k in @("tr$t","ta$t")){
                if($dyrl_CONF[$k]){
                    try{ $v = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($dyrl_CONF[$k])) }
                    catch{ $v = '' }
                    $v -split ',' | ?{ $_.Trim() -and $_.Trim() -ne 'none' } | %{ [void]$names.Add($_.Trim()) }
                }
            }
        }
    }
    foreach($e in $extra){ if("$e".Trim()){ [void]$names.Add("$e".Trim()) } }
    $seen = @{}
    foreach($nm in $names){
        if($seen.ContainsKey($nm.ToLower())){ Continue }
        $seen[$nm.ToLower()] = $true
        $r = kngResolve_ $nm
        if($r){ $r }
    }
}

function kngDirs_([string]$kshare,[string]$klocal,[switch]$localfirst){
    $d = @()
    if($kshare){ $d += (Join-Path $kshare 'kawa') }
    if($klocal){ $l = Join-Path $klocal 'kawa'; if($d -notContains $l){ $d += $l } }
    if($localfirst){ [array]::Reverse($d) }
    Return $d
}
function kngHeader_(){ '### MACROSS KEY v2 ###' }
function kngRead_([string]$file){
    $raw = [IO.File]::ReadAllText($file)
    $parts = $raw -split "`r?`n",2
    if($parts[0].Trim() -ne (kngHeader_) -or $parts.Count -lt 2){ Return $null }
    $o = $parts[1] | ConvertFrom-Json
    $o | Add-Member -NotePropertyName '_file' -NotePropertyValue $file -Force
    Return $o
}
function kngWrite_($obj,[string]$file){
    $dir = Split-Path $file
    if(-not (Test-Path $dir)){ New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $json = $obj | Select-Object * -ExcludeProperty '_file' | ConvertTo-Json -Depth 8
    [IO.File]::WriteAllText($file,"$(kngHeader_)`n$json`n",[Text.UTF8Encoding]::new($false))
}
function kngFind_([string]$id,$dirs){
    foreach($d in $dirs){
        $f = Join-Path $d "$id.mori"
        if(Test-Path -PathType Leaf $f){
            try{ $k = kngRead_ $f }
            catch{
                kngLog_ ERROR "Key file $f could not be parsed (corrupted or replaced?): $($_.Exception.Message) $(kngWho_)"
                throw "Key file $f is damaged and can't be read."
            }
            if($k){ Return $k }
            Return [pscustomobject]@{ legacy=$true; _file=$f }
        }
    }
    Return $null
}
function kngAad_($key,[string]$part){ "MACROSS-KAWAMORI-v2|$($key.id)|$part" }


################################################################
## Unlocking and enrollment
################################################################
function kngReadPass_([string]$prompt){
    $ss = Read-Host " $prompt" -AsSecureString
    $pw = [Net.NetworkCredential]::new('',$ss).Password
    ,(kngUtf8_ $pw)
}
function kngNewPass_(){
    while($true){
        $a = kngReadPass_ 'New team passphrase (12+ characters; it unlocks this key for enrollment and recovery; ENTER to cancel)'
        if($a.Length -eq 0){ throw 'Cancelled; nothing was changed.' }
        if($a.Length -lt 12){ kngSay_ 'The passphrase must be at least 12 characters.' Yellow; kngWipe_ $a; Continue }
        $b = kngReadPass_ 'Enter the passphrase again'
        if(kngSame_ $a $b){ kngWipe_ $b; ,$a; Return }
        kngSay_ 'Passphrases do not match.' Yellow
        kngWipe_ $a; kngWipe_ $b
    }
}
function kngPassSlot_($key,[byte[]]$dek,[byte[]]$pw){
    $salt = kngRandom_ 16; $iter = 600000
    $pk = kngPassKey_ $pw $salt $iter
    try{ $box = kngSeal_ $pk $dek (kngAad_ $key 'pass') }finally{ kngWipe_ $pk }
    [pscustomobject][ordered]@{ type='pass'; salt=(kngB64_ $salt); iter=$iter; iv=$box.iv; ct=$box.ct; mac=$box.mac }
}
function kngTryPass_($key,[byte[]]$pw){
    foreach($s in @($key.slots | ?{ $_.type -eq 'pass' })){
        $pk = kngPassKey_ $pw (kngUnB64_ $s.salt) ([int]$s.iter)
        try{
            $dek = kngOpen_ $pk $s (kngAad_ $key 'pass')
            if(kngVerify_ $dek $key.data (kngAad_ $key 'data')){ ,$dek; Return }
        }
        catch{ }    ## wrong passphrase; try the next slot (emit nothing, or callers see a non-empty result)
        finally{ kngWipe_ $pk }
    }
    ## Team slot: the team passphrase unlocks the team private key (kept in the MACROSS config)
    $teams = @($key.slots | ?{ $_.type -eq 'team' })
    if($teams.Count){
        $priv = kngTeamOpen_ $pw
        if($priv){
            try{
                foreach($s in $teams){
                    try{
                        $dek = kngTeamUnwrap_ $s $priv
                        if(kngVerify_ $dek $key.data (kngAad_ $key 'data')){ ,$dek; Return }
                    }
                    catch{ }    ## slot made with an older team key
                }
            }
            finally{ kngWipe_ $priv }
        }
    }
    Return $null
}


################################################################
## Team key: created by the MACROSS admin at setup (or config menu option 4).
## The public half (config 'tpk') lets ANYONE create keys with a recovery slot, without
## knowing the team passphrase. The private half (config 'tsk') is locked with the team
## passphrase (PBKDF2) and is only needed for enrollment and recovery.
## RSA-3072 with OAEP (SHA-1 OAEP is used because it's the padding every .NET version on
## Windows supports; OAEP-SHA1 has no known weaknesses for encryption).
################################################################
function kngTeamPub_(){
    if($Global:dyrl_CONF -and $dyrl_CONF['tpk']){
        try{ Return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($dyrl_CONF['tpk'])) }catch{ }
    }
    Return $null
}
function kngTeamKid_([string]$pubXml){
    $h = [Security.Cryptography.SHA256]::Create()
    try{ ([BitConverter]::ToString($h.ComputeHash((kngUtf8_ $pubXml)),0,8)) -replace '-','' }finally{ $h.Dispose() }
}
## New key pair. Returns config values (base64, like every MACROSS setting): tpk = public key,
## tsk = private key sealed with the team passphrase.
## New RSA key of a given size on every .NET version: RSA.Create(int) needs .NET Framework 4.7.2+,
## and on older versions setting KeySize afterwards doesn't reliably change the generated key.
function kngRsaNew_([int]$bits){
    try{ $r = [Security.Cryptography.RSA]::Create($bits) }catch{ $r = $null }
    if(-not $r -or $r.KeySize -ne $bits){
        if($r){ $r.Dispose() }
        $r = New-Object Security.Cryptography.RSACryptoServiceProvider($bits)
    }
    Return $r
}
function kngTeamCreate_([byte[]]$pw){
    $rsa = kngRsaNew_ 3072
    try{ $priv = kngUtf8_ $rsa.ToXmlString($true); $pub = $rsa.ToXmlString($false) }finally{ $rsa.Dispose() }
    try{ $tsk = kngTeamSeal_ $priv $pw }finally{ kngWipe_ $priv }
    Return @{ tpk = [Convert]::ToBase64String((kngUtf8_ $pub)); tsk = $tsk }
}
function kngTeamSeal_([byte[]]$priv,[byte[]]$pw){
    $salt = kngRandom_ 16; $iter = 600000
    $pk = kngPassKey_ $pw $salt $iter
    try{ $box = kngSeal_ $pk $priv 'MACROSS-TEAMKEY-v1' }finally{ kngWipe_ $pk }
    $j = [pscustomobject][ordered]@{ salt=(kngB64_ $salt); iter=$iter; iv=$box.iv; ct=$box.ct; mac=$box.mac } | ConvertTo-Json -Compress
    Return [Convert]::ToBase64String((kngUtf8_ $j))
}
## Private key (XML bytes) if $pw is the team passphrase, otherwise $null
function kngTeamOpen_([byte[]]$pw,[string]$tsk){
    if(-not $tsk){ if($Global:dyrl_CONF){ $tsk = $dyrl_CONF['tsk'] } }
    if(-not $tsk -or -not $pw -or -not $pw.Length){ Return $null }
    try{
        $box = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($tsk)) | ConvertFrom-Json
        $pk = kngPassKey_ $pw (kngUnB64_ $box.salt) ([int]$box.iter)
        try{ ,(kngOpen_ $pk $box 'MACROSS-TEAMKEY-v1') }finally{ kngWipe_ $pk }
    }
    catch{ Return $null }
}
function kngTeamSlot_($key,[byte[]]$dek){
    $pub = kngTeamPub_
    if(-not $pub){ Return $null }
    $rsa = [Security.Cryptography.RSA]::Create()
    try{ $rsa.FromXmlString($pub); $blob = $rsa.Encrypt($dek,[Security.Cryptography.RSAEncryptionPadding]::OaepSHA1) }
    finally{ $rsa.Dispose() }
    [pscustomobject][ordered]@{ type='team'; kid=(kngTeamKid_ $pub); blob=(kngB64_ $blob) }
}
function kngTeamUnwrap_($slot,[byte[]]$privXml){
    $rsa = [Security.Cryptography.RSA]::Create()
    try{
        $rsa.FromXmlString([Text.Encoding]::UTF8.GetString($privXml))
        ,$rsa.Decrypt((kngUnB64_ $slot.blob),[Security.Cryptography.RSAEncryptionPadding]::OaepSHA1)
    }
    finally{ $rsa.Dispose() }
}
function kngSidecar_($key,[string]$dir,[string]$sid){ Join-Path $dir "$($key.id).$sid.slot" }

## Who/where, for log entries
function kngWho_(){ "account=$(kngMyName_) ($(kngMySid_)) computer=$([Environment]::MachineName)" }

## Get the data key using the first slot that works for the current account.
## $passcache (a [ref]) lets enrollment of several keys reuse one typed passphrase.
## Logging: nothing is logged when a domain slot or enrollment works normally. Otherwise
## one summary entry is written per call (who, which key, why each method failed, and how
## many wrong passphrases were typed), plus a separate ERROR for signs of tampering.
## -nolog lets the caller (e.g. -own) write its own entry instead.
function kngUnlock_($key,$dirs,[switch]$silent,[ref]$how,[ref]$passcache,[switch]$nolog){
    $why = New-Object System.Collections.ArrayList
    $ctx = "key=$($key.id) file=$($key._file) $(kngWho_)"
    function tamper_($what){
        [void]$why.Add("$what opened, but the key data failed its integrity check")
        kngLog_ ERROR "POSSIBLE TAMPERING: $what opened but the encrypted value failed its integrity check; the .mori file may have been altered or replaced. $ctx"
    }
    function summary_($level,$outcome,[int]$wrong=0){
        if($nolog){ Return }
        $msg = "$outcome. $ctx"
        if($wrong -gt 0){ $msg += " wrong_passphrases=$wrong" }
        if($why.Count){ $msg += " reasons: $($why -join '; ')" }
        kngLog_ $level $msg
    }

    foreach($s in @($key.slots | ?{ $_.type -eq 'domain' })){
        try{
            $dek = kngNGUnprotect_ (kngUnB64_ $s.blob)
            if(kngVerify_ $dek $key.data (kngAad_ $key 'data')){ if($how){ $how.Value = 'domain' }; ,$dek; Return }
            tamper_ 'the domain slot'
        }
        catch{ [void]$why.Add("domain slot: $($_.Exception.Message)") }
    }
    $sid = kngMySid_
    $ent = kngUtf8_ (kngAad_ $key "user|$sid")
    ## Per-account DPAPI slots stored inside the key file (used by -own keys)
    foreach($s in @($key.slots | ?{ $_.type -eq 'user' -and $_.sid -eq $sid })){
        try{
            $dek = kngUserUnprotect_ (kngUnB64_ $s.blob) $ent
            if(kngVerify_ $dek $key.data (kngAad_ $key 'data')){ if($how){ $how.Value = 'user' }; ,$dek; Return }
            tamper_ 'the account slot'
        }
        catch{ [void]$why.Add("account slot: $($_.Exception.Message)") }
    }
    foreach($d in @($dirs) + @(Split-Path $key._file)){
        $sc = kngSidecar_ $key $d $sid
        if(Test-Path -PathType Leaf $sc){
            try{
                $side = Get-Content -Raw $sc | ConvertFrom-Json
                $dek = kngUserUnprotect_ (kngUnB64_ $side.blob) $ent
                if(kngVerify_ $dek $key.data (kngAad_ $key 'data')){ if($how){ $how.Value = 'user' }; ,$dek; Return }
                [void]$why.Add("enrollment $sc is stale (the key was rotated, or the .mori file was replaced)")
            }
            catch{ [void]$why.Add("enrollment $($sc): $($_.Exception.Message)") }
        }
    }
    if($passcache -and $passcache.Value){
        $dek = kngTryPass_ $key $passcache.Value
        if($dek){
            if($how){ $how.Value = 'pass' }
            summary_ INFO 'Unlocked with the team passphrase (entered earlier in this session)'
            ,$dek; Return
        }
    }
    if($silent){
        summary_ WARN 'Access failed (no prompt allowed)'
        $reason = if($why.Count){ " ($($why -join '; '))" }else{ '' }
        throw "Key $($key.id) is not available to $(kngMyName_)$reason. Enroll from the MACROSS menu ('enroll')."
    }

    kngSay_ "$(kngMyName_) is not enrolled for key $($key.id) on this computer." Yellow
    foreach($y in $why){ kngSay_ "  ($y)" DarkGray }
    $wrong = 0
    for($i = 1; $i -le 3; $i++){
        $pw = kngReadPass_ "Team passphrase for $($key.id) (attempt $i of 3, ENTER to cancel)"
        if($pw.Length -eq 0){ Break }
        $dek = kngTryPass_ $key $pw
        if($dek){
            if($passcache){ $passcache.Value = $pw }else{ kngWipe_ $pw }
            if($how){ $how.Value = 'pass' }
            summary_ INFO 'Unlocked with the team passphrase' $wrong
            ,$dek; Return
        }
        kngWipe_ $pw
        $wrong++
        kngSay_ 'That passphrase did not unlock this key.' Yellow
    }
    if($wrong -ge 3){ summary_ ERROR 'Access failed: 3 wrong passphrase attempts' $wrong }
    else{ summary_ WARN 'Access failed: passphrase entry cancelled' $wrong }
    throw "Could not unlock key $($key.id)."
}

## Save a per-account DPAPI enrollment next to the key (or locally if that folder is read-only)
function kngEnrollMe_($key,[byte[]]$dek,[string]$klocal){
    $sid = kngMySid_
    $blob = kngUserProtect_ $dek (kngUtf8_ (kngAad_ $key "user|$sid"))
    $side = [pscustomobject][ordered]@{
        v=2; type='user'; id=$key.id; sid=$sid; name=(kngMyName_); host=[Environment]::MachineName
        created=(Get-Date -Format 's'); blob=(kngB64_ $blob)
    }
    $targets = @(Split-Path $key._file)
    if($klocal){ $targets += (Join-Path $klocal 'kawa') }
    foreach($t in ($targets | Select-Object -Unique)){
        try{
            if(-not (Test-Path $t)){ New-Item -ItemType Directory -Path $t -Force | Out-Null }
            $f = kngSidecar_ $key $t $sid
            [IO.File]::WriteAllText($f,($side | ConvertTo-Json),[Text.UTF8Encoding]::new($false))
            Return $f
        }
        catch{ }    ## folder not writable; try the next one
    }
    throw "Could not save the enrollment for $($key.id) in $($targets -join ' or ')."
}

## Build the slots that grant access (domain rule + passphrase), reporting what it did
## Recovery slot: when a team key is set up (config 'tpk'), a fresh team slot is always made
## (no passphrase needed, and older passphrase/team slots are replaced). Without a team key:
## $pw = new passphrase for a passphrase slot; when it's empty, the key's existing passphrase
## slot(s) are kept (valid as long as the data key hasn't changed, i.e. not rotating).
function kngGrant_($key,[byte[]]$dek,[byte[]]$pw,[int[]]$tiers,[string[]]$principals){
    $who = @(kngPrincipals_ $tiers $principals)
    $dom = @($who | ?{ $_.kind -eq 'domain' })
    $slots = New-Object System.Collections.ArrayList
    $note = $null
    if($dom.Count -gt 0){
        $rule = ($dom | %{ "SID=$($_.sid)" }) -join ' OR '
        try{
            $blob = kngNGProtect_ $rule $dek
            [void]$slots.Add([pscustomobject][ordered]@{
                type='domain'; rule=$rule; names=(($dom | %{ $_.name }) -join ', '); blob=(kngB64_ $blob) })
        }
        catch{ $note = "Domain slot not created: $($_.Exception.Message)" }
    }
    else{ $note = 'No domain accounts or groups were found in the selected tiers.' }
    $team = kngTeamSlot_ $key $dek
    if($team){ [void]$slots.Add($team) }
    elseif($pw -and $pw.Length){ [void]$slots.Add((kngPassSlot_ $key $dek $pw)) }
    else{ foreach($s in @($key.slots | ?{ $_.type -in @('pass','team') })){ [void]$slots.Add($s) } }
    $pending = @($who | ?{ $_.kind -ne 'domain' -or $note } | %{ [pscustomobject][ordered]@{ name=$_.name; sid=$_.sid } })
    if($note){ $dom = @() }     ## nobody actually got domain access
    Return [pscustomobject]@{ slots=@($slots); pending=$pending; note=$note; domain=$dom }
}

## Re-grant access to one key from the tier lists/groups. -rotate also replaces the key's data
## key (needs $newpw), which cuts off enrollments and the old passphrase. Returns kngGrant_'s report.
function kngRewrapOne_($key,$dirs,[string]$klocal,[byte[]]$newpw,[int[]]$rt,[string[]]$rp,[switch]$rotate,[ref]$passcache){
    if($rotate -and -not (kngTeamPub_) -and -not ($newpw -and $newpw.Length)){ throw 'Rotating needs a new team passphrase.' }
    $dek = kngUnlock_ $key $dirs -passcache $passcache
    try{
        if($rotate){
            $pt = kngOpen_ $dek $key.data (kngAad_ $key 'data')
            kngWipe_ $dek
            $dek = kngRandom_ 32
            $key.data = kngSeal_ $dek $pt (kngAad_ $key 'data')
            kngWipe_ $pt
        }
        $g = kngGrant_ $key $dek $newpw $rt $rp
        $key | Add-Member -NotePropertyName tiers -NotePropertyValue @($rt) -Force
        $key | Add-Member -NotePropertyName extra -NotePropertyValue @($rp) -Force
        $key.slots = $g.slots; $key.pending = $g.pending
        kngWrite_ $key $key._file
        if($rotate){
            foreach($d in @($dirs) + @(Split-Path $key._file) | Select-Object -Unique){
                if(Test-Path $d){ Get-ChildItem -File -Path $d -Filter "$($key.id).*.slot" | Remove-Item -Force -ErrorAction SilentlyContinue }
            }
        }
        if(-not (kngCoversMe_ $g)){ [void](kngEnrollMe_ $key $dek $klocal) }
    }
    finally{ kngWipe_ $dek }
    kngLog_ INFO "Key $($key.id) $(if($rotate){'rotated'}else{'rewrapped'}) by $(kngMyName_)$(if($newpw){' (new team passphrase)'})"
    Return $g
}

## Report what kngGrant_ did
function kngReport_($g){
    if($g.note){ kngSay_ $g.note Yellow; kngSay_ 'Accounts must enroll with the team passphrase until that is fixed.' Yellow }
    if($g.domain.Count){ kngSay_ "Domain access: $(($g.domain | %{ $_.name }) -join ', ')" Green }
    if($g.pending.Count){ kngSay_ "Need to enroll (passphrase): $(($g.pending | %{ $_.name }) -join ', ')" Cyan }
}
function kngSecretInput_([string]$title,[string]$ask='Paste the value to protect (API key, token, password...):'){
    if(Get-Command getBlox -ErrorAction SilentlyContinue){
        $lines = getBlox -t $title -i $ask
        if($null -eq $lines){ Return $null }
        Return (@($lines) -join "`n").Trim()
    }
    kngSay_ $ask Cyan
    $ss = Read-Host " Value" -AsSecureString
    Return [Net.NetworkCredential]::new('',$ss).Password
}

## Personal (-own) keys: one file per account, <name>.<SID>.mori in the local kawa folder
function kngMeIsDomain_(){
    $dom = [Security.Principal.WindowsIdentity]::GetCurrent().User.AccountDomainSid
    Return [bool]($dom -and $dom.Value -ne (kngMachineDomain_))
}
function kngOwnFile_([string]$name,[string]$klocal){
    Join-Path (Join-Path $klocal 'kawa') "$name.$(kngMySid_).mori"
}
function kngOwnSave_([string]$name,[string]$value,[string]$file){
    $sid = kngMySid_
    $dek = kngRandom_ 32
    $pt = kngUtf8_ $value
    try{
        $key = [pscustomobject][ordered]@{
            v=2; id=$name; own=$true; owner=(kngMyName_); sid=$sid; created=(Get-Date -Format 's')
            data=$null; slots=@(); _file=$file
        }
        $key.data = kngSeal_ $dek $pt (kngAad_ $key 'data')
        $slots = New-Object System.Collections.ArrayList
        $why = @()
        if(kngMeIsDomain_){
            try{
                $blob = kngNGProtect_ "SID=$sid" $dek
                [void]$slots.Add([pscustomobject][ordered]@{ type='domain'; rule="SID=$sid"; names=(kngMyName_); blob=(kngB64_ $blob) })
            }
            catch{ $why += "domain: $($_.Exception.Message)" }
        }
        try{
            $blob = kngUserProtect_ $dek (kngUtf8_ (kngAad_ $key "user|$sid"))
            [void]$slots.Add([pscustomobject][ordered]@{ type='user'; sid=$sid; host=[Environment]::MachineName; blob=(kngB64_ $blob) })
        }
        catch{ $why += "account: $($_.Exception.Message)" }
        if($slots.Count -eq 0){
            kngLog_ ERROR "Personal key '$name' could not be saved; no protection method worked. $(kngWho_) reasons: $($why -join '; ')"
            throw "Could not protect the value for this account ($($why -join '; '))."
        }
        $key.slots = @($slots)
        kngWrite_ $key $file
    }
    finally{ kngWipe_ $dek; kngWipe_ $pt }
    kngLog_ INFO "$(kngMyName_) saved personal key '$name'"
}
function kngCoversMe_($grant){
    $me = kngMySid_
    Return [bool](@($grant.domain | ?{ $_.sid -eq $me }).Count -and -not $grant.note)
}


################################################################
## Public function
################################################################
function kawamori(){   #mp
    <#
    ||shorthelp||
    kawamori [-c KEY_NAME_OR_ID] [-g <GENERATE>] [-n <LITERAL NAME>] [-t TIERS]
        [-p EXTRA_PRINCIPALS] [-e <ENROLL>] [-rewrap [-rotate]] [-u <UPDATE VALUE>]
    kawamori all -rewrap [-rotate] [-t TIERS] [-p EXTRA_PRINCIPALS]
        [-i <INFO>] [-m <SHOW CREATED MSG>] [-local] [-silent]
    kawamori [-c NAME] -own [-ask PROMPT_TEXT] [-u <REPLACE>] [-forget]

    ||longhelp||
    Store secrets (API keys, tokens, passwords) that every authorized SOC account
    can use, including regular and admin-level domain accounts and local/non-AD
    accounts, without installing anything. Keys are .mori files (v2) in the kawa
    folder of $dyrl_CONTENT (shared) or $dyrl_RESOURCES (local). Older kawamori
    keys keep working with the original kawamori function.

    How access works:
      -Domain accounts in the MACROSS tier lists (and any -p groups/users) can read
       the key from any domain computer; nothing to set up per user. Changes to
       group membership apply after the user logs on again.
      -Local/non-AD accounts (or anyone, if the domain slot can't be used) enroll
       once with the team passphrase; type "enroll" in the main menu or run
       "kawamori -e". After that, no passphrase is needed on that account.
      -The team passphrase also recovers a key if everything else fails, so keep
       it somewhere safe; anyone with it can read the keys.
      -The team passphrase is set by the MACROSS admin during setup (or main menu >
       config > 4), which creates a team key. Keys are created with the team key, so
       whoever creates a key never chooses or needs to know the passphrase. Changing
       the team passphrase there doesn't require updating any keys; creating a NEW
       team key does (kawamori all -rewrap).

    Options:
      -g          create a key (opens an entry box for the value). Returns the key
                  ID, or prints it with -m. The ID is based on the -c name unless
                  you use -n to make the name itself the ID. Requires the team
                  passphrase to have been set up by the admin.
      -t 1,2,3    which MACROSS tiers (user AND admin lists) get access; default all
      -p          extra domain groups/users, e.g. -p 'CORP\SOC Analysts','CORP\SOC Admins'
      -e          enroll this account (one key with -c, or every key without it)
      -rewrap     re-grant access from the current tier lists (and the tiers/
                  groups the key was created with, unless you give new -t / -p).
                  Use a key ID, or 'all' for every shared key in the central kawa
                  folder ($dyrl_CONTENT\kawa; personal -own and legacy files are
                  skipped). The team passphrase is kept unless you choose to
                  change it, so no passphrase is needed when your account can
                  already open the keys. Add -rotate to replace each key's
                  internal data key, which cuts off every existing enrollment and
                  anyone who had the old passphrase (a new passphrase is set).
      -u          replace the protected value, keeping everyone's access
      -i          show who has access (never shows the value)
      -local      prefer the local resources\kawa copy over the shared one
      -silent     never prompt; throw an error instead (used by python)

    Personal values (-own):
      For services where every analyst has their own API key (or any value that
      shouldn't be shared), a diamond can just call kawamori with -own and a name.
      The first time, the user is asked to paste their value; it is protected for
      that account only and saved in their local resources\kawa folder as
      <name>.<their SID>.mori. Every later call returns it without prompting. If
      the saved value can't be unlocked (e.g. the account's profile was reset),
      the user is simply asked to paste it again.
      -ask        the text shown in the paste box
      -u          ask for a new value and replace the saved one (e.g. the key changed)
      -forget     delete this account's saved value
      -silent     don't prompt; throw an error if nothing usable is saved

    ||examples||
    Create a key for all tiers plus two AD groups, and print its ID:

        kawamori -c 'virustotal' -g -m -p 'CORP\SOC Analysts','CORP\SOC Admins'

    Use it in a diamond:

        $vtkey = kawamori 'virustotal-Ab3dE9xQ2mPz'

    Enroll a local account for every key, or see who has access:

        kawamori -e
        kawamori 'virustotal-Ab3dE9xQ2mPz' -i

    After changing the tier lists in "config" (one key, or every shared key):

        kawamori 'virustotal-Ab3dE9xQ2mPz' -rewrap
        kawamori all -rewrap

    Someone left the team and may have copied keys or known the passphrase:

        kawamori all -rewrap -rotate

    Each analyst uses their own API key (asks once, then remembers it):

        $vtkey = kawamori 'virustotal' -own -ask 'Paste your VirusTotal API key:'
        if(-not $vtkey){ Return }   ## user cancelled

    The user's key changed:

        $vtkey = kawamori 'virustotal' -own -u

    #>
    param(
        [Parameter(Position=0)]
        [string]$cid,
        [switch]$gen,
        [switch]$no_uid,
        [switch]$msg,
        [int[]]$tiers=@(1,2,3),
        [string[]]$principals=@(),
        [switch]$enroll,
        [switch]$rewrap,
        [switch]$rotate,
        [switch]$update,
        [switch]$info,
        [switch]$local,
        [switch]$silent,
        [switch]$own,
        [string]$ask='',
        [switch]$forget,
        $value=$null,
        [string]$kshare=$dyrl_CONTENT,
        [string]$klocal=$dyrl_RESOURCES,
        [string]$klog=$dyrl_LOG
    )
    $dirs = kngDirs_ $kshare $klocal -localfirst:$local
    $Global:dyrl_KNGLOG = $klog         ## used by kngLog_ when errLog isn't loaded

    ######## Personal value for this account (-own) ########
    if($own){
        if(-not $cid){ throw 'kawamori -own needs a name, e.g. kawamori ''virustotal'' -own' }
        if($cid -match '[\\/:*?"<>|]'){ throw "'$cid' contains characters that can't be used in a filename." }
        if(-not $klocal){ throw 'No local resources folder is configured for personal keys.' }
        $file = kngOwnFile_ $cid $klocal
        if(-not $ask){ $ask = "Paste your value for '$cid'. It will be protected for $(kngMyName_) only:" }

        if($forget){
            if(Test-Path $file){ Remove-Item -Force $file; kngSay_ "Removed your saved '$cid' value." Green }
            else{ kngSay_ "You have no saved '$cid' value." Yellow }
            kngLog_ INFO "$(kngMyName_) removed personal key '$cid'"
            Return
        }

        ## Use the saved value unless replacing it
        if((Test-Path $file) -and -not $update -and $null -eq $value){
            try{ $key = kngRead_ $file }catch{ $key = $null }
            try{
                if(-not $key){
                    kngLog_ ERROR "Personal key '$cid' could not be read; $file is not a valid v2 key file (corrupted or replaced?). $(kngWho_)"
                    throw 'the file is not a valid v2 key'
                }
                $dek = kngUnlock_ $key @() -silent -nolog
                try{
                    $pt = kngOpen_ $dek $key.data (kngAad_ $key 'data')
                    try{ Return [Text.Encoding]::UTF8.GetString($pt) }finally{ kngWipe_ $pt }
                }
                finally{ kngWipe_ $dek }
            }
            catch{
                $m = $_.Exception.Message -replace " Enroll from the MACROSS menu \('enroll'\)\.$"
                if($silent){
                    kngLog_ WARN "Personal key '$cid' could not be unlocked (no prompt allowed). file=$file $(kngWho_) reasons: $m"
                    throw "Your saved '$cid' value could not be unlocked: $m"
                }
                kngLog_ INFO "Personal key '$cid' could not be unlocked; asking the user to enter it again. file=$file $(kngWho_) reasons: $m"
                kngSay_ "Your saved '$cid' value could not be unlocked, so it needs to be entered again." Yellow
                kngSay_ "  ($m)" DarkGray
            }
        }
        elseif(-not (Test-Path $file) -and $silent -and $null -eq $value){
            ## Not an error: python catches this and asks the user for the value
            throw "KAWAMORI_NOT_SAVED: no '$cid' value has been saved for $(kngMyName_)."
        }

        ## Ask for the value (or take it from -value) and save it
        if($null -ne $value){ $v = "$value" }
        else{ $v = kngSecretInput_ "MACROSS: $cid" $ask }
        if(-not $v){ kngSay_ "No value entered for '$cid'." Yellow; Return $null }
        kngOwnSave_ $cid $v $file
        if($null -eq $value){ kngSay_ "Saved. Your '$cid' value will be used automatically from now on." Green }
        Return $v
    }

    ######## Create ########
    if($gen){
        if(-not $cid){ throw 'kawamori -g needs a name (-c).' }
        if($no_uid){ $id = $cid }
        else{
            $base = ($cid -replace '[^\w-]','')
            if($base.Length -gt 15){ $base = $base.Substring(0,15) }
            $an = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
            $rb = kngRandom_ 12
            $id = "$base-$(-join ($rb | %{ $an[$_ % $an.Length] }))"
        }
        if($id -match '[\\/:*?"<>|]'){ throw "Key ID '$id' contains characters that can't be used in a filename." }
        if($id -eq 'all'){ throw "'all' is reserved (kawamori all -rewrap); choose another name." }
        if(kngFind_ $id $dirs){ throw "Key $id already exists; use -u to change its value or -rewrap to change access." }

        $value = kngSecretInput_ "MACROSS key: $id"
        if(-not $value){ kngSay_ 'Cancelled; no key was created.' Yellow; Return }

        ## Write to the shared content folder if possible, otherwise locally
        $target = $null
        foreach($d in (kngDirs_ $kshare $klocal)){
            try{
                if(-not (Test-Path $d)){ New-Item -ItemType Directory -Path $d -Force -ErrorAction Stop | Out-Null }
                $probe = Join-Path $d ".write-test-$PID"
                [IO.File]::WriteAllText($probe,''); Remove-Item $probe -Force
                $target = Join-Path $d "$id.mori"; Break
            }
            catch{ }    ## not writable; try the next folder
        }
        if(-not $target){ throw 'No writable kawa folder was found.' }

        ## The recovery slot uses the team key set up by the MACROSS admin, so whoever creates a
        ## key never chooses (or needs to know) the team passphrase.
        if(-not (kngTeamPub_)){
            throw 'No team passphrase has been set up yet, so keys can''t be created. Ask the MACROSS admin to set one: main menu > config > 4.'
        }
        $pw = $null
        $dek = kngRandom_ 32
        $pt = kngUtf8_ $value; Remove-Variable value
        try{
            $key = [pscustomobject][ordered]@{
                v=2; id=$id; created=(Get-Date -Format 's'); by=(kngMyName_)
                tiers=@($tiers); extra=@($principals)       ## remembered for -rewrap
                data=$null; slots=@(); pending=@(); _file=$target
            }
            $key.data = kngSeal_ $dek $pt (kngAad_ $key 'data')
            $g = kngGrant_ $key $dek $pw $tiers $principals
            $key.slots = $g.slots; $key.pending = $g.pending
            kngWrite_ $key $target
            if(-not (kngCoversMe_ $g)){ [void](kngEnrollMe_ $key $dek $klocal) }
        }
        finally{ kngWipe_ $dek; kngWipe_ $pt; kngWipe_ $pw }

        kngLog_ INFO "Key $id created by $(kngMyName_) in $target"
        kngReport_ $g
        if($msg){
            kngSay_ "Saved to $target" Green
            kngSay_ "SAVE THIS ID: $id" Yellow
            kngSay_ "Your diamonds can retrieve the value with:  kawamori $id" Green
        }
        else{ Return $id }
        Return
    }

    ######## Enroll ########
    if($enroll){
        $pc = $null
        if($cid){ $keys = @(kngFind_ $cid $dirs) }
        else{
            $seen = @{}
            $keys = foreach($d in $dirs){
                if(Test-Path $d){
                    Get-ChildItem -File -Path $d -Filter '*.mori' | %{
                        $k = kngRead_ $_.FullName
                        if($k -and -not $seen.ContainsKey($k.id)){ $seen[$k.id] = $true; $k }
                    }
                }
            }
        }
        $keys = @($keys | ?{ $_ -and -not $_.legacy -and -not $_.own })
        if(-not $keys.Count){ kngSay_ 'No v2 keys found to enroll.' Yellow; Return }
        try{
            foreach($k in $keys){
                $how = $null
                try{
                    $dek = kngUnlock_ $k $dirs -how ([ref]$how) -passcache ([ref]$pc)
                    if($how -eq 'domain'){ kngSay_ "$($k.id): already available through your domain account." Green }
                    elseif($how -eq 'user'){ kngSay_ "$($k.id): already enrolled." Green }
                    else{
                        $f = kngEnrollMe_ $k $dek $klocal
                        kngSay_ "$($k.id): enrolled ($f)." Green
                        kngLog_ INFO "$(kngMyName_) enrolled for key $($k.id)"
                    }
                }
                catch{ kngSay_ "$($k.id): $($_.Exception.Message)" Yellow }
                finally{ kngWipe_ $dek; $dek = $null }
            }
        }
        finally{ kngWipe_ $pc }
        Return
    }

    ######## Rewrap / rotate: one key, or 'all' shared keys in the central kawa folder ########
    if($rewrap){
        if(-not $cid){ throw "kawamori -rewrap needs a key ID, or 'all'." }
        if($cid -eq 'all'){
            $kdir = if($kshare){ Join-Path $kshare 'kawa' }else{ Join-Path $klocal 'kawa' }
            $keys = @(if(Test-Path $kdir){
                Get-ChildItem -File -Path $kdir -Filter '*.mori' | %{
                    $fi = $_
                    try{ $k = kngRead_ $fi.FullName }
                    catch{ $k = $null; kngSay_ "Skipping $($fi.Name): damaged ($($_.Exception.Message))" Yellow }
                    if($k -and -not $k.own){ $k }      ## legacy (v1) files read as $null and are skipped
                }
            })
            if(-not $keys.Count){ kngSay_ "No shared v2 keys found in $kdir." Yellow; Return }
            kngSay_ "Re-granting access for $($keys.Count) key(s) in ${kdir}:" Cyan
            $keys | %{ kngSay_ "  $($_.id)" }
        }
        else{
            $k = kngFind_ $cid $dirs
            if(-not $k){ throw "No key found for $cid." }
            if($k.legacy){ throw "$cid is a legacy (v1) key; recreate it with kawamori -g to use -rewrap." }
            $keys = @($k)
        }

        ## Recovery: with a team key (normal), each key's recovery slot is simply rebuilt from it;
        ## no passphrase questions. Without one (setups from before team keys), the per-key
        ## passphrase is kept unless changed; rotating always sets a new one.
        $newpw = $null
        if(kngTeamPub_){
            if($rotate){
                kngSay_ "Rotating replaces each key's data key: enrolled accounts must enroll again." Yellow
                kngSay_ 'To also cut off anyone who knew the team passphrase, replace the team key first (config > 4).' Yellow
            }
        }
        elseif($rotate){
            kngSay_ "Rotating replaces each key's data key: enrolled accounts must enroll again, and the old passphrase stops working." Yellow
            $newpw = kngNewPass_
        }
        else{
            $q = if($keys.Count -gt 1){ " Set a new team passphrase for all $($keys.Count) keys? (y/N)" }else{ ' Change the team passphrase? (y/N)' }
            if((Read-Host $q) -like 'y*'){ $newpw = kngNewPass_ }
        }

        $pc = $null; $ok = 0; $bad = New-Object System.Collections.ArrayList
        try{
            foreach($k in $keys){
                ## Reuse the tiers/groups each key was created with unless new ones were given
                $rt = if($PSBoundParameters.ContainsKey('tiers') -or -not $k.tiers){ $tiers }else{ [int[]]@($k.tiers) }
                $rp = if($PSBoundParameters.ContainsKey('principals') -or -not $k.extra){ $principals }else{ [string[]]@($k.extra) }
                if($keys.Count -gt 1){ Write-Host ''; kngSay_ "[$($k.id)]" Cyan }
                try{
                    $g = kngRewrapOne_ $k $dirs $klocal $newpw $rt $rp -rotate:$rotate -passcache ([ref]$pc)
                    kngReport_ $g
                    $ok++
                }
                catch{
                    [void]$bad.Add("$($k.id): $($_.Exception.Message)")
                    kngSay_ "Not updated: $($_.Exception.Message)" Yellow
                }
            }
        }
        finally{ kngWipe_ $newpw; kngWipe_ $pc }

        if($keys.Count -gt 1){
            Write-Host ''
            kngSay_ "Updated $ok of $($keys.Count) key(s)." $(if($bad.Count){ 'Yellow' }else{ 'Green' })
            foreach($b in $bad){ kngSay_ "  $b" Yellow }
            kngLog_ $(if($bad.Count){ 'WARN' }else{ 'INFO' }) "Rewrap all$(if($rotate){' (rotate)'}): $ok of $($keys.Count) key(s) updated by $(kngMyName_)$(if($bad.Count){ "; failed: $($bad -join '; ')" })"
        }
        if($rotate -and $ok){ kngSay_ 'Rotated: every enrolled account must enroll again.' Yellow }
        Return
    }

    if(-not $cid){ throw 'kawamori needs a key ID.' }
    $key = kngFind_ $cid $dirs
    if(-not $key){
        kngLog_ ERROR "No key found for $cid in $($dirs -join ', '). $(kngWho_)"
        throw "No key found for $cid."
    }
    if($key.legacy){
        if($info -or $rewrap -or $update){ throw "$cid is a legacy (v1) key; recreate it with kawamori -g to use these options." }
        Return (kawamori $cid -local:$local)
    }

    ######## Info ########
    if($info){
        kngSay_ "Key:      $($key.id)" Cyan
        kngSay_ "File:     $($key._file)" Cyan
        kngSay_ "Created:  $($key.created) by $($key.by)" Cyan
        $ds = @($key.slots | ?{ $_.type -eq 'domain' })
        if($ds.Count){ kngSay_ "Domain:   $($ds.names -join ', ')" Green }
        else{ kngSay_ 'Domain:   (none)' Yellow }
        $tslot = @($key.slots | ?{ $_.type -eq 'team' })
        $rec = if($tslot.Count){
                   $pub = kngTeamPub_
                   if($pub -and ($tslot.kid -contains (kngTeamKid_ $pub))){ 'team passphrase' }
                   else{ 'team passphrase (OLD team key: run kawamori all -rewrap)' }
               }
               elseif(@($key.slots | ?{ $_.type -eq 'pass' }).Count){ 'key passphrase (moves to the team key at the next -rewrap)' }
               else{ 'none' }
        kngSay_ "Recovery: $rec" Cyan
        $enrolled = foreach($d in @($dirs) + @(Split-Path $key._file) | Select-Object -Unique){
            if(Test-Path $d){ Get-ChildItem -File -Path $d -Filter "$($key.id).*.slot" | %{ (Get-Content -Raw $_.FullName | ConvertFrom-Json) } }
        }
        $enrolled = @($enrolled | ?{ $_ })
        if($enrolled.Count){ kngSay_ "Enrolled: $(($enrolled | %{ "$($_.name) on $($_.host)" }) -join ', ')" Green }
        $waiting = @($key.pending | ?{
            $p = $_
            -not ($enrolled | ?{ ($p.sid -and $_.sid -eq $p.sid) -or ($_.name -split '\\')[-1] -eq ($p.name -split '\\')[-1] })
        })
        if($waiting.Count){ kngSay_ "Not enrolled yet: $(($waiting | %{ $_.name }) -join ', ')" Yellow }
        Return
    }

    ######## Update value ########
    if($update){
        $dek = kngUnlock_ $key $dirs
        try{
            $value = kngSecretInput_ "MACROSS key: $($key.id) (new value)"
            if(-not $value){ kngSay_ 'Cancelled; the key was not changed.' Yellow; Return }
            $pt = kngUtf8_ $value; Remove-Variable value
            $key.data = kngSeal_ $dek $pt (kngAad_ $key 'data')
            kngWrite_ $key $key._file
        }
        finally{ kngWipe_ $dek; kngWipe_ $pt }
        kngLog_ INFO "Key $($key.id) value updated by $(kngMyName_)"
        kngSay_ "Updated $($key.id)." Green
        Return
    }

    ######## Retrieve ########
    $how = $null
    $dek = kngUnlock_ $key $dirs -silent:$silent -how ([ref]$how)
    try{
        $pt = kngOpen_ $dek $key.data (kngAad_ $key 'data')
        if($how -eq 'pass' -and -not $silent){
            try{
                $f = kngEnrollMe_ $key $dek $klocal
                kngSay_ "Enrolled $(kngMyName_) for $($key.id); no passphrase needed next time." Green
                kngLog_ INFO "$(kngMyName_) enrolled for key $($key.id)"
            }
            catch{ kngSay_ "Could not save an enrollment: $($_.Exception.Message)" Yellow }
        }
        Return [Text.Encoding]::UTF8.GetString($pt)
    }
    finally{ kngWipe_ $dek; kngWipe_ $pt }
}
