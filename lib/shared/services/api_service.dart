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

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add token to header if available
          final token = StorageService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          AppLogger.d('REQUEST[${options.method}] => ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.i('RESPONSE[${response.statusCode}] => ${response.data}');
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

  Dio get dio => _dio;

  // Auth methods
  Future<Response> login(String email, String password) async {
    return await _dio.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Response> logout() async {
    return await _dio.post(ApiConstants.logout);
  }

  // Location methods
  Future<Response> validateLocation(double latitude, double longitude) async {
    return await _dio.get(
      ApiConstants.validateLocation,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
      },
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

    AppLogger.i('FormData fields: ${formData.fields.map((e) => '${e.key}=${e.value}').join(', ')}');
    AppLogger.i('FormData files: ${formData.files.map((e) => '${e.key}: ${e.value.filename} (${e.value.length} bytes)').join(', ')}');

    return await _dio.post(
      ApiConstants.checkIn,
      data: formData,
    );
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
      'photo': MultipartFile.fromBytes(
        bytes,
        filename: 'photo.jpg',
      ),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });

    return await _dio.post(
      ApiConstants.checkOut,
      data: formData,
    );
  }

  Future<Response> getHistory({int limit = 30, int offset = 0}) async {
    return await _dio.get(
      ApiConstants.attendanceHistory,
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );
  }

  Future<Response> getAttendanceDetail(String id) async {
    return await _dio.get('${ApiConstants.attendanceDetail}/$id');
  }

  // User methods (Admin)
  Future<Response> getAllUsers({String? role}) async {
    return await _dio.get(
      ApiConstants.users,
      queryParameters: role != null ? {'role': role} : null,
    );
  }
}
