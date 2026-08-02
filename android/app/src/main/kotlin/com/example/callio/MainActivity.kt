package com.example.callio

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.callio/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "sendSms") {
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")
                
                if (phoneNumber != null && message != null) {
                    try {
                        val smsManager = android.telephony.SmsManager.getDefault()
                        smsManager.sendTextMessage(phoneNumber, null, message, null, null)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SMS_FAILED", "Failed to send SMS: ${e.message}", null)
                    }
                } else {
                    result.error("INVALID_ARGS", "Phone number or message is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
