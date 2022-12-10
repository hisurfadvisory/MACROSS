## CUSTOMIZING THE CORE FUNCTIONS FOR YOUR ENVIRONMENT


<b><u>SETTING DEFAULT VARIABLES</u></b><br>
TL;DR -- Run the DEMO options from the menu in MACROSS for a quick overview.

Line 4 in the extras.ps1 file is reserved for a string of Base64-encoded lines delimited by '@@@'. Additional base64 strings can be
inserted into this file's multi-line comment, as long as you prepend it with a three-letter identifier, and separate each base64
value with '@@@'.

I wrote this as a way to avoid hardcoding paths, and values like GPO strings. This should NOT be used to obscure sensitive details!
(Also, the better method for this would be to have a restricted web or fileserver that contains a textfile with these base64 values,
and use line 4 only for the base64 encoded path to THAT protected file. But you'll need to modify the <b>startUp</b> function in
display.ps1 to do this properly.)

After encoding your info, which could be filenames/filepaths, GPO membership strings, etc., add a three-letter identifier to the front
of that string before inserting it into the commented section. I have an example line already set in extras.ps1 that you can modify
however you need to. In general, I reserved these IDs for MACROSS functions:
	nre = location of the master MACROSS repo
	tbl = location of the resources folder
	...and several others in the validation.ps1 files "setUser" function, which is entirely optional and will probably
	be ignored by most people who'd use this framework.

These lines get read into the <b>startUp</b> function in the display.ps1 file, which splits your encoded block into their individual
values by removing the '@@@'. It then reads your three-character identifier at the front of each Base64 value, and uses those characters
as the index-key for a global array, <i>$vf19_TOOLSOPT</i>.

Anytime one of your scripts needs to decode a specific value, you can call the <b>getThis</b> function (in the validation.ps1 file) with
your <i>$vf19_TOOLSOPT</i>['key']. The decoded string is written to <i>$vf19_READ</i>. You need to set your new variable BEFORE <b>getThis</b>
gets called again, because <i>$vf19_READ</i> will get overwritten:

    getThis $vf19_TOOLSOPT['abc']
    $my_var = $vf19_READ
    


<br><br>
<b><u>DECODING STORED VALUES</u></b><br>
The <b>getThis</b> function doesn't disappear after startup, it can continue decoding Base64 and Hexadecimal for you as long
as MACROSS is running! The decoded plaintext gets written to <i>$vf19_READ</i> which you must store as something else before
using <b>getThis</b> again:

    getThis $b64_value
    $myVar = $vf19_READ
    
Call it with '1' as a second parameter if you're decoding hex:

    getThis $hex_value 1
    $myVar = $vf19_READ
    
Decoding is also offered as an option in the MACROSS menu for the occasional obfuscated string that doesn't require full-blown
CyberChef to decode in your investigation of events.



<br><br>
<b><u>SETTING USER RESTRICTIONS</u></b><br>
If you're going to make use of the user-restriction functions, I recommend you remove all the comments from these scripts first.
I also would recommend using more "official" methods to lockdown script use if at all possible; this is admittedly a
hacked-together solution, but it's better than nothing if nothing is what you're given to work with.

REQUIREMENTS: this only works with active-directory that contains unique GPO names for your cybersecurity users. It's also most
effective if your network enforces digital-signing to prevent modifying the code. This, and the obfuscations built into MACROSS,
are primarily intended to keep random users on your network, who may come across your scripts, from using them to perform advanced
data-collections that they wouldn't know how to do on their own (don't feed the insiders). Also, why provide attackers with
custom-built tools that do all the work without them needing to learn your environment and trip all over your detections?

<b>nconsole\ncore\validation.ps1</b><br>
^^This file contains several functions that perform the restriction method. See the file itself for more details.

<b>getHelp1</b>  you do not need to modify anything in this function; it allows your tier 1 users to access the MACROSS toolsets

<b>getHelp2</b>  you do not need to modify anything in this function; it allows your tier 2 & tier 3 users to access automations meant
specifically for them

