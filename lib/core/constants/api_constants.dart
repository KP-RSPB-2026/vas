class ApiConstants {
  // Base URL
  // Untuk emulator Android gunakan: 10.0.2.2
  // Untuk iOS simulator gunakan: localhost
  // Untuk device fisik, ganti dengan IP komputer (cek dengan ipconfig/ifconfig)
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Uncomment ini jika test di device fisik:
  // static const String baseUrl = 'http://192.168.x.x:3000/api';
  
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
