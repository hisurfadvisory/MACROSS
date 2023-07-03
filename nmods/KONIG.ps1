#_superdimensionfortress Network Fileshare Search tool
#_ver 1.0
#_class User,File search,Powershell,HiSurfAdvisory,1

<#
    KÖNIG fileshare search tool
    Author: HiSurfAdvisory
    This script is designed to perform quick file searches across your enterprise
    by offering multiple filters to the SOC analyst:
        -you can select which fileshare to search from
        -you can select which user profile to search in (Active-Directory
            roaming profiles only!)
        -you can search based on one or more extensions, example "search for
            all docx,pdf,txt,rtf,xlsx,pptx,md" to find all documents of those
            filetypes.
        -you can search specifically for alternate data streams to find files
            that users may be trying to hide
        -you can search by filesize
        -and of course, you can search by full or partial filenames
    It is also designed to accept and auto-run queries from other MACROSS scripts.
	
    v1.0
    Default share paths are *NOT* configured; you need to do this on your own.
	
    NOTE 1:
        Unless you rewrite the search functions of this script, you *MUST* set
        your default share paths using the MACROSS framework's preferred method,
        i.e. encoding the paths, attaching an index, and adding the encoded path
        with a delimiter to the utility.ps1 file. See the notes/comments in the
        MACROSS.ps1 script, or the splitShares function further down this script.
    
    NOTE 2:
        This script is heavily dependent on MACROSS resources. Trying to run this
        outside of the MACROSS console will not work well, if at all.
		
    NOTE 3:
        Search through this script for the text "MPOD ALERT!!" Wherever this
        comment appears, it's a place where you need to check and make sure
        your network share variables all match up as you need them to!
		
    NOTE 4:
        KÖNIG drills down into *directories*, i.e. if you tell it to search
		
            C:\Users\Bob\My Documents
			
        it will not return results for any files in the "My Documents" folder; it
        will only look for *folders* inside \My Documents, and give you results from
        files within those folders. You would instead need to set your search
        location as
		
            C:\Users\Bob
			
        Which of course would also search inside all of Bob's other home folders in
        addition to "\My Documents". KÖNIG is set up this way because it is meant to
        search targeted network shares, local hosts or root directories.
#>


<#
	## CALLER SCRIPTS THAT DON'T GO THROUGH 'collab' (i.e. python scripts) NEED TO SET
	## THEIR SEARCH VALUES HERE
    -$ORDERS = the filename string to search for
    -$COMMANDER = the calling script; if python, it should start with 'py', i.e. 'pyMYSCRIPT' to differentiate
        from the powershell callers, which *should be* set globally as $CALLER. When KÖNIG is called by a $COMMANDER
        beginning with "py", $COMMANDER is promoted to $GENERAL so that additional actions can be taken to
        communicate back to python.
        
        If both $CALLER and $COMMANDER have unique values assigned to them, KÖNIG will give preference to COMMANDER
        because that is *not* a globally-set value. The likely scenario is that a powershell script ($CALLER)
        launched another script, which then launched KÖNIG to do a file search, while $CALLER didn't request
        anything from KÖNIG.
        If $GENERAL gets set, it will always take priority, because it only exists when a python script tasks
        KÖNIG.
        NOTE: The "collab" function in MACROSS can pass along an optional value from other powershell scripts,
        which would be read by KÖNIG as $ORDERS; *however*, if there is no $COMMANDER to go along with it,
        KÖNIG ignores this value and focuses on the global $CALLER and $external_NM values instead.
    -$AO = the area of operations, an optional directory path that can be set if you don't have KÖNIG set to
        automatically search a specific location. If that is the case, and no $AO value is passed, the user
        will be asked to supply a location manually.
    -$AAR = After-Action Report: This is the location of the $vf19_GBIO directory, where MACROSS powershell scripts
        write their results as a text value that your python script can pull into a dictionary if necessary. In
        KÖNIG's case, it will write the location of your $RESULTFILE and $HOWMANY succesful hits your search got.
        This is mainly done as an example for you -- it would be more useful if you're running scripts that return
        tons of information.
    -$HOMEBASE = the location you want results, if any, to be written to. This is needed because python scripts
        have to pass values that would normally be available through MACROSS, but since python and powershell
        can't share global variables, they need to be passed back and forth. If your python script doesn't pass
        something like your user's Desktop or a group shared drive as this 4th param, no result file will be
        written.
##>
param(
    [Parameter(position = 0)]
    [string[]]$dyrl_kon_ORDERS,
    [Parameter(position = 1)]
    [string[]]$dyrl_kon_COMMANDER,
    [Parameter(position = 2)]
    [string[]]$dyrl_kon_AO,
    [Parameter(position = 3)]
    [string]$dyrl_kon_AAR,
    [Parameter(position = 4)]
    [string]$dyrl_kon_HOMEBASE
)

##########  PYTHON PREP SECTION  ######################
if( $dyrl_kon_COMMANDER -Match "^py" ){
    $dyrl_kon_GENERAL = $dyrl_kon_COMMANDER -replace "^py"
    Remove-Variable -Force dyrl_kon_COMMANDER
}
if( $dyrl_kon_AAR ){
    $vf19_GBIO = $dyrl_kon_AAR
    Remove-Variable -Force dyrl_kon_AAR
}
## Don't let invalid filepaths continue
if( ! (Test-Path -Path "$dyrl_kon_AO") ){
    Remove-Variable -Force dyrl_kon_AO
}
######################################################





## Display help file
if( $HELP ){
    cls
    $vf19_ATTS['KONIG'].toolInfo() | %{
        Write-Host -f YELLOW $_
    }
    Write-Host -f YELLOW "
 KÖNIG performs an automated search based on filenames or extensions (for example,
 if you need to see all documents in a share, you can have KÖNIG focus on just
 docx, docm, rtfs and pdfs in a single search). Any matching search results are
 written to file on your desktop in the '" -NoNewline;
    Write-Host -f CYAN "target-pkgs\" -NoNewline;
    Write-Host -f YELLOW "' directory.
 If your enterprise uses roaming profiles, KÖNIG can attempt to search based on
 user profiles, if you provide it a full or partial username.
 KÖNIG can interact with these MACROSS tools:
    -forward its target packages to ELINTS to perform string-searches
    -forward its target packages to GERWALK, querying your Carbon Black EDR for file info
    -accepts usernames from MYLENE to perform filesearches in their roaming profiles
 Hit ENTER to return.
 "

    Read-Host
    Return
}


## Uncomment if this script will be used where not all your default share paths will be available
## SJW displays a notice to users that their privilege is limited and lets them choose whether to continue
#SJW 'pass'



