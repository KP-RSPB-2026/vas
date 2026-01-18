import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/attendance_model.dart';
import '../../../shared/services/api_service.dart';

class AttendanceHistoryEntry {
  final List<Attendance> items;
  final bool hasMore;
  final int page;
  final int? total;
  final DateTime fetchedAt;

  AttendanceHistoryEntry({
    required this.items,
    required this.hasMore,
    required this.page,
    required this.total,
    required this.fetchedAt,
  });

  AttendanceHistoryEntry copyWith({
    List<Attendance>? items,
    bool? hasMore,
    int? page,
    int? total,
    DateTime? fetchedAt,
  }) {
    return AttendanceHistoryEntry(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      total: total ?? this.total,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}

final attendanceHistoryCacheProvider = StateNotifierProvider<AttendanceHistoryCache, Map<String, AttendanceHistoryEntry>>(
  (ref) => AttendanceHistoryCache(),
);

class AttendanceHistoryCache extends StateNotifier<Map<String, AttendanceHistoryEntry>> {
  AttendanceHistoryCache() : super({});
  static const _ttl = Duration(seconds: 15);

  String _key({String? employeeId, required int month, required int year}) {
    return '${employeeId ?? 'me'}-$month-$year';
  }

  Future<AttendanceHistoryEntry> fetch({
    required int month,
    required int year,
    required int page,
    int limit = 31,
    bool includePhotos = false,
    String? employeeId,
    bool force = false,
  }) async {
    final key = _key(employeeId: employeeId, month: month, year: year);
    final now = DateTime.now();
    final cached = state[key];

    final useCache = page == 1 && !force && cached != null && now.difference(cached.fetchedAt) < _ttl;
    if (useCache) return cached;

    final res = await ApiService().getHistory(
      month: month,
      year: year,
      page: page,
      limit: limit,
      includePhotos: includePhotos,
      userId: employeeId,
    );

    if (res.statusCode != 200 || res.data['success'] != true) {
      throw Exception(res.data['error'] ?? 'Gagal memuat riwayat');
    }

    final List data = res.data['data'] as List;
    final parsed = data.map((e) => Attendance.fromJson(e as Map<String, dynamic>)).toList();
    final meta = res.data['meta'] as Map<String, dynamic>?;
    final hasMore = meta?['hasMore'] == true;
    final totalVal = meta?['total'];
    final total = totalVal is int ? totalVal : null;

    if (page > 1 && cached != null) {
      final merged = [...cached.items, ...parsed];
      final entry = cached.copyWith(
        items: merged,
        hasMore: hasMore,
        page: page,
        total: total ?? cached.total,
        fetchedAt: now,
      );
      state = {...state, key: entry};
      return entry;
    }

    final entry = AttendanceHistoryEntry(
      items: parsed,
      hasMore: hasMore,
      page: page,
      total: total,
      fetchedAt: now,
    );
    state = {...state, key: entry};
    return entry;
  }
}
