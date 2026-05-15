# Developer Guide

This guide provides practical information for developers working on the Flutter Golf Cart Computer codebase, including code organization, conventions, protocols, testing practices, and debugging techniques.

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

### Key Principles

- **Domain classes have zero Flutter dependencies.** They import only `dart:core`, `dart:math`, `dart:typed_data`, and other domain classes. This makes them trivially testable.
- **Data classes define abstract interfaces.** Concrete implementations can be swapped for mocks in tests without touching domain or application code.
- **Application notifiers are the coordination layer.** They subscribe to streams, invoke domain logic, and expose state. They're the only layer that knows about both domain and data.
- **Presentation widgets are thin.** They read providers, render state, and forward user actions to notifiers. No business logic in widgets.

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
- State classes: `PascalCase` with `State` suffix — `MainState`, `WeatherState`

### Riverpod Providers

- Data layer providers: `<serviceName>Provider` — `meshtasticServiceProvider`
- Domain providers: `<managerName>Provider` — `geofenceManagerProvider`
- Application providers: `<notifierName>Provider` — `mainNotifierProvider`
- Stream providers: `<streamName>StreamProvider` — `gpsPositionStreamProvider`

### Constants and Configuration

- Timing constants: descriptive names with units — `heartbeatIntervalSeconds`, `reconnectMaxDelayMs`
- Protocol constants: grouped in a class — `MeshtasticUuids.serviceUuid`, `GciProtocol.headerSize`
- Default values: prefixed with `default` — `defaultGeofenceRadius`, `defaultBrightnessDay`

## Adding a New Feature

Follow these steps when adding a new feature to the application:

### Step 1: Define Domain Models

Create data classes in `lib/domain/models/` for any new data types. Use immutable classes with `copyWith` methods for state updates:

```dart
class NewFeatureData {
  final int value;
  final String label;
  final DateTime timestamp;

  const NewFeatureData({
    required this.value,
    required this.label,
    required this.timestamp,
  });

  NewFeatureData copyWith({int? value, String? label, DateTime? timestamp}) {
    return NewFeatureData(
      value: value ?? this.value,
      label: label ?? this.label,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
```

### Step 2: Implement Domain Logic

Write the core business logic in `lib/domain/`. Domain classes should have no Flutter or plugin dependencies — only pure Dart. This ensures they are fully testable without mocks.

```dart
class NewFeatureProcessor {
  // Pure function — easy to test
  NewFeatureData process(RawInput input) {
    // Business logic here
  }
}
```

### Step 3: Add Data Layer Support

If the feature requires external communication or persistence, add services or repository methods in `lib/data/`. Define abstract interfaces and concrete implementations:

```dart
abstract class NewFeatureRepository {
  Future<void> save(NewFeatureData data);
  Future<NewFeatureData?> load();
}

class NewFeatureRepositoryImpl implements NewFeatureRepository {
  // Concrete implementation using Hive, shared_preferences, etc.
}
```

### Step 4: Create Application Notifier

Add a Riverpod notifier in `lib/application/` that coordinates the domain logic and data layer. Register the provider in `providers.dart`:

```dart
class NewFeatureNotifier extends StateNotifier<NewFeatureState> {
  final NewFeatureProcessor _processor;
  final NewFeatureRepository _repository;

  NewFeatureNotifier(this._processor, this._repository)
      : super(NewFeatureState.initial());

  Future<void> processInput(RawInput input) async {
    final result = _processor.process(input);
    await _repository.save(result);
    state = state.copyWith(data: result);
  }
}
```

### Step 5: Build Presentation Widgets

Create screen and widget files in `lib/presentation/`. Widgets should only read from providers and call notifier methods — no business logic in widgets:

```dart
class NewFeatureWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newFeatureNotifierProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt layout based on available space
        return Text(state.data.label);
      },
    );
  }
}
```

### Step 6: Write Tests

Write unit tests for domain logic, property-based tests for algorithmic correctness, and widget tests for UI behavior. See the Testing section below for details.

## Bluetooth Communication Protocols

### Meshtastic BLE Protocol

The Meshtastic radio communicates via BLE using a specific GATT service:

- **Service UUID:** `6ba1b218-15a8-461f-9fa8-5dcae273eafd`
- **TORADIO (write):** `f75c76d2-129e-4dad-a1dd-7866124401e7`
- **FROMRADIO (read):** `2c55e69e-4993-11ed-b878-0242ac120002`
- **FROMNUM (notify):** `ed9da18c-a800-4f66-a670-aa7547e34453`

