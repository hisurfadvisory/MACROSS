

TL;DR -- A "no-command-line-necessary" powershell menu to link multiple automation scripts together for blue-team investigators. When you run MACROSS for the first time, select the HIKARU demo to get a basic demonstration of making your scripts talk to each other. From the main menu, you can type "help" and any tool number to get that tool's help page, or type "debug" to get the usage and descriptions of MACROSS functions your scripts can make use of.<br><br>

<img src="https://raw.githubusercontent.com/hisurfadvisory/MACROSS/main/mscr.PNG">

# MACROSS
Powershell framework that links your Powershell and Python API automations for blueteam investigations
<br><br><br>
Multi-API-Cross-Search (MACROSS) console interface is a very simple powershell framework to connect multiple automation scripts together. I've included a few of my own scripts here, but the key to MACROSS is adding scripts specific to your environment, and letting the console seamlessly link them together.
<br><br>
The purpose of MACROSS is to make automation tasks available to everyone on your blue team regardless of their skill with command-line. This can make things alot quicker if you script out your most common Active-Directory and Windows Server queries, or you're able to use APIs instead of web-interfaces to query security tools (See my GERWALK script as an example, which accesses the Carbon Black Endpoint Response API).
<br><br>
DISCLAIMER: I'm a bash junkie, but Windows is what I work on in most corporate environments, and this project originally started as a way simplify my most common investigation queries. While I am experienced in a few scripting languages, I am NOT a powershell expert. I'm sure there's tons of optimizations that could be done to this code.
<br><br>
MACROSS came about because I got tired of handjamming cmdlets and copying everything into notepad. I wanted a way to automatically send search results to other cmdlets while being able to come back to previous results, or pull information directly from APIs to avoid going to multiple web interfaces. Eventually I created a single front-end to handle doing all of these queries in whatever sequence I needed. It is written in powershell because all the initial automations were for active-directory and windows desktop tasks.
<br><br>

See the full README inside the core folder for function details, but here's the basics:<br>
<br>

&emsp;-When you use MACROSS for the first time, a config wizard walks you through the process of generating a configuration file. By default, you need to move this configuration file into the \core folder after it's generated, but if you want to store it somewhere more secure, change the $vf19_CONFIG value in the MACROSS.ps1 file (search for "MOD SECTION!"). Changing this location is recommended if you have multiple users.<br>
&emsp;--From the main MACROSS menu, enter "debug" to load a playground for testing functions and viewing helpfiles. <br>
&emsp;--From the main MACROSS menu, enter "config" to add or change the settings in your config.conf file.
<br><br>
&emsp;-Several of my scripts are included in this release as examples to help you integrate your scripts into MACROSS, but you may find MYLENE, NOME and ELINTS helpful; MYLENE performs new Active-Directory account audits, ELINTS can perform keyword & pattern searches on various document formats, and NOME lets you build a quick filter with Active-Directory properties to hunt for anomalous accounts in your enterprise.
<br><br>
&emsp;-When you add the required MACROSS values to your scripts, they'll be able to talk to each other and enrich IOCs your SOC analysts are investigating. This is not meant to be a monitoring tool, but a "quick-task" aid designed to help you gather data quickly if you don't have a million-dollar security stack to work with.
<br><br>
&emsp;-MACROSS provides several built-in functions to make your life easy, like printing your outputs to screen in pretty tables, writing reports to colorized excel spreadsheets, performing basic decoding tasks, and showing lists of stale reports that may need to be deleted from your report folders. The secondary reason for many of these functions is that by using them, you tie them directly to MACROSS: for scripts that may be able to gather sensitive info, if someone attempts to execute them outside of MACROSS and its (admittedly basic) access controls, the script will fail. See the "core/utility.ps1" file for details on these and more, or type "help dev" into the main menu.
<br><br>
&emsp;-Core functions are kept in the "core" folder. You can search for the comment "MOD SECTION!" in any of these files for sections where you can change default values if necessary. 
<br><br>
&emsp;-Files that can be used for enrichment across multiple scripts (xml, json, txt) are kept in the "resources" folder. This folder is currently in the MACROSS root folder, but can be placed anywhere you want. The MACROSS configuration wizard will ask you for an alternate folder path if you don't want to use the default.
<br><br>
&emsp;-There are several global variables used within MACROSS that your scripts will need to recognize. These are explained in the core folder's README.
<br><br>
&emsp;-If you want your script to be part of MACROSS, it *requires* special tags in the first 3 lines of your script (even the python scripts). These lines are read by MACROSS and used to classify each script by its language and what it does.
<br><br>
&emsp;-Because MACROSS is meant to allow several scripts to be running at once and sharing data, I strongly recommend naming your variables beginning with "dyrl_" and maybe a nickname of the script (example, "$dyrl_mys_var" for a variable generated in "myscript.ps1"). The reason for this is that MACROSS automatically clears all scoped variables beginning with "$dyrl_" every time the menu loads. We want to make sure scripts always behave as intended even if somebody forgot to clear values in their code.
<br><br>
&emsp;-All of your custom automation scripts go into the "modules" folder. Once placed there, they immediately become available in the main menu.
<br><br>


