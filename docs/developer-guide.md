# Developer Guide

This guide provides practical information for developers working on the Flutter Golf Cart Computer codebase, including code organization, conventions, protocols, and testing practices.

## Code Organization

The project follows a four-layer architecture with a clear folder structure:

```
lib/
├── application/          # Riverpod notifiers and providers
│   ├── providers.dart    # Central provider definitions
│   ├── main_notifier.dart
│   ├── weather_notifier.dart
│   ├── entertainment_notifier.dart
│   ├── config_notifier.dart
│   ├── connection_notifier.dart
│   └── permission_manager.dart
├── domain/               # Pure business logic (no framework deps)
│   ├── models/           # Data classes and enums
│   ├── gps_processor.dart
│   ├── speed_filter.dart
│   ├── odometer_manager.dart
│   ├── service_reminder_manager.dart
│   ├── hot_packet_parser.dart
│   ├── sleep_manager.dart
│   ├── brightness_manager.dart
│   ├── geofence_manager.dart
│   └── audio_service.dart
├── data/                 # External communication and persistence
│   ├── services/         # Bluetooth, GPS, background
│   ├── repositories/     # Persistence (preferences, cache)
│   └── generated/        # Protobuf-generated Dart classes
└── presentation/         # Flutter widgets and screens
    ├── screens/          # Full-screen widgets
    ├── widgets/          # Reusable UI components
    └── theme/            # Material 3 theming

test/
├── unit/
│   ├── domain/           # Domain logic unit tests
│   └── data/             # Data layer unit tests
├── property/             # Property-based tests (glados)
├── widget/               # Widget tests
└── integration/          # Integration tests
```

## Naming Conventions

### Files and Directories

- Use `snake_case` for all Dart files: `speed_filter.dart`, `gps_processor.dart`
- Use `snake_case` for directories: `domain/models/`
- Test files mirror source files with `_test` suffix: `speed_filter_test.dart`
- Property test files use `_property_test` suffix: `speed_filter_property_test.dart`

### Dart Code

- Classes: `PascalCase` — `SpeedFilter`, `MeshtasticService`
- Methods and variables: `camelCase` — `processRawPosition`, `filteredSpeed`
- Constants: `camelCase` — `maxReconnectAttempts`, `heartbeatInterval`
- Enums: `PascalCase` for type, `camelCase` for values — `ConnectionState.connecting`
- Private members: prefix with underscore — `_lastSpeed`, `_processPacket()`
- Providers: `camelCase` with `Provider` suffix — `meshtasticServiceProvider`

### Riverpod Providers

- Data layer providers: `<serviceName>Provider` — `meshtasticServiceProvider`
- Domain providers: `<managerName>Provider` — `geofenceManagerProvider`
- Application providers: `<notifierName>Provider` — `mainNotifierProvider`

## Adding a New Feature

Follow these steps when adding a new feature to the application:

### Step 1: Define Domain Models

Create data classes in `lib/domain/models/` for any new data types. Use immutable classes with `copyWith` methods for state updates.

### Step 2: Implement Domain Logic

Write the core business logic in `lib/domain/`. Domain classes should have no Flutter or plugin dependencies — only pure Dart. This ensures they are fully testable without mocks.

### Step 3: Add Data Layer Support

If the feature requires external communication or persistence, add services or repository methods in `lib/data/`. Define abstract interfaces and concrete implementations.

### Step 4: Create Application Notifier

Add a Riverpod notifier in `lib/application/` that coordinates the domain logic and data layer. Register the provider in `providers.dart`.

### Step 5: Build Presentation Widgets

Create screen and widget files in `lib/presentation/`. Widgets should only read from providers and call notifier methods — no business logic in widgets.

### Step 6: Write Tests

Write unit tests for domain logic, property-based tests for algorithmic correctness, and widget tests for UI behavior.

## Bluetooth Communication Protocols

### Meshtastic BLE Protocol

