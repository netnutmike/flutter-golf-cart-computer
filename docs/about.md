# About the Flutter Golf Cart Computer

## Purpose

The Flutter Golf Cart Computer (GCD) is a cross-platform mobile application designed to serve as the primary display and control interface for a smart golf cart system. It replaces a native Android-only implementation with a Flutter-based solution that runs on both Android and iOS devices, enabling a wider range of hardware choices for golf cart operators.

The application transforms a standard mobile device into a dedicated golf cart dashboard, providing real-time speed, navigation, vehicle telemetry, mesh messaging, weather forecasts, and entertainment schedules — all without requiring cellular data connectivity for core features.

The project originated from a need to provide golf cart operators with a purpose-built information display that consolidates multiple data sources into a single, glanceable interface. Rather than juggling separate apps for navigation, messaging, and vehicle monitoring, the GCD brings everything together in a layout optimized for outdoor readability and minimal driver distraction.

## Target Audience

The primary audience is golf cart operators in **The Villages Retirement Community** in central Florida. The Villages is one of the largest retirement communities in the United States, where golf carts are a primary mode of transportation used daily for shopping, dining, recreation, and socializing. The community spans over 32 square miles with more than 100 miles of dedicated golf cart trails connecting neighborhoods, town squares, recreation centers, and commercial areas.

Golf cart operators in The Villages typically:
- Use their carts daily for distances of 5-20 miles
- Travel on dedicated cart paths and public roads with speed limits of 20-25 mph
- Want to stay connected with neighbors and friends without relying on cellular service
- Appreciate weather and entertainment information for planning activities at the three town squares and numerous recreation centers
- Value simplicity and readability in their technology interfaces, preferring large text and minimal clutter
- May have varying levels of technical comfort, from tech-savvy early adopters to those who prefer appliance-like simplicity
- Often mount devices on their cart dashboards in various orientations depending on cart model and personal preference

The application is designed with large, readable displays, minimal interaction requirements while driving, and automatic operation that requires little ongoing attention from the operator. The interface prioritizes information density without sacrificing readability — operators should be able to glance at the screen and immediately understand their speed, heading, and system status.

## Key Capabilities

### Real-Time Vehicle Dashboard
The main screen provides at-a-glance information including current speed, compass heading, time, date, temperature, and GPS quality indicators. All values update in real time as the cart moves. The speed display uses GPS-based filtering to eliminate noise and provide stable, accurate readings even at the low speeds typical of golf cart operation (5-25 mph). The heading display uses a 16-point cardinal direction system that updates smoothly as the cart turns.

### Mesh Network Communication
Through integration with a Meshtastic radio, the app enables text messaging over a long-range mesh network without cellular service. Operators can communicate with other mesh users within radio range, which in The Villages can extend several miles through the mesh relay system. The messaging system supports both broadcast messages (visible to all mesh users) and direct messages to specific nodes. A library of preformatted messages enables quick communication while driving without needing to type.

### Vehicle Telemetry Monitoring
Connected to the GCI (Golf Cart Internal) ESP-32 computer via Bluetooth, the app displays battery voltage, fuel level, outdoor temperature, and headlight status. This gives operators visibility into their cart's electrical and mechanical state. Battery voltage monitoring is particularly important for electric golf carts, where knowing the remaining charge helps operators plan their routes and avoid being stranded. The temperature display includes a configurable offset for sensor calibration.

### Weather and Entertainment
Weather forecasts and local entertainment venue schedules are received over the mesh network from a base station. This information is displayed without requiring an internet connection, making it available even in areas with poor cellular coverage. The weather display shows current temperature and a 4-hour forecast with weather glyphs, temperature predictions, and precipitation probability. The entertainment display shows which venues have live music or events scheduled for the day — a key social feature for Villages residents who frequently visit the town squares for evening entertainment.

### Intelligent Power Management
The app automatically manages display brightness based on time of day (using calculated sunrise/sunset times), dims the screen during inactivity, and adjusts GPS update frequency based on whether the cart is at home or away. This extends device battery life during long parking periods. The three-state sleep system (Startup Grace, GCI Mode, Standalone Mode) ensures the app behaves appropriately whether the cart's telemetry computer is connected or not.

### Distance and Maintenance Tracking
An odometer tracks total distance traveled with GPS-based distance accumulation that uses speed gating to prevent false accumulation when stationary. A trip odometer tracks individual journeys and can be reset independently. A service reminder monitors driving hours and alerts operators when maintenance is due based on a configurable interval. These features help operators maintain their carts on schedule and track usage over time.

### Responsive Display
The application adapts to different screen sizes and orientations, supporting resolutions as low as 800x600 pixels. Whether mounted in portrait or landscape orientation, the layout adjusts to make optimal use of available space while maintaining readability and touch target sizes appropriate for use while driving.

