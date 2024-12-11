import 'package:flutter/material.dart';

import 'package:wifi_connector_flutter/wifi_connector_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _wifiConnectorFlutterPlugin = WifiConnectorFlutter();
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                bool hasPermission = await _wifiConnectorFlutterPlugin.requestPermissions();
                if (hasPermission) {
                  // You can now connect to wifi
                } else {
                  // You can show a dialog to the user to enable the permissions
                }
              },
              child: const Text("Request Permissions"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _wifiConnectorFlutterPlugin.connectToWifi(
                  ssid: "PITSBIKE:BC2",
                  password: "12345678",
                );
              },
              child: const Text("Connect to wifi"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _wifiConnectorFlutterPlugin.disconnect();
              },
              child: const Text("Disconnect from wifi"),
            ),
          ],
        ),
      ),
    );
  }
}
