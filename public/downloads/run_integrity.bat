@echo off
echo ========== INTEGRITY ASSISTANT LAUNCHER ==========
echo.
echo Checking Python version...
python --version > temp_version.txt 2>&1
set /p PYTHON_VERSION=<temp_version.txt
echo %PYTHON_VERSION%
del temp_version.txt

REM Extract the version number
for /f "tokens=2" %%i in ("%PYTHON_VERSION%") do set PYTHON_VERSION=%%i

REM Check if Python is installed
if "%PYTHON_VERSION%"=="" (
    echo ERROR: Python is not installed or not in PATH.
    echo.
    echo We'll open the Python download page for you.
    echo Please install Python 3.8-3.10 (recommended) and be sure to check "Add Python to PATH" during installation.
    echo After installation, please run this launcher again.
    echo.
    start https://www.python.org/downloads/
    echo Press any key to exit...
    pause > nul
    exit /b 1
) else (
    echo Found Python %PYTHON_VERSION%
)

REM Create installation directory
set INSTALL_DIR=%USERPROFILE%\IntegrityAssistant
echo Creating installation directory %INSTALL_DIR%...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Copy necessary files
echo Copying program files...
xcopy /y .\integrity_*.py "%INSTALL_DIR%\"

REM Create a configuration directory
echo Creating configuration directory...
if not exist "%INSTALL_DIR%\config" mkdir "%INSTALL_DIR%\config"

REM Create a desktop shortcut
echo Creating desktop shortcut...
echo @echo off > "%USERPROFILE%\Desktop\Integrity Assistant.bat"
echo cd /d "%INSTALL_DIR%" >> "%USERPROFILE%\Desktop\Integrity Assistant.bat"
echo call "%INSTALL_DIR%\run.bat" >> "%USERPROFILE%\Desktop\Integrity Assistant.bat"

REM Create a launcher script in the installation directory
echo @echo off > "%INSTALL_DIR%\run.bat"
echo cd /d "%INSTALL_DIR%" >> "%INSTALL_DIR%\run.bat"
echo if exist venv\Scripts\activate.bat ( >> "%INSTALL_DIR%\run.bat"
echo   call venv\Scripts\activate.bat >> "%INSTALL_DIR%\run.bat"
echo   python integrity_main.py >> "%INSTALL_DIR%\run.bat"
echo   call venv\Scripts\deactivate.bat >> "%INSTALL_DIR%\run.bat"
echo ) else ( >> "%INSTALL_DIR%\run.bat"
echo   echo Virtual environment not found. Running setup... >> "%INSTALL_DIR%\run.bat"
echo   call "%INSTALL_DIR%\setup.bat" >> "%INSTALL_DIR%\run.bat"
echo ) >> "%INSTALL_DIR%\run.bat"

REM Create a setup script in the installation directory
echo @echo off > "%INSTALL_DIR%\setup.bat"
echo cd /d "%INSTALL_DIR%" >> "%INSTALL_DIR%\setup.bat"
echo echo Setting up Integrity Assistant environment... >> "%INSTALL_DIR%\setup.bat"

REM Add version-specific instructions
echo if not exist venv ( >> "%INSTALL_DIR%\setup.bat"
echo   echo Creating virtual environment... >> "%INSTALL_DIR%\setup.bat"
echo   python -m venv venv >> "%INSTALL_DIR%\setup.bat"
echo   if errorlevel 1 ( >> "%INSTALL_DIR%\setup.bat"
echo     echo Failed to create virtual environment with venv module. >> "%INSTALL_DIR%\setup.bat"
echo     echo Installing virtualenv... >> "%INSTALL_DIR%\setup.bat"
echo     python -m pip install virtualenv >> "%INSTALL_DIR%\setup.bat"
echo     python -m virtualenv venv >> "%INSTALL_DIR%\setup.bat"
echo     if errorlevel 1 ( >> "%INSTALL_DIR%\setup.bat"
echo       echo CRITICAL ERROR: Cannot create virtual environment. >> "%INSTALL_DIR%\setup.bat"
echo       echo Please try running as administrator or install Python 3.8-3.10. >> "%INSTALL_DIR%\setup.bat"
echo       pause >> "%INSTALL_DIR%\setup.bat"
echo       exit /b 1 >> "%INSTALL_DIR%\setup.bat"
echo     ) >> "%INSTALL_DIR%\setup.bat"
echo   ) >> "%INSTALL_DIR%\setup.bat"
echo ) >> "%INSTALL_DIR%\setup.bat"

