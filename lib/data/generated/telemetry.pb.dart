//
//  Generated code. Do not modify.
//  source: telemetry.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// *
///  Device metrics reported by nodes.
class DeviceMetrics extends $pb.GeneratedMessage {
  factory DeviceMetrics({
    $core.int? batteryLevel,
    $core.double? voltage,
    $core.double? channelUtilization,
    $core.double? airUtilTx,
    $core.int? uptimeSeconds,
  }) {
    final $result = create();
    if (batteryLevel != null) {
      $result.batteryLevel = batteryLevel;
    }
    if (voltage != null) {
      $result.voltage = voltage;
    }
    if (channelUtilization != null) {
      $result.channelUtilization = channelUtilization;
    }
    if (airUtilTx != null) {
      $result.airUtilTx = airUtilTx;
    }
    if (uptimeSeconds != null) {
      $result.uptimeSeconds = uptimeSeconds;
    }
    return $result;
  }
  DeviceMetrics._() : super();
  factory DeviceMetrics.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeviceMetrics.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeviceMetrics', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'batteryLevel', $pb.PbFieldType.OU3)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'voltage', $pb.PbFieldType.OF)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'channelUtilization', $pb.PbFieldType.OF)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'airUtilTx', $pb.PbFieldType.OF)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'uptimeSeconds', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeviceMetrics clone() => DeviceMetrics()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeviceMetrics copyWith(void Function(DeviceMetrics) updates) => super.copyWith((message) => updates(message as DeviceMetrics)) as DeviceMetrics;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceMetrics create() => DeviceMetrics._();
  DeviceMetrics createEmptyInstance() => create();
  static $pb.PbList<DeviceMetrics> createRepeated() => $pb.PbList<DeviceMetrics>();
  @$core.pragma('dart2js:noInline')
  static DeviceMetrics getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeviceMetrics>(create);
  static DeviceMetrics? _defaultInstance;

