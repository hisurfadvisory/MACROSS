#_sdf1 Demo - a basic config walkthru (6-8 mins)
#_ver 0.2
#_class user,demo script,powershell,HiSurfAdvisory,0,none

<#

    This script is a simple demonstration of collecting information
    from one script and passing it others that could add more detail
    or uncover more indicators related to your SOC investigations.
    
    This script requires the file "hikaru_demo.txt" in the resources folder.
#
#>

$dyrl_hik_HD = (Get-Content -Path "$vf19_TOOLSROOT\resources\hikaru_demo.txt") -Split("`n")
function splashPage($1){
    cls
    if($1 -eq 1){
        '' 
        screenResults '[macross] attributes:' ' .priv | .valtype | .lang | .auth | .evalmax | .rtype | .ver | .fname'
        screenResults 'Variables to remember' '$PROTOCULTURE, $CALLER, $RESULTFILE, $vf19_MPOD, $vf19_LATTS $vf19_TABLES'
        screenResults 'endr'
    }
    else{
    $b = 'ICAgICAgIOKWiOKWiOKVlyAg4paI4paI4pWX4paI4paI4pWX4paI4paI4pWXICDilojiloj
    ilZcg4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKVlyDilojilojilZcgICDi
    lojilojilZcKICAgICAgIOKWiOKWiOKVkSAg4paI4paI4pWR4paI4paI4pWR4paI4paI4pWRIOKWi
    OKWiOKVlOKVneKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+
    KWiOKWiOKVkSAgIOKWiOKWiOKVkQogICAgICAg4paI4paI4paI4paI4paI4paI4paI4pWR4paI4pa
    I4pWR4paI4paI4paI4paI4paI4pWU4pWdIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkeKWiOKWiOKW
    iOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVkSAgIOKWiOKWiOKVkQogICAgICAg4paI4paI4pWU4pWQ4
    pWQ4paI4paI4pWR4paI4paI4pWR4paI4paI4pWU4pWQ4paI4paI4pWXIOKWiOKWiOKVlOKVkOKVkO
    KWiOKWiOKVkeKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVkSAgIOKWiOKWiOKVkQogICA
    gICAg4paI4paI4pWRICDilojilojilZHilojilojilZHilojilojilZEgIOKWiOKWiOKVl+KWiOKW
    iOKVkSAg4paI4paI4pWR4paI4paI4pWRICDilojilojilZHilZrilojilojilojilojilojilojil
    ZTilZ0KICAgICAgIOKVmuKVkOKVnSAg4pWa4pWQ4pWd4pWa4pWQ4pWd4pWa4pWQ4pWdICDilZrilZ
    DilZ3ilZrilZDilZ0gIOKVmuKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWdIOKVmuKVkOKVkOKVkOK
    VkOKVkOKVnSA='
    getThis $b
    Write-Host '
    '
    Write-Host -f YELLOW $vf19_READ
    Write-Host -f CYAN   '              A demo of MACROSS automations
    
    '
    }
    
}

if($HELP){
    splashPage
    $vf19_LATTS['HIKARU'].toolInfo() | %{
        Write-Host -f YELLOW $_
    }
    Write-Host "
      ======================================================================
  This script is a simple walkthru on how to use the MACROSS framework to connect
  your scripts together. The main goal of MACROSS is to automate your automations;
  give even your most junior analysts the ability to get as much information as
  quickly and easily as any crusty ol' command-line junkie -- on a budget!
  
  HIKARU explains the rules/guidelines of the framework that help automate your
  automations. It takes about 3 minutes for a quick overview, or you can pick the
  detailed option which takes around 6-8 minutes to go through the basics.
  
  Hit ENTER to exit.
  "
    Read-Host
    Exit
}

function next($1){
    if($1 -eq 1){
        while($Z -ne 'c'){
            Write-Host -f GREEN "
    Type 'c' to continue! " -NoNewline;
            $Z = Read-Host
        }
    }
    else{
        Write-Host -f GREEN "
    Hit ENTER to continue!
        "
        Read-Host
    }
}

$dyrl_hik_Z = $null
$K = 'KONIG'
if($N_){ $K = "K$(chr 214)NIG" }

transitionSplash 8 2
splashPage

while($dyrl_hik_Z -notIn 1..3){
    Write-Host -f GREEN '
        Choose a walk-thru:

        1. Quick & dirty (2-3 mins)
        2. Detailed (6-8 mins)
        3. Quit
    
        > ' -NoNewline;

        $dyrl_hik_Z = Read-Host
        if($dyrl_hik_Z -eq '3'){
            Exit
        }
}

function writeDemo($1){
    getThis $dyrl_hik_HD[$1]
    $a = ([System.Management.Automation.Language.Parser]::ParseInput($vf19_READ, [ref]$null, [ref]$null)).GetScriptBlock()
    Invoke-Command -NoNewScope $a
}


if($dyrl_hik_Z -eq 2){
    splashPage
    writeDemo 3
    
	Read-Host
    splashPage 1
    
    writeDemo 4
    
	Read-Host
    splashPage 1
	
    writeDemo 5
    
	Read-Host
    splashPage 1
    
    writeDemo 6
    
	Read-Host
    splashPage 1
    
    writeDemo 7
    
    Write-Host -f GREEN "
 Give me a keyword or keywords like 'sql', 'sql audit', or an ID like 24054, and we'll see 
 what GUBABA comes up with: " -NoNewline;
 $dyrl_hik_Z = Read-Host
 if($dyrl_hik_Z -ne ''){
    $Global:PROTOCULTURE = $dyrl_hik_Z
    $results = collab 'GUBABA.ps1' 'HIKARU'
    if($results.count -gt 0){
        $results.keys | Sort | %{
            screenResults $_ $results[$_]
        }
        screenResults 'endr'
        Write-Host -f GREEN '
 Your automation can now parse these and begin searching log files. But this is a very basic 
 example.'
    }
    else{
        screenResults "r~         No results found for $dyrl_hik_Z"
    }
    rv PROTOCULTURE -Scope Global
 }
    Write-Host -f GREEN '
 Hit ENTER to continue!'
	Read-Host
    splashPage 1
    
    writeDemo 8
    
    Read-Host
    $dyrl_hik_file = getFile
    if($dyrl_hik_file -ne ''){
        writeDemo 9
    }
    else{
        writeDemo 10
    }
    splashPage 1
    writeDemo 11
    next
    splashPage 1
    writeDemo 12
    Read-Host
    Exit
}
elseif($dyrl_hik_Z -eq 1){
    splashPage 1
    writeDemo 0
    splashPage 1
    writeDemo 1
    splashPage 1
    writeDemo 2
    Exit
}
