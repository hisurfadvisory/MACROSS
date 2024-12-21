## ADD YOUR AUTOMATIONS TO MACROSS

<b><u>REQUIREMENTS:</u></b><br>
-For any script to function in MACROSS, whether you're writing new code or using an existing automation, you must reserve the first three lines of the file for these attributes (review the scripts I've included in the modules folder to get an idea of the required structure for MACROSS integration):
<br>
The first three lines of your automation script require these:<br>

	#_sdf1   BRIEF DESCRIPTION OF YOUR SCRIPT
	#_ver    VERSION NUMBER OF YOUR SCRIPT
	#_class  COMMA-SEPARATED ATTRIBUTES OF YOUR SCRIPT

	The "sdf1" line needs a brief description of your script; this gets written to the MACROSS menu
	The "ver" line is the version of your script
	The "class" line needs you to comma-separate ***all*** of these attributes, in this order:
		1. If you have different tiers/levels of analysts, use this for distribution control (1 - 3).
			To allow anyone to download and execute the script, use 0.
		2. The LOWEST privilege level your script requires (user, admin, etc.)
			Even if your script contains tasks that require elevated privilege, set to "user"
			if the script can perform tasks without admin privilege. MACROSS tags non-admin users 
   			with "$vf19_ROBOTECH", which you can use to skip admin tasks if $vf19_ROBOTECH is $True.
		3. What kind of data your script processes (IPs, filescans, etc.), or what task it performs.
  			Keep this concise but specific across your scripts. For example, you might have
     		several automations that do things in active directory, but don't just use "active-
			directory" for each one!
		4. What language your script is (powershell or python)
		5. The author
		6. The maximum number of values your script can process
		7. The format of your script's responses to other scripts' queries

		Here's an example class line for scripts offered to user-privileged tier 1 analysts, and their
  		\[macross\] attribute names:
		
		#_class 1,user,office vba extraction,powershell,HiSurfAdvisory,1,xml

			1 			= .access
			user			= .priv
			office vba extraction 	= .valtype
			powershell 		= .lang
			HiSurfAdvisory 		= .auth
			1 			= .evalmax
			xml 			= .rtype

When all these lines are set correctly, MACROSS uses the \[macross\] class to keep track of the scripts in the "modules" folder and the central repository (if you're using one). You can see what these look like by typing "debug TL" in the main menu.

Consistency is important when you craft the #_class lines for your scripts! It's a good idea to leave everything lower case even though powershell doesn't care, because python IS case-sensitive. Make sure field 3 (the task/evaluation descriptor) keeps commonality while being unique. For example, if you have three different scripts that access AD, you could begin them all with "active-directory" followed by their unique task. This will be important as you'll see.<br><br>

<b><u>THE REASON FOR MACROSS</u></b><br>
When your script extracts or identifies a value to focus on, set it as the <u>global</u> variable $PROTOCULTURE (the power that defeated the Zeltran empire in the original Macross anime -- love and pop music!). Scripts that are meant to collaborate with others should all be coded to act automatically when this variable contains a value; make sure to set your script's #_class field 6 (.evalmax) as 1*.

<i>*If your script can accept additional parameters, set .evalmax to 2.</i>

When the global $PROTOCULTURE has been set, there are two key utilities that will pull your scripts together: availableTypes() and collab().<br>

availableTypes() is used to generate a list of scripts relevant to your task. It accepts several arguments that let you filter based on the #_class field 3 value mentioned above (.valtype), as well as language, response type, and how many inputs a script accepts. In reference to my commonality suggestion above, availableTypes can filter based on <u>exact</u> matches, or just partial matches. If you want all the scripts that access AD, you can get them; if you just want the script that locks or unlocks accounts, you can do that too.

Once you have this list, you can iterate each script with the collab function, which handles generating all necessary background resources and passing your investigation values to each script.<br><br>

<b><u>CROSS LANGUAGE SUPPORT</u></b><br>
In order to let powershell and python scripts interact seamlessly, there are a few more requirements. First, you'll need to add a param field in your powershell scripts like this (in addition to any other params you have):

	param(
    	$pythonsrc = $null
	)
	if( $pythonsrc ){
		$Global:CALLER = $pythonsrc
		foreach( $core in gci "$(($env:MACROSS -Split ';')[0])\core\*.ps1" ){ 
			. $core.fullname 
		}
		restoreMacross
	}

<i>*$pythonsrc is not counted as an evaluation parameter in MACROSS; don't count it in your .evalmax value.</i>

The above check allows a powershell script to know when it is being called by python. Since jumping to python and back creates new sessions outside of the currently running MACROSS session, this lets powershell regen any values and functions it would require from MACROSS.

If your automation is written in python, you'll need to import the custom MACROSS module, "valkyrie". This module contains most of the powershell utilities converted into python, and also generates the default global MACROSS variables. The valkyrie.collab() and valkyrie.availableTypes() functions work just like their powershell counterparts, with caveats (see QUIRKS & LIMITATIONS below).<br><br>


<b><u>OPTIONAL STUFF</u></b><br>
-The configuration wizard that walks you through MACROSS for the first time can be re-launched by typing "config" in the main menu. This lets you change, add, or remove any configured values. The purpose of the config.conf file is to store regularly used data, which could be file locations, URLs, or whatever you don't want hardcoded in plaintext. The data is protected with a very basic encryption, so I wouldn't recommend storing keys or passwords in it!<br>

-If a user types "help" with the number of your script in the menu, it sets global "$HELP" to true. Your script should have a description/helpfile/man-page that loads for the user when they do this, then exits when they finish reading.<br>

-If a user adds an "s" to their selection in the menu, it sets the global value "$vf19_OPT" to true. This allows your script to load additional features or change functions without adding param switches.<br>

-There are lots of built-in utilities your script can make use of. Check out the "FUNCTION_DETAILS" readme, or type "debug" in the main menu to load a "developer playground".<br><br>


<b><u>QUIRKS & LIMITATIONS</u></b><br>
1. The powershell collab() function can only pass 1 extra evaluation parameter to scripts, an alternate value to $PROTOCULTURE. It passes this value as "$spiritia" (the energy source highlighted in the Macross 7 anime -- generated by love & rock music!), so your script will need to accept is as<br>

	param( $spiritia )

to avoid confusion with any other params. If you need to modify this behavior to handle more parameters, the collab function is located in the validation.ps1 file.<br><br>

2. The valkyrie module's collab() function operates by reading and writing to a simple json file in the core\macross_py\garbage_io folder. The function allows for writing your own custom outputs to this folder as well, but the folder gets cleared out every time MACROSS exits or launches.


Be sure to read the FUNCTION_DETAILS readme file for the full notes of MACROSS functionalities!
