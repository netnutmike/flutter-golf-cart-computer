import 'dart:async';
import 'dart:math' as math;

import 'package:golf_cart_computer/domain/models/gps_data.dart';
import 'package:golf_cart_computer/domain/speed_filter.dart';

/// Processes raw GPS data from the device sensor and/or Meshtastic position
/// packets, emitting filtered [ProcessedGpsData] and [NavigationData] streams.
///
/// Implements:
/// - Speed filtering via [SpeedFilter]
/// - Heading conversion to 16-point cardinal direction (22.5° intervals)
/// - Satellite count debounce (3 consecutive zeros before displaying zero)
/// - HDOP estimation from satellite count when unavailable
/// - Dual GPS source: device sensor primary, Meshtastic fallback
/// - "NO GPS" detection after 60 seconds without time update
/// - Invalid speed handling
/// - Sunrise/sunset calculation from GPS location and date
abstract class GpsProcessor {
  /// Stream of processed GPS data after filtering and validation.
  Stream<ProcessedGpsData> get gpsState;

  /// Stream of navigation display data (date, time, sunrise, sunset).
  Stream<NavigationData> get navigationData;

  /// Process a raw position from the device's internal GPS sensor.
  void processRawPosition(RawPosition position);

  /// Process a position received from the Meshtastic radio (fallback source).
  void processMeshtasticPosition(MeshtasticPosition position);
}

/// 16-point cardinal directions in clockwise order starting from North.
const List<String> _cardinalDirections = [
  'N', 'NNE', 'NE', 'ENE',
  'E', 'ESE', 'SE', 'SSE',
  'S', 'SSW', 'SW', 'WSW',
  'W', 'WNW', 'NW', 'NNW',
];

/// Converts a bearing in degrees [0, 360) to a 16-point cardinal direction.
///
/// Each direction spans 22.5°, centered on its cardinal point.
/// For example, N spans from 348.75° to 11.25°.
String bearingToCardinal(double bearingDegrees) {
  // Normalize bearing to [0, 360)
  final normalized = ((bearingDegrees % 360) + 360) % 360;
  // Add half-interval (11.25°) to shift boundaries, then divide by 22.5°
  final index = ((normalized + 11.25) / 22.5).floor() % 16;
  return _cardinalDirections[index];
}

/// Estimates HDOP from satellite count when direct HDOP data is unavailable.
///
/// - ≥6 satellites: 1.5 (good accuracy)
/// - 4-5 satellites: 2.0 (moderate accuracy)
/// - <4 satellites: 99.0 (poor/no accuracy)
double estimateHdop(int satelliteCount) {
  if (satelliteCount >= 6) return 1.5;
  if (satelliteCount >= 4) return 2.0;
  return 99.0;
}

