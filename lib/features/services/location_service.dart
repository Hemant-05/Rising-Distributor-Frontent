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
        String name = placemark.name ?? "";
        String street = placemark.street ?? "";
        String thoroughfare = placemark.thoroughfare ?? "";
        String subLocality = placemark.subLocality ?? "";
        String locality = placemark.locality ?? "";
        String state = placemark.administrativeArea ?? "";
        String postalCode = placemark.postalCode ?? "";

        // Combine parts and avoid duplicates
        List<String> parts = [name, street, thoroughfare, subLocality, locality, state, postalCode];
        List<String> uniqueParts = [];
        for (var part in parts) {
          if (part.isNotEmpty && !uniqueParts.contains(part)) {
            uniqueParts.add(part);
          }
        }
        return uniqueParts.join(", ");
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
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      print("Error getting location: $e");
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }
}