:: This script automates the installation and updating process for AU2SB, a custom Minecraft modpack.  It checks for the latest version of the updater script, AU2SB, and its components (mods, config files, resource packs, and extra files).  If updates are available, it downloads and installs them.  It also sets up a custom Minecraft Launcher profile with optimized Java arguments and manages the installation of Fabric, a popular mod loader.  The script ensures all components are up to date and configures the game environment for AU2SB.  If Minecraft is detected not to be installed, the Minecraft Launcher can be installed automatically.
:: Run the script in a Windows command prompt environment.  It will guide you through the installation or update process with prompts.
:: Requirements: Internet connection, winget (included in Win10/11 by default) for prerequisite installers, and permissions to access the .minecraft directory.  At least 8 GB of system RAM is required to play AU2SB.  Installing on an SSD is recommended.

@echo off
setlocal enabledelayedexpansion
:start
set "this_updater_version=1.5.2"

REM Title presets
set "title_normal=AU2SB Updater %this_updater_version%"
set "title_updating_updater=Updating Updater to %latest_updater_version%..."
set "title_prompt=Input Required^! - %title_normal%"
set "title_installing=Installing... - %title_normal%"
set "title_warning=Warning^! - %title_normal%"
set "title_error=Error^! - %title_normal%"
set "title_failed=Install Failed^! - %title_normal%"
set "title_cleaning=Cleaning up... - %title_normal%"
set "title_finished=Finished^! - %title_normal%"
set "title_stopped=Stopped^! - %title_normal%"

set "exclaim=^!"
title %title_normal%

REM Define the path to the launcher_profiles.json file
set "launcher_profiles=%appdata%\.minecraft\launcher_profiles.json"

REM Fetch OS version
for /F "tokens=2 delims==" %%i in ('wmic os get Version /value') do set os_version=%%i
for /F "tokens=3 delims=." %%a in ("%os_version%") do set os_build=%%a
if %os_build% LSS 16299 (
    echo WARNING: Your Windows version is not at least build 16299. Please update your OS. Like seriously.
    pause
    exit
)
REM Fetch system RAM capacity
for /F "tokens=2 delims=:" %%a in ('systeminfo ^| findstr /C:"Total Physical Memory"') do set user_RAM=%%a
set user_RAM=%user_RAM:~1,-3%
set user_RAM=%user_RAM:MB=%
set user_RAM=%user_RAM:,=%
set /A user_RAM_GB=%user_RAM%/1024
REM user_RAM_max caps the user to 90% of their total RAM
set /A user_RAM_max=9*user_RAM_GB/10
REM echo RAM in GB: %user_RAM_GB%

REM Cancel the install if the system has less than 7 GB of RAM.  I'm doing this early so nothing gets installed if this is the case.  Using 7 just in case the values are odd, but still much less than 8.
if %user_RAM_GB% lss 7 (
    echo.
    echo.
echo        Your system appears to have less than 6 GB of RAM.  Unfortunately, running AU2SB is likely
echo        impossible, if not highly inadvisable.  Please upgrade your system to play.
echo        Or maybe it would work, I don't know, probably not though.  Doubt anyone will see this anyway.
echo        I really hope.  For your sake.
echo        If this appeared erroneously, let me know.
title %title_stopped%
    pause
    exit
)

REM check if we can connect to github via curl
set "ERRORLEVEL="
curl -s -L --head https://www.quad9.net | find "200 OK" >nul
if %ERRORLEVEL% neq 0 (
title %title_failed%
echo.
echo.               .d88 
echo.        d8b   d88P' 
echo.        Y8P  d88P   
echo.             888    
echo.             888    
echo.        d8b  Y88b   
echo.        Y8P   Y88b. 
echo.               'Y88 
echo.
echo        No internet connection?
echo        That or it looks like your Windows installation is somehow messed up.
echo        Default Windows component curl.exe is not functioning or is missing.
echo        Why have you done this.
pause
exit
)
REM check if winget works
set "ERRORLEVEL="
winget >nul 2>&1
if %ERRORLEVEL% neq 0 (
title %title_failed%
echo.
echo.               .d88 
echo.        d8b   d88P' 
echo.        Y8P  d88P   
echo.             888    
echo.             888    
echo.        d8b  Y88b   
echo.        Y8P   Y88b. 
echo.               'Y88 
echo.
echo        Winget is not installed or not found in your environment variables.
echo        Please download and install Winget from: https://aka.ms/getwinget
pause
exit
)
set "ERRORLEVEL="
winget source update >nul 2>&1
if %ERRORLEVEL% neq 0 (
title %title_failed%
echo.
echo.               .d88 
echo.        d8b   d88P' 
echo.        Y8P  d88P   
echo.             888    
echo.             888    
echo.        d8b  Y88b   
echo.        Y8P   Y88b. 
echo.               'Y88 
echo.
echo        Winget sources failed to update.
echo        Please download and reinstall Winget from: https://aka.ms/getwinget
pause
exit
)

REM Check updater version
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/updaterversion.txt') do set "latest_updater_version=%%i"
set "updater_download_path=%cd%"
REM Compare versions
if not "%latest_updater_version%"=="%this_updater_version%" (
    title %title_updating_updater%
	rename AU2SB_Updater.bat AU2SB_Updater_old.bat
    curl -s -L "https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/AU2SB_Updater.bat" --output "%updater_download_path%\AU2SB_Updater.bat"
    echo AU2SB Updater has been updated to %latest_updater_version%
    echo.
    title AU2SB Updater %latest_updater_version%
    REM Delete the old updater
    del %updater_download_path%\AU2SB_Updater_old.bat /q 2>nul
    REM Run the new updater
    %updater_download_path%\AU2SB_Updater.bat
    echo.
	pause
	exit
)
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/version.txt') do set "latest_AU2SB_version=%%i"
REM Check AU2SB size
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/size.txt') do set "AU2SB_size=%%i"


REM Check AU2SB path and version
if exist "%appdata%\.minecraft_au2sb\path" (
set /p current_minecraft_au2sb_folder=<"%appdata%\.minecraft_au2sb\path"
)
if not "%current_minecraft_au2sb_folder%"=="" (
    if not exist "%current_minecraft_au2sb_folder%\au2sb" mkdir "%current_minecraft_au2sb_folder%\au2sb"

    REM move old items
    if exist "%current_minecraft_au2sb_folder%\AU2SBmodsversion" (
        move /y "%current_minecraft_au2sb_folder%\AU2SBmodsversion" "%current_minecraft_au2sb_folder%\au2sb\mods_version"
    )
    if exist "%current_minecraft_au2sb_folder%\AU2SBresourcepacksversion" (
        move /y "%current_minecraft_au2sb_folder%\AU2SBresourcepacksversion" "%current_minecraft_au2sb_folder%\au2sb\resourcepacks_version"
    )
    if exist "%current_minecraft_au2sb_folder%\dh_date" (
        move /y "%current_minecraft_au2sb_folder%\dh_date" "%current_minecraft_au2sb_folder%\au2sb\dh_date"
    )
    if exist "%current_minecraft_au2sb_folder%\dvc" (
        move /y "%current_minecraft_au2sb_folder%\dvc" "%current_minecraft_au2sb_folder%\au2sb\dvc"
    )
    if exist "%current_minecraft_au2sb_folder%\keybinds_set" (
        move /y "%current_minecraft_au2sb_folder%\keybinds_set" "%current_minecraft_au2sb_folder%\au2sb\keybinds_set"
    )
    if exist "%current_minecraft_au2sb_folder%\ram_alloc.txt" (
        move /y "%current_minecraft_au2sb_folder%\ram_alloc.txt" "%current_minecraft_au2sb_folder%\au2sb\ram_alloc.txt"
    )
    if exist "%current_minecraft_au2sb_folder%\version" (
        move /y "%current_minecraft_au2sb_folder%\version" "%current_minecraft_au2sb_folder%\au2sb\version"
    )
    if exist "%current_minecraft_au2sb_folder%\zerotier_set" (
        move /y "%current_minecraft_au2sb_folder%\zerotier_set" "%current_minecraft_au2sb_folder%\au2sb\zerotier_set"
    )

    REM version check
    if exist "%current_minecraft_au2sb_folder%\au2sb\version" (
    set /p current_AU2SB_version=<"%current_minecraft_au2sb_folder%\au2sb\version"
    ) else (
        set "current_AU2SB_version="
    )
)

REM version determines existing_install
if not "%current_AU2SB_version%"=="" (
    set "existing_install=true"
) else (
    set "existing_install=false"
)

REM Make folder
if not exist "%appdata%\.minecraft_au2sb" mkdir "%appdata%\.minecraft_au2sb"

REM pickup where we left off after a java installation
if exist "%minecraft_au2sb_folder%\au2sb\java_continue" (
    set "ERRORLEVEL="
    where java >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo Java is recognized
    ) else (
        echo ERROR: Java command is not recognized, something either went wrong or you need to restart your PC to continue.
title %title_error%
        echo Press any key to exit.
        pause >nul
        exit
    )

    del "%minecraft_au2sb_folder%\au2sb\java_continue" /s /q
    if exist "%minecraft_au2sb_folder%\au2sb\java_continue_1" (
        set "install_selection=1"
        del "%minecraft_au2sb_folder%\au2sb\java_continue_1" /s /q
    )
    echo.
    echo AU2SB Installer will now continue from where it left off...
    @timeout /t 3 /nobreak >nul
    goto skip_prompt
)

