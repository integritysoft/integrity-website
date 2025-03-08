@echo off
setlocal enabledelayedexpansion

echo ========== INTEGRITY ASSISTANT LAUNCHER ==========
echo.
echo [INFO] Starting installation process...
echo [INFO] Current directory: %CD%

:: Ensure we have admin rights for better reliability
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo [WARNING] This script is not running with administrative privileges.
    echo [WARNING] Some operations might fail. Consider running as administrator.
    echo.
)

:: Set installation directory
set INSTALL_DIR=%USERPROFILE%\IntegrityAssistant
echo [INFO] Installation directory: %INSTALL_DIR%

:: Check for Python and get version
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

:: Get Python version information with explicit redirection
echo [INFO] Getting Python version...
python --version > "%TEMP%\pyversion.txt" 2>&1
set /p PYTHON_VERSION=<"%TEMP%\pyversion.txt"
del "%TEMP%\pyversion.txt"
echo [INFO] %PYTHON_VERSION%

:: Extract Python version numbers more carefully
for /f "tokens=2" %%i in ("%PYTHON_VERSION%") do set PY_VER=%%i
for /f "tokens=1,2 delims=." %%a in ("%PY_VER%") do (
    set PY_MAJOR=%%a
    set PY_MINOR=%%b
)
echo [INFO] Detected Python !PY_MAJOR!.!PY_MINOR!

:: Create installation directory if it doesn't exist
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

:: Copy Python files with explicit error checking
echo [INFO] Copying application files...
for %%f in (integrity_*.py) do (
    echo [INFO] Copying %%f...
    copy /Y "%%f" "%INSTALL_DIR%\" >nul
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to copy %%f to %INSTALL_DIR%
        pause
        exit /b 1
    )
)
echo [INFO] All files copied successfully.

:: Create config directory
if not exist "%INSTALL_DIR%\config" (
    echo [INFO] Creating configuration directory...
    mkdir "%INSTALL_DIR%\config" >nul 2>&1
)

:: Create desktop shortcut
echo [INFO] Creating desktop shortcut...
(
echo @echo off
echo cd /d "%INSTALL_DIR%"
echo if exist "%INSTALL_DIR%\venv\Scripts\activate.bat" (
echo   call "%INSTALL_DIR%\venv\Scripts\activate.bat" 
echo   python integrity_main.py
echo   call "%INSTALL_DIR%\venv\Scripts\deactivate.bat"
echo ) else (
echo   echo Virtual environment not found. Please run run_integrity.bat again.
echo   pause
echo )
) > "%USERPROFILE%\Desktop\Integrity Assistant.bat"

echo [INFO] Desktop shortcut created.

:: Change to installation directory
echo [INFO] Changing to installation directory...
cd /d "%INSTALL_DIR%"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to change to installation directory.
    pause
    exit /b 1
)
echo [INFO] Current directory: %CD%

:: Remove any existing virtual environment if it's corrupt
if exist venv (
    echo [INFO] Checking if existing virtual environment is valid...
    if not exist venv\Scripts\activate.bat (
        echo [WARNING] Existing virtual environment appears corrupt. Removing...
        rmdir /S /Q venv
        echo [INFO] Removed corrupted environment.
    ) else (
        echo [INFO] Existing virtual environment looks valid.
    )
)

:: Create and activate virtual environment
echo [INFO] Setting up Python virtual environment...
if exist venv (
    echo [INFO] Using existing virtual environment...
) else (
    echo [INFO] Creating new virtual environment...
    python -m venv venv
    if %errorlevel% neq 0 (
        echo [WARNING] Failed to create venv with standard method. Trying alternative...
        python -m pip install virtualenv
        python -m virtualenv venv
        if %errorlevel% neq 0 (
            echo [ERROR] All attempts to create virtual environment failed.
            echo [INFO] Please check your Python installation.
            pause
            exit /b 1
        )
    )
)

:: Activate virtual environment with explicit verification
echo [INFO] Activating virtual environment...
call venv\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo [ERROR] Failed to activate virtual environment.
    pause
    exit /b 1
)

:: Verify activation
echo [INFO] Verifying virtual environment activation...
python -c "import sys; print('Virtual environment path:', sys.prefix)" > "%TEMP%\venv_check.txt"
if %errorlevel% neq 0 (
    echo [ERROR] Virtual environment seems to be activated but Python is not working.
    pause
    exit /b 1
)
set /p VENV_PATH=<"%TEMP%\venv_check.txt"
del "%TEMP%\venv_check.txt"
echo [INFO] %VENV_PATH%

:: Check if the path contains the expected virtual environment path
echo !VENV_PATH! | findstr /C:"%INSTALL_DIR%\venv" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Virtual environment does not seem to be properly activated.
    pause
    exit /b 1
)

