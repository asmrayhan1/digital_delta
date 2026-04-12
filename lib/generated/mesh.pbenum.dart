// This is a generated file - do not edit.
//
// Generated from mesh.proto.

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class EntryType extends $pb.ProtobufEnum {
  static const EntryType MESSAGE =
      EntryType._(0, _omitEnumNames ? '' : 'MESSAGE');
  static const EntryType POST = EntryType._(1, _omitEnumNames ? '' : 'POST');

  static const $core.List<EntryType> values = <EntryType>[
    MESSAGE,
    POST,
  ];

  static final $core.List<EntryType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static EntryType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EntryType._(super.value, super.name);
}

class MeshEnvelope_PayloadType extends $pb.ProtobufEnum {
  static const MeshEnvelope_PayloadType SYNC_REQUEST =
      MeshEnvelope_PayloadType._(0, _omitEnumNames ? '' : 'SYNC_REQUEST');
  static const MeshEnvelope_PayloadType SYNC_RESPONSE =
      MeshEnvelope_PayloadType._(1, _omitEnumNames ? '' : 'SYNC_RESPONSE');
  static const MeshEnvelope_PayloadType MESH_MESSAGE =
      MeshEnvelope_PayloadType._(2, _omitEnumNames ? '' : 'MESH_MESSAGE');
  static const MeshEnvelope_PayloadType NODE_INFO =
      MeshEnvelope_PayloadType._(3, _omitEnumNames ? '' : 'NODE_INFO');
  static const MeshEnvelope_PayloadType CRDT_SYNC_REQUEST =
      MeshEnvelope_PayloadType._(4, _omitEnumNames ? '' : 'CRDT_SYNC_REQUEST');
  static const MeshEnvelope_PayloadType CRDT_SYNC_RESPONSE =
      MeshEnvelope_PayloadType._(5, _omitEnumNames ? '' : 'CRDT_SYNC_RESPONSE');

  static const $core.List<MeshEnvelope_PayloadType> values = <MeshEnvelope_PayloadType>[
    SYNC_REQUEST,
    SYNC_RESPONSE,
    MESH_MESSAGE,
    NODE_INFO,
    CRDT_SYNC_REQUEST,
    CRDT_SYNC_RESPONSE,
  ];

  static final $core.List<MeshEnvelope_PayloadType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static MeshEnvelope_PayloadType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MeshEnvelope_PayloadType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
