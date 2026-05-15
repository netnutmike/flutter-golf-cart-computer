//
//  Generated code. Do not modify.
//  source: mesh.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use hardwareModelDescriptor instead')
const HardwareModel$json = {
  '1': 'HardwareModel',
  '2': [
    {'1': 'UNSET', '2': 0},
    {'1': 'TLORA_V2', '2': 1},
    {'1': 'TLORA_V1', '2': 2},
    {'1': 'TLORA_V2_1_1P6', '2': 3},
    {'1': 'TBEAM', '2': 4},
    {'1': 'HELTEC_V2_0', '2': 5},
    {'1': 'TBEAM_V0P7', '2': 6},
    {'1': 'T_ECHO', '2': 7},
    {'1': 'TLORA_V1_1P3', '2': 8},
    {'1': 'RAK4631', '2': 9},
    {'1': 'HELTEC_V2_1', '2': 10},
    {'1': 'HELTEC_V1', '2': 11},
    {'1': 'LILYGO_TBEAM_S3_CORE', '2': 12},
    {'1': 'RAK11200', '2': 13},
    {'1': 'NANO_G1', '2': 14},
    {'1': 'STATION_G1', '2': 25},
    {'1': 'LORA_RELAY_V1', '2': 32},
    {'1': 'NRF52840DK', '2': 33},
    {'1': 'PPR', '2': 34},
    {'1': 'GENIEBLOCKS', '2': 35},
    {'1': 'NRF52_UNKNOWN', '2': 36},
    {'1': 'PORTDUINO', '2': 37},
    {'1': 'ANDROID_SIM', '2': 38},
    {'1': 'DIY_V1', '2': 39},
    {'1': 'NRF52840_PCA10059', '2': 40},
    {'1': 'PRIVATE_HW', '2': 255},
  ],
};

/// Descriptor for `HardwareModel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List hardwareModelDescriptor = $convert.base64Decode(
    'Cg1IYXJkd2FyZU1vZGVsEgkKBVVOU0VUEAASDAoIVExPUkFfVjIQARIMCghUTE9SQV9WMRACEh'
    'IKDlRMT1JBX1YyXzFfMVA2EAMSCQoFVEJFQU0QBBIPCgtIRUxURUNfVjJfMBAFEg4KClRCRUFN'
    'X1YwUDcQBhIKCgZUX0VDSE8QBxIQCgxUTE9SQV9WMV8xUDMQCBILCgdSQUs0NjMxEAkSDwoLSE'
    'VMVEVDX1YyXzEQChINCglIRUxURUNfVjEQCxIYChRMSUxZR09fVEJFQU1fUzNfQ09SRRAMEgwK'
    'CFJBSzExMjAwEA0SCwoHTkFOT19HMRAOEg4KClNUQVRJT05fRzEQGRIRCg1MT1JBX1JFTEFZX1'
    'YxECASDgoKTlJGNTI4NDBESxAhEgcKA1BQUhAiEg8KC0dFTklFQkxPQ0tTECMSEQoNTlJGNTJf'
    'VU5LTk9XThAkEg0KCVBPUlREVUlOTxAlEg8KC0FORFJPSURfU0lNECYSCgoGRElZX1YxECcSFQ'
    'oRTlJGNTI4NDBfUENBMTAwNTkQKBIPCgpQUklWQVRFX0hXEP8B');

@$core.Deprecated('Use positionDescriptor instead')
const Position$json = {
  '1': 'Position',
  '2': [
    {'1': 'latitude_i', '3': 1, '4': 1, '5': 15, '10': 'latitudeI'},
    {'1': 'longitude_i', '3': 2, '4': 1, '5': 15, '10': 'longitudeI'},
    {'1': 'altitude', '3': 3, '4': 1, '5': 5, '10': 'altitude'},
    {'1': 'time', '3': 4, '4': 1, '5': 7, '10': 'time'},
    {'1': 'ground_speed', '3': 5, '4': 1, '5': 13, '10': 'groundSpeed'},
    {'1': 'ground_track', '3': 6, '4': 1, '5': 13, '10': 'groundTrack'},
    {'1': 'sats_in_view', '3': 7, '4': 1, '5': 13, '10': 'satsInView'},
    {'1': 'precision_bits', '3': 8, '4': 1, '5': 13, '10': 'precisionBits'},
  ],
};

