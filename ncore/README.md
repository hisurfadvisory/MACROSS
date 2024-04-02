## CUSTOMIZING THE CORE FUNCTIONS FOR YOUR ENVIRONMENT

<b><u>ADDING SCRIPTS AND CONFIGURING MACROSS</u></b><br>
TL;DR -- To reiterate the main Macross README -- MACROSS isn't so much a toolset as it is a standardized scheme (we'll call it a "Framework" because buzzwords) to help you connect unrelated scripts together in any way that seems natural or relevant to the everyday tasks in your SOC. <u>Its primary goal is to speed up the gathering of common info from Active Directory and any tools that have command-line APIs you already make use of</u>. Look up a host, or a username, or a filename, then extract any related data that is relevant to your investigation. Run the DEMO options from the menu in MACROSS (Hikaru and Minmay) to see a demonstration of how the scripts talk to each other to enrich gathered data.


MACROSS.ps1  = execute this to start MACROSS

\core folder = contains all of MACROSS' core functions; you shouldn't need to change much in here<br>
\modules folder = put your automation scripts in here<br>
\resources folder = put any enrichment or config files you want in here (json, xml, etc.); I recommend you place this in an alternate, access-controlled location and modify the temp_config.txt file with the new location.<br>



The first three lines of your automation script requires these:<br>

	#_sdf1   <BRIEF DESCRIPTION OF YOUR SCRIPT>
	#_ver    <VERSION NUMBER OF YOUR SCRIPT>
	#_class  <COMMA-SEPARATED ATTRIBUTES OF YOUR SCRIPT>

	The "sdf1" line needs a brief description of your script; this gets written to the MACROSS menu
	The "ver" line is the version of your script
	The "class" line needs you to comma-separate these attributes, in order:
		1. The LOWEST privilege level your script requires (user, admin, etc.)
		2. If you have different levels of analysts, use this for access control (Tier 1 or "help desk", etc.)
			If not, just put anything in this field. Do NOT leave it blank.
		3. What kind of data your script processes (IPs, filescans, etc.). Keep this uniform across your scripts.
		4. What language your script is (powershell, python)
		5. The author
		6. The maximum number of values your script can process

		Example class line:
		#_class user,tier2,PDFs,powershell,HiSurfAdvisory,1

When all these lines are set correctly, MACROSS uses the [macross] class to keep track of the scripts in the "modules" folder. You can see what these look like by typing "debug TL" in the main menu.

For python scripts:<br>
You'll need the argv and path functions from the sys library. MACROSS always passes at least 6 args to any python script it executes (7 if you include the script name). The below example explains how to use them.

	from sys import argv,path
	L = len(argv)
	if L >= 7: 			## make sure MACROSS sent all its default values
		mpath = argv[6]  	## MACROSS sends the filepath to the mcdefs.py library
		path.insert(0,mpath) 	## modify the sys path to include the local py_classes folder
		import mcdefs 		## this is the custom MACROSS library

		## The other 5 args always passed in by MACROSS can be used or ignored as you like.
  		## In order, they are:

		USR = argv[1] 		## The logged-in user $USR
		atts = argv[2] 		## The $vf19_ATTS hashtable attributes .name and .valtype for each script,
 					## but you'll need to use "mcdefs.getATTS(atts)" to actually import this
					## as a dictionary in python.
		vf19_DEFAULTPATH = argv[3]  	## USR's desktop filepath
		vf19_PYPOD = argv[4]        	## The encoded array of filepaths/URLs generated from temp_configs.txt
		N_ = argv[5]                	## The integer MACROSS uses for common math functions in all the scripts
		M_ = mcdefs.makeM(N_)        	## This function splits the N_ value into 6 digits you can use for mathing
		vf19_TOOLSROOT = argv[7]    	## The path to the MACROSS folder
		GBG = argv[6] + '\\garbage_io'  ## Path to the garbage I/O folder.

GBG is a folder your python scripts can write outputs into if you want them available for later use in your MACROSS session. This folder gets cleared out every time MACROSS exits.



