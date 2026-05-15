# Requirements Document

## Introduction

This document specifies the requirements for the Flutter Golf Cart Computer application — a cross-platform port of the existing native Android Golf Cart Display Computer (GCD). The Flutter version targets both Android and iOS platforms, providing the same functionality as the Android-native app while leveraging Flutter's cross-platform capabilities.

The system is part of a three-component golf cart computer ecosystem designed for The Villages Retirement Community:
- **GCM (Golf Cart Meshtastic):** A Meshtastic radio providing mesh messaging, GPS, and data relay
- **GCD (Golf Cart Display):** The display computer application (this Flutter app)
- **GCI (Golf Cart Internal):** An ESP-32 central computer providing vehicle telemetry (battery voltage, fuel level, temperature, headlight status) over Bluetooth

The Flutter app must handle two simultaneous Bluetooth connections: one to the Meshtastic radio (BLE) and one to the GCI telemetry radio (Bluetooth Classic or BLE). The app must handle platform-specific BLE permission models for both Android and iOS.

## Glossary

- **GCD:** Golf Cart Display — the display computer application (this Flutter app)
- **GCM:** Golf Cart Meshtastic — the Meshtastic radio unit connected via Bluetooth LE
- **GCI:** Golf Cart Internal — the ESP-32 vehicle telemetry computer connected via Bluetooth
- **Meshtastic:** An open-source mesh networking protocol for LoRa radios
- **HoT_Packet:** "Hands-off-Transmission" packet — a structured data packet received via Meshtastic containing weather or venue/event data, identified by a leading `|` character
- **BLE:** Bluetooth Low Energy — the protocol used to communicate with the Meshtastic radio
- **GATT:** Generic Attribute Profile — the BLE protocol layer for data exchange
- **Protobuf:** Protocol Buffers — the serialization format used by Meshtastic for radio communication
- **Geofence:** A virtual geographic boundary defined by GPS coordinates and a radius
- **Odometer:** Accumulated distance traveled counter
- **Trip_Odometer:** Resettable distance counter for individual trips
- **Service_Reminder:** A maintenance tracking system based on accumulated driving hours
- **Brightness_Manager:** The component managing display brightness based on time of day and activity
- **Sleep_Manager:** The component managing power states and screen timeout behavior
- **Hot_Packet_Parser:** The component that parses structured weather and venue/event data from Meshtastic messages
- **Telemetry_Service:** The component managing Bluetooth communication with the GCI for vehicle data
- **Meshtastic_Service:** The component managing BLE communication with the Meshtastic radio
- **Packet_Framer:** The component responsible for framing and unframing protobuf messages with 4-byte big-endian length prefixes
- **Widget:** A configurable UI element on the main display screen
- **Flutter_BLE_Plugin:** The Flutter plugin used for cross-platform BLE communication (flutter_blue_plus or flutter_reactive_ble)
- **Riverpod:** The state management and dependency injection framework used in the Flutter app
- **Platform_Channel:** Flutter mechanism for invoking platform-specific native code on Android and iOS

## Requirements

### Requirement 1: Meshtastic BLE Connection

**User Story:** As a golf cart operator, I want the app to connect to my Meshtastic radio via Bluetooth LE on both Android and iOS, so that I can send and receive mesh messages regardless of which mobile platform I use.

#### Acceptance Criteria

1. THE Meshtastic_Service SHALL connect to the Meshtastic radio using Bluetooth Low Energy with the service UUID `6ba1b218-15a8-461f-9fa8-5dcae273eafd` within a connection timeout of 15 seconds
2. THE Meshtastic_Service SHALL write outbound packets to the TORADIO characteristic (UUID: `f75c76d2-129e-4dad-a1dd-7866124401e7`)
3. THE Meshtastic_Service SHALL subscribe to notifications on the FROMNUM characteristic (UUID: `ed9da18c-a800-4f66-a670-aa7547e34453`) to detect when new data is available
4. WHEN a FROMNUM notification is received, THE Meshtastic_Service SHALL read all available data from the FROMRADIO characteristic (UUID: `2c55e69e-4993-11ed-b878-0242ac120002`) until an empty response is returned
5. THE Meshtastic_Service SHALL encode outbound messages using Protocol Buffers with the Meshtastic `ToRadio` message format
6. THE Meshtastic_Service SHALL decode inbound messages using Protocol Buffers with the Meshtastic `FromRadio` message format
7. THE Meshtastic_Service SHALL use the `protobuf` Dart package with protoc-generated Dart classes from Meshtastic `.proto` definition files
8. THE Meshtastic_Service SHALL use a Flutter BLE plugin (flutter_blue_plus or flutter_reactive_ble) for cross-platform BLE communication
9. WHEN the BLE connection is established, THE Meshtastic_Service SHALL perform the Meshtastic handshake by sending a `want_config_id` in the `ToRadio` message and SHALL consider the handshake complete upon receiving a `config_complete_id` in a `FromRadio` message within 10 seconds
10. THE Meshtastic_Service SHALL maintain a 30-second heartbeat interval to detect connection liveness
11. IF no data is received from the radio within 60 seconds after a heartbeat, THEN THE Meshtastic_Service SHALL treat the connection as dead and attempt reconnection using exponential backoff starting at 5 seconds, doubling each attempt, up to a maximum of 10 reconnection attempts
12. WHEN disconnecting, THE Meshtastic_Service SHALL send a `ToRadio(disconnect=true)` frame before closing the BLE connection
13. THE Meshtastic_Service SHALL persist the bonded/connected device identifier for automatic reconnection on application startup
14. THE Meshtastic_Service SHALL scan for Meshtastic devices matching the name pattern `^.*_([0-9a-fA-F]{4})$` with a scan duration of 10 seconds
15. THE Meshtastic_Service SHALL request platform-appropriate Bluetooth permissions: BLUETOOTH_CONNECT and BLUETOOTH_SCAN on Android 12+, and Bluetooth usage authorization on iOS
16. IF the BLE connection attempt exceeds the 15-second timeout or the handshake does not complete within 10 seconds, THEN THE Meshtastic_Service SHALL disconnect, report a connection failure state, and schedule a reconnection attempt
17. IF no Meshtastic devices are discovered during the 10-second scan period, THEN THE Meshtastic_Service SHALL report a "no devices found" state and allow the user to initiate a new scan

