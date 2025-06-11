# Android Flutter Development Environment with Emulator
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=$ANDROID_HOME
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$PATH:$FLUTTER_HOME/bin
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk \
    wget \
    qemu-kvm \
    bridge-utils \
    cpu-checker \
    x11-xserver-utils \
    xvfb \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libpulse0 \
    libasound2 \
    libasound2-plugins \
    && rm -rf /var/lib/apt/lists/*

# Create android user
RUN useradd -m -s /bin/bash android && \
    usermod -aG kvm android

# Install Android SDK
RUN mkdir -p $ANDROID_HOME && \
    cd $ANDROID_HOME && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip commandlinetools-linux-9477386_latest.zip && \
    rm commandlinetools-linux-9477386_latest.zip && \
    mkdir -p cmdline-tools/latest && \
    mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true && \
    chown -R android:android $ANDROID_HOME

# Install Flutter
RUN cd /opt && \
    wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.6-stable.tar.xz && \
    tar xf flutter_linux_3.19.6-stable.tar.xz && \
    rm flutter_linux_3.19.6-stable.tar.xz && \
    chown -R android:android $FLUTTER_HOME

# Switch to android user
USER android

# Accept Android licenses and install SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0" && \
    sdkmanager "system-images;android-33;google_apis;x86_64" && \
    sdkmanager "emulator"

# Create AVD (Android Virtual Device)
RUN echo "no" | avdmanager create avd \
    -n "Pixel_6_API_33" \
    -k "system-images;android-33;google_apis;x86_64" \
    -d "pixel_6"

# Set working directory
WORKDIR /app

# Copy Flutter project
COPY --chown=android:android . .

# Get Flutter dependencies
RUN flutter pub get

# Expose ports
EXPOSE 5554 5555 8080

# Create startup script
RUN echo '#!/bin/bash\n\
export DISPLAY=:99\n\
Xvfb :99 -screen 0 1024x768x16 &\n\
echo "Starting Android Emulator..."\n\
emulator -avd Pixel_6_API_33 -no-audio -no-window -gpu swiftshader_indirect -no-snapshot -wipe-data &\n\
sleep 30\n\
echo "Waiting for emulator to be ready..."\n\
adb wait-for-device\n\
sleep 10\n\
echo "Emulator is ready!"\n\
flutter devices\n\
echo "Starting Flutter app..."\n\
flutter run -d emulator-5554\n\
' > /home/android/start.sh && chmod +x /home/android/start.sh

CMD ["/home/android/start.sh"]