import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'attendance_detail_page.dart';
import 'attendance_status.dart';

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final List<Map<String, dynamic>> histories = [
    {
      'date': DateTime(2026, 1, 5),
      'checkIn': '06:45',
      'checkOut': '16:01',
      'checkInStatus': AttendanceStatus.success,
      'checkOutStatus': AttendanceStatus.success,
      'note': '',
    },
    {
      'date': DateTime(2026, 1, 6),
      'checkIn': '07:54',
      'checkOut': '13:34',
      'checkInStatus': AttendanceStatus.late,
      'checkOutStatus': AttendanceStatus.early,
      'note': 'Terlambat karena hujan',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = histories.where((e) {
      final d = e['date'] as DateTime;
      return d.month == selectedMonth && d.year == selectedYear;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Riwayat Kehadiran'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          buildFilter(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final item = filtered[i];
                return historyCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<int>(
              value: selectedMonth,
              isExpanded: true,
              items: List.generate(12, (i) {
                return DropdownMenuItem(
                  value: i + 1,
                  child: Text(
                    DateFormat.MMMM('id_ID').format(DateTime(0, i + 1)),
                  ),
                );
              }),
              onChanged: (v) => setState(() => selectedMonth = v!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<int>(
              value: selectedYear,
              isExpanded: true,
              items: [2025, 2026, 2027]
                  .map(
                    (y) =>
                        DropdownMenuItem(value: y, child: Text(y.toString())),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedYear = v!),
            ),
          ),
        ],
      ),
    );
  }

  Widget historyCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AttendanceDetailPage(data: data)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                DateFormat('EEEE, d MMMM y', 'id_ID').format(data['date']),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                statusBadge('Check-in', data['checkIn'], data['checkInStatus']),
                const SizedBox(height: 6),
                statusBadge(
                  'Check-out',
                  data['checkOut'],
                  data['checkOutStatus'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget statusBadge(String label, String time, AttendanceStatus status) {
    final color = statusColor(status);
    return SizedBox(
      width: 124,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color statusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.success:
        return const Color(0xFF7BC043);
      case AttendanceStatus.late:
      case AttendanceStatus.early:
        return const Color(0xFFD32F2F);
    }
  }
}
