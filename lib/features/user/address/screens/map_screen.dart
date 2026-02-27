import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/services/location_service.dart';
import 'package:raising_india/features/user/address/screens/fill_address_details_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.userId});
  final String userId;
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLatLng;
  String _selectedAddress = "Fetching address...";

  bool _isLoading = true;
  bool _isFetchingLocation = false; // Used for the FAB loading spinner

  @override
  void initState() {
    super.initState();
    _getInitialLocation();
  }

  Future<void> _getInitialLocation() async {
    final position = await LocationService.getCurrentPosition();
    if (position != null && mounted) {
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _mapController.move(_currentLatLng!, 16.0);
      _updateAddress(_currentLatLng!);
    } else {
      setState(() => _isLoading = false);
    }
  }

  // ✅ New Method: Triggered by the Current Location Button
  Future<void> _goToCurrentLocation() async {
    setState(() => _isFetchingLocation = true);

    final position = await LocationService.getCurrentPosition();
    if (position != null && mounted) {
      final newLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLatLng = newLatLng;
      });

      // Animate/Move the map back to the user's location
      _mapController.move(newLatLng, 16.0);
      await _updateAddress(newLatLng);
    }

    if (mounted) {
      setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _updateAddress(LatLng latLng) async {
    String address = await LocationService.getReadableAddress(latLng);
    if (mounted) {
      setState(() {
        _selectedAddress = address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Select Location', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: _isLoading || _currentLatLng == null
          ? Center(child: CircularProgressIndicator(color: AppColour.primary))
          : Stack(
        children: [
          // 1. The Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLatLng!,
              initialZoom: 16.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && position.center != null) {
                  _currentLatLng = position.center!;
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _updateAddress(_currentLatLng!);
                }
              },
            ),
            children: [
              TileLayer(
                // ✅ UPGRADE 1: CartoDB Voyager Map (Beautiful, detailed, free)
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'], // Helps load tiles faster
                userAgentPackageName: 'com.rising.raising_india',
                // ✅ UPGRADE 2: retinaMode makes texts and roads incredibly sharp on mobile!
                retinaMode: true,
              ),
            ],
          ),

          // 2. The Center Pin Layer
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Icon(Icons.location_on, size: 50, color: Colors.red),
            ),
          ),

          // 3. ✅ Current Location Button
          Positioned(
            bottom: 230, // Placed right above the bottom sheet
            right: 20,
            child: FloatingActionButton(
              heroTag: "current_location_btn",
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: _isFetchingLocation ? null : _goToCurrentLocation,
              child: _isFetchingLocation
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: AppColour.primary, strokeWidth: 2.5),
              )
                  : Icon(Icons.my_location, color: AppColour.primary),
            ),
          ),

          // 4. The Bottom UI Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColour.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Delivery Address", style: simple_text_style(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    _selectedAddress,
                    style: simple_text_style(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: elevated_button_style(),
                      onPressed: () async {
                        if (_currentLatLng != null) {
                          Map<String, dynamic> addressData = {
                            'address': _selectedAddress,
                            'userId': widget.userId,
                            'latitude': _currentLatLng!.latitude,
                            'longitude': _currentLatLng!.longitude,
                          };

                          List<Placemark> placemarks = await placemarkFromCoordinates(
                            _currentLatLng!.latitude,
                            _currentLatLng!.longitude,
                          );

                          if (placemarks.isNotEmpty) {
                            final placemark = placemarks.first;
                            addressData['street'] = placemark.street ?? "";
                            addressData['city'] = placemark.locality ?? placemark.subLocality ?? "";
                            addressData['state'] = placemark.administrativeArea ?? "";
                            addressData['zipCode'] = placemark.postalCode ?? "";
                            addressData['country'] = placemark.country ?? "";
                          }
                          Navigator.pop(context, addressData);
                        }
                      },
                      child: Text(
                        'CONFIRM LOCATION',
                        style: simple_text_style(
                          color: AppColour.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}