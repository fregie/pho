package com.example.img_syncer

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import run.Run

import android.content.ContentUris
import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.provider.MediaStore

import android.content.Intent
import java.io.File


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
      } else if (call.method == "scanFile") {
        scanFile(call.argument("path"), call.argument("volumeName"), call.argument("relativePath"), call.argument("mimeType"))
        result.success(null)
      } else {
        result.notImplemented()
      }
    }
  }

  private fun scanFile(path: String?, volumeName: String?, relativePath: String?, mimeType: String?) {
    // if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        // val values = ContentValues().apply {
        //     put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
        //     put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
        //     put(MediaStore.MediaColumns.IS_PENDING, 1)
        // }

        // val contentUri: Uri = MediaStore.Files.getContentUri(volumeName)
        // val itemUri = contentResolver.insert(contentUri, values)
        
        // values.clear()
        // values.put(MediaStore.MediaColumns.IS_PENDING, 0)
        // contentResolver.update(itemUri!!, values, null, null)
        // } else {
            val mediaScanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
            val file = File(path)
            val contentUri = Uri.fromFile(file)
            mediaScanIntent.data = contentUri
            sendBroadcast(mediaScanIntent)
        // }
  }
}
