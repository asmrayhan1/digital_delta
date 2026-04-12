// This is a generated file - do not edit.
//
// Generated from mesh.proto.

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unnecessary_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'mesh.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'mesh.pbenum.dart';

// ═══════════════════════════════════════════════════════════════
// LedgerEntry
// ═══════════════════════════════════════════════════════════════
class LedgerEntry extends $pb.GeneratedMessage {
  factory LedgerEntry({
    $core.String? id,
    EntryType? type,
    $core.List<$core.int>? payload,
    $core.String? senderId,
    $core.String? receiverId,
    $fixnum.Int64? timestamp,
    $core.String? prevHash,
    $core.String? currentHash,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (payload != null) result.payload = payload;
    if (senderId != null) result.senderId = senderId;
    if (receiverId != null) result.receiverId = receiverId;
    if (timestamp != null) result.timestamp = timestamp;
    if (prevHash != null) result.prevHash = prevHash;
    if (currentHash != null) result.currentHash = currentHash;
    return result;
  }

  LedgerEntry._();

  factory LedgerEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LedgerEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<EntryType>(2, _omitFieldNames ? '' : 'type', enumValues: EntryType.values)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aOS(4, _omitFieldNames ? '' : 'senderId')
    ..aOS(5, _omitFieldNames ? '' : 'receiverId')
    ..aInt64(6, _omitFieldNames ? '' : 'timestamp')
    ..aOS(7, _omitFieldNames ? '' : 'prevHash')
    ..aOS(8, _omitFieldNames ? '' : 'currentHash')
    ..hasRequiredFields = false;

  @$core.override
  LedgerEntry clone() => LedgerEntry()..mergeFromMessage(this);
  @$core.override
  LedgerEntry copyWith(void Function(LedgerEntry) updates) =>
      super.copyWith((message) => updates(message as LedgerEntry)) as LedgerEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LedgerEntry create() => LedgerEntry._();
  @$core.override
  LedgerEntry createEmptyInstance() => create();
  static LedgerEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LedgerEntry>(create);
  static LedgerEntry? _defaultInstance;

  @$pb.TagNumber(1) $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1) set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1) $core.bool hasId() => $_has(0);

  @$pb.TagNumber(2) EntryType get type => $_getN(1);
  @$pb.TagNumber(2) set type(EntryType value) => $_setField(2, value);
  @$pb.TagNumber(2) $core.bool hasType() => $_has(1);

  @$pb.TagNumber(3) $core.List<$core.int> get payload => $_getN(2);
  @$pb.TagNumber(3) set payload($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3) $core.bool hasPayload() => $_has(2);

  @$pb.TagNumber(4) $core.String get senderId => $_getSZ(3);
  @$pb.TagNumber(4) set senderId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4) $core.bool hasSenderId() => $_has(3);

  @$pb.TagNumber(5) $core.String get receiverId => $_getSZ(4);
  @$pb.TagNumber(5) set receiverId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5) $core.bool hasReceiverId() => $_has(4);

  @$pb.TagNumber(6) $fixnum.Int64 get timestamp => $_getI64(5);
  @$pb.TagNumber(6) set timestamp($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6) $core.bool hasTimestamp() => $_has(5);

  @$pb.TagNumber(7) $core.String get prevHash => $_getSZ(6);
  @$pb.TagNumber(7) set prevHash($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7) $core.bool hasPrevHash() => $_has(6);

  @$pb.TagNumber(8) $core.String get currentHash => $_getSZ(7);
  @$pb.TagNumber(8) set currentHash($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8) $core.bool hasCurrentHash() => $_has(7);
}

