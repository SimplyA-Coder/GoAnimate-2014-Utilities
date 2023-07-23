:: GoAnimate 2014 Installer
:: Author: SimplyA_Coder
:: License: MIT
title GoAnimate 2014 Installer [Initializing...]

::::::::::::::::::::
:: Initialization ::
::::::::::::::::::::

:: Stop commands from spamming stuff, cleans up the screen
@echo off && cls

:: Lets variables work or something idk im not a nerd
SETLOCAL ENABLEDELAYEDEXPANSION

::check for admin 
fsutil dirty query !systemdrive! >NUL 2>&1
if /i not !ERRORLEVEL!==0 (
	echo You need to run this file with admin privelages.
	echo Right-click on this file, and click "Run as Administrator".
	echo If you don't have this option, your current user account does not have admin privileges.
	pause
	exit
)

:: Make sure we're starting in the correct folder
pushd "%~dp0"
:: Check *again* because it seems like sometimes it doesn't go into dp0 the first time???
pushd "%~dp0"

::::::::::::::::::::::
:: Dependency Check ::
::::::::::::::::::::::

title GoAnimate 2014 Installer [Checking for dependencies...]
echo Checking for dependencies...
echo:

:: Preload variables
set DEPENDENCIES_NEEDED=n
set GIT_DETECTED=n
set NODE_DETECTED=n
set HTTPSERVER_DETECTED=n
set FLASH_DETECTED=n

:: Git check
echo Checking for Git installation...
for /f "delims=" %%i in ('git --version 2^>nul') do set goutput=%%i
IF "!goutput!" EQU "" (
	echo Git could not be found.
	set DEPENDENCIES_NEEDED=y
) else (
	echo Git is installed.
	echo:
	set GIT_DETECTED=y
)

:: Node.JS check
echo Checking for Node.JS installation...
for /f "delims=" %%i in ('node -v 2^>nul') do set noutput=%%i
IF "!noutput!" EQU "" (
	echo Node.JS could not be found.
	set DEPENDENCIES_NEEDED=y
) else (
	echo Node.JS is installed.
	echo:
	set NODE_DETECTED=y
)

:: Flash check
echo Checking for Flash installation...
if exist "!windir!\SysWOW64\Macromed\Flash\*pepper.exe" set FLASH_DETECTED=y
if exist "!windir!\System32\Macromed\Flash\*pepper.exe" set FLASH_DETECTED=y
if !FLASH_DETECTED!==n (
	echo Flash could not be found.
	echo:
	set DEPENDENCIES_NEEDED=y
) else (
	echo Flash is installed.
	echo:
)

::::::::::::::::::::::::
:: Dependency Install ::
::::::::::::::::::::::::

if !DEPENDENCIES_NEEDED!==y (
	title GoAnimate 2014 Installer [Installing Dependencies...]
	echo:
	echo Installing dependencies...
	echo:

	set INSTALL_FLAGS=ALLUSERS=1 /norestart
	set SAFE_MODE=n
	if /i "!SAFEBOOT_OPTION!"=="MINIMAL" set SAFE_MODE=y
	if /i "!SAFEBOOT_OPTION!"=="NETWORK" set SAFE_MODE=y
	set CPU_ARCHITECTURE=what
	if /i "!processor_architecture!"=="x86" set CPU_ARCHITECTURE=32
	if /i "!processor_architecture!"=="AMD64" set CPU_ARCHITECTURE=64
	if /i "!PROCESSOR_ARCHITEW6432!"=="AMD64" set CPU_ARCHITECTURE=64
)

if !GIT_DETECTED!==n (
	cls
	echo Installing Git...
	echo:
	if not exist "git_installer.exe" (
		powershell -Command "Invoke-WebRequest https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-32-bit.exe -OutFile git_installer.exe"
	)
	echo Proper Git installation doesn't seem possible to do automatically.
	echo You can just keep clicking next until it finishes,
	echo and the GoAnimate 2014 installer will continue once it closes.
	git_installer.exe
	goto git_installed
	
	:git_installed
	del git_installer.exe
	echo Git has been installed.
)

