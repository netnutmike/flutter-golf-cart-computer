/// Cross-platform permission management for the Golf Cart Computer.
///
/// Provides unified permission handling using the `permission_handler` package.
/// Requests permissions at point of first use (not at startup), displays
/// rationale dialogs before system prompts, and handles platform-specific
/// denied states including "Don't ask again" on Android and Restricted/Denied
/// states on iOS.
///
/// Detects permission state changes when the app returns to the foreground.
///
/// Requirements: 21.1, 21.2, 21.3, 21.4, 21.5, 21.6, 21.7, 21.10, 21.11
library;

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

/// The result of a permission request operation.
enum PermissionResult {
  /// Permission was granted; proceed with the protected operation.
  granted,

  /// Permission was denied by the user.
  denied,

  /// Permission is permanently denied (Android "Don't ask again") or
  /// iOS "Denied" state — user must go to system settings.
  permanentlyDenied,

  /// iOS only: permission is restricted by device policy (MDM, parental
  /// controls). The user cannot grant it.
  restricted,
}

/// Describes a permission group with its associated feature context.
///
/// Used to display rationale dialogs and denied-state messages that
/// identify which feature requires the permission.
class PermissionRequest {
  /// The permission(s) to request.
  final List<Permission> permissions;

  /// Human-readable name of the feature requiring this permission.
  final String featureName;

  /// Rationale message explaining why the permission is needed.
  /// Displayed before the system prompt.
  final String rationale;

  /// Message displayed when the permission is denied, identifying
  /// which feature is unavailable.
  final String deniedMessage;

  const PermissionRequest({
    required this.permissions,
    required this.featureName,
    required this.rationale,
    required this.deniedMessage,
  });
}

/// Pre-defined permission requests for the Golf Cart Computer features.
///
/// Requirements 21.1, 21.2: Bluetooth and Location permission groups.
class PermissionRequests {
  PermissionRequests._();

  /// Bluetooth permissions required before any Bluetooth operations.
  ///
  /// Requirement 21.1: BLUETOOTH_SCAN and BLUETOOTH_CONNECT on Android 12+,
  /// CBCentralManager authorization on iOS.
  static const bluetooth = PermissionRequest(
    permissions: [Permission.bluetoothScan, Permission.bluetoothConnect],
    featureName: 'Bluetooth',
    rationale:
        'Bluetooth is required to connect to the Meshtastic radio and GCI '
        'telemetry computer. Without this permission, mesh messaging and '
        'vehicle telemetry features will be unavailable.',
    deniedMessage:
        'Bluetooth permission denied. Mesh messaging and vehicle telemetry '
        'features are unavailable.',
  );

  /// Location permission required before accessing GPS.
  ///
  /// Requirement 21.2: ACCESS_FINE_LOCATION on Android, "When In Use"
  /// location authorization on iOS.
  static const location = PermissionRequest(
    permissions: [Permission.locationWhenInUse],
    featureName: 'Location',
    rationale:
        'Location access is required for GPS navigation, speed display, '
        'odometer tracking, and geofence detection. Without this permission, '
        'navigation features will be unavailable.',
    deniedMessage:
        'Location permission denied. GPS navigation, speed, odometer, and '
        'geofence features are unavailable.',
  );
}

/// Callback signature for displaying a rationale dialog to the user.
///
/// The implementation should show a dialog explaining why the permission
/// is needed and return `true` if the user agrees to proceed with the
/// system prompt, or `false` to cancel.
typedef RationaleDialogCallback = Future<bool> Function(
  BuildContext context,
  PermissionRequest request,
);

/// Callback signature for displaying a denied-state message with a
/// settings button.
///
/// The implementation should show a message identifying the unavailable
/// feature and provide a button that opens system settings.
typedef DeniedDialogCallback = Future<void> Function(
  BuildContext context,
  PermissionRequest request,
  PermissionResult result,
);

/// Manages cross-platform permission requests with rationale dialogs,
/// denied-state handling, and foreground state change detection.
///
/// This class is designed to be used at the point of first use for each
/// feature (Requirement 21.10), not at application startup.
///
/// Usage:
/// ```dart
/// final result = await permissionManager.requestPermission(
///   context,
///   PermissionRequests.bluetooth,
/// );
/// if (result == PermissionResult.granted) {
///   // Proceed with Bluetooth operations.
/// }
/// ```
class PermissionManager with WidgetsBindingObserver {
  /// Callback to display a rationale dialog before the system prompt.
  ///
  /// Requirement 21.3: Display rationale stating the feature and consequence.
  final RationaleDialogCallback showRationaleDialog;

