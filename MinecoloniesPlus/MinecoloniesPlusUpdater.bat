@echo off
setlocal
:: Prompt the user for the Minecraft folder path
echo This installer/updater script will automatically download the required mods and config files. 
echo You need to install forge-1.20.1-47.2.21 manually.
echo Please enter the folder path if you are using a custom Minecraft folder location,
set /p "minecraftfolder=or press Enter if you are using the default .minecraft folder: "
:: If the user enters nothing, set minecraftfolder to %appdata%\.minecraft
if "%minecraftfolder%"=="" set "minecraftfolder=%appdata%\.minecraft" >nul
echo.

:: Fetch the URL for the download
for /f "delims=" %%i in ('curl -s https://raw.githubusercontent.com/nx5314/repo_nx/main/minecoloniesplusupdate.txt') do set "modpackurl=%%i"

echo Downloading mods
curl -L "%modpackurl%" --output "%temp%\minecoloniesplusmodpack.zip"
if exist "%temp%\minecoloniesplusmodpack" rmdir "%temp%\minecoloniesplusmodpack" /s /q 2>&1 >nul
if not exist "%temp%\minecoloniesplusmodpack" mkdir "%temp%\minecoloniesplusmodpack" 2>&1 >nul
tar -xf "%temp%\minecoloniesplusmodpack.zip" -C "%temp%\minecoloniesplusmodpack" 2>&1 >nul
robocopy "%temp%\minecoloniesplusmodpack\mods_client\mods" "%minecraftfolder%\mods" /s /purge /r:100 /move /log:"%temp%\minecoloniesplusmodpack\mods.log" 2>&1 >nul
robocopy "%temp%\minecoloniesplusmodpack\mods_client\config" "%minecraftfolder%\config" /s /r:100 /move /log:"%temp%\minecoloniesplusmodpack\config.log" 2>&1 >nul
rmdir "%temp%\minecoloniesplusmodpack\mods_client\mods" /s /q 2>&1 >nul
rmdir "%temp%\minecoloniesplusmodpack\mods_client\config" /s /q 2>&1 >nul
del "%temp%\minecoloniesplusmodpack.zip" /q 2>&1 >nul
echo.
echo Modpack updated
echo.
endlocal
pause
