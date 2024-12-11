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
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    bool hasPermission =
                        await _wifiConnectorFlutterPlugin.requestPermissions();
                    if (hasPermission) {
                      // You can now connect to wifi
                    } else {
                      // You can show a dialog to the user to enable the permissions
                    }
                  },
                  child: const Text("Request Permissions"),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _ssidController,
                  decoration: const InputDecoration(
                    labelText: "SSID",
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _wifiConnectorFlutterPlugin.connectToWifi(
                      ssid: _ssidController.text.trim(),
                      password: _passwordController.text.trim(),
                    );
                  },
                  child: const Text("Connect to wifi"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _wifiConnectorFlutterPlugin.disconnect();
                  },
                  child: const Text("Disconnect from wifi"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
