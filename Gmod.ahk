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

;~ Function Test Hotkey:
F12:: MNDecrypt("AwMOGQsGNh0RSwIBBjESFlMDAHMKARMKFjZL","SooperSeekritPasswo") ;Max password length is 19char?
;~ Plaintext: Plaintext phrase to encode.
;~ Key: SooperSeekritPasswo
;~ Ciphertext: AwMOGQsGNh0RSwIBBjESFlMDAHMKARMKFjZL

;Global hotkeys.
F5:: LaunchGmod()
F6:: PingCivilCityServer()
Joy4:: VCMinerManager(true,false) ;(Single-use on-demand trigger of VCMiner restart, intended for game controller use when reclined, away from keyboard. Will bring focus back to active window when done. (My favorite mode.))

;Ingame hotkeys.
#IfWinActive:: Garry's Mod ahk_class Valve001 ahk_exe hl2.exe
NumpadDiv:: HashDecoder()
NumpadSub:: HoldMouseButton("LButton") ;Holds the left mouse button down.
F7:: DropBalance(true) ;Drops currently held /balance, and optionally makes a quick call to cops.
F8:: ReportDeathAsRDM(false) ;Manual hotkey to report RDM.
F9:: MaxNetConfigurator("DerpyWhooves","block",true,"761RPX88W6U16RNG33784B3A5Y34HUDH") ;Configures MaxNet terminal after deployment, BLOCKING outbound hacks. (assumes console program is onscreen).
+F9:: MaxNetConfigurator("DerpyWhooves","allow",true,"761RPX88W6U16RNG33784B3A5Y34HUDH") ;Configures MaxNet terminal after deployment, ALLOWING outbound hacks.(assumes console program is onscreen).
F10:: BitMinerFueler() ;Keeps bitminer fueled. (This is just a stupid fueler; it won't defend your base for you. Don't run this AFK.)
F11:: VCMinerManager(true,false) ;Triggers a single-use manual restart of VCMiners.
+F11:: VCMinerManager(false,true) ;Starts AFK management of VCMiners (for extended breaks like laundry, officework, etc).

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

