## Functions controlling MACROSS's display


######################################
## MACROSS banner
######################################
function splashPage(){
$b = 'ICAgICAgIOKWiOKWiOKWiOKVlyAgIOKWiOKWiOKWiOKVlyDilojilojilojilojilojilZcgIOKWiOKWiOKWiOKWiOK
WiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKVlyAg4paI4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKW
iOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKVlwogICAgICAg4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKVkeKWiOKWi
OKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKVkOKVkOKVneKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiO
KVlOKVkOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKVkOKVkOKVneKWiOKWiOKVlOKVkOKVkOKVkOKVkOKVnQogICA
gICAg4paI4paI4pWU4paI4paI4paI4paI4pWU4paI4paI4pWR4paI4paI4paI4paI4paI4paI4paI4pWR4paI4paI4pWRICAg
ICDilojilojilojilojilojilojilZTilZ3ilojilojilZEgICDilojilojilZHilojilojilojilojilojilojilojilZfil
ojilojilojilojilojilojilojilZcKICAgICAgIOKWiOKWiOKVkeKVmuKWiOKWiOKVlOKVneKWiOKWiOKVkeKWiOKWiOKVlO
KVkOKVkOKWiOKWiOKVkeKWiOKWiOKVkSAgICAg4paI4paI4pWU4pWQ4pWQ4paI4paI4pWX4paI4paI4pWRICAg4paI4paI4pW
R4pWa4pWQ4pWQ4pWQ4pWQ4paI4paI4pWR4pWa4pWQ4pWQ4pWQ4pWQ4paI4paI4pWRCiAgICAgICDilojilojilZEg4pWa4pWQ
4pWdIOKWiOKWiOKVkeKWiOKWiOKVkSAg4paI4paI4pWR4pWa4paI4paI4paI4paI4paI4paI4pWX4paI4paI4pWRICDilojil
ojilZHilZrilojilojilojilojilojilojilZTilZ3ilojilojilojilojilojilojilojilZHilojilojilojilojilojilo
jilojilZEKICAgICAgIOKVmuKVkOKVnSAgICAg4pWa4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ0g4pWa4pWQ4pWQ4pWQ4pW
Q4pWQ4pWd4pWa4pWQ4pWdICDilZrilZDilZ0g4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWdIOKVmuKVkOKVkOKVkOKVkOKVkOKVkOKV
neKVmuKVkOKVkOKVkOKVkOKVkOKVkOKVnQ=='
    $ip = $(ipconfig | Select-String "IPv4 Address") -replace "^.* : ",""
    $hn = hostname
    $vl = $vf19_VERSION.length
    cls
    Write-Host "
    "
    getThis $b
    Write-Host -f CYAN "$vf19_READ"
    Write-Host -f CYAN "  ======================================================================" 
    Write-Host -f YELLOW "               Welcome to Multi-API-Cross-Search, " -NoNewline;
        Write-Host -f CYAN "$USR"
    Write-Host -f YELLOW "             Host: $hn  ||  IP: $ip"
    Write-Host -f CYAN "  ======================================================================"
    Write-Host -f CYAN "  ║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║║" -NoNewline;
    Write-Host -f YELLOW "v$vf19_VERSION" -NoNewline;
    if( $vl -lt 3){
        Write-Host -f CYAN "║║║║║"
    }
    elseif( $vl -le 4 ){
        Write-Host -f CYAN "║║║║"
    }
    elseif( $vl -le 5 ){
        Write-Host -f CYAN "║║"
    }
    elseif( $vl -ge 6 ){
        Write-Host '
        '
    }
                                                                     
}


