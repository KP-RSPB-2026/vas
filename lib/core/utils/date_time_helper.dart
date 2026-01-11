class DateTimeHelper {
  // GMT+8 timezone offset (8 hours = 8 * 60 * 60 seconds)
  static const int _gmt8OffsetInSeconds = 8 * 60 * 60;
  
  // Nama hari dalam Bahasa Indonesia
  static const List<String> _dayNames = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  // Nama bulan dalam Bahasa Indonesia  
  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  /// Convert UTC DateTime to GMT+8 timezone
  static DateTime toGMT8(DateTime utcTime) {
    // If the time is already in local timezone or not UTC, convert to UTC first
    final utc = utcTime.toUtc();
    // Add 8 hours offset for GMT+8
    return utc.add(Duration(seconds: _gmt8OffsetInSeconds));
  }

  static String formatDate(DateTime date) {
    // Convert to GMT+8 before formatting
    final gmt8Date = toGMT8(date);
    final dayName = _dayNames[gmt8Date.weekday - 1];
    final monthName = _monthNames[gmt8Date.month - 1];
    return '$dayName, ${gmt8Date.day} $monthName ${gmt8Date.year}';
  }

  static String formatTime(DateTime time) {
    // Convert to GMT+8 before formatting
    final gmt8Time = toGMT8(time);
    final hour = gmt8Time.hour.toString().padLeft(2, '0');
    final minute = gmt8Time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String formatDateTime(DateTime dateTime) {
    // Convert to GMT+8 before formatting
    final gmt8DateTime = toGMT8(dateTime);
    final day = gmt8DateTime.day.toString().padLeft(2, '0');
    final monthName = _monthNames[gmt8DateTime.month - 1].substring(0, 3);
    final hour = gmt8DateTime.hour.toString().padLeft(2, '0');
    final minute = gmt8DateTime.minute.toString().padLeft(2, '0');
    return '$day $monthName ${gmt8DateTime.year} $hour:$minute';
  }

  static bool isLate(DateTime checkInTime) {
    // Convert to GMT+8 before checking
    final gmt8Time = toGMT8(checkInTime);
    final hour = gmt8Time.hour;
    final minute = gmt8Time.minute;
    
    if (hour > 7) return true;
    if (hour == 7 && minute > 0) return true;
    
    return false;
  }

  static bool isEarly(DateTime checkOutTime) {
    // Convert to GMT+8 before checking
    final gmt8Time = toGMT8(checkOutTime);
    final hour = gmt8Time.hour;
    final minute = gmt8Time.minute;
    
    if (hour < 16) return true;
    if (hour == 16 && minute < 0) return true;
    
    return false;
  }
}
