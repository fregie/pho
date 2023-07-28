///
//  Generated code. Do not modify.
//  source: proto/img_syncer.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use listByDateRequestDescriptor instead')
const ListByDateRequest$json = const {
  '1': 'ListByDateRequest',
  '2': const [
    const {'1': 'date', '3': 1, '4': 1, '5': 9, '10': 'date'},
    const {'1': 'offset', '3': 2, '4': 1, '5': 5, '10': 'offset'},
    const {'1': 'maxReturn', '3': 3, '4': 1, '5': 5, '10': 'maxReturn'},
  ],
};

/// Descriptor for `ListByDateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listByDateRequestDescriptor = $convert.base64Decode('ChFMaXN0QnlEYXRlUmVxdWVzdBISCgRkYXRlGAEgASgJUgRkYXRlEhYKBm9mZnNldBgCIAEoBVIGb2Zmc2V0EhwKCW1heFJldHVybhgDIAEoBVIJbWF4UmV0dXJu');
@$core.Deprecated('Use listByDateResponseDescriptor instead')
const ListByDateResponse$json = const {
  '1': 'ListByDateResponse',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'paths', '3': 3, '4': 3, '5': 9, '10': 'paths'},
  ],
};

/// Descriptor for `ListByDateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listByDateResponseDescriptor = $convert.base64Decode('ChJMaXN0QnlEYXRlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdlEhQKBXBhdGhzGAMgAygJUgVwYXRocw==');
@$core.Deprecated('Use deleteRequestDescriptor instead')
const DeleteRequest$json = const {
  '1': 'DeleteRequest',
  '2': const [
    const {'1': 'paths', '3': 1, '4': 3, '5': 9, '10': 'paths'},
  ],
};

/// Descriptor for `DeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteRequestDescriptor = $convert.base64Decode('Cg1EZWxldGVSZXF1ZXN0EhQKBXBhdGhzGAEgAygJUgVwYXRocw==');
@$core.Deprecated('Use deleteResponseDescriptor instead')
const DeleteResponse$json = const {
  '1': 'DeleteResponse',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `DeleteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteResponseDescriptor = $convert.base64Decode('Cg5EZWxldGVSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2U=');
@$core.Deprecated('Use filterNotUploadedRequestInfoDescriptor instead')
const FilterNotUploadedRequestInfo$json = const {
  '1': 'FilterNotUploadedRequestInfo',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'date', '3': 2, '4': 1, '5': 9, '10': 'date'},
    const {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `FilterNotUploadedRequestInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filterNotUploadedRequestInfoDescriptor = $convert.base64Decode('ChxGaWx0ZXJOb3RVcGxvYWRlZFJlcXVlc3RJbmZvEhIKBG5hbWUYASABKAlSBG5hbWUSEgoEZGF0ZRgCIAEoCVIEZGF0ZRIOCgJpZBgDIAEoCVICaWQ=');
@$core.Deprecated('Use filterNotUploadedRequestDescriptor instead')
const FilterNotUploadedRequest$json = const {
  '1': 'FilterNotUploadedRequest',
  '2': const [
    const {'1': 'photos', '3': 1, '4': 3, '5': 11, '6': '.img_syncer.FilterNotUploadedRequestInfo', '10': 'photos'},
    const {'1': 'isFinished', '3': 2, '4': 1, '5': 8, '10': 'isFinished'},
  ],
};

/// Descriptor for `FilterNotUploadedRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filterNotUploadedRequestDescriptor = $convert.base64Decode('ChhGaWx0ZXJOb3RVcGxvYWRlZFJlcXVlc3QSQAoGcGhvdG9zGAEgAygLMiguaW1nX3N5bmNlci5GaWx0ZXJOb3RVcGxvYWRlZFJlcXVlc3RJbmZvUgZwaG90b3MSHgoKaXNGaW5pc2hlZBgCIAEoCFIKaXNGaW5pc2hlZA==');
@$core.Deprecated('Use filterNotUploadedResponseDescriptor instead')
const FilterNotUploadedResponse$json = const {
  '1': 'FilterNotUploadedResponse',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'notUploaedIDs', '3': 3, '4': 3, '5': 9, '10': 'notUploaedIDs'},
    const {'1': 'isFinished', '3': 4, '4': 1, '5': 8, '10': 'isFinished'},
  ],
};

