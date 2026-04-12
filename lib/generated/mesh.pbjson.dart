// This is a generated file - do not edit.
//
// Generated from mesh.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use entryTypeDescriptor instead')
const EntryType$json = {
  '1': 'EntryType',
  '2': [
    {'1': 'MESSAGE', '2': 0},
    {'1': 'POST', '2': 1},
  ],
};

/// Descriptor for `EntryType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List entryTypeDescriptor =
    $convert.base64Decode('CglFbnRyeVR5cGUSCwoHTUVTU0FHRRAAEggKBFBPU1QQAQ==');

@$core.Deprecated('Use ledgerEntryDescriptor instead')
const LedgerEntry$json = {
  '1': 'LedgerEntry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.mesh.EntryType',
      '10': 'type'
    },
    {'1': 'payload', '3': 3, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'sender_id', '3': 4, '4': 1, '5': 9, '10': 'senderId'},
    {'1': 'receiver_id', '3': 5, '4': 1, '5': 9, '10': 'receiverId'},
    {'1': 'timestamp', '3': 6, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'prev_hash', '3': 7, '4': 1, '5': 9, '10': 'prevHash'},
    {'1': 'current_hash', '3': 8, '4': 1, '5': 9, '10': 'currentHash'},
  ],
};

/// Descriptor for `LedgerEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ledgerEntryDescriptor = $convert.base64Decode(
    'CgtMZWRnZXJFbnRyeRIOCgJpZBgBIAEoCVICaWQSIwoEdHlwZRgCIAEoDjIPLm1lc2guRW50cn'
    'lUeXBlUgR0eXBlEhgKB3BheWxvYWQYAyABKAxSB3BheWxvYWQSGwoJc2VuZGVyX2lkGAQgASgJ'
    'UghzZW5kZXJJZBIfCgtyZWNlaXZlcl9pZBgFIAEoCVIKcmVjZWl2ZXJJZBIcCgl0aW1lc3RhbX'
    'AYBiABKANSCXRpbWVzdGFtcBIbCglwcmV2X2hhc2gYByABKAlSCHByZXZIYXNoEiEKDGN1cnJl'
    'bnRfaGFzaBgIIAEoCVILY3VycmVudEhhc2g=');

@$core.Deprecated('Use syncRequestDescriptor instead')
const SyncRequest$json = {
  '1': 'SyncRequest',
  '2': [
    {'1': 'last_known_hash', '3': 1, '4': 1, '5': 9, '10': 'lastKnownHash'},
  ],
};

/// Descriptor for `SyncRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncRequestDescriptor = $convert.base64Decode(
    'CgtTeW5jUmVxdWVzdBImCg9sYXN0X2tub3duX2hhc2gYASABKAlSDWxhc3RLbm93bkhhc2g=');

@$core.Deprecated('Use syncResponseDescriptor instead')
const SyncResponse$json = {
  '1': 'SyncResponse',
  '2': [
    {
      '1': 'entries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.mesh.LedgerEntry',
      '10': 'entries'
    },
  ],
};

/// Descriptor for `SyncResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncResponseDescriptor = $convert.base64Decode(
    'CgxTeW5jUmVzcG9uc2USKwoHZW50cmllcxgBIAMoCzIRLm1lc2guTGVkZ2VyRW50cnlSB2VudH'
    'JpZXM=');
