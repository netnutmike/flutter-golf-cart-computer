//
//  Generated code. Do not modify.
//  source: config.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use configDescriptor instead')
const Config$json = {
  '1': 'Config',
  '2': [
    {'1': 'device', '3': 1, '4': 1, '5': 11, '6': '.meshtastic.Config.DeviceConfig', '9': 0, '10': 'device'},
    {'1': 'position', '3': 2, '4': 1, '5': 11, '6': '.meshtastic.Config.PositionConfig', '9': 0, '10': 'position'},
    {'1': 'power', '3': 3, '4': 1, '5': 11, '6': '.meshtastic.Config.PowerConfig', '9': 0, '10': 'power'},
    {'1': 'network', '3': 4, '4': 1, '5': 11, '6': '.meshtastic.Config.NetworkConfig', '9': 0, '10': 'network'},
    {'1': 'display', '3': 5, '4': 1, '5': 11, '6': '.meshtastic.Config.DisplayConfig', '9': 0, '10': 'display'},
    {'1': 'lora', '3': 6, '4': 1, '5': 11, '6': '.meshtastic.Config.LoRaConfig', '9': 0, '10': 'lora'},
    {'1': 'bluetooth', '3': 7, '4': 1, '5': 11, '6': '.meshtastic.Config.BluetoothConfig', '9': 0, '10': 'bluetooth'},
  ],
  '3': [Config_DeviceConfig$json, Config_PositionConfig$json, Config_PowerConfig$json, Config_NetworkConfig$json, Config_DisplayConfig$json, Config_LoRaConfig$json, Config_BluetoothConfig$json],
  '8': [
    {'1': 'payload_variant'},
  ],
};

@$core.Deprecated('Use configDescriptor instead')
const Config_DeviceConfig$json = {
  '1': 'DeviceConfig',
  '2': [
    {'1': 'role', '3': 1, '4': 1, '5': 14, '6': '.meshtastic.Config.DeviceConfig.Role', '10': 'role'},
    {'1': 'serial_enabled', '3': 2, '4': 1, '5': 8, '10': 'serialEnabled'},
    {'1': 'debug_log_enabled', '3': 3, '4': 1, '5': 8, '10': 'debugLogEnabled'},
    {'1': 'button_gpio', '3': 4, '4': 1, '5': 13, '10': 'buttonGpio'},
    {'1': 'buzzer_gpio', '3': 5, '4': 1, '5': 13, '10': 'buzzerGpio'},
  ],
  '4': [Config_DeviceConfig_Role$json],
};

@$core.Deprecated('Use configDescriptor instead')
const Config_DeviceConfig_Role$json = {
  '1': 'Role',
  '2': [
    {'1': 'CLIENT', '2': 0},
    {'1': 'CLIENT_MUTE', '2': 1},
    {'1': 'ROUTER', '2': 2},
    {'1': 'ROUTER_CLIENT', '2': 3},
  ],
};

@$core.Deprecated('Use configDescriptor instead')
const Config_PositionConfig$json = {
  '1': 'PositionConfig',
  '2': [
    {'1': 'position_broadcast_secs', '3': 1, '4': 1, '5': 13, '10': 'positionBroadcastSecs'},
    {'1': 'position_broadcast_smart_enabled', '3': 2, '4': 1, '5': 8, '10': 'positionBroadcastSmartEnabled'},
    {'1': 'fixed_position', '3': 3, '4': 1, '5': 8, '10': 'fixedPosition'},
    {'1': 'gps_enabled', '3': 4, '4': 1, '5': 8, '10': 'gpsEnabled'},
    {'1': 'gps_update_interval', '3': 5, '4': 1, '5': 13, '10': 'gpsUpdateInterval'},
    {'1': 'gps_attempt_time', '3': 6, '4': 1, '5': 13, '10': 'gpsAttemptTime'},
    {'1': 'position_flags', '3': 7, '4': 1, '5': 13, '10': 'positionFlags'},
    {'1': 'rx_gpio', '3': 8, '4': 1, '5': 13, '10': 'rxGpio'},
    {'1': 'tx_gpio', '3': 9, '4': 1, '5': 13, '10': 'txGpio'},
    {'1': 'broadcast_smart_minimum_distance', '3': 10, '4': 1, '5': 13, '10': 'broadcastSmartMinimumDistance'},
    {'1': 'broadcast_smart_minimum_interval_secs', '3': 11, '4': 1, '5': 13, '10': 'broadcastSmartMinimumIntervalSecs'},
  ],
};

