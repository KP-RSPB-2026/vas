class User {
  final String id;
  final String nomorKaryawan;
  final String name;
  final String role;

  User({
    required this.id,
    required this.nomorKaryawan,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String toString(dynamic v) => v == null ? '' : v.toString();
    return User(
      id: toString(json['id']),
      nomorKaryawan: toString(json['nomor_karyawan']),
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_karyawan': nomorKaryawan,
      'name': name,
      'role': role,
    };
  }

  bool get isAdmin => role == 'admin';
}

class LoginResponse {
  final User user;
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return LoginResponse(
      user: User.fromJson(data['user']),
      accessToken: data['session']['access_token'],
      refreshToken: data['session']['refresh_token'],
    );
  }
}
