# Features

This document lists all application features of the Flutter Golf Cart Computer, organized by functional category. Each feature describes the user-facing behavior as experienced by golf cart operators.

## Connectivity

### Meshtastic BLE Connection
The application connects to a Meshtastic radio via Bluetooth Low Energy for mesh network communication. It automatically scans for compatible devices, performs the Meshtastic handshake protocol, and maintains the connection with heartbeat monitoring. If the connection drops, the app automatically attempts reconnection using exponential backoff. The bonded device is remembered for automatic reconnection on subsequent app launches.

### GCI Telemetry Connection
The application connects to the Golf Cart Internal (GCI) ESP-32 computer via Bluetooth to receive real-time vehicle telemetry data. The connection uses Bluetooth Classic SPP on Android and BLE on iOS. A heartbeat mechanism detects connection loss, and the app supports pairing with new GCI devices through a broadcast discovery process with a 6-second pairing window.

### Dual Bluetooth Management
Both Bluetooth connections operate simultaneously and independently. Each connection has its own state management, reconnection logic, and error handling. Connection status indicators on the main screen show the current state of each link.

## Navigation and GPS

### Speed Display
Current vehicle speed is displayed as an integer value in miles per hour. The speed reading is filtered to eliminate GPS noise: readings below 2.5 mph are suppressed to zero, sudden spikes are rejected, and responsive stop detection ensures the display quickly shows zero when the cart stops.

### Compass Heading
The current travel direction is displayed as a 16-point cardinal direction (N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW) derived from the GPS bearing.

### Position Display
Current latitude and longitude coordinates are displayed to 6 decimal places, along with satellite count and Horizontal Dilution of Precision (HDOP) for GPS quality indication.

### Time and Date
Current time is displayed in 12-hour format with AM/PM indicator, derived from GPS time converted to the local timezone. The date is shown in "Day, Mon DD" format. Sunrise and sunset times are calculated based on the current GPS position and displayed on the main screen.

### Odometer and Trip Distance
Total distance traveled is accumulated using GPS position calculations and displayed with 1 decimal place precision in miles. A separate trip odometer can be reset by the user for tracking individual journeys. Distance only accumulates when the vehicle is confirmed to be in motion.

## Telemetry

### Battery Voltage
Real-time battery voltage from the GCI is displayed with 1 decimal place precision in volts, allowing operators to monitor charge level during use.

### Fuel Level
Fuel level percentage from the GCI is displayed as an integer, providing at-a-glance fuel status information.

### Temperature
Outdoor air temperature from the GCI sensor is displayed in degrees Fahrenheit as an integer value. A user-configurable offset allows calibration if the sensor reads consistently high or low.

### Headlight Mode
The current headlight mode status received from the GCI is displayed as a numeric indicator, reflecting the operating mode of the cart's lighting system.

## Messaging

### Mesh Text Messaging
Users can send and receive text messages over the Meshtastic mesh network. Incoming messages display the sender's node ID in hex format, channel number, and timestamp. Messages can be sent to broadcast (all users) or to specific nodes.

### Preformatted Messages
A configurable list of up to 20 preformatted messages allows quick sending of common phrases without typing. This is particularly useful while driving when composing custom messages is impractical.

### Custom Message Composition
An on-screen keyboard allows composing custom text messages. A byte counter shows the current message size relative to the 237-byte payload limit, preventing oversized messages from being sent.

### Message History
Up to 100 received messages are retained in a scrollable history. When the limit is reached, the oldest messages are discarded. An audible notification tone plays when new messages arrive (if volume is enabled).

## Weather and Entertainment

### Weather Forecast Display
Weather data received via Meshtastic HoT packets is displayed showing the current temperature and a 4-hour forecast. Each forecast hour shows the time label, a weather glyph icon, temperature, and precipitation probability. Data is cached locally and restored on app restart if it is from the current day.

### Venue and Event Schedule
Entertainment venue and event data received via Meshtastic is displayed in a scrollable two-column table showing venue names and their scheduled events. Up to 12 venues are displayed. Data is cached and restored from local storage when current-day data is available.

### Data Freshness Indicators
Both weather and entertainment screens show the timestamp of when data was last received. A visual indicator distinguishes between live data and cached (stored) data loaded from local storage.

## Display Management

### Automatic Brightness
Display brightness automatically adjusts based on time of day. Separate brightness levels are configurable for daytime (between sunrise and sunset) and nighttime. This prevents the screen from being too dim in sunlight or too bright at night.

### Inactivity Dimming
After a configurable period of inactivity (no touch input and no vehicle movement), the display dims to off to conserve power. Any touch or detected movement immediately restores the display to the appropriate brightness level.

### Screen Orientation
The display can be flipped 180 degrees via configuration to accommodate different mounting orientations in the golf cart.

## Geofencing

### Home Location
Users can set their current GPS position as the home location. The system uses this to determine whether the cart is "at home" or "away," which affects GPS update frequency and other behaviors.

### Geofence with Hysteresis
A configurable radius (100-5000 meters, default 500m) defines the home area. A 50-meter hysteresis band prevents status oscillation when the cart is near the boundary. The at-home status is communicated to the GCI and affects Meshtastic GPS update intervals.

## Configuration

### User Preferences
A comprehensive configuration screen provides access to all adjustable settings: brightness levels, speaker volume, backlight timeout, temperature offset, service interval, geofence radius, and connection toggles. Changes are persisted immediately with debouncing for rapid adjustments.

### Service Reminder
Driving hours are tracked and compared against a configurable service interval. When accumulated hours reach the threshold, a visual indicator alerts the operator that maintenance is due. The counter can be reset after service is performed.

### Radio Administration
The connected Meshtastic radio can be rebooted and its GPS update interval configured directly from the app. Admin commands use a read-modify-write pattern to preserve existing radio settings while updating specific fields.

## Power Management

### Three-State Sleep System
The application implements intelligent power management with three states: Startup Grace (waiting for GCI connection), GCI Mode (display stays active while GCI is connected), and Standalone Mode (display dims per timeout settings). Transitions between states are automatic based on GCI connection status.

### Background Execution
The app maintains Bluetooth connections and GPS updates when running in the background. On Android, a foreground service with a persistent notification keeps the app alive. On iOS, declared background modes for Bluetooth and location enable continued operation.
