@echo off
setlocal EnableDelayedExpansion

echo Integrity Assistant Public Beta 1.0.2 - Installation
echo ================================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this script as Administrator
    echo Right-click install.bat and select "Run as administrator"
    pause
    exit /b 1
)

:: Check Python installation
python --version > nul 2>&1
if %errorLevel% neq 0 (
    echo Python is not installed or not in PATH
    echo Please install Python 3.8 or newer from https://python.org
    echo IMPORTANT: Check "Add Python to PATH" during installation
    start https://www.python.org/downloads/
    pause
    exit /b 1
)

:: Get Python version
for /f "tokens=2" %%I in ('python --version 2^>^&1') do set "PYVER=%%I"
for /f "tokens=1,2 delims=." %%a in ("%PYVER%") do (
    set PY_MAJOR=%%a
    set PY_MINOR=%%b
)

:: Check Python version
if %PY_MAJOR% LSS 3 (
    echo Error: Python 3.8 or newer is required
    echo Current version: %PYVER%
    pause
    exit /b 1
)
if %PY_MAJOR%==3 if %PY_MINOR% LSS 8 (
    echo Error: Python 3.8 or newer is required
    echo Current version: %PYVER%
    pause
    exit /b 1
)

echo Found Python %PYVER%

:: Create virtual environment
echo Creating virtual environment...
if exist venv (
    echo Removing old virtual environment...
    rmdir /s /q venv
)
python -m venv venv
if errorlevel 1 (
    echo Failed to create virtual environment
    pause
    exit /b 1
)

:: Activate virtual environment
call venv\Scripts\activate
if errorlevel 1 (
    echo Failed to activate virtual environment
    pause
    exit /b 1
)

:: Upgrade pip
echo Upgrading pip...
python -m pip install --upgrade pip
if errorlevel 1 (
    echo Failed to upgrade pip
    pause
    exit /b 1
)

:: Install dependencies
echo Installing dependencies...
python -m pip install --no-cache-dir -r requirements.txt
if errorlevel 1 (
    echo Failed to install dependencies
    pause
    exit /b 1
)

:: Create desktop shortcut
echo Creating desktop shortcut...
set SCRIPT_DIR=%~dp0
set SHORTCUT_PATH=%USERPROFILE%\Desktop\Integrity Assistant.lnk
powershell -ExecutionPolicy Bypass -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SHORTCUT_PATH%'); $s.TargetPath = '%SCRIPT_DIR%run_integrity.bat'; $s.WorkingDirectory = '%SCRIPT_DIR%'; $s.Description = 'Integrity Assistant Public Beta 1.0.2'; $s.Save()"

:: Create start menu shortcut
set STARTMENU_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Integrity Assistant.lnk
powershell -ExecutionPolicy Bypass -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%STARTMENU_PATH%'); $s.TargetPath = '%SCRIPT_DIR%run_integrity.bat'; $s.WorkingDirectory = '%SCRIPT_DIR%'; $s.Description = 'Integrity Assistant Public Beta 1.0.2'; $s.Save()"

echo.
echo Installation completed successfully!
echo Desktop and Start Menu shortcuts have been created
echo.
echo Press any key to start Integrity Assistant...
pause > nul

:: Start the application
call run_integrity.bat 