/// Descriptor for `FilterNotUploadedResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filterNotUploadedResponseDescriptor = $convert.base64Decode('ChlGaWx0ZXJOb3RVcGxvYWRlZFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZRIkCg1ub3RVcGxvYWVkSURzGAMgAygJUg1ub3RVcGxvYWVkSURzEh4KCmlzRmluaXNoZWQYBCABKAhSCmlzRmluaXNoZWQ=');
@$core.Deprecated('Use setDriveSMBRequestDescriptor instead')
const SetDriveSMBRequest$json = const {
  '1': 'SetDriveSMBRequest',
  '2': const [
    const {'1': 'addr', '3': 1, '4': 1, '5': 9, '10': 'addr'},
    const {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    const {'1': 'password', '3': 3, '4': 1, '5': 9, '10': 'password'},
    const {'1': 'share', '3': 4, '4': 1, '5': 9, '10': 'share'},
    const {'1': 'root', '3': 5, '4': 1, '5': 9, '10': 'root'},
  ],
};

/// Descriptor for `SetDriveSMBRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDriveSMBRequestDescriptor = $convert.base64Decode('ChJTZXREcml2ZVNNQlJlcXVlc3QSEgoEYWRkchgBIAEoCVIEYWRkchIaCgh1c2VybmFtZRgCIAEoCVIIdXNlcm5hbWUSGgoIcGFzc3dvcmQYAyABKAlSCHBhc3N3b3JkEhQKBXNoYXJlGAQgASgJUgVzaGFyZRISCgRyb290GAUgASgJUgRyb290');
@$core.Deprecated('Use setDriveSMBResponseDescriptor instead')
const SetDriveSMBResponse$json = const {
  '1': 'SetDriveSMBResponse',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SetDriveSMBResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDriveSMBResponseDescriptor = $convert.base64Decode('ChNTZXREcml2ZVNNQlJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZQ==');
@$core.Deprecated('Use listDriveSMBSharesRequestDescriptor instead')
const ListDriveSMBSharesRequest$json = const {
  '1': 'ListDriveSMBSharesRequest',
};

/// Descriptor for `ListDriveSMBSharesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDriveSMBSharesRequestDescriptor = $convert.base64Decode('ChlMaXN0RHJpdmVTTUJTaGFyZXNSZXF1ZXN0');
@$core.Deprecated('Use listDriveSMBSharesResponseDescriptor instead')
const ListDriveSMBSharesResponse$json = const {
  '1': 'ListDriveSMBSharesResponse',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'shares', '3': 3, '4': 3, '5': 9, '10': 'shares'},
  ],
};

/// Descriptor for `ListDriveSMBSharesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDriveSMBSharesResponseDescriptor = $convert.base64Decode('ChpMaXN0RHJpdmVTTUJTaGFyZXNSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USFgoGc2hhcmVzGAMgAygJUgZzaGFyZXM=');
@$core.Deprecated('Use listDriveSMBDirRequestDescriptor instead')
const ListDriveSMBDirRequest$json = const {
  '1': 'ListDriveSMBDirRequest',
  '2': const [
    const {'1': 'share', '3': 1, '4': 1, '5': 9, '10': 'share'},
    const {'1': 'dir', '3': 2, '4': 1, '5': 9, '10': 'dir'},
  ],
};

/// Descriptor for `ListDriveSMBDirRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDriveSMBDirRequestDescriptor = $convert.base64Decode('ChZMaXN0RHJpdmVTTUJEaXJSZXF1ZXN0EhQKBXNoYXJlGAEgASgJUgVzaGFyZRIQCgNkaXIYAiABKAlSA2Rpcg==');
@$core.Deprecated('Use listDriveSMBDirResponseDescriptor instead')
const ListDriveSMBDirResponse$json = const {
  '1': 'ListDriveSMBDirResponse',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'dirs', '3': 3, '4': 3, '5': 9, '10': 'dirs'},
  ],
};

/// Descriptor for `ListDriveSMBDirResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDriveSMBDirResponseDescriptor = $convert.base64Decode('ChdMaXN0RHJpdmVTTUJEaXJSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USEgoEZGlycxgDIAMoCVIEZGlycw==');
@$core.Deprecated('Use setDriveSMBShareRequestDescriptor instead')
const SetDriveSMBShareRequest$json = const {
  '1': 'SetDriveSMBShareRequest',
  '2': const [
    const {'1': 'share', '3': 1, '4': 1, '5': 9, '10': 'share'},
    const {'1': 'root', '3': 2, '4': 1, '5': 9, '10': 'root'},
  ],
};