<b><u>HOW TO CONFIGURE GLOBAL DEFAULTS:</u></b><br>
-Lines 130 and 133 in "core/display.ps1" point to a file called "core/temp_config.txt". This file contains a block of base64-encoded strings separated with "@@@" delimiters. These base64 values are default values that will be needed by various MACROSS tools, for instance URLs, IP addresses, filepaths, etc., that your scripts may need to access at any given time.
	
Each of these strings begins with three letters that are not part of the string. MACROSS strips these letters and uses them as keys, with the base64 string being the value. All of these strings are kept in a hashtable called "$vf19_MPOD", and your scripts can decode them by sending the key to the "getThis" function (detailed later on), which returns the plaintext value to you in "$vf19_READ":

		getThis $vf19_MPOD['abc']; $vf19_READ

To set your defaults here, encode the value in base64, choose a 3-letter key to put in front of it, and add it to the last line of the block in "temp_config.txt", separating it from the rest with a new "@@@". 

Note that the keys 'nre', 'tbl', and 'log' are reserved for MACROSS use. These point to your master MACROSS repo, MACROSS resources folder, and MACROSS logs folder respectively. You can change these values, but MACROSS will always assume they are pointing to those locations, and functions will break if they are not used for those purposes!

I also suggest you use something other than "temp_config.txt" in a central location you control. If you do create a different file, make sure to modify line 130 and 133 in "display.ps1"! 
	
This is NOT for security. Do <u>not</u> put credentials in here. The purpose of this file is to store not-quite sensitive values in a way that avoids scanners, while also letting you write your scripts without hardcoding things like IP addresses into them. For example, if your script is accessing an API, instead of hardcoding a URL, you can simply do

	curl -X GET $(getThis $vf19_MPOD['abc']; $vf19_READ)
	
and then modify the temp_config (or whatever file you use) with updated addresses as needed. The "getThis" function can base64-encode strings for you if you just need to do a few. From the main MACROSS menu, simply type "debug" followed by your command. To encode, pass in 0 as the second parameter:

	debug getThis 'hello world' 0

-The file "core/validation.ps1" contains a function at line 199 called "setUser". If your environment uses active directory to set permissions, AND you enforce code-signing, review this function to see how you can use it to restrict MACROSS use to only your SOC users. This is especially important if you will be adding API scripts to MACROSS. You don't want random users to be able to query your firewalls or endpoint agents.

-Unfortunately, MACROSS does not provide a way for you to handle API keys. I think it's best for everyone to come up with their own way rather than have one method in MACROSS that could be ripped apart and exploited by people much smarter than me. Just don't hardcode them anywhere, and don't store them in the temp_config file, please.

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

Or call it with a plaintext value as the first parameter, and 0 as the second parameter to get the Base64 value.
    
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
	&emsp;<b>B.</b> screenResults() = This is a cosmetic feature that lets you present your script's results in a pre-formatted manner on screen. Call this function with 1 required parameter (plus 2 optional) to print a table. Additionally, if you have need to highlight a value, attach a color to it with a "~" symbol, as below:<br>
	Usage:<br>
	
	# This displays your results in 3 columns like a spreadsheet
	foreach($i in someFunction){ screenResults $result_name "red~$result_value" $optional_value }
	screenResults 'endr'
	
The second parameter above, "red~$result_value", will print $result_value in red-colored text. At the end of printing your results, call the function again with a single parameter 'endr', to write a closing "row" separator at the bottom of the table. Example output:<br>

	‖≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡‖
	║ HOST 1                 ║ Windows 11                ║ Patched                             ║
	‖≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡‖
	║                        ║                           ║ Not patched; your outputs can be    ║
	║ HOST 2                 ║ Windows 10                ║ longer than the columns, they will  ║
	║                        ║                           ║ automatically be wrapped to fit.    ║
	‖≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡‖
	║ HOST 3                 ║ Windows 10                ║ Patched                             ║
	‖≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡‖

