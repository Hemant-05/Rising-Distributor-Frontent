import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/address_service.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/features/user/address/screens/map_screen.dart';
import 'package:raising_india/models/model/address.dart';

class UpdateAddressScreen extends StatefulWidget {
  final Address address;

  const UpdateAddressScreen({super.key, required this.address});

  @override
  State<UpdateAddressScreen> createState() => _UpdateAddressScreenState();
}

class _UpdateAddressScreenState extends State<UpdateAddressScreen> {
  late TextEditingController titleController;
  late TextEditingController recipientNameController;
  late TextEditingController recipientPhoneController;
  late TextEditingController streetController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController zipController;

  bool _isLoading = false;
  double? _currentLat;
  double? _currentLng;

  @override
  void initState() {
    super.initState();
    // Pre-fill the fields with the existing address data
    titleController = TextEditingController(text: widget.address.title);
    recipientNameController = TextEditingController(text: widget.address.recipientName);
    recipientPhoneController = TextEditingController(text: widget.address.phoneNumber);
    streetController = TextEditingController(text: widget.address.streetAddress);
    cityController = TextEditingController(text: widget.address.city);
    stateController = TextEditingController(text: widget.address.state);
    zipController = TextEditingController(text: widget.address.zipCode);
    _currentLat = widget.address.latitude;
    _currentLng = widget.address.longitude;
  }

  @override
  void dispose() {
    titleController.dispose();
    recipientNameController.dispose();
    recipientPhoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    super.dispose();
  }

  Future<void> _onUpdateAddress() async {
    String title = titleController.text.trim();
    String recipientName = recipientNameController.text.trim();
    String recipientPhone = recipientPhoneController.text.trim();

    if (title.isEmpty || recipientName.isEmpty || recipientPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColour.primary,
          content: Text(
            'Title, Name, and Phone are required.',
            style: simple_text_style(color: AppColour.white),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Create updated Address Object (keeping original ID, coordinates, and primary status)
    final updatedAddress = Address(
      id: widget.address.id,
      userId: widget.address.userId,
      latitude: _currentLat ?? widget.address.latitude,
      longitude: _currentLng ?? widget.address.longitude,
      primary: widget.address.primary,

      // Updated Fields
      title: title,
      recipientName: recipientName,
      phoneNumber: recipientPhone,
      streetAddress: streetController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      zipCode: zipController.text.trim(),
    );

    // Call the service
    final error = await context.read<AddressService>().updateAddress(widget.address.id!, updatedAddress);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error == null) {
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Address updated successfully!'),
        ),
      );
      Navigator.pop(context, true);
    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(error, style: simple_text_style(color: AppColour.white)),
        ),
      );
    }
  }

  Future<void> _onChangeLocationOnMap() async {
    final user = context.read<AuthService>().customer;
    if (user == null) return;

    final mapResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(userId: user.uid ?? ''),
      ),
    );

    if (mapResult != null && mapResult is Map<String, dynamic>) {
      setState(() {
        // Update the hidden coordinates
        _currentLat = mapResult['latitude'];
        _currentLng = mapResult['longitude'];

        // Auto-fill the text fields with the newly selected map data!
        if (mapResult['street']?.isNotEmpty ?? false) streetController.text = mapResult['street'];
        if (mapResult['city']?.isNotEmpty ?? false) cityController.text = mapResult['city'];
        if (mapResult['state']?.isNotEmpty ?? false) stateController.text = mapResult['state'];
        if (mapResult['zipCode']?.isNotEmpty ?? false) zipController.text = mapResult['zipCode'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        elevation: 0,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Update Address', style: simple_text_style(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Contact Information", style: simple_text_style(fontWeight: FontWeight.bold, color: AppColour.primary)),
            const SizedBox(height: 12),
            _buildTextField(titleController, 'Address Title (e.g., Home, Work)'),
            const SizedBox(height: 12),
            _buildTextField(recipientNameController, 'Recipient Name'),
            const SizedBox(height: 12),
            _buildTextField(recipientPhoneController, 'Phone Number', inputType: TextInputType.phone),

            const SizedBox(height: 24),
            Text("Location Details", style: simple_text_style(fontWeight: FontWeight.bold, color: AppColour.primary)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _onChangeLocationOnMap,
                icon: const Icon(Icons.map_outlined),
                label: const Text("Change Location on Map"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColour.primary,
                  side: BorderSide(color: AppColour.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField(streetController, 'Street Address / Building'),
            const SizedBox(height: 12),

            // Put City and Zip in the same row to save space
            Row(
              children: [
                Expanded(child: _buildTextField(cityController, 'City')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(zipController, 'Zip Code', inputType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(stateController, 'State'),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: elevated_button_style(),
                onPressed: _isLoading ? null : _onUpdateAddress,
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
                    : Text(
                  "UPDATE ADDRESS",
                  style: simple_text_style(
                    color: AppColour.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A sleek, reusable text field builder
  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType inputType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColour.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        style: simple_text_style(fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: hint,
          labelStyle: simple_text_style(color: Colors.grey.shade500, fontSize: 13),
        ),
      ),
    );
  }
}