#!/bin/bash

# ADB Connection Script for Docker Android Emulator

echo "🔌 Connecting to Docker Android Emulator..."

# Check if Docker container is running
if ! docker ps | grep -q "pmemo-android-emulator"; then
    echo "❌ Android emulator container is not running."
    echo "Please start it first with: ./scripts/run-android.sh"
    exit 1
fi

# Get container IP
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pmemo-android-emulator)

echo "📱 Container IP: $CONTAINER_IP"

# Connect ADB to the emulator
echo "🔗 Connecting ADB..."
adb connect $CONTAINER_IP:5555

# Wait a moment for connection
sleep 3

# Show connected devices
echo "📋 Connected devices:"
adb devices

# Check if emulator is ready
echo "✅ Checking emulator status..."
adb shell getprop sys.boot_completed

echo "🎉 Ready to deploy Flutter app!"
echo "Run: flutter run -d emulator-5554"