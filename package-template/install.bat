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

:: Install dependencies
echo [INFO] Installing dependencies...
python -m pip install --upgrade pip
python -m pip install --no-cache-dir setuptools wheel
python -m pip install --no-cache-dir requests customtkinter "numpy>=1.26.0" "opencv-python>=4.8.0" "python-supabase>=2.0.0"

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