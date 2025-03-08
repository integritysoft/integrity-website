@echo off
echo ========== INTEGRITY ASSISTANT LAUNCHER ==========
echo.
echo Starting setup process...

REM Check if Python is installed
python --version > nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH.
    echo.
    echo We'll open the Python download page for you.
    echo Please install Python 3.8 or higher and be sure to check "Add Python to PATH" during installation.
    echo After installation, please run this launcher again.
    echo.
    start https://www.python.org/downloads/
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

REM Set up a Python virtual environment in the same folder
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
    if %errorlevel% neq 0 (
        echo Failed to create virtual environment.
        echo Installing venv module...
        python -m pip install virtualenv
        python -m virtualenv venv
        
        if %errorlevel% neq 0 (
            echo ERROR: Failed to create virtual environment.
            echo Please make sure you have virtualenv installed or try running as administrator.
            echo Press any key to exit...
            pause > nul
            exit /b 1
        )
    )
)

REM Activate the virtual environment
call venv\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo ERROR: Failed to activate virtual environment.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

REM Upgrade pip and setuptools
echo Upgrading pip and setuptools...
python -m pip install --upgrade pip setuptools wheel --no-warn-script-location
if %errorlevel% neq 0 (
    echo WARNING: Failed to upgrade pip. Continuing anyway...
)

REM Install required packages with better error handling
echo Installing dependencies (this may take a few minutes on first run)...

REM Install packages one by one for better error handling and using --only-binary for problematic packages
echo Installing requests...
pip install requests --no-warn-script-location
if %errorlevel% neq 0 (
    echo ERROR: Failed to install requests. 
    echo Please check your internet connection and try again.
    call venv\Scripts\deactivate.bat
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

echo Installing customtkinter...
pip install customtkinter==5.2.0 --no-warn-script-location
if %errorlevel% neq 0 (
    echo ERROR: Failed to install customtkinter.
    call venv\Scripts\deactivate.bat
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

echo Installing numpy...
pip install numpy==1.24.3 --only-binary=numpy --no-warn-script-location
if %errorlevel% neq 0 (
    echo ERROR: Failed to install numpy.
    call venv\Scripts\deactivate.bat
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

echo Installing opencv-python...
pip install opencv-python==4.8.0.76 --only-binary=opencv-python --no-warn-script-location
if %errorlevel% neq 0 (
    echo ERROR: Failed to install opencv-python.
    call venv\Scripts\deactivate.bat
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

echo Installing easyocr...
pip install easyocr==1.7.0 --no-warn-script-location
if %errorlevel% neq 0 (
    echo ERROR: Failed to install easyocr.
    call venv\Scripts\deactivate.bat
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

REM Run the application
echo.
echo ==========================================
echo Integrity Assistant is ready to launch!
echo.
echo Starting Integrity Assistant...
echo ==========================================
python src\integrity_main.py

REM Deactivate the virtual environment when the app closes
call venv\Scripts\deactivate.bat

echo.
echo Integrity Assistant has closed.
echo Next time you run this launcher, startup will be much faster.
echo.
echo Press any key to exit...
pause > nul 