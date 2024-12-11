package com.prbelief.wifi_connector_flutter

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.cancel

class WifiConnectorFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private lateinit var wifiConnector: WifiConnector
    private val scope = CoroutineScope(Dispatchers.Main)
    private var permissionCallback: ((Boolean) -> Unit)? = null
    private var isStreamActive = false 
    
    private val requiredPermissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.CHANGE_WIFI_STATE,
            Manifest.permission.ACCESS_NETWORK_STATE,
            Manifest.permission.CHANGE_NETWORK_STATE,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                Manifest.permission.NEARBY_WIFI_DEVICES
            } else {
                ""
            }
        ).filter { it.isNotEmpty() }.toTypedArray()
    } else {
        arrayOf()
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wifi_connector_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        wifiConnector = WifiConnector(context)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
             "startListeningConnectionChanges" -> {
                isStreamActive = true
                result.success(null)
            }

            "stopListeningConnectionChanges" -> {
                isStreamActive = false
                result.success(null)
            }

            "connectToWifi" -> {
                if (!checkPermissions()) {
                    result.error(
                        "PERMISSION_DENIED",
                        "Required permissions are not granted",
                        null
                    )
                    return
                }

                val ssid = call.argument<String>("ssid")
                val password = call.argument<String>("password")
                
                if (ssid == null || password == null) {
                    result.error(
                        "INVALID_ARGUMENTS",
                        "SSID and password are required",
                        null
                    )
                    return
                }

                scope.launch {
                    try {
                        val connectResult = wifiConnector.connectToWifi(
                            ssid = ssid,
                            password = password
                        ) { isConnected ->
                            if (isStreamActive) {
                               channel.invokeMethod("onConnectionChanged", isConnected)
                            }
                        }

                        connectResult.fold(
                            onSuccess = { network -> 
                                result.success(mapOf(
                                    "success" to true,
                                    "errorMessage" to null,
                                    "errorCode" to null
                                ))
                            },
                            onFailure = { error ->
                                result.success(mapOf(
                                    "success" to false,
                                    "errorMessage" to error.message,
                                    "errorCode" to "CONNECTION_ERROR"
                                ))
                            }
                        )
                    } catch (e: Exception) {
                        result.success(mapOf(
                            "success" to false,
                            "errorMessage" to e.message,
                            "errorCode" to "EXCEPTION"
                        ))
                    }
                }
            }
            
            "disconnect" -> {
                wifiConnector.disconnect()
                result.success(null)
            }
            
            "isConnected" -> {
                result.success(wifiConnector.isConnected())
            }
            
            "checkPermissions" -> {
                result.success(checkPermissions())
            }
            
            "requestPermissions" -> {
                requestPermissions { granted ->
                    result.success(granted)
                }
            }
            
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun checkPermissions(): Boolean {
        return requiredPermissions.all {
            ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun requestPermissions(callback: (Boolean) -> Unit) {
        val activity = activity ?: run {
            callback(false)
            return
        }

        if (checkPermissions()) {
            callback(true)
            return
        }

        permissionCallback = callback
        ActivityCompat.requestPermissions(
            activity,
            requiredPermissions,
            PERMISSION_REQUEST_CODE
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(permissionResultListener)
    }

    override fun onDetachedFromActivity() {
        activity = null
        permissionCallback = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(permissionResultListener)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        permissionCallback = null
    }

    private val permissionResultListener = object : PluginRegistry.RequestPermissionsResultListener {
        override fun onRequestPermissionsResult(
            requestCode: Int,
            permissions: Array<out String>,
            grantResults: IntArray
        ): Boolean {
            if (requestCode == PERMISSION_REQUEST_CODE) {
                val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
                permissionCallback?.invoke(allGranted)
                permissionCallback = null
                return true
            }
            return false
        }
    }

    companion object {
        private const val PERMISSION_REQUEST_CODE = 12345
    }
}