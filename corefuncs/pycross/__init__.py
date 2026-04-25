""" MACROSS v2.0 python conversion of MACROSS powershell utilities

 This library imports a lot of common functions, so I just make them available here
 to avoid having to code multiple imports into a script. i.e. instead of importing
 libs like re, os or datetime, you might be able to just use macross.rgx(), 
 macross.psc() or macross.cdate() to do the basics.

 This library was written and tested with Python 3.13

 CLASSES

    macross
        Applies MACROSS properties to each hunter script

 FUNCTIONS

    cdate():
        get the current date + time

    delfile():
        delete a file

    errLog():
        write to a MACROSS error log

    findDF():
        find relevant MACROSS hunters to process your data

    getFile():
        open a dialog to select files or folders

    ispath():
        verify a file or folder path is valid

    minmay():
        display a terminator image.

    gerwalk():
        decrypt a MACROSS data key

    psc():
        execute a system command

    reString():
        decode/encode base64 or hexadecimal

    rgx():
        search and replace with regular expressions

    screenResults():
        format blocks of text into a table of up to 3 columns

    battroid():
        generate ascii-art of large block words

    slp():
        sleep for n seconds/milliseconds
    
    w():
        onscreen text formatting

    valkyrie():
        sends your data to a MACROSS diamond 



"""

from .macross import (
    battroid,
    cdate,
    delfile,
    errLog,
    findDF,
    getFile,
    ispath,
    macross,
    minmay,
    gerwalk,
    psc,
    reString,
    rgx,
    screenResults,
    slp,
    w,
    valkyrie,
    CALLER,
    CONF,
    DESKTOP,
    GBIO,
    HELP,
    MODS,
    LATTS,
    LOGS,
    MACROOT,
    N_,
    OUTFILES,
    PLUGINS,
    PROTOCULTURE,
    PSVER,
    RESOURCES,
    ROBOTECH,
    TMP,
    USR
)