<br>
	&emsp;<b>B.</b> screenResultsAlt() = This is an alternate format to display your outputs, meant for simpler results. Call this function with same parameters as screenResults to print a list (don't forget to use 'endr' to close your list, and add a "color~" to highlight interesting results).<br>
 
	Usage with example output:

 	foreach($i in someFunction){ screenResultsAlt $result_name $result_value $optional_value; screenResultsAlt 'endr' }

	## Outputs to:
	║║║║║║ HOST 1
	============================================================================
	Windows 11     ║  Patched
	============================================================================
	║║║║║║ Host 2
	============================================================================
	Windows 10     ║  Not Patched
	============================================================================
	║║║║║║ HOST 3
	============================================================================
	Windows 10     ║  Patched
	============================================================================
  
 <br>
	&emsp;<b>C.</b> slp() = Sleep function; provide it the number of seconds you want your script to pause; pass 'm' as a second param to use milliseconds.<br>
 
	Usage:
	slp 2   # This pauses your script for 2 seconds
<br>
	&emsp;<b>D.</b> startUp() = This is the first function to run when MACROSS loads. It sets many of the default variable values, and checks to see if programs like wireshark are installed. It sets these values to $true for your scripts to be aware of (and you can add other checks as necessary for other installed software):<br>
	&emsp;&emsp;$MONTY = python3 is installed<br>
	&emsp;&emsp;$SHARK = wireshark is installed<br>
	&emsp;&emsp;$MAPPER = nmap is installed<br>
<br>
<br>
	&emsp;<b>E.</b> chooseMod() = This function builds the main menu screen in MACROSS. It reads the contents of the modules folder, strips out file extensions, and creates hashtables using the script names and the descriptions found in the first line of those scripts. If the startUp() function did not detect python, chooseMod() will only look for scripts ending in ".ps1" or ".psm" and ignore any ".py".<br>
<br>
	&emsp;<b>F.</b> scrollPage() = If you have more than 9 scripts in your modules folder, a second "page" will be created in chooseMods().
	The scrollPage() function is then used to switch between them when the user types 'p' into the main menu. At the moment this is limited to 2 pages, someday I'll update in case more are needed.<br>
	
<br>
<br>
<b>II. validation.ps1</b><br>
	&emsp;<b>A.</b> varCleanup() = Everytime a script exits and returns to the MACROSS menu, this function clears out the shared variables* to make sure they're ready to use with the next script<br>
	&emsp;&emsp;<i>* the global $PROTOCULTURE value, which is the value all scripts look for as the IOC or element to investigate, does not get cleared until you do it manually from the menu, or you exit MACROSS. Be careful, as one of the framework's guidelines is to write your scripts so that they automatically act on, or at least are aware of, the existence of $PROTOCULTURE! You can also uncomment the PROTOCULTURE line in the varCleanup function to have it cleared every time the main menu loads, if you prefer.</i><br>
<br>
	&emsp;<b>B.</b> getThis() = This function will decode Base64 and Hexadecimal strings, and can encode plaintext to base64. Call it with your encoded string as the first param.vLeave the second param empty if decoding base64; if you are decoding hexadecimal you must pass it a '1' as yourvsecond param. The decoded value gets stored as <i>$vf19_READ</i>.<br>
	
	getThis $base64_string
	write-host $vf19_READ
	
	getThis $hex_string 1
	write-host $vf19_READ
	
Writing plaintext values to $vf19_READ makes cleanup actions easier, as this value gets cleared every time the main menu loads. Alternatively, if you pass a plaintext string as your first parameter, with '0' as your second param, getThis() will return a Base64-encoded value (it will NOT get stored in $vf19_READ!).<br>
	
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
	&emsp;<b>F.</b> setUser() = Attempts two different methods to set the logged in user as global $USR. If the system or active-directory method fails, it will default to using "whoami" and also set the global value $vf19_ROBOTECH, which tells all the MACROSS scripts that the user does not have elevated privilege. (Of course, that assumes your IT managers don't allow standard users to run Get-AD cmdlets!) This way you can write checks to avoid loading different functions unnecessarily.<br>
<br>
	&emsp;<b>G.</b> collab() = This is the function that allows your scripts to talk to each other. It must be called with (1) the name of the script you
	want to "collaborate" with in the modules folder, and (2) the name of the script making the call, WITHOUT the file extension.
	Your script should already be setting the global values for <i>$RESULTFILE</i> and <i>$PROTOCULTURE</i> as necessary, but this
	function does allow for passing another optional value if needed. That value will be set as <i>$eNM</i> and passed along as a separate
	param to the script you're calling.<br>
<br>
	If you are calling a python script, up to 9 values (6 required defaults, 2 situational, 1 optional) will be passed along as arguments that can be parsed using the sys.argv library in your python script:<br>
	&emsp;&emsp;1. the username<br>
	&emsp;&emsp;2. the user's desktop path<br>
	&emsp;&emsp;3. the $vf19_MPOD hashtable that MACROSS uses to store default filepaths<br>
	&emsp;&emsp;4. the $vf19_numchk integer for mathing<br>
	&emsp;&emsp;5. the filepath to the MACROSS python library (core\pyclasses)<br>
	&emsp;&emsp;6. the path to the MACROSS root folder<br>
	&emsp;&emsp;7. the name of the script making the call<br>
	&emsp;&emsp;8. the $PROTOCULTURE value being evaluated<br>
	&emsp;&emsp;9. (optional) the $eNM value being evaluated<br>
	<br>
	&emsp;&emsp;Usage:
	
	collab 'Otherscript.ps1' 'Myscript' $var0

^^ Calls Otherscript.ps1, tells it 'Myscript' is sending $var0 for evaluation. Otherscript.ps1 can then evaluate both $PROTOCULTURE and $var0, or just $var0.<br>

	collab 'Anotherscript.py' 'Myscript'

^^ Calls Anotherscript.py, tells it 'Myscript' is the caller. Because it's calling a python script, the <b>collab</b> function will automatically add the first seven args mentioned above. Assuming your script generated a global $PROTOCULTURE value, that will also be passed as an arg to python. See also the 'pyCross' and 'cleanGBIO' functions down below in the utility.ps1 section for further python integration info.<br>
<br>
	&emsp;<b>J.</b> availableMods() = When a user selects a script from the MACROSS menu, the chooseMods() function sends their selection to availableMods()
	where the filepath to the script gets verified, along with the script version using the verChk() function (see the
	updates.ps1 file). As with the collab() function, availableMods() will automatically send some default arguments to python scripts.<br>
	
<br>
<br>
<b>III. updates.ps1</b><br>
<i>*** To use verChk & dlNew, you must first set a central repo for your master copies, either your gitlab or a fileshare or something, and set the location of your repo as a base64-encoded string prepended with "nre" in the temp_config.txt comment section. Even if you are not managing a MACROSS repo, this file and its functions are required by MACROSS for local management.***</i><br>
<br>
&emsp;<b>A.</b> toolCount() = This function counts the number of scripts in the local modules folder vs. the number in your master repository. It then reads the first three lines of each script to get its attributes, and uses that info to create macross objects that get stored in the $vf19_ATTS hashtable, with the scriptnames as the index keys. See the included scripts in the modules folder for examples of the magic lines described here; the first three lines of your script MUST contain:<br>

	#_sdf1 "This is a brief description of the tool"
	#_ver 1.0
	#_class comma,separated,attributes,for,your,script  # See the classes.ps1 further down
<br>
&emsp;<b>B.</b> look4New() = This relies on the number of scripts <b>toolCount()</b> discovered. If the local count is higher, the update functions 
	will be disabled to avoid problems. If the master count is higher, the dlNew() function will be used to automatically download the scripts that the 
	user is missing.<br>
	&emsp;<b>C.</b> dlNew() = This function gets called when new scripts or newer versions are available, or if the user wants to pull fresh copies from
	the master repo.<br><br>
&emsp;<b>D.</b> verChk() = This function is used every time a script gets selected from the MACROSS menu. It compares the "#\_ver" line in the local
	script and in the master repo script. If the master version is newer, it gets downloaded before the selected script executes.<br>
	
<br>
<br>
<b>IV. utility.ps1</b><br>
&emsp;<b>A.</b> debugMacross() = 'debug' is an unlisted option in the MACROSS menu. Use it to change whether errors are output to the screen or not to troubleshoot scripts (the default is 'SilentlyContinue' to suppress errors). You can also use 'debug' to test commands or variables in your scripts:<br>
	
	debug
	debug screenResults 'Item 1' 'Value 1' 'Optional Value 1'
	
^^ Typing 'debug' in the main menu, you can either open the error message selector, or do things like check what your script's outputs might look like after being sent to the screenResults function.

If you review this function, it contains a "blacklist" that you can edit. As the "debug" command is not restricted in any way, you can add keywords here that will prevent command executions that you don't want performed.

<br>
	&emsp;<b>B.</b> runSomething() = Pauses the MACROSS console and loads a fresh powershell instance so that the user can perform a quick powershell task; users can call this by typing 'shell' into the MACROSS menu. Typing "exit" returns the user to MACROSS.<br>
	&emsp;<b>C.</b> decodeSomething() = From the MACROSS menu, the user can call this by typing 'dec' to quickly decode a simple Base64 or Hex string they may come across in an investigation.<br>
	&emsp;<b>D.</b> getHash() = accepts a filepath and the hash method (md5 or sha256), and returns the hash for
	you. Usage:<br>
	
	$var = getHash $filepath 'md5'
	    
&emsp;<b>E.</b> getFile() = Your script can use this to open a dialog box for users to select a file or directory. Pass an optional argument to <b>1)</b> apply a type-filter to the dialog (it has to match <u>exactly</u> what Windows puts in its selection drop-downs for different file types), or <b>2)</b> send 'folder' to have the user select a folder instead of a file.<br>

	$file1 = getFile 'Microsoft Excel Worksheet (.xlsx) | .xlsx'   # Opens a window that only shows Excel files as choices
 	$folder1 = getFile 'folder'                                    # Opens a window that only shows folders as choices

