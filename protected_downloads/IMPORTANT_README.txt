========== INTEGRITY ASSISTANT - QUICK START GUIDE ==========

PASSWORD FOR THIS ZIP FILE: integrity2025

==== GETTING STARTED (JUST 2 STEPS!) ====

1. EXTRACT THIS ZIP FILE:
   - Right-click the zip file
   - Select "Extract All..." 
   - When prompted, enter: integrity2025
   - Click "Extract"

2. RUN THE PROGRAM:
   - Double-click "run_integrity.bat"
   - That's it! Everything else happens automatically

The first time you run the application, it will:
- Check if Python is installed (and help you install it if needed)
- Set up a clean environment
- Install all necessary components
- Launch Integrity Assistant

Future launches will be much faster!

==== TROUBLESHOOTING ====

• If you see a Windows Security warning:
  Click "More info" and then "Run anyway"

• If Python isn't installed:
  The launcher will open the download page for you
  Be sure to check "Add Python to PATH" during installation

• If your antivirus interferes:
  Add the extracted folder to your antivirus exceptions

• If you see "ModuleNotFoundError" messages:
  - The launcher will now detect and fix this automatically
  - Each dependency is installed one by one with error checking
  - If you still have issues, try running the launcher with administrator privileges

• If numpy or other packages fail to install:
  - The launcher now uses pre-compiled wheels to avoid build errors
  - Make sure you have an active internet connection
  - If problems persist, try from a different network (some corporate networks block pip)

• If the application crashes after starting:
  - Check the error messages in the console window
  - Try running the launcher again as administrator
  - Make sure your Python version is 3.8 or higher (3.10 recommended)

==== NEED HELP? ====

Contact our support team at: integritysoftware1@gmail.com

Thank you for trying the Integrity Assistant!

==== TECHNICAL DETAILS ====

Integrity Assistant creates a Python virtual environment in the installation folder to ensure it doesn't interfere with other Python applications on your system. The installation process installs these packages:

- requests: For API communication
- customtkinter: For the modern user interface
- numpy: For numerical operations
- opencv-python: For image processing
- easyocr: For optical character recognition

All dependencies use specific versions to ensure compatibility. The installation process has been improved to handle errors gracefully and provide clear feedback when issues occur.

If you're a developer and want to modify the installation process, you can edit run_integrity.bat to customize it for your needs. 