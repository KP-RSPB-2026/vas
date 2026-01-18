import 'package:flutter/material.dart';
import '../../../attendance/presentation/screens/riwayat_screen.dart';

class EmployeeHistoryScreen extends StatelessWidget {
  final String employeeId;
  final String? employeeName;

  const EmployeeHistoryScreen({super.key, required this.employeeId, this.employeeName});

  @override
  Widget build(BuildContext context) {
    return AttendanceHistoryPage(
      employeeId: employeeId,
      employeeName: employeeName,
    );
  }
}
