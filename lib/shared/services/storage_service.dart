import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  static Future<void> saveToken(String accessToken, String refreshToken) async {
    await _prefs?.setString(AppConstants.keyAccessToken, accessToken);
    await _prefs?.setString(AppConstants.keyRefreshToken, refreshToken);
  }

  static String? getAccessToken() {
    return _prefs?.getString(AppConstants.keyAccessToken);
  }

  static String? getRefreshToken() {
    return _prefs?.getString(AppConstants.keyRefreshToken);
  }

  static Future<void> clearTokens() async {
    await _prefs?.remove(AppConstants.keyAccessToken);
    await _prefs?.remove(AppConstants.keyRefreshToken);
  }

  // User data management
  static Future<void> saveUserData({
    required String userId,
    required String email,
    required String name,
    required String role,
  }) async {
    await _prefs?.setString(AppConstants.keyUserId, userId);
    await _prefs?.setString(AppConstants.keyUserEmail, email);
    await _prefs?.setString(AppConstants.keyUserName, name);
    await _prefs?.setString(AppConstants.keyUserRole, role);
  }

  static Map<String, String?> getUserData() {
    return {
      'id': _prefs?.getString(AppConstants.keyUserId),
      'email': _prefs?.getString(AppConstants.keyUserEmail),
      'name': _prefs?.getString(AppConstants.keyUserName),
      'role': _prefs?.getString(AppConstants.keyUserRole),
    };
  }

  static Future<void> clearUserData() async {
    await _prefs?.remove(AppConstants.keyUserId);
    await _prefs?.remove(AppConstants.keyUserEmail);
    await _prefs?.remove(AppConstants.keyUserName);
    await _prefs?.remove(AppConstants.keyUserRole);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await clearTokens();
    await clearUserData();
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
