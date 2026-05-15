//
//  Generated code. Do not modify.
//  source: module_config.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig$json = {
  '1': 'ModuleConfig',
  '2': [
    {'1': 'mqtt', '3': 1, '4': 1, '5': 11, '6': '.meshtastic.ModuleConfig.MQTTConfig', '9': 0, '10': 'mqtt'},
    {'1': 'serial', '3': 2, '4': 1, '5': 11, '6': '.meshtastic.ModuleConfig.SerialConfig', '9': 0, '10': 'serial'},
    {'1': 'external_notification', '3': 3, '4': 1, '5': 11, '6': '.meshtastic.ModuleConfig.ExternalNotificationConfig', '9': 0, '10': 'externalNotification'},
    {'1': 'store_forward', '3': 4, '4': 1, '5': 11, '6': '.meshtastic.ModuleConfig.StoreForwardConfig', '9': 0, '10': 'storeForward'},
    {'1': 'range_test', '3': 5, '4': 1, '5': 11, '6': '.meshtastic.ModuleConfig.RangeTestConfig', '9': 0, '10': 'rangeTest'},
    {'1': 'telemetry', '3': 6, '4': 1, '5': 11, '6': '.meshtastic.ModuleConfig.TelemetryConfig', '9': 0, '10': 'telemetry'},
    {'1': 'canned_message', '3': 7, '4': 1, '5': 11, '6': '.meshtastic.ModuleConfig.CannedMessageConfig', '9': 0, '10': 'cannedMessage'},
    {'1': 'audio', '3': 8, '4': 1, '5': 11, '6': '.meshtastic.ModuleConfig.AudioConfig', '9': 0, '10': 'audio'},
    {'1': 'remote_hardware', '3': 9, '4': 1, '5': 11, '6': '.meshtastic.ModuleConfig.RemoteHardwareConfig', '9': 0, '10': 'remoteHardware'},
  ],
  '3': [ModuleConfig_MQTTConfig$json, ModuleConfig_SerialConfig$json, ModuleConfig_ExternalNotificationConfig$json, ModuleConfig_StoreForwardConfig$json, ModuleConfig_RangeTestConfig$json, ModuleConfig_TelemetryConfig$json, ModuleConfig_CannedMessageConfig$json, ModuleConfig_AudioConfig$json, ModuleConfig_RemoteHardwareConfig$json],
  '8': [
    {'1': 'payload_variant'},
  ],
};

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig_MQTTConfig$json = {
  '1': 'MQTTConfig',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'address', '3': 2, '4': 1, '5': 9, '10': 'address'},
    {'1': 'username', '3': 3, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 4, '4': 1, '5': 9, '10': 'password'},
    {'1': 'encryption_enabled', '3': 5, '4': 1, '5': 8, '10': 'encryptionEnabled'},
    {'1': 'json_enabled', '3': 6, '4': 1, '5': 8, '10': 'jsonEnabled'},
    {'1': 'tls_enabled', '3': 7, '4': 1, '5': 8, '10': 'tlsEnabled'},
    {'1': 'root_topic', '3': 8, '4': 1, '5': 9, '10': 'rootTopic'},
  ],
};

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig_SerialConfig$json = {
  '1': 'SerialConfig',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'echo', '3': 2, '4': 1, '5': 8, '10': 'echo'},
    {'1': 'rxd', '3': 3, '4': 1, '5': 13, '10': 'rxd'},
    {'1': 'txd', '3': 4, '4': 1, '5': 13, '10': 'txd'},
    {'1': 'baud', '3': 5, '4': 1, '5': 14, '6': '.meshtastic.ModuleConfig.SerialConfig.Serial_Baud', '10': 'baud'},
    {'1': 'timeout', '3': 6, '4': 1, '5': 13, '10': 'timeout'},
    {'1': 'mode', '3': 7, '4': 1, '5': 14, '6': '.meshtastic.ModuleConfig.SerialConfig.Serial_Mode', '10': 'mode'},
  ],
  '4': [ModuleConfig_SerialConfig_Serial_Baud$json, ModuleConfig_SerialConfig_Serial_Mode$json],
};

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig_SerialConfig_Serial_Baud$json = {
  '1': 'Serial_Baud',
  '2': [
    {'1': 'BAUD_DEFAULT', '2': 0},
    {'1': 'BAUD_110', '2': 1},
    {'1': 'BAUD_300', '2': 2},
    {'1': 'BAUD_600', '2': 3},
    {'1': 'BAUD_1200', '2': 4},
    {'1': 'BAUD_2400', '2': 5},
    {'1': 'BAUD_4800', '2': 6},
    {'1': 'BAUD_9600', '2': 7},
    {'1': 'BAUD_19200', '2': 8},
    {'1': 'BAUD_38400', '2': 9},
    {'1': 'BAUD_57600', '2': 10},
    {'1': 'BAUD_115200', '2': 11},
    {'1': 'BAUD_230400', '2': 12},
    {'1': 'BAUD_460800', '2': 13},
    {'1': 'BAUD_576000', '2': 14},
    {'1': 'BAUD_921600', '2': 15},
  ],
};

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig_SerialConfig_Serial_Mode$json = {
  '1': 'Serial_Mode',
  '2': [
    {'1': 'DEFAULT', '2': 0},
    {'1': 'SIMPLE', '2': 1},
    {'1': 'PROTO', '2': 2},
    {'1': 'TEXTMSG', '2': 3},
    {'1': 'NMEA', '2': 4},
  ],
};

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig_ExternalNotificationConfig$json = {
  '1': 'ExternalNotificationConfig',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'output_ms', '3': 2, '4': 1, '5': 13, '10': 'outputMs'},
    {'1': 'output', '3': 3, '4': 1, '5': 13, '10': 'output'},
    {'1': 'active', '3': 4, '4': 1, '5': 8, '10': 'active'},
    {'1': 'alert_message', '3': 5, '4': 1, '5': 8, '10': 'alertMessage'},
    {'1': 'alert_bell', '3': 6, '4': 1, '5': 8, '10': 'alertBell'},
    {'1': 'use_pwm', '3': 7, '4': 1, '5': 8, '10': 'usePwm'},
    {'1': 'nag_timeout', '3': 8, '4': 1, '5': 13, '10': 'nagTimeout'},
  ],
};

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig_StoreForwardConfig$json = {
  '1': 'StoreForwardConfig',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'heartbeat', '3': 2, '4': 1, '5': 8, '10': 'heartbeat'},
    {'1': 'records', '3': 3, '4': 1, '5': 13, '10': 'records'},
    {'1': 'history_return_max', '3': 4, '4': 1, '5': 13, '10': 'historyReturnMax'},
    {'1': 'history_return_window', '3': 5, '4': 1, '5': 13, '10': 'historyReturnWindow'},
  ],
};

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig_RangeTestConfig$json = {
  '1': 'RangeTestConfig',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'sender', '3': 2, '4': 1, '5': 13, '10': 'sender'},
    {'1': 'save', '3': 3, '4': 1, '5': 8, '10': 'save'},
  ],
};

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig_TelemetryConfig$json = {
  '1': 'TelemetryConfig',
  '2': [
    {'1': 'device_update_interval', '3': 1, '4': 1, '5': 13, '10': 'deviceUpdateInterval'},
    {'1': 'environment_update_interval', '3': 2, '4': 1, '5': 13, '10': 'environmentUpdateInterval'},
    {'1': 'environment_measurement_enabled', '3': 3, '4': 1, '5': 8, '10': 'environmentMeasurementEnabled'},
    {'1': 'environment_screen_enabled', '3': 4, '4': 1, '5': 8, '10': 'environmentScreenEnabled'},
    {'1': 'environment_display_fahrenheit', '3': 5, '4': 1, '5': 8, '10': 'environmentDisplayFahrenheit'},
  ],
};

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig_CannedMessageConfig$json = {
  '1': 'CannedMessageConfig',
  '2': [
    {'1': 'rotary1_enabled', '3': 1, '4': 1, '5': 8, '10': 'rotary1Enabled'},
    {'1': 'inputbroker_pin_a', '3': 2, '4': 1, '5': 13, '10': 'inputbrokerPinA'},
    {'1': 'inputbroker_pin_b', '3': 3, '4': 1, '5': 13, '10': 'inputbrokerPinB'},
    {'1': 'inputbroker_pin_press', '3': 4, '4': 1, '5': 13, '10': 'inputbrokerPinPress'},
    {'1': 'inputbroker_event_cw', '3': 5, '4': 1, '5': 14, '6': '.meshtastic.ModuleConfig.CannedMessageConfig.InputEventChar', '10': 'inputbrokerEventCw'},
    {'1': 'inputbroker_event_ccw', '3': 6, '4': 1, '5': 14, '6': '.meshtastic.ModuleConfig.CannedMessageConfig.InputEventChar', '10': 'inputbrokerEventCcw'},
    {'1': 'inputbroker_event_press', '3': 7, '4': 1, '5': 14, '6': '.meshtastic.ModuleConfig.CannedMessageConfig.InputEventChar', '10': 'inputbrokerEventPress'},
    {'1': 'updown1_enabled', '3': 8, '4': 1, '5': 8, '10': 'updown1Enabled'},
    {'1': 'enabled', '3': 9, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'allow_input_source', '3': 10, '4': 1, '5': 9, '10': 'allowInputSource'},
    {'1': 'send_bell', '3': 11, '4': 1, '5': 8, '10': 'sendBell'},
  ],
  '4': [ModuleConfig_CannedMessageConfig_InputEventChar$json],
};

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig_CannedMessageConfig_InputEventChar$json = {
  '1': 'InputEventChar',
  '2': [
    {'1': 'NONE', '2': 0},
    {'1': 'UP', '2': 17},
    {'1': 'DOWN', '2': 18},
    {'1': 'LEFT', '2': 19},
    {'1': 'RIGHT', '2': 20},
    {'1': 'SELECT', '2': 10},
    {'1': 'BACK', '2': 27},
    {'1': 'CANCEL', '2': 24},
  ],
};

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig_AudioConfig$json = {
  '1': 'AudioConfig',
  '2': [
    {'1': 'codec2_enabled', '3': 1, '4': 1, '5': 8, '10': 'codec2Enabled'},
    {'1': 'ptt_pin', '3': 2, '4': 1, '5': 13, '10': 'pttPin'},
    {'1': 'bitrate', '3': 3, '4': 1, '5': 14, '6': '.meshtastic.ModuleConfig.AudioConfig.Audio_Baud', '10': 'bitrate'},
    {'1': 'i2s_ws', '3': 4, '4': 1, '5': 13, '10': 'i2sWs'},
    {'1': 'i2s_sd', '3': 5, '4': 1, '5': 13, '10': 'i2sSd'},
    {'1': 'i2s_din', '3': 6, '4': 1, '5': 13, '10': 'i2sDin'},
    {'1': 'i2s_sck', '3': 7, '4': 1, '5': 13, '10': 'i2sSck'},
  ],
  '4': [ModuleConfig_AudioConfig_Audio_Baud$json],
};

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig_AudioConfig_Audio_Baud$json = {
  '1': 'Audio_Baud',
  '2': [
    {'1': 'CODEC2_DEFAULT', '2': 0},
    {'1': 'CODEC2_3200', '2': 1},
    {'1': 'CODEC2_2400', '2': 2},
    {'1': 'CODEC2_1600', '2': 3},
    {'1': 'CODEC2_1400', '2': 4},
    {'1': 'CODEC2_1300', '2': 5},
    {'1': 'CODEC2_1200', '2': 6},
    {'1': 'CODEC2_700', '2': 7},
    {'1': 'CODEC2_700B', '2': 8},
  ],
};

