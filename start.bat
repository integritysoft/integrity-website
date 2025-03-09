@echo off
echo Starting Integrity Assistant...

:: Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python 3.8 or later
    pause
    exit /b 1
)

:: Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
    call venv\Scripts\activate
    python -m pip install -r requirements.txt
) else (
    call venv\Scripts\activate
)

:: Start the application
python start.py

:: If there was an error, don't close immediately
if errorlevel 1 (
    echo.
    echo Application exited with an error
    pause
) 