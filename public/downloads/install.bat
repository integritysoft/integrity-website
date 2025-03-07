@echo off
echo ===================================================
echo    Integrity Assistant 0.1.2 - Installer
echo ===================================================
echo.

REM Set installation directory
set INSTALL_DIR=%USERPROFILE%\IntegrityAssistant

echo Installing Integrity Assistant to %INSTALL_DIR%...
echo.

REM Create installation directory if it doesn't exist
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Copy files to installation directory
echo Extracting files...
powershell -Command "Expand-Archive -Path 'integrity-assistant-windows.zip' -DestinationPath '%INSTALL_DIR%' -Force"

REM Create desktop shortcut
echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Integrity Assistant.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%\IntegrityAssistant.exe'; $Shortcut.Save()"

REM Registration
echo.
echo Setting up your Integrity Assistant account...
echo.
set /p username=Enter your username: 
set /p email=Enter your email: 

echo.
echo Registering user: %username% with email: %email%
echo Configuration complete!
echo.

REM Start application
echo.
echo Installation complete!
echo.
echo Would you like to start Integrity Assistant now?
set /p start=Type 'yes' to start or any other key to exit: 

if /i "%start%"=="yes" (
    echo Starting Integrity Assistant...
    start "" "%INSTALL_DIR%\IntegrityAssistant.exe" --new-user --username "%username%" --email "%email%"
) else (
    echo You can start Integrity Assistant from your desktop shortcut.
)

echo.
echo Thank you for installing Integrity Assistant!
echo.
pause 