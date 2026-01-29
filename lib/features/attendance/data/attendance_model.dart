import '../../../core/utils/date_time_helper.dart';

class Attendance {
  final String id;
  final String userId;
  final DateTime checkInTime;
  final String checkInPhotoUrl;
  final double checkInLatitude;
  final double checkInLongitude;
  final String? checkInReason;
  final DateTime? checkOutTime;
  final String? checkOutPhotoUrl;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? checkOutReason;
  final String status;
  final String date;
  final bool? isLateFromServer;
  final bool? isEarlyFromServer;

  Attendance({
    required this.id,
    required this.userId,
    required this.checkInTime,
    required this.checkInPhotoUrl,
    required this.checkInLatitude,
    required this.checkInLongitude,
    this.checkInReason,
    this.checkOutTime,
    this.checkOutPhotoUrl,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutReason,
    required this.status,
    required this.date,
    this.isLateFromServer,
    this.isEarlyFromServer,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date']?.toString() ?? '';
    final dateOnly = rawDate.contains('T') ? rawDate.split('T').first : rawDate;

    return Attendance(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      checkInTime: DateTime.parse(json['check_in_time'].toString()),
        checkInPhotoUrl: json['check_in_photo_url'] ?? '',
        checkInLatitude: double.tryParse(json['check_in_latitude']?.toString() ?? '') ?? 0,
        checkInLongitude: double.tryParse(json['check_in_longitude']?.toString() ?? '') ?? 0,
      checkInReason: json['check_in_reason'],
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'].toString())
          : null,
      checkOutPhotoUrl: json['check_out_photo_url'],
        checkOutLatitude: json['check_out_latitude'] != null
          ? double.tryParse(json['check_out_latitude'].toString())
          : null,
        checkOutLongitude: json['check_out_longitude'] != null
          ? double.tryParse(json['check_out_longitude'].toString())
          : null,
      checkOutReason: json['check_out_reason'],
      status: json['status']?.toString() ?? 'checked_in',
          date: dateOnly,
      isLateFromServer: json['is_late_check_in'] is bool
          ? json['is_late_check_in']
          : (json['is_late_check_in'] is num ? (json['is_late_check_in'] as num) == 1 : null),
      isEarlyFromServer: json['is_early_check_out'] is bool
          ? json['is_early_check_out']
          : (json['is_early_check_out'] is num ? (json['is_early_check_out'] as num) == 1 : null),
    );
  }

  bool get hasCheckedOut => checkOutTime != null;
  
    // Prefer server-calculated flags (respecting server env), fallback to client calc
    bool get isLate => isLateFromServer ?? DateTimeHelper.isLate(checkInTime);
  
    bool get isEarly => checkOutTime != null 
      ? (isEarlyFromServer ?? DateTimeHelper.isEarly(checkOutTime!))
      : false;
      
  bool get isCompleted => status == 'completed';
}

class LocationValidation {
  final bool isValid;
  final int distance;
  final int allowedRadius;
  final String message;

  LocationValidation({
    required this.isValid,
    required this.distance,
    required this.allowedRadius,
    required this.message,
  });

  factory LocationValidation.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return LocationValidation(
      isValid: data['isValid'] ?? false,
      distance: data['distance'] ?? 0,
      allowedRadius: data['allowedRadius'] ?? 0,
      message: data['message'] ?? '',
    );
  }
}