/// Descriptor for `SetDriveSMBShareRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDriveSMBShareRequestDescriptor = $convert.base64Decode('ChdTZXREcml2ZVNNQlNoYXJlUmVxdWVzdBIUCgVzaGFyZRgBIAEoCVIFc2hhcmUSEgoEcm9vdBgCIAEoCVIEcm9vdA==');
@$core.Deprecated('Use setDriveSMBShareResponseDescriptor instead')
const SetDriveSMBShareResponse$json = const {
  '1': 'SetDriveSMBShareResponse',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SetDriveSMBShareResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDriveSMBShareResponseDescriptor = $convert.base64Decode('ChhTZXREcml2ZVNNQlNoYXJlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdl');
@$core.Deprecated('Use setDriveWebdavRequestDescriptor instead')
const SetDriveWebdavRequest$json = const {
  '1': 'SetDriveWebdavRequest',
  '2': const [
    const {'1': 'addr', '3': 1, '4': 1, '5': 9, '10': 'addr'},
    const {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    const {'1': 'password', '3': 3, '4': 1, '5': 9, '10': 'password'},
    const {'1': 'root', '3': 4, '4': 1, '5': 9, '10': 'root'},
  ],
};

/// Descriptor for `SetDriveWebdavRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDriveWebdavRequestDescriptor = $convert.base64Decode('ChVTZXREcml2ZVdlYmRhdlJlcXVlc3QSEgoEYWRkchgBIAEoCVIEYWRkchIaCgh1c2VybmFtZRgCIAEoCVIIdXNlcm5hbWUSGgoIcGFzc3dvcmQYAyABKAlSCHBhc3N3b3JkEhIKBHJvb3QYBCABKAlSBHJvb3Q=');
@$core.Deprecated('Use setDriveWebdavResponseDescriptor instead')
const SetDriveWebdavResponse$json = const {
  '1': 'SetDriveWebdavResponse',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SetDriveWebdavResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDriveWebdavResponseDescriptor = $convert.base64Decode('ChZTZXREcml2ZVdlYmRhdlJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZQ==');
@$core.Deprecated('Use listDriveWebdavDirRequestDescriptor instead')
const ListDriveWebdavDirRequest$json = const {
  '1': 'ListDriveWebdavDirRequest',
  '2': const [
    const {'1': 'dir', '3': 1, '4': 1, '5': 9, '10': 'dir'},
  ],
};

/// Descriptor for `ListDriveWebdavDirRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDriveWebdavDirRequestDescriptor = $convert.base64Decode('ChlMaXN0RHJpdmVXZWJkYXZEaXJSZXF1ZXN0EhAKA2RpchgBIAEoCVIDZGly');
@$core.Deprecated('Use listDriveWebdavDirResponseDescriptor instead')
const ListDriveWebdavDirResponse$json = const {
  '1': 'ListDriveWebdavDirResponse',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'dirs', '3': 3, '4': 3, '5': 9, '10': 'dirs'},
  ],
};

/// Descriptor for `ListDriveWebdavDirResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDriveWebdavDirResponseDescriptor = $convert.base64Decode('ChpMaXN0RHJpdmVXZWJkYXZEaXJSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USEgoEZGlycxgDIAMoCVIEZGlycw==');
@$core.Deprecated('Use setDriveNFSRequestDescriptor instead')
const SetDriveNFSRequest$json = const {
  '1': 'SetDriveNFSRequest',
  '2': const [
    const {'1': 'addr', '3': 1, '4': 1, '5': 9, '10': 'addr'},
    const {'1': 'root', '3': 2, '4': 1, '5': 9, '10': 'root'},
  ],
};

/// Descriptor for `SetDriveNFSRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDriveNFSRequestDescriptor = $convert.base64Decode('ChJTZXREcml2ZU5GU1JlcXVlc3QSEgoEYWRkchgBIAEoCVIEYWRkchISCgRyb290GAIgASgJUgRyb290');
@$core.Deprecated('Use setDriveNFSResponseDescriptor instead')
const SetDriveNFSResponse$json = const {
  '1': 'SetDriveNFSResponse',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SetDriveNFSResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDriveNFSResponseDescriptor = $convert.base64Decode('ChNTZXREcml2ZU5GU1Jlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZQ==');
@$core.Deprecated('Use listDriveNFSDirRequestDescriptor instead')
const ListDriveNFSDirRequest$json = const {
  '1': 'ListDriveNFSDirRequest',
  '2': const [
    const {'1': 'dir', '3': 1, '4': 1, '5': 9, '10': 'dir'},
  ],
};

/// Descriptor for `ListDriveNFSDirRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDriveNFSDirRequestDescriptor = $convert.base64Decode('ChZMaXN0RHJpdmVORlNEaXJSZXF1ZXN0EhAKA2RpchgBIAEoCVIDZGly');
@$core.Deprecated('Use listDriveNFSDirResponseDescriptor instead')
const ListDriveNFSDirResponse$json = const {
  '1': 'ListDriveNFSDirResponse',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'dirs', '3': 3, '4': 3, '5': 9, '10': 'dirs'},
  ],
};

