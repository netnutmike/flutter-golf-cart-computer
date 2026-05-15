//
//  Generated code. Do not modify.
//  source: telemetry.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use deviceMetricsDescriptor instead')
const DeviceMetrics$json = {
  '1': 'DeviceMetrics',
  '2': [
    {'1': 'battery_level', '3': 1, '4': 1, '5': 13, '10': 'batteryLevel'},
    {'1': 'voltage', '3': 2, '4': 1, '5': 2, '10': 'voltage'},
    {'1': 'channel_utilization', '3': 3, '4': 1, '5': 2, '10': 'channelUtilization'},
    {'1': 'air_util_tx', '3': 4, '4': 1, '5': 2, '10': 'airUtilTx'},
    {'1': 'uptime_seconds', '3': 5, '4': 1, '5': 13, '10': 'uptimeSeconds'},
  ],
};

/// Descriptor for `DeviceMetrics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceMetricsDescriptor = $convert.base64Decode(
    'Cg1EZXZpY2VNZXRyaWNzEiMKDWJhdHRlcnlfbGV2ZWwYASABKA1SDGJhdHRlcnlMZXZlbBIYCg'
    'd2b2x0YWdlGAIgASgCUgd2b2x0YWdlEi8KE2NoYW5uZWxfdXRpbGl6YXRpb24YAyABKAJSEmNo'
    'YW5uZWxVdGlsaXphdGlvbhIeCgthaXJfdXRpbF90eBgEIAEoAlIJYWlyVXRpbFR4EiUKDnVwdG'
    'ltZV9zZWNvbmRzGAUgASgNUg11cHRpbWVTZWNvbmRz');

@$core.Deprecated('Use environmentMetricsDescriptor instead')
const EnvironmentMetrics$json = {
  '1': 'EnvironmentMetrics',
  '2': [
    {'1': 'temperature', '3': 1, '4': 1, '5': 2, '10': 'temperature'},
    {'1': 'relative_humidity', '3': 2, '4': 1, '5': 2, '10': 'relativeHumidity'},
    {'1': 'barometric_pressure', '3': 3, '4': 1, '5': 2, '10': 'barometricPressure'},
    {'1': 'gas_resistance', '3': 4, '4': 1, '5': 2, '10': 'gasResistance'},
    {'1': 'voltage', '3': 5, '4': 1, '5': 2, '10': 'voltage'},
    {'1': 'current', '3': 6, '4': 1, '5': 2, '10': 'current'},
  ],
};

/// Descriptor for `EnvironmentMetrics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List environmentMetricsDescriptor = $convert.base64Decode(
    'ChJFbnZpcm9ubWVudE1ldHJpY3MSIAoLdGVtcGVyYXR1cmUYASABKAJSC3RlbXBlcmF0dXJlEi'
    'sKEXJlbGF0aXZlX2h1bWlkaXR5GAIgASgCUhByZWxhdGl2ZUh1bWlkaXR5Ei8KE2Jhcm9tZXRy'
    'aWNfcHJlc3N1cmUYAyABKAJSEmJhcm9tZXRyaWNQcmVzc3VyZRIlCg5nYXNfcmVzaXN0YW5jZR'
    'gEIAEoAlINZ2FzUmVzaXN0YW5jZRIYCgd2b2x0YWdlGAUgASgCUgd2b2x0YWdlEhgKB2N1cnJl'
    'bnQYBiABKAJSB2N1cnJlbnQ=');

@$core.Deprecated('Use powerMetricsDescriptor instead')
const PowerMetrics$json = {
  '1': 'PowerMetrics',
  '2': [
    {'1': 'ch1_voltage', '3': 1, '4': 1, '5': 2, '10': 'ch1Voltage'},
    {'1': 'ch1_current', '3': 2, '4': 1, '5': 2, '10': 'ch1Current'},
    {'1': 'ch2_voltage', '3': 3, '4': 1, '5': 2, '10': 'ch2Voltage'},
    {'1': 'ch2_current', '3': 4, '4': 1, '5': 2, '10': 'ch2Current'},
    {'1': 'ch3_voltage', '3': 5, '4': 1, '5': 2, '10': 'ch3Voltage'},
    {'1': 'ch3_current', '3': 6, '4': 1, '5': 2, '10': 'ch3Current'},
  ],
};

/// Descriptor for `PowerMetrics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List powerMetricsDescriptor = $convert.base64Decode(
    'CgxQb3dlck1ldHJpY3MSHwoLY2gxX3ZvbHRhZ2UYASABKAJSCmNoMVZvbHRhZ2USHwoLY2gxX2'
    'N1cnJlbnQYAiABKAJSCmNoMUN1cnJlbnQSHwoLY2gyX3ZvbHRhZ2UYAyABKAJSCmNoMlZvbHRh'
    'Z2USHwoLY2gyX2N1cnJlbnQYBCABKAJSCmNoMkN1cnJlbnQSHwoLY2gzX3ZvbHRhZ2UYBSABKA'
    'JSCmNoM1ZvbHRhZ2USHwoLY2gzX2N1cnJlbnQYBiABKAJSCmNoM0N1cnJlbnQ=');

@$core.Deprecated('Use telemetryDescriptor instead')
const Telemetry$json = {
  '1': 'Telemetry',
  '2': [
    {'1': 'time', '3': 1, '4': 1, '5': 7, '10': 'time'},
    {'1': 'device_metrics', '3': 2, '4': 1, '5': 11, '6': '.meshtastic.DeviceMetrics', '9': 0, '10': 'deviceMetrics'},
    {'1': 'environment_metrics', '3': 3, '4': 1, '5': 11, '6': '.meshtastic.EnvironmentMetrics', '9': 0, '10': 'environmentMetrics'},
    {'1': 'power_metrics', '3': 4, '4': 1, '5': 11, '6': '.meshtastic.PowerMetrics', '9': 0, '10': 'powerMetrics'},
  ],
  '8': [
    {'1': 'variant'},
  ],
};

/// Descriptor for `Telemetry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List telemetryDescriptor = $convert.base64Decode(
    'CglUZWxlbWV0cnkSEgoEdGltZRgBIAEoB1IEdGltZRJCCg5kZXZpY2VfbWV0cmljcxgCIAEoCz'
    'IZLm1lc2h0YXN0aWMuRGV2aWNlTWV0cmljc0gAUg1kZXZpY2VNZXRyaWNzElEKE2Vudmlyb25t'
    'ZW50X21ldHJpY3MYAyABKAsyHi5tZXNodGFzdGljLkVudmlyb25tZW50TWV0cmljc0gAUhJlbn'
    'Zpcm9ubWVudE1ldHJpY3MSPwoNcG93ZXJfbWV0cmljcxgEIAEoCzIYLm1lc2h0YXN0aWMuUG93'
    'ZXJNZXRyaWNzSABSDHBvd2VyTWV0cmljc0IJCgd2YXJpYW50');

