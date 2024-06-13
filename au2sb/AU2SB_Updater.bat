@echo off
title AU2SB Updater 1.1.0
setlocal enabledelayedexpansion
REM Set the current version of the script
set "this_updater_version=1.1.0"
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
REM Intro and path prompt
echo        This installer/updater script will automatically download the required mods and config files. 
echo.
echo        An AU2SB profile will be created in the Minecraft launcher.
echo        Fabric will be installed automatically if it is not already installed.
echo.
echo        Please enter the folder path if you would like to use a custom folder location, or
echo        press Enter if you would like to use the default .minecraft_au2sb folder. (recommended)
echo.
set /p "minecraft_au2sb_folder=Path: "
REM If the user enters nothing, set minecraft_au2sb_folder to %appdata%\.minecraft_au2sb
if "%minecraft_au2sb_folder%"=="" set "minecraft_au2sb_folder=%appdata%\.minecraft_au2sb" >nul
set "base_minecraft_folder=%appdata%\.minecraft" >nul
echo.
echo Path set to %minecraft_au2sb_folder%
echo.

REM Check if %appdata%\.minecraft exists
if not exist "%appdata%\.minecraft" (
    echo Can't seem to find the base .minecraft folder, something weird going on or do you not have the game installed?
    pause
    exit /b    
)

REM Make folder
if not exist "%appdata%\.minecraft_au2sb" mkdir "%appdata%\.minecraft_au2sb"
if not exist "%temp%\au2sb" mkdir "%temp%\au2sb"

REM Check fabric installation
set "fabric_exists=false"
if exist "%appdata%\.minecraft\versions\fabric-loader-0.15.11-1.20.1" (
    set "fabric_exists=true"
    goto :fabric_is_installed
)

REM If missing, download fabric and java installer and run
if "%fabric_exists%"=="false" (
	echo.
	echo Fabric appears to not be installed, downloading now
    curl -L https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar --output "%temp%\fabric-installer.jar"
	echo.
    java -jar %temp%\fabric-installer.jar client -mcversion 1.20.1 -dir %appdata%\.minecraft
    goto check_fabric
) else (
    goto skip_check_fabric
)
:check_fabric
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
:skip_check_fabric
REM If java needs to be installed
if "%need_java%"=="true" (
    echo.
    set "install_java=null"
    set /p "install_java=Would you like to install Java? ([y]es / no [Enter] = skip, fabric will not be installed): "
    echo.
)
REM If the user input contains 'y' or 'Y', install java
set "input_java=%install_java%"
set "result_java=!input_java:y=!"
if not "!result_java!"=="%install_java%" (
    echo Java will now be installed    
    REM Initialize a variable for the file size
    set size=0
    REM Loop until the file size is at least 33MB (in bytes)
    :downloadLoop
    curl -L "https://eif7tq.dm.files.1drv.com/y4maXEo--4pCZFY3H2U9wsEO--av1LGdWDzoum26zFJ4cAxxoI17VyJA8GcGtiDMDbBNJ8Oy4N7k5H_w511KLhmeyuBSLEAVNh8uUJbF83UtJRUB7t_ygL45nYD2BYLQyB19lh4K2pnJriShoMO6TG6wZosKZBx7CBuTMbkkoYtVnKfn5t_lfNH_SUBhXZ9E7vBZWq9MCWAEmiOrzRYY8ouuA" --output "%temp%\OpenJDK21U-jre_x64_windows_hotspot_21.0.3_9.msi"
    timeout /t 10 /nobreak >nul
    REM Check the size of the downloaded file
    for %%A in ("%temp%\OpenJDK21U-jre_x64_windows_hotspot_21.0.3_9.msi") do set size=%%~zA
    REM I really tried to get this to download from the official github but it just would not cooperate when run in the bat which is why all this shit is here and I am too lazy to remove it
    REM If the file size is less than 33MB (in bytes), go back to the start of the loop
    if !size! LSS 34603008 (
        echo The download failed, attempting to download again
        timeout /t 10 /nobreak >nul
        goto downloadLoop
    )
    
    msiexec /i "%temp%\OpenJDK21U-jre_x64_windows_hotspot_21.0.3_9.msi" INSTALLLEVEL=1 /quiet
    del "%temp%\OpenJDK21U-jre_x64_windows_hotspot_21.0.3_9.msi" /q 2>&1 >nul
    echo Java should now be installed, please exit this terminal window and run this installer again to finish installing AU2SB
    pause
    exit /b
)

