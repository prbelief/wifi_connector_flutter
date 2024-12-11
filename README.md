# WiFi Connector Flutter Plugin

A Flutter plugin to connect to WiFi networks on Android devices without internet validation. This plugin allows direct WiFi connection even when the network has no internet access.

## Getting Started

### Prerequisites
- Minimum Android SDK: 29 (Android 10)
- Flutter: any

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  wifi_connector_flutter: ^0.0.1
```

or

```yaml
dependencies:
  wifi_connector_flutter:
    git:
      url: https://github.com/prbelief/wifi_connector_flutter
      ref: <TAG VERSION>
```

### Android Setup

1. Set the minimum SDK version in your `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 29
    }
}
```

2. Add required permissions to your `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <!-- WiFi permissions -->
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES" 
                     android:usesPermissionFlags="neverForLocation"/>

    <application
        android:networkSecurityConfig="@xml/network_security_config"
        ...>
        ...
    </application>
</manifest>
```

3. Create network security configuration file at `android/app/src/main/res/xml/network_security_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

## Usage

### Basic Usage

```dart
import 'package:wifi_connector_flutter/wifi_connector_flutter.dart';

// Check permissions
bool hasPermissions = await WifiConnectorFlutter.checkPermissions();
if (!hasPermissions) {
  // Request permissions
  hasPermissions = await WifiConnectorFlutter.requestPermissions();
}

if (hasPermissions) {
  try {
    // Connect to WiFi
    WifiConnectionResult result = await WifiConnectorFlutter.connectToWifi(
      ssid: "YourWiFiName",
      password: "YourWiFiPassword"
    );

    if (result.success) {
      print("Connected successfully!");
    } else {
      print("Connection failed: ${result.errorMessage}");
    }
  } catch (e) {
    print("Error: $e");
  }
}
```

### Monitor Connection Status

```dart
// Listen to connection status changes
WifiConnectorFlutter.connectionStream.listen((bool isConnected) {
  print("Connection status: ${isConnected ? 'Connected' : 'Disconnected'}");
});
```

### Check Connection Status

```dart
bool isConnected = await WifiConnectorFlutter.isConnected();
print("Currently connected: $isConnected");
```

### Disconnect

```dart
await WifiConnectorFlutter.disconnect();
```

### Cleanup

```dart
@override
void dispose() {
  WifiConnectorFlutter.dispose();
  super.dispose();
}
```

## API Reference

### Methods

- `Future<WifiConnectionResult> connectToWifi({required String ssid, required String password})`
  - Connects to a specified WiFi network
  - Returns a `WifiConnectionResult` containing success status and error information

- `Future<void> disconnect()`
  - Disconnects from the current WiFi network

- `Future<bool> isConnected()`
  - Checks if currently connected to a WiFi network

- `Future<bool> checkPermissions()`
  - Checks if all required permissions are granted

- `Future<bool> requestPermissions()`
  - Requests the required permissions from the user

- `Stream<bool> get connectionStream`
  - Stream of connection status changes

- `void dispose()`
  - Cleans up resources

### Classes

```dart
class WifiConnectionResult {
  final bool success;
  final String? errorMessage;
  final String? errorCode;
}
```

## Notes

- This plugin only supports Android 10 (API level 29) and above
- Location permissions are required for WiFi operations on Android
- The plugin bypasses internet validation, allowing connection to networks without internet access
- Always handle permissions before attempting to connect

## License

This project is licensed under the MIT License - see the LICENSE file for details
