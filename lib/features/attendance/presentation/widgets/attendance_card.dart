import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum AttendanceStatus {
  disabled, // Gray - tidak bisa ditekan
  active, // Blue - bisa ditekan
  success, // Green - selesai, tepat waktu
  late, // Red - selesai, terlambat/dini
}

class AttendanceCard extends StatelessWidget {
  final String title;
  final String time;
  final AttendanceStatus status;
  final String message;
  final bool isActive;
  final bool isCheckOut;
  final VoidCallback? onTap;

  const AttendanceCard({
    super.key,
    required this.title,
    required this.time,
    required this.status,
    required this.message,
    this.isActive = false,
    this.isCheckOut = false,
    this.onTap,
  });

  Color _getBackgroundColor() {
    switch (status) {
      case AttendanceStatus.disabled:
        return Colors.white;
      case AttendanceStatus.active:
        return AppColors.buttonInArea;
      case AttendanceStatus.success:
        return AppColors.buttonSuccess;
      case AttendanceStatus.late:
        return AppColors.buttonLate;
    }
  }

  Color _getTextColor() {
    return status == AttendanceStatus.disabled
        ? AppColors.textDisabled
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: status == AttendanceStatus.disabled
                ? AppColors.error
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Time
            Text(
              time,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: _getTextColor(),
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _getTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),

            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _getTextColor().withAlpha((0.9 * 255).round()),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
