//
//  Generated code. Do not modify.
//  source: config.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'config.pbenum.dart';

export 'config.pbenum.dart';

/// *
///  Device configuration.
class Config_DeviceConfig extends $pb.GeneratedMessage {
  factory Config_DeviceConfig({
    Config_DeviceConfig_Role? role,
    $core.bool? serialEnabled,
    $core.bool? debugLogEnabled,
    $core.int? buttonGpio,
    $core.int? buzzerGpio,
  }) {
    final $result = create();
    if (role != null) {
      $result.role = role;
    }
    if (serialEnabled != null) {
      $result.serialEnabled = serialEnabled;
    }
    if (debugLogEnabled != null) {
      $result.debugLogEnabled = debugLogEnabled;
    }
    if (buttonGpio != null) {
      $result.buttonGpio = buttonGpio;
    }
    if (buzzerGpio != null) {
      $result.buzzerGpio = buzzerGpio;
    }
    return $result;
  }
  Config_DeviceConfig._() : super();
  factory Config_DeviceConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Config_DeviceConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Config.DeviceConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..e<Config_DeviceConfig_Role>(1, _omitFieldNames ? '' : 'role', $pb.PbFieldType.OE, defaultOrMaker: Config_DeviceConfig_Role.CLIENT, valueOf: Config_DeviceConfig_Role.valueOf, enumValues: Config_DeviceConfig_Role.values)
    ..aOB(2, _omitFieldNames ? '' : 'serialEnabled')
    ..aOB(3, _omitFieldNames ? '' : 'debugLogEnabled')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'buttonGpio', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'buzzerGpio', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Config_DeviceConfig clone() => Config_DeviceConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Config_DeviceConfig copyWith(void Function(Config_DeviceConfig) updates) => super.copyWith((message) => updates(message as Config_DeviceConfig)) as Config_DeviceConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Config_DeviceConfig create() => Config_DeviceConfig._();
  Config_DeviceConfig createEmptyInstance() => create();
  static $pb.PbList<Config_DeviceConfig> createRepeated() => $pb.PbList<Config_DeviceConfig>();
  @$core.pragma('dart2js:noInline')
  static Config_DeviceConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Config_DeviceConfig>(create);
  static Config_DeviceConfig? _defaultInstance;