**Packet framing:** All messages are prefixed with a 4-byte big-endian length header before the protobuf payload. The length encodes the payload size (not including the 4-byte prefix itself). Packets exceeding the negotiated MTU are split into chunks of (MTU - 3) bytes and written sequentially.

**Connection handshake sequence:**
1. Scan for devices matching name pattern `^.*_([0-9a-fA-F]{4})$` (10-second timeout)
2. Connect to device and discover services
3. Negotiate MTU (request maximum, accept whatever the peripheral grants)
4. Subscribe to FROMNUM notifications
5. Send `ToRadio(want_config_id=<random_uint32>)` — framed with 4-byte length prefix
6. Poll FROMRADIO until empty, processing responses:
   - `my_info` → extract and store local node number
   - `config` → store radio configuration (especially PositionConfig for GPS interval)
   - `config_complete_id` → verify matches sent `want_config_id`, handshake complete
7. Enter steady-state: 30-second heartbeat, poll FROMRADIO on each FROMNUM notification

**Reconnection strategy:**
- Exponential backoff: 2s → 4s → 8s → 16s → 32s → 60s (capped)
- Maximum 10 attempts before giving up
- Reset attempt counter on successful connection
- User can manually trigger reconnection from config screen

**Message routing by port number:**
| Port | Name | Handler |
|------|------|---------|
| 1 | TEXT_MESSAGE_APP | Message history + HoT packet check |
| 3 | POSITION_APP | GPS fallback data |
| 6 | ADMIN_APP | Admin command responses |
| 67 | TELEMETRY_APP | Node telemetry (battery, etc.) |
| Other | — | Discarded silently |

### GCI Telemetry Protocol

The GCI ESP-32 uses a custom binary protocol with a 9-byte message envelope:

```
┌──────────┬───────────────┬──────────────┬──────────────┬─────────────┐
│ type (1) │ timestamp (4) │ seq_num (2)  │ data_len (2) │ payload (N) │
│  uint8   │  uint32 LE    │  uint16 LE   │  uint16 LE   │  bytes      │
└──────────┴───────────────┴──────────────┴──────────────┴─────────────┘
```

**Message types:**

| Type | Name | Direction | Payload |
|------|------|-----------|---------|
| 0 | TEXT | Both | UTF-8 string |
| 1 | GPS_DATA | GCD → GCI | 24 bytes (lat, lon, alt, speed, heading, sats) |
| 2 | TELEMETRY | GCI → GCD | 20 bytes (lights, lum, temp, volts, fuel) |
| 3 | COMMAND | Both | Variable (command-specific) |
| 4 | ACK | Both | 0 bytes (acknowledgment) |
| 5 | HEARTBEAT | Both | 0 bytes (keepalive) |
| 6 | IS_HOME | GCD → GCI | 1 byte (0=away, 1=home) |
| 7 | IS_DAYTIME | GCD → GCI | 1 byte (0=night, 1=day) |

**Telemetry payload (20 bytes, little-endian, received from GCI):**
```
┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│ modeLights   │ outdoorLum   │ airTemp      │ battVolts    │ fuel         │
│ int32 (4B)   │ int32 (4B)   │ float32 (4B) │ float32 (4B) │ float32 (4B) │
└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘
```

**GPS payload (24 bytes, little-endian, sent to GCI):**
```
┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│ latitude     │ longitude    │ altitude     │ speed        │ heading      │ satellites   │
│ float64 (8B) │ float64 (8B) │ float32 (4B) │ float32 (4B) │ float32 (4B) │ int32 (4B)   │
└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘
```

Note: The satellite count is packed into the last 4 bytes. The total is 32 bytes but the protocol uses 24 bytes by packing altitude, speed, and heading into float32 and omitting the satellite field in some implementations. Check the actual GCI firmware for the current format.

**Connection management:**
- Android: Prefer Bluetooth Classic SPP; fall back to BLE if Classic fails
- iOS: BLE only (iOS does not expose Classic Bluetooth to third-party apps)
- Heartbeat: send every 10 seconds
- Timeout: 40 seconds (4 missed heartbeats) → mark disconnected
- Reconnection: exponential backoff, 2s start, 60s max
- Pairing: broadcast discovery with 6-second window, ACK handshake

### HoT Packet Format

