import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'attendance_model.dart';

class TodayAttendanceCacheEntry {
  final Attendance? attendance;
  final DateTime fetchedAt;

  const TodayAttendanceCacheEntry({required this.attendance, required this.fetchedAt});
}

final todayAttendanceCacheProvider = StateProvider<TodayAttendanceCacheEntry?>((ref) => null);
