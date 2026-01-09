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
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      checkInTime: DateTime.parse(json['check_in_time']),
      checkInPhotoUrl: json['check_in_photo_url'] ?? '',
      checkInLatitude: (json['check_in_latitude'] ?? 0).toDouble(),
      checkInLongitude: (json['check_in_longitude'] ?? 0).toDouble(),
      checkInReason: json['check_in_reason'],
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'])
          : null,
      checkOutPhotoUrl: json['check_out_photo_url'],
      checkOutLatitude: json['check_out_latitude']?.toDouble(),
      checkOutLongitude: json['check_out_longitude']?.toDouble(),
      checkOutReason: json['check_out_reason'],
      status: json['status'] ?? 'checked_in',
      date: json['date'] ?? '',
    );
  }

  bool get hasCheckedOut => checkOutTime != null;
  bool get isLate => status == 'late';
  bool get isEarly => status == 'early_leave';
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
