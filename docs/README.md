# Flutter Golf Cart Computer Documentation

Welcome to the documentation for the Flutter Golf Cart Computer (GCD) application. This folder contains comprehensive guides covering architecture, development, features, and project direction.

## Documentation Index

| Document | Description |
|----------|-------------|
| [About](about.md) | Overview of the application's purpose, target audience, key capabilities, and value proposition for golf cart operators in The Villages. |
| [Build Guide](build-guide.md) | Step-by-step instructions for setting up the development environment, building for Android and iOS, generating protobuf code, and resolving common build issues. |
| [Design](design.md) | Architectural overview of the four-layer system, component interactions, data flow diagrams, state management patterns with Riverpod, and key design decisions. |
| [Developer Guide](developer-guide.md) | Practical guide for contributors covering code organization, naming conventions, adding new features, Bluetooth protocols, protobuf message formats, testing, and debugging. |
| [Features](features.md) | Complete listing of all application features organized by functional category including connectivity, navigation, telemetry, messaging, and display management. |
| [Future Ideas](future-ideas.md) | Planned enhancements, feature ideas, and potential improvements for future development cycles. |

## Quick Links

- **New to the project?** Start with [About](about.md) for context, then read the [Design](design.md) document.
- **Setting up your environment?** Follow the [Build Guide](build-guide.md).
- **Ready to contribute?** Read the [Developer Guide](developer-guide.md) for coding standards and workflow.
- **Looking for a specific feature?** Check the [Features](features.md) list.
- **Want to know what's next?** See [Future Ideas](future-ideas.md) for the roadmap.

## About This Documentation

These documents are maintained alongside the source code. If you find inaccuracies or have suggestions for improvement, please open an issue or submit a pull request. Documentation updates follow the same review process as code changes.

The project targets both Android and iOS platforms and is part of a three-component ecosystem: the Meshtastic radio (GCM), this display application (GCD), and the ESP-32 telemetry computer (GCI). Understanding this ecosystem context is important for working effectively with the codebase.