### Requirement 2: Meshtastic Messaging

**User Story:** As a golf cart operator, I want to send and receive text messages via the Meshtastic mesh network, so that I can communicate with other mesh users.

#### Acceptance Criteria

1. WHEN a text message is received via Meshtastic, THE GCD SHALL display the message with sender node ID in hex format (e.g., `!a1b2c3d4`), channel number, and timestamp in 12-hour format with AM/PM matching the system time display
2. THE GCD SHALL accept incoming messages addressed to the broadcast destination (`0xFFFFFFFF`) or to the local node number, and SHALL discard messages addressed to other nodes
3. THE GCD SHALL support sending text messages to broadcast address on any configured channel (channels 0 through 7)
4. THE GCD SHALL support sending direct messages to specific node numbers
5. THE GCD SHALL support sending preformatted messages selectable from a configurable list of up to 20 entries
6. THE GCD SHALL support composing custom text messages via on-screen keyboard
7. IF the composed message payload exceeds 237 bytes when encoded as UTF-8, THEN THE GCD SHALL prevent sending and display a character/byte count indicator showing current size relative to the 237-byte limit
8. WHEN the Meshtastic connection is first established, THE GCD SHALL send an AWAKE notification message (`~#01#GC#AWAKE#`) on channel 0 to broadcast address
9. THE GCD SHALL encode text messages using the `TEXT_MESSAGE_APP` port number (1) for transmission
10. WHEN a new message is received and speaker volume is greater than zero, THE GCD SHALL play an audible notification tone
11. THE GCD SHALL retain up to 100 received messages in the message history, discarding the oldest message when the limit is exceeded
12. IF the Meshtastic connection is not established when the user attempts to send a message, THEN THE GCD SHALL reject the send attempt and display an error message indicating no connection is available

### Requirement 3: Weather Data Reception and Display

**User Story:** As a golf cart operator, I want to receive and display weather forecasts via Meshtastic, so that I can check the weather without using my phone.

#### Acceptance Criteria

1. WHEN a HoT_Packet with type `01` (weather) is received, THE Hot_Packet_Parser SHALL parse the weather data
2. THE Hot_Packet_Parser SHALL validate weather packets contain exactly 7 `#` delimiters and 12 `,` delimiters before parsing
3. THE Hot_Packet_Parser SHALL parse the weather packet format: `|#01#<current_temp>#<hr>,<glyph>,<temp>,<precip>#<hr>,<glyph>,<temp>,<precip>#<hr>,<glyph>,<temp>,<precip>#<hr>,<glyph>,<temp>,<precip>#`
4. THE GCD SHALL display current temperature and 4-hour forecast with hour label, weather glyph icon, temperature, and precipitation probability for each hour
5. THE GCD SHALL display the timestamp of when weather data was last received in 12-hour format with AM/PM indicator (e.g., "2:35 PM")
6. THE GCD SHALL persist weather data to local storage with the date received in YYYYMMDD format
7. WHEN the app starts and no live weather data has been received, THE GCD SHALL load stored weather data if it is from the current day
8. IF stored weather data is from a previous day or absent, THEN THE GCD SHALL send a request message (`~#01#GC#REQ_WX_ENT#`) on channel 0 to broadcast address to request fresh weather and entertainment data
9. THE Hot_Packet_Parser SHALL validate temperature fields are integer values within range -99 to 999 degrees
10. THE Hot_Packet_Parser SHALL validate hour labels are 6 characters or fewer
11. THE Hot_Packet_Parser SHALL validate precipitation values are numeric in the range 0.0 to 100.0
12. THE Hot_Packet_Parser SHALL replace zero precipitation values (`0.0`) with an empty string so that no text is displayed for the precipitation field of that hour
13. THE Hot_Packet_Parser SHALL validate glyph fields are 10 characters or fewer
14. IF a weather packet fails delimiter count validation or any field fails validation (temperature range, hour label length, precipitation range, or glyph length), THEN THE Hot_Packet_Parser SHALL discard the entire packet and log a diagnostic message identifying the validation failure

### Requirement 4: Venue and Event Entertainment Display

**User Story:** As a golf cart operator in The Villages, I want to see today's entertainment schedule at local venues, so that I can plan my evening activities.

#### Acceptance Criteria

1. WHEN a HoT_Packet with type `02` (venue/event) is received, THE Hot_Packet_Parser SHALL parse the venue and event data
2. THE Hot_Packet_Parser SHALL parse the venue/event packet format: `|#02#<venue>,<event>#<venue>,<event>#...#` where each venue-event pair is separated by `#` and venue name is separated from event name by the first `,` in each pair (subsequent commas are part of the event name)
3. THE Hot_Packet_Parser SHALL validate that a venue/event packet contains at least 1 venue-event pair and that each pair contains at least one `,` delimiter separating a non-empty venue name from a non-empty event name
4. IF a venue/event packet is malformed or contains no valid venue-event pairs, THEN THE Hot_Packet_Parser SHALL discard the packet and log a diagnostic message
5. THE GCD SHALL display venue/event data in a scrollable two-column table with venue names in column 1 and event names in column 2
6. THE GCD SHALL display up to 12 venue/event entries; IF a packet contains more than 12 pairs, THEN THE GCD SHALL display only the first 12 entries
7. THE GCD SHALL display the timestamp when venue/event data was last received in 12-hour format with AM/PM indicator
8. THE GCD SHALL persist venue/event data to local storage with the date received in YYYYMMDD format
9. WHEN the app starts and no live venue/event data has been received, THE GCD SHALL load stored venue/event data if the stored date matches the current GPS date (or device date if GPS is unavailable)
10. IF stored venue/event data is from a previous day or absent, THEN THE GCD SHALL display an empty entertainment screen until fresh data is received
11. WHEN new venue/event data is received while the entertainment screen is active, THE GCD SHALL refresh the display with the updated data within 1 second

### Requirement 5: GPS and Navigation

**User Story:** As a golf cart operator, I want to see my current speed, heading, and location, so that I can navigate safely.

#### Acceptance Criteria

