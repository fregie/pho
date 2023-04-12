///
//  Generated code. Do not modify.
//  source: proto/img_syncer.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class HelloRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'HelloRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..hasRequiredFields = false
  ;

  HelloRequest._() : super();
  factory HelloRequest({
    $core.String? name,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    return _result;
  }
  factory HelloRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HelloRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  HelloRequest clone() => HelloRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  HelloRequest copyWith(void Function(HelloRequest) updates) => super.copyWith((message) => updates(message as HelloRequest)) as HelloRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static HelloRequest create() => HelloRequest._();
  HelloRequest createEmptyInstance() => create();
  static $pb.PbList<HelloRequest> createRepeated() => $pb.PbList<HelloRequest>();
  @$core.pragma('dart2js:noInline')
  static HelloRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HelloRequest>(create);
  static HelloRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);
}

class HelloResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'HelloResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..hasRequiredFields = false
  ;

  HelloResponse._() : super();
  factory HelloResponse({
    $core.String? message,
  }) {
    final _result = create();
    if (message != null) {
      _result.message = message;
    }
    return _result;
  }
  factory HelloResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HelloResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  HelloResponse clone() => HelloResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  HelloResponse copyWith(void Function(HelloResponse) updates) => super.copyWith((message) => updates(message as HelloResponse)) as HelloResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static HelloResponse create() => HelloResponse._();
  HelloResponse createEmptyInstance() => create();
  static $pb.PbList<HelloResponse> createRepeated() => $pb.PbList<HelloResponse>();
  @$core.pragma('dart2js:noInline')
  static HelloResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HelloResponse>(create);
  static HelloResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);
}

class UploadRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'UploadRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'date')
    ..a<$core.List<$core.int>>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'thumbnailData', $pb.PbFieldType.OY, protoName: 'thumbnailData')
    ..hasRequiredFields = false
  ;

  UploadRequest._() : super();
  factory UploadRequest({
    $core.List<$core.int>? data,
    $core.String? name,
    $core.String? date,
    $core.List<$core.int>? thumbnailData,
  }) {
    final _result = create();
    if (data != null) {
      _result.data = data;
    }
    if (name != null) {
      _result.name = name;
    }
    if (date != null) {
      _result.date = date;
    }
    if (thumbnailData != null) {
      _result.thumbnailData = thumbnailData;
    }
    return _result;
  }
  factory UploadRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UploadRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UploadRequest clone() => UploadRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UploadRequest copyWith(void Function(UploadRequest) updates) => super.copyWith((message) => updates(message as UploadRequest)) as UploadRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static UploadRequest create() => UploadRequest._();
  UploadRequest createEmptyInstance() => create();
  static $pb.PbList<UploadRequest> createRepeated() => $pb.PbList<UploadRequest>();
  @$core.pragma('dart2js:noInline')
  static UploadRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UploadRequest>(create);
  static UploadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get date => $_getSZ(2);
  @$pb.TagNumber(3)
  set date($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearDate() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get thumbnailData => $_getN(3);
  @$pb.TagNumber(4)
  set thumbnailData($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasThumbnailData() => $_has(3);
  @$pb.TagNumber(4)
  void clearThumbnailData() => clearField(4);
}

class UploadResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'UploadResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..hasRequiredFields = false
  ;

  UploadResponse._() : super();
  factory UploadResponse({
    $core.bool? success,
    $core.String? message,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    return _result;
  }
  factory UploadResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UploadResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UploadResponse clone() => UploadResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UploadResponse copyWith(void Function(UploadResponse) updates) => super.copyWith((message) => updates(message as UploadResponse)) as UploadResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static UploadResponse create() => UploadResponse._();
  UploadResponse createEmptyInstance() => create();
  static $pb.PbList<UploadResponse> createRepeated() => $pb.PbList<UploadResponse>();
  @$core.pragma('dart2js:noInline')
  static UploadResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UploadResponse>(create);
  static UploadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

class GetRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'GetRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'path')
    ..hasRequiredFields = false
  ;

  GetRequest._() : super();
  factory GetRequest({
    $core.String? path,
  }) {
    final _result = create();
    if (path != null) {
      _result.path = path;
    }
    return _result;
  }
  factory GetRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetRequest clone() => GetRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetRequest copyWith(void Function(GetRequest) updates) => super.copyWith((message) => updates(message as GetRequest)) as GetRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetRequest create() => GetRequest._();
  GetRequest createEmptyInstance() => create();
  static $pb.PbList<GetRequest> createRepeated() => $pb.PbList<GetRequest>();
  @$core.pragma('dart2js:noInline')
  static GetRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetRequest>(create);
  static GetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => clearField(1);
}

class GetResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'GetResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  GetResponse._() : super();
  factory GetResponse({
    $core.bool? success,
    $core.String? message,
    $core.List<$core.int>? data,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    if (data != null) {
      _result.data = data;
    }
    return _result;
  }
  factory GetResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetResponse clone() => GetResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetResponse copyWith(void Function(GetResponse) updates) => super.copyWith((message) => updates(message as GetResponse)) as GetResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetResponse create() => GetResponse._();
  GetResponse createEmptyInstance() => create();
  static $pb.PbList<GetResponse> createRepeated() => $pb.PbList<GetResponse>();
  @$core.pragma('dart2js:noInline')
  static GetResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetResponse>(create);
  static GetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => clearField(3);
}

class GetThumbnailRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'GetThumbnailRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'path')
    ..hasRequiredFields = false
  ;

  GetThumbnailRequest._() : super();
  factory GetThumbnailRequest({
    $core.String? path,
  }) {
    final _result = create();
    if (path != null) {
      _result.path = path;
    }
    return _result;
  }
  factory GetThumbnailRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetThumbnailRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetThumbnailRequest clone() => GetThumbnailRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetThumbnailRequest copyWith(void Function(GetThumbnailRequest) updates) => super.copyWith((message) => updates(message as GetThumbnailRequest)) as GetThumbnailRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetThumbnailRequest create() => GetThumbnailRequest._();
  GetThumbnailRequest createEmptyInstance() => create();
  static $pb.PbList<GetThumbnailRequest> createRepeated() => $pb.PbList<GetThumbnailRequest>();
  @$core.pragma('dart2js:noInline')
  static GetThumbnailRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetThumbnailRequest>(create);
  static GetThumbnailRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => clearField(1);
}

class GetThumbnailResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'GetThumbnailResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..a<$core.List<$core.int>>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  GetThumbnailResponse._() : super();
  factory GetThumbnailResponse({
    $core.bool? success,
    $core.String? message,
    $core.List<$core.int>? data,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    if (data != null) {
      _result.data = data;
    }
    return _result;
  }
  factory GetThumbnailResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetThumbnailResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetThumbnailResponse clone() => GetThumbnailResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetThumbnailResponse copyWith(void Function(GetThumbnailResponse) updates) => super.copyWith((message) => updates(message as GetThumbnailResponse)) as GetThumbnailResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetThumbnailResponse create() => GetThumbnailResponse._();
  GetThumbnailResponse createEmptyInstance() => create();
  static $pb.PbList<GetThumbnailResponse> createRepeated() => $pb.PbList<GetThumbnailResponse>();
  @$core.pragma('dart2js:noInline')
  static GetThumbnailResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetThumbnailResponse>(create);
  static GetThumbnailResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => clearField(3);
}

class ListByDateRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ListByDateRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'date')
    ..a<$core.int>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'offset', $pb.PbFieldType.O3)
    ..a<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'maxReturn', $pb.PbFieldType.O3, protoName: 'maxReturn')
    ..hasRequiredFields = false
  ;

  ListByDateRequest._() : super();
  factory ListByDateRequest({
    $core.String? date,
    $core.int? offset,
    $core.int? maxReturn,
  }) {
    final _result = create();
    if (date != null) {
      _result.date = date;
    }
    if (offset != null) {
      _result.offset = offset;
    }
    if (maxReturn != null) {
      _result.maxReturn = maxReturn;
    }
    return _result;
  }
  factory ListByDateRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListByDateRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListByDateRequest clone() => ListByDateRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListByDateRequest copyWith(void Function(ListByDateRequest) updates) => super.copyWith((message) => updates(message as ListByDateRequest)) as ListByDateRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListByDateRequest create() => ListByDateRequest._();
  ListByDateRequest createEmptyInstance() => create();
  static $pb.PbList<ListByDateRequest> createRepeated() => $pb.PbList<ListByDateRequest>();
  @$core.pragma('dart2js:noInline')
  static ListByDateRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListByDateRequest>(create);
  static ListByDateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get offset => $_getIZ(1);
  @$pb.TagNumber(2)
  set offset($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearOffset() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get maxReturn => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxReturn($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMaxReturn() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxReturn() => clearField(3);
}

class ListByDateResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ListByDateResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..pPS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'paths')
    ..hasRequiredFields = false
  ;

  ListByDateResponse._() : super();
  factory ListByDateResponse({
    $core.bool? success,
    $core.String? message,
    $core.Iterable<$core.String>? paths,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    if (paths != null) {
      _result.paths.addAll(paths);
    }
    return _result;
  }
  factory ListByDateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListByDateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListByDateResponse clone() => ListByDateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListByDateResponse copyWith(void Function(ListByDateResponse) updates) => super.copyWith((message) => updates(message as ListByDateResponse)) as ListByDateResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListByDateResponse create() => ListByDateResponse._();
  ListByDateResponse createEmptyInstance() => create();
  static $pb.PbList<ListByDateResponse> createRepeated() => $pb.PbList<ListByDateResponse>();
  @$core.pragma('dart2js:noInline')
  static ListByDateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListByDateResponse>(create);
  static ListByDateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get paths => $_getList(2);
}

class DeleteRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'DeleteRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..pPS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'paths')
    ..hasRequiredFields = false
  ;

  DeleteRequest._() : super();
  factory DeleteRequest({
    $core.Iterable<$core.String>? paths,
  }) {
    final _result = create();
    if (paths != null) {
      _result.paths.addAll(paths);
    }
    return _result;
  }
  factory DeleteRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteRequest clone() => DeleteRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteRequest copyWith(void Function(DeleteRequest) updates) => super.copyWith((message) => updates(message as DeleteRequest)) as DeleteRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DeleteRequest create() => DeleteRequest._();
  DeleteRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteRequest> createRepeated() => $pb.PbList<DeleteRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteRequest>(create);
  static DeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get paths => $_getList(0);
}

class DeleteResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'DeleteResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..hasRequiredFields = false
  ;

  DeleteResponse._() : super();
  factory DeleteResponse({
    $core.bool? success,
    $core.String? message,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    return _result;
  }
  factory DeleteResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteResponse clone() => DeleteResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteResponse copyWith(void Function(DeleteResponse) updates) => super.copyWith((message) => updates(message as DeleteResponse)) as DeleteResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DeleteResponse create() => DeleteResponse._();
  DeleteResponse createEmptyInstance() => create();
  static $pb.PbList<DeleteResponse> createRepeated() => $pb.PbList<DeleteResponse>();
  @$core.pragma('dart2js:noInline')
  static DeleteResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteResponse>(create);
  static DeleteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

class FilterNotUploadedRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'FilterNotUploadedRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..pPS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'names')
    ..hasRequiredFields = false
  ;

  FilterNotUploadedRequest._() : super();
  factory FilterNotUploadedRequest({
    $core.Iterable<$core.String>? names,
  }) {
    final _result = create();
    if (names != null) {
      _result.names.addAll(names);
    }
    return _result;
  }
  factory FilterNotUploadedRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FilterNotUploadedRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FilterNotUploadedRequest clone() => FilterNotUploadedRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FilterNotUploadedRequest copyWith(void Function(FilterNotUploadedRequest) updates) => super.copyWith((message) => updates(message as FilterNotUploadedRequest)) as FilterNotUploadedRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FilterNotUploadedRequest create() => FilterNotUploadedRequest._();
  FilterNotUploadedRequest createEmptyInstance() => create();
  static $pb.PbList<FilterNotUploadedRequest> createRepeated() => $pb.PbList<FilterNotUploadedRequest>();
  @$core.pragma('dart2js:noInline')
  static FilterNotUploadedRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FilterNotUploadedRequest>(create);
  static FilterNotUploadedRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get names => $_getList(0);
}

class FilterNotUploadedResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'FilterNotUploadedResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..pPS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'notUploaed', protoName: 'notUploaed')
    ..hasRequiredFields = false
  ;

  FilterNotUploadedResponse._() : super();
  factory FilterNotUploadedResponse({
    $core.bool? success,
    $core.String? message,
    $core.Iterable<$core.String>? notUploaed,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    if (notUploaed != null) {
      _result.notUploaed.addAll(notUploaed);
    }
    return _result;
  }
  factory FilterNotUploadedResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FilterNotUploadedResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FilterNotUploadedResponse clone() => FilterNotUploadedResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FilterNotUploadedResponse copyWith(void Function(FilterNotUploadedResponse) updates) => super.copyWith((message) => updates(message as FilterNotUploadedResponse)) as FilterNotUploadedResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FilterNotUploadedResponse create() => FilterNotUploadedResponse._();
  FilterNotUploadedResponse createEmptyInstance() => create();
  static $pb.PbList<FilterNotUploadedResponse> createRepeated() => $pb.PbList<FilterNotUploadedResponse>();
  @$core.pragma('dart2js:noInline')
  static FilterNotUploadedResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FilterNotUploadedResponse>(create);
  static FilterNotUploadedResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get notUploaed => $_getList(2);
}

class SetDriveSMBRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SetDriveSMBRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'addr')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'username')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'password')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'share')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'root')
    ..hasRequiredFields = false
  ;

  SetDriveSMBRequest._() : super();
  factory SetDriveSMBRequest({
    $core.String? addr,
    $core.String? username,
    $core.String? password,
    $core.String? share,
    $core.String? root,
  }) {
    final _result = create();
    if (addr != null) {
      _result.addr = addr;
    }
    if (username != null) {
      _result.username = username;
    }
    if (password != null) {
      _result.password = password;
    }
    if (share != null) {
      _result.share = share;
    }
    if (root != null) {
      _result.root = root;
    }
    return _result;
  }
  factory SetDriveSMBRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetDriveSMBRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetDriveSMBRequest clone() => SetDriveSMBRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetDriveSMBRequest copyWith(void Function(SetDriveSMBRequest) updates) => super.copyWith((message) => updates(message as SetDriveSMBRequest)) as SetDriveSMBRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SetDriveSMBRequest create() => SetDriveSMBRequest._();
  SetDriveSMBRequest createEmptyInstance() => create();
  static $pb.PbList<SetDriveSMBRequest> createRepeated() => $pb.PbList<SetDriveSMBRequest>();
  @$core.pragma('dart2js:noInline')
  static SetDriveSMBRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetDriveSMBRequest>(create);
  static SetDriveSMBRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get addr => $_getSZ(0);
  @$pb.TagNumber(1)
  set addr($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddr() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get password => $_getSZ(2);
  @$pb.TagNumber(3)
  set password($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearPassword() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get share => $_getSZ(3);
  @$pb.TagNumber(4)
  set share($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasShare() => $_has(3);
  @$pb.TagNumber(4)
  void clearShare() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get root => $_getSZ(4);
  @$pb.TagNumber(5)
  set root($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasRoot() => $_has(4);
  @$pb.TagNumber(5)
  void clearRoot() => clearField(5);
}

class SetDriveSMBResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SetDriveSMBResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..hasRequiredFields = false
  ;

  SetDriveSMBResponse._() : super();
  factory SetDriveSMBResponse({
    $core.bool? success,
    $core.String? message,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    return _result;
  }
  factory SetDriveSMBResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetDriveSMBResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetDriveSMBResponse clone() => SetDriveSMBResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetDriveSMBResponse copyWith(void Function(SetDriveSMBResponse) updates) => super.copyWith((message) => updates(message as SetDriveSMBResponse)) as SetDriveSMBResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SetDriveSMBResponse create() => SetDriveSMBResponse._();
  SetDriveSMBResponse createEmptyInstance() => create();
  static $pb.PbList<SetDriveSMBResponse> createRepeated() => $pb.PbList<SetDriveSMBResponse>();
  @$core.pragma('dart2js:noInline')
  static SetDriveSMBResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetDriveSMBResponse>(create);
  static SetDriveSMBResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

class ListDriveSMBSharesRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ListDriveSMBSharesRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  ListDriveSMBSharesRequest._() : super();
  factory ListDriveSMBSharesRequest() => create();
  factory ListDriveSMBSharesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDriveSMBSharesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDriveSMBSharesRequest clone() => ListDriveSMBSharesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDriveSMBSharesRequest copyWith(void Function(ListDriveSMBSharesRequest) updates) => super.copyWith((message) => updates(message as ListDriveSMBSharesRequest)) as ListDriveSMBSharesRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListDriveSMBSharesRequest create() => ListDriveSMBSharesRequest._();
  ListDriveSMBSharesRequest createEmptyInstance() => create();
  static $pb.PbList<ListDriveSMBSharesRequest> createRepeated() => $pb.PbList<ListDriveSMBSharesRequest>();
  @$core.pragma('dart2js:noInline')
  static ListDriveSMBSharesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDriveSMBSharesRequest>(create);
  static ListDriveSMBSharesRequest? _defaultInstance;
}

class ListDriveSMBSharesResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ListDriveSMBSharesResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..pPS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'shares')
    ..hasRequiredFields = false
  ;

  ListDriveSMBSharesResponse._() : super();
  factory ListDriveSMBSharesResponse({
    $core.bool? success,
    $core.String? message,
    $core.Iterable<$core.String>? shares,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    if (shares != null) {
      _result.shares.addAll(shares);
    }
    return _result;
  }
  factory ListDriveSMBSharesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDriveSMBSharesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDriveSMBSharesResponse clone() => ListDriveSMBSharesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDriveSMBSharesResponse copyWith(void Function(ListDriveSMBSharesResponse) updates) => super.copyWith((message) => updates(message as ListDriveSMBSharesResponse)) as ListDriveSMBSharesResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListDriveSMBSharesResponse create() => ListDriveSMBSharesResponse._();
  ListDriveSMBSharesResponse createEmptyInstance() => create();
  static $pb.PbList<ListDriveSMBSharesResponse> createRepeated() => $pb.PbList<ListDriveSMBSharesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListDriveSMBSharesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDriveSMBSharesResponse>(create);
  static ListDriveSMBSharesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get shares => $_getList(2);
}

class ListDriveSMBDirRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ListDriveSMBDirRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'share')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'dir')
    ..hasRequiredFields = false
  ;

  ListDriveSMBDirRequest._() : super();
  factory ListDriveSMBDirRequest({
    $core.String? share,
    $core.String? dir,
  }) {
    final _result = create();
    if (share != null) {
      _result.share = share;
    }
    if (dir != null) {
      _result.dir = dir;
    }
    return _result;
  }
  factory ListDriveSMBDirRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDriveSMBDirRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDriveSMBDirRequest clone() => ListDriveSMBDirRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDriveSMBDirRequest copyWith(void Function(ListDriveSMBDirRequest) updates) => super.copyWith((message) => updates(message as ListDriveSMBDirRequest)) as ListDriveSMBDirRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListDriveSMBDirRequest create() => ListDriveSMBDirRequest._();
  ListDriveSMBDirRequest createEmptyInstance() => create();
  static $pb.PbList<ListDriveSMBDirRequest> createRepeated() => $pb.PbList<ListDriveSMBDirRequest>();
  @$core.pragma('dart2js:noInline')
  static ListDriveSMBDirRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDriveSMBDirRequest>(create);
  static ListDriveSMBDirRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get share => $_getSZ(0);
  @$pb.TagNumber(1)
  set share($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasShare() => $_has(0);
  @$pb.TagNumber(1)
  void clearShare() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get dir => $_getSZ(1);
  @$pb.TagNumber(2)
  set dir($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDir() => $_has(1);
  @$pb.TagNumber(2)
  void clearDir() => clearField(2);
}

class ListDriveSMBDirResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ListDriveSMBDirResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..pPS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'dirs')
    ..hasRequiredFields = false
  ;

  ListDriveSMBDirResponse._() : super();
  factory ListDriveSMBDirResponse({
    $core.bool? success,
    $core.String? message,
    $core.Iterable<$core.String>? dirs,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    if (dirs != null) {
      _result.dirs.addAll(dirs);
    }
    return _result;
  }
  factory ListDriveSMBDirResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDriveSMBDirResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDriveSMBDirResponse clone() => ListDriveSMBDirResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDriveSMBDirResponse copyWith(void Function(ListDriveSMBDirResponse) updates) => super.copyWith((message) => updates(message as ListDriveSMBDirResponse)) as ListDriveSMBDirResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListDriveSMBDirResponse create() => ListDriveSMBDirResponse._();
  ListDriveSMBDirResponse createEmptyInstance() => create();
  static $pb.PbList<ListDriveSMBDirResponse> createRepeated() => $pb.PbList<ListDriveSMBDirResponse>();
  @$core.pragma('dart2js:noInline')
  static ListDriveSMBDirResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDriveSMBDirResponse>(create);
  static ListDriveSMBDirResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get dirs => $_getList(2);
}

class SetDriveSMBShareRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SetDriveSMBShareRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'share')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'root')
    ..hasRequiredFields = false
  ;

  SetDriveSMBShareRequest._() : super();
  factory SetDriveSMBShareRequest({
    $core.String? share,
    $core.String? root,
  }) {
    final _result = create();
    if (share != null) {
      _result.share = share;
    }
    if (root != null) {
      _result.root = root;
    }
    return _result;
  }
  factory SetDriveSMBShareRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetDriveSMBShareRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetDriveSMBShareRequest clone() => SetDriveSMBShareRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetDriveSMBShareRequest copyWith(void Function(SetDriveSMBShareRequest) updates) => super.copyWith((message) => updates(message as SetDriveSMBShareRequest)) as SetDriveSMBShareRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SetDriveSMBShareRequest create() => SetDriveSMBShareRequest._();
  SetDriveSMBShareRequest createEmptyInstance() => create();
  static $pb.PbList<SetDriveSMBShareRequest> createRepeated() => $pb.PbList<SetDriveSMBShareRequest>();
  @$core.pragma('dart2js:noInline')
  static SetDriveSMBShareRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetDriveSMBShareRequest>(create);
  static SetDriveSMBShareRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get share => $_getSZ(0);
  @$pb.TagNumber(1)
  set share($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasShare() => $_has(0);
  @$pb.TagNumber(1)
  void clearShare() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get root => $_getSZ(1);
  @$pb.TagNumber(2)
  set root($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRoot() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoot() => clearField(2);
}

class SetDriveSMBShareResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SetDriveSMBShareResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..hasRequiredFields = false
  ;

  SetDriveSMBShareResponse._() : super();
  factory SetDriveSMBShareResponse({
    $core.bool? success,
    $core.String? message,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    return _result;
  }
  factory SetDriveSMBShareResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetDriveSMBShareResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetDriveSMBShareResponse clone() => SetDriveSMBShareResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetDriveSMBShareResponse copyWith(void Function(SetDriveSMBShareResponse) updates) => super.copyWith((message) => updates(message as SetDriveSMBShareResponse)) as SetDriveSMBShareResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SetDriveSMBShareResponse create() => SetDriveSMBShareResponse._();
  SetDriveSMBShareResponse createEmptyInstance() => create();
  static $pb.PbList<SetDriveSMBShareResponse> createRepeated() => $pb.PbList<SetDriveSMBShareResponse>();
  @$core.pragma('dart2js:noInline')
  static SetDriveSMBShareResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetDriveSMBShareResponse>(create);
  static SetDriveSMBShareResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

class SetDriveWebdavRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SetDriveWebdavRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'addr')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'username')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'password')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'root')
    ..hasRequiredFields = false
  ;

  SetDriveWebdavRequest._() : super();
  factory SetDriveWebdavRequest({
    $core.String? addr,
    $core.String? username,
    $core.String? password,
    $core.String? root,
  }) {
    final _result = create();
    if (addr != null) {
      _result.addr = addr;
    }
    if (username != null) {
      _result.username = username;
    }
    if (password != null) {
      _result.password = password;
    }
    if (root != null) {
      _result.root = root;
    }
    return _result;
  }
  factory SetDriveWebdavRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetDriveWebdavRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetDriveWebdavRequest clone() => SetDriveWebdavRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetDriveWebdavRequest copyWith(void Function(SetDriveWebdavRequest) updates) => super.copyWith((message) => updates(message as SetDriveWebdavRequest)) as SetDriveWebdavRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SetDriveWebdavRequest create() => SetDriveWebdavRequest._();
  SetDriveWebdavRequest createEmptyInstance() => create();
  static $pb.PbList<SetDriveWebdavRequest> createRepeated() => $pb.PbList<SetDriveWebdavRequest>();
  @$core.pragma('dart2js:noInline')
  static SetDriveWebdavRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetDriveWebdavRequest>(create);
  static SetDriveWebdavRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get addr => $_getSZ(0);
  @$pb.TagNumber(1)
  set addr($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddr() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get password => $_getSZ(2);
  @$pb.TagNumber(3)
  set password($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearPassword() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get root => $_getSZ(3);
  @$pb.TagNumber(4)
  set root($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRoot() => $_has(3);
  @$pb.TagNumber(4)
  void clearRoot() => clearField(4);
}

class SetDriveWebdavResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SetDriveWebdavResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..hasRequiredFields = false
  ;

  SetDriveWebdavResponse._() : super();
  factory SetDriveWebdavResponse({
    $core.bool? success,
    $core.String? message,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    return _result;
  }
  factory SetDriveWebdavResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetDriveWebdavResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetDriveWebdavResponse clone() => SetDriveWebdavResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetDriveWebdavResponse copyWith(void Function(SetDriveWebdavResponse) updates) => super.copyWith((message) => updates(message as SetDriveWebdavResponse)) as SetDriveWebdavResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SetDriveWebdavResponse create() => SetDriveWebdavResponse._();
  SetDriveWebdavResponse createEmptyInstance() => create();
  static $pb.PbList<SetDriveWebdavResponse> createRepeated() => $pb.PbList<SetDriveWebdavResponse>();
  @$core.pragma('dart2js:noInline')
  static SetDriveWebdavResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetDriveWebdavResponse>(create);
  static SetDriveWebdavResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

class ListDriveWebdavDirRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ListDriveWebdavDirRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'dir')
    ..hasRequiredFields = false
  ;

  ListDriveWebdavDirRequest._() : super();
  factory ListDriveWebdavDirRequest({
    $core.String? dir,
  }) {
    final _result = create();
    if (dir != null) {
      _result.dir = dir;
    }
    return _result;
  }
  factory ListDriveWebdavDirRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDriveWebdavDirRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDriveWebdavDirRequest clone() => ListDriveWebdavDirRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDriveWebdavDirRequest copyWith(void Function(ListDriveWebdavDirRequest) updates) => super.copyWith((message) => updates(message as ListDriveWebdavDirRequest)) as ListDriveWebdavDirRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListDriveWebdavDirRequest create() => ListDriveWebdavDirRequest._();
  ListDriveWebdavDirRequest createEmptyInstance() => create();
  static $pb.PbList<ListDriveWebdavDirRequest> createRepeated() => $pb.PbList<ListDriveWebdavDirRequest>();
  @$core.pragma('dart2js:noInline')
  static ListDriveWebdavDirRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDriveWebdavDirRequest>(create);
  static ListDriveWebdavDirRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dir => $_getSZ(0);
  @$pb.TagNumber(1)
  set dir($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDir() => $_has(0);
  @$pb.TagNumber(1)
  void clearDir() => clearField(1);
}

class ListDriveWebdavDirResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ListDriveWebdavDirResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..pPS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'dirs')
    ..hasRequiredFields = false
  ;

  ListDriveWebdavDirResponse._() : super();
  factory ListDriveWebdavDirResponse({
    $core.bool? success,
    $core.String? message,
    $core.Iterable<$core.String>? dirs,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    if (dirs != null) {
      _result.dirs.addAll(dirs);
    }
    return _result;
  }
  factory ListDriveWebdavDirResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDriveWebdavDirResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDriveWebdavDirResponse clone() => ListDriveWebdavDirResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDriveWebdavDirResponse copyWith(void Function(ListDriveWebdavDirResponse) updates) => super.copyWith((message) => updates(message as ListDriveWebdavDirResponse)) as ListDriveWebdavDirResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListDriveWebdavDirResponse create() => ListDriveWebdavDirResponse._();
  ListDriveWebdavDirResponse createEmptyInstance() => create();
  static $pb.PbList<ListDriveWebdavDirResponse> createRepeated() => $pb.PbList<ListDriveWebdavDirResponse>();
  @$core.pragma('dart2js:noInline')
  static ListDriveWebdavDirResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDriveWebdavDirResponse>(create);
  static ListDriveWebdavDirResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get dirs => $_getList(2);
}

