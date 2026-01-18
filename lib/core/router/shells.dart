import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserShell extends StatelessWidget {
  final Widget child;
  const UserShell({super.key, required this.child});

  int _indexForLocation(String location) {
    if (location.startsWith('/home/presensi')) return 1;
    if (location.startsWith('/home/settings')) return 2;
    return 0; // default to riwayat
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/home/riwayat');
              break;
            case 1:
              context.go('/home/presensi');
              break;
            case 2:
              context.go('/home/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.fingerprint), label: 'Presensi'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  int _indexForLocation(String location) {
    if (location.startsWith('/admin/settings')) return 1;
    return 0; // default to riwayat
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/admin/riwayat');
              break;
            case 1:
              context.go('/admin/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
