@echo off
REM Windows Setup Script for P-Memo Development Environment

echo 🚀 P-Memo Development Environment Setup for Windows

echo.
echo This script will help you set up the development environment for P-Memo.
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed.
    echo.
    echo Please install Flutter first:
    echo 1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows
    echo 2. Extract to C:\flutter (or your preferred location)
    echo 3. Add C:\flutter\bin to your PATH environment variable
    echo 4. Restart command prompt and run this script again
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Flutter is installed
    flutter --version
)

echo.

REM Check if Git is installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git is not installed.
    echo Please install Git from: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Git is installed
)

echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️ Docker is not installed (optional for Android emulator).
    echo.
    echo To use Docker Android emulator:
    echo 1. Install Docker Desktop from: https://www.docker.com/products/docker-desktop
    echo 2. Enable WSL 2 backend
    echo 3. Enable Hyper-V (if available)
    echo.
) else (
    echo ✅ Docker is installed
    docker --version
)

echo.

REM Run Flutter doctor
echo 🔍 Running Flutter doctor...
flutter doctor

echo.

REM Get Flutter dependencies
echo 📦 Getting Flutter dependencies...
flutter pub get

if %errorlevel% neq 0 (
    echo ❌ Failed to get Flutter dependencies.
    pause
    exit /b 1
)

echo.
echo ✅ Setup completed successfully!
echo.
echo 🚀 Available commands:
echo.
echo Web Development:
echo   flutter run -d chrome --web-port 8080
echo.
echo Android Development (with Docker):
echo   scripts\run-android.bat
echo   scripts\connect-adb.bat  (in new terminal)
echo   flutter run -d emulator-5554
echo.
echo Android Development (local):
echo   flutter emulators --launch ^<emulator_name^>
echo   flutter run
echo.

pause