## Set $1 to 1 for VF-19, 2 for SDF-1, 3 for VF-1S, 4 for Gubaba, 5 for Minmay
## If these transition screens annoy you, just delete this entire function
function transitionSplash($1){
    cls
    if($1 -eq 1){
    $b = 'CiAgICAgICAgICAgICAgICAgICAgICAgICAgICBAKuKVkHcsICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgIOKVmeKWhOKBv3cgICDiloTiloTilZYgICAgICAgICAgICAg4p
    WT4pWr4paTYCAgICwswqvilZAqJeKVo+KWiOKWiCAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICDiiKkuICAp
    IOKVmeKWkOKWhGDilojilojilpPilZYgICAgICAgIOKVk+KVo+KVo+KWkuKVnMK/KiIgLHcq4oyg4oyQQOKWk+KWiOKWiOKVnCAgIC
    AgICAgICAgICAKICAgICAgICAgICAgICAgICAgIOKVk+KVpW1QzphRaiAgIGrilojiloggICBdWjssLDLDnOKUgOKVmeKVmeKVmeKV
    nVrDhEAm4pWcLOKWhOKWgC9gIOKUgOKWhFDilaniloDilpPilZwgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAg4pWTbe
    KVmeKVk+KWk+KWk0zilpPilojilpIgLDfilZAiwqzilZxgIGAqLCAgLuKUgCAgKi4sIE0gICAgICriloTilojilojilojilohN4pWQ
    w5HijJAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICziloTiloTilozilZHilpPilpPilpPiloAi4pWTLOKVoEMgICAgLC7ijJ
    DilIDilIBgYGAi4pWQwrvCq27ilaXilabilaN3d+KWhCw9fl7ilZPilpPilpPilojilojilpMswr/ilajigb8i4pWZIFwgICAgICAg
    ICAgIAogICAgICAgICAswqsq4pWZ4paA4paA4paA4paA4paA4pWZ4pWjIMKr4pWd4pWZ4paS4paSLn7ilZDilad+fsKr4pWTLOKVkz
    ssLCwsLCwq4paT4paT4pWRLCwsLOKWkuKWgOKWjOKUlCAgICDCteKWhOKVnH4gICAgIGB+IuKUkCAgICAgICAgCiAgICAgIOKVk8Ky
    YCAgICAgIHcq4pWZIuKWkCzilavilpLijJDilZBw4pWc4pWc4paA4paT4paA4paI4paEICDilZnilaLiloDiloDilpPiloTiloQgIC
    BgYF3DhyJgYCAg4pS8TSJN4pWlYOKVk34iKuKVk+KUgC4gICAgYCwqLCAgICAgCiAgICDilZJ34pWT4pWT4pWT4pSAXl4iYOKMoF3i
    lZPilZzilpLilpLilZ3DhiLilZnilpPilaVA4pWsKeKWgOKWiOKWhOKWgGAgIOKWk+KWk3Qs4paA4paI4paIICAg4pWR4pWjIiLilZ
    YgICDilZPilpPiloTilaLCvSAgICDilJQgIGAq4pWW4pSALiAgYMK7IuKVliAgIAogICAgICAgICAs4pWTd+KVkCIiICAg4pWlZ86m
    4pWdYOKWhOKWhOKWhOKWgOKVkeKWkm3ilZzilZxg4pWf4pWQfkwgICDilZnilpPiloziloR34oia4paAICAgICLilZbilZMgLCogIC
    AgICDiiKnilZogICAgICIq4oia4pSALixgLuKVlCAKICAs4pWT4pWQIiI7ICAgICAgICws4oyQ4pWX4paE4pWj4paTbeKWk1filaPi
    lohdLMKr4pWQIiAg4pWZ4pWmIC4i4pWWQOKWky7ilZnilZZgIjrilZB+fuKVk+KVnCwiICAgICAgIOKVmyJqICAgICAgICAgYCrDkS
    ogIApq4paT4pWZIFtgICAswrvilZdOImBgYGBgICAg4pWc4pWr4pWiQOKVkWAgICAgIOKVk8KyYOKWgOKWgOKUlC0g4paQ4paMVSAg
    ICLilIB34pWTRCDilJggICAgICAgICAgIOKVkSAgICAgICAgICAgICAgIAog4pWZwrpE4pWo4pWo4pWc4pWZ4pWZYCAgICAgICAgIC
    AgICDilZnilZkgICAgLCotICAgICAgICAgxpIgICAgIMK/4pWr4paAwqUgICAgICAgICAgICwqICAgICAgICAgICAgICAgIAogICAg
    ICAgICAgICAgICAgICAgICAgICAgIOKVk8+G4pWcICAgICAgICAgICDilZwgICAg4pWU4paTZ+KVo14gICAgICAgICAs4oipYCAgIC
    AgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICDilZHiloRgKuKWkOKWgOKWhGAgICAgICDilZPilZwgICAgIOKV
    meKVpeKVlyAgICAgICAgLOKVkGAgVSAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAg4pWR4paI4paI4p
    aIIOKVmeKVleKWgOKWhCAgICAvYCAgICAgICAg4pWZICAgIC7ilZAiICAgICDilowgICAgICAgICAgICAgICAgICAgCiAgICAgICAg
    ICAgICAgICAgICAgICAgLMOF4pWZICDilpDDhyBY4pWZ4paM4paAw5bilpMgICAgICAgICAgICLCssOcLCAgICAgw6bijJAg4pWRIC
    AgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICDCv+KVqeKWiOKWgOKWgOKWgOKWgOKWgCLiloQg4pWZ4paQ4paE
    wrLilZ/iloTiloTiloTiloTiloTiloTilZMgICAgICDilZlbL+KWkOKWhOKWhOKWhOKWhOKUmFbilZEgICAgICAgICAgICAgICAgIC
    AgCiAgICAgICAgICAgICAgICAgICDilZMiICAgICAgIOKVk+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKW
    iOKWiOKWiOKWiOKWhOKWhOKWhOKWhOKWhHnilpDiloTiloRN4paE4paE4pWZ4paE4pWZICAgICAgICAgICAgICAgICAgIAogICAgIC
    AgICAgICAgICAgICA0d+KVpeKVl+KVpm3CouKWgOKWiOKWiOKWiOKWiOKWiOKWiOKWgOKWgOKWgOKWgOKWiOKWiOKWiOKWiOKWiOKW
    iOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiFzilojiloziloDDnyJg4paIIuKWgFUgICAgICAgICAgICAgICAgICAKICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICLiloDiloDiloDilojiloDiloDiloDilojilojilojilojilojilojilojilaLi
    loggICBq4paI4paT4paE4paI4paI4paI4paI4paI4paI4paI4paE4paE4paE4paE4paE4paE4pWTICAgICAKICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIMKy4paA4paI4paI4paI4paIw5ziloDilojiloTiloTilogi4paQ4paI4paI
    4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paE4paEIAogICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgIuKWgOKWiOKWjCAg4paA4pWYICDilpDilojilojilojilojilojilojilojilojiloji
    lojilojilojilojilojiloggICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIOKWgO
    KWiCwgICAgIOKWiOKWiOKWiOKWgCIgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICAiTiAgICDilojilojiloAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgIOKVmeKWhCDilpPiloAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBg'
    $c = "                                           MACROSS 7 VF-19 'FIRE'"
    }
    elseif($1 -eq 2){
    $b = 'ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICDilZIKICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICDiloTCtVDiloQKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAg4pWSICAgICAgIOKWiOKWiOKWjOKWjAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIOKWhM+G
    4paTICAgICDilpDiloxb4paI4paM4paECiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBq4paI4paI4paQaC
    AgICDilpMgXeKWiOKWkOKWk+KVrAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg4paQ4paA4pWj4paM4paQ
    ICAgIOKWkOKWiOKWiOKWk+KWk+KWiGoKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIOKWiCziloTilowgIC
    AgICDijKDiloDiloTiloTilojiloggICAgICAgLOKWhAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg4paT
    4paI4paI4paMICAgICAg4paQ4paAIOKWiGDilowgICAgICAv4pWSYAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgIOKWiOKWgOKWiCrijJAgICAg4pScICDilpDilozilpAgICAgIOKWky8KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICDilowg4paTIFsgICAgICAgIOKWiCAgICAsYOKWjCAgIC/ilowKICAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICDilowgXOKWjGogICAs4paQTC7ilpDilojilpPilpMgZ+KWjEsgIOKVk3lgCiAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAg4paMIOKVmOKWjGTiloRMICAg4paT4paM4paSTeKWjMOG4paT4paQ4paT4pWV4pWTzqbilagKIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIMKi4pWoZyzilpPilpPilZPDqOKWk+KWhGDCvOKWk+KWkyDiloDi
    lojDkeKWk+KWjOKWk+KWiOKVnCAgICDilZPilojilpPilojilowKICAgICAgICAgICAgICAgICAgICAgICAgICAgw4d2ICAgICAgIC
    AgIGpgIOKVmCzilpDilpPilojilpPilpPiloh34pWR4paTYOKWkGAg4paQ4paI4paI4paT4paTw4filoTiloTiloTilpPiloTiloji
    lJjilojilozilpPiloQsCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAid+KVliDilaMs4pWUZ+KWhOKWk8KhL03igb8iauKWiO
    KWgOKWk+KWiOKWiOKWkOKWjCDilpDilpDilpJd4paE4paI4paA4paT4paIIOKWhOKWiOKWk+KWk+KWjMOH4paQ4paI4paT4paE4paI
    4paT4paTCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIOKVmeKWkuKVn+KWkOKWk+KWkuKWiOKWk+KWjOKWkyxL4paQ4paQ4p
    aI4paQ4paT4paI4paI4paI4paIVeKWkMKlIuKWk+KWiOKWiOKWhOKWkyJt4paI4paT4paA4paT4paMLOKWiOKWiCzilojilpPilozi
    lZUiCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICDilZ8g4pWZ4paT4paI4paM4paI4paM4paTXMOx4paIMeKWgOKWjOKWgO
    KWk+KWgOKWgOKVoSws4paI4paE4paM4paE4paT4oG/YOKUlOKUmOKWk+KWk+KWk+KWhOKWhOKWiOKWiOKWiOKWiOKWgOKWgCAg4pWZ
    4paQCiAgICAgICAgICAgICAgICAgICAgICAgICzilaYsN2DDhSzilaUi4pWd4paT4paT4paT4paI4paTIOKVqCDilpB5wrUg4paE4p
    aEw4filoTiloQ0ICDilZnilozilojilowgICAg4paT4paE4paI4paI4paI4paI4paI4paI4paMIkDDnHnilZTilpAKICAgICAgICAg
    ICAgICAgICAgICDCouKVpkDDkeKWjCws4paEcuKWk+KWkyDiloDiloTilZ/ilpJNd8Oc4paE4paTICDilZ7ilZHilZ3ilpDilojilp
    NO4paA4paI4pWQ4paI4paE4paE4paI4paIIEggIOKWiOKWk+KWiOKWiOKWiOKWiOKWiOKVlsaS4paA4paA4paIIOKVmQogICAgICAg
    ICAgICAgICzilZPiiKlQ4pWcYOKWhOKWhOKWiOKWiOKWjOKVmeKWhOKUgOKVmS/ilpPilohH4pWj4paTw4filassw6/ilpPilowgIC
    Bb4pWZJCAgJMORIsOm4paI4paI4paI4paI4paILOKVnCAk4paM4paQ4paI4paI4paI4paI4paI4paT4paT4paE4paA4paACiAgICAg
    ICAgIOKVk+KWhMKyIiDiloTiloTiloTiloDiloDilpHilozilojilojilojiloAs4pWfLOKMkOKVkCwozpMgICAg4pWi4pWhIEwgIC
    DCoSDilpAgIOKWhOKWhOKVmeKWhOKVmeKVo2Ag4pWZICAg4pWRW+KVmuKWk+KWk+KWgOKWiOKWiOKWiCLilpMKICAgICDijJBeLOKW
    kOKWhOKWgOKWiOKWgOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWhOKVq17iloDilojilaZ9LC4gIGAsIF
    tgIOKWkuKWjCAg4paI4pWZ4pWW4paS4paM4paA4paA4paE4pWmLCAgICBbw5HilpPilojilozilojilpPiloDilpAg4paMCiAgIC7i
    lIAi4paA4paI4paI4paI4paE4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paA4paA4pWg4paS4paSJOKVrOKWk+
    KWk8+E4pWRIiAs4pWa4pWr4pWRL+KWgExV4paI4paQ4paE4paI4paIKuKWgCAgICDiloRX4paMICAgICIgICAgIEMgIEwKICAgImAg
    S+KWk+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWgOKWgOKWgCwu4paELOKWjOKVo1BNYCAgYCJgICAgIOKVqeKWgGAg4paA4paI4p
    aI4paI4paI4paI4paI4paI4paA4pWXICAiw6HilozilojiloRQXCAgICAgICAg4pSc4paT4paTCiAgICAgMeKVmOKUgOKWgOKWiOKW
    iOKWgOKWgOKWiOKWjOKVklPiloTilpNS4pWQIiAgICAgICAgICAgICAgIFwgICAg4paI4paI4paIIuKWgOKWgOKWgOKWjOKVq+KWgM
    OF4paA4paAXiDilojilozilZhdLAogICAgICAgYOKWk+KWk+KWhOKWk+KWiOKWk+KWgMORImAgICAgICAgICAgICAgICAgICAgLOKW
    iOKWhOKWhOKWgOKWkOKWkOKWiOKWjCAgICDilpDilowgICAgz4TiloDilojiloQg4pWRJAogICAgICDilZUu4pWQXmAgICAgICAgIC
    AgICAgICAgICAgICAgICAgIMKqYCA7IOKWkOKWjOKWiOKWiOKWjOKVlSAgIOKWkyAgICAg4pWY4pWZ4paI4paEYOKVluKVnwogICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICxDICAgIFvilpAg4paI4paI4paM4pWhICAgXCwgICAg4pSAIuKWgOKWiCBg4p
    aTV+KVlQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIFkgICAgICDilogg4paA4paI4paI4paAICAgXeKWiCAgICAg
    4paSIOKWgOKWiMOW4oyQ4pWQXSwKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIOKVmCAgICBbIOKWgOKWiCDilojilo
    jilohyICAgIEzilZEgICAgIOKVmSDilojilojilZbColzilZnijJAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgLGAg
    ICAgICDilpDilows4paI4paI4paI4paAICAgICAgwr8gICAgXCBd4paI4paI4pWrLEws4paE4paECiAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgIMKsICAgICAgIOKWiCDiloggIOKVmeKWhCBQICAg4paI4paIICAgICDilZFI4paI4paIw5wgXkwgYOKBv+KM
    kAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICDOkyAgICAgIOKWiOKWiCDilojiloQs4paE4paQICAgICDilpPilohiLM
    Ot4paE4paE4paI4paI4paI4paMIOKVliAg4paIICDilJQKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICDiloggICAg4pSY
    LOKWiOKWiC8g4paI4paA4paAKiDOoyAgICDilZHiloDilojilojilojilojilpPiloDiloDilojilogg4pSU4pS0ICDiloggIEwKIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgICAg4pWU4paI4paI4paE4paEQOKWhOKWiOKWiOKWgOKUmCAg4paIICAgTSAgICAg4paQ
    IOKWkOKWiOKWhOKWgOKWgOKWgOKWjEHilZwiICzDheKWgDTilpPiloQg4pWf4oieCiAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AsYOKWhOKWiOKWiOKWk+KWiOKWiOKWhOKWgMaSYCAgIOKWgOKWiOKWhOKWiCAgICAgIF0s4pWT4pWQImAg4paT4paTICDGkiAgICAg
    KOKWkOKWhGAKICAgICAgICAgICAgICAgICAgICAgICAgICAg4paQIOKWgOKWgOKWgOKWgOKWgOKWgOKWgCzilaPijJDiloQuIMKh4p
    aQ4paA4paA4paIICQgICAgIOKMkOKVkF7ilZAsICDilpMgIOKWjCAgICBcICDiloDiloDilZnilZUKICAgICAgICAgICAgICAgICAg
    ICAgICAgICAsTVsiIuKWkEIgIOKMkF4iIuKWgOKWgOKWgMOR4pWSLGpDIF3ilIAgICBGICAgIFbCpeKWhOKWk86m4paQICAgICAgwr
    XilZMgXHRcXAogICAgICAgICAgICAgICAgICAgICAgICAgYCAgIOKVqCDilZ9bIOKVmyAgIFsgIExdw4filZziloziloTiloBOICAg
    ICAgICAgICDilpDilojilojilojilojiloRQIuKWhOKWhOKWiOKWiOKWhOKWk+KWiMOHXMK1CiAgICAgICAgICAgICAgICAgICAgIC
    AgIM6TICAgIFvilZHilozilozilZsgICAgYCAgIOKWgFLilojiloQvICBcICBdICx+Xlsq4paE4paI4paI4paI4paI4paI4paI4paI
    4paI4paI4paI4paI4paI4paI4paI4paI4paI4paMLAogICAgICAgICAgICAgICAgICAgICAgIOKVkiAgICziiKks4paE4paI4paI4o
    yQ4pSAICAgICAuLuKWiOKWiOKWiOKWjMKhICAgICAgQOKVkeKWgOKWiOKWiOKWgOKWgOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWgGAg
    YOKWgOKWgOKWgOKVmWAiCiAgICAgICAgICAgICAgICAgICAgICAgXOKWgOKWgOKWgOKWiOKWiOKWiOKWgOKWgOKWgOKWiOKWiOKWiO
    KWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWhGcsIFwgICAgICAgICBg4pSY4paA4paA4paA4pWZCiAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICBgICAgICLilpDiloDilojilojilojilojilojiloAgIOKVmeKWgOKWgOKWgOKWgOKWgGAK'
    $c = "                                           SDF MACROSS"
    }
    elseif($1 -eq 4){
    $b = 'QEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJiZAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBA
    QEBAQEBAQEBAQEBAQCYmJkBAQEBAQEBAQEBAQAolJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJiYoJS
    YlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlCiUlJSUlJSUlJSUlJSUlJSUlJSUlJSUl
    JSUlJSUlJSUmJiYmJiYlJSUlJSUlJSUlJigoJiUlJSUlJSUlJSUlJSUlJSUlJSUlJiYmJiYmJSUlJSUlJSUlJSUlJSUlJSUlJSUlJS
    UKJSUlJSUlJSUlJSUlJSUlJSUlJSUlJiMoKCgoKCgoKCgoKCgoKCgoKCgoKCglJiUlJSYoKCMmJSUlJSUlJSUlJiZAJSUlJSUlJSUl
    JSUlJSUlJSUlJSUlJSUlJSUlJSUlJSUlJgolJSUlJSUlJSUlJSUlJSUlJiUlJSUlJSUlJkAmJSgoKCgoKCgoIyUjKCgoKCgoKCgoJS
    YmKCgmJSUlJSUoJiUlJSUlJSUlJSUlJSUlJSUlJSYmJiYlJSUlJSUlJSUlJSUlJSUlCiUlJSUlJSUlJSUlJSUlJSUlJSYlKCgoKCgo
    KCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgmJSMoQCYjKCgoKCgoKCgoKCgjJSYmJSUlJSUlJSUlJSUlJSUlJSUlJSUlIyMKJS
    UlJSUlJSUlJSUlJSYlKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgjJSZA
    JiUmJiUlJSUlJSUjIyMjIyMjIyMjIwolJSUlJSUlJSUlJigoKCMmIygoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKC
    goKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoJSUmJiMjIyMjIyMjIyMjIyMjCiUlJSUlJSUlKCgmQCUoIyMoKCgoKCgoKCgoKCgo
    KCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoJSUjIyMjIyMjIyMjIyMKIyMjIy
    YoJSVAIyMjIyMoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgo
    KCglJSgoKCgoJSMjIyMjIyMjIwojJSUmJUAjIyMjIyMjIygoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKC
    goKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgjJigoKCUlIyMjIyMjCkAlJiYjIyMjJSMjIyMoKCgoKCgoKCMjKCgoKCgoKCgo
    KCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCVAKCglIyMjIyMKJiUjIyNAJi
    MjIyMjKCgoKCgoI0BAKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgo
    KCgoKCgoKCgjJiMoJSMjIwojIyUmJiMjIyMjIygoKCgoJkBAQCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKC
    goKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoJSYjJiMjCiYlJSUjIyMjIyMoKCgoQEBAQEAoKCgoKCgoKCgoKCgoKCgo
    KCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCUmJSMKIyYjIyMjJSYjKC
    goQEBAQEBAKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgo
    KCgoKCgoKCgoKCMlQAomIyMjI0AmIyMjQEBAQEBAQCgoKCgoKCMlKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKC
    8jIy8sLi4uLi4uKi8jKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgmCiMjIyVAJiMjJUBAQEBAQEAjKCgoKCNAKCgoKCgoKCgoKCgoIyUj
    KCosLCwsLyMlIygoKCgoKCgoKCgoIy8uLi4uLi4uLi4uLi4uLi4uLi4vIygoKCgoKCgoKCgoKCgoKCgoIygKIyMmQEAjJkBAQEBAQE
    BAJigoKCNAJigoKCgoKCgvIyMuLi4uLi4uLi4uLi4uLi4uLi4vIygoKCgoIywuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLiMoKCgoKCgo
    KCgoKCgoKCgoIwojJkBAJUBAQEBAQEBAQEAoKChAQCUoKCgoKCgjKi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLiUoKCMsLi4uLi4uLi
    4uLi4uLi4uLi4uLi4uLi4uLi8oKCgoKCgoKCgoKCgoKCgoCkBAQEBAQEBAQEBAQEAmI0BAQEAlKCMjKCgoKC4uLi4uLi4uLi4gLi4g
    IC4uLi4uLi4uLi4uLiMoLC4uLiwoKi4uLi4uLiAuLi4uLi4gLi4uLi4uLi8oKCgoKCgoKCgoKCgoKCgKQEBAQEBAQEBAQEBAQEBAQE
    BAQCgmJigoIyouLi4uLi4uLi4uLi4uLi4uLi4uLi4lLC4uKiwuLiUuLiwlLi4uLi8uLi4uLi4uLi4uLi4uLi4uLi4uICMoKCgoKCgo
    KCgoKCgoKApAQEBAQEBAQEBAQEBAQEBAQEBAQEAjKCgvLi4uLi4uLi4uLi4uLi4uLi4uLi4sQCouLi4uLiouIy4uI0AsLi4uIy4uLi
    4uLi4uLi4uLi4uLi4uLi4uKC8oKCgoKCgoKCgoKCgoCkBAQEBAQEBAQEBAQEBAQEBAQEBAQCgoJS4uLi4uLi4uLi4uLi4uLi4uLi4u
    LipAQCMqLCwjJS4oLi4vQEBAQEBAKi4uLi4uLi4uLi4uLi4uLi4uLi4vLygoKCgoKCgoKCgoKCgKQEBAQEBAQEBAQEBAQEBAQEBAQE
    BAQEAjLi4uLi4uLi4uLi4uLi4uLi4uLi4uLiVAQCZAQCMjLiosLi4vKi4oQCMuLi4uLi4uLi4uLi4uLi4uLi4uLigvKCgoKCgoKCgo
    KCgoIwpAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCMuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4oKEAmKi4uKCMuLi4uLi4uLi4uLi4uLi
    4uLi4uLi4uLi4uLi4vKCgoKCgoKCgoKCgoKCMqCkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQC8uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
    Li4uLi4uLi4jKC8uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uIygoKCgoKCgoKCgoKCgjKCoKKEBAQEBAQEBAQEBAQEBAQEBAQEBAQE
    BAQC8uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4sIygoKCMsLi4uLi4uLi4uLi4uLi4uLi4uLi4uIygoKCgoKCgoKCgoKCgoKCUv
    LAosJUBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAsLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uJSgoKCgoKCgoIywuLi4uLi4uLi4uLi
    4uLCMjKCgoKCgoKCgoKCgoKCgoKCgoJS8sCiwoQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJSwuLi4uLi4uLi4uLi4uLi4uLi4l
    IygoKCgoKCglJiMoKCglJiUjIygjJSUlIyMjIyMlJSUjKCgjJSYmJSMoKCgoKCgjLyoKLCgjQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE
    BAQEBAQEBAQCYlKCoqLCwvKCUlJSMoIyYlIygoIyUjKCgoKCMjIyMoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKC8jLwos
    KCUjJkBAJUBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAmJiYmJiYmJiUlJSUlJSMjIygoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKC
    goKCgoKCgoKCgoKCgoKCgoKCgoKCMvCi8vJSMjI0BAIyZAQEBAQEBAQEBAQEBAQEBAQEBAQEAmJiYmJiYmJiYlJSUlIyMjIygoKCgj
    IygoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoIy8KLy8vJSMjIyMjIyVAQEBAQEBAQEBAQEBAQEBAQE
    BAJkBAJiZAQEBAQCYmJSUjIyMjKCgoKCMjKCgoKCgoKCgoJSgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgjLwovLy8v
    IyMjJiMjIyMmQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAJkAjJSYjIyMoKCgjIyYjKCgoJSgjJiglJigoKCgoKCgoKCgoKCgoKC
    goKCgoKCgoKCgoKCgoKCglKCMvCi8vLy8vJSYjJSMmIyMjQEBAJkBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAlQCYjJSMjJiMlQCUlJ
    igmJSUlJiNAJigoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCUjIyoKLy8vLy8vJS8mIyYoJiMjIyNAJSVAQEBAQEBAQEBAQEB
    AQEBAQEBAQEBAQCVAQCUjIyUmIyVAQEBAQEAlIyNAQEBAJigoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCglKCMoLAovLy8vLy8mK
    C8vJiUjIyUjIyMjIyNAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQCMlQCYjJUAmQEBAQCUlI0AmKCNAJSgoKCgoKCgoKCgoKCgoKCg
    oKCgoKCgoKCgoJSgjKCwsCi8vLy8vLyYoLy8vLyUmLyUjIyUjIyNAQCVAI0BAQEAmJkBAQEBAQEBAQEBAQEBAQEBAJiMlQCMjIyZAJ
    SMjJkAjKChAKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCUvKiUsLCwKLy8vKiwsJSwsLy8vLy8vLyMjIyUjIyNAQCMjI0BAQEAlJkB
    AJkBAQEBAQEBAQEBAQEAlIyYjIyMjI0AlIyMlQCMoKCglKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgmLywlLCwsLAovKiwsLCwvLCwsL
    CwqLy8vLyglIyYjIyNAJiMjIyZAQEAjJkBAJUBAQEBAQEBAQEAmQCUjJiMjIyMjJiUjIyVAIygoKCgoKCgoKCgoKCgoKCgoKCgoKCg
    oKCgoJSgsLywsLCwsCi8sLCwsLCwsLCwsLCwsKi8vLygjJSMlIyNAIyMjIyZAQCUjJkAmJUBAQEBAQEBAJiZAJSMjIyMjIyMlIyMjJ
    SYjIygoKCgoKCgoKCgoKCgoKCgoKCgoJSgoKCMoLCwsLCwsLCwKKiwsLCwsLCwsLCwsLCwsLCovLyMjIyUjIyUmIyMjIyVAJiMjJkA
    jJUAmQEBAQEAlIyUjIyMjIyMjIyMjIyMjJSMjKCgoKCgoKCgoKCgoKCgoKCgoKCYoKCgoJSosLCwsLCwsLAovLCwsLCwsLCwsLCwsL
    CwsLCwvLyYlLyUjIyUjIyMjIyNAJSMjQCUjJiZAQEBAIyMjIyMjIyMjIyMjIyMjIyMjIyMoKCgoKCgoKCgoKCgjKCgoKCgoJigoKCg
    oLCwsLCwsLCwsCi8sLCwsLCwsLCwsLCwsLCwsLCwvLyYvLyUjIyMjIyMjIyMmIyMjJSMjQCNAQEAjIyMjIyMjIyMjIyMjIyMjIyMjI
    ygoKCgoKCgoKCgoIygoKCgoKCUjKCgoJSosLCwsLCwsLCwKKiwsLCwsLCwsLCwsLCwsLCwsLCovJS8vJSMjIyMjIyMjIyMjIyMjIyM
    lJSVAQCMjIyMjIyMjIyMjIyMjIyMjIyMjKCgoKCgoKCgoKCgmKCgoKCgoJSMoKCMoLCwsLCwsLCwsLAoqLCwsLCwsLCwsLCwsLCwsL
    CwsLCovLy8vJSYjIyMjIyMlIyMjIyMjIyMlI0AmIyMjIyMjIyMjKCMjIyMjIyMjIyMoKCgoKCgoKCgoKCUoKCgoKCgjKCMoIy8sLCw
    sLCwsLCwsCiwsLCwsLCwsLCwsLCwsLCwsLCwsLCovLy8lJiMjIyMjIyYjIyMjIyMlIyMjJUAjIyMjIyMjIyMoIyMjIyMjIyMjIygoK
    CgoKCgoKCgjIygoKCgoJS8vIyglLywsLCwsLCwsLCwKLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCovLyNAJiMjIyMjIyUjIyMjIyUjIyM
    jQCMjIyMjIyMjKCgjKCMjIyMjIyMjKCgoKCgoKCgoKCMoKCgoKCglLy8jKCMqLCwsLCwsLCwsLAosLCwsLCwsLCwsLCwsLCwsLCwsL
    CwsKi8vKCYjIyMjIyMjJiMjIyMjJSMjIyMlIyMjIyMjIyMoKCMoIyMjIyMjIyMoKCgoKCgoKCgjIygoKCgoKCMvLy8lIy8sLCwsLCw
    sLCws'
    $c = "                                           Gubaba (MACROSS 7)"
    }
    elseif($1 -eq 5){
    $b = 'ICAgICAgICAgICAgICAgICAgICAgICAgICAgIOKWhOKWgOKWhOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiCwgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAg4paE4paI4paI4paI4paI4p
    aI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paILCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAg
    ICAgICAgICAgICAgICAgICAgIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiO
    KVlSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgIOKVkuKWiOKWiOKWiOKW
    iOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiCAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAg4paQ4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paIIOKW
    gOKWkOKWiOKWiOKWiOKWiOKWiOKWiCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgIC
    AgICAg4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paAICDiloDilojilojilojilojiloggICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICDilojilojilojilojilojilojilojilojilojilo
    DiloBgICAgICDilpDilojiloggICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAg
    ICDilojilojilojilojilojilojilojilojilojilojiloggICDiloTiloTilogg4pWSICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgIOKWhOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiCwgICDi
    loDilowsICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgIOKWiOKWiOKWiO
    KWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWk+KWk+KWiOKWk+KWhDte4paI4paE4pWQLOKVmyAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAs4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paT4p
    aT4paT4paT4paI4paT4paT4paT4paEeOKWiOKWhOKIniDijJAuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAg
    ICAgICAgICAgICAg4paI4paI4paI4paI4paI4paI4paI4paI4paA4paA4paE4paA4paI4paM4pWQLCrilpMg4paAaiBoICBg4paE4p
    aIICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAs4paI4paI4paI4paI4paI4paI4paI4paI
    ICAgICAg4pWZ4paILGDilZlO4paTLOKWk+KWk86TICAg4paI4paI4paAICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKIC
    AgICAgICAgICAgIOKWhOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiCAgICAgTi/ilZksLnfiloTiloDilojilojiloAl
    4oyQ4pWT4paT4paI4paI4paI4paITSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICzilojilojilojilojilo
    jilojilojilojilojilojilojilojilojilojilojilojilogs4paI4paI4paI4paI4paI4paAICDilZFyICAgICAg4paT4paIICDi
    loQgICDCsuKUgC4gICAgICAgICAgICAgICAgICAgICAgICAgIAogXl5e4paA4paA4paA4paAIOKWiOKWiOKWiOKWiOKWiOKWiOKWiO
    KWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiCAgIOKVmuKUkCAg4pWTICAgICAgw4bilpPilozilZNnwrXilojilpNA
    4pWWICAgIC0gICAgICAgICAgICAgICAgICAgICAgIAogICAgICAs4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4p
    aI4paI4paI4paI4paI4paI4paI4paIICAgICDiloAl4pWm4paTICAgICzilaPiloTilpPilpPilpPilpPiloBg4pWZ4paA4pWp4paT
    TiAgICBg4pWQICAgICAgICAgICAgICAgICAgICAKICAgICzilojilojilohg4paI4paI4paI4paI4paI4paI4paI4paI4paI4paI4p
    aI4paI4paI4paI4paI4paI4paI4paI4paI4pWVICAgIOKWiOKWk+KWgCLilZB34paE4paI4paT4paT4paT4paQ4pWi4paMICAg4pS0
    4pSQIOKVmeKWk+KVosOmLOKVk2AgICAgICIiXiwgICAgICAgICAgIAogICDilojilojiloggLOKWiOKWiOKWhOKWiOKWiOKWiOKWiO
    KWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiCAgQyAgICAs4paT4paA4pWj4paS4paS4paTIOKWjCAg
    ICAg4pSUICAgIGDilZriloBXICAgICAgICAgYCAgICAgICAgICAKICDilojiloggICzilojiloDilZLilojilojilojilojilojilo
    jilojilojilojilojilojilojilojilojilojilojilojilojiloggIOKVliAgICzilaPilojilpPiloTilanilZwiIuKWhCAgICAg
    ICAgICAgICBg4paT4paTVywgICAs4paE4paI4pWZLCAgIOKVlixw4pWQICAKICDiloggICDiloggIOKWiOKWiOKWiOKWiOKWiOKWiO
    KWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKWiCAgIDTilojPhuKWhOKWiOKWiOKWiOKWhCwgICAgzpMgIuKUgCAg
    ICAgICAgICAgICDilaPilpPilaLilpPilpPilojiloggIGriloxAICAgICAgIAog4paIICAg4paIICDilZLilojilojilojilojilo
    jilojilojilojilojilojilojilojilojilojilojilojilojilojilpAgICAgIiAs4paI4paI4paMIOKVmeKWgFAgIOKWhCAgICAg
    ICAgICAgICAgICAgICLilajilanilZwi4pWp4pWXICDilpPilZXilZN+ICAgIAogYCAgIOKWiCAg4paAIOKWiOKWiOKWiOKWiOKWiO
    KWiOKWiOKWiOKWiOKWiOKWiOKWk+KWiOKWiOKWgCAg4pWYICAgLOKVkOKVneKWk+KWgF3ilZnilowgICAgIOKWiOKWiCwgICAgICAg
    ICAgICAgICAgICAgICAgIGDilZAu4paQ4paA4paT4pWWfiAgCiAgICAgICAgICDiloDilojiloDilojilojilojilojilojilojilo
    jilohyICAgICAgIOKVnCAgIMaS4paIIOKWiCDilojilozilohX4paE4pWj4paS4paI4paI4paI4oip4pWWICAgICAgICAgICAgICAg
    ICAgICAgICAgICDilZnilaxbIAogICAgIGAgICBgIOKWiCDilojilojilojilojilojilojilpPilZzilowgICDilZNNw6kgICzCou
    KUmCDilojilohdIOKWiOKWiCDilojiloggICDilJTilpHiloDilpEg4oip4oipICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAg
    ICAgICAgICAg4paQwqLilazilaLilpPiloBgICAgIOKVk8Ky4pWTIOKVnCAr4pWc4paMICAsLSDijKEg4pWf4paQ4paMIOKWgHcgIC
    Ag4paS4paR4paSLCogICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgIOKVmOKWkuKWkuKWkmAgICAgICAgICAu4pWc
    4pWU4pWiIOKVkkMgLGAgIF0gYCDilasgICAg4oG/wqwgIOKUlOKWkuKWkuKWkiBgICAgICAgICAgICAgICAgICAgICAgICAgIAogIC
    AgICAgICAgIOKVkiAgICAgICAgICDDhiDilpAgYCAg4pWY4paMwr/iloggICAg4pWVICAgYCAgICAgLOKVpSAgIOKUtOKWkVIsICAg
    ICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAg4paE4pWdICDilJQsLuKMkG1O4paI4paI4paMICAgICBcIC
    DijJDigb9q4paSICAgLiAgLCws4pWT4pWR4pWj4omIICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgIGAgICDDhuKW
    jCAgICAgICAgICDilpPiloggICLilLTCqsOn4pWT4pWWLCwsLFtOJOKWk+KWk+KWiOKWkyAgICLilaPilpLilpHilpIuICAgICAgIC
    AgICAgICAgICAgICAKICAgICAgICAgICAgICAgIOKBvyDilZwgICAgICAgICAgLOKWgOKWiCAgICAgICAg4paQ4paTYCAgICAg4paT
    4pWo4paTUiAgICAgN2AgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgIOKVkCwgICAgICAgIOKWjOKWkiAgIC
    AgICAgIGrilpJMICAgICAg4pWZ4paS4paE4paQLC5eICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAg
    ICBgXuKVkOKUkCwg4paIwqrilasgICAgICAgICAgw5zilpAgICAgICAs4oyQKiAgICAgICAgICAgICAgICAgICAgICAgICAgICAKIC
    AgICAgICAgICAgICAgICAgICAgICAgICDilpPilojilpPilojilozilZMsLCwsLCwsLCzilojilpPiloTilZReYCAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgIOKWkOKWk+KVnCJgYCIi4paA4paT4paT4paI4p
    aI4paI4paT4paT4paT4paT4paIICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAg
    ICAgICAg4paTICAgICAgIOKWkOKWk+KWiOKWk+KWk+KWk+KWk+KWk+KWiEMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAg4oipICAgICAgIOKWk+KWiOKWk+KWk+KWk+KWk+KWk+KWkyAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAg4pWaICAgICAgIOKVn+KWiOKWk+KWk+
    KWk+KWk+KWk+KWjCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAg
    IOKVlSAgICAgIF3ilojilpPilpPilpPilpPilpMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgYCAgICAgIF3ilojilpPilpPilpPilpPilpMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICAgICAg'
    $c = "                                         LYNN MINMAY (MACROSS DYRL)"
    }
    else{
    $b = 'ICAjQCYjICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgCiAgICYjIyUlIy4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAuIyUlJSYlI0AlICAgICAgICAgICAgICAgICAgICAg
    ICAgICBAICAgICAgICAgICAgICAgICMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgIyNAJiUlJiUjJi
    MgICAgICAgICAgICAgICAgICAgICAgICAgIyYgICAgICAgICAgICAgIy4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICAgCiAgICAgICMjJSUlQCUlJSMjICAgICAgICAgICAgICAgICAgICAgICAgQC4mICAgICAgICAgICBAJiMgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAsIyUlKiomJSUjQCAgICAgICAgICAgICAgICAgICAgICAgICgoICAgICAgICAg
    ICAoKCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICYjJSUlJSUlJSMjICAgICAgICAgICAgIC
    AgICAgICAgIC9AQCUjIyUuICAgICwoJiAgICAgICAjLyojICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgIyYl
    JSUlJSUlIyAgICAgICAgICAgICAgICAgICAgICAgQCAvICAgIywqJiAqICAoIEBAJiwqLiAqKiAgICAgICAgICAgICAgICAgICAgIC
    AgICAgCiAgICAgICAgICAgIyMlJiUlJSUlJSUjICAgICAgICAgICAgICAgICAgICAsQCAjICAqJSoqLyoqQEBAQEBAIComJSAvKi8g
    ICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICMjJSMlJSUlJSUlI0AgICAgICAgICAgICwqKiolKiBAJSAgKkAuIC
    8qQCpAQEBAQEBAQEBAQEAoKCogICAgIC4vKiouICAgICAgICAgICAgICAgCiAgICAgICAgICAgICUsIyMjIyUlJSUlJSUjICAgIEBA
    QEAqKiAgICwjQCgvI0AgQC8lICooQEBAQEBAKiAgICAgICAgICAgICAmQEAlICoqKiYgICAgICAgICAgICAgCiAgICAgICAgICAgIC
    AsLCMgJSMlJSUlJSUlJSMgICYgQCMqKCAoJi4gICMmQEBAIyAlKiYqI0BAICAgICAgICwvKiwgKioqIEBAQEBAQComJiguICAgICAg
    ICAgICAgCiAgICAgICAgICAgICAjLCwgICAjIyUlJSUlJSUjJSogQEBAKiAgI0BALi4uKkAmLCUlKi9AQC4uLixAQEBAICAgLCpAQC
    ogQCNAQEBAQCgqKiooICAgICAgICAgICAgCiAgICAgICAgICAgICAgLCxAICAgQCMmJkAlJSUlJSMgKEBAKiAgICVAQCMuLiwqLCMo
    Ly8uLi5AQEBALCAgICAgKioqKiBAQEBAQCAgICAqJiogICAgICAgICAgICAgCiAgICAgICAgICAgICAgKCwsICAgICUjJSUmQCUlJU
    BAIC8sKCUgICBAQEBAQEAuLiZAQEBAQEBAQCAgICAgICAuKioqKiBAQEBAIC4lKipAKiwgICAgICAgICAgICAgCiAgICAgICAgICAg
    ICAgICgsJSAgICAmIyomICAgJSUlJSYgIC4lICAgICAuQCAgIChAQEBAJSAgICAgICAgICoqKipAQCwqKiUuICAgLkAgKiMgICAgIC
    AgICAuICAgCiAgICAgICAgICAgICAgICAjLCAgICAgJUAlJiggIEAlJUAjJSAgKCAuICAgICAuICMvKiogICAgICAuKkBAKiosQEAl
    KiMgICAsICAgICAgKiosICAgICAgIC8qIyAgCiAgICAgICAgICAgICAgICAgIyYgICAgICgqKiomQCwjJSUmJiNALipAKihAQCMgQE
    BAQCYqLiwoQEAoKigjQEAjKi8qICAgICAgJiAgICAgQCoqICAgL0BAJSoqICAgCiAgICAgICAgICAgICAgICAgLCMsICMgLComJiYq
    KiomJSYlJSUlIyoqKiMqQEAmI0BAQEAqJSUqKipAQEBAKioqKiogICAgICAgICAgICVAICAqKiAgQEAlKioqICAgCiAgICAgICAgIC
    AgICAgICAgICAjICAmQCVAJUAqLyoqLyUlJSUlJSVAJSYmLkBAICBAQEAqKipAQEBAKCoqKioqLyAgICAgICAgICAgICAlICAqKkBA
    QCoqKiogICAgCiAgICAgICAgICAgICAgICAgICAgIyAgJiNAJioqQCZAQEAoJiUlJSUlQCUmI0BALkBAQCgqQEAvQCMoIyYgJSpAIC
    AgICAgICAgICAgICAjJioqQEBAKkAqKiUgICAgCiAgICAgICAgICAgICAgICAgICAgICMgICBAJiAvKioqJkBAQEAjJSUmJUAmQEBA
    QEBAQCNAQCNAJiwoKCMgKkAgICAgICAgICAgIyAgICAqKipAQEAqKioqKiAgICAgCiAgICAgICAgICAgICAgICAgICAgICAoICAsIC
    AgJSoqKioqQEAjJSUlJigoQEBAQEAqKioqJkAmLCwoKCosKiosICAgICAgICwgICAqICoqKkBAQC8qKioqJSAgICAgCiAgICAgICAg
    ICAgICAgICAgICAgICAgJSYgIC4uICAjKioqL0BAQCUmKCglLiAgICBAQComQCYsLCgoKCUqQCoqICAgICAgQCAuICAgKioqQEBAKi
    oqKioqICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAjICAgKEAvLCwmJi4gICAgLyoqLyAgIC4qKiBAIygoKCgoLiomKiAj
    IyogICBAIC9AL0BAICBAQEAvKioqKiogICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICpAKiAgJSoqQC
    AgICwqKiAgICAgICAjKComKCAgIColICAuICAgKiAgKiogIC8qKioqKiogICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICggICAgIypALyAgICoqKiYvIyUmQCMlIyYmKiAgICpAICUgICAuKiAgICoqKCoqQC8qICAgICAgICAgCiAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgKCoqKCAgICoqKiAgICAgICAgLyAvKiogICooQCAgKCooICAgICoqKihA
    JiAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAoICAgLCgqKkAgLCojICAuICAgICAgICAlKi
    oqKiogKCoqKiAgICAgKiosICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgJSNAKCMq
    KiouJSoqICAgLyAgICAgIC8gKiolKiogICoqKiwqKiMvJiAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgLiYoKioqKkAuICAgICYqKiwvLy8qJSoqKiogICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICwqKiVAQCYgICAgICAjJSAgICAgJiUqQCYoICAgICAgICAg'
    $c = "                                           DYRL VF-1S 'SKULL LEADER'"
    }

    getThis $b
    Write-Host -f YELLOW "$vf19_READ
    
    ===================================================================================================="
    Write-Host "$c"
    ss 2
    cls
}



