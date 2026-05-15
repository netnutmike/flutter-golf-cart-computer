# Implementation Plan: Flutter Golf Cart Computer

## Overview

This implementation plan builds the Flutter Golf Cart Computer application from the ground up, following the four-layer architecture (Presentation, Application, Domain, Data). Tasks are ordered from foundational infrastructure through data layer services, domain logic, application state management, and finally presentation widgets. Property-based tests validate correctness properties alongside the domain components they cover.

## Tasks

- [x] 1. Project scaffolding and repository setup
  - [x] 1.1 Create Flutter project structure with four-layer architecture
    - Initialize Flutter project with `flutter create` targeting Android and iOS
    - Create directory layout: `lib/presentation/`, `lib/application/`, `lib/domain/`, `lib/data/`
    - Create subdirectories: `lib/domain/models/`, `lib/data/services/`, `lib/data/repositories/`
    - Add `analysis_options.yaml` with `flutter_lints`
    - Add core dependencies to `pubspec.yaml`: `flutter_riverpod`, `flutter_blue_plus`, `geolocator`, `protobuf`, `shared_preferences`, `hive`, `permission_handler`, `audioplayers`
    - Add dev dependencies: `glados`, `mocktail`, `build_runner`
    - Set version to 0.1.0
    - _Requirements: 16.1, 16.2, 16.3, 16.9, 16.14, 16.15, 16.16, 16.17_

  - [x] 1.2 Configure platform-specific settings
    - Android: Set `minSdkVersion 21` in `build.gradle`, add Bluetooth and Location permissions to `AndroidManifest.xml`
    - iOS: Add `NSBluetoothAlwaysUsageDescription`, `NSBluetoothPeripheralUsageDescription`, `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription` to `Info.plist`
    - iOS: Add `bluetooth-central` and `location` background modes to `Info.plist`
    - Android: Add `FOREGROUND_SERVICE` and `WAKE_LOCK` permissions
    - _Requirements: 16.11, 20.2, 20.3, 20.8, 21.8, 21.9_

  - [x] 1.3 Set up protobuf code generation
    - Create `proto/` directory with Meshtastic `.proto` files: `mesh.proto`, `admin.proto`, `config.proto`, `portnums.proto`, `telemetry.proto`, `module_config.proto`, `channel.proto`
    - Create a `Makefile` target or shell script for `protoc --dart_out` generation
    - Generate initial Dart classes from proto files into `lib/data/generated/`
    - Verify generated classes compile without errors
    - _Requirements: 16.4, 16.16, 18.10, 18.11_

  - [x] 1.4 Set up repository documentation and CI
    - Create `README.md` with project overview, setup instructions, architecture summary, platform build notes, badges, and docs links
    - Create `CONTRIBUTING.md` with coding standards, branch naming, PR process
    - Create `CHANGELOG.md` with initial `[Unreleased]` section
    - Add GPL-3.0 `LICENSE` file
    - Create `.github/dependabot.yml` with weekly schedule
    - Create `renovate.json` for automated dependency updates
    - Create `.github/workflows/ci.yml` running `flutter analyze` and `flutter test`
    - _Requirements: 16.5, 16.6, 16.7, 16.8, 16.12, 16.13, 16.18_

  - [x] 1.5 Create project documentation in docs/ folder
    - Create `docs/README.md` index with links and descriptions
    - Create `docs/build-guide.md` with prerequisites, setup, protobuf generation, troubleshooting
    - Create `docs/design.md` with architecture overview, component interactions, data flow, state management
    - Create `docs/developer-guide.md` with code organization, naming conventions, adding features, protocols, testing
    - Create `docs/features.md` listing all features by category
    - Create `docs/future-ideas.md` with planned enhancements
    - Create `docs/about.md` with purpose, audience, capabilities, screenshot placeholders
    - Each file must contain minimum 200 words of substantive content
    - _Requirements: 22.1, 22.2, 22.3, 22.4, 22.5, 22.6, 22.7, 22.8, 22.9, 22.10, 22.11_

  - [x] 1.6 Set up test infrastructure
    - Create test directory structure: `test/unit/domain/`, `test/unit/data/`, `test/property/`, `test/widget/`, `test/integration/`
    - Create a test helper file with common utilities and mock setup
    - Verify `flutter analyze` passes with zero errors
    - Verify `flutter test` runs without build failures
    - _Requirements: 16.17, 16.19_

- [x] 2. Checkpoint - Verify project scaffolding
  - Ensure `flutter analyze` passes with zero errors and `flutter test` executes without build failures. Ask the user if questions arise.


