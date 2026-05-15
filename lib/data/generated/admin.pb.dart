//
//  Generated code. Do not modify.
//  source: admin.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'admin.pbenum.dart';
import 'channel.pb.dart' as $0;
import 'config.pb.dart' as $1;
import 'module_config.pb.dart' as $2;

export 'admin.pbenum.dart';

enum AdminMessage_PayloadVariant {
  getChannelRequest, 
  getChannelResponse, 
  getOwnerRequest, 
  getConfigRequest, 
  getConfigResponse, 
  getModuleConfigRequest, 
  getModuleConfigResponse, 
  setConfig, 
  setModuleConfig, 
  setChannel, 
  rebootSeconds, 
  rebootOtaSeconds, 
  shutdownSeconds, 
  factoryReset, 
  nodedbReset, 
  notSet
}

/// *
///  Admin message for radio administration commands.
///  Sent via ADMIN_APP port (6) to the local node number.
class AdminMessage extends $pb.GeneratedMessage {
  factory AdminMessage({
    $core.int? getChannelRequest,
    $0.Channel? getChannelResponse,
    $core.bool? getOwnerRequest,
    AdminMessage_ConfigType? getConfigRequest,
    $1.Config? getConfigResponse,
    AdminMessage_ModuleConfigType? getModuleConfigRequest,
    $2.ModuleConfig? getModuleConfigResponse,
    $1.Config? setConfig,
    $2.ModuleConfig? setModuleConfig,
    $0.Channel? setChannel,
    $core.int? rebootSeconds,
    $core.int? rebootOtaSeconds,
    $core.int? shutdownSeconds,
    $core.int? factoryReset,
    $core.int? nodedbReset,
  }) {
    final $result = create();
    if (getChannelRequest != null) {
      $result.getChannelRequest = getChannelRequest;
    }
    if (getChannelResponse != null) {
      $result.getChannelResponse = getChannelResponse;
    }
    if (getOwnerRequest != null) {
      $result.getOwnerRequest = getOwnerRequest;
    }
    if (getConfigRequest != null) {
      $result.getConfigRequest = getConfigRequest;
    }
    if (getConfigResponse != null) {
      $result.getConfigResponse = getConfigResponse;
    }
    if (getModuleConfigRequest != null) {
      $result.getModuleConfigRequest = getModuleConfigRequest;
    }
    if (getModuleConfigResponse != null) {
      $result.getModuleConfigResponse = getModuleConfigResponse;
    }
    if (setConfig != null) {
      $result.setConfig = setConfig;
    }
    if (setModuleConfig != null) {
      $result.setModuleConfig = setModuleConfig;
    }
    if (setChannel != null) {
      $result.setChannel = setChannel;
    }
    if (rebootSeconds != null) {
      $result.rebootSeconds = rebootSeconds;
    }
    if (rebootOtaSeconds != null) {
      $result.rebootOtaSeconds = rebootOtaSeconds;
    }
    if (shutdownSeconds != null) {
      $result.shutdownSeconds = shutdownSeconds;
    }
    if (factoryReset != null) {
      $result.factoryReset = factoryReset;
    }
    if (nodedbReset != null) {
      $result.nodedbReset = nodedbReset;
    }
    return $result;
  }
  AdminMessage._() : super();
  factory AdminMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AdminMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, AdminMessage_PayloadVariant> _AdminMessage_PayloadVariantByTag = {
    1 : AdminMessage_PayloadVariant.getChannelRequest,
    2 : AdminMessage_PayloadVariant.getChannelResponse,
    3 : AdminMessage_PayloadVariant.getOwnerRequest,
    5 : AdminMessage_PayloadVariant.getConfigRequest,
    6 : AdminMessage_PayloadVariant.getConfigResponse,
    7 : AdminMessage_PayloadVariant.getModuleConfigRequest,
    8 : AdminMessage_PayloadVariant.getModuleConfigResponse,
    10 : AdminMessage_PayloadVariant.setConfig,
    11 : AdminMessage_PayloadVariant.setModuleConfig,
    12 : AdminMessage_PayloadVariant.setChannel,
    20 : AdminMessage_PayloadVariant.rebootSeconds,
    21 : AdminMessage_PayloadVariant.rebootOtaSeconds,
    22 : AdminMessage_PayloadVariant.shutdownSeconds,
    23 : AdminMessage_PayloadVariant.factoryReset,
    24 : AdminMessage_PayloadVariant.nodedbReset,
    0 : AdminMessage_PayloadVariant.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AdminMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 20, 21, 22, 23, 24])
    ..a<$core.int>(1, _omitFieldNames ? '' : 'getChannelRequest', $pb.PbFieldType.OU3)
    ..aOM<$0.Channel>(2, _omitFieldNames ? '' : 'getChannelResponse', subBuilder: $0.Channel.create)
    ..aOB(3, _omitFieldNames ? '' : 'getOwnerRequest')
    ..e<AdminMessage_ConfigType>(5, _omitFieldNames ? '' : 'getConfigRequest', $pb.PbFieldType.OE, defaultOrMaker: AdminMessage_ConfigType.DEVICE_CONFIG, valueOf: AdminMessage_ConfigType.valueOf, enumValues: AdminMessage_ConfigType.values)
    ..aOM<$1.Config>(6, _omitFieldNames ? '' : 'getConfigResponse', subBuilder: $1.Config.create)
    ..e<AdminMessage_ModuleConfigType>(7, _omitFieldNames ? '' : 'getModuleConfigRequest', $pb.PbFieldType.OE, defaultOrMaker: AdminMessage_ModuleConfigType.MQTT_CONFIG, valueOf: AdminMessage_ModuleConfigType.valueOf, enumValues: AdminMessage_ModuleConfigType.values)
    ..aOM<$2.ModuleConfig>(8, _omitFieldNames ? '' : 'getModuleConfigResponse', subBuilder: $2.ModuleConfig.create)
    ..aOM<$1.Config>(10, _omitFieldNames ? '' : 'setConfig', subBuilder: $1.Config.create)
    ..aOM<$2.ModuleConfig>(11, _omitFieldNames ? '' : 'setModuleConfig', subBuilder: $2.ModuleConfig.create)
    ..aOM<$0.Channel>(12, _omitFieldNames ? '' : 'setChannel', subBuilder: $0.Channel.create)
    ..a<$core.int>(20, _omitFieldNames ? '' : 'rebootSeconds', $pb.PbFieldType.O3)
    ..a<$core.int>(21, _omitFieldNames ? '' : 'rebootOtaSeconds', $pb.PbFieldType.O3)
    ..a<$core.int>(22, _omitFieldNames ? '' : 'shutdownSeconds', $pb.PbFieldType.O3)
    ..a<$core.int>(23, _omitFieldNames ? '' : 'factoryReset', $pb.PbFieldType.O3)
    ..a<$core.int>(24, _omitFieldNames ? '' : 'nodedbReset', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AdminMessage clone() => AdminMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AdminMessage copyWith(void Function(AdminMessage) updates) => super.copyWith((message) => updates(message as AdminMessage)) as AdminMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AdminMessage create() => AdminMessage._();
  AdminMessage createEmptyInstance() => create();
  static $pb.PbList<AdminMessage> createRepeated() => $pb.PbList<AdminMessage>();
  @$core.pragma('dart2js:noInline')
  static AdminMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AdminMessage>(create);
  static AdminMessage? _defaultInstance;

  AdminMessage_PayloadVariant whichPayloadVariant() => _AdminMessage_PayloadVariantByTag[$_whichOneof(0)]!;
  void clearPayloadVariant() => clearField($_whichOneof(0));

  /// Get channel by index
  @$pb.TagNumber(1)
  $core.int get getChannelRequest => $_getIZ(0);
  @$pb.TagNumber(1)
  set getChannelRequest($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasGetChannelRequest() => $_has(0);
  @$pb.TagNumber(1)
  void clearGetChannelRequest() => clearField(1);

  /// Response with channel data
  @$pb.TagNumber(2)
  $0.Channel get getChannelResponse => $_getN(1);
  @$pb.TagNumber(2)
  set getChannelResponse($0.Channel v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasGetChannelResponse() => $_has(1);
  @$pb.TagNumber(2)
  void clearGetChannelResponse() => clearField(2);
  @$pb.TagNumber(2)
  $0.Channel ensureGetChannelResponse() => $_ensure(1);

  /// Get owner info
  @$pb.TagNumber(3)
  $core.bool get getOwnerRequest => $_getBF(2);
  @$pb.TagNumber(3)
  set getOwnerRequest($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasGetOwnerRequest() => $_has(2);
  @$pb.TagNumber(3)
  void clearGetOwnerRequest() => clearField(3);

  /// Get config by type
  @$pb.TagNumber(5)
  AdminMessage_ConfigType get getConfigRequest => $_getN(3);
  @$pb.TagNumber(5)
  set getConfigRequest(AdminMessage_ConfigType v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasGetConfigRequest() => $_has(3);
  @$pb.TagNumber(5)
  void clearGetConfigRequest() => clearField(5);

  /// Response with config
  @$pb.TagNumber(6)
  $1.Config get getConfigResponse => $_getN(4);
  @$pb.TagNumber(6)
  set getConfigResponse($1.Config v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasGetConfigResponse() => $_has(4);
  @$pb.TagNumber(6)
  void clearGetConfigResponse() => clearField(6);
  @$pb.TagNumber(6)
  $1.Config ensureGetConfigResponse() => $_ensure(4);

  /// Get module config by type
  @$pb.TagNumber(7)
  AdminMessage_ModuleConfigType get getModuleConfigRequest => $_getN(5);
  @$pb.TagNumber(7)
  set getModuleConfigRequest(AdminMessage_ModuleConfigType v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasGetModuleConfigRequest() => $_has(5);
  @$pb.TagNumber(7)
  void clearGetModuleConfigRequest() => clearField(7);

  /// Response with module config
  @$pb.TagNumber(8)
  $2.ModuleConfig get getModuleConfigResponse => $_getN(6);
  @$pb.TagNumber(8)
  set getModuleConfigResponse($2.ModuleConfig v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasGetModuleConfigResponse() => $_has(6);
  @$pb.TagNumber(8)
  void clearGetModuleConfigResponse() => clearField(8);
  @$pb.TagNumber(8)
  $2.ModuleConfig ensureGetModuleConfigResponse() => $_ensure(6);

  /// Set config
  @$pb.TagNumber(10)
  $1.Config get setConfig => $_getN(7);
  @$pb.TagNumber(10)
  set setConfig($1.Config v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasSetConfig() => $_has(7);
  @$pb.TagNumber(10)
  void clearSetConfig() => clearField(10);
  @$pb.TagNumber(10)
  $1.Config ensureSetConfig() => $_ensure(7);

  /// Set module config
  @$pb.TagNumber(11)
  $2.ModuleConfig get setModuleConfig => $_getN(8);
  @$pb.TagNumber(11)
  set setModuleConfig($2.ModuleConfig v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasSetModuleConfig() => $_has(8);
  @$pb.TagNumber(11)
  void clearSetModuleConfig() => clearField(11);
  @$pb.TagNumber(11)
  $2.ModuleConfig ensureSetModuleConfig() => $_ensure(8);

  /// Set channel
  @$pb.TagNumber(12)
  $0.Channel get setChannel => $_getN(9);
  @$pb.TagNumber(12)
  set setChannel($0.Channel v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasSetChannel() => $_has(9);
  @$pb.TagNumber(12)
  void clearSetChannel() => clearField(12);
  @$pb.TagNumber(12)
  $0.Channel ensureSetChannel() => $_ensure(9);

  /// Reboot the radio after specified seconds
  @$pb.TagNumber(20)
  $core.int get rebootSeconds => $_getIZ(10);
  @$pb.TagNumber(20)
  set rebootSeconds($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(20)
  $core.bool hasRebootSeconds() => $_has(10);
  @$pb.TagNumber(20)
  void clearRebootSeconds() => clearField(20);

  /// Reboot into OTA mode
  @$pb.TagNumber(21)
  $core.int get rebootOtaSeconds => $_getIZ(11);
  @$pb.TagNumber(21)
  set rebootOtaSeconds($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(21)
  $core.bool hasRebootOtaSeconds() => $_has(11);
  @$pb.TagNumber(21)
  void clearRebootOtaSeconds() => clearField(21);

  /// Shutdown after specified seconds
  @$pb.TagNumber(22)
  $core.int get shutdownSeconds => $_getIZ(12);
  @$pb.TagNumber(22)
  set shutdownSeconds($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(22)
  $core.bool hasShutdownSeconds() => $_has(12);
  @$pb.TagNumber(22)
  void clearShutdownSeconds() => clearField(22);

  /// Factory reset
  @$pb.TagNumber(23)
  $core.int get factoryReset => $_getIZ(13);
  @$pb.TagNumber(23)
  set factoryReset($core.int v) { $_setSignedInt32(13, v); }
  @$pb.TagNumber(23)
  $core.bool hasFactoryReset() => $_has(13);
  @$pb.TagNumber(23)
  void clearFactoryReset() => clearField(23);

  /// Reset node database
  @$pb.TagNumber(24)
  $core.int get nodedbReset => $_getIZ(14);
  @$pb.TagNumber(24)
  set nodedbReset($core.int v) { $_setSignedInt32(14, v); }
  @$pb.TagNumber(24)
  $core.bool hasNodedbReset() => $_has(14);
  @$pb.TagNumber(24)
  void clearNodedbReset() => clearField(24);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