  /// Callback to display a denied-state message with settings button.
  ///
  /// Requirements 21.4, 21.5, 21.6: Handle denied, permanently denied,
  /// and iOS-specific states.
  final DeniedDialogCallback showDeniedDialog;

  /// Listeners notified when permission states change after returning
  /// to the foreground.
  ///
  /// Requirement 21.11: Detect permission state changes when app returns
  /// to foreground.
  final List<PermissionChangeListener> _listeners = [];

  /// Tracks which permissions have been requested at least once during
  /// this session, to avoid showing rationale repeatedly.
  final Set<Permission> _requestedPermissions = {};

  /// Whether this manager is currently observing app lifecycle changes.
  bool _isObserving = false;

  PermissionManager({
    required this.showRationaleDialog,
    required this.showDeniedDialog,
  });

  /// Starts observing app lifecycle changes to detect permission state
  /// updates when the app returns to the foreground.
  ///
  /// Requirement 21.11: Detect permission state changes on foreground return.
  void startObserving() {
    if (!_isObserving) {
      WidgetsBinding.instance.addObserver(this);
      _isObserving = true;
    }
  }

  /// Stops observing app lifecycle changes.
  void stopObserving() {
    if (_isObserving) {
      WidgetsBinding.instance.removeObserver(this);
      _isObserving = false;
    }
  }

  /// Registers a listener for permission state changes detected on
  /// foreground return.
  void addPermissionChangeListener(PermissionChangeListener listener) {
    _listeners.add(listener);
  }

  /// Removes a previously registered permission change listener.
  void removePermissionChangeListener(PermissionChangeListener listener) {
    _listeners.remove(listener);
  }

  /// Requests a permission group, handling the full flow:
  ///
  /// 1. Check current status — if already granted, return immediately.
  /// 2. Display rationale dialog (Requirement 21.3).
  /// 3. Invoke system permission prompt.
  /// 4. Handle result: granted, denied, permanently denied, or restricted.
  ///
  /// Requirement 21.10: Called at point of first use, not at startup.
  ///
  /// Returns [PermissionResult.granted] if all permissions in the group
  /// are granted, otherwise returns the most restrictive denial state.
  Future<PermissionResult> requestPermission(
    BuildContext context,
    PermissionRequest request,
  ) async {
    // Step 1: Check if all permissions are already granted.
    final currentStatuses = await _checkStatuses(request.permissions);
    if (_allGranted(currentStatuses)) {
      return PermissionResult.granted;
    }

    // Check for iOS Restricted state (Requirement 21.6).
    if (_anyRestricted(currentStatuses)) {
      if (context.mounted) {
        await showDeniedDialog(context, request, PermissionResult.restricted);
      }
      return PermissionResult.restricted;
    }

    // Check for permanently denied state (Requirement 21.5 Android,
    // 21.6 iOS Denied).
    if (_anyPermanentlyDenied(currentStatuses)) {
      if (context.mounted) {
        await showDeniedDialog(
          context,
          request,
          PermissionResult.permanentlyDenied,
        );
      }
      return PermissionResult.permanentlyDenied;
    }

    // Step 2: Show rationale dialog before system prompt (Requirement 21.3).
    // Only show rationale if we haven't already requested this session
    // or if the permission was previously denied (shouldShowRequestRationale).
    final shouldShowRationale =
        !_allPreviouslyRequested(request.permissions) ||
            await _shouldShowRationale(request.permissions);

    if (shouldShowRationale && context.mounted) {
      final userAgreed = await showRationaleDialog(context, request);
      if (!userAgreed) {
        return PermissionResult.denied;
      }
    }

    // Mark permissions as requested this session.
    _requestedPermissions.addAll(request.permissions);

    // Step 3: Request permissions from the system.
    final results = await request.permissions.request();

    // Step 4: Evaluate results.
    final result = _evaluateResults(results);

    // If denied or permanently denied, show the denied dialog
    // (Requirements 21.4, 21.5).
    if (result != PermissionResult.granted && context.mounted) {
      await showDeniedDialog(context, request, result);
    }

    return result;
  }

  /// Checks the current status of a single permission without requesting it.
  ///
  /// Useful for checking permission state before deciding whether to
  /// show UI elements that depend on a permission.
  Future<PermissionResult> checkPermission(Permission permission) async {
    final status = await permission.status;
    return _mapStatus(status);
  }