<b>setUser</b>  You will need to find the Active Directory GPO memberships for your SOC and DFIR analysts, and use a unique pattern from
that membership string. For instance, if your SOC users are in a group like "IT-Security", then you might base64-encode "T-Secu", and add
the 3-letter identifier 'sgu' to it, e.g. "sguVC1TZWN1". You then need to append this and any other encoded GPO strings to line 4+ of
<b>ncore/extras.ps1</b>, separated with '@@@' as described above in the <b>DEFAULT VARIABLES</b> section. Essentially MACROSS will see
this as "sgu = VC1TZWN1" and can decode it to match against a user's GPO.

<b>setUserCt</b>  you do not need to modify anything in this function; it generates a unique permission key based on variables created by <b>setUser</b>

After you've created your encoded GPO strings in extras.ps1, you can make use of permission checks by beginning your custom scripts with this code:

    try{
        getHelp1  ## This check allows all your cybersec analysts to use your script
        getHelp2  ## This check allows ONLY the senior analysts and/or incident-response & forensics investigators to use your script, if they pass the first check
    }
    catch{
        Exit
    }



<b>FINALLY...</b>
To further customize and modify these core functions to your liking, see the comments in each .ps1 file and the README below.



<b>ALL CORE FUNCTIONS IN DETAIL</b>

<b>I. display.ps1</b><br>
	<b>A.</b> splashPage() = a cosmetic function for the MACROSS menu<br>
<br>
	<b>B.</b> transitionSplash() = various Macross ASCII art for certain scripts<br>
<br>
	<b>C.</b> ss() = Sleep function; provide it the number of seconds you want your script to pause<br>
<br>
	<b>D.</b> startUp() = This is the first function to run when MACROSS loads. It sets many of the default variable values, and
	checks to see if programs like python are installed<br>
<br>
	<b>E.</b> chooseMod() = This function builds the main menu screen in MACROSS. It reads the contents of the nmods folder, strips
	out file extensions, and creates hashtables using the script names and the descriptions found in the
	first line of those scripts. If the startUp() function did not detect python, chooseMod() will only look
	for scripts ending in ".ps1" or ".psm" and ignore any ".py".<br>
<br>
	<b>F.</b> scrollPage() = If you have more than 9 scripts in your nmods folder, a second "page" will be created in chooseMods().
	The scrollPage() function is then used to switch between them.<br>
<br>
<br>
<b>II. validation.ps1</b><br>
	<b>A.</b> varCleanup() = Everytime a script exits and returns to the MACROSS menu, this function clears out the shared variables
	to make sure they're ready to use with the next script<br>
<br>
	<b>B.</b> getHelp1() and getHelp2() = These functions are used to control who can run your scripts (see the setUser() function
	below). The intended usage is that you call these functions within a "try" statement, and if
	they fail, your script will exit.<br>
<br>
	<b>C.</b> getThis() = This function will decode Base64 and Hexadecimal strings. Call it with your encoded string as the first param.
	Leave the second param empty if decoding base64; if you are decoding hexadecimal you must pass it a '1' as your
	second param. The decoded value gets stored as <i>$vf19_READ</i>. Alternatively, if you pass a plaintext string as
	your first parameter, with '0' as your second param, getThis() will write a Base64-encoded value to <i>$vf19_READ</i>.<br>
<br>
	<b>D.</b> SJW() = This function checks the user's privilege, which is determined in the setUser() function. It alerts MACROSS users
		   that they may not have the required privilege to run some scripts.<br>
<br>
	<b>E.</b> $vf19_M = This takes the $vf19_numchk value from MACROSS.ps1, and splits into 6 individual integers that can be used for mathing.<br>
<br>
	<b>F.</b> adminChk() = You can use this function in your scripts to either kill the script for non-admins, or prevent certain values/functions
	from loading. Call adminChk() with 'pass' to let the user decide whether to continue with limited functionality, or
	'deny' to kill the script and let the user know they need to be an admin.<br>