/// Descriptor for `Position`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positionDescriptor = $convert.base64Decode(
    'CghQb3NpdGlvbhIdCgpsYXRpdHVkZV9pGAEgASgPUglsYXRpdHVkZUkSHwoLbG9uZ2l0dWRlX2'
    'kYAiABKA9SCmxvbmdpdHVkZUkSGgoIYWx0aXR1ZGUYAyABKAVSCGFsdGl0dWRlEhIKBHRpbWUY'
    'BCABKAdSBHRpbWUSIQoMZ3JvdW5kX3NwZWVkGAUgASgNUgtncm91bmRTcGVlZBIhCgxncm91bm'
    'RfdHJhY2sYBiABKA1SC2dyb3VuZFRyYWNrEiAKDHNhdHNfaW5fdmlldxgHIAEoDVIKc2F0c0lu'
    'VmlldxIlCg5wcmVjaXNpb25fYml0cxgIIAEoDVINcHJlY2lzaW9uQml0cw==');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'long_name', '3': 2, '4': 1, '5': 9, '10': 'longName'},
    {'1': 'short_name', '3': 3, '4': 1, '5': 9, '10': 'shortName'},
    {'1': 'macaddr', '3': 4, '4': 1, '5': 12, '10': 'macaddr'},
    {'1': 'hw_model', '3': 5, '4': 1, '5': 14, '6': '.meshtastic.HardwareModel', '10': 'hwModel'},
    {'1': 'is_licensed', '3': 6, '4': 1, '5': 8, '10': 'isLicensed'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEg4KAmlkGAEgASgJUgJpZBIbCglsb25nX25hbWUYAiABKAlSCGxvbmdOYW1lEh0KCn'
    'Nob3J0X25hbWUYAyABKAlSCXNob3J0TmFtZRIYCgdtYWNhZGRyGAQgASgMUgdtYWNhZGRyEjQK'
    'CGh3X21vZGVsGAUgASgOMhkubWVzaHRhc3RpYy5IYXJkd2FyZU1vZGVsUgdod01vZGVsEh8KC2'
    'lzX2xpY2Vuc2VkGAYgASgIUgppc0xpY2Vuc2Vk');

@$core.Deprecated('Use dataDescriptor instead')
const Data$json = {
  '1': 'Data',
  '2': [
    {'1': 'portnum', '3': 1, '4': 1, '5': 14, '6': '.meshtastic.PortNum', '10': 'portnum'},
    {'1': 'payload', '3': 2, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'want_response', '3': 3, '4': 1, '5': 8, '10': 'wantResponse'},
    {'1': 'dest', '3': 4, '4': 1, '5': 7, '10': 'dest'},
    {'1': 'source', '3': 5, '4': 1, '5': 7, '10': 'source'},
    {'1': 'request_id', '3': 6, '4': 1, '5': 7, '10': 'requestId'},
    {'1': 'reply_id', '3': 7, '4': 1, '5': 7, '10': 'replyId'},
    {'1': 'emoji', '3': 8, '4': 1, '5': 7, '10': 'emoji'},
  ],
};

/// Descriptor for `Data`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dataDescriptor = $convert.base64Decode(
    'CgREYXRhEi0KB3BvcnRudW0YASABKA4yEy5tZXNodGFzdGljLlBvcnROdW1SB3BvcnRudW0SGA'
    'oHcGF5bG9hZBgCIAEoDFIHcGF5bG9hZBIjCg13YW50X3Jlc3BvbnNlGAMgASgIUgx3YW50UmVz'
    'cG9uc2USEgoEZGVzdBgEIAEoB1IEZGVzdBIWCgZzb3VyY2UYBSABKAdSBnNvdXJjZRIdCgpyZX'
    'F1ZXN0X2lkGAYgASgHUglyZXF1ZXN0SWQSGQoIcmVwbHlfaWQYByABKAdSB3JlcGx5SWQSFAoF'
    'ZW1vamkYCCABKAdSBWVtb2pp');

@$core.Deprecated('Use meshPacketDescriptor instead')
const MeshPacket$json = {
  '1': 'MeshPacket',
  '2': [
    {'1': 'from', '3': 1, '4': 1, '5': 7, '10': 'from'},
    {'1': 'to', '3': 2, '4': 1, '5': 7, '10': 'to'},
    {'1': 'channel', '3': 3, '4': 1, '5': 13, '10': 'channel'},
    {'1': 'decoded', '3': 4, '4': 1, '5': 11, '6': '.meshtastic.Data', '9': 0, '10': 'decoded'},
    {'1': 'encrypted', '3': 5, '4': 1, '5': 12, '9': 0, '10': 'encrypted'},
    {'1': 'id', '3': 6, '4': 1, '5': 7, '10': 'id'},
    {'1': 'rx_time', '3': 7, '4': 1, '5': 7, '10': 'rxTime'},
    {'1': 'rx_snr', '3': 8, '4': 1, '5': 2, '10': 'rxSnr'},
    {'1': 'hop_limit', '3': 9, '4': 1, '5': 13, '10': 'hopLimit'},
    {'1': 'want_ack', '3': 10, '4': 1, '5': 8, '10': 'wantAck'},
    {'1': 'priority', '3': 11, '4': 1, '5': 14, '6': '.meshtastic.MeshPacket.Priority', '10': 'priority'},
    {'1': 'rx_rssi', '3': 12, '4': 1, '5': 5, '10': 'rxRssi'},
  ],
  '4': [MeshPacket_Priority$json],
  '8': [
    {'1': 'payload_variant'},
  ],
};