echo call venv\Scripts\activate.bat >> "%INSTALL_DIR%\setup.bat"
echo if errorlevel 1 ( >> "%INSTALL_DIR%\setup.bat"
echo   echo CRITICAL ERROR: Cannot activate virtual environment. >> "%INSTALL_DIR%\setup.bat"
echo   pause >> "%INSTALL_DIR%\setup.bat"
echo   exit /b 1 >> "%INSTALL_DIR%\setup.bat"
echo ) >> "%INSTALL_DIR%\setup.bat"

echo echo Updating pip, setuptools and wheel... >> "%INSTALL_DIR%\setup.bat"
echo python -m pip install --upgrade pip setuptools wheel >> "%INSTALL_DIR%\setup.bat"

REM Handle the installation of packages based on Python version
echo echo Installing dependencies for Python %PYTHON_VERSION%... >> "%INSTALL_DIR%\setup.bat"
echo. >> "%INSTALL_DIR%\setup.bat"

REM First install requests which is required and relatively simple
echo echo Installing requests... >> "%INSTALL_DIR%\setup.bat"
echo pip install requests >> "%INSTALL_DIR%\setup.bat"
echo if errorlevel 1 ( >> "%INSTALL_DIR%\setup.bat"
echo   echo ERROR: Failed to install requests. >> "%INSTALL_DIR%\setup.bat"
echo   echo This is required and cannot continue without it. >> "%INSTALL_DIR%\setup.bat"
echo   call venv\Scripts\deactivate.bat >> "%INSTALL_DIR%\setup.bat"
echo   pause >> "%INSTALL_DIR%\setup.bat"
echo   exit /b 1 >> "%INSTALL_DIR%\setup.bat"
echo ) >> "%INSTALL_DIR%\setup.bat"

REM Then install customtkinter - should work on all Python versions
echo echo Installing customtkinter... >> "%INSTALL_DIR%\setup.bat"
echo pip install customtkinter==5.2.0 >> "%INSTALL_DIR%\setup.bat"
echo if errorlevel 1 ( >> "%INSTALL_DIR%\setup.bat"
echo   echo ERROR: Failed to install customtkinter. >> "%INSTALL_DIR%\setup.bat"
echo   echo This is required and cannot continue without it. >> "%INSTALL_DIR%\setup.bat"
echo   call venv\Scripts\deactivate.bat >> "%INSTALL_DIR%\setup.bat"
echo   pause >> "%INSTALL_DIR%\setup.bat"
echo   exit /b 1 >> "%INSTALL_DIR%\setup.bat"
echo ) >> "%INSTALL_DIR%\setup.bat"

REM Handle numpy specially based on Python version
echo for /f "tokens=1,2 delims=." %%%%a in ('python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"') do ( >> "%INSTALL_DIR%\setup.bat"
echo   set py_major=%%%%a >> "%INSTALL_DIR%\setup.bat"
echo   set py_minor=%%%%b >> "%INSTALL_DIR%\setup.bat"
echo ) >> "%INSTALL_DIR%\setup.bat"

REM Numpy compatibility with different Python versions
echo if !py_major!.!py_minor! GEQ 3.12 ( >> "%INSTALL_DIR%\setup.bat"
echo   echo Installing numpy for Python 3.12+ ... >> "%INSTALL_DIR%\setup.bat"
echo   pip install "numpy>=1.26.0" --only-binary=numpy >> "%INSTALL_DIR%\setup.bat"
echo ) else if !py_major!.!py_minor! GEQ 3.11 ( >> "%INSTALL_DIR%\setup.bat"
echo   echo Installing numpy for Python 3.11 ... >> "%INSTALL_DIR%\setup.bat"
echo   pip install "numpy>=1.25.0,<1.26.0" --only-binary=numpy >> "%INSTALL_DIR%\setup.bat"
echo ) else if !py_major!.!py_minor! GEQ 3.8 ( >> "%INSTALL_DIR%\setup.bat"
echo   echo Installing numpy for Python 3.8-3.10 ... >> "%INSTALL_DIR%\setup.bat"
echo   pip install "numpy==1.24.3" --only-binary=numpy >> "%INSTALL_DIR%\setup.bat"
echo ) else ( >> "%INSTALL_DIR%\setup.bat"
echo   echo Installing numpy for older Python ... >> "%INSTALL_DIR%\setup.bat"
echo   pip install "numpy==1.22.4" --only-binary=numpy >> "%INSTALL_DIR%\setup.bat"
echo ) >> "%INSTALL_DIR%\setup.bat"