## Function to pause your scripts for $1 seconds
function ss(){
    param(
        [Parameter(Mandatory=$true)]
        [int]$sec
    )
    Start-Sleep -Seconds $sec
}

<######################################
## Set the default startup object
    When you have resources like tables/arrays to be built from text
    files, you can base64 encode the file path, add a 3-letter identifier
    so that you can easily decode them when necessary, then add them to
    line 5 in 'extras.ps1', separated by '@@@' as delimiters.

    This function reads line 5 from 'extras.ps1' and creates an array of
    base64 values with the 3-letter identifier as its index. When you
    need to call your encoded filepath, you use the 'getThis' function,
    which returns $vf19_READ as your decoded filepath:

        getThis $vf19_MPOD['abc']
        $your_variable = $vf19_READ


######################################>
function startUp(){
    ## Check if necessary progs are available; add as many as you need
    #$INST = Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall'
    $INST = Get-ChildItem 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
    foreach($i in $INST){
        $prog = $i.GetValue('DisplayName')
        if($prog -match 'python'){
            $Global:MONTY = $true
            $Global:vf19_PYOPT = ''  ## Prep string values for passing to python scripts
            $p = @()
        }
        if($prog -match 'nmap'){
            $Global:MAPPER = $true  ## Can use nmap, yay!
        }
        if($prog -match 'wireshark'){
            $Global:SHARK = $true  ## Can use wireshark, yay!
        }
    }

    ## Build the options list
    $Global:vf19_MPOD = @{}
    $aa = @()
    $x = 3
    while($a -ne '#>'){
        $a = Get-Content "$vf19_TOOLSROOT\ncore\extras.ps1" | Select -Index $x
        $aa += $a
        $x++
    }
    $b = $aa -Join ''
    $b = $b -replace "#>$",''
    $b = $b -Split '@@@'
    foreach($c in $b){
        $d = $c.substring(0,3)
        $e = $c -replace "^...",''
        $Global:vf19_MPOD.Add($d,$e)
        if($MONTY){
            $p += $c  ## Create a parallel options list that python can read
        }
    }
    if($p.length -gt 0){
        $Global:vf19_PYOPT = $p -join(',')
    }

}

