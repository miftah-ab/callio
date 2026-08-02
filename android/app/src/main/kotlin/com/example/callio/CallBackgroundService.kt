package com.example.callio

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.telephony.SmsManager
import android.util.Log

class CallBackgroundService : Service() {
    private val TAG = "CallBackgroundService"
    private val CHANNEL_ID = "CallioBackgroundService"

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = createNotification()
        startForeground(1, notification)

        val action = intent?.getStringExtra("action")
        val number = intent?.getStringExtra("number")

        if (action == "missed_call" && number != null) {
            Log.d(TAG, "Processing missed call for: $number")
            // TODO: Here we should ideally start a Flutter background isolate to run the Rules Engine.
            // For now, as a robust native fallback, if rules dictate an SMS, we send it.
            // We will expose sendSms via MethodChannel in MainActivity for Flutter to call.
            
            // Note: Since starting a Flutter Engine in a background service can be heavy,
            // the `flutter_background_service` package handles spinning up the dart isolate.
            // We can emit a broadcast or use SharedPreferences to pass this number to the Flutter background task.
        }

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null // We don't provide binding
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Callio Background Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(serviceChannel)
        }
    }

    private fun createNotification(): Notification {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            Notification.Builder(this)
        }
        
        return builder
            .setContentTitle("Callio is running")
            .setContentText("Monitoring for missed calls")
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Fallback icon
            .build()
    }
}
