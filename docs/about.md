# About the Flutter Golf Cart Computer

## Purpose

The Flutter Golf Cart Computer (GCD) is a cross-platform mobile application designed to serve as the primary display and control interface for a smart golf cart system. It replaces a native Android-only implementation with a Flutter-based solution that runs on both Android and iOS devices, enabling a wider range of hardware choices for golf cart operators.

The application transforms a standard mobile device into a dedicated golf cart dashboard, providing real-time speed, navigation, vehicle telemetry, mesh messaging, weather forecasts, and entertainment schedules — all without requiring cellular data connectivity for core features.

## Target Audience

The primary audience is golf cart operators in **The Villages Retirement Community** in central Florida. The Villages is one of the largest retirement communities in the United States, where golf carts are a primary mode of transportation used daily for shopping, dining, recreation, and socializing.

Golf cart operators in The Villages typically:
- Use their carts daily for distances of 5-20 miles
- Travel on dedicated cart paths and public roads
- Want to stay connected with neighbors and friends
- Appreciate weather and entertainment information for planning activities
- Value simplicity and readability in their technology interfaces
- May have varying levels of technical comfort

The application is designed with large, readable displays, minimal interaction requirements while driving, and automatic operation that requires little ongoing attention from the operator.

## Key Capabilities

### Real-Time Vehicle Dashboard
The main screen provides at-a-glance information including current speed, compass heading, time, date, temperature, and GPS quality indicators. All values update in real time as the cart moves.

### Mesh Network Communication
Through integration with a Meshtastic radio, the app enables text messaging over a long-range mesh network without cellular service. Operators can communicate with other mesh users within radio range, which in The Villages can extend several miles through the mesh relay system.

### Vehicle Telemetry Monitoring
Connected to the GCI (Golf Cart Internal) ESP-32 computer via Bluetooth, the app displays battery voltage, fuel level, outdoor temperature, and headlight status. This gives operators visibility into their cart's electrical and mechanical state.

### Weather and Entertainment
Weather forecasts and local entertainment venue schedules are received over the mesh network from a base station. This information is displayed without requiring an internet connection, making it available even in areas with poor cellular coverage.

### Intelligent Power Management
The app automatically manages display brightness based on time of day, dims the screen during inactivity, and adjusts GPS update frequency based on whether the cart is at home or away. This extends device battery life during long parking periods.

### Distance and Maintenance Tracking
An odometer tracks total distance traveled, a trip odometer tracks individual journeys, and a service reminder monitors driving hours to alert operators when maintenance is due.

## Screenshots

> **Note:** Screenshots will be added once the UI implementation is complete.

### Main Dashboard
<!-- ![Main Dashboard](screenshots/main-dashboard.png) -->
*Placeholder: The main dashboard showing speed, heading, time, temperature, and connection status indicators.*

### Weather Screen
<!-- ![Weather Screen](screenshots/weather-screen.png) -->
*Placeholder: The weather forecast screen showing current temperature and 4-hour forecast with weather glyphs.*

### Entertainment Screen
<!-- ![Entertainment Screen](screenshots/entertainment-screen.png) -->
*Placeholder: The entertainment venue listing showing today's schedule in a two-column table format.*

### Configuration Screen
<!-- ![Configuration Screen](screenshots/config-screen.png) -->
*Placeholder: The configuration screen showing brightness, volume, and connection settings.*

### Messaging Screen
<!-- ![Messaging Screen](screenshots/messaging-screen.png) -->
*Placeholder: The mesh messaging interface showing message history and send controls.*

## Value Proposition

The Flutter Golf Cart Computer provides golf cart operators with a dedicated, purpose-built dashboard experience that combines navigation, communication, and vehicle monitoring in a single application. Unlike general-purpose navigation or messaging apps, every feature is designed specifically for the golf cart use case:

- **No cellular data required** for core features — mesh networking and GPS work independently
- **Optimized for outdoor readability** with automatic brightness management
- **Designed for driving** with large touch targets and minimal interaction requirements
- **Integrated ecosystem** connecting the display, radio, and vehicle computer seamlessly
- **Community-oriented** with mesh messaging connecting neighbors across The Villages

The cross-platform Flutter implementation ensures operators can use whatever Android or iOS device they prefer, mounted in their cart as a permanent or removable display.

## System Ecosystem

The Golf Cart Computer is one component of a three-part system:

| Component | Role | Connection |
|-----------|------|------------|
| **GCM** (Golf Cart Meshtastic) | LoRa mesh radio for messaging and GPS relay | Bluetooth LE |
| **GCD** (Golf Cart Display) | This application — display and control interface | — |
| **GCI** (Golf Cart Internal) | ESP-32 telemetry computer for vehicle sensors | Bluetooth Classic/LE |

All three components work together to provide the complete smart golf cart experience, but the GCD can operate in standalone mode with reduced functionality when either external device is unavailable.