- [x] 3. Data layer - Core models and utilities
  - [x] 3.1 Define domain models
    - Create `lib/domain/models/gps_data.dart` with `ProcessedGpsData`, `NavigationData`, `RawPosition`
    - Create `lib/domain/models/weather_data.dart` with `WeatherData`, `HourForecast`
    - Create `lib/domain/models/entertainment_data.dart` with `VenueEvent`, `EntertainmentData`
    - Create `lib/domain/models/telemetry_data.dart` with `TelemetryData`
    - Create `lib/domain/models/odometer_state.dart` with `OdometerState`
    - Create `lib/domain/models/connection_state.dart` with `ConnectionState` enum
    - Create `lib/domain/models/geofence_state.dart` with `GeofenceState`
    - Create `lib/domain/models/sleep_state.dart` with `OperatingMode` enum, `SleepState`
    - Create `lib/domain/models/brightness_state.dart` with `BrightnessState`
    - Create `lib/domain/models/user_preferences.dart` with `UserPreferences` and defaults
    - Create `lib/domain/models/gci_message.dart` with `GciMessage`, `GciMessageType`, `GciTelemetryPayload`, `GciGpsPayload`, `GciCommandPayload`
    - _Requirements: 5.3, 5.8, 5.9, 6.3, 8.2, 9.3, 10.3, 11.1, 15.9_

  - [x] 3.2 Implement PacketFramer
    - Create `lib/data/services/packet_framer.dart`
    - Implement `frame()`: prepend 4-byte big-endian length prefix to payload
    - Implement `unframe()`: read length prefix, extract payload; return null if buffer too short or length exceeds available bytes
    - Implement `splitForMtu()`: split framed data into chunks of (mtuSize - 3) bytes
    - Handle edge cases: empty payload, maximum size (65535 bytes), framed data < 4 bytes
    - _Requirements: 18.2, 18.3, 18.4_

  - [x] 3.3 Write property test for PacketFramer round-trip
    - **Property 2: Packet framing round-trip**
    - Test that for any byte array (0 to 65535 bytes), frame then unframe produces the original
    - Test that framed data < 4 bytes returns null from unframe
    - Test that length prefix exceeding buffer returns null
    - **Validates: Requirements 18.2**

  - [x] 3.4 Write unit tests for PacketFramer
    - Test frame/unframe with known byte arrays
    - Test splitForMtu with various MTU sizes (20, 128, 512)
    - Test edge cases: empty payload, single byte, max size
    - _Requirements: 18.2, 18.3, 18.4_

- [x] 4. Data layer - Persistence
  - [x] 4.1 Implement PreferencesRepository
    - Create `lib/data/repositories/preferences_repository.dart` with abstract class and implementation
    - Implement `loadPreferences()` with defaults for missing/corrupted values
    - Implement `savePreference()` with 2-second debounce for slider/spinner values
    - Implement `resetAllPreferences()` preserving operational data (odometer, hours)
    - Implement `persistOdometer()`, `loadOdometer()`, `persistDrivingHours()`, `loadDrivingHours()`
    - Apply default values from Requirements 15.9
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.6, 15.7, 15.8, 15.9_

  - [x] 4.2 Implement CacheRepository
    - Create `lib/data/repositories/cache_repository.dart` with abstract class and implementation using Hive
    - Implement `cacheWeatherData()` and `cacheVenueData()` with raw packet, timestamp, and YYYYMMDD date
    - Implement `loadCachedWeather()` and `loadCachedVenue()`
    - Implement `clearStaleCache()` comparing stored date against current date
    - _Requirements: 15.5, 19.1, 19.2, 19.3, 19.4, 19.5_

  - [x] 4.3 Write property test for cache date validation
    - **Property 10: Cache date validation**
    - Test that cached data is restored if and only if stored date equals current date
    - Test that mismatched dates result in stale cache discard
    - **Validates: Requirements 3.7, 3.8, 4.9, 4.10, 19.3, 19.4, 19.5**

  - [x] 4.4 Write unit tests for PreferencesRepository and CacheRepository
    - Test loading defaults when no data exists
    - Test debounce behavior for rapid writes
    - Test reset preserves operational data
    - Test corrupted data handling
    - _Requirements: 15.3, 15.4, 15.8_