# Run check
$dyrl_kon_LOOP = $true

# Give the analyst something to stare at
$dyrl_kon_CTR = 0



function splashPage1a(){
    cls
    $b = 'CsKgwqDCoMKgwqDCoMKgwqDCoMKgLMKgwqDCoOKVkuKWk+KWiMOWIuKVkOKVpOKWhOKWhOKVkOKInizCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgCsKgwqDCoMKgwqDCoMKgwqDilZTilojilojilozCoMKg4pWZ4paA4paAKipI4pWi4paI4paIVn4swq
    DCoGAi4pWQfi7CoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoArCoMKgwqDCoMKgwqDCoMKgwqDiloDiloBMImAqKuKIqT3ijJ
    BKXn7ijJBgXi0uLMKgwqDilIDCoMKgLsKgwqAiXn4uwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoArCoMKgwqDCoMKgwq
    DilazilojilownIuKBv+KVkOKInuKWhEkq4pWQ4oieTCwiIuKUgOKUgCwuYF7CrC474pSAwqwuwqDCoMKgwqDCrCzCoMKgIl5+LizCoMKgwqDCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoArCoMKgwqDCoMKgwqDilZniloDiloTijKAiwrJe4pSA4pSALiwsIiJZ4pWQd+KWhFQq4pWQLixgwqBgLc
    KgwqBg4pSAwqxgO+KUgMKsLGAn4pSA4pSAwqwsJ+KVmeKVmeKVpybiloTiloTiloQs4pWZ4pWZwrLilaTilZfCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    KgwqDCoMKgCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqAnIirilZDiiJ53TCzCoGBg4pSA4pSALizijKBUVFnilZDiloRaXn7CrCzCoGDCoC3CoCxe4pSA4omISu
    KUgH4uwqAiIuKUgC7CoOKWgOKVkeKWgOKVmuKVrOKWjOKVrOKWhOKMoWAqdyzCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqDCoArCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg4oygIiIq4pWQdywswqDilJQnLeKUgH534oygIirilZ
    DDhVoq4pWQd2wq4paE4paT4paEd+KVqeKWgOKWgFfCqiTilpPilaxILeKVmeKVkeKVnOKVouKVqy7CoMKgwqAiPizCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwq
    DCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoArCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    KgwqAnIirilZDiiJ4uLCwiYOKUgC4s4pWZ4paMQDfilZnilabilZPDh+KVk+KVlyXiloDilZrilavilaziloDiloziloTiloTilarilZPilZ/ilaZZwqDCoM
    KgwqDCoCIl4pWQLCzCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAKwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgJyciKuKWk+KWk0AnLOKWgOKWgOKVo+KVo07iloTiloTiloTiloTilpPilpLiloDiloDilpPilpPilpPilazilo
    TiloB3XeKUmMKgwqDCoMKgwqDCoMKg4pWjUnfCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgCsKgwqDCoMKgICAgICAgICAgICAgIC
    AgICAgICAgIMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgJyfilZrilpPilpPiloTilpPiloziloTilozDheKVqeKVkOKVnOKVluKWk+
    KWk+KWjOKMoOKWkuKVmnfijJDilpLilpDiloTiloTiloTilZXCoMKgwqDCoOKVneKWksKgWcKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoA
    rCoMKgwqDCoMKgwqAgICDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgLOKMkO
    KVkCLijKDilZnilpLilpLilaVn4pWTwqDCoOKWkOKVoCfCoMKg4paQ4paMwqBg4paMwqDiloTiloziloR3wqDiloTCoMKgYMKgXuKVoSLCoMKgwqDCoMKgwq
    DCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoArCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg4paMxpJqXeKVl8KgXMKg4pWRZ+KVmmDCoMKg4paMwqAuwqDCoOKWk0zCoOKVkeKWkDjiloDiloDiloDilpPilp
    FewqDCoMKgwqDilIBewqDCoMKgwqDCoMKgLCzCv+KVkCJXwqDCoMKgwqDCoMKgwqAKwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoOKWjMOHwqDCoOKWkXbCoOKUlMKgwqDCoMKgwqDCoMKg4pWZ4pWd4paS4p
    aE4paA4pSA4pSs4pWr4pWRwqBE4paS4paE4pWQ4pWp4pWcwqrilabilozilZvCoMKgwqDCoMKgwqDiiJoiJ17ilIDilZPilZtNwqDCoMKgwqDCoMKgwqAKwq
    DCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoOKWkO
    KWkMKgwqBdwqDilJDCoMKgLCwswqDCoMKgwqDCoMKg4pWZ4pWQz4bilpDiloTilpNA4pWs4paTw5Es4pSALCPilZ3ilaniloTiloTCoMKgLOKVm8KgwqDCoO
    KIqVvCoFvCoE3CoMKgwqDCoMKgwqDCoArCoMKgwqDCoMKgwqDCoMKgICAgICAgICAgIMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwq
    DCoMKgwqDCoMKgwqAsa+KWhMKgwqBgLC3iloRRKn7DpizCoMKg4pWZ4paA4paA4paT4paT4pWj4pWp4pWs4paA4pWs4paT4paM4pWr4pWr4paTV8Kg4pSM4p
    WmcOKVrOKWgOKVqcOf4paEQMKgwqBbwqDilZnilpDCoMKgwqDCoMKgwqDCoMKgCsKgwqDCoMKgwqDCoMKgICAgICAgICAgIMKgwqDCoMKgwqDCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqDCoMKgwqAs4oyQcM6p4pWnKmziloTiloQ54pWszqniloDilZniloDilpHilpDiloDilozilaZn4paSJeKWgOKWgOKWk+KWk+KVrO
    KWkuKVkFzCoCYqz4PiloDilazilazilpPiloziloDDkeKWkOKWhOKInuKVpeKVo+KWkOKWjMKgwqDilZsuwqBNwqDCoMKgwqDCoMKgwqDCoArCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAs4pWTz4bOqeKInuKVnCLijKB3z4Ql4pWc4paS4pWiLOKVnOKVo+
    KWjOKWk+KWjOKWk+KWgOKWgOKWk1TilZlUIuKVqOKVrOKWgOKWk+KWk+KWk+KWk00uzpPCoMKg4pWZ4pWQVy4swqDilZkkwqDiloDiloDiloDOkyJN4paTLy
    xXIsKgwqDCoMKgwqDCoMKgwqDCoMKgCsKgwqDCoMKgwqDCoMKgwqDCoCAgICAgICAgICAgIMKgwqAs4pWT4pWkJMOR4pWiIuKWgHfilZBTUOKVqEnilZNn4p
    aE4pWj4pWs4paA4pWs4pWgXuKVmOKWgOKWjOKVnFddwqDilZriloDilpDijKDiloTCoF0iJ13iloxgdMKgwqDCoMKgwqDilJDCoOKVmeKWjOKVp+KWhOKWjC
    TilpPilojilpPOk8Kg4paE4pWpL8KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    Kg4pWp4pWs4paA4pWXcMOi4pWjKmDCoMKgwqAnYOKVqOKWgOKWhOKVrOKVo+KVouKVmuKVouKVoOKVneKVqeKMoD3ilZDilozCoMKgwqDilZnilpPiloTilp
    LGkuKWhOKVk+KWhOKWk+KWhOKWgOKWkE7CoMKgwqDCoMKgLMOFZ2filoDilazilZ3iloTiloDijKBVQ+KWkFTCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    KgCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg4pWp4paI4paM4pWs4pWTKiLCoMKgwqDCoMKgwqA84omI4paSMuKVmyLijK
    B34pWQXmAs4oyQXiIiV8KgwqDCoF7ilZTilazilpPiloziloTilozilozilpLCoMKgwqDilZnilZbilZM9a+KVo+KWk8OR4pWm4pWgUeKVrOKWiOKWiOKImu
    KVkUDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoArCoMKgwqAgICAgICAgIMKgwqDCoMKgwqDCoMKgwqDCoMKg4paQVeKWk+KWiOKVoOKVoioqXi
    ws4oyQ4pSAIiwu4pWQXmAsd+KVkCJgwqDCoMKgwqDCoMKgIuKVpk3ilalQIuKVmuKWjOKWgCTilaniloTiloTiloTilJDiiJ7CoMKgwqDCoOKVk+KVo14s4p
    WR4paI4paITSziloTiloTiloAiwqDCoMKgwqDCoMKgwqAKwqDCoMKgICAgICAgICAgwqDCoMKgwqDCoMKgwqDCoMKgwqAqV+KVkeKWiOKWhMOxw4csd8KyQ2
    DilZPilZQmKiJgwqDCoMKgwqAu4pSAJ2AswqDCoMKgwqDCoH7ilanilpPilown4oyg4paQ4oipwqDilpDiloTilafilZDCoMKgwqDilZjiloTilpPiloDilo
    DilZPiladU4pWdwqDilaxV4paEwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAKwqDCoMKgICAgICAgICAgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    Kg4pWZ4pWpL+KWgOKWjCTijJDilZAiYMKgwqDCoMKgwqDCq+KUgCzilZbilZNe4pSUwqDCoMKgwqDCoMKgwqDiloziloTilabCoMKgXCzilaXijJDijJDCoE
    7CoMKgwqDCoMKgwqDCoMKg4paQ4paAIuKWgOKWgMKgJ+KWgOKVmMKg4pWfwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgCsKgwqDCoMKgwqDCoMKgwqDCoMKgwq
    DCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAs4pWbwqDCoMKgwq
    DCoOKVk+KWhMKgwqDilaDCoH7CoMKgwqDCoMKgwqDCoMKg4paE4paMwqDCoMKgwqDCoOKVo+KVn+KVo8On4paQwqDCoMKgCsKgwqDCoMKgwqDCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAu4pWTL8KgLMKgwqDCoCzilZRUYMKgwqDCoCzilZPilo
    TilpPilpPijKDOk+KVmeKVrOKVmeKVpcaSwqDCoMKgwqDCoMKg4pWU4paTwqDCoMKgwqDCoGvilZzilanilojilozilozCoMKgwqDCoMKgwqDCoArCoMKgwq
    DCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoOKUgM6T4pWcImDCoCzCoMKgwqAsNOKWgOKVo1
    zCoMKg4pWT4paT4paT4paA4pWc4oygYMKgwqDCoMKg4paEYEXCoMKgwqDCoMKgwqDilojiloziloTiloDiloziloTCoEBd4paI4paTJy53wqDCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqDCoMKgCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwq
    DCoMKgwqDCoMKgwqAs4oyQKuKVneKVo+KWkeKWjOKWgCIi4paQ4paA4oyQwqAswqDCoMKgwqDiiKnCoOKWjMKg4pWdwqDCoMKgwqDCoF1N4paQ4paMJiXila
    LilazDh+KVmeKUlMKgwr8i4pWRwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwq
    DCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgLOKVkCLCoMKgwqDCoMKgwqBV4paQW8Kg4pScwqDCoMKgwqzCoFfCoMKgwqDilZNn4paQ4paMKs
    KsLsKgwqDCoCLCoMOGwqDCoMKgIuKWgF3ilZlgwqDCoMKg4pWZV8KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqAKwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoEDijJDCoMKgcsKgwqDCoOKUjFzCoF3ilaviloziloTilazilZfilZPilZ
    DDh+KVmeKVomDCoMKgwqDCoGDCoOKVmeKWk+KWiOKWiOKWhOKWhOKVm+KWhMKgwqDCoMKgwqDilaBVwqDCoMKgXV1b4paMwqDCoMKgwqDCoMKgwqDCoMKgwq
    DCoMKgwqDCoArCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg4paM4paTUH7Cqk
    tgwqDCoOKVmcKg4paE4paI4paMwqDilZDCoOKWkOKWhOKWhOKWhOKWhOKWhOKWhOKWhOKWhOKWk+KWiOKWiOKWiOKWiOKWiOKWiOKWgOKVoOKVo+KVnyRNwq
    BdW2rilaPilZHilZXCoEDDqcOR4pWc4pWoIl7ijIJMTExMLEzCoMKgwqDCoArCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqBU4pWZ4paA4paA4paA4paA4paAVFRUVFQiIiLilZniloDiloDiloDiiJ4sd+KWgOKWgOKWgOKWgOKWgOKWgOKVmeKVmeKVmeKVme
    KVmeKVmeKMoOKWk+KWk+KVkCLilanilazilpPilZnDkSJR4paQw4cqwqDilZrilpLilIBgKuKVpuKWhOKWhOKWiOKWiOKWiOKWiOKWiOKWiOKWgOKMoMKgwq
    DCoMKgCsKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoM
    KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoCzilZPiloTiloTiloTiloTiloRR4paQ4paT4paMLCzilZPiloTiloTiloTilpPilp
    PiloDiloDiloDiloDiloDiloDijKDijKDijKDCoMKg'
    getThis $b
    Write-Host ''
    Write-Host $vf19_READ
    Write-Host -f YELLOW "    ==============================================================================="
}

