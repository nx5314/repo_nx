@echo off
title AU2SB Updater 1.0.1
setlocal enabledelayedexpansion
REM Set the current version of the script
set "this_updater_version=1.0.1"
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
echo        This installer/updater script will automatically download the required mods and config files. 
echo.
echo        Fabric will be installed automatically if it is not already installed. (Requires Java)
echo.
echo        Please enter the folder path if you are using a custom Minecraft folder location, or
echo        press Enter if you would like to use the default .minecraft_au2sb folder: 
set /p "minecraft_au2sb_folder="
REM If the user enters nothing, set minecraft_au2sb_folder to %appdata%\.minecraft_au2sb
if "%minecraft_au2sb_folder%"=="" set "minecraft_au2sb_folder=%appdata%\.minecraft_au2sb" >nul
set "base_minecraft_folder=%appdata%\.minecraft" >nul
echo.

REM Make folder
if not exist "%appdata%\.minecraft_au2sb" mkdir "%appdata%\.minecraft_au2sb"
if not exist "%temp%\au2sb" mkdir "%temp%\au2sb"

REM Fetch the URL for the download
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/mods.txt') do (set "mods_url=%%i")
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/config.txt') do (set "config_url=%%i")
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/resourcepacks.txt') do (set "resourcepacks_url=%%i")
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/extras.txt') do (set "extras_url=%%i")

REM Check if AU2SBmodsversion exists
set "is_update=false"
set "mods_uptodate=false"
if exist "%minecraft_au2sb_folder%\AU2SBmodsversion" (
    for /f %%A in ("%minecraft_au2sb_folder%\AU2SBmodsversion") do (
        if %%~zA equ 0 (
            echo The mods version file appears empty.
            REM Handle the empty file case here
            (echo %mods_url% > "%minecraft_au2sb_folder%\AU2SBmodsversion")
        ) else (
            REM Read the contents of the file
            for /f "delims=" %%i in ('type "%minecraft_au2sb_folder%\AU2SBmodsversion"') do (set "current_mods_url=%%i")
            set "current_mods_url=!current_mods_url:~0,-1!"
            set "is_update=true"
            goto continue
        )
    )
) else (
    REM If the file does not exist, create it and set the contents to mods_url
    (echo %mods_url% > "%minecraft_au2sb_folder%\AU2SBmodsversion")
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
    (echo %mods_url% > "%minecraft_au2sb_folder%\AU2SBmodsversion")
)

REM If mods are up to date offer for user override
if "%mods_uptodate%"=="true" (
    REM Prompt the user to override mods_uptodate
    echo Your mods appear to be up-to-date.
    set /p "user_input=Do you want to override and download mods anyway? ([y]es / no [Enter] = config only): "
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
    echo Moving mods to %minecraft_au2sb_folder%...
    robocopy "%temp%\au2sb\mods" "%minecraft_au2sb_folder%\mods" /s /purge /r:100 /move /log:"%temp%\au2sb_mods.log" 2>&1 >nul
)

REM Download, extract, and move config
echo Downloading config...
curl -L "%config_url%" --output "%temp%\au2sb_config.zip"
echo Extracting config...
tar -xf "%temp%\au2sb_config.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Moving config to %minecraft_au2sb_folder%...
robocopy "%temp%\au2sb\config" "%minecraft_au2sb_folder%\config" /s /r:100 /move /log:"%temp%\au2sb_config.log" 2>&1 >nul

REM Download, extract, and move resourcepacks
echo Downloading resourcepacks...
curl -L "%resourcepacks_url%" --output "%temp%\au2sb_resourcepacks.zip"
echo Extracting resourcepacks...
tar -xf "%temp%\au2sb_resourcepacks.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Moving resourcepacks to %minecraft_au2sb_folder%...
robocopy "%temp%\au2sb\resourcepacks" "%minecraft_au2sb_folder%\resourcepacks" /s /r:100 /move /log:"%temp%\au2sb_resourcepacks.log" 2>&1 >nul

REM Download, extract, and move extras
echo Downloading extras...
curl -L "%extras_url%" --output "%temp%\au2sb_extras.zip"
echo Extracting extras...
tar -xf "%temp%\au2sb_extras.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Moving extras to %minecraft_au2sb_folder%...
robocopy "%temp%\au2sb" "%minecraft_au2sb_folder%" /s /r:100 /move /log:"%temp%\au2sb_extras.log" 2>&1 >nul

REM Delete the zips
echo Cleaning up zips...
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

