# Future Ideas

This document captures planned enhancements, feature ideas, and potential improvements for future development of the Flutter Golf Cart Computer application. Items are organized by category and priority level.

## Planned Enhancements

### Route Recording and Playback
Record GPS tracks during trips and allow users to review routes taken. This could include distance, duration, average speed, maximum speed, and a simple map view of the path. Recorded routes could be exported as GPX files for use in other mapping applications or shared with other cart operators. Implementation would involve buffering GPS positions during movement and persisting them as trip records with metadata. A trip history screen would list past trips with summary statistics.

### Map Integration
Add an optional map screen showing the current position on a tile-based map. This would require an offline map tile cache since golf carts may not always have cellular connectivity. OpenStreetMap tiles with a local cache (pre-downloaded for The Villages area) would provide coverage without requiring a data connection. The map could show the current position, heading arrow, home location marker, and geofence boundary circle. Tile caching would need to handle storage limits gracefully, prioritizing the local area.

### Multi-Cart Fleet Tracking
Leverage the Meshtastic mesh network to share position data between multiple golf carts. Each cart running the app could broadcast its position periodically (using a dedicated channel or port number), allowing operators to see nearby carts on a distance/direction display or map overlay. This would be useful for group outings in The Villages — friends could see each other's approximate location without needing to call or text. Privacy controls would allow operators to opt in/out of position sharing.

### Weather Alerts and Notifications
Extend the weather system to support alert-level notifications for severe weather conditions. When a weather HoT packet indicates dangerous conditions (high winds, lightning risk, extreme heat index), display a prominent warning overlay that requires acknowledgment before dismissing. Florida's afternoon thunderstorms can develop quickly, and golf carts offer no protection from lightning. An alert system could help operators make informed decisions about heading home.

### Voice Announcements
Add text-to-speech capability for announcing incoming messages, speed warnings, or geofence transitions without requiring the operator to look at the screen. This improves safety by keeping eyes on the road. Announcements could be configurable — operators could choose which events trigger voice output. The Flutter `flutter_tts` package provides cross-platform TTS support. Volume would follow the existing speaker volume setting.

### Turn-by-Turn Navigation to Favorites
Once favorite destinations are implemented, add simple turn-by-turn guidance showing distance and direction to the selected destination. This wouldn't require full routing (no road network data), but a compass-style "point toward destination" display with distance countdown would help operators navigate The Villages' extensive trail system. A bearing arrow and distance readout would be sufficient for the relatively simple path network.

## Feature Ideas

### Maintenance Log
Expand the service reminder into a full maintenance log that records service dates, types of maintenance performed, mileage at service, and notes. This history would help operators track the maintenance lifecycle of their cart and provide records for resale value documentation. The log could include categories like oil change, battery replacement, tire rotation, brake inspection, and custom entries. Data would be persisted locally and optionally exportable as CSV.

