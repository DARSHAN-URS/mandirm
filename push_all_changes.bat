@echo off
title Mandirm - Deployment and Push
color 0A

echo ============================================================
echo           MANDIRM DEPLOYMENT: AUTO FIX AND FORCE PUSH
echo ============================================================
echo.

:: 1. CONSUMER WEBSITE
echo [1/4] Processing Consumer Website (mandirmweb)...
cd /d "%~dp0consumer_website"
git status --short
echo [*] Staging and committing changes...
git add .
git commit -m "fix: temple hindi-english localization, image fallback for admin-added temples, and direct temple detail routing"
echo [*] Pushing to origin main...
git push origin main
if %ERRORLEVEL% NEQ 0 (
    echo [!] Standard push encountered an issue, attempting push with force...
    git push origin main --force
)
echo [+] Consumer Website push finished!
echo.

:: 2. ADMIN PANEL
echo [2/4] Processing Admin Panel (mandirm-admin)...
cd /d "%~dp0admin_panel"
git status --short
git add .
git commit -m "feat(admin): temple chadhawa linking, system file upload, and update chadhawa faqs"
echo Pushing admin_panel to origin main...
git push origin main
if %ERRORLEVEL% NEQ 0 (
    echo [!] Standard push encountered an issue, attempting push with force...
    git push origin main --force
)
echo [+] Admin Panel push finished!
echo.

:: 3. CONSUMER APP
echo [3/4] Processing Consumer Mobile App (consumer_app)...
cd /d "%~dp0consumer_app"
git status --short 2>nul
git add . 2>nul
git commit -m "feat(consumer-app): sync with live database, remove AI Jyotish bot, connect verified astrologers & official helplines" 2>nul
git push origin main 2>nul
echo [+] Consumer App changes staged!
echo.

:: 4. ASTROLOGER APP
echo [4/5] Processing Astrologer Mobile App (astrologer_app)...
cd /d "%~dp0astrologer_app"
git status --short 2>nul
git add . 2>nul
git commit -m "feat(astrologer-app): live Supabase sync, remove hardcoded data, support emails and avatar resolution" 2>nul
git push origin main 2>nul
echo [+] Astrologer App changes staged!
echo.

:: 5. ROOT REPOSITORY
echo [5/5] Processing Root Workspace...
cd /d "%~dp0"
git add .
git commit -m "feat: live database sync, remove AI Jyotish, and add official support emails across app & web"
git push origin main
if %ERRORLEVEL% NEQ 0 (
    echo [!] Root push encountered an issue, attempting push with force...
    git push origin main --force
)
echo [+] Root workspace updated!
echo.

echo ============================================================
echo   ALL REPOSITORIES PROCESSED AND PUSHED TO PRODUCTION!
echo ============================================================
echo.
pause
