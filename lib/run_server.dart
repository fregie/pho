import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

Future<int> runServer() async {
  int port = 0;
  WidgetsFlutterBinding.ensureInitialized();
  port = await const MethodChannel('com.example.img_syncer/RunGrpcServer')
      .invokeMethod('RunGrpcServer');
  return port;
}
