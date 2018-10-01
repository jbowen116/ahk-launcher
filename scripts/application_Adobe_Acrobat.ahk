autoexec_application_Adobe_Acrobat:
{
	CoordMode, mouse,screen

	acrobat_approval_window_title = Save As
	; dcds_approval_window_title = Untitled ; <--- used notepad during test

	acrobat_approval_window_moved=0		; a flag to indicate the window has not been moved

	return
}

; set a timer that will move the little 'approval' window from the middle of the screen
; to the mouse location when it pops up. Convenience factor. Works! (sort of)
; borrowed heavily from thread: https://autohotkey.com/board/topic/99518-move-active-window-to-cursor-position/
timer_detectAcrobat_approval_window:
IfWinActive, %acrobat_approval_window_title%
{
    if acrobat_approval_window_moved = 0
    {
		BlockInput, Mouse
        MouseGetPos, xpos,ypos
        WinMove, %acrobat_approval_window_title%,, xpos-160, ypos-132
		BlockInput, Off
		
	acrobat_approval_window_moved = 1 ; set the flag because the window has been moved
    }
}
else
    acrobat_approval_window_moved=0 ; reset the flag for the next time the window is active
return
