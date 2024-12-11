/// Custom exception for WiFi connection errors
class WifiConnectorException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  WifiConnectorException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'WifiConnectorException($code): $message';
}