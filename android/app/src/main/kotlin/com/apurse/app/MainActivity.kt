package com.apurse.app

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.apurse.app/share"
    private var pendingSharePath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getSharedImage") {
                    val path = pendingSharePath
                    pendingSharePath = null
                    Log.d("ShareHandler", "getSharedImage called, path=$path")
                    if (path != null) result.success(path) else result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        Log.d("ShareHandler", "handleIntent: action=${intent.action} type=${intent.type}")
        if (intent.action != Intent.ACTION_SEND) return
        if (intent.type?.startsWith("image/") != true) return

        val uri = intent.getParcelableExtra<android.net.Uri>(Intent.EXTRA_STREAM)
        Log.d("ShareHandler", "URI from EXTRA_STREAM: $uri")
        if (uri == null) return

        try {
            val dir = File(cacheDir, "share")
            dir.mkdirs()
            val file = File(dir, "share_${System.currentTimeMillis()}.jpg")
            Log.d("ShareHandler", "Writing to: ${file.absolutePath}")

            // Always use contentResolver — handles both content:// and file:// URIs
            // On Android 10+, file:// URIs need to go through contentResolver
            val inputStream = contentResolver.openInputStream(uri)
            if (inputStream == null) {
                Log.d("ShareHandler", "inputStream is null")
                return
            }

            FileOutputStream(file).use { output ->
                inputStream.copyTo(output)
            }
            inputStream.close()
            pendingSharePath = file.absolutePath
            Log.d("ShareHandler", "Success! pendingSharePath=${file.absolutePath}")
        } catch (e: Exception) {
            Log.e("ShareHandler", "Error: ${e.message}", e)
            pendingSharePath = null
        }
    }
}