:: Critical step: update setuptools completely before anything else
echo [INFO] Installing latest setuptools, pip and wheel...
python -m pip install --upgrade pip wheel setuptools
if %errorlevel% neq 0 (
    echo [WARNING] Failed to upgrade pip/setuptools. Trying direct method...
    python -m pip install pip==23.1.2 setuptools==67.8.0 wheel==0.40.0 --force-reinstall
    if %errorlevel% neq 0 (
        echo [ERROR] Critical error: Failed to install basic tools.
        echo [INFO] Please try with a different Python installation.
        call venv\Scripts\deactivate.bat
        pause
        exit /b 1
    )
)

:: For Python 3.13+, ensure setuptools is properly configured
if !PY_MAJOR!.!PY_MINOR! GEQ 3.12 (
    echo [INFO] Python 3.12+ detected, ensuring setuptools compatibility...
    python -m pip install "setuptools>=69.0.2" --force-reinstall
    if %errorlevel% neq 0 (
        echo [WARNING] Setuptools upgrade failed, installation might fail later.
    )
)

:: Install pyproject dependencies that might be needed to build packages
echo [INFO] Installing build dependencies...
python -m pip install "build>=1.0.3" "wheel>=0.42.0" "setuptools_scm>=8.0.0" "packaging>=23.0"
if %errorlevel% neq 0 (
    echo [WARNING] Failed to install build dependencies. Will attempt to continue...
)

:: Install packages one by one with repeated verification
echo [INFO] Installing dependencies (this may take a while)...

:: Install requests with verification
echo [INFO] Installing requests...
python -m pip install requests
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install requests.
    echo [INFO] Trying alternative source...
    python -m pip install requests --index-url https://pypi.org/simple
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install requests. Cannot continue.
        call venv\Scripts\deactivate.bat
        pause
        exit /b 1
    )
)
echo [INFO] Verifying requests installation...
python -c "import requests; print('Requests', requests.__version__)" > "%TEMP%\pkg_check.txt"
if %errorlevel% neq 0 (
    echo [ERROR] Requests installed but cannot be imported.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)
set /p PKG_VERSION=<"%TEMP%\pkg_check.txt"
del "%TEMP%\pkg_check.txt"
echo [SUCCESS] %PKG_VERSION% installed successfully.

:: Install customtkinter with verification
echo [INFO] Installing customtkinter...
python -m pip install customtkinter==5.2.0
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install customtkinter.
    echo [INFO] Trying without version constraint...
    python -m pip install customtkinter
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install customtkinter. Cannot continue.
        call venv\Scripts\deactivate.bat
        pause
        exit /b 1
    )
)
echo [INFO] Verifying customtkinter installation...
python -c "import customtkinter; print('CustomTkinter', customtkinter.__version__)" > "%TEMP%\pkg_check.txt"
if %errorlevel% neq 0 (
    echo [ERROR] CustomTkinter installed but cannot be imported.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)
set /p PKG_VERSION=<"%TEMP%\pkg_check.txt"
del "%TEMP%\pkg_check.txt"
echo [SUCCESS] %PKG_VERSION% installed successfully.

:: Install NumPy with version-specific handling and verification
echo [INFO] Installing NumPy...
set NUMPY_INSTALLED=0

:: Try specific version for this Python version
if !PY_MAJOR!.!PY_MINOR! GEQ 3.13 (
    echo [INFO] Using NumPy 1.26.4 for Python 3.13+...
    python -m pip install numpy==1.26.4 --only-binary=numpy
) else if !PY_MAJOR!.!PY_MINOR! GEQ 3.12 (
    echo [INFO] Using NumPy 1.26.0 for Python 3.12...
    python -m pip install numpy==1.26.0 --only-binary=numpy
) else if !PY_MAJOR!.!PY_MINOR! GEQ 3.11 (
    echo [INFO] Using NumPy 1.25.2 for Python 3.11...
    python -m pip install numpy==1.25.2 --only-binary=numpy
) else (
    echo [INFO] Using NumPy 1.24.3 for Python 3.8-3.10...
    python -m pip install numpy==1.24.3 --only-binary=numpy
)

if %errorlevel% equ 0 (
    set NUMPY_INSTALLED=1
) else (
    echo [WARNING] First NumPy installation attempt failed.
    echo [INFO] Trying alternative approach (1/3)...
    
    :: Try with a different source
    python -m pip install numpy --only-binary=numpy --index-url https://pypi.org/simple
    if %errorlevel% equ 0 (
        set NUMPY_INSTALLED=1
    ) else (
        echo [INFO] Trying alternative approach (2/3)...
        
        :: Try with any version
        python -m pip install numpy --only-binary=numpy
        if %errorlevel% equ 0 (
            set NUMPY_INSTALLED=1
        ) else (
            echo [INFO] Trying final alternative approach (3/3)...
            
            :: Try a known-good version with specific flags
            python -m pip install numpy==1.24.3 --only-binary=numpy --no-cache-dir --use-pep517
            if %errorlevel% equ 0 (
                set NUMPY_INSTALLED=1
            )
        )
    )
)

