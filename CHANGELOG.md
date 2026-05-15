# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial Flutter project scaffolding with four-layer architecture
- Project dependencies: flutter_riverpod, flutter_blue_plus, geolocator, protobuf, shared_preferences, hive, permission_handler, audioplayers
- Platform configuration for Android (Bluetooth/Location permissions) and iOS (background modes)
- Protobuf code generation setup with Meshtastic .proto files
- Repository documentation (README, CONTRIBUTING)
- GitHub Actions CI workflow
- Dependabot and Renovate configuration for automated dependency updates
- Responsive layout system with three breakpoints: Compact (<800px), Medium (800-1024px), Expanded (>1024px)
- `ResponsiveLayout` widget with LayoutBuilder/MediaQuery-based breakpoint and orientation detection
- Layout variant widgets: `CompactDashboardLayout`, `MediumDashboardLayout`, `ExpandedDashboardLayout`
- `ResponsiveLayoutScope` InheritedWidget for descendant access to layout data
- `ResponsiveScaffold` convenience wrapper combining layout detection with scope propagation
- Portrait/landscape orientation-aware layout switching via `ResponsiveLayout.oriented`
- MainScreen responsive adaptation: single-column (compact), two-column (medium), three-column (expanded)
- WeatherScreen responsive adaptation: vertical stack (portrait) vs side-by-side (landscape)
- EntertainmentScreen responsive adaptation: adaptive table column widths and cell padding
- ConfigScreen responsive adaptation: single-column (portrait) vs two-column (landscape)
- Minimum font size enforcement: 16sp for primary data, 12sp for labels/status
- Minimum 44x44dp touch targets on all interactive elements across all screen sizes
- 41 widget tests covering responsive layout system and screen behavior at multiple resolutions
