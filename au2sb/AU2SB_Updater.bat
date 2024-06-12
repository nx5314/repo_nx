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
