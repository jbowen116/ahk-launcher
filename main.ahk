;----- Common settings -----
#SingleInstance force
StringCaseSense On
AutoTrim OFF
Process Priority,,High
SetWinDelay 0
SetKeyDelay 20
SetBatchLines -1

SetTitleMatchMode, 2
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
IMAGEPATH := A_ScriptDir "\scripts\images\"

;----- Included scripts -----
#Include includes.ahk	; this file is deleted and then dynamically generated with each run of the 'launcher.ahk' script
#Include spelling.ahk	; this file is gigantic. It takes too long to parse it line by line as part of the launcher.ahk, so don't bother
ListHotkeys
pause
return

;---none of the rest of this file is needed to use the launcher.ahk concept. It can all be deleted. ---

;---- use caps-lock key as an activator for complex scripts. Use double-tap shift as caps-lock ----

;---- double-tap on the 'Shift' key to toggle caps-lock on the keyboard ----
Shift::
if (A_PriorHotkey = "Shift" and A_TimeSincePriorHotkey < 500) {
  if GetKeyState("CapsLock", "T") = 1 {
    SetCapsLockState, off
  } else {
    SetCapsLockState, on
  }
}
return

; use CapsLock as an activator key for all the other keys
; Activate whatever is at Gosub call_%keyPressed% 
CapsLock::
	TrayTip, Hotkeys, Waiting for command..., 2, 1	;notify user we're waiting for a key
	;SetTimer, waitForCommand, 2
	Input, keyPressed, T2 L1
	if (keyPressed){
			if (keyPressed = "a"){
				TrayTip, Hotkeys, App Menu Launched. Waiting for command..., 2, 1	; notify user we're waiting for another keystroke
				Input, keyPressed2, T2 L1
				TrayTip
				sLabel = call_app_%keyPressed2%
			}
			else{
				sLabel = call_%keyPressed%
			}
		TrayTip		
		;msgbox, Key pressed was %keyPressed%
		if IsLabel(sLabel) {
			Gosub, %sLabel%
		}
		else {
			TrayTip, Hotkeys, Invalid key pressed! ('%keyPressed%')
		}
	}
return
	