@$core.Deprecated('Use moduleConfigDescriptor instead')
const ModuleConfig_RemoteHardwareConfig$json = {
  '1': 'RemoteHardwareConfig',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'allow_undefined_pin_access', '3': 2, '4': 1, '5': 8, '10': 'allowUndefinedPinAccess'},
  ],
};

/// Descriptor for `ModuleConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List moduleConfigDescriptor = $convert.base64Decode(
    'CgxNb2R1bGVDb25maWcSOQoEbXF0dBgBIAEoCzIjLm1lc2h0YXN0aWMuTW9kdWxlQ29uZmlnLk'
    '1RVFRDb25maWdIAFIEbXF0dBI/CgZzZXJpYWwYAiABKAsyJS5tZXNodGFzdGljLk1vZHVsZUNv'
    'bmZpZy5TZXJpYWxDb25maWdIAFIGc2VyaWFsEmoKFWV4dGVybmFsX25vdGlmaWNhdGlvbhgDIA'
    'EoCzIzLm1lc2h0YXN0aWMuTW9kdWxlQ29uZmlnLkV4dGVybmFsTm90aWZpY2F0aW9uQ29uZmln'
    'SABSFGV4dGVybmFsTm90aWZpY2F0aW9uElIKDXN0b3JlX2ZvcndhcmQYBCABKAsyKy5tZXNodG'
    'FzdGljLk1vZHVsZUNvbmZpZy5TdG9yZUZvcndhcmRDb25maWdIAFIMc3RvcmVGb3J3YXJkEkkK'
    'CnJhbmdlX3Rlc3QYBSABKAsyKC5tZXNodGFzdGljLk1vZHVsZUNvbmZpZy5SYW5nZVRlc3RDb2'
    '5maWdIAFIJcmFuZ2VUZXN0EkgKCXRlbGVtZXRyeRgGIAEoCzIoLm1lc2h0YXN0aWMuTW9kdWxl'
    'Q29uZmlnLlRlbGVtZXRyeUNvbmZpZ0gAUgl0ZWxlbWV0cnkSVQoOY2FubmVkX21lc3NhZ2UYBy'
    'ABKAsyLC5tZXNodGFzdGljLk1vZHVsZUNvbmZpZy5DYW5uZWRNZXNzYWdlQ29uZmlnSABSDWNh'
    'bm5lZE1lc3NhZ2USPAoFYXVkaW8YCCABKAsyJC5tZXNodGFzdGljLk1vZHVsZUNvbmZpZy5BdW'
    'Rpb0NvbmZpZ0gAUgVhdWRpbxJYCg9yZW1vdGVfaGFyZHdhcmUYCSABKAsyLS5tZXNodGFzdGlj'
    'Lk1vZHVsZUNvbmZpZy5SZW1vdGVIYXJkd2FyZUNvbmZpZ0gAUg5yZW1vdGVIYXJkd2FyZRqKAg'
    'oKTVFUVENvbmZpZxIYCgdlbmFibGVkGAEgASgIUgdlbmFibGVkEhgKB2FkZHJlc3MYAiABKAlS'
    'B2FkZHJlc3MSGgoIdXNlcm5hbWUYAyABKAlSCHVzZXJuYW1lEhoKCHBhc3N3b3JkGAQgASgJUg'
    'hwYXNzd29yZBItChJlbmNyeXB0aW9uX2VuYWJsZWQYBSABKAhSEWVuY3J5cHRpb25FbmFibGVk'
    'EiEKDGpzb25fZW5hYmxlZBgGIAEoCFILanNvbkVuYWJsZWQSHwoLdGxzX2VuYWJsZWQYByABKA'
    'hSCnRsc0VuYWJsZWQSHQoKcm9vdF90b3BpYxgIIAEoCVIJcm9vdFRvcGljGt8ECgxTZXJpYWxD'
    'b25maWcSGAoHZW5hYmxlZBgBIAEoCFIHZW5hYmxlZBISCgRlY2hvGAIgASgIUgRlY2hvEhAKA3'
    'J4ZBgDIAEoDVIDcnhkEhAKA3R4ZBgEIAEoDVIDdHhkEkUKBGJhdWQYBSABKA4yMS5tZXNodGFz'
    'dGljLk1vZHVsZUNvbmZpZy5TZXJpYWxDb25maWcuU2VyaWFsX0JhdWRSBGJhdWQSGAoHdGltZW'
    '91dBgGIAEoDVIHdGltZW91dBJFCgRtb2RlGAcgASgOMjEubWVzaHRhc3RpYy5Nb2R1bGVDb25m'
    'aWcuU2VyaWFsQ29uZmlnLlNlcmlhbF9Nb2RlUgRtb2RlIooCCgtTZXJpYWxfQmF1ZBIQCgxCQV'
    'VEX0RFRkFVTFQQABIMCghCQVVEXzExMBABEgwKCEJBVURfMzAwEAISDAoIQkFVRF82MDAQAxIN'
    'CglCQVVEXzEyMDAQBBINCglCQVVEXzI0MDAQBRINCglCQVVEXzQ4MDAQBhINCglCQVVEXzk2MD'
    'AQBxIOCgpCQVVEXzE5MjAwEAgSDgoKQkFVRF8zODQwMBAJEg4KCkJBVURfNTc2MDAQChIPCgtC'
    'QVVEXzExNTIwMBALEg8KC0JBVURfMjMwNDAwEAwSDwoLQkFVRF80NjA4MDAQDRIPCgtCQVVEXz'
    'U3NjAwMBAOEg8KC0JBVURfOTIxNjAwEA8iSAoLU2VyaWFsX01vZGUSCwoHREVGQVVMVBAAEgoK'
    'BlNJTVBMRRABEgkKBVBST1RPEAISCwoHVEVYVE1TRxADEggKBE5NRUEQBBqBAgoaRXh0ZXJuYW'
    'xOb3RpZmljYXRpb25Db25maWcSGAoHZW5hYmxlZBgBIAEoCFIHZW5hYmxlZBIbCglvdXRwdXRf'
    'bXMYAiABKA1SCG91dHB1dE1zEhYKBm91dHB1dBgDIAEoDVIGb3V0cHV0EhYKBmFjdGl2ZRgEIA'
    'EoCFIGYWN0aXZlEiMKDWFsZXJ0X21lc3NhZ2UYBSABKAhSDGFsZXJ0TWVzc2FnZRIdCgphbGVy'
    'dF9iZWxsGAYgASgIUglhbGVydEJlbGwSFwoHdXNlX3B3bRgHIAEoCFIGdXNlUHdtEh8KC25hZ1'
    '90aW1lb3V0GAggASgNUgpuYWdUaW1lb3V0GsgBChJTdG9yZUZvcndhcmRDb25maWcSGAoHZW5h'
    'YmxlZBgBIAEoCFIHZW5hYmxlZBIcCgloZWFydGJlYXQYAiABKAhSCWhlYXJ0YmVhdBIYCgdyZW'
    'NvcmRzGAMgASgNUgdyZWNvcmRzEiwKEmhpc3RvcnlfcmV0dXJuX21heBgEIAEoDVIQaGlzdG9y'
    'eVJldHVybk1heBIyChVoaXN0b3J5X3JldHVybl93aW5kb3cYBSABKA1SE2hpc3RvcnlSZXR1cm'
    '5XaW5kb3caVwoPUmFuZ2VUZXN0Q29uZmlnEhgKB2VuYWJsZWQYASABKAhSB2VuYWJsZWQSFgoG'
    'c2VuZGVyGAIgASgNUgZzZW5kZXISEgoEc2F2ZRgDIAEoCFIEc2F2ZRrTAgoPVGVsZW1ldHJ5Q2'
    '9uZmlnEjQKFmRldmljZV91cGRhdGVfaW50ZXJ2YWwYASABKA1SFGRldmljZVVwZGF0ZUludGVy'
    'dmFsEj4KG2Vudmlyb25tZW50X3VwZGF0ZV9pbnRlcnZhbBgCIAEoDVIZZW52aXJvbm1lbnRVcG'
    'RhdGVJbnRlcnZhbBJGCh9lbnZpcm9ubWVudF9tZWFzdXJlbWVudF9lbmFibGVkGAMgASgIUh1l'
    'bnZpcm9ubWVudE1lYXN1cmVtZW50RW5hYmxlZBI8ChplbnZpcm9ubWVudF9zY3JlZW5fZW5hYm'
    'xlZBgEIAEoCFIYZW52aXJvbm1lbnRTY3JlZW5FbmFibGVkEkQKHmVudmlyb25tZW50X2Rpc3Bs'
    'YXlfZmFocmVuaGVpdBgFIAEoCFIcZW52aXJvbm1lbnREaXNwbGF5RmFocmVuaGVpdBqSBgoTQ2'
    'FubmVkTWVzc2FnZUNvbmZpZxInCg9yb3RhcnkxX2VuYWJsZWQYASABKAhSDnJvdGFyeTFFbmFi'
    'bGVkEioKEWlucHV0YnJva2VyX3Bpbl9hGAIgASgNUg9pbnB1dGJyb2tlclBpbkESKgoRaW5wdX'
    'Ricm9rZXJfcGluX2IYAyABKA1SD2lucHV0YnJva2VyUGluQhIyChVpbnB1dGJyb2tlcl9waW5f'
    'cHJlc3MYBCABKA1SE2lucHV0YnJva2VyUGluUHJlc3MSbQoUaW5wdXRicm9rZXJfZXZlbnRfY3'
    'cYBSABKA4yOy5tZXNodGFzdGljLk1vZHVsZUNvbmZpZy5DYW5uZWRNZXNzYWdlQ29uZmlnLklu'
    'cHV0RXZlbnRDaGFyUhJpbnB1dGJyb2tlckV2ZW50Q3cSbwoVaW5wdXRicm9rZXJfZXZlbnRfY2'
    'N3GAYgASgOMjsubWVzaHRhc3RpYy5Nb2R1bGVDb25maWcuQ2FubmVkTWVzc2FnZUNvbmZpZy5J'
    'bnB1dEV2ZW50Q2hhclITaW5wdXRicm9rZXJFdmVudENjdxJzChdpbnB1dGJyb2tlcl9ldmVudF'
    '9wcmVzcxgHIAEoDjI7Lm1lc2h0YXN0aWMuTW9kdWxlQ29uZmlnLkNhbm5lZE1lc3NhZ2VDb25m'
    'aWcuSW5wdXRFdmVudENoYXJSFWlucHV0YnJva2VyRXZlbnRQcmVzcxInCg91cGRvd24xX2VuYW'
    'JsZWQYCCABKAhSDnVwZG93bjFFbmFibGVkEhgKB2VuYWJsZWQYCSABKAhSB2VuYWJsZWQSLAoS'
    'YWxsb3dfaW5wdXRfc291cmNlGAogASgJUhBhbGxvd0lucHV0U291cmNlEhsKCXNlbmRfYmVsbB'
    'gLIAEoCFIIc2VuZEJlbGwiYwoOSW5wdXRFdmVudENoYXISCAoETk9ORRAAEgYKAlVQEBESCAoE'
    'RE9XThASEggKBExFRlQQExIJCgVSSUdIVBAUEgoKBlNFTEVDVBAKEggKBEJBQ0sQGxIKCgZDQU'
    '5DRUwQGBqiAwoLQXVkaW9Db25maWcSJQoOY29kZWMyX2VuYWJsZWQYASABKAhSDWNvZGVjMkVu'
    'YWJsZWQSFwoHcHR0X3BpbhgCIAEoDVIGcHR0UGluEkkKB2JpdHJhdGUYAyABKA4yLy5tZXNodG'
    'FzdGljLk1vZHVsZUNvbmZpZy5BdWRpb0NvbmZpZy5BdWRpb19CYXVkUgdiaXRyYXRlEhUKBmky'
    'c193cxgEIAEoDVIFaTJzV3MSFQoGaTJzX3NkGAUgASgNUgVpMnNTZBIXCgdpMnNfZGluGAYgAS'
    'gNUgZpMnNEaW4SFwoHaTJzX3NjaxgHIAEoDVIGaTJzU2NrIqcBCgpBdWRpb19CYXVkEhIKDkNP'
    'REVDMl9ERUZBVUxUEAASDwoLQ09ERUMyXzMyMDAQARIPCgtDT0RFQzJfMjQwMBACEg8KC0NPRE'
    'VDMl8xNjAwEAMSDwoLQ09ERUMyXzE0MDAQBBIPCgtDT0RFQzJfMTMwMBAFEg8KC0NPREVDMl8x'
    'MjAwEAYSDgoKQ09ERUMyXzcwMBAHEg8KC0NPREVDMl83MDBCEAgabQoUUmVtb3RlSGFyZHdhcm'
    'VDb25maWcSGAoHZW5hYmxlZBgBIAEoCFIHZW5hYmxlZBI7ChphbGxvd191bmRlZmluZWRfcGlu'
    'X2FjY2VzcxgCIAEoCFIXYWxsb3dVbmRlZmluZWRQaW5BY2Nlc3NCEQoPcGF5bG9hZF92YXJpYW'
    '50');

