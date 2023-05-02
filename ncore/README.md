## CUSTOMIZING THE CORE FUNCTIONS FOR YOUR ENVIRONMENT

<b><u>SETTING DEFAULT VARIABLES</u></b><br>
TL;DR -- To reiterate the main Macross README -- MACROSS isn't so much a toolset as it is a standardized scheme (we'll call it a "Framework" because buzzwords) to help you connect unrelated scripts together in any way that seems natural or relevant to the everyday tasks in your SOC. <u>Its primary goal is to speed up the gathering of common info from Active Directory and any tools that have command-line APIs you already make use of</u>. Look up a host, or a username, or a filename, then extract any related data that is relevant to your investigation. Run the DEMO options from the menu in MACROSS (Hikaru and Minmay) to see a demonstration of how the scripts talk to each other to enrich gathered data.


HOW TO CONFIGURE GLOBAL DEFAULTS:
To begin with, the opening comment lines in the utility.ps1 file are reserved for a string of Base64-encoded lines delimited by '@@@'. Additional base64 strings can be inserted into this file's multi-line comment, as long as you prepend it with a three-letter identifier, and separate each base64
value with '@@@'.

For example, let's say you have a security tool that you've written an automation API to run queries in your command line. If you want to modify your API to work in MACROSS, you could base64-encode the IP or URL to your security tool and add it to the lines in utility.ps1 so that everytime MACROSS loads, that URL/IP is ready to POST or QUERY to any time you need it.

I have a couple of my custom scripts included in the github release --MYLENE and KONIG-- which query active directory in environments that use roaming profiles, and so instead of having the fileshare paths sitting in each script, I would just keep them encoded in this comment block until they're needed.

I included this as a way to avoid hardcoding my commonly used values in plaintext. ***This should NOT be used to obscure sensitive details!***
(Also, the better method for this would be to have a restricted web or fileserver that contains a textfile with these base64 values,
and use the utility.ps1 comments for the base64 encoded path to THAT protected file. But you'll need to modify the <b>startUp</b> function in
display.ps1 to do this properly. Remember, obfuscation ATTRACTS everyone on both sides of the infosec yin-yang, Defenders and Attackers alike.)

