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

The installation process:
- Detects your Python version and adapts package installations accordingly
- Creates a dedicated installation directory in your user folder
- Sets up a clean virtual environment to avoid conflicts
- Installs compatible versions of all dependencies
- Creates a desktop shortcut for easy access
- Launches the application when done

Future launches will be much faster using the desktop shortcut!

==== COMPATIBLE PYTHON VERSIONS ====

Integrity Assistant works with Python 3.8 and higher, with these notes:
• Python 3.8-3.10: Best compatibility with all dependencies
• Python 3.11-3.12: Good compatibility, some adapters used
• Python 3.13+: Newest version with experimental support

If you encounter issues with Python 3.13+, we recommend installing Python 3.10
which has the best compatibility with all required packages.

==== TROUBLESHOOTING ====

• If you see a Windows Security warning:
  Click "More info" and then "Run anyway"

• If Python isn't installed:
  The launcher will open the download page for you
  Be sure to check "Add Python to PATH" during installation

• If your antivirus interferes:
  Add the extracted folder to your antivirus exceptions

• If you see dependency installation errors:
  - The installer now provides detailed error messages
  - For NumPy issues on Python 3.13+, try installing Python 3.10
  - For EasyOCR issues, the installer will fallback to core functionality

• If the application crashes after starting:
  - Check the error messages in the console window
  - Try running the desktop shortcut as administrator
  - Verify the installation by running setup.bat in the installation folder

==== NEED HELP? ====

Contact our support team at: integritysoftware1@gmail.com

Thank you for trying the Integrity Assistant!

==== TECHNICAL DETAILS ====

The improved installation process now:

1. Creates a dedicated installation directory at %USERPROFILE%\IntegrityAssistant
2. Sets up a virtual environment within that directory
3. Detects your Python version and installs appropriate package versions:
   - requests: For API communication
   - customtkinter: For the modern user interface  
   - numpy: Version selected based on Python version compatibility
   - opencv-python: Version selected based on Python version
   - easyocr: With fallback installation methods if needed

4. Creates two helper scripts:
   - run.bat: Starts the application using the virtual environment
   - setup.bat: Full installation script with enhanced error handling

5. Creates a desktop shortcut for easy future access

This architecture ensures maximum compatibility across different Python versions
and provides a clean, isolated environment for the application to run in.

==== CLEANUP SCRIPT ====

The cleanup script (`cleanup_repository.ps1`) is a PowerShell script I created to help you organize your repository. It doesn't automatically delete files (for safety), but rather:

1. Creates a proper directory structure
2. Checks if essential files exist
3. Creates a package template for your application
4. Lists files that can be safely removed
5. Provides instructions for creating the final package

The script hasn't run automatically - you need to execute it manually. Here's how:

1. Open PowerShell in your repository directory
2. Run the script with:
   ```
   .\cleanup_repository.ps1
   ```

When you run it, you'll see colored output showing:
- Which essential files are present/missing
- A new `package-template` folder with the proper structure
- A list of files that can be safely removed
- Step-by-step instructions for creating your final package

If you want the script to actually delete unnecessary files, you'll need to edit it and uncomment these lines near the end:

```powershell
# Uncomment these lines when you're ready to actually delete files
# foreach ($pattern in $removableFiles) {
#     Remove-Item -Path $pattern -Force -Recurse -ErrorAction SilentlyContinue
# }
# if (Test-Path "downloads") { 
#     Remove-Item -Path "downloads" -Force -Recurse -ErrorAction SilentlyContinue
# }
```

Would you like me to modify the script to automatically delete the unnecessary files, or would you prefer to run it first to see what it reports?