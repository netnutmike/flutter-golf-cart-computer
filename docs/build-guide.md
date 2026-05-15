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
- Bluetooth Classic SPP support for GCI telemetry connection
- Foreground service support for background Bluetooth connectivity

**iOS:**
- Minimum deployment target: iOS 14.0
- Background modes: `bluetooth-central`, `location`
- Privacy descriptions for Bluetooth and Location in Info.plist
- BLE-only communication (no Bluetooth Classic on iOS)
- Xcode command line tools installed (`xcode-select --install`)

### Hardware for Testing

While the app can be developed and tested in simulators/emulators for UI work, full integration testing requires:

- A Meshtastic-compatible LoRa radio (T-Beam, RAK WisBlock, or similar) with firmware 2.x
- A GCI ESP-32 telemetry computer (or a BLE peripheral simulator for protocol testing)
- A physical Android or iOS device with Bluetooth support (emulators do not support BLE)

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

This installs all packages defined in `pubspec.yaml` including:
- `flutter_riverpod` — state management
- `flutter_blue_plus` — BLE communication
- `geolocator` — GPS access
- `protobuf` — Protocol Buffer runtime
- `shared_preferences` — settings persistence
- `hive` / `hive_flutter` — binary data caching
- `permission_handler` — cross-platform permissions
- `audioplayers` — audio feedback

### Step 3: Verify Flutter Environment

```bash
flutter doctor -v
```

Ensure all checkmarks pass for your target platform (Android and/or iOS). Common issues:
- Missing Android SDK licenses: run `flutter doctor --android-licenses`
- Missing iOS simulator: install via Xcode → Preferences → Platforms
- Outdated Flutter: run `flutter upgrade`

### Step 4: iOS Setup (macOS only)

```bash
cd ios
pod install
cd ..
```

If you encounter CocoaPods version issues, update first:
```bash
gem install cocoapods
```

For Apple Silicon Macs, you may need:
```bash
cd ios
arch -x86_64 pod install
cd ..
```

### Step 5: Android Setup

Open the project in Android Studio and let Gradle sync complete. Alternatively:

```bash
cd android
./gradlew assembleDebug
cd ..
```

Ensure you have accepted all Android SDK licenses:
```bash
flutter doctor --android-licenses
```

### Step 6: Verify the Build

Run a quick build verification to ensure everything is configured correctly:

```bash
flutter analyze
flutter test
```

Both commands should complete without errors before you begin development.

## Protobuf Code Generation

The application uses Protocol Buffers for Meshtastic radio communication. Generated Dart classes must be regenerated whenever `.proto` files change.

### Installing protoc

**macOS (Homebrew):**
```bash
brew install protobuf
```

**Linux (apt):**
```bash
sudo apt install protobuf-compiler
```

