import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../screens/attendance_status.dart';

class StatusHeader extends StatelessWidget {
  final String label;
  final String time;
  final AttendanceStatus status;

  const StatusHeader({
    super.key,
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
              color: AppColors.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.textWhite,
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
        return AppColors.success;
      case AttendanceStatus.late:
      case AttendanceStatus.early:
        return AppColors.error;
    }
  }
}
