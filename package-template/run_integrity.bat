@echo off
setlocal EnableDelayedExpansion

:: Change to script directory
cd /d "%~dp0"

:: Check if virtual environment exists
if not exist "venv" (
    echo Virtual environment not found
    echo Please run install.bat first
    pause
    exit /b 1
)

:: Activate virtual environment
call venv\Scripts\activate
if errorlevel 1 (
    echo Failed to activate virtual environment
    echo Please run install.bat to repair the installation
    pause
    exit /b 1
)

:: Run the application
python src\integrity_main.py

:: Deactivate virtual environment
call venv\Scripts\deactivate

:: If we get here with an error, show it
if errorlevel 1 (
    echo.
    echo Application exited with an error
    echo Please check the logs in: %USERPROFILE%\IntegrityAssistant\logs
    pause
) 