; Displays an overlayed image in the center of the screen. Can be used e.g. for enhancing an in-game reticle with a custom image.

#SingleInstance force
#Persistent
#NoEnv

#Include, Gdip.ahk	; include GDI+ functions


; ########## Variables ##########
configfile := "ReticleOverlayer.ini"

; (Strings for default values must be without "" here)
IniRead, image_path, %configfile%, Parameters, image_path, C:\yourpath\yourpic.png	; full path to overlay image file
IniRead, overlay_state, %configfile%, Parameters, overlay_state, 1	; initial state of reticle visibility at script startup (0=off, 1=on)
IniRead, x_offset, %configfile%, Parameters, x_offset, 0	; manual X position offset from center
IniRead, y_offset, %configfile%, Parameters, y_offset, 0	; manual Y position offset from center
IniRead, alpha_value, %configfile%, Parameters, alpha_value, 255	; transparency of overlay. 0=invisible, 255=full opaque, 1..254=semi-transparent
IniRead, hotkey_string, %configfile%, Parameters, hotkey_string, +NumpadAdd	; hotkey for overlay toggle
IniRead, toggle_beep, %configfile%, Parameters, toggle_beep, 0	; sound beeps on overlay toggling (0=off, 1=on)

if (not FileExist(configfile))	; create default .ini file
{
	IniWrite, %image_path%, %configfile%, Parameters, image_path
	IniWrite, %overlay_state%, %configfile%, Parameters, overlay_state
	IniWrite, %x_offset%, %configfile%, Parameters, x_offset
	IniWrite, %y_offset%, %configfile%, Parameters, y_offset
	IniWrite, %alpha_value%, %configfile%, Parameters, alpha_value
	IniWrite, %hotkey_string%, %configfile%, Parameters, hotkey_string
	IniWrite, %toggle_beep%, %configfile%, Parameters, toggle_beep
	MsgBox, 64, New INI file, Please edit the file %configfile%
}

; ########## Initialization ##########
OnExit, Exit	; use label Exit on exiting app

if (hotkey_string != "")
	Hotkey, %hotkey_string%, HotkeyToggle, On	; create hotkey for toggling overlay

If !pToken := Gdip_Startup()	; Start gdi+
{
	MsgBox, 48, GDI+ error!, GDI+ failed to start. Please ensure you have GDI+ on your system
	ExitApp
}

; Create a layered window with following parameters:
; +AlwaysOnTop: overlayed above all other windows
; +ToolWindow: avoids a taskbar button and an alt-tab menu item
; -Caption: remove the border and title bar
; E: ExStyle (https://docs.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles )
;   0x80000 WS_EX_LAYERED: This must be used for UpdateLayeredWindow to work
;   0x20 WS_EX_TRANSPARENT: makes the window invisible to mouse clicks ("click-through")
; (-SysMenu is obsolete due to -Caption, +Disabled is seemingly not needed with WS_EX_TRANSPARENT.)
Gui, New, +AlwaysOnTop +ToolWindow -Caption +E0x80020 +LastFound +OwnDialogs, ReticleOverlay
Gui, Margin, 0, 0
Gui, Show, NA	; "Show" the window (nothing to see). NA: avoids deactivating the currently active window. This Show is needed, else toggling doesn't work later! Don't know why exactly.
if (overlay_state = 0)
	Gui, Hide
hwnd1 := WinExist(ReticleOverlay)	; Get a handle to this window we have created in order to update it later


pBitmap := Gdip_CreateBitmapFromFile(image_path)	; Get a bitmap from the image
if !pBitmap	; Check to ensure we actually got a bitmap from the file, in case the file was corrupt or some other error occured
{
	MsgBox, 48, File loading error!, Could not load %image_path%, please correct it in %configfile%
	ExitApp
}

; Get the width and height of the bitmap we have just created from the file.
; Also calculate the top-left anchor position for centered displaying.
w_reticle := Gdip_GetImageWidth(pBitmap)
h_reticle := Gdip_GetImageHeight(pBitmap)
x_reticle := A_ScreenWidth / 2 - w_reticle / 2 + x_offset
y_reticle := A_ScreenHeight / 2 - h_reticle / 2 + y_offset

; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything. We are creating this "canvas" with the size of the actual image (but could be different).
hbm := CreateDIBSection(w_reticle, h_reticle)
hdc := CreateCompatibleDC()	; Get a device context compatible with the screen
obm := SelectObject(hdc, hbm)	; Select the bitmap into the device context
graph := Gdip_GraphicsFromHDC(hdc)	; Get a pointer to the graphics of the bitmap, for use with drawing functions

; DrawImage will draw the bitmap we took from the file into the graphics of the bitmap we created.
; We want to draw the entire image at original size.
; Coordinates are therefore taken from (0,0) of the source bitmap and also into the destination bitmap.
; The source width and height are omitted (=defaults), only the destination width and height are specified.
; Gdip_DrawImage(pGraphics, pBitmap, dx, dy, dw, dh, sx, sy, sw, sh, Matrix)  (d=destination, s=source)
Gdip_DrawImage(graph, pBitmap, 0, 0, w_reticle, h_reticle)

; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc),
; specifying the x,y,w,h we want it positioned on our screen.
UpdateLayeredWindow(hwnd1, hdc, x_reticle, y_reticle, w_reticle, h_reticle, alpha_value)

SelectObject(hdc, obm)	; Select the object back into the hdc
DeleteObject(hbm)	; Now the bitmap may be deleted
DeleteDC(hdc)	; Also the device context related to the bitmap may be deleted
Gdip_DeleteGraphics(graph)	; The graphics may now be deleted
Gdip_DisposeImage(pBitmap)	; The bitmap we made from the image may be deleted
Return


; ########## Jump Labels ##########
HotkeyToggle:
	overlay_state := not overlay_state	; toggle reticle visibility
	if (overlay_state)
	{
		Gui, %hwnd1%: Show, NA	; specific hwnd needed, else ahk uses a different Gui (maybe that of the main script?)
		if (toggle_beep)
		{
			SoundBeep, 440, 100
			SoundBeep, 660, 100
		}
	}
	else
	{
		Gui, %hwnd1%: Hide
		if (toggle_beep)
		{
			SoundBeep, 660, 100
			SoundBeep, 440, 100
		}
	}
Return


Exit:
	Gdip_Shutdown(pToken)	; gdi+ may now be shutdown on exiting the program
	ExitApp
Return
