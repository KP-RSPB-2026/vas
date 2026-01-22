import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/api_service.dart';
import 'office_location_model.dart';

final officeLocationProvider = FutureProvider<OfficeLocation?>((ref) async {
  try {
    final res = await ApiService().getOfficeLocation();
    if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
      return OfficeLocation.fromJson(res.data['data'] as Map<String, dynamic>);
    }
  } catch (_) {
    // ignore errors; caller can fall back to defaults
  }
  return null;
});
