# Flutter Golf Cart Computer

[![Flutter](https://img.shields.io/badge/Flutter-3.22%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9%2B-0175C2?logo=dart)](https://dart.dev)
[![Build](https://github.com/mikemyers/flutter-golf-cart-computer/actions/workflows/ci.yml/badge.svg)](https://github.com/mikemyers/flutter-golf-cart-computer/actions/workflows/ci.yml)

A cross-platform Flutter application that serves as the display computer for a golf cart telemetry, mesh messaging, and navigation system. This is a port of the native Android Golf Cart Display Computer (GCD) targeting both Android and iOS.

## Overview

The Flutter Golf Cart Computer is part of a three-component golf cart ecosystem designed for The Villages Retirement Community:

- **GCM (Golf Cart Meshtastic)** — A Meshtastic radio providing mesh messaging, GPS, and data relay
- **GCD (Golf Cart Display)** — The display computer application (this Flutter app)
- **GCI (Golf Cart Internal)** — An ESP-32 central computer providing vehicle telemetry over Bluetooth

The app maintains two simultaneous Bluetooth connections: one to the Meshtastic radio (BLE) for mesh messaging and one to the GCI telemetry computer for vehicle data (battery voltage, fuel level, temperature, headlight status).

## Features

- Real-time GPS speed, heading, and position display
- Meshtastic mesh network text messaging
- Weather forecast reception and display via HoT packets
- Venue/event entertainment schedule display
- Vehicle telemetry monitoring (battery, fuel, temperature)
- Odometer and trip distance tracking
- Service hour reminder system
- Home location geofencing with behavior adjustments
- Automatic display brightness management (day/night)
- Power and sleep management
- Cross-platform BLE and Bluetooth Classic support

## Setup Instructions

### Prerequisites

- Flutter SDK 3.22.0 or later
- Dart SDK 3.9.0 or later
- Android Studio or Xcode (for platform builds)
- `protoc` compiler with `protoc-gen-dart` plugin (for protobuf generation)

### Getting Started

```bash
# Clone the repository
git clone https://github.com/mikemyers/flutter-golf-cart-computer.git
cd flutter-golf-cart-computer

# Install dependencies
flutter pub get

# Generate protobuf Dart classes
make proto
# or: ./scripts/generate_protos.sh

# Run static analysis
flutter analyze

# Run tests
flutter test

# Run the app
flutter run
```

## Architecture

The project follows a four-layer architecture:

```
lib/
├── presentation/   # Flutter widgets and screens (UI)
├── application/    # Riverpod state notifiers and controllers
├── domain/         # Pure business logic and models
└── data/           # Repositories, services, and platform APIs
```

| Layer | Responsibility | Key Technologies |
|-------|---------------|-----------------|
| **Presentation** | Render state, capture user input | Flutter Widgets, Material 3 |
| **Application** | State management, coordinate domain logic | Riverpod StateNotifier/AsyncNotifier |
| **Domain** | Pure business logic, algorithms | Plain Dart classes |
| **Data** | External communication, persistence | flutter_blue_plus, geolocator, protobuf, hive |

State management uses **Riverpod** for compile-time safe dependency injection and reactive state propagation.

## Platform Build Notes

### Android

- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34
- Requires Bluetooth and Location permissions in AndroidManifest.xml
- Uses foreground service for background Bluetooth connectivity
- Supports Bluetooth Classic SPP for GCI connection (preferred over BLE)

### iOS

- Minimum deployment target: iOS 13.0
- Requires `NSBluetoothAlwaysUsageDescription` and `NSLocationWhenInUseUsageDescription` in Info.plist
- Declares `bluetooth-central` and `location` background modes
- Uses BLE for both Meshtastic and GCI connections

## Documentation

| Document | Description |
|----------|-------------|
| [docs/README.md](docs/README.md) | Documentation index with links to all docs |
| [docs/about.md](docs/about.md) | Application purpose, audience, and capabilities |
| [docs/build-guide.md](docs/build-guide.md) | Prerequisites, setup, protobuf generation, troubleshooting |
| [docs/design.md](docs/design.md) | Architecture overview, component interactions, data flow |
| [docs/developer-guide.md](docs/developer-guide.md) | Code organization, conventions, adding features, testing |
| [docs/features.md](docs/features.md) | All features listed by functional category |
| [docs/future-ideas.md](docs/future-ideas.md) | Planned enhancements and future development ideas |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for coding standards, branch naming conventions, and the PR process.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a history of notable changes.
