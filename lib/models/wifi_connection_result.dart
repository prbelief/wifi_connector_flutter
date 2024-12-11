/// Result of a WiFi connection attempt
class WifiConnectionResult {
  final bool success;
  final String? errorMessage;
  final String? errorCode;

  WifiConnectionResult({
    required this.success,
    this.errorMessage,
    this.errorCode,
  });
}