// ═══════════════════════════════════════════════════════════════
// SyncRequest
// ═══════════════════════════════════════════════════════════════
class SyncRequest extends $pb.GeneratedMessage {
  factory SyncRequest({$core.String? lastKnownHash}) {
    final result = create();
    if (lastKnownHash != null) result.lastKnownHash = lastKnownHash;
    return result;
  }
  SyncRequest._();
  factory SyncRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'lastKnownHash')
    ..hasRequiredFields = false;

  @$core.override SyncRequest clone() => SyncRequest()..mergeFromMessage(this);
  @$core.override SyncRequest copyWith(void Function(SyncRequest) updates) =>
      super.copyWith((message) => updates(message as SyncRequest)) as SyncRequest;
  @$core.override $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline') static SyncRequest create() => SyncRequest._();
  @$core.override SyncRequest createEmptyInstance() => create();
  static SyncRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncRequest>(create);
  static SyncRequest? _defaultInstance;

  @$pb.TagNumber(1) $core.String get lastKnownHash => $_getSZ(0);
  @$pb.TagNumber(1) set lastKnownHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1) $core.bool hasLastKnownHash() => $_has(0);
}

// ═══════════════════════════════════════════════════════════════
// SyncResponse
// ═══════════════════════════════════════════════════════════════
class SyncResponse extends $pb.GeneratedMessage {
  factory SyncResponse({$core.Iterable<LedgerEntry>? entries}) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    return result;
  }
  SyncResponse._();
  factory SyncResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh'),
      createEmptyInstance: create)
    ..pPM<LedgerEntry>(1, _omitFieldNames ? '' : 'entries', subBuilder: LedgerEntry.create)
    ..hasRequiredFields = false;

  @$core.override SyncResponse clone() => SyncResponse()..mergeFromMessage(this);
  @$core.override SyncResponse copyWith(void Function(SyncResponse) updates) =>
      super.copyWith((message) => updates(message as SyncResponse)) as SyncResponse;
  @$core.override $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline') static SyncResponse create() => SyncResponse._();
  @$core.override SyncResponse createEmptyInstance() => create();
  static SyncResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncResponse>(create);
  static SyncResponse? _defaultInstance;

  @$pb.TagNumber(1) $pb.PbList<LedgerEntry> get entries => $_getList(0);
}

// ═══════════════════════════════════════════════════════════════
// VectorClock
// ═══════════════════════════════════════════════════════════════
class VectorClock extends $pb.GeneratedMessage {
  factory VectorClock({$core.Map<$core.String, $fixnum.Int64>? clocks}) {
    final result = create();
    if (clocks != null) result.clocks.addAll(clocks);
    return result;
  }
  VectorClock._();
  factory VectorClock.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VectorClock',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh'),
      createEmptyInstance: create)
    ..m<$core.String, $fixnum.Int64>(1, _omitFieldNames ? '' : 'clocks',
        entryClassName: 'VectorClock.ClocksEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O6)
    ..hasRequiredFields = false;

  @$core.override VectorClock clone() => VectorClock()..mergeFromMessage(this);
  @$core.override VectorClock copyWith(void Function(VectorClock) updates) =>
      super.copyWith((message) => updates(message as VectorClock)) as VectorClock;
  @$core.override $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline') static VectorClock create() => VectorClock._();
  @$core.override VectorClock createEmptyInstance() => create();
  static VectorClock getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VectorClock>(create);
  static VectorClock? _defaultInstance;

  @$pb.TagNumber(1) $core.Map<$core.String, $fixnum.Int64> get clocks => $_getMap(0);
}

// ═══════════════════════════════════════════════════════════════
// CrdtEntry
// ═══════════════════════════════════════════════════════════════
class CrdtEntry extends $pb.GeneratedMessage {
  factory CrdtEntry({
    $core.String? id, $core.String? fieldName, $core.String? value,
    $fixnum.Int64? hlcTimestamp, $core.String? nodeId, VectorClock? vectorClock,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fieldName != null) result.fieldName = fieldName;
    if (value != null) result.value = value;
    if (hlcTimestamp != null) result.hlcTimestamp = hlcTimestamp;
    if (nodeId != null) result.nodeId = nodeId;
    if (vectorClock != null) result.vectorClock = vectorClock;
    return result;
  }
  CrdtEntry._();
  factory CrdtEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CrdtEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fieldName')
    ..aOS(3, _omitFieldNames ? '' : 'value')
    ..aInt64(4, _omitFieldNames ? '' : 'hlcTimestamp')
    ..aOS(5, _omitFieldNames ? '' : 'nodeId')
    ..aOM<VectorClock>(6, _omitFieldNames ? '' : 'vectorClock', subBuilder: VectorClock.create)
    ..hasRequiredFields = false;