:intro
REM Intro
echo.
echo                       z444444444444m 144444  44444m ^|444444444444m 1444444444444m 1444444444444m
echo                       $#####44#####L $#####  #####F ^|4444444EEEEE@ j$$$$$A444444R j$$$$$R44$$$$E
echo                       KKKKKF jKKKKKW EKKKKK  KKKKKF         EEEEE@ j#####W         #####F 4#####
echo                      jKKKKKKKKKKKKK  KKKKKW jKKKKKH $@@@@@@@EEEEE@ jKKKKK#RRRRRRR  #KKKK$R#KKKE
echo                      jHHHHHMMHHHHHH  HHHHHt jHHHHHH $EEEEEMMMMMMMM  MMMMMMM#KKKKKW #KKKKKMMKKKHHK
echo                      K]]]]H  ]]]]]K j]]]]]H ]]]]]]  $EEEEE                 jHHHHHH jHHHHHW #HHHHH
echo                      ]]]]]H ]]]]]]H ]]]]]]HHH]]]]]  $EEEEE@@@@@@@@  KKKKKKKKNNNNNK jNNNNNKKKNNNNNH
echo                     ]HHHHH` (HHHHH  [HHHHHHHHHHHHH  RRRRRRRRRRRRRR  HHHHHHHHHHHHHH  HHHHHHHHHHHHHK
echo                      `````  ``````   `````````````  ][[[[[[[[[[[[[  ]]]]]]]]]]]]]  ]]]]]]]]]]]]]H
echo                       ````   ``````   ````````````  ][[[[[[[[[[[[[ ]]]]]]]]]]]]][  ]]]]]]]]]]]]H
if not "%current_AU2SB_version%"=="" if not "%current_AU2SB_version%"=="%latest_AU2SB_version%" (
echo                                      Your current version of AU2SB is %current_AU2SB_version%
) else ( echo. )
if not "%current_AU2SB_version%"=="%latest_AU2SB_version%" (
echo                                        The latest version of AU2SB is %latest_AU2SB_version%
) else (
echo.
echo                                         Your AU2SB installation is up-to-date.
)
echo.

:: .d88888b.           888    d8b                            
::d88P" "Y88b          888    Y8P                            
::888     888          888                                   
::888     888 88888b.  888888 888  .d88b.  88888b.  .d8888b  
::888     888 888 "88b 888    888 d88""88b 888 "88b 88K      
::888     888 888  888 888    888 888  888 888  888 "Y8888b. 
::Y88b. .d88P 888 d88P Y88b.  888 Y88..88P 888  888      X88 
:: "Y88888P"  88888P"   "Y888 888  "Y88P"  888  888  88888P' 
::            888                                            
::            888                                            
::            888

REM show options if existing install
if "%existing_install%"=="true" (
    :retry_selection
set "startup_selection=47"
echo    Options:
echo         1. Update
echo         2. Modify and update
echo         3. Uninstall
echo         4. Move install location
echo         5. Distant Horizons LOD - NEW!exclaim!
echo         6. About
echo         0. Exit
echo.
    title %title_prompt%
    set /p "startup_selection=Select: "
    if "!startup_selection!"=="0" exit
    if "!startup_selection!"=="yeet" (
        echo.
        echo Use the command [/dvc start] in-game and connect to the DVC channel in Discord.
        set "dvc=true"
        echo|set /p="!dvc!" > "%minecraft_au2sb_folder%\au2sb\dvc"
        echo Press any key to continue...
        pause >nul
        echo.
        set "startup_selection=1"
    )
    if "!startup_selection!"=="unyeet" (
        echo.
        echo Unyeeten.
        set "dvc=false"
        del "%minecraft_au2sb_folder%\au2sb\dvc" /s /q
        echo Press any key to continue...
        pause >nul
        echo.
        set "startup_selection=1"
    )
    if not "!startup_selection!"=="1" if not "!startup_selection!"=="2" if not "!startup_selection!"=="3" if not "!startup_selection!"=="4" if not "!startup_selection!"=="5" if not "!startup_selection!"=="6" (
        echo Invalid selection.
        echo.
        goto retry_selection
    )
    title %title_normal%
)

if "%startup_selection%"=="1" goto skip_prompt

if "%startup_selection%"=="3" (
title %title_prompt%
set /p "uninstall_confirm=Please confirm to uninstall ([y]es / no [Enter]): "
title %title_normal%
    REM If the user input is 'y' or 'yes', uninstall
    echo !uninstall_confirm! | findstr /I /C:"y" >nul && (
        title %title_prompt%
        set /p "uninstall_zerotier=Would you like to also uninstall ZeroTier? ([y]es / no [Enter]): "
        title %title_normal%
            REM If the user input is 'y' or 'yes', uninstall zerotier
            echo !uninstall_zerotier! | findstr /I /C:"y" >nul && (
                set "uninstall_zerotier=true"
                goto skip_prompt
            ) || (
                set "uninstall_zerotier=false"
                goto skip_prompt
            )
    ) || (
        echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo.
        goto start
    )
)

if "%startup_selection%"=="4" (
echo.
set /p old_minecraft_au2sb_folder=<"%appdata%\.minecraft_au2sb\path"
echo Current path = !old_minecraft_au2sb_folder!
echo.
goto path_prompt
)

::8888888b.  d8b          888                      888         888    888                  d8b                                     
::888  "Y88b Y8P          888                      888         888    888                  Y8P                                     
::888    888              888                      888         888    888                                                          
::888    888 888 .d8888b  888888  8888b.  88888b.  888888      8888888888  .d88b.  888d888 888 88888888  .d88b.  88888b.  .d8888b  
::888    888 888 88K      888        "88b 888 "88b 888         888    888 d88""88b 888P"   888    d88P  d88""88b 888 "88b 88K      
::888    888 888 "Y8888b. 888    .d888888 888  888 888         888    888 888  888 888     888   d88P   888  888 888  888 "Y8888b. 
::888  .d88P 888      X88 Y88b.  888  888 888  888 Y88b.       888    888 Y88..88P 888     888  d88P    Y88..88P 888  888      X88 
::8888888P"  888  88888P'  "Y888 "Y888888 888  888  "Y888      888    888  "Y88P"  888     888 88888888  "Y88P"  888  888  88888P' 

if "%startup_selection%"=="5" (
:dh_start
if exist "%current_minecraft_au2sb_folder%\au2sb\dh_date" (
set /p dh_date_prev=<"%current_minecraft_au2sb_folder%\au2sb\dh_date"
) else (
    set "dh_date_prev="
)
REM Check LOD date and size
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/dh_date.txt') do set "dh_date=%%i"
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/dh_size.txt') do set "dh_size=%%i"
echo.
if not "%startup_selection%"=="5" (
echo Would you like to download the latest Distant Horizons LOD data?
echo The download size will be !dh_size! GB
goto dh_prompt
) else (
echo This will download the latest Distant Horizons LOD data and REPLACE any existing data you have.
echo The game cannot be running during this.
)
if not "!dh_date_prev!"=="" (
echo Your existing LOD data will be backed up and can be reverted until the next time you download LOD.
)
echo.
if "!dh_date!"=="!dh_date_prev!" (
echo You have already downloaded the latest LOD data from !dh_date!, would you like to redownload?
echo The download size will be !dh_size! GB
) else (
echo  The latest update was at !dh_date! and the download size will be !dh_size! GB
if not "!dh_date_prev!"=="" (
echo Your last download was at !dh_date_prev!
)
)
:dh_prompt
echo.
set /p "dh_download_confirm=Please confirm to download ([y]es / no [Enter]): "
title %title_normal%
    REM If the user input is 'y' or 'yes', uninstall
    echo !dh_download_confirm! | findstr /I /C:"y" >nul && (

:dh_javaw_check
set "ERRORLEVEL="
REM Check if javaw.exe is running
tasklist /FI "IMAGENAME eq javaw.exe" 2>NUL | find /I /N "javaw.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo If Minecraft is currently running, please close it before proceeding.
    pause
) else (
    echo Minecraft is not running, proceeding...
)

REM Distant Horizons download
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/dh.txt') do (set "dh_url=%%i")

if exist "%current_minecraft_au2sb_folder%\Distant_Horizons_server_data" (
    REM delete any old LOD folder if exists
    if exist "%current_minecraft_au2sb_folder%\Distant_Horizons_server_data_OLD" rmdir "%current_minecraft_au2sb_folder%\Distant_Horizons_server_data_OLD" /s /q
    REM rename existing LOD folder
    move "%current_minecraft_au2sb_folder%\Distant_Horizons_server_data" "%current_minecraft_au2sb_folder%\Distant_Horizons_server_data_OLD" 
)

REM Download, extract, and move config
echo Downloading Distant Horizons LOD...
curl -L "!dh_url!" --output "%temp%\au2sb_dh.zip"

REM Check the size of the downloaded file
for %%A in ("%temp%\au2sb_dh.zip") do set dh_dl_size=%%~zA
REM If the file size is less than 10MB (in bytes), indicate the mods download failed
if !dh_dl_size! LSS 10000000 (
    title %title_failed%
    echo WARNING: The download failed, please report that the Distant Horizons LOD download needs to be fixed
    set "fail_state=true"
    goto dh_cleanup
)

echo Extracting Distant Horizons LOD...
mkdir "%temp%\au2sb_dh"
tar -xf "%temp%\au2sb_dh.zip" -C "%temp%\au2sb_dh" 2>&1 >nul
echo Moving Distant Horizons LOD to %current_minecraft_au2sb_folder%...
robocopy "%temp%\au2sb_dh" "%current_minecraft_au2sb_folder%" /s /r:100 /move /xo /log:"%temp%\au2sb_config.log" 2>&1 >nul

REM save date
curl -s -L https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/dh_date.txt --output "%current_minecraft_au2sb_folder%\au2sb\dh_date"

:dh_cleanup
echo Cleaning up...
if exist "%temp%\au2sb_dh.zip" del "%temp%\au2sb_dh.zip" /q 2>&1 >nul
if exist "%temp%\au2sb_dh" rmdir "%temp%\au2sb_dh"
if "%existing_install%"=="false" goto update_start
if "%startup_selection%"=="2" goto update_start
if "!fail_state!"=="true" (
title %title_failed%
echo.
echo.               .d88 
echo.        d8b   d88P' 
echo.        Y8P  d88P   
echo.             888    
echo.             888    
echo.        d8b  Y88b   
echo.        Y8P   Y88b. 
echo.               'Y88 
echo.
    echo Failed to download Distant Horizons LOG
    echo Press any key to return to the Options...
    pause >nul
    echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo.
    goto start
)
echo. & echo. & echo.
echo.       BTTTTTTTTTTjBPTTTTBPTTTTB #TTTTjBPTTTTBPTTTTTTTTTT#KTTTT#BTTTTjBTTTTTTTTTTjBPTTTTTTTTjggPTTTT#
echo.      jK    ,,,,,,/B    jB     P#B    jB     BP    ,,,,,,#K    jB    jB     ,,,,,;BP    ,,    jB    jK
echo.      B     BBBBBBBK    /B      #K    jB    jB'    BBBBBBBK    jB    -B'    BBBBBBBb    jB    -B     B
echo.     jK           BM    BK    zg      jB    jB           jB           BP          jB     BP    #K    jk
echo.     #'    BBBBBBBB     BM    BK,     BK    jBBBBBBBP    jB    jB'    BK    jBBBBBBBW    #K    jBPPPPPB
echo.    jP    jBBBBBBBK    jB     BBB     BK    jB           jB    jB-    #b           BK           Bk    jC
echo.    #WgggggBBBPTTtWgggggBgggggBBBgggggBkgggggBggggggggggggBgggggBkgggggBggggggggggggBggggggggggBBBgggggB
echo.     TBBBBBBBB    jBBBBBBBBBBBBBhBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBP
echo.      '#BBBBBK     jBBBBBBBBBBBB #BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBCjBBBBBB-
echo.
echo                                                 LOD updated.
echo.
echo Press any key to return to the Options...
pause >nul
echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo.
goto start
    ) || (
        echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo.
        goto start
    )
)

::       d8888 888                        888    
::      d88888 888                        888    
::     d88P888 888                        888    
::    d88P 888 88888b.   .d88b.  888  888 888888 
::   d88P  888 888 "88b d88""88b 888  888 888    
::  d88P   888 888  888 888  888 888  888 888    
:: d8888888888 888 d88P Y88..88P Y88b 888 Y88b.  
::d88P     888 88888P"   "Y88P"   "Y88888  "Y888 

if "%startup_selection%"=="6" (
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/dh_size.txt') do set "dh_size=%%i"
echo.
echo          About:
echo.
echo          This script automates the installation and updating process for AU2SB, a custom Minecraft modpack.
echo       It checks for the latest version of the updater script, AU2SB, and its components ^(mods, config files,
echo       resource packs, and extra files^).  ^If updates are available, it downloads and installs them.  It also
echo       sets up a custom Minecraft Launcher profile with optimized Java arguments and manages the installation
echo       of Fabric, a popular mod loader.  The script ensures all components are up to ^date and configures the
echo       game environment ^for AU2SB.  ^If Minecraft is detected not to be installed, the Minecraft Launcher can
echo       be installed automatically.
echo.
echo          Data for the Distant Horizons mod is optionally available to download.  It allows you to see further 
echo       than your ^"actual^" view distance.  Its current download size is !dh_size! GB.
echo.
echo          We use ZeroTier for our SD-WAN ^(sorta like a VPN^) so it is required to play.  Basically, it is an 
echo       authorized-only virtual network which keeps the server secure from the wider internet.
echo.
echo          Run the script in a Windows command prompt environment.  It will guide you through the installation
echo       or update process with prompts.
echo.
echo          Requirements: Internet connection, winget ^(included in Win10/11 by default^) ^for prerequisite
echo       installers, and permissions to access the .minecraft directory.  ^At least 8 GB of system RAM is required
echo       to play AU2SB.  Installing on an SSD is recommended.  The install size will be at least %AU2SB_size% GB,
echo       if you don't have enough space you should feel bad about your computer organization.
echo. & echo.
echo Press any key to return to the Options...
pause >nul
echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo.
goto start
)

::8888888b.          888    888           8888888b.                                         888    
::888   Y88b         888    888           888   Y88b                                        888    
::888    888         888    888           888    888                                        888    
::888   d88P 8888b.  888888 88888b.       888   d88P 888d888 .d88b.  88888b.d88b.  88888b.  888888 
::8888888P"     "88b 888    888 "88b      8888888P"  888P"  d88""88b 888 "888 "88b 888 "88b 888    
::888       .d888888 888    888  888      888        888    888  888 888  888  888 888  888 888    
::888       888  888 Y88b.  888  888      888        888    Y88..88P 888  888  888 888 d88P Y88b.  
::888       "Y888888  "Y888 888  888      888        888     "Y88P"  888  888  888 88888P"   "Y888 
::                                                                                 888             
::                                                                                 888             
::                                                                                 888             

REM Prompt for path
if "%existing_install%"=="true" (
    goto skip_prompt
)
echo.           PLEASE READ THE FOLLOWING:
echo.
echo.           This installer/updater script will guide you through the installation process with prompts.
echo.        Running this script as administrator should be neither necessary nor is it recommended.
echo.
echo.           An AU2SB profile will be created in the offical Minecraft Launcher.  If you do not yet have
echo.        Minecraft installed, the launcher will be installed.  A licensed copy of Minecraft Java Edition
echo.        is required to play.  Fabric will be installed automatically if it is not already installed.
echo.
echo.           At least 8 GB of system RAM is required to play AU2SB.  Installing on an SSD is recommended.
echo.        The install size will be at least %AU2SB_size% GB, if you don't have enough space you should feel
echo.        bad about your computer organization.
echo.
:install_selection
set "install_selection=47"
echo    Options:
echo         1. Express Install
echo         2. Custom Install
echo         0. Exit
echo.
title %title_prompt%
set /p "install_selection=Select: "
title %title_normal%
if "!install_selection!"=="0" exit
if "!install_selection!"=="1" (
    set "input_path=%appdata%\.minecraft_au2sb"
    goto skip_prompt
)
if "!install_selection!"=="2" (
    goto path_prompt
)
if not "!install_selection!"=="1" if not "!install_selection!"=="2" (
    echo Invalid selection.
    echo.
    goto intro
)

:path_prompt
title %title_prompt%
echo.
echo.        Please input a folder path if you would like to use a custom folder location, or simply
echo.        press [Enter] if you would like to use the default .minecraft_au2sb folder (recommended).
title %title_prompt%
set "input_path="
set /p "input_path=Path: "
title %title_normal%
if "%input_path%"=="" set "input_path=%appdata%\.minecraft_au2sb"

REM Remove trailing slash if it exists and clear quotation marks
if "%input_path:~-1%"=="\" set "input_path=%input_path:~0,-1%"
set "input_path=%input_path:"=%"

REM Define disallowed paths and invalid characters
set "dont_use=C:,C:\Program Files,C:\ProgramData"
set "dont_include=C:\Program Files,C:\ProgramData,C:\Windows"
set "invalid_chars=^<^>^:^|^?^*"

REM Check if the path contains any invalid characters
for %%i in (%invalid_chars%) do (
    echo.%input_path%|findstr /C:"%%i" >nul && (
        echo.
        echo This path contains invalid characters.
        @timeout /t 3 /nobreak >nul
        goto path_prompt
    )
)
REM Check if the path is disallowed
for %%a in (%dont_use%) do (
    if /i "%input_path%"=="%%a" (
        echo.
        echo This path is disallowed.
        @timeout /t 3 /nobreak >nul
        goto path_prompt
    )
)
REM Check if the path includes disallowed path
for %%a in (%dont_include%) do (
    echo.%input_path% | findstr /I /C:"%%a" >nul && (
        echo.
        echo This path is disallowed.
        goto path_prompt
    )
)
REM Check if the path is a file
if exist "%input_path%" if not exist "%input_path%\" (
    echo.
    echo This path is a file, not a folder.
    goto path_prompt
)
REM Confirm the path
echo.
echo You've input %input_path%
set /p "confirm_path=Are you sure this is where you want to install? ([y]es / no [Enter]): "
echo !confirm_path! | findstr /I /C:"y" >nul && (
    echo Confirmed input as %input_path%
) || (
    goto path_prompt
)
REM Check if the folder is empty excluding the path file
for /f %%A in ('dir /b "%input_path%\*"') do (
    if "%%A" neq "path" (
        echo.
        echo This folder is not empty.
        goto path_prompt
    )
)


set "minecraft_au2sb_folder=%input_path%"

:skip_prompt

REM If the user enters nothing, set minecraft_au2sb_folder to %appdata%\.minecraft_au2sb
if "%minecraft_au2sb_folder%"=="" if not "%startup_selection%"=="4" set /p minecraft_au2sb_folder=<"%appdata%\.minecraft_au2sb\path"
if "%minecraft_au2sb_folder%"=="" set "minecraft_au2sb_folder=%appdata%\.minecraft_au2sb"
if "%minecraft_au2sb_folder%"=="%appdata%\.minecraft" set "minecraft_au2sb_folder=%appdata%\.minecraft_au2sb"
set "base_minecraft_folder=%appdata%\.minecraft"
set "current_minecraft_au2sb_folder=%minecraft_au2sb_folder%"

if not "%startup_selection%"=="4" (
    echo.
    echo AU2SB install path is %minecraft_au2sb_folder%
)

REM Make minecraft_au2sb_folder
if not exist "%minecraft_au2sb_folder%" mkdir "%minecraft_au2sb_folder%"
echo.|set /p="%minecraft_au2sb_folder%" > "%appdata%\.minecraft_au2sb\path"
echo.

REM Check if the user has access to the folder
if not exist "%minecraft_au2sb_folder%" (
    echo The folder %minecraft_au2sb_folder% does not exist or you do not have access to it.
    set "fail_state=true"
    goto fail_end
) else (
    echo The folder %minecraft_au2sb_folder% exists and you have access to it.
    if not exist "%minecraft_au2sb_folder%\au2sb" mkdir "%minecraft_au2sb_folder%\au2sb"
)

:: .d8888b.  888                        888                                      
::d88P  Y88b 888                        888                                      
::888    888 888                        888                                      
::888        88888b.   .d88b.   .d8888b 888  888       .d88b.  888  888  .d88b.  
::888        888 "88b d8P  Y8b d88P"    888 .88P      d8P  Y8b `Y8bd8P' d8P  Y8b 
::888    888 888  888 88888888 888      888888K       88888888   X88K   88888888 
::Y88b  d88P 888  888 Y8b.     Y88b.    888 "88b      Y8b.     .d8""8b. Y8b.     
:: "Y8888P"  888  888  "Y8888   "Y8888P 888  888       "Y8888  888  888  "Y8888  

