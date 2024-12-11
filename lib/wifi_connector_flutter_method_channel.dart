import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wifi_connector_flutter/models/wifi_connection_result.dart';

import 'wifi_connector_flutter_platform_interface.dart';

/// An implementation of [WifiConnectorFlutterPlatform] that uses method channels
class MethodChannelWifiConnectorFlutter extends WifiConnectorFlutterPlatform {
  /// The method channel used to interact with the native platform
  final methodChannel = const MethodChannel('wifi_connector_flutter');

  /// Stream controller for connection status updates
  StreamController<bool>? _streamController;
  static bool _isListening = false;

  @override
  Future<WifiConnectionResult> connectToWifi({
    required String ssid,
    required String password,
  }) async {
    try {
      final result = await methodChannel.invokeMethod<Map>('connectToWifi', {
        'ssid': ssid,
        'password': password,
      });
      if (result == null) {
        return WifiConnectionResult(
          success: false,
          errorMessage: 'Unknown error',
        );
      }
      return WifiConnectionResult.fromMap(result);
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
    if (_streamController == null || _streamController!.isClosed) {
      _streamController = StreamController<bool>.broadcast(
        onListen: () async {
          _isListening = true;
          await methodChannel.invokeMethod('startListeningConnectionChanges');
        },
        onCancel: () async {
          _isListening = false;
          await methodChannel.invokeMethod('stopListeningConnectionChanges');
          _streamController?.close();
          _streamController = null;
        },
      );

      methodChannel.setMethodCallHandler((call) async {
        if (call.method == 'onConnectionChanged' && _isListening) {
          _streamController?.add(call.arguments as bool);
        }
      });
    }
    return _streamController!.stream;
  }

  @override
  void dispose() {
    _streamController?.close();
    _streamController = null;
  }
}
