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


## If these transition screens annoy you, just delete this entire function
## Set $1 to 1 for VF-19, 2 for SDF-1, 3 for VF-1S, 4 for Gubaba
function transitionSplash($1){
    cls
    if($1 -eq 1){
    $b = 'ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA
    gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAmJSwsKiUsICAg
    ICAgICAgICAgICAgICAgICAgICAsJiAgICAgICAgICAgICAoJSAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgI
    CAgICAgICAgICAgICAgICAgKiUlJi4sLCxAQCggICAgICAgICAgICAgICAqJi8lICAgIC8oLCwuJiYlJkBAQCggICAgICAgICAgIC
    AgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgKiAgICBAJSUmJiosQEAmJiAgICAgICAgICAqJSMjJiAuKi4
    uLiNAJSUmJkAmJiZAICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgLCgjKCMmKCgoIyZAQCUl
    JSUmQCgoKCMlJiUoKCgoJiVAJiYmLC4mJiZAJSUmJkAlJSgjJSAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgI
    CAgICAgICAgICouLiZAIyVAQCYoKCMoIyUjJSYoKCgjJSgjJSUlIygoIyMoKCMmJSUlJSUlJiZAQEBAQCUgIC4gICAgICAgICAgIC
    AgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgIC4jJSUmJiYlJSMlJSMoKCgoIyUlJSUlJSYlKCMmIygoIyUjJUAlJiUmJSU
    lJiYmQEBAQEBAJSVAJSUlJSYlJSAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAqJkBAQEBAQCMjKCgoIy8oIyUlJSYm
    KCgoKCgoKCgoKCgoKCgoJUAlJSgoKCglJiZAJiYmJiYmJiUlQCUoKCgoKCgoKCUoIyAgICAgICAgICAgICAKICAgICAgICAgICAgL
    iMoKCgoKCgoKCMoKCgoKCgjJiUlJSUmJkBAQEAmJiYlI0BAQCYlJSYmJiYmJiYlJSgqLCAgICYlJiYmJiwgICAgIygjIygoKCgoKC
    UoIyAgICAgICAgICAKICAgICAgICAgIygoKCgoKCgoKEAoLygoJUAmJS4gICgjKCgjJiUjJkAmJSUlQCYjLyNAQEAoIyUlJSUmJi8
    gICAgICAmQCZAJiMjJSUlKiAgICwlKCMoKCgoKCMoKCAgICAgICAKICAgICAgICgmJiUlJSUlJSUlJiMqICAgLyMjJSUjJUBAJiYl
    JiZAQEAmJiUmQCUlJSYvJUBAKCgoQEAlJSUlIyAgICMlJSUjJSUlJSUlJSUgICAgICAgKiUjIygoKCMoIyAgICAKICAgICAgICAgI
    CAgICAgLygjKCgoKCMmJiYmJiUmJkBAJkAmJiUlJSUlJigoIyYlJSUlJSUjIyMoKCUlJSUlJSVAIyglKCUlJSUlJSUmJSUqICAgIC
    AgICAgICAoKCUoLCAgICAKICAgICAgIC8jIygoKCgjJSUlJSUlJSUmJkBAQCZAQEAmQCYlJiggICAgICAlKCglJUBAJiUgIC8jKCg
    jJSUlJigoJSMlJSUlJSUlJSUlJSUuICAgICAgICAgICAgICAgICAgICAKICAuIyYoJSYlJSUlJSUmQCogICAgICAgICAgKiZAQCUo
    ICAgICAgICAvKCgoKCMlJSUmQCMgICAgICAgLyZAJSMjJSUlJSUlJSUlJSUlJSYgICAgICAgICAgICAgICAgICAgICAKICAuJiMmJ
    iZAQCUmKCAgICAgICAgICAgICAgICAgKiAgICAgICAoKCgoKCMlJSUlJSUlJSAgICAgICAqJiYmKCUlJSUlJSUlJSUlJSUjICAgIC
    AgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC4qIygoKCgjJSUlJSUlJSUmICAgICA
    gQEAjIyUlJSUlJSUlJSUlJSUlICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICoqJSgsJSYvIyUlJSUlJSUlJSwgICAgICAgI0BAKCUlJSUlJSUlJSUlJSUmICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgI
    CAgICAgICAgICAgICAgICAgICAgICAgICAgIChAQEAsLCUvJiUlJSUlJSUmICAgICAgICAgICAsIyUlJSUlJiUoKCgoJSUlLiAgIC
    AgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICxAJSMlJS8vJi9AJiYlQCMgICAgICA
    gICAgICAgKCUmKCgoKCgoKCgoJSUlLyAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICAgLyUoJSUmQEAvLygoJSMmLywgICAgICAgICAgICAgICAgJSguQCYlKCovKkAlLCAgICAgICAgICAgICAgICAgICAgICAgICAKI
    CAgICAgICAgICAgICAgICAgICAgICAgICAgLiUmJSMlJiYmJiZAKC8oQEAmQEBAQEBAQEBAQEAuICAgICAgICojKi4uLCwsKEAvQC
    AgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAlJSUlJiYmJiYmQEBAQEBAQEBAQEBAQEB
    AQEBAQEBAQEBAQEBAQCMoQCYjKCYmQC9AKCogICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAg
    JSUmQEBAQEBAQCYmJiYmIygoKiwuLiomQEBAQEBAQEBAQEBAQEBAJi9AQCgoKCglQEAoLyggICAgICAgICAgICAgICAgICAgICAgI
    CAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAuJiUoIywqJkBAQEBAQEAmQCUoKCglQE
    BAQEBAQEBAQEBAJkBAQCZAQEBAQC4gICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA
    gICAgICAgICAgICAoQEBAQEAlJSZAJUBAJiZAQEBAQEBAQEBAJkBAQEBAQEBAQEBALiAgICAKICAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgQEBAJSUlIyYmJiZAQEBAQEBAQEBAQEBAQCMvLy8uICAgI
    CAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICxAJSUlJS
    YmJiZAQEBAICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA
    gICAgICAgICAgICAgICAgICAgICAgLyUlJSYmJkBALyAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAmIyUmQCAgICAgICAgICAgICAgICAgICAgI
    CAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgIC4gICA='
    $c = "                                           MACROSS 7 VF-19 'FIRE'"
    }
    elseif($1 -eq 2){
    $b = 'ICAgICAgICAgICAgICAgICAgICAgICAgICAgICMuIC4uICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAqKCooIy8uIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgKC8vIy8oLi4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgLCAgICAgICAgICAgICAgICAgICAgICAgICoqKC8qIy8uLiAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICovLC4qLC
    AgICAgICAgICAgICAgICAgICAgICAgLygqKC8oIC4uLiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgIygvJi4uLiAgICAgICAgICAgICAgICAgICAgICMuKigoIyguKC4uICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgIC8vLy8oLi4uICAg
    ICAgICAgICAgICAgICAgICAsLiooLiUoIyguLi4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAKICAgICAgICAqJS8vKiwsLi4sICAgICAgICAgICAgICAgICAgKCgoLy8jLCUmLi4vLiUgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgIC8gLCgjLCwuLi4gICAgIC
    AgICAgICAgICAgIC8oKCUvKComJi4uJUBAIyMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
    ICAgICAgICAKICAgICAgICAgICAuLi8oKigsLi4uLi4gICAgICAgICAgICAgICAlIyguKCMoJUBAJiYjIyMjIyAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgKCgoIyMsLCwsLihAICAgICAgICAg
    ICAgICAgICZAQEBAQCZAQCYjLyMjIyMjICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AKICAgICAgICAgICAgICwoKCgoLyosLCZAQC4uLiAgICAgICAgICAgICAgKCMjIyYmJiYmJiUjIyMjIyMgICAgICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAoIyMvKCgvQCZALCwuLi4uLiAgICAgICAgIC
    AgICMjKCgjJiYmJiYmIyMjIyVAQCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAg
    ICAgICAgICAgJkBAQEAlIyMjIy8qKiwuLi4uLiAgICAgICAgICAgKCgoKCMmJiYmJiYjIyMjJUAmICAgICAgICAgICAgICAgICAgIC
    AgICAgICAgLCAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgJkAmJiUjIygjIygvKiwqLC4oLCAgICAgICAgICAg
    KCgoIyYmJiYmJiMjIyMjIyMgICAgICAgICAgICAgICAgICAgICAgICAqICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgIC
    AgICAgICAmJiYmJiMoKCgjIy8oJSUjLCMsICAgICAgICAgICAgICgoJiYmJiYmJSMjIyVAJiAgICAgICAgICAgICAgICAgICAgICog
    ICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAmJiYmIygoIyMvKCYmJiMsLi4gICAgICAgICAgICAgIC
    gmJiYmQCYlJiMjJUAlICAgICAgICAgICAgICAgICAgLyAgICAgICAgICogICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAg
    ICAgIEAmJiYmIyMoLyolJSYmIygsIywgICAgICAgICAgICAoKCYmJiZAQCUjIyMjIyUgICAgICAgICAgICAgICAvICAgICAgICAgKi
    AgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICYmJiYoIygqKiUlLyUlIywjLCAgICAgICAgICAgKCYmJiZA
    QCYmJSMjJSUlICAgICAgICAgICAgIC8gICAgICAjKCYmICAjIyYmKiAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgIC
    AgJSYmJkAjIyMjLy8oKCwsKiwsICAgICAgICAgICgqLyYmJiUjKCYlJSUlIyAgICAgICAgICAgLyAgICAjJSYmJiZAQEAmJiYmICAg
    ICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAuICAgIyYmQCYjJSMjIygjKiwsLCAgICAgIC4qICAqIy4uJiYjLywsJS
    UmJSUmLyAgICAgICAlICAgICglJSYmJiYmJiYmJiYgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgLiAgICAm
    Ji8vIyMjIyUjKCgjIyUgICAgICwjKCUqKiMqLCglJiwvIyMjJiMlJSUlJSUgLCouICAgIyUlJSYmQEBAQEBAJiAgICAgICAgICAKIC
    AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICwgICAgKCMjIyMjIyMjIyUmJiUlJSggICMlIy4sJS8oKCMqL0AmQCYjJiYjJSUl
    JSouKiguLCAjJSUlIyMlQEBAJSYmICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC4gICAgICwlLyMjJS
    MjJiYmJiYmJiUlJiMjIy4jJiYmJkBAQEBAQEBAQCUlJSUmLCgsLywvLiMlJSUjKCUjKCMlJiYlICAgICAgICAgICAKICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAjICAgICAqIyggQEBAQCYuLi4uLCoqLyovKCMlJiYmICAgQCYmJiYmJkBAKiwsLCMjIywsIy
    UlJSMjJiUlJSUlJiUoJiMoICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAqIyAgICAuKiAgJkBAJiAgICAs
    KC4uKi8oKC8oJkBAIyMsKiYmJSMmJkAjLCwuLCYjJiYmJiYlIyMlJSUmJiYmJSUlJSAgICAgICAgICAKICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAuLC4qIy4sKCAgJSUlJiwsKiwsKi8uKComKCgjQEAqQCgsQEBALyMmQEAoLC4uKCZAQEBAJiYlJiUlJSYm
    JiYmJSUgICAgICAgICAgICAKJSUjLyAgICAgICAgICAgICAgICAgICAgICAgICAgICAuLiAjJiAgIywjIy4mLi4sLCosLCwqKiolLy
    MlQEAvQEAjQCVALCMmQCMvLCgsLyolKiwoQCMmIyMlJSYmJiYlICAgICAgICAgICAgICAKIyMlIyMlJSUlIyAgICAgICAgICAgICAg
    ICAgICAgICAuIC8vICAmQEBALiYmLi4uLi4gLC4jLypAIyUmQEAvQEBAKkBALyZAQC8sLi4oJiYmJiglJiYlIyUlJiYmJiMgICAgIC
    AgICAgICAgICAKIyUjJkAmJiMjJSUlJSUlJiYmJiYgICAgICAgICAgICAgJS8gICAjQCMvQEAmJS4gLi4vKCwvKCgjIyUmQEAjQCNA
    QEAmKCYmQEBAQEBAJiYmJSomJiMlJSUmJiYmKCAgICAgICAgICAgICAgICAKJiYlIyMjIyUlJSYmQEAmJiYmJiYmJiYmJiUmJiYgIC
    AgIC4oICgsQEAmQCgmJS4uJiwuJS8oIygjJSVAQEAjLyUmJiYmQCYmJiUmJiYlJSUlICAgICMlJSYlJiYgICAgICAgICAgICAgICAg
    ICAKJiYmJiYmJiUjIyUlJSUmJiYmJkBAQCYmJiYmJiYmJiAgICMsLi4qQEAmQComJUAuIyguLyMjIy8jJSVAQEBAJiYmJiYmJiZAJi
    MlJSUjIyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAlJiYmJiYmJiYmJiYmJiYmJiZAQCZAJiYmJkBAJSUlJiYg
    JigjJiYmJiYsLCwqLy8oKi8jIyUlJkBAQEBAQEBAQEBAQEBAQCYlIyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgIC
    AgICAgICAgJSYmJiYmJiYmJkBAQCYmJiYmJiYmJSUmICAgICYmJiZAQCYjLiAsKCMjLi4vKCgjJkBAQCYmJkAgQEAmICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgJi
    YlIC4sIygqLiAvKiovJkAmJiYmJSUlICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAg
    ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBALC4uLi4uLy4vKiooJkBAJiUmJiYlJSAgICAgICAgICAgICAgICAgIC
    AgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAlLiAgLi4s
    Iy4mIyooIyYoJiUmIyUgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA='
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