REM Check if javaw.exe is running
:javaw_check
set "ERRORLEVEL="
tasklist /FI "IMAGENAME eq javaw.exe" 2>NUL | find /I /N "javaw.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Minecraft is currently running. Please close it before proceeding.
    pause
    goto javaw_check
)

REM Check if MinecraftLauncher.exe is running
:kill_launcher
set "ERRORLEVEL="
tasklist /FI "IMAGENAME eq MinecraftLauncher.exe" 2>NUL | find /I /N "MinecraftLauncher.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Minecraft Launcher is currently running. Please close it before proceeding.
    set /p "kill_launcher=Would you like to end all MinecraftLauncher.exe processes? ([y]es / no [Enter]): "
    echo.
    REM If the user input is 'y' or 'yes', kill all MinecraftLauncher.exe processes
    echo !kill_launcher! | findstr /I /C:"y" >nul && (
        taskkill /F /IM MinecraftLauncher.exe /T
        echo All MinecraftLauncher.exe processes have been stopped. Continuing...
        echo.
    ) || (
        goto kill_launcher
title %title_stopped%
        echo Please close the Minecraft Launcher and run the updater again.
        echo Press any key to exit.
        pause >nul
        exit
    )
)

::888     888          d8b                   888             888 888 
::888     888          Y8P                   888             888 888 
::888     888                                888             888 888 
::888     888 88888b.  888 88888b.  .d8888b  888888  8888b.  888 888 
::888     888 888 "88b 888 888 "88b 88K      888        "88b 888 888 
::888     888 888  888 888 888  888 "Y8888b. 888    .d888888 888 888 
::Y88b. .d88P 888  888 888 888  888      X88 Y88b.  888  888 888 888 
:: "Y88888P"  888  888 888 888  888  88888P'  "Y888 "Y888888 888 888 

