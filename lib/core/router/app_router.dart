import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/attendance/presentation/screens/presensi_screen.dart';
import '../../features/attendance/presentation/screens/riwayat_screen.dart';
import '../../features/attendance/presentation/screens/settings_screen.dart';
import '../../features/admin/presentation/screens/employee_list_screen.dart';
import '../../features/admin/presentation/screens/employee_history_screen.dart';
import '../../shared/providers/auth_provider.dart';
import 'shells.dart';
import '../../features/auth/presentation/screens/forbidden_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  final role = authState?.role;
  final isAdmin = role == 'admin';

  return GoRouter(
    initialLocation: authState != null
        ? (isAdmin ? '/admin/riwayat' : '/home/presensi')
        : '/login',
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isLoginRoute = state.matchedLocation == '/login';
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isUserRoute = state.matchedLocation.startsWith('/home');

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      if (isLoggedIn && isLoginRoute) {
        return isAdmin ? '/admin/riwayat' : '/home/presensi';
      }

      if (!isAdmin && isAdminRoute) {
        return '/forbidden';
      }

      if (isAdmin && isUserRoute) {
        return '/admin/riwayat';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forbidden',
        builder: (context, state) => const ForbiddenScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => UserShell(child: child),
        routes: [
          GoRoute(
            path: '/home/riwayat',
            builder: (context, state) => const AttendanceHistoryPage(),
          ),
          GoRoute(
            path: '/home/presensi',
            builder: (context, state) => const PresensiScreen(),
          ),
          GoRoute(
            path: '/home/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/riwayat',
            builder: (context, state) => const EmployeeListScreen(),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/admin/employee/:id',
            builder: (context, state) => EmployeeHistoryScreen(
              employeeId: state.pathParameters['id']!,
              employeeName: (state.extra is Map<String, dynamic>)
                  ? (state.extra as Map<String, dynamic>)['name'] as String?
                  : null,
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