@$core.Deprecated('Use configDescriptor instead')
const Config_PowerConfig$json = {
  '1': 'PowerConfig',
  '2': [
    {'1': 'is_power_saving', '3': 1, '4': 1, '5': 8, '10': 'isPowerSaving'},
    {'1': 'on_battery_shutdown_after_secs', '3': 2, '4': 1, '5': 13, '10': 'onBatteryShutdownAfterSecs'},
    {'1': 'adc_multiplier_override', '3': 3, '4': 1, '5': 2, '10': 'adcMultiplierOverride'},
    {'1': 'wait_bluetooth_secs', '3': 4, '4': 1, '5': 13, '10': 'waitBluetoothSecs'},
    {'1': 'sds_secs', '3': 5, '4': 1, '5': 13, '10': 'sdsSecs'},
    {'1': 'ls_secs', '3': 6, '4': 1, '5': 13, '10': 'lsSecs'},
    {'1': 'min_wake_secs', '3': 7, '4': 1, '5': 13, '10': 'minWakeSecs'},
  ],
};

@$core.Deprecated('Use configDescriptor instead')
const Config_NetworkConfig$json = {
  '1': 'NetworkConfig',
  '2': [
    {'1': 'wifi_enabled', '3': 1, '4': 1, '5': 8, '10': 'wifiEnabled'},
    {'1': 'wifi_ssid', '3': 2, '4': 1, '5': 9, '10': 'wifiSsid'},
    {'1': 'wifi_psk', '3': 3, '4': 1, '5': 9, '10': 'wifiPsk'},
    {'1': 'ntp_server', '3': 4, '4': 1, '5': 9, '10': 'ntpServer'},
  ],
};

@$core.Deprecated('Use configDescriptor instead')
const Config_DisplayConfig$json = {
  '1': 'DisplayConfig',
  '2': [
    {'1': 'screen_on_secs', '3': 1, '4': 1, '5': 13, '10': 'screenOnSecs'},
    {'1': 'gps_format', '3': 2, '4': 1, '5': 14, '6': '.meshtastic.Config.DisplayConfig.GpsCoordinateFormat', '10': 'gpsFormat'},
    {'1': 'compass_north_top', '3': 3, '4': 1, '5': 8, '10': 'compassNorthTop'},
    {'1': 'flip_screen', '3': 4, '4': 1, '5': 8, '10': 'flipScreen'},
    {'1': 'units', '3': 5, '4': 1, '5': 14, '6': '.meshtastic.Config.DisplayConfig.DisplayUnits', '10': 'units'},
  ],
  '4': [Config_DisplayConfig_GpsCoordinateFormat$json, Config_DisplayConfig_DisplayUnits$json],
};

@$core.Deprecated('Use configDescriptor instead')
const Config_DisplayConfig_GpsCoordinateFormat$json = {
  '1': 'GpsCoordinateFormat',
  '2': [
    {'1': 'DEC', '2': 0},
    {'1': 'DMS', '2': 1},
    {'1': 'UTM', '2': 2},
    {'1': 'MGRS', '2': 3},
    {'1': 'OLC', '2': 4},
    {'1': 'OSGR', '2': 5},
  ],
};

@$core.Deprecated('Use configDescriptor instead')
const Config_DisplayConfig_DisplayUnits$json = {
  '1': 'DisplayUnits',
  '2': [
    {'1': 'METRIC', '2': 0},
    {'1': 'IMPERIAL', '2': 1},
  ],
};

