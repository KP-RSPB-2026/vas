import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
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
  bool _exporting = false;
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
        actions: [
          if (widget.employeeId != null)
            IconButton(
              onPressed: _loading || _exporting
                  ? null
                  : () {
                      _exportPdf(filtered);
                    },
              tooltip: 'Export PDF',
              icon: _exporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
            ),
        ],
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
                      'Total $_total record',
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

  Future<void> _exportPdf(List<Attendance> filtered) async {
    if (_exporting) return;
    setState(() => _exporting = true);

    try {
      final redEntries = filtered.where((a) => a.isLate || a.isEarly).toList()
        ..sort(
          (a, b) => DateTimeHelper
              .toGMT8(a.checkInTime)
              .compareTo(DateTimeHelper.toGMT8(b.checkInTime)),
        );
      if (redEntries.isEmpty) {
        _showSnack('Tidak ada keterlambatan/pulang dini di bulan ini');
        return;
      }

      final monthLabel = DateFormat.MMMM('id_ID').format(DateTime(selectedYear, selectedMonth));
      pdf.PdfColor pdfColor(Color c) => pdf.PdfColor.fromInt(c.value);
      pw.Widget timeCell(String text, bool isFlagged) {
        final bg = isFlagged ? AppColors.error : AppColors.success;
        final fg = isFlagged ? AppColors.textWhite : AppColors.textPrimary;
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          color: pdfColor(bg),
          child: pw.Text(text, style: pw.TextStyle(color: pdfColor(fg), fontSize: 11)),
        );
      }

      pw.Widget plainCell(String text) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
          );

      final rows = redEntries.map((a) {
        final date = DateFormat('d MMM y', 'id_ID').format(DateTimeHelper.toGMT8(a.checkInTime));
        final ci = DateTimeHelper.formatTime(a.checkInTime);
        final co = a.checkOutTime != null ? DateTimeHelper.formatTime(a.checkOutTime!) : '-';
        final status = [
          if (a.isLate) 'Terlambat',
          if (a.isEarly) 'Pulang dini',
        ].join(' & ');
        final reasonParts = <String>[
          if (a.isLate && (a.checkInReason ?? '').trim().isNotEmpty) 'In: ${a.checkInReason!.trim()}',
          if (a.isEarly && (a.checkOutReason ?? '').trim().isNotEmpty) 'Out: ${a.checkOutReason!.trim()}',
        ];
        final note = reasonParts.isEmpty ? '-' : reasonParts.join(' | ');

        return pw.TableRow(
          children: [
            plainCell(date),
            timeCell(ci, a.isLate),
            timeCell(co, a.isEarly),
            plainCell(status),
            plainCell(note),
          ],
        );
      }).toList();

      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: pdf.PdfPageFormat.a4.landscape,
          orientation: pw.PageOrientation.landscape,
          build: (ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Laporan Kehadiran', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(widget.employeeName ?? 'Karyawan', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Periode: $monthLabel $selectedYear', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Dibuat: ${DateFormat('d MMM y HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder.symmetric(inside: pw.BorderSide.none, outside: pw.BorderSide.none),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1.3),
                    1: const pw.FlexColumnWidth(1.0),
                    2: const pw.FlexColumnWidth(1.0),
                    3: const pw.FlexColumnWidth(1.3),
                    4: const pw.FlexColumnWidth(2.0),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: pdf.PdfColor.fromInt(0xFFE5E7EB)),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: pw.Text('Tanggal', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: pw.Text('Check-in', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: pw.Text('Check-out', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: pw.Text('Status', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: pw.Text('Keterangan', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...rows,
                  ],
                ),
              ],
            );
          },
        ),
      );

      final bytes = await doc.save();
      final dir = await getTemporaryDirectory();
      final safeName = (widget.employeeName ?? widget.employeeId ?? 'karyawan').replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
      final fileName = 'riwayat_${safeName}_${selectedYear}-${selectedMonth.toString().padLeft(2, '0')}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles([
        XFile(file.path, mimeType: 'application/pdf'),
      ], text: 'Laporan keterlambatan/pulang dini $monthLabel $selectedYear');
    } catch (e) {
      _showSnack('Gagal export: $e');
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
