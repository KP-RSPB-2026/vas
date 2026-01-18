import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/auth_provider.dart';
import '../../features/auth/data/user_model.dart';

class AuthListener extends ConsumerWidget {
  final Widget child;
  const AuthListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<User?>(authProvider, (prev, next) {
      if (prev != next && next == null) {
        // User logged out or token cleared => send to login
        if (context.mounted) {
          context.go('/login');
        }
      }
    });
    return child;
  }
}
