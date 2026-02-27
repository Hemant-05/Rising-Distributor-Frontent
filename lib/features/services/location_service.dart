import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart'; // ✅ Swapped to latlong2

class LocationService {

  static Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  static Future<String> getReadableAddress(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        String street = placemark.street ?? "";
        String city = placemark.locality ?? placemark.subLocality ?? "";
        String state = placemark.administrativeArea ?? "";
        String postalCode = placemark.postalCode ?? "";

        // ✅ Smarter formatting: Only joins non-empty parts
        List<String> parts = [street, city, state, postalCode];
        parts.removeWhere((element) => element.isEmpty);
        return parts.join(", ");
      } else {
        return "Location not found";
      }
    } catch (e) {
      print("Error getting address: $e");
      return "Unable to fetch address";
    }
  }

  static Future<Position?> getCurrentPosition() async {
    if (!await checkPermissions()) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }
}