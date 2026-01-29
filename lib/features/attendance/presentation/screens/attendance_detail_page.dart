import 'package:flutter/material.dart';
import '../widgets/status_header.dart';
import '../widgets/photo_box.dart';
import 'attendance_status.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/date_time_helper.dart';

class AttendanceDetailPage extends StatefulWidget {
  final String attendanceId;
  final Map<String, dynamic> fallback;

  const AttendanceDetailPage({super.key, required this.attendanceId, required this.fallback});

  @override
  State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService().getAttendanceDetail(widget.attendanceId);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final d = res.data['data'] as Map<String, dynamic>;
        final checkInTime = DateTime.parse(d['check_in_time']);
        final checkOutTime = d['check_out_time'] != null ? DateTime.parse(d['check_out_time']) : null;
        setState(() {
          String resolvePhoto(String? path) {
            if (path == null || path.isEmpty) return '';
            if (path.startsWith('http')) return path;
            final base = ApiConstants.baseUrl;
            final origin = base.contains('/api') ? base.split('/api').first : base;
            return '$origin$path';
          }

          _data = {
            'checkIn': DateTimeHelper.formatTime(checkInTime),
            'checkOut': checkOutTime != null ? DateTimeHelper.formatTime(checkOutTime) : null,
            'checkInStatus': (d['is_late_check_in'] ?? false) ? AttendanceStatus.late : AttendanceStatus.success,
            'checkOutStatus': checkOutTime != null
                ? ((d['is_early_check_out'] ?? false) ? AttendanceStatus.early : AttendanceStatus.success)
                : null,
            'checkInPhotoUrl': resolvePhoto(d['check_in_photo_url'] as String?),
            'checkOutPhotoUrl': resolvePhoto(d['check_out_photo_url'] as String?),
            'checkInReason': d['check_in_reason'] ?? '-',
            'checkOutReason': d['check_out_reason'] ?? '-',
          };
        });
      } else {
        setState(() => _error = 'Gagal memuat detail');
      }
    } catch (e) {
      setState(() => _error = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data ?? widget.fallback;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Detail Kehadiran'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    StatusHeader(
                      label: 'Check-in',
                      time: data['checkIn'],
                      status: data['checkInStatus'],
                    ),
                    const SizedBox(height: 12),
                    const Text('Foto kehadiran'),
                    const SizedBox(height: 8),
                    PhotoBox(label: 'Foto Check-in', imageUrl: data['checkInPhotoUrl'] as String?),
                    const SizedBox(height: 16),
                    const Text('Keterangan:'),
                    const SizedBox(height: 4),
                    Text(
                      (data['checkInReason'] ?? '-').toString(),
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    if (data['checkOut'] != null) ...[
                      StatusHeader(
                        label: 'Check-out',
                        time: data['checkOut'],
                        status: data['checkOutStatus'] ?? AttendanceStatus.success,
                      ),
                      const SizedBox(height: 12),
                      const Text('Foto kehadiran'),
                      const SizedBox(height: 8),
                      PhotoBox(label: 'Foto Check-out', imageUrl: data['checkOutPhotoUrl'] as String?),
                      const SizedBox(height: 16),
                      const Text('Keterangan:'),
                      const SizedBox(height: 4),
                      Text(
                        (data['checkOutReason'] ?? '-').toString(),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ],
                ),
    );
  }
}

