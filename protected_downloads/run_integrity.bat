@echo off
setlocal enabledelayedexpansion

echo ========== INTEGRITY ASSISTANT INSTALLER ==========
echo.
echo [INFO] Starting installation process...
echo [INFO] Current directory: %CD%

:: Set installation directory
set INSTALL_DIR=%USERPROFILE%\IntegrityAssistant
echo [INFO] Installation directory: %INSTALL_DIR%

:: Ensure we have admin rights for better reliability
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo [WARNING] This script is not running with administrative privileges.
    echo [WARNING] Some operations might fail. Consider running as administrator.
    echo.
)

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
echo [INFO] Checking Python version...
for /f "tokens=*" %%i in ('python -c "import sys; print(sys.version.split()[0])"') do set PY_VER=%%i
echo [INFO] Found Python %PY_VER%

:: Parse version components
for /f "tokens=1,2,3 delims=." %%a in ("%PY_VER%") do (
    set PY_MAJOR=%%a
    set PY_MINOR=%%b
    set PY_PATCH=%%c
)
echo [INFO] Python version breakdown: !PY_MAJOR!.!PY_MINOR!.!PY_PATCH!

:: Check for baseline Python version compatibility
if !PY_MAJOR! LSS 3 (
    echo [ERROR] Python 3.x is required, but Python !PY_MAJOR!.!PY_MINOR! was found.
    echo [INFO] Please install Python 3.8 or newer.
    pause
    exit /b 1
)

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