if !NUMPY_INSTALLED! neq 1 (
    echo [ERROR] All attempts to install NumPy failed.
    echo [INFO] Please try with Python 3.10 which has better compatibility.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

echo [INFO] Verifying NumPy installation...
python -c "import numpy; print('NumPy', numpy.__version__)" > "%TEMP%\pkg_check.txt"
if %errorlevel% neq 0 (
    echo [ERROR] NumPy installed but cannot be imported.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)
set /p PKG_VERSION=<"%TEMP%\pkg_check.txt"
del "%TEMP%\pkg_check.txt"
echo [SUCCESS] %PKG_VERSION% installed successfully.

:: Install OpenCV with verification
echo [INFO] Installing OpenCV...
set OPENCV_INSTALLED=0

if !PY_MAJOR!.!PY_MINOR! GEQ 3.12 (
    python -m pip install opencv-python --only-binary=opencv-python
) else (
    python -m pip install opencv-python==4.8.0.76 --only-binary=opencv-python
)

if %errorlevel% equ 0 (
    set OPENCV_INSTALLED=1
) else (
    echo [WARNING] First OpenCV installation attempt failed.
    echo [INFO] Trying alternative approach...
    
    python -m pip install opencv-python --only-binary=opencv-python --index-url https://pypi.org/simple
    if %errorlevel% equ 0 (
        set OPENCV_INSTALLED=1
    )
)

if !OPENCV_INSTALLED! neq 1 (
    echo [ERROR] Failed to install OpenCV.
    echo [INFO] This is required. Please try with a different Python version.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

echo [INFO] Verifying OpenCV installation...
python -c "import cv2; print('OpenCV', cv2.__version__)" > "%TEMP%\pkg_check.txt"
if %errorlevel% neq 0 (
    echo [ERROR] OpenCV installed but cannot be imported.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)
set /p PKG_VERSION=<"%TEMP%\pkg_check.txt"
del "%TEMP%\pkg_check.txt"
echo [SUCCESS] %PKG_VERSION% installed successfully.

:: Install EasyOCR with fallback strategies
echo [INFO] Installing EasyOCR (this may take several minutes)...
set EASYOCR_INSTALLED=0

python -m pip install easyocr==1.7.0
if %errorlevel% equ 0 (
    set EASYOCR_INSTALLED=1
) else (
    echo [WARNING] Standard EasyOCR installation failed.
    echo [INFO] Trying alternative installation approach...
    
    python -m pip install easyocr --no-deps
    python -m pip install torch==2.0.1 torchvision==0.15.2 --index-url https://download.pytorch.org/whl/cpu
    python -m pip install Pillow scipy Jinja2 scikit-image
    
    :: Check if core components are installed, even if the full package failed
    python -c "import torch, torchvision" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [INFO] Core OCR dependencies installed successfully.
        set EASYOCR_INSTALLED=1
    )
)

if !EASYOCR_INSTALLED! neq 1 (
    echo [WARNING] Could not install EasyOCR or its core dependencies.
    echo [INFO] The application will run with limited OCR functionality.
) else (
    echo [INFO] Verifying EasyOCR core installation...
    python -c "import torch; print('PyTorch', torch.__version__)" > "%TEMP%\pkg_check.txt"
    if %errorlevel% equ 0 (
        set /p PKG_VERSION=<"%TEMP%\pkg_check.txt"
        del "%TEMP%\pkg_check.txt"
        echo [SUCCESS] %PKG_VERSION% installed successfully.
    )
)

:: Create verification file to indicate successful installation
echo Installation completed on %date% %time% > "%INSTALL_DIR%\installation_completed.txt"
echo Python version: %PYTHON_VERSION% >> "%INSTALL_DIR%\installation_completed.txt"

:: Do a final import test of all critical dependencies
echo [INFO] Performing final verification of all critical packages...
(
echo import sys
echo import requests
echo import customtkinter
echo import numpy
echo import cv2
echo print("All critical packages imported successfully!")
) > "%TEMP%\verify_imports.py"

python "%TEMP%\verify_imports.py"
if %errorlevel% neq 0 (
    echo [ERROR] Final verification failed. Some packages may not be installed correctly.
    del "%TEMP%\verify_imports.py"
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)
del "%TEMP%\verify_imports.py"

echo.
echo [SUCCESS] All dependencies installed and verified successfully!
echo.
echo ==========================================
echo Integrity Assistant is ready to launch!
echo ==========================================
echo.

:: Run the application
echo [INFO] Starting Integrity Assistant...
python integrity_main.py

:: Deactivate the virtual environment when the app closes
call venv\Scripts\deactivate.bat

echo.
echo [INFO] Integrity Assistant has closed.
echo [INFO] Next time, you can use the desktop shortcut.
echo.
pause
endlocal 