<################################
## Display tool menu to user

    Planned improvement is to rewrite this function so it can
    accomodate more than 20 scripts in the nmods folder. Right
    now, for example, if you have 40 scripts in nmods, the
    scrollPage function will show the first 9 tools in $FIRSTPAGE,
    but would show tools 10-40 in $NEXTPAGE because chooseMods
    only generates two arrays based on the nmods folder file count.

    Also need to truncate if filename is longer than 7 characters
    to keep the menu uniform.

################################>
function chooseMod(){
    $Global:vf19_FIRSTPAGE = @{}
    $Global:vf19_NEXTPAGE = @{}
    $Global:vf19_MODULENUM = @()
    if( $MONTY ){
        $Global:vf19_pylib = "$vf19_TOOLSROOT\ncore\py_classes"
        $ftypes = "*.p*" ## Integrate python scripts if Python3 is installed
    }
    else{
        $ftypes = "*.ps*"  ## Ignore py files if Python3 not installed
    }
    $vf19_LISTDIR = Get-ChildItem "$vf19_TOOLSDIR\$ftypes" | Sort Name     ## Get the names of all the scripts in alpha-order

    # Enumerate the nmods\ folder to find all scripts; all of my scripts  
    #     contain a descriptor on the first line beginning with '_wut'
    $vf19_LISTDIR |
    Select -First 9 | 
    ForEach-Object{
        if( Get-Content $_.FullName | Select-String -Pattern "^#_wut.*" ){   # verify the script is meant for MACROSS
            $d1 = Get-Content $_.FullName -First 1         # grab the first line of the script
            $d1 = $d1 -replace("^#_wut[\S]* ",'')          # remove the 'wut'
            $d2 = $_ -replace("\.p.+$",'')    # remove the file extension, only care about the name
            $d2 = $d2 -replace("^.+\\",'')    # remove the filepath
            $d3 = $d2.Length                  # count how many characters in the filename
            if($d3 -lt 7){
                $d4 = (7 - $d3)
                while($d4 -gt 0){
                    $d2 = $d2 + ' '      # format the name to append whitespaces so the length adds up to 7 characters; 
                    $d4--                    #    this keeps the list uniform on the screen
                }
            }
            # Create an array containing each script name and its description
            $Global:vf19_FIRSTPAGE.Add("$d2","$d1")
        }

        
    }

    ## Repeat the above to create a new menu page if there are more than 9 tools available
    if( $vf19_FILECT -gt 9 ){
        $Global:vf19_MULTIPAGE = $true
        $vf19_LISTDIR |
        Select -Skip 9 | 
        ForEach-Object{
            if( Get-Content $_.FullName | Select-String -Pattern "^#_wut.*" ){
                $d5 = Get-Content $_.FullName -First 1
                $d5 = $d5 -replace("^#_wut[\S]* ","")
                $d6 = $_ -replace("\.p.+$",'')
                $d6 = $d6 -replace("^.+\\",'')
                $d7 = $d6.Length
                if($d7 -lt 7){
                    $d8 = (7 - $d7)
                    while($d8 -gt 0){
                        $d6 = $d6 + " "
                        $d8--
                    }
                }
            }

            # Create an array containing each script name and its description
            $Global:vf19_NEXTPAGE.Add("$d6","$d5")
        }
    }

    $vf19_MODCT = 0

    ####################
    # Use the arrays to generate the list of active modules for the user to choose from
    ####################
    if( $Global:vf19_PAGE -eq 'X' -or $Global:vf19_PAGE -eq $null ){
        $vf19_FIRSTTOOL = '1'
        foreach($vf19_STUFF in $Global:vf19_FIRSTPAGE.GetEnumerator()){
            $vf19_MODCT++
            $d_a = $vf19_STUFF.Key

            # The names formatted for the MODULES array need to have their whitespaces stripped
            $d_a1 = $d_a -replace("\s*",'')

            # figure out what the extension is...
            $ext = (Get-ChildItem $vf19_TOOLSDIR | where{$_ -Match "$d_a1"}) -replace "^.+\.p",'.p'

            # ...and add the correct extension back in for a new array
            $d_a1 = $d_a1 -replace("$", "$ext")

             # This array tracks the scripts with an index for the availableMods function
            $Global:vf19_MODULENUM += $d_a1
            $d_b = $vf19_STUFF.Value

            # Write the script number, name, and description together
            $d_c = "   $vf19_MODCT. " + $d_a + "|| " + $d_b

            ## Iterate through the key-value pairs in vf19_MODULES table and write them to the screen
            Write-Host -f CYAN "  ======================================================================"
            Write-Host -f YELLOW "   $d_c"
    
        }
    }
    ## Build the $NEXTPAGE menu if user selected 'p'; mirrors previous instructions but with new vars
    else{
        $vf19_FIRSTTOOL = '10'
        $vf19_MODCT = 9
        splashPage
        foreach($vf19_STUFF in $Global:vf19_NEXTPAGE.GetEnumerator()){
            $vf19_MODCT++
            $d_d = $vf19_STUFF.Key
            $d_d1 = $d_d -replace("\s*",'')
            $ext = (Get-ChildItem $vf19_TOOLSDIR | where{$_ -Match "$d_a1"}) -replace "^.+\.p",'.p'
            $d_d1 = $d_d1 -replace("$", "$ext")
            $Global:vf19_MODULENUM += $d_d1
            $d_e = $vf19_STUFF.Value
            $d_f = "   $vf19_MODCT. " + $d_d + "|| " + $d_e
            Write-Host -f CYAN "  ======================================================================"
            Write-Host -f YELLOW "   $d_f"
    
        }
    }

    Write-Host -f CYAN "  ======================================================================
    "

    SJW     ## check user's privilege LOL
    Write-Host ''

    if( $vf19_MULTIPAGE ){
        Write-Host -f GREEN '   -There are more than 9 tools available. Hit ' -NoNewline;
            Write-Host -f YELLOW 'p' -NoNewline;
                Write-Host -f GREEN ' for the next Page.'
    }
    Write-Host -f GREEN '   -Select the module for the tool you want (' -NoNewline;
        Write-Host -f YELLOW "$vf19_FIRSTTOOL-$vf19_MODCT" -NoNewline;
            Write-Host -f GREEN '). Add an ' -NoNewline;
                Write-Host -f YELLOW 'h' -NoNewline;
                    Write-Host -f GREEN ' to view'
    Write-Host -f GREEN "      a help/description of the tool (ex. '1h')."
    Write-Host -f GREEN '   -Type ' -NoNewline;
        Write-Host -f YELLOW 'shell' -NoNewline;
            Write-Host -f GREEN ' to pause and run your own commands.'
    Write-Host -f GREEN '   -Type ' -NoNewline;
        Write-Host -f YELLOW 'dec' -NoNewline;
        Write-Host -f GREEN ' or ' -NoNewline;
        Write-Host -f YELLOW 'enc' -NoNewline;
            Write-Host -f GREEN ' to do Hex/B64 evals.'
    Write-Host -f GREEN '   -Type ' -NoNewline;
        Write-Host -f YELLOW 'q' -NoNewline;
            Write-Host -f GREEN ' to quit.
            '
    Write-Host -f GREEN '                               TROUBLESHOOTING:
   If the console is misbehaving, you can enter ' -NoNewline;
    Write-Host -f CYAN 'refresh' -NoNewline;
    Write-Host -f GREEN ' to automatically
   pull down a fresh copy. Or, if one of the tools is not working as you
   expect it to, enter the module # with an ' -NoNewline;
    Write-Host -f CYAN 'r' -NoNewline;
    Write-Host -f GREEN " to refresh that script
   (ex. '3r').
   
   "
    Write-Host -f GREEN '                        SELECTION: ' -NoNewline;
        $Global:vf19_Z = Read-Host


    if( $vf19_Z -eq 'dec' ){
        decodeSomething 0 ## function to decode obfuscated strings; see extras.ps1
    }
    elseif( $vf19_Z -eq 'enc' ){
        decodeSomething 1 ## function to encode plaintext strings; see extras.ps1
    }
    elseif( $vf19_Z -eq 'shell' ){
        runSomething     ## pauses the console so user can run commands; see extras.ps1
    }
    elseif( $vf19_Z -Match $vf19_CHOICE ){
        if( $vf19_Z -Match "[0-9]{1,2}h" ){
            $Global:vf19_Z = $vf19_Z -replace('h','')
            $Global:HELP = $true   ## Launch the selected script's man page/help display
        }
        elseif( $vf19_Z -eq 'p' ){
            if( $vf19_MULTIPAGE ){
                scrollPage   ## Changes menu to show 1-9 vs 10-20
            }
            else{
                $Global:vf19_Z = ''  ## scrollPage only works if there's more than 9 tools in the nmods folder
            }
        }
        elseif( $vf19_Z -eq 'q' ){
            $Global:vf19_Z = $null
            Break                    ## User chose to quit MACROSS
        }
        elseif( $vf19_Z -Match "[0-9]{1,2}r" ){
            $Global:vf19_Z = $vf19_Z -replace('r','')
            $Global:vf19_REF = $true      ## Triggers the dlNew function to download fresh copy of the selected script before executing it
        }
        elseif( $vf19_Z -Match "[0-9]{1,2}s" ){
            $Global:vf19_Z = $vf19_Z -replace('s','')
            $Global:vf19_OPT1 = $true     ## Triggers the selected script to switch modes/enable added functions
        }
        elseif( $vf19_Z -Match "[0-9]{1,2}w" ){
            $Global:vf19_Z = $vf19_Z -replace('w','')
            $Global:vf19_NEWWINDOW = $true   ## Triggers the availableMods function to launch the selected script in a new powershell window
        }
        elseif( $vf19_Z -eq 'refresh' ){
            dlNew "MACROSS.ps1" $vf19_LVER  ## Downloads a fresh copy of MACROSS and the ncore files, then exits
        }
        else{
            $Global:HELP = $false
            $Global:vf19_OPT1 = $false
        }
        if( $vf19_Z -Match "[0-9]"){
            availableMods $vf19_Z         ## availableMods checks to see if script exists, then launches with any selected options; see the validation.ps1 file
            Clear-Variable -Force vf19_Z
        }
    }
    else{
        errmsg
    }

}

################################
## If more than 9 tools available, split into two menus
################################
function scrollPage(){
    ##  X = 1st page, Y= 2nd page
    if( $vf19_FILECT -gt 9 ){
        if( $vf19_PAGE -eq 'X' ){
            $Global:vf19_PAGE = 'Y'
        }
        elseif( $vf19_PAGE -eq 'Y' ){
            $Global:vf19_PAGE = 'X'
        }
        splashPage
        chooseMod
    }
}
