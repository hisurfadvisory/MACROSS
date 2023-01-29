## CUSTOMIZING THE CORE FUNCTIONS FOR YOUR ENVIRONMENT

<b><u>SETTING DEFAULT VARIABLES</u></b><br>
TL;DR -- To reiterate the main README -- MACROSS isn't so much a toolset as it is a standardized scheme (we'll call it a "Framework" because buzzwords) to help you connect unrelated scripts together in any way that seems natural or relevant to the everyday tasks in your SOC. Run the DEMO options from the menu in MACROSS (Hikaru and Minmay) to see a demonstration of how the scripts talk to each other to enrich gathered data.


HOW TO CONFIGURE GLOBAL DEFAULTS:
To begin with, the opening comment lines in the utility.ps1 file are reserved for a string of Base64-encoded lines delimited by '@@@'. Additional base64 strings can be inserted into this file's multi-line comment, as long as you prepend it with a three-letter identifier, and separate each base64
value with '@@@'.

For example, let's say you have a security tool that you've written an automation API to run queries in your command line. If you want to modify your API to work in MACROSS, you could base64-encode the IP or URL to your security tool and add it to the lines in utility.ps1 so that everytime MACROSS loads, that URL/IP is ready to grab any time you need it.

I have a couple of my custom scripts included in the github release --MYLENE and KONIG-- which query active directory in environments that use roaming profiles, and so instead of having the fileshare paths sitting in each script, I just keep them encoded in this comment block until they're needed.

I wrote this as a way to avoid hardcoding my commonly used values in plaintext. ***This should NOT be used to obscure sensitive details!***
(Also, the better method for this would be to have a restricted web or fileserver that contains a textfile with these base64 values,
and use the utility.ps1 comments for the base64 encoded path to THAT protected file. But you'll need to modify the <b>startUp</b> function in
display.ps1 to do this properly. Remember, obfuscation ATTRACTS everyone on both sides of the infosec yin-yang, Defenders and Attackers alike.)