  /// Checks the current status of a permission group without requesting.
  ///
  /// Returns [PermissionResult.granted] only if all permissions in the
  /// group are granted.
  Future<PermissionResult> checkPermissionGroup(
    PermissionRequest request,
  ) async {
    final statuses = await _checkStatuses(request.permissions);
    if (_allGranted(statuses)) return PermissionResult.granted;
    if (_anyRestricted(statuses)) return PermissionResult.restricted;
    if (_anyPermanentlyDenied(statuses)) {
      return PermissionResult.permanentlyDenied;
    }
    return PermissionResult.denied;
  }

  /// Opens the app's system settings page.
  ///
  /// Requirements 21.4, 21.5, 21.6: Provide a way to open settings
  /// when permission is denied or permanently denied.
  Future<bool> openSettings() async {
    return openAppSettings();
  }

  /// Called when the app lifecycle state changes.
  ///
  /// Requirement 21.11: When the app returns to the foreground, check
  /// if any previously denied permissions have been granted via settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionChangesOnResume();
    }
  }

  /// Checks all previously requested permissions for state changes
  /// after the app returns to the foreground.
  Future<void> _checkPermissionChangesOnResume() async {
    if (_requestedPermissions.isEmpty) return;

    final changedPermissions = <Permission, PermissionResult>{};

    for (final permission in _requestedPermissions) {
      final status = await permission.status;
      final result = _mapStatus(status);
      // We only notify about newly granted permissions, since that's
      // the actionable state change (feature can now be enabled).
      if (result == PermissionResult.granted) {
        changedPermissions[permission] = result;
      }
    }

    if (changedPermissions.isNotEmpty) {
      for (final listener in _listeners) {
        listener.onPermissionsChanged(changedPermissions);
      }
    }
  }

  /// Checks the status of multiple permissions.
  Future<Map<Permission, PermissionStatus>> _checkStatuses(
    List<Permission> permissions,
  ) async {
    final Map<Permission, PermissionStatus> statuses = {};
    for (final permission in permissions) {
      statuses[permission] = await permission.status;
    }
    return statuses;
  }

  /// Returns true if all permissions are granted.
  bool _allGranted(Map<Permission, PermissionStatus> statuses) {
    return statuses.values.every((s) => s.isGranted);
  }

  /// Returns true if any permission is in the restricted state (iOS).
  bool _anyRestricted(Map<Permission, PermissionStatus> statuses) {
    return statuses.values.any((s) => s.isRestricted);
  }

  /// Returns true if any permission is permanently denied.
  bool _anyPermanentlyDenied(Map<Permission, PermissionStatus> statuses) {
    return statuses.values.any((s) => s.isPermanentlyDenied);
  }

  /// Returns true if all permissions have been requested at least once
  /// this session.
  bool _allPreviouslyRequested(List<Permission> permissions) {
    return permissions.every((p) => _requestedPermissions.contains(p));
  }

  /// Checks if the system recommends showing a rationale for any of
  /// the given permissions (Android-specific).
  Future<bool> _shouldShowRationale(List<Permission> permissions) async {
    // On iOS, shouldShowRequestRationale is not applicable.
    if (!Platform.isAndroid) return false;

    for (final permission in permissions) {
      final shouldShow = await permission.shouldShowRequestRationale;
      if (shouldShow) return true;
    }
    return false;
  }

  /// Evaluates the results of a permission request and returns the
  /// most restrictive result.
  PermissionResult _evaluateResults(
    Map<Permission, PermissionStatus> results,
  ) {
    if (results.values.every((s) => s.isGranted)) {
      return PermissionResult.granted;
    }

    if (results.values.any((s) => s.isRestricted)) {
      return PermissionResult.restricted;
    }

    if (results.values.any((s) => s.isPermanentlyDenied)) {
      return PermissionResult.permanentlyDenied;
    }

    return PermissionResult.denied;
  }

  /// Maps a single [PermissionStatus] to a [PermissionResult].
  PermissionResult _mapStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        return PermissionResult.granted;
      case PermissionStatus.restricted:
        return PermissionResult.restricted;
      case PermissionStatus.permanentlyDenied:
        return PermissionResult.permanentlyDenied;
      case PermissionStatus.denied:
        return PermissionResult.denied;
    }
  }

  /// Releases resources and stops lifecycle observation.
  void dispose() {
    stopObserving();
    _listeners.clear();
    _requestedPermissions.clear();
  }
}

/// Interface for receiving permission state change notifications.
///
/// Requirement 21.11: Enable features without app restart when permissions
/// are granted via system settings.
abstract class PermissionChangeListener {
  /// Called when one or more permissions have changed state after the
  /// app returned to the foreground.
  ///
  /// The map contains only permissions whose state changed to granted,
  /// enabling the corresponding features to be activated.
  void onPermissionsChanged(Map<Permission, PermissionResult> changes);
}
