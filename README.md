# ahk-launcher

## Description ##
Careful naming and placement of AHK files allows loading several of them dynamically when the system starts up. Each AHK script can hook into a single timer instance and can load it's own start-up variables (or run start-up actions). 

## Structure ##
* *launcher.ahk* - iterates through the scripts folder, looking for and loading functionality. Then, loads main.ahk.
* *main.ahk* - loads some static scripts, also loads the dynamically-created includes.ahk file 
includes.ahk - this file is dynamically created by launcher.ahk, and doesn't exist at the beginning (or in this repository)
* *scripts/application_Adobe_Acrobat.ahk* - see below
* *scripts/...* other .ahk files

The ./scripts/ folder is meant to hold whatever .ahk files should be loaded at boot/login time. One example (application_Adobe_Acrobat.ahk) is supplied here to demonstrate some of the concepts. 

## Usage ##
On Windows, set up a startup shortcut pointing to launcher.ahk. It will load the rest! 

This has only been tested on Windows 8/8.1/10. YMMV. 