echo if errorlevel 1 ( >> "%INSTALL_DIR%\setup.bat"
echo   echo ERROR: Failed to install numpy. >> "%INSTALL_DIR%\setup.bat"
echo   echo This is required and cannot continue without it. >> "%INSTALL_DIR%\setup.bat"
echo   echo Please try with Python 3.8-3.10 which has better package compatibility. >> "%INSTALL_DIR%\setup.bat"
echo   call venv\Scripts\deactivate.bat >> "%INSTALL_DIR%\setup.bat"
echo   pause >> "%INSTALL_DIR%\setup.bat"
echo   exit /b 1 >> "%INSTALL_DIR%\setup.bat"
echo ) >> "%INSTALL_DIR%\setup.bat"

REM Install OpenCV with version compatibility
echo echo Installing OpenCV... >> "%INSTALL_DIR%\setup.bat"
echo if !py_major!.!py_minor! GEQ 3.12 ( >> "%INSTALL_DIR%\setup.bat"
echo   pip install opencv-python --only-binary=opencv-python >> "%INSTALL_DIR%\setup.bat"
echo ) else ( >> "%INSTALL_DIR%\setup.bat"
echo   pip install opencv-python==4.8.0.76 --only-binary=opencv-python >> "%INSTALL_DIR%\setup.bat"
echo ) >> "%INSTALL_DIR%\setup.bat"

echo if errorlevel 1 ( >> "%INSTALL_DIR%\setup.bat"
echo   echo ERROR: Failed to install OpenCV. >> "%INSTALL_DIR%\setup.bat"
echo   echo This is required and cannot continue without it. >> "%INSTALL_DIR%\setup.bat"
echo   call venv\Scripts\deactivate.bat >> "%INSTALL_DIR%\setup.bat"
echo   pause >> "%INSTALL_DIR%\setup.bat"
echo   exit /b 1 >> "%INSTALL_DIR%\setup.bat"
echo ) >> "%INSTALL_DIR%\setup.bat"

REM Install EasyOCR with fallback options
echo echo Installing EasyOCR... >> "%INSTALL_DIR%\setup.bat"
echo echo This may take a while. Please be patient... >> "%INSTALL_DIR%\setup.bat"
echo pip install easyocr==1.7.0 >> "%INSTALL_DIR%\setup.bat"
echo if errorlevel 1 ( >> "%INSTALL_DIR%\setup.bat"
echo   echo First attempt failed. Trying alternative approach... >> "%INSTALL_DIR%\setup.bat"
echo   pip install easyocr --no-deps >> "%INSTALL_DIR%\setup.bat"
echo   pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu >> "%INSTALL_DIR%\setup.bat"
echo   pip install Pillow scipy Jinja2 scikit-image >> "%INSTALL_DIR%\setup.bat"
echo   if errorlevel 1 ( >> "%INSTALL_DIR%\setup.bat"
echo     echo WARNING: Could not install EasyOCR. >> "%INSTALL_DIR%\setup.bat"
echo     echo Some OCR functions may not work. >> "%INSTALL_DIR%\setup.bat"
echo     echo Proceeding with core functionality only. >> "%INSTALL_DIR%\setup.bat"
echo   ) >> "%INSTALL_DIR%\setup.bat"
echo ) >> "%INSTALL_DIR%\setup.bat"

echo echo Installation complete. >> "%INSTALL_DIR%\setup.bat"
echo call venv\Scripts\deactivate.bat >> "%INSTALL_DIR%\setup.bat"
echo call "%INSTALL_DIR%\run.bat" >> "%INSTALL_DIR%\setup.bat"

REM Run the setup process
echo.
echo ==========================================
echo Integrity Assistant is ready to install!
echo.
echo Press any key to begin the installation process...
pause > nul
echo.
cd /d "%INSTALL_DIR%"
call "%INSTALL_DIR%\setup.bat" 