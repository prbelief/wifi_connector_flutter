
import 'package:wifi_connector_flutter/models/wifi_connection_result.dart';

import 'wifi_connector_flutter_platform_interface.dart';
export 'wifi_connector_flutter_platform_interface.dart';
export 'models/wifi_connection_result.dart';
export 'models/wifi_connector_exception.dart';

class WifiConnectorFlutter {
  /// Connects to a WiFi network
  Future<WifiConnectionResult> connectToWifi({
    required String ssid,
    required String password,
  }) {
    return WifiConnectorFlutterPlatform.instance
        .connectToWifi(ssid: ssid, password: password);
  }

  /// Disconnects from the current WiFi network
  Future<void> disconnect() {
    return WifiConnectorFlutterPlatform.instance.disconnect();
  }

  /// Checks if currently connected to a WiFi network
  Future<bool> isConnected() {
    return WifiConnectorFlutterPlatform.instance.isConnected();
  }

  /// Checks if the required permissions are granted
  Future<bool> checkPermissions() {
    return WifiConnectorFlutterPlatform.instance.checkPermissions();
  }

  /// Requests the required permissions
  Future<bool> requestPermissions() {
    return WifiConnectorFlutterPlatform.instance.requestPermissions();
  }

  /// Stream of connection status changes
  Stream<bool> get connectionStream {
    return WifiConnectorFlutterPlatform.instance.connectionStream;
  }

  /// Disposes resources
  void dispose() {
    WifiConnectorFlutterPlatform.instance.dispose();
  }
}