function splashPage1b(){
    Write-Host -f YELLOW "               VB-6  KÖNIG MONSTER (Macross VFX-2/Macross Frontier)"
    Write-Host -f YELLOW "     Scans accessible shares to generate a list of filepaths for investigation/hunting"
    Write-Host -f YELLOW "    ===============================================================================
    "
}



## If no default paths have been configured for MACROSS, get it manually
function getValidPath(){
    Write-Host -f GREEN ' Enter a valid filepath to recursively search, or "c" to cancel:'
    Write-Host -f GREEN '  > ' -NoNewline;
    $z = Read-Host
    if($z -eq 'c'){
        Remove-Variable dyrl_kon_* -Scope Global
        Exit
    }
    elseif($z -eq ''){
        ''
        Write-Host -f GREEN '  Opening folder selection window:
        '
        $zz = getFile 'folder'
        $zz
        read-host
    }

    if($zz -eq ''){
        Remove-Variable dyrl_kon_* -Scope Global
        Exit
    }
    
    Return $zz
    
}


## Set the fileshare locations
function splitShares($1){
    if(getThis $vf19_MPOD[$1]){
        Return $Global:vf19_READ
    }
    else{
        Return $false
    }
}




## Stale reports
$dyrl_kon_STALE = "$vf19_DEFAULTPATH\target-pkgs\*.txt"