1. THE GCD SHALL obtain GPS data from the device's internal GPS sensor using a cross-platform location plugin (geolocator) at a 1-second update interval
2. THE GCD SHALL also support receiving GPS position data from the connected Meshtastic radio, using the internal GPS sensor as the primary source and falling back to Meshtastic GPS data when the internal sensor is unavailable or reports zero satellites
3. THE GCD SHALL display current speed in miles per hour as an integer value (rounded down), ranging from 0 to 99
4. THE GCD SHALL filter GPS speed values below 2.5 mph to zero to eliminate GPS dither when stationary
5. IF a speed reading exceeds the previous reading by more than 8 mph per second of elapsed time, THEN THE GCD SHALL discard the reading and retain the last accepted speed value
6. WHEN speed is below 4 mph and decreasing, THE GCD SHALL report speed as zero for responsive stop detection
7. THE GCD SHALL require 2 consecutive speed readings above the 2.5 mph stationary threshold before reporting movement (3 consecutive when screen is dimmed)
8. THE GCD SHALL display compass heading as a 16-point cardinal direction (N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW)
9. THE GCD SHALL display current latitude and longitude coordinates to 6 decimal places
10. THE GCD SHALL display satellite count and HDOP (Horizontal Dilution of Precision) value in format "sats/hdop" (e.g., "8/1.50") with HDOP shown to 2 decimal places
11. THE GCD SHALL require 3 consecutive zero-satellite readings before displaying zero satellite count to prevent display flicker during brief signal dropouts
12. THE GCD SHALL estimate HDOP from satellite count when direct HDOP data is unavailable: 6 or more sats = 1.5, 4-5 sats = 2.0, fewer than 4 sats = 99.0
13. THE GCD SHALL display current date in format `Day, Mon DD` (e.g., "Mon, Jan 15")
14. THE GCD SHALL display current time in 12-hour format with AM/PM indicator
15. THE GCD SHALL convert GPS time (UTC) to local time using the device's configured timezone, including automatic daylight saving time transitions
16. IF no GPS time update is received for 60 seconds, THEN THE GCD SHALL display "NO GPS" for the date field
17. THE GCD SHALL calculate sunrise and sunset times based on current GPS location and date
18. THE GCD SHALL display sunrise and sunset times in 12-hour format
19. WHEN GPS speed is invalid but location is valid and last known speed was below 5 mph, THE GCD SHALL report speed as zero; otherwise retain last known speed to avoid jarring display changes during brief signal loss
20. THE GCD SHALL request platform-appropriate location permissions: ACCESS_FINE_LOCATION on Android, and "When In Use" location authorization on iOS

### Requirement 6: Odometer and Distance Tracking

**User Story:** As a golf cart operator, I want to track total distance traveled and trip distance, so that I can monitor usage and plan maintenance.

#### Acceptance Criteria

1. THE GCD SHALL accumulate total distance traveled (odometer) using GPS position-based calculation
2. THE GCD SHALL maintain a resettable trip odometer that the user can reset to 0.0 via a dedicated control on the main display or configuration screen
3. THE GCD SHALL display both odometer and trip odometer with 1 decimal place precision in miles, ranging from 0.0 to 99,999.9
4. THE GCD SHALL only accumulate distance when filtered speed is greater than zero (Doppler speed gating as primary gate)
5. THE GCD SHALL require position change of at least 2.6 feet (0.0005 miles) minimum before accumulating distance when Doppler speed confirms motion
6. IF Doppler speed data is unavailable, THEN THE GCD SHALL use a fallback minimum distance threshold of 10 feet (0.002 miles) before accumulating
7. IF a position-based speed calculation exceeds 30 mph, THEN THE GCD SHALL discard that position update entirely and not accumulate any distance for that GPS sample
8. WHEN the odometer reaches 100,000.0 miles, THE GCD SHALL roll over the odometer to 0.0
9. THE GCD SHALL persist both odometer and trip odometer values to local storage every 0.5 miles of travel
10. THE GCD SHALL persist both odometer and trip odometer values to local storage before entering sleep or shutdown
11. WHEN the app starts, THE GCD SHALL load persisted odometer and trip odometer values from local storage
12. IF persisted odometer data is missing or unreadable on startup, THEN THE GCD SHALL initialize both odometer and trip odometer to 0.0
13. THE GCD SHALL roll over the trip odometer at 10,000.0 miles to 0.0

### Requirement 7: Service Reminder and Maintenance Tracking

**User Story:** As a golf cart operator, I want to track driving hours since last service, so that I know when maintenance is due.

#### Acceptance Criteria

1. THE GCD SHALL accumulate driving hours only when the vehicle is in motion (filtered speed greater than zero)
2. THE GCD SHALL store driving hours in tenths of hours (6-minute resolution)
3. THE GCD SHALL use GPS time as the primary time source for hour accumulation
4. IF GPS time is unavailable, THEN THE GCD SHALL fall back to system clock for hour accumulation
5. THE GCD SHALL only accept time deltas greater than 0 and less than or equal to 10 seconds to filter GPS glitches and device reboots
6. THE GCD SHALL display hours since last service with 1 decimal place precision (e.g., "45.3 hours")
7. THE GCD SHALL provide a configurable service interval with a range of 1 to 500 hours (default: 100 hours)
8. THE GCD SHALL persist driving hours to local storage every 1.0 hours of driving
9. WHEN the user initiates a service hour counter reset, THE GCD SHALL require a confirmation action before resetting the counter to zero
10. WHEN accumulated driving hours reach or exceed the configured service interval, THE GCD SHALL display a visual service-due indicator on the main screen

### Requirement 8: GCI Telemetry Connection

**User Story:** As a golf cart operator, I want the app to receive vehicle telemetry data from the GCI computer via Bluetooth, so that I can monitor battery voltage, fuel level, and temperature.

#### Acceptance Criteria

