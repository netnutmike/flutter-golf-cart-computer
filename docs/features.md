# Features

This document lists all application features of the Flutter Golf Cart Computer, organized by functional category. Each feature describes the user-facing behavior as experienced by golf cart operators.

## Connectivity

### Meshtastic BLE Connection
The application connects to a Meshtastic radio via Bluetooth Low Energy for mesh network communication. It automatically scans for compatible devices matching the Meshtastic naming pattern, performs the full Meshtastic handshake protocol (want_config → my_info → config → config_complete), and maintains the connection with 30-second heartbeat monitoring. If the connection drops, the app automatically attempts reconnection using exponential backoff (2s → 4s → 8s → ... → 60s max, up to 10 attempts). The bonded device identifier is persisted for automatic reconnection on subsequent app launches without requiring a new scan.

### GCI Telemetry Connection
The application connects to the Golf Cart Internal (GCI) ESP-32 computer via Bluetooth to receive real-time vehicle telemetry data. The connection uses Bluetooth Classic SPP on Android (preferred for reliability and throughput) and BLE on iOS (the only option available on Apple's platform). A 10-second heartbeat mechanism detects connection loss after 40 seconds of silence (4 missed heartbeats). The app supports pairing with new GCI devices through a broadcast discovery process with a 6-second pairing window and ACK handshake confirmation.

### Dual Bluetooth Management
Both Bluetooth connections operate simultaneously and independently. Each connection has its own state machine (Disconnected → Connecting → Connected → Reconnecting), reconnection logic with independent backoff timers, and error handling. A failure or disconnection on one link does not affect the other. Connection status indicators on the main screen show the current state of each link with distinct visual states for connected, disconnected, and connecting/reconnecting.

### Background Connectivity
Bluetooth connections remain active when the app is in the background or the screen is off. On Android, a foreground service with a persistent notification keeps the process alive. On iOS, declared background modes (`bluetooth-central`, `location`) enable continued BLE operation. Messages and telemetry data continue to be processed in the background so nothing is lost during screen-off periods.

## Navigation and GPS

### Speed Display
Current vehicle speed is displayed as an integer value in miles per hour (0-99 range). The speed reading passes through a multi-stage filter to eliminate GPS noise common at golf cart speeds:
- **Dither elimination:** Readings below 2.5 mph are suppressed to zero, preventing the display from flickering between 0-2 mph when stationary
- **Spike rejection:** Readings exceeding 8 mph/s acceleration are discarded as GPS glitches
- **Responsive stop detection:** When speed is below 4 mph and decreasing, it immediately reports zero for a snappy stop response
- **Consecutive threshold:** 2 readings above 2.5 mph are required before reporting movement (3 when the screen is dimmed, to prevent false wake-ups)

### Compass Heading
The current travel direction is displayed as a 16-point cardinal direction (N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW) derived from the GPS bearing. Each direction covers a 22.5° arc. The heading updates smoothly as the cart turns and is only displayed when the vehicle is in motion (heading is meaningless when stationary).

### Position Display
Current latitude and longitude coordinates are displayed to 6 decimal places (approximately 0.11 meter precision), along with satellite count and Horizontal Dilution of Precision (HDOP) for GPS quality indication. The satellite count is debounced — 3 consecutive zero readings are required before displaying zero to prevent flicker during brief signal dropouts. HDOP is estimated from satellite count when direct HDOP data is unavailable (≥6 sats = 1.5, 4-5 sats = 2.0, <4 sats = 99.0).

### Dual GPS Source
The app uses the device's internal GPS sensor as the primary position source (1-second update interval via the geolocator plugin). When the internal sensor is unavailable or reports zero satellites, it falls back to GPS data received from the connected Meshtastic radio. This provides redundancy — if the device is mounted in a location with poor GPS reception, the external Meshtastic radio (often mounted with a better antenna) can provide position data.

### Time and Date
Current time is displayed in 12-hour format with AM/PM indicator, derived from GPS time converted to the local timezone (including automatic daylight saving time transitions). The date is shown in "Day, Mon DD" format (e.g., "Mon, Jan 15"). If no GPS time update is received for 60 seconds, "NO GPS" is displayed for the date field to alert the operator of signal loss.

### Sunrise and Sunset
Sunrise and sunset times are calculated based on the current GPS position and date, then displayed in 12-hour format. These times drive the automatic brightness switching between day and night levels and are useful for operators planning evening activities.

### Odometer and Trip Distance
Total distance traveled is accumulated using GPS position calculations with speed gating (distance only accumulates when filtered speed > 0). A minimum distance threshold of 2.6 feet (0.0005 miles) prevents micro-accumulation from GPS jitter. Position-based speed exceeding 30 mph causes that sample to be discarded entirely. The odometer displays with 1 decimal place precision in miles and rolls over at 100,000.0 miles.

A separate trip odometer can be reset by the user for tracking individual journeys. It rolls over independently at 10,000.0 miles. Both values are persisted every 0.5 miles and before sleep/shutdown to minimize data loss.

## Telemetry

### Battery Voltage
Real-time battery voltage from the GCI is displayed with 1 decimal place precision in volts (e.g., "48.2V"), allowing operators to monitor charge level during use. For electric golf carts, this is the primary indicator of remaining range. A fully charged 48V cart typically reads 50-52V; operators learn their cart's voltage curve over time.

### Fuel Level
Fuel level percentage from the GCI is displayed as an integer (e.g., "75%"), providing at-a-glance fuel status for gas-powered carts. The value comes directly from the GCI's fuel sensor reading.

### Temperature
Outdoor air temperature from the GCI sensor is displayed in degrees Fahrenheit as an integer value. A user-configurable offset (range -20 to +20 degrees, default 0) allows calibration if the sensor reads consistently high or low due to mounting location (e.g., near the engine or in direct sunlight). The offset is applied at display time and persisted across restarts.

### Headlight Mode
The current headlight mode status received from the GCI is displayed as a numeric indicator, reflecting the operating mode of the cart's lighting system. This helps operators confirm their lights are in the expected state, particularly useful at dusk when automatic headlights should activate.

## Messaging

### Mesh Text Messaging
Users can send and receive text messages over the Meshtastic mesh network. Incoming messages display the sender's node ID in hex format (e.g., `!a1b2c3d4`), channel number (0-7), and timestamp in 12-hour format with AM/PM. Messages can be sent to broadcast (all users on a channel) or to specific node numbers for private communication.

The mesh network operates independently of cellular service, making it ideal for areas with poor coverage. In The Villages, the mesh relay system can extend communication range to several miles through intermediate nodes.

### Preformatted Messages
A configurable list of up to 20 preformatted messages allows quick sending of common phrases without typing. This is particularly useful while driving when composing custom messages is impractical and potentially unsafe. Examples might include "On my way," "Running late," "At the clubhouse," or "Need a ride."

### Custom Message Composition
An on-screen keyboard allows composing custom text messages. A byte counter shows the current message size relative to the 237-byte UTF-8 payload limit, preventing oversized messages from being sent. The counter updates in real-time as the user types, accounting for multi-byte characters.

### Message History
Up to 100 received messages are retained in a scrollable history with FIFO eviction (oldest messages discarded when the limit is reached). Each message shows the sender node ID, channel, timestamp, and message text. An audible notification tone plays when new messages arrive (if volume is enabled and > 0).

### Connection-Aware Sending
If the Meshtastic connection is not established when the user attempts to send a message, the send is rejected with a clear error message indicating no connection is available. This prevents confusion about whether a message was actually transmitted.

## Weather and Entertainment

### Weather Forecast Display
Weather data received via Meshtastic HoT packets is displayed showing the current temperature prominently and a 4-hour forecast below. Each forecast hour shows:
- Time label (e.g., "3PM")
- Weather glyph icon representing conditions
- Temperature in °F
- Precipitation probability (hidden when 0%)

Data is cached locally with a date stamp and restored on app restart if it is from the current day. A "(stored)" indicator distinguishes cached data from live data.

### Venue and Event Schedule
Entertainment venue and event data received via Meshtastic is displayed in a scrollable two-column table showing venue names and their scheduled events. Up to 12 venues are displayed (extras are discarded). This is a key social feature for Villages residents who frequently visit the three town squares for live music and entertainment.

Data is cached and restored from local storage when current-day data is available, ensuring operators see the schedule immediately on startup without waiting for a new transmission.

### Data Freshness Indicators
Both weather and entertainment screens show the timestamp of when data was last received in 12-hour format (e.g., "2:35 PM"). A visual indicator distinguishes between live data and cached (stored) data loaded from local storage. When fresh data arrives, a "new data received" indicator appears for 5 seconds to draw attention to the update.

### Automatic Data Requests
When the app starts and cached data is stale (from a previous day) or absent, it automatically sends a request message (`~#01#GC#REQ_WX_ENT#`) over the mesh network to request fresh weather and entertainment data from the base station.

## Display Management

### Automatic Brightness
Display brightness automatically adjusts based on time of day using calculated sunrise and sunset times. Separate brightness levels are configurable for daytime (default 7/10) and nighttime (default 3/10) on an integer scale of 0-10. This prevents the screen from being too dim in sunlight or too bright at night, both of which impair readability.

### Inactivity Dimming
After a configurable period of inactivity (0-60 minutes, default 5 minutes), the display dims to off to conserve device battery power. "Activity" is defined as either touch input or GPS-detected movement (speed > 0). Any touch or detected movement immediately restores the display to the appropriate brightness level (day or night based on current time). Setting the timeout to 0 disables auto-dimming entirely.

### Screen Orientation
The display can be flipped 180 degrees via configuration to accommodate different mounting orientations in the golf cart. Some operators mount their device upside-down due to cable routing or mounting bracket constraints.

### Responsive Layout
The application adapts to different screen sizes and orientations:
- **Minimum resolution:** 800x600 pixels fully supported
- **Orientation:** Both portrait and landscape layouts with automatic reflow
- **Scaling:** Relative sizing ensures proportional display across screen sizes
- **Priority:** Essential information (speed, heading, time, status) is always visible; secondary information scrolls or navigates on smaller screens
- **Touch targets:** Minimum 44x44dp regardless of screen size

## Geofencing

### Home Location
Users can set their current GPS position as the home location via the configuration screen. This requires an active GPS fix — if GPS is unavailable, the request is rejected with an error message. The home location can also be cleared, which disables geofence calculations and defaults the at-home status to false.

### Geofence with Hysteresis
A configurable radius (100-5000 meters, default 500m) defines the home area. A 50-meter hysteresis band prevents status oscillation when the cart is near the boundary:
- **Entering home:** Status changes to "at home" when distance drops below (radius - 50m)
- **Leaving home:** Status changes to "away" when distance exceeds (radius + 50m)
- **Within band:** Status remains unchanged, preventing rapid toggling

The at-home status affects:
- GPS update interval sent to Meshtastic radio (120s at home, 8s away)
- GPS data sending interval to GCI
- GCI notification of home/away status

## Configuration

### User Preferences
A comprehensive configuration screen provides access to all adjustable settings:

| Setting | Range | Default | Notes |
|---------|-------|---------|-------|
| Day brightness | 0-10 | 7 | Active between sunrise and sunset |
| Night brightness | 0-10 | 3 | Active between sunset and sunrise |
| Speaker volume | 0-20 | 10 | 0 = muted |
| Screen flip | On/Off | Off | 180° rotation |
| Backlight timeout | 0-60 min | 5 | 0 = never dim |
| Temperature offset | -20 to +20°F | 0 | Sensor calibration |
| Service interval | 1-500 hours | 100 | Maintenance reminder |
| Geofence radius | 100-5000m | 500 | Home area size |
| Meshtastic enabled | On/Off | Off | Radio connection toggle |

Changes are persisted immediately with 2-second debouncing for slider/spinner values to reduce storage wear during rapid adjustments.

### Service Reminder
Driving hours are tracked (only when speed > 0) and compared against the configurable service interval. When accumulated hours reach the threshold, a visual indicator alerts the operator that maintenance is due. The counter can be reset after service is performed (requires confirmation to prevent accidental resets). Hours are stored in tenths (6-minute resolution) and persisted every 1.0 hours of driving.

### Radio Administration
The connected Meshtastic radio can be managed from the app:
- **Reboot:** Sends a reboot command with 5-second delay and confirmation prompt
- **GPS interval:** Automatically configured based on at-home status (8s away, 120s home)
- **Node ID display:** Shows the connected radio's node ID in hex format
- **Enable/disable:** Toggle the Meshtastic connection on or off

Admin commands use a read-modify-write pattern to preserve existing radio settings while updating specific fields.

### GCI Pairing
New GCI devices can be paired through a broadcast discovery mechanism:
1. User initiates pairing from config screen
2. App broadcasts pairing command with device MAC address
3. 6-second window for GCI to respond with ACK
4. Success: new device address persisted for auto-reconnection
5. Failure: previous device address restored (if any), error tone played

### Reset Options
- **Trip odometer reset:** Sets trip distance to 0.0 without affecting total odometer
- **Service hours reset:** Resets driving hours counter (requires confirmation)
- **Reset all preferences:** Clears all user settings to defaults while preserving operational data (odometer, hours), then restarts the app
- **Manual restart:** Restarts the application and resets the sleep state machine

## Power Management

### Three-State Sleep System
The application implements intelligent power management with three states:

1. **STARTUP_GRACE** (initial state): Waits for GCI connection for a period equal to the backlight timeout setting (minimum 30 seconds). This gives the GCI time to connect before the app decides on its operating mode.

2. **GCI_MODE** (entered when GCI connects): Display stays at active brightness for as long as the GCI connection is maintained. The assumption is that if the GCI is connected, the cart is in use and the display should remain visible.

3. **STANDALONE_MODE** (entered when grace expires without GCI, or GCI disconnects for timeout period): Display dims per the backlight timeout setting. The system never enters deep sleep — it continues processing GPS, maintaining Bluetooth connections, and accumulating odometer/hours data.

Transitions:
- STARTUP_GRACE → GCI_MODE: GCI connects during grace period
- STARTUP_GRACE → STANDALONE_MODE: Grace period expires without GCI
- GCI_MODE → STANDALONE_MODE: GCI disconnected for backlight timeout period
- STANDALONE_MODE → GCI_MODE: GCI reconnects

### Background Execution
The app maintains Bluetooth connections and GPS updates when running in the background:
- **Android:** Foreground service with persistent notification keeps the process alive and prevents the OS from killing it
- **iOS:** Declared background modes (`bluetooth-central`, `location`) enable continued BLE and GPS operation

When the app returns to the foreground, it resumes displaying live data within 2 seconds without requiring reconnection (assuming connections were maintained in the background).

## Audio Feedback

### Event Tones
The app provides audible feedback for important events using distinct tones:

| Event | Tone | When |
|-------|------|------|
| Startup | Startup tone | App launches |
| Message received | Notification tone | New Meshtastic text message arrives |
| Data received | Alert tone | New weather or entertainment HoT packet |
| Action success | Confirmation tone | Home set, trip reset, pairing complete |
| Button press | Click tone | Interactive control activated |
| Action failure | Error tone | Pairing timeout, no GPS, send failure |

### Volume Control
Speaker volume is adjustable from 0 to 20 in integer steps. Volume 0 suppresses all audio playback entirely. The volume setting is persisted and restored on app restart. Audio uses a cross-platform plugin (audioplayers) for consistent behavior on both Android and iOS.