@$core.Deprecated('Use configDescriptor instead')
const Config_LoRaConfig$json = {
  '1': 'LoRaConfig',
  '2': [
    {'1': 'region', '3': 1, '4': 1, '5': 13, '10': 'region'},
    {'1': 'use_preset', '3': 2, '4': 1, '5': 8, '10': 'usePreset'},
    {'1': 'modem_preset', '3': 3, '4': 1, '5': 14, '6': '.meshtastic.Config.LoRaConfig.ModemPreset', '10': 'modemPreset'},
    {'1': 'bandwidth', '3': 4, '4': 1, '5': 13, '10': 'bandwidth'},
    {'1': 'spread_factor', '3': 5, '4': 1, '5': 13, '10': 'spreadFactor'},
    {'1': 'coding_rate', '3': 6, '4': 1, '5': 13, '10': 'codingRate'},
    {'1': 'frequency_offset', '3': 7, '4': 1, '5': 2, '10': 'frequencyOffset'},
    {'1': 'hop_limit', '3': 8, '4': 1, '5': 13, '10': 'hopLimit'},
    {'1': 'tx_enabled', '3': 9, '4': 1, '5': 8, '10': 'txEnabled'},
    {'1': 'tx_power', '3': 10, '4': 1, '5': 5, '10': 'txPower'},
    {'1': 'channel_num', '3': 11, '4': 1, '5': 13, '10': 'channelNum'},
  ],
  '4': [Config_LoRaConfig_ModemPreset$json],
};

@$core.Deprecated('Use configDescriptor instead')
const Config_LoRaConfig_ModemPreset$json = {
  '1': 'ModemPreset',
  '2': [
    {'1': 'LONG_FAST', '2': 0},
    {'1': 'LONG_SLOW', '2': 1},
    {'1': 'VERY_LONG_SLOW', '2': 2},
    {'1': 'MEDIUM_SLOW', '2': 3},
    {'1': 'MEDIUM_FAST', '2': 4},
    {'1': 'SHORT_SLOW', '2': 5},
    {'1': 'SHORT_FAST', '2': 6},
  ],
};

@$core.Deprecated('Use configDescriptor instead')
const Config_BluetoothConfig$json = {
  '1': 'BluetoothConfig',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'mode', '3': 2, '4': 1, '5': 14, '6': '.meshtastic.Config.BluetoothConfig.PairingMode', '10': 'mode'},
    {'1': 'fixed_pin', '3': 3, '4': 1, '5': 13, '10': 'fixedPin'},
  ],
  '4': [Config_BluetoothConfig_PairingMode$json],
};

@$core.Deprecated('Use configDescriptor instead')
const Config_BluetoothConfig_PairingMode$json = {
  '1': 'PairingMode',
  '2': [
    {'1': 'RANDOM_PIN', '2': 0},
    {'1': 'FIXED_PIN', '2': 1},
    {'1': 'NO_PIN', '2': 2},
  ],
};