  @$core.override CrdtEntry clone() => CrdtEntry()..mergeFromMessage(this);
  @$core.override CrdtEntry copyWith(void Function(CrdtEntry) updates) =>
      super.copyWith((message) => updates(message as CrdtEntry)) as CrdtEntry;
  @$core.override $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline') static CrdtEntry create() => CrdtEntry._();
  @$core.override CrdtEntry createEmptyInstance() => create();
  static CrdtEntry getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CrdtEntry>(create);
  static CrdtEntry? _defaultInstance;

  @$pb.TagNumber(1) $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1) set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(2) $core.String get fieldName => $_getSZ(1);
  @$pb.TagNumber(2) set fieldName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(3) $core.String get value => $_getSZ(2);
  @$pb.TagNumber(3) set value($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4) $fixnum.Int64 get hlcTimestamp => $_getI64(3);
  @$pb.TagNumber(4) set hlcTimestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(5) $core.String get nodeId => $_getSZ(4);
  @$pb.TagNumber(5) set nodeId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(6) VectorClock get vectorClock => $_getN(5);
  @$pb.TagNumber(6) set vectorClock(VectorClock value) => $_setField(6, value);
  @$pb.TagNumber(6) $core.bool hasVectorClock() => $_has(5);
  @$pb.TagNumber(6) VectorClock ensureVectorClock() => $_ensure(5);
}

// ═══════════════════════════════════════════════════════════════
// CrdtSyncRequest
// ═══════════════════════════════════════════════════════════════
class CrdtSyncRequest extends $pb.GeneratedMessage {
  factory CrdtSyncRequest({VectorClock? senderClock}) {
    final result = create();
    if (senderClock != null) result.senderClock = senderClock;
    return result;
  }
  CrdtSyncRequest._();
  factory CrdtSyncRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CrdtSyncRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh'),
      createEmptyInstance: create)
    ..aOM<VectorClock>(1, _omitFieldNames ? '' : 'senderClock', subBuilder: VectorClock.create)
    ..hasRequiredFields = false;

  @$core.override CrdtSyncRequest clone() => CrdtSyncRequest()..mergeFromMessage(this);
  @$core.override CrdtSyncRequest copyWith(void Function(CrdtSyncRequest) updates) =>
      super.copyWith((message) => updates(message as CrdtSyncRequest)) as CrdtSyncRequest;
  @$core.override $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline') static CrdtSyncRequest create() => CrdtSyncRequest._();
  @$core.override CrdtSyncRequest createEmptyInstance() => create();
  static CrdtSyncRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CrdtSyncRequest>(create);
  static CrdtSyncRequest? _defaultInstance;

  @$pb.TagNumber(1) VectorClock get senderClock => $_getN(0);
  @$pb.TagNumber(1) set senderClock(VectorClock value) => $_setField(1, value);
  @$pb.TagNumber(1) $core.bool hasSenderClock() => $_has(0);
  @$pb.TagNumber(1) VectorClock ensureSenderClock() => $_ensure(0);
}

