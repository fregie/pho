import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

Future<String> runServer() async {
  String ports;
  WidgetsFlutterBinding.ensureInitialized();
  ports = await const MethodChannel('com.example.img_syncer/RunGrpcServer')
      .invokeMethod('RunGrpcServer');
  return ports;
}
