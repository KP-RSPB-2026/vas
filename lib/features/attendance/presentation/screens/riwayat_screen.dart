import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'attendance_detail_page.dart';
import 'attendance_status.dart';
import '../widgets/history_card.dart';
import '../../data/attendance_model.dart';
import '../../data/attendance_history_cache.dart';
import '../../../../core/utils/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';

class AttendanceHistoryPage extends ConsumerStatefulWidget {
  final String? employeeId;
  final String? employeeName;

  const AttendanceHistoryPage({
    super.key,
    this.employeeId,
    this.employeeName,
  });

  @override
  ConsumerState<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends ConsumerState<AttendanceHistoryPage> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  List<Attendance> _items = [];
  bool _hasMore = false;
  int _page = 1;
  int? _total;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final entry = await ref.read(attendanceHistoryCacheProvider.notifier).fetch(
            month: selectedMonth,
            year: selectedYear,
            page: 1,
            limit: 31,
            includePhotos: false,
            employeeId: widget.employeeId,
          );

      if (!mounted) return;

      setState(() {
        _items = entry.items;
        _hasMore = entry.hasMore;
        _page = 1;
        _total = entry.total;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final nextPage = _page + 1;
      final entry = await ref.read(attendanceHistoryCacheProvider.notifier).fetch(
            month: selectedMonth,
            year: selectedYear,
            page: nextPage,
            limit: 31,
            includePhotos: false,
            employeeId: widget.employeeId,
          );
      if (!mounted) return;
      setState(() {
        _items = entry.items;
        _hasMore = entry.hasMore;
        _page = nextPage;
        _total = entry.total;
      });
    } finally {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((e) {
      final d = DateTimeHelper.toGMT8(e.checkInTime);
      return d.month == selectedMonth && d.year == selectedYear;
    }).toList()
      ..sort((a, b) => DateTimeHelper
          .toGMT8(b.checkInTime)
          .compareTo(DateTimeHelper.toGMT8(a.checkInTime))); // newest first

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Riwayat Kehadiran'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.primary),
        titleTextStyle: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (widget.employeeName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.employeeName!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
            ),
          buildFilter(),
          if (_total != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 1),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Total ${_total} record',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _fetch();
              },
              child: _loading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(
                          height: 300,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    )
                  : _error != null
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: 300,
                              child: Center(child: Text(_error!)),
                            ),
                          ],
                        )
                      : filtered.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(
                                  height: 300,
                                  child: Center(child: Text('Belum ada riwayat untuk periode ini')),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length + (_hasMore ? 1 : 0),
                              itemBuilder: (_, i) {
                                if (_hasMore && i == filtered.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: _loadingMore
                                        ? const Center(child: CircularProgressIndicator())
                                        : TextButton(
                                            onPressed: _loadMore,
                                            child: const Text('Muat lebih banyak'),
                                          ),
                                  );
                                }
                                final a = filtered[i];
                                final dateLabel = DateFormat('EEEE, d MMMM y', 'id_ID')
                                    .format(DateTimeHelper.toGMT8(a.checkInTime));
                                final checkInTime = DateTimeHelper.formatTime(a.checkInTime);
                                final checkInStatus = a.isLate
                                    ? AttendanceStatus.late
                                    : AttendanceStatus.success;
                                final checkOutTime = a.checkOutTime != null
                                    ? DateTimeHelper.formatTime(a.checkOutTime!)
                                    : null;
                                final checkOutStatus = a.checkOutTime != null
                                    ? (a.isEarly ? AttendanceStatus.early : AttendanceStatus.success)
                                    : null; // null -> grey pill

                                return HistoryCard(
                                  dateLabel: dateLabel,
                                  checkInTime: checkInTime,
                                  checkInStatus: checkInStatus,
                                  checkOutTime: checkOutTime,
                                  checkOutStatus: checkOutStatus,
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AttendanceDetailPage(attendanceId: a.id, fallback: {
                                          'checkIn': checkInTime,
                                          'checkOut': checkOutTime,
                                          'checkInStatus': checkInStatus,
                                          'checkOutStatus': checkOutStatus,
                                        }),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
              onChanged: (v) {
                setState(() => selectedMonth = v!);
                _fetch();
              },
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
              onChanged: (v) {
                setState(() => selectedYear = v!);
                _fetch();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Old inline card/badge removed in favor of HistoryCard widget
}
