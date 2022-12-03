<img src="https://raw.githubusercontent.com/hisurfadvisory/MACROSS/main/scr.PNG">

# MACROSS
Powershell framework for interweaving Powershell and Python API automations for blueteams

TL;DR -- A "no-command-line-necessary" powershell menu to link multiple automation scripts together for blue-team investigators. When you run MACROSS for the first time, select the option for 'DEMO' to get a quick walkthru on configuring your defaults.

Multi-API-Cross-Search Console (MACROSS --- yeah, I'm a hardcore Macross nerd) tool interface is a very simple powershell framework to connect multiple automation scripts together. I've included a few of my own scripts here, but the key to MACROSS is adding scripts specific to your environment, and letting the console seamlessly link them together.

The purpose of this framework is to make automation tasks available to everyone on your blue team regardless of their skill with command-line. This can make things alot quicker if you're able to use APIs to query security tools instead of web-interfaces (See my CARBON8 tool which uses the Carbon Black API).

DISCLAIMER: I'm a bash junkie, but Windows is what I work on in most corporate environments, and this project originally started as a way simplify my most common investigation queries. While I am experienced in a few scripting languages, I am NOT a powershell expert. I'm sure there's tons of optimizations that could be done to this framework.

Just a couple examples of why I created it:

-One network I investigated used specific hostname patterns to identify what kind of client or server the host was. I wrote a script to parse these hostnames, either after performing an nslookup or with input from the user, and then matched the hostnames to their descriptions for the user. It also offered options to perform customizable Active-Directory lookups on hosts, and shared results with scripts that performed Bloodhound (https://github.com/BloodHoundAD/SharpHound) and basic NMAP functions for the IR and VM teams to make use of.

-I wrote one script to actively scan for accessible file shares and perform searches on filenames and extensions by username, file-size, last-modified time, etc. Results from these searches could then be automatically passed to another script that performed customizable string-scans & copy/robo-copy functions.

Any analyst on the team could quickly launch one of these options from MACROSS, and easily pass results into their choice of other functions within the console to aid them investigating alerts from their security tools. No hand-jamming commands necessary, and was usually faster than logging into a web-interface (or several web interfaces).

See the full readme below for details, but the basic FAQ is that core functions are kept in the 'ncore' folder within the same directory as MACROSS.ps1 (usually on the user's desktop), and all of your custom powershell scripts, when dropped into the 'nmods' folder, will automatically become options in the MACROSS menu. If you host a master repo for MACROSS on your network and modify the extras.ps1 file to include its encoded filepath, then any updates you make to your scripts in the 'nmods' folder will automatically get pushed out to your SOC users.

FRAMEWORK SETUP (modify however works best for you):
1. All core functions are kept in the "ncore" folder
1a. Default variables are base-64 encoded and stored in the opening comments line within "extras.ps1" in the ncore folder
1b. The "ncore" folder also contains a subfolder called "py_classes". A very basic python library, "mcdefs", is located here, and you can place your own custom libraries/classes here, as well.
1c. The mcdefs library enables python scripts to share the default resources/values of MACROSS powershell scripts.
2. Custom automation/API scripts (powershell and python) are kept in the "nmods" folder
2a. Custom scripts must contain "#_wut " in the first line, and "#_ver " in the second line, or they will be ignored
2b. Custom python scripts are always passed 6 arguments by default (see the availableMods function in "validation.ps1"): the logged in user, their desktop location, the array of base64-encoded defaults, the "numchk" integer MACROSS uses for common mathing, the location of the mcdefs python library, and the filepath to the MACROSS root folder
2c. MACROSS ignores python scripts if Python3 isn't installed
3. All core variables (when possible) are named beginning "$vf19_" to control cleanup
3a. For the same reason, custom variables (when possible) should be named beginning with "$dyrl_"
3b. Shared variables that get passed from one script to another for processing include:
	$PROTOCULTURE = the thing being investigated (A file, a value, a username, etc)
	$CALLER = the name of the script calling functions in another
	$HOWMANY = the number of successful results being tracked between scripts
4. Files used for enrichment are kept in the "resources" folder