REM If missing, download fabric and java installer and run
if "%fabric_exists%"=="false" (
	echo.
	echo Fabric appears to not be installed, downloading now
    curl -L https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar --output "%temp%\fabric-installer.jar"
	echo.
    winget.exe install --id EclipseAdoptium.Temurin.21.JRE --exact --accept-source-agreements --silent --disable-interactivity --accept-package-agreements
    java -jar %temp%\fabric-installer.jar client -mcversion 1.20.1 -dir %appdata%\.minecraft
	echo Fabric installed (unless there is an error indicating you are missing java)
)

REM Define the path to the launcher_profiles.json file
set "launcher_profiles=%appdata%\.minecraft\launcher_profiles.json"

REM Invoke PowerShell to add the AU2SB profile to the launcher_profiles.json file
PowerShell -Command "$json = Get-Content -Path '%launcher_profiles%' -Raw | ConvertFrom-Json; $au2sbProfile = @{ 'AU2SB' = @{ 'created' = '1970-01-01T00:00:00.002Z'; 'gameDir' = '%minecraft_au2sb_folder%'; 'icon' = 'data:image/png;base64,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'; 'javaArgs' = '-Xmx12G -Xms12G -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseNUMA -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:ThreadPriorityPolicy=1 -XX:AllocatePrefetchStyle=3  -XX:+UseG1GC -XX:MaxGCPauseMillis=37 -XX:+PerfDisableSharedMem -XX:G1HeapRegionSize=16M -XX:G1NewSizePercent=23 -XX:G1ReservePercent=20 -XX:SurvivorRatio=32 -XX:G1MixedGCCountTarget=3 -XX:G1HeapWastePercent=20 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1RSetUpdatingPauseTimePercent=0 -XX:MaxTenuringThreshold=1 -XX:G1SATBBufferEnqueueingThresholdPercent=30 -XX:G1ConcMarkStepDurationMillis=5.0 -XX:G1ConcRSHotCardLimit=16 -XX:G1ConcRefinementServiceIntervalMillis=150 -XX:GCTimeRatio=99'; 'lastUsed' = '2063-04-05T00:00:00.002Z'; 'lastVersionId' = 'fabric-loader-0.15.11-1.20.1'; 'name' = 'AU2SB'; 'type' = 'custom' } }; if ($json.profiles.'AU2SB') { $json.profiles.'AU2SB' = $au2sbProfile.'AU2SB' } else { $json.profiles | Add-Member -NotePropertyName 'AU2SB' -NotePropertyValue $au2sbProfile.'AU2SB' }; $json | ConvertTo-Json -Depth 100 | Set-Content -Path '%launcher_profiles%'"

echo.
echo AU2SB profile created

REM copy options.txt
if not exist "%minecraft_au2sb_folder%\options.txt" copy /Y "%base_minecraft_folder%\options.txt" "%minecraft_au2sb_folder%\options.txt" >nul

REM Read the options.txt file and replace the resourcePacks line
setlocal enabledelayedexpansion
set "optionsfile=%minecraft_au2sb_folder%\options.txt"
set "optionsfiletemp=%temp%\au2sboptionsfiletemp.txt"
if exist "%optionsfiletemp%" del "%optionsfiletemp%"
for /f "delims=" %%i in (%optionsfile%) do (
    set "line=%%i"
    if "!line:~0,13!"=="resourcePacks" (
        echo resourcePacks:["vanilla","fabric","Moonlight Mods Dynamic Assets","convenientdecor:hydrated_farmland","moreberries:modifiedsweetberrybushmodel","Fabrication","Fabrication grayscale","seamless:default_seamless","seasons:seasonal_lush_caves","rprenames:default_dark_mode","presencefootsteps:default_sound_pack","file/Nautilus3D_V1.9_[MC-1.13+].zip","file/Fancy, GUI Overhaul v0.1.2.8.zip","a_good_place:default_animations","file/better_flame_particles-v2.0-mc1.14x-1.20x-resourcepack.zip","file/[1.4] Enhanced Boss Bars.zip"]>>"%optionsfiletemp%"
    ) else (
        echo !line!>>"%optionsfiletemp%"
    )
)
move /Y "%optionsfiletemp%" "%optionsfile%" >nul

echo.
REM Check the flag and display the appropriate message
if "!is_update!"=="true" (
    echo Modpack updated
) else (
    echo Modpack installed
)
echo.
echo You can now launch your game with the AU2SB profile
echo.
echo If there were any errors please let me know
endlocal
pause
