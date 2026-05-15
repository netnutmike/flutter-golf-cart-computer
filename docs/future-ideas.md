# Future Ideas

This document captures planned enhancements, feature ideas, and potential improvements for future development of the Flutter Golf Cart Computer application. Items are organized by category and priority level.

## Planned Enhancements

### Route Recording and Playback
Record GPS tracks during trips and allow users to review routes taken. This could include distance, duration, average speed, and a map view of the path. Recorded routes could be exported as GPX files for use in other mapping applications.

### Map Integration
Add an optional map screen showing the current position on a tile-based map. This would require an offline map tile cache since golf carts may not always have cellular connectivity. OpenStreetMap tiles with a local cache would provide coverage without requiring a data connection.

### Multi-Cart Fleet Tracking
Leverage the Meshtastic mesh network to share position data between multiple golf carts. Each cart running the app could broadcast its position, allowing operators to see nearby carts on a map or distance display. This would be useful for group outings in The Villages.

### Weather Alerts and Notifications
Extend the weather system to support alert-level notifications for severe weather conditions. When a weather HoT packet indicates dangerous conditions (high winds, lightning, extreme heat), display a prominent warning that requires acknowledgment.

### Voice Announcements
Add text-to-speech capability for announcing incoming messages, speed warnings, or geofence transitions without requiring the operator to look at the screen. This improves safety by keeping eyes on the road.

## Feature Ideas

### Maintenance Log
Expand the service reminder into a full maintenance log that records service dates, types of maintenance performed, and notes. This history would help operators track the maintenance lifecycle of their cart and provide records for resale.

### Favorite Destinations
Allow users to save GPS coordinates as named favorites (home, clubhouse, pool, shopping center). Display distance and direction to favorites from the current position. This would be particularly useful for navigating The Villages' extensive trail system.

### Speed Zones and Alerts
Define geographic zones with speed limits. When the cart enters a zone, display the speed limit and provide an audible alert if the operator exceeds it. Zones could be shared between carts via the mesh network.

### Battery Health Monitoring
Track battery voltage over time to identify degradation patterns. Display a battery health trend graph and alert the operator when voltage patterns suggest the battery pack needs attention or replacement.

### Social Features
Add a "buddy list" of known Meshtastic nodes with friendly names. Show online/offline status of buddies and enable quick messaging to frequent contacts. This builds community among golf cart operators using the mesh network.

### Customizable Dashboard Layouts
Allow users to rearrange, resize, and choose which widgets appear on the main dashboard. Different layouts could be saved as profiles (driving mode, parked mode, social mode) and switched with a single tap.

### Night Mode Theme
Implement a dark theme that activates automatically with the night brightness setting. Use red-tinted colors for night driving to preserve night vision, similar to aviation cockpit displays.

### Trip Statistics
Provide a trip summary screen showing statistics for the current trip: distance, duration, average speed, maximum speed, elevation change, and estimated battery consumption. Historical trip data could be stored for comparison.

## Technical Improvements

### Offline-First Architecture
Enhance the caching system to provide a fully offline-capable experience. Queue outbound messages when disconnected and send them when connectivity is restored. Cache all displayable data locally with intelligent expiration.

### Widget Testing Coverage
Expand widget test coverage to include all screens and interactive elements. Implement golden file tests for visual regression detection across platform updates.

### Performance Profiling
Add performance monitoring for BLE operations, GPS processing, and UI frame rates. Identify and optimize any operations that cause frame drops on lower-end devices commonly used as golf cart displays.

### Automated Integration Tests
Build a comprehensive integration test suite that simulates the full Bluetooth communication flow using mock BLE peripherals. This would enable CI/CD validation of the complete connection lifecycle without physical hardware.

### Accessibility Improvements
Add VoiceOver and TalkBack support for all interactive elements. Ensure sufficient color contrast ratios for outdoor visibility. Support dynamic text sizing for operators with vision impairments.

### Localization Framework
While the primary audience speaks English, adding a localization framework would enable future translation for international golf cart communities. The Villages has residents from many countries who might prefer their native language.

## Platform-Specific Ideas

### Android Auto / CarPlay Integration
Explore integration with Android Auto or CarPlay for carts equipped with compatible head units. This would provide a familiar interface and voice control capabilities.

### Wear OS / Apple Watch Companion
A companion watch app could display speed and basic telemetry on the operator's wrist, useful when the main display is not easily visible or when walking away from the cart.

### Home Assistant Integration
Expose cart telemetry data to Home Assistant via MQTT or a REST API. This would allow operators to monitor their cart's battery level, location, and status from their smart home dashboard.