/// Descriptor for `Config`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configDescriptor = $convert.base64Decode(
    'CgZDb25maWcSOQoGZGV2aWNlGAEgASgLMh8ubWVzaHRhc3RpYy5Db25maWcuRGV2aWNlQ29uZm'
    'lnSABSBmRldmljZRI/Cghwb3NpdGlvbhgCIAEoCzIhLm1lc2h0YXN0aWMuQ29uZmlnLlBvc2l0'
    'aW9uQ29uZmlnSABSCHBvc2l0aW9uEjYKBXBvd2VyGAMgASgLMh4ubWVzaHRhc3RpYy5Db25maW'
    'cuUG93ZXJDb25maWdIAFIFcG93ZXISPAoHbmV0d29yaxgEIAEoCzIgLm1lc2h0YXN0aWMuQ29u'
    'ZmlnLk5ldHdvcmtDb25maWdIAFIHbmV0d29yaxI8CgdkaXNwbGF5GAUgASgLMiAubWVzaHRhc3'
    'RpYy5Db25maWcuRGlzcGxheUNvbmZpZ0gAUgdkaXNwbGF5EjMKBGxvcmEYBiABKAsyHS5tZXNo'
    'dGFzdGljLkNvbmZpZy5Mb1JhQ29uZmlnSABSBGxvcmESQgoJYmx1ZXRvb3RoGAcgASgLMiIubW'
    'VzaHRhc3RpYy5Db25maWcuQmx1ZXRvb3RoQ29uZmlnSABSCWJsdWV0b290aBqhAgoMRGV2aWNl'
    'Q29uZmlnEjgKBHJvbGUYASABKA4yJC5tZXNodGFzdGljLkNvbmZpZy5EZXZpY2VDb25maWcuUm'
    '9sZVIEcm9sZRIlCg5zZXJpYWxfZW5hYmxlZBgCIAEoCFINc2VyaWFsRW5hYmxlZBIqChFkZWJ1'
    'Z19sb2dfZW5hYmxlZBgDIAEoCFIPZGVidWdMb2dFbmFibGVkEh8KC2J1dHRvbl9ncGlvGAQgAS'
    'gNUgpidXR0b25HcGlvEh8KC2J1enplcl9ncGlvGAUgASgNUgpidXp6ZXJHcGlvIkIKBFJvbGUS'
    'CgoGQ0xJRU5UEAASDwoLQ0xJRU5UX01VVEUQARIKCgZST1VURVIQAhIRCg1ST1VURVJfQ0xJRU'
    '5UEAMapwQKDlBvc2l0aW9uQ29uZmlnEjYKF3Bvc2l0aW9uX2Jyb2FkY2FzdF9zZWNzGAEgASgN'
    'UhVwb3NpdGlvbkJyb2FkY2FzdFNlY3MSRwogcG9zaXRpb25fYnJvYWRjYXN0X3NtYXJ0X2VuYW'
    'JsZWQYAiABKAhSHXBvc2l0aW9uQnJvYWRjYXN0U21hcnRFbmFibGVkEiUKDmZpeGVkX3Bvc2l0'
    'aW9uGAMgASgIUg1maXhlZFBvc2l0aW9uEh8KC2dwc19lbmFibGVkGAQgASgIUgpncHNFbmFibG'
    'VkEi4KE2dwc191cGRhdGVfaW50ZXJ2YWwYBSABKA1SEWdwc1VwZGF0ZUludGVydmFsEigKEGdw'
    'c19hdHRlbXB0X3RpbWUYBiABKA1SDmdwc0F0dGVtcHRUaW1lEiUKDnBvc2l0aW9uX2ZsYWdzGA'
    'cgASgNUg1wb3NpdGlvbkZsYWdzEhcKB3J4X2dwaW8YCCABKA1SBnJ4R3BpbxIXCgd0eF9ncGlv'
    'GAkgASgNUgZ0eEdwaW8SRwogYnJvYWRjYXN0X3NtYXJ0X21pbmltdW1fZGlzdGFuY2UYCiABKA'
    '1SHWJyb2FkY2FzdFNtYXJ0TWluaW11bURpc3RhbmNlElAKJWJyb2FkY2FzdF9zbWFydF9taW5p'
    'bXVtX2ludGVydmFsX3NlY3MYCyABKA1SIWJyb2FkY2FzdFNtYXJ0TWluaW11bUludGVydmFsU2'
    'Vjcxq5AgoLUG93ZXJDb25maWcSJgoPaXNfcG93ZXJfc2F2aW5nGAEgASgIUg1pc1Bvd2VyU2F2'
    'aW5nEkIKHm9uX2JhdHRlcnlfc2h1dGRvd25fYWZ0ZXJfc2VjcxgCIAEoDVIab25CYXR0ZXJ5U2'
    'h1dGRvd25BZnRlclNlY3MSNgoXYWRjX211bHRpcGxpZXJfb3ZlcnJpZGUYAyABKAJSFWFkY011'
    'bHRpcGxpZXJPdmVycmlkZRIuChN3YWl0X2JsdWV0b290aF9zZWNzGAQgASgNUhF3YWl0Qmx1ZX'
    'Rvb3RoU2VjcxIZCghzZHNfc2VjcxgFIAEoDVIHc2RzU2VjcxIXCgdsc19zZWNzGAYgASgNUgZs'
    'c1NlY3MSIgoNbWluX3dha2Vfc2VjcxgHIAEoDVILbWluV2FrZVNlY3MaiQEKDU5ldHdvcmtDb2'
    '5maWcSIQoMd2lmaV9lbmFibGVkGAEgASgIUgt3aWZpRW5hYmxlZBIbCgl3aWZpX3NzaWQYAiAB'
    'KAlSCHdpZmlTc2lkEhkKCHdpZmlfcHNrGAMgASgJUgd3aWZpUHNrEh0KCm50cF9zZXJ2ZXIYBC'
    'ABKAlSCW50cFNlcnZlchqVAwoNRGlzcGxheUNvbmZpZxIkCg5zY3JlZW5fb25fc2VjcxgBIAEo'
    'DVIMc2NyZWVuT25TZWNzElMKCmdwc19mb3JtYXQYAiABKA4yNC5tZXNodGFzdGljLkNvbmZpZy'
    '5EaXNwbGF5Q29uZmlnLkdwc0Nvb3JkaW5hdGVGb3JtYXRSCWdwc0Zvcm1hdBIqChFjb21wYXNz'
    'X25vcnRoX3RvcBgDIAEoCFIPY29tcGFzc05vcnRoVG9wEh8KC2ZsaXBfc2NyZWVuGAQgASgIUg'
    'pmbGlwU2NyZWVuEkMKBXVuaXRzGAUgASgOMi0ubWVzaHRhc3RpYy5Db25maWcuRGlzcGxheUNv'
    'bmZpZy5EaXNwbGF5VW5pdHNSBXVuaXRzIk0KE0dwc0Nvb3JkaW5hdGVGb3JtYXQSBwoDREVDEA'
    'ASBwoDRE1TEAESBwoDVVRNEAISCAoETUdSUxADEgcKA09MQxAEEggKBE9TR1IQBSIoCgxEaXNw'
    'bGF5VW5pdHMSCgoGTUVUUklDEAASDAoISU1QRVJJQUwQARqcBAoKTG9SYUNvbmZpZxIWCgZyZW'
    'dpb24YASABKA1SBnJlZ2lvbhIdCgp1c2VfcHJlc2V0GAIgASgIUgl1c2VQcmVzZXQSTAoMbW9k'
    'ZW1fcHJlc2V0GAMgASgOMikubWVzaHRhc3RpYy5Db25maWcuTG9SYUNvbmZpZy5Nb2RlbVByZX'
    'NldFILbW9kZW1QcmVzZXQSHAoJYmFuZHdpZHRoGAQgASgNUgliYW5kd2lkdGgSIwoNc3ByZWFk'
    'X2ZhY3RvchgFIAEoDVIMc3ByZWFkRmFjdG9yEh8KC2NvZGluZ19yYXRlGAYgASgNUgpjb2Rpbm'
    'dSYXRlEikKEGZyZXF1ZW5jeV9vZmZzZXQYByABKAJSD2ZyZXF1ZW5jeU9mZnNldBIbCglob3Bf'
    'bGltaXQYCCABKA1SCGhvcExpbWl0Eh0KCnR4X2VuYWJsZWQYCSABKAhSCXR4RW5hYmxlZBIZCg'
    'h0eF9wb3dlchgKIAEoBVIHdHhQb3dlchIfCgtjaGFubmVsX251bRgLIAEoDVIKY2hhbm5lbE51'
    'bSKBAQoLTW9kZW1QcmVzZXQSDQoJTE9OR19GQVNUEAASDQoJTE9OR19TTE9XEAESEgoOVkVSWV'
    '9MT05HX1NMT1cQAhIPCgtNRURJVU1fU0xPVxADEg8KC01FRElVTV9GQVNUEAQSDgoKU0hPUlRf'
    'U0xPVxAFEg4KClNIT1JUX0ZBU1QQBhrGAQoPQmx1ZXRvb3RoQ29uZmlnEhgKB2VuYWJsZWQYAS'
    'ABKAhSB2VuYWJsZWQSQgoEbW9kZRgCIAEoDjIuLm1lc2h0YXN0aWMuQ29uZmlnLkJsdWV0b290'
    'aENvbmZpZy5QYWlyaW5nTW9kZVIEbW9kZRIbCglmaXhlZF9waW4YAyABKA1SCGZpeGVkUGluIj'
    'gKC1BhaXJpbmdNb2RlEg4KClJBTkRPTV9QSU4QABINCglGSVhFRF9QSU4QARIKCgZOT19QSU4Q'
    'AkIRCg9wYXlsb2FkX3ZhcmlhbnQ=');