if /i "%install_java%"=="" (
    echo Java will not be installed, please install it yourself and run this installer again to finish installing AU2SB
    pause
    exit /b
)

:fabric_is_installed

REM Define the path to the launcher_profiles.json file
set "launcher_profiles=%appdata%\.minecraft\launcher_profiles.json"

REM Invoke PowerShell to add the AU2SB profile to the launcher_profiles.json file
powershell -Command "$newAU2SBProfile = @{ 'created' = '1970-01-01T00:00:00.002Z'; 'gameDir' = '%minecraft_au2sb_folder%'; 'icon' = 'data:image/png;base64,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'; 'javaArgs' = '-Xmx12G -Xms12G -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseNUMA -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:ThreadPriorityPolicy=1 -XX:AllocatePrefetchStyle=3  -XX:+UseG1GC -XX:MaxGCPauseMillis=37 -XX:+PerfDisableSharedMem -XX:G1HeapRegionSize=16M -XX:G1NewSizePercent=23 -XX:G1ReservePercent=20 -XX:SurvivorRatio=32 -XX:G1MixedGCCountTarget=3 -XX:G1HeapWastePercent=20 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1RSetUpdatingPauseTimePercent=0 -XX:MaxTenuringThreshold=1 -XX:G1SATBBufferEnqueueingThresholdPercent=30 -XX:G1ConcMarkStepDurationMillis=5.0 -XX:G1ConcRSHotCardLimit=16 -XX:G1ConcRefinementServiceIntervalMillis=150 -XX:GCTimeRatio=99'; 'lastUsed' = '2063-04-05T00:00:00.002Z'; 'lastVersionId' = 'fabric-loader-0.15.11-1.20.1'; 'name' = 'AU2SB'; 'type' = 'custom' }; $jsonFilePath = '%launcher_profiles%'; $jsonContent = Get-Content -Path $jsonFilePath | ConvertFrom-Json; if ($jsonContent.profiles.PSObject.Properties.Name -contains 'AU2SB') { $jsonContent.profiles.AU2SB = $newAU2SBProfile } else { $jsonContent.profiles | Add-Member -MemberType NoteProperty -Name 'AU2SB' -Value $newAU2SBProfile -Force }; $jsonContent | ConvertTo-Json -Depth 32 | Set-Content -Path $jsonFilePath"


REM copy options.txt
if not exist "%minecraft_au2sb_folder%\options.txt" copy /Y "%base_minecraft_folder%\options.txt" "%minecraft_au2sb_folder%\options.txt" >nul

REM Read the options.txt file and replace the resourcePacks line
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

