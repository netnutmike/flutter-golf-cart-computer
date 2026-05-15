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

class Config_DeviceConfig_Role extends $pb.ProtobufEnum {
  static const Config_DeviceConfig_Role CLIENT = Config_DeviceConfig_Role._(0, _omitEnumNames ? '' : 'CLIENT');
  static const Config_DeviceConfig_Role CLIENT_MUTE = Config_DeviceConfig_Role._(1, _omitEnumNames ? '' : 'CLIENT_MUTE');
  static const Config_DeviceConfig_Role ROUTER = Config_DeviceConfig_Role._(2, _omitEnumNames ? '' : 'ROUTER');
  static const Config_DeviceConfig_Role ROUTER_CLIENT = Config_DeviceConfig_Role._(3, _omitEnumNames ? '' : 'ROUTER_CLIENT');

  static const $core.List<Config_DeviceConfig_Role> values = <Config_DeviceConfig_Role> [
    CLIENT,
    CLIENT_MUTE,
    ROUTER,
    ROUTER_CLIENT,
  ];

  static final $core.Map<$core.int, Config_DeviceConfig_Role> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Config_DeviceConfig_Role? valueOf($core.int value) => _byValue[value];

  const Config_DeviceConfig_Role._($core.int v, $core.String n) : super(v, n);
}

class Config_DisplayConfig_GpsCoordinateFormat extends $pb.ProtobufEnum {
  static const Config_DisplayConfig_GpsCoordinateFormat DEC = Config_DisplayConfig_GpsCoordinateFormat._(0, _omitEnumNames ? '' : 'DEC');
  static const Config_DisplayConfig_GpsCoordinateFormat DMS = Config_DisplayConfig_GpsCoordinateFormat._(1, _omitEnumNames ? '' : 'DMS');
  static const Config_DisplayConfig_GpsCoordinateFormat UTM = Config_DisplayConfig_GpsCoordinateFormat._(2, _omitEnumNames ? '' : 'UTM');
  static const Config_DisplayConfig_GpsCoordinateFormat MGRS = Config_DisplayConfig_GpsCoordinateFormat._(3, _omitEnumNames ? '' : 'MGRS');
  static const Config_DisplayConfig_GpsCoordinateFormat OLC = Config_DisplayConfig_GpsCoordinateFormat._(4, _omitEnumNames ? '' : 'OLC');
  static const Config_DisplayConfig_GpsCoordinateFormat OSGR = Config_DisplayConfig_GpsCoordinateFormat._(5, _omitEnumNames ? '' : 'OSGR');

  static const $core.List<Config_DisplayConfig_GpsCoordinateFormat> values = <Config_DisplayConfig_GpsCoordinateFormat> [
    DEC,
    DMS,
    UTM,
    MGRS,
    OLC,
    OSGR,
  ];

  static final $core.Map<$core.int, Config_DisplayConfig_GpsCoordinateFormat> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Config_DisplayConfig_GpsCoordinateFormat? valueOf($core.int value) => _byValue[value];

  const Config_DisplayConfig_GpsCoordinateFormat._($core.int v, $core.String n) : super(v, n);
}

class Config_DisplayConfig_DisplayUnits extends $pb.ProtobufEnum {
  static const Config_DisplayConfig_DisplayUnits METRIC = Config_DisplayConfig_DisplayUnits._(0, _omitEnumNames ? '' : 'METRIC');
  static const Config_DisplayConfig_DisplayUnits IMPERIAL = Config_DisplayConfig_DisplayUnits._(1, _omitEnumNames ? '' : 'IMPERIAL');

  static const $core.List<Config_DisplayConfig_DisplayUnits> values = <Config_DisplayConfig_DisplayUnits> [
    METRIC,
    IMPERIAL,
  ];

  static final $core.Map<$core.int, Config_DisplayConfig_DisplayUnits> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Config_DisplayConfig_DisplayUnits? valueOf($core.int value) => _byValue[value];

  const Config_DisplayConfig_DisplayUnits._($core.int v, $core.String n) : super(v, n);
}

class Config_LoRaConfig_ModemPreset extends $pb.ProtobufEnum {
  static const Config_LoRaConfig_ModemPreset LONG_FAST = Config_LoRaConfig_ModemPreset._(0, _omitEnumNames ? '' : 'LONG_FAST');
  static const Config_LoRaConfig_ModemPreset LONG_SLOW = Config_LoRaConfig_ModemPreset._(1, _omitEnumNames ? '' : 'LONG_SLOW');
  static const Config_LoRaConfig_ModemPreset VERY_LONG_SLOW = Config_LoRaConfig_ModemPreset._(2, _omitEnumNames ? '' : 'VERY_LONG_SLOW');
  static const Config_LoRaConfig_ModemPreset MEDIUM_SLOW = Config_LoRaConfig_ModemPreset._(3, _omitEnumNames ? '' : 'MEDIUM_SLOW');
  static const Config_LoRaConfig_ModemPreset MEDIUM_FAST = Config_LoRaConfig_ModemPreset._(4, _omitEnumNames ? '' : 'MEDIUM_FAST');
  static const Config_LoRaConfig_ModemPreset SHORT_SLOW = Config_LoRaConfig_ModemPreset._(5, _omitEnumNames ? '' : 'SHORT_SLOW');
  static const Config_LoRaConfig_ModemPreset SHORT_FAST = Config_LoRaConfig_ModemPreset._(6, _omitEnumNames ? '' : 'SHORT_FAST');

  static const $core.List<Config_LoRaConfig_ModemPreset> values = <Config_LoRaConfig_ModemPreset> [
    LONG_FAST,
    LONG_SLOW,
    VERY_LONG_SLOW,
    MEDIUM_SLOW,
    MEDIUM_FAST,
    SHORT_SLOW,
    SHORT_FAST,
  ];

  static final $core.Map<$core.int, Config_LoRaConfig_ModemPreset> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Config_LoRaConfig_ModemPreset? valueOf($core.int value) => _byValue[value];

  const Config_LoRaConfig_ModemPreset._($core.int v, $core.String n) : super(v, n);
}

class Config_BluetoothConfig_PairingMode extends $pb.ProtobufEnum {
  static const Config_BluetoothConfig_PairingMode RANDOM_PIN = Config_BluetoothConfig_PairingMode._(0, _omitEnumNames ? '' : 'RANDOM_PIN');
  static const Config_BluetoothConfig_PairingMode FIXED_PIN = Config_BluetoothConfig_PairingMode._(1, _omitEnumNames ? '' : 'FIXED_PIN');
  static const Config_BluetoothConfig_PairingMode NO_PIN = Config_BluetoothConfig_PairingMode._(2, _omitEnumNames ? '' : 'NO_PIN');

  static const $core.List<Config_BluetoothConfig_PairingMode> values = <Config_BluetoothConfig_PairingMode> [
    RANDOM_PIN,
    FIXED_PIN,
    NO_PIN,
  ];

  static final $core.Map<$core.int, Config_BluetoothConfig_PairingMode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Config_BluetoothConfig_PairingMode? valueOf($core.int value) => _byValue[value];

  const Config_BluetoothConfig_PairingMode._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