After encoding your info, which could be filenames/filepaths, GPO membership strings, etc., you add a three-letter identifier to the front
of that string before inserting it into the commented section. I have examples already set in utility.ps1 that you can modify however you need to. I do have two identifiers that are <u>reserved</u> for MACROSS functions, so don't use them for anything else:<br>
	&emsp;&emsp;nre = location of the master MACROSS repo (it is currently set to the same location as your local MACROSS root)<br>
	&emsp;&emsp;tbl = location of the resources folder, I typically stored common txt, xml or json files here. (this is also currently in the MACROSS root, though you might consider changing the location to something more accessed-controlled. It's up to you).<br>

These commented Base64 strings get read into the <b>startUp</b> function in the display.ps1 file, which splits your encoded block into their individual
values by removing the '@@@' delimiters. <b>startUp</b> then reads your three-character identifier at the front of each Base64 value, and uses those characters as the index-key for a global array, <i>$vf19_MPOD</i>.

Anytime one of your scripts needs to decode a specific value, you can call the <b>getThis</b> function (in the validation.ps1 file) with
your <i>$vf19_MPOD</i>['key']. The plaintext result is written to <i>$vf19_READ</i>, which gets overwritten every time the function is called. You may only need to use $dash_READ once, but if you need it persistently, you'll need to set it with another variable name:

    getThis $vf19_MPOD['abc']
    $my_var = $vf19_READ
    


<br>
<br><br>
<b><u>DECODING STORED VALUES</u></b><br>
The <b>getThis</b> function doesn't disappear after startup, it can continue decoding Base64 and Hexadecimal for you as long as MACROSS is running. The decoded plaintext gets written to <i>$vf19_READ</i> which you must store as something else before using <b>getThis</b> again:<br><br>

    getThis $b64_value
    $myVar = $vf19_READ
<br>    
Call it with '1' as a second parameter if you're decoding hex:<br><br>

    getThis $hex_value 1
    $myVar = $vf19_READ
    
Decoding is also offered as an option in the MACROSS menu for the occasional obfuscated string that doesn't require full-blown CyberChef to decode in your investigation of events.<br>

There are several similar functions in the utility.ps1 file that are available to all your scripts to hopefully make life a little easier. (Details toward the end of this page)<br>

<b>FINALLY...</b><br>
To further customize and modify these core functions to your liking, see the comments in each .ps1/.py file and the README below.<br>
<br>
<br>


<b>ALL CORE FUNCTIONS IN DETAIL</b>

<b>I. display.ps1</b><br>
	&emsp;<b>A.</b> splashPage() = a cosmetic function for the MACROSS menu<br>
<br>
	&emsp;<b>B.</b> screenResults() = This is a cosmetic feature that lets you present your script's results in a pre-formatted manner
	on screen. Call this function with 2 required parameters (plus 1 optional) to print a table:<br>
	Usage:<br>
	
	# This displays your results in 3 columns like a spreadsheet
	foreach($i in someFunction){ screenResults $result_name $result_value $optional_value }
	screenResults 0
	
At the end of printing your results, call the function again with a single parameter (can be any value) to write a closing bar at the bottom of the table. Example output:<br>

	‖≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡‖
	║ HOST 1                 ║ Windows 11                ║ Patched                             ║
	‖≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡‖
	║ HOST 2                 ║ Windows 10                ║ Not patched                         ║
	‖≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡‖
	║ HOST 3                 ║ Windows 10                ║ Patched                             ║
	‖≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡‖

<br>
	&emsp;<b>C.</b> slp() = Sleep function; provide it the number of seconds you want your script to pause<br>
	Usage:<br>
	
	slp 2   # This pauses your script for 2 seconds
<br>
	&emsp;<b>D.</b> startUp() = This is the first function to run when MACROSS loads. It sets many of the default variable values, and
	checks to see if programs like wireshark are installed. It sets these values to $true for your scripts to be aware of (and you
	can add other checks as necessary for other installed software):<br>
	&emsp;&emsp;$MONTY = python3 is installed<br>
	&emsp;&emsp;$SHARK = wireshark is installed<br>
	&emsp;&emsp;$MAPPER = nmap is installed<br>
<br>
<br>
	&emsp;<b>E.</b> chooseMod() = This function builds the main menu screen in MACROSS. It reads the contents of the nmods folder, strips
	out file extensions, and creates hashtables using the script names and the descriptions found in the
	first line of those scripts. If the startUp() function did not detect python, chooseMod() will only look
	for scripts ending in ".ps1" or ".psm" and ignore any ".py".<br>
<br>
	&emsp;<b>F.</b> scrollPage() = If you have more than 9 scripts in your nmods folder, a second "page" will be created in chooseMods().
	The scrollPage() function is then used to switch between them when the user types 'p' into the main menu.<br>
	
<br>
<br>
<b>II. validation.ps1</b><br>
	&emsp;<b>A.</b> varCleanup() = Everytime a script exits and returns to the MACROSS menu, this function clears out the shared variables*
	to make sure they're ready to use with the next script<br>
	&emsp;&emsp;<i>* the global $PROTOCULTURE value, which is the value all scripts look for as the IOC or element to investigate, does not get cleared
	until you do it manually from the menu, or you exit MACROSS. Be careful, as one of the framework's guidelines is to write your scripts so that they 
	automatically act on, or at least are aware of, the existence of $PROTOCULTURE!</i><br>
<br>
	&emsp;<b>B.</b> getThis() = This function will decode Base64 and Hexadecimal strings. Call it with your encoded string as the first param.
	Leave the second param empty if decoding base64; if you are decoding hexadecimal you must pass it a '1' as your
	second param. The decoded value gets stored as <i>$vf19_READ</i>.<br>
	
	getThis $base64_string
	write-host $vf19_READ
	
	getThis $hex_string 1
	write-host $vf19_READ
	
 Alternatively, if you pass a plaintext string as your first parameter, with '0' as your second param, getThis() will return a Base64-encoded value.<br>
	
	$encodedstr = getThis 'plaintext string of whatever' 0
	
<br>
	&emsp;<b>C.</b> SJW() = This function checks the user's privilege, which is determined in the setUser() function. Call it from your scripts to automatically alert MACROSS users that they may not have the required privilege to continue.<br>
	&emsp;Usage:<br>
	
	SJW 'pass'  # Notifies user some functions will not work
	SJW 'deny  # Notifies user they need elevated privileges, then kills the script
	
<br>
	&emsp;<b>D.</b> $vf19_M = This takes the $vf19_numchk value from MACROSS.ps1, and splits into 6 individual integers that can be used for mathing, like building an IP or hex value that you don't want resting in plaintext (again, not secure, don't use it as such).<br>
	&emsp;&emsp;Example usage:
	
	$var = $vf19_M[2] + $vf19_M[0]
	
<br>
	&emsp;<b>E.</b> errMsg() = This function contains various error messages that can be reused across scripts. Change or add new messages however you
	need.<br>
	&emsp;&emsp;Usage:
	
	errMsg 3 # Displays whichever message is in the third slot
	
