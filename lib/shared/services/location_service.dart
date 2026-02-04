import 'package:geolocator/geolocator.dart';
import 'package:travel_app/domain/services/i_location_service.dart';

class LocationService implements ILocationService {
  @override
  Future<({double latitude, double longitude})?> getCurrentPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.medium),
      );
      return (latitude: pos.latitude, longitude: pos.longitude);
    } catch (_) {
      return null;
    }
  }
}