- [x] 5. Data layer - Bluetooth and GPS services
  - [x] 5.1 Implement MeshtasticService
    - Create `lib/data/services/meshtastic_service.dart` with abstract class and BLE implementation
    - Implement device scanning with name pattern `^.*_([0-9a-fA-F]{4})$` and 10-second timeout
    - Implement BLE connection with service UUID `6ba1b218-15a8-461f-9fa8-5dcae273eafd`
    - Implement GATT interaction: subscribe FROMNUM, write TORADIO, poll FROMRADIO until empty
    - Implement MTU negotiation and packet splitting via PacketFramer
    - Implement handshake: send `want_config_id`, process `my_info`, `config`, `config_complete_id`
    - Implement 30-second heartbeat and 60-second liveness timeout
    - Implement disconnect with `ToRadio(disconnect=true)` frame
    - Implement exponential backoff reconnection (2s start, 60s max, 10 attempts)
    - Implement message routing by portnum: TEXT_MESSAGE_APP(1), ADMIN_APP(6), POSITION_APP(3), TELEMETRY_APP(67)
    - Implement outbound MeshPacket construction with random packet ID, destination, channel, port number
    - Persist bonded device identifier for auto-reconnection
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.8, 1.9, 1.10, 1.11, 1.12, 1.13, 1.14, 1.16, 1.17, 18.1, 18.4, 18.5, 18.6, 18.7, 18.8, 18.9_

  - [x] 5.2 Write property tests for Meshtastic message handling
    - **Property 1: Protobuf serialization round-trip**
    - **Validates: Requirements 1.5, 1.6**
    - **Property 3: Message routing acceptance**
    - **Validates: Requirements 2.2**
    - **Property 4: Outbound message construction**
    - **Validates: Requirements 2.3, 2.4, 2.9, 18.8**
    - **Property 5: Outbound payload size enforcement**
    - **Validates: Requirements 2.7**

  - [x] 5.3 Implement TelemetryService
    - Create `lib/data/services/telemetry_service.dart` with abstract class and implementation
    - Implement GCI message envelope: type(1) + timestamp(4 LE) + seq_num(2 LE) + data_len(2 LE) + data
    - Implement telemetry data parsing: 20-byte LE payload (modeLights, outdoorLum, airTemp, battVolts, fuel)
    - Implement heartbeat sending every 10 seconds
    - Implement 40-second timeout (4 missed heartbeats) disconnect detection
    - Implement pairing: broadcast discovery with 6-second timeout, ACK handshake
    - Implement GPS data sending (24-byte LE payload) at configurable interval
    - Implement `sendIsHome()` and `sendIsDaytime()` as single-byte boolean payloads
    - Implement exponential backoff reconnection (2s start, 60s max)
    - Persist paired device address
    - Platform-specific: BLE on iOS, Bluetooth Classic SPP preferred on Android with BLE fallback
    - _Requirements: 8.1, 8.2, 8.7, 8.8, 8.9, 8.10, 8.11, 8.12, 8.13, 8.14, 8.15, 8.16, 8.17, 17.7, 17.8_

  - [x] 5.4 Write unit tests for TelemetryService message parsing
    - Test 20-byte LE telemetry payload decoding with known values
    - Test GCI message envelope construction and parsing
    - Test heartbeat timing and timeout detection
    - Test pairing flow with ACK and timeout scenarios
    - Test packets < 20 bytes are discarded
    - _Requirements: 8.2, 8.7, 8.8, 8.9, 8.17_

  - [x] 5.5 Implement LocationService
    - Create `lib/data/services/location_service.dart` with abstract class and geolocator implementation
    - Implement `positionStream` with 1-second update interval via `Geolocator.getPositionStream()`
    - Implement `currentPosition` getter
    - Implement `requestPermission()` using permission_handler
    - Implement `isServiceEnabled` check
    - Configure background location for iOS via background modes
    - _Requirements: 5.1, 5.20, 20.8_

  - [x] 5.6 Implement BackgroundService
    - Create `lib/data/services/background_service.dart` with abstract class and platform channel implementation
    - Android: Implement foreground service start/stop with persistent notification via platform channel
    - iOS: Leverage declared background modes (bluetooth-central, location)
    - Implement `isRunningInBackground` stream
    - _Requirements: 20.1, 20.2, 20.3, 20.7_

- [x] 6. Checkpoint - Verify data layer services compile
  - Ensure all tests pass, ask the user if questions arise.


- [x] 7. Domain layer - GPS and speed processing
  - [x] 7.1 Implement SpeedFilter
    - Create `lib/domain/speed_filter.dart`
    - Implement dither elimination: speeds below 2.5 mph → zero
    - Implement spike rejection: discard readings exceeding 8 mph/s acceleration
    - Implement responsive stop detection: speed < 4 mph and decreasing → zero
    - Implement consecutive reading threshold: 2 readings above 2.5 mph before reporting movement (3 when dimmed)
    - Implement `reset()` for GPS signal loss
    - Return `FilterResult` with filteredSpeedMph, isMoving, wasDiscarded
    - _Requirements: 5.4, 5.5, 5.6, 5.7_

  - [x] 7.2 Write property test for GPS speed filtering pipeline
    - **Property 11: GPS speed filtering pipeline**
    - Test dither elimination (raw < 2.5 → 0)
    - Test spike rejection (> 8 mph/s acceleration discarded)
    - Test responsive stop detection (< 4 mph decreasing → 0)
    - Test consecutive reading threshold (2 normal, 3 dimmed)
    - **Validates: Requirements 5.4, 5.5, 5.6, 5.7**

  - [x] 7.3 Implement GpsProcessor
    - Create `lib/domain/gps_processor.dart`
    - Integrate SpeedFilter for speed processing
    - Implement heading conversion: bearing degrees → 16-point cardinal direction (22.5° intervals)
    - Implement satellite count debounce: 3 consecutive zeros before displaying zero
    - Implement HDOP estimation: ≥6 sats = 1.5, 4-5 sats = 2.0, <4 sats = 99.0
    - Implement dual GPS source: device sensor primary, Meshtastic fallback
    - Implement "NO GPS" detection after 60 seconds without time update
    - Implement invalid speed handling: zero if last speed < 5 mph, else retain
    - Emit `ProcessedGpsData` and `NavigationData` streams
    - _Requirements: 5.1, 5.2, 5.3, 5.8, 5.9, 5.10, 5.11, 5.12, 5.15, 5.16, 5.17, 5.18, 5.19_

  - [x] 7.4 Write property tests for GPS navigation calculations
    - **Property 12: Cardinal direction mapping**
    - Test 16-point mapping with 22.5° intervals for all bearings [0, 360)
    - **Validates: Requirements 5.8**
    - **Property 13: Satellite count debounce**
    - Test zero only displayed after 3 consecutive zero readings
    - **Validates: Requirements 5.11**
    - **Property 14: HDOP estimation from satellite count**
    - Test estimation rules: ≥6→1.5, 4-5→2.0, <4→99.0
    - **Validates: Requirements 5.12**