HoT (Hands-off-Transmission) packets are structured data embedded in Meshtastic text messages, identified by a leading `|` character.

**Weather packet (type 01):**
```
|#01#<current_temp>#<hr>,<glyph>,<temp>,<precip>#<hr>,<glyph>,<temp>,<precip>#<hr>,<glyph>,<temp>,<precip>#<hr>,<glyph>,<temp>,<precip>#
```

Validation rules:
- Must start with `|#01#`
- Must contain exactly 7 `#` delimiters
- Must contain exactly 12 `,` delimiters
- Temperature: integer, range -99 to 999
- Hour label: ≤6 characters
- Precipitation: float, range 0.0 to 100.0 (0.0 displayed as empty string)
- Glyph: ≤10 characters

**Venue/event packet (type 02):**
```
|#02#<venue>,<event>#<venue>,<event>#...#
```

Validation rules:
- Must start with `|#02#`
- Each pair separated by `#`
- Venue and event separated by first `,` in each pair (subsequent commas are part of event name)
- Both venue and event must be non-empty
- Maximum 12 pairs displayed (extras discarded)

## Protobuf Message Formats

Key Meshtastic protobuf messages used by the application:

| Message | Direction | Usage |
|---------|-----------|-------|
| `ToRadio` | App → Radio | Wrapper for all outbound messages |
| `FromRadio` | Radio → App | Wrapper for all inbound messages |
| `MeshPacket` | Both | Individual mesh network packet |
| `Data` | Both | Decoded payload within MeshPacket |
| `AdminMessage` | App → Radio | Radio administration commands |
| `Position` | Radio → App | GPS position from radio |
| `Config` | Radio → App | Radio configuration during handshake |
| `MyNodeInfo` | Radio → App | Local node information |

**Outbound MeshPacket construction:**
```dart
final packet = MeshPacket()
  ..id = Random().nextInt(0xFFFFFFFF)  // Non-zero random ID (deduplication)
  ..to = destinationNodeNum            // 0xFFFFFFFF for broadcast
  ..channel = channelIndex             // 0-7
  ..decoded = (Data()
    ..portnum = PortNum.TEXT_MESSAGE_APP
    ..payload = utf8.encode(messageText));

final toRadio = ToRadio()..packet = packet;
final framedBytes = PacketFramer.frame(toRadio.writeToBuffer());
```

**Port numbers:** TEXT_MESSAGE_APP(1), POSITION_APP(3), ADMIN_APP(6), TELEMETRY_APP(67)

## Testing

### Running Tests

```bash
flutter test                          # All tests
flutter test test/unit/               # Unit tests only
flutter test test/property/           # Property tests only
flutter test test/widget/             # Widget tests only
flutter test --coverage               # With coverage report
flutter test --reporter expanded      # Verbose output
```

### Test Organization

Tests mirror the source structure:
- `test/unit/domain/speed_filter_test.dart` tests `lib/domain/speed_filter.dart`
- `test/property/speed_filter_property_test.dart` tests properties of `SpeedFilter`
- `test/widget/main_screen_test.dart` tests `lib/presentation/screens/main_screen.dart`

### Property-Based Testing with Glados

Property tests use the `glados` package to verify correctness properties across many random inputs. These tests validate algorithmic invariants rather than specific examples:

```dart
Glados<int>().test('speed below threshold maps to zero', (rawSpeed) {
  assume(rawSpeed >= 0 && rawSpeed < 250); // centimph
  final result = filter.filter(rawSpeed / 100.0, 1.0);
  if (rawSpeed < 250) {
    expect(result.filteredSpeedMph, equals(0));
  }
});

Glados2<List<int>, int>().test('frame then unframe is identity', (payload, _) {
  assume(payload.length <= 65535);
  final bytes = Uint8List.fromList(payload);
  final framed = PacketFramer.frame(bytes);
  final unframed = PacketFramer.unframe(framed);
  expect(unframed, equals(bytes));
});
```

Property tests are particularly valuable for:
- Packet framing round-trip (frame → unframe = identity)
- Speed filter invariants (below threshold → zero, spike rejection)
- Cardinal direction mapping (all bearings map to valid directions)
- Odometer accumulation (only when speed > 0, rollover at limits)
- Geofence hysteresis (no oscillation within band)

### Mocking with Mocktail

Use `mocktail` for mocking data layer dependencies in application layer tests:

```dart
class MockMeshtasticService extends Mock implements MeshtasticService {}
class MockPreferencesRepository extends Mock implements PreferencesRepository {}

void main() {
  late MockMeshtasticService mockService;
  late ConnectionNotifier notifier;

  setUp(() {
    mockService = MockMeshtasticService();
    when(() => mockService.connectionState)
        .thenAnswer((_) => Stream.value(BleConnectionState.connected));
    notifier = ConnectionNotifier(mockService);
  });
}
```

### Widget Testing

Widget tests verify UI behavior using Flutter's test framework:

```dart
testWidgets('displays speed from provider', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mainNotifierProvider.overrideWith(() => MockMainNotifier(
          MainState(speed: 15, heading: 'NNE'),
        )),
      ],
      child: MaterialApp(home: MainScreen()),
    ),
  );

  expect(find.text('15'), findsOneWidget);
  expect(find.text('NNE'), findsOneWidget);
});
```

### Test Helpers

Common test utilities are in `test/helpers/`:
- `test_helpers.dart` — shared setup, mock factories, test data generators
- `fake_bluetooth.dart` — fake BLE peripheral for integration tests
- `fake_gps.dart` — fake location service with controllable position stream

## Debugging Tips

### BLE Issues

- **Enable verbose logging:** `FlutterBluePlus.setLogLevel(LogLevel.verbose)` in debug builds
- **Check permissions:** BLE scanning silently fails without location permission on Android
- **MTU issues:** If packets are truncated, verify MTU negotiation completed and PacketFramer is splitting correctly
- **Connection drops:** Monitor the heartbeat/liveness timeout — 60 seconds without data triggers reconnection
- **iOS background:** Ensure `bluetooth-central` background mode is declared; iOS may suspend BLE otherwise

### Protobuf Errors

- **Deserialization failures:** Check that generated classes match the proto file versions; regenerate with `make proto`
- **Field not populated:** Protobuf uses default values for unset fields — check `hasField()` before assuming data is present
- **Version mismatch:** If the Meshtastic radio firmware is updated, proto files may need updating too

### State Management Issues

- **Use ProviderObserver:** Log all state changes during development:
  ```dart
  class LoggingObserver extends ProviderObserver {
    @override
    void didUpdateProvider(ProviderBase provider, Object? prev, Object? next, ProviderContainer container) {
      debugPrint('${provider.name}: $prev → $next');
    }
  }
  ```
- **Provider not updating:** Ensure you're using `ref.watch()` in widgets (not `ref.read()`) for reactive rebuilds
- **Stale state:** Check that notifiers properly dispose stream subscriptions in `dispose()`

### GPS Simulation

- **Android Emulator:** Extended Controls → Location → set coordinates or load GPX route
- **iOS Simulator:** Features → Location → select predefined or custom location
- **Mock routes:** Create a GPX file with a route and play it back in the emulator for testing odometer and geofence
- **Speed testing:** Use the "Freeway Drive" preset in iOS Simulator for realistic speed variations

### GCI Protocol Debugging

- **Serial monitor:** Connect to the ESP-32 via USB serial to see raw bytes being sent/received
- **Byte inspection:** Log raw bytes at the TelemetryService level to verify endianness and field alignment
- **Heartbeat verification:** Ensure heartbeats are sent every 10 seconds and responses arrive within 40 seconds
- **Pairing issues:** The 6-second pairing window is strict — ensure the GCI is in pairing mode before initiating from the app

### Performance Profiling

- **Frame rate:** Use Flutter DevTools Performance tab to identify jank
- **Memory:** Watch for stream subscription leaks in DevTools Memory tab
- **BLE throughput:** Log packet sizes and timing to identify bottlenecks in the Meshtastic polling loop
- **GPS processing:** The 1-second GPS interval means all processing (filter, heading, odometer) must complete in well under 1 second

### Common Pitfalls

1. **Forgetting to dispose stream subscriptions** — Always cancel in the notifier's `dispose()` method
2. **Blocking the UI thread with BLE operations** — All BLE calls should be async and not awaited in build methods
3. **Testing with real Bluetooth in CI** — CI has no Bluetooth; use mocked services for all automated tests
4. **Assuming GPS accuracy** — GPS at golf cart speeds (5-25 mph) has significant noise; the SpeedFilter exists for a reason
5. **Ignoring platform differences** — BLE behavior differs between Android and iOS; test on both platforms
6. **Hardcoding screen dimensions** — Always use LayoutBuilder/MediaQuery for responsive layouts; never assume a fixed screen size