1. THE Telemetry_Service SHALL connect to the GCI ESP-32 computer via Bluetooth (Classic SPP or BLE depending on platform capability)
2. THE Telemetry_Service SHALL receive telemetry data packets containing: headlight mode (int), outdoor luminosity (int), air temperature (float), battery voltage (float), and fuel level (float) using a 20-byte little-endian binary payload within the GCI message envelope (9-byte header: type 1 byte, timestamp 4 bytes, sequence number 2 bytes, data length 2 bytes)
3. THE GCD SHALL display battery voltage with 1 decimal place precision in volts (e.g., "48.2V")
4. THE GCD SHALL display fuel level as an integer percentage (e.g., "75%")
5. THE GCD SHALL display outdoor air temperature as an integer value in degrees Fahrenheit, adjusted by a user-configurable temperature offset in the range -20 to +20 degrees (default: 0)
6. THE GCD SHALL display headlight mode status as a numeric mode indicator reflecting the integer value received from the GCI
7. THE Telemetry_Service SHALL send periodic heartbeat messages every 10 seconds to maintain connection
8. IF no heartbeat response is received from GCI within 40 seconds (4 missed heartbeats), THEN THE Telemetry_Service SHALL mark the GCI as disconnected
9. THE Telemetry_Service SHALL support pairing with a new GCI device via a broadcast discovery mechanism with a 6-second pairing timeout window
10. WHEN pairing is initiated, THE Telemetry_Service SHALL broadcast a pairing command containing the device MAC address (6 bytes) and command code, and wait for an ACK response from the GCI within the 6-second timeout window
11. IF no ACK is received within the 6-second pairing window, THEN THE Telemetry_Service SHALL restore the previously paired device address (if any)
12. THE Telemetry_Service SHALL persist the paired GCI device address for automatic reconnection
13. WHEN the GCI connection is established, THE GCD SHALL send current "at home" and "is daytime" status to the GCI as single-byte boolean payloads (1 = true, 0 = false)
14. WHEN the "at home" or "is daytime" status changes, THE GCD SHALL notify the GCI of the change
15. THE Telemetry_Service SHALL send GPS data (latitude, longitude, altitude, speed, heading, satellite count as a 24-byte little-endian payload) to the GCI at the same interval as the Meshtastic radio GPS update rate (8 seconds when away from home, 120 seconds when at home)
16. IF the GCI connection is lost unexpectedly, THEN THE Telemetry_Service SHALL attempt automatic reconnection every 10 seconds until the connection is re-established or the user initiates a new pairing
17. IF a received telemetry packet payload is fewer than 20 bytes, THEN THE Telemetry_Service SHALL discard the packet and retain the last valid telemetry values on display

### Requirement 9: Home Location and Geofencing

**User Story:** As a golf cart operator, I want to set my home location and know when I am within my home area, so that the system can adjust behavior (like GPS update frequency) based on whether I am home or away.

#### Acceptance Criteria

1. THE GCD SHALL allow the user to set the current GPS position as the home location
2. THE GCD SHALL allow the user to clear the saved home location
3. THE GCD SHALL provide a configurable geofence radius with a minimum of 100 meters, a maximum of 5000 meters, and a default of 500 meters
4. WHILE a home location is set, THE GCD SHALL recalculate distance from current position to home location on each GPS position update
5. WHEN the calculated distance from home transitions from greater than the geofence radius to less than or equal to the geofence radius minus 50 meters (hysteresis band), THE GCD SHALL set the "at home" status to true and notify the GCI
6. WHEN the calculated distance from home transitions from less than or equal to the geofence radius to greater than the geofence radius plus 50 meters (hysteresis band), THE GCD SHALL set the "at home" status to false and notify the GCI
7. THE GCD SHALL persist home location coordinates to local storage
8. IF GPS is not available when the user attempts to set home location, THEN THE GCD SHALL reject the request and display an error message indicating that GPS is required
9. WHEN the app starts with a persisted home location, THE GCD SHALL evaluate the current GPS position against the geofence and set the initial "at home" status accordingly before notifying the GCI
10. IF no home location is set, THEN THE GCD SHALL default the "at home" status to false and skip geofence calculations

### Requirement 10: Display Brightness Management

**User Story:** As a golf cart operator, I want the display brightness to automatically adjust based on time of day, so that the screen is readable in daylight and not blinding at night.

#### Acceptance Criteria

1. WHILE the current time is between sunrise and sunset, THE Brightness_Manager SHALL set display brightness to the configured day brightness level
2. WHILE the current time is between sunset and sunrise, THE Brightness_Manager SHALL set display brightness to the configured night brightness level
3. THE GCD SHALL provide separate configurable brightness levels for day and night (range 0-10 integer scale, default day: 8, default night: 3)
4. THE GCD SHALL provide a configurable inactivity timeout for screen dimming (range 0-60 minutes in 1-minute increments, default: 5 minutes)
5. WHEN no touch input or GPS-based movement (speed greater than zero) is detected for the configured timeout period, THE Brightness_Manager SHALL dim the display to off
6. WHEN touch input or GPS-based movement (speed greater than zero) is detected while the display is dimmed, THE Brightness_Manager SHALL restore the display to the day or night brightness level based on the current time relative to sunrise and sunset
7. IF the inactivity timeout is set to 0, THEN THE Brightness_Manager SHALL disable automatic dimming and keep the display at the current day or night brightness level indefinitely
8. THE Brightness_Manager SHALL use platform-appropriate APIs to control screen brightness on both Android and iOS
9. IF sunrise and sunset times are unavailable due to lack of GPS fix, THEN THE Brightness_Manager SHALL use the day brightness level as the default until sunrise and sunset times can be calculated

### Requirement 11: Power and Sleep Management

**User Story:** As a golf cart operator, I want the app to manage power efficiently, so that it does not drain the device battery unnecessarily when the cart is parked.

#### Acceptance Criteria

