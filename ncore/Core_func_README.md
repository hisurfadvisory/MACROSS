## CUSTOMIZING THE CORE FUNCTIONS FOR YOUR ENVIRONMENT


<b><u>SETTING DEFAULT VARIABLES</u></b><br>
TL;DR -- Run the DEMO option from the menu in MACROSS for a quick overview.

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
To further customize and modify these core functions to your liking, see the comments in each .ps1 file.


  