- [x] 8. Domain layer - Distance and time tracking
  - [x] 8.1 Implement OdometerManager
    - Create `lib/domain/odometer_manager.dart`
    - Implement distance accumulation with Doppler speed gating (only when filtered speed > 0)
    - Implement minimum distance threshold: 2.6 feet (0.0005 miles) with Doppler, 10 feet (0.002 miles) without
    - Implement position-based speed rejection: discard if > 30 mph
    - Implement rollover: total at 100,000.0 miles, trip at 10,000.0 miles
    - Implement trip reset (sets trip to 0.0 without affecting total)
    - Implement persistence triggers: every 0.5 miles and before sleep/shutdown
    - Wire to PreferencesRepository for persist/load
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9, 6.10, 6.11, 6.12, 6.13_

  - [x] 8.2 Write property tests for odometer
    - **Property 15: Distance accumulation gating**
    - Test distance only accumulates when speed > 0, position change exceeds threshold, implied speed ≤ 30 mph
    - **Validates: Requirements 6.4, 6.5, 6.6, 6.7**
    - **Property 16: Odometer invariants**
    - Test trip reset doesn't affect total, rollover at 100,000 and 10,000, total = sum of segments mod 100,000
    - **Validates: Requirements 6.1, 6.2, 6.8, 6.13**

  - [x] 8.3 Implement ServiceReminderManager
    - Create `lib/domain/service_reminder_manager.dart`
    - Implement time accumulation: only when speed > 0
    - Implement time delta validation: accept only > 0 and ≤ 10 seconds
    - Store in tenths of hours (6-minute resolution)
    - Implement persistence trigger: every 1.0 hours of driving
    - Implement configurable service interval (1-500 hours, default 100)
    - Implement reset with confirmation requirement
    - Wire to PreferencesRepository for persist/load
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 7.10_

  - [x] 8.4 Write property test for driving hours accumulation
    - **Property 17: Driving hours accumulation gating**
    - Test hours only accumulate when speed > 0 AND delta > 0 AND delta ≤ 10 seconds
    - Test deltas outside range are discarded
    - **Validates: Requirements 7.1, 7.5**


- [x] 9. Domain layer - Packet parsing
  - [x] 9.1 Implement HotPacketParser
    - Create `lib/domain/hot_packet_parser.dart`
    - Implement `isHotPacket()`: check leading `|` character
    - Implement `parsePacketType()`: extract type code after `|#`
    - Implement weather packet parsing: validate 7 `#` and 12 `,` delimiters, parse current temp and 4 forecasts
    - Validate temperature range (-99 to 999), hour labels (≤6 chars), precipitation (0.0-100.0), glyphs (≤10 chars)
    - Replace `0.0` precipitation with empty string
    - Implement venue/event parsing: split by `#`, split each pair at first `,`, validate non-empty venue and event
    - Support 1-12 venue/event pairs, discard extras
    - Log diagnostic messages for validation failures
    - _Requirements: 3.1, 3.2, 3.3, 3.9, 3.10, 3.11, 3.12, 3.13, 3.14, 4.1, 4.2, 4.3, 4.4, 4.6_

  - [x] 9.2 Write property tests for weather packet validation and parsing
    - **Property 6: Weather packet structural validation**
    - Test acceptance iff starts with `|#01#`, has 7 `#` and 12 `,`, valid temps/hours/precip/glyphs
    - **Validates: Requirements 3.2, 3.9, 3.10, 3.11, 3.13, 3.14**
    - **Property 7: Weather packet parsing correctness**
    - Test valid packets produce WeatherData with current temp and exactly 4 HourForecast entries
    - **Validates: Requirements 3.1, 3.3, 3.4**
    - **Property 8: Precipitation zero-clearing**
    - Test `0.0` → empty string, other values preserved
    - **Validates: Requirements 3.12**

  - [x] 9.3 Write property test for venue/event packet parsing
    - **Property 9: Venue/event packet parsing**
    - Test valid packets produce correct VenueEvent list with venue = text before first comma, event = text after
    - Test list length equals number of valid pairs (up to 12)
    - **Validates: Requirements 4.1, 4.2, 4.3, 4.6**

