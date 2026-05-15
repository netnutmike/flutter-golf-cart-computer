//
//  Generated code. Do not modify.
//  source: admin.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use adminMessageDescriptor instead')
const AdminMessage$json = {
  '1': 'AdminMessage',
  '2': [
    {'1': 'get_channel_request', '3': 1, '4': 1, '5': 13, '9': 0, '10': 'getChannelRequest'},
    {'1': 'get_channel_response', '3': 2, '4': 1, '5': 11, '6': '.meshtastic.Channel', '9': 0, '10': 'getChannelResponse'},
    {'1': 'get_owner_request', '3': 3, '4': 1, '5': 8, '9': 0, '10': 'getOwnerRequest'},
    {'1': 'get_config_request', '3': 5, '4': 1, '5': 14, '6': '.meshtastic.AdminMessage.ConfigType', '9': 0, '10': 'getConfigRequest'},
    {'1': 'get_config_response', '3': 6, '4': 1, '5': 11, '6': '.meshtastic.Config', '9': 0, '10': 'getConfigResponse'},
    {'1': 'get_module_config_request', '3': 7, '4': 1, '5': 14, '6': '.meshtastic.AdminMessage.ModuleConfigType', '9': 0, '10': 'getModuleConfigRequest'},
    {'1': 'get_module_config_response', '3': 8, '4': 1, '5': 11, '6': '.meshtastic.ModuleConfig', '9': 0, '10': 'getModuleConfigResponse'},
    {'1': 'set_config', '3': 10, '4': 1, '5': 11, '6': '.meshtastic.Config', '9': 0, '10': 'setConfig'},
    {'1': 'set_module_config', '3': 11, '4': 1, '5': 11, '6': '.meshtastic.ModuleConfig', '9': 0, '10': 'setModuleConfig'},
    {'1': 'set_channel', '3': 12, '4': 1, '5': 11, '6': '.meshtastic.Channel', '9': 0, '10': 'setChannel'},
    {'1': 'reboot_seconds', '3': 20, '4': 1, '5': 5, '9': 0, '10': 'rebootSeconds'},
    {'1': 'reboot_ota_seconds', '3': 21, '4': 1, '5': 5, '9': 0, '10': 'rebootOtaSeconds'},
    {'1': 'shutdown_seconds', '3': 22, '4': 1, '5': 5, '9': 0, '10': 'shutdownSeconds'},
    {'1': 'factory_reset', '3': 23, '4': 1, '5': 5, '9': 0, '10': 'factoryReset'},
    {'1': 'nodedb_reset', '3': 24, '4': 1, '5': 5, '9': 0, '10': 'nodedbReset'},
  ],
  '4': [AdminMessage_ConfigType$json, AdminMessage_ModuleConfigType$json],
  '8': [
    {'1': 'payload_variant'},
  ],
};

@$core.Deprecated('Use adminMessageDescriptor instead')
const AdminMessage_ConfigType$json = {
  '1': 'ConfigType',
  '2': [
    {'1': 'DEVICE_CONFIG', '2': 0},
    {'1': 'POSITION_CONFIG', '2': 1},
    {'1': 'POWER_CONFIG', '2': 2},
    {'1': 'NETWORK_CONFIG', '2': 3},
    {'1': 'DISPLAY_CONFIG', '2': 4},
    {'1': 'LORA_CONFIG', '2': 5},
    {'1': 'BLUETOOTH_CONFIG', '2': 6},
  ],
};

@$core.Deprecated('Use adminMessageDescriptor instead')
const AdminMessage_ModuleConfigType$json = {
  '1': 'ModuleConfigType',
  '2': [
    {'1': 'MQTT_CONFIG', '2': 0},
    {'1': 'SERIAL_CONFIG', '2': 1},
    {'1': 'EXTNOTIF_CONFIG', '2': 2},
    {'1': 'STOREFORWARD_CONFIG', '2': 3},
    {'1': 'RANGETEST_CONFIG', '2': 4},
    {'1': 'TELEMETRY_CONFIG', '2': 5},
    {'1': 'CANNEDMSG_CONFIG', '2': 6},
    {'1': 'AUDIO_CONFIG', '2': 7},
    {'1': 'REMOTEHARDWARE_CONFIG', '2': 8},
  ],
};

