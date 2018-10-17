/*
Gmod Macros
	A collection of AutoHotkey functions intended for use in day-to-day Garry's mod play.
NOTES:
	Script was designed with a 1600x900 game window in mind.
		Window coordinates for ImageSearch are offset by +2 pixels on the X axis.
	MaxNet console command delay seems to be reliable at minimum 1250ms.
		Apparently becomes unreliable when submitting commands at 1250ms delay when more than 30-40 players online.
TODO:
	Implement dynamic coordinates for ImageSearch across different window sizes.
*/

#SingleInstance,ignore
#InstallKeybdHook
#InstallMouseHook
Version = 0.0.2
Menu,Tray,Tip,Gmod Macros v.%Version%
Menu,Tray,Icon, Sprites/Gmod.ico

/*
	/=======================================================================\
	|Administrator Privilege Check
	\=======================================================================/
*/
if !A_IsAdmin {
	;Ask user if we want to relaunch the script as Administrator.
	MsgBox, 36, Relaunch as admin?, The script needs to be run as administrator in order to send keyboard presses and mouse input.`n`nShall we relaunch the script as administrator for you?`n(If not`, we'll just exit the script.)
	IfMsgBox,Yes
	{
		;Launch a new instance of the script, this time with admin privilege.
		Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
		;Close this unprivileged instance, as it's no longer needed.
		ExitApp
	}
	IfMsgBox,No
	{
		ExitApp
	}
}

/*
	/=======================================================================\
	|Hotkeys
	|Joystick Keys Legend:
	|	Joy1: A
	|	Joy2: B
	|	Joy3: X
	|	Joy4: Y
	|	Joy5: LShoulder
	|	Joy6: RShoulder
	|	Joy7: Select
	|	Joy8: Start
	|	Joy9: LThumbClick
	|	Joy10: RThumbClick
	|	vk07sc000: Guide Button (Does this even work in Windows 10?)
	\=======================================================================/
*/
Pause:: Pause
+F12:: Reload
^+F12:: ExitApp

/*
	/=======================================================================\
	|Utility Functions
	|For script testing & etc.
	\=======================================================================/
*/
ImageSearchTest(){
	WinGetActiveStats,gameTitle,gameWidth,gameHeight,gameX,gameY
	;Note the "+2" on the coords - this is due to the windowed mode of the game having an offset of 2px on the x-axis...
	;If pulling coordinates from screenshots, make sure to take this into account.
	ImageSearch,blahX,blahY,737+2,467,863+2,483, *150 Sprites/SpriteFileName.fw.png
	if !ErrorLevel
		ToolTip,Found at %blahX%`,%blahY%,gameWidth/2,0
	if ErrorLevel
		ToolTip,NOT FOUND,gameWidth/2,0
	return
}

RepositionGameWindow(){
	LaunchGmod()
	WinMove,0,0
	return
}

SoundTest(){
	SoundPlay,Sounds/InceptionNoise.mp3
	return
}

/*
	/=======================================================================\
	|Main Functions
	\=======================================================================/
*/
ReportDeathAsRDM(indicateAFK:=true){ ;Quickly fires off an admin chat message, reporting RDM.
	;~ Optionally indicates that player was AFK at time of death; useful for scripted functionality where player is AFK, but wants to report any death.
	;TODO: Add additional functionality to handle Admin Sit menu if it appears. (Unsure whether its absence after @-message is a bug.)
	Menu,Tray,Icon, Sprites/GmodActive.ico
	WinGetActiveStats,gameTitle,gameWidth,gameHeight,gameX,gameY
	FormatTime, timeString, A_NowUTC,hh:mm:ss tt
	if indicateAFK {
		deathMessageString=% "@ AutoReport: RDM'd at " . timeString . " UTC; was AFK at time of death."
	} else {
		deathMessageString=% "@ RDM'd at " . timeString . " UTC"
	}
	Loop {
		SendInput,y
		ToolTip,Opening chatbox (Attempt %A_Index%)...,gameWidth/2,0
		Sleep,2000
	} until CheckForChatBox(false)
	SendInput,%deathMessageString%{Enter}
	Menu,Tray,Icon, Sprites/Gmod.ico
	ToolTip
	return
}

CheckForChatBox(closeChat:=true){ ;Checks to see if chat box is active, returning true/false, and optionally closes it. (Returns false once sucessfully closed. Returns true if not able to close.)
	WinGetActiveStats,gameTitle,gameWidth,gameHeight,gameX,gameY
	ImageSearch,blahX,blahY,40+2,741,71+2,752, *80 Sprites/ChatBoxActive.fw.png
	if !ErrorLevel {
		if closeChat {
			chatPresentTimestamp:=A_TickCount
			Loop {
				if ((A_TickCount - chatPresentTimestamp) > 30000){ ;Just return true if we weren't able to close the chatbox within 30s.
					return true
				}
				SendInput,{Esc}
				ToolTip,Closing chatbox (Attempt %A_Index%)...,gameWidth/2,0
				Sleep,2000
				ImageSearch,blahX,blahY,40+2,741,71+2,752, *80 Sprites/ChatBoxActive.fw.png
			} until ErrorLevel
			ToolTip
			return false
		} else {
			return true
		}
	} else {
		return false
	}
	return
}

/*
	/=======================================================================\
	|Beta Functions
	|	Experimental features under development.
	\=======================================================================/
*/