## Input validation
$dyrl_kon_BROAD = [regex]"[a-z]*\-*[0-9]{1,2}"
$dyrl_kon_SINGLE = [regex]"[a-z]*[0-9]*"
$dyrl_kon_ADMINUSR = [regex]"^admin\-[a-z][a-z]*[0-9]*"  ## MPOD ALERT!! Your admin users may have a different designation than 'admin'
$dyrl_kon_ONLYFC = [regex]"[a-z0-9._-]*"
$dyrl_kon_ONLYLC = [regex]"[a-z,]*"
$dyrl_kon_ERRMSG = "  ERROR! Unsupported character in your filename!"




<#
    
    MPOD ALERT!!
    The below "splitShares" instructions are placeholders:
    You can have as many or as few filepaths as you need.
    Encode them as base64 strings, and add a three-letter
    ID to the front of the encoded string (for example,
    'fdr' and 'nxd' below), and add them to the opening
    comment in utility.ps1 separated by '@@@'. (or use whatever
    method you created and changed in the display.ps1 script's
    "startUp" function).

    The calls for "splitShares" are using the three-letter
    ID as the index for where your base64 string is located
    inside the $vf19_MPOD hashtable. 

    PROCESS:
    MACROSS starts up, reads the opening comments from utility.ps1,
    splits the comment up into separate strings using '@@@' as the
    delimiter, and stores each value in $vf19_MPOD, using the first
    three characters of each string as the index.
    YOUR script can decode those filepaths (or whatever value you
    stored in utility.ps1) by using the getThis function:

        getThis $vf19_MPOD['abc']

    where 'abc' is the index you added to your encoded string. The
    plaintext value is stored in $vf19_READ, which you can then use
    however you need to. Be aware that $vf19_READ gets overwritten
    every time the getThis function is used, so store that variable
    in a new one if you want to keep it!

#>
#splitShares 'fdr'
$dyrl_kon_FIRSTDRIVE = splitShares 'fdr'
#splitShares 'nxd'
$dyrl_kon_NEXTDRIVE = splitShares 'nxd'
#splitShares 'thd'
$dyrl_kon_THIRDDRIVE = splitShares 'thd'
#splitShares 'fth'
$dyrl_kon_FOURTHDRIVE = splitShares 'fth'

## Enables the main "While" loop
$dyrl_kon_LOOP = $true