REM uses powershell to move the folder to the recycle bin and delete the profile from the launcher
if "%startup_selection%"=="3" (
    powershell -Command "(New-Object -ComObject 'Shell.Application').Namespace(10).MoveHere('%minecraft_au2sb_folder%')"
    rmdir %appdata%\.minecraft_au2sb /s /q 2>&1 >nul
    powershell -Command "$jsonFilePath = '%launcher_profiles%'; $jsonContent = Get-Content -Path $jsonFilePath | ConvertFrom-Json; $jsonContent.profiles.PSObject.Properties | Where-Object { $_.Name -eq 'AU2SB' } | ForEach-Object { $jsonContent.profiles.PSObject.Properties.Remove($_.Name) }; $jsonContent | ConvertTo-Json -Depth 32 | Set-Content -Path $jsonFilePath"
set "ERRORLEVEL="
    if "%uninstall_zerotier%"=="true" (
        winget.exe uninstall --id ZeroTier.ZeroTierOne --exact
    )
echo. & echo. & echo.
echo.               .d88 
echo.        d8b   d88P' 
echo.        Y8P  d88P   
echo.             888    
echo.             888    
echo.        d8b  Y88b   
echo.        Y8P   Y88b. 
echo.               'Y88 
echo. & echo.
echo.        AU2SB has been uninstalled but is retrievable from the recycle bin until it is cleared.
if "%uninstall_zerotier%"=="true" (
    if %ERRORLEVEL% neq 0 (
echo.        ZeroTier uninstallation failed.
    ) else (
echo.        ZeroTier has also been uninstalled.
    )
)
echo.        This script does not uninstall the Minecraft Launcher itself.
title %title_finished%
echo.
echo Press any key to exit.
pause >nul
    exit
)

::888b     d888                            
::8888b   d8888                            
::88888b.d88888                            
::888Y88888P888  .d88b.  888  888  .d88b.  
::888 Y888P 888 d88""88b 888  888 d8P  Y8b 
::888  Y8P  888 888  888 Y88  88P 88888888 
::888   "   888 Y88..88P  Y8bd8P  Y8b.     
::888       888  "Y88P"    Y88P    "Y8888  

REM uses robocopy to move the existing folder to the specified location
if "%startup_selection%"=="4" (
    echo Moving installation to %minecraft_au2sb_folder%
    robocopy %old_minecraft_au2sb_folder% %minecraft_au2sb_folder% /e /move /xf "%old_minecraft_au2sb_folder%\path" /log:"%temp%\AU2SB_move.log"
    goto update_start
)

REM Check if %appdata%\.minecraft exists
if not exist "%appdata%\.minecraft" (
    echo Can't seem to find the base .minecraft folder, something weird going on or do you not have the game installed?
title %title_prompt%
    set /p "install_minecraft=Would you like to install the Minecraft Launcher? ([y]es / no [Enter]): "
title %title_installing%
    echo.
    REM If the user input is 'y' or 'yes', install Minecraft Launcher
    echo !install_minecraft! | findstr /I /C:"y" >nul && (
        echo Installing Minecraft Launcher now... 
        winget.exe install --id Mojang.MinecraftLauncher --exact --accept-source-agreements --silent --disable-interactivity --accept-package-agreements
    ) || (
        echo Please download and install the Minecraft Launcher and run the AU2SB installer again.
echo Press any key to exit.
pause >nul
        exit
    )
)

::8888888b.                   .d888 d8b 888                .d8888b.  888                        888      
::888   Y88b                 d88P"  Y8P 888               d88P  Y88b 888                        888      
::888    888                 888        888               888    888 888                        888      
::888   d88P 888d888 .d88b.  888888 888 888  .d88b.       888        88888b.   .d88b.   .d8888b 888  888 
::8888888P"  888P"  d88""88b 888    888 888 d8P  Y8b      888        888 "88b d8P  Y8b d88P"    888 .88P 
::888        888    888  888 888    888 888 88888888      888    888 888  888 88888888 888      888888K  
::888        888    Y88..88P 888    888 888 Y8b.          Y88b  d88P 888  888 Y8b.     Y88b.    888 "88b 
::888        888     "Y88P"  888    888 888  "Y8888        "Y8888P"  888  888  "Y8888   "Y8888P 888  888 

:recheck_launcher_profiles
REM Make sure it exists
if not exist %launcher_profiles% (
    echo.
    echo Whoa, you don't seem to have any launcher profiles I can read, have you not run the Minecraft Launcher even once?
title %title_prompt%
    set /p "recheck_profiles=Try again? ([y]es / no [Enter]): "
title %title_installing%
    echo !recheck_profiles! | findstr /I /C:"y" >nul && (
        goto recheck_launcher_profiles
    ) || (
title %title_prompt%
        set /p "create_new_file=Would you like to create a new launcher_profiles.json file? ([y]es / no [Enter]): "
title %title_installing%
        echo !create_new_file! | findstr /I /C:"y" >nul && (
            echo Creating new launcher_profiles.json file...
            (
                echo {
                echo   "profiles" : {
                echo     "Latest Snapshot" : {
                echo       "icon" : "Dirt",
                echo       "javaArgs" : "-Xmx4G",
                echo       "lastUsed" : "1970-01-01T00:00:00.002Z",
                echo       "lastVersionId" : "latest-snapshot",
                echo       "name" : "",
                echo       "type" : "latest-snapshot"
                echo     },
                echo     "Latest Version" : {
                echo       "icon" : "Grass",
                echo       "lastUsed" : "2024-01-01T01:01:00.002Z",
                echo       "lastVersionId" : "latest-release",
                echo       "name" : "",
                echo       "type" : "latest-release"
                echo     }
                echo   },
                echo   "settings" : {
                echo     "crashAssistance" : false,
                echo     "enableAdvanced" : true,
                echo     "enableAnalytics" : true,
                echo     "enableHistorical" : true,
                echo     "enableReleases" : true,
                echo     "enableSnapshots" : true,
                echo     "keepLauncherOpen" : true,
                echo     "profileSorting" : "ByLastPlayed",
                echo     "showGameLog" : false,
                echo     "showMenu" : true,
                echo     "soundOn" : false
                echo   },
                echo   "version" : 3
                echo }
            ) > %launcher_profiles%
            goto recheck_launcher_profiles
        )
        echo Please ensure %appdata%\.minecraft\launcher_profiles.json exists before attempting installation again
title %title_stopped%
echo Press any key to exit.
pause >nul
        exit
    )
) else (
    echo Checking profiles...
)

::8888888888       888              d8b          
::888              888              Y8P          
::888              888                           
::8888888  8888b.  88888b.  888d888 888  .d8888b 
::888         "88b 888 "88b 888P"   888 d88P"    
::888     .d888888 888  888 888     888 888      
::888     888  888 888 d88P 888     888 Y88b.    
::888     "Y888888 88888P"  888     888  "Y8888P 

REM Check fabric installation
set "fabric_exists=false"
if exist "%appdata%\.minecraft\versions\fabric-loader-0.15.11-1.20.1" (
    set "fabric_exists=true"
    goto fabric_is_installed
)

REM If missing, download fabric and java installer and run
if "%fabric_exists%"=="false" (
	echo.
	echo Fabric appears to not be installed, downloading now...
    curl -L https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar --output "%temp%\fabric-installer.jar"
    REM Check the size of the downloaded file
    for %%A in ("%temp%\fabric-installer.jar") do set fabric_installer=%%~zA
    REM If the file size is less than 1000 bytes, indicate the mods download failed
    if !fabric_installer! LSS 1000 (
        echo.
        echo ERROR: The fabric installer download failed
        set "fail_state=true"
        goto cleanup
    )
	echo.
    java -jar %temp%\fabric-installer.jar client -mcversion 1.20.1 -dir %appdata%\.minecraft
) else (
    goto fabric_is_installed
)

REM Check if fabric was able to install
    set "fabric_exists=false"
    if exist "%appdata%\.minecraft\versions\fabric-loader-0.15.11-1.20.1" set "fabric_exists=true"
    if "!fabric_exists!"=="false" (
        echo Fabric was unable to install, you likely need to install java or your .minecraft folder was unable to be accessed
        set "need_java=true"
    ) else (
        echo Fabric installed
        goto fabric_is_installed
)

