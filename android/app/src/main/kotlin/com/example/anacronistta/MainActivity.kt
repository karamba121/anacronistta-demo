package com.example.anacronistta

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingResult: MethodChannel.Result? = null
    private var pendingBytes: ByteArray? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            REPORT_EXPORT_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method != "savePdf") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (pendingResult != null) {
                result.error(
                    "EXPORT_IN_PROGRESS",
                    "Uma exportação já está em andamento.",
                    null,
                )
                return@setMethodCallHandler
            }

            val fileName = call.argument<String>("fileName")
            val bytes = call.argument<ByteArray>("bytes")
            if (fileName.isNullOrBlank() || bytes == null) {
                result.error(
                    "INVALID_REPORT",
                    "Nome ou conteúdo do PDF inválido.",
                    null,
                )
                return@setMethodCallHandler
            }

            pendingResult = result
            pendingBytes = bytes
            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "application/pdf"
                putExtra(Intent.EXTRA_TITLE, fileName)
            }
            startActivityForResult(intent, CREATE_PDF_REQUEST)
        }
    }

    @Deprecated("Required for Flutter Activity result integration.")
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?,
    ) {
        if (requestCode != CREATE_PDF_REQUEST) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }

        val result = pendingResult
        val bytes = pendingBytes
        pendingResult = null
        pendingBytes = null

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result?.success(null)
            return
        }
        if (result == null || bytes == null) return

        writePdf(data.data!!, bytes, result)
    }

    private fun writePdf(
        uri: Uri,
        bytes: ByteArray,
        result: MethodChannel.Result,
    ) {
        Thread {
            try {
                contentResolver.openOutputStream(uri)?.use { stream ->
                    stream.write(bytes)
                    stream.flush()
                } ?: throw IllegalStateException(
                    "Não foi possível abrir o arquivo selecionado.",
                )

                runOnUiThread { result.success(uri.toString()) }
            } catch (error: Exception) {
                runOnUiThread {
                    result.error("SAVE_FAILED", error.localizedMessage, null)
                }
            }
        }.start()
    }

    companion object {
        private const val REPORT_EXPORT_CHANNEL = "anacronistta/report_export"
        private const val CREATE_PDF_REQUEST = 7401
    }
}
