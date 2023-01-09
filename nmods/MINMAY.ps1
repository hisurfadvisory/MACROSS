#_wut Demo powershell launching MILIA.py functions
#_ver 0

transitionSplash 5

function splashPage(){
    cls
    $b = 'ICAgICAgIOKWiOKWiOKWiOKVlyAgIOKWiOKWiOKWiOKVl+KWiOKWiOKVl+KWiOKWiOKWiOKVlyA
    gIOKWiOKWiOKVl+KWiOKWiOKWiOKVlyAgIOKWiOKWiOKWiOKVlyDilojilojilojilojilojilZcg4paI
    4paI4pWXICAg4paI4paI4pWXCiAgICAgICDilojilojilojilojilZcg4paI4paI4paI4paI4pWR4paI4
    paI4pWR4paI4paI4paI4paI4pWXICDilojilojilZHilojilojilojilojilZcg4paI4paI4paI4paI4p
    WR4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4pWa4paI4paI4pWXIOKWiOKWiOKVlOKVnQogICAgICAg4pa
    I4paI4pWU4paI4paI4paI4paI4pWU4paI4paI4pWR4paI4paI4pWR4paI4paI4pWU4paI4paI4pWXIOKW
    iOKWiOKVkeKWiOKWiOKVlOKWiOKWiOKWiOKWiOKVlOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKWi
    OKVkSDilZrilojilojilojilojilZTilZ0gCiAgICAgICDilojilojilZHilZrilojilojilZTilZ3ilo
    jilojilZHilojilojilZHilojilojilZHilZrilojilojilZfilojilojilZHilojilojilZHilZriloj
    ilojilZTilZ3ilojilojilZHilojilojilZTilZDilZDilojilojilZEgIOKVmuKWiOKWiOKVlOKVnSAK
    ICAgICAgIOKWiOKWiOKVkSDilZrilZDilZ0g4paI4paI4pWR4paI4paI4pWR4paI4paI4pWRIOKVmuKWi
    OKWiOKWiOKWiOKVkeKWiOKWiOKVkSDilZrilZDilZ0g4paI4paI4pWR4paI4paI4pWRICDilojilojilZ
    EgICDilojilojilZEgCiAgICAgICDilZrilZDilZ0gICAgIOKVmuKVkOKVneKVmuKVkOKVneKVmuKVkOK
    VnSAg4pWa4pWQ4pWQ4pWQ4pWd4pWa4pWQ4pWdICAgICDilZrilZDilZ3ilZrilZDilZ0gIOKVmuKVkOKV
    nSAgIOKVmuKVkOKVnSA='
    getThis $b
    Write-Host '
    '
    Write-Host -f YELLOW $vf19_READ
    Write-Host -f YELLOW '     =======================================================
              Making MACROSS play nice with python
    '
}


if($HELP){
    splashPage
    Write-Host -f YELLOW "
    This is a demo script to demonstrate using your python
    scripts within MACROSS to interact with other python
    or powershell scripts.

    Hit ENTER to continue.
    "
    Read-Host
    Exit
}

if( ! (Test-Path -Path "$vf19_TOOLSDIR\MILIA.py")){
    Write-Host -f CYAN '
    MILIA.py script not found! Exiting...
    '
    ss 2
    Exit
}

transitionSplash 3
splashPage

Write-Host -f GREEN "
  This is a basic demonstration of passing values to any of your python tools
  for processing.

  I'll be launching 'MILIA.py' while passing it MACROSS's default globals:

    1) Your username:  " -NoNewline; Write-Host -f YELLOW $USR
Write-Host -f GREEN "    2) Your desktop:  " -NoNewline; Write-Host -f YELLOW  $vf19_DEFAULTPATH
Write-Host -f GREEN "    3) The location of the script folder:  " -NoNewline; Write-Host -f YELLOW  $vf19_TOOLSDIR
Write-Host -f GREEN "    4) The encoded list of default filepaths:"
foreach($d in $vf19_MPOD.GetEnumerator()){
    Write-Host -f YELLOW "      $($d.Name)$($d.Value)"
}
  
Write-Host -f GREEN "
  Hit ENTER to see how the integrations work! (or 'q' to quit)  " -NoNewline;
$Z = Read-Host
if($Z -eq 'q'){
    Exit
}
cls
collab 'MILIA.py' 'MINMAY'
splashPage
Write-Host -f GREEN "
  Aaaand now we're back in Powershell!
  
  Hit ENTER to exit this demo.
  "
Read-Host
