///
//  Generated code. Do not modify.
//  source: proto/img_syncer.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'img_syncer.pb.dart' as $0;
export 'img_syncer.pb.dart';

class ImgSyncerClient extends $grpc.Client {
  static final _$hello = $grpc.ClientMethod<$0.HelloRequest, $0.HelloResponse>(
      '/img_syncer.ImgSyncer/Hello',
      ($0.HelloRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.HelloResponse.fromBuffer(value));
  static final _$upload =
      $grpc.ClientMethod<$0.UploadRequest, $0.UploadResponse>(
          '/img_syncer.ImgSyncer/Upload',
          ($0.UploadRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.UploadResponse.fromBuffer(value));
  static final _$get = $grpc.ClientMethod<$0.GetRequest, $0.GetResponse>(
      '/img_syncer.ImgSyncer/Get',
      ($0.GetRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetResponse.fromBuffer(value));
  static final _$getThumbnail =
      $grpc.ClientMethod<$0.GetThumbnailRequest, $0.GetThumbnailResponse>(
          '/img_syncer.ImgSyncer/GetThumbnail',
          ($0.GetThumbnailRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.GetThumbnailResponse.fromBuffer(value));
  static final _$listByDate =
      $grpc.ClientMethod<$0.ListByDateRequest, $0.ListByDateResponse>(
          '/img_syncer.ImgSyncer/ListByDate',
          ($0.ListByDateRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.ListByDateResponse.fromBuffer(value));
  static final _$delete =
      $grpc.ClientMethod<$0.DeleteRequest, $0.DeleteResponse>(
          '/img_syncer.ImgSyncer/Delete',
          ($0.DeleteRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.DeleteResponse.fromBuffer(value));
  static final _$filterNotUploaded = $grpc.ClientMethod<
          $0.FilterNotUploadedRequest, $0.FilterNotUploadedResponse>(
      '/img_syncer.ImgSyncer/FilterNotUploaded',
      ($0.FilterNotUploadedRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.FilterNotUploadedResponse.fromBuffer(value));
  static final _$setDriveSMB =
      $grpc.ClientMethod<$0.SetDriveSMBRequest, $0.SetDriveSMBResponse>(
          '/img_syncer.ImgSyncer/SetDriveSMB',
          ($0.SetDriveSMBRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.SetDriveSMBResponse.fromBuffer(value));
  static final _$listDriveSMBShares = $grpc.ClientMethod<
          $0.ListDriveSMBSharesRequest, $0.ListDriveSMBSharesResponse>(
      '/img_syncer.ImgSyncer/ListDriveSMBShares',
      ($0.ListDriveSMBSharesRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.ListDriveSMBSharesResponse.fromBuffer(value));
  static final _$listDriveSMBDir =
      $grpc.ClientMethod<$0.ListDriveSMBDirRequest, $0.ListDriveSMBDirResponse>(
          '/img_syncer.ImgSyncer/ListDriveSMBDir',
          ($0.ListDriveSMBDirRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.ListDriveSMBDirResponse.fromBuffer(value));
  static final _$setDriveSMBShare = $grpc.ClientMethod<
          $0.SetDriveSMBShareRequest, $0.SetDriveSMBShareResponse>(
      '/img_syncer.ImgSyncer/SetDriveSMBShare',
      ($0.SetDriveSMBShareRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.SetDriveSMBShareResponse.fromBuffer(value));
  static final _$setDriveWebdav =
      $grpc.ClientMethod<$0.SetDriveWebdavRequest, $0.SetDriveWebdavResponse>(
          '/img_syncer.ImgSyncer/SetDriveWebdav',
          ($0.SetDriveWebdavRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.SetDriveWebdavResponse.fromBuffer(value));
  static final _$listDriveWebdavDir = $grpc.ClientMethod<
          $0.ListDriveWebdavDirRequest, $0.ListDriveWebdavDirResponse>(
      '/img_syncer.ImgSyncer/ListDriveWebdavDir',
      ($0.ListDriveWebdavDirRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.ListDriveWebdavDirResponse.fromBuffer(value));

  ImgSyncerClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.HelloResponse> hello($0.HelloRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$hello, request, options: options);
  }

  $grpc.ResponseFuture<$0.UploadResponse> upload(
      $async.Stream<$0.UploadRequest> request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$upload, request, options: options).single;
  }

  $grpc.ResponseStream<$0.GetResponse> get($0.GetRequest request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$get, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.GetThumbnailResponse> getThumbnail(
      $0.GetThumbnailRequest request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$getThumbnail, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.ListByDateResponse> listByDate(
      $0.ListByDateRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listByDate, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteResponse> delete($0.DeleteRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$delete, request, options: options);
  }

  $grpc.ResponseFuture<$0.FilterNotUploadedResponse> filterNotUploaded(
      $0.FilterNotUploadedRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$filterNotUploaded, request, options: options);
  }

  $grpc.ResponseFuture<$0.SetDriveSMBResponse> setDriveSMB(
      $0.SetDriveSMBRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setDriveSMB, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListDriveSMBSharesResponse> listDriveSMBShares(
      $0.ListDriveSMBSharesRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listDriveSMBShares, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListDriveSMBDirResponse> listDriveSMBDir(
      $0.ListDriveSMBDirRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listDriveSMBDir, request, options: options);
  }

  $grpc.ResponseFuture<$0.SetDriveSMBShareResponse> setDriveSMBShare(
      $0.SetDriveSMBShareRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setDriveSMBShare, request, options: options);
  }

  $grpc.ResponseFuture<$0.SetDriveWebdavResponse> setDriveWebdav(
      $0.SetDriveWebdavRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setDriveWebdav, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListDriveWebdavDirResponse> listDriveWebdavDir(
      $0.ListDriveWebdavDirRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listDriveWebdavDir, request, options: options);
  }
}

abstract class ImgSyncerServiceBase extends $grpc.Service {
  $core.String get $name => 'img_syncer.ImgSyncer';

  ImgSyncerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.HelloRequest, $0.HelloResponse>(
        'Hello',
        hello_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HelloRequest.fromBuffer(value),
        ($0.HelloResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UploadRequest, $0.UploadResponse>(
        'Upload',
        upload,
        true,
        false,
        ($core.List<$core.int> value) => $0.UploadRequest.fromBuffer(value),
        ($0.UploadResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetRequest, $0.GetResponse>(
        'Get',
        get_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.GetRequest.fromBuffer(value),
        ($0.GetResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetThumbnailRequest, $0.GetThumbnailResponse>(
            'GetThumbnail',
            getThumbnail_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.GetThumbnailRequest.fromBuffer(value),
            ($0.GetThumbnailResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListByDateRequest, $0.ListByDateResponse>(
        'ListByDate',
        listByDate_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListByDateRequest.fromBuffer(value),
        ($0.ListByDateResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteRequest, $0.DeleteResponse>(
        'Delete',
        delete_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteRequest.fromBuffer(value),
        ($0.DeleteResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FilterNotUploadedRequest,
            $0.FilterNotUploadedResponse>(
        'FilterNotUploaded',
        filterNotUploaded_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.FilterNotUploadedRequest.fromBuffer(value),
        ($0.FilterNotUploadedResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SetDriveSMBRequest, $0.SetDriveSMBResponse>(
            'SetDriveSMB',
            setDriveSMB_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SetDriveSMBRequest.fromBuffer(value),
            ($0.SetDriveSMBResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListDriveSMBSharesRequest,
            $0.ListDriveSMBSharesResponse>(
        'ListDriveSMBShares',
        listDriveSMBShares_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListDriveSMBSharesRequest.fromBuffer(value),
        ($0.ListDriveSMBSharesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListDriveSMBDirRequest,
            $0.ListDriveSMBDirResponse>(
        'ListDriveSMBDir',
        listDriveSMBDir_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListDriveSMBDirRequest.fromBuffer(value),
        ($0.ListDriveSMBDirResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetDriveSMBShareRequest,
            $0.SetDriveSMBShareResponse>(
        'SetDriveSMBShare',
        setDriveSMBShare_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetDriveSMBShareRequest.fromBuffer(value),
        ($0.SetDriveSMBShareResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetDriveWebdavRequest,
            $0.SetDriveWebdavResponse>(
        'SetDriveWebdav',
        setDriveWebdav_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetDriveWebdavRequest.fromBuffer(value),
        ($0.SetDriveWebdavResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListDriveWebdavDirRequest,
            $0.ListDriveWebdavDirResponse>(
        'ListDriveWebdavDir',
        listDriveWebdavDir_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListDriveWebdavDirRequest.fromBuffer(value),
        ($0.ListDriveWebdavDirResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.HelloResponse> hello_Pre(
      $grpc.ServiceCall call, $async.Future<$0.HelloRequest> request) async {
    return hello(call, await request);
  }

  $async.Stream<$0.GetResponse> get_Pre(
      $grpc.ServiceCall call, $async.Future<$0.GetRequest> request) async* {
    yield* get(call, await request);
  }

  $async.Stream<$0.GetThumbnailResponse> getThumbnail_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.GetThumbnailRequest> request) async* {
    yield* getThumbnail(call, await request);
  }

  $async.Future<$0.ListByDateResponse> listByDate_Pre($grpc.ServiceCall call,
      $async.Future<$0.ListByDateRequest> request) async {
    return listByDate(call, await request);
  }

  $async.Future<$0.DeleteResponse> delete_Pre(
      $grpc.ServiceCall call, $async.Future<$0.DeleteRequest> request) async {
    return delete(call, await request);
  }

  $async.Future<$0.FilterNotUploadedResponse> filterNotUploaded_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.FilterNotUploadedRequest> request) async {
    return filterNotUploaded(call, await request);
  }

  $async.Future<$0.SetDriveSMBResponse> setDriveSMB_Pre($grpc.ServiceCall call,
      $async.Future<$0.SetDriveSMBRequest> request) async {
    return setDriveSMB(call, await request);
  }

  $async.Future<$0.ListDriveSMBSharesResponse> listDriveSMBShares_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.ListDriveSMBSharesRequest> request) async {
    return listDriveSMBShares(call, await request);
  }

  $async.Future<$0.ListDriveSMBDirResponse> listDriveSMBDir_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.ListDriveSMBDirRequest> request) async {
    return listDriveSMBDir(call, await request);
  }

  $async.Future<$0.SetDriveSMBShareResponse> setDriveSMBShare_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.SetDriveSMBShareRequest> request) async {
    return setDriveSMBShare(call, await request);
  }

  $async.Future<$0.SetDriveWebdavResponse> setDriveWebdav_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.SetDriveWebdavRequest> request) async {
    return setDriveWebdav(call, await request);
  }

  $async.Future<$0.ListDriveWebdavDirResponse> listDriveWebdavDir_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.ListDriveWebdavDirRequest> request) async {
    return listDriveWebdavDir(call, await request);
  }

  $async.Future<$0.HelloResponse> hello(
      $grpc.ServiceCall call, $0.HelloRequest request);
  $async.Future<$0.UploadResponse> upload(
      $grpc.ServiceCall call, $async.Stream<$0.UploadRequest> request);
  $async.Stream<$0.GetResponse> get(
      $grpc.ServiceCall call, $0.GetRequest request);
  $async.Stream<$0.GetThumbnailResponse> getThumbnail(
      $grpc.ServiceCall call, $0.GetThumbnailRequest request);
  $async.Future<$0.ListByDateResponse> listByDate(
      $grpc.ServiceCall call, $0.ListByDateRequest request);
  $async.Future<$0.DeleteResponse> delete(
      $grpc.ServiceCall call, $0.DeleteRequest request);
  $async.Future<$0.FilterNotUploadedResponse> filterNotUploaded(
      $grpc.ServiceCall call, $0.FilterNotUploadedRequest request);
  $async.Future<$0.SetDriveSMBResponse> setDriveSMB(
      $grpc.ServiceCall call, $0.SetDriveSMBRequest request);
  $async.Future<$0.ListDriveSMBSharesResponse> listDriveSMBShares(
      $grpc.ServiceCall call, $0.ListDriveSMBSharesRequest request);
  $async.Future<$0.ListDriveSMBDirResponse> listDriveSMBDir(
      $grpc.ServiceCall call, $0.ListDriveSMBDirRequest request);
  $async.Future<$0.SetDriveSMBShareResponse> setDriveSMBShare(
      $grpc.ServiceCall call, $0.SetDriveSMBShareRequest request);
  $async.Future<$0.SetDriveWebdavResponse> setDriveWebdav(
      $grpc.ServiceCall call, $0.SetDriveWebdavRequest request);
  $async.Future<$0.ListDriveWebdavDirResponse> listDriveWebdavDir(
      $grpc.ServiceCall call, $0.ListDriveWebdavDirRequest request);
}
