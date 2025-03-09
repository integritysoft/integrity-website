@echo off
echo Starting Integrity Assistant...

:: Enable command output
echo on

:: Check if Python is installed
python --version
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python 3.8 or later
    pause
    exit /b 1
)

:: Show Python path
where python
echo.

:: Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
    if errorlevel 1 (
        echo Failed to create virtual environment
        pause
        exit /b 1
    )
)

:: Activate virtual environment and show status
call venv\Scripts\activate
if errorlevel 1 (
    echo Failed to activate virtual environment
    pause
    exit /b 1
)

:: Show Python version and path in venv
python --version
where python
echo.

:: Install or upgrade dependencies
echo Installing/upgrading dependencies...
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
if errorlevel 1 (
    echo Failed to install dependencies
    pause
    exit /b 1
)

:: List installed packages
python -m pip list
echo.

:: Start the application with full output
echo Starting application...
python start.py

:: Always pause at the end
echo.
echo Press any key to exit...
pause > nul 