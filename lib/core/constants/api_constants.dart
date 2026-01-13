import '../utils/base_url_resolver.dart' as env;

class ApiConstants {
  // Base URL (otomatis sesuai platform). Bisa override dengan
  // `--dart-define=API_BASE_URL=http://IP:3000/api` saat run/build.
  static final String baseUrl = env.resolveBaseUrl();

  // Auth endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';

  // Location endpoints
  static const String validateLocation = '/location/validate';

  // Attendance endpoints
  static const String checkIn = '/attendance/check-in';
  static const String checkOut = '/attendance/check-out';
  static const String attendanceHistory = '/attendance/history';
  static const String attendanceDetail = '/attendance/detail';

  // Users endpoints (Admin)
  static const String users = '/users';

  // Headers
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