1. THE Sleep_Manager SHALL implement a three-state power management system with the following states and transitions: STARTUP_GRACE (initial state), GCI_MODE (entered when GCI connects), and STANDALONE_MODE (entered when grace period expires without GCI or when GCI disconnects for the timeout period); transition from STANDALONE_MODE back to GCI_MODE SHALL occur when the GCI reconnects
2. THE Sleep_Manager SHALL implement a startup grace period equal to the backlight timeout setting (minimum 30 seconds) to allow the GCI to connect before determining operating mode
3. WHEN the GCI connects and communicates, THE Sleep_Manager SHALL operate in GCI_MODE where the display remains at the active brightness level for as long as the GCI connection is maintained
4. WHEN the GCI has never connected and the startup grace period expires, THE Sleep_Manager SHALL transition to STANDALONE_MODE where the display dims per the backlight timeout setting but the system never enters deep sleep
5. IF the GCI was previously connected during the current session but has since disconnected for the backlight timeout period (minimum 30 seconds), THEN THE Sleep_Manager SHALL transition to STANDALONE_MODE
6. WHILE in STANDALONE_MODE, THE Sleep_Manager SHALL set the Meshtastic radio GPS update interval to 120 seconds when at_home status is true and 8 seconds when at_home status is false
7. WHEN the app is about to enter the background or shut down, THE Sleep_Manager SHALL persist odometer and driving hour values to local storage before the transition completes
8. THE GCD SHALL provide a manual restart option in the configuration screen that restarts the application and resets the Sleep_Manager to the STARTUP_GRACE state
9. THE Sleep_Manager SHALL use platform-appropriate background execution mechanisms to maintain Bluetooth connectivity when the app is backgrounded

### Requirement 12: Meshtastic Radio Administration

**User Story:** As a golf cart operator, I want to configure and manage my Meshtastic radio from the app, so that I can adjust settings without a separate computer.

#### Acceptance Criteria

1. THE GCD SHALL display the connected Meshtastic radio's node ID in hex format (e.g., `!a1b2c3d4`)
2. WHEN the user initiates a reboot command from the configuration screen, THE GCD SHALL send a reboot admin command to the Meshtastic radio with a 5-second delay and display a confirmation prompt before sending
3. WHEN the Meshtastic BLE connection handshake receives a `config` message of type PositionConfig, THE GCD SHALL extract and store the position configuration for use in subsequent read-modify-write operations
4. THE GCD SHALL support setting the GPS update interval on the Meshtastic radio with values of 8 seconds when away from home and 120 seconds when at home
5. WHEN updating radio configuration, THE GCD SHALL use a read-modify-write pattern that modifies only the target field in the stored PositionConfig and preserves all other fields unchanged
6. THE GCD SHALL encode admin commands using the `ADMIN_APP` port number with protobuf `AdminMessage` format, addressed to the local node number
7. WHEN the user disables the Meshtastic connection from the configuration screen, THE GCD SHALL disconnect from the radio and suppress automatic reconnection until re-enabled
8. WHEN the "at home" status changes while the Meshtastic radio is connected, THE GCD SHALL send an updated GPS interval configuration to the radio (120 seconds at home, 8 seconds away)
9. IF an admin command fails due to BLE disconnection or no response within 10 seconds, THEN THE GCD SHALL display an error message indicating the command was not completed

### Requirement 13: User Interface and Navigation

**User Story:** As a golf cart operator, I want a clean, widget-based main display with easy access to configuration, so that I can see important information at a glance while driving.

#### Acceptance Criteria

1. THE GCD SHALL provide a main display screen with widgets showing: speed, heading, time, date, temperature, satellite/HDOP info, and connection status indicators, where widget visibility is configurable by the user
2. THE GCD SHALL provide a weather forecast screen showing current temperature and 4-hour forecast
3. THE GCD SHALL provide a venue/event entertainment screen showing today's schedule in a scrollable table
4. THE GCD SHALL provide a configuration screen accessible from the main display via a single tap or swipe gesture that does not obscure the main display content until activated
5. THE GCD SHALL provide configuration controls for: day brightness, night brightness, speaker volume, screen flip, backlight timeout, temperature offset, service interval, home location, GCI pairing, and Meshtastic enable/disable
6. THE GCD SHALL display connection status indicators for both Meshtastic and GCI connections, showing at minimum three distinct visual states: connected, disconnected, and connecting
7. THE GCD SHALL display the app version string on the configuration screen
8. THE GCD SHALL display the device identifier on the configuration screen
9. THE GCD SHALL support screen rotation (flip) configurable by the user
10. WHEN fresh weather or entertainment data is received, THE GCD SHALL display a "new data received" visual indicator distinguishable from static UI elements
11. THE GCD SHALL auto-clear the "new data received" indicator after 5 seconds
12. THE GCD SHALL render the UI using Flutter widgets with Material Design 3 theming, using platform-adaptive components where provided by Flutter's adaptive APIs
13. THE GCD SHALL maintain identical screen layout, widget placement, and feature availability across Android and iOS platforms
14. THE GCD SHALL support navigation between the main display, weather forecast, venue/event entertainment, and configuration screens, with all screens reachable within 2 taps from the main display
15. THE GCD SHALL size all main display widgets with touch targets of at least 48x48 density-independent pixels to ensure readability and tap accuracy while driving

### Requirement 14: Audio Feedback

**User Story:** As a golf cart operator, I want audible feedback for important events, so that I am alerted to new messages and system events without looking at the screen.

#### Acceptance Criteria

1. WHEN the application launches, THE GCD SHALL play a startup tone
2. WHEN a new Meshtastic message is received, THE GCD SHALL play a message notification tone
3. WHEN new weather or venue/event HoT_Packet data is received, THE GCD SHALL play an alert tone
4. WHEN a user action completes successfully (setting home location, resetting trip odometer, resetting service hours, completing GCI pairing), THE GCD SHALL play a confirmation tone
5. WHEN a button or interactive control is pressed, THE GCD SHALL play a click tone
6. IF a user-initiated operation fails (GCI pairing timeout, home location set with no GPS, message send failure), THEN THE GCD SHALL play an error tone
7. THE GCD SHALL use audibly distinct tones for each audio event category (startup, notification, alert, confirmation, click, error)
8. THE GCD SHALL provide a configurable speaker volume level with integer steps from 0 to 20
9. IF the speaker volume is set to 0, THEN THE GCD SHALL suppress all audio playback
10. THE GCD SHALL persist the speaker volume setting to local storage
11. THE GCD SHALL use a cross-platform audio plugin (audioplayers or just_audio) for sound playback on both Android and iOS

### Requirement 15: Persistent Configuration Storage

**User Story:** As a golf cart operator, I want my settings to be saved between app restarts, so that I do not have to reconfigure the app every time.

#### Acceptance Criteria

