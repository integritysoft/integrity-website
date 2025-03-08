# PowerShell Script to create password-protected zip files for Integrity Assistant
# This script provides guidance - you'll still need to use 7-Zip manually

Write-Host "=== Integrity Assistant - Protected Zip Creation Guide ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will guide you through creating password-protected zip files for distribution." -ForegroundColor White
Write-Host ""
Write-Host "REQUIREMENTS:" -ForegroundColor Yellow
Write-Host "- 7-Zip installed (download from https://7-zip.org/)" -ForegroundColor White
Write-Host "- Integrity Assistant files ready for each platform" -ForegroundColor White
Write-Host ""

Write-Host "STEP 1: Ensure your files are organized" -ForegroundColor Green
Write-Host "For each platform (Windows, macOS, Linux), create a folder with:" -ForegroundColor White
Write-Host "- All files needed for that platform" -ForegroundColor White
Write-Host "- Copy of IMPORTANT_README.txt (from protected_downloads folder)" -ForegroundColor White
Write-Host ""

Write-Host "STEP 2: Create password-protected zip files manually" -ForegroundColor Green
Write-Host "For each platform folder:" -ForegroundColor White
Write-Host "1. Right-click on the folder" -ForegroundColor White
Write-Host "2. Select 7-Zip > Add to archive..." -ForegroundColor White
Write-Host "3. Set format to ZIP" -ForegroundColor White
Write-Host "4. Go to Encryption section" -ForegroundColor White
Write-Host "5. Enter password: integrity2025" -ForegroundColor Yellow
Write-Host "6. Set encryption method to AES-256" -ForegroundColor White
Write-Host "7. Click OK to create zip file" -ForegroundColor White
Write-Host ""

Write-Host "STEP 3: Move protected zip files" -ForegroundColor Green
Write-Host "Move all protected zip files to: public/downloads/" -ForegroundColor White
Write-Host "Name them:" -ForegroundColor White
Write-Host "- integrity-assistant-windows-protected.zip" -ForegroundColor White
Write-Host "- integrity-assistant-macos-protected.zip" -ForegroundColor White
Write-Host "- integrity-assistant-linux-protected.zip" -ForegroundColor White
Write-Host ""

Write-Host "STEP 4: Update repository" -ForegroundColor Green
Write-Host "Commit and push changes to your repository" -ForegroundColor White
Write-Host "Vercel should automatically deploy the updates" -ForegroundColor White
Write-Host ""

Write-Host "DONE!" -ForegroundColor Cyan
Write-Host "Your protected downloads should now work with minimal antivirus interference." -ForegroundColor White 