/// Meshtastic radio administration notifier for the Golf Cart Computer.
///
/// Provides radio admin operations including reboot with confirmation,
/// GPS interval configuration using read-modify-write pattern on
/// PositionConfig, admin command encoding with ADMIN_APP port to local
/// node number, timeout handling (10 seconds), and connected radio node
/// ID display in hex format.
///
/// Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.9
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protobuf/protobuf.dart';

import '../data/generated/meshtastic.dart';
import '../data/services/meshtastic_service.dart';
import '../domain/audio_service.dart';
import '../domain/models/connection_state.dart' as app;

/// GPS update interval when away from home (seconds).
const int kGpsIntervalAway = 8;

/// GPS update interval when at home (seconds).
const int kGpsIntervalHome = 120;

/// Admin command timeout duration.
const Duration kAdminCommandTimeout = Duration(seconds: 10);

/// Reboot delay in seconds sent to the radio.
const int kRebootDelaySeconds = 5;

/// State exposed by [RadioAdminNotifier] to the UI.
class RadioAdminState {
  /// The connected radio's node ID in hex format (e.g., "!a1b2c3d4"),
  /// or null if not connected.
  final String? nodeIdHex;

  /// Whether a reboot confirmation is pending.
  final bool rebootConfirmationPending;

  /// Whether an admin command is currently in progress.
  final bool isCommandInProgress;

  /// Error message from the last failed admin command, or null.
  final String? lastError;

  /// Success message from the last completed admin command, or null.
  final String? lastSuccess;

  const RadioAdminState({
    this.nodeIdHex,
    this.rebootConfirmationPending = false,
    this.isCommandInProgress = false,
    this.lastError,
    this.lastSuccess,
  });