1. THE GCD SHALL persist the following settings to local storage: day brightness, night brightness, speaker volume, screen flip, backlight timeout, temperature offset, service interval hours, GCI device address, home location coordinates, home geofence radius, Meshtastic enabled flag, Meshtastic device identifier
2. WHEN the application starts, THE GCD SHALL load all persisted settings before initializing dependent components (Brightness_Manager, Sleep_Manager, Telemetry_Service, Meshtastic_Service)
3. THE GCD SHALL debounce writes to persistent storage by 2 seconds for slider/spinner values to reduce storage wear
4. WHEN the user activates the "reset all preferences" option, THE GCD SHALL clear all persisted user-configurable settings (brightness, volume, screen flip, backlight timeout, temperature offset, service interval, home location, geofence radius, Meshtastic enabled flag, Meshtastic device identifier, GCI device address) while preserving operational data (odometer values, trip odometer, driving hours), then restart the application
5. THE GCD SHALL persist weather data, venue/event data, and their timestamps for same-day cache restoration
6. THE GCD SHALL persist odometer values, trip odometer values, and driving hours
7. THE GCD SHALL use a cross-platform persistence solution (shared_preferences or hive) that works identically on Android and iOS
8. IF persisted settings data is corrupted or unreadable, THEN THE GCD SHALL discard the corrupted entries, apply default values for the affected settings, and continue startup without error
9. WHEN no persisted value exists for a setting (first launch or after reset), THE GCD SHALL apply the following defaults: day brightness 7, night brightness 3, speaker volume 10, screen flip disabled, backlight timeout 5 minutes, temperature offset 0, service interval 100 hours, home geofence radius 500 meters, Meshtastic enabled false

### Requirement 16: Flutter Project Architecture and Repository Setup

**User Story:** As a developer, I want the Flutter project repository to be properly set up with best-practice tooling, automation, and documentation before any feature coding begins, so that the project is maintainable, professional, and welcoming to contributors.

#### Acceptance Criteria

1. THE Repository SHALL use Flutter (minimum SDK 3.22.0) with Dart as the primary language targeting both Android and iOS platforms
2. THE Repository SHALL use the `flutter_riverpod` package for state management and dependency injection
3. THE Repository SHALL structure the project using the following directory layout under `lib/`: `presentation/` (widgets and screens), `application/` (state notifiers and controllers), `domain/` (models and business logic), and `data/` (repositories and services)
4. THE Repository SHALL include protobuf code generation using the `protoc` compiler with the Dart plugin, with a documented build script or Makefile target that generates Dart classes from Meshtastic `.proto` definition files stored in a `proto/` directory
5. THE Repository SHALL include a root README.md containing the following sections: project overview, setup instructions, architecture summary, platform-specific build notes, GitHub badges (license, language, build status, Flutter version), and references to detailed documentation in a `docs/` folder
6. THE Repository SHALL include a CONTRIBUTING.md with coding standards, branch naming conventions, PR process, and development setup instructions
7. THE Repository SHALL include a CHANGELOG.md changelog following Keep a Changelog format with an initial `[Unreleased]` section
8. THE Repository SHALL include a GNU General Public License v3 (GPL-3.0) license file
9. THE Repository SHALL follow semantic versioning (MAJOR.MINOR.PATCH) starting at version 0.1.0
10. THE Repository SHALL include a `.gitignore` file covering Flutter/Dart generated files, IDE files, build outputs, and platform-specific artifacts
11. THE Repository SHALL include platform-specific configuration for Android (AndroidManifest.xml with Bluetooth and Location permissions, minSdkVersion 21) and iOS (Info.plist with NSBluetoothAlwaysUsageDescription and NSLocationWhenInUseUsageDescription keys)
12. THE Repository SHALL include a Renovate configuration file (`renovate.json`) for automated dependency updates
13. THE Repository SHALL include a Dependabot configuration file (`.github/dependabot.yml`) for GitHub security updates with a weekly check schedule
14. THE Repository SHALL use the `flutter_blue_plus` or `flutter_reactive_ble` package for BLE communication
15. THE Repository SHALL use the `geolocator` package for cross-platform GPS access
16. THE Repository SHALL use the `protobuf` Dart package for Meshtastic protocol buffer message handling
17. THE Repository SHALL include an `analysis_options.yaml` file configured with the `flutter_lints` package for static analysis
18. THE Repository SHALL include a GitHub Actions CI workflow that runs `flutter analyze` and `flutter test` on pull requests
19. THE Repository SHALL verify setup completeness by passing `flutter analyze` with zero errors and `flutter test` executing without build failures before feature implementation begins

### Requirement 17: Dual Bluetooth Connection Management

**User Story:** As a golf cart operator, I want the app to maintain simultaneous Bluetooth connections to both the Meshtastic radio and the GCI telemetry computer, so that all features work together seamlessly.

#### Acceptance Criteria

1. THE GCD SHALL support two simultaneous Bluetooth connections: one BLE connection to the Meshtastic radio and one connection to the GCI
2. THE GCD SHALL manage each Bluetooth connection independently with separate connection state tracking using the following states: Disconnected, Connecting, Connected, and Reconnecting
3. IF the Meshtastic BLE connection is lost, THEN THE Meshtastic_Service SHALL attempt automatic reconnection using exponential backoff starting at 2 seconds, doubling up to a maximum interval of 60 seconds, without affecting the GCI connection
4. IF the GCI Bluetooth connection is lost, THEN THE Telemetry_Service SHALL attempt automatic reconnection using exponential backoff starting at 2 seconds, doubling up to a maximum interval of 60 seconds, without affecting the Meshtastic connection
5. THE GCD SHALL display independent connection status indicators for each Bluetooth connection, reflecting the current state (Disconnected, Connecting, Connected, or Reconnecting)
6. THE GCD SHALL request all necessary Bluetooth permissions at runtime before attempting any Bluetooth operations, providing user-facing rationale text explaining why each permission is needed, on both Android and iOS
7. THE GCD SHALL use BLE for the GCI connection on iOS and prefer Bluetooth Classic SPP for the GCI connection on Android
8. IF Bluetooth Classic SPP connection to the GCI fails on Android or is unavailable, THEN THE Telemetry_Service SHALL fall back to BLE for the GCI connection
9. IF the user denies a required Bluetooth permission, THEN THE GCD SHALL display the affected connection as Disconnected and show a message indicating which features are unavailable until the permission is granted

### Requirement 18: Meshtastic Protocol Implementation Details

