import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/date_time_helper.dart';
import '../../../../core/utils/location_helper.dart';
import '../../../../shared/services/location_service.dart';
import '../../../../shared/services/camera_service.dart';
import '../../../../shared/services/api_service.dart';
import '../../data/attendance_model.dart';
import '../widgets/attendance_card.dart';
import 'photo_confirmation_screen.dart';

class PresensiScreen extends ConsumerStatefulWidget {
  const PresensiScreen({super.key});

  @override
  ConsumerState<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends ConsumerState<PresensiScreen> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  Position? _currentPosition;
  bool _isInArea = false;
  Attendance? _todayAttendance;
  bool _isLoadingAttendance = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initLocation();
    _loadTodayAttendance();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });
  }

  Future<void> _initLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null && mounted) {
        setState(() {
          _currentPosition = position;
          final distance = LocationHelper.calculateDistance(
            position.latitude,
            position.longitude,
            AppConstants.officeLat,
            AppConstants.officeLng,
          );
          _isInArea = distance <= AppConstants.officeRadius.toDouble();
          
          AppLogger.i('Distance to office: ${distance.toStringAsFixed(2)} meters (radius: ${AppConstants.officeRadius}m)');
        });
      }
    } catch (e) {
      AppLogger.e('Error getting location', e);
    }
  }
     
  Future<void> _loadTodayAttendance() async {
    setState(() => _isLoadingAttendance = true);

    try {
      final response = await ApiService().getHistory(limit: 1);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List attendances = response.data['data'];
        if (attendances.isNotEmpty) {
          final attendance = Attendance.fromJson(attendances.first);
          final today = DateTime.now();
          final attendanceDate = DateTime.parse(attendance.date);

          // Check if attendance is from today
          if (attendanceDate.year == today.year &&
              attendanceDate.month == today.month &&
              attendanceDate.day == today.day) {
            if (mounted) {
              setState(() => _todayAttendance = attendance);
            }
          }
        }
      }
    } catch (e) {
      AppLogger.e('Error loading today attendance', e);
    } finally {
      if (mounted) {
        setState(() => _isLoadingAttendance = false);
      }
    }
  }

  Future<void> _handleCheckIn() async {
    if (!_isInArea || _currentPosition == null) {
      _showError('Anda harus berada di area RSPB!');
      return;
    }

    if (_todayAttendance != null) {
      _showError('Anda sudah check-in hari ini!');
      return;
    }

    // Take selfie
    final photoFile = await CameraService.takeSelfie();
    if (photoFile == null) {
      _showError('Foto diperlukan untuk check-in');
      return;
    }

    // Check if late
    final isLate = DateTimeHelper.isLate(_currentTime);

    // Navigate to photo confirmation screen
    if (mounted) {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoConfirmationScreen(
            photoFile: photoFile,
            isLate: isLate,
            title: 'Konfirmasi Check-in',
          ),
        ),
      );

      // If user cancelled (result is null means user pressed X/back)
      if (result == null) {
        return;
      }

      // If late and no reason provided
      if (isLate && result.isEmpty) {
        _showError('Alasan harus diisi karena Anda terlambat');
        return;
      }

      // Submit check-in
      _submitCheckIn(photoFile, result.isEmpty ? null : result);
    }
  }

  Future<void> _submitCheckIn(File photoFile, String? reason) async {
    if (_currentPosition == null) return;

    AppLogger.i('Submitting check-in with photo: ${photoFile.path}');
    AppLogger.i('Photo exists: ${photoFile.existsSync()}');
    AppLogger.i('Coordinates: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
    AppLogger.i('Reason: $reason');

    _showLoading();

    try {
      final response = await ApiService().checkIn(
        photoPath: photoFile.path,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        reason: reason,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final attendance = Attendance.fromJson(response.data['data']['attendance']);
        setState(() => _todayAttendance = attendance);
        _hideLoading();
        _showSuccess('Check-in berhasil!');
      } else {
        _hideLoading();
        _showError(response.data['error'] ?? 'Check-in gagal');
      }
    } catch (e) {
      _hideLoading();
      AppLogger.e('Check-in error', e);
      _showError('Terjadi kesalahan saat check-in');
    }
  }

  Future<void> _handleCheckOut() async {
    if (!_isInArea || _currentPosition == null) {
      _showError('Anda harus berada di area RSPB!');
      return;
    }

    if (_todayAttendance == null) {
      _showError('Anda belum check-in hari ini!');
      return;
    }

    if (_todayAttendance!.hasCheckedOut) {
      _showError('Anda sudah check-out hari ini!');
      return;
    }

    // Take selfie
    final photoFile = await CameraService.takeSelfie();
    if (photoFile == null) {
      _showError('Foto diperlukan untuk check-out');
      return;
    }

    // Check if early
    final isEarly = DateTimeHelper.isEarly(_currentTime);

    // Navigate to photo confirmation screen
    if (mounted) {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoConfirmationScreen(
            photoFile: photoFile,
            isLate: isEarly,
            title: 'Konfirmasi Check-out',
          ),
        ),
      );

      // If user cancelled (result is null means user pressed X/back)
      if (result == null) {
        return;
      }

      // If early and no reason provided
      if (isEarly && result.isEmpty) {
        _showError('Alasan harus diisi karena Anda pulang terlalu dini');
        return;
      }

      // Submit check-out
      _submitCheckOut(photoFile, result.isEmpty ? null : result);
    }
  }

  Future<void> _submitCheckOut(File photoFile, String? reason) async {
    if (_currentPosition == null) return;

    _showLoading();

    try {
      final response = await ApiService().checkOut(
        photoPath: photoFile.path,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        reason: reason,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final attendance = Attendance.fromJson(response.data['data']['attendance']);
        setState(() => _todayAttendance = attendance);
        _hideLoading();
        _showSuccess('Check-out berhasil!');
      } else {
        _hideLoading();
        _showError(response.data['error'] ?? 'Check-out gagal');
      }
    } catch (e) {
      _hideLoading();
      AppLogger.e('Check-out error', e);
      _showError('Terjadi kesalahan saat check-out');
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _hideLoading() {
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoadingAttendance
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _initLocation();
                await _loadTodayAttendance();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      'Presensi',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                    // Date
                    Text(
                      DateTimeHelper.formatDate(_currentTime),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 32),

                    // Check-in Card
                    AttendanceCard(
                      title: 'Check-in',
                      time: _todayAttendance != null
                          ? DateTimeHelper.formatTime(_todayAttendance!.checkInTime)
                          : DateTimeHelper.formatTime(_currentTime),
                      status: _getCheckInStatus(),
                      message: _getCheckInMessage(),
                      isActive: _todayAttendance == null && _isInArea,
                      isCheckOut: false,
                      onTap: _todayAttendance == null && _isInArea
                          ? _handleCheckIn
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Check-out Card
                    AttendanceCard(
                      title: 'Check-out',
                      time: _todayAttendance?.checkOutTime != null
                          ? DateTimeHelper.formatTime(_todayAttendance!.checkOutTime!)
                          : DateTimeHelper.formatTime(_currentTime),
                      status: _getCheckOutStatus(),
                      message: _getCheckOutMessage(),
                      isActive: _todayAttendance != null &&
                          !_todayAttendance!.hasCheckedOut &&
                          _isInArea,
                      isCheckOut: true,
                      onTap: _todayAttendance != null &&
                              !_todayAttendance!.hasCheckedOut &&
                              _isInArea
                          ? _handleCheckOut
                          : null,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  AttendanceStatus _getCheckInStatus() {
    if (_todayAttendance == null) {
      return _isInArea
          ? AttendanceStatus.active
          : AttendanceStatus.disabled;
    }
    return _todayAttendance!.isLate
        ? AttendanceStatus.late
        : AttendanceStatus.success;
  }

  String _getCheckInMessage() {
    if (_todayAttendance == null) {
      return _isInArea
          ? 'Tekan untuk check-in'
          : 'Anda harus berada di area RSPB!';
    }
    return _todayAttendance!.isLate
        ? 'Check-in berhasil'
        : 'Berhasil check-in';
  }

  AttendanceStatus _getCheckOutStatus() {
    if (_todayAttendance == null) {
      return AttendanceStatus.disabled;
    }
    if (_todayAttendance!.hasCheckedOut) {
      return _todayAttendance!.isEarly
          ? AttendanceStatus.late
          : AttendanceStatus.success;
    }
    return _isInArea
        ? AttendanceStatus.active
        : AttendanceStatus.disabled;
  }

  String _getCheckOutMessage() {
    if (_todayAttendance == null) {
      return 'Anda perlu check-in dahulu';
    }
    if (_todayAttendance!.hasCheckedOut) {
      return _todayAttendance!.isEarly
          ? 'Berhasil check-out'
          : 'Berhasil check-out';
    }
    return _isInArea
        ? 'Tekan untuk check-out'
        : 'Anda harus berada di area RSPB!';
  }
}
