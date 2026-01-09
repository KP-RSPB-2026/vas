import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/user_model.dart';
import '../services/storage_service.dart';

// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null) {
    _loadUser();
  }

  void _loadUser() {
    final userData = StorageService.getUserData();
    if (userData['id'] != null) {
      state = User(
        id: userData['id']!,
        email: userData['email']!,
        name: userData['name']!,
        role: userData['role']!,
      );
    }
  }

  void setUser(User user) {
    state = user;
    StorageService.saveUserData(
      userId: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
    );
  }

  void logout() {
    state = null;
    StorageService.clearAll();
  }

  bool get isLoggedIn => state != null;
}
