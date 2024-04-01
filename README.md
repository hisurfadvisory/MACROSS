

TL;DR -- A "no-command-line-necessary" powershell menu to link multiple automation scripts together for blue-team investigators. When you run MACROSS for the first time, select the HIKARU demo to get a quick walkthru on configuring your defaults.<br><br>

<img src="https://raw.githubusercontent.com/hisurfadvisory/MACROSS/main/mscr.PNG">

# MACROSS
Powershell framework that links your Powershell and Python API automations for blueteam investigations
<br><br><br>
Multi-API-Cross-Search (MACROSS) console interface is a very simple powershell framework to connect multiple automation scripts together. I've included a few of my own scripts here, but the key to MACROSS is adding scripts specific to your environment, and letting the console seamlessly link them together.
<br><br>
The purpose of this framework is to make automation tasks available to everyone on your blue team regardless of their skill with command-line. This can make things alot quicker if you script out your most common Active-Directory and Windows Server tasks, or you're able to use APIs instead of web-interfaces to query security tools (See my GERWALK script as an example, which accesses the Carbon Black Endpoint Response API).
<br><br>
DISCLAIMER: I'm a bash junkie, but Windows is what I work on in most corporate environments, and this project originally started as a way simplify my most common investigation queries. While I am experienced in a few scripting languages, I am NOT a powershell expert. I'm sure there's tons of optimizations that could be done to this framework.
<br><br>
MACROSS came about because I got tired of handjamming queries and wanted a way to pull in API information without going to multiple web interfaces. Eventually I created a single front-end to handle doing all of these queries in whatever sequence I needed. It is written in powershell because the initial automations were for active-directory and windows desktop tasks.
<br><br>

See the full README inside the core folder for function details, but here's the basics:<br>
<br>

&emsp;-Several of my scripts are included in this release mainly as examples to help you integrate MACROSS, but you may find KONIG and ELINTS helpful; KONIG can scan enterprise shares for files based on names/extensions, and ELINTS can perform keyword & pattern searches on those files.
<br><br>
&emsp;-When you add the required MACROSS values to your scripts, they'll be able to talk to each other and enrich IOCs your SOC analysts are investigating. This is not a SEIM or SOAR replacement, but a "quick-lookup" designed to help you gather data quickly if you don't have a million-dollar security stack to work with.
<br><br>
&emsp;-MACROSS provides several built-in functions to make your life easy, like printing your outputs to screen in pretty tables, writing reports to colorized excel spreadsheets, performing basic decoding tasks, and showing lists of stale reports that may need to be deleted from your report folders. See the "core/utility.ps1" file for details on these and more!
<br><br>
&emsp;-Core functions are kept in scripts within the "core" folder, though you're unlikely to need to modify any of these except the "display.ps1" file. This file contains the startUp function to kick off everything MACROSS, and points to the initial config file (see next point).
<br><br>
&emsp;-The temp_config.txt file inside the core folder contains an example of the default values that MACROSS sets and makes available to all its tools. Your default values should be kept in a centrally-located file in a location you control so that your users aren't all downloading it and leaving copies all over the place.
<br><br>
&emsp;-Files that can be used for enrichment across multiple scripts (xml, json, txt) are kept in the "resources" folder. This folder is currently in the MACROSS root folder, but can be placed anywhere you want
<br><br>
&emsp;-There are several global variables used within MACROSS that your scripts will need to recognize. These are explained in the core folder's README.
<br><br>
&emsp;-If you want your script to be part of MACROSS, it *requires* special tags in the first 3 lines of your script. These lines are read by MACROSS and used to classify each script by its language and what it does.
<br><br>
&emsp;-Because several scripts can be running at once and sharing data, I strongly recommend naming your variables beginning with "dyrl_" and maybe a nickname of the script (example, "$dyrl_mys_var" for a variable generated in "myscript.ps1"). The reason for this is that MACROSS automatically clears all variables beginning with "$dyrl_" every time the menu loads, ensuring scripts always behave as intended even if somebody forgot to clear globals in their code.
<br><br>
&emsp;-All of your custom automation scripts go into the "modules" folder. Once placed there, they immediately become available in the main menu.