### Favorite Destinations
Allow users to save GPS coordinates as named favorites (home, clubhouse, pool, shopping center, doctor's office). Display distance and direction to favorites from the current position in a list sorted by proximity. This would be particularly useful for navigating The Villages' extensive trail system, which spans over 100 miles of paths connecting dozens of recreation centers, town squares, and commercial areas. Favorites could be organized into categories and shared between devices.

### Speed Zones and Alerts
Define geographic zones with speed limits (e.g., 20 mph on cart paths, 25 mph on roads, 15 mph in parking areas). When the cart enters a zone, display the speed limit and provide an audible alert if the operator exceeds it. Zones could be defined manually by the operator or shared between carts via the mesh network. This would help operators comply with The Villages' posted speed limits, which vary by area and are enforced by community patrol.

### Battery Health Monitoring
Track battery voltage over time to identify degradation patterns. Store periodic voltage readings (e.g., every 5 minutes while driving) and display a battery health trend graph showing voltage under load over days/weeks. Alert the operator when voltage patterns suggest the battery pack needs attention or replacement — for example, if voltage drops faster than historical norms or if resting voltage is consistently lower than previous weeks. This predictive maintenance feature could save operators from unexpected breakdowns.

### Social Features
Add a "buddy list" of known Meshtastic nodes with friendly names (instead of hex node IDs). Show online/offline status of buddies based on recent mesh activity. Enable quick messaging to frequent contacts with a single tap. This builds community among golf cart operators using the mesh network and makes the messaging feature more approachable for less technical users who don't want to deal with hex node numbers.

### Customizable Dashboard Layouts
Allow users to rearrange, resize, and choose which widgets appear on the main dashboard. Different layouts could be saved as profiles:
- **Driving mode:** Speed, heading, and connection status prominent
- **Parked mode:** Weather, entertainment, and messages prominent
- **Monitoring mode:** Battery, fuel, and maintenance info prominent

Profiles could switch automatically based on context (moving vs. stationary) or be selected manually with a single tap.

### Night Mode Theme
Implement a dark theme that activates automatically with the night brightness setting. Use red-tinted colors for night driving to preserve night vision, similar to aviation cockpit displays. The red theme would apply to all screens and reduce eye strain during evening drives. The transition between day and night themes would follow the same sunrise/sunset timing as brightness switching.

### Trip Statistics
Provide a trip summary screen showing statistics for the current trip: distance, duration, average speed, maximum speed, time spent moving vs. stopped, and estimated battery consumption (based on voltage drop during the trip). Historical trip data could be stored for comparison — operators could see trends in their daily usage patterns over weeks or months.

### Parking Timer
Add a simple parking timer that starts when the cart stops moving and the operator activates it. Useful for timed parking areas in The Villages' town squares where parking is limited to 2-3 hours. An audible alert at a configurable time before expiration would remind operators to move their cart.

### Group Ride Coordination
Extend the multi-cart tracking concept into a group ride feature. A "ride leader" could create a group, others join via mesh, and the leader's position is shared with all members. Members see distance and direction to the leader, helping groups stay together on longer rides through The Villages' trail system. The leader could also broadcast text messages to the group for coordination.

## Technical Improvements

### Offline-First Architecture
Enhance the caching system to provide a fully offline-capable experience. Queue outbound messages when the Meshtastic radio is disconnected and send them when connectivity is restored. Cache all displayable data locally with intelligent expiration policies. This ensures the app remains useful even when both Bluetooth connections are temporarily unavailable — the dashboard still shows GPS data, time, odometer, and cached weather/entertainment.

### Widget Testing Coverage
Expand widget test coverage to include all screens and interactive elements. Implement golden file tests for visual regression detection across Flutter version updates. Test responsive layouts at multiple screen sizes (800x600, 1024x768, 1920x1080) and both orientations. Ensure accessibility semantics are correct for screen readers.

### Performance Profiling
Add performance monitoring for BLE operations, GPS processing, and UI frame rates. Identify and optimize any operations that cause frame drops on lower-end devices commonly used as golf cart displays (older phones and tablets). Key areas to profile:
- Meshtastic FROMRADIO polling loop (multiple sequential reads)
- GPS processing pipeline (1-second interval means tight timing)
- Widget rebuilds on state changes (ensure minimal rebuild scope)
- Hive cache operations (should not block UI thread)

### Automated Integration Tests
Build a comprehensive integration test suite that simulates the full Bluetooth communication flow using mock BLE peripherals. This would enable CI/CD validation of the complete connection lifecycle without physical hardware. The test suite would cover:
- Meshtastic handshake sequence
- Message send/receive round-trip
- GCI pairing flow
- Reconnection after simulated disconnection
- HoT packet parsing end-to-end

### Accessibility Improvements
Add VoiceOver (iOS) and TalkBack (Android) support for all interactive elements with meaningful semantic labels. Ensure sufficient color contrast ratios for outdoor visibility (WCAG AA minimum, AAA preferred for primary data). Support dynamic text sizing for operators with vision impairments. Test with actual assistive technologies, not just automated checks. Consider adding haptic feedback as an alternative to audio for operators with hearing impairments.

### Localization Framework
While the primary audience speaks English, adding a localization framework (Flutter's `intl` package with ARB files) would enable future translation for international golf cart communities. The Villages has residents from many countries who might prefer their native language. Initial targets could include Spanish and Portuguese given Florida's demographics. The framework should be added early even if translations come later, to avoid retrofitting string extraction.

### Automated Crash Reporting
Integrate a crash reporting service (Firebase Crashlytics or Sentry) to capture unhandled exceptions in production builds. This would help identify issues that only occur on specific devices or under specific conditions (particular BLE chipsets, GPS hardware, etc.) without requiring users to manually report problems.

### OTA Update Mechanism
Implement a mechanism to check for and notify users of app updates. Since the app may not be distributed through app stores initially (side-loaded APKs for Android), a simple version check against a hosted JSON file could alert operators when a new version is available and provide download instructions.

## Platform-Specific Ideas

### Android Auto / CarPlay Integration
Explore integration with Android Auto or CarPlay for carts equipped with compatible head units. This would provide a familiar interface and voice control capabilities. The simplified Android Auto/CarPlay UI would show speed, heading, and connection status, with voice commands for sending preformatted messages. This is a longer-term goal as it requires significant platform-specific development.

### Wear OS / Apple Watch Companion
A companion watch app could display speed and basic telemetry on the operator's wrist, useful when the main display is not easily visible or when walking away from the cart (to check battery level before heading out). The watch app would communicate with the phone app via the platform's watch connectivity framework. Key displays: speed, battery voltage, connection status, and last message preview.

### Home Assistant Integration
Expose cart telemetry data to Home Assistant via MQTT or a REST API. This would allow operators to monitor their cart's battery level, location (home/away), and status from their smart home dashboard. Use cases include:
- Automation: turn on garage lights when cart arrives home
- Monitoring: alert if battery voltage drops below threshold while parked
- History: track daily mileage and driving patterns over time
- Dashboard: show cart status on a wall-mounted tablet at home

### Tablet Kiosk Mode
For operators who dedicate a tablet as a permanent cart display, add a kiosk mode that:
- Prevents accidental navigation away from the app
- Disables system gestures that could interrupt the display
- Automatically launches on device boot
- Locks to the app without requiring device-level kiosk configuration

This would make the tablet behave like a dedicated instrument panel rather than a general-purpose device.

## Community Features

### Shared Points of Interest
Allow operators to mark and share points of interest (POI) via the mesh network — a new restaurant, a road closure, a scenic route, or a hazard. POIs would be broadcast to nearby carts and displayed as notifications or on a future map view. This creates a community-maintained knowledge base of useful locations and conditions.

### Event Notifications
Extend the entertainment system to support push-style notifications for upcoming events. If a venue the operator has "favorited" has an event starting within a configurable time window, display a notification. This helps operators plan their evening without repeatedly checking the entertainment screen.

### Mesh Network Health Display
Add a diagnostic screen showing mesh network statistics: number of nodes seen, signal quality to the connected radio, packet delivery success rate, and network topology (which nodes are relaying). This helps technically-inclined operators troubleshoot mesh coverage issues and optimize radio placement.
