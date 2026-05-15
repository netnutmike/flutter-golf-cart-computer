/// GPS speed filtering pipeline for eliminating noise and providing
/// responsive speed display on the golf cart computer.
///
/// Implements:
/// - Dither elimination (speeds below 2.5 mph → zero)
/// - Spike rejection (acceleration > 8 mph/s discarded)
/// - Responsive stop detection (speed < 4 mph and decreasing → zero)
/// - Consecutive reading threshold (2 normal, 3 when dimmed)
/// - Reset on GPS signal loss
class SpeedFilter {
  /// Threshold below which GPS speed is considered dither/noise.
  static const double ditherThresholdMph = 2.5;

  /// Maximum allowed acceleration in mph per second.
  static const double maxAccelerationMphPerSec = 8.0;

  /// Speed below which decreasing readings trigger zero reporting.
  static const double stopDetectionThresholdMph = 4.0;

  /// Number of consecutive readings above threshold required before
  /// reporting movement in normal mode.
  static const int normalConsecutiveThreshold = 2;

  /// Number of consecutive readings above threshold required before
  /// reporting movement when screen is dimmed.
  static const int dimmedConsecutiveThreshold = 3;

  double? _lastAcceptedSpeed;
  double? _previousRawSpeed;
  int _consecutiveAboveThreshold = 0;
  bool _isMoving = false;

  /// Applies the full speed filtering pipeline to a raw speed reading.
  ///
  /// [rawSpeedMph] is the unfiltered GPS speed in miles per hour.
  /// [elapsedSeconds] is the time since the last reading in seconds.
  /// [isDimmed] indicates whether the screen is currently dimmed,
  /// which increases the consecutive reading threshold.
  ///
  /// Returns a [FilterResult] with the filtered speed, movement status,
  /// and whether the reading was discarded.
  FilterResult filter(
    double rawSpeedMph,
    double elapsedSeconds, {
    bool isDimmed = false,
  }) {
    // Step 1: Dither elimination - speeds below 2.5 mph → zero
    if (rawSpeedMph < ditherThresholdMph) {
      _consecutiveAboveThreshold = 0;
      _isMoving = false;
      _previousRawSpeed = rawSpeedMph;
      _lastAcceptedSpeed = rawSpeedMph;
      return FilterResult(
        filteredSpeedMph: 0,
        isMoving: false,
        wasDiscarded: false,
      );
    }

    // Step 2: Spike rejection - discard if acceleration exceeds 8 mph/s
    if (_lastAcceptedSpeed != null && elapsedSeconds > 0) {
      final acceleration =
          (rawSpeedMph - _lastAcceptedSpeed!) / elapsedSeconds;
      if (acceleration > maxAccelerationMphPerSec) {
        // Discard this reading, retain last accepted speed
        _previousRawSpeed = rawSpeedMph;
        return FilterResult(
          filteredSpeedMph: _lastAcceptedSpeed!.truncate(),
          isMoving: _isMoving,
          wasDiscarded: true,
        );
      }
    }

    // Step 3: Responsive stop detection - speed < 4 mph and decreasing → zero
    if (rawSpeedMph < stopDetectionThresholdMph &&
        _previousRawSpeed != null &&
        rawSpeedMph < _previousRawSpeed!) {
      _consecutiveAboveThreshold = 0;
      _isMoving = false;
      _previousRawSpeed = rawSpeedMph;
      _lastAcceptedSpeed = rawSpeedMph;
      return FilterResult(
        filteredSpeedMph: 0,
        isMoving: false,
        wasDiscarded: false,
      );
    }

    // Step 4: Consecutive reading threshold
    _consecutiveAboveThreshold++;
    // Track this as the last accepted speed for spike rejection purposes,
    // regardless of whether we've met the consecutive threshold yet.
    _lastAcceptedSpeed = rawSpeedMph;
    _previousRawSpeed = rawSpeedMph;

    final requiredConsecutive =
        isDimmed ? dimmedConsecutiveThreshold : normalConsecutiveThreshold;

    if (_consecutiveAboveThreshold >= requiredConsecutive) {
      _isMoving = true;
      return FilterResult(
        filteredSpeedMph: rawSpeedMph.truncate(),
        isMoving: true,
        wasDiscarded: false,
      );
    } else {
      // Not enough consecutive readings yet - report zero
      return FilterResult(
        filteredSpeedMph: 0,
        isMoving: false,
        wasDiscarded: false,
      );
    }
  }

  /// Resets the filter state. Call on GPS signal loss to clear
  /// all accumulated state.
  void reset() {
    _lastAcceptedSpeed = null;
    _previousRawSpeed = null;
    _consecutiveAboveThreshold = 0;
    _isMoving = false;
  }
}

/// Result of the speed filtering pipeline.
class FilterResult {
  /// The filtered speed in miles per hour (integer, truncated).
  final int filteredSpeedMph;

  /// Whether the vehicle is considered to be in motion.
  final bool isMoving;

  /// Whether the raw reading was discarded (e.g., spike rejection).
  final bool wasDiscarded;

  const FilterResult({
    required this.filteredSpeedMph,
    required this.isMoving,
    required this.wasDiscarded,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterResult &&
          runtimeType == other.runtimeType &&
          filteredSpeedMph == other.filteredSpeedMph &&
          isMoving == other.isMoving &&
          wasDiscarded == other.wasDiscarded;

  @override
  int get hashCode =>
      filteredSpeedMph.hashCode ^ isMoving.hashCode ^ wasDiscarded.hashCode;

  @override
  String toString() =>
      'FilterResult(filteredSpeedMph: $filteredSpeedMph, isMoving: $isMoving, wasDiscarded: $wasDiscarded)';
}
