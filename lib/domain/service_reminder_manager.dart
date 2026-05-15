/// Service reminder manager for tracking driving hours and maintenance reminders.
///
/// Accumulates driving time only when the vehicle is in motion,
/// stores in tenths of hours (6-minute resolution), and triggers
/// persistence every 1.0 hours of driving.
///
/// Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 7.10
library;

import 'dart:async';

import 'package:golf_cart_computer/data/repositories/preferences_repository.dart';

/// State emitted by the [ServiceReminderManager].
class ServiceState {
  /// Accumulated driving hours since last service, in tenths of hours.
  final double hoursSinceService;

  /// Configured service interval in hours (1-500, default 100).
  final int serviceIntervalHours;

  /// Whether service is due (hours >= interval).
  final bool isServiceDue;

  const ServiceState({
    required this.hoursSinceService,
    required this.serviceIntervalHours,
    required this.isServiceDue,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceState &&
          runtimeType == other.runtimeType &&
          hoursSinceService == other.hoursSinceService &&
          serviceIntervalHours == other.serviceIntervalHours &&
          isServiceDue == other.isServiceDue;

  @override
  int get hashCode =>
      hoursSinceService.hashCode ^
      serviceIntervalHours.hashCode ^
      isServiceDue.hashCode;

  @override
  String toString() =>
      'ServiceState(hoursSinceService: $hoursSinceService, '
      'serviceIntervalHours: $serviceIntervalHours, '
      'isServiceDue: $isServiceDue)';
}

/// Abstract interface for the service reminder manager.
abstract class ServiceReminderManager {
  /// Stream of service state updates.
  Stream<ServiceState> get serviceState;

  /// Accumulates driving time.
  ///
  /// [deltaSeconds] is the time elapsed since the last call.
  /// [isMoving] indicates whether the vehicle is currently in motion
  /// (filtered speed > 0).
  ///
  /// Only accumulates when [isMoving] is true and [deltaSeconds] is
  /// greater than 0 and less than or equal to 10 seconds.
  void accumulateTime(double deltaSeconds, bool isMoving);

  /// Resets the driving hours counter to zero.
  ///
  /// Callers should implement a confirmation step before invoking this.
  void resetHours();

  /// Persists the current driving hours to storage.
  Future<void> persist();
}

/// Default implementation of [ServiceReminderManager].
///
/// Stores driving hours in tenths of hours (6-minute resolution).
/// Persists automatically every 1.0 hours of accumulated driving.
class DefaultServiceReminderManager implements ServiceReminderManager {
  DefaultServiceReminderManager({
    required PreferencesRepository preferencesRepository,
    int serviceIntervalHours = 100,
  })  : _preferencesRepository = preferencesRepository,
        _serviceIntervalHours = serviceIntervalHours.clamp(1, 500);

  final PreferencesRepository _preferencesRepository;

  /// Maximum accepted time delta in seconds.
  static const double maxDeltaSeconds = 10.0;

  /// Seconds per tenth of an hour (360 seconds = 6 minutes).
  static const double secondsPerTenthHour = 360.0;

  /// Persistence trigger interval in tenths of hours (10 tenths = 1.0 hours).
  static const double persistenceIntervalTenths = 10.0;

  final _serviceStateController = StreamController<ServiceState>.broadcast();

  /// Accumulated driving time in tenths of hours.
  double _hoursTenths = 0.0;

  /// Configured service interval in hours.
  int _serviceIntervalHours;

  /// Accumulated tenths since last persistence.
  double _tenthsSinceLastPersist = 0.0;

  @override
  Stream<ServiceState> get serviceState => _serviceStateController.stream;

  /// The current accumulated hours in tenths (exposed for testing).
  double get currentHoursTenths => _hoursTenths;

  /// The configured service interval in hours.
  int get serviceIntervalHours => _serviceIntervalHours;

  /// Loads persisted driving hours from storage.
  ///
  /// Should be called once during initialization.
  Future<void> initialize() async {
    _hoursTenths = await _preferencesRepository.loadDrivingHours();
    _emitState();
  }

  /// Updates the service interval.
  ///
  /// [hours] must be between 1 and 500 (clamped if out of range).
  void setServiceInterval(int hours) {
    _serviceIntervalHours = hours.clamp(1, 500);
    _emitState();
  }

  @override
  void accumulateTime(double deltaSeconds, bool isMoving) {
    // Only accumulate when moving
    if (!isMoving) return;

    // Validate time delta: must be > 0 and ≤ 10 seconds
    if (deltaSeconds <= 0 || deltaSeconds > maxDeltaSeconds) return;

    // Convert seconds to tenths of hours and accumulate
    final tenthsToAdd = deltaSeconds / secondsPerTenthHour;
    _hoursTenths += tenthsToAdd;
    _tenthsSinceLastPersist += tenthsToAdd;

    // Check if persistence is needed (every 1.0 hours = 10 tenths)
    if (_tenthsSinceLastPersist >= persistenceIntervalTenths) {
      _tenthsSinceLastPersist = 0.0;
      persist();
    }

    _emitState();
  }

  @override
  void resetHours() {
    _hoursTenths = 0.0;
    _tenthsSinceLastPersist = 0.0;
    persist();
    _emitState();
  }

  @override
  Future<void> persist() async {
    await _preferencesRepository.persistDrivingHours(_hoursTenths);
  }

  /// Emits the current service state to listeners.
  void _emitState() {
    // Convert tenths of hours to hours for display (1 decimal place)
    final hoursForDisplay = _hoursTenths;
    final isServiceDue = (hoursForDisplay / 10.0) >= _serviceIntervalHours;

    _serviceStateController.add(ServiceState(
      hoursSinceService: hoursForDisplay,
      serviceIntervalHours: _serviceIntervalHours,
      isServiceDue: isServiceDue,
    ));
  }

  /// Disposes of stream controllers.
  void dispose() {
    _serviceStateController.close();
  }
}
