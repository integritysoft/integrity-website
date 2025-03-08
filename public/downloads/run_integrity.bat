@echo off
setlocal enabledelayedexpansion

echo ========== INTEGRITY ASSISTANT LAUNCHER ==========
echo.
echo [INFO] Starting installation process...

REM Set installation directory
set INSTALL_DIR=%USERPROFILE%\IntegrityAssistant
echo [INFO] Installation directory: %INSTALL_DIR%

REM Check for Python and get version
echo [INFO] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found in PATH.
    echo [INFO] Opening Python download page...
    start https://www.python.org/downloads/
    echo Please install Python 3.8-3.10 (recommended) and check "Add Python to PATH"
    echo Then run this script again.
    pause
    exit /b 1
)

REM Get Python version information
for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [INFO] %PYTHON_VERSION%

REM Extract Python version numbers
for /f "tokens=2" %%i in ("%PYTHON_VERSION%") do set PY_VER=%%i
for /f "tokens=1,2 delims=." %%a in ("%PY_VER%") do (
    set PY_MAJOR=%%a
    set PY_MINOR=%%b
)
echo [INFO] Using Python !PY_MAJOR!.!PY_MINOR!

REM Create installation directory if it doesn't exist
if not exist "%INSTALL_DIR%" (
    echo [INFO] Creating installation directory...
    mkdir "%INSTALL_DIR%"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to create installation directory.
        echo [INFO] Try running as administrator or check permissions.
        pause
        exit /b 1
    )
)

REM Copy Python files
echo [INFO] Copying application files...
xcopy /y .\integrity_*.py "%INSTALL_DIR%\" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Failed to copy application files.
    pause
    exit /b 1
)

REM Create config directory
if not exist "%INSTALL_DIR%\config" (
    echo [INFO] Creating configuration directory...
    mkdir "%INSTALL_DIR%\config" >nul 2>&1
)

REM Create desktop shortcut
echo [INFO] Creating desktop shortcut...
echo @echo off > "%USERPROFILE%\Desktop\Integrity Assistant.bat"
echo cd /d "%INSTALL_DIR%" >> "%USERPROFILE%\Desktop\Integrity Assistant.bat"
echo if exist "%INSTALL_DIR%\venv\Scripts\activate.bat" ( >> "%USERPROFILE%\Desktop\Integrity Assistant.bat"
echo   call "%INSTALL_DIR%\venv\Scripts\activate.bat" >> "%USERPROFILE%\Desktop\Integrity Assistant.bat" 
echo   python integrity_main.py >> "%USERPROFILE%\Desktop\Integrity Assistant.bat"
echo   call "%INSTALL_DIR%\venv\Scripts\deactivate.bat" >> "%USERPROFILE%\Desktop\Integrity Assistant.bat"
echo ) else ( >> "%USERPROFILE%\Desktop\Integrity Assistant.bat"
echo   echo Virtual environment not found. Please run run_integrity.bat again. >> "%USERPROFILE%\Desktop\Integrity Assistant.bat"
echo   pause >> "%USERPROFILE%\Desktop\Integrity Assistant.bat"
echo ) >> "%USERPROFILE%\Desktop\Integrity Assistant.bat"

REM Change to installation directory
cd /d "%INSTALL_DIR%"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to change to installation directory.
    pause
    exit /b 1
)

REM Create and activate virtual environment
echo [INFO] Setting up Python virtual environment...
if exist venv (
    echo [INFO] Using existing virtual environment...
) else (
    echo [INFO] Creating new virtual environment...
    python -m venv venv
    if %errorlevel% neq 0 (
        echo [WARNING] Failed to create venv, trying virtualenv...
        pip install virtualenv >nul 2>&1
        python -m virtualenv venv
        if %errorlevel% neq 0 (
            echo [ERROR] Failed to create virtual environment.
            echo [INFO] Please check your Python installation.
            pause
            exit /b 1
        )
    )
)

REM Activate virtual environment
echo [INFO] Activating virtual environment...
call venv\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo [ERROR] Failed to activate virtual environment.
    pause
    exit /b 1
)

REM Upgrade pip and setuptools with error checking
echo [INFO] Upgrading pip and setuptools...
python -m pip install --upgrade pip wheel setuptools >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Failed to upgrade pip/setuptools. Continuing anyway...
)

REM For Python 3.13+, ensure we have latest setuptools
if !PY_MAJOR!.!PY_MINOR! GEQ 3.13 (
    echo [INFO] Python 3.13+ detected, installing latest setuptools...
    pip install setuptools --upgrade >nul 2>&1
)

