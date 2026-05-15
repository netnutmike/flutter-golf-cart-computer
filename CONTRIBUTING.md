# Contributing to Flutter Golf Cart Computer

Thank you for your interest in contributing to the Flutter Golf Cart Computer project. This document outlines the coding standards, branch naming conventions, and pull request process.

## Development Setup

1. Ensure you have Flutter SDK 3.22.0+ and Dart SDK 3.9.0+ installed
2. Clone the repository and run `flutter pub get`
3. Generate protobuf classes: `make proto`
4. Verify your setup: `flutter analyze && flutter test`

## Coding Standards

### Dart Style

- Follow the [Effective Dart](https://dart.dev/effective-dart) guidelines
- Use the project's `analysis_options.yaml` (based on `flutter_lints`)
- Run `flutter analyze` before committing — zero warnings required
- Use `dart format` to format all Dart files

### Architecture Rules

- **Presentation layer** — Only Flutter widgets. No business logic. Consume Riverpod providers.
- **Application layer** — Riverpod notifiers/controllers. Coordinate domain logic. No direct I/O.
- **Domain layer** — Pure Dart. No Flutter imports. No framework dependencies.
- **Data layer** — Repositories and services. Handle I/O, persistence, and platform APIs.

### Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables and functions: `camelCase`
- Constants: `camelCase` (Dart convention)
- Private members: prefix with `_`
- Test files: `<source_file>_test.dart`
- Provider names: `<name>Provider` (e.g., `gpsProcessorProvider`)

### Testing

- Write unit tests for all domain logic
- Write property-based tests (using `glados`) for correctness properties
- Write widget tests for presentation components
- Use `mocktail` for mocking data layer dependencies
- Aim for meaningful coverage of business logic — not arbitrary coverage percentages

## Branch Naming

Use the following prefixes:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feature/` | New features | `feature/weather-display` |
| `fix/` | Bug fixes | `fix/speed-filter-spike` |
| `refactor/` | Code refactoring | `refactor/odometer-manager` |
| `docs/` | Documentation changes | `docs/build-guide-update` |
| `ci/` | CI/CD changes | `ci/add-ios-build` |
| `test/` | Test additions/fixes | `test/geofence-property` |

Branch names should be lowercase with hyphens separating words.

## Pull Request Process

1. **Create a branch** from `main` using the naming convention above
2. **Make your changes** following the coding standards
3. **Run checks locally:**
   ```bash
   flutter analyze
   flutter test
   ```
4. **Commit** with clear, descriptive messages:
   - Use present tense: "Add weather parsing" not "Added weather parsing"
   - Reference issue numbers where applicable: "Fix speed filter spike rejection (#42)"
5. **Push** your branch and open a pull request against `main`
6. **PR description** should include:
   - Summary of what changed and why
   - How to test the changes
   - Any breaking changes or migration steps
7. **Review** — At least one approval is required before merging
8. **Merge** — Use squash merge to keep history clean

## Commit Messages

Follow conventional commit style:

```
<type>: <short description>

<optional body with more detail>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `ci`, `chore`

## Reporting Issues

- Use GitHub Issues for bug reports and feature requests
- Include steps to reproduce for bugs
- Include device/platform information for platform-specific issues

## Code of Conduct

Be respectful and constructive. We're all here to build something useful.
