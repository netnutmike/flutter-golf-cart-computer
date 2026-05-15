//
//  Generated code. Do not modify.
//  source: mesh.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class HardwareModel extends $pb.ProtobufEnum {
  static const HardwareModel UNSET = HardwareModel._(0, _omitEnumNames ? '' : 'UNSET');
  static const HardwareModel TLORA_V2 = HardwareModel._(1, _omitEnumNames ? '' : 'TLORA_V2');
  static const HardwareModel TLORA_V1 = HardwareModel._(2, _omitEnumNames ? '' : 'TLORA_V1');
  static const HardwareModel TLORA_V2_1_1P6 = HardwareModel._(3, _omitEnumNames ? '' : 'TLORA_V2_1_1P6');
  static const HardwareModel TBEAM = HardwareModel._(4, _omitEnumNames ? '' : 'TBEAM');
  static const HardwareModel HELTEC_V2_0 = HardwareModel._(5, _omitEnumNames ? '' : 'HELTEC_V2_0');
  static const HardwareModel TBEAM_V0P7 = HardwareModel._(6, _omitEnumNames ? '' : 'TBEAM_V0P7');
  static const HardwareModel T_ECHO = HardwareModel._(7, _omitEnumNames ? '' : 'T_ECHO');
  static const HardwareModel TLORA_V1_1P3 = HardwareModel._(8, _omitEnumNames ? '' : 'TLORA_V1_1P3');
  static const HardwareModel RAK4631 = HardwareModel._(9, _omitEnumNames ? '' : 'RAK4631');
  static const HardwareModel HELTEC_V2_1 = HardwareModel._(10, _omitEnumNames ? '' : 'HELTEC_V2_1');
  static const HardwareModel HELTEC_V1 = HardwareModel._(11, _omitEnumNames ? '' : 'HELTEC_V1');
  static const HardwareModel LILYGO_TBEAM_S3_CORE = HardwareModel._(12, _omitEnumNames ? '' : 'LILYGO_TBEAM_S3_CORE');
  static const HardwareModel RAK11200 = HardwareModel._(13, _omitEnumNames ? '' : 'RAK11200');
  static const HardwareModel NANO_G1 = HardwareModel._(14, _omitEnumNames ? '' : 'NANO_G1');
  static const HardwareModel STATION_G1 = HardwareModel._(25, _omitEnumNames ? '' : 'STATION_G1');
  static const HardwareModel LORA_RELAY_V1 = HardwareModel._(32, _omitEnumNames ? '' : 'LORA_RELAY_V1');
  static const HardwareModel NRF52840DK = HardwareModel._(33, _omitEnumNames ? '' : 'NRF52840DK');
  static const HardwareModel PPR = HardwareModel._(34, _omitEnumNames ? '' : 'PPR');
  static const HardwareModel GENIEBLOCKS = HardwareModel._(35, _omitEnumNames ? '' : 'GENIEBLOCKS');
  static const HardwareModel NRF52_UNKNOWN = HardwareModel._(36, _omitEnumNames ? '' : 'NRF52_UNKNOWN');
  static const HardwareModel PORTDUINO = HardwareModel._(37, _omitEnumNames ? '' : 'PORTDUINO');
  static const HardwareModel ANDROID_SIM = HardwareModel._(38, _omitEnumNames ? '' : 'ANDROID_SIM');
  static const HardwareModel DIY_V1 = HardwareModel._(39, _omitEnumNames ? '' : 'DIY_V1');
  static const HardwareModel NRF52840_PCA10059 = HardwareModel._(40, _omitEnumNames ? '' : 'NRF52840_PCA10059');
  static const HardwareModel PRIVATE_HW = HardwareModel._(255, _omitEnumNames ? '' : 'PRIVATE_HW');

  static const $core.List<HardwareModel> values = <HardwareModel> [
    UNSET,
    TLORA_V2,
    TLORA_V1,
    TLORA_V2_1_1P6,
    TBEAM,
    HELTEC_V2_0,
    TBEAM_V0P7,
    T_ECHO,
    TLORA_V1_1P3,
    RAK4631,
    HELTEC_V2_1,
    HELTEC_V1,
    LILYGO_TBEAM_S3_CORE,
    RAK11200,
    NANO_G1,
    STATION_G1,
    LORA_RELAY_V1,
    NRF52840DK,
    PPR,
    GENIEBLOCKS,
    NRF52_UNKNOWN,
    PORTDUINO,
    ANDROID_SIM,
    DIY_V1,
    NRF52840_PCA10059,
    PRIVATE_HW,
  ];

  static final $core.Map<$core.int, HardwareModel> _byValue = $pb.ProtobufEnum.initByValue(values);
  static HardwareModel? valueOf($core.int value) => _byValue[value];

  const HardwareModel._($core.int v, $core.String n) : super(v, n);
}

class MeshPacket_Priority extends $pb.ProtobufEnum {
  static const MeshPacket_Priority UNSET = MeshPacket_Priority._(0, _omitEnumNames ? '' : 'UNSET');
  static const MeshPacket_Priority MIN = MeshPacket_Priority._(1, _omitEnumNames ? '' : 'MIN');
  static const MeshPacket_Priority BACKGROUND = MeshPacket_Priority._(10, _omitEnumNames ? '' : 'BACKGROUND');
  static const MeshPacket_Priority DEFAULT = MeshPacket_Priority._(64, _omitEnumNames ? '' : 'DEFAULT');
  static const MeshPacket_Priority RELIABLE = MeshPacket_Priority._(70, _omitEnumNames ? '' : 'RELIABLE');
  static const MeshPacket_Priority ACK = MeshPacket_Priority._(120, _omitEnumNames ? '' : 'ACK');
  static const MeshPacket_Priority MAX = MeshPacket_Priority._(127, _omitEnumNames ? '' : 'MAX');

  static const $core.List<MeshPacket_Priority> values = <MeshPacket_Priority> [
    UNSET,
    MIN,
    BACKGROUND,
    DEFAULT,
    RELIABLE,
    ACK,
    MAX,
  ];

  static final $core.Map<$core.int, MeshPacket_Priority> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MeshPacket_Priority? valueOf($core.int value) => _byValue[value];

  const MeshPacket_Priority._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
