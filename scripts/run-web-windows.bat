@echo off
REM Flutter Web Runner Script for P-Memo (Windows)

echo 🌐 Starting P-Memo Web Application...

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed.
    echo Please run scripts\setup-windows.bat first.
    pause
    exit /b 1
)

REM Get Flutter dependencies
echo 📦 Getting Flutter dependencies...
flutter pub get

REM Enable web support
echo 🌐 Enabling web support...
flutter config --enable-web

REM Clean previous build
echo 🧹 Cleaning previous build...
flutter clean

REM Run web application
echo 🚀 Starting web server on http://localhost:8080
echo.
echo 📱 The app will open in your default browser.
echo 🔄 Hot reload: Press 'r' in terminal to reload
echo 🛑 Stop server: Press Ctrl+C
echo.

flutter run -d chrome --web-port 8080

pause