@$core.Deprecated('Use meshPacketDescriptor instead')
const MeshPacket_Priority$json = {
  '1': 'Priority',
  '2': [
    {'1': 'UNSET', '2': 0},
    {'1': 'MIN', '2': 1},
    {'1': 'BACKGROUND', '2': 10},
    {'1': 'DEFAULT', '2': 64},
    {'1': 'RELIABLE', '2': 70},
    {'1': 'ACK', '2': 120},
    {'1': 'MAX', '2': 127},
  ],
};

/// Descriptor for `MeshPacket`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meshPacketDescriptor = $convert.base64Decode(
    'CgpNZXNoUGFja2V0EhIKBGZyb20YASABKAdSBGZyb20SDgoCdG8YAiABKAdSAnRvEhgKB2NoYW'
    '5uZWwYAyABKA1SB2NoYW5uZWwSLAoHZGVjb2RlZBgEIAEoCzIQLm1lc2h0YXN0aWMuRGF0YUgA'
    'UgdkZWNvZGVkEh4KCWVuY3J5cHRlZBgFIAEoDEgAUgllbmNyeXB0ZWQSDgoCaWQYBiABKAdSAm'
    'lkEhcKB3J4X3RpbWUYByABKAdSBnJ4VGltZRIVCgZyeF9zbnIYCCABKAJSBXJ4U25yEhsKCWhv'
    'cF9saW1pdBgJIAEoDVIIaG9wTGltaXQSGQoId2FudF9hY2sYCiABKAhSB3dhbnRBY2sSOwoIcH'
    'Jpb3JpdHkYCyABKA4yHy5tZXNodGFzdGljLk1lc2hQYWNrZXQuUHJpb3JpdHlSCHByaW9yaXR5'
    'EhcKB3J4X3Jzc2kYDCABKAVSBnJ4UnNzaSJbCghQcmlvcml0eRIJCgVVTlNFVBAAEgcKA01JTh'
    'ABEg4KCkJBQ0tHUk9VTkQQChILCgdERUZBVUxUEEASDAoIUkVMSUFCTEUQRhIHCgNBQ0sQeBIH'
    'CgNNQVgQf0IRCg9wYXlsb2FkX3ZhcmlhbnQ=');

@$core.Deprecated('Use myNodeInfoDescriptor instead')
const MyNodeInfo$json = {
  '1': 'MyNodeInfo',
  '2': [
    {'1': 'my_node_num', '3': 1, '4': 1, '5': 13, '10': 'myNodeNum'},
    {'1': 'firmware_version', '3': 2, '4': 1, '5': 9, '10': 'firmwareVersion'},
    {'1': 'reboot_count', '3': 3, '4': 1, '5': 13, '10': 'rebootCount'},
    {'1': 'min_app_version', '3': 4, '4': 1, '5': 13, '10': 'minAppVersion'},
  ],
};

/// Descriptor for `MyNodeInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List myNodeInfoDescriptor = $convert.base64Decode(
    'CgpNeU5vZGVJbmZvEh4KC215X25vZGVfbnVtGAEgASgNUglteU5vZGVOdW0SKQoQZmlybXdhcm'
    'VfdmVyc2lvbhgCIAEoCVIPZmlybXdhcmVWZXJzaW9uEiEKDHJlYm9vdF9jb3VudBgDIAEoDVIL'
    'cmVib290Q291bnQSJgoPbWluX2FwcF92ZXJzaW9uGAQgASgNUg1taW5BcHBWZXJzaW9u');

@$core.Deprecated('Use nodeInfoDescriptor instead')
const NodeInfo$json = {
  '1': 'NodeInfo',
  '2': [
    {'1': 'num', '3': 1, '4': 1, '5': 13, '10': 'num'},
    {'1': 'user', '3': 2, '4': 1, '5': 11, '6': '.meshtastic.User', '10': 'user'},
    {'1': 'position', '3': 3, '4': 1, '5': 11, '6': '.meshtastic.Position', '10': 'position'},
    {'1': 'snr', '3': 4, '4': 1, '5': 2, '10': 'snr'},
    {'1': 'last_heard', '3': 5, '4': 1, '5': 7, '10': 'lastHeard'},
    {'1': 'device_metrics', '3': 6, '4': 1, '5': 11, '6': '.meshtastic.DeviceMetrics', '10': 'deviceMetrics'},
  ],
};

