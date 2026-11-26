package com.noorai.com

import android.app.Activity
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.view.Surface
import io.flutter.plugin.common.EventChannel

/** Magnetic rotation vector corrected to true north for the selected coordinates. */
class QiblaCompass(private val activity: Activity) : EventChannel.StreamHandler, SensorEventListener {
    private val manager = activity.getSystemService(Activity.SENSOR_SERVICE) as SensorManager
    private var sink: EventChannel.EventSink? = null
    private var declination = 0f
    private var resumed = true
    private var lastSent = 0L
    private val sensor = manager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        ?: manager.getDefaultSensor(Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR)

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        manager.unregisterListener(this)
        sink = events
        val args = arguments as? Map<*, *>
        val lat = (args?.get("latitude") as? Number)?.toFloat() ?: 0f
        val lng = (args?.get("longitude") as? Number)?.toFloat() ?: 0f
        declination = GeomagneticField(lat, lng, 0f, System.currentTimeMillis()).declination
        lastSent = 0L
        start()
    }

    private fun start() {
        if (sink == null || !resumed) return
        if (sensor == null || !manager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_UI)) {
            sink?.error("NO_COMPASS", "This device has no usable compass sensor", null)
        }
    }

    fun pause() { resumed = false; manager.unregisterListener(this) }
    fun resume() { resumed = true; start() }
    fun close() { manager.unregisterListener(this); sink = null }
    override fun onCancel(arguments: Any?) { close() }
    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) { }

    @Suppress("DEPRECATION")
    override fun onSensorChanged(event: SensorEvent) {
        if (event.timestamp - lastSent < 100_000_000L) return
        lastSent = event.timestamp
        val raw = FloatArray(9)
        val adjusted = FloatArray(9)
        SensorManager.getRotationMatrixFromVector(raw, event.values)
        val axes = when (activity.windowManager.defaultDisplay.rotation) {
            Surface.ROTATION_90 -> Pair(SensorManager.AXIS_Y, SensorManager.AXIS_MINUS_X)
            Surface.ROTATION_180 -> Pair(SensorManager.AXIS_MINUS_X, SensorManager.AXIS_MINUS_Y)
            Surface.ROTATION_270 -> Pair(SensorManager.AXIS_MINUS_Y, SensorManager.AXIS_X)
            else -> Pair(SensorManager.AXIS_X, SensorManager.AXIS_Y)
        }
        SensorManager.remapCoordinateSystem(raw, axes.first, axes.second, adjusted)
        val angles = FloatArray(3)
        SensorManager.getOrientation(adjusted, angles)
        val heading = (Math.toDegrees(angles[0].toDouble()) + declination + 360) % 360
        sink?.success(mapOf(
            "heading" to heading,
            "pitch" to Math.toDegrees(angles[1].toDouble()),
            "roll" to Math.toDegrees(angles[2].toDouble()),
            "accuracy" to event.accuracy
        ))
    }
}
