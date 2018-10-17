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
;~ Script control hotkeys.
Pause:: Pause
+F12:: Reload
^+F12:: ExitApp

;Global hotkeys.
F5:: LaunchGmod()
F6:: PingCivilCityServer()

;Ingame hotkeys.
#IfWinActive:: Garry's Mod ahk_class Valve001 ahk_exe hl2.exe
NumpadSub:: HoldMouseButton("LButton") ;Holds the left mouse button down.
F8:: ReportDeathAsRDM(false) ;Manual hotkey to report RDM.

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

PingCivilCityServer(){
	;Fire up a quick command propmpt, pinging the game server until closed.
	;Useful to quickly figure out if the server is reachable from clientside.
	Run,cmd /C "ping cc.civilservers.net -n -1"
	return
}

LaunchGmod(){ ;Checks if Gmod is running, and if not, offers to launch it. If the window is present, but hidden, it will bring it to the front, and snap it to the top-left corner of the screen.
	IfWinNotExist,Garry's Mod ahk_class Valve001 ahk_exe hl2.exe
	{
		MsgBox, 36, Launch Garry's Mod?, There is no instance of Garry's Mod running.`nShould we launch it and connect to Civil City RP?
		IfMsgBox,Yes
			Run,steam://connect/cc.civilservers.net:27015/
		IfMsgBox,No
			return
	}
	IfWinExist,Garry's Mod ahk_class Valve001 ahk_exe hl2.exe
	{
		IfWinNotActive,Garry's Mod ahk_class Valve001 ahk_exe hl2.exe
		{
			ToolTip,Activating game window...,0,0
			WinActivate,Garry's Mod ahk_class Valve001 ahk_exe hl2.exe
			WinWaitActive,Garry's Mod ahk_class Valve001 ahk_exe hl2.exe
			RepositionGameWindow()
			ToolTip
		}
	}
	return
}

/*
	/=======================================================================\
	|Main Functions
	\=======================================================================/
*/
HoldMouseButton(mouseButton:="LButton"){
	;Holds down specified mouse button. Great for mining with a pickaxe or repairing a car, since it requires you to hold down the mouse button for a long time.
	SendInput,{%mouseButton% Down}
	Sleep,64
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

CheckIfDead(respawn:=false, irrelevantDeath:=false,reportDeathToAdmins:=false){
	;~ Checks if player is dead, returning true/false. If so, optionally respawn.
	;~ (Returns false once successfully respawned. Returns true if unable to respawn.
	;~ irrelevantDeath argument will optionally return true even if we respawn. Optionally reports death as RDM to admins.)
	WinGetActiveStats,gameTitle,gameWidth,gameHeight,gameX,gameY
	ImageSearch,blahX,blahY,693+2,414,905+2,441, *80 Sprites/YouAreDeadPendingRespawn.fw.png
	if !ErrorLevel {
		;~ Scare the player to get their attention back on the game window.
		SoundPlay,Sounds/InceptionNoise.mp3
		if respawn {
			deathTimestamp:=A_TickCount
			ToolTip,Waiting for respawn timer...,gameWidth/2,0
			Loop { ;Wait for the respawn timer...
				ImageSearch,blahX,blahY,737+2,467,863+2,483, *150 Sprites/YouAreDeadReadyToRespawn.fw.png
			} until !ErrorLevel
			ToolTip,Attempting to respawn...,gameWidth/2,0
			Loop { ;Press Space until we respawn. Bail out if we can't respawn within 30s.
				if ((A_TickCount - deathTimestamp) >= 30000) { ;Just return true if we weren't able to respawn within 30s.
					if reportDeathToAdmins
						ReportDeathAsRDM(false)
					return true
				}
				SendInput,{Space}
				Sleep,2000
				ImageSearch,blahX,blahY,693+2,414,905+2,441, *80 Sprites/YouAreDeadPendingRespawn.fw.png
			} until ErrorLevel
			ToolTip
			if !irrelevantDeath {
				if reportDeathToAdmins
					ReportDeathAsRDM(false)
				return true
			} else {
				if reportDeathToAdmins
					ReportDeathAsRDM(false)
				return false
			}
		} else {
			if reportDeathToAdmins
				ReportDeathAsRDM(false)
			return true
		}
	} else {
		if !irrelevantDeath {
			if reportDeathToAdmins
				ReportDeathAsRDM(false)
			return false
		} else {
			if reportDeathToAdmins
				ReportDeathAsRDM(false)
			return true
		}
	}
	return
}

ReportDeathAsRDM(indicateAFK:=true){ ;Quickly fires off an admin chat message, reporting RDM.
	;~ Optionally indicates that player was AFK at time of death; useful for scripted functionality where player is AFK, but wants to report any death.
	;~ TODO: Add additional functionality to handle Admin Sit menu if it appears. (Unsure whether its absence after @-message is a bug.)
	;~ TODO: Possible to retrieve name of person comitting RDM from the console? RegEx the last few recent lines for an "x killed player" message?
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

/*
	/=======================================================================\
	|Beta Functions
	|	Experimental features under development.
	\=======================================================================/
*/