// ═══════════════════════════════════════════════════════════════
// CrdtSyncResponse
// ═══════════════════════════════════════════════════════════════
class CrdtSyncResponse extends $pb.GeneratedMessage {
  factory CrdtSyncResponse({$core.Iterable<CrdtEntry>? entries, VectorClock? senderClock}) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    if (senderClock != null) result.senderClock = senderClock;
    return result;
  }
  CrdtSyncResponse._();
  factory CrdtSyncResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CrdtSyncResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh'),
      createEmptyInstance: create)
    ..pPM<CrdtEntry>(1, _omitFieldNames ? '' : 'entries', subBuilder: CrdtEntry.create)
    ..aOM<VectorClock>(2, _omitFieldNames ? '' : 'senderClock', subBuilder: VectorClock.create)
    ..hasRequiredFields = false;

  @$core.override CrdtSyncResponse clone() => CrdtSyncResponse()..mergeFromMessage(this);
  @$core.override CrdtSyncResponse copyWith(void Function(CrdtSyncResponse) updates) =>
      super.copyWith((message) => updates(message as CrdtSyncResponse)) as CrdtSyncResponse;
  @$core.override $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline') static CrdtSyncResponse create() => CrdtSyncResponse._();
  @$core.override CrdtSyncResponse createEmptyInstance() => create();
  static CrdtSyncResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CrdtSyncResponse>(create);
  static CrdtSyncResponse? _defaultInstance;

  @$pb.TagNumber(1) $pb.PbList<CrdtEntry> get entries => $_getList(0);
  @$pb.TagNumber(2) VectorClock get senderClock => $_getN(1);
  @$pb.TagNumber(2) set senderClock(VectorClock value) => $_setField(2, value);
  @$pb.TagNumber(2) $core.bool hasSenderClock() => $_has(1);
  @$pb.TagNumber(2) VectorClock ensureSenderClock() => $_ensure(1);
}

