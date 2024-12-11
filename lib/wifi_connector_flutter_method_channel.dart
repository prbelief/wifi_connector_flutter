import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wifi_connector_flutter/models/wifi_connection_result.dart';

import 'wifi_connector_flutter_platform_interface.dart';

/// An implementation of [WifiConnectorFlutterPlatform] that uses method channels
class MethodChannelWifiConnectorFlutter extends WifiConnectorFlutterPlatform {
  /// The method channel used to interact with the native platform
  final methodChannel = const MethodChannel('wifi_connector_flutter');

  /// Stream controller for connection status updates
  StreamController<bool>? _connectionStreamController;

  @override
  Future<WifiConnectionResult> connectToWifi({
    required String ssid,
    required String password,
  }) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('connectToWifi', {
        'ssid': ssid,
        'password': password,
      });

      return WifiConnectionResult(success: result ?? false);
    } on PlatformException catch (e) {
      return WifiConnectionResult(
        success: false,
        errorMessage: e.message,
        errorCode: e.code,
      );
    }
  }

  @override
  Future<void> disconnect() async {
    await methodChannel.invokeMethod<void>('disconnect');
  }

  @override
  Future<bool> isConnected() async {
    final result = await methodChannel.invokeMethod<bool>('isConnected');
    return result ?? false;
  }

  @override
  Future<bool> checkPermissions() async {
    final result = await methodChannel.invokeMethod<bool>('checkPermissions');
    return result ?? false;
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final result =
          await methodChannel.invokeMethod<bool>('requestPermissions');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  @override
  Stream<bool> get connectionStream {
    _connectionStreamController ??= StreamController<bool>.broadcast();

    methodChannel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onConnectionChanged':
          _connectionStreamController?.add(call.arguments as bool);
          break;
      }
    });

    return _connectionStreamController!.stream;
  }

  @override
  void dispose() {
    _connectionStreamController?.close();
    _connectionStreamController = null;
  }
}
