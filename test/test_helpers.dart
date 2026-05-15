/// Common test utilities and mock setup for the Golf Cart Computer test suite.
///
/// Import this file in test files to access shared helpers, mock classes,
/// and test configuration utilities.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Widget test helpers
// ---------------------------------------------------------------------------

/// Wraps a widget in a [MaterialApp] and [ProviderScope] for widget testing.
///
/// Optionally accepts [overrides] to inject mock providers.
Widget createTestApp(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Pumps a widget wrapped in the standard test app shell.
Future<void> pumpTestWidget(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(createTestApp(child, overrides: overrides));
}

// ---------------------------------------------------------------------------
// Mock registration
// ---------------------------------------------------------------------------

/// Registers fallback values for common types used in mock verification.
///
/// Call this in `setUpAll` when using mocktail with types that need
/// fallback values for `any()` matchers.
void registerCommonFallbackValues() {
  registerFallbackValue(Duration.zero);
  registerFallbackValue(const Offset(0, 0));
}

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

/// Creates a minimal [DateTime] for testing with sensible defaults.
DateTime testDateTime({
  int year = 2024,
  int month = 6,
  int day = 15,
  int hour = 12,
  int minute = 0,
  int second = 0,
}) {
  return DateTime(year, month, day, hour, minute, second);
}

/// Returns a date integer in YYYYMMDD format for cache testing.
int toDateInt(DateTime date) {
  return date.year * 10000 + date.month * 100 + date.day;
}