<br>
	<b>G.</b> errMsg() = This function contains various error messages that can be reused across scripts. Change or add new messages however you
	need.<br>
<br>
	<b>H.</b> setUser() and setUserCt() = This is a convoluted function that attempts to perform user control if you don't have a better method
	available. See the function comments for the details, but the TLDR is that it reads the user's GPO
	to check for a group membership string that you specify, then creates a random key for that user
	($vf19_SOC for an analyst, $vf19_DFIR for an incident response investigator). Your scripts can then
	use these "keys" to validate user permissions on your scripts using the functions getHelp1() and
	getHelp2().<br>
<br>
	<b>I.</b> collab() = This is the function that allows your scripts to talk to each other. It must be called with (1) the name of the script you
	want to "collaborate" with in the nmods folder, and (2) the name of the script making the call, WITHOUT the file extension.
	Your script should already be setting the global values for <i>$RESULTFILE</i> and <i>$PROTOCULTURE</i> as necessary, but this
	function does allow for passing another value if necessary. It will be set as <i>$eNM</i> and passed along as a separate
	param to the script you're calling.<br>
<br>
	If you are calling a python script, up to 9 values will be passed along as arguments that can be parsed using the sys.argv
	library in your python script:<br>
	1. the username<br>
	2. the user's desktop<br>
	3. the $vf19_MPOD hashtable that MACROSS uses to store default filepaths<br>
	4. the $vf19_numchk integer for mathing<br>
	5. the filepath to the MACROSS python library (ncore\pyclasses)<br>
	6. the filepath to the MACROSS resources folder (you set this in extras.ps1)<br>
	7. the name of the script making the call<br>
	8. the $PROTOCULTURE value being evaluated<br>
	9. (optional) the $eNM value being evaluated<br>
<br>
	<b>J.</b> availableMods() = When a user selects a script from the MACROSS menu, the chooseMods() function sends their selection to availableMods()
	where the filepath to the script gets verified, along with the script version using the verChk() function (see the
	updates.ps1 file). As with the collab() function, availableMods() will automatically send some arguments to python
	scripts, but only the first 5 listed in collab() along with the string value of $PSScriptRoot so your python scripts
	know where the local files are at.<br>
<br>
<br>
<b>III. updates.ps1</b><br>
	<b>A.</b> toolCount() = This function counts the number of scripts in the local nmods folder vs. the number in the master repository (you set this
	this location in the extras.ps1 file).<br>
	<b>B.</b> look4New() = If the local count is higher, the update functions will be disabled to avoid problems. If the master count is higher, the
	dlNew() function will be used to automatically download the scripts that the user is missing.<br>
	<b>C.</b> dlNew() = This function gets called when new scripts or newer versions are available, or if the user wants to pull fresh copies from
	the master repo.<br>
	<b>D.</b> verChk() = This function is used every time a script gets selected from the MACROSS menu. It compares the "#_ver" line in the local
	script and in the master repo script. The master version is newer, it gets downloaded before the selected script executes.<br>
<br>
<br>
<b>IV. extras.ps1</b><br>
	<b>A.</b> runSomething() = Pauses the MACROSS console and loads a fresh powershell instance so that the user can perform a quick powershell task.
	Typing "exit" returns the user to MACROSS.<br>
	<b>B.</b> decodeSomething() = From the MACROSS menu, the user can call decodeSomething() to quickly decode a Base64 or Hex string they may
	come across in an investigation.<br>
	<b>C.</b> disVer() = A quick way to pull any script version. Call it with the name of your script without the file extension. The value gets
	written to the global variable $VER.<br>
	<b>D.</b> getFile() = Your script can use this to open a dialog box for users to select a file<br>
	<b>E.</b> houseKeeping() = Call this function with a filepath to any reports or files created by your scripts. It offers users the option to delete
	any or all of these files when they are no longer needed.<br>
<br>
<br>
<b>V. mcdefs.py</b><br>
	<b>A.</b> This is a python library that provides many of the same core functions used in the MACROSS powershell scripts. See the script comments for
			  details.