::  888888                            
::    "88b                            
::     888                            
::     888  8888b.  888  888  8888b.  
::     888     "88b 888  888     "88b 
::     888 .d888888 Y88  88P .d888888 
::     88P 888  888  Y8bd8P  888  888 
::     888 "Y888888   Y88P   "Y888888 
::   .d88P                            
:: .d88P"                             
::888P"
:java_install
REM If java needs to be installed
set proceed_with_java_install=null
if "%need_java%"=="true" (
    echo.
    if "%install_selection%"=="1" goto winget_java
    set "install_java=null"
title %title_prompt%
    set /p "install_java=Would you like to install Java? ([y]es / no [Enter] = skip, fabric will not be installed): "
title %title_normal%
    echo.
)
REM If the user input contains 'y' or 'Y', set the proceed variable to true
echo %install_java% | findstr /I /C:"y" >nul && (set "proceed_with_java_install=true") || (set "proceed_with_java_install=false")
REM If proceed_with_java_install is true, install java
if "%proceed_with_java_install%"=="true" (
    :winget_java
    echo Java will now be installed
title %title_installing%
    set "ERRORLEVEL="
    winget.exe install --id EclipseAdoptium.Temurin.21.JRE --exact
    if !ERRORLEVEL! equ 0 (
        echo Java installation succeeded, please exit this terminal window and run this installer again to finish installing AU2SB
    ) else (
        title %title_failed%
        echo WARNING: Java installation failed
        set "fail_state=true"
        goto cleanup
    )
    echo. 2> "%minecraft_au2sb_folder%\au2sb\java_continue"
    if "%install_selection%"=="1" (
        echo. 2> "%minecraft_au2sb_folder%\au2sb\java_continue_1"
    )
title %title_stopped%
    echo Press any key to exit.
    pause >nul
    exit
)

if "%proceed_with_java_install%"=="false" (
title %title_stopped%
    echo Java will not be installed, please install it yourself and run this installer again to finish installing AU2SB
    echo Press any key to exit.
    pause >nul
    exit
)

:fabric_is_installed
title %title_installing%

::8888888b.         d8888 888b     d888 
::888   Y88b       d88888 8888b   d8888 
::888    888      d88P888 88888b.d88888 
::888   d88P     d88P 888 888Y88888P888 
::8888888P"     d88P  888 888 Y888P 888 
::888 T88b     d88P   888 888  Y8P  888 
::888  T88b   d8888888888 888   "   888 
::888   T88b d88P     888 888       888 

REM Set RAM allocation amount
set "RAM_unset=false"
if not exist "%minecraft_au2sb_folder%\au2sb\ram_alloc.txt" (
    echo|set /p="6" > "%minecraft_au2sb_folder%\au2sb\ram_alloc.txt"
    set "RAM_allocation=6"
    set "RAM_unset=true"
)

REM Warn the user if RAM capacity is less than certain values on first run
if %user_RAM_GB% lss 8 if "%RAM_unset%"=="true" (
    echo|set /p="5" > "%minecraft_au2sb_folder%\au2sb\ram_alloc.txt"
    set "RAM_allocation=5"
    echo.
    echo Warning: Your system has less than 8 GB of RAM.  Performance may be negatively impacted.
title %title_prompt%
    set /p "proceed_low_RAM=Do you want to proceed? ([y]es / no [Enter]): "
title %title_installing%
    echo !proceed_low_RAM! | findstr /I /C:"y" >nul || (pause && exit)
    echo.
    goto input_loop
) else (
    if %user_RAM_GB% lss 14 if "%RAM_unset%"=="true" (
        echo.
        echo Warning: Your system has less than 16 GB of RAM.  Performance may be negatively impacted.
title %title_prompt%
        set /p "proceed_low_RAM=Do you want to proceed? ([y]es / no [Enter]): "
title %title_installing%
        echo !proceed_low_RAM! | findstr /I /C:"y" >nul || (pause && exit)
        echo.
        goto input_loop
    )
)
set /p "RAM_allocation=" < "%minecraft_au2sb_folder%\au2sb\ram_alloc.txt"

REM skip prompt if startup_selection 1
if "%startup_selection%"=="1" if "%RAM_unset%"=="false" goto update_start
REM skip prompt if install_selection 1
if "%install_selection%"=="1" (
    set "RAM_unset=false"
    set "RAM_allocation=6"
    if %user_RAM_GB% lss 8 (
        set "RAM_allocation=5"
    )
)

REM Warn the user if RAM capacity is less than certain values on subsequent runs
if %user_RAM_GB% lss 8 (
title %title_warning%
    echo.
    echo Warning: Your system has less than 8 GB of RAM.  Performance may be negatively impacted.
    echo.
    @timeout /t 3 /nobreak >nul
) else (
    if %user_RAM_GB% lss 14 (
title %title_warning%
        echo.
        echo Warning: Your system has less than 16 GB of RAM.  Performance may be negatively impacted.
        echo.
        @timeout /t 3 /nobreak >nul
    )
)

:input_loop
title %title_prompt%

REM Prompt the user for RAM allocation
if "%RAM_unset%"=="true" if %user_RAM_GB% lss 8 (
    set /p "RAM_allocation=Please enter the amount of RAM to allocate (4 - %user_RAM_max%), or press [Enter] to use the default 5 GB (remembers your choice): "
    goto ram_next
)
if "%RAM_unset%"=="true" (
    set /p "RAM_allocation=Please enter the amount of RAM to allocate (4 - %user_RAM_max%), or press [Enter] to use the default 6 GB (remembers your choice): "
) else (
    if %user_RAM_GB% lss 8 (
        set /p "RAM_allocation=Press [Enter] to use %RAM_allocation% GB (remembers your choice), or enter a new amount of RAM to allocate (<%user_RAM_max%): "
    ) else (
        set /p "RAM_allocation=Press [Enter] to use %RAM_allocation% GB (remembers your choice), or enter a new amount of RAM to allocate (4 - %user_RAM_max%): "
    )
)
:ram_next
title %title_installing%

if not defined RAM_allocation (
    set /p "RAM_allocation=" < "%minecraft_au2sb_folder%\au2sb\ram_alloc.txt"
)
REM Trim leading and trailing spaces
for /f "tokens=* delims= " %%a in ("!RAM_allocation!") do set "RAM_allocation=%%~a"
for /f "tokens=* delims= " %%a in ("!RAM_allocation:~0,2!") do set "RAM_allocation=%%~a"
if %RAM_allocation% geq 4 if %RAM_allocation% leq %user_RAM_max% (
    if !RAM_allocation! lss 6 (
title %title_warning%
        echo Warning: Allocating less than 6 GB of RAM might not be enough.
        @timeout /t 1 /nobreak >nul
title %title_prompt%
        set /p "proceed=Do you want to proceed? ([y]es / no [Enter]): "
        echo !proceed! | findstr /I /C:"y" >nul || goto input_loop
    )
title %title_installing%
    echo|set /p="!RAM_allocation!" > "%minecraft_au2sb_folder%\au2sb\ram_alloc.txt"
    echo You have allocated !RAM_allocation! GB of RAM.
) else (
    echo Invalid input. Please enter a number between 4 and %user_RAM_max%.
    goto input_loop
)

REM detour to Distant Horizons LOD download
if "%existing_install%"=="false" goto dh_start
if "%startup_selection%"=="2" goto dh_start

:update_start
title %title_installing%

::8888888b.                   .d888 d8b 888                .d8888b.           888    
::888   Y88b                 d88P"  Y8P 888               d88P  Y88b          888    
::888    888                 888        888               Y88b.               888    
::888   d88P 888d888 .d88b.  888888 888 888  .d88b.        "Y888b.    .d88b.  888888 
::8888888P"  888P"  d88""88b 888    888 888 d8P  Y8b          "Y88b. d8P  Y8b 888    
::888        888    888  888 888    888 888 88888888            "888 88888888 888    
::888        888    Y88..88P 888    888 888 Y8b.          Y88b  d88P Y8b.     Y88b.  
::888        888     "Y88P"  888    888 888  "Y8888        "Y8888P"   "Y8888   "Y888 

set "AU2SB_created_date=1999-03-20T00:00:00.002Z"
set "AU2SB_icon=data:image/png;base64,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"

set "profile_suffix= %latest_AU2SB_version%"

REM powershell time
REM remove older AU2SB profile entry
powershell -Command "$jsonFilePath = '%launcher_profiles%'; $jsonContent = Get-Content -Path $jsonFilePath | ConvertFrom-Json; $jsonContent.profiles.PSObject.Properties | Where-Object { $_.Name -eq 'AU2SB' } | ForEach-Object { $jsonContent.profiles.PSObject.Properties.Remove($_.Name) }; $jsonContent | ConvertTo-Json -Depth 32 | Set-Content -Path $jsonFilePath"
REM new AU2SB profile entry
powershell -Command "$newAU2SBProfile = @{ 'created' = '%AU2SB_created_date%'; 'gameDir' = '%minecraft_au2sb_folder%'; 'icon' = '%AU2SB_icon%'; 'javaArgs' = '-Xmx%RAM_allocation%G -Xms%RAM_allocation%G -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseNUMA -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:ThreadPriorityPolicy=1 -XX:AllocatePrefetchStyle=3  -XX:+UseG1GC -XX:MaxGCPauseMillis=37 -XX:+PerfDisableSharedMem -XX:G1HeapRegionSize=16M -XX:G1NewSizePercent=23 -XX:G1ReservePercent=20 -XX:SurvivorRatio=32 -XX:G1MixedGCCountTarget=3 -XX:G1HeapWastePercent=20 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1RSetUpdatingPauseTimePercent=0 -XX:MaxTenuringThreshold=1 -XX:G1SATBBufferEnqueueingThresholdPercent=30 -XX:G1ConcMarkStepDurationMillis=5.0 -XX:G1ConcRSHotCardLimit=16 -XX:G1ConcRefinementServiceIntervalMillis=150 -XX:GCTimeRatio=99'; 'lastUsed' = '2063-04-05T00:00:00.002Z'; 'lastVersionId' = 'fabric-loader-0.15.11-1.20.1'; 'name' = 'AU2SB%profile_suffix%'; 'type' = 'custom' }; $jsonContent = Get-Content -Path '%launcher_profiles%' | ConvertFrom-Json; $jsonContent.profiles.PSObject.Properties | Where-Object { $_.Value.created -eq '%AU2SB_created_date%' } | ForEach-Object { $jsonContent.profiles.PSObject.Properties.Remove($_.Name) }; $jsonContent.profiles | Add-Member -MemberType NoteProperty -Name 'AU2SB' -Value $newAU2SBProfile -Force; $jsonContent | ConvertTo-Json -Depth 32 | Set-Content -Path '%launcher_profiles%'"

