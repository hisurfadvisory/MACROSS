""" MACROSS ce v1.0 python conversion of MACROSS powershell utilities

 This library imports a lot of common functions, so I just make them available here
 to avoid having to code multiple imports into a script. i.e. instead of importing
 libs like re, os or datetime, you might be able to just use macross.rgx(),
 macross.psc(), macross.cdate(), etc. to do the basics.

 CLASSES

    macross
        Applies MACROSS properties to each diamond script

 DATA
    PROTOCULTURE
        The investigation value for diamond scripts to process

    CALLER
        The name of the diamond script querying other diamonds

    DESKTOP
        The path to your desktop

    PSVER
        The major version of powershell currently in use

    USR
        The logged in user

    ROBOTECH
        If true, the user doesn't have elevated system/network privilege

    HELP
        Check if user is requesting to view a diamond's help message

    GBIO
        Path to the local garbage_io folder that contains the
        PROTOCULTURE.mori file

    OUTFILES
        Path to the local MACROSS output folder

    PLUGINS
        Path to the local MACROSS plugins folder

    RESOURCES
        Path to the local MACROSS resources folder

    CONTENT
        Path to the remote MACROSS resources folder (default will be
        the same as RESOURCES if not configured)

    LATTS
        A dictionary of all local diamonds and their macross class attributes


 FUNCTIONS

    collab():
        sends your data to a MACROSS diamond

    cdate():
        get the current date + time

    delfile():
        delete a file

    errLog():
        write to a MACROSS error log

    availableTypes():
        find relevant MACROSS diamonds to process your data

    getFile():
        open a dialog to select files or folders

    ispath():
        verify a file or folder path is valid

    minmay():
        display a terminator image.

    kawamori():
        decrypt a MACROSS data key

    psc():
        execute a system command

    gerwalk():
        decode/encode base64 or hexadecimal

    rgx():
        search and replace with regular expressions

    screenResults():
        format blocks of text into a table of up to 3 columns

    skyWriter():
        generate ascii-art of large block words

    slp():
        sleep for n seconds/milliseconds

    w():
        onscreen text formatting


"""

from .macross import (
    availableTypes,
    cdate,
    collab,
    delfile,
    errLog,
    getFile,
    gerwalk,
    ispath,
    minmay,
    kawamori,
    psc,
    rgx,
    screenResults,
    skyWriter,
    slp,
    w,
    CALLER,
    CONF,
    DESKTOP,
    GBIO,
    HELP,
    DIAMONDS,
    LATTS,
    LOGS,
    N_,
    ROBOTECH,
    OUTFILES,
    PLUGINS,
    PSVER,
    RESOURCES,
    MACROOT,
    PROTOCULTURE,
    TMP,
    USR
)



