import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/utils/app_logger.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  // Check camera permission
  static Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  // Request camera permission
  static Future<PermissionStatus> requestCameraPermission() async {
    final status = await Permission.camera.request();
    AppLogger.i('Camera permission status: $status');
    return status;
  }

  // Take photo with front camera (for selfie)
  static Future<File?> takeSelfie() async {
    try {
      // Check permission
      var permission = await checkCameraPermission();
      
      if (permission.isDenied) {
        permission = await requestCameraPermission();
      }

      if (permission.isDenied) {
        AppLogger.w('Camera permission denied');
        throw Exception('Camera permission denied');
      }

      if (permission.isPermanentlyDenied) {
        AppLogger.w('Camera permission permanently denied');
        throw Exception(
          'Camera permission permanently denied. Please enable it in settings.',
        );
      }

      // Take photo with front camera
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo == null) {
        AppLogger.i('No photo taken');
        return null;
      }

      final file = File(photo.path);
      AppLogger.i('Photo taken: ${file.path}');
      return file;
    } catch (e) {
      AppLogger.e('Error taking selfie', e);
      return null;
    }
  }

  // Pick image from gallery (alternative)
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo == null) {
        AppLogger.i('No image selected');
        return null;
      }

      final file = File(photo.path);
      AppLogger.i('Image selected: ${file.path}');
      return file;
    } catch (e) {
      AppLogger.e('Error picking image', e);
      return null;
    }
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