if "%startup_selection%"=="4" (
echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo.
echo.       BTTTTTTTTTTjBPTTTTBPTTTTB #TTTTjBPTTTTBPTTTTTTTTTT#KTTTT#BTTTTjBTTTTTTTTTTjBPTTTTTTTTjggPTTTT#
echo.      jK    ,,,,,,/B    jB     P#B    jB     BP    ,,,,,,#K    jB    jB     ,,,,,;BP    ,,    jB    jK
echo.      B     BBBBBBBK    /B      #K    jB    jB'    BBBBBBBK    jB    -B'    BBBBBBBb    jB    -B     B
echo.     jK           BM    BK    zg      jB    jB           jB           BP          jB     BP    #K    jk
echo.     #'    BBBBBBBB     BM    BK,     BK    jBBBBBBBP    jB    jB'    BK    jBBBBBBBW    #K    jBPPPPPB
echo.    jP    jBBBBBBBK    jB     BBB     BK    jB           jB    jB-    #b           BK           Bk    jC
echo.    #WgggggBBBPTTtWgggggBgggggBBBgggggBkgggggBggggggggggggBgggggBkgggggBggggggggggggBggggggggggBBBgggggB
echo.     TBBBBBBBB    jBBBBBBBBBBBBBhBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBP
echo.      '#BBBBBK     jBBBBBBBBBBBB #BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBCjBBBBBB-
echo.
echo                                           AU2SB successfully moved!exclaim!
title %title_finished%
echo Press any key to return to the Options...
pause >nul
echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo.
goto start
)

REM Fetch the URL for the downloads
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/mods.txt') do (set "mods_url=%%i")
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/config.txt') do (set "config_url=%%i")
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/resourcepacks.txt') do (set "resourcepacks_url=%%i")
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/extras.txt') do (set "extras_url=%%i")

REM make folder
if not exist "%temp%\au2sb" mkdir "%temp%\au2sb"

::888b     d888               888          
::8888b   d8888               888          
::88888b.d88888               888          
::888Y88888P888  .d88b.   .d88888 .d8888b  
::888 Y888P 888 d88""88b d88" 888 88K      
::888  Y8P  888 888  888 888  888 "Y8888b. 
::888   "   888 Y88..88P Y88b 888      X88 
::888       888  "Y88P"   "Y88888  88888P' 

REM Check if mods_version exists
set "is_update=false"
set "mods_uptodate=false"
if exist "%minecraft_au2sb_folder%\au2sb\mods_version" (
    for /f %%A in ("%minecraft_au2sb_folder%\au2sb\mods_version") do (
        if %%~zA equ 0 (
            echo The mods version file appears empty? How did that even happen?
            REM Handle the empty file case here
            (echo %mods_url% > "%minecraft_au2sb_folder%\au2sb\mods_version")
        ) else (
            REM Read the contents of the file
            for /f "delims=" %%i in ('type "%minecraft_au2sb_folder%\au2sb\mods_version"') do (set "current_mods_url=%%i")
            set "current_mods_url=!current_mods_url:~0,-1!"
            if not exist "%minecraft_au2sb_folder%\mods" (
                set "mods_uptodate=false"
                echo Mods folder missing
                goto mods_skip_prompt
            )
            if not exist "%minecraft_au2sb_folder%\mods\*" (
                set "mods_uptodate=false"
                echo Mods folder empty
                goto mods_skip_prompt
            ) else (
                set "is_update=true"
            )
        )
    )
) else (
    REM If the file does not exist, create it and set the contents to mods_url
    (echo %mods_url% > "%minecraft_au2sb_folder%\au2sb\mods_version")
)

REM Compare the contents of the file with mods_url
if "!current_mods_url!"=="!mods_url!" (
    REM If they are the same, set mods_uptodate to true
    set "mods_uptodate=true"
    REM Mods up-to-date = !mods_uptodate!
) else (
    REM If they are not the same, update the file with the new mods_url
    REM Mods up-to-date = !mods_uptodate!
    (echo %mods_url% > "%minecraft_au2sb_folder%\au2sb\mods_version")
)

REM If mods are up to date offer for user override
if "%mods_uptodate%"=="true" (
    REM Prompt the user to override mods_uptodate
    echo Your mods appear to be up-to-date.
if "%startup_selection%"=="1" goto mods_skip_prompt
title %title_prompt%
    set /p "override_mods=Do you want to override and redownload mods anyway? ([y]es / no [Enter] = config only): "
title %title_installing%
    echo.
    REM If the user input is 'y' or 'yes', set mods_uptodate to false
    echo !override_mods! | findstr /I /C:"y" >nul && (set "mods_uptodate=false" && echo Mods status overruled) || (set "mods_uptodate=true" && echo Skipping mods && goto skip_mods)
)

:mods_skip_prompt
REM Download, extract, and move mods if mods_uptodate is not true
if "%mods_uptodate%"=="false" (
    echo Downloading mods...
    curl -L "%mods_url%" --output "%temp%\au2sb_mods.zip"

    REM Check the size of the downloaded file
    for %%A in ("%temp%\au2sb_mods.zip") do set mods_size=%%~zA
    REM If the file size is less than .5 GB (in bytes), indicate the mods download failed
    if !mods_size! LSS 500000000 (
        echo The download failed, please report that the mods download needs to be fixed
        set "fail_state=true"
        goto cleanup
    )

    echo Extracting mods...
    tar -xf "%temp%\au2sb_mods.zip" -C "%temp%\au2sb" 2>&1 >nul
    echo Moving mods to %minecraft_au2sb_folder%...
    robocopy "%temp%\au2sb\mods" "%minecraft_au2sb_folder%\mods" /s /purge /r:100 /move /log:"%temp%\au2sb_mods.log" 2>&1 >nul
)
:skip_mods

:: .d8888b.                     .d888 d8b          
::d88P  Y88b                   d88P"  Y8P          
::888    888                   888                 
::888         .d88b.  88888b.  888888 888  .d88b.  
::888        d88""88b 888 "88b 888    888 d88P"88b 
::888    888 888  888 888  888 888    888 888  888 
::Y88b  d88P Y88..88P 888  888 888    888 Y88b 888 
:: "Y8888P"   "Y88P"  888  888 888    888  "Y88888 
::                                             888 
::                                        Y8b d88P 
::                                         "Y88P"

REM Download, extract, and move config
echo Downloading config...
curl -L "%config_url%" --output "%temp%\au2sb_config.zip"

REM Check the size of the downloaded file
for %%A in ("%temp%\au2sb_config.zip") do set config_size=%%~zA
REM If the file size is less than 10MB (in bytes), indicate the mods download failed
if !config_size! LSS 10000000 (
    echo The download failed, please report that the config download needs to be fixed
    set "fail_state=true"
    goto cleanup
)

echo Extracting config...
tar -xf "%temp%\au2sb_config.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Moving config to %minecraft_au2sb_folder%...
robocopy "%temp%\au2sb\config" "%minecraft_au2sb_folder%\config" /s /r:100 /move /xo /log:"%temp%\au2sb_config.log" 2>&1 >nul

::8888888b.                                                                                        888               
::888   Y88b                                                                                       888               
::888    888                                                                                       888               
::888   d88P .d88b.  .d8888b   .d88b.  888  888 888d888 .d8888b .d88b.  88888b.   8888b.   .d8888b 888  888 .d8888b  
::8888888P" d8P  Y8b 88K      d88""88b 888  888 888P"  d88P"   d8P  Y8b 888 "88b     "88b d88P"    888 .88P 88K      
::888 T88b  88888888 "Y8888b. 888  888 888  888 888    888     88888888 888  888 .d888888 888      888888K  "Y8888b. 
::888  T88b Y8b.          X88 Y88..88P Y88b 888 888    Y88b.   Y8b.     888 d88P 888  888 Y88b.    888 "88b      X88 
::888   T88b "Y8888   88888P'  "Y88P"   "Y88888 888     "Y8888P "Y8888  88888P"  "Y888888  "Y8888P 888  888  88888P' 
::                                                                      888                                          
::                                                                      888                                          
::                                                                      888                                          

REM Check if resourcepacks_version exists
set "resourcepacks_uptodate=false"
if exist "%minecraft_au2sb_folder%\au2sb\resourcepacks_version" (
    for /f %%A in ("%minecraft_au2sb_folder%\au2sb\resourcepacks_version") do (
        if %%~zA equ 0 (
            echo The resourcepacks version file appears empty? How did that even happen?
            REM Handle the empty file case here
            (echo %resourcepacks_url% > "%minecraft_au2sb_folder%\au2sb\resourcepacks_version")
        ) else (
            REM Read the contents of the file
            for /f "delims=" %%i in ('type "%minecraft_au2sb_folder%\au2sb\resourcepacks_version"') do (set "current_resourcepacks_url=%%i")
            set "current_resourcepacks_url=!current_resourcepacks_url:~0,-1!"
            if not exist "%minecraft_au2sb_folder%\resourcepacks" (
                set "resourcepacks_uptodate=false"
                echo Resourcepacks folder missing
                goto resourcepacks_skip_prompt
            )
            if not exist "%minecraft_au2sb_folder%\resourcepacks\*" (
                set "resourcepacks_uptodate=false"
                echo Resourcepacks folder empty
                goto resourcepacks_skip_prompt
            )
        )
    )
) else (
    REM If the file does not exist, create it and set the contents to resourcepacks_url
    (echo %resourcepacks_url% > "%minecraft_au2sb_folder%\au2sb\resourcepacks_version")
)

