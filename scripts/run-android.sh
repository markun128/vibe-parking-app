#!/bin/bash

# Android Emulator Runner Script for P-Memo

echo "🚀 Starting Android Emulator for P-Memo..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Build Docker image
echo "🔨 Building Docker image..."
docker-compose build

# Start the Android emulator
echo "📱 Starting Android emulator..."
docker-compose up -d

# Wait for container to be ready
echo "⏳ Waiting for emulator to start..."
sleep 30

# Show container logs
echo "📋 Container logs:"
docker-compose logs -f android-emulator

# Function to cleanup on exit
cleanup() {
    echo "🧹 Cleaning up..."
    docker-compose down
}

# Set trap for cleanup
trap cleanup EXIT

# Keep script running
while true; do
    sleep 10
done