The Meshtastic radio communicates via BLE using a specific GATT service:

- **Service UUID:** `6ba1b218-15a8-461f-9fa8-5dcae273eafd`
- **TORADIO (write):** `f75c76d2-129e-4dad-a1dd-7866124401e7`
- **FROMRADIO (read):** `2c55e69e-4993-11ed-b878-0242ac120002`
- **FROMNUM (notify):** `ed9da18c-a800-4f66-a670-aa7547e34453`

**Packet framing:** All messages are prefixed with a 4-byte big-endian length header before the protobuf payload. Packets exceeding the negotiated MTU are split into chunks of (MTU - 3) bytes.

**Connection handshake:**
1. Subscribe to FROMNUM notifications
2. Send `ToRadio(want_config_id=<random_id>)`
3. Read FROMRADIO responses: `my_info` → `config` messages → `config_complete_id`
4. Enter steady-state operation with 30-second heartbeat

**Reconnection:** Exponential backoff starting at 2 seconds, doubling up to 60 seconds, maximum 10 attempts.

### GCI Telemetry Protocol

The GCI ESP-32 uses a custom binary protocol with a 9-byte message envelope:

```
| type (1 byte) | timestamp (4 bytes LE) | seq_num (2 bytes LE) | data_len (2 bytes LE) | payload |
```

**Message types:** TEXT(0), GPS_DATA(1), TELEMETRY(2), COMMAND(3), ACK(4), HEARTBEAT(5), IS_HOME(6), IS_DAYTIME(7)

**Telemetry payload (20 bytes, little-endian from GCI):**
- modeLights (int32), outdoorLum (int32), airTemp (float32), battVolts (float32), fuel (float32)

**GPS payload (24 bytes, little-endian to GCI):**
- latitude (float64), longitude (float64), altitude (float32), speed (float32), heading (float32), satelliteCount (int32... packed)

## Protobuf Message Formats

Key Meshtastic protobuf messages:

| Message | Direction | Usage |
|---------|-----------|-------|
| `ToRadio` | App → Radio | Wrapper for all outbound messages |
| `FromRadio` | Radio → App | Wrapper for all inbound messages |
| `MeshPacket` | Both | Individual mesh network packet |
| `Data` | Both | Decoded payload within MeshPacket |
| `AdminMessage` | App → Radio | Radio administration commands |

**Port numbers:** TEXT_MESSAGE_APP(1), POSITION_APP(3), ADMIN_APP(6), TELEMETRY_APP(67)

## Testing

### Running Tests

```bash
flutter test                          # All tests
flutter test test/unit/               # Unit tests only
flutter test test/property/           # Property tests only
flutter test --coverage               # With coverage report
```

### Property-Based Testing with Glados

Property tests use the `glados` package to verify correctness properties across many random inputs. These tests validate algorithmic invariants rather than specific examples.

```dart
Glados<int>().test('speed below threshold maps to zero', (rawSpeed) {
  assume(rawSpeed >= 0 && rawSpeed < 250); // centimph
  final result = filter.filter(rawSpeed / 100.0, 1.0);
  if (rawSpeed < 250) {
    expect(result.filteredSpeedMph, equals(0));
  }
});
```

### Mocking with Mocktail

Use `mocktail` for mocking data layer dependencies in application layer tests:

```dart
class MockMeshtasticService extends Mock implements MeshtasticService {}
```

### Debugging Tips

- **BLE issues:** Enable verbose logging in flutter_blue_plus with `FlutterBluePlus.setLogLevel(LogLevel.verbose)`
- **Protobuf errors:** Check that generated classes match the proto file versions; regenerate with `make proto`
- **State issues:** Use Riverpod's `ProviderObserver` to log all state changes during development
- **GPS simulation:** Use Android Studio's emulator GPS controls or Xcode's location simulation for testing without physical movement
- **GCI protocol:** Use a serial monitor on the ESP-32 to verify message framing matches expectations