REM Compare the contents of the file with resourcepacks_url
if "!current_resourcepacks_url!"=="!resourcepacks_url!" (
    set "resourcepacks_uptodate=true"
) else (
    REM If they are not the same, update the file with the new resourcepacks_url
    (echo %resourcepacks_url% > "%minecraft_au2sb_folder%\au2sb\resourcepacks_version")
)

REM If resourcepacks are up to date offer for user override
if "%resourcepacks_uptodate%"=="true" (
    REM Prompt the user to override resourcepacks_uptodate
    echo Your resourcepacks appear to be up-to-date.
if "%startup_selection%"=="1" goto resourcepacks_skip_prompt
title %title_prompt%
    set /p "override_resourcepacks=Do you want to override and redownload resourcepacks anyway? ([y]es / no [Enter] = config only): "
title %title_installing%
    echo.
    REM If the user input is 'y' or 'yes', set resourcepacks_uptodate to false
    echo !override_resourcepacks! | findstr /I /C:"y" >nul && (set "resourcepacks_uptodate=false" && echo Resourcepacks status overruled) || (set "resourcepacks_uptodate=true" && echo Skipping resourcepacks && goto skip_resourcepacks)
)

:resourcepacks_skip_prompt
REM Download, extract, and move mods if resourcepacks_uptodate is not true
if "%resourcepacks_uptodate%"=="false" (
    REM Download, extract, and move resourcepacks
    echo Downloading resourcepacks...
    curl -L "%resourcepacks_url%" --output "%temp%\au2sb_resourcepacks.zip"

    REM Check the size of the downloaded file
    for %%A in ("%temp%\au2sb_resourcepacks.zip") do set resourcepacks_size=%%~zA
    REM If the file size is less than 1MB (in bytes), indicate the mods download failed
    if !resourcepacks_size! LSS 1000000 (
        echo The download failed, please report that the resourcepacks download needs to be fixed
        set "fail_state=true"
        goto cleanup
    )

    echo Extracting resourcepacks...
    tar -xf "%temp%\au2sb_resourcepacks.zip" -C "%temp%\au2sb" 2>&1 >nul
    echo Moving resourcepacks to %minecraft_au2sb_folder%...
    robocopy "%temp%\au2sb\resourcepacks" "%minecraft_au2sb_folder%\resourcepacks" /s /r:100 /move /log:"%temp%\au2sb_resourcepacks.log" 2>&1 >nul
)
:skip_resourcepacks

::8888888888          888                             
::888                 888                             
::888                 888                             
::8888888    888  888 888888 888d888 8888b.  .d8888b  
::888        `Y8bd8P' 888    888P"      "88b 88K      
::888          X88K   888    888    .d888888 "Y8888b. 
::888        .d8""8b. Y88b.  888    888  888      X88 
::8888888888 888  888  "Y888 888    "Y888888  88888P' 

REM Download, extract, and move extras
echo Downloading extras...
curl -L "%extras_url%" --output "%temp%\au2sb_extras.zip"

REM Check the size of the downloaded file
for %%A in ("%temp%\au2sb_extras.zip") do set extras_size=%%~zA
REM If the file size is less than 1 byte, indicate the mods download failed
if !extras_size! LSS 1 (
    echo The download failed, please report that the extras download needs to be fixed
    set "fail_state=true"
    goto cleanup
)

echo Extracting extras...
tar -xf "%temp%\au2sb_extras.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Moving extras to %minecraft_au2sb_folder%...
robocopy "%temp%\au2sb" "%minecraft_au2sb_folder%" /s /r:100 /move /xo /log:"%temp%\au2sb_extras.log" 2>&1 >nul

::                  888    d8b                                888             888    
::                  888    Y8P                                888             888    
::                  888                                       888             888    
:: .d88b.  88888b.  888888 888  .d88b.  88888b.  .d8888b      888888 888  888 888888 
::d88""88b 888 "88b 888    888 d88""88b 888 "88b 88K          888    `Y8bd8P' 888    
::888  888 888  888 888    888 888  888 888  888 "Y8888b.     888      X88K   888    
::Y88..88P 888 d88P Y88b.  888 Y88..88P 888  888      X88 d8b Y88b.  .d8""8b. Y88b.  
:: "Y88P"  88888P"   "Y888 888  "Y88P"  888  888  88888P' Y8P  "Y888 888  888  "Y888 
::         888                                                                       
::         888                                                                       
::         888

REM copy options.txt
if not exist "%base_minecraft_folder%\options.txt" (
    echo Creating new options.txt file...
    (
        echo version:3465
        echo autoJump:false
        echo operatorItemsTab:false
        echo autoSuggestions:true
        echo chatColors:true
        echo chatLinks:true
        echo chatLinksPrompt:true
        echo enableVsync:true
        echo entityShadows:true
        echo forceUnicodeFont:false
        echo discrete_mouse_scroll:false
        echo invertYMouse:false
        echo realmsNotifications:true
        echo reducedDebugInfo:false
        echo showSubtitles:false
        echo directionalAudio:false
        echo touchscreen:false
        echo fullscreen:false
        echo bobView:true
        echo toggleCrouch:false
        echo toggleSprint:false
        echo darkMojangStudiosBackground:false
        echo hideLightningFlashes:false
        echo mouseSensitivity:0.5
        echo fov:0.0
        echo screenEffectScale:1.0
        echo fovEffectScale:1.0
        echo darknessEffectScale:1.0
        echo glintSpeed:0.5
        echo glintStrength:0.75
        echo damageTiltStrength:1.0
        echo highContrast:false
        echo gamma:0.0
        echo renderDistance:32
        echo simulationDistance:10
        echo entityDistanceScaling:1.0
        echo guiScale:4
        echo particles:0
        echo maxFps:260
        echo graphicsMode:1
        echo ao:true
        echo prioritizeChunkUpdates:0
        echo biomeBlendRadius:7
        echo renderClouds:"true"
        echo resourcePacks:[]
        echo incompatibleResourcePacks:[]
        echo lastServer:
        echo lang:en_us
        echo soundDevice:""
        echo chatVisibility:0
        echo chatOpacity:1.0
        echo chatLineSpacing:0.0
        echo textBackgroundOpacity:0.5
        echo backgroundForChatOnly:true
        echo hideServerAddress:false
        echo advancedItemTooltips:false
        echo pauseOnLostFocus:true
        echo overrideWidth:0
        echo overrideHeight:0
        echo chatHeightFocused:1.0
        echo chatDelay:0.0
        echo chatHeightUnfocused:0.4375
        echo chatScale:1.0
        echo chatWidth:1.0
        echo notificationDisplayTime:1.0
        echo mipmapLevels:4
        echo useNativeTransport:true
        echo mainHand:"right"
        echo attackIndicator:1
        echo narrator:0
        echo tutorialStep:movement
        echo mouseWheelSensitivity:1.0
        echo rawMouseInput:true
        echo glDebugVerbosity:1
        echo skipMultiplayerWarning:false
        echo skipRealms32bitWarning:false
        echo hideMatchedNames:true
        echo joinedFirstServer:false
        echo hideBundleTutorial:false
        echo syncChunkWrites:true
        echo showAutosaveIndicator:true
        echo allowServerListing:true
        echo onlyShowSecureChat:false
        echo panoramaScrollSpeed:1.0
        echo telemetryOptInExtra:false
        echo onboardAccessibility:false
        echo key_key.attack:key.mouse.left
        echo key_key.use:key.mouse.right
        echo key_key.forward:key.keyboard.w
        echo key_key.left:key.keyboard.a
        echo key_key.back:key.keyboard.s
        echo key_key.right:key.keyboard.d
        echo key_key.jump:key.keyboard.space
        echo key_key.sneak:key.keyboard.left.shift
        echo key_key.sprint:key.keyboard.left.control
        echo key_key.drop:key.keyboard.q
        echo key_key.inventory:key.keyboard.e
        echo key_key.chat:key.keyboard.t
        echo key_key.playerlist:key.keyboard.tab
        echo key_key.pickItem:key.mouse.middle
        echo key_key.command:key.keyboard.slash
        echo key_key.socialInteractions:key.keyboard.p
        echo key_key.screenshot:key.keyboard.f2
        echo key_key.togglePerspective:key.keyboard.f5
        echo key_key.smoothCamera:key.keyboard.unknown
        echo key_key.fullscreen:key.keyboard.f11
        echo key_key.spectatorOutlines:key.keyboard.unknown
        echo key_key.swapOffhand:key.keyboard.f
        echo key_key.saveToolbarActivator:key.keyboard.c
        echo key_key.loadToolbarActivator:key.keyboard.x
        echo key_key.advancements:key.keyboard.l
        echo key_key.hotbar.1:key.keyboard.1
        echo key_key.hotbar.2:key.keyboard.2
        echo key_key.hotbar.3:key.keyboard.3
        echo key_key.hotbar.4:key.keyboard.4
        echo key_key.hotbar.5:key.keyboard.5
        echo key_key.hotbar.6:key.keyboard.6
        echo key_key.hotbar.7:key.keyboard.7
        echo key_key.hotbar.8:key.keyboard.8
        echo key_key.hotbar.9:key.keyboard.9
        echo soundCategory_master:0.5
        echo soundCategory_music:1.0
        echo soundCategory_record:1.0
        echo soundCategory_weather:1.0
        echo soundCategory_block:0.7
        echo soundCategory_hostile:0.5
        echo soundCategory_neutral:0.25
        echo soundCategory_player:0.32
        echo soundCategory_ambient:0.5
        echo soundCategory_voice:1.0
        echo modelPart_cape:true
        echo modelPart_jacket:true
        echo modelPart_left_sleeve:true
        echo modelPart_right_sleeve:true
        echo modelPart_left_pants_leg:true
        echo modelPart_right_pants_leg:true
        echo modelPart_hat:true
    ) > "%base_minecraft_folder%\options.txt"
)
if not exist "%minecraft_au2sb_folder%\options.txt" copy /Y "%base_minecraft_folder%\options.txt" "%minecraft_au2sb_folder%\options.txt" >nul

