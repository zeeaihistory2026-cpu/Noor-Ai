package com.noorai.com

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.location.Geocoder
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import java.util.TimeZone

/** Foreground-only location, requested exclusively after tapping Use device location. */
class PrayerLocation(private val activity: Activity) {
    companion object { const val REQUEST = 7802 }
    private val manager = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    private val handler = Handler(Looper.getMainLooper())
    private var pending: MethodChannel.Result? = null
    private var listening = false
    private val timeout = Runnable { fail("LOCATION_TIMEOUT", "No fresh location was found. Turn on location services or choose your city.") }
    private val listener = object : LocationListener {
        override fun onLocationChanged(location: Location) { deliver(location) }
        @Deprecated("Legacy location callback")
        override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
        override fun onProviderEnabled(provider: String) {}
        override fun onProviderDisabled(provider: String) {}
    }

    fun request(result: MethodChannel.Result) {
        if (pending != null) { result.error("LOCATION_BUSY", "Location is already being requested", null); return }
        pending = result
        if (!hasPermission()) {
            activity.requestPermissions(arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION), REQUEST)
        } else start()
    }

    private fun hasPermission() = activity.checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
        activity.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED

    fun permissionsResult() {
        if (pending == null) return
        if (hasPermission()) start() else fail("LOCATION_DENIED", "Location permission was denied. Choose your city instead.")
    }

    @Suppress("MissingPermission")
    private fun start() {
        try {
            val providers = listOf(LocationManager.GPS_PROVIDER, LocationManager.NETWORK_PROVIDER).filter { manager.isProviderEnabled(it) }
            if (providers.isEmpty()) { fail("LOCATION_DISABLED", "Turn on device location or choose your city."); return }
            val recent = providers.mapNotNull { manager.getLastKnownLocation(it) }
                .filter { SystemClock.elapsedRealtimeNanos() - it.elapsedRealtimeNanos in 0..120_000_000_000L && it.accuracy <= 2000f }
                .minByOrNull { it.accuracy }
            if (recent != null) { deliver(recent); return }
            listening = true
            handler.postDelayed(timeout, 20_000)
            for (provider in providers) manager.requestLocationUpdates(provider, 1000L, 0f, listener, Looper.getMainLooper())
        } catch (_: Exception) { fail("LOCATION_UNAVAILABLE", "Device location is unavailable. Choose your city instead.") }
    }

    private fun stop() {
        handler.removeCallbacks(timeout)
        if (listening) { manager.removeUpdates(listener); listening = false }
    }

    private fun deliver(location: Location) {
        if (pending == null) return
        stop()
        val result = pending!!
        pending = null
        // Reverse geocoding is optional; coordinates still work offline.
        Thread {
            var city = "Current location"
            var country = "Device location"
            try {
                @Suppress("DEPRECATION")
                val address = Geocoder(activity, Locale.ENGLISH).getFromLocation(location.latitude, location.longitude, 1)?.firstOrNull()
                city = address?.locality ?: address?.subAdminArea ?: city
                country = address?.countryName ?: country
            } catch (_: Exception) {}
            val value = mapOf("city" to city, "country" to country, "latitude" to location.latitude,
                "longitude" to location.longitude, "timeZone" to TimeZone.getDefault().id, "isLive" to true,
                "accuracyMeters" to location.accuracy.toDouble(), "locationSource" to "device")
            activity.runOnUiThread { result.success(value) }
        }.start()
    }

    private fun fail(code: String, message: String) {
        stop()
        val result = pending ?: return
        pending = null
        result.error(code, message, null)
    }
    fun close() { fail("LOCATION_CANCELLED", "Location request cancelled") }
}