/// Calculates sunrise and sunset times for a given location and date.
///
/// Uses a simplified solar position algorithm based on the
/// "Sunrise/Sunset Algorithm" from the US Naval Observatory.
/// Returns a record with sunrise and sunset as local [DateTime].
({DateTime sunrise, DateTime sunset}) calculateSunriseSunset({
  required double latitude,
  required double longitude,
  required DateTime date,
}) {
  // Day of year
  final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;

  // Convert longitude to hour value
  final lngHour = longitude / 15.0;

  // Sunrise: t = dayOfYear + ((6 - lngHour) / 24)
  final tRise = dayOfYear + ((6 - lngHour) / 24);
  // Sunset: t = dayOfYear + ((18 - lngHour) / 24)
  final tSet = dayOfYear + ((18 - lngHour) / 24);

  // Sun's mean anomaly
  final mRise = (0.9856 * tRise) - 3.289;
  final mSet = (0.9856 * tSet) - 3.289;

  // Sun's true longitude
  double sunTrueLong(double m) {
    final mRad = m * math.pi / 180.0;
    var l = m +
        (1.916 * math.sin(mRad)) +
        (0.020 * math.sin(2 * mRad)) +
        282.634;
    // Normalize to [0, 360)
    l = ((l % 360) + 360) % 360;
    return l;
  }

  final lRise = sunTrueLong(mRise);
  final lSet = sunTrueLong(mSet);

  // Sun's right ascension
  double rightAscension(double l) {
    final lRad = l * math.pi / 180.0;
    var ra = math.atan(0.91764 * math.tan(lRad)) * 180.0 / math.pi;
    // Normalize to [0, 360)
    ra = ((ra % 360) + 360) % 360;

    // RA must be in same quadrant as L
    final lQuadrant = (l / 90.0).floor() * 90;
    final raQuadrant = (ra / 90.0).floor() * 90;
    ra += (lQuadrant - raQuadrant);

    // Convert to hours
    ra /= 15.0;
    return ra;
  }

  final raRise = rightAscension(lRise);
  final raSet = rightAscension(lSet);

  // Sun's declination
  double sinDec(double l) {
    final lRad = l * math.pi / 180.0;
    return 0.39782 * math.sin(lRad);
  }

  double cosDec(double sinD) {
    return math.cos(math.asin(sinD));
  }

  final sinDecRise = sinDec(lRise);
  final cosDecRise = cosDec(sinDecRise);
  final sinDecSet = sinDec(lSet);
  final cosDecSet = cosDec(sinDecSet);

  // Sun's local hour angle
  final latRad = latitude * math.pi / 180.0;
  // Zenith for official sunrise/sunset = 90.833 degrees
  final cosZenith = math.cos(90.833 * math.pi / 180.0);

  double localHourAngle(double sinD, double cosD, {required bool isRise}) {
    final cosH =
        (cosZenith - (sinD * math.sin(latRad))) / (cosD * math.cos(latRad));

    // Clamp to valid range (handles polar regions)
    final clampedCosH = cosH.clamp(-1.0, 1.0);
    final h = math.acos(clampedCosH) * 180.0 / math.pi;

    if (isRise) {
      return (360 - h) / 15.0;
    } else {
      return h / 15.0;
    }
  }

  final hRise = localHourAngle(sinDecRise, cosDecRise, isRise: true);
  final hSet = localHourAngle(sinDecSet, cosDecSet, isRise: false);

  // Local mean time
  final localMeanTimeRise = hRise + raRise - (0.06571 * tRise) - 6.622;
  final localMeanTimeSet = hSet + raSet - (0.06571 * tSet) - 6.622;

  // UTC time
  var utcRise = localMeanTimeRise - lngHour;
  var utcSet = localMeanTimeSet - lngHour;

  // Normalize to [0, 24)
  utcRise = ((utcRise % 24) + 24) % 24;
  utcSet = ((utcSet % 24) + 24) % 24;

  // Convert to local DateTime
  final sunriseUtc = DateTime.utc(
    date.year,
    date.month,
    date.day,
    utcRise.floor(),
    ((utcRise - utcRise.floor()) * 60).round(),
  );
  final sunsetUtc = DateTime.utc(
    date.year,
    date.month,
    date.day,
    utcSet.floor(),
    ((utcSet - utcSet.floor()) * 60).round(),
  );

  return (sunrise: sunriseUtc.toLocal(), sunset: sunsetUtc.toLocal());
}

/// Default implementation of [GpsProcessor].
///
/// Uses device GPS as primary source, falling back to Meshtastic GPS
/// when the device sensor is unavailable or reports zero satellites.
class DefaultGpsProcessor implements GpsProcessor {
  DefaultGpsProcessor({
    SpeedFilter? speedFilter,
  }) : _speedFilter = speedFilter ?? SpeedFilter();

  final SpeedFilter _speedFilter;

  final _gpsStateController = StreamController<ProcessedGpsData>.broadcast();
  final _navigationDataController = StreamController<NavigationData>.broadcast();

  /// Duration after which "NO GPS" is displayed if no time update received.
  static const Duration noGpsTimeout = Duration(seconds: 60);

  /// Number of consecutive zero-satellite readings required before
  /// displaying zero.
  static const int satelliteDebounceCount = 3;

  /// Speed threshold below which we report zero on invalid speed.
  static const double invalidSpeedRetainThreshold = 5.0;

  // State tracking
  DateTime? _lastTimeUpdate;
  DateTime? _lastPositionTimestamp;
  int _consecutiveZeroSatellites = 0;
  int _displayedSatelliteCount = 0;
  int _lastFilteredSpeed = 0;
  bool _hasDeviceGps = false;

  @override
  Stream<ProcessedGpsData> get gpsState => _gpsStateController.stream;

  @override
  Stream<NavigationData> get navigationData => _navigationDataController.stream;

  @override
  void processRawPosition(RawPosition position) {
    _hasDeviceGps = position.isValid && position.satelliteCount > 0;
    _processPosition(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      rawSpeedMph: position.speedMph,
      headingDegrees: position.headingDegrees,
      satelliteCount: position.satelliteCount,
      hdop: position.hdop,
      timestamp: position.timestamp,
      isValid: position.isValid,
      isSpeedValid: position.speedMph >= 0,
    );
  }

  @override
  void processMeshtasticPosition(MeshtasticPosition position) {
    // Only use Meshtastic GPS as fallback when device GPS is unavailable
    if (_hasDeviceGps) return;

    _processPosition(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      rawSpeedMph: position.speedMph,
      headingDegrees: position.headingDegrees,
      satelliteCount: position.satelliteCount,
      hdop: null,
      timestamp: position.timestamp,
      isValid: true,
      isSpeedValid: position.speedMph >= 0,
    );
  }

