@echo off
setlocal enabledelayedexpansion

echo ========== INTEGRITY ASSISTANT INSTALLER ==========
echo.
echo [INFO] Starting installation process...

:: Set installation directory
set INSTALL_DIR=%USERPROFILE%\IntegrityAssistant
echo [INFO] Installation directory: %INSTALL_DIR%

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

:: Create installation directory
if not exist "%INSTALL_DIR%" (
    echo [INFO] Creating installation directory...
    mkdir "%INSTALL_DIR%"
)

:: Copy files
echo [INFO] Copying program files...
for %%f in (integrity_*.py) do (
    echo %%f
    copy /Y "%%f" "%INSTALL_DIR%\" >nul
)

:: Create virtual environment
echo [INFO] Creating virtual environment...
cd /d "%INSTALL_DIR%"
python -m venv venv
call venv\Scripts\activate.bat

echo [INFO] Virtual environment activated

:: Critical setup for Python 3.13+
echo [INFO] Upgrading pip...
python -m pip install --upgrade pip

if !PY_MAJOR!.!PY_MINOR! GEQ 3.13 (
    echo [INFO] Setting up Python 3.13+ compatibility...
    
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
)

:: Install packages one by one
echo [INFO] Installing dependencies...

:: Install requests
python -m pip install --no-cache-dir requests==2.31.0
if %errorlevel% neq 0 exit /b 1

:: Install customtkinter
python -m pip install --no-cache-dir customtkinter==5.2.0
if %errorlevel% neq 0 exit /b 1

:: Install numpy (binary only)
python -m pip install --no-cache-dir --only-binary=numpy "numpy>=1.26.0"
if %errorlevel% neq 0 exit /b 1

:: Install opencv (binary only)
python -m pip install --no-cache-dir --only-binary=opencv-python "opencv-python>=4.8.0"
if %errorlevel% neq 0 exit /b 1

:: Create config directory
echo [INFO] Creating configuration directory...
if not exist "%INSTALL_DIR%\config" mkdir "%INSTALL_DIR%\config"

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
echo ==========================================
echo Integrity Assistant is ready to launch!
echo.

:: Run the application
echo [INFO] Starting Integrity Assistant...
python integrity_main.py

:: Deactivate virtual environment
call venv\Scripts\deactivate.bat
endlocal 