**User Story:** As a developer, I want the Meshtastic BLE protocol implementation to be fully documented and correctly implemented in Dart, so that the app can communicate correctly with the radio.

#### Acceptance Criteria

1. THE Meshtastic_Service SHALL implement the following BLE GATT interaction pattern: subscribe to FROMNUM notifications, then write `ToRadio` packets to TORADIO characteristic, then poll FROMRADIO characteristic when FROMNUM notification arrives until a zero-length (empty) response is returned indicating no more data is queued
2. THE Packet_Framer SHALL frame `ToRadio` protobuf messages with a 4-byte big-endian length prefix encoding the payload size (not including the prefix itself) before writing to the TORADIO characteristic
3. IF the Packet_Framer receives framed data shorter than 4 bytes or the length prefix indicates more bytes than are available in the buffer, THEN THE Packet_Framer SHALL discard the data and report a framing error
4. THE Meshtastic_Service SHALL handle MTU negotiation and split large packets if the framed write value length exceeds the negotiated MTU minus 3 bytes (default safe payload: 20 bytes without MTU negotiation), writing each chunk sequentially to the TORADIO characteristic
5. WHILE the handshake is in progress, THE Meshtastic_Service SHALL process the following `FromRadio` message types: `my_info` (extract local node number), `config` (read radio configuration including position config), and `config_complete_id` (handshake complete when the returned value matches the `want_config_id` that was sent)
6. WHEN a `my_info` message is received during handshake, THE Meshtastic_Service SHALL extract the local node number and store it for use in addressing outbound packets and filtering inbound packets
7. WHEN an incoming `FromRadio` message contains a `MeshPacket` with a decoded `Data` payload, THE Meshtastic_Service SHALL route it based on `portnum`: `TEXT_MESSAGE_APP` (1) for text messages, `ADMIN_APP` (6) for admin responses, `POSITION_APP` (3) for position data, `TELEMETRY_APP` (67) for node telemetry; packets with unrecognized port numbers SHALL be discarded
8. THE Meshtastic_Service SHALL construct outbound `MeshPacket` messages with: a non-zero random packet ID (required for Meshtastic deduplication), destination node number (fixed32), channel index (varint), decoded payload with appropriate port number, and payload bytes not exceeding 237 bytes
9. THE Meshtastic_Service SHALL wrap outbound `MeshPacket` in a `ToRadio` message using the `packet` variant (field tag 1, length-delimited)
10. THE GCD SHALL include all necessary Meshtastic `.proto` files: `mesh.proto`, `admin.proto`, `config.proto`, `portnums.proto`, `telemetry.proto`, `module_config.proto`, `channel.proto`, and supporting definitions
11. THE GCD SHALL generate Dart classes from `.proto` files using the `protoc` compiler with the `protoc-gen-dart` plugin

### Requirement 19: Data Synchronization and Caching

**User Story:** As a golf cart operator, I want the app to cache received data and restore it on restart, so that I see the latest information immediately without waiting for new transmissions.

#### Acceptance Criteria

1. WHEN weather data is received and GPS time is available (received within the last 60 seconds), THE GCD SHALL persist the raw packet data, parsed GPS timestamp, and current date (YYYYMMDD format) to local storage
2. WHEN venue/event data is received and GPS time is available (received within the last 60 seconds), THE GCD SHALL persist the raw packet data, parsed GPS timestamp, and current date (YYYYMMDD format) to local storage
3. WHEN the app starts and GPS time becomes available, THE GCD SHALL validate cached weather and venue/event data independently by comparing each stored date against the current GPS date
4. IF the stored date matches the current GPS date, THEN THE GCD SHALL restore the cached data and display it with a "(stored)" indicator
5. IF the stored date does not match the current GPS date, THEN THE GCD SHALL discard the stale cache and send a fresh data request (`~#01#GC#REQ_WX_ENT#`)
6. WHEN fresh weather or venue/event data is received to replace cached data, THE GCD SHALL remove the "(stored)" indicator and display the live GPS timestamp of the new data
7. IF GPS time has not become available within 30 seconds of app start, THEN THE GCD SHALL restore any existing cached data with a "(stored)" indicator regardless of date validation, and perform date validation once GPS time is subsequently acquired

### Requirement 20: Cross-Platform Background Connectivity

**User Story:** As a golf cart operator, I want the Bluetooth connections to remain active when the app is in the background or the screen is off, so that I continue receiving messages and telemetry data.

#### Acceptance Criteria

1. WHILE the app is backgrounded or the screen is off, THE GCD SHALL maintain BLE connections to the Meshtastic radio and the GCI telemetry connection on both Android and iOS
2. WHERE the platform is Android, THE GCD SHALL use a foreground service with a persistent notification to maintain Bluetooth connectivity in the background
3. WHERE the platform is iOS, THE GCD SHALL declare the `bluetooth-central` background mode in Info.plist to maintain BLE connections when backgrounded
4. WHEN the app returns to the foreground, THE GCD SHALL resume displaying live data from active Bluetooth connections and restore the last-viewed screen within 2 seconds
5. IF the operating system terminates background Bluetooth connections, THEN THE GCD SHALL attempt reconnection within 5 seconds of the app returning to the foreground, using the same reconnection logic defined in Requirements 1 and 8
6. WHILE the app is backgrounded, THE GCD SHALL continue processing incoming Meshtastic messages and GCI telemetry data so that no messages are lost during the background period
7. THE GCD SHALL use platform channels or conditional imports to implement platform-specific background execution strategies
8. WHERE the platform is iOS, THE GCD SHALL declare the `location` background mode in Info.plist to continue receiving GPS updates when backgrounded (required for odometer and geofence functionality)

### Requirement 21: Cross-Platform Permission Handling

**User Story:** As a golf cart operator, I want the app to request necessary permissions in a platform-appropriate way, so that all features work correctly on both Android and iOS.

#### Acceptance Criteria

