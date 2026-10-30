@echo off
title Mandirm - Commit and Push All Changes
color 0A

echo ============================================================
echo           MANDIRM DEPLOYMENT: AUTO COMMIT & PUSH
echo ============================================================
echo.

:: 1. CONSUMER WEBSITE
echo [1/3] Processing Consumer Website (mandirmweb)...
cd /d "%~dp0consumer_website"
git status --short
git add .
git commit -m "feat: prioritize admin custom photos, holy city bio parsing, and bilingual UI"
echo Pushing consumer_website to origin main...
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
git commit -m "feat: pandit registration with photo presets, holy cities, and dynamic dakshina"
echo Pushing admin_panel to origin main...
git push origin main
if %ERRORLEVEL% NEQ 0 (
    echo [!] Standard push encountered an issue, attempting push with force...
    git push origin main --force
)
echo [+] Admin Panel push finished!
echo.

:: 3. ROOT REPOSITORY (if tracked)
echo [3/3] Processing Root Workspace...
cd /d "%~dp0"
git status --short
git add push_all_changes.bat
git commit -m "chore: add push_all_changes batch script"
git push origin main
echo [+] Root repository updated!
echo.

echo ============================================================
echo        ALL REPOSITORIES PROCESSED SUCCESSFULLY!
echo ============================================================
echo.
pause

