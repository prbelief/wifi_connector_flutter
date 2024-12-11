# Changelog

## 0.0.1 (2024-03-11)

### Added
- Initial release
- Basic WiFi connection functionality
  - Connect to WiFi networks without internet validation
  - Disconnect from networks
  - Check connection status
- Permission handling
  - Request and check for required permissions
  - Support for Android 10+ permissions
- Connection status monitoring
  - Real-time connection status updates via Stream
  - Connection state checking
- Error handling and result types
  - WifiConnectionResult for detailed connection status
  - Proper error messaging and codes
- Documentation
  - README with setup instructions
  - Usage examples
  - API documentation

### Requirements
- Minimum Android SDK: 29 (Android 10)
- Flutter: Any

### Known Issues
- iOS platform not supported
- Requires location permissions for WiFi operations on Android
