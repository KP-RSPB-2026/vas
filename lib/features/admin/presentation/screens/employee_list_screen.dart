import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/api_service.dart';
import '../../../auth/data/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmployeeListScreen extends ConsumerStatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  ConsumerState<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends ConsumerState<EmployeeListScreen> {
  bool _loading = false;
  String? _error;
  List<User> _users = [];
  String _search = '';
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;
  Timer? _searchDebounce;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _fetch({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
        _hasMore = true;
        _users = [];
      });
    } else {
      setState(() {
        _loadingMore = true;
        _error = null;
      });
    }

    final nextPage = reset ? 1 : _page + 1;

    try {
      final res = await ApiService().getAllUsers(
        role: 'user',
        search: _search,
        page: nextPage,
        limit: _pageSize,
      );
      if (res.statusCode == 200 && res.data['success'] == true) {
        final List data = res.data['data'] as List;
        final meta = res.data['meta'] as Map<String, dynamic>?;
        final fetched = data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
        final hasMore = meta?['hasMore'] == true;
        setState(() {
          _users = reset ? fetched : [..._users, ...fetched];
          _page = nextPage;
          _hasMore = hasMore;
        });
      } else {
        setState(() => _error = 'Gagal memuat karyawan');
      }
    } catch (e) {
      setState(() => _error = 'Terjadi kesalahan: $e');
    } finally {
      if (!mounted) return;
      if (reset) {
        setState(() => _loading = false);
      } else {
        setState(() => _loadingMore = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _search = value);
      _fetch(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
      body: RefreshIndicator(
        onRefresh: () => _fetch(reset: true),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Cari karyawan',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                ),
                  onChanged: _onSearchChanged,
              ),
            ),
              if (_loading)
                Expanded(
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemBuilder: (_, __) => _ShimmerTile(),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: 3,
                  ),
                )
              else if (_error != null)
                Expanded(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _fetch(reset: true),
                              child: const Text('Coba lagi'),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _users.length + (_hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (_hasMore && index == _users.length) {
                        return TextButton(
                          onPressed: _loadingMore ? null : () => _fetch(reset: false),
                          child: _loadingMore
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Muat lebih banyak'),
                        );
                      }
                      final user = _users[index];
                      return InkWell(
                        onTap: () => context.push('/admin/employee/${user.id}', extra: {'name': user.name}),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(8),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary.withAlpha((0.12 * 255).round()),
                                child: Text('${index + 1}', style: const TextStyle(color: AppColors.primary)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  user.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.black45),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

  class _ShimmerTile extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(40),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
