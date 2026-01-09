class AppConstants {
  // App info
  static const String appName = 'VAS Presensi';
  static const String appVersion = '1.0.0';
  
  // Storage keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyUserRole = 'user_role';
  
  // Work hours
  static const int workStartHour = 7;
  static const int workStartMinute = 0;
  static const int workEndHour = 16;
  static const int workEndMinute = 0;
  
  // Office location (untuk validasi) - sesuai emulator dan Supabase
  static const double officeLat = 37.42199830;
  static const double officeLng = -122.08400000;
  static const int officeRadius = 50; // meters
  
  // Image settings
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
}