// ═══════════════════════════════════════════════════════════════
// MeshMessage
// ═══════════════════════════════════════════════════════════════
class MeshMessage extends $pb.GeneratedMessage {
  factory MeshMessage({
    $core.String? messageId, $core.String? sourceId, $core.String? destinationId,
    $core.List<$core.int>? encryptedPayload, $core.int? ttl,
    $core.Iterable<$core.String>? hopList, $fixnum.Int64? createdAt,
    $core.List<$core.int>? senderPublicKey,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (sourceId != null) result.sourceId = sourceId;
    if (destinationId != null) result.destinationId = destinationId;
    if (encryptedPayload != null) result.encryptedPayload = encryptedPayload;
    if (ttl != null) result.ttl = ttl;
    if (hopList != null) result.hopList.addAll(hopList);
    if (createdAt != null) result.createdAt = createdAt;
    if (senderPublicKey != null) result.senderPublicKey = senderPublicKey;
    return result;
  }
  MeshMessage._();
  factory MeshMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeshMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOS(2, _omitFieldNames ? '' : 'sourceId')
    ..aOS(3, _omitFieldNames ? '' : 'destinationId')
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'encryptedPayload', $pb.PbFieldType.OY)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'ttl', $pb.PbFieldType.O3)
    ..pPS(6, _omitFieldNames ? '' : 'hopList')
    ..aInt64(7, _omitFieldNames ? '' : 'createdAt')
    ..a<$core.List<$core.int>>(8, _omitFieldNames ? '' : 'senderPublicKey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.override MeshMessage clone() => MeshMessage()..mergeFromMessage(this);
  @$core.override MeshMessage copyWith(void Function(MeshMessage) updates) =>
      super.copyWith((message) => updates(message as MeshMessage)) as MeshMessage;
  @$core.override $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline') static MeshMessage create() => MeshMessage._();
  @$core.override MeshMessage createEmptyInstance() => create();
  static MeshMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MeshMessage>(create);
  static MeshMessage? _defaultInstance;

  @$pb.TagNumber(1) $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1) set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(2) $core.String get sourceId => $_getSZ(1);
  @$pb.TagNumber(2) set sourceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(3) $core.String get destinationId => $_getSZ(2);
  @$pb.TagNumber(3) set destinationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4) $core.List<$core.int> get encryptedPayload => $_getN(3);
  @$pb.TagNumber(4) set encryptedPayload($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(5) $core.int get ttl => $_getIZ(4);
  @$pb.TagNumber(5) set ttl($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(6) $core.List<$core.String> get hopList => $_getList(5);
  @$pb.TagNumber(7) $fixnum.Int64 get createdAt => $_getI64(6);
  @$pb.TagNumber(7) set createdAt($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(8) $core.List<$core.int> get senderPublicKey => $_getN(7);
  @$pb.TagNumber(8) set senderPublicKey($core.List<$core.int> value) => $_setBytes(7, value);
}

// ═══════════════════════════════════════════════════════════════
// NodeInfo
// ═══════════════════════════════════════════════════════════════
class NodeInfo extends $pb.GeneratedMessage {
  factory NodeInfo({
    $core.String? nodeId, $core.String? deviceName, $core.String? role,
    $core.int? batteryLevel, $core.int? signalStrength,
    $core.List<$core.int>? publicKey,
  }) {
    final result = create();
    if (nodeId != null) result.nodeId = nodeId;
    if (deviceName != null) result.deviceName = deviceName;
    if (role != null) result.role = role;
    if (batteryLevel != null) result.batteryLevel = batteryLevel;
    if (signalStrength != null) result.signalStrength = signalStrength;
    if (publicKey != null) result.publicKey = publicKey;
    return result;
  }
  NodeInfo._();
  factory NodeInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nodeId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceName')
    ..aOS(3, _omitFieldNames ? '' : 'role')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'batteryLevel', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'signalStrength', $pb.PbFieldType.O3)
    ..a<$core.List<$core.int>>(6, _omitFieldNames ? '' : 'publicKey', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.override NodeInfo clone() => NodeInfo()..mergeFromMessage(this);
  @$core.override NodeInfo copyWith(void Function(NodeInfo) updates) =>
      super.copyWith((message) => updates(message as NodeInfo)) as NodeInfo;
  @$core.override $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline') static NodeInfo create() => NodeInfo._();
  @$core.override NodeInfo createEmptyInstance() => create();
  static NodeInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NodeInfo>(create);
  static NodeInfo? _defaultInstance;

  @$pb.TagNumber(1) $core.String get nodeId => $_getSZ(0);
  @$pb.TagNumber(1) set nodeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(2) $core.String get deviceName => $_getSZ(1);
  @$pb.TagNumber(2) set deviceName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(3) $core.String get role => $_getSZ(2);
  @$pb.TagNumber(3) set role($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4) $core.int get batteryLevel => $_getIZ(3);
  @$pb.TagNumber(4) set batteryLevel($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(5) $core.int get signalStrength => $_getIZ(4);
  @$pb.TagNumber(5) set signalStrength($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(6) $core.List<$core.int> get publicKey => $_getN(5);
  @$pb.TagNumber(6) set publicKey($core.List<$core.int> value) => $_setBytes(5, value);
}

// ═══════════════════════════════════════════════════════════════
// MeshEnvelope
// ═══════════════════════════════════════════════════════════════
class MeshEnvelope extends $pb.GeneratedMessage {
  factory MeshEnvelope({
    MeshEnvelope_PayloadType? type,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (data != null) result.data = data;
    return result;
  }
  MeshEnvelope._();
  factory MeshEnvelope.fromBuffer($core.List<$core.int> data_,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data_, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeshEnvelope',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh'),
      createEmptyInstance: create)
    ..aE<MeshEnvelope_PayloadType>(1, _omitFieldNames ? '' : 'type',
        enumValues: MeshEnvelope_PayloadType.values)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.override MeshEnvelope clone() => MeshEnvelope()..mergeFromMessage(this);
  @$core.override MeshEnvelope copyWith(void Function(MeshEnvelope) updates) =>
      super.copyWith((message) => updates(message as MeshEnvelope)) as MeshEnvelope;
  @$core.override $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline') static MeshEnvelope create() => MeshEnvelope._();
  @$core.override MeshEnvelope createEmptyInstance() => create();
  static MeshEnvelope getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MeshEnvelope>(create);
  static MeshEnvelope? _defaultInstance;

  @$pb.TagNumber(1) MeshEnvelope_PayloadType get type => $_getN(0);
  @$pb.TagNumber(1) set type(MeshEnvelope_PayloadType value) => $_setField(1, value);
  @$pb.TagNumber(1) $core.bool hasType() => $_has(0);
  @$pb.TagNumber(2) $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2) set data($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2) $core.bool hasData() => $_has(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
