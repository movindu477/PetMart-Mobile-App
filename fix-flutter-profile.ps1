# Fix Flutter Profile Script
# This script removes the old flutter function and reloads the profile

Write-Host "Fixing Flutter profile..." -ForegroundColor Cyan

# Remove any existing flutter function
if (Get-Command flutter -ErrorAction SilentlyContinue | Where-Object { $_.CommandType -eq 'Function' }) {
    Remove-Item function:flutter -Force -ErrorAction SilentlyContinue
    Write-Host "Removed old flutter function" -ForegroundColor Green
}

# Reload the profile
$profilePath = "C:\Users\USER\Documents\PowerShell\profile.ps1"
if (Test-Path $profilePath) {
    . $profilePath
    Write-Host "Profile reloaded successfully" -ForegroundColor Green
} else {
    Write-Host "Warning: Profile file not found at $profilePath" -ForegroundColor Yellow
}

# Test Flutter
Write-Host "`nTesting Flutter..." -ForegroundColor Cyan
flutter --version

Write-Host "`nFix complete! Flutter should now work correctly." -ForegroundColor Green