REM Function to install a package with retries
echo [INFO] Installing dependencies (this may take a while)...

REM Install requests
echo [INFO] Installing requests...
pip install requests
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install requests.
    echo [INFO] Trying with alternative method...
    pip install requests --no-deps
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install requests. Cannot continue.
        call venv\Scripts\deactivate.bat
        pause
        exit /b 1
    )
)

REM Install customtkinter
echo [INFO] Installing customtkinter...
pip install customtkinter==5.2.0
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install customtkinter.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

REM Install NumPy with version-specific handling
echo [INFO] Installing NumPy...
if !PY_MAJOR!.!PY_MINOR! GEQ 3.13 (
    echo [INFO] Using NumPy 1.26.4+ for Python 3.13+...
    pip install numpy==1.26.4 --only-binary=numpy
) else if !PY_MAJOR!.!PY_MINOR! GEQ 3.12 (
    echo [INFO] Using NumPy 1.26.0+ for Python 3.12...
    pip install "numpy>=1.26.0" --only-binary=numpy
) else if !PY_MAJOR!.!PY_MINOR! GEQ 3.11 (
    echo [INFO] Using NumPy 1.25.2 for Python 3.11...
    pip install numpy==1.25.2 --only-binary=numpy
) else (
    echo [INFO] Using NumPy 1.24.3 for Python 3.8-3.10...
    pip install numpy==1.24.3 --only-binary=numpy
)

if %errorlevel% neq 0 (
    echo [ERROR] Failed to install NumPy.
    echo [INFO] Trying alternative approach...
    
    REM For Python 3.13+, use the latest version
    if !PY_MAJOR!.!PY_MINOR! GEQ 3.13 (
        pip install --index-url https://pypi.org/simple/ numpy==1.26.4 --only-binary=numpy
    ) else (
        pip install --index-url https://pypi.org/simple/ "numpy>=1.24.0" --only-binary=numpy
    )
    
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install NumPy. Cannot continue.
        echo [INFO] Please try installing Python 3.10 which has better compatibility.
        call venv\Scripts\deactivate.bat
        pause
        exit /b 1
    )
)

REM Verify NumPy installed correctly
python -c "import numpy; print('NumPy', numpy.__version__)" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] NumPy installed but cannot be imported.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

REM Install OpenCV with proper version selection
echo [INFO] Installing OpenCV...
if !PY_MAJOR!.!PY_MINOR! GEQ 3.12 (
    pip install opencv-python --only-binary=opencv-python
) else (
    pip install opencv-python==4.8.0.76 --only-binary=opencv-python
)

if %errorlevel% neq 0 (
    echo [ERROR] Failed to install OpenCV.
    echo [INFO] Trying alternative version...
    pip install opencv-python --only-binary=opencv-python
    
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install OpenCV. Cannot continue.
        call venv\Scripts\deactivate.bat
        pause
        exit /b 1
    )
)

REM Install EasyOCR with fallback strategies
echo [INFO] Installing EasyOCR (this may take several minutes)...
pip install easyocr==1.7.0
if %errorlevel% neq 0 (
    echo [WARNING] Failed to install EasyOCR with standard method.
    echo [INFO] Trying alternative installation approach...
    
    REM Try alternative installation method
    pip install easyocr --no-deps
    pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
    pip install Pillow scipy Jinja2 scikit-image
    
    echo [WARNING] Some OCR features may not work correctly.
    echo [INFO] Will proceed with core functionality.
)

REM Verify critical packages are installed
echo [INFO] Verifying installation...
python -c "import requests; print('Requests OK')" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Critical package 'requests' is not properly installed.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

python -c "import customtkinter; print('CTk OK')" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Critical package 'customtkinter' is not properly installed.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

python -c "import numpy; print('NumPy OK')" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Critical package 'numpy' is not properly installed.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

python -c "import cv2; print('OpenCV OK')" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Critical package 'opencv-python' is not properly installed.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

REM Create verification file to indicate successful installation
echo %date% %time% > "%INSTALL_DIR%\installation_completed.txt"

echo.
echo [SUCCESS] All dependencies installed successfully!
echo.
echo ==========================================
echo Integrity Assistant is ready to launch!
echo ==========================================
echo.

REM Run the application
echo [INFO] Starting Integrity Assistant...
python integrity_main.py

REM Deactivate the virtual environment when the app closes
call venv\Scripts\deactivate.bat

echo.
echo [INFO] Integrity Assistant has closed.
echo [INFO] Next time, you can use the desktop shortcut.
echo.
pause
endlocal 