## Screenshots

> **Note:** Screenshots will be added once the UI implementation is complete.

### Main Dashboard
<!-- ![Main Dashboard](screenshots/main-dashboard.png) -->
*Placeholder: The main dashboard showing speed, heading, time, temperature, and connection status indicators. The layout adapts between portrait and landscape orientations.*

### Weather Screen
<!-- ![Weather Screen](screenshots/weather-screen.png) -->
*Placeholder: The weather forecast screen showing current temperature and 4-hour forecast with weather glyphs, temperatures, and precipitation probabilities.*

### Entertainment Screen
<!-- ![Entertainment Screen](screenshots/entertainment-screen.png) -->
*Placeholder: The entertainment venue listing showing today's schedule in a two-column scrollable table format with venue names and event descriptions.*

### Configuration Screen
<!-- ![Configuration Screen](screenshots/config-screen.png) -->
*Placeholder: The configuration screen showing brightness, volume, connection settings, geofence controls, and maintenance tracking options.*

### Messaging Screen
<!-- ![Messaging Screen](screenshots/messaging-screen.png) -->
*Placeholder: The mesh messaging interface showing message history with sender IDs, timestamps, and channel indicators, plus send controls with preformatted message selection.*

## Value Proposition

The Flutter Golf Cart Computer provides golf cart operators with a dedicated, purpose-built dashboard experience that combines navigation, communication, and vehicle monitoring in a single application. Unlike general-purpose navigation or messaging apps, every feature is designed specifically for the golf cart use case:

- **No cellular data required** for core features — mesh networking and GPS work independently of cellular coverage
- **Optimized for outdoor readability** with automatic brightness management that adjusts for sunlight and nighttime conditions
- **Designed for driving** with large touch targets (minimum 44x44dp), high-contrast displays, and minimal interaction requirements
- **Integrated ecosystem** connecting the display, radio, and vehicle computer seamlessly over Bluetooth
- **Community-oriented** with mesh messaging connecting neighbors across The Villages without monthly service fees
- **Maintenance awareness** with odometer tracking and service reminders that help operators keep their carts in good condition
- **Weather and entertainment at a glance** without needing to open separate apps or have cellular connectivity
- **Adaptive layout** that works on various screen sizes and mounting orientations common in golf cart installations

The cross-platform Flutter implementation ensures operators can use whatever Android or iOS device they prefer, mounted in their cart as a permanent or removable display. The responsive design accommodates everything from compact phones to larger tablets.

## System Ecosystem

The Golf Cart Computer is one component of a three-part system:

| Component | Role | Connection | Hardware |
|-----------|------|------------|----------|
| **GCM** (Golf Cart Meshtastic) | LoRa mesh radio for messaging, weather/entertainment relay, and GPS backup | Bluetooth LE | Meshtastic-compatible LoRa radio (e.g., T-Beam, RAK WisBlock) |
| **GCD** (Golf Cart Display) | This application — display and control interface | — | Any Android or iOS device (phone or tablet) |
| **GCI** (Golf Cart Internal) | ESP-32 telemetry computer for vehicle sensors | Bluetooth Classic/LE | Custom ESP-32 board with voltage, fuel, temperature, and light sensors |

All three components work together to provide the complete smart golf cart experience, but the GCD can operate in standalone mode with reduced functionality when either external device is unavailable. In standalone mode, the app still provides GPS-based speed, heading, distance tracking, and time display using only the device's built-in sensors.

### Communication Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Mesh Network (LoRa)                        │
│  Base Station ←──→ GCM Radio ←──→ Other Carts' Radios       │
└──────────────────────────┬──────────────────────────────────┘
                           │ BLE (Meshtastic Protocol)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              GCD (This Application)                           │
│  Messages, Weather, Entertainment, GPS backup                │
└──────────────────────────┬──────────────────────────────────┘
                           │ Bluetooth Classic (Android) / BLE (iOS)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              GCI (ESP-32 Telemetry Computer)                  │
│  Battery voltage, fuel level, temperature, headlight mode    │
└─────────────────────────────────────────────────────────────┘
```

## Technology Stack

| Technology | Purpose |
|-----------|---------|
| Flutter 3.22+ | Cross-platform UI framework |
| Dart 3.4+ | Programming language |
| Riverpod | State management and dependency injection |
| flutter_blue_plus | Bluetooth Low Energy communication |
| geolocator | Cross-platform GPS access |
| Protocol Buffers | Meshtastic message serialization |
| Hive | Local binary data caching |
| shared_preferences | User settings persistence |
| audioplayers | Cross-platform audio feedback |
| permission_handler | Unified permission management |
