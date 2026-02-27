import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/address_service.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/features/services/location_service.dart';
import 'package:raising_india/features/user/address/screens/fill_address_details_screen.dart';
import 'package:raising_india/features/user/address/screens/map_screen.dart';
import 'package:raising_india/features/user/address/screens/update_address_screen.dart';
import 'package:raising_india/models/model/address.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key, required this.isFromProfile});
  final bool isFromProfile;

  @override
  _SelectAddressScreenState createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressService>().fetchAddresses();
    });
  }

  // Helper to format the full address cleanly
  String _formatFullAddress(Address address) {
    List<String> parts = [
      address.streetAddress ?? '',
      address.city ?? '',
      address.state ?? '',
      address.zipCode ?? '',
    ];
    parts.removeWhere((part) => part.trim().isEmpty);
    return parts.join(', ');
  }

  // Helper to choose an icon based on the title (Home, Work, etc.)
  IconData _getAddressIcon(String? title) {
    final lowerTitle = (title ?? '').toLowerCase();
    if (lowerTitle.contains('home')) return Icons.home_rounded;
    if (lowerTitle.contains('work') || lowerTitle.contains('office')) return Icons.work_rounded;
    return Icons.location_on_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Softer background to make cards pop
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        elevation: 0,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Saved Addresses', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: () async {
                final authService = context.read<AuthService>();
                final user = authService.customer;
                final addressService = context.read<AddressService>();

                if (user == null) return;
                bool isPermission = await LocationService.checkPermissions();

                if (isPermission) {
                  if (addressService.addresses.length < 5) {

                    // 1. Open the Map and wait for the result
                    final mapResult = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(userId: user.uid ?? ''),
                      ),
                    );

                    // 2. If the user confirmed a location on the map, go to Details Screen
                    if (mapResult != null && mapResult is Map<String, dynamic>) {
                      bool? refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FillAddressDetailsScreen(data: mapResult),
                        ),
                      );

                      if (refresh == true && mounted) {
                        context.read<AddressService>().fetchAddresses();
                      }
                    }

                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColour.primary,
                        content: Text('Maximum 5 Addresses allowed.\nDelete one to add new.', style: simple_text_style(color: AppColour.white)),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColour.primary,
                      content: Text('Location services must be enabled to add an address.', style: simple_text_style(color: AppColour.white)),
                    ),
                  );
                }
              },
              icon: Icon(Icons.add_location_alt_rounded, color: AppColour.primary, size: 18),
              label: Text(
                'ADD NEW',
                style: simple_text_style(
                  color: AppColour.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Consumer<AddressService>(
        builder: (context, addressService, child) {
          if (addressService.isLoading) {
            return Center(child: CircularProgressIndicator(color: AppColour.primary));
          }

          if (addressService.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No Addresses Found', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Add a delivery location to continue', style: simple_text_style(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addressService.addresses.length,
            itemBuilder: (context, index) {
              final model = addressService.addresses[index];
              final isPrimary = model.primary ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isPrimary ? AppColour.primary.withOpacity(0.03) : AppColour.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPrimary ? AppColour.primary : Colors.grey.shade300,
                    width: isPrimary ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Return selected address for checkout
                      Navigator.pop(context, {'address': model});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- HEADER: Icon, Title, and Primary Badge ---
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColour.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_getAddressIcon(model.title), color: AppColour.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  model.title ?? "Address",
                                  style: simple_text_style(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (isPrimary)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColour.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Primary",
                                    style: simple_text_style(color: AppColour.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // --- BODY: Name, Phone, and Full Address ---
                          Text(
                            "${model.recipientName ?? 'No Name'}  •  ${model.phoneNumber ?? ''}",
                            style: simple_text_style(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatFullAddress(model),
                            style: simple_text_style(fontSize: 13, color: Colors.grey.shade700, isEllipsisAble: false),
                          ),

                          // --- DIVIDER ---
                          if (widget.isFromProfile) ...[
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey.shade200, thickness: 1),

                            // --- ACTION BAR: Set Primary, Edit, Delete ---
                            Row(
                              children: [
                                // Set Primary Button
                                if (!isPrimary)
                                  Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () => addressService.setPrimary(model.id!),
                                    icon: Icon(Icons.star_border_rounded, size: 18, color: Colors.grey.shade600),
                                    label:  Text("Set as Primary", style: simple_text_style(color: Colors.grey.shade600, fontSize: 13))),)
                                else
                                  const Spacer(), // Push other buttons to the right if already primary

                                if (!isPrimary) const Spacer(),
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UpdateAddressScreen(address: model),
                                      ),
                                    );
                                  },
                                ),

                                // Delete Button
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                                  onPressed: () => addressService.deleteAddress(model.id!),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}