if !NODE_DETECTED!==n (	
	cls
	echo Installing Node.js...
	echo:
	:: Install Node.js
	if !CPU_ARCHITECTURE!==64 (
		if !VERBOSEWRAPPER!==y ( echo 64-bit system detected, installing 64-bit Node.js. )
		goto installnode64
	)
	if !CPU_ARCHITECTURE!==32 (
		if !VERBOSEWRAPPER!==y ( echo 32-bit system detected, installing 32-bit Node.js. )
		goto installnode32
	)
	if !CPU_ARCHITECTURE!==what (
		echo:
		echo Well, GoAnimate 2014 has ran into an error.
		echo GoAnimate 2014 can't tell if you're on a 32-bit or 64-bit system,
		echo Which means it doesn't know which version of Node.js to install.
		echo:
		echo If you don't know what that means, press 1 to try anyway.
		echo If you're a tech expert
		echo and you know what you're doing, then press 3 to keep going.
		echo:
		:architecture_ask
		set /p CPUCHOICE= Response:
		echo:
		if "!cpuchoice!"=="1" echo Attempting 32-bit Node.js installation. && goto installnode32
		if "!cpuchoice!"=="3" echo Node.js will not be installed. && goto after_nodejs_install
		echo You must pick one or the other.&& goto architecture_ask
	)

	:installnode64
	if not exist "node_installer_64.msi" (
		powershell -Command "Invoke-WebRequest https://nodejs.org/dist/v17.8.0/node-v17.8.0-x64.msi -OutFile node_installer_64.msi"
	)
	echo Proper Node.js installation doesn't seem possible to do automatically.
	echo You can just keep clicking next until it finishes, and GoAnimate 2014 will continue once it closes.
	msiexec /i "node_installer_64.msi" !INSTALL_FLAGS!
	del node_installer_64.msi
	goto nodejs_installed

	:installnode32
	if not exist "node_installer_32.msi" (
		powershell -Command "Invoke-WebRequest https://nodejs.org/dist/v17.8.0/node-v17.8.0-x86.msi -OutFile node_installer_32.msi"
	)
	echo Proper Node.js installation doesn't seem possible to do automatically.
	echo You can just keep clicking next until it finishes, and GoAnimate 2014 will continue once it closes.
	msiexec /i "node_installer_32.msi" !INSTALL_FLAGS!
	del node_installer_32.msi
	goto nodejs_installed

	:nodejs_installed
	echo Node.js has been installed.
)

:after_nodejs_install

:: Flash Player
if !FLASH_DETECTED!==n (
	:start_flash_install
	echo Installing Flash Player...
	echo:

	echo To install Flash Player, GoAnimate 2014 must end the processes of any currently running web browsers.
	echo Please make sure any work in your browser is saved before proceeding.
	echo GoAnimate 2014 will not continue installation until you press any key.
	echo:
	pause
	echo:

	:: Summon the Browser Slayer
	echo Ending processes of all browsers...
	for %%i in (firefox,palemoon,iexplore,microsoftedge,chrome,chrome64,opera,brave) do (
		if !VERBOSEWRAPPER!==y (
			 taskkill /f /im %%i.exe /t
			 wmic process where name="%%i.exe" call terminate
		) else (
			 taskkill /f /im %%i.exe /t >nul
			 wmic process where name="%%i.exe" call terminate >nul
		)
	)
	:lurebrowserslayer
	cls
	echo:
	echo Starting Flash installer...
	if not exist "flash_windows_chromium.msi" (
		powershell -Command "Invoke-WebRequest https://downgit.github.io/#/home?url=https://github.com/SimplyA-Coder/GoAnimate-2014-Utilities/blob/utils/installers/flash_windows_chromium.msi -OutFile flash_windows_chromium.msi"
	)
	msiexec /i "flash_windows_chromium.msi" !INSTALL_FLAGS! /quiet

	echo Flash has been installed.
	del flash_windows_chromium.msi	
	echo:
)

if !DEPENDENCIES_NEEDED!==y (
	echo Dependencies installed. 
	start installer_windows.bat
	exit
)

:::::::::::::::::::::::::
:: Post-Initialization ::
:::::::::::::::::::::::::

title GoAnimate 2014 Installer
:cls
cls

echo:
echo GoAnimate 2014 Installer
echo A Legacy Video Maker with the old GoAnimate from 2014, built on Flash Player and NodeJS.
echo:
echo Enter 1 to install the main version
echo Enter 2 to install the stable version
echo Enter 0 to close the installer
:wrapperidle
echo:

:::::::::::::
:: Choices ::
:::::::::::::

set /p CHOICE=Choice:
if "!choice!"=="0" goto exit
if "!choice!"=="1" goto downloadmain
if "!choice!"=="2" goto downloadstable
echo Time to choose. && goto wrapperidle

:downloadmain
cls
if not exist "GoAnimate-2014" (
	echo Cloning repository from GitHub...
	git clone https://github.com/SimplyA-Coder/GoAnimate-2014.git
) else (
	echo You already have it installed apparently?
	echo If you're trying to install a different version make sure you remove the old folder.
	pause
)
goto npminstall

:downloadstable
cls
if not exist "GoAnimate-2014-Stable" (
	echo Cloning repository from GitHub...
	git clone -https://github.com/SimplyA-Coder/GoAnimate-2014-Stable.git
) else (
	echo You already have it installed apparently?
	echo If you're trying to install a different version make sure you remove the old folder.
	pause
)
goto npminstall

:npminstall
cls
pushd GoAnimate-2014-Stable\wrapper
if not exist "package-lock.json" (
	echo Installing Node.JS packages...
	call npm install
) else (
	echo Node.JS packages already installed.
)
popd

:finish
cls
echo:
echo GoAnimate 2014 has been installed^^! Would you like to start it now?
echo:
echo Enter 1 to open GoAnimate 2014 now.
echo Enter 0 to just open the folder.
:finalidle
echo:

set /p CHOICE=Choice:
if "!choice!"=="0" goto folder
if "!choice!"=="1" goto start
echo Time to choose. && goto finalidle

:folder
start "" "GoAnimate-2014"
) else (
	start "" "GoAnimate-2014-Stable"
pause & exit

:start
pushd GoAnimate-2014
start start_goanimate.bat
) else (
	npm install
	npm start

:exit
pause & exit