  @$pb.TagNumber(1)
  Config_DeviceConfig_Role get role => $_getN(0);
  @$pb.TagNumber(1)
  set role(Config_DeviceConfig_Role v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasRole() => $_has(0);
  @$pb.TagNumber(1)
  void clearRole() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get serialEnabled => $_getBF(1);
  @$pb.TagNumber(2)
  set serialEnabled($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSerialEnabled() => $_has(1);
  @$pb.TagNumber(2)
  void clearSerialEnabled() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get debugLogEnabled => $_getBF(2);
  @$pb.TagNumber(3)
  set debugLogEnabled($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDebugLogEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearDebugLogEnabled() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get buttonGpio => $_getIZ(3);
  @$pb.TagNumber(4)
  set buttonGpio($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasButtonGpio() => $_has(3);
  @$pb.TagNumber(4)
  void clearButtonGpio() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get buzzerGpio => $_getIZ(4);
  @$pb.TagNumber(5)
  set buzzerGpio($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasBuzzerGpio() => $_has(4);
  @$pb.TagNumber(5)
  void clearBuzzerGpio() => clearField(5);
}

/// *
///  Position/GPS configuration.
///  Controls how often the radio reports its position.
class Config_PositionConfig extends $pb.GeneratedMessage {
  factory Config_PositionConfig({
    $core.int? positionBroadcastSecs,
    $core.bool? positionBroadcastSmartEnabled,
    $core.bool? fixedPosition,
    $core.bool? gpsEnabled,
    $core.int? gpsUpdateInterval,
    $core.int? gpsAttemptTime,
    $core.int? positionFlags,
    $core.int? rxGpio,
    $core.int? txGpio,
    $core.int? broadcastSmartMinimumDistance,
    $core.int? broadcastSmartMinimumIntervalSecs,
  }) {
    final $result = create();
    if (positionBroadcastSecs != null) {
      $result.positionBroadcastSecs = positionBroadcastSecs;
    }
    if (positionBroadcastSmartEnabled != null) {
      $result.positionBroadcastSmartEnabled = positionBroadcastSmartEnabled;
    }
    if (fixedPosition != null) {
      $result.fixedPosition = fixedPosition;
    }
    if (gpsEnabled != null) {
      $result.gpsEnabled = gpsEnabled;
    }
    if (gpsUpdateInterval != null) {
      $result.gpsUpdateInterval = gpsUpdateInterval;
    }
    if (gpsAttemptTime != null) {
      $result.gpsAttemptTime = gpsAttemptTime;
    }
    if (positionFlags != null) {
      $result.positionFlags = positionFlags;
    }
    if (rxGpio != null) {
      $result.rxGpio = rxGpio;
    }
    if (txGpio != null) {
      $result.txGpio = txGpio;
    }
    if (broadcastSmartMinimumDistance != null) {
      $result.broadcastSmartMinimumDistance = broadcastSmartMinimumDistance;
    }
    if (broadcastSmartMinimumIntervalSecs != null) {
      $result.broadcastSmartMinimumIntervalSecs = broadcastSmartMinimumIntervalSecs;
    }
    return $result;
  }
  Config_PositionConfig._() : super();
  factory Config_PositionConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Config_PositionConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Config.PositionConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'positionBroadcastSecs', $pb.PbFieldType.OU3)
    ..aOB(2, _omitFieldNames ? '' : 'positionBroadcastSmartEnabled')
    ..aOB(3, _omitFieldNames ? '' : 'fixedPosition')
    ..aOB(4, _omitFieldNames ? '' : 'gpsEnabled')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'gpsUpdateInterval', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'gpsAttemptTime', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'positionFlags', $pb.PbFieldType.OU3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'rxGpio', $pb.PbFieldType.OU3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'txGpio', $pb.PbFieldType.OU3)
    ..a<$core.int>(10, _omitFieldNames ? '' : 'broadcastSmartMinimumDistance', $pb.PbFieldType.OU3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'broadcastSmartMinimumIntervalSecs', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Config_PositionConfig clone() => Config_PositionConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Config_PositionConfig copyWith(void Function(Config_PositionConfig) updates) => super.copyWith((message) => updates(message as Config_PositionConfig)) as Config_PositionConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Config_PositionConfig create() => Config_PositionConfig._();
  Config_PositionConfig createEmptyInstance() => create();
  static $pb.PbList<Config_PositionConfig> createRepeated() => $pb.PbList<Config_PositionConfig>();
  @$core.pragma('dart2js:noInline')
  static Config_PositionConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Config_PositionConfig>(create);
  static Config_PositionConfig? _defaultInstance;

  /// How often to update position (seconds)
  @$pb.TagNumber(1)
  $core.int get positionBroadcastSecs => $_getIZ(0);
  @$pb.TagNumber(1)
  set positionBroadcastSecs($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPositionBroadcastSecs() => $_has(0);
  @$pb.TagNumber(1)
  void clearPositionBroadcastSecs() => clearField(1);

  /// Smart position broadcast enabled
  @$pb.TagNumber(2)
  $core.bool get positionBroadcastSmartEnabled => $_getBF(1);
  @$pb.TagNumber(2)
  set positionBroadcastSmartEnabled($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPositionBroadcastSmartEnabled() => $_has(1);
  @$pb.TagNumber(2)
  void clearPositionBroadcastSmartEnabled() => clearField(2);

  /// Fixed position mode
  @$pb.TagNumber(3)
  $core.bool get fixedPosition => $_getBF(2);
  @$pb.TagNumber(3)
  set fixedPosition($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFixedPosition() => $_has(2);
  @$pb.TagNumber(3)
  void clearFixedPosition() => clearField(3);

  /// GPS enabled
  @$pb.TagNumber(4)
  $core.bool get gpsEnabled => $_getBF(3);
  @$pb.TagNumber(4)
  set gpsEnabled($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasGpsEnabled() => $_has(3);
  @$pb.TagNumber(4)
  void clearGpsEnabled() => clearField(4);

  /// GPS update interval in seconds
  @$pb.TagNumber(5)
  $core.int get gpsUpdateInterval => $_getIZ(4);
  @$pb.TagNumber(5)
  set gpsUpdateInterval($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasGpsUpdateInterval() => $_has(4);
  @$pb.TagNumber(5)
  void clearGpsUpdateInterval() => clearField(5);

  /// GPS attempt time in seconds
  @$pb.TagNumber(6)
  $core.int get gpsAttemptTime => $_getIZ(5);
  @$pb.TagNumber(6)
  set gpsAttemptTime($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasGpsAttemptTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearGpsAttemptTime() => clearField(6);

  /// Position flags bitmask
  @$pb.TagNumber(7)
  $core.int get positionFlags => $_getIZ(6);
  @$pb.TagNumber(7)
  set positionFlags($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasPositionFlags() => $_has(6);
  @$pb.TagNumber(7)
  void clearPositionFlags() => clearField(7);

  /// Rx GPIO pin for GPS
  @$pb.TagNumber(8)
  $core.int get rxGpio => $_getIZ(7);
  @$pb.TagNumber(8)
  set rxGpio($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasRxGpio() => $_has(7);
  @$pb.TagNumber(8)
  void clearRxGpio() => clearField(8);

  /// Tx GPIO pin for GPS
  @$pb.TagNumber(9)
  $core.int get txGpio => $_getIZ(8);
  @$pb.TagNumber(9)
  set txGpio($core.int v) { $_setUnsignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasTxGpio() => $_has(8);
  @$pb.TagNumber(9)
  void clearTxGpio() => clearField(9);

  /// Broadcast smart minimum distance (meters)
  @$pb.TagNumber(10)
  $core.int get broadcastSmartMinimumDistance => $_getIZ(9);
  @$pb.TagNumber(10)
  set broadcastSmartMinimumDistance($core.int v) { $_setUnsignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasBroadcastSmartMinimumDistance() => $_has(9);
  @$pb.TagNumber(10)
  void clearBroadcastSmartMinimumDistance() => clearField(10);

  /// Broadcast smart minimum interval (seconds)
  @$pb.TagNumber(11)
  $core.int get broadcastSmartMinimumIntervalSecs => $_getIZ(10);
  @$pb.TagNumber(11)
  set broadcastSmartMinimumIntervalSecs($core.int v) { $_setUnsignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasBroadcastSmartMinimumIntervalSecs() => $_has(10);
  @$pb.TagNumber(11)
  void clearBroadcastSmartMinimumIntervalSecs() => clearField(11);
}

/// *
///  Power configuration.
class Config_PowerConfig extends $pb.GeneratedMessage {
  factory Config_PowerConfig({
    $core.bool? isPowerSaving,
    $core.int? onBatteryShutdownAfterSecs,
    $core.double? adcMultiplierOverride,
    $core.int? waitBluetoothSecs,
    $core.int? sdsSecs,
    $core.int? lsSecs,
    $core.int? minWakeSecs,
  }) {
    final $result = create();
    if (isPowerSaving != null) {
      $result.isPowerSaving = isPowerSaving;
    }
    if (onBatteryShutdownAfterSecs != null) {
      $result.onBatteryShutdownAfterSecs = onBatteryShutdownAfterSecs;
    }
    if (adcMultiplierOverride != null) {
      $result.adcMultiplierOverride = adcMultiplierOverride;
    }
    if (waitBluetoothSecs != null) {
      $result.waitBluetoothSecs = waitBluetoothSecs;
    }
    if (sdsSecs != null) {
      $result.sdsSecs = sdsSecs;
    }
    if (lsSecs != null) {
      $result.lsSecs = lsSecs;
    }
    if (minWakeSecs != null) {
      $result.minWakeSecs = minWakeSecs;
    }
    return $result;
  }
  Config_PowerConfig._() : super();
  factory Config_PowerConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Config_PowerConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Config.PowerConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isPowerSaving')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'onBatteryShutdownAfterSecs', $pb.PbFieldType.OU3)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'adcMultiplierOverride', $pb.PbFieldType.OF)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'waitBluetoothSecs', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'sdsSecs', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'lsSecs', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'minWakeSecs', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Config_PowerConfig clone() => Config_PowerConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Config_PowerConfig copyWith(void Function(Config_PowerConfig) updates) => super.copyWith((message) => updates(message as Config_PowerConfig)) as Config_PowerConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Config_PowerConfig create() => Config_PowerConfig._();
  Config_PowerConfig createEmptyInstance() => create();
  static $pb.PbList<Config_PowerConfig> createRepeated() => $pb.PbList<Config_PowerConfig>();
  @$core.pragma('dart2js:noInline')
  static Config_PowerConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Config_PowerConfig>(create);
  static Config_PowerConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isPowerSaving => $_getBF(0);
  @$pb.TagNumber(1)
  set isPowerSaving($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIsPowerSaving() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsPowerSaving() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get onBatteryShutdownAfterSecs => $_getIZ(1);
  @$pb.TagNumber(2)
  set onBatteryShutdownAfterSecs($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOnBatteryShutdownAfterSecs() => $_has(1);
  @$pb.TagNumber(2)
  void clearOnBatteryShutdownAfterSecs() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get adcMultiplierOverride => $_getN(2);
  @$pb.TagNumber(3)
  set adcMultiplierOverride($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAdcMultiplierOverride() => $_has(2);
  @$pb.TagNumber(3)
  void clearAdcMultiplierOverride() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get waitBluetoothSecs => $_getIZ(3);
  @$pb.TagNumber(4)
  set waitBluetoothSecs($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWaitBluetoothSecs() => $_has(3);
  @$pb.TagNumber(4)
  void clearWaitBluetoothSecs() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get sdsSecs => $_getIZ(4);
  @$pb.TagNumber(5)
  set sdsSecs($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSdsSecs() => $_has(4);
  @$pb.TagNumber(5)
  void clearSdsSecs() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get lsSecs => $_getIZ(5);
  @$pb.TagNumber(6)
  set lsSecs($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasLsSecs() => $_has(5);
  @$pb.TagNumber(6)
  void clearLsSecs() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get minWakeSecs => $_getIZ(6);
  @$pb.TagNumber(7)
  set minWakeSecs($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMinWakeSecs() => $_has(6);
  @$pb.TagNumber(7)
  void clearMinWakeSecs() => clearField(7);
}

/// *
///  Network configuration.
class Config_NetworkConfig extends $pb.GeneratedMessage {
  factory Config_NetworkConfig({
    $core.bool? wifiEnabled,
    $core.String? wifiSsid,
    $core.String? wifiPsk,
    $core.String? ntpServer,
  }) {
    final $result = create();
    if (wifiEnabled != null) {
      $result.wifiEnabled = wifiEnabled;
    }
    if (wifiSsid != null) {
      $result.wifiSsid = wifiSsid;
    }
    if (wifiPsk != null) {
      $result.wifiPsk = wifiPsk;
    }
    if (ntpServer != null) {
      $result.ntpServer = ntpServer;
    }
    return $result;
  }
  Config_NetworkConfig._() : super();
  factory Config_NetworkConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Config_NetworkConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Config.NetworkConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'wifiEnabled')
    ..aOS(2, _omitFieldNames ? '' : 'wifiSsid')
    ..aOS(3, _omitFieldNames ? '' : 'wifiPsk')
    ..aOS(4, _omitFieldNames ? '' : 'ntpServer')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Config_NetworkConfig clone() => Config_NetworkConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Config_NetworkConfig copyWith(void Function(Config_NetworkConfig) updates) => super.copyWith((message) => updates(message as Config_NetworkConfig)) as Config_NetworkConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Config_NetworkConfig create() => Config_NetworkConfig._();
  Config_NetworkConfig createEmptyInstance() => create();
  static $pb.PbList<Config_NetworkConfig> createRepeated() => $pb.PbList<Config_NetworkConfig>();
  @$core.pragma('dart2js:noInline')
  static Config_NetworkConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Config_NetworkConfig>(create);
  static Config_NetworkConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get wifiEnabled => $_getBF(0);
  @$pb.TagNumber(1)
  set wifiEnabled($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWifiEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearWifiEnabled() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wifiSsid => $_getSZ(1);
  @$pb.TagNumber(2)
  set wifiSsid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWifiSsid() => $_has(1);
  @$pb.TagNumber(2)
  void clearWifiSsid() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get wifiPsk => $_getSZ(2);
  @$pb.TagNumber(3)
  set wifiPsk($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWifiPsk() => $_has(2);
  @$pb.TagNumber(3)
  void clearWifiPsk() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get ntpServer => $_getSZ(3);
  @$pb.TagNumber(4)
  set ntpServer($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNtpServer() => $_has(3);
  @$pb.TagNumber(4)
  void clearNtpServer() => clearField(4);
}

/// *
///  Display configuration.
class Config_DisplayConfig extends $pb.GeneratedMessage {
  factory Config_DisplayConfig({
    $core.int? screenOnSecs,
    Config_DisplayConfig_GpsCoordinateFormat? gpsFormat,
    $core.bool? compassNorthTop,
    $core.bool? flipScreen,
    Config_DisplayConfig_DisplayUnits? units,
  }) {
    final $result = create();
    if (screenOnSecs != null) {
      $result.screenOnSecs = screenOnSecs;
    }
    if (gpsFormat != null) {
      $result.gpsFormat = gpsFormat;
    }
    if (compassNorthTop != null) {
      $result.compassNorthTop = compassNorthTop;
    }
    if (flipScreen != null) {
      $result.flipScreen = flipScreen;
    }
    if (units != null) {
      $result.units = units;
    }
    return $result;
  }
  Config_DisplayConfig._() : super();
  factory Config_DisplayConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Config_DisplayConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Config.DisplayConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'screenOnSecs', $pb.PbFieldType.OU3)
    ..e<Config_DisplayConfig_GpsCoordinateFormat>(2, _omitFieldNames ? '' : 'gpsFormat', $pb.PbFieldType.OE, defaultOrMaker: Config_DisplayConfig_GpsCoordinateFormat.DEC, valueOf: Config_DisplayConfig_GpsCoordinateFormat.valueOf, enumValues: Config_DisplayConfig_GpsCoordinateFormat.values)
    ..aOB(3, _omitFieldNames ? '' : 'compassNorthTop')
    ..aOB(4, _omitFieldNames ? '' : 'flipScreen')
    ..e<Config_DisplayConfig_DisplayUnits>(5, _omitFieldNames ? '' : 'units', $pb.PbFieldType.OE, defaultOrMaker: Config_DisplayConfig_DisplayUnits.METRIC, valueOf: Config_DisplayConfig_DisplayUnits.valueOf, enumValues: Config_DisplayConfig_DisplayUnits.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Config_DisplayConfig clone() => Config_DisplayConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Config_DisplayConfig copyWith(void Function(Config_DisplayConfig) updates) => super.copyWith((message) => updates(message as Config_DisplayConfig)) as Config_DisplayConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Config_DisplayConfig create() => Config_DisplayConfig._();
  Config_DisplayConfig createEmptyInstance() => create();
  static $pb.PbList<Config_DisplayConfig> createRepeated() => $pb.PbList<Config_DisplayConfig>();
  @$core.pragma('dart2js:noInline')
  static Config_DisplayConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Config_DisplayConfig>(create);
  static Config_DisplayConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get screenOnSecs => $_getIZ(0);
  @$pb.TagNumber(1)
  set screenOnSecs($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasScreenOnSecs() => $_has(0);
  @$pb.TagNumber(1)
  void clearScreenOnSecs() => clearField(1);

  @$pb.TagNumber(2)
  Config_DisplayConfig_GpsCoordinateFormat get gpsFormat => $_getN(1);
  @$pb.TagNumber(2)
  set gpsFormat(Config_DisplayConfig_GpsCoordinateFormat v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasGpsFormat() => $_has(1);
  @$pb.TagNumber(2)
  void clearGpsFormat() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get compassNorthTop => $_getBF(2);
  @$pb.TagNumber(3)
  set compassNorthTop($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCompassNorthTop() => $_has(2);
  @$pb.TagNumber(3)
  void clearCompassNorthTop() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get flipScreen => $_getBF(3);
  @$pb.TagNumber(4)
  set flipScreen($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFlipScreen() => $_has(3);
  @$pb.TagNumber(4)
  void clearFlipScreen() => clearField(4);

  @$pb.TagNumber(5)
  Config_DisplayConfig_DisplayUnits get units => $_getN(4);
  @$pb.TagNumber(5)
  set units(Config_DisplayConfig_DisplayUnits v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasUnits() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnits() => clearField(5);
}

/// *
///  LoRa radio configuration.
class Config_LoRaConfig extends $pb.GeneratedMessage {
  factory Config_LoRaConfig({
    $core.int? region,
    $core.bool? usePreset,
    Config_LoRaConfig_ModemPreset? modemPreset,
    $core.int? bandwidth,
    $core.int? spreadFactor,
    $core.int? codingRate,
    $core.double? frequencyOffset,
    $core.int? hopLimit,
    $core.bool? txEnabled,
    $core.int? txPower,
    $core.int? channelNum,
  }) {
    final $result = create();
    if (region != null) {
      $result.region = region;
    }
    if (usePreset != null) {
      $result.usePreset = usePreset;
    }
    if (modemPreset != null) {
      $result.modemPreset = modemPreset;
    }
    if (bandwidth != null) {
      $result.bandwidth = bandwidth;
    }
    if (spreadFactor != null) {
      $result.spreadFactor = spreadFactor;
    }
    if (codingRate != null) {
      $result.codingRate = codingRate;
    }
    if (frequencyOffset != null) {
      $result.frequencyOffset = frequencyOffset;
    }
    if (hopLimit != null) {
      $result.hopLimit = hopLimit;
    }
    if (txEnabled != null) {
      $result.txEnabled = txEnabled;
    }
    if (txPower != null) {
      $result.txPower = txPower;
    }
    if (channelNum != null) {
      $result.channelNum = channelNum;
    }
    return $result;
  }
  Config_LoRaConfig._() : super();
  factory Config_LoRaConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Config_LoRaConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Config.LoRaConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'region', $pb.PbFieldType.OU3)
    ..aOB(2, _omitFieldNames ? '' : 'usePreset')
    ..e<Config_LoRaConfig_ModemPreset>(3, _omitFieldNames ? '' : 'modemPreset', $pb.PbFieldType.OE, defaultOrMaker: Config_LoRaConfig_ModemPreset.LONG_FAST, valueOf: Config_LoRaConfig_ModemPreset.valueOf, enumValues: Config_LoRaConfig_ModemPreset.values)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'bandwidth', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'spreadFactor', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'codingRate', $pb.PbFieldType.OU3)
    ..a<$core.double>(7, _omitFieldNames ? '' : 'frequencyOffset', $pb.PbFieldType.OF)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'hopLimit', $pb.PbFieldType.OU3)
    ..aOB(9, _omitFieldNames ? '' : 'txEnabled')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'txPower', $pb.PbFieldType.O3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'channelNum', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Config_LoRaConfig clone() => Config_LoRaConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Config_LoRaConfig copyWith(void Function(Config_LoRaConfig) updates) => super.copyWith((message) => updates(message as Config_LoRaConfig)) as Config_LoRaConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Config_LoRaConfig create() => Config_LoRaConfig._();
  Config_LoRaConfig createEmptyInstance() => create();
  static $pb.PbList<Config_LoRaConfig> createRepeated() => $pb.PbList<Config_LoRaConfig>();
  @$core.pragma('dart2js:noInline')
  static Config_LoRaConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Config_LoRaConfig>(create);
  static Config_LoRaConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get region => $_getIZ(0);
  @$pb.TagNumber(1)
  set region($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRegion() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegion() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get usePreset => $_getBF(1);
  @$pb.TagNumber(2)
  set usePreset($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUsePreset() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsePreset() => clearField(2);

  @$pb.TagNumber(3)
  Config_LoRaConfig_ModemPreset get modemPreset => $_getN(2);
  @$pb.TagNumber(3)
  set modemPreset(Config_LoRaConfig_ModemPreset v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasModemPreset() => $_has(2);
  @$pb.TagNumber(3)
  void clearModemPreset() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get bandwidth => $_getIZ(3);
  @$pb.TagNumber(4)
  set bandwidth($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBandwidth() => $_has(3);
  @$pb.TagNumber(4)
  void clearBandwidth() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get spreadFactor => $_getIZ(4);
  @$pb.TagNumber(5)
  set spreadFactor($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSpreadFactor() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpreadFactor() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get codingRate => $_getIZ(5);
  @$pb.TagNumber(6)
  set codingRate($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCodingRate() => $_has(5);
  @$pb.TagNumber(6)
  void clearCodingRate() => clearField(6);

  @$pb.TagNumber(7)
  $core.double get frequencyOffset => $_getN(6);
  @$pb.TagNumber(7)
  set frequencyOffset($core.double v) { $_setFloat(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasFrequencyOffset() => $_has(6);
  @$pb.TagNumber(7)
  void clearFrequencyOffset() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get hopLimit => $_getIZ(7);
  @$pb.TagNumber(8)
  set hopLimit($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasHopLimit() => $_has(7);
  @$pb.TagNumber(8)
  void clearHopLimit() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get txEnabled => $_getBF(8);
  @$pb.TagNumber(9)
  set txEnabled($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasTxEnabled() => $_has(8);
  @$pb.TagNumber(9)
  void clearTxEnabled() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get txPower => $_getIZ(9);
  @$pb.TagNumber(10)
  set txPower($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasTxPower() => $_has(9);
  @$pb.TagNumber(10)
  void clearTxPower() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get channelNum => $_getIZ(10);
  @$pb.TagNumber(11)
  set channelNum($core.int v) { $_setUnsignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasChannelNum() => $_has(10);
  @$pb.TagNumber(11)
  void clearChannelNum() => clearField(11);
}

/// *
///  Bluetooth configuration.
class Config_BluetoothConfig extends $pb.GeneratedMessage {
  factory Config_BluetoothConfig({
    $core.bool? enabled,
    Config_BluetoothConfig_PairingMode? mode,
    $core.int? fixedPin,
  }) {
    final $result = create();
    if (enabled != null) {
      $result.enabled = enabled;
    }
    if (mode != null) {
      $result.mode = mode;
    }
    if (fixedPin != null) {
      $result.fixedPin = fixedPin;
    }
    return $result;
  }
  Config_BluetoothConfig._() : super();
  factory Config_BluetoothConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Config_BluetoothConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Config.BluetoothConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..e<Config_BluetoothConfig_PairingMode>(2, _omitFieldNames ? '' : 'mode', $pb.PbFieldType.OE, defaultOrMaker: Config_BluetoothConfig_PairingMode.RANDOM_PIN, valueOf: Config_BluetoothConfig_PairingMode.valueOf, enumValues: Config_BluetoothConfig_PairingMode.values)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'fixedPin', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Config_BluetoothConfig clone() => Config_BluetoothConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Config_BluetoothConfig copyWith(void Function(Config_BluetoothConfig) updates) => super.copyWith((message) => updates(message as Config_BluetoothConfig)) as Config_BluetoothConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Config_BluetoothConfig create() => Config_BluetoothConfig._();
  Config_BluetoothConfig createEmptyInstance() => create();
  static $pb.PbList<Config_BluetoothConfig> createRepeated() => $pb.PbList<Config_BluetoothConfig>();
  @$core.pragma('dart2js:noInline')
  static Config_BluetoothConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Config_BluetoothConfig>(create);
  static Config_BluetoothConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => clearField(1);

  @$pb.TagNumber(2)
  Config_BluetoothConfig_PairingMode get mode => $_getN(1);
  @$pb.TagNumber(2)
  set mode(Config_BluetoothConfig_PairingMode v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearMode() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get fixedPin => $_getIZ(2);
  @$pb.TagNumber(3)
  set fixedPin($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFixedPin() => $_has(2);
  @$pb.TagNumber(3)
  void clearFixedPin() => clearField(3);
}

enum Config_PayloadVariant {
  device, 
  position, 
  power, 
  network, 
  display, 
  lora, 
  bluetooth, 
  notSet
}

/// *
///  Radio configuration message.
///  Contains sub-configurations for different aspects of the radio.
class Config extends $pb.GeneratedMessage {
  factory Config({
    Config_DeviceConfig? device,
    Config_PositionConfig? position,
    Config_PowerConfig? power,
    Config_NetworkConfig? network,
    Config_DisplayConfig? display,
    Config_LoRaConfig? lora,
    Config_BluetoothConfig? bluetooth,
  }) {
    final $result = create();
    if (device != null) {
      $result.device = device;
    }
    if (position != null) {
      $result.position = position;
    }
    if (power != null) {
      $result.power = power;
    }
    if (network != null) {
      $result.network = network;
    }
    if (display != null) {
      $result.display = display;
    }
    if (lora != null) {
      $result.lora = lora;
    }
    if (bluetooth != null) {
      $result.bluetooth = bluetooth;
    }
    return $result;
  }
  Config._() : super();
  factory Config.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Config.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, Config_PayloadVariant> _Config_PayloadVariantByTag = {
    1 : Config_PayloadVariant.device,
    2 : Config_PayloadVariant.position,
    3 : Config_PayloadVariant.power,
    4 : Config_PayloadVariant.network,
    5 : Config_PayloadVariant.display,
    6 : Config_PayloadVariant.lora,
    7 : Config_PayloadVariant.bluetooth,
    0 : Config_PayloadVariant.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Config', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7])
    ..aOM<Config_DeviceConfig>(1, _omitFieldNames ? '' : 'device', subBuilder: Config_DeviceConfig.create)
    ..aOM<Config_PositionConfig>(2, _omitFieldNames ? '' : 'position', subBuilder: Config_PositionConfig.create)
    ..aOM<Config_PowerConfig>(3, _omitFieldNames ? '' : 'power', subBuilder: Config_PowerConfig.create)
    ..aOM<Config_NetworkConfig>(4, _omitFieldNames ? '' : 'network', subBuilder: Config_NetworkConfig.create)
    ..aOM<Config_DisplayConfig>(5, _omitFieldNames ? '' : 'display', subBuilder: Config_DisplayConfig.create)
    ..aOM<Config_LoRaConfig>(6, _omitFieldNames ? '' : 'lora', subBuilder: Config_LoRaConfig.create)
    ..aOM<Config_BluetoothConfig>(7, _omitFieldNames ? '' : 'bluetooth', subBuilder: Config_BluetoothConfig.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Config clone() => Config()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Config copyWith(void Function(Config) updates) => super.copyWith((message) => updates(message as Config)) as Config;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Config create() => Config._();
  Config createEmptyInstance() => create();
  static $pb.PbList<Config> createRepeated() => $pb.PbList<Config>();
  @$core.pragma('dart2js:noInline')
  static Config getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Config>(create);
  static Config? _defaultInstance;

  Config_PayloadVariant whichPayloadVariant() => _Config_PayloadVariantByTag[$_whichOneof(0)]!;
  void clearPayloadVariant() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Config_DeviceConfig get device => $_getN(0);
  @$pb.TagNumber(1)
  set device(Config_DeviceConfig v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => clearField(1);
  @$pb.TagNumber(1)
  Config_DeviceConfig ensureDevice() => $_ensure(0);

  @$pb.TagNumber(2)
  Config_PositionConfig get position => $_getN(1);
  @$pb.TagNumber(2)
  set position(Config_PositionConfig v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPosition() => $_has(1);
  @$pb.TagNumber(2)
  void clearPosition() => clearField(2);
  @$pb.TagNumber(2)
  Config_PositionConfig ensurePosition() => $_ensure(1);

  @$pb.TagNumber(3)
  Config_PowerConfig get power => $_getN(2);
  @$pb.TagNumber(3)
  set power(Config_PowerConfig v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPower() => $_has(2);
  @$pb.TagNumber(3)
  void clearPower() => clearField(3);
  @$pb.TagNumber(3)
  Config_PowerConfig ensurePower() => $_ensure(2);

  @$pb.TagNumber(4)
  Config_NetworkConfig get network => $_getN(3);
  @$pb.TagNumber(4)
  set network(Config_NetworkConfig v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasNetwork() => $_has(3);
  @$pb.TagNumber(4)
  void clearNetwork() => clearField(4);
  @$pb.TagNumber(4)
  Config_NetworkConfig ensureNetwork() => $_ensure(3);

  @$pb.TagNumber(5)
  Config_DisplayConfig get display => $_getN(4);
  @$pb.TagNumber(5)
  set display(Config_DisplayConfig v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasDisplay() => $_has(4);
  @$pb.TagNumber(5)
  void clearDisplay() => clearField(5);
  @$pb.TagNumber(5)
  Config_DisplayConfig ensureDisplay() => $_ensure(4);

  @$pb.TagNumber(6)
  Config_LoRaConfig get lora => $_getN(5);
  @$pb.TagNumber(6)
  set lora(Config_LoRaConfig v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasLora() => $_has(5);
  @$pb.TagNumber(6)
  void clearLora() => clearField(6);
  @$pb.TagNumber(6)
  Config_LoRaConfig ensureLora() => $_ensure(5);

  @$pb.TagNumber(7)
  Config_BluetoothConfig get bluetooth => $_getN(6);
  @$pb.TagNumber(7)
  set bluetooth(Config_BluetoothConfig v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasBluetooth() => $_has(6);
  @$pb.TagNumber(7)
  void clearBluetooth() => clearField(7);
  @$pb.TagNumber(7)
  Config_BluetoothConfig ensureBluetooth() => $_ensure(6);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
