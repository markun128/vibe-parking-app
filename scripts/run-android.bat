@echo off
REM Android Emulator Runner Script for P-Memo (Windows)

echo 🚀 Starting Android Emulator for P-Memo on Windows...

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed. Please install Docker Desktop first.
    echo Download from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

REM Build Docker image
echo 🔨 Building Docker image...
docker-compose build

if %errorlevel% neq 0 (
    echo ❌ Failed to build Docker image.
    pause
    exit /b 1
)

REM Start the Android emulator
echo 📱 Starting Android emulator...
docker-compose up -d

if %errorlevel% neq 0 (
    echo ❌ Failed to start emulator.
    pause
    exit /b 1
)

REM Wait for container to be ready
echo ⏳ Waiting for emulator to start... (this may take 2-3 minutes)
timeout /t 60 /nobreak

REM Show container status
echo 📋 Container status:
docker-compose ps

echo.
echo ✅ Emulator container started successfully!
echo.
echo 📱 To connect ADB and run Flutter app:
echo    1. Open a new command prompt
echo    2. Run: scripts\connect-adb.bat
echo    3. Run: flutter run -d emulator-5554
echo.
echo 🔍 To view emulator logs:
echo    docker-compose logs -f android-emulator
echo.
echo 🛑 To stop emulator:
echo    docker-compose down
echo.

pause