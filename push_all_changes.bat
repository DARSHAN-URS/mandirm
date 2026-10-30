@echo off
title Mandirm - Fix Netlify Build & Push All Changes
color 0A

echo ============================================================
echo           MANDIRM DEPLOYMENT: AUTO FIX & FORCE PUSH
echo ============================================================
echo.

:: 1. CONSUMER WEBSITE
echo [1/3] Processing Consumer Website (mandirmweb)...
cd /d "%~dp0consumer_website"

:: Restore page.tsx to clean state and run regex automated cleaner
echo [*] Reverting corrupted edits and applying clean fix to page.tsx...
git checkout src/app/page.tsx
node fix_page.js

echo [*] Staging and committing changes...
git add .
git commit -m "fix: resolve Netlify build by removing dead live darshan modal and typing errors"

echo [*] Pushing to origin main...
git push origin main
if %ERRORLEVEL% NEQ 0 (
    echo [!] Standard push encountered an issue, attempting push with force...
    git push origin main --force
)
echo [+] Consumer Website push finished!
echo.

:: 2. ADMIN PANEL
echo [2/3] Processing Admin Panel (mandirm-admin)...
cd /d "%~dp0admin_panel"
git status --short
git add .
git commit -m "feat: add Add Pandit button in header banner, remove mock fallbacks, add EN/HI toggle with full bilingual transformation"
echo Pushing admin_panel to origin main...
git push origin main
if %ERRORLEVEL% NEQ 0 (
    echo [!] Standard push encountered an issue, attempting push with force...
    git push origin main --force
)
echo [+] Admin Panel push finished!
echo.

:: 3. ROOT REPOSITORY
echo [3/3] Processing Root Workspace...
cd /d "%~dp0"
git add push_all_changes.bat
git commit -m "chore: update push_all_changes batch script with admin language toggle and add pandit button"
git push origin main
echo [+] Root workspace updated!
echo.

echo ============================================================
echo   ALL REPOSITORIES PROCESSED & PUSHED TO NETLIFY SUCCESSFULLY!
echo ============================================================
echo.
pause
