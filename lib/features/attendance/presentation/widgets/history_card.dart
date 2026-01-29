import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../screens/attendance_status.dart';

class HistoryCard extends StatelessWidget {
  final String dateLabel;
  final String checkInTime;
  final AttendanceStatus checkInStatus;
  final String? checkOutTime;
  final AttendanceStatus? checkOutStatus;
  final VoidCallback? onTap;

  const HistoryCard({
    super.key,
    required this.dateLabel,
    required this.checkInTime,
    required this.checkInStatus,
    required this.checkOutTime,
    required this.checkOutStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  dateLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusPill(
                  label: 'Check-in',
                  time: checkInTime,
                  status: checkInStatus,
                  width: 70,
                ),
                const SizedBox(width: 8),
                _StatusPill(
                  label: 'Check-out',
                  time: checkOutTime ?? '-',
                  status: checkOutStatus,
                  width: 70,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final String time;
  final AttendanceStatus? status;
  final double? width;

  const _StatusPill({
    required this.label,
    required this.time,
    required this.status,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = status == null;
    final bg = isDisabled ? AppColors.disabled : _statusColor(status!);
    final textColor = isDisabled ? AppColors.textDisabled : AppColors.textWhite;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      constraints: BoxConstraints.tightFor(width: width ?? 108),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            time,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
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
