// This is a generated file - do not edit.
//
// Generated from mesh.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'mesh.pb.dart' as $0;

export 'mesh.pb.dart';

@$pb.GrpcServiceName('mesh.MeshSyncService')
class MeshSyncServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  MeshSyncServiceClient(super.channel, {super.options, super.interceptors});

  /// Pull-based sync: Ask peer for entries after our last known hash
  $grpc.ResponseFuture<$0.SyncResponse> getUpdates(
    $0.SyncRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getUpdates, request, options: options);
  }

  // method descriptors

  static final _$getUpdates =
      $grpc.ClientMethod<$0.SyncRequest, $0.SyncResponse>(
          '/mesh.MeshSyncService/GetUpdates',
          ($0.SyncRequest value) => value.writeToBuffer(),
          $0.SyncResponse.fromBuffer);
}

@$pb.GrpcServiceName('mesh.MeshSyncService')
abstract class MeshSyncServiceBase extends $grpc.Service {
  $core.String get $name => 'mesh.MeshSyncService';

  MeshSyncServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SyncRequest, $0.SyncResponse>(
        'GetUpdates',
        getUpdates_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SyncRequest.fromBuffer(value),
        ($0.SyncResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.SyncResponse> getUpdates_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SyncRequest> $request) async {
    return getUpdates($call, await $request);
  }

  $async.Future<$0.SyncResponse> getUpdates(
      $grpc.ServiceCall call, $0.SyncRequest request);
}
