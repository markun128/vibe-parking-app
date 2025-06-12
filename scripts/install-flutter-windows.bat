@echo off
REM Flutter SDK Auto-installer for Windows

echo 🚀 Flutter SDK Auto-installer for P-Memo

setlocal enabledelayedexpansion

REM Set Flutter installation directory
set FLUTTER_DIR=C:\flutter
set FLUTTER_VERSION=3.19.6

echo.
echo This script will:
echo - Download Flutter SDK %FLUTTER_VERSION%
echo - Extract to %FLUTTER_DIR%
echo - Add to PATH environment variable
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ⚠️  Administrator privileges recommended for PATH modification.
    echo   Right-click and "Run as administrator" for automatic PATH setup.
    echo.
)

REM Check if Flutter directory already exists
if exist "%FLUTTER_DIR%" (
    echo ⚠️  Flutter directory already exists at %FLUTTER_DIR%
    echo.
    choice /C YN /M "Do you want to reinstall Flutter? (Y/N)"
    if errorlevel 2 goto :check_path
    if errorlevel 1 (
        echo 🗑️  Removing existing Flutter installation...
        rmdir /s /q "%FLUTTER_DIR%" 2>nul
    )
)

REM Create Flutter directory
echo 📁 Creating Flutter directory...
mkdir "%FLUTTER_DIR%" 2>nul

REM Check if we have curl or powershell
where curl >nul 2>&1
if %errorlevel% equ 0 (
    set DOWNLOADER=curl
) else (
    set DOWNLOADER=powershell
)

REM Download Flutter SDK
echo 📥 Downloading Flutter SDK %FLUTTER_VERSION%...
echo    This may take several minutes depending on your internet connection.

if "%DOWNLOADER%"=="curl" (
    curl -L -o "%TEMP%\flutter_windows.zip" "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_%FLUTTER_VERSION%-stable.zip"
) else (
    powershell -Command "& {Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_%FLUTTER_VERSION%-stable.zip' -OutFile '%TEMP%\flutter_windows.zip'}"
)

if not exist "%TEMP%\flutter_windows.zip" (
    echo ❌ Failed to download Flutter SDK.
    echo Please check your internet connection and try again.
    pause
    exit /b 1
)

echo ✅ Download completed!

REM Extract Flutter SDK
echo 📦 Extracting Flutter SDK...
powershell -Command "& {Expand-Archive -Path '%TEMP%\flutter_windows.zip' -DestinationPath 'C:\' -Force}"

if not exist "%FLUTTER_DIR%\bin\flutter.bat" (
    echo ❌ Failed to extract Flutter SDK.
    pause
    exit /b 1
)

echo ✅ Flutter SDK extracted successfully!

REM Clean up
del "%TEMP%\flutter_windows.zip" 2>nul

:check_path
REM Check if Flutter is in PATH
echo 🔍 Checking PATH environment variable...

echo %PATH% | findstr /i "flutter" >nul
if %errorlevel% equ 0 (
    echo ✅ Flutter is already in PATH
    goto :verify
)

REM Add Flutter to PATH
echo 🛠️  Adding Flutter to PATH...

REM Try to add to system PATH (requires admin)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "%PATH%;%FLUTTER_DIR%\bin" /f >nul 2>&1

if %errorlevel% equ 0 (
    echo ✅ Added Flutter to system PATH
    set "PATH=%PATH%;%FLUTTER_DIR%\bin"
) else (
    REM Add to user PATH if system PATH failed
    echo ⚠️  Adding to user PATH (system PATH requires administrator privileges)
    
    for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USER_PATH=%%b"
    if "!USER_PATH!"=="" set "USER_PATH=%FLUTTER_DIR%\bin"
    if not "!USER_PATH!"=="" set "USER_PATH=!USER_PATH!;%FLUTTER_DIR%\bin"
    
    reg add "HKCU\Environment" /v Path /t REG_EXPAND_SZ /d "!USER_PATH!" /f >nul
    
    if !errorlevel! equ 0 (
        echo ✅ Added Flutter to user PATH
        set "PATH=%PATH%;%FLUTTER_DIR%\bin"
    ) else (
        echo ❌ Failed to add Flutter to PATH automatically.
        echo.
        echo Please manually add %FLUTTER_DIR%\bin to your PATH:
        echo 1. Press Win + R, type "sysdm.cpl" and press Enter
        echo 2. Click "Environment Variables"
        echo 3. Under "User variables", find and select "Path", then click "Edit"
        echo 4. Click "New" and add: %FLUTTER_DIR%\bin
        echo 5. Click "OK" to close all dialogs
        echo 6. Restart command prompt
        pause
        exit /b 1
    )
)

:verify
REM Refresh environment variables for current session
set "PATH=%PATH%;%FLUTTER_DIR%\bin"

REM Verify Flutter installation
echo 🔍 Verifying Flutter installation...
"%FLUTTER_DIR%\bin\flutter.bat" --version

if %errorlevel% neq 0 (
    echo ❌ Flutter verification failed.
    pause
    exit /b 1
)

echo.
echo ✅ Flutter SDK installation completed successfully!
echo.
echo 📋 Next steps:
echo 1. Restart your command prompt to refresh PATH
echo 2. Run: flutter doctor
echo 3. Run: scripts\setup-windows.bat
echo 4. Run: scripts\run-web-windows.bat
echo.
echo 🎉 You're ready to develop with Flutter!

pause