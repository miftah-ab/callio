<div align="center">

# 📱 Callio

**The Intelligent, Privacy-First Auto-Reply Engine for Modern Professionals.**

[![Build Status](https://github.com/miftah-ab/callio/actions/workflows/build.yml/badge.svg)](https://github.com/miftah-ab/callio/actions/workflows/build.yml)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)]()
[![Flutter](https://img.shields.io/badge/Made_with-Flutter-blue.svg)]()
[![Privacy](https://img.shields.io/badge/Privacy-100%25_Offline-brightgreen.svg)]()

</div>

---

## 🚀 Mission

In today’s hyper-connected world, missing a call often means missing an opportunity or leaving a loved one anxious. **Callio** bridges the gap. It is a highly optimized, intelligent Android application that automatically dispatches personalized SMS replies to missed calls—keeping you connected without breaking your focus.

Built for scale, speed, and uncompromising privacy.

---

## ✨ Enterprise-Grade Features

* 🧠 **Intelligent Rules Engine**: Dynamically route responses based on who is calling. (e.g., Send "I'm in a meeting" to your Boss, but "Driving right now" to your Family).
* 🔋 **Zero Battery Drain**: Leveraging Android's native `ForegroundService` and `TelephonyManager`, Callio detects missed calls instantly with near-zero impact on battery life.
* ⏱️ **Precision Scheduling**: Configure delays. Send replies instantly, or wait 5 minutes to simulate a manual response.
* 🛡️ **100% Offline Privacy**: No telemetry. No cloud syncing. No ads. Your call logs, contacts, and SMS records never leave your device.
* 🎨 **Material Design 3**: A stunning, fluid user interface built on Flutter's dynamic theming engine.

---

## 🏗️ Architecture & Tech Stack

Callio is engineered using **Clean Architecture** principles, ensuring modularity, testability, and scalability.

- **UI & Presentation**: Flutter / Dart
- **Native Android Backbone**: Kotlin, Android SDK, BroadcastReceivers
- **State Management**: Riverpod
- **Dependency Injection**: GetIt
- **Local Storage**: 
  - `sqflite` (Relational data: Rules, Templates, Logs)
  - `Hive` (Fast key-value pairs: User preferences)
- **CI/CD**: Fully automated Cloud Builds via GitHub Actions.

---

## 🛠️ Build & Installation

Callio leverages a modern **Cloud Build** pipeline. You do not need the heavy Flutter SDK installed locally to compile this application.

### Method 1: Cloud Build (Recommended)
1. Fork or clone this repository.
2. Push your changes to the `main` branch.
3. Navigate to the **Actions** tab in GitHub.
4. Download the generated `app-release.apk` artifact and install it directly on your Android device.

### Method 2: Local Development
Ensure you have the Flutter SDK (>= 3.24.0) and Android Studio installed.

```bash
# Clone the repository
git clone https://github.com/miftah-ab/callio.git

# Navigate to the directory
cd callio

# Install dependencies
flutter pub get

# Run the app on your connected device
flutter run
```

---

## 🔒 Security & Permissions

Because Callio integrates deeply with the device's communication layer, it strictly requests only the permissions it needs to function:
- `READ_PHONE_STATE`: To detect when a call transitions from ringing to idle.
- `SEND_SMS`: To dispatch the automated templates.
- `FOREGROUND_SERVICE`: To ensure the Android OS does not kill the listener while your phone is locked.

---

<div align="center">
  <sub>Built with ❤️ by Miftah.</sub>
</div>
