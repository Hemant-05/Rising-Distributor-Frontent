import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
  late GoogleMapController _mapController;
  LatLng? _currentLatLng;
  String _selectedAddress = "Fetching address...";
  Map<String,dynamic> address_data = {};

  @override
  void initState() {
    super.initState();
    _getInitialLocation();
  }

  Future<void> _getInitialLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentLatLng = LatLng(position.latitude, position.longitude);
    _selectedAddress = await LocationService.getReadableAddress(
      _currentLatLng!,
    );
    setState(() {});
  }

  void _onMapTap(LatLng latLng) async {
    _currentLatLng = latLng;
    _selectedAddress = await LocationService.getReadableAddress(
      _currentLatLng!,
    );
    setState(() {});
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
            Text('Map', style: simple_text_style(fontSize: 18)),
            const Spacer(),
          ],
        ),
      ),
      body: _currentLatLng == null
          ? Center(child: CircularProgressIndicator(color: AppColour.primary))
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng!,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: _onMapTap,
                  zoomControlsEnabled: false,
                  markers: {
                    Marker(
                      markerId: MarkerId('selected'),
                      position: _currentLatLng!,
                      draggable: true,
                      onDragEnd: _onMapTap,
                    ),
                  },
                ),
                Positioned(
                  bottom: 90,
                  left: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColour.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColour.primary, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12),
                    child: Text(_selectedAddress, style: simple_text_style()),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () async {
                      if(_currentLatLng != null) {
                        address_data['address'] = _selectedAddress;
                        List<Placemark> placemarks = await placemarkFromCoordinates(
                          _currentLatLng!.latitude,
                          _currentLatLng!.longitude,
                        );
                        if(placemarks.isNotEmpty) {
                          final placemark = placemarks.first;
                          address_data['street'] = placemark.street ?? "";
                          address_data['city'] = placemark.locality ?? "";
                          address_data['state'] = placemark.administrativeArea ?? "";
                          address_data['zipCode'] = placemark.postalCode ?? "";
                          address_data['country'] = placemark.country ?? "";
                          address_data['userId'] = widget.userId;
                          address_data['latitude'] = _currentLatLng!.latitude;
                          address_data['longitude'] = _currentLatLng!.longitude;
                        }
                      }
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FillAddressDetailsScreen(data: address_data,),));
                    },
                    style: elevated_button_style(width: 200),
                    child: Text(
                      'NEXT',
                      style: simple_text_style(
                        color: AppColour.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