/// Descriptor for `AdminMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List adminMessageDescriptor = $convert.base64Decode(
    'CgxBZG1pbk1lc3NhZ2USMAoTZ2V0X2NoYW5uZWxfcmVxdWVzdBgBIAEoDUgAUhFnZXRDaGFubm'
    'VsUmVxdWVzdBJHChRnZXRfY2hhbm5lbF9yZXNwb25zZRgCIAEoCzITLm1lc2h0YXN0aWMuQ2hh'
    'bm5lbEgAUhJnZXRDaGFubmVsUmVzcG9uc2USLAoRZ2V0X293bmVyX3JlcXVlc3QYAyABKAhIAF'
    'IPZ2V0T3duZXJSZXF1ZXN0ElMKEmdldF9jb25maWdfcmVxdWVzdBgFIAEoDjIjLm1lc2h0YXN0'
    'aWMuQWRtaW5NZXNzYWdlLkNvbmZpZ1R5cGVIAFIQZ2V0Q29uZmlnUmVxdWVzdBJEChNnZXRfY2'
    '9uZmlnX3Jlc3BvbnNlGAYgASgLMhIubWVzaHRhc3RpYy5Db25maWdIAFIRZ2V0Q29uZmlnUmVz'
    'cG9uc2USZgoZZ2V0X21vZHVsZV9jb25maWdfcmVxdWVzdBgHIAEoDjIpLm1lc2h0YXN0aWMuQW'
    'RtaW5NZXNzYWdlLk1vZHVsZUNvbmZpZ1R5cGVIAFIWZ2V0TW9kdWxlQ29uZmlnUmVxdWVzdBJX'
    'ChpnZXRfbW9kdWxlX2NvbmZpZ19yZXNwb25zZRgIIAEoCzIYLm1lc2h0YXN0aWMuTW9kdWxlQ2'
    '9uZmlnSABSF2dldE1vZHVsZUNvbmZpZ1Jlc3BvbnNlEjMKCnNldF9jb25maWcYCiABKAsyEi5t'
    'ZXNodGFzdGljLkNvbmZpZ0gAUglzZXRDb25maWcSRgoRc2V0X21vZHVsZV9jb25maWcYCyABKA'
    'syGC5tZXNodGFzdGljLk1vZHVsZUNvbmZpZ0gAUg9zZXRNb2R1bGVDb25maWcSNgoLc2V0X2No'
    'YW5uZWwYDCABKAsyEy5tZXNodGFzdGljLkNoYW5uZWxIAFIKc2V0Q2hhbm5lbBInCg5yZWJvb3'
    'Rfc2Vjb25kcxgUIAEoBUgAUg1yZWJvb3RTZWNvbmRzEi4KEnJlYm9vdF9vdGFfc2Vjb25kcxgV'
    'IAEoBUgAUhByZWJvb3RPdGFTZWNvbmRzEisKEHNodXRkb3duX3NlY29uZHMYFiABKAVIAFIPc2'
    'h1dGRvd25TZWNvbmRzEiUKDWZhY3RvcnlfcmVzZXQYFyABKAVIAFIMZmFjdG9yeVJlc2V0EiMK'
    'DG5vZGVkYl9yZXNldBgYIAEoBUgAUgtub2RlZGJSZXNldCKVAQoKQ29uZmlnVHlwZRIRCg1ERV'
    'ZJQ0VfQ09ORklHEAASEwoPUE9TSVRJT05fQ09ORklHEAESEAoMUE9XRVJfQ09ORklHEAISEgoO'
    'TkVUV09SS19DT05GSUcQAxISCg5ESVNQTEFZX0NPTkZJRxAEEg8KC0xPUkFfQ09ORklHEAUSFA'
    'oQQkxVRVRPT1RIX0NPTkZJRxAGItMBChBNb2R1bGVDb25maWdUeXBlEg8KC01RVFRfQ09ORklH'
    'EAASEQoNU0VSSUFMX0NPTkZJRxABEhMKD0VYVE5PVElGX0NPTkZJRxACEhcKE1NUT1JFRk9SV0'
    'FSRF9DT05GSUcQAxIUChBSQU5HRVRFU1RfQ09ORklHEAQSFAoQVEVMRU1FVFJZX0NPTkZJRxAF'
    'EhQKEENBTk5FRE1TR19DT05GSUcQBhIQCgxBVURJT19DT05GSUcQBxIZChVSRU1PVEVIQVJEV0'
    'FSRV9DT05GSUcQCEIRCg9wYXlsb2FkX3ZhcmlhbnQ=');

