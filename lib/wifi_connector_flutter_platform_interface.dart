import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wifi_connector_flutter/models/wifi_connection_result.dart';

import 'wifi_connector_flutter_method_channel.dart';

/// The interface that platform-specific implementations must implement
abstract class WifiConnectorFlutterPlatform extends PlatformInterface {
  /// Constructs a WifiConnectorFlutterPlatform
  WifiConnectorFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static WifiConnectorFlutterPlatform _instance = MethodChannelWifiConnectorFlutter();

  /// The default instance of [WifiConnectorFlutterPlatform] to use
  static WifiConnectorFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WifiConnectorFlutterPlatform] when
  /// they register themselves.
  static set instance(WifiConnectorFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Connects to a WiFi network
  Future<WifiConnectionResult> connectToWifi({
    required String ssid,
    required String password,
  }) {
    throw UnimplementedError('connectToWifi() has not been implemented.');
  }

  /// Disconnects from the current WiFi network
  Future<void> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  /// Checks if currently connected to a WiFi network
  Future<bool> isConnected() {
    throw UnimplementedError('isConnected() has not been implemented.');
  }

  /// Checks if the required permissions are granted
  Future<bool> checkPermissions() {
    throw UnimplementedError('checkPermissions() has not been implemented.');
  }

  /// Requests the required permissions
  Future<bool> requestPermissions() {
    throw UnimplementedError('requestPermissions() has not been implemented.');
  }

  /// Stream of connection status changes
  Stream<bool> get connectionStream {
    throw UnimplementedError('connectionStream has not been implemented.');
  }

  /// Disposes resources
  void dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }
}