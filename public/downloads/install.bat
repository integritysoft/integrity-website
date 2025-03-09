@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo Integrity Assistant Installer
echo Version: 1.0.2
echo ==========================================
echo.

:: Set installation directory
set "INSTALL_DIR=%~dp0"
cd /d "%INSTALL_DIR%"

:: Check Python installation
echo [INFO] Checking Python installation...
python --version > nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python 3.8 or newer from https://python.org/downloads
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

:: Get Python version
for /f "tokens=2 delims=." %%I in ('python -c "import sys; print(sys.version.split()[0])"') do (
    set PY_MAJOR=%%I
)
for /f "tokens=2 delims=." %%I in ('python -c "import sys; print(sys.version.split()[0])"') do (
    set PY_MINOR=%%I
)
for /f "tokens=3 delims=." %%I in ('python -c "import sys; print(sys.version.split()[0])"') do (
    set PY_PATCH=%%I
)

:: Check Python version
if !PY_MAJOR! lss 3 (
    echo [ERROR] Python 3.8 or newer is required
    echo Current version: !PY_MAJOR!.!PY_MINOR!.!PY_PATCH!
    pause
    exit /b 1
)
if !PY_MAJOR! equ 3 if !PY_MINOR! lss 8 (
    echo [ERROR] Python 3.8 or newer is required
    echo Current version: !PY_MAJOR!.!PY_MINOR!.!PY_PATCH!
    pause
    exit /b 1
)

:: Create and activate virtual environment
echo [INFO] Creating virtual environment...
python -m venv venv
call venv\Scripts\activate.bat

:: Upgrade pip
python -m pip install --upgrade pip

:: Special handling for Python 3.13+
if !PY_MAJOR!.!PY_MINOR! GEQ 3.13 (
    echo [INFO] Setting up Python 3.13+ compatibility...
    python -m pip install --no-cache-dir wheel==0.42.0
    python -m pip install --no-cache-dir setuptools==69.2.0 --force-reinstall
)

:: Install core dependencies
echo [INFO] Installing core dependencies...
python -m pip install --no-cache-dir -r src/requirements.txt

:: Verify critical packages
echo [INFO] Verifying critical packages...
python -c "from verify_helpers import check_imports; failed = check_imports(['requests', 'customtkinter', 'numpy', 'cv2', 'PIL', 'mss']); exit(1 if failed else 0)"
if %errorlevel% neq 0 (
    echo [ERROR] Critical package verification failed
    echo [INFO] Attempting to fix installation...
    
    :: Try reinstalling problematic packages
    python -m pip install --no-cache-dir --force-reinstall Pillow==10.2.0 mss==9.0.1
    
    :: Verify again
    python -c "from verify_helpers import check_imports; failed = check_imports(['requests', 'customtkinter', 'numpy', 'cv2', 'PIL', 'mss']); exit(1 if failed else 0)"
    if %errorlevel% neq 0 (
        echo [ERROR] Could not fix critical package installation
        pause
        exit /b 1
    )
)

:: Try to install EasyOCR (optional)
echo [INFO] Installing EasyOCR (optional)...
python -m pip install --no-cache-dir easyocr==1.7.1
if %errorlevel% neq 0 (
    echo [WARNING] EasyOCR installation failed. The application will run with limited OCR functionality.
    echo [INFO] This is not a critical error, continuing...
)

:: Create desktop shortcut
echo [INFO] Creating desktop shortcut...
(
echo @echo off
echo cd /d "%INSTALL_DIR%"
echo call venv\Scripts\activate.bat
echo python src\integrity_main.py
echo if errorlevel 1 pause
echo call venv\Scripts\deactivate.bat
) > "%USERPROFILE%\Desktop\Integrity Assistant.bat"

echo.
echo [SUCCESS] Installation completed successfully!
echo.
echo ==========================================
echo Integrity Assistant is ready to launch!
echo ==========================================
echo.

:: Run the application
echo [INFO] Starting Integrity Assistant...
python src\integrity_main.py

:: Deactivate virtual environment
call venv\Scripts\deactivate.bat

echo.
echo [INFO] Integrity Assistant has closed.
echo [INFO] Next time, you can use the desktop shortcut.
echo.
pause
endlocal 