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

import 'channel.pb.dart' as $0;
import 'config.pb.dart' as $1;
import 'mesh.pbenum.dart';
import 'module_config.pb.dart' as $2;
import 'portnums.pbenum.dart' as $4;
import 'telemetry.pb.dart' as $3;

export 'mesh.pbenum.dart';

/// *
///  Position data from GPS or other location source.
class Position extends $pb.GeneratedMessage {
  factory Position({
    $core.int? latitudeI,
    $core.int? longitudeI,
    $core.int? altitude,
    $core.int? time,
    $core.int? groundSpeed,
    $core.int? groundTrack,
    $core.int? satsInView,
    $core.int? precisionBits,
  }) {
    final $result = create();
    if (latitudeI != null) {
      $result.latitudeI = latitudeI;
    }
    if (longitudeI != null) {
      $result.longitudeI = longitudeI;
    }
    if (altitude != null) {
      $result.altitude = altitude;
    }
    if (time != null) {
      $result.time = time;
    }
    if (groundSpeed != null) {
      $result.groundSpeed = groundSpeed;
    }
    if (groundTrack != null) {
      $result.groundTrack = groundTrack;
    }
    if (satsInView != null) {
      $result.satsInView = satsInView;
    }
    if (precisionBits != null) {
      $result.precisionBits = precisionBits;
    }
    return $result;
  }
  Position._() : super();
  factory Position.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Position.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Position', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'latitudeI', $pb.PbFieldType.OSF3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'longitudeI', $pb.PbFieldType.OSF3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'altitude', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'time', $pb.PbFieldType.OF3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'groundSpeed', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'groundTrack', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'satsInView', $pb.PbFieldType.OU3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'precisionBits', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Position clone() => Position()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Position copyWith(void Function(Position) updates) => super.copyWith((message) => updates(message as Position)) as Position;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Position create() => Position._();
  Position createEmptyInstance() => create();
  static $pb.PbList<Position> createRepeated() => $pb.PbList<Position>();
  @$core.pragma('dart2js:noInline')
  static Position getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Position>(create);
  static Position? _defaultInstance;

