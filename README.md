<img src="https://raw.githubusercontent.com/hisurfadvisory/MACROSS/main/mscr.PNG">

# MACROSS
Powershell framework aimed at interweaving Powershell and Python API automations for blueteams

TL;DR -- A "no-command-line-necessary" powershell menu to link multiple automation scripts together for blue-team investigators. When you run MACROSS for the first time, select the option for 'DEMO' to get a quick walkthru on configuring your defaults.

Multi-API-Cross-Search Console (MACROSS) tool interface is a very simple powershell framework to connect multiple automation scripts together. I've included a few of my own scripts here, but the key to MACROSS is adding scripts specific to your environment, and letting the console seamlessly link them together.

The purpose of this framework is to make automation tasks available to everyone on your blue team regardless of their skill with command-line. This can make things alot quicker if you're able to use APIs to query security tools instead of web-interfaces (See my GERWALK tool as an example, which uses the Carbon Black API).

DISCLAIMER: I'm a bash junkie, but Windows is what I work on in most corporate environments, and this project originally started as a way simplify my most common investigation queries. While I am experienced in a few scripting languages, I am NOT a powershell expert. I'm sure there's tons of optimizations that could be done to this framework.

MACROSS came about because I realized that all of the scripts I was writing to gather information during investigations were usually related -- look up AD info in a host > find out who's logged in > what was that file they just downloaded? > Let's string search that document file for some macros...

Eventually I created a single front-end to handle doing all of these queries in whatever sequence I needed.

See the full readme below for details, but the basic FAQ is that core functions are kept in the 'ncore' folder within the same directory as MACROSS.ps1 (usually on the user's desktop), and all of your custom powershell scripts, when dropped into the 'nmods' folder, will automatically become options in the MACROSS menu. If you host a master repo for MACROSS on your network and modify the extras.ps1 file to include its encoded filepath, then any updates you make to your scripts in the 'nmods' folder will automatically get pushed out to your SOC users.

FRAMEWORK RULES (modify however works best for you):
1. All core functions are kept in the "ncore" folder
	<br>1a. Default variables that are used by all the MACROSS tools are base-64 encoded and stored in the opening comments line within "utility.ps1" in the ncore folder. When MACROSS starts up, it grabs those comments and splits them into an array for quick decoding anytime you need them.
	<br>1b. The ncore folder also contains subfolder "py_classes". This folder contains the MACROSS python library "mcdefs.py", and a subfolder called "garbage_io". MACROSS powershell scripts should contain a function that will write values to plaintext "*.eod" files  in garbage_io, so that python scripts can read them. See the "pyCross" function in the utility.ps1 file. 
<br>
2. Custom automation scripts are kept in the "nmods" folder
	<br>&emsp;2a. Custom scripts must contain "#_superdimensionfortress" in the first line, "#_ver " in the second line, and "#_class " in the third line, or they will be ignored. The first line is where you'll write a brief description of your script, which gets displayed in the MACROSS menu. The second line is the version number. For the third line with "#_class", please review the \ncore\classes.ps1 file to see what kind of attributes need to be placed there. 
	<br>&emsp;2b. Custom python scripts are always passed 6 arguments by default (see the availableMods function in "validation.ps1") so that they can share MACROSS' default values.
	<br>&emsp;2c. MACROSS ignores python scripts if Python3 isn't installed
<br>
3. All core variables (when possible) are named beginning "$vf19_" to control cleanup
	<br>&emsp;3a. For the same reason, custom variables (when possible) should be named beginning with "$dyrl_"
	<br>&emsp;3b. Shared variables that get passed from one script to another for processing include:
		<br>&emsp;&emsp;$PROTOCULTURE = the thing being investigated (A file, a value, a username, etc)
		<br>&emsp;&emsp;$CALLER = the name of the script calling functions in another
		<br>&emsp;&emsp;$HOWMANY = the number of successful results being tracked between scripts
		<br>&emsp;&emsp;$RESULTFILE = the path to any output your script generates that can be processed by another script
<br>		
4. Files used for enrichment across multiple scripts (xml, json, txt) are kept in the "resources" folder
	<br>&emsp;4a. This folder is currently in the MACROSS root folder, but can be placed anywhere you want
<br>
5. At the top of the utility.ps1 file, you'll find a block of base64 encoded strings. These are default values used for MACROSS and its scripts. Changing or adding your own defaults involves base64-encoding your value and adding a three-letter ID to the front of it, and separating each value with "@@@". At startup, MACROSS will strip the "@@@" delimiters, and create a hashtable ($vf19_MPOD) of your values using the three-letter ID as an index so that you can grab and decode them as needed.  Example:<br><br>

&emsp; `getThis $vf19MPOD['abc'] # This will decode the value you've tagged as "abc" and store it as $vf19_READ`

<br>
<br>
6. MACROSS handles many functions common to what your scripts will likely be doing. Some examples:
<br>
	Do you output results to file? The "houseKeeping" function will remind you if old reports exist and delete them for you if you choose. Need your user to specify a document or file to analyze? The "getFile" function will open a dialog for them to quickly select it. Need to see if an odd string can decode from Base64 or hexadecimal, or maybe you want to grab the hash of a file? "getThis" can decode base64 and hex, while "getHash" will give you an md5 or sha256 signature for any file you want. Check out the docs for more --- and use MACROSS to automate your SOC automations!

