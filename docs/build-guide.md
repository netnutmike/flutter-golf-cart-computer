# Build Guide

This guide covers everything needed to build and run the Flutter Golf Cart Computer application on both Android and iOS platforms.

## Prerequisites

Before building the project, ensure you have the following software installed:

- **Flutter SDK** 3.22 or later (stable channel)
- **Dart SDK** 3.4 or later (bundled with Flutter)
- **Android Studio** 2024.1+ with Android SDK 34 (for Android builds)
- **Xcode** 15.0+ with iOS 17 SDK (for iOS builds, macOS only)
- **CocoaPods** 1.14+ (for iOS dependency management)
- **Protocol Buffers compiler** (`protoc`) 3.21+ with the Dart plugin (`protoc-gen-dart`)
- **Git** 2.30+
- **Java Development Kit** 17 (required by Android Gradle)

### Platform-Specific Requirements

**Android:**
- Minimum SDK version: 21 (Android 5.0 Lollipop)
- Target SDK version: 34 (Android 14)
- Bluetooth and Location permissions configured in AndroidManifest.xml

**iOS:**
- Minimum deployment target: iOS 14.0
- Background modes: `bluetooth-central`, `location`
- Privacy descriptions for Bluetooth and Location in Info.plist

## Environment Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/flutter-golf-cart-computer.git
cd flutter-golf-cart-computer
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 3: Verify Flutter Environment

```bash
flutter doctor -v
```

Ensure all checkmarks pass for your target platform (Android and/or iOS).

### Step 4: iOS Setup (macOS only)

```bash
cd ios
pod install
cd ..
```

### Step 5: Android Setup

Open the project in Android Studio and let Gradle sync complete. Alternatively:

```bash
cd android
./gradlew assembleDebug
cd ..
```

## Protobuf Code Generation

The application uses Protocol Buffers for Meshtastic radio communication. Generated Dart classes must be regenerated whenever `.proto` files change.

### Installing protoc-gen-dart

```bash
dart pub global activate protoc_plugin
```

Ensure `~/.pub-cache/bin` is in your PATH.

### Generating Dart Classes

Run the generation script from the project root:

```bash
make proto
```

Or manually:

```bash
protoc --dart_out=lib/data/generated/ \
  -Iproto/ \
  proto/mesh.proto \
  proto/admin.proto \
  proto/config.proto \
  proto/portnums.proto \
  proto/telemetry.proto \
  proto/module_config.proto \
  proto/channel.proto
```

Generated files are placed in `lib/data/generated/` and should be committed to the repository so that contributors without `protoc` installed can still build the project.

### Updating Proto Files

When Meshtastic releases updated `.proto` definitions:

1. Download the new `.proto` files from the Meshtastic repository
2. Place them in the `proto/` directory
3. Run `make proto` to regenerate Dart classes
4. Run `flutter analyze` to check for breaking changes
5. Update any affected service code

## Running the Application

### Debug Mode

```bash
flutter run
```

### Release Mode

```bash
flutter run --release
```

### Specific Device

```bash
flutter devices          # List available devices
flutter run -d <device>  # Run on specific device
```

## Building Release Artifacts

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS Archive

```bash
flutter build ios --release
```

Then archive via Xcode for App Store distribution.

## Troubleshooting

### Issue: `protoc-gen-dart` not found

**Symptom:** Running `make proto` fails with "protoc-gen-dart: program not found"

**Solution:** Ensure the Dart pub cache bin directory is in your PATH:
```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```
Add this line to your shell profile (`.bashrc`, `.zshrc`, etc.) for persistence.

### Issue: iOS pod install fails with version conflicts

**Symptom:** `pod install` reports version conflicts for flutter_blue_plus or geolocator

**Solution:** Clear the CocoaPods cache and reinstall:
```bash
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..
```

If the issue persists, try `flutter clean` followed by `flutter pub get` before re-running pod install.

### Issue: Android Gradle sync fails with JDK version error

**Symptom:** Gradle reports incompatible Java version or cannot find JDK 17

**Solution:** Set the JAVA_HOME environment variable to point to JDK 17:
```bash
export JAVA_HOME=/path/to/jdk-17
```
In Android Studio, go to Settings → Build → Gradle and set the Gradle JDK to version 17.

### Issue: BLE permissions not granted on Android 12+

**Symptom:** App crashes or BLE scanning fails on Android 12 (API 31) or later

**Solution:** Android 12 introduced new Bluetooth permissions (`BLUETOOTH_CONNECT`, `BLUETOOTH_SCAN`). Ensure these are declared in `AndroidManifest.xml` and requested at runtime before any BLE operations. The app handles this via the permission_handler package, but if testing on a fresh install, grant permissions when prompted.

### Issue: Flutter analyze reports generated protobuf warnings

**Symptom:** `flutter analyze` shows warnings in `lib/data/generated/` files

**Solution:** Generated protobuf files may trigger lint warnings. These are excluded from analysis via `analysis_options.yaml`:
```yaml
analyzer:
  exclude:
    - lib/data/generated/**
```
