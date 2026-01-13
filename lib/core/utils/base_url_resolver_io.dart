import 'dart:io';

String resolveBaseUrl() {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) return override;

  // Android emulator uses 10.0.2.2 to reach host machine
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api';
  }

  // iOS simulator, desktop apps resolve localhost directly
  return 'http://localhost:3000/api';
}
