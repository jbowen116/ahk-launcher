
; This launcher script iterates through a folder, looking for other .ahk scripts. It will dynamically build an 'includes.ahk' AHK file, made mostly of #Include
; statements. Once the includes.ahk file is written (by this script), control is handed off to main.ahk, which will #Include the includes.ahk file, thereby 
; including the whole collection of AHK files. This script should be launched at every login, to assure a fresh copy of all the scripts in 'includeFolder'. 

; Within each included AHK file, it also has the ability to handle two special kinds of labels: 
; 
; autoexec_* labels - will automatically be included as if they are their own autoexecute section. This allows each script to have its own 
;								collection of commands at startup - load variables, read .ini files, etc.
; timer_* labels - will automatically be included in a single/common timer event, loaded in the main script. This prevents each loaded script from 
; 						  	needing its own timer in an autoexec_ section. One timer, multiple timed events! 
; 
; To trigger either of the above kinds of labels, you just need to name them properly. 


includeFolder = %A_ScriptDir%\scripts  ; the folder to search for .ahk files - modify this to meet your needs
includeFileName = includes.ahk		; the name of the 'temporary' file that will be created every time this launcher.ahk script runs. 

; loop through and get all the files we want to load via #Include statements
Loop, Files, %includeFolder%\*.ahk, R		; iterate over all the .ahk files in the 'includeFolder', recursively into subfolders if necessary
	fileList = %fileList%%A_LoopFileName%`n	; for each .ahk file found, add it to the list of files we want to load
	
StringTrimRight, fileList, fileList, 1	; trim off the last `n
;MsgBox, 0, Title, % fileList	; for testing
StringReplace, fileText, fileList, `n, `n#Include%A_Space%%includeFolder%\, A	; turn all the `n 's into #Include statements

fileText := "#Include " includeFolder "\" fileText ; start assembling the text for our 'include' file
;fileText := "Msgbox, Loading includes.ahk`n`n" fileText
fileText := ";-- Include all the files found in the ./scripts folder --`n" fileText

; set a timer for 400ms (0.4 seconds). This will be used by loaded scripts to look for active windows and act on them later
fileText := "SetTimer,detectApps,300`n`n" fileText			
fileText := "`n;--- Create a timer for included scripts that need one --`n" fileText

; loop through all the included files and look for autoexec functions to run
Loop, Files, %includeFolder%\*.ahk, R
{
	scriptFilesFound += 1
	Loop					; after we find a file, loop through all of its lines looking for special situations
	{
				
		FileReadLine, line, %includeFolder%\%A_LoopFileName%, %A_Index%
		if ErrorLevel
			break
		if (Substr(line,1,2) = "::") {		; gather the total number of hotscripts loaded
			hotScriptsFound += 1
		}
		if (SubStr(line,1,9) = "autoexec_") {						; find labels to 'auto-execute' at startup
			autoExecSectionsFound += 1								; count the number of autoexec sections we're loading
			StringReplace, line, line, :							; trim off the colon that's at the end of the label's line
			;Msgbox, In file %A_LoopFileName%, line hit: %line%
			autoExecSection := "gosub, " line "`n" autoExecSection	; add it to the autoexec section
		}
		if (SubStr(line,1,6) = "timer_") {							; find labels to include in a timer event
			timersFound += 1										; count the total number of timers loaded
			StringReplace, line, line, :							; trim off the colon that's at the end of the line
			timerSection := "   gosub, " line "`n" timerSection		; add a hook/call for the timer to our timer section
		}
	}
	;MsgBox, The end of the file has been reached or there was a problem.
}

timerSection := "detectApps:`n{`n" timerSection		; build the label to lead-in the timer section
timerSection := timerSection "   return`n}"			; close out the timer section label with a return/line break and bracket
fileText := fileText "`n`nreturn"					; close out the autoexec section of the file with a return/line break

fileText := autoExecSection fileText				; prepend the autoexec content for the included files
fileText := ";-- AutoExecute labels found in the included files --`n" fileText		; add a comment to explain the autoexec section of the file

; these next five lines just build a TrayTip that will display when the scripts are done loading, to show some stats about what was loaded
fileText := "`nTrayTip, Scripts Ready, Total Scripts: %scriptFilesFound%``nAutoExec Sections: %autoExecSectionsFound%``nTimers Set: %timersFound%``nHotscripts: %hotScriptsFound%, 10`n`n" fileText 
fileText = timersFound := %timersFound% `n%fileText%
fileText = hotScriptsFound := %hotScriptsFound% `n%fileText%
fileText = autoExecSectionsFound := %autoExecSectionsFound% `n%fileText%
fileText = scriptFilesFound := %scriptFilesFound% `n%fileText%

; add a warning to the top of the file, to prevent someone accidentally editing it by hand
fileText := ";--- THIS FILE IS CONSTRUCTED AUTOMATICALLY ---`n;----- MANUAL CHANGES WILL BE OVERWRITTEN -----`n`n`n" fileText

fileText := fileText "`n`n" timerSection			; append the timerSection content (label and whole 'function')

; write the fileText out to the file for use later
file := FileOpen(includeFileName,"w")

if !IsObject(file) 	; if we can't open the file for writing, throw an error
{
	MsgBox Can't open "%includeFileName%" for writing. Can't load scripts! 
	return
}

;MsgBox, 0, Title, % fileText
file.Write(fileText)	; write the includes.ahk file to disk
file.Close()			; close the written file

Run main.ahk			; call main.ahk, which "Includes" the brand-new includes.ahk file