CheckIfDisconnected(reconnect:=false,irrelevantDisconnection:=false){
	WinGetActiveStats,gameTitle,gameWidth,gameHeight,gameX,gameY
	ImageSearch,blahX,blahY,631+2,464,776+2,473, *80 Sprites/LostConnectionToServer.fw.png
	if !ErrorLevel {
		SoundPlay,Sounds/InceptionNoise.mp3
		if reconnect {
			Run,steam://connect/cc.civilservers.net:27015/
			;TODO: Add functionality to determine that we actually make it back into the game after attempting to reconnect
			if !irrelevantDisconnection { ;Return true even if we were able to reconnect.
				return true
			} else {
				return false
			}
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

DropBalance(callPolice:=false){ ;A quick-response money dropper for use in mugging scenarios. Optionally places a quick call to police.
	Menu,Tray,Icon, Sprites/GmodActive.ico
	SendInput,{NumpadDiv}
	Loop { ;Open chatbox.
		if CheckForChatBox(false)
			break
		SendInput,y
		Sleep,1000
	}
	Loop { ;Find our balance in chat. (Note that this uses the first appearance of a /balance message. TODO: rework to use the latest /balance message.)
		ImageSearch,balanceX,balanceY,45+2,576,173+2,705,*80 Sprites/BalanceChatMessage.fw.png
	} until !ErrorLevel
	MouseClick,Left,balanceX+143,balanceY+5,2
	Sleep,256
	SendInput,{LCtrl Down}
	Sleep,64
	SendInput,c
	Sleep,64
	SendInput,{LCtrl Up}
	balanceValue:=SubStr(Clipboard,2)
	MouseClick,Left,100,746
	Sleep,256
	SendInput,/dropmoney %balanceValue%{Enter}
	Sleep,1025
	SendInput,{NumpadDiv}
	if callPolice{
		SendInput,5
		Sleep,64
		MouseClick,Left
		Sleep,128
		MouseClick,Right
		Loop {
			ImageSearch,ePhoneTitleX,ePhoneTitleY,734+2,408,763+2,417, *150 Sprites/PhoneMenuTitle.fw.png
		} until !ErrorLevel
		Sleep,64
		MouseClick,Left,ePhoneTitleX+67,ePhoneTitleY+103
		Sleep,128
		SendInput,2
		Sleep,64
		MouseClick,Left
		return
	}
	Menu,Tray,Icon, Sprites/Gmod.ico
	return
}

HashDecoder(){
	global ;Necessary to work with clipboard values.
	Clipboard := "" ;Clear the clipboard for use.
	;~ TODO: Work on adding number values to the caesar cipher (they remain unchanged by the process, so just pass them through).
	;~ TODO: Add a check to make sure our MaxNet command prompt is open, so we can actually copy/paste values to/from it. (Immediately do nothing if it's not open.)
	encryptedString := "" ;Clear a variable for use.
	;~ Select everything in a text box, and hit Ctrl+C to copy it.
	SendInput,{Ctrl down}
	Sleep,64
	SendInput,a
	Sleep,64
	SendInput,c
	Sleep,64
	SendInput,{Ctrl up}
	ClipWait,2 ;Wait for the copied text to appear in the clipboard.
	
	;If we're just dealing with unicode character codes, jump straight to running it through a Chr().
	UnicodeRegEx := RegExMatch(Clipboard,"([\d]{1,3})+")
	if UnicodeRegEx
		goto UnicodeDecoder

	CaesarDecoder: ;Shift a set of characters by 28 (or -1) positions.
	key = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	Loop, Parse, Clipboard
	{
		if A_LoopField == "A"
		{
			;Wrap uppercase Z's to A.
			encryptedString .= "Z"
			continue
		}
		if A_LoopField == "a"
		{
			;Wrap lowercase z's to a.
			encryptedString .= "z"
			continue
		}
		;~ Append the letter 28 positions down from the hashed letter to the encryptedString.
		encryptedString .= SubStr(key, Mod(Instr(key, A_LoopField, True) -1, StrLen(key)), 1)
	}
	goto, OutputString
	
	UnicodeDecoder:
	Loop, Parse, Clipboard,`,
	{
		encryptedString .= Chr(A_LoopField)
	}
	
	OutputString:
	;Paste the results of our decoded string, so we can decide what to do with it.
	Clipboard := encryptedString
	Sendinput,{Ctrl down}
	Sleep,64
	Sendinput,v
	Sleep,64
	Sendinput,{Ctrl up}
	Sleep,64
	return
}

/*
	/=======================================================================\
	|Dubious Functions
	|	Features that are likely to be seen seen as cheating ingame, and should not be used except for experiments.
	\=======================================================================/
*/
AntiAFK(){ ;Prevents most AFK-detection mechanisms from registering you as idle in roles that are stationary, and often idle.
	;This is designed to be used while sitting; it will toggle third person, instead of you being seen repeatedly crouching.
	;Intended for use as roles that are AFK-limited, but have periods where it may seem like player is AFK, i.e.: sitting at desk as mayor.
	;	Apparently the system will auto-demote you even while talking to others, and looking around, etc. Seems to be based on x/y/z movement.
	;	Since roles will auto-demote if player stands still, desk roles often end up in false demotions. This is an attempt to resolve that.
	;Not intended to facilitate actual AFK players, but rather to remedy the pains of true roleplayers. (Deskbound mayors, gov't agents, etc.)
	Menu,Tray,Icon, Sprites/GmodActive.ico
	Loop {
		WinGetActiveStats,gameWinTitle,gameWinWidth,gameWinHeight,gameWinX,gameWinY
		IfWinNotActive,Garry's Mod ahk_class Valve001 ahk_exe hl2.exe
		{
			ToolTip
			break
		}
		ToolTip,Toggling thirdperson view...,gameWidth/2,0
		SendInput, {Ctrl Down}
		Random,buttonToggleWait,500,750
		Sleep,buttonToggleWait
		SendInput, {Ctrl Up}
		Random,buttonToggleWait,1000,2000
		Sleep,buttonToggleWait
		SendInput, {Ctrl Down}
		Random,buttonToggleWait,500,750
		Sleep,buttonToggleWait
		SendInput, {Ctrl Up}
		Sleep,64
		Random,waitTime,180000,200000
		ToolTip,Delaying %waitTime%ms before toggling thirdperson view...,gameWidth/2,0
		Sleep,waitTime
	}
	return
}

MaxNetConfigurator(routerPassword:="SooperSeekritPassword",blockOrAllowOutboundHacks:="block",configMiners:=true, walletAddress:="761RPX88W6U16RNG33784B3A5Y34HUDH"){ ;Expedites the router configuration for MaxNet deployment.
	Menu,Tray,Icon, Sprites/GmodActive.ico
	WinGetActiveStats,gameTitle,gameWidth,gameHeight,gameX,gameY
	MouseClick,Left
	ToolTip,Waiting for MaxNet console...,gameWidth/2,0
	Loop{
		ImageSearch,blahX,blahY,674+2,438,711+2,447, *80 Sprites/MaxNetConsoleBoxTitle.fw.png
	} until !ErrorLevel
	ToolTip,Configuring MaxNet settings...,gameWidth/2,0
	if configMiners {
		Sendinput,vcmine set_wallet %walletAddress%{Enter}
		Sleep,1500
		Sendinput,vcmine start{Enter}
		Sleep,1500
	}
	Sendinput,router settings admin_password %routerPassword%{Enter}
	Sleep,1500
	Sendinput,router login %routerPassword%{Enter}
	Sleep,1500
	Sendinput,cls{Enter}
	Sleep,1500
	Sendinput,router settings hide_terminals true{Enter}
	Sleep,1500
	Sendinput,router firewall block MN_PROTOCOL_REMOTE{Enter}
	Sleep,1500
	Sendinput,router firewall block MN_PROTOCOL_REMOTE_ATTEMPT{Enter}
	Sleep,1500
	Sendinput,router firewall block MN_PROTOCOL_REMOTE_COMMAND{Enter}
	Sleep,1500
	Sendinput,router firewall block MN_PROTOCOL_MESSAGE{Enter}
	Sleep,1500
	Sendinput,router firewall block MN_PROTOCOL_MANAGER_SCAN{Enter}
	Sleep,1500
	Sendinput,router firewall %blockOrAllowOutboundHacks% MN_PROTOCOL_REMOTE out{Enter}
	Sleep,1500
	Sendinput,router firewall %blockOrAllowOutboundHacks% MN_PROTOCOL_REMOTE_ATTEMPT out{Enter}
	Sleep,1500
	Sendinput,router firewall %blockOrAllowOutboundHacks% MN_PROTOCOL_REMOTE_COMMAND out{Enter}
	Sleep,1500
	Sendinput,router firewall %blockOrAllowOutboundHacks% MN_PROTOCOL_MESSAGE out{Enter}
	Sleep,1500
	Sendinput,router firewall %blockOrAllowOutboundHacks% MN_PROTOCOL_MANAGER_SCAN out{Enter}
	Sleep,1500
	Sendinput,router settings firewall_enabled true{Enter}
	Sleep,1500
	Sendinput,firewall block MN_PROTOCOL_REMOTE{Enter}
	Sleep,1500
	Sendinput,firewall block MN_PROTOCOL_REMOTE_ATTEMPT{Enter}
	Sleep,1500
	Sendinput,firewall block MN_PROTOCOL_REMOTE_COMMAND{Enter}
	Sleep,1500
	Sendinput,firewall block MN_PROTOCOL_MESSAGE{Enter}
	Sleep,1500
	Sendinput,firewall block MN_PROTOCOL_MANAGER_SCAN{Enter}
	Sleep,1500
	Sendinput,firewall enable{Enter}
	Sleep,1500
	Sendinput,router settings admin_password %routerPassword%{Enter} ;Setting the password a second time here secures the router so that raiders can't divulge it through subsequent use of "router settings" on an unlocked pc.
	Sleep,1500
	Sendinput,cls{Enter}
	Sleep,64
	SendInput,{LAlt Down}
	Sleep,64
	SendInput,{LAlt Up}
	ToolTip
	Menu,Tray,Icon, Sprites/Gmod.ico
	return
}

BitMinerFueler(){ ;Automatically keeps generator fueled. (Intended to be run with an empty generator on start.)
	Menu,Tray,Icon, Sprites/GmodActive.ico
	WinGetActiveStats,gameTitle,gameWidth,gameHeight,gameX,gameY
	Loop {
		Loop,4
		{
			CheckForChatBox(true) ;Close the chatbox if open; we can't use our keybind for /buybitminerfuel if it's open.
			if CheckIfDead(true,false,false) {
				ToolTip,Player died at %A_Now%,gameWidth/2,0
				Menu,Tray,Icon, Sprites/Gmod.ico
				return
			}
			ToolTip,Fueling... (%A_Index%x),gameWidth/2,0
			Sendinput,v ;Change this to whatever key is bound to /buybitminerfuel
			if (A_Index < 4) { ;Delays in between each spawning of fuel. (Except for after fourth one, since we don't need to respawn a fifth.)
				Sleep 3000
			}
		}
		CheckForChatBox(true)
		if CheckIfDead(true,false,false) {
			ToolTip,Player died at %A_Now%,gameWidth/2,0
			Menu,Tray,Icon, Sprites/Gmod.ico
			return
		}
		ToolTip,Waiting to refuel...,gameWidth/2,0
		Sleep,241000 ;(Basically, 250s, minus the amount of time it actually takes to spawn the four fuel cans.)
	}
	ToolTip
	Menu,Tray,Icon, Sprites/Gmod.ico
	return
}

VCMinerManager(ManualToggle=false, keepGameFocused:=true){
	;Basic AFK VCMiner management. Keeps VCMiners running. Best used while sitting in a chair prop, looking at the screen, and with keys equipped. (Can't use MaxNet computer while sitting if you have grav/physgun equipped.)
	Menu,Tray,Icon, Sprites/GmodActive.ico
	WinGetActiveStats,gameTitle,gameWidth,gameHeight,gameX,gameY
	ToolTip
	Loop {
		IfWinNotActive,Garry's Mod ahk_class Valve001 ahk_exe hl2.exe
		{
			if (!keepGameFocused) { ;If Gmod is not the aactive window, take note of the window that is active so we can return to it later.
				WinGetActiveStats,activeWinTitle,activeWinWidth,activeWinHeight,activeWinX,activeWinY
			}
			LaunchGmod()
		}
		CheckForChatBox(true)
		if CheckIfDead(true,false,false) {
			ToolTip,Player died at %A_Now%,gameWidth/2,0
			Menu,Tray,Icon, Sprites/Gmod.ico
			return
		}
		if CheckIfDisconnected(true,false) {
			ToolTip,Disconnected at %A_Now%...,gameWidth/2,0
			Menu,Tray,Icon, Sprites/Gmod.ico
			return
		}
		ToolTip,Starting VCMiners...,gameWidth/2,0
		MouseClick,Left ;Unlock the MaxNet terminal, and show the command prompt.
		Loop{
			ImageSearch,blahX,blahY,674+2,438,711+2,447, *80 Sprites/MaxNetConsoleBoxTitle.fw.png
		} until !ErrorLevel
		Sendinput,vcmine start{Enter}
		Sleep,1500
		Sendinput,lock{Enter}
		Sleep,64
		SendInput,{LAlt Down} ;Close the MaxNet command prompt.
		Sleep,64
		SendInput,{LAlt Up}
		Sleep,512
		SendInput,{NumpadMult} ;Press keybind for "stopsound." Handy for watching videos on second screen.
		ToolTip
		if ManualToggle {
			Menu,Tray,Icon, Sprites/Gmod.ico
			if (!keepGameFocused) {
				WinActivate,%activeWinTitle%
			}
			return
		}
		if CheckIfDead(true,false,false) { ;We run an additional death check here, in case death occurred while MaxNet computer was in use. (Possible scenario of someone camping the player, waiting for computer to be unlocked.)
			ToolTip,Player died at %A_Now%,0,0
			Menu,Tray,Icon, Sprites/Gmod.ico
			return
		}
		Random,vcMinerRestartDelay,180000,300000 ;(3-5 minutes should be a decent range of time to expect VCMiners to stop at random.)
		ToolTip,Waiting %vcMinerRestartDelay%ms before restarting miners...,gameWidth/2,0
		Sleep,vcMinerRestartDelay
	}
	Menu,Tray,Icon, Sprites/Gmod.ico
	return
}

/*
	/=======================================================================\
	|Beta Functions (Beware - here be dragons.)
	|	Stuff that's currently being thought over, and likely horribly broken in places.
	\=======================================================================/
*/
Base64Decode(ByRef Bin,Code,IsString = 0){ ;Simple Base64 decoding function.
	static CharSet := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	StringReplace Code, Code, =,, All
	Length := StrLen(Code), VarSetCapacity(Bin,Ceil((Length / 4) * 3),0), Index := 1, BinPos := 0
	Loop, % Length // 4
	Temp1 := ((InStr(CharSet,SubStr(Code,Index,1),True) - 1) << 18) | ((InStr(CharSet,SubStr(Code,Index + 1,1),True) - 1) << 12) | ((InStr(CharSet,SubStr(Code,Index + 2,1),True) - 1) << 6) | (InStr(CharSet,SubStr(Code,Index + 3,1),True) - 1), NumPut((Temp1 >> 16) | (((Temp1 >> 8) & 255) << 8) | ((Temp1 & 255) << 16),Bin,BinPos,"UInt"), Index += 4, BinPos += 3
	If (Length & 3)
	{
		Temp1 := ((InStr(CharSet,SubStr(Code,Index,1),True) - 1) << 18) | ((InStr(CharSet,SubStr(Code,Index + 1,1),True) - 1) << 12), NumPut(Temp1 >> 16,Bin,BinPos,"UChar")
		If (Length & 1)
			Temp1 |= ((InStr(CharSet,SubStr(Code,Index + 2,1),True) - 1) << 6), NumPut((Temp1 >> 8) & 255,Bin,BinPos + 1,"UChar")
	}
	If IsString
		VarSetCapacity(Bin,-1)
}

MNDecrypt(cipherText:="",key:=""){
	/*
		Subtracts (or does it add?) a key string's characters' values from a ciphertext string, and returns the resulting plaintext.
		How do we wrap the array to make sure our character codes stay within 32-126? Mod()? If <>?
			Hydrogen's MNEncrypt DOES include the control characters like NUL, SOH, STX, ETX, etc in the math. We just don't notice because it's Base64'd output.
			...Was Hydrogen only intending on using MNEncrypt to cipher "." and 0-9 with A-Za-z key phrases?
			...No need to worry about there being control characters? Just Base64 the string, and be done with it?
		The math of adding/subtracting the characters' values to/from each other doesn't add up. Something else, simple, is being done.
			Could there be a stupidly-simple offset somewhere, just to throw us off? Hydrogen's smart like that.
		Will have to expect a Base64 string, decode it directly into a plaintext variable, then run a string parse loop on each character of the string.
			Then we have to figure out the relation between the Key and the Ciphertext.
				We know the key has a RELATIVE effect on the text, but it doesn't explain the irregularity in the pattern of (attempted) decoded text.
			Will need to do additional experimenting with Hydro's MNEncrypt to deduce what the relation is.
	*/
	ANSIChars:=["","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""
	," ","!","""","#","$","%","&","'","(",")","*","+",",","-",".","/","0","1","2","3","4","5","6","7","8","9",":",";","<","=",">","?"
	,"@","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","[","\","]","^","_"
	,"``","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","{","|","}","~"]
	CipherTextCharacterArray:=Object()
	KeyTextCharacterArray:=Object()
	DecryptedCharacterArray:=Object()
	cipherTextCharPosition:=0
	Loop Parse, cipherText ;Create an array of ANSI character codes from the ciphertext string.
	{
		CipherTextCharacterArray.Push(Asc(A_LoopField))
	}
	Loop Parse, key ;Create an array from the key string
	{
		KeyTextCharacterArray.Push(Asc(A_LoopField))
	}
	DecryptionStart:
	for index, keyIndex in KeyTextCharacterArray {
		cipherTextCharPosition++
		PlaintextANSI .= ANSIChars[(CipherTextCharacterArray[A_Index] + KeyTextCharacterArray[A_Index])] . ","
	}
	MsgBox, 64, Decoded String:, Ciphertext: %cipherText%`nKey: %key%`nPlaintextANSI: %PlaintextANSI%
	return
}

MNEncrypt(plainText:="",key:=""){
	;~ Adds a key string's characters' values to a plaintext string, and returns a ciphertext string.
	PlainTextCharacterArray:=Object()
	KeyTextCharacterArray:=Object()
	
	Loop Parse, plainText ;Create an array from the plaintext string.
	{
		PlainTextCharacterArray.Push(Asc(A_LoopField))
	}
	Loop Parse, key ;Create an array from the key string
	{
		KeyTextCharacterArray.Push(Asc(A_LoopField))
	}
return
}