  void _processPosition({
    required double latitude,
    required double longitude,
    required double altitude,
    required double rawSpeedMph,
    required double headingDegrees,
    required int satelliteCount,
    required double? hdop,
    required DateTime timestamp,
    required bool isValid,
    required bool isSpeedValid,
  }) {
    // Calculate elapsed time since last position
    final elapsed = _lastPositionTimestamp != null
        ? timestamp.difference(_lastPositionTimestamp!).inMilliseconds / 1000.0
        : 1.0;

    // Update time tracking
    _lastTimeUpdate = DateTime.now();
    _lastPositionTimestamp = timestamp;

    // Speed filtering
    int filteredSpeed;
    if (isSpeedValid) {
      final result = _speedFilter.filter(rawSpeedMph, elapsed);
      filteredSpeed = result.filteredSpeedMph;
    } else {
      // Invalid speed handling: zero if last speed < 5 mph, else retain
      if (_lastFilteredSpeed < invalidSpeedRetainThreshold) {
        filteredSpeed = 0;
      } else {
        filteredSpeed = _lastFilteredSpeed;
      }
    }
    _lastFilteredSpeed = filteredSpeed;

    // Heading conversion
    final cardinal = bearingToCardinal(headingDegrees);

    // Satellite count debounce
    final displayedSats = _debounceSatelliteCount(satelliteCount);

    // HDOP estimation
    final displayedHdop = hdop ?? estimateHdop(displayedSats);

    // Emit processed GPS data
    final processedData = ProcessedGpsData(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      speedMph: filteredSpeed,
      rawSpeedMph: rawSpeedMph,
      headingDegrees: headingDegrees,
      cardinalDirection: cardinal,
      satelliteCount: displayedSats,
      hdop: displayedHdop,
      timestamp: timestamp,
      isValid: isValid,
    );
    _gpsStateController.add(processedData);

    // Emit navigation data
    _emitNavigationData(
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
    );
  }

  /// Applies satellite count debounce logic.
  ///
  /// Requires 3 consecutive zero readings before displaying zero.
  /// Non-zero readings reset the counter and display immediately.
  int _debounceSatelliteCount(int rawCount) {
    if (rawCount == 0) {
      _consecutiveZeroSatellites++;
      if (_consecutiveZeroSatellites >= satelliteDebounceCount) {
        _displayedSatelliteCount = 0;
      }
      // Otherwise retain last non-zero count
    } else {
      _consecutiveZeroSatellites = 0;
      _displayedSatelliteCount = rawCount;
    }
    return _displayedSatelliteCount;
  }

  /// Emits navigation data including date, time, sunrise/sunset.
  void _emitNavigationData({
    required double latitude,
    required double longitude,
    required DateTime timestamp,
  }) {
    // Check for "NO GPS" condition
    final now = DateTime.now();
    final hasGps = _lastTimeUpdate != null &&
        now.difference(_lastTimeUpdate!) < noGpsTimeout;

    // Convert GPS time (UTC) to local time
    final localTime = timestamp.toLocal();

    // Format date: "Mon, Jan 15"
    final dateString = hasGps ? _formatDate(localTime) : 'NO GPS';

    // Format time: "2:30 PM"
    final timeString = _formatTime(localTime);

    // Calculate sunrise/sunset
    final sunTimes = calculateSunriseSunset(
      latitude: latitude,
      longitude: longitude,
      date: localTime,
    );

    final sunriseString = _formatTime(sunTimes.sunrise);
    final sunsetString = _formatTime(sunTimes.sunset);

    // Determine if daytime
    final isDaytime = localTime.isAfter(sunTimes.sunrise) &&
        localTime.isBefore(sunTimes.sunset);

    _navigationDataController.add(NavigationData(
      dateString: dateString,
      timeString: timeString,
      sunriseTime: sunriseString,
      sunsetTime: sunsetString,
      isDaytime: isDaytime,
    ));
  }

  /// Checks if GPS signal has been lost (no update for 60 seconds).
  bool get isGpsLost {
    if (_lastTimeUpdate == null) return true;
    return DateTime.now().difference(_lastTimeUpdate!) >= noGpsTimeout;
  }

  /// Formats a DateTime as "Mon, Jan 15".
  String _formatDate(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, $monthName ${dt.day}';
  }

  /// Formats a DateTime as "2:30 PM" (12-hour format).
  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Disposes of stream controllers.
  void dispose() {
    _gpsStateController.close();
    _navigationDataController.close();
  }
}
