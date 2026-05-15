# Flutter Golf Cart Computer Documentation

Welcome to the documentation for the Flutter Golf Cart Computer (GCD) application. This folder contains comprehensive guides covering architecture, development, features, and project direction.

## Documentation Index

| Document | Description |
|----------|-------------|
| [About](about.md) | Overview of the application's purpose, target audience, key capabilities, system ecosystem, and value proposition for golf cart operators in The Villages. |
| [Build Guide](build-guide.md) | Step-by-step instructions for setting up the development environment, building for Android and iOS, generating protobuf code, CI configuration, and resolving common build issues. |
| [Design](design.md) | Architectural overview of the four-layer system, component interactions, data flow diagrams, state management patterns with Riverpod, responsive layout architecture, and key design decisions with rationale. |
| [Developer Guide](developer-guide.md) | Practical guide for contributors covering code organization, naming conventions, adding new features, Bluetooth protocols (Meshtastic BLE and GCI), HoT packet formats, protobuf message formats, testing strategies, and debugging techniques. |
| [Features](features.md) | Complete listing of all application features organized by functional category including connectivity, navigation, telemetry, messaging, weather/entertainment, display management, geofencing, configuration, power management, and audio feedback. |
| [Future Ideas](future-ideas.md) | Planned enhancements, feature ideas, technical improvements, platform-specific ideas, and community features for future development cycles. |

## Quick Links

- **New to the project?** Start with [About](about.md) for context on the application's purpose and ecosystem, then read the [Design](design.md) document for architectural understanding.
- **Setting up your environment?** Follow the [Build Guide](build-guide.md) for prerequisites, platform setup, and protobuf generation.
- **Ready to contribute?** Read the [Developer Guide](developer-guide.md) for coding standards, conventions, and the step-by-step process for adding features.
- **Looking for a specific feature?** Check the [Features](features.md) list for detailed descriptions of all user-facing functionality.
- **Want to know what's next?** See [Future Ideas](future-ideas.md) for the roadmap and planned enhancements.

## About This Documentation

These documents are maintained alongside the source code. If you find inaccuracies or have suggestions for improvement, please open an issue or submit a pull request. Documentation updates follow the same review process as code changes.

The project targets both Android and iOS platforms and is part of a three-component ecosystem:
- **GCM** (Golf Cart Meshtastic) — LoRa mesh radio for messaging and GPS relay
- **GCD** (Golf Cart Display) — this application, the display and control interface
- **GCI** (Golf Cart Internal) — ESP-32 telemetry computer for vehicle sensors

Understanding this ecosystem context is important for working effectively with the codebase. The GCD maintains two simultaneous Bluetooth connections (one to GCM via BLE, one to GCI via Classic/BLE) and must handle both gracefully, including independent reconnection logic and platform-specific Bluetooth differences between Android and iOS.

## Documentation Standards

When updating or adding documentation:
- Each document should contain a minimum of 200 words of substantive content
- Use Mermaid or ASCII diagrams for architectural illustrations
- Include code examples where they clarify concepts
- Keep protocol details accurate and synchronized with the implementation
- Update the index table above when adding new documents
- Cross-reference related documents where appropriate
