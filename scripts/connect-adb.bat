@echo off
REM ADB Connection Script for Docker Android Emulator (Windows)

echo 🔌 Connecting to Docker Android Emulator on Windows...

REM Check if Docker container is running
docker ps | findstr "pmemo-android-emulator" >nul
if %errorlevel% neq 0 (
    echo ❌ Android emulator container is not running.
    echo Please start it first with: scripts\run-android.bat
    pause
    exit /b 1
)

REM Get container IP
for /f "tokens=*" %%i in ('docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" pmemo-android-emulator') do set CONTAINER_IP=%%i

echo 📱 Container IP: %CONTAINER_IP%

REM Connect ADB to the emulator
echo 🔗 Connecting ADB...
adb connect %CONTAINER_IP%:5555

REM Wait a moment for connection
timeout /t 5 /nobreak

REM Show connected devices
echo 📋 Connected devices:
adb devices

REM Check if emulator is ready
echo ✅ Checking emulator status...
adb shell getprop sys.boot_completed

echo.
echo 🎉 Ready to deploy Flutter app!
echo Run: flutter run -d emulator-5554
echo.

pause