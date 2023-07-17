import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

Future<String> runServer() async {
  late String ports;
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    ports = await const MethodChannel('com.example.img_syncer/RunGrpcServer')
        .invokeMethod('RunGrpcServer');
  } else if (Platform.isIOS) {
    ports = await const MethodChannel('com.example.img_syncer/RunGrpcServer')
        .invokeMethod('RunGrpcServer');
  }

  return ports;
}