/// Descriptor for `ListDriveNFSDirResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDriveNFSDirResponseDescriptor = $convert.base64Decode('ChdMaXN0RHJpdmVORlNEaXJSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USEgoEZGlycxgDIAMoCVIEZGlycw==');
@$core.Deprecated('Use setDriveBaiduNetDiskRequestDescriptor instead')
const SetDriveBaiduNetDiskRequest$json = const {
  '1': 'SetDriveBaiduNetDiskRequest',
  '2': const [
    const {'1': 'refreshToken', '3': 1, '4': 1, '5': 9, '10': 'refreshToken'},
    const {'1': 'accessToken', '3': 2, '4': 1, '5': 9, '10': 'accessToken'},
    const {'1': 'tmpDir', '3': 3, '4': 1, '5': 9, '10': 'tmpDir'},
  ],
};

/// Descriptor for `SetDriveBaiduNetDiskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDriveBaiduNetDiskRequestDescriptor = $convert.base64Decode('ChtTZXREcml2ZUJhaWR1TmV0RGlza1JlcXVlc3QSIgoMcmVmcmVzaFRva2VuGAEgASgJUgxyZWZyZXNoVG9rZW4SIAoLYWNjZXNzVG9rZW4YAiABKAlSC2FjY2Vzc1Rva2VuEhYKBnRtcERpchgDIAEoCVIGdG1wRGly');
@$core.Deprecated('Use setDriveBaiduNetDiskResponseDescriptor instead')
const SetDriveBaiduNetDiskResponse$json = const {
  '1': 'SetDriveBaiduNetDiskResponse',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `SetDriveBaiduNetDiskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDriveBaiduNetDiskResponseDescriptor = $convert.base64Decode('ChxTZXREcml2ZUJhaWR1TmV0RGlza1Jlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZQ==');
@$core.Deprecated('Use startBaiduNetdiskLoginRequestDescriptor instead')
const StartBaiduNetdiskLoginRequest$json = const {
  '1': 'StartBaiduNetdiskLoginRequest',
  '2': const [
    const {'1': 'tmpDir', '3': 1, '4': 1, '5': 9, '10': 'tmpDir'},
  ],
};

/// Descriptor for `StartBaiduNetdiskLoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startBaiduNetdiskLoginRequestDescriptor = $convert.base64Decode('Ch1TdGFydEJhaWR1TmV0ZGlza0xvZ2luUmVxdWVzdBIWCgZ0bXBEaXIYASABKAlSBnRtcERpcg==');
@$core.Deprecated('Use startBaiduNetdiskLoginResponseDescriptor instead')
const StartBaiduNetdiskLoginResponse$json = const {
  '1': 'StartBaiduNetdiskLoginResponse',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'refreshToken', '3': 3, '4': 1, '5': 9, '10': 'refreshToken'},
    const {'1': 'accessToken', '3': 4, '4': 1, '5': 9, '10': 'accessToken'},
    const {'1': 'exiresAt', '3': 5, '4': 1, '5': 3, '10': 'exiresAt'},
  ],
};

/// Descriptor for `StartBaiduNetdiskLoginResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startBaiduNetdiskLoginResponseDescriptor = $convert.base64Decode('Ch5TdGFydEJhaWR1TmV0ZGlza0xvZ2luUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdlEiIKDHJlZnJlc2hUb2tlbhgDIAEoCVIMcmVmcmVzaFRva2VuEiAKC2FjY2Vzc1Rva2VuGAQgASgJUgthY2Nlc3NUb2tlbhIaCghleGlyZXNBdBgFIAEoA1IIZXhpcmVzQXQ=');