&emsp;<b>F.</b> houseKeeping() = If your scripts generate file outputs, call this function to offer users the option to delete any or all of these files when they are no longer needed. Usage:<br>
	
	houseKeeping $filepath 'myscriptname' 
	
&emsp;<b>G.</b> cleanGBIO() = The "garbage_io" folder inside of "py_classes" uses .eod files to share outputs from powershell to python. This function ensures the directory gets cleaned out before and after every session. This is a temp fix until the mcdefs library can read-in powershell outputs by default.<br>
	&emsp;<b>H.</b> pyCross() = This is the function your powershell scripts need to call if passing info *back to* a calling python script. Outputs are written to .eod files.  The 'MINMAY' demo script goes into detail on using .eod files<br>
	
&emsp;<b>I.</b> TL() = This function quickly displays all available scripts and their attributes. From the main MACROSS menu, you can use it in <i>debug</i> mode:<br>

	debug TL

<br>
	
<br>
<br>
<b>V. splashes.ps1</b><br>
	&emsp;<b>A.</b> transitionSplash() = This function is purely cosmetic, and allows you to briefly throw some anime ASCII art on screen before launching a script. Type 'splash' in the main menu to cycle through a slideshow of available images.<br><br>

<b>VI. classes.ps1</b><br>
	This file should be reserved for any custom classes your scripts need, especially if they could be useful for other scripts to make use of.<br>
	&emsp;<b>A.</b> macross = A custom powershell class that tags every script in the \modules folder with specific attributes that you MUST include on the third line of your scripts, tagged with "#\_class" so that MACROSS will parse it correctly. In this example:<br>
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

