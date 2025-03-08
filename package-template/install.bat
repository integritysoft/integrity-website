@echo off
setlocal enabledelayedexpansion

echo ========== INTEGRITY ASSISTANT INSTALLER ==========
echo.

:: Set installation directory
set INSTALL_DIR=%USERPROFILE%\IntegrityAssistant
echo [INFO] Installing to: %INSTALL_DIR%

:: Check for Python
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found. Opening download page...
    start https://www.python.org/downloads/
    echo Please install Python and check "Add Python to PATH"
    pause
    exit /b 1
)

:: Get Python version
for /f "tokens=*" %%i in ('python -c "import sys; print(sys.version.split()[0])"') do set PY_VER=%%i
echo [INFO] Found Python %PY_VER%

:: Parse version components
for /f "tokens=1,2,3 delims=." %%a in ("%PY_VER%") do (
    set PY_MAJOR=%%a
    set PY_MINOR=%%b
    set PY_PATCH=%%c
)

:: Create installation directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Copy files
echo [INFO] Copying files...
xcopy /Y /Q "src\*" "%INSTALL_DIR%\" >nul

:: Create virtual environment
echo [INFO] Setting up Python environment...
cd /d "%INSTALL_DIR%"
python -m venv venv
call venv\Scripts\activate.bat

:: Critical setup for Python 3.13+
if !PY_MAJOR!.!PY_MINOR! GEQ 3.13 (
    echo [INFO] Setting up Python 3.13+ compatibility...
    python -m pip install --upgrade pip
    python -m pip install --no-cache-dir wheel==0.42.0
    python -m pip install --no-cache-dir setuptools==69.2.0 --force-reinstall
    
    :: Verify setuptools
    python -c "import setuptools" >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to configure setuptools. Installation cannot continue.
        call venv\Scripts\deactivate.bat
        pause
        exit /b 1
    )
) else (
    python -m pip install --upgrade pip setuptools wheel
)

:: Install packages one by one with verification
echo [INFO] Installing dependencies...

:: Install requests
echo [INFO] Installing requests...
python -m pip install --no-cache-dir requests==2.31.0
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install requests. Installation cannot continue.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: Verify requests
python -c "import requests" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Failed to verify requests installation.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: Install customtkinter
echo [INFO] Installing customtkinter...
python -m pip install --no-cache-dir customtkinter==5.2.0
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install customtkinter.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: Verify customtkinter
python -c "import customtkinter" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Failed to verify customtkinter installation.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: Install numpy with version based on Python version
echo [INFO] Installing NumPy...
if !PY_MAJOR!.!PY_MINOR! GEQ 3.13 (
    python -m pip install --no-cache-dir --only-binary=numpy "numpy>=1.26.0"
) else (
    python -m pip install --no-cache-dir --only-binary=numpy numpy==1.24.3
)
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install NumPy.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: Verify numpy
python -c "import numpy" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Failed to verify NumPy installation.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: Install opencv-python
echo [INFO] Installing OpenCV...
python -m pip install --no-cache-dir --only-binary=opencv-python opencv-python==4.8.0.76
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install OpenCV.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: Verify opencv
python -c "import cv2" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Failed to verify OpenCV installation.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: Install python-supabase
echo [INFO] Installing Supabase client...
python -m pip install --no-cache-dir python-supabase==2.0.0
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install Supabase client.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: Verify all critical imports
echo [INFO] Verifying all dependencies...
python -c "import requests, customtkinter, numpy, cv2; from supabase import create_client" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Final verification failed. Please try reinstalling.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: Create desktop shortcut
echo [INFO] Creating desktop shortcut...
(
echo @echo off
echo cd /d "%INSTALL_DIR%"
echo call venv\Scripts\activate.bat
echo python integrity_main.py
echo call venv\Scripts\deactivate.bat
) > "%USERPROFILE%\Desktop\Integrity Assistant.bat"

echo.
echo [SUCCESS] Installation complete!
echo A desktop shortcut has been created.
echo.
pause 