- [x] 10. Domain layer - System managers
  - [x] 10.1 Implement GeofenceManager
    - Create `lib/domain/geofence_manager.dart`
    - Implement distance calculation from current position to home using Haversine formula
    - Implement hysteresis: entering home at radius - 50m, leaving at radius + 50m
    - Implement configurable radius (100-5000m, default 500m)
    - Implement `setHomeLocation()`, `clearHomeLocation()`
    - Default `isAtHome` to false when no home location set
    - Emit `GeofenceState` stream on each position update
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, 9.9, 9.10_

  - [x] 10.2 Write property test for geofence hysteresis
    - **Property 18: Geofence status determination with hysteresis**
    - Test `at_home` transitions true only at radius - 50m, false only at radius + 50m
    - Test no oscillation within hysteresis band
    - **Validates: Requirements 9.4, 9.5, 9.6**

  - [x] 10.3 Implement SleepManager
    - Create `lib/domain/sleep_manager.dart`
    - Implement three-state machine: STARTUP_GRACE, GCI_MODE, STANDALONE_MODE
    - STARTUP_GRACE → GCI_MODE when GCI connects
    - STARTUP_GRACE → STANDALONE_MODE when grace period expires
    - GCI_MODE → STANDALONE_MODE when GCI disconnected for timeout period
    - STANDALONE_MODE → GCI_MODE when GCI reconnects
    - Grace period = backlight timeout setting (minimum 30 seconds)
    - Emit `OperatingMode` stream
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

  - [x] 10.4 Write property test for sleep state machine
    - **Property 20: Sleep state machine transitions**
    - Test all valid transitions and verify no invalid transitions are possible
    - **Validates: Requirements 11.1, 11.2, 11.3, 11.4, 11.5**

  - [x] 10.5 Implement BrightnessManager
    - Create `lib/domain/brightness_manager.dart`
    - Implement day/night brightness selection based on current time vs sunrise/sunset
    - Implement inactivity timeout dimming (0-60 minutes, default 5)
    - Implement activity detection: touch input or GPS movement (speed > 0) restores brightness
    - Timeout 0 disables auto-dimming
    - Default to day brightness when sunrise/sunset unavailable
    - Emit `BrightnessState` stream
    - Use platform channels for native screen brightness control
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8, 10.9_

  - [x] 10.6 Write property test for brightness level selection
    - **Property 19: Brightness level selection**
    - Test day brightness between sunrise and sunset, night brightness otherwise
    - **Validates: Requirements 10.1, 10.2**

  - [x] 10.7 Implement AudioService
    - Create `lib/domain/audio_service.dart`
    - Implement distinct tones: startup, message notification, alert, confirmation, click, error
    - Implement volume control (0-20 integer steps)
    - Volume 0 suppresses all playback
    - Use audioplayers or just_audio plugin for cross-platform playback
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7, 14.8, 14.9, 14.10, 14.11_

- [x] 11. Checkpoint - Verify domain layer
  - Ensure all tests pass, ask the user if questions arise.


