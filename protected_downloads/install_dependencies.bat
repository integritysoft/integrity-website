@echo off
echo ========== INTEGRITY ASSISTANT - DEPENDENCY INSTALLER ==========
echo.
echo This script will install all required dependencies for Integrity Assistant.
echo.

REM Check if Python is installed
python --version > nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH.
    echo Please install Python 3.8 or higher from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation.
    echo.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

echo Updating pip, setuptools, and wheel...
python -m pip install --upgrade pip setuptools wheel

echo.
echo Installing required dependencies...
python -m pip install requests customtkinter==5.2.0 easyocr==1.7.0 opencv-python==4.8.0.76 numpy==1.24.3

echo.
echo All dependencies should now be installed!
echo.
echo If you encounter any issues, please contact support@integritysoftware.download
echo.
echo Press any key to exit...
pause > nul 