  /// Battery level (0-100, or 101 for powered)
  @$pb.TagNumber(1)
  $core.int get batteryLevel => $_getIZ(0);
  @$pb.TagNumber(1)
  set batteryLevel($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBatteryLevel() => $_has(0);
  @$pb.TagNumber(1)
  void clearBatteryLevel() => clearField(1);

  /// Voltage in volts
  @$pb.TagNumber(2)
  $core.double get voltage => $_getN(1);
  @$pb.TagNumber(2)
  set voltage($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVoltage() => $_has(1);
  @$pb.TagNumber(2)
  void clearVoltage() => clearField(2);

  /// Channel utilization percentage
  @$pb.TagNumber(3)
  $core.double get channelUtilization => $_getN(2);
  @$pb.TagNumber(3)
  set channelUtilization($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasChannelUtilization() => $_has(2);
  @$pb.TagNumber(3)
  void clearChannelUtilization() => clearField(3);

  /// Airtime utilization percentage
  @$pb.TagNumber(4)
  $core.double get airUtilTx => $_getN(3);
  @$pb.TagNumber(4)
  set airUtilTx($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAirUtilTx() => $_has(3);
  @$pb.TagNumber(4)
  void clearAirUtilTx() => clearField(4);

  /// Uptime in seconds
  @$pb.TagNumber(5)
  $core.int get uptimeSeconds => $_getIZ(4);
  @$pb.TagNumber(5)
  set uptimeSeconds($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasUptimeSeconds() => $_has(4);
  @$pb.TagNumber(5)
  void clearUptimeSeconds() => clearField(5);
}

/// *
///  Environment metrics from sensors.
class EnvironmentMetrics extends $pb.GeneratedMessage {
  factory EnvironmentMetrics({
    $core.double? temperature,
    $core.double? relativeHumidity,
    $core.double? barometricPressure,
    $core.double? gasResistance,
    $core.double? voltage,
    $core.double? current,
  }) {
    final $result = create();
    if (temperature != null) {
      $result.temperature = temperature;
    }
    if (relativeHumidity != null) {
      $result.relativeHumidity = relativeHumidity;
    }
    if (barometricPressure != null) {
      $result.barometricPressure = barometricPressure;
    }
    if (gasResistance != null) {
      $result.gasResistance = gasResistance;
    }
    if (voltage != null) {
      $result.voltage = voltage;
    }
    if (current != null) {
      $result.current = current;
    }
    return $result;
  }
  EnvironmentMetrics._() : super();
  factory EnvironmentMetrics.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EnvironmentMetrics.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EnvironmentMetrics', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'temperature', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'relativeHumidity', $pb.PbFieldType.OF)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'barometricPressure', $pb.PbFieldType.OF)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'gasResistance', $pb.PbFieldType.OF)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'voltage', $pb.PbFieldType.OF)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'current', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EnvironmentMetrics clone() => EnvironmentMetrics()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EnvironmentMetrics copyWith(void Function(EnvironmentMetrics) updates) => super.copyWith((message) => updates(message as EnvironmentMetrics)) as EnvironmentMetrics;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EnvironmentMetrics create() => EnvironmentMetrics._();
  EnvironmentMetrics createEmptyInstance() => create();
  static $pb.PbList<EnvironmentMetrics> createRepeated() => $pb.PbList<EnvironmentMetrics>();
  @$core.pragma('dart2js:noInline')
  static EnvironmentMetrics getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EnvironmentMetrics>(create);
  static EnvironmentMetrics? _defaultInstance;

  /// Temperature in Celsius
  @$pb.TagNumber(1)
  $core.double get temperature => $_getN(0);
  @$pb.TagNumber(1)
  set temperature($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTemperature() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemperature() => clearField(1);

  /// Relative humidity percentage
  @$pb.TagNumber(2)
  $core.double get relativeHumidity => $_getN(1);
  @$pb.TagNumber(2)
  set relativeHumidity($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRelativeHumidity() => $_has(1);
  @$pb.TagNumber(2)
  void clearRelativeHumidity() => clearField(2);

  /// Barometric pressure in hPa
  @$pb.TagNumber(3)
  $core.double get barometricPressure => $_getN(2);
  @$pb.TagNumber(3)
  set barometricPressure($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBarometricPressure() => $_has(2);
  @$pb.TagNumber(3)
  void clearBarometricPressure() => clearField(3);

  /// Gas resistance in ohms
  @$pb.TagNumber(4)
  $core.double get gasResistance => $_getN(3);
  @$pb.TagNumber(4)
  set gasResistance($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasGasResistance() => $_has(3);
  @$pb.TagNumber(4)
  void clearGasResistance() => clearField(4);

  /// Voltage (external sensor)
  @$pb.TagNumber(5)
  $core.double get voltage => $_getN(4);
  @$pb.TagNumber(5)
  set voltage($core.double v) { $_setFloat(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasVoltage() => $_has(4);
  @$pb.TagNumber(5)
  void clearVoltage() => clearField(5);

  /// Current in mA
  @$pb.TagNumber(6)
  $core.double get current => $_getN(5);
  @$pb.TagNumber(6)
  set current($core.double v) { $_setFloat(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCurrent() => $_has(5);
  @$pb.TagNumber(6)
  void clearCurrent() => clearField(6);
}

/// *
///  Power metrics.
class PowerMetrics extends $pb.GeneratedMessage {
  factory PowerMetrics({
    $core.double? ch1Voltage,
    $core.double? ch1Current,
    $core.double? ch2Voltage,
    $core.double? ch2Current,
    $core.double? ch3Voltage,
    $core.double? ch3Current,
  }) {
    final $result = create();
    if (ch1Voltage != null) {
      $result.ch1Voltage = ch1Voltage;
    }
    if (ch1Current != null) {
      $result.ch1Current = ch1Current;
    }
    if (ch2Voltage != null) {
      $result.ch2Voltage = ch2Voltage;
    }
    if (ch2Current != null) {
      $result.ch2Current = ch2Current;
    }
    if (ch3Voltage != null) {
      $result.ch3Voltage = ch3Voltage;
    }
    if (ch3Current != null) {
      $result.ch3Current = ch3Current;
    }
    return $result;
  }
  PowerMetrics._() : super();
  factory PowerMetrics.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PowerMetrics.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PowerMetrics', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'ch1Voltage', $pb.PbFieldType.OF)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'ch1Current', $pb.PbFieldType.OF)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'ch2Voltage', $pb.PbFieldType.OF)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'ch2Current', $pb.PbFieldType.OF)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'ch3Voltage', $pb.PbFieldType.OF)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'ch3Current', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PowerMetrics clone() => PowerMetrics()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PowerMetrics copyWith(void Function(PowerMetrics) updates) => super.copyWith((message) => updates(message as PowerMetrics)) as PowerMetrics;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PowerMetrics create() => PowerMetrics._();
  PowerMetrics createEmptyInstance() => create();
  static $pb.PbList<PowerMetrics> createRepeated() => $pb.PbList<PowerMetrics>();
  @$core.pragma('dart2js:noInline')
  static PowerMetrics getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PowerMetrics>(create);
  static PowerMetrics? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get ch1Voltage => $_getN(0);
  @$pb.TagNumber(1)
  set ch1Voltage($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCh1Voltage() => $_has(0);
  @$pb.TagNumber(1)
  void clearCh1Voltage() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get ch1Current => $_getN(1);
  @$pb.TagNumber(2)
  set ch1Current($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCh1Current() => $_has(1);
  @$pb.TagNumber(2)
  void clearCh1Current() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get ch2Voltage => $_getN(2);
  @$pb.TagNumber(3)
  set ch2Voltage($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCh2Voltage() => $_has(2);
  @$pb.TagNumber(3)
  void clearCh2Voltage() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get ch2Current => $_getN(3);
  @$pb.TagNumber(4)
  set ch2Current($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCh2Current() => $_has(3);
  @$pb.TagNumber(4)
  void clearCh2Current() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get ch3Voltage => $_getN(4);
  @$pb.TagNumber(5)
  set ch3Voltage($core.double v) { $_setFloat(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCh3Voltage() => $_has(4);
  @$pb.TagNumber(5)
  void clearCh3Voltage() => clearField(5);

  @$pb.TagNumber(6)
  $core.double get ch3Current => $_getN(5);
  @$pb.TagNumber(6)
  set ch3Current($core.double v) { $_setFloat(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCh3Current() => $_has(5);
  @$pb.TagNumber(6)
  void clearCh3Current() => clearField(6);
}

enum Telemetry_Variant {
  deviceMetrics, 
  environmentMetrics, 
  powerMetrics, 
  notSet
}

/// *
///  Telemetry message containing device or environment metrics.
class Telemetry extends $pb.GeneratedMessage {
  factory Telemetry({
    $core.int? time,
    DeviceMetrics? deviceMetrics,
    EnvironmentMetrics? environmentMetrics,
    PowerMetrics? powerMetrics,
  }) {
    final $result = create();
    if (time != null) {
      $result.time = time;
    }
    if (deviceMetrics != null) {
      $result.deviceMetrics = deviceMetrics;
    }
    if (environmentMetrics != null) {
      $result.environmentMetrics = environmentMetrics;
    }
    if (powerMetrics != null) {
      $result.powerMetrics = powerMetrics;
    }
    return $result;
  }
  Telemetry._() : super();
  factory Telemetry.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Telemetry.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, Telemetry_Variant> _Telemetry_VariantByTag = {
    2 : Telemetry_Variant.deviceMetrics,
    3 : Telemetry_Variant.environmentMetrics,
    4 : Telemetry_Variant.powerMetrics,
    0 : Telemetry_Variant.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Telemetry', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..oo(0, [2, 3, 4])
    ..a<$core.int>(1, _omitFieldNames ? '' : 'time', $pb.PbFieldType.OF3)
    ..aOM<DeviceMetrics>(2, _omitFieldNames ? '' : 'deviceMetrics', subBuilder: DeviceMetrics.create)
    ..aOM<EnvironmentMetrics>(3, _omitFieldNames ? '' : 'environmentMetrics', subBuilder: EnvironmentMetrics.create)
    ..aOM<PowerMetrics>(4, _omitFieldNames ? '' : 'powerMetrics', subBuilder: PowerMetrics.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Telemetry clone() => Telemetry()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Telemetry copyWith(void Function(Telemetry) updates) => super.copyWith((message) => updates(message as Telemetry)) as Telemetry;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Telemetry create() => Telemetry._();
  Telemetry createEmptyInstance() => create();
  static $pb.PbList<Telemetry> createRepeated() => $pb.PbList<Telemetry>();
  @$core.pragma('dart2js:noInline')
  static Telemetry getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Telemetry>(create);
  static Telemetry? _defaultInstance;

  Telemetry_Variant whichVariant() => _Telemetry_VariantByTag[$_whichOneof(0)]!;
  void clearVariant() => clearField($_whichOneof(0));

  /// Timestamp when the telemetry was measured
  @$pb.TagNumber(1)
  $core.int get time => $_getIZ(0);
  @$pb.TagNumber(1)
  set time($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearTime() => clearField(1);

  @$pb.TagNumber(2)
  DeviceMetrics get deviceMetrics => $_getN(1);
  @$pb.TagNumber(2)
  set deviceMetrics(DeviceMetrics v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasDeviceMetrics() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceMetrics() => clearField(2);
  @$pb.TagNumber(2)
  DeviceMetrics ensureDeviceMetrics() => $_ensure(1);

  @$pb.TagNumber(3)
  EnvironmentMetrics get environmentMetrics => $_getN(2);
  @$pb.TagNumber(3)
  set environmentMetrics(EnvironmentMetrics v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasEnvironmentMetrics() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnvironmentMetrics() => clearField(3);
  @$pb.TagNumber(3)
  EnvironmentMetrics ensureEnvironmentMetrics() => $_ensure(2);

  @$pb.TagNumber(4)
  PowerMetrics get powerMetrics => $_getN(3);
  @$pb.TagNumber(4)
  set powerMetrics(PowerMetrics v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasPowerMetrics() => $_has(3);
  @$pb.TagNumber(4)
  void clearPowerMetrics() => clearField(4);
  @$pb.TagNumber(4)
  PowerMetrics ensurePowerMetrics() => $_ensure(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