- [x] 12. Application layer - Riverpod providers and notifiers
  - [x] 12.1 Set up Riverpod provider definitions
    - Create `lib/application/providers.dart` with all provider definitions organized by layer
    - Data providers: `meshtasticServiceProvider`, `telemetryServiceProvider`, `locationServiceProvider`, `preferencesRepositoryProvider`, `cacheRepositoryProvider`, `backgroundServiceProvider`
    - Domain providers: `gpsProcessorProvider`, `odometerManagerProvider`, `serviceReminderProvider`, `hotPacketParserProvider`, `sleepManagerProvider`, `brightnessManagerProvider`, `geofenceManagerProvider`, `audioServiceProvider`, `speedFilterProvider`
    - Application providers: `mainNotifierProvider`, `weatherNotifierProvider`, `entertainmentNotifierProvider`, `configNotifierProvider`, `connectionNotifierProvider`
    - _Requirements: 16.2_

  - [x] 12.2 Implement ConnectionNotifier
    - Create `lib/application/connection_notifier.dart`
    - Manage independent connection state for Meshtastic and GCI
    - Expose connection states: Disconnected, Connecting, Connected, Reconnecting
    - Coordinate initial connection on app startup using persisted device identifiers
    - Handle permission checks before connection attempts
    - Send AWAKE notification (`~#01#GC#AWAKE#`) on Meshtastic connection established
    - Send stale cache request (`~#01#GC#REQ_WX_ENT#`) when cache is outdated
    - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.5, 2.8, 3.8_

  - [x] 12.3 Implement MainNotifier
    - Create `lib/application/main_notifier.dart`
    - Subscribe to GpsProcessor for speed, heading, coordinates, satellite/HDOP, date/time, sunrise/sunset
    - Subscribe to OdometerManager for distance values
    - Subscribe to ServiceReminderManager for driving hours
    - Subscribe to GeofenceManager for at-home status
    - Subscribe to SleepManager for operating mode
    - Subscribe to BrightnessManager for display brightness
    - Subscribe to TelemetryService for battery voltage, fuel, temperature, headlight mode
    - Apply temperature offset from preferences
    - Coordinate GPS interval changes based on at-home status (8s away, 120s home)
    - Notify GCI of at-home and is-daytime status changes
    - Trigger odometer/hours persistence before sleep/shutdown
    - _Requirements: 5.3, 5.8, 5.9, 5.10, 5.13, 5.14, 5.17, 5.18, 6.3, 7.6, 8.3, 8.4, 8.5, 8.6, 8.13, 8.14, 9.5, 9.6, 11.6, 11.7, 12.4, 12.8_

  - [x] 12.4 Implement WeatherNotifier
    - Create `lib/application/weather_notifier.dart`
    - Subscribe to MeshtasticService incoming packets for HoT weather packets
    - Use HotPacketParser to parse weather data
    - Cache received weather data via CacheRepository
    - Load cached weather on startup with date validation
    - Manage "(stored)" indicator for cached vs live data
    - Track received timestamp in 12-hour format
    - Trigger alert tone on new weather data
    - Manage "new data received" indicator with 5-second auto-clear
    - _Requirements: 3.1, 3.4, 3.5, 3.6, 3.7, 3.8, 13.10, 13.11, 14.3, 19.1, 19.3, 19.4, 19.5, 19.6, 19.7_

  - [x] 12.5 Implement EntertainmentNotifier
    - Create `lib/application/entertainment_notifier.dart`
    - Subscribe to MeshtasticService incoming packets for HoT venue/event packets
    - Use HotPacketParser to parse venue/event data
    - Cache received venue/event data via CacheRepository
    - Load cached venue data on startup with date validation
    - Manage "(stored)" indicator for cached vs live data
    - Track received timestamp in 12-hour format
    - Trigger alert tone on new venue data
    - Manage "new data received" indicator with 5-second auto-clear
    - Refresh display within 1 second when new data arrives on active screen
    - _Requirements: 4.5, 4.7, 4.8, 4.9, 4.10, 4.11, 13.10, 13.11, 14.3, 19.2, 19.3, 19.4, 19.5, 19.6, 19.7_

  - [x] 12.6 Implement ConfigNotifier
    - Create `lib/application/config_notifier.dart`
    - Expose all user preferences with getters and setters
    - Implement preference changes with 2-second debounce for sliders/spinners
    - Implement home location set (requires GPS) and clear
    - Implement GCI pairing initiation with 6-second timeout
    - Implement Meshtastic enable/disable toggle
    - Implement service hours reset with confirmation
    - Implement trip odometer reset
    - Implement "reset all preferences" with app restart
    - Implement manual app restart
    - Expose app version and device identifier
    - Play confirmation/error tones for user actions
    - _Requirements: 9.1, 9.2, 9.8, 13.5, 13.7, 13.8, 15.3, 15.4, 12.7, 11.8, 7.9, 6.2, 14.4, 14.6_

- [x] 13. Application layer - Messaging and admin
  - [x] 13.1 Implement Meshtastic messaging logic in ConnectionNotifier
    - Support sending text messages to broadcast on channels 0-7
    - Support sending direct messages to specific node numbers
    - Support preformatted message selection (up to 20 entries)
    - Support custom text composition
    - Enforce 237-byte UTF-8 payload limit with size indicator
    - Reject send attempts when not connected
    - Maintain message history (up to 100, FIFO eviction)
    - Display received messages with sender node ID (hex), channel, timestamp (12-hour)
    - Play notification tone on message receipt (if volume > 0)
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.9, 2.10, 2.11, 2.12_

  - [x] 13.2 Implement Meshtastic radio administration
    - Implement reboot command with 5-second delay and confirmation prompt
    - Implement GPS interval configuration (read-modify-write pattern on PositionConfig)
    - Implement admin command encoding with ADMIN_APP port to local node number
    - Handle admin command timeout (10 seconds) with error display
    - Display connected radio node ID in hex format
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.9_

- [x] 14. Application layer - Permission handling
  - [x] 14.1 Implement cross-platform permission management
    - Create `lib/application/permission_manager.dart`
    - Use `permission_handler` package for unified permission management
    - Request permissions at point of first use (not at startup)
    - Display rationale dialog before system prompt
    - Handle denied state: show message identifying unavailable features + settings button
    - Handle "Don't ask again" on Android: direct to system settings
    - Handle iOS states: Not Determined (prompt), Restricted (device message), Denied (settings), Authorized (proceed)
    - Detect permission state changes when app returns to foreground
    - _Requirements: 21.1, 21.2, 21.3, 21.4, 21.5, 21.6, 21.7, 21.10, 21.11_

- [x] 15. Checkpoint - Verify application layer
  - Ensure all tests pass, ask the user if questions arise.


