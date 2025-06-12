@echo off
REM Portable Flutter Web Runner for P-Memo (Windows)
REM This script works without system Flutter installation

echo 🌐 P-Memo Web Application (Portable Mode)

setlocal enabledelayedexpansion

REM Check for local Flutter installation first
set LOCAL_FLUTTER=C:\flutter\bin\flutter.bat
set PORTABLE_FLUTTER=%~dp0..\tools\flutter\bin\flutter.bat

REM Try system Flutter first
flutter --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Using system Flutter installation
    set FLUTTER_CMD=flutter
    goto :run_app
)

REM Try local Flutter installation
if exist "%LOCAL_FLUTTER%" (
    echo ✅ Using local Flutter installation at C:\flutter
    set FLUTTER_CMD="%LOCAL_FLUTTER%"
    goto :run_app
)

REM Try portable Flutter
if exist "%PORTABLE_FLUTTER%" (
    echo ✅ Using portable Flutter installation
    set FLUTTER_CMD="%PORTABLE_FLUTTER%"
    goto :run_app
)

REM No Flutter found - offer to install
echo ❌ Flutter not found on this system.
echo.
echo 🚀 Would you like to install Flutter automatically?
echo.
choice /C YN /M "Install Flutter SDK? (Y/N)"
if errorlevel 2 goto :manual_install
if errorlevel 1 (
    call "%~dp0install-flutter-windows.bat"
    if !errorlevel! equ 0 (
        echo.
        echo 🔄 Restarting with newly installed Flutter...
        call "%~dp0run-web-portable.bat"
        exit /b
    ) else (
        echo ❌ Flutter installation failed.
        goto :manual_install
    )
)

:manual_install
echo.
echo 📖 Manual Installation Steps:
echo 1. Run: scripts\install-flutter-windows.bat
echo 2. Or download from: https://docs.flutter.dev/get-started/install/windows
echo 3. Restart command prompt after installation
echo.
pause
exit /b 1

:run_app
echo.
echo 📦 Getting Flutter dependencies...
%FLUTTER_CMD% pub get

if %errorlevel% neq 0 (
    echo ❌ Failed to get dependencies.
    echo Try running: flutter clean
    pause
    exit /b 1
)

REM Enable web support
echo 🌐 Enabling web support...
%FLUTTER_CMD% config --enable-web

REM Clean previous build
echo 🧹 Cleaning previous build...
%FLUTTER_CMD% clean

REM Check if Chrome is available
where chrome >nul 2>&1
if %errorlevel% equ 0 (
    set WEB_DEVICE=chrome
    echo 🌐 Using Chrome browser
) else (
    set WEB_DEVICE=web-server
    echo 🌐 Using web server mode
)

REM Run web application
echo.
echo 🚀 Starting P-Memo web application...
echo 📱 App will be available at: http://localhost:8080
echo.
echo 💡 Tips:
echo    - Press 'r' to hot reload
echo    - Press 'R' to hot restart
echo    - Press 'q' to quit
echo    - Press Ctrl+C to stop server
echo.

%FLUTTER_CMD% run -d %WEB_DEVICE% --web-port 8080

pause