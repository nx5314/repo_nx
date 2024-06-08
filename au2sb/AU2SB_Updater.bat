@echo off
setlocal
set "this_updater_version=1.0.0"
:: Check updater version
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/updaterversion.txt') do set "latest_updater_version=%%i"
:: Compare versions
if not "%latest_updater_version%"=="%this_updater_version%" (
    echo Your updater is out of date. The latest version is %latest_updater_version%.
    echo Please enter the directory where you want to save the new updater,
    set /p "user_download_path=or press Enter to use the current directory: "
    :: If the user enters nothing, set user_download_path to the current directory
    if "%user_download_path%"=="" set "user_download_path=%cd%" >nul
    echo.
    echo Downloading the latest updater...
    curl -L "https://raw.githubusercontent.com/nx5314/repo_nx/main/au2sb/AU2SB_Updater.bat" --output "%user_download_path%\AU2SB_Updater_%latest_updater_version%.bat"
    echo.
    echo The latest updater has been downloaded to %user_download_path%\AU2SB_Updater_%latest_updater_version%.bat.
    echo Please run the new updater.
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

echo Downloading mods
if exist "%temp%\au2sb" rmdir "%temp%\au2sb" /s /q 2>&1 >nul
mkdir "%temp%\au2sb" 2>&1 >nul
curl -L "%mods_url%" --output "%temp%\au2sb_mods.zip"
curl -L "%config_url%" --output "%temp%\au2sb_config.zip"
curl -L "%resourcepacks_url%" --output "%temp%\au2sb_resourcepacks.zip"
curl -L "%extras_url%" --output "%temp%\au2sb_extras.zip"
tar -xf "%temp%\au2sb_mods.zip" -C "%temp%\au2sb" 2>&1 >nul
tar -xf "%temp%\au2sb_config.zip" -C "%temp%\au2sb" 2>&1 >nul
tar -xf "%temp%\au2sb_resourcepacks.zip" -C "%temp%\au2sb" 2>&1 >nul
tar -xf "%temp%\au2sb_extras.zip" -C "%temp%\au2sb" 2>&1 >nul
del "%temp%\au2sb_mods.zip" /q 2>&1 >nul
del "%temp%\au2sb_config.zip" /q 2>&1 >nul
del "%temp%\au2sb_resourcepacks.zip" /q 2>&1 >nul
del "%temp%\au2sb_extras.zip" /q 2>&1 >nul
robocopy "%temp%\au2sb\mods" "%minecraftfolder%\mods" /s /purge /r:100 /move /log:"%temp%\au2sb_mods.log" 2>&1 >nul
robocopy "%temp%\au2sb\config" "%minecraftfolder%\config" /s /r:100 /move /log:"%temp%\au2sb_config.log" 2>&1 >nul
robocopy "%temp%\au2sb\resourcepacks" "%minecraftfolder%\resourcepacks" /s /r:100 /move /log:"%temp%\au2sb_resourcepacks.log" 2>&1 >nul
robocopy "%temp%\au2sb" "%minecraftfolder%" /s /r:100 /move /log:"%temp%\au2sb_extras.log" 2>&1 >nul

rmdir "%temp%\au2sb" /s /q 2>&1 >nul

:: Check fabric installation
set "fabric_exists=false"
if exist "%appdata%\.minecraft\versions\fabric-loader-0.15.11-1.20.1" set "fabric_exists=true"

:: If missing, download installer and run
if "%fabric_exists%"=="false" (
	echo.
	echo Fabric appears to not be installed, downloading now
    curl -L https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar --output "%temp%\fabric-installer.jar"
    java -jar %temp%\fabric-installer.jar client -dir %appdata%\.minecraft
	echo.
	echo Fabric installed
)

echo.
echo Modpack installed/updated
echo.
endlocal
pause
