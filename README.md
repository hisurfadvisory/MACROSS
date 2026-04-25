

TL;DR -- A "no-command-line-necessary" powershell menu to link multiple automation scripts together for blue-team investigators. When you run MACROSS for the first time, select the HIKARU demo to get a basic demonstration of making your scripts talk to each other. From the main menu, you can type "help" and any tool number to get that tool's help page, or type "debug" to get the usage and descriptions of MACROSS functions your scripts can make use of. Also, scan each script for the phrase "MOD SECTION" to find sections you can modify if needed.<br><br>

<img src="https://raw.githubusercontent.com/hisurfadvisory/MACROSS/main/mscr.PNG">

# MACROSS
Powershell framework that links your Powershell and Python API automations for blueteam investigations
<br><br><br>
Multi-API-Cross-Search (MACROSS) console interface is a very simple powershell framework to connect multiple automation scripts together. I've included a few of my own scripts as examples, but the key to MACROSS is adding scripts specific to your environment, and letting the console seamlessly link them together.
<br><br>
The purpose of MACROSS is to make automation tasks available to everyone on your blue team regardless of their skill with command-line. This can make things alot quicker if you script out your most common Active-Directory and Windows Server queries, or you're able to use APIs instead of web-interfaces to query security tools (See my GERWALK script as an example, which accesses the Carbon Black Endpoint Response API).
<br><br>
MACROSS came about because I got tired of handjamming cmdlets and copying everything into notepad. I wanted a way to automatically send search results to other cmdlets while being able to come back to previous results, or pull information directly from APIs to avoid going to multiple web interfaces. Eventually I created a single front-end to handle doing all of these queries in whatever sequence I needed. It is written in powershell because all the initial automations were for active-directory and windows desktop tasks.
<br><br>

<b><u>Important Note 1:</u></b> There are some very basic access controls that can be used with MACROSS, however, they can be easily bypassed by anyone with any scripting experience. If your environment enforces code-signing, this isn't an issue, but keep this in mind and don't treat MACROSS like a super secure storage application.<br><br>
<b><u>Important Note 2:</u></b> MACROSS makes two very important assumptions -- Assumption #1 is that your host is running powershell 5+ and optionally, python 3+; Assumption #2 is that your corporate policy doesn't allow for installing third-party modules or software whenever you like, which is why tasks like scanning PDFs is done in a clunky way.<br>

<br><br>
<img src="https://raw.githubusercontent.com/hisurfadvisory/MACROSS/main/configpanel.PNG">
<br><br>

When you use MACROSS for the first time, a config wizard walks you through the process of generating a configuration file. To disable or ignore any of these configurations, simply enter 'None' in the appropriate field (except the mathing field, it requires an int value!). By default, you need to move this configuration file into the \core folder after it's generated, but if you want to store it somewhere more secure, change the $vf19_CONFIG value in the MACROSS.ps1 file (search for "MOD SECTION" comment lines).<br>
&emsp;-Master Repository: if you want to distribute master copies to multiple users in your enterprise, enter its location here. MACROSS will check it at each startup.<br><br>
&emsp;-Debugging blacklist: the debugger is accessible by all users, so you can enter a regular expression (or keep the default one) that prevents anyone from executing commands you want to restrict, unless they enter the admin password.<br><br>
&emsp;-Log server: one of MACROSS' core utilities is a log writer to help with troubleshooting or auditing. It provides the option to forward its logs to a log collector or SEIM, if your organization uses one.<br><br>
&emsp;-Mathing Obfuscation Key: add an integer of any length here, and it will be stored in a list called "$N_". $N_[0] is the original value, and the rest of the index is the $N_[0] value split into single digits. You can use this for any equation or network scripting where you'd prefer not to have the numbers hardcoded in plaintext.<br><br>
&emsp;-Enrichments Folder: this is the location of files your scripts might regularly acccess (csv, json, etc.). The default is MACROSS' own resources folder.<br><br>
&emsp;-Location for logs: this is the location where MACROSS will write its logs to. The default is MACROSS' own resources\logs folder.<br><br>
&emsp;-Additional configs: Once these required values have been entered, you'll have an opportunity to add more, if you want. You can also launch the config wizard later on by typing "config" in the main menu.<br><br>
<br><br><br>

Once you've entered all the initial configurations and launched MACROSS, you can start testing and modifying:<br>
&emsp;-From the main MACROSS menu, enter "debug" to load a playground for testing scripts & functions, and viewing helpfiles.<br><br>
&emsp;-From the main MACROSS menu, enter "config" to change or add settings in your macross.conf file.<br><br>
&emsp;-There are two example scripts included -- BASARA (python) and HIKARU (powershell). Both of these demonstrate how to use MACROSS' built-in tools. They are located in the diamonds folder. Beyond that, everything you need is in the help comments in the MACROSS.ps1 file.
<br><br>
