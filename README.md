# ReticleOverlayer

## Description
AutoHotKey (AHK) script that displays an overlayed image in the center of the screen. Can be used e.g. for enhancing an in-game reticle with a custom image. This is achieved by creating an invisible, unclickable, always-on-top window that contains the image.

**Does not work in true fullscreen applications! Please instead use "borderless fullscreen" mode for usage in games.**

Includes library Gdip.ahk from https://github.com/tariqporter/Gdip to achieve correct semi-transparency as the native AHK Gui commands seem to not fully support it.

## Usage
Execute the compiled ReticleOverlayer.exe, or open the ReticleOverlayer.ahk source with your AHK installation, e.g. AutoHotkeyU32.exe. To terminate the script, right-click on the tray icon (violet crosshair for .exe, green H symbol for .ahk) in the taskbar -> Exit.

If not yet present, a .ini file is created in the script's directory on first start, containing the default settings. Please edit the parameter values in this file (after the = sign) to customize the behavior. Restart the script after saving the changes.

Description of .ini parameters:
- image_path: Full path to overlay image file, in quotes. A filename without full path also works when the image is in the script's directory.
- overlay_state: Initial state of reticle visibility at script startup (0=off, 1=on).
- x_offset: Manual X position offset from center (positive = more right, negative = more left).
- y_offset: Manual Y position offset from center (positive = lower, negative = higher).
- alpha_value: Total transparency of overlay. 0=invisible, 255=full opaque (normal), 1..254=semi-transparent.
- hotkey_string: Hotkey definition for overlay toggling. This is a global hotkey that toggles the reticle's visibility on/off. The default (^NumpadAdd) means Ctrl - Numpad+. Leave empty to disable the hotkey (and set overlay_state=1, else nothing will be ever shown). See https://documentation.help/AutoHotKey-Functions/Hotkeys.htm#Symbols and https://documentation.help/AutoHotKey-Functions/KeyList.htm for hotkey syntax.
- toggle_beep: Sound beeps on overlay toggling (0=off, 1=on). May be useful to check whether the hotkey works.


Notes about the image:
- Image type can be .png or .ico. (Maybe also other image types work, but not tested yet.) Do not use .jpg because this doesn't support an alpha channel for selective transparency.
- Image is shown unscaled, so an image size of 100x100 will also be 100x100 px on screen.
- For optimal centered placement, use an image with even pixel numbers for width and height (e.g. 70x64), and make sure the reticle center is in the middle of the image.
- If the reticle is not shown where you want, you can set x_offset/y_offset to adjust the placement.