REM Fetch the URL for the downloads
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
            echo The mods version file appears empty? How did that even happen?
            REM Handle the empty file case here
            (echo %mods_url% > "%minecraft_au2sb_folder%\AU2SBmodsversion")
        ) else (
            REM Read the contents of the file
            for /f "delims=" %%i in ('type "%minecraft_au2sb_folder%\AU2SBmodsversion"') do (set "current_mods_url=%%i")
            set "current_mods_url=!current_mods_url:~0,-1!"
            if not exist "%minecraft_au2sb_folder%\mods" (
                set "mods_uptodate=false"
                echo Mods folder missing
                echo.
                goto mods_folder_empty_or_missing
            if not exist "%minecraft_au2sb_folder%\mods\*" (
                set "mods_uptodate=false"
                echo Mods folder empty
                echo.
                goto mods_folder_empty_or_missing
            ) else (
                set "is_update=true"
                goto continue
            )
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
    set /p "override_mods=     Do you want to override and download mods anyway? ([y]es / no [Enter] = config only): "
    echo.
)
if "%override_mods%"=="" (
    echo Skipping mods
    echo.
    goto skip_mods
)
REM If the user input is 'y' or 'yes', set mods_uptodate to false
set "input_override_mods=%override_mods%"
set "result_mods=!input_override_mods:y=!"
if not "!result_mods!"=="%override_mods%" (
    set "mods_uptodate=false"
    echo Mods status overruled
    REM Mods up-to-date set to = %mods_uptodate%
)

:mods_folder_empty_or_missing
REM Download, extract, and move mods if mods_uptodate is not true
if not "!mods_uptodate!"=="true" (
    echo Downloading mods...
    curl -L "%mods_url%" --output "%temp%\au2sb_mods.zip"

    REM Check the size of the downloaded file
    for %%A in ("%temp%\au2sb_mods.zip") do set mods_size=%%~zA
    REM If the file size is less than .5GB (in bytes), indicate the mods download failed
    if !mods_size! LSS 500000000 (
        echo The download failed, please report that the mods download needs to be fixed
        set "fail_state=true"
        goto :cleanup
    )

    echo Extracting mods...
    tar -xf "%temp%\au2sb_mods.zip" -C "%temp%\au2sb" 2>&1 >nul
    echo Moving mods to %minecraft_au2sb_folder%...
    robocopy "%temp%\au2sb\mods" "%minecraft_au2sb_folder%\mods" /s /purge /r:100 /move /log:"%temp%\au2sb_mods.log" 2>&1 >nul
)
:skip_mods
REM Download, extract, and move config
echo Downloading config...
curl -L "%config_url%" --output "%temp%\au2sb_config.zip"

REM Check the size of the downloaded file
for %%A in ("%temp%\au2sb_config.zip") do set config_size=%%~zA
REM If the file size is less than 10MB (in bytes), indicate the mods download failed
if !config_size! LSS 10000000 (
    echo The download failed, please report that the config download needs to be fixed
    set "fail_state=true"
    goto :cleanup
)

echo Extracting config...
tar -xf "%temp%\au2sb_config.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Moving config to %minecraft_au2sb_folder%...
robocopy "%temp%\au2sb\config" "%minecraft_au2sb_folder%\config" /s /r:100 /move /log:"%temp%\au2sb_config.log" 2>&1 >nul

REM Download, extract, and move resourcepacks
echo Downloading resourcepacks...
curl -L "%resourcepacks_url%" --output "%temp%\au2sb_resourcepacks.zip"

REM Check the size of the downloaded file
for %%A in ("%temp%\au2sb_resourcepacks.zip") do set resourcepacks_size=%%~zA
REM If the file size is less than 1MB (in bytes), indicate the mods download failed
if !resourcepacks_size! LSS 1000000 (
    echo The download failed, please report that the resourcepacks download needs to be fixed
    set "fail_state=true"
    goto :cleanup
)

echo Extracting resourcepacks...
tar -xf "%temp%\au2sb_resourcepacks.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Moving resourcepacks to %minecraft_au2sb_folder%...
robocopy "%temp%\au2sb\resourcepacks" "%minecraft_au2sb_folder%\resourcepacks" /s /r:100 /move /log:"%temp%\au2sb_resourcepacks.log" 2>&1 >nul

REM Download, extract, and move extras
echo Downloading extras...
curl -L "%extras_url%" --output "%temp%\au2sb_extras.zip"

REM Check the size of the downloaded file
for %%A in ("%temp%\au2sb_extras.zip") do set extras_size=%%~zA
REM If the file size is less than 1 byte, indicate the mods download failed
if !extras_size! LSS 1 (
    echo The download failed, please report that the extras download needs to be fixed
    set "fail_state=true"
    goto :cleanup
)

echo Extracting extras...
tar -xf "%temp%\au2sb_extras.zip" -C "%temp%\au2sb" 2>&1 >nul
echo Moving extras to %minecraft_au2sb_folder%...
robocopy "%temp%\au2sb" "%minecraft_au2sb_folder%" /s /r:100 /move /log:"%temp%\au2sb_extras.log" 2>&1 >nul

:cleanup
REM Delete the zips
echo Cleaning up zips...
if "%mods_uptodate%"=="false" (
    del "%temp%\au2sb_mods.zip" /q 2>&1 >nul
)
del "%temp%\au2sb_config.zip" /q 2>&1 >nul
del "%temp%\au2sb_resourcepacks.zip" /q 2>&1 >nul
del "%temp%\au2sb_extras.zip" /q 2>&1 >nul
rmdir "%temp%\au2sb" /s /q

REM Exit if in failed state
if "%fail_state%"=="true" (
    pause
    exit /b
)

echo.
REM Check the flag and display the appropriate message
if "!is_update!"=="true" (
    echo Modpack updated
) else (
    echo Modpack installed
)
echo.
echo        Launch your game with the AU2SB profile
echo        You may need to adjust the RAM allocation in the launcher if you experience instability
echo.
echo        If there were any errors please let me know
echo.
endlocal
pause