1. THE GCD SHALL request Bluetooth permissions before attempting any Bluetooth operations: BLUETOOTH_SCAN and BLUETOOTH_CONNECT on Android 12+, BLUETOOTH and BLUETOOTH_ADMIN on older Android, and CBCentralManager authorization on iOS
2. THE GCD SHALL request location permissions before accessing GPS: ACCESS_FINE_LOCATION on Android, "When In Use" or "Always" location authorization on iOS
3. WHEN requesting a permission for the first time, THE GCD SHALL display a rationale dialog stating the specific feature that requires the permission and the consequence of denying it, before invoking the system permission prompt
4. IF a required permission is denied, THEN THE GCD SHALL display a message identifying which feature is unavailable due to the denied permission and provide a button that opens the system settings page for the app
5. IF a permission is in the "Don't ask again" state on Android (permanently denied), THEN THE GCD SHALL display a message identifying the affected feature and provide a button that opens the system settings page for the app instead of re-prompting the system dialog
6. IF an iOS permission state is "Not Determined", THEN THE GCD SHALL present the system permission prompt; IF the state is "Restricted", THEN THE GCD SHALL display a message indicating the permission is controlled by device restrictions and cannot be granted by the user; IF the state is "Denied", THEN THE GCD SHALL display a message identifying the affected feature and provide a button to open system settings; IF the state is "Authorized", THEN THE GCD SHALL proceed with the protected operation
7. THE GCD SHALL use the `permission_handler` Flutter package for unified cross-platform permission management
8. WHERE the platform is Android, THE GCD SHALL include all required permissions in AndroidManifest.xml: BLUETOOTH, BLUETOOTH_ADMIN, BLUETOOTH_SCAN, BLUETOOTH_CONNECT, ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION, FOREGROUND_SERVICE, and WAKE_LOCK
9. WHERE the platform is iOS, THE GCD SHALL include usage description strings in Info.plist for: NSBluetoothAlwaysUsageDescription, NSBluetoothPeripheralUsageDescription, NSLocationWhenInUseUsageDescription, and NSLocationAlwaysAndWhenInUseUsageDescription
10. THE GCD SHALL request each permission only at the point of first use of the feature requiring it, not at application startup
11. WHEN a previously denied permission is later granted via system settings and the app returns to the foreground, THE GCD SHALL detect the updated permission state and enable the corresponding feature without requiring an app restart

### Requirement 22: Project Documentation

**User Story:** As a developer or potential contributor, I want comprehensive project documentation in a dedicated docs folder, so that I can understand the project's architecture, build process, features, and future direction without reading source code.

#### Acceptance Criteria

1. THE Repository SHALL include a `docs/` folder containing all project documentation files in markdown format
2. THE Repository SHALL include a `docs/README.md` that serves as an index listing every documentation file in the docs folder, where each entry includes the filename as a relative markdown link and a one-sentence description of what the document covers
3. THE Repository SHALL include a `docs/build-guide.md` containing sections for: prerequisites (required software and versions), environment setup steps for both Android and iOS, protobuf code generation steps using `protoc` with the Dart plugin, and a troubleshooting section with at least 3 common build issues and their resolutions
4. THE Repository SHALL include a `docs/design.md` containing sections for: architecture overview with at least one text-based diagram (Mermaid or ASCII), component interactions describing how presentation, application, domain, and data layers communicate, data flow for Bluetooth connections, state management patterns using Riverpod, and key design decisions with rationale
5. THE Repository SHALL include a `docs/developer-guide.md` containing sections for: code organization describing the folder structure, naming conventions, how to add a new feature (step-by-step), Bluetooth communication protocol details for both Meshtastic BLE and GCI connections, protobuf message formats, testing instructions, and debugging tips
6. THE Repository SHALL include a `docs/features.md` listing all application features grouped by functional category (connectivity, navigation, telemetry, messaging, display management, configuration) with a description of each feature's user-facing behavior
7. THE Repository SHALL include a `docs/future-ideas.md` documenting planned enhancements, feature ideas, and potential improvements for future development
8. THE Repository SHALL include a `docs/about.md` containing sections for: application purpose, target audience (golf cart operators in The Villages), key capabilities summary, a clearly marked placeholder section for screenshots, and value proposition
9. THE root README.md SHALL include a documentation section containing a relative markdown link to each file in the docs folder accompanied by a one-sentence description of its contents
10. WHEN any documentation file listed in criteria 2 through 8 is added to the repository, THE file SHALL contain a minimum of 200 words of substantive content (excluding markdown formatting characters and blank lines)
11. THE root README.md documentation section SHALL contain only valid relative markdown links that resolve to existing files in the docs folder


### Requirement 23: Responsive Layout and Screen Adaptability

**User Story:** As a golf cart operator, I want the application to adapt to different screen sizes and orientations, so that it works well on a variety of devices including smaller screens and both portrait and landscape mounting positions.

#### Acceptance Criteria

1. THE GCD SHALL support screen resolutions as low as 800x600 pixels, ensuring all UI elements remain visible, readable, and functional at this minimum resolution
2. THE GCD SHALL implement a responsive layout system that dynamically adjusts widget sizes, spacing, and arrangement based on the available screen dimensions
3. THE GCD SHALL support both portrait (vertical) and landscape (horizontal) device orientations, adapting the layout to make optimal use of the available space in each orientation
4. WHEN the device orientation changes, THE GCD SHALL reflow the UI layout within 500 milliseconds without losing application state or interrupting active Bluetooth connections
5. THE GCD SHALL use relative sizing (percentages, flex factors, or MediaQuery-based calculations) rather than fixed pixel dimensions for primary layout containers to ensure proportional scaling across screen sizes
6. THE GCD SHALL ensure that all text remains legible at the minimum supported resolution (800x600), using a minimum effective font size of 12sp for informational text and 16sp for primary data displays (speed, temperature, time)
7. THE GCD SHALL ensure that all interactive touch targets maintain a minimum size of 44x44 density-independent pixels regardless of screen size or orientation
8. WHEN displayed on screens smaller than 1024x768, THE GCD SHALL prioritize essential dashboard information (speed, heading, time, connection status) and allow secondary information to scroll or be accessed via navigation
9. THE GCD SHALL adapt the main dashboard layout between a single-column arrangement for narrow/portrait screens and a multi-column arrangement for wider/landscape screens
10. THE GCD SHALL use Flutter's LayoutBuilder, MediaQuery, and/or responsive breakpoint utilities to implement adaptive layouts that respond to the actual rendered area rather than assuming a fixed screen size
