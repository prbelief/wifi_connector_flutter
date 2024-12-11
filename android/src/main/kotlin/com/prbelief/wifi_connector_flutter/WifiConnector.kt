package com.prbelief.wifi_connector_flutter

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.wifi.WifiNetworkSpecifier
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

class WifiConnector(private val context: Context) {
    private val connectivityManager: ConnectivityManager =
        context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    private var currentNetwork: Network? = null
    private var currentCallback: ConnectivityManager.NetworkCallback? = null

    suspend fun connectToWifi(
        ssid: String,
        password: String,
        onConnectionChanged: (Boolean) -> Unit = {}
    ): Result<Network> = suspendCancellableCoroutine { continuation ->
        try {
            val specifier = WifiNetworkSpecifier.Builder().apply {
                setSsid(ssid)
                setWpa2Passphrase(password)
            }.build()

            val request = NetworkRequest.Builder().apply {
                addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                removeCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                setNetworkSpecifier(specifier)
            }.build()

            val networkCallback = object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(network: Network) {
                    currentNetwork = network
                    connectivityManager.bindProcessToNetwork(network)
                    onConnectionChanged(true)
                    continuation.resume(Result.success(network))
                }

                override fun onLost(network: Network) {
                    currentNetwork = null
                    connectivityManager.bindProcessToNetwork(null)
                    onConnectionChanged(false)
                }

                override fun onUnavailable() {
                    continuation.resumeWithException(
                        Exception("Unable to connect to network: $ssid")
                    )
                }
            }

            currentCallback = networkCallback
            connectivityManager.requestNetwork(request, networkCallback)

            continuation.invokeOnCancellation {
                disconnect()
            }
        } catch (e: Exception) {
            continuation.resume(Result.failure(e))
        }
    }

    fun disconnect() {
        currentCallback?.let { callback ->
            connectivityManager.unregisterNetworkCallback(callback)
            currentCallback = null
        }
        currentNetwork = null
        connectivityManager.bindProcessToNetwork(null)
    }

    fun isConnected(): Boolean = currentNetwork != null
}