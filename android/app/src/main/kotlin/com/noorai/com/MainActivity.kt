package com.noorai.com

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.content.ContentValues
import android.content.Intent
import android.app.Activity
import android.os.Build
import android.os.Environment
import android.provider.MediaStore

class MainActivity : FlutterActivity() {
    private var compass: QiblaCompass? = null
    private var prayerLocation: PrayerLocation? = null
    private var pendingSave: MethodChannel.Result? = null
    private var pendingBytes: ByteArray? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        prayerLocation = PrayerLocation(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.noorai.com/location")
            .setMethodCallHandler { call, result ->
                if (call.method == "currentLocation") prayerLocation?.request(result) else result.notImplemented()
            }
        compass = QiblaCompass(this)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.noorai.com/compass")
            .setStreamHandler(compass)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.noorai.com/export")
            .setMethodCallHandler { call, result ->
                if (call.method != "saveImage") { result.notImplemented(); return@setMethodCallHandler }
                val bytes = call.argument<ByteArray>("bytes")
                val name = call.argument<String>("name") ?: "MuslimGo.png"
                if (bytes == null) { result.error("INVALID_IMAGE", "No image to save", null); return@setMethodCallHandler }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    Thread {
                        var uri: android.net.Uri? = null
                        try {
                            val values = ContentValues().apply {
                                put(MediaStore.Images.Media.DISPLAY_NAME, name)
                                put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                                put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/MuslimGo")
                                put(MediaStore.Images.Media.IS_PENDING, 1)
                            }
                            uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                                ?: throw java.io.IOException("Gallery unavailable")
                            val stream = contentResolver.openOutputStream(uri!!)
                                ?: throw java.io.IOException("Storage unavailable")
                            stream.use { it.write(bytes) }
                            values.clear()
                            values.put(MediaStore.Images.Media.IS_PENDING, 0)
                            contentResolver.update(uri!!, values, null, null)
                            val saved = uri.toString()
                            runOnUiThread { result.success(saved) }
                        } catch (error: Exception) {
                            uri?.let { contentResolver.delete(it, null, null) }
                            runOnUiThread { result.error("SAVE_FAILED", "Could not save image", null) }
                        }
                    }.start()
                } else {
                    if (pendingSave != null) { result.error("SAVE_BUSY", "A save is already open", null); return@setMethodCallHandler }
                    pendingSave = result
                    pendingBytes = bytes
                    try {
                        startActivityForResult(Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = "image/png"
                            putExtra(Intent.EXTRA_TITLE, name)
                        }, 7801)
                    } catch (error: Exception) {
                        pendingSave = null; pendingBytes = null
                        result.error("SAVE_FAILED", "No file picker available", null)
                    }
                }
            }
    }

    override fun onPause() { compass?.pause(); super.onPause() }
    override fun onResume() { super.onResume(); compass?.resume() }
    override fun onDestroy() { prayerLocation?.close(); compass?.close(); super.onDestroy() }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PrayerLocation.REQUEST) prayerLocation?.permissionsResult()
    }

    @Deprecated("Legacy Android document picker callback")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != 7801) return
        val result = pendingSave ?: return
        val bytes = pendingBytes
        pendingSave = null; pendingBytes = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null || bytes == null) { result.success(null); return }
        Thread {
            try {
                val stream = contentResolver.openOutputStream(uri) ?: throw java.io.IOException("Storage unavailable")
                stream.use { it.write(bytes) }
                runOnUiThread { result.success(uri.toString()) }
            } catch (error: Exception) { runOnUiThread { result.error("SAVE_FAILED", "Could not save image", null) } }
        }.start()
    }
}
