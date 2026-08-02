package com.example.callio

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log

class CallReceiver : BroadcastReceiver() {
    private val TAG = "CallReceiver"

    companion object {
        private var lastState = TelephonyManager.CALL_STATE_IDLE
        private var isIncoming = false
        private var savedNumber: String? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            val stateStr = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
            
            var state = TelephonyManager.CALL_STATE_IDLE
            when (stateStr) {
                TelephonyManager.EXTRA_STATE_IDLE -> state = TelephonyManager.CALL_STATE_IDLE
                TelephonyManager.EXTRA_STATE_OFFHOOK -> state = TelephonyManager.CALL_STATE_OFFHOOK
                TelephonyManager.EXTRA_STATE_RINGING -> state = TelephonyManager.CALL_STATE_RINGING
            }

            onCallStateChanged(context, state, number)
        }
    }

    private fun onCallStateChanged(context: Context, state: Int, number: String?) {
        if (lastState == state) {
            return // No change
        }

        when (state) {
            TelephonyManager.CALL_STATE_RINGING -> {
                isIncoming = true
                savedNumber = number
                Log.d(TAG, "Incoming call ringing: $savedNumber")
            }
            TelephonyManager.CALL_STATE_OFFHOOK -> {
                if (lastState == TelephonyManager.CALL_STATE_RINGING) {
                    isIncoming = true
                    Log.d(TAG, "Incoming call answered: $savedNumber")
                }
            }
            TelephonyManager.CALL_STATE_IDLE -> {
                if (lastState == TelephonyManager.CALL_STATE_RINGING) {
                    // Ringing but then went straight to idle -> Missed call!
                    Log.d(TAG, "Missed call detected from: $savedNumber")
                    savedNumber?.let { notifyMissedCall(context, it) }
                } else if (lastState == TelephonyManager.CALL_STATE_OFFHOOK && isIncoming) {
                    Log.d(TAG, "Incoming call ended: $savedNumber")
                }
                isIncoming = false
            }
        }
        lastState = state
    }

    private fun notifyMissedCall(context: Context, number: String) {
        // Start the foreground service to handle the missed call reliably
        val serviceIntent = Intent(context, CallBackgroundService::class.java).apply {
            putExtra("action", "missed_call")
            putExtra("number", number)
        }
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION.SDK_INT) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }
}
