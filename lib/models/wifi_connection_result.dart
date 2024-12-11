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

  factory WifiConnectionResult.fromMap(Map map) {
    return WifiConnectionResult(
      success: map['success'],
      errorMessage: map['errorMessage'],
      errorCode: map['errorCode'],
    );
  }
}