<br>
	&emsp;<b>F.</b> setUser() = Attempts two different methods to set the logged in user as global $USR. If the system or active-directory method fails, it will default to using "whoami" and also set the global value $vf19_GAVIL, which tells all the MACROSS scripts that the user does not have elevated privilege. (Of course, that assumes your IT managers don't allow standard users to run Get-AD cmdlets!) This way you can write checks to avoid loading different functions unnecessarily.<br>
<br>
	&emsp;<b>G.</b> collab() = This is the function that allows your scripts to talk to each other. It must be called with (1) the name of the script you
	want to "collaborate" with in the nmods folder, and (2) the name of the script making the call, WITHOUT the file extension.
	Your script should already be setting the global values for <i>$RESULTFILE</i> and <i>$PROTOCULTURE</i> as necessary, but this
	function does allow for passing another optional value if needed. That value will be set as <i>$eNM</i> and passed along as a separate
	param to the script you're calling.<br>
<br>
	If you are calling a python script, up to 9 values (6 required defaults, 2 situational, 1 optional) will be passed along as arguments that can be parsed using the sys.argv library in your python script:<br>
	&emsp;&emsp;1. the username<br>
	&emsp;&emsp;2. the user's desktop path<br>
	&emsp;&emsp;3. the $vf19_MPOD hashtable that MACROSS uses to store default filepaths<br>
	&emsp;&emsp;4. the $vf19_numchk integer for mathing<br>
	&emsp;&emsp;5. the filepath to the MACROSS python library (ncore\pyclasses)<br>
	&emsp;&emsp;6. the path to the MACROSS root folder<br>
	&emsp;&emsp;7. the name of the script making the call<br>
	&emsp;&emsp;8. the $PROTOCULTURE value being evaluated<br>
	&emsp;&emsp;9. (optional) the $eNM value being evaluated<br>
	<br>
	&emsp;&emsp;Usage:
	
	collab 'Otherscript.ps1' 'Myscript' $var0

^^ Calls Otherscript.ps1, tells it 'Myscript' is sending $var0 for evaluation. Otherscript.ps1 can then evaluate both $PROTOCULTURE and $var0, or just $var0.<br>

	collab 'Anotherscript.py' 'Myscript'

^^ Calls Anotherscript.py, tells it 'Myscript' is the caller. Because it's calling a python script, the <b>collab</b> function will automatically add the first seven args mentioned above. Assuming your script generated a global $PROTOCULTURE value, that will also be passed as an arg to python.<br>
<br>
	&emsp;<b>J.</b> availableMods() = When a user selects a script from the MACROSS menu, the chooseMods() function sends their selection to availableMods()
	where the filepath to the script gets verified, along with the script version using the verChk() function (see the
	updates.ps1 file). As with the collab() function, availableMods() will automatically send some default arguments to
	python scripts.<br>
	
<br>
<br>
<b>III. updates.ps1</b><br>
<i>*** To use verChk & dlNew, you must first set a central repo for your master copies, either your gitlab or a fileshare or something, and set the location of your repo as a base64-encoded string prepended with "nre" in the utility.ps1 comment section***</i><br>
	&emsp;<b>A.</b> toolCount() = This function counts the number of scripts in the local nmods folder vs. the number in your master repository. It then reads the first three lines of each script to get its attributes, and uses that info to create macross objects that get stored in the $vf19_ATTS hashtable, with the scriptnames as the index keys. See the included scripts in the nmods folder for examples of the magic lines described here; the first three lines of your script MUST contain:<br>
	
	#_superdimensionfortress "This is a brief description of the tool"
	#_ver 1.0
	#_class comma,separated,attributes,for,your,script  # See the classes.ps1 further down
	
&emsp;<b>B.</b> look4New() = This relies on the number of scripts <b>toolCount()</b> discovered. If the local count is higher, the update functions 
	will be disabled to avoid problems. If the master count is higher, the dlNew() function will be used to automatically download the scripts that the 
	user is missing.<br>
	&emsp;<b>C.</b> dlNew() = This function gets called when new scripts or newer versions are available, or if the user wants to pull fresh copies from
	the master repo.<br>
&emsp;<b>D.</b> verChk() = This function is used every time a script gets selected from the MACROSS menu. It compares the "#\_ver" line in the local
	script and in the master repo script. If the master version is newer, it gets downloaded before the selected script executes.<br>
	
<br>
<br>
<b>IV. utility.ps1</b><br>
	*** The comments section of this file contains base64-encoded values that are used to populate the $vf19_MPOD hashtable; values can be decoded and used by referencing thier index, like
	
	getThis $vf19_MPOD["nre"]
	
&emsp;<b>A.</b> debugMacross() = 'debug' is an unlisted option in the MACROSS menu. Use it to change whether errors are output to the screen or not
	to troubleshoot scripts. You can also use debug to test commands or variables in your scripts:<br>
	
	debug
	debug myFunction $var1
	
^^ Typing 'debug' in the main menu, you can either open the error message selector, or do things like check if your script's "myFunction" parses $var1 correctly.<br>
	&emsp;<b>B.</b> runSomething() = Pauses the MACROSS console and loads a fresh powershell instance so that the user can perform a quick powershell task; users can call this by typing 'shell' into the MACROSS menu. Typing "exit" returns the user to MACROSS.<br>
	&emsp;<b>C.</b> decodeSomething() = From the MACROSS menu, the user can call this by typing 'dec' to quickly decode a Base64 or Hex string they may come across in an investigation.<br>
	&emsp;<b>D.</b> getHash() = accepts a filepath and the hash method (md5 or sha256), and returns the hash for
	you. Usage:<br>
	
	$var = getHash $filepath 'md5'
	    
&emsp;<b>E.</b> getFile() = Your script can use this to open a dialog box for users to select a file. Pass an optional argument to apply a type-filter to the dialog; it has to match <u>exactly</u> what Windows puts in its selection drop-downs for different file types.<br>

	$file1 = getFile 'Microsoft Excel Worksheet (.xlsx) | .xlsx'   # Opens a window that only shows Excel files as choices

&emsp;<b>F.</b> houseKeeping() = If your scripts generate file outputs, call this function to offer users the option to delete any or all of these files when they are no longer needed. Usage:<br>
	
	houseKeeping $filepath 'myscriptname'
	
&emsp;<b>G.</b> cleanGBIO() = The "garbage_io" folder inside of "py_classes" uses .eod files to share info from powershell to python. This function ensures the directory gets cleaned out before and after every session. This is a temp fix until the mcdefs library can read-in powershell outputs by default.<br>
	&emsp;<b>H.</b> pyCross() = This is the function your powershell scripts need to call if passing info *back to* a calling python script. Outputs are written to .eod files.
	
&emsp;<b>H.</b> TL() = This function quickly displays all available scripts and their attributes. From the main MACROSS menu, you can use it in <i>debug</i> mode:<br>

	debug TL

<br>
	
<br>
<br>
<b>V. splashes.ps1</b><br>
	&emsp;<b>A.</b> transitionSplash() = This function is purely cosmetic, and allows you to briefly throw some anime ASCII art on screen before launching a script.<br><br>

<b>VI. classes.ps1</b><br>
	This file should be reserved for any custom classes your scripts need, especially if they could be useful for other scripts to make use of.<br>
	&emsp;<b>A.</b> macross = A custom powershell class that tags every script in the \nmods folder with specific attributes that you MUST include on the third line of your scripts, tagged with "#\_class" so that MACROSS will parse it correctly. In this example:<br>
	<br>
	`#_class  User,syslogs,Python3,SuzyQ,1`
	<br>
	The first value <b>User</b> is the .priv attribute, or the level of privilege required to run your script (will typically be User vs. Admin). Next, the <b>syslogs</b> value will be assigned to the .valtype attribute, describing what kind of data your script processes/returns, or what kind of actions it performs. The third value, <b>Python3</b>, is the .lang attribute while the fourth, <b>SuzyQ</b>, is the .author attribute. Finally, "<b>1</b>" is the .evalmax attribute, which is the maximum number of parameters that your script can accept for processing. The attributes tracked in this class are:<br>
	
	.name
	.priv
	.valtype
	.lang
	.author
	.evalmax
	
<br>
This is used for:<br>
	&emsp;&emsp;-controlling which scripts get pushed to your analysts when you are using a master repository to centrally maintain MACROSS<br>
	&emsp;&emsp;-allowing you to write functions that automatically know what scripts can accept what types of values for auto-evaluating:<br>
	&emsp;&emsp;for example,
	
	$vf19_ATTS.keys | where{ $vf19_ATTS[$_].valtype -like '*json*' }
	
&emsp;&emsp;might be used to autoquery scripts that parse or generate JSON files.<br><br>
&emsp;&emsp;Calling the script name from the hashtable will give you all its attributes. The <b>toolInfo()</b> method will prettify the output, or you can just view it raw:<br>
	
	$vf19_ATTS['MINMAY'].toolInfo()
	  MACROSS: MINMAY
	     Version:                     0.1
	     Author:                      HiSurfAdvisory
	     Evaluates:                   demo script
	     Privilege required:          User
	     Language:                    Python 3
	     Max # of simultaneous evals: 2
	
	[macross]$vf19_ATTS['MINMAY']
	name    : MINMAY
	priv    : User
	valtype : demo script
	lang    : Python 3
	author  : HiSurfAdvisory
	evalmax : 2
	ver     : 0.1
	
<br>
&emsp;&emsp;If you use the MACROSS debug command from the main menu, you can pull all this info at once with the TL funtion:

	debug TL
<br>
<br>
<b>VII. py_classes\mcdefs.py</b><br>
	&emsp;<b>A.</b> This is a python library that provides many of the same core functions used in the MACROSS powershell scripts, as well a "getDefaults" function that will convert MACROSS' $vf19_MPOD hashtable into a python dictionary. See the mcdefs file comments for more details.


