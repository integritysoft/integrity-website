# PowerShell script to clean up the integrity-website repository

Write-Host "=== INTEGRITY WEBSITE REPOSITORY CLEANUP ===" -ForegroundColor Cyan
Write-Host "This script will help organize your repository with only necessary files." -ForegroundColor White
Write-Host ""

# Step 1: Create proper directory structure if it doesn't exist
Write-Host "Step 1: Ensuring proper directory structure..." -ForegroundColor Green
if (-not (Test-Path "public")) {
    New-Item -Path "public" -ItemType Directory
}
if (-not (Test-Path "public\downloads")) {
    New-Item -Path "public\downloads" -ItemType Directory
}

# Step 2: Check if the essentials files exist
Write-Host "Step 2: Checking essential files..." -ForegroundColor Green
$essentials = @(
    "index.html",
    "vercel.json",
    "README.md",
    "public\downloads\IMPORTANT_README.txt",
    "public\downloads\run_integrity.bat"
)

$missing = @()
foreach ($file in $essentials) {
    if (-not (Test-Path $file)) {
        $missing += $file
    }
}

if ($missing.Count -gt 0) {
    Write-Host "WARNING: The following essential files are missing:" -ForegroundColor Yellow
    foreach ($file in $missing) {
        Write-Host "  - $file" -ForegroundColor Yellow
    }
    Write-Host "Please make sure these files are created before proceeding." -ForegroundColor Yellow
    Write-Host ""
}

# Step 3: Create a package structure example for convenience
Write-Host "Step 3: Creating a clean package template..." -ForegroundColor Green
$packageDir = "package-template"
if (-not (Test-Path $packageDir)) {
    New-Item -Path $packageDir -ItemType Directory
    New-Item -Path "$packageDir\src" -ItemType Directory
    
    # Copy README and batch file
    Copy-Item "public\downloads\IMPORTANT_README.txt" -Destination $packageDir
    Copy-Item "public\downloads\run_integrity.bat" -Destination $packageDir
    
    # Create a placeholder for the main script
    @"
# This is a placeholder for your main Python script
# Replace this with your actual code

import sys
print("Integrity Assistant - Main Application")
print(f"Running on Python {sys.version}")
print("\nThis is just a placeholder. Replace with your actual application code.")
input("\nPress Enter to exit...")
"@ | Out-File -FilePath "$packageDir\src\integrity_main.py" -Encoding utf8
}

Write-Host "Package template created at: $packageDir" -ForegroundColor White
Write-Host "Use this template to organize your actual application files." -ForegroundColor White
Write-Host ""

# Step 4: List of files that can be safely removed
Write-Host "Step 4: Files that can be safely removed..." -ForegroundColor Green
$removableFiles = @(
    "downloads\*.*",
    "SUPABASE.md",
    "supabase_setup.sql",
    "create_protected_zips.ps1"
)

foreach ($pattern in $removableFiles) {
    $files = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        Write-Host "  - $($file.FullName)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "To delete these files, uncomment the 'Remove-Item' lines in this script." -ForegroundColor Yellow
Write-Host ""

# Uncomment these lines when you're ready to actually delete files
# foreach ($pattern in $removableFiles) {
#     Remove-Item -Path $pattern -Force -Recurse -ErrorAction SilentlyContinue
# }
# if (Test-Path "downloads") { 
#     Remove-Item -Path "downloads" -Force -Recurse -ErrorAction SilentlyContinue
# }

# Step 5: Instructions for creating the final package
Write-Host "Step 5: Creating the final package..." -ForegroundColor Green
Write-Host "1. Organize your application files using the package template" -ForegroundColor White
Write-Host "2. Use 7-Zip to create a password-protected zip (password: integrity2025)" -ForegroundColor White
Write-Host "3. Name the file: integrity-assistant-windows-protected.zip" -ForegroundColor White
Write-Host "4. Move it to public\downloads\" -ForegroundColor White
Write-Host "5. Remove any other files from public\downloads\ except:" -ForegroundColor White
Write-Host "   - integrity-assistant-windows-protected.zip" -ForegroundColor White
Write-Host "   - integrity-assistant-macos-protected.zip (if you have macOS version)" -ForegroundColor White
Write-Host "   - integrity-assistant-linux-protected.zip (if you have Linux version)" -ForegroundColor White
Write-Host ""

Write-Host "Repository cleanup guide complete!" -ForegroundColor Cyan
Write-Host "After following these steps, your repository will have only the necessary files." -ForegroundColor White 