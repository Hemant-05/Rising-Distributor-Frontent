import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/address_service.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/features/services/location_service.dart';
import 'package:raising_india/features/user/address/screens/map_screen.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key, required this.isFromProfile});
  final bool isFromProfile;

  @override
  _SelectAddressScreenState createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  bool isLoading = false;
  String? address;
  LatLng? latLng;

  @override
  void initState() {
    super.initState();
    // Fetch addresses when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressService>().fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Addresses', style: simple_text_style(fontSize: 20)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () async {
                  // 1. Get User from AuthService (Provider)
                  final authService = context.read<AuthService>();
                  final user = authService.customer;
                  final addressService = context.read<AddressService>();

                  if (user == null) return;

                  bool isPermission = await LocationService.checkPermissions();

                  // Check limit (Max 5 addresses)
                  if (isPermission && addressService.addresses.length < 5) {
                    bool? refresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(userId: user.uid ?? ''),
                      ),
                    );

                    if (refresh == true) {
                      if (mounted)
                        context.read<AddressService>().fetchAddresses();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColour.primary,
                        content: Text(
                          'Maximum 5 Addresses allowed.\nDelete one to add new.',
                          style: simple_text_style(color: AppColour.white),
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  'ADD LOCATION',
                  style: simple_text_style(
                    color: AppColour.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // 2. Consume AddressService
      body: Consumer<AddressService>(
        builder: (context, addressService, child) {
          if (addressService.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColour.primary),
            );
          }

          if (addressService.addresses.isEmpty) {
            return Center(
              child: Text(
                'No Location Added',
                style: simple_text_style(fontWeight: FontWeight.bold),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: addressService.addresses.length,
                    itemBuilder: (context, index) {
                      final model = addressService.addresses[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColour.lightGrey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.pop(context, {'address': model});
                          },
                          trailing: widget.isFromProfile
                              ? IconButton(
                                  onPressed: () async {
                                    // Delete Logic
                                    await addressService.deleteAddress(
                                      model.id!,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.delete_outlined,
                                    color: AppColour.primary,
                                  ),
                                )
                              : model.isPrimary! == true
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColour.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Primary",
                                    style: simple_text_style(
                                      color: AppColour.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : SizedBox(width: 2),
                          title: Text(
                            model.title ?? "Address",
                            style: simple_text_style(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            model.streetAddress ?? "",
                            style: const TextStyle(fontFamily: 'Sen'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
