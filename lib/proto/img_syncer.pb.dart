///
//  Generated code. Do not modify.
//  source: proto/img_syncer.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

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

class FilterNotUploadedRequestInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'FilterNotUploadedRequestInfo', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'date')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id')
    ..hasRequiredFields = false
  ;

  FilterNotUploadedRequestInfo._() : super();
  factory FilterNotUploadedRequestInfo({
    $core.String? name,
    $core.String? date,
    $core.String? id,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    if (date != null) {
      _result.date = date;
    }
    if (id != null) {
      _result.id = id;
    }
    return _result;
  }
  factory FilterNotUploadedRequestInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FilterNotUploadedRequestInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FilterNotUploadedRequestInfo clone() => FilterNotUploadedRequestInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FilterNotUploadedRequestInfo copyWith(void Function(FilterNotUploadedRequestInfo) updates) => super.copyWith((message) => updates(message as FilterNotUploadedRequestInfo)) as FilterNotUploadedRequestInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FilterNotUploadedRequestInfo create() => FilterNotUploadedRequestInfo._();
  FilterNotUploadedRequestInfo createEmptyInstance() => create();
  static $pb.PbList<FilterNotUploadedRequestInfo> createRepeated() => $pb.PbList<FilterNotUploadedRequestInfo>();
  @$core.pragma('dart2js:noInline')
  static FilterNotUploadedRequestInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FilterNotUploadedRequestInfo>(create);
  static FilterNotUploadedRequestInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get date => $_getSZ(1);
  @$pb.TagNumber(2)
  set date($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearDate() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => clearField(3);
}

class FilterNotUploadedRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'FilterNotUploadedRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..pc<FilterNotUploadedRequestInfo>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'photos', $pb.PbFieldType.PM, subBuilder: FilterNotUploadedRequestInfo.create)
    ..aOB(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'isFinished', protoName: 'isFinished')
    ..hasRequiredFields = false
  ;

  FilterNotUploadedRequest._() : super();
  factory FilterNotUploadedRequest({
    $core.Iterable<FilterNotUploadedRequestInfo>? photos,
    $core.bool? isFinished,
  }) {
    final _result = create();
    if (photos != null) {
      _result.photos.addAll(photos);
    }
    if (isFinished != null) {
      _result.isFinished = isFinished;
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
  $core.List<FilterNotUploadedRequestInfo> get photos => $_getList(0);

  @$pb.TagNumber(2)
  $core.bool get isFinished => $_getBF(1);
  @$pb.TagNumber(2)
  set isFinished($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIsFinished() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsFinished() => clearField(2);
}

class FilterNotUploadedResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'FilterNotUploadedResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..pPS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'notUploaedIDs', protoName: 'notUploaedIDs')
    ..aOB(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'isFinished', protoName: 'isFinished')
    ..hasRequiredFields = false
  ;

  FilterNotUploadedResponse._() : super();
  factory FilterNotUploadedResponse({
    $core.bool? success,
    $core.String? message,
    $core.Iterable<$core.String>? notUploaedIDs,
    $core.bool? isFinished,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    if (notUploaedIDs != null) {
      _result.notUploaedIDs.addAll(notUploaedIDs);
    }
    if (isFinished != null) {
      _result.isFinished = isFinished;
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
  $core.List<$core.String> get notUploaedIDs => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get isFinished => $_getBF(3);
  @$pb.TagNumber(4)
  set isFinished($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsFinished() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsFinished() => clearField(4);
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

class SetDriveNFSRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SetDriveNFSRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'addr')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'root')
    ..hasRequiredFields = false
  ;

  SetDriveNFSRequest._() : super();
  factory SetDriveNFSRequest({
    $core.String? addr,
    $core.String? root,
  }) {
    final _result = create();
    if (addr != null) {
      _result.addr = addr;
    }
    if (root != null) {
      _result.root = root;
    }
    return _result;
  }
  factory SetDriveNFSRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetDriveNFSRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetDriveNFSRequest clone() => SetDriveNFSRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetDriveNFSRequest copyWith(void Function(SetDriveNFSRequest) updates) => super.copyWith((message) => updates(message as SetDriveNFSRequest)) as SetDriveNFSRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SetDriveNFSRequest create() => SetDriveNFSRequest._();
  SetDriveNFSRequest createEmptyInstance() => create();
  static $pb.PbList<SetDriveNFSRequest> createRepeated() => $pb.PbList<SetDriveNFSRequest>();
  @$core.pragma('dart2js:noInline')
  static SetDriveNFSRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetDriveNFSRequest>(create);
  static SetDriveNFSRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get addr => $_getSZ(0);
  @$pb.TagNumber(1)
  set addr($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddr() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddr() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get root => $_getSZ(1);
  @$pb.TagNumber(2)
  set root($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRoot() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoot() => clearField(2);
}

class SetDriveNFSResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SetDriveNFSResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..hasRequiredFields = false
  ;

  SetDriveNFSResponse._() : super();
  factory SetDriveNFSResponse({
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
  factory SetDriveNFSResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetDriveNFSResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetDriveNFSResponse clone() => SetDriveNFSResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetDriveNFSResponse copyWith(void Function(SetDriveNFSResponse) updates) => super.copyWith((message) => updates(message as SetDriveNFSResponse)) as SetDriveNFSResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SetDriveNFSResponse create() => SetDriveNFSResponse._();
  SetDriveNFSResponse createEmptyInstance() => create();
  static $pb.PbList<SetDriveNFSResponse> createRepeated() => $pb.PbList<SetDriveNFSResponse>();
  @$core.pragma('dart2js:noInline')
  static SetDriveNFSResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetDriveNFSResponse>(create);
  static SetDriveNFSResponse? _defaultInstance;

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

class ListDriveNFSDirRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ListDriveNFSDirRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'dir')
    ..hasRequiredFields = false
  ;

  ListDriveNFSDirRequest._() : super();
  factory ListDriveNFSDirRequest({
    $core.String? dir,
  }) {
    final _result = create();
    if (dir != null) {
      _result.dir = dir;
    }
    return _result;
  }
  factory ListDriveNFSDirRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDriveNFSDirRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDriveNFSDirRequest clone() => ListDriveNFSDirRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDriveNFSDirRequest copyWith(void Function(ListDriveNFSDirRequest) updates) => super.copyWith((message) => updates(message as ListDriveNFSDirRequest)) as ListDriveNFSDirRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListDriveNFSDirRequest create() => ListDriveNFSDirRequest._();
  ListDriveNFSDirRequest createEmptyInstance() => create();
  static $pb.PbList<ListDriveNFSDirRequest> createRepeated() => $pb.PbList<ListDriveNFSDirRequest>();
  @$core.pragma('dart2js:noInline')
  static ListDriveNFSDirRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDriveNFSDirRequest>(create);
  static ListDriveNFSDirRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get dir => $_getSZ(0);
  @$pb.TagNumber(1)
  set dir($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDir() => $_has(0);
  @$pb.TagNumber(1)
  void clearDir() => clearField(1);
}

class ListDriveNFSDirResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ListDriveNFSDirResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..pPS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'dirs')
    ..hasRequiredFields = false
  ;

  ListDriveNFSDirResponse._() : super();
  factory ListDriveNFSDirResponse({
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
  factory ListDriveNFSDirResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDriveNFSDirResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDriveNFSDirResponse clone() => ListDriveNFSDirResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDriveNFSDirResponse copyWith(void Function(ListDriveNFSDirResponse) updates) => super.copyWith((message) => updates(message as ListDriveNFSDirResponse)) as ListDriveNFSDirResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListDriveNFSDirResponse create() => ListDriveNFSDirResponse._();
  ListDriveNFSDirResponse createEmptyInstance() => create();
  static $pb.PbList<ListDriveNFSDirResponse> createRepeated() => $pb.PbList<ListDriveNFSDirResponse>();
  @$core.pragma('dart2js:noInline')
  static ListDriveNFSDirResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDriveNFSDirResponse>(create);
  static ListDriveNFSDirResponse? _defaultInstance;

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

class SetDriveBaiduNetDiskRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SetDriveBaiduNetDiskRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'refreshToken', protoName: 'refreshToken')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'accessToken', protoName: 'accessToken')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'tmpDir', protoName: 'tmpDir')
    ..hasRequiredFields = false
  ;

  SetDriveBaiduNetDiskRequest._() : super();
  factory SetDriveBaiduNetDiskRequest({
    $core.String? refreshToken,
    $core.String? accessToken,
    $core.String? tmpDir,
  }) {
    final _result = create();
    if (refreshToken != null) {
      _result.refreshToken = refreshToken;
    }
    if (accessToken != null) {
      _result.accessToken = accessToken;
    }
    if (tmpDir != null) {
      _result.tmpDir = tmpDir;
    }
    return _result;
  }
  factory SetDriveBaiduNetDiskRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetDriveBaiduNetDiskRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetDriveBaiduNetDiskRequest clone() => SetDriveBaiduNetDiskRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetDriveBaiduNetDiskRequest copyWith(void Function(SetDriveBaiduNetDiskRequest) updates) => super.copyWith((message) => updates(message as SetDriveBaiduNetDiskRequest)) as SetDriveBaiduNetDiskRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SetDriveBaiduNetDiskRequest create() => SetDriveBaiduNetDiskRequest._();
  SetDriveBaiduNetDiskRequest createEmptyInstance() => create();
  static $pb.PbList<SetDriveBaiduNetDiskRequest> createRepeated() => $pb.PbList<SetDriveBaiduNetDiskRequest>();
  @$core.pragma('dart2js:noInline')
  static SetDriveBaiduNetDiskRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetDriveBaiduNetDiskRequest>(create);
  static SetDriveBaiduNetDiskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get refreshToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set refreshToken($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRefreshToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearRefreshToken() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get accessToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set accessToken($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAccessToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccessToken() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get tmpDir => $_getSZ(2);
  @$pb.TagNumber(3)
  set tmpDir($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTmpDir() => $_has(2);
  @$pb.TagNumber(3)
  void clearTmpDir() => clearField(3);
}

class SetDriveBaiduNetDiskResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SetDriveBaiduNetDiskResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..hasRequiredFields = false
  ;

  SetDriveBaiduNetDiskResponse._() : super();
  factory SetDriveBaiduNetDiskResponse({
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
  factory SetDriveBaiduNetDiskResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetDriveBaiduNetDiskResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetDriveBaiduNetDiskResponse clone() => SetDriveBaiduNetDiskResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetDriveBaiduNetDiskResponse copyWith(void Function(SetDriveBaiduNetDiskResponse) updates) => super.copyWith((message) => updates(message as SetDriveBaiduNetDiskResponse)) as SetDriveBaiduNetDiskResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SetDriveBaiduNetDiskResponse create() => SetDriveBaiduNetDiskResponse._();
  SetDriveBaiduNetDiskResponse createEmptyInstance() => create();
  static $pb.PbList<SetDriveBaiduNetDiskResponse> createRepeated() => $pb.PbList<SetDriveBaiduNetDiskResponse>();
  @$core.pragma('dart2js:noInline')
  static SetDriveBaiduNetDiskResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetDriveBaiduNetDiskResponse>(create);
  static SetDriveBaiduNetDiskResponse? _defaultInstance;

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

class StartBaiduNetdiskLoginRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'StartBaiduNetdiskLoginRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'tmpDir', protoName: 'tmpDir')
    ..hasRequiredFields = false
  ;

  StartBaiduNetdiskLoginRequest._() : super();
  factory StartBaiduNetdiskLoginRequest({
    $core.String? tmpDir,
  }) {
    final _result = create();
    if (tmpDir != null) {
      _result.tmpDir = tmpDir;
    }
    return _result;
  }
  factory StartBaiduNetdiskLoginRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StartBaiduNetdiskLoginRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StartBaiduNetdiskLoginRequest clone() => StartBaiduNetdiskLoginRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StartBaiduNetdiskLoginRequest copyWith(void Function(StartBaiduNetdiskLoginRequest) updates) => super.copyWith((message) => updates(message as StartBaiduNetdiskLoginRequest)) as StartBaiduNetdiskLoginRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static StartBaiduNetdiskLoginRequest create() => StartBaiduNetdiskLoginRequest._();
  StartBaiduNetdiskLoginRequest createEmptyInstance() => create();
  static $pb.PbList<StartBaiduNetdiskLoginRequest> createRepeated() => $pb.PbList<StartBaiduNetdiskLoginRequest>();
  @$core.pragma('dart2js:noInline')
  static StartBaiduNetdiskLoginRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartBaiduNetdiskLoginRequest>(create);
  static StartBaiduNetdiskLoginRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tmpDir => $_getSZ(0);
  @$pb.TagNumber(1)
  set tmpDir($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTmpDir() => $_has(0);
  @$pb.TagNumber(1)
  void clearTmpDir() => clearField(1);
}

class StartBaiduNetdiskLoginResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'StartBaiduNetdiskLoginResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'img_syncer'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'success')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'message')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'refreshToken', protoName: 'refreshToken')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'accessToken', protoName: 'accessToken')
    ..aInt64(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'exiresAt', protoName: 'exiresAt')
    ..hasRequiredFields = false
  ;

  StartBaiduNetdiskLoginResponse._() : super();
  factory StartBaiduNetdiskLoginResponse({
    $core.bool? success,
    $core.String? message,
    $core.String? refreshToken,
    $core.String? accessToken,
    $fixnum.Int64? exiresAt,
  }) {
    final _result = create();
    if (success != null) {
      _result.success = success;
    }
    if (message != null) {
      _result.message = message;
    }
    if (refreshToken != null) {
      _result.refreshToken = refreshToken;
    }
    if (accessToken != null) {
      _result.accessToken = accessToken;
    }
    if (exiresAt != null) {
      _result.exiresAt = exiresAt;
    }
    return _result;
  }
  factory StartBaiduNetdiskLoginResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StartBaiduNetdiskLoginResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StartBaiduNetdiskLoginResponse clone() => StartBaiduNetdiskLoginResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StartBaiduNetdiskLoginResponse copyWith(void Function(StartBaiduNetdiskLoginResponse) updates) => super.copyWith((message) => updates(message as StartBaiduNetdiskLoginResponse)) as StartBaiduNetdiskLoginResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static StartBaiduNetdiskLoginResponse create() => StartBaiduNetdiskLoginResponse._();
  StartBaiduNetdiskLoginResponse createEmptyInstance() => create();
  static $pb.PbList<StartBaiduNetdiskLoginResponse> createRepeated() => $pb.PbList<StartBaiduNetdiskLoginResponse>();
  @$core.pragma('dart2js:noInline')
  static StartBaiduNetdiskLoginResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartBaiduNetdiskLoginResponse>(create);
  static StartBaiduNetdiskLoginResponse? _defaultInstance;

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
  $core.String get refreshToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set refreshToken($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRefreshToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearRefreshToken() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get accessToken => $_getSZ(3);
  @$pb.TagNumber(4)
  set accessToken($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAccessToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearAccessToken() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get exiresAt => $_getI64(4);
  @$pb.TagNumber(5)
  set exiresAt($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExiresAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearExiresAt() => clearField(5);
}

