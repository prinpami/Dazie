package com.example.dazie

import android.Manifest
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.pm.PackageManager
import android.location.LocationManager
import android.net.wifi.WifiManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dazie/device_readiness")
            .setMethodCallHandler { call, result ->
                if (call.method != "check") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    val bluetooth = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
                    val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                    val location = getSystemService(Context.LOCATION_SERVICE) as LocationManager
                    val playServices = try {
                        packageManager.getApplicationInfo("com.google.android.gms", 0).enabled
                    } catch (_: PackageManager.NameNotFoundException) { false }
                    val locationEnabled = if (Build.VERSION.SDK_INT >= 28) location.isLocationEnabled
                        else location.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
                            location.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
                    result.success(mapOf(
                        "playServices" to playServices,
                        "bluetoothSupported" to (bluetooth.adapter != null),
                        "bluetooth" to (bluetooth.adapter?.isEnabled == true),
                        "wifi" to wifi.isWifiEnabled,
                        "location" to locationEnabled,
                        "preciseLocation" to (checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED)
                    ))
                } catch (error: SecurityException) {
                    result.error("permission", "Allow Nearby devices in Dazie app settings.", null)
                }
            }
    }
}