After encoding your info, which could be filenames/filepaths, GPO membership strings, etc., you add a three-letter identifier to the front
of that string before inserting it into the commented section. I have examples already set in utility.ps1 that you can modify however you need to. I do have two identifiers that are <u>reserved</u> for MACROSS functions, so don't use them for anything else:
	nre = location of the master MACROSS repo (it is currently set to the same location as your local MACROSS root)
	tbl = location of the resources folder (this is also currently in the MACROSS root, though you might consider changing the location to something more accessed-controlled. It's up to you).<br>

These commented Base64 lines get read into the <b>startUp</b> function in the display.ps1 file, which splits your encoded block into their individual
values by removing the '@@@' delimiters. <b>startUp</b> then reads your three-character identifier at the front of each Base64 value, and uses those characters as the index-key for a global array, <i>$vf19_MPOD</i>.

Anytime one of your scripts needs to decode a specific value, you can call the <b>getThis</b> function (in the validation.ps1 file) with
your <i>$vf19_MPOD</i>['key']. The decoded string is written to <i>$vf19_READ</i>, which gets overwritten every time the function is called. You may only need to use $dash_READ once, but if you need it persistently, you'll need to set it with another variable name:

    getThis $vf19_MPOD['abc']
    $my_var = $vf19_READ
    


<br>
<br><br>
<b><u>DECODING STORED VALUES</u></b><br>
The <b>getThis</b> function doesn't disappear after startup, it can continue decoding Base64 and Hexadecimal for you as long as MACROSS is running. The decoded plaintext gets written to <i>$vf19_READ</i> which you must store as something else before using <b>getThis</b> again:<br><br>

    getThis $b64_value<br>
    $myVar = $vf19_READ<br>
    
Call it with '1' as a second parameter if you're decoding hex:<br><br>

    getThis $hex_value 1
    $myVar = $vf19_READ
    
Decoding is also offered as an option in the MACROSS menu for the occasional obfuscated string that doesn't require full-blown CyberChef to decode in your investigation of events.<br>

There are several similar functions in the utility.ps1 file that is available to all your scripts to hopefully make life a little easier. (Details toward the end of this page)<br>

<b>FINALLY...</b><br>
To further customize and modify these core functions to your liking, see the comments in each .ps1/.py file and the README below.<br>
<br>
<br>


<b>ALL CORE FUNCTIONS IN DETAIL</b>

<b>I. display.ps1</b><br>
	&emsp;<b>A.</b> splashPage() = a cosmetic function for the MACROSS menu<br>
<br>
	&emsp;<b>B.</b> slp() = Sleep function; provide it the number of seconds you want your script to pause<br>
	Usage:  <i> slp 2</i> &nbsp;&nbsp;## pauses your script for 2 seconds<br>
<br>
	&emsp;<b>C.</b> startUp() = This is the first function to run when MACROSS loads. It sets many of the default variable values, and
	checks to see if programs like wireshark are installed. It sets these values to $true for your scripts to be aware of (and you
	can add other checks as necessary for other installed software):<br>
	&emsp;&emsp;$MONTY = python3 is installed<br>
	&emsp;&emsp;$SHARK = wireshark is installed<br>
	&emsp;&emsp;$MAPPER = nmap is installed<br>
<br>
<br>
	&emsp;<b>D.</b> chooseMod() = This function builds the main menu screen in MACROSS. It reads the contents of the nmods folder, strips
	out file extensions, and creates hashtables using the script names and the descriptions found in the
	first line of those scripts. If the startUp() function did not detect python, chooseMod() will only look
	for scripts ending in ".ps1" or ".psm" and ignore any ".py".<br>
<br>
	&emsp;<b>E.</b> scrollPage() = If you have more than 9 scripts in your nmods folder, a second "page" will be created in chooseMods().
	The scrollPage() function is then used to switch between them.<br>
	
<br>
<br>
<b>II. validation.ps1</b><br>
	&emsp;<b>A.</b> varCleanup() = Everytime a script exits and returns to the MACROSS menu, this function clears out the shared variables*
	to make sure they're ready to use with the next script<br>
	&emsp;&emsp;<i>* the global $PROTOCULTURE value, which is the value all scripts look for as the IOC or element to investigate, does not get cleared
	until you do it manually from the menu</i><br>
<br>
	&emsp;<b>B.</b> getThis() = This function will decode Base64 and Hexadecimal strings. Call it with your encoded string as the first param.
	Leave the second param empty if decoding base64; if you are decoding hexadecimal you must pass it a '1' as your
	second param. The decoded value gets stored as <i>$vf19_READ</i>. Alternatively, if you pass a plaintext string as
	your first parameter, with '0' as your second param, getThis() will write a Base64-encoded value to <i>$vf19_READ</i>.<br>
	&emsp;&emsp;Usage:   <i>getThis $base64_string; write-host $vf19_READ</i><br>
	&emsp;&emsp;OR<br>
	&emsp;&emsp;Hex usage:   <i>getThis $hex_string 1; write-host $vf19_READ</i><br>
<br>
	&emsp;<b>C.</b> SJW() = This function checks the user's privilege, which is determined in the setUser() function. Call it from your scripts to automatically alert MACROSS users that they may not have the required privilege to continue.<br>
	&emsp;Usage:<br>
	&emsp;&emsp;<i>SJW 'pass'</i>  &nbsp;&nbsp;## Notifies user some functions will not work<br>
	&emsp;&emsp;<i>SJW 'deny</i>  &nbsp;&nbsp;## Notifies user they need elevated privileges, then kills the script<br>
<br>
	&emsp;<b>D.</b> $vf19_M = This takes the $vf19_numchk value from MACROSS.ps1, and splits into 6 individual integers that can be used for mathing.<br>
	&emsp;&emsp;Example usage:  <i>$var = $vf19_M[2] + $vf19_M[0]</i><br>
<br>
	&emsp;<b>E.</b> errMsg() = This function contains various error messages that can be reused across scripts. Change or add new messages however you
	need.<br>
	&emsp;&emsp;Usage:  <i>errMsg 3</i>  &nbsp;&nbsp;## Displays whichever message is in the third slot<br>
<br>
	&emsp;<b>F.</b> setUser() = Attempts two different methods to set the logged in user as global $USR. If the system or active-directory method fails, it will default to using "whoami" and also set the global value $vf19_GAVIL, which tells all the MACROSS scripts that the user does not have elevated privilege. This way you can write checks to avoid loading different functions unnecessarily.<br>
<br>
	&emsp;<b>G.</b> collab() = This is the function that allows your scripts to talk to each other. It must be called with (1) the name of the script you
	want to "collaborate" with in the nmods folder, and (2) the name of the script making the call, WITHOUT the file extension.
	Your script should already be setting the global values for <i>$RESULTFILE</i> and <i>$PROTOCULTURE</i> as necessary, but this
	function does allow for passing another value if necessary. It will be set as <i>$eNM</i> and passed along as a separate
	param to the script you're calling.<br>
<br>
	If you are calling a python script, up to 9 values will be passed along as arguments that can be parsed using the sys.argv
	library in your python script:<br>
	&emsp;&emsp;1. the username<br>
	&emsp;&emsp;2. the user's desktop<br>
	&emsp;&emsp;3. the $vf19_MPOD hashtable that MACROSS uses to store default filepaths<br>
	&emsp;&emsp;4. the $vf19_numchk integer for mathing<br>
	&emsp;&emsp;5. the filepath to the MACROSS python library (ncore\pyclasses)<br>
	&emsp;&emsp;6. the filepath to the MACROSS resources folder (you set this in utility.ps1 with the "tbl" key)<br>
	&emsp;&emsp;7. the name of the script making the call<br>
	&emsp;&emsp;8. the $PROTOCULTURE value being evaluated<br>
	&emsp;&emsp;9. (optional) the $eNM value being evaluated<br>
	<br>
	&emsp;&emsp;Usage: <i>collab 'Otherscript.ps1' 'Myscript' $var0</i>  ## Calls Otherscript.ps1, tells it 'Myscript' is sending $var0 for evaluation<br>
<br>
	&emsp;<b>J.</b> availableMods() = When a user selects a script from the MACROSS menu, the chooseMods() function sends their selection to availableMods()
	where the filepath to the script gets verified, along with the script version using the verChk() function (see the
	updates.ps1 file). As with the collab() function, availableMods() will automatically send some arguments to python
	scripts, but only the first 5 listed in collab() along with the string value of $PSScriptRoot so your python scripts
	know where the local files are at.<br>
	
<br>
<br>
<b>III. updates.ps1</b><br>
<i>*** To use verChk & dlNew, you must first set a central repo for your master copies, and set the location of your repo as a base64-encoded string prepended with "nre" in the utility.ps1 comment section***</i><br>
	&emsp;<b>A.</b> toolCount() = This function counts the number of scripts in the local nmods folder vs. the number in the master repository (you set this
	this location in the utility.ps1 file). It then reads the first three lines of each script to get its attributes, and uses that info to create macross objects that get stored in the $vf19_ATTS hashtable, with the scriptnames as the index keys.<br>
	The first three lines of your script MUST contain:<br>
	&emsp;&emsp;#\_superdimensionfortress &emsp;"This is a brief description of the tool"<br>
	&emsp;&emsp;#\_ver &emsp;1.0<br>
	&emsp;&emsp;#\_class &emsp;comma,separated,attributes,for,your,script (see the classes.ps1 file)<br>
	&emsp;<b>B.</b> look4New() = If the local count is higher, the update functions will be disabled to avoid problems. If the master count is higher, the dlNew() function will be used to automatically download the scripts that the user is missing.<br>
	&emsp;<b>C.</b> dlNew() = This function gets called when new scripts or newer versions are available, or if the user wants to pull fresh copies from
	the master repo.<br>
	&emsp;<b>D.</b> verChk() = This function is used every time a script gets selected from the MACROSS menu. It compares the "#_ver" line in the local
	script and in the master repo script. The master version is newer, it gets downloaded before the selected script executes.<br>
	
<br>
<br>
<b>IV. utility.ps1</b><br>
	*** The comments section of this file contains base64-encoded values that are used to populate the $vf19_MPOD hashtable; values can be decoded and used by referencing thier index, like &nbsp;&nbsp;&nbsp;&nbsp;getThis $vf19_MPOD["nre"]<br>
	&emsp;<b>A.</b> debugMacross() = 'debug' is an unlisted option in the MACROSS menu. Use it to change whether errors are output to the screen or not
	to troubleshoot scripts.<br>
	&emsp;<b>B.</b> runSomething() = Pauses the MACROSS console and loads a fresh powershell instance so that the user can perform a quick powershell task; users can call this by typing 'shell' into the MACROSS menu. Typing "exit" returns the user to MACROSS.<br>
	&emsp;<b>C.</b> decodeSomething() = From the MACROSS menu, the user can call this by typing 'dec' to quickly decode a Base64 or Hex string they may come across in an investigation.<br>
	&emsp;<b>D.</b> getHash() = accepts a filepath and the hash method (md5 or sha256), and returns the hash for
	you.<br>
	    &emsp;&emsp;Usage:  &emsp;$var = getHash $filepath 'md5'<br>
	&emsp;<b>E.</b> getFile() = Your script can use this to open a dialog box for users to select a file. Pass an optional arguemt to apply a type-filter to the dialog, e.g. "Microsoft Excel Worksheet (.xlsx) | .xlsx" to only let users select Excel files.<br>
	&emsp;<b>F.</b> houseKeeping() = If your scripts generate file outputs, call this function to offers users the option to delete any or all of these files when they are no longer needed.<br>
	   &emsp;&emsp;Usage:  &emsp;houseKeeping $filepath 'myscriptname'<br>
	&emsp;<b>G.</b> cleanGBIO() = The "garbage_io" folder inside of "py_classes" uses .eod files to share info from powershell to python. This function ensures the directory gets cleaned out before and after every session. This is a temp fix until the mcdefs library can read-in powershell outputs by default.<br>
	&emsp;<b>H.</b> pyCross() = This is the function your powershell scripts need to call if passing info *back to* a calling python script. Outputs are written to .eod files.
	<br><br>
	
<br>
<br>
<b>V. splashes.ps1</b><br>
	&emsp;<b>A.</b> transitionSplash() = This function is purely cosmetic, and allows you to briefly throw some anime ASCII art on screen before launching a script.<br><br>

<b>VI. classes.ps1</b><br>
	This file should be reserved for any custom classes your scripts need, especially if they could be useful for other scripts to make use of.<br>
	&emsp;<b>A.</b> macross = A custom powershell class that tags every script in the \nmods folder with specific attributes that you MUST include on the third line of your scripts, tagged with "#\_class" so that MACROSS will parse it correctly. In this example:<br>
	<br>
	`#_class  User,syslogs,Python3,SuzyQ,1`<br>
	<br>
	The first value <b>User</b> is the .priv attribute, or the level of privilege required to run your script (will typically be User vs. Admin). Next, the <b>syslogs</b> value will be assigned to the .valtype attribute, describing what kind of data your script processes/returns, or what kind of actions it performs. The third value, <b>Python3</b>, is the .lang attribute while the fourth, <b>SuzyQ</b>, is the .author attribute. Finally, "<b>1</b>" is the .evalmax attribute, which is the maximum number of parameters that your script can accept for processing.<br>
	<br>
This is used for:<br>
	&emsp;&emsp;-controlling which scripts get pushed to your analysts when you are using a master repository to centrally store MACROSS<br>
	&emsp;&emsp;-allowing you to write functions that automatically know what scripts can accept what types of values for auto-evaluating:<br>
	&emsp;&emsp;(for example, <i><b>$vf19_ATTS | where{$_.valtype -eq 'json'}</b></i> might be used to autoquery scripts that work with JSON files).<br>
	

<br>
<br>
<b>VII. py_classes\mcdefs.py</b><br>
	&emsp;<b>A.</b> This is a python library that provides many of the same core functions used in the MACROSS powershell scripts, as well a "getDefaults" function that will rebuild MACROSS' $vf19_MPOD hashtable in python. See the mcdefs file 	comments for more details.


