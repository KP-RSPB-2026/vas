class DateTimeHelper {
  // Nama hari dalam Bahasa Indonesia
  static const List<String> _dayNames = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  // Nama bulan dalam Bahasa Indonesia  
  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static String formatDate(DateTime date) {
    final dayName = _dayNames[date.weekday - 1];
    final monthName = _monthNames[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  static String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final monthName = _monthNames[dateTime.month - 1].substring(0, 3);
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day $monthName ${dateTime.year} $hour:$minute';
  }

  static bool isLate(DateTime checkInTime) {
    final hour = checkInTime.hour;
    final minute = checkInTime.minute;
    
    if (hour > 7) return true;
    if (hour == 7 && minute > 0) return true;
    
    return false;
  }

  static bool isEarly(DateTime checkOutTime) {
    final hour = checkOutTime.hour;
    final minute = checkOutTime.minute;
    
    if (hour < 16) return true;
    if (hour == 16 && minute < 0) return true;
    
    return false;
  }
}