**Manual installation:**
Download from the [Protocol Buffers releases page](https://github.com/protocolbuffers/protobuf/releases) and add to your PATH.

### Installing protoc-gen-dart

```bash
dart pub global activate protoc_plugin
```

Ensure `~/.pub-cache/bin` is in your PATH. Add to your shell profile:
```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

Verify the installation:
```bash
protoc-gen-dart --version
```

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

1. Download the new `.proto` files from the [Meshtastic protobufs repository](https://github.com/meshtastic/protobufs)
2. Place them in the `proto/` directory, replacing existing files
3. Run `make proto` to regenerate Dart classes
4. Run `flutter analyze` to check for breaking changes in the generated code
5. Update any affected service code (particularly `MeshtasticService` and `ConnectionNotifier`)
6. Run the full test suite to verify nothing is broken
7. Commit both the updated `.proto` files and the regenerated Dart classes

## Running the Application

### Debug Mode

```bash
flutter run
```

Debug mode includes hot reload support, debug assertions, and the Flutter DevTools connection. This is the recommended mode for development.

### Release Mode

```bash
flutter run --release
```

Release mode compiles with optimizations and removes debug overhead. Use this for performance testing and final verification before building release artifacts.

### Profile Mode

```bash
flutter run --profile
```

Profile mode enables the performance overlay and timeline recording while maintaining near-release performance. Use this for identifying frame drops and performance bottlenecks.

### Specific Device

```bash
flutter devices          # List available devices
flutter run -d <device>  # Run on specific device
```

Common device identifiers:
- Physical Android: device serial number (from `adb devices`)
- Physical iOS: device UDID
- Android emulator: `emulator-5554`
- iOS simulator: simulator name (e.g., `iPhone 15 Pro`)

### Running with Verbose Logging

For debugging Bluetooth and GPS issues:
```bash
flutter run --verbose
```

## Building Release Artifacts

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

For a split APK (smaller download per architecture):
```bash
flutter build apk --split-per-abi --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

This is the preferred format for Google Play Store distribution.

### iOS Archive

```bash
flutter build ios --release
```

Then archive via Xcode for App Store distribution:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Product → Archive
3. Follow the distribution workflow in the Organizer

### Side-loading on Android

For direct installation without the Play Store:
```bash
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Continuous Integration

The project includes a GitHub Actions CI workflow (`.github/workflows/ci.yml`) that runs on every pull request:

1. `flutter pub get` — install dependencies
2. `flutter analyze` — static analysis
3. `flutter test` — run all tests

The CI environment uses the latest stable Flutter SDK. Ensure your local Flutter version matches or is newer than the CI version to avoid compatibility issues.

## Troubleshooting

### Issue: `protoc-gen-dart` not found

**Symptom:** Running `make proto` fails with "protoc-gen-dart: program not found"

**Solution:** Ensure the Dart pub cache bin directory is in your PATH:
```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```
Add this line to your shell profile (`.bashrc`, `.zshrc`, etc.) for persistence. Then verify:
```bash
which protoc-gen-dart
```

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

If the issue persists, try `flutter clean` followed by `flutter pub get` before re-running pod install. On Apple Silicon Macs, ensure you're using the correct architecture:
```bash
cd ios
arch -x86_64 pod install
cd ..
```

### Issue: Android Gradle sync fails with JDK version error

**Symptom:** Gradle reports incompatible Java version or cannot find JDK 17

**Solution:** Set the JAVA_HOME environment variable to point to JDK 17:
```bash
export JAVA_HOME=/path/to/jdk-17
```

On macOS with Homebrew:
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

In Android Studio, go to Settings → Build → Gradle and set the Gradle JDK to version 17.

### Issue: BLE permissions not granted on Android 12+

**Symptom:** App crashes or BLE scanning fails on Android 12 (API 31) or later

**Solution:** Android 12 introduced new Bluetooth permissions (`BLUETOOTH_CONNECT`, `BLUETOOTH_SCAN`). These are declared in `AndroidManifest.xml` and requested at runtime via the `permission_handler` package. If testing on a fresh install:
1. Grant all Bluetooth permissions when prompted
2. Grant location permission (required for BLE scanning on Android)
3. If permissions were previously denied, go to Settings → Apps → Golf Cart Computer → Permissions and enable them manually

### Issue: Flutter analyze reports generated protobuf warnings

**Symptom:** `flutter analyze` shows warnings in `lib/data/generated/` files

**Solution:** Generated protobuf files may trigger lint warnings. These are excluded from analysis via `analysis_options.yaml`:
```yaml
analyzer:
  exclude:
    - lib/data/generated/**
```

If you see warnings in generated files, verify this exclusion is present.

### Issue: iOS build fails with "No signing certificate"

**Symptom:** Xcode reports code signing errors when building for a physical device

**Solution:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target → Signing & Capabilities
3. Select your development team
4. Ensure "Automatically manage signing" is checked
5. For CI builds, configure signing certificates in your CI environment

### Issue: GPS not working in emulator/simulator

**Symptom:** Location services return no data or fixed coordinates

**Solution:** Emulators and simulators provide simulated GPS:
- **Android Emulator:** Use the Extended Controls (three dots) → Location to set coordinates or simulate routes
- **iOS Simulator:** Use Features → Location to select a predefined location or custom coordinates
- **Note:** For testing real GPS behavior (satellite count, HDOP, signal loss), a physical device is required

### Issue: Bluetooth not available in emulator

**Symptom:** BLE scanning returns no devices or throws platform exceptions

**Solution:** Android emulators and iOS simulators do not support Bluetooth. For BLE testing:
- Use a physical device
- For unit/integration tests, use mocked BLE services (see the test infrastructure)
- Consider using a BLE peripheral simulator app on a second device for controlled testing

### Issue: Build fails after Flutter upgrade

**Symptom:** Various compilation errors after running `flutter upgrade`

**Solution:**
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter analyze
```

If errors persist, check the Flutter migration guides for breaking changes between versions.