/// Descriptor for `NodeInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeInfoDescriptor = $convert.base64Decode(
    'CghOb2RlSW5mbxIQCgNudW0YASABKA1SA251bRIkCgR1c2VyGAIgASgLMhAubWVzaHRhc3RpYy'
    '5Vc2VyUgR1c2VyEjAKCHBvc2l0aW9uGAMgASgLMhQubWVzaHRhc3RpYy5Qb3NpdGlvblIIcG9z'
    'aXRpb24SEAoDc25yGAQgASgCUgNzbnISHQoKbGFzdF9oZWFyZBgFIAEoB1IJbGFzdEhlYXJkEk'
    'AKDmRldmljZV9tZXRyaWNzGAYgASgLMhkubWVzaHRhc3RpYy5EZXZpY2VNZXRyaWNzUg1kZXZp'
    'Y2VNZXRyaWNz');

@$core.Deprecated('Use toRadioDescriptor instead')
const ToRadio$json = {
  '1': 'ToRadio',
  '2': [
    {'1': 'packet', '3': 1, '4': 1, '5': 11, '6': '.meshtastic.MeshPacket', '9': 0, '10': 'packet'},
    {'1': 'want_config_id', '3': 3, '4': 1, '5': 13, '9': 0, '10': 'wantConfigId'},
    {'1': 'disconnect', '3': 4, '4': 1, '5': 8, '9': 0, '10': 'disconnect'},
  ],
  '8': [
    {'1': 'payload_variant'},
  ],
};

/// Descriptor for `ToRadio`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List toRadioDescriptor = $convert.base64Decode(
    'CgdUb1JhZGlvEjAKBnBhY2tldBgBIAEoCzIWLm1lc2h0YXN0aWMuTWVzaFBhY2tldEgAUgZwYW'
    'NrZXQSJgoOd2FudF9jb25maWdfaWQYAyABKA1IAFIMd2FudENvbmZpZ0lkEiAKCmRpc2Nvbm5l'
    'Y3QYBCABKAhIAFIKZGlzY29ubmVjdEIRCg9wYXlsb2FkX3ZhcmlhbnQ=');

@$core.Deprecated('Use fromRadioDescriptor instead')
const FromRadio$json = {
  '1': 'FromRadio',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'packet', '3': 2, '4': 1, '5': 11, '6': '.meshtastic.MeshPacket', '9': 0, '10': 'packet'},
    {'1': 'my_info', '3': 3, '4': 1, '5': 11, '6': '.meshtastic.MyNodeInfo', '9': 0, '10': 'myInfo'},
    {'1': 'node_info', '3': 4, '4': 1, '5': 11, '6': '.meshtastic.NodeInfo', '9': 0, '10': 'nodeInfo'},
    {'1': 'config', '3': 5, '4': 1, '5': 11, '6': '.meshtastic.Config', '9': 0, '10': 'config'},
    {'1': 'moduleConfig', '3': 6, '4': 1, '5': 11, '6': '.meshtastic.ModuleConfig', '9': 0, '10': 'moduleConfig'},
    {'1': 'channel', '3': 7, '4': 1, '5': 11, '6': '.meshtastic.Channel', '9': 0, '10': 'channel'},
    {'1': 'config_complete_id', '3': 8, '4': 1, '5': 13, '9': 0, '10': 'configCompleteId'},
  ],
  '8': [
    {'1': 'payload_variant'},
  ],
};

/// Descriptor for `FromRadio`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fromRadioDescriptor = $convert.base64Decode(
    'CglGcm9tUmFkaW8SDgoCaWQYASABKA1SAmlkEjAKBnBhY2tldBgCIAEoCzIWLm1lc2h0YXN0aW'
    'MuTWVzaFBhY2tldEgAUgZwYWNrZXQSMQoHbXlfaW5mbxgDIAEoCzIWLm1lc2h0YXN0aWMuTXlO'
    'b2RlSW5mb0gAUgZteUluZm8SMwoJbm9kZV9pbmZvGAQgASgLMhQubWVzaHRhc3RpYy5Ob2RlSW'
    '5mb0gAUghub2RlSW5mbxIsCgZjb25maWcYBSABKAsyEi5tZXNodGFzdGljLkNvbmZpZ0gAUgZj'
    'b25maWcSPgoMbW9kdWxlQ29uZmlnGAYgASgLMhgubWVzaHRhc3RpYy5Nb2R1bGVDb25maWdIAF'
    'IMbW9kdWxlQ29uZmlnEi8KB2NoYW5uZWwYByABKAsyEy5tZXNodGFzdGljLkNoYW5uZWxIAFIH'
    'Y2hhbm5lbBIuChJjb25maWdfY29tcGxldGVfaWQYCCABKA1IAFIQY29uZmlnQ29tcGxldGVJZE'
    'IRCg9wYXlsb2FkX3ZhcmlhbnQ=');

