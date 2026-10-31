@echo off
title Mandirm - Deployment and Push
color 0A

echo ============================================================
echo           MANDIRM DEPLOYMENT: AUTO FIX AND FORCE PUSH
echo ============================================================
echo.

:: 1. CONSUMER WEBSITE
echo [1/3] Processing Consumer Website (mandirmweb)...
cd /d "%~dp0consumer_website"
git status --short
echo [*] Staging and committing changes...
git add .
git commit -m "fix(build): resolve Razorpay payment types in chadhawa, remove WhatsApp video references, and link all tap-to-detail pages"
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
git commit -m "feat: add Sri Mandir details editor, FAQ manager, auto-fill Hindi button, and bilingual content persistence"
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
git add .
git commit -m "feat: add migration 002 for details & FAQs, update batch deployment script"
git push origin main
echo [+] Root workspace updated!
echo.

echo ============================================================
echo   ALL REPOSITORIES PROCESSED AND PUSHED TO NETLIFY!
echo ============================================================
echo.
pause
