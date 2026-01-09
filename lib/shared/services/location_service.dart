import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/utils/app_logger.dart';

class LocationService {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission status
  static Future<PermissionStatus> checkPermission() async {
    return await Permission.location.status;
  }

  // Request location permission
  static Future<PermissionStatus> requestPermission() async {
    final status = await Permission.location.request();
    AppLogger.i('Location permission status: $status');
    return status;
  }

  // Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.w('Location services are disabled');
        throw Exception('Location services are disabled');
      }

      // Check permission
      var permission = await checkPermission();
      
      if (permission.isDenied) {
        permission = await requestPermission();
      }

      if (permission.isDenied) {
        AppLogger.w('Location permission denied');
        throw Exception('Location permission denied');
      }

      if (permission.isPermanentlyDenied) {
        AppLogger.w('Location permission permanently denied');
        throw Exception(
          'Location permission permanently denied. Please enable it in settings.',
        );
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      AppLogger.i('Current position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      AppLogger.e('Error getting current position', e);
      return null;
    }
  }

  // Get current position stream (for real-time tracking)
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  // Open location settings
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
