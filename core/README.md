## CUSTOMIZING THE CORE FUNCTIONS FOR YOUR ENVIRONMENT

<b><u>ADDING SCRIPTS AND CONFIGURING MACROSS</u></b><br>
TL;DR -- To reiterate the main README -- MACROSS isn't so much a toolset as it is a standardized scheme (we'll call it a "Framework" because buzzwords) to help you connect unrelated scripts together in any way that seems natural or relevant to the everyday tasks in your SOC. <u>Its primary goal is to speed up the gathering of common info from Active Directory and any tools that have command-line APIs you already make use of</u>. Look up a host, or a username, or a filename, then extract any related data that is relevant to your investigation.<br><br>

Important notes -- the basic permission & authentication checks that MACROSS provides are most useful in environments where code-signing is enforced (i.e. where scripts with no digital signature, or broken digital signatures, will not execute). Otherwise, it is fairly trivial for anyone with moderate skill to bypass these checks. I didn't write this as an enterprise security tool, it's an aid to help cut down on the amount of web consoles and cmdlets I need to use throughout the day. Keep that in mind if you want to use MACROSS to access APIs, and write your scripts accordingly! <br><br>


MACROSS.ps1  = execute this to start MACROSS<br>

\core folder = Contains all of MACROSS' core functions; you shouldn't need to change much in here, but I've left comments in these files on how you can modify them if you want.<br>
\modules folder = Put your automation scripts in here. You can use powershell 5+ or python 3+.<br><br>
I recommend you place these folders in an alternate, access-controlled location:<br>
 \resources folder = put any enrichment or custom config files you want in here (json, xml, etc.)<br>
 \logs folder = The location you want MACROSS to write its log files to (currently sitting in the resources folder)<br>


The first three lines of your automation script require these:<br>

	#_sdf1   BRIEF DESCRIPTION OF YOUR SCRIPT
	#_ver    VERSION NUMBER OF YOUR SCRIPT
	#_class  COMMA-SEPARATED ATTRIBUTES OF YOUR SCRIPT

	The "sdf1" line needs a brief description of your script; this gets written to the MACROSS menu
	The "ver" line is the version of your script
	The "class" line needs you to comma-separate ***all*** of these attributes, in order:
		1. If you have different tiers/levels of analysts, use this for access control (1 - 3).
			  To allow anyone to execute the script, use 0.
		2. The LOWEST privilege level your script requires (user, admin, etc.)
		3. What kind of data your script processes (IPs, filescans, etc.). Keep this concise and uniform across your scripts!
		4. What language your script is (powershell, python)
		5. The author
		6. The maximum number of values your script can process
		7. The format of your script's responses to other scripts' queries

		Example class line:
		#_class 1,user,office vba extraction,powershell,HiSurfAdvisory,1,hashtable