- [x] 16. Presentation layer - Screens and widgets
  - [x] 16.1 Implement MainScreen widget
    - Create `lib/presentation/screens/main_screen.dart`
    - Display widgets: speed (integer mph), heading (16-point cardinal), time (12-hour AM/PM), date ("Mon, Jan 15")
    - Display: temperature (integer °F with offset), satellite/HDOP ("8/1.50"), connection status indicators
    - Display: battery voltage ("48.2V"), fuel level ("75%"), headlight mode, odometer, trip odometer, driving hours
    - Display: sunrise/sunset times, "NO GPS" when applicable
    - Display: service-due indicator when hours ≥ service interval
    - Configurable widget visibility
    - Touch targets minimum 48x48 dp
    - Navigation to weather, entertainment, and config screens within 2 taps
    - Support screen rotation (flip) configuration
    - Material Design 3 theming
    - _Requirements: 13.1, 13.6, 13.9, 13.12, 13.13, 13.14, 13.15, 5.3, 5.8, 5.9, 5.10, 5.13, 5.14, 5.17, 5.18, 6.3, 7.6, 7.10, 8.3, 8.4, 8.5, 8.6_

  - [x] 16.2 Implement WeatherScreen widget
    - Create `lib/presentation/screens/weather_screen.dart`
    - Display current temperature prominently
    - Display 4-hour forecast: hour label, weather glyph icon, temperature, precipitation
    - Display received timestamp in 12-hour format with AM/PM
    - Display "(stored)" indicator for cached data
    - Display "new data received" indicator with 5-second auto-clear
    - Handle empty state when no weather data available
    - _Requirements: 3.4, 3.5, 13.2, 13.10, 13.11, 19.4, 19.6_

  - [x] 16.3 Implement EntertainmentScreen widget
    - Create `lib/presentation/screens/entertainment_screen.dart`
    - Display scrollable two-column table: venue names (col 1), event names (col 2)
    - Display up to 12 venue/event entries
    - Display received timestamp in 12-hour format with AM/PM
    - Display "(stored)" indicator for cached data
    - Display "new data received" indicator with 5-second auto-clear
    - Handle empty state when no venue data available
    - _Requirements: 4.5, 4.6, 4.7, 13.3, 13.10, 13.11, 19.4, 19.6_

  - [x] 16.4 Implement ConfigScreen widget
    - Create `lib/presentation/screens/config_screen.dart`
    - Controls: day brightness slider (0-10), night brightness slider (0-10), speaker volume slider (0-20)
    - Controls: screen flip toggle, backlight timeout spinner (0-60 min), temperature offset spinner (-20 to +20)
    - Controls: service interval spinner (1-500 hours), home geofence radius spinner (100-5000m)
    - Controls: set home location button, clear home location button
    - Controls: GCI pair button, Meshtastic enable/disable toggle
    - Controls: reset trip odometer, reset service hours (with confirmation)
    - Controls: reset all preferences (with confirmation), manual restart
    - Display: app version, device identifier, connected radio node ID
    - Accessible via single tap/swipe from main display
    - _Requirements: 13.4, 13.5, 13.7, 13.8, 12.1, 12.2, 12.7, 11.8_

  - [x] 16.5 Implement connection status indicators
    - Create reusable connection indicator widgets for Meshtastic and GCI
    - Display three distinct visual states: connected, disconnected, connecting/reconnecting
    - Independent indicators for each connection
    - _Requirements: 13.6, 17.2, 17.5_

  - [x] 16.6 Write widget tests for all screens
    - Test MainScreen renders all widgets with correct data
    - Test WeatherScreen displays 4-hour forecast correctly
    - Test EntertainmentScreen displays scrollable venue/event table
    - Test ConfigScreen has all controls present and functional
    - Test connection indicators show correct states
    - Test screen rotation/flip works
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.6_

