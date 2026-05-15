//
//  Generated code. Do not modify.
//  source: module_config.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'module_config.pbenum.dart';

export 'module_config.pbenum.dart';

/// *
///  MQTT module configuration.
class ModuleConfig_MQTTConfig extends $pb.GeneratedMessage {
  factory ModuleConfig_MQTTConfig({
    $core.bool? enabled,
    $core.String? address,
    $core.String? username,
    $core.String? password,
    $core.bool? encryptionEnabled,
    $core.bool? jsonEnabled,
    $core.bool? tlsEnabled,
    $core.String? rootTopic,
  }) {
    final $result = create();
    if (enabled != null) {
      $result.enabled = enabled;
    }
    if (address != null) {
      $result.address = address;
    }
    if (username != null) {
      $result.username = username;
    }
    if (password != null) {
      $result.password = password;
    }
    if (encryptionEnabled != null) {
      $result.encryptionEnabled = encryptionEnabled;
    }
    if (jsonEnabled != null) {
      $result.jsonEnabled = jsonEnabled;
    }
    if (tlsEnabled != null) {
      $result.tlsEnabled = tlsEnabled;
    }
    if (rootTopic != null) {
      $result.rootTopic = rootTopic;
    }
    return $result;
  }
  ModuleConfig_MQTTConfig._() : super();
  factory ModuleConfig_MQTTConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ModuleConfig_MQTTConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ModuleConfig.MQTTConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aOS(3, _omitFieldNames ? '' : 'username')
    ..aOS(4, _omitFieldNames ? '' : 'password')
    ..aOB(5, _omitFieldNames ? '' : 'encryptionEnabled')
    ..aOB(6, _omitFieldNames ? '' : 'jsonEnabled')
    ..aOB(7, _omitFieldNames ? '' : 'tlsEnabled')
    ..aOS(8, _omitFieldNames ? '' : 'rootTopic')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ModuleConfig_MQTTConfig clone() => ModuleConfig_MQTTConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ModuleConfig_MQTTConfig copyWith(void Function(ModuleConfig_MQTTConfig) updates) => super.copyWith((message) => updates(message as ModuleConfig_MQTTConfig)) as ModuleConfig_MQTTConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModuleConfig_MQTTConfig create() => ModuleConfig_MQTTConfig._();
  ModuleConfig_MQTTConfig createEmptyInstance() => create();
  static $pb.PbList<ModuleConfig_MQTTConfig> createRepeated() => $pb.PbList<ModuleConfig_MQTTConfig>();
  @$core.pragma('dart2js:noInline')
  static ModuleConfig_MQTTConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ModuleConfig_MQTTConfig>(create);
  static ModuleConfig_MQTTConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get username => $_getSZ(2);
  @$pb.TagNumber(3)
  set username($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUsername() => $_has(2);
  @$pb.TagNumber(3)
  void clearUsername() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get password => $_getSZ(3);
  @$pb.TagNumber(4)
  set password($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPassword() => $_has(3);
  @$pb.TagNumber(4)
  void clearPassword() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get encryptionEnabled => $_getBF(4);
  @$pb.TagNumber(5)
  set encryptionEnabled($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasEncryptionEnabled() => $_has(4);
  @$pb.TagNumber(5)
  void clearEncryptionEnabled() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get jsonEnabled => $_getBF(5);
  @$pb.TagNumber(6)
  set jsonEnabled($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasJsonEnabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearJsonEnabled() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get tlsEnabled => $_getBF(6);
  @$pb.TagNumber(7)
  set tlsEnabled($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTlsEnabled() => $_has(6);
  @$pb.TagNumber(7)
  void clearTlsEnabled() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get rootTopic => $_getSZ(7);
  @$pb.TagNumber(8)
  set rootTopic($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasRootTopic() => $_has(7);
  @$pb.TagNumber(8)
  void clearRootTopic() => clearField(8);
}

/// *
///  Serial module configuration.
class ModuleConfig_SerialConfig extends $pb.GeneratedMessage {
  factory ModuleConfig_SerialConfig({
    $core.bool? enabled,
    $core.bool? echo,
    $core.int? rxd,
    $core.int? txd,
    ModuleConfig_SerialConfig_Serial_Baud? baud,
    $core.int? timeout,
    ModuleConfig_SerialConfig_Serial_Mode? mode,
  }) {
    final $result = create();
    if (enabled != null) {
      $result.enabled = enabled;
    }
    if (echo != null) {
      $result.echo = echo;
    }
    if (rxd != null) {
      $result.rxd = rxd;
    }
    if (txd != null) {
      $result.txd = txd;
    }
    if (baud != null) {
      $result.baud = baud;
    }
    if (timeout != null) {
      $result.timeout = timeout;
    }
    if (mode != null) {
      $result.mode = mode;
    }
    return $result;
  }
  ModuleConfig_SerialConfig._() : super();
  factory ModuleConfig_SerialConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ModuleConfig_SerialConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ModuleConfig.SerialConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..aOB(2, _omitFieldNames ? '' : 'echo')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'rxd', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'txd', $pb.PbFieldType.OU3)
    ..e<ModuleConfig_SerialConfig_Serial_Baud>(5, _omitFieldNames ? '' : 'baud', $pb.PbFieldType.OE, defaultOrMaker: ModuleConfig_SerialConfig_Serial_Baud.BAUD_DEFAULT, valueOf: ModuleConfig_SerialConfig_Serial_Baud.valueOf, enumValues: ModuleConfig_SerialConfig_Serial_Baud.values)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'timeout', $pb.PbFieldType.OU3)
    ..e<ModuleConfig_SerialConfig_Serial_Mode>(7, _omitFieldNames ? '' : 'mode', $pb.PbFieldType.OE, defaultOrMaker: ModuleConfig_SerialConfig_Serial_Mode.DEFAULT, valueOf: ModuleConfig_SerialConfig_Serial_Mode.valueOf, enumValues: ModuleConfig_SerialConfig_Serial_Mode.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ModuleConfig_SerialConfig clone() => ModuleConfig_SerialConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ModuleConfig_SerialConfig copyWith(void Function(ModuleConfig_SerialConfig) updates) => super.copyWith((message) => updates(message as ModuleConfig_SerialConfig)) as ModuleConfig_SerialConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModuleConfig_SerialConfig create() => ModuleConfig_SerialConfig._();
  ModuleConfig_SerialConfig createEmptyInstance() => create();
  static $pb.PbList<ModuleConfig_SerialConfig> createRepeated() => $pb.PbList<ModuleConfig_SerialConfig>();
  @$core.pragma('dart2js:noInline')
  static ModuleConfig_SerialConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ModuleConfig_SerialConfig>(create);
  static ModuleConfig_SerialConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get echo => $_getBF(1);
  @$pb.TagNumber(2)
  set echo($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEcho() => $_has(1);
  @$pb.TagNumber(2)
  void clearEcho() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get rxd => $_getIZ(2);
  @$pb.TagNumber(3)
  set rxd($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRxd() => $_has(2);
  @$pb.TagNumber(3)
  void clearRxd() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get txd => $_getIZ(3);
  @$pb.TagNumber(4)
  set txd($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTxd() => $_has(3);
  @$pb.TagNumber(4)
  void clearTxd() => clearField(4);

  @$pb.TagNumber(5)
  ModuleConfig_SerialConfig_Serial_Baud get baud => $_getN(4);
  @$pb.TagNumber(5)
  set baud(ModuleConfig_SerialConfig_Serial_Baud v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasBaud() => $_has(4);
  @$pb.TagNumber(5)
  void clearBaud() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get timeout => $_getIZ(5);
  @$pb.TagNumber(6)
  set timeout($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTimeout() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimeout() => clearField(6);

  @$pb.TagNumber(7)
  ModuleConfig_SerialConfig_Serial_Mode get mode => $_getN(6);
  @$pb.TagNumber(7)
  set mode(ModuleConfig_SerialConfig_Serial_Mode v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasMode() => $_has(6);
  @$pb.TagNumber(7)
  void clearMode() => clearField(7);
}

/// *
///  External notification module configuration.
class ModuleConfig_ExternalNotificationConfig extends $pb.GeneratedMessage {
  factory ModuleConfig_ExternalNotificationConfig({
    $core.bool? enabled,
    $core.int? outputMs,
    $core.int? output,
    $core.bool? active,
    $core.bool? alertMessage,
    $core.bool? alertBell,
    $core.bool? usePwm,
    $core.int? nagTimeout,
  }) {
    final $result = create();
    if (enabled != null) {
      $result.enabled = enabled;
    }
    if (outputMs != null) {
      $result.outputMs = outputMs;
    }
    if (output != null) {
      $result.output = output;
    }
    if (active != null) {
      $result.active = active;
    }
    if (alertMessage != null) {
      $result.alertMessage = alertMessage;
    }
    if (alertBell != null) {
      $result.alertBell = alertBell;
    }
    if (usePwm != null) {
      $result.usePwm = usePwm;
    }
    if (nagTimeout != null) {
      $result.nagTimeout = nagTimeout;
    }
    return $result;
  }
  ModuleConfig_ExternalNotificationConfig._() : super();
  factory ModuleConfig_ExternalNotificationConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ModuleConfig_ExternalNotificationConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ModuleConfig.ExternalNotificationConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'outputMs', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'output', $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'active')
    ..aOB(5, _omitFieldNames ? '' : 'alertMessage')
    ..aOB(6, _omitFieldNames ? '' : 'alertBell')
    ..aOB(7, _omitFieldNames ? '' : 'usePwm')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'nagTimeout', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ModuleConfig_ExternalNotificationConfig clone() => ModuleConfig_ExternalNotificationConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ModuleConfig_ExternalNotificationConfig copyWith(void Function(ModuleConfig_ExternalNotificationConfig) updates) => super.copyWith((message) => updates(message as ModuleConfig_ExternalNotificationConfig)) as ModuleConfig_ExternalNotificationConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModuleConfig_ExternalNotificationConfig create() => ModuleConfig_ExternalNotificationConfig._();
  ModuleConfig_ExternalNotificationConfig createEmptyInstance() => create();
  static $pb.PbList<ModuleConfig_ExternalNotificationConfig> createRepeated() => $pb.PbList<ModuleConfig_ExternalNotificationConfig>();
  @$core.pragma('dart2js:noInline')
  static ModuleConfig_ExternalNotificationConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ModuleConfig_ExternalNotificationConfig>(create);
  static ModuleConfig_ExternalNotificationConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get outputMs => $_getIZ(1);
  @$pb.TagNumber(2)
  set outputMs($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOutputMs() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutputMs() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get output => $_getIZ(2);
  @$pb.TagNumber(3)
  set output($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOutput() => $_has(2);
  @$pb.TagNumber(3)
  void clearOutput() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get active => $_getBF(3);
  @$pb.TagNumber(4)
  set active($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasActive() => $_has(3);
  @$pb.TagNumber(4)
  void clearActive() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get alertMessage => $_getBF(4);
  @$pb.TagNumber(5)
  set alertMessage($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAlertMessage() => $_has(4);
  @$pb.TagNumber(5)
  void clearAlertMessage() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get alertBell => $_getBF(5);
  @$pb.TagNumber(6)
  set alertBell($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAlertBell() => $_has(5);
  @$pb.TagNumber(6)
  void clearAlertBell() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get usePwm => $_getBF(6);
  @$pb.TagNumber(7)
  set usePwm($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasUsePwm() => $_has(6);
  @$pb.TagNumber(7)
  void clearUsePwm() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get nagTimeout => $_getIZ(7);
  @$pb.TagNumber(8)
  set nagTimeout($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasNagTimeout() => $_has(7);
  @$pb.TagNumber(8)
  void clearNagTimeout() => clearField(8);
}

/// *
///  Store and forward module configuration.
class ModuleConfig_StoreForwardConfig extends $pb.GeneratedMessage {
  factory ModuleConfig_StoreForwardConfig({
    $core.bool? enabled,
    $core.bool? heartbeat,
    $core.int? records,
    $core.int? historyReturnMax,
    $core.int? historyReturnWindow,
  }) {
    final $result = create();
    if (enabled != null) {
      $result.enabled = enabled;
    }
    if (heartbeat != null) {
      $result.heartbeat = heartbeat;
    }
    if (records != null) {
      $result.records = records;
    }
    if (historyReturnMax != null) {
      $result.historyReturnMax = historyReturnMax;
    }
    if (historyReturnWindow != null) {
      $result.historyReturnWindow = historyReturnWindow;
    }
    return $result;
  }
  ModuleConfig_StoreForwardConfig._() : super();
  factory ModuleConfig_StoreForwardConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ModuleConfig_StoreForwardConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ModuleConfig.StoreForwardConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..aOB(2, _omitFieldNames ? '' : 'heartbeat')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'records', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'historyReturnMax', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'historyReturnWindow', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ModuleConfig_StoreForwardConfig clone() => ModuleConfig_StoreForwardConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ModuleConfig_StoreForwardConfig copyWith(void Function(ModuleConfig_StoreForwardConfig) updates) => super.copyWith((message) => updates(message as ModuleConfig_StoreForwardConfig)) as ModuleConfig_StoreForwardConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModuleConfig_StoreForwardConfig create() => ModuleConfig_StoreForwardConfig._();
  ModuleConfig_StoreForwardConfig createEmptyInstance() => create();
  static $pb.PbList<ModuleConfig_StoreForwardConfig> createRepeated() => $pb.PbList<ModuleConfig_StoreForwardConfig>();
  @$core.pragma('dart2js:noInline')
  static ModuleConfig_StoreForwardConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ModuleConfig_StoreForwardConfig>(create);
  static ModuleConfig_StoreForwardConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get heartbeat => $_getBF(1);
  @$pb.TagNumber(2)
  set heartbeat($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeartbeat() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeartbeat() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get records => $_getIZ(2);
  @$pb.TagNumber(3)
  set records($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRecords() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecords() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get historyReturnMax => $_getIZ(3);
  @$pb.TagNumber(4)
  set historyReturnMax($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHistoryReturnMax() => $_has(3);
  @$pb.TagNumber(4)
  void clearHistoryReturnMax() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get historyReturnWindow => $_getIZ(4);
  @$pb.TagNumber(5)
  set historyReturnWindow($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHistoryReturnWindow() => $_has(4);
  @$pb.TagNumber(5)
  void clearHistoryReturnWindow() => clearField(5);
}

/// *
///  Range test module configuration.
class ModuleConfig_RangeTestConfig extends $pb.GeneratedMessage {
  factory ModuleConfig_RangeTestConfig({
    $core.bool? enabled,
    $core.int? sender,
    $core.bool? save,
  }) {
    final $result = create();
    if (enabled != null) {
      $result.enabled = enabled;
    }
    if (sender != null) {
      $result.sender = sender;
    }
    if (save != null) {
      $result.save = save;
    }
    return $result;
  }
  ModuleConfig_RangeTestConfig._() : super();
  factory ModuleConfig_RangeTestConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ModuleConfig_RangeTestConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ModuleConfig.RangeTestConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'sender', $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'save')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ModuleConfig_RangeTestConfig clone() => ModuleConfig_RangeTestConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ModuleConfig_RangeTestConfig copyWith(void Function(ModuleConfig_RangeTestConfig) updates) => super.copyWith((message) => updates(message as ModuleConfig_RangeTestConfig)) as ModuleConfig_RangeTestConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModuleConfig_RangeTestConfig create() => ModuleConfig_RangeTestConfig._();
  ModuleConfig_RangeTestConfig createEmptyInstance() => create();
  static $pb.PbList<ModuleConfig_RangeTestConfig> createRepeated() => $pb.PbList<ModuleConfig_RangeTestConfig>();
  @$core.pragma('dart2js:noInline')
  static ModuleConfig_RangeTestConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ModuleConfig_RangeTestConfig>(create);
  static ModuleConfig_RangeTestConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get sender => $_getIZ(1);
  @$pb.TagNumber(2)
  set sender($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSender() => $_has(1);
  @$pb.TagNumber(2)
  void clearSender() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get save => $_getBF(2);
  @$pb.TagNumber(3)
  set save($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSave() => $_has(2);
  @$pb.TagNumber(3)
  void clearSave() => clearField(3);
}

/// *
///  Telemetry module configuration.
class ModuleConfig_TelemetryConfig extends $pb.GeneratedMessage {
  factory ModuleConfig_TelemetryConfig({
    $core.int? deviceUpdateInterval,
    $core.int? environmentUpdateInterval,
    $core.bool? environmentMeasurementEnabled,
    $core.bool? environmentScreenEnabled,
    $core.bool? environmentDisplayFahrenheit,
  }) {
    final $result = create();
    if (deviceUpdateInterval != null) {
      $result.deviceUpdateInterval = deviceUpdateInterval;
    }
    if (environmentUpdateInterval != null) {
      $result.environmentUpdateInterval = environmentUpdateInterval;
    }
    if (environmentMeasurementEnabled != null) {
      $result.environmentMeasurementEnabled = environmentMeasurementEnabled;
    }
    if (environmentScreenEnabled != null) {
      $result.environmentScreenEnabled = environmentScreenEnabled;
    }
    if (environmentDisplayFahrenheit != null) {
      $result.environmentDisplayFahrenheit = environmentDisplayFahrenheit;
    }
    return $result;
  }
  ModuleConfig_TelemetryConfig._() : super();
  factory ModuleConfig_TelemetryConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ModuleConfig_TelemetryConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ModuleConfig.TelemetryConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'deviceUpdateInterval', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'environmentUpdateInterval', $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'environmentMeasurementEnabled')
    ..aOB(4, _omitFieldNames ? '' : 'environmentScreenEnabled')
    ..aOB(5, _omitFieldNames ? '' : 'environmentDisplayFahrenheit')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ModuleConfig_TelemetryConfig clone() => ModuleConfig_TelemetryConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ModuleConfig_TelemetryConfig copyWith(void Function(ModuleConfig_TelemetryConfig) updates) => super.copyWith((message) => updates(message as ModuleConfig_TelemetryConfig)) as ModuleConfig_TelemetryConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModuleConfig_TelemetryConfig create() => ModuleConfig_TelemetryConfig._();
  ModuleConfig_TelemetryConfig createEmptyInstance() => create();
  static $pb.PbList<ModuleConfig_TelemetryConfig> createRepeated() => $pb.PbList<ModuleConfig_TelemetryConfig>();
  @$core.pragma('dart2js:noInline')
  static ModuleConfig_TelemetryConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ModuleConfig_TelemetryConfig>(create);
  static ModuleConfig_TelemetryConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get deviceUpdateInterval => $_getIZ(0);
  @$pb.TagNumber(1)
  set deviceUpdateInterval($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceUpdateInterval() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceUpdateInterval() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get environmentUpdateInterval => $_getIZ(1);
  @$pb.TagNumber(2)
  set environmentUpdateInterval($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEnvironmentUpdateInterval() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnvironmentUpdateInterval() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get environmentMeasurementEnabled => $_getBF(2);
  @$pb.TagNumber(3)
  set environmentMeasurementEnabled($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEnvironmentMeasurementEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnvironmentMeasurementEnabled() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get environmentScreenEnabled => $_getBF(3);
  @$pb.TagNumber(4)
  set environmentScreenEnabled($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEnvironmentScreenEnabled() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnvironmentScreenEnabled() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get environmentDisplayFahrenheit => $_getBF(4);
  @$pb.TagNumber(5)
  set environmentDisplayFahrenheit($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasEnvironmentDisplayFahrenheit() => $_has(4);
  @$pb.TagNumber(5)
  void clearEnvironmentDisplayFahrenheit() => clearField(5);
}

/// *
///  Canned message module configuration.
class ModuleConfig_CannedMessageConfig extends $pb.GeneratedMessage {
  factory ModuleConfig_CannedMessageConfig({
    $core.bool? rotary1Enabled,
    $core.int? inputbrokerPinA,
    $core.int? inputbrokerPinB,
    $core.int? inputbrokerPinPress,
    ModuleConfig_CannedMessageConfig_InputEventChar? inputbrokerEventCw,
    ModuleConfig_CannedMessageConfig_InputEventChar? inputbrokerEventCcw,
    ModuleConfig_CannedMessageConfig_InputEventChar? inputbrokerEventPress,
    $core.bool? updown1Enabled,
    $core.bool? enabled,
    $core.String? allowInputSource,
    $core.bool? sendBell,
  }) {
    final $result = create();
    if (rotary1Enabled != null) {
      $result.rotary1Enabled = rotary1Enabled;
    }
    if (inputbrokerPinA != null) {
      $result.inputbrokerPinA = inputbrokerPinA;
    }
    if (inputbrokerPinB != null) {
      $result.inputbrokerPinB = inputbrokerPinB;
    }
    if (inputbrokerPinPress != null) {
      $result.inputbrokerPinPress = inputbrokerPinPress;
    }
    if (inputbrokerEventCw != null) {
      $result.inputbrokerEventCw = inputbrokerEventCw;
    }
    if (inputbrokerEventCcw != null) {
      $result.inputbrokerEventCcw = inputbrokerEventCcw;
    }
    if (inputbrokerEventPress != null) {
      $result.inputbrokerEventPress = inputbrokerEventPress;
    }
    if (updown1Enabled != null) {
      $result.updown1Enabled = updown1Enabled;
    }
    if (enabled != null) {
      $result.enabled = enabled;
    }
    if (allowInputSource != null) {
      $result.allowInputSource = allowInputSource;
    }
    if (sendBell != null) {
      $result.sendBell = sendBell;
    }
    return $result;
  }
  ModuleConfig_CannedMessageConfig._() : super();
  factory ModuleConfig_CannedMessageConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ModuleConfig_CannedMessageConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ModuleConfig.CannedMessageConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'rotary1Enabled')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'inputbrokerPinA', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'inputbrokerPinB', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'inputbrokerPinPress', $pb.PbFieldType.OU3)
    ..e<ModuleConfig_CannedMessageConfig_InputEventChar>(5, _omitFieldNames ? '' : 'inputbrokerEventCw', $pb.PbFieldType.OE, defaultOrMaker: ModuleConfig_CannedMessageConfig_InputEventChar.NONE, valueOf: ModuleConfig_CannedMessageConfig_InputEventChar.valueOf, enumValues: ModuleConfig_CannedMessageConfig_InputEventChar.values)
    ..e<ModuleConfig_CannedMessageConfig_InputEventChar>(6, _omitFieldNames ? '' : 'inputbrokerEventCcw', $pb.PbFieldType.OE, defaultOrMaker: ModuleConfig_CannedMessageConfig_InputEventChar.NONE, valueOf: ModuleConfig_CannedMessageConfig_InputEventChar.valueOf, enumValues: ModuleConfig_CannedMessageConfig_InputEventChar.values)
    ..e<ModuleConfig_CannedMessageConfig_InputEventChar>(7, _omitFieldNames ? '' : 'inputbrokerEventPress', $pb.PbFieldType.OE, defaultOrMaker: ModuleConfig_CannedMessageConfig_InputEventChar.NONE, valueOf: ModuleConfig_CannedMessageConfig_InputEventChar.valueOf, enumValues: ModuleConfig_CannedMessageConfig_InputEventChar.values)
    ..aOB(8, _omitFieldNames ? '' : 'updown1Enabled')
    ..aOB(9, _omitFieldNames ? '' : 'enabled')
    ..aOS(10, _omitFieldNames ? '' : 'allowInputSource')
    ..aOB(11, _omitFieldNames ? '' : 'sendBell')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ModuleConfig_CannedMessageConfig clone() => ModuleConfig_CannedMessageConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ModuleConfig_CannedMessageConfig copyWith(void Function(ModuleConfig_CannedMessageConfig) updates) => super.copyWith((message) => updates(message as ModuleConfig_CannedMessageConfig)) as ModuleConfig_CannedMessageConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModuleConfig_CannedMessageConfig create() => ModuleConfig_CannedMessageConfig._();
  ModuleConfig_CannedMessageConfig createEmptyInstance() => create();
  static $pb.PbList<ModuleConfig_CannedMessageConfig> createRepeated() => $pb.PbList<ModuleConfig_CannedMessageConfig>();
  @$core.pragma('dart2js:noInline')
  static ModuleConfig_CannedMessageConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ModuleConfig_CannedMessageConfig>(create);
  static ModuleConfig_CannedMessageConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get rotary1Enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set rotary1Enabled($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRotary1Enabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearRotary1Enabled() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get inputbrokerPinA => $_getIZ(1);
  @$pb.TagNumber(2)
  set inputbrokerPinA($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInputbrokerPinA() => $_has(1);
  @$pb.TagNumber(2)
  void clearInputbrokerPinA() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get inputbrokerPinB => $_getIZ(2);
  @$pb.TagNumber(3)
  set inputbrokerPinB($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasInputbrokerPinB() => $_has(2);
  @$pb.TagNumber(3)
  void clearInputbrokerPinB() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get inputbrokerPinPress => $_getIZ(3);
  @$pb.TagNumber(4)
  set inputbrokerPinPress($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasInputbrokerPinPress() => $_has(3);
  @$pb.TagNumber(4)
  void clearInputbrokerPinPress() => clearField(4);

  @$pb.TagNumber(5)
  ModuleConfig_CannedMessageConfig_InputEventChar get inputbrokerEventCw => $_getN(4);
  @$pb.TagNumber(5)
  set inputbrokerEventCw(ModuleConfig_CannedMessageConfig_InputEventChar v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasInputbrokerEventCw() => $_has(4);
  @$pb.TagNumber(5)
  void clearInputbrokerEventCw() => clearField(5);

  @$pb.TagNumber(6)
  ModuleConfig_CannedMessageConfig_InputEventChar get inputbrokerEventCcw => $_getN(5);
  @$pb.TagNumber(6)
  set inputbrokerEventCcw(ModuleConfig_CannedMessageConfig_InputEventChar v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasInputbrokerEventCcw() => $_has(5);
  @$pb.TagNumber(6)
  void clearInputbrokerEventCcw() => clearField(6);

  @$pb.TagNumber(7)
  ModuleConfig_CannedMessageConfig_InputEventChar get inputbrokerEventPress => $_getN(6);
  @$pb.TagNumber(7)
  set inputbrokerEventPress(ModuleConfig_CannedMessageConfig_InputEventChar v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasInputbrokerEventPress() => $_has(6);
  @$pb.TagNumber(7)
  void clearInputbrokerEventPress() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get updown1Enabled => $_getBF(7);
  @$pb.TagNumber(8)
  set updown1Enabled($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasUpdown1Enabled() => $_has(7);
  @$pb.TagNumber(8)
  void clearUpdown1Enabled() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get enabled => $_getBF(8);
  @$pb.TagNumber(9)
  set enabled($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasEnabled() => $_has(8);
  @$pb.TagNumber(9)
  void clearEnabled() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get allowInputSource => $_getSZ(9);
  @$pb.TagNumber(10)
  set allowInputSource($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasAllowInputSource() => $_has(9);
  @$pb.TagNumber(10)
  void clearAllowInputSource() => clearField(10);

  @$pb.TagNumber(11)
  $core.bool get sendBell => $_getBF(10);
  @$pb.TagNumber(11)
  set sendBell($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasSendBell() => $_has(10);
  @$pb.TagNumber(11)
  void clearSendBell() => clearField(11);
}

/// *
///  Audio module configuration.
class ModuleConfig_AudioConfig extends $pb.GeneratedMessage {
  factory ModuleConfig_AudioConfig({
    $core.bool? codec2Enabled,
    $core.int? pttPin,
    ModuleConfig_AudioConfig_Audio_Baud? bitrate,
    $core.int? i2sWs,
    $core.int? i2sSd,
    $core.int? i2sDin,
    $core.int? i2sSck,
  }) {
    final $result = create();
    if (codec2Enabled != null) {
      $result.codec2Enabled = codec2Enabled;
    }
    if (pttPin != null) {
      $result.pttPin = pttPin;
    }
    if (bitrate != null) {
      $result.bitrate = bitrate;
    }
    if (i2sWs != null) {
      $result.i2sWs = i2sWs;
    }
    if (i2sSd != null) {
      $result.i2sSd = i2sSd;
    }
    if (i2sDin != null) {
      $result.i2sDin = i2sDin;
    }
    if (i2sSck != null) {
      $result.i2sSck = i2sSck;
    }
    return $result;
  }
  ModuleConfig_AudioConfig._() : super();
  factory ModuleConfig_AudioConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ModuleConfig_AudioConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ModuleConfig.AudioConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'codec2Enabled')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'pttPin', $pb.PbFieldType.OU3)
    ..e<ModuleConfig_AudioConfig_Audio_Baud>(3, _omitFieldNames ? '' : 'bitrate', $pb.PbFieldType.OE, defaultOrMaker: ModuleConfig_AudioConfig_Audio_Baud.CODEC2_DEFAULT, valueOf: ModuleConfig_AudioConfig_Audio_Baud.valueOf, enumValues: ModuleConfig_AudioConfig_Audio_Baud.values)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'i2sWs', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'i2sSd', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'i2sDin', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'i2sSck', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ModuleConfig_AudioConfig clone() => ModuleConfig_AudioConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ModuleConfig_AudioConfig copyWith(void Function(ModuleConfig_AudioConfig) updates) => super.copyWith((message) => updates(message as ModuleConfig_AudioConfig)) as ModuleConfig_AudioConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModuleConfig_AudioConfig create() => ModuleConfig_AudioConfig._();
  ModuleConfig_AudioConfig createEmptyInstance() => create();
  static $pb.PbList<ModuleConfig_AudioConfig> createRepeated() => $pb.PbList<ModuleConfig_AudioConfig>();
  @$core.pragma('dart2js:noInline')
  static ModuleConfig_AudioConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ModuleConfig_AudioConfig>(create);
  static ModuleConfig_AudioConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get codec2Enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set codec2Enabled($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCodec2Enabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearCodec2Enabled() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get pttPin => $_getIZ(1);
  @$pb.TagNumber(2)
  set pttPin($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPttPin() => $_has(1);
  @$pb.TagNumber(2)
  void clearPttPin() => clearField(2);

  @$pb.TagNumber(3)
  ModuleConfig_AudioConfig_Audio_Baud get bitrate => $_getN(2);
  @$pb.TagNumber(3)
  set bitrate(ModuleConfig_AudioConfig_Audio_Baud v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasBitrate() => $_has(2);
  @$pb.TagNumber(3)
  void clearBitrate() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get i2sWs => $_getIZ(3);
  @$pb.TagNumber(4)
  set i2sWs($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasI2sWs() => $_has(3);
  @$pb.TagNumber(4)
  void clearI2sWs() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get i2sSd => $_getIZ(4);
  @$pb.TagNumber(5)
  set i2sSd($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasI2sSd() => $_has(4);
  @$pb.TagNumber(5)
  void clearI2sSd() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get i2sDin => $_getIZ(5);
  @$pb.TagNumber(6)
  set i2sDin($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasI2sDin() => $_has(5);
  @$pb.TagNumber(6)
  void clearI2sDin() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get i2sSck => $_getIZ(6);
  @$pb.TagNumber(7)
  set i2sSck($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasI2sSck() => $_has(6);
  @$pb.TagNumber(7)
  void clearI2sSck() => clearField(7);
}

/// *
///  Remote hardware module configuration.
class ModuleConfig_RemoteHardwareConfig extends $pb.GeneratedMessage {
  factory ModuleConfig_RemoteHardwareConfig({
    $core.bool? enabled,
    $core.bool? allowUndefinedPinAccess,
  }) {
    final $result = create();
    if (enabled != null) {
      $result.enabled = enabled;
    }
    if (allowUndefinedPinAccess != null) {
      $result.allowUndefinedPinAccess = allowUndefinedPinAccess;
    }
    return $result;
  }
  ModuleConfig_RemoteHardwareConfig._() : super();
  factory ModuleConfig_RemoteHardwareConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ModuleConfig_RemoteHardwareConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ModuleConfig.RemoteHardwareConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..aOB(2, _omitFieldNames ? '' : 'allowUndefinedPinAccess')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ModuleConfig_RemoteHardwareConfig clone() => ModuleConfig_RemoteHardwareConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ModuleConfig_RemoteHardwareConfig copyWith(void Function(ModuleConfig_RemoteHardwareConfig) updates) => super.copyWith((message) => updates(message as ModuleConfig_RemoteHardwareConfig)) as ModuleConfig_RemoteHardwareConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModuleConfig_RemoteHardwareConfig create() => ModuleConfig_RemoteHardwareConfig._();
  ModuleConfig_RemoteHardwareConfig createEmptyInstance() => create();
  static $pb.PbList<ModuleConfig_RemoteHardwareConfig> createRepeated() => $pb.PbList<ModuleConfig_RemoteHardwareConfig>();
  @$core.pragma('dart2js:noInline')
  static ModuleConfig_RemoteHardwareConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ModuleConfig_RemoteHardwareConfig>(create);
  static ModuleConfig_RemoteHardwareConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get allowUndefinedPinAccess => $_getBF(1);
  @$pb.TagNumber(2)
  set allowUndefinedPinAccess($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAllowUndefinedPinAccess() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllowUndefinedPinAccess() => clearField(2);
}

enum ModuleConfig_PayloadVariant {
  mqtt, 
  serial, 
  externalNotification, 
  storeForward, 
  rangeTest, 
  telemetry, 
  cannedMessage, 
  audio, 
  remoteHardware, 
  notSet
}

/// *
///  Module configuration message.
///  Contains sub-configurations for optional radio modules.
class ModuleConfig extends $pb.GeneratedMessage {
  factory ModuleConfig({
    ModuleConfig_MQTTConfig? mqtt,
    ModuleConfig_SerialConfig? serial,
    ModuleConfig_ExternalNotificationConfig? externalNotification,
    ModuleConfig_StoreForwardConfig? storeForward,
    ModuleConfig_RangeTestConfig? rangeTest,
    ModuleConfig_TelemetryConfig? telemetry,
    ModuleConfig_CannedMessageConfig? cannedMessage,
    ModuleConfig_AudioConfig? audio,
    ModuleConfig_RemoteHardwareConfig? remoteHardware,
  }) {
    final $result = create();
    if (mqtt != null) {
      $result.mqtt = mqtt;
    }
    if (serial != null) {
      $result.serial = serial;
    }
    if (externalNotification != null) {
      $result.externalNotification = externalNotification;
    }
    if (storeForward != null) {
      $result.storeForward = storeForward;
    }
    if (rangeTest != null) {
      $result.rangeTest = rangeTest;
    }
    if (telemetry != null) {
      $result.telemetry = telemetry;
    }
    if (cannedMessage != null) {
      $result.cannedMessage = cannedMessage;
    }
    if (audio != null) {
      $result.audio = audio;
    }
    if (remoteHardware != null) {
      $result.remoteHardware = remoteHardware;
    }
    return $result;
  }
  ModuleConfig._() : super();
  factory ModuleConfig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ModuleConfig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, ModuleConfig_PayloadVariant> _ModuleConfig_PayloadVariantByTag = {
    1 : ModuleConfig_PayloadVariant.mqtt,
    2 : ModuleConfig_PayloadVariant.serial,
    3 : ModuleConfig_PayloadVariant.externalNotification,
    4 : ModuleConfig_PayloadVariant.storeForward,
    5 : ModuleConfig_PayloadVariant.rangeTest,
    6 : ModuleConfig_PayloadVariant.telemetry,
    7 : ModuleConfig_PayloadVariant.cannedMessage,
    8 : ModuleConfig_PayloadVariant.audio,
    9 : ModuleConfig_PayloadVariant.remoteHardware,
    0 : ModuleConfig_PayloadVariant.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ModuleConfig', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8, 9])
    ..aOM<ModuleConfig_MQTTConfig>(1, _omitFieldNames ? '' : 'mqtt', subBuilder: ModuleConfig_MQTTConfig.create)
    ..aOM<ModuleConfig_SerialConfig>(2, _omitFieldNames ? '' : 'serial', subBuilder: ModuleConfig_SerialConfig.create)
    ..aOM<ModuleConfig_ExternalNotificationConfig>(3, _omitFieldNames ? '' : 'externalNotification', subBuilder: ModuleConfig_ExternalNotificationConfig.create)
    ..aOM<ModuleConfig_StoreForwardConfig>(4, _omitFieldNames ? '' : 'storeForward', subBuilder: ModuleConfig_StoreForwardConfig.create)
    ..aOM<ModuleConfig_RangeTestConfig>(5, _omitFieldNames ? '' : 'rangeTest', subBuilder: ModuleConfig_RangeTestConfig.create)
    ..aOM<ModuleConfig_TelemetryConfig>(6, _omitFieldNames ? '' : 'telemetry', subBuilder: ModuleConfig_TelemetryConfig.create)
    ..aOM<ModuleConfig_CannedMessageConfig>(7, _omitFieldNames ? '' : 'cannedMessage', subBuilder: ModuleConfig_CannedMessageConfig.create)
    ..aOM<ModuleConfig_AudioConfig>(8, _omitFieldNames ? '' : 'audio', subBuilder: ModuleConfig_AudioConfig.create)
    ..aOM<ModuleConfig_RemoteHardwareConfig>(9, _omitFieldNames ? '' : 'remoteHardware', subBuilder: ModuleConfig_RemoteHardwareConfig.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ModuleConfig clone() => ModuleConfig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ModuleConfig copyWith(void Function(ModuleConfig) updates) => super.copyWith((message) => updates(message as ModuleConfig)) as ModuleConfig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ModuleConfig create() => ModuleConfig._();
  ModuleConfig createEmptyInstance() => create();
  static $pb.PbList<ModuleConfig> createRepeated() => $pb.PbList<ModuleConfig>();
  @$core.pragma('dart2js:noInline')
  static ModuleConfig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ModuleConfig>(create);
  static ModuleConfig? _defaultInstance;

  ModuleConfig_PayloadVariant whichPayloadVariant() => _ModuleConfig_PayloadVariantByTag[$_whichOneof(0)]!;
  void clearPayloadVariant() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ModuleConfig_MQTTConfig get mqtt => $_getN(0);
  @$pb.TagNumber(1)
  set mqtt(ModuleConfig_MQTTConfig v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasMqtt() => $_has(0);
  @$pb.TagNumber(1)
  void clearMqtt() => clearField(1);
  @$pb.TagNumber(1)
  ModuleConfig_MQTTConfig ensureMqtt() => $_ensure(0);

  @$pb.TagNumber(2)
  ModuleConfig_SerialConfig get serial => $_getN(1);
  @$pb.TagNumber(2)
  set serial(ModuleConfig_SerialConfig v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSerial() => $_has(1);
  @$pb.TagNumber(2)
  void clearSerial() => clearField(2);
  @$pb.TagNumber(2)
  ModuleConfig_SerialConfig ensureSerial() => $_ensure(1);

  @$pb.TagNumber(3)
  ModuleConfig_ExternalNotificationConfig get externalNotification => $_getN(2);
  @$pb.TagNumber(3)
  set externalNotification(ModuleConfig_ExternalNotificationConfig v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasExternalNotification() => $_has(2);
  @$pb.TagNumber(3)
  void clearExternalNotification() => clearField(3);
  @$pb.TagNumber(3)
  ModuleConfig_ExternalNotificationConfig ensureExternalNotification() => $_ensure(2);

  @$pb.TagNumber(4)
  ModuleConfig_StoreForwardConfig get storeForward => $_getN(3);
  @$pb.TagNumber(4)
  set storeForward(ModuleConfig_StoreForwardConfig v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasStoreForward() => $_has(3);
  @$pb.TagNumber(4)
  void clearStoreForward() => clearField(4);
  @$pb.TagNumber(4)
  ModuleConfig_StoreForwardConfig ensureStoreForward() => $_ensure(3);

  @$pb.TagNumber(5)
  ModuleConfig_RangeTestConfig get rangeTest => $_getN(4);
  @$pb.TagNumber(5)
  set rangeTest(ModuleConfig_RangeTestConfig v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasRangeTest() => $_has(4);
  @$pb.TagNumber(5)
  void clearRangeTest() => clearField(5);
  @$pb.TagNumber(5)
  ModuleConfig_RangeTestConfig ensureRangeTest() => $_ensure(4);

  @$pb.TagNumber(6)
  ModuleConfig_TelemetryConfig get telemetry => $_getN(5);
  @$pb.TagNumber(6)
  set telemetry(ModuleConfig_TelemetryConfig v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasTelemetry() => $_has(5);
  @$pb.TagNumber(6)
  void clearTelemetry() => clearField(6);
  @$pb.TagNumber(6)
  ModuleConfig_TelemetryConfig ensureTelemetry() => $_ensure(5);

  @$pb.TagNumber(7)
  ModuleConfig_CannedMessageConfig get cannedMessage => $_getN(6);
  @$pb.TagNumber(7)
  set cannedMessage(ModuleConfig_CannedMessageConfig v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasCannedMessage() => $_has(6);
  @$pb.TagNumber(7)
  void clearCannedMessage() => clearField(7);
  @$pb.TagNumber(7)
  ModuleConfig_CannedMessageConfig ensureCannedMessage() => $_ensure(6);

  @$pb.TagNumber(8)
  ModuleConfig_AudioConfig get audio => $_getN(7);
  @$pb.TagNumber(8)
  set audio(ModuleConfig_AudioConfig v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasAudio() => $_has(7);
  @$pb.TagNumber(8)
  void clearAudio() => clearField(8);
  @$pb.TagNumber(8)
  ModuleConfig_AudioConfig ensureAudio() => $_ensure(7);

  @$pb.TagNumber(9)
  ModuleConfig_RemoteHardwareConfig get remoteHardware => $_getN(8);
  @$pb.TagNumber(9)
  set remoteHardware(ModuleConfig_RemoteHardwareConfig v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasRemoteHardware() => $_has(8);
  @$pb.TagNumber(9)
  void clearRemoteHardware() => clearField(9);
  @$pb.TagNumber(9)
  ModuleConfig_RemoteHardwareConfig ensureRemoteHardware() => $_ensure(8);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