  /// Creates a copy with the given fields replaced.
  RadioAdminState copyWith({
    String? nodeIdHex,
    bool clearNodeId = false,
    bool? rebootConfirmationPending,
    bool? isCommandInProgress,
    String? lastError,
    bool clearError = false,
    String? lastSuccess,
    bool clearSuccess = false,
  }) {
    return RadioAdminState(
      nodeIdHex: clearNodeId ? null : (nodeIdHex ?? this.nodeIdHex),
      rebootConfirmationPending:
          rebootConfirmationPending ?? this.rebootConfirmationPending,
      isCommandInProgress: isCommandInProgress ?? this.isCommandInProgress,
      lastError: clearError ? null : (lastError ?? this.lastError),
      lastSuccess: clearSuccess ? null : (lastSuccess ?? this.lastSuccess),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadioAdminState &&
          runtimeType == other.runtimeType &&
          nodeIdHex == other.nodeIdHex &&
          rebootConfirmationPending == other.rebootConfirmationPending &&
          isCommandInProgress == other.isCommandInProgress &&
          lastError == other.lastError &&
          lastSuccess == other.lastSuccess;

  @override
  int get hashCode => Object.hash(
        nodeIdHex,
        rebootConfirmationPending,
        isCommandInProgress,
        lastError,
        lastSuccess,
      );
}

/// Manages Meshtastic radio administration commands.
///
/// Coordinates with [BleMeshtasticService] for sending admin commands,
/// provides confirmation prompts for destructive operations (reboot),
/// implements read-modify-write pattern for GPS interval configuration,
/// and handles 10-second command timeouts with error display.
class RadioAdminNotifier extends StateNotifier<RadioAdminState> {
  final MeshtasticService _meshtasticService;
  final AudioService _audioService;

  StreamSubscription<String>? _nodeIdSubscription;
  StreamSubscription<app.ConnectionState>? _connectionSubscription;

  RadioAdminNotifier({
    required MeshtasticService meshtasticService,
    required AudioService audioService,
  })  : _meshtasticService = meshtasticService,
        _audioService = audioService,
        super(const RadioAdminState()) {
    _subscribeToNodeId();
    _subscribeToConnectionState();
  }

  /// Subscribes to the node ID stream to display the connected radio's
  /// node number in hex format.
  ///
  /// Requirement 12.1: Display connected radio node ID in hex format.
  void _subscribeToNodeId() {
    _nodeIdSubscription = _meshtasticService.nodeId.listen((hexId) {
      state = state.copyWith(nodeIdHex: hexId, clearError: true);
    });
  }

  /// Subscribes to connection state to clear node ID on disconnect.
  void _subscribeToConnectionState() {
    _connectionSubscription =
        _meshtasticService.connectionState.listen((connState) {
      if (connState == app.ConnectionState.disconnected) {
        state = state.copyWith(clearNodeId: true);
      }
    });
  }

  // ===========================================================================
  // Reboot Command
  // ===========================================================================

  /// Requests confirmation before rebooting the radio.
  ///
  /// Requirement 12.2: Display a confirmation prompt before sending reboot.
  void requestReboot() {
    state = state.copyWith(
      rebootConfirmationPending: true,
      clearError: true,
      clearSuccess: true,
    );
  }

  /// Cancels the pending reboot confirmation.
  void cancelReboot() {
    state = state.copyWith(rebootConfirmationPending: false);
  }

  /// Confirms and executes the reboot command with a 5-second delay.
  ///
  /// Requirement 12.2: Send reboot admin command with 5-second delay.
  /// Requirement 12.6: Encode admin command using ADMIN_APP port to local node.
  /// Requirement 12.9: Handle timeout (10 seconds) with error display.
  Future<void> confirmReboot() async {
    state = state.copyWith(
      rebootConfirmationPending: false,
      isCommandInProgress: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await _executeWithTimeout(() async {
        await _meshtasticService.rebootRadio(delaySeconds: kRebootDelaySeconds);
      });

      state = state.copyWith(
        isCommandInProgress: false,
        lastSuccess: 'Reboot command sent. Radio will restart in '
            '$kRebootDelaySeconds seconds.',
      );
      await _audioService.playConfirmation();
    } catch (e) {
      state = state.copyWith(
        isCommandInProgress: false,
        lastError: _formatError(e),
      );
      await _audioService.playError();
    }
  }

  // ===========================================================================
  // GPS Interval Configuration
  // ===========================================================================

  /// Sets the GPS update interval on the radio using read-modify-write.
  ///
  /// Reads the stored PositionConfig from the handshake, modifies only the
  /// `gpsUpdateInterval` field, and writes the updated config back.
  ///
  /// Requirement 12.3: Extract and store position config from handshake.
  /// Requirement 12.4: Support setting GPS update interval (8s away, 120s home).
  /// Requirement 12.5: Use read-modify-write pattern preserving other fields.
  /// Requirement 12.6: Encode using ADMIN_APP port to local node number.
  /// Requirement 12.9: Handle timeout (10 seconds) with error display.
  Future<void> setGpsInterval({required bool isAtHome}) async {
    final intervalSeconds = isAtHome ? kGpsIntervalHome : kGpsIntervalAway;

    state = state.copyWith(
      isCommandInProgress: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      // Read-modify-write: get stored config from handshake
      final storedConfig = _getStoredPositionConfig();
      if (storedConfig == null) {
        throw StateError(
          'No stored position config available. '
          'Radio handshake may not have completed.',
        );
      }

      // Clone and modify only the GPS update interval field
      final updatedConfig = storedConfig.deepCopy()
        ..gpsUpdateInterval = intervalSeconds;

      await _executeWithTimeout(() async {
        await _meshtasticService.setPositionConfig(updatedConfig);
      });

      state = state.copyWith(
        isCommandInProgress: false,
        lastSuccess: 'GPS interval set to $intervalSeconds seconds.',
      );
      await _audioService.playConfirmation();
    } catch (e) {
      state = state.copyWith(
        isCommandInProgress: false,
        lastError: _formatError(e),
      );
      await _audioService.playError();
    }
  }

  // ===========================================================================
  // Generic Admin Command
  // ===========================================================================

  /// Sends a generic admin message to the local node.
  ///
  /// Requirement 12.6: Encode admin commands using ADMIN_APP port with
  /// protobuf AdminMessage format, addressed to the local node number.
  /// Requirement 12.9: Handle timeout (10 seconds) with error display.
  Future<void> sendAdminCommand(AdminMessage message) async {
    state = state.copyWith(
      isCommandInProgress: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await _executeWithTimeout(() async {
        await _meshtasticService.sendAdminMessage(message);
      });

      state = state.copyWith(
        isCommandInProgress: false,
        lastSuccess: 'Admin command sent successfully.',
      );
      await _audioService.playConfirmation();
    } catch (e) {
      state = state.copyWith(
        isCommandInProgress: false,
        lastError: _formatError(e),
      );
      await _audioService.playError();
    }
  }

  // ===========================================================================
  // Error/Success Clearing
  // ===========================================================================

  /// Clears the last error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clears the last success message.
  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// Executes an async operation with a 10-second timeout.
  ///
  /// Requirement 12.9: If an admin command fails due to BLE disconnection
  /// or no response within 10 seconds, display an error message.
  Future<void> _executeWithTimeout(Future<void> Function() operation) async {
    await operation().timeout(
      kAdminCommandTimeout,
      onTimeout: () {
        throw TimeoutException(
          'Admin command timed out after '
          '${kAdminCommandTimeout.inSeconds} seconds',
        );
      },
    );
  }

  /// Gets the stored position config from the BLE service.
  ///
  /// Requirement 12.3: The position config is extracted and stored during
  /// the handshake when a `config` message of type PositionConfig is received.
  Config_PositionConfig? _getStoredPositionConfig() {
    final service = _meshtasticService;
    if (service is BleMeshtasticService) {
      return service.storedPositionConfig;
    }
    return null;
  }

  /// Formats an error for display.
  String _formatError(Object error) {
    if (error is TimeoutException) {
      return 'Command not completed: no response within '
          '${kAdminCommandTimeout.inSeconds} seconds.';
    }
    if (error is StateError) {
      return error.message;
    }
    return 'Admin command failed: $error';
  }

  @override
  void dispose() {
    _nodeIdSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }
}