###################
##  MAIN
###################
while( $dyrl_kon_LOOP ){
    
    # Tables/Arrays
    $dyrl_kon_FEXT0 = @()          ## Collects multiple extensions entered by user
    $dyrl_kon_FEXT1 = @()          ## FEXT0 contents formatted with wildcards
    [int[]]$dyrl_kon_CT = $null    ## number of items in FEXT1


    # Start clean when user chooses to perform multiple searches
    $Global:RESULTFILE = $null     ## write results to this file
    $dyrl_kon_NORE = $null         ## user's search type -- filename vs. extension vs. alt data stream
    $dyrl_kon_WILD = $null         ## user's search query with wildcard
    $dyrl_kon_i = $null            ## for-loop variables
    $dyrl_kon_UNAME = $null        ## username OR name of top-level dir
    $dyrl_kon_Z = $null            ## user response, typically 'y' or 'n'

    $dyrl_kon_ADS = $false         ## default alt-data stream choice, forces user to switch to 'true'




    #############
    # Check if KÖNIG is being auto-queried by another tool:
    #############
    if( $CALLER -or $dyrl_kon_COMMANDER -or $dyrl_kon_GENERAL ){

        $dyrl_kon_CLIENT = $CALLER         ## $CALLER gets replaced below if necessary
        $dyrl_kon_WILD = $PROTOCULTURE     ## This is the default search term; will change below if necessary
        $dyrl_kon_LOOP = $false            ## Only perform one search


        ## Account for python callers
        if( $dyrl_kon_GENERAL ){
            $dyrl_kon_CLIENT = $dyrl_kon_GENERAL
            $dyrl_kon_WILD = '*' + $dyrl_kon_ORDERS + '*'
        }
        elseif( $dyrl_kon_COMMANDER ){
            if( $CALLER ){

                if($dyrl_kon_COMMANDER -ne $CALLER){

                    ## $external_NM may already be in use by another script; use pyCALLER's search words instead
                    if( $dyrl_kon_ORDERS -and ($dyrl_kon_ORDERS -ne $external_NM) ){
                        $dyrl_kon_WILD = $dyrl_kon_ORDERS
                    }

                    ## Ignore $CALLER, KÖNIG is being queried by $pyCALLER
                    $dyrl_kon_CLIENT = $dyrl_kon_COMMANDER

                }

            }
            else{
                $dyrl_kon_CLIENT = $dyrl_kon_COMMANDER
                $dyrl_kon_WILD = '*' + $dyrl_kon_ORDERS + '*'
            }

        }


        ## MPOD ALERT!!
        ## The FPATH variable here gets set based on username. You need to configure MACROSS' utility.ps1 file so that
        ## it knows where your roaming profile locations are at! (See the MACROSS readme about encoding and storing
        ## default filepaths)

        elseif( $CALLER -eq 'MYLENE' ){         ## MYLENE will forward lists of usernames to search their profiles
            ''
            $dyrl_kon_UNAME = $PROTOCULTURE
            $dyrl_kon_WILD = '*'                ## MYLENE wants to see ALL files in newly-created user accounts
            if( $dyrl_kon_UNAME -Match $dyrl_kon_ADMINUSR ){
                $dyrl_kon_FPATH = $dyrl_kon_FOURTHDRIVE
            }
            else{
                while( ! (Test-Path -Path $dyrl_kon_FPATH)){
                    $dyrl_kon_FPATH = getValidPath
                }
            }
        }


        cls
        splashPage1b
        Write-Host -f GREEN " $dyrl_kon_CLIENT is tasking KÖNIG to target " -NoNewLine;
        Write-Host -f YELLOW "$dyrl_kon_WILD"
        $GOBACK = $true
        #$dyrl_kon_WILD = "*"
        $dyrl_kon_SM = "1KB"
        $dyrl_kon_LG = "100GB"
        $dyrl_kon_FDESC = "0_to_100GB"

        ## Name the output file same as the search term, but add "-search"
        ## -Python scripts must pass a write-location as a fourth param if they want a text file output.
        ## -MACROSS powershell scripts already use $vf_19_DEFAULTPATH, so they're good to go.
        if( $dyrl_kon_HOMEBASE ){
            $vf19_DEFAULTPATH = $dyrl_kon_HOMEBASE
        }
        if( $vf19_DEFAULTPATH ){
            $dyrl_kon_NEWOUT = $dyrl_kon_WILD -replace "\*" -replace " .*$" -replace "$",'-search'
        }

        <#
            MPOD ALERT!!
            The below "if/else" statement is a placeholder!  You need to set these values based
            on your network share locations. See the section above where "splitShares"
            resides.
            In the example below, KONIG is setting the search location (a bogus value) based on whether
            the value passed in (DIRECT) looks like an adminsitrator's username, which probably
            means it should search a fileshare containing admin profiles. You need to modify this
            to suit your needs.
        #>
        ## Use the passed-in directory to search, if one was provided
        if( $dyrl_kon_AO ){
            if( $dyrl_kon_AO -Match $dyrl_kon_ADMINUSR ){
                $dyrl_kon_FPATH = "$dyrl_kon_FOURTHDRIVE\$dyrl_kon_AO"
            }
            else{
                $dyrl_kon_FPATH = $dyrl_kon_AO
            }
        }
        ## Ask the user to specify the search location
        else{
            while( ! $dyrl_kon_FPATH ){
                $dyrl_kon_FPATH = getValidPath
            }
        }
        
        slp 2
        
    }


    ########################
    ## If KÖNIG was launched by itself, it needs user input
    ########################
    while( ! $dyrl_kon_FPATH ){

        if( (Get-ChildItem -Path $dyrl_kon_STALE).count -gt 0 ){
            cls
            houseKeeping $dyrl_kon_STALE 'KONIG'
        }

        splashPage1a
        splashPage1b


        ## MPOD ALERT!!
        ## If you have not set default paths via the MACROSS method in utility.ps1, you can only
        ##  perform manually-entered filepath searches
        if( $dyrl_kon_FIRSTDRIVE -eq $false){
            $dyrl_kon_FPATH = getValidPath
        }
        else{

        <#
            MPOD ALERT!!  Modify the below text to match the network shares you are searching.
                          Until set those values, you will be stuck manually entering filepaths!!
        #>

        Write-Host ''
        Write-Host '    1 ' -NoNewline;
            Write-Host -f GREEN '- Second share'
        Write-Host '    2 ' -NoNewline;
            Write-Host -f GREEN '- First share'
        Write-Host '
        '

        Write-Host -f GREEN " If you need to search non-profile shares, please choose from 1-2 above, otherwise"
        Write-Host -f GREEN ' hit ENTER to search user profiles, or ' -NoNewline;
        Write-Host -f YELLOW 'q' -NoNewline;
        Write-Host -f GREEN ' to quit:  ' -NoNewline;
        $dyrl_kon_Z = Read-Host

        if( $dyrl_kon_Z -eq 'q' ){
            Remove-Variable vf19_OPT1
            Remove-Variable dyrl_kon* -Scope Global
            Return
        }
        if( $dyrl_kon_Z -Match "[1-2]{1}" ){
            if( $dyrl_kon_Z -eq 1 ){
                $dyrl_kon_FPATH = $dyrl_kon_NEXTDRIVE         ## MPOD ALERT!! 'NEXTDRIVE' is set by 'splitShares' above
                $dyrl_kon_Z = $null
            }
            elseif( $dyrl_kon_Z -eq 2 ){
                $dyrl_kon_FPATH = $dyrl_kon_FIRSTDRIVE        ## MPOD ALERT!! 'FIRSTDRIVE' is set by 'splitShares' above
                $dyrl_kon_Z = $null
            }

            while( $dyrl_kon_UNAME -notMatch "^[a-zA-Z0-9].*" ){
                Write-Host ''
                Write-Host -f GREEN ' Enter ' -NoNewline;
                Write-Host -f YELLOW 'ls' -NoNewline;
                Write-Host -f GREEN ' to get a quick root directory listing, OR enter a full/partial'
                Write-Host -f GREEN ' directory name (at least one letter/number), or a captial ' -NoNewline;
                Write-Host -f YELLOW 'C' -NoNewline;
                Write-Host -f GREEN ' to cancel:  ' -NoNewline;
                $dyrl_kon_UNAME = Read-Host

                if( $dyrl_kon_UNAME -eq 'ls' ){
                    Get-ChildItem -Path $dyrl_kon_FPATH |
                    Foreach-Object{
                        $nc_list = $_.name
                        if($_.mode -Like "d*"){
                            $nc_list = $nc_list + ' (Directory)'
                        }
                        Write-Host -f GREEN "     $nc_list"
                    }
                    Write-Host ''
                    Write-Host -f GREEN "  Hit ENTER to continue.
                    "
                    Read-Host
                    $dyrl_kon_UNAME = $null
                }
                elseif( $dyrl_kon_UNAME | Select-String -CaseSensitive "^C$" ){
                    Remove-Variable nc_* -Scope Global
                    Exit
                }
            }
        }
        else{
            cls
            splashPage1a
            splashPage1b

            
            Write-Host -f GREEN " Enter " -NoNewLine;
            Write-Host -f CYAN "admin-<letter> " -NoNewLine;        ## MPOD ALERT!!  Your admins may not use an 'admin-name' designation
            Write-Host -f GREEN "to search admin user shares.
            "
            Write-Host -f GREEN " If you only enter 'a', KÖNIG will search all 'a' users AND any admin users it finds.
            "
            while( $dyrl_kon_UNAME -notMatch "^[a-zA-Z].*" ){
                Write-Host -f GREEN ' Enter a username, partial username, or ' -NoNewline;
                Write-Host -f YELLOW 'BRRT' -NoNewline;
                Write-Host -f GREEN ' to search all the things.
                '
                Write-Host -f GREEN ' Enter ' -NoNewline;
                Write-Host -f YELLOW 'Q' -NoNewline;
                Write-Host -f GREEN ' (MUST CAPITALIZE IT!) to quit.
                '
                Write-Host -f GREEN '   > ' -NoNewline;
                $dyrl_kon_UNAME = Read-Host
            }
            

            if( $dyrl_kon_UNAME | Select-String -CaseSensitive 'BRRT' ){
		        Write-Host " Okay, searching EVERYBODY'S fileshare...
		        "
                $dyrl_kon_UNAME = '*'
                $dyrl_kon_FPATH = $dyrl_kon_THIRDDRIVE                                  ## MPOD ALERT!!
            }
            elseif( $dyrl_kon_UNAME | Select-String -CaseSensitive 'Q' ){
                Remove-Variable vf19_OPT1
                Remove-Variable dyrl_kon* -Scope Global
                Return
            }
            elseif($dyrl_kon_UNAME -Match $dyrl_kon_ADMINUSR){                           ## MPOD ALERT!!
                $dyrl_kon_FPATH = $dyrl_kon_FOURTHDRIVE
            }
            elseif(($dyrl_kon_UNAME -Match $dyrl_kon_SINGLE)  -or  ($dyrl_kon_UNAME -Match $dyrl_kon_BROAD)){        ## MPOD ALERT!!
                $dyrl_kon_FPATH = $dyrl_kon_THIRDDRIVE
            }
        }


        }  ### Closes the if($NOTCONFIGURED)...else statement


        #############
        # Specify search for filenames or extensions & make sure only
        # valid chars are used
        #############

        $dyrl_kon_HOLDINGPATTERN = $true
        while( $dyrl_kon_HOLDINGPATTERN ){
            Write-Host ''
            Write-Host -f GREEN " Enter a filename or partial filename to search (" -NoNewline;
            Write-Host -f YELLOW "*" -NoNewline;
            Write-Host -f GREEN " wildcard is okay), or " -NoNewLine;
            Write-Host -f YELLOW "ext " -NoNewLine;
            Write-Host -f GREEN "to search"
            Write-Host -f GREEN " by file extension instead. If you want to search for hidden ADS files, enter" -NoNewline;
            Write-Host -f YELLOW " altds" -NoNewline;
            Write-Host -f GREEN " to"
            Write-Host -f GREEN " only report on alternate data streams:  " -NoNewline;
                    $dyrl_kon_NORE = Read-Host
            if( $dyrl_kon_NORE -eq "ext" ){
                Write-Host ''
                Write-Host -f GREEN " Specify the file extension(s) you need to find. If more than one, separate them with"
                Write-Host -f GREEN " a comma (no spaces).  " -NoNewline;
                    $dyrl_kon_FEXT0 = Read-Host

                if( $dyrl_kon_FEXT0 -Match $dyrl_kon_ONLYLC ){
                    Remove-Variable -Force dyrl_kon_HOLDINGPATTERN
                }
                else{
                    Write-Host -f CYAN $dyrl_kon_ERRMSG
                }

            }
            elseif( $dyrl_kon_NORE -eq 'altds' ){
                $dyrl_kon_WILD = "*"
                $dyrl_kon_ADS = $true                 ## Skip writing any results that are not alt data streams
                Remove-Variable -Force dyrl_kon_HOLDINGPATTERN 
            }
            elseif( $dyrl_kon_NORE -Match $dyrl_kon_ONLYFC ){
                $dyrl_kon_WILD = "*$dyrl_kon_NORE*"
                Remove-Variable -Force dyrl_kon_HOLDINGPATTERN
            }
            else{
                Write-Host -f CYAN $dyrl_kon_ERRMSG
            }

            
            Write-Host ''
            Write-Host -f GREEN " If you want to save a txt output, enter a new filename. A file is required if you want to send"
            Write-Host -f GREEN " search results to another tool for parsing. If not, hit ENTER to skip:  " -NoNewLine;
            $dyrl_kon_NEWOUT = Read-Host

        }

        #############
        # If user entered multiple items, check them against the input validators,
        # create an array to store each item then add the wildcards
        #############
        if( $dyrl_kon_FEXT0 -Match $dyrl_kon_ONLYLC ){
            $dyrl_kon_FEXT0 = $dyrl_kon_FEXT0.Split(",")
            $dyrl_kon_CT = $dyrl_kon_FEXT0.count

            if( $dyrl_kon_CT -ge 1 ){
                foreach($dyrl_kon_i in $dyrl_kon_FEXT0){
                    $dyrl_kon_FEXT1 += "*.$dyrl_kon_i"
                }
                $dyrl_kon_WILD = $dyrl_kon_FEXT1.Split(' ')
            }
            else{
                $dyrl_kon_WILD = $dyrl_kon_FEXT0
            }
        }




        #############
        # Filter collection by filesize to help narrow the size of lists
        #############
        Write-Host ''
        Write-Host -f GREEN " Adjusting KÖNIG's loadout selector... (you can filter by filesize here)"
        Write-Host "    1. " -NoNewLine;
            Write-Host -f GREEN "Autocannons    (files between 0 and 3MB)"
        Write-Host "    2. " -NoNewLine;
            Write-Host -f GREEN "Micro-missles  (files between 3 and 6MB)"
        Write-Host "    3. " -NoNewLine;
            Write-Host -f GREEN "Cluster Bombs  (files between 6 and 10MB)"
        Write-Host "    4. " -NoNewLine;
            Write-Host -f GREEN "Heat-Seekers   (files between 0 and 10MB)"
        Write-Host "    5. " -NoNewLine;
            Write-Host -f GREEN "Rail Guns      (files between 10MB and 100MB)
             "
        Write-Host -f GREEN " Choose 1, 2, 3, 4, or 5, or press ENTER to go for broke and find all files up to 100 " -NoNewline;
		    Write-Host -f YELLOW "GB:  " -NoNewLine;
            $dyrl_kon_SZ1 = Read-Host 

            if( $dyrl_kon_SZ1 -eq 1 ){
                $dyrl_kon_SM = "0MB"
                $dyrl_kon_LG = "3MB"
                $dyrl_kon_FDESC = "0_to_3MB"
            }
            elseif( $dyrl_kon_SZ1 -eq 2 ){
                $dyrl_kon_SM = "3MB"
                $dyrl_kon_LG = "6MB"
                $dyrl_kon_FDESC = "3_to_6MB"
            }
            elseif( $dyrl_kon_SZ1 -eq 3 ){
                $dyrl_kon_SM = "6MB"
                $dyrl_kon_LG = "10MB"
                $dyrl_kon_FDESC = "6_to_10MB"
            }
            elseif( $dyrl_kon_SZ1 -eq 4 ){
                $dyrl_kon_SM = "0MB"
                $dyrl_kon_LG = "10MB"
                $dyrl_kon_FDESC = "0_to_10MB"
            }
            elseif( $dyrl_kon_SZ1 -eq 5 ){
                $dyrl_kon_SM = "10MB"
                $dyrl_kon_LG = "100MB"
                $dyrl_kon_FDESC = "10MB_to_100MB"
            }
            else{
                $dyrl_kon_SM = "0MB"
                $dyrl_kon_LG = "100GB"
                $dyrl_kon_FDESC = "0_to_100GB"
            }


    
        Write-Host ''
        Write-Host -f GREEN ' Searching for ' -NoNewLine;
        Write-Host -f YELLOW "$dyrl_kon_WILD" -NoNewLine;
        Write-Host -f GREEN '.'
        Write-Host -f GREEN ' Please wait while I collect the directories matching your inputs...'
        Write-Host " ==================================================================
        "
        Start-Sleep -Second 2



    }   # Everything above this line is determined by either user input or an auto-generated file from an associated tool



    #############
    # Set default vars for search results output; create txt file that can be exported or shared within MACROSS
    #############
    $dyrl_kon_DIREXISTS = Test-Path "$vf19_DEFAULTPATH\target-pkgs\"
    $dyrl_kon_CTR = 0
    $Global:dyrl_kon_ADSC = 0


    #############
    # Create output directory
    #############
    if( $dyrl_kon_NEWOUT ){
        if( ! $dyrl_kon_DIREXISTS ){
            New-Item -Path $vf19_DEFAULTPATH -Name 'target-pkgs' -ItemType directory
        }
        $Global:RESULTFILE = "$vf19_DEFAULTPATH\target-pkgs\$dyrl_kon_NEWOUT.txt"
    }

    if( ! $dyrl_kon_GENERAL ){
        splashPage1a
    }

    #########################
    ## Look for hidden files
    #########################
    function secretStash(){
        $dyrl_kon_ADS1 = Get-Item $_ 
		$dyrl_kon_ADS2 = Get-Item $_ -Stream * | Where Stream -ne ':$DATA' | Where Stream -ne 'Zone.Identifier'
        $dyrl_kon_ADSF = $dyrl_kon_ADS2 | Select -ExpandProperty Stream
        $dyrl_kon_ADSN = $dyrl_kon_ADS1 | Select -ExpandProperty Name
        $dyrl_kon_ADSP = $dyrl_kon_ADS2 | Select -ExpandProperty PSPath
        if( $dyrl_kon_ADS ){
            if( $dyrl_kon_ADS2 ){                                           ## Write to screen if only looking for ADS
                Write-Host -f YELLOW "  $dyrl_kon_ADSN : $dyrl_kon_ADSF"
                $dyrl_kon_ADSP | Out-File -FilePath "$RESULTFILE" -Append
                $dyrl_kon_ADSF | Out-File -FilePath "$RESULTFILE" -Append
                Add-Content -Path "$RESULTFILE" -Value '--------------------
                '
                $Global:dyrl_kon_ADSC++
                $dyrl_kon_FILEWRITTEN = $true
            }
            else{
                Write-Host "  $dyrl_kon_ADSN" -NoNewline;
                Write-Host -f GREEN ' - No ADS found...'
            }
        }
        elseif( $dyrl_kon_ADS2 ){
            Write-Host -f CYAN "  $dyrl_kon_ADSN : $dyrl_kon_ADSF"
            Add-Content -Path $RESULTFILE -Value 'ALTERNATE DATA STREAM FOUND:'
            $dyrl_kon_ADSP | Out-File -FilePath "$RESULTFILE" -Append
            $Global:dyrl_kon_ADSC++
            $dyrl_kon_FILEWRITTEN = $true
        }
    }


    <#================================================================
                                 Run the search and generate a list
    ================================================================#>
    $Global:HOWMANY = 0  ## Track search results
    $dyrl_kon_TRUNCATE = Split-Path -Path "$_" -Leaf -Resolve  ## Format the screen output to omit the filepath

    ## Iterate through matching usernames
    foreach( $dyrl_kon_DIR0 in Get-ChildItem -Directory $dyrl_kon_FPATH\$dyrl_kon_UNAME* ){
        $dyrl_kon_DIR1 = Split-Path -Path $dyrl_kon_DIR0 -Leaf -Resolve
        Write-Host ''
        Write-Host -f GREEN '  Now searching ' -NoNewline;
        Write-Host -f MAGENTA "$dyrl_kon_DIR1" -NoNewline;
        Write-Host -f GREEN "'s stuff..."
        slp 1

        ## Recursively search profile directory for specified words/extensions
        Get-Childitem -Path "$dyrl_kon_DIR0\*" `
            -Include $dyrl_kon_WILD `
            -Exclude ._* `
            -Recurse `
            -Force |
            %{
                if(%{ 
                    $_.length -gt "$dyrl_kon_SM" -and $_.length -le "$dyrl_kon_LG"
                })


                ## Write each result to the filename created by the user if not focused on alt data streams;
                ##   will just silently error out if user didn't want a save file 
                {
                    if( $dyrl_kon_ADS -ne $true ){
                        %{$_.FullName} |  
                        Out-File -FilePath $RESULTFILE -Append
                        $dyrl_kon_FILEWRITTEN = $true
                        $dyrl_kon_TRUNCATE = Split-Path -Path "$_" -Leaf -Resolve
                        $dyrl_kon_CTR++
                        $Global:HOWMANY++
                        Write-Host -f MAGENTA "     $dyrl_kon_DIR1" -NoNewline;
                        Write-Host ":" -NoNewline;
                        Write-Host -f YELLOW " Match #$dyrl_kon_CTR - $dyrl_kon_TRUNCATE"
                    }
                    secretStash $_
                }
            }
    }

    
    $dyrl_kon_LOOP = $false

}




    <#================================================================
                                Check if other modules need to load
    ================================================================#>
    Write-Host '
    '

    #############
    ## Give user feedback on how many results they got 
    #############
    $dyrl_kon_RESULTFN = Split-Path -Path "$RESULTFILE" -Leaf -Resolve

    if( ($dyrl_kon_CTR -gt 0) -or ($Global:dyrl_kon_ADSC -gt 0) ){
        $dyrl_kon_LOOP = $false
        Write-Host "  $HOWMANY " -NoNewLine;
        Write-Host -f GREEN 'results have been found!'
        if( $dyrl_kon_RESULTFN ){
            Write-Host -f GREEN '  Results have been written to ' -NoNewLine;
            Write-Host -f MAGENTA "$dyrl_kon_RESULTFN " -NoNewLine;
            Write-Host -f GREEN 'in the ' -NoNewLine;
            Write-Host -f MAGENTA 'target-pkgs' -NoNewLine;
            Write-Host -f GREEN ' directory on your Desktop.
            '
        }
        Write-Host "  $Global:dyrl_kon_ADSC" -NoNewline;
        Write-Host -f GREEN ' alternate data streams were found!'
        
        while( $dyrl_kon_ZC -ne 'c' ){
            Write-Host -f GREEN '  Type ' -NoNewline;
            Write-Host -f YELLOW 'c' -NoNewline;
            Write-Host -f GREEN ' to continue:  ' -NoNewline;
            $dyrl_kon_ZC = Read-Host
        }

        #############
        ## Check if tool was run from another module, and send back a KONIG target package
        #############
        if( $dyrl_kon_CLIENT ){
            cls

            function pyFile($1,$2){
                $1 | Out-File -FilePath "$vf19_GBIO\konig.eod" -Encoding UTF8 -Append
                if($2){
                    $2 | Out-File -FilePath "$vf19_GBIO\konig.eod" -Encoding UTF8 -Append
                }
            }

			if( $RESULTFILE ){
                if( $dyrl_kon_GENERAL ){
                    pyFile $RESULTFILE $HOWMANY
                    Exit
                }
                else{
				    Return $RESULTFILE,$HOWMANY
                }
			}
			else{
                if( $dyrl_kon_GENERAL ){
                    pyFile $HOWMANY
                    Exit
                }
                else{
				    Return $HOWMANY
                }
			}
        }



        #############
        ## Check if related MACROSS tools are available, and offer option
        ## to cross-search results
        #############
        
        function collaborate(){
            Write-Host '
            '
            if( $vf19_E1 ){
                $choices = $true
                Write-Host -f GREEN '      -Enter ' -NoNewline;
                Write-Host -f YELLOW 'e' -NoNewline;
                Write-Host -f GREEN " to have ELINTS string-search these $dyrl_kon_numfiles files."
            }
            if( $vf19_G1 ){
                $choices = $true
                Write-Host -f GREEN '      -Enter ' -NoNewline;
                Write-Host -f YELLOW 'g' -NoNewline;
                Write-Host -f GREEN ' to have GERWALK query Carbon Black for the most recent users/processes'
                Write-Host -f GREEN "        related to these $dyrl_kon_numfiles files."
            }
            if( $choices ){
                Write-Host -f GREEN '      -Just hit ENTER to skip.'
                Write-Host -f GREEN '         > ' -NoNewline;
                Read-Host
            }
            
        }

        $dyrl_kon_numfiles = (gc $RESULTFILE).length
        if($dyrl_kon_numfiles -gt 0){
        while( $dyrl_kon_collaborate -ne 'no' ){
            $dyrl_kon_collaborate = collaborate
            if( $dyrl_kon_collaborate -eq 'e' ){
                $COMEBACK = $true
                collab 'ELINTS.ps1' 'KONIG'                            ## ELINTS is looking for $RESULTFILE
                Write-Host '
                '
            }
            if( $dyrl_kon_collaborate -eq 'g' ){
                $COMEBACK = $true
                Write-Host -f GREEN "  Do you want to scan for ALL of these files? " -NoNewline;
                $tcz = Read-Host
                if( $tcz-Match "^y"){
                    gc $RESULTFILE | Foreach-Object{
                        $Global:external_NM = $_ -replace "^.+\\",''    ## GERWALK scans $external_NM
                        collab 'GERWALK.ps1' 'KONIG'
                    }
                }

                ## If user wants to pick and choose which filenames to query against Carbon Black
                else{
                    while($tch -ne 'q'){
                        $tnm = 0
                        $tlist = @()
                        gc $RESULTFILE | Foreach-Object{
                            $tnm++
                            $tfl = $_ -replace "^.+\\",''
                            $tlist += $tfl
                            Write-Host -f YELLOW "  $tnm" -NoNewline;
                            Write-Host -f GREEN ". $tfl"
                        }
                        Write-Host -f GREEN '  Choose a file number to pull data on (q to quit):' -NoNewline;
                        $tch = Read-Host
                        $tch = $tch - 1
                        if($tlist[$tch]){
                            $Global:external_NM = [string]($tlist[$tch])
                            collab 'GERWALK.ps1' 'KONIG'
                            splashPage
                        }
                    }
                    
                }
                Remove-Variable -Force tnm,tlist,tfl,tch,tcz
                Write-Host '
                '
                
            }
            else{
                $dyrl_kon_collaborate = 'no'
                $dyrl_kon_LOOP = $false
            }


        }
        }
    }
    #############
    ##  While running 'KÖNIG' from other modules like MYLENE, give notice if search has no results
    #############
    elseif( $GOBACK ){
        $dyrl_kon_LOOP = $false
        Remove-Variable GOBACK
        Remove-Variable dyrl_kon_*
        Write-Host ''
        Write-Host -f CYAN '  Nothing found...
        
        '
        Return
    }
    #############
    ##  While running 'KÖNIG' by itself, give notice if search has no results
    #############
    else{
        Write-Host -f CYAN '  Bummer, nothing was found! Exiting...'
        slp 1
        Exit
    }



    #############
    ##  Resume here when finished with string searches and
    ##  offer option to delete the 'KÖNIG' file if no longer needed
    #############
    if( $COMEBACK ){
        $dyrl_kon_LOOP = $false
        Remove-Variable COMEBACK
        Remove-Variable GOBACK
        Write-Host ''
        splashPage1a
        Write-Host '
        '

        $dyrl_kon_Z = $null

        while( $dyrl_kon_Z -notMatch "^(y|n)" ){
            Write-Host -f GREEN "  Welcome back to KÖNIG! Do you want to delete " -NoNewLine; 
            Write-Host -f YELLOW "$dyrl_kon_NEWOUT.txt" -NoNewLine; 
            Write-Host -f GREEN " now that the other scans are finished? " -NoNewLine; 
            $dyrl_kon_Z = Read-Host
        }

        if( $dyrl_kon_Z -Match "^y" ){
            '6e656f6e67656e657369736576616e67656c696f6e737578' | Set-Content -Force $RESULTFILE   # sanitize file
            Remove-Item -Path $RESULTFILE                                                         # delete file
            Write-Host -f GREEN '  File has been deleted. Goodbye.
            '
        }
        else{
            Write-Host -f GREEN '  File will not be deleted. Goodbye.
            '
        }
        Remove-Variable -Force dyrl_kon_loop
        slp 3
    }



Remove-Variable dyrl_kon_* -Scope Global
Remove-Variable RESULTFILE -Scope Global