  /// Latitude in degrees * 1e-7
  @$pb.TagNumber(1)
  $core.int get latitudeI => $_getIZ(0);
  @$pb.TagNumber(1)
  set latitudeI($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLatitudeI() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitudeI() => clearField(1);

  /// Longitude in degrees * 1e-7
  @$pb.TagNumber(2)
  $core.int get longitudeI => $_getIZ(1);
  @$pb.TagNumber(2)
  set longitudeI($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLongitudeI() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitudeI() => clearField(2);

  /// Altitude in meters above MSL
  @$pb.TagNumber(3)
  $core.int get altitude => $_getIZ(2);
  @$pb.TagNumber(3)
  set altitude($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAltitude() => $_has(2);
  @$pb.TagNumber(3)
  void clearAltitude() => clearField(3);

  /// Time the position was received (seconds since 1970)
  @$pb.TagNumber(4)
  $core.int get time => $_getIZ(3);
  @$pb.TagNumber(4)
  set time($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearTime() => clearField(4);

  /// Ground speed in km/h
  @$pb.TagNumber(5)
  $core.int get groundSpeed => $_getIZ(4);
  @$pb.TagNumber(5)
  set groundSpeed($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasGroundSpeed() => $_has(4);
  @$pb.TagNumber(5)
  void clearGroundSpeed() => clearField(5);

  /// Ground track in degrees
  @$pb.TagNumber(6)
  $core.int get groundTrack => $_getIZ(5);
  @$pb.TagNumber(6)
  set groundTrack($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasGroundTrack() => $_has(5);
  @$pb.TagNumber(6)
  void clearGroundTrack() => clearField(6);

  /// Number of satellites used in fix
  @$pb.TagNumber(7)
  $core.int get satsInView => $_getIZ(6);
  @$pb.TagNumber(7)
  set satsInView($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasSatsInView() => $_has(6);
  @$pb.TagNumber(7)
  void clearSatsInView() => clearField(7);

  /// Horizontal dilution of precision * 100
  @$pb.TagNumber(8)
  $core.int get precisionBits => $_getIZ(7);
  @$pb.TagNumber(8)
  set precisionBits($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasPrecisionBits() => $_has(7);
  @$pb.TagNumber(8)
  void clearPrecisionBits() => clearField(8);
}

/// *
///  User information for a node.
class User extends $pb.GeneratedMessage {
  factory User({
    $core.String? id,
    $core.String? longName,
    $core.String? shortName,
    $core.List<$core.int>? macaddr,
    HardwareModel? hwModel,
    $core.bool? isLicensed,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (longName != null) {
      $result.longName = longName;
    }
    if (shortName != null) {
      $result.shortName = shortName;
    }
    if (macaddr != null) {
      $result.macaddr = macaddr;
    }
    if (hwModel != null) {
      $result.hwModel = hwModel;
    }
    if (isLicensed != null) {
      $result.isLicensed = isLicensed;
    }
    return $result;
  }
  User._() : super();
  factory User.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory User.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'User', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'longName')
    ..aOS(3, _omitFieldNames ? '' : 'shortName')
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'macaddr', $pb.PbFieldType.OY)
    ..e<HardwareModel>(5, _omitFieldNames ? '' : 'hwModel', $pb.PbFieldType.OE, defaultOrMaker: HardwareModel.UNSET, valueOf: HardwareModel.valueOf, enumValues: HardwareModel.values)
    ..aOB(6, _omitFieldNames ? '' : 'isLicensed')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  User clone() => User()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  User copyWith(void Function(User) updates) => super.copyWith((message) => updates(message as User)) as User;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  User createEmptyInstance() => create();
  static $pb.PbList<User> createRepeated() => $pb.PbList<User>();
  @$core.pragma('dart2js:noInline')
  static User getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get longName => $_getSZ(1);
  @$pb.TagNumber(2)
  set longName($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLongName() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get shortName => $_getSZ(2);
  @$pb.TagNumber(3)
  set shortName($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasShortName() => $_has(2);
  @$pb.TagNumber(3)
  void clearShortName() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get macaddr => $_getN(3);
  @$pb.TagNumber(4)
  set macaddr($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMacaddr() => $_has(3);
  @$pb.TagNumber(4)
  void clearMacaddr() => clearField(4);

  @$pb.TagNumber(5)
  HardwareModel get hwModel => $_getN(4);
  @$pb.TagNumber(5)
  set hwModel(HardwareModel v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasHwModel() => $_has(4);
  @$pb.TagNumber(5)
  void clearHwModel() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isLicensed => $_getBF(5);
  @$pb.TagNumber(6)
  set isLicensed($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsLicensed() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsLicensed() => clearField(6);
}

/// *
///  The data payload within a MeshPacket.
class Data extends $pb.GeneratedMessage {
  factory Data({
    $4.PortNum? portnum,
    $core.List<$core.int>? payload,
    $core.bool? wantResponse,
    $core.int? dest,
    $core.int? source,
    $core.int? requestId,
    $core.int? replyId,
    $core.int? emoji,
  }) {
    final $result = create();
    if (portnum != null) {
      $result.portnum = portnum;
    }
    if (payload != null) {
      $result.payload = payload;
    }
    if (wantResponse != null) {
      $result.wantResponse = wantResponse;
    }
    if (dest != null) {
      $result.dest = dest;
    }
    if (source != null) {
      $result.source = source;
    }
    if (requestId != null) {
      $result.requestId = requestId;
    }
    if (replyId != null) {
      $result.replyId = replyId;
    }
    if (emoji != null) {
      $result.emoji = emoji;
    }
    return $result;
  }
  Data._() : super();
  factory Data.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Data.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Data', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..e<$4.PortNum>(1, _omitFieldNames ? '' : 'portnum', $pb.PbFieldType.OE, defaultOrMaker: $4.PortNum.UNKNOWN_APP, valueOf: $4.PortNum.valueOf, enumValues: $4.PortNum.values)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aOB(3, _omitFieldNames ? '' : 'wantResponse')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'dest', $pb.PbFieldType.OF3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'source', $pb.PbFieldType.OF3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OF3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'replyId', $pb.PbFieldType.OF3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'emoji', $pb.PbFieldType.OF3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Data clone() => Data()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Data copyWith(void Function(Data) updates) => super.copyWith((message) => updates(message as Data)) as Data;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Data create() => Data._();
  Data createEmptyInstance() => create();
  static $pb.PbList<Data> createRepeated() => $pb.PbList<Data>();
  @$core.pragma('dart2js:noInline')
  static Data getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Data>(create);
  static Data? _defaultInstance;

  /// Port number for routing
  @$pb.TagNumber(1)
  $4.PortNum get portnum => $_getN(0);
  @$pb.TagNumber(1)
  set portnum($4.PortNum v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPortnum() => $_has(0);
  @$pb.TagNumber(1)
  void clearPortnum() => clearField(1);

  /// The actual payload bytes
  @$pb.TagNumber(2)
  $core.List<$core.int> get payload => $_getN(1);
  @$pb.TagNumber(2)
  set payload($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayload() => clearField(2);

  /// Whether the payload needs to be decoded as protobuf
  @$pb.TagNumber(3)
  $core.bool get wantResponse => $_getBF(2);
  @$pb.TagNumber(3)
  set wantResponse($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWantResponse() => $_has(2);
  @$pb.TagNumber(3)
  void clearWantResponse() => clearField(3);

  /// Destination node for response
  @$pb.TagNumber(4)
  $core.int get dest => $_getIZ(3);
  @$pb.TagNumber(4)
  set dest($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDest() => $_has(3);
  @$pb.TagNumber(4)
  void clearDest() => clearField(4);

  /// Source node
  @$pb.TagNumber(5)
  $core.int get source => $_getIZ(4);
  @$pb.TagNumber(5)
  set source($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSource() => $_has(4);
  @$pb.TagNumber(5)
  void clearSource() => clearField(5);

  /// Unique ID for deduplication
  @$pb.TagNumber(6)
  $core.int get requestId => $_getIZ(5);
  @$pb.TagNumber(6)
  set requestId($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasRequestId() => $_has(5);
  @$pb.TagNumber(6)
  void clearRequestId() => clearField(6);

  /// Reply ID for response matching
  @$pb.TagNumber(7)
  $core.int get replyId => $_getIZ(6);
  @$pb.TagNumber(7)
  set replyId($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasReplyId() => $_has(6);
  @$pb.TagNumber(7)
  void clearReplyId() => clearField(7);

  /// Emoji flag
  @$pb.TagNumber(8)
  $core.int get emoji => $_getIZ(7);
  @$pb.TagNumber(8)
  set emoji($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasEmoji() => $_has(7);
  @$pb.TagNumber(8)
  void clearEmoji() => clearField(8);
}

enum MeshPacket_PayloadVariant {
  decoded, 
  encrypted, 
  notSet
}

/// *
///  A mesh network packet.
class MeshPacket extends $pb.GeneratedMessage {
  factory MeshPacket({
    $core.int? from,
    $core.int? to,
    $core.int? channel,
    Data? decoded,
    $core.List<$core.int>? encrypted,
    $core.int? id,
    $core.int? rxTime,
    $core.double? rxSnr,
    $core.int? hopLimit,
    $core.bool? wantAck,
    MeshPacket_Priority? priority,
    $core.int? rxRssi,
  }) {
    final $result = create();
    if (from != null) {
      $result.from = from;
    }
    if (to != null) {
      $result.to = to;
    }
    if (channel != null) {
      $result.channel = channel;
    }
    if (decoded != null) {
      $result.decoded = decoded;
    }
    if (encrypted != null) {
      $result.encrypted = encrypted;
    }
    if (id != null) {
      $result.id = id;
    }
    if (rxTime != null) {
      $result.rxTime = rxTime;
    }
    if (rxSnr != null) {
      $result.rxSnr = rxSnr;
    }
    if (hopLimit != null) {
      $result.hopLimit = hopLimit;
    }
    if (wantAck != null) {
      $result.wantAck = wantAck;
    }
    if (priority != null) {
      $result.priority = priority;
    }
    if (rxRssi != null) {
      $result.rxRssi = rxRssi;
    }
    return $result;
  }
  MeshPacket._() : super();
  factory MeshPacket.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MeshPacket.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, MeshPacket_PayloadVariant> _MeshPacket_PayloadVariantByTag = {
    4 : MeshPacket_PayloadVariant.decoded,
    5 : MeshPacket_PayloadVariant.encrypted,
    0 : MeshPacket_PayloadVariant.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MeshPacket', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..oo(0, [4, 5])
    ..a<$core.int>(1, _omitFieldNames ? '' : 'from', $pb.PbFieldType.OF3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'to', $pb.PbFieldType.OF3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'channel', $pb.PbFieldType.OU3)
    ..aOM<Data>(4, _omitFieldNames ? '' : 'decoded', subBuilder: Data.create)
    ..a<$core.List<$core.int>>(5, _omitFieldNames ? '' : 'encrypted', $pb.PbFieldType.OY)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OF3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'rxTime', $pb.PbFieldType.OF3)
    ..a<$core.double>(8, _omitFieldNames ? '' : 'rxSnr', $pb.PbFieldType.OF)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'hopLimit', $pb.PbFieldType.OU3)
    ..aOB(10, _omitFieldNames ? '' : 'wantAck')
    ..e<MeshPacket_Priority>(11, _omitFieldNames ? '' : 'priority', $pb.PbFieldType.OE, defaultOrMaker: MeshPacket_Priority.UNSET, valueOf: MeshPacket_Priority.valueOf, enumValues: MeshPacket_Priority.values)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'rxRssi', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MeshPacket clone() => MeshPacket()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MeshPacket copyWith(void Function(MeshPacket) updates) => super.copyWith((message) => updates(message as MeshPacket)) as MeshPacket;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeshPacket create() => MeshPacket._();
  MeshPacket createEmptyInstance() => create();
  static $pb.PbList<MeshPacket> createRepeated() => $pb.PbList<MeshPacket>();
  @$core.pragma('dart2js:noInline')
  static MeshPacket getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MeshPacket>(create);
  static MeshPacket? _defaultInstance;

  MeshPacket_PayloadVariant whichPayloadVariant() => _MeshPacket_PayloadVariantByTag[$_whichOneof(0)]!;
  void clearPayloadVariant() => clearField($_whichOneof(0));

  /// Sender node number
  @$pb.TagNumber(1)
  $core.int get from => $_getIZ(0);
  @$pb.TagNumber(1)
  set from($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFrom() => $_has(0);
  @$pb.TagNumber(1)
  void clearFrom() => clearField(1);

  /// Destination node number (0xFFFFFFFF for broadcast)
  @$pb.TagNumber(2)
  $core.int get to => $_getIZ(1);
  @$pb.TagNumber(2)
  set to($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTo() => $_has(1);
  @$pb.TagNumber(2)
  void clearTo() => clearField(2);

  /// Channel index
  @$pb.TagNumber(3)
  $core.int get channel => $_getIZ(2);
  @$pb.TagNumber(3)
  set channel($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasChannel() => $_has(2);
  @$pb.TagNumber(3)
  void clearChannel() => clearField(3);

  @$pb.TagNumber(4)
  Data get decoded => $_getN(3);
  @$pb.TagNumber(4)
  set decoded(Data v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasDecoded() => $_has(3);
  @$pb.TagNumber(4)
  void clearDecoded() => clearField(4);
  @$pb.TagNumber(4)
  Data ensureDecoded() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.List<$core.int> get encrypted => $_getN(4);
  @$pb.TagNumber(5)
  set encrypted($core.List<$core.int> v) { $_setBytes(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasEncrypted() => $_has(4);
  @$pb.TagNumber(5)
  void clearEncrypted() => clearField(5);

  /// Unique packet ID (non-zero, used for deduplication)
  @$pb.TagNumber(6)
  $core.int get id => $_getIZ(5);
  @$pb.TagNumber(6)
  set id($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasId() => $_has(5);
  @$pb.TagNumber(6)
  void clearId() => clearField(6);

  /// Time packet was received (seconds since 1970)
  @$pb.TagNumber(7)
  $core.int get rxTime => $_getIZ(6);
  @$pb.TagNumber(7)
  set rxTime($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasRxTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearRxTime() => clearField(7);

  /// Signal-to-noise ratio
  @$pb.TagNumber(8)
  $core.double get rxSnr => $_getN(7);
  @$pb.TagNumber(8)
  set rxSnr($core.double v) { $_setFloat(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasRxSnr() => $_has(7);
  @$pb.TagNumber(8)
  void clearRxSnr() => clearField(8);

  /// Hop limit
  @$pb.TagNumber(9)
  $core.int get hopLimit => $_getIZ(8);
  @$pb.TagNumber(9)
  set hopLimit($core.int v) { $_setUnsignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasHopLimit() => $_has(8);
  @$pb.TagNumber(9)
  void clearHopLimit() => clearField(9);

  /// Whether this packet needs an ACK
  @$pb.TagNumber(10)
  $core.bool get wantAck => $_getBF(9);
  @$pb.TagNumber(10)
  set wantAck($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasWantAck() => $_has(9);
  @$pb.TagNumber(10)
  void clearWantAck() => clearField(10);

  /// Priority level
  @$pb.TagNumber(11)
  MeshPacket_Priority get priority => $_getN(10);
  @$pb.TagNumber(11)
  set priority(MeshPacket_Priority v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasPriority() => $_has(10);
  @$pb.TagNumber(11)
  void clearPriority() => clearField(11);

  /// Received signal strength indicator
  @$pb.TagNumber(12)
  $core.int get rxRssi => $_getIZ(11);
  @$pb.TagNumber(12)
  set rxRssi($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasRxRssi() => $_has(11);
  @$pb.TagNumber(12)
  void clearRxRssi() => clearField(12);
}

/// *
///  Information about the local node.
class MyNodeInfo extends $pb.GeneratedMessage {
  factory MyNodeInfo({
    $core.int? myNodeNum,
    $core.String? firmwareVersion,
    $core.int? rebootCount,
    $core.int? minAppVersion,
  }) {
    final $result = create();
    if (myNodeNum != null) {
      $result.myNodeNum = myNodeNum;
    }
    if (firmwareVersion != null) {
      $result.firmwareVersion = firmwareVersion;
    }
    if (rebootCount != null) {
      $result.rebootCount = rebootCount;
    }
    if (minAppVersion != null) {
      $result.minAppVersion = minAppVersion;
    }
    return $result;
  }
  MyNodeInfo._() : super();
  factory MyNodeInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MyNodeInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyNodeInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'myNodeNum', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'firmwareVersion')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'rebootCount', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'minAppVersion', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MyNodeInfo clone() => MyNodeInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MyNodeInfo copyWith(void Function(MyNodeInfo) updates) => super.copyWith((message) => updates(message as MyNodeInfo)) as MyNodeInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MyNodeInfo create() => MyNodeInfo._();
  MyNodeInfo createEmptyInstance() => create();
  static $pb.PbList<MyNodeInfo> createRepeated() => $pb.PbList<MyNodeInfo>();
  @$core.pragma('dart2js:noInline')
  static MyNodeInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MyNodeInfo>(create);
  static MyNodeInfo? _defaultInstance;

  /// The node number assigned to this device
  @$pb.TagNumber(1)
  $core.int get myNodeNum => $_getIZ(0);
  @$pb.TagNumber(1)
  set myNodeNum($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMyNodeNum() => $_has(0);
  @$pb.TagNumber(1)
  void clearMyNodeNum() => clearField(1);

  /// Firmware version string
  @$pb.TagNumber(2)
  $core.String get firmwareVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set firmwareVersion($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFirmwareVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearFirmwareVersion() => clearField(2);

  /// Reboot count
  @$pb.TagNumber(3)
  $core.int get rebootCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set rebootCount($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRebootCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearRebootCount() => clearField(3);

  /// Minimum app version supported
  @$pb.TagNumber(4)
  $core.int get minAppVersion => $_getIZ(3);
  @$pb.TagNumber(4)
  set minAppVersion($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMinAppVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearMinAppVersion() => clearField(4);
}

/// *
///  Node information database entry.
class NodeInfo extends $pb.GeneratedMessage {
  factory NodeInfo({
    $core.int? num,
    User? user,
    Position? position,
    $core.double? snr,
    $core.int? lastHeard,
    $3.DeviceMetrics? deviceMetrics,
  }) {
    final $result = create();
    if (num != null) {
      $result.num = num;
    }
    if (user != null) {
      $result.user = user;
    }
    if (position != null) {
      $result.position = position;
    }
    if (snr != null) {
      $result.snr = snr;
    }
    if (lastHeard != null) {
      $result.lastHeard = lastHeard;
    }
    if (deviceMetrics != null) {
      $result.deviceMetrics = deviceMetrics;
    }
    return $result;
  }
  NodeInfo._() : super();
  factory NodeInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NodeInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NodeInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'num', $pb.PbFieldType.OU3)
    ..aOM<User>(2, _omitFieldNames ? '' : 'user', subBuilder: User.create)
    ..aOM<Position>(3, _omitFieldNames ? '' : 'position', subBuilder: Position.create)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'snr', $pb.PbFieldType.OF)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'lastHeard', $pb.PbFieldType.OF3)
    ..aOM<$3.DeviceMetrics>(6, _omitFieldNames ? '' : 'deviceMetrics', subBuilder: $3.DeviceMetrics.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NodeInfo clone() => NodeInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NodeInfo copyWith(void Function(NodeInfo) updates) => super.copyWith((message) => updates(message as NodeInfo)) as NodeInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NodeInfo create() => NodeInfo._();
  NodeInfo createEmptyInstance() => create();
  static $pb.PbList<NodeInfo> createRepeated() => $pb.PbList<NodeInfo>();
  @$core.pragma('dart2js:noInline')
  static NodeInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NodeInfo>(create);
  static NodeInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get num => $_getIZ(0);
  @$pb.TagNumber(1)
  set num($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNum() => $_has(0);
  @$pb.TagNumber(1)
  void clearNum() => clearField(1);

  @$pb.TagNumber(2)
  User get user => $_getN(1);
  @$pb.TagNumber(2)
  set user(User v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasUser() => $_has(1);
  @$pb.TagNumber(2)
  void clearUser() => clearField(2);
  @$pb.TagNumber(2)
  User ensureUser() => $_ensure(1);

  @$pb.TagNumber(3)
  Position get position => $_getN(2);
  @$pb.TagNumber(3)
  set position(Position v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPosition() => $_has(2);
  @$pb.TagNumber(3)
  void clearPosition() => clearField(3);
  @$pb.TagNumber(3)
  Position ensurePosition() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.double get snr => $_getN(3);
  @$pb.TagNumber(4)
  set snr($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSnr() => $_has(3);
  @$pb.TagNumber(4)
  void clearSnr() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get lastHeard => $_getIZ(4);
  @$pb.TagNumber(5)
  set lastHeard($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasLastHeard() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastHeard() => clearField(5);

  @$pb.TagNumber(6)
  $3.DeviceMetrics get deviceMetrics => $_getN(5);
  @$pb.TagNumber(6)
  set deviceMetrics($3.DeviceMetrics v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasDeviceMetrics() => $_has(5);
  @$pb.TagNumber(6)
  void clearDeviceMetrics() => clearField(6);
  @$pb.TagNumber(6)
  $3.DeviceMetrics ensureDeviceMetrics() => $_ensure(5);
}

enum ToRadio_PayloadVariant {
  packet, 
  wantConfigId, 
  disconnect, 
  notSet
}

/// *
///  Wrapper for all messages sent TO the radio.
class ToRadio extends $pb.GeneratedMessage {
  factory ToRadio({
    MeshPacket? packet,
    $core.int? wantConfigId,
    $core.bool? disconnect,
  }) {
    final $result = create();
    if (packet != null) {
      $result.packet = packet;
    }
    if (wantConfigId != null) {
      $result.wantConfigId = wantConfigId;
    }
    if (disconnect != null) {
      $result.disconnect = disconnect;
    }
    return $result;
  }
  ToRadio._() : super();
  factory ToRadio.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ToRadio.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, ToRadio_PayloadVariant> _ToRadio_PayloadVariantByTag = {
    1 : ToRadio_PayloadVariant.packet,
    3 : ToRadio_PayloadVariant.wantConfigId,
    4 : ToRadio_PayloadVariant.disconnect,
    0 : ToRadio_PayloadVariant.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ToRadio', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..oo(0, [1, 3, 4])
    ..aOM<MeshPacket>(1, _omitFieldNames ? '' : 'packet', subBuilder: MeshPacket.create)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'wantConfigId', $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'disconnect')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ToRadio clone() => ToRadio()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ToRadio copyWith(void Function(ToRadio) updates) => super.copyWith((message) => updates(message as ToRadio)) as ToRadio;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ToRadio create() => ToRadio._();
  ToRadio createEmptyInstance() => create();
  static $pb.PbList<ToRadio> createRepeated() => $pb.PbList<ToRadio>();
  @$core.pragma('dart2js:noInline')
  static ToRadio getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ToRadio>(create);
  static ToRadio? _defaultInstance;

  ToRadio_PayloadVariant whichPayloadVariant() => _ToRadio_PayloadVariantByTag[$_whichOneof(0)]!;
  void clearPayloadVariant() => clearField($_whichOneof(0));

  /// Send a mesh packet
  @$pb.TagNumber(1)
  MeshPacket get packet => $_getN(0);
  @$pb.TagNumber(1)
  set packet(MeshPacket v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPacket() => $_has(0);
  @$pb.TagNumber(1)
  void clearPacket() => clearField(1);
  @$pb.TagNumber(1)
  MeshPacket ensurePacket() => $_ensure(0);

  /// Request config from radio (random ID for handshake)
  @$pb.TagNumber(3)
  $core.int get wantConfigId => $_getIZ(1);
  @$pb.TagNumber(3)
  set wantConfigId($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(3)
  $core.bool hasWantConfigId() => $_has(1);
  @$pb.TagNumber(3)
  void clearWantConfigId() => clearField(3);

  /// Disconnect cleanly from radio
  @$pb.TagNumber(4)
  $core.bool get disconnect => $_getBF(2);
  @$pb.TagNumber(4)
  set disconnect($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(4)
  $core.bool hasDisconnect() => $_has(2);
  @$pb.TagNumber(4)
  void clearDisconnect() => clearField(4);
}

enum FromRadio_PayloadVariant {
  packet, 
  myInfo, 
  nodeInfo, 
  config, 
  moduleConfig, 
  channel, 
  configCompleteId, 
  notSet
}

/// *
///  Wrapper for all messages received FROM the radio.
class FromRadio extends $pb.GeneratedMessage {
  factory FromRadio({
    $core.int? id,
    MeshPacket? packet,
    MyNodeInfo? myInfo,
    NodeInfo? nodeInfo,
    $1.Config? config,
    $2.ModuleConfig? moduleConfig,
    $0.Channel? channel,
    $core.int? configCompleteId,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (packet != null) {
      $result.packet = packet;
    }
    if (myInfo != null) {
      $result.myInfo = myInfo;
    }
    if (nodeInfo != null) {
      $result.nodeInfo = nodeInfo;
    }
    if (config != null) {
      $result.config = config;
    }
    if (moduleConfig != null) {
      $result.moduleConfig = moduleConfig;
    }
    if (channel != null) {
      $result.channel = channel;
    }
    if (configCompleteId != null) {
      $result.configCompleteId = configCompleteId;
    }
    return $result;
  }
  FromRadio._() : super();
  factory FromRadio.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FromRadio.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, FromRadio_PayloadVariant> _FromRadio_PayloadVariantByTag = {
    2 : FromRadio_PayloadVariant.packet,
    3 : FromRadio_PayloadVariant.myInfo,
    4 : FromRadio_PayloadVariant.nodeInfo,
    5 : FromRadio_PayloadVariant.config,
    6 : FromRadio_PayloadVariant.moduleConfig,
    7 : FromRadio_PayloadVariant.channel,
    8 : FromRadio_PayloadVariant.configCompleteId,
    0 : FromRadio_PayloadVariant.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FromRadio', package: const $pb.PackageName(_omitMessageNames ? '' : 'meshtastic'), createEmptyInstance: create)
    ..oo(0, [2, 3, 4, 5, 6, 7, 8])
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OU3)
    ..aOM<MeshPacket>(2, _omitFieldNames ? '' : 'packet', subBuilder: MeshPacket.create)
    ..aOM<MyNodeInfo>(3, _omitFieldNames ? '' : 'myInfo', subBuilder: MyNodeInfo.create)
    ..aOM<NodeInfo>(4, _omitFieldNames ? '' : 'nodeInfo', subBuilder: NodeInfo.create)
    ..aOM<$1.Config>(5, _omitFieldNames ? '' : 'config', subBuilder: $1.Config.create)
    ..aOM<$2.ModuleConfig>(6, _omitFieldNames ? '' : 'moduleConfig', protoName: 'moduleConfig', subBuilder: $2.ModuleConfig.create)
    ..aOM<$0.Channel>(7, _omitFieldNames ? '' : 'channel', subBuilder: $0.Channel.create)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'configCompleteId', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FromRadio clone() => FromRadio()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FromRadio copyWith(void Function(FromRadio) updates) => super.copyWith((message) => updates(message as FromRadio)) as FromRadio;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FromRadio create() => FromRadio._();
  FromRadio createEmptyInstance() => create();
  static $pb.PbList<FromRadio> createRepeated() => $pb.PbList<FromRadio>();
  @$core.pragma('dart2js:noInline')
  static FromRadio getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FromRadio>(create);
  static FromRadio? _defaultInstance;

  FromRadio_PayloadVariant whichPayloadVariant() => _FromRadio_PayloadVariantByTag[$_whichOneof(0)]!;
  void clearPayloadVariant() => clearField($_whichOneof(0));

  /// Unique ID for this message
  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  /// A received mesh packet
  @$pb.TagNumber(2)
  MeshPacket get packet => $_getN(1);
  @$pb.TagNumber(2)
  set packet(MeshPacket v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPacket() => $_has(1);
  @$pb.TagNumber(2)
  void clearPacket() => clearField(2);
  @$pb.TagNumber(2)
  MeshPacket ensurePacket() => $_ensure(1);

  /// Local node info (during handshake)
  @$pb.TagNumber(3)
  MyNodeInfo get myInfo => $_getN(2);
  @$pb.TagNumber(3)
  set myInfo(MyNodeInfo v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasMyInfo() => $_has(2);
  @$pb.TagNumber(3)
  void clearMyInfo() => clearField(3);
  @$pb.TagNumber(3)
  MyNodeInfo ensureMyInfo() => $_ensure(2);

  /// Node database entry
  @$pb.TagNumber(4)
  NodeInfo get nodeInfo => $_getN(3);
  @$pb.TagNumber(4)
  set nodeInfo(NodeInfo v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasNodeInfo() => $_has(3);
  @$pb.TagNumber(4)
  void clearNodeInfo() => clearField(4);
  @$pb.TagNumber(4)
  NodeInfo ensureNodeInfo() => $_ensure(3);

  /// Config data (during handshake)
  @$pb.TagNumber(5)
  $1.Config get config => $_getN(4);
  @$pb.TagNumber(5)
  set config($1.Config v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfig() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfig() => clearField(5);
  @$pb.TagNumber(5)
  $1.Config ensureConfig() => $_ensure(4);

  /// Module config data
  @$pb.TagNumber(6)
  $2.ModuleConfig get moduleConfig => $_getN(5);
  @$pb.TagNumber(6)
  set moduleConfig($2.ModuleConfig v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasModuleConfig() => $_has(5);
  @$pb.TagNumber(6)
  void clearModuleConfig() => clearField(6);
  @$pb.TagNumber(6)
  $2.ModuleConfig ensureModuleConfig() => $_ensure(5);

  /// Channel data
  @$pb.TagNumber(7)
  $0.Channel get channel => $_getN(6);
  @$pb.TagNumber(7)
  set channel($0.Channel v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasChannel() => $_has(6);
  @$pb.TagNumber(7)
  void clearChannel() => clearField(7);
  @$pb.TagNumber(7)
  $0.Channel ensureChannel() => $_ensure(6);

  /// Config complete signal (value matches want_config_id)
  @$pb.TagNumber(8)
  $core.int get configCompleteId => $_getIZ(7);
  @$pb.TagNumber(8)
  set configCompleteId($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasConfigCompleteId() => $_has(7);
  @$pb.TagNumber(8)
  void clearConfigCompleteId() => clearField(8);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