- [x] 17. Integration and wiring
  - [x] 17.1 Wire app entry point and navigation
    - Create `lib/main.dart` with ProviderScope and MaterialApp
    - Implement navigation between main, weather, entertainment, and config screens
    - Initialize preferences loading before dependent components
    - Play startup tone on launch
    - Implement app lifecycle handling (persist data on background/shutdown)
    - Configure screen brightness on startup based on loaded preferences
    - _Requirements: 13.14, 14.1, 15.2, 11.7, 20.4_

  - [x] 17.2 Wire background connectivity and lifecycle
    - Start foreground service on Android when app launches
    - Maintain BLE connections when backgrounded
    - Continue processing messages and telemetry in background
    - Resume displaying live data within 2 seconds on foreground return
    - Reconnect within 5 seconds if OS terminated connections
    - _Requirements: 20.1, 20.2, 20.3, 20.4, 20.5, 20.6_

  - [x] 17.3 Write integration tests
    - Test BLE connection lifecycle with mock peripheral
    - Test dual Bluetooth independence (one failure doesn't affect other)
    - Test persistence round-trip (shared_preferences and hive)
    - Test permission flow with denied permissions
    - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.9_

- [x] 18. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 19. Responsive layout implementation
  - [x] 19.1 Implement responsive breakpoint system
    - Create `lib/presentation/widgets/responsive_layout.dart` with `ResponsiveLayout` widget
    - Implement breakpoint detection using `LayoutBuilder` and `MediaQuery`: Compact (<800px), Medium (800-1024px), Expanded (>1024px)
    - Create layout variants for each breakpoint: `CompactDashboardLayout`, `MediumDashboardLayout`, `ExpandedDashboardLayout`
    - Ensure all primary layout containers use relative sizing (flex factors, percentage-based constraints) rather than fixed pixel dimensions
    - Implement orientation detection and provide portrait vs landscape layout variants
    - Verify orientation changes reflow within 500ms without losing application state or interrupting Bluetooth connections
    - _Requirements: 23.1, 23.2, 23.3, 23.4, 23.5, 23.9, 23.10_

  - [x] 19.2 Adapt MainScreen for responsive layout
    - Refactor `lib/presentation/screens/main_screen.dart` to use `ResponsiveLayout`
    - Portrait layout: single-column stack with speed/heading at top, secondary info scrollable below
    - Landscape layout: side-by-side with speed/heading on one side, telemetry/status on the other
    - Compact breakpoint: prioritize speed, heading, time, connection status; secondary info scrolls
    - Medium breakpoint: two-column dashboard with essential info visible
    - Expanded breakpoint: all widgets visible simultaneously in multi-column arrangement
    - Ensure all text meets minimum font sizes: 16sp for speed/temperature/time, 12sp for labels/status
    - Ensure all touch targets maintain minimum 44x44dp at all screen sizes
    - _Requirements: 23.1, 23.2, 23.3, 23.5, 23.6, 23.7, 23.8, 23.9_

  - [x] 19.3 Adapt secondary screens for responsive layout
    - Refactor `WeatherScreen` to adapt layout for portrait/landscape and screen size breakpoints
    - Refactor `EntertainmentScreen` to adapt scrollable table for available space
    - Refactor `ConfigScreen` to reflow controls for portrait/landscape and smaller screens
    - Ensure all screens render correctly at 800x600 minimum resolution
    - Ensure font sizes and touch targets meet minimums on all screens
    - _Requirements: 23.1, 23.2, 23.3, 23.6, 23.7_

  - [x] 19.4 Write widget tests for responsive behavior
    - Test MainScreen renders correctly at 800x600 (minimum resolution)
    - Test MainScreen renders correctly at 1024x768 (medium breakpoint)
    - Test MainScreen renders correctly at 1920x1080 (expanded)
    - Test MainScreen adapts between portrait and landscape orientations
    - Test all text meets minimum font size requirements (12sp informational, 16sp primary)
    - Test all interactive elements maintain 44x44dp minimum touch targets
    - Test WeatherScreen, EntertainmentScreen, and ConfigScreen at minimum resolution
    - Test orientation change does not lose application state
    - Test priority-based content display on screens smaller than 1024x768
    - _Requirements: 23.1, 23.2, 23.3, 23.6, 23.7, 23.8, 23.9, 23.10_

- [x] 20. Final verification - Responsive layout
  - Ensure all responsive layout tests pass and screens render correctly at 800x600 minimum. Ask the user if questions arise.

## Notes

- All tasks are required
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The four-layer architecture ensures clean separation: Data → Domain → Application → Presentation
- Riverpod providers enable testability through overrides without mocks for domain logic
- Platform-specific code (background service, Bluetooth Classic) uses platform channels


## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2", "1.4", "1.5"] },
    { "id": 2, "tasks": ["1.3", "1.6"] },
    { "id": 3, "tasks": ["3.1", "3.2"] },
    { "id": 4, "tasks": ["3.3", "3.4", "4.1", "4.2"] },
    { "id": 5, "tasks": ["4.3", "4.4", "5.5", "5.6"] },
    { "id": 6, "tasks": ["5.1", "5.3"] },
    { "id": 7, "tasks": ["5.2", "5.4"] },
    { "id": 8, "tasks": ["7.1", "9.1", "10.7"] },
    { "id": 9, "tasks": ["7.2", "7.3", "9.2", "9.3"] },
    { "id": 10, "tasks": ["7.4", "8.1", "8.3", "10.1", "10.3", "10.5"] },
    { "id": 11, "tasks": ["8.2", "8.4", "10.2", "10.4", "10.6"] },
    { "id": 12, "tasks": ["12.1"] },
    { "id": 13, "tasks": ["12.2", "12.3", "12.4", "12.5", "12.6"] },
    { "id": 14, "tasks": ["13.1", "13.2", "14.1"] },
    { "id": 15, "tasks": ["16.1", "16.2", "16.3", "16.4", "16.5"] },
    { "id": 16, "tasks": ["16.6", "17.1"] },
    { "id": 17, "tasks": ["17.2"] },
    { "id": 18, "tasks": ["17.3"] },
    { "id": 19, "tasks": ["19.1"] },
    { "id": 20, "tasks": ["19.2", "19.3"] },
    { "id": 21, "tasks": ["19.4"] }
  ]
}
```