:: Copy files
echo [INFO] Copying program files...
for %%f in (integrity_*.py) do (
    echo %%f
    copy /Y "%%f" "%INSTALL_DIR%\" >nul
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
echo call venv\Scripts\activate.bat
echo python integrity_main.py
echo call venv\Scripts\deactivate.bat
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
echo [INFO] Creating virtual environment...
if exist venv (
    echo [INFO] Using existing virtual environment...
) else (
    echo [INFO] Creating new virtual environment...
    
    :: Set environment variables to avoid compilation issues
    set PYTHONNOUSERSITE=1
    set PIP_NO_BUILD_ISOLATION=0
    set PIP_USE_PEP517=1
    
    python -m venv venv
    if %errorlevel% neq 0 (
        echo [WARNING] Failed to create venv with standard method. Trying alternative...
        python -m pip install --user virtualenv
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

:: Define helper functions via temporary file
echo [INFO] Setting up verification helpers...
(
echo import sys, subprocess, importlib
echo 
echo def check_imports(packages):
echo     """Check if packages can be imported, return list of failed packages"""
echo     failed = []
echo     for pkg in packages:
echo         try:
echo             importlib.import_module(pkg)
echo             print(f"  - {pkg}: OK")
echo         except ImportError:
echo             failed.append(pkg)
echo             print(f"  - {pkg}: FAILED")
echo     return failed
echo 
echo def verify_package(package_name, import_name=None):
echo     """Verify a package is properly installed"""
echo     if import_name is None:
echo         import_name = package_name
echo     try:
echo         module = importlib.import_module(import_name)
echo         version = getattr(module, '__version__', 'unknown')
echo         print(f"{package_name} {version}: INSTALLED SUCCESSFULLY")
echo         return True
echo     except ImportError:
echo         print(f"{package_name}: INSTALLATION VERIFICATION FAILED")
echo         return False
) > "%TEMP%\verify_helpers.py"

:: Verify activation using the helper script
echo [INFO] Verifying virtual environment activation...
python -c "import sys; print('Virtual environment active at:', sys.prefix)"

:: CRITICAL SECTION: Properly set up pip and setuptools first
echo [INFO] Installing critical build dependencies...

:: For Python 3.13+ we need to be very careful with setuptools
if !PY_MAJOR!.!PY_MINOR! GEQ 3.13 (
    echo [INFO] Detected Python 3.13+, applying special compatibility fixes...
    
    :: Install core build tools first
    python -m pip install --no-cache-dir wheel==0.42.0
    if %errorlevel% neq 0 exit /b 1
    
    python -m pip install --no-cache-dir setuptools==69.2.0 --force-reinstall
    if %errorlevel% neq 0 exit /b 1
    
    :: Verify setuptools
    python -c "import setuptools" >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to configure setuptools
        exit /b 1
    )
) else (
    :: For older Python versions, standard method works fine
    python -m pip install --upgrade pip setuptools wheel
)

:: Verify working status of pip
python -m pip --version
if %errorlevel% neq 0 (
    echo [ERROR] pip is not functioning properly in the virtual environment.
    echo [INFO] This critical tool is required. Please try with a different Python version.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: Add additional build dependencies
echo [INFO] Installing extended build dependencies...
python -m pip install "build>=1.0.3" "cython>=3.0.0" --no-warn-script-location

:: Set environment variables to prevent build isolation issues
set PIP_NO_BUILD_ISOLATION=0
set PIP_NO_DEPENDENCIES=0
set PIP_DISABLE_PIP_VERSION_CHECK=1

:: ==== SPECIALIZED PACKAGE INSTALLATION ====
:: Each package installed and verified individually

echo [INFO] Installing essential packages one by one...

:: 1. Install requests (HTTP client) with verification
echo [INFO] Installing requests...
python -m pip install --no-cache-dir requests==2.31.0
if %errorlevel% neq 0 (
    echo [WARNING] First attempt failed. Trying alternative approach...
    python -m pip install requests --index-url https://pypi.org/simple/
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install requests. This is a critical dependency.
        call venv\Scripts\deactivate.bat
        pause
        exit /b 1
    )
)

:: Verify requests installation using helper
python -c "import requests; print(f'Requests {requests.__version__} installed successfully')"
if %errorlevel% neq 0 (
    echo [ERROR] requests package installed but cannot be imported.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: 2. Install customtkinter (UI framework) with verification
echo [INFO] Installing customtkinter...
python -m pip install --no-cache-dir customtkinter==5.2.0
if %errorlevel% neq 0 (
    echo [WARNING] Specific version failed. Trying without version constraint...
    python -m pip install customtkinter
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install customtkinter. This is a required UI package.
        call venv\Scripts\deactivate.bat
        pause
        exit /b 1
    )
)

:: Verify customtkinter installation
python -c "import customtkinter; print(f'CustomTkinter {customtkinter.__version__} installed successfully')"
if %errorlevel% neq 0 (
    echo [ERROR] customtkinter package installed but cannot be imported.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: 3. Install NumPy with special handling for Python version
echo [INFO] Installing NumPy (mathematical library)...

:: Set NumPy version based on Python version
if !PY_MAJOR!.!PY_MINOR! GEQ 3.13 (
    set NUMPY_VERSION=1.26.4
) else if !PY_MAJOR!.!PY_MINOR! GEQ 3.12 (
    set NUMPY_VERSION=1.26.0
) else (
    set NUMPY_VERSION=1.24.3
)

echo [INFO] Selected NumPy version: !NUMPY_VERSION! for Python !PY_MAJOR!.!PY_MINOR!

:: Try multiple approaches to install NumPy
set NUMPY_INSTALLED=0

:: First attempt: Using the selected version with binary-only
python -m pip install --no-cache-dir --only-binary=numpy "numpy>=1.26.0"
if %errorlevel% equ 0 set NUMPY_INSTALLED=1

:: If first attempt failed, try alternative approaches
if !NUMPY_INSTALLED! neq 1 (
    echo [WARNING] First NumPy installation attempt failed (error code: %errorlevel%)
    echo [INFO] Trying alternative approach (1/3)...
    
    :: Try current binary version without specific version
    python -m pip install --no-cache-dir numpy --only-binary=numpy
    if %errorlevel% equ 0 (
        set NUMPY_INSTALLED=1
    ) else (
        echo [INFO] Trying alternative approach (2/3)...
        
        :: Try with a different source
        python -m pip install --no-cache-dir numpy --only-binary=numpy --index-url https://pypi.org/simple/
        if %errorlevel% equ 0 (
            set NUMPY_INSTALLED=1
        ) else (
            echo [INFO] Trying final alternative approach (3/3)...
            
            :: Last resort - Try with specific flags
            python -m pip install --no-cache-dir numpy==1.24.3 --only-binary=numpy --no-cache-dir --no-deps
            if %errorlevel% equ 0 (
                set NUMPY_INSTALLED=1
                
                :: Install dependencies separately if needed
                python -m pip install pybind11
            )
        )
    )
)

:: Verify NumPy installation
if !NUMPY_INSTALLED! equ 1 (
    python -c "import numpy; print(f'NumPy {numpy.__version__} installed successfully')"
    if %errorlevel% neq 0 (
        echo [ERROR] NumPy package installed but cannot be imported correctly.
        set NUMPY_INSTALLED=0
    )
)

:: Exit if NumPy installation failed
if !NUMPY_INSTALLED! neq 1 (
    echo [ERROR] All attempts to install NumPy failed.
    echo [INFO] Please try with Python 3.10 which has better compatibility.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: 4. Install OpenCV (computer vision library)
echo [INFO] Installing OpenCV...
set OPENCV_INSTALLED=0

:: Try specific version for this Python version
if !PY_MAJOR!.!PY_MINOR! GEQ 3.12 (
    python -m pip install --no-cache-dir --only-binary=opencv-python "opencv-python>=4.8.0"
) else (
    python -m pip install --no-cache-dir opencv-python==4.8.0.76 --only-binary=opencv-python
)

if %errorlevel% equ 0 (
    set OPENCV_INSTALLED=1
) else (
    echo [WARNING] First OpenCV installation attempt failed.
    echo [INFO] Trying alternative approach...
    
    :: Try with a different source
    python -m pip install --no-cache-dir opencv-python --only-binary=opencv-python --index-url https://pypi.org/simple/
    if %errorlevel% equ 0 (
        set OPENCV_INSTALLED=1
    ) else (
        :: One last attempt with no version constraint
        python -m pip install --no-cache-dir opencv-python --only-binary=opencv-python --no-deps
        if %errorlevel% equ 0 (
            set OPENCV_INSTALLED=1
            :: Install common dependencies separately
            python -m pip install numpy
        )
    )
)

:: Verify OpenCV installation
if !OPENCV_INSTALLED! equ 1 (
    python -c "import cv2; print(f'OpenCV {cv2.__version__} installed successfully')"
    if %errorlevel% neq 0 (
        echo [ERROR] OpenCV package installed but cannot be imported correctly.
        set OPENCV_INSTALLED=0
    )
)

:: Exit if OpenCV installation failed
if !OPENCV_INSTALLED! neq 1 (
    echo [ERROR] All attempts to install OpenCV failed.
    echo [INFO] This is required. Please try with a different Python version.
    call venv\Scripts\deactivate.bat
    pause
    exit /b 1
)

:: 5. Install EasyOCR (optional but useful)
echo [INFO] Installing EasyOCR (this may take several minutes)...
set EASYOCR_INSTALLED=0

python -m pip install easyocr==1.7.0
if %errorlevel% equ 0 (
    set EASYOCR_INSTALLED=1
) else (
    echo [WARNING] Standard EasyOCR installation failed.
    echo [INFO] Trying alternative installation approach...
    
    :: Try to install core components separately
    python -m pip install easyocr --no-deps
    python -m pip install torch==2.0.1 torchvision==0.15.2 --index-url https://download.pytorch.org/whl/cpu
    python -m pip install Pillow scipy Jinja2 scikit-image
    
    :: Check if core components are installed, even if the full package failed
    python -c "import torch" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [INFO] Core OCR dependencies installed successfully.
        set EASYOCR_INSTALLED=1
    )
)

if !EASYOCR_INSTALLED! neq 1 (
    echo [WARNING] Could not install EasyOCR or its core dependencies.
    echo [INFO] The application will run with limited OCR functionality.
)

:: Perform final verification of all critical packages
echo [INFO] Performing final verification of all critical packages...
(
echo from verify_helpers import check_imports
echo print("Verifying critical packages...")
echo failed = check_imports(['requests', 'customtkinter', 'numpy', 'cv2'])
echo if failed:
echo     print(f"VERIFICATION FAILED for: {', '.join(failed)}")
echo     exit(1)
echo else:
echo     print("All critical imports verified successfully!")
) > "%TEMP%\final_verify.py"

python "%TEMP%\final_verify.py"
if %errorlevel% neq 0 (
    echo [ERROR] Final verification failed. Some packages may not be installed correctly.
    echo [INFO] The application may not work properly.
    pause
    exit /b 1
)

:: Clean up temporary files
del "%TEMP%\verify_helpers.py" 2>nul
del "%TEMP%\final_verify.py" 2>nul

:: Create installation record
echo Installation completed on %date% %time% > "%INSTALL_DIR%\installation_completed.txt"
echo Python version: !PY_MAJOR!.!PY_MINOR!.!PY_PATCH! >> "%INSTALL_DIR%\installation_completed.txt"

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
endlocal 