REM Read the options.txt file and replace the resourcePacks line
set "optionsfile=%minecraft_au2sb_folder%\options.txt"
set "optionsfiletemp=%temp%\au2sboptionsfiletemp.txt"
if exist "%optionsfiletemp%" del "%optionsfiletemp%"
for /f "delims=" %%i in (%optionsfile%) do (
    set "line=%%i"
    if "!line:~0,13!"=="resourcePacks" (
        echo resourcePacks:["vanilla","Fabrication grayscale","Fabrication","Moonlight Mods Dynamic Assets","convenientdecor:hydrated_farmland","moreberries:modifiedsweetberrybushmodel","fabric","continuity:default","continuity:glass_pane_culling_fix","file/Nautilus3D_V1.9_[MC-1.13+].zip","file/AU2SB Panorama.zip","file/AU2SB WATUT.zip","file/AU2SB CIT.zip","seamless:default_seamless","seasons:seasonal_lush_caves","file/Os\u0027 Colorful Cobblestone.zip","file/Os\u0027 2D Iron Bars.zip","meadow:optifine_support","vinery:bushy_leaves","presencefootsteps:default_sound_pack","rprenames:default_dark_mode","file/Authentic Shadows_1.20.zip","file/§9RAY\u0027s§r 3D Rails.zip","file/§bRAY\u0027s§r 3D Ladders.zip","file/xali\u0027s Potions v1.0.0.zip","file/Better Cats 1.20.zip","file/Better Horses 1.20.zip","file/Sparkles_1.21_v1.0.7.zip","file/better_flame_particles-v2.0-mc1.14x-1.20x-resourcepack.zip","telepistons:enable_steam","telepistons:bellows_pistons","file/GUI-SimpleStylized_4.7-1.20+.zip","file/Brewing Guide 1.20.zip","file/[1.4.1] Enhanced Boss Bars.zip"]>>"%optionsfiletemp%"
    ) else if "!line:~0,24!"=="incompatibleResourcePacks" (
        echo incompatibleResourcePacks:["file/§9RAY\u0027s§r 3D Rails.zip","file/§bRAY\u0027s§r 3D Ladders.zip","file/xali\u0027s Potions v1.0.0.zip"]>>"%optionsfiletemp%"
    ) else if "!line:~0,16!"=="glDebugVerbosity" (
        echo glDebugVerbosity:0>>"%optionsfiletemp%"
    ) else (
        echo !line!>>"%optionsfiletemp%"
    )
)
move /Y "%optionsfiletemp%" "%optionsfile%" >nul

REM Replace the options.txt keybindings with custom defaults if not previously done, powershell is easier for this bulk operation
if not exist "%minecraft_au2sb_folder%\au2sb\keybinds_set" (
    powershell -Command "$keybinds = @{}; (Get-Content '%minecraft_au2sb_folder%\defaultkeybinds.txt') | ForEach-Object { $key = ($_ -split ':')[0]; $keybinds[$key] = $_ }; $newContent = (Get-Content '%minecraft_au2sb_folder%\options.txt') | ForEach-Object { if ($_ -match '^key_') { $key = ($_ -split ':')[0]; if ($keybinds.ContainsKey($key)) { $keybinds[$key] } else { $_ } } else { $_ } }; $keybinds.Keys | ForEach-Object { if ($keybinds[$_]) { $newContent += $keybinds[$_] } }; $newContent | Out-File -FilePath '%minecraft_au2sb_folder%\options.txt' -Encoding utf8"

    echo. 2> "%minecraft_au2sb_folder%\au2sb\keybinds_set"
)

:: .d8888b.  888                                              
::d88P  Y88b 888                                              
::888    888 888                                              
::888        888  .d88b.   8888b.  88888b.  888  888 88888b.  
::888        888 d8P  Y8b     "88b 888 "88b 888  888 888 "88b 
::888    888 888 88888888 .d888888 888  888 888  888 888  888 
::Y88b  d88P 888 Y8b.     888  888 888  888 Y88b 888 888 d88P 
:: "Y8888P"  888  "Y8888  "Y888888 888  888  "Y88888 88888P"  
::                                                   888      
::                                                   888      
::                                                   888

:cleanup
title %title_cleaning%
REM Delete the zips
echo Cleaning up leftovers...
if "%mods_uptodate%"=="false" (
    del "%temp%\au2sb_mods.zip" /q 2>&1 >nul
)
del "%temp%\au2sb_config.zip" /q 2>&1 >nul
if "%resourcepacks_uptodate%"=="false" (
    del "%temp%\au2sb_resourcepacks.zip" /q 2>&1 >nul
)
del "%temp%\au2sb_extras.zip" /q 2>&1 >nul
rmdir "%temp%\au2sb" /s /q

REM delete voicechat if dvc true
if exist "%minecraft_au2sb_folder%\au2sb\dvc" (
set /p dvc=<"%minecraft_au2sb_folder%\au2sb\dvc"
)
if "%dvc%"=="true" (
    del "%minecraft_au2sb_folder%\mods\voicechat-fabric-*.jar" /s /q
)

:fail_end
REM Exit if in failed state
if "%fail_state%"=="true" (
echo. & echo. & echo. & echo.
echo.               .d88 
echo.        d8b   d88P' 
echo.        Y8P  d88P   
echo.             888    
echo.             888    
echo.        d8b  Y88b   
echo.        Y8P   Y88b. 
echo.               'Y88 
echo. & echo. & echo.
title %title_failed%
echo Something went wrong along the way, please report the issue and save the terminal output for reference.
echo Press any key to exit.
    pause >nul
    exit
)

::8888888888P                         888    d8b                  
::      d88P                          888    Y8P                  
::     d88P                           888                         
::    d88P    .d88b.  888d888 .d88b.  888888 888  .d88b.  888d888 
::   d88P    d8P  Y8b 888P"  d88""88b 888    888 d8P  Y8b 888P"   
::  d88P     88888888 888    888  888 888    888 88888888 888     
:: d88P      Y8b.     888    Y88..88P Y88b.  888 Y8b.     888     
::d8888888888 "Y8888  888     "Y88P"   "Y888 888  "Y8888  888     

echo.
if not exist "%minecraft_au2sb_folder%\au2sb\zerotier_set" (
:: Check for ZeroTier network
ipconfig /all | findstr /C:"ZeroTier" >nul 2>&1 && (
    echo. 2> "%minecraft_au2sb_folder%\au2sb\zerotier_set"
    goto skip_zerotier
) || (
    echo No ZeroTier network detected
)
:: Check if ZeroTier is installed
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "ZeroTier" | findstr "DisplayName" >nul && (
    echo ZeroTier is installed
    echo. 2> "%minecraft_au2sb_folder%\au2sb\zerotier_set"
    goto skip_zerotier
) || (
    echo ZeroTier is not installed
)
echo We use ZeroTier for our SD-WAN so it is required to play
title %title_prompt%
    set /p "zerotier_prompt=Please confirm to install ZeroTier ([y]es / no [Enter]): "
    echo.
    REM If the user input confirms, install zerotier
    echo !zerotier_prompt! | findstr /I /C:"y" >nul && (
    title %title_installing%
            set "zerotier_note=true"
            echo Installing ZeroTier now...
            winget.exe install --id ZeroTier.ZeroTierOne --exact
            REM Create file at "%minecraft_au2sb_folder%\au2sb\zerotier_set" after ZeroTier is installed
            echo. 2> "%minecraft_au2sb_folder%\au2sb\zerotier_set"
        ) || (
            set "zerotier_note=true"
            echo Please ensure ZeroTier is installed and configured before attempting to play AU2SB.
        )
)
:skip_zerotier

echo.|set /p="%latest_AU2SB_version%" > "%minecraft_au2sb_folder%\au2sb\version"

title %title_finished%
echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo.
echo.       BTTTTTTTTTTjBPTTTTBPTTTTB #TTTTjBPTTTTBPTTTTTTTTTT#KTTTT#BTTTTjBTTTTTTTTTTjBPTTTTTTTTjggPTTTT#
echo.      jK    ,,,,,,/B    jB     P#B    jB     BP    ,,,,,,#K    jB    jB     ,,,,,;BP    ,,    jB    jK
echo.      B     BBBBBBBK    /B      #K    jB    jB'    BBBBBBBK    jB    -B'    BBBBBBBb    jB    -B     B
echo.     jK           BM    BK    zg      jB    jB           jB           BP          jB     BP    #K    jk
echo.     #'    BBBBBBBB     BM    BK,     BK    jBBBBBBBP    jB    jB'    BK    jBBBBBBBW    #K    jBPPPPPB
echo.    jP    jBBBBBBBK    jB     BBB     BK    jB           jB    jB-    #b           BK           Bk    jC
echo.    #WgggggBBBPTTtWgggggBgggggBBBgggggBkgggggBggggggggggggBgggggBkgggggBggggggggggggBggggggggggBBBgggggB
echo.     TBBBBBBBB    jBBBBBBBBBBBBBhBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBP
echo.      '#BBBBBK     jBBBBBBBBBBBB #BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBCjBBBBBB-
echo.
echo            Tips:
echo        The game will take a few moments to launch, it will ding when finished.  Neat!exclaim!
echo.
echo        If the game appears to be "not responding" on the loading screen please wait for a
echo        moment, it is likely still loading.
echo.
echo.
REM Check the variables and display the appropriate messages
if "%is_update%"=="true" (
echo                                            AU2SB updated!exclaim!
) else (
echo                                           AU2SB installed!exclaim!
)
echo.
if "%zerotier_note%"=="true" (
echo        NOTE: You will need to configure ZeroTier and be authorized before playing AU2SB.
)
echo.
echo        Start your game with the AU2SB %latest_AU2SB_version% profile in the official Minecraft Launcher.
echo.
echo Press any key to return to the Options...
pause >nul
echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo. & echo.
goto start