package com.example.img_syncer

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import run.Run

class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.example.img_syncer/RunGrpcServer"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
        call,
        result ->
      if (call.method == "RunGrpcServer") {
        val re =  Run.runGrpcServer()
        result.success(re)
      } else {
        result.notImplemented()
      }
    }
  }
}
