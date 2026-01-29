import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/app_logger.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  Future<bool>? _refreshingFuture;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
        // Anggap status <500 sebagai respons biasa supaya 401/403 dsb bisa diproses manual
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add token to header if available
          final token = StorageService.getAccessToken();
          final isAuthPath =
              options.path.startsWith(ApiConstants.login) ||
              options.path.startsWith(ApiConstants.logout);

          // Jangan kirim Authorization untuk login/logout supaya tidak mengganggu autentikasi
          if (!isAuthPath && token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          AppLogger.d('REQUEST[${options.method}] => ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          AppLogger.i('RESPONSE[${response.statusCode}] => ${response.data}');

          if (response.statusCode == 401) {
            final options = response.requestOptions;
            final isAuthPath = _isAuthPath(options.path);
            final alreadyRetried = options.extra['retried'] == true;

            if (!isAuthPath && !alreadyRetried) {
              final refreshed = await _refreshToken();
              if (refreshed) {
                options.headers['Authorization'] = 'Bearer ${StorageService.getAccessToken()}';
                options.extra['retried'] = true;
                final clone = await _dio.fetch(options);
                return handler.resolve(clone);
              }
            }

            _handleUnauthorized();
          }

          return handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.e(
            'ERROR[${error.response?.statusCode}] => ${error.message}',
            error,
          );
          if (error.response?.data != null) {
            AppLogger.e('Response body: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  void _handleUnauthorized() {
    try {
      // Clear stored tokens/user and rely on listeners to redirect.
      StorageService.clearAll();
    } catch (_) {
      // best-effort
    }
  }

  bool _isAuthPath(String path) {
    return path.startsWith(ApiConstants.login) ||
        path.startsWith(ApiConstants.logout) ||
        path.startsWith(ApiConstants.refresh);
  }

  Future<bool> _refreshToken() {
    if (_refreshingFuture != null) {
      return _refreshingFuture!;
    }

    final refreshToken = StorageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      _refreshingFuture = Future.value(false);
      return _refreshingFuture!;
    }

    _refreshingFuture = () async {
      try {
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {'Content-Type': 'application/json'},
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        final res = await refreshDio.post(
          ApiConstants.refresh,
          data: {'refresh_token': refreshToken},
        );

        if (res.statusCode == 200 && res.data['success'] == true) {
          final session = res.data['data']['session'];
          final newAccess = session['access_token'];
          final newRefresh = session['refresh_token'];

          await StorageService.saveToken(newAccess, newRefresh);
          _dio.options.headers['Authorization'] = 'Bearer $newAccess';
          return true;
        }
      } catch (e) {
        AppLogger.e('Failed to refresh token', e);
      } finally {
        _refreshingFuture = null;
      }

      await StorageService.clearAll();
      return false;
    }();

    return _refreshingFuture!;
  }

  Dio get dio => _dio;

  // Auth methods
  Future<Response> login({required String nomorKaryawan, required String password}) async {
    return await _dio.post(
      ApiConstants.login,
      data: {'nomor_karyawan': nomorKaryawan, 'password': password},
    );
  }

  Future<Response> logout() async {
    return await _dio.post(ApiConstants.logout);
  }

  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _dio.post(
      ApiConstants.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  // Office location (Admin)
  Future<Response> getOfficeLocation() async {
    return await _dio.get('/office/location');
  }

  // Location methods
  Future<Response> validateLocation(double latitude, double longitude) async {
    return await _dio.get(
      ApiConstants.validateLocation,
      queryParameters: {'latitude': latitude, 'longitude': longitude},
    );
  }

  // Attendance methods
  Future<Response> checkIn({
    required String photoPath,
    required double latitude,
    required double longitude,
    String? reason,
  }) async {
    // Read file as bytes to ensure it's readable
    final file = File(photoPath);
    final bytes = await file.readAsBytes();

    AppLogger.i('CheckIn API call:');
    AppLogger.i('- Photo path: $photoPath');
    AppLogger.i('- File exists: ${file.existsSync()}');
    AppLogger.i('- Bytes length: ${bytes.length}');
    AppLogger.i('- Latitude: $latitude');
    AppLogger.i('- Longitude: $longitude');
    AppLogger.i('- Reason: $reason');

    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(
        bytes,
        filename: 'photo.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });

    AppLogger.i(
      'FormData fields: ${formData.fields.map((e) => '${e.key}=${e.value}').join(', ')}',
    );
    AppLogger.i(
      'FormData files: ${formData.files.map((e) => '${e.key}: ${e.value.filename} (${e.value.length} bytes)').join(', ')}',
    );

    return await _dio.post(ApiConstants.checkIn, data: formData);
  }

  Future<Response> checkOut({
    required String photoPath,
    required double latitude,
    required double longitude,
    String? reason,
  }) async {
    // Read file as bytes to ensure it's readable
    final file = File(photoPath);
    final bytes = await file.readAsBytes();

    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(bytes, filename: 'photo.jpg'),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });

    return await _dio.post(ApiConstants.checkOut, data: formData);
  }

  Future<Response> getHistory({
    int? month,
    int? year,
    int? page,
    int limit = 31,
    int? offset,
    bool includePhotos = true,
    String? userId,
  }) async {
    final params = <String, dynamic>{
      'limit': limit,
      if (offset != null) 'offset': offset,
      if (page != null) 'page': page,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      'include_photos': includePhotos,
      if (userId != null) 'user_id': userId,
    };
    return await _dio.get(
      ApiConstants.attendanceHistory,
      queryParameters: params,
    );
  }

  Future<Response> getAttendanceDetail(String id) async {
    return await _dio.get('${ApiConstants.attendanceDetail}/$id');
  }

  // User methods (Admin)
  Future<Response> getAllUsers({String? role, String? search, int page = 1, int limit = 20}) async {
    return await _dio.get(
      ApiConstants.users,
      queryParameters: {
        if (role != null) 'role': role,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'limit': limit,
      },
    );
  }
}
