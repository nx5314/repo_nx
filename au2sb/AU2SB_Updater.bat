@echo off
title AU2SB Updater 1.0.0
setlocal
:: Set the current version of the script
set "this_updater_version=1.0.0"
:: Check updater version
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/updaterversion.txt') do set "latest_updater_version=%%i"
set "updater_download_path=%cd%"
:: Compare versions
if not "%latest_updater_version%"=="%this_updater_version%" (
	rename AU2SB_Updater.bat AU2SB_Updater_old.bat
    curl -s -L "https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/AU2SB_Updater.bat" --output "%updater_download_path%\AU2SB_Updater.bat"
    echo AU2SB Updater has been updated to %latest_updater_version%
    title AU2SB Updater %latest_updater_version%
    :: Delete the old updater
    del %updater_download_path%\AU2SB_Updater_old.bat /q 2>nul
    :: Run the new updater
    %updater_download_path%\AU2SB_Updater.bat
    echo.
	pause
	exit /b
)
:: Prompt the user for the Minecraft folder path
echo This installer/updater script will automatically download the required mods and config files. 
echo Fabric will be installed automatically if it is not already installed. (Requires Java)
echo Please enter the folder path if you are using a custom Minecraft folder location,
set /p "minecraftfolder=or press Enter if you are using the default .minecraft folder: "
:: If the user enters nothing, set minecraftfolder to %appdata%\.minecraft
if "%minecraftfolder%"=="" set "minecraftfolder=%appdata%\.minecraft" >nul
echo.

:: Fetch the URL for the download
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/mods.txt') do set "mods_url=%%i"
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/config.txt') do set "config_url=%%i"
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/resourcepacks.txt') do set "resourcepacks_url=%%i"
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/extras.txt') do set "extras_url=%%i"

:: Check if AU2SB_mods_version.txt exists, if not, create it and set its contents to the value of %mods_url%
REM if not exist "%minecraftfolder%\AU2SB_mods_version.txt" (
    REM echo %mods_url% > "%minecraftfolder%\AU2SB_mods_version.txt"
	REM :: attrib +h "%minecraftfolder%\AU2SB_mods_version.txt"
REM )

:: Check if the mods_url is the same as the one saved in AU2SB_mods_version.txt
REM set mods_uptodate=false
REM if exist "%minecraftfolder%\AU2SB_mods_version.txt" (
    REM set /p saved_mods_url=<"%minecraftfolder%\AU2SB_mods_version.txt"
    REM if "%mods_url%"=="%saved_mods_url%" (
        REM echo The mods appear to already be up-to-date.
	    REM set "mods_uptodate=true"
	    REM set /p "mods_force=Do you want to force a redownload? y/n"
	    REM if "%mods_force%"=="y" (
		    REM set "mods_uptodate=false"
	    REM )
    REM )
REM )

:: Save the mods_url in AU2SB_mods_version.txt
REM echo %mods_url% > "%minecraftfolder%\AU2SB_mods_version.txt"

echo Starting modpack update...
if exist "%temp%\au2sb" rmdir "%temp%\au2sb" /s /q 2>&1 >nul
mkdir "%temp%\au2sb" 2>&1 >nul
echo Downloading mods...
curl -L "%mods_url%" --output "%temp%\au2sb_mods.zip"
echo Downloading config...
curl -L "%config_url%" --output "%temp%\au2sb_config.zip"
echo Downloading resourcepacks...
curl -L "%resourcepacks_url%" --output "%temp%\au2sb_resourcepacks.zip"
echo Downloading extras...
curl -L "%extras_url%" --output "%temp%\au2sb_extras.zip"
echo Extracting mods...
tar -xf "%temp%\au2sb_mods.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Extracting config...
tar -xf "%temp%\au2sb_config.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Extracting resourcepacks...
tar -xf "%temp%\au2sb_resourcepacks.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Extracting extras...
tar -xf "%temp%\au2sb_extras.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Moving files to %minecraftfolder%...
robocopy "%temp%\au2sb\mods" "%minecraftfolder%\mods" /s /purge /r:100 /move /log:"%temp%\au2sb_mods.log" 2>&1 >nul
robocopy "%temp%\au2sb\config" "%minecraftfolder%\config" /s /r:100 /move /log:"%temp%\au2sb_config.log" 2>&1 >nul
robocopy "%temp%\au2sb\resourcepacks" "%minecraftfolder%\resourcepacks" /s /r:100 /move /log:"%temp%\au2sb_resourcepacks.log" 2>&1 >nul
robocopy "%temp%\au2sb" "%minecraftfolder%" /s /r:100 /move /log:"%temp%\au2sb_extras.log" 2>&1 >nul
echo Cleaning up leftovers...
del "%temp%\au2sb_mods.zip" /q 2>&1 >nul
del "%temp%\au2sb_config.zip" /q 2>&1 >nul
del "%temp%\au2sb_resourcepacks.zip" /q 2>&1 >nul
del "%temp%\au2sb_extras.zip" /q 2>&1 >nul

:: Check fabric installation
set "fabric_exists=false"
if exist "%appdata%\.minecraft\versions\fabric-loader-0.15.11-1.20.1" set "fabric_exists=true"

:: If missing, download installer and run
if "%fabric_exists%"=="false" (
	echo.
	echo Fabric appears to not be installed, downloading now
    curl -L https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar --output "%temp%\fabric-installer.jar"
    java -jar %temp%\fabric-installer.jar client -mcversion 1.20.1 -dir %appdata%\.minecraft
	echo.
	echo Fabric installed
)

echo.
echo Modpack installed/updated
echo.
endlocal
pause
