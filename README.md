<img src="https://raw.githubusercontent.com/hisurfadvisory/MACROSS/main/scr1.PNG">

# MACROSS
Powershell framework for interweaving Powershell and Python API automations for blueteams

TL;DR -- A "no-command-line-necessary" powershell menu to link multiple automation scripts together for blue-team investigators. When you run MACROSS for the first time, select one of the several demo scripts to get a quick walkthru on configuring your defaults.

Multi-API-Cross-Search Console (MACROSS --- yeah, I'm a hardcore Macross anime nerd) tool interface is a very simple powershell framework to connect multiple automation scripts together. I've included a few of my own scripts here, but the key to MACROSS is adding scripts specific to your environment, and letting the console seamlessly link them together.

The purpose of this framework is to make automation tasks available to everyone on your blue team regardless of their skill with command-line. This can make things alot quicker if you're able to use APIs to query security tools instead of web-interfaces (See my GERWALK tool which uses the Carbon Black API).

DISCLAIMER: I'm a bash junkie, but Windows is what I work on in most corporate environments, and we don't always get to have all the goodies we want to have on every single network. This project originally started as a way simplify my most common investigation queries, and it was written on a closed network where I couldn't just install whatever I wanted/needed. While I am experienced in a few scripting languages, I am NOT a powershell expert. I'm sure there's tons of optimizations that could be done to this framework.



See the many script internal comments for details, but the basic FAQ is that core functions are kept in the 'ncore' folder within the same directory as MACROSS.ps1 (usually on the user's desktop), and all of your custom powershell scripts, when dropped into the 'nmods' folder, will automatically become options in the MACROSS menu. If you host a master repo for MACROSS on your network and modify the extras.ps1 file to include its encoded filepath, then any updates you make to your scripts in the 'nmods' folder will automatically get pushed out to your SOC users.

When you run this for the first time, you'll see a warning about disabling updates. This is because it has no master repository defined, and you can ignore
this if you don't plan to use one.


FRAMEWORK SETUP (modify however works best for you):
1. All core functions are kept in the "ncore" folder<br>
1a. Default variables are base-64 encoded and stored in the opening comments line within "extras.ps1" in the ncore folder<br>
1b. The "ncore" folder also contains a subfolder called "py_classes". A very basic python library, "mcdefs", is located here, and you can place your own custom libraries/classes here, as well.<br>
1c. The mcdefs library enables python scripts to share the default resources/values of MACROSS powershell scripts.<br>
2. Custom automation/API scripts (powershell and python) are kept in the "nmods" folder<br>
2a. Custom scripts must contain "#_wut " in the first line, and "#_ver " in the second line, or they will be ignored<br>
2b. Custom python scripts are always passed 6 arguments by default (see the availableMods function in "validation.ps1"): the logged in user, their desktop location, the array of base64-encoded defaults, the "numchk" integer MACROSS uses for common mathing, the location of the mcdefs python library, and the filepath to the MACROSS root folder<br>
2c. MACROSS ignores python scripts if Python3 isn't installed<br>
3. All core variables (when possible) are named beginning "$vf19_" to control cleanup<br>
3a. For the same reason, custom variables (when possible) should be named beginning with "$dyrl_"<br>
3b. Shared variables that get passed from one script to another for processing include:<br>
	&emsp;$PROTOCULTURE = the thing being investigated (A file, a value, a username, etc)<br>
	&emsp;$CALLER = the name of the script calling functions in another<br>
	&emsp;$HOWMANY = the number of successful results being tracked between scripts<br>
4. Files used for enrichment are kept in the "resources" folder<br>

