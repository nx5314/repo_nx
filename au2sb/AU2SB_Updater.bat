@echo off
title AU2SB Updater 1.0.0
setlocal enabledelayedexpansion
REM Set the current version of the script
set "this_updater_version=1.0.0"
REM Check updater version
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/updaterversion.txt') do set "latest_updater_version=%%i"
set "updater_download_path=%cd%"
REM Compare versions
if not "%latest_updater_version%"=="%this_updater_version%" (
	rename AU2SB_Updater.bat AU2SB_Updater_old.bat
    curl -s -L "https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/AU2SB_Updater.bat" --output "%updater_download_path%\AU2SB_Updater.bat"
    echo AU2SB Updater has been updated to %latest_updater_version%
    title AU2SB Updater %latest_updater_version%
    REM Delete the old updater
    del %updater_download_path%\AU2SB_Updater_old.bat /q 2>nul
    REM Run the new updater
    %updater_download_path%\AU2SB_Updater.bat
    echo.
	pause
	exit /b
)
REM Prompt the user for the Minecraft folder path
echo This installer/updater script will automatically download the required mods and config files. 
echo Fabric will be installed automatically if it is not already installed. (Requires Java)
echo Please enter the folder path if you are using a custom Minecraft folder location,
set /p "minecraftfolder=or press Enter if you are using the default .minecraft folder: "
REM If the user enters nothing, set minecraftfolder to %appdata%\.minecraft
if "%minecraftfolder%"=="" set "minecraftfolder=%appdata%\.minecraft" >nul
echo.

REM Make temp folder
if not exist "%temp%\au2sb" mkdir "%temp%\au2sb"

REM Fetch the URL for the download
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/mods.txt') do (set "mods_url=%%i")
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/config.txt') do (set "config_url=%%i")
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/resourcepacks.txt') do (set "resourcepacks_url=%%i")
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/extras.txt') do (set "extras_url=%%i")

REM Check if AU2SBmodsversion exists
set "is_update=false"
set "mods_uptodate=false"
if exist "%minecraftfolder%\AU2SBmodsversion" (
    for /f %%A in ("%minecraftfolder%\AU2SBmodsversion") do (
        if %%~zA equ 0 (
            echo The mods version file appears empty.
            REM Handle the empty file case here
            (echo %mods_url% > "%minecraftfolder%\AU2SBmodsversion")
        ) else (
            REM Read the contents of the file
            for /f "delims=" %%i in ('type "%minecraftfolder%\AU2SBmodsversion"') do (set "current_mods_url=%%i")
            set "current_mods_url=!current_mods_url:~0,-1!"
            set "is_update=true"
            goto continue
        )
    )
) else (
    REM If the file does not exist, create it and set the contents to mods_url
    (echo %mods_url% > "%minecraftfolder%\AU2SBmodsversion")
    goto continue
)

:continue
REM current_mods_url = "!current_mods_url!"
REM mods_url = "%mods_url%"
REM Compare the contents of the file with mods_url
if "!current_mods_url!"=="!mods_url!" (
    REM If they are the same, set mods_uptodate to true
    set "mods_uptodate=true"
    REM Mods up-to-date = !mods_uptodate!
) else (
    REM If they are not the same, update the file with the new mods_url
    REM Mods up-to-date = !mods_uptodate!
    (echo %mods_url% > "%minecraftfolder%\AU2SBmodsversion")
)

REM If mods are up to date offer for user override
if "%mods_uptodate%"=="true" (
    REM Prompt the user to override mods_uptodate
    set /p "user_input=Mods are up to date. Do you want to override and update anyway ([y]es = redownload mods / no = config only)? [Enter=skip]"
)
REM If the user input is 'y' or 'yes', set mods_uptodate to false
if /I "%user_input%"=="y" (
    set "mods_uptodate=false"
    REM Mods up-to-date set to = %mods_uptodate%
)
if /I "%user_input%"=="yes" (
    set "mods_uptodate=false"
    REM Mods up-to-date set to = %mods_uptodate%
)

REM Download, extract, and move mods if mods_uptodate is not true
if not "!mods_uptodate!"=="true" (
    echo Downloading mods...
    curl -L "%mods_url%" --output "%temp%\au2sb_mods.zip"
    echo Extracting mods...
    tar -xf "%temp%\au2sb_mods.zip" -C "%temp%\au2sb" 2>&1 >nul
    echo Moving mods to %minecraftfolder%...
    robocopy "%temp%\au2sb\mods" "%minecraftfolder%\mods" /s /purge /r:100 /move /log:"%temp%\au2sb_mods.log" 2>&1 >nul
)

REM Download, extract, and move config
echo Downloading config...
curl -L "%config_url%" --output "%temp%\au2sb_config.zip"
echo Extracting config...
tar -xf "%temp%\au2sb_config.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Moving config to %minecraftfolder%...
robocopy "%temp%\au2sb\config" "%minecraftfolder%\config" /s /r:100 /move /log:"%temp%\au2sb_config.log" 2>&1 >nul

REM Download, extract, and move resourcepacks
echo Downloading resourcepacks...
curl -L "%resourcepacks_url%" --output "%temp%\au2sb_resourcepacks.zip"
echo Extracting resourcepacks...
tar -xf "%temp%\au2sb_resourcepacks.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Moving resourcepacks to %minecraftfolder%...
robocopy "%temp%\au2sb\resourcepacks" "%minecraftfolder%\resourcepacks" /s /r:100 /move /log:"%temp%\au2sb_resourcepacks.log" 2>&1 >nul

REM Download, extract, and move extras
echo Downloading extras...
curl -L "%extras_url%" --output "%temp%\au2sb_extras.zip"
echo Extracting extras...
tar -xf "%temp%\au2sb_extras.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Moving extras to %minecraftfolder%...
robocopy "%temp%\au2sb" "%minecraftfolder%" /s /r:100 /move /log:"%temp%\au2sb_extras.log" 2>&1 >nul

REM Delete the zips
echo Cleaning up leftovers...
if "%mods_uptodate%"=="false" (
    del "%temp%\au2sb_mods.zip" /q 2>&1 >nul
)
del "%temp%\au2sb_config.zip" /q 2>&1 >nul
del "%temp%\au2sb_resourcepacks.zip" /q 2>&1 >nul
del "%temp%\au2sb_extras.zip" /q 2>&1 >nul
rmdir "%temp%\au2sb" /s /q

REM Check fabric installation
set "fabric_exists=false"
if exist "%appdata%\.minecraft\versions\fabric-loader-0.15.11-1.20.1" set "fabric_exists=true"

REM If missing, download installer and run
if "%fabric_exists%"=="false" (
	echo.
	echo Fabric appears to not be installed, downloading now
    curl -L https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar --output "%temp%\fabric-installer.jar"
    java -jar %temp%\fabric-installer.jar client -mcversion 1.20.1 -dir %appdata%\.minecraft
	echo.
	echo Fabric installed
)

echo.
REM Check the flag and display the appropriate message
if "!is_update!"=="true" (
    echo Modpack updated
) else (
    echo Modpack installed
)
echo.
echo If there were any errors please let me know
endlocal
pause