When all these lines are set correctly, MACROSS uses the \[macross\] class to keep track of the scripts in the "modules" folder and the central repository (if you're using one). You can see what these look like by typing "debug TL" in the main menu.<br>

FOR YOUR PYTHON SCRIPTS:<br>
You'll need the argv and path functions from the sys library. MACROSS always passes at least 6 args to any python script it executes (7 if you include the script name). The below example explains how to use them.<br>

	from sys import argv,path
	L = len(argv)
	if L >= 7:                    ## make sure MACROSS sent all its default values
		mpath = argv[6]
		path.insert(0,mpath)  	  ## modify the sys path to include the local py_classes folder
		import mcdefs		      ## this is the custom MACROSS library that contains most of the functions in utilities.ps1
								  ## and display.ps1

		## The other 5 args always passed in by MACROSS can be used or ignored as you like. In order, they are:

		USR = argv[1]               	## The logged-in user $USR
		latts = argv[2]              	## The $vf19_LATTS hashtable attributes .name and .valtype for each script,
										## but you'll need to use "mcdefs.getATTS(latts)" to actually import this
										## as a dictionary in python.
		vf19_DTOP = argv[3]  	## USR's desktop filepath
		vf19_PYPOD = argv[4]        	## The encoded array of filepaths/URLs generated from temp_configs.txt
		N_ = argv[5]                	## The integer MACROSS uses for common math functions in all the scripts
		M_ = mcdefs.makeM(N_)        	## This function splits the N_ value into 6 digits you can use for mathing
		vf19_TOOLSROOT = argv[7]    	## The path to the MACROSS folder
		GBG = argv[6] + '\\garbage_io'  ## Path to the garbage I/O folder.

GBG is a folder your python scripts can write outputs into if you want them available for later use in your MACROSS session. This folder gets cleared out every time MACROSS exits.<br>



<b><u>RUN THE CONFIGURATION WIZARD:</u></b><br>
-If you are writing automations that will be used by other people, change the default config location! In the MACROSS.ps1 file, look for line 189. Change the "$vf19_CONFIG" value to a filepath external to MACROSS (someplace access-controlled). If you are only using MACROSS yourself, or you don't really care, you don't need to change anything.

-When you first launch MACROSS, it does not have a configration file. You'll be prompted to create a password, then you'll need to enter values for the required configuration defaults. After that, you can enter additional configurations which are values that you want all of your scripts to have regular access to (stuff like server addresses, file locations, etc.).

After you've entered the default configuration, you'll be asked if you want to use access control. In an active-directory environment, assuming your SOC analysts have different tiers of permissions, you can enter the group-policy names that you want MACROSS to identify for allowing or denying execution of scripts. You can enter up to 3 group-policy names, the first for tier1 analysts/investigators, then tier2, and tier3. Alternatively, you can supply text files with usernames for each tier to achieve the same result. *If you skip this configuration, MACROSS will allow everybody to execute any tool.*

Once your config file is generated, MACROSS will exit. Move config.conf (and analyst.conf if you created one) from the root MACROSS folder to the location specified in MACROSS.ps1 line 189 (again, by default it is the MACROSS\core folder), then launch MACROSS again. Congrats, you're ready to go! Any custom scripts you drop into the modules folder will become available in the menu.

If you need to change or add more configurations, type "config" into the main menu and follow the instructions. A new configuration file will be generated with your changes (you should backup the old one, but remember that if you changed the admin password, the old file will still be encrypted with your old password*!).

*NOTE: This configuration file uses basic encryption to protect itself from prying eyes & unauthorized modifications, but I wouldn't recommend storing anything too sensitive, like authentication keys/credentials.


<b><u>MANUAL CONFIGURATION CHANGES:</u></b><br>
MACROSS.ps1 line 189 -- In this section, you can change the location for the config.conf file (the default is your local core folder). The access controls work best if you can place this file in a centralized location reachable by your SOC teams, instead of having copies installed to each user's core folder.

display.ps1 line 800 -- You can add checks for MACROSS to determine if specific programs are installed that your automations can use. Just copy line 799, which is checking for MS Excel. (The MACROSS function "sheetz" can create excel spreadsheets for you)



<br>
<br><br>
<b><u>MAKING USE OF YOUR CONFIGS</u></b><br>
The configuration wizard asked you to enter a number for obfuscation. You can access it using "$N_". The idea behind this is you can perform mathing in your scripts without having the numbers written out for others to see. The variable $N_ contains a list beginning with the number you chose, and the rest of the list is that number split into single digits, so you can do things like script out an IP address:

	$ip = "192.168." + "$($N_[3] + 6)" + ".$($N_[9])"

For all of the other configs you set, the array $vf19_MPOD contains your decrypted values. You can review these at any time by launching the debugger or configuration wizard. Just type "debug" or "config" in the main menu.

For example, the configuration wizard asked you for a folder to place enrichments. MACROSS uses the ID "enr" to track this value, which would be where you keep anything that contains data your scripts make regular use of; json, xml, csv, etc. If you entered a location (or kept the default MACROSS\resources folder), and it contains a file like "servers.json", your scripts can access it with

	getThis $vf19_MPOD['enr']; $SERVERS = "$vf19_READ\servers.json"

If you've set a configuration key for something like the address of your firewall, your scripts can access it with

	getThis $vf19_MPOD['key']; $firewall = $vf19_READ

where 'key' is the ID you specified for your firewall's URL. $vf19_READ is a variable that is regularly flushed so that plaintext values are only available while needed.

The <b>getThis</b> function can decode any Base64 and Hexadecimal for your scripts as long as MACROSS is running. The decoded plaintext gets written to <i>$vf19_READ</i>. If you need that value persistently, you must store it as something else before using <b>getThis</b> again:<br><br>

    getThis $b64
    $plaintext = $vf19_READ
<br>    
Call it with -h if you're decoding hex:<br><br>

    getThis $hex -h
    $plaintext = $vf19_READ
    
Call it with -e to encode plaintext (it does NOT write to $vf19_READ):<br><br>

    $b64 = getThis $plaintext -e
	$hex = getThis -h -e $plaintext

There are many more functions in the display.ps1 and utility.ps1 files that are available to all your scripts to hopefully make life a little easier. (Details toward the end of this page)<br>

<b>FINALLY...</b><br>
To further customize and modify these core functions to your liking, see the comments in each .ps1/.py file and the README below.<br>
<br>
<br>


<b>The MACROSS powershell object</b>
<b>core\classes.ps1</b><br>
	This file should be reserved for any custom classes your scripts need, especially if they could be useful for other scripts to make use of.<br>
	&emsp;<b>A.</b> macross = A custom powershell class that tags every script in the \modules folder with specific attributes that you MUST include on the third line of your scripts, tagged with "#\_class" so that MACROSS will parse it correctly. In this example:<br>
	<br>
	`#_class  1,user,syslog parsing,python,SuzyQ,1,list`
	<br>
	The first value<b>1</b> is the .access attribute, used for basic role-based access (values can be 1, 2, or 3, to limit the script to your tier 1, tier 2 and tier 3 analysts respectively). Next is the .priv attribute <b>user</b>, or the level of privilege required to run your script (will typically be User vs. Admin). Next, the <b>syslogs</b> value will be assigned to the .valtype attribute, describing what kind of data your script processes/returns, or what kind of actions it performs. The third value, <b>Python3</b>, is the .lang attribute while the fourth, <b>SuzyQ</b>, is the .author attribute. The fifth, "<b>1</b>" is the .evalmax attribute, which is the maximum number of parameters that your script can accept for processing. And finally, the value <b>list</b> is the type of response your script provides. The attributes tracked in this class are:<br>
	
	.name
	.access
	.priv
	.valtype
	.lang
	.author
	.evalmax
	.rtype
	
<br>
This is used for:<br>
	&emsp;&emsp;-controlling which scripts get pushed to your analysts when you are using a master repository to centrally maintain MACROSS<br>
	&emsp;&emsp;-allowing you to write functions that automatically know what scripts can accept what types of values for auto-evaluating:<br>
	&emsp;&emsp;for example, using MACROSS' "availableTypes" utility:
	
	availableTypes -v intel -r json | foreach-object { $results.add( $(collab $_ 'myscript') ) }
	
&emsp;&emsp;your script can autoquery any other scripts that parse intel reports and send back JSON files.<br><br>
&emsp;&emsp;Calling the script name from the hashtable will give you all its attributes. The <b>toolInfo()</b> method will prettify the output, or you can just view it raw:<br>
	
	$vf19_LATTS['MINMAY'].toolInfo()
	  MACROSS: MINMAY
         Version:       0.2
         Author:        HiSurfAdvisory
         Evaluates:     demo script
         Max arguments: 2
         Response type: onscreen
         Privilege:     user
         Tier:          tier1
         Language:      python
         Filename:      MINMAY.py
	
	[macross]$vf19_LATTS['MINMAY']
	name    : MINMAY
	access  : tier1
	priv    : user
	valtype : demo script
	lang    : python
	author  : HiSurfAdvisory
	evalmax : 2
	rtype   : onscreen
	ver     : 0.2
	fname   : MINMAY.py

&emsp;&emsp;From the MACROSS debug console, you can just type TL to get this information!
<br>
<br>
<b>py_classes\mcdefs.py</b><br>
	&emsp;<b>A.</b> This is a python library that provides many of the same core functions used in the MACROSS powershell scripts, as well a "getDefaults" function that will convert MACROSS' $vf19_MPOD hashtable into a python dictionary. See the mcdefs file comments for more details.



<b>IMPORTANT:</b>
Your script should be written to recognize the global variables MACROSS uses. Unless otherwise noted, all of these variables are cleared out or refreshed when an investigation session finishes, i.e. when the user exits back to the main MACROSS menu.
<br><br>
&emsp;&emsp;$PROTOCULTURE = this is the IOC that you are investigating. Usernames, filenames, IPs, anything. MACROSS scripts should all be written to set this value when you find an artifact worth investigating, and also to automatically act on this variable if it was generated by another script. This variable does NOT clear automatically when exiting to the menu, but a persistent message reminds you about it and offers to clear it for you.

&emsp;&emsp;$RESULTFILE = if your script outputs results to a file that other scripts might be able to process, set its filepath in this global variable.

&emsp;&emsp;$HOWMANY = the total number of successful hits from all of the tasks run so far (your scripts must be coded to update this value when applicable, MACROSS only clears it out when necessary).

&emsp;&emsp;$N_ = This is a number you can use to perform math or obfuscate IP addresses in your scripts. It has a counterpart, $M_, which an array created by splitting $N_ into a list of single-digit numbers.

<br><br>
Make sure to code your scripts to provide responses when MACROSS executes them via the collab function, and use the availableTypes function to make auto-searching for relevant scripts easier.<br>

<br><br>

<br>
MACROSS provides shared utilities your scripts can use (many of them also provided in the python "mcdefs" library):

&emsp;&emsp;w =  Alias for the write-host cmdlet. The first param is the string you want written to screen, the second (optional) param colorizes the text. You can send a third param that will colorize the background, or use "nl" to set the "-NoNewLine" option.
	
	w 'I want green text here ' 'g' 'nl'; w 'and yellow text here.' 'y'

&emsp;&emsp;getThis = base64 and hex decoder/encoder

	getThis  $b64          ## decodes base64 to $vf19_READ.
	getThis  $hex -h       ## decodes hexadecimal to $vf19_READ.
	getThis  $text -e      ## encodes to base64.
	getThis  $text -e -h   ## encodes to hex.

&emsp;&emsp;getFile = open a file-selection dialog

	$file = getFile

&emsp;&emsp;getHash = get the md5 or sha256 of a file

		-Usage:   getHash $filepath 'md5'

&emsp;&emsp;yorn = Open a popup to get a "yes" or "no" response from the analyst.

&emsp;&emsp;ord = get the decimal representation of a unicode character

	ord $string

&emsp;&emsp;chr = get the string representation of a unicode's decimal

	chr $integer

&emsp;&emsp;stringz = extract strings from a file

	stringz $filepath

&emsp;&emsp;screenResults = used for writing results to screen in a colorized table format

	screenResults  $string  $optional_var1  $optional_var2
	screenResults  'endr'

&emsp;&emsp;&emsp;&emsp;-Set $string as "endr" to draw the "end of row" border lines. OPTIONAL: Begin any of your string values with "color~" to change the color of the text. For example "r~$string" for red text or "m~$optional_var2" for magenta

&emsp;&emsp;screenResultsAlt = same as above, but formatted differently for small values

	same as "screenResults" above.

&emsp;&emsp;sheetz = write results to an excel spreadsheet, with options to highlight text and/or cells in different colors

	sheetz $file_to_edit  $comma_separated_values  $optional_row_to_start_writing  $optional_headers_or_max_columns

&emsp;&emsp;&emsp;&emsp;-To highlight values: in your comma-separated values, add the color you want to use to the value you want highlighted, ending with a "~". 

&emsp;&emsp;&emsp;&emsp;If you want to colorize cells, you must add the color for the cell AND the color for the text. Example:

&emsp;&emsp;&emsp;&emsp;"blue~white~Linux,Windows" will write "Linux" to a blue cell in white text, and "Windows" in the next cell with no colorization. "blue~Linux,Windows" will write "Linux" in blue text without coloring the cell.

&emsp;&emsp;&emsp;&emsp;-$optional_row_to_start_writing is the row you want to start writing to. If editing an existing spreadsheet and the next available row is A151, you would send 151 in this space.

&emsp;&emsp;&emsp;&emsp;-$optional_headers_or_max_columns can be a comma-separated list of column names you want to use, OR the number of columns that you want $comma_separated_values to write to before jumping to the next row. For instance, if you send eight column names in this parameter, it will write each name to its own column (A1 thru H1). The $comma_separated_values will then get written under these columns, so make sure you send the $comma_separated_values in order!

&emsp;&emsp;houseKeeping = display the contents of a folder your script writes outputs to, and options to delete stale reports

	houseKeeping  $path_to_your_scripts_reports  $your_script_name

<br><br>
