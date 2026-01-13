import 'package:flutter/material.dart';

import 'attendance_status.dart';

class AttendanceDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const AttendanceDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Detail Kehadiran'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusHeader(
            label: 'Check-in',
            time: data['checkIn'],
            status: data['checkInStatus'],
          ),
          const SizedBox(height: 12),
          const Text('Foto kehadiran'),
          const SizedBox(height: 8),
          const _PhotoBox(label: 'Foto Check-in'),
          const SizedBox(height: 16),
          const Text('Keterangan:'),
          const SizedBox(height: 4),
          Text(
            (data['note'] ?? '-').toString(),
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          _StatusHeader(
            label: 'Check-out',
            time: data['checkOut'],
            status: data['checkOutStatus'],
          ),
          const SizedBox(height: 12),
          const Text('Foto kehadiran'),
          const SizedBox(height: 8),
          const _PhotoBox(label: 'Foto Check-out'),
          const SizedBox(height: 16),
          const Text('Keterangan:'),
          const SizedBox(height: 4),
          Text(
            (data['note'] ?? '-').toString(),
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  bool get _hasNote =>
      data['note'] != null && data['note'].toString().isNotEmpty;
}

class _StatusHeader extends StatelessWidget {
  final String label;
  final String time;
  final AttendanceStatus status;

  const _StatusHeader({
    required this.label,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.success:
        return const Color(0xFF8BC34A);
      case AttendanceStatus.late:
      case AttendanceStatus.early:
        return const Color(0xFFC62828);
    }
  }
}

class _PhotoBox extends StatelessWidget {
  final String label;

  const _PhotoBox({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPreview(context),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFD7D7D7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      ),
    );
  }

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.image, size: 120, color: Colors.white),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
