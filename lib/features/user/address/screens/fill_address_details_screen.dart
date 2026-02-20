import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/address_service.dart';
import 'package:raising_india/models/model/address.dart';

import '../../../../comman/back_button.dart';
import '../../../../comman/elevated_button_style.dart';
import '../../../../comman/simple_text_style.dart';

class FillAddressDetailsScreen extends StatefulWidget {
  FillAddressDetailsScreen({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  State<FillAddressDetailsScreen> createState() => _FillAddressDetailsScreenState();
}

class _FillAddressDetailsScreenState extends State<FillAddressDetailsScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController recipientNameController = TextEditingController();
  final TextEditingController recipientPhoneController = TextEditingController();

  bool _isLoading = false;

  void _onAddAddress() async {
    String title = titleController.text.trim();
    String recipientName = recipientNameController.text.trim();
    String recipientPhone = recipientPhoneController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColour.primary,
          content: Text(
            'Title is required...',
            style: simple_text_style(color: AppColour.white),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Create Address Model Object
    // Assuming your AddressModel has a constructor or factory like this:
    final newAddress = Address(
      title: title,
      latitude: widget.data['latitude'],
      longitude: widget.data['longitude'],
      recipientName: recipientName,
      phoneNumber: recipientPhone,
      streetAddress: widget.data['street'],
      city: widget.data['city'],
      state: widget.data['state'],
      zipCode: widget.data['zipCode'],
    );

    // Call Service
    final error = await context.read<AddressService>().addAddress(newAddress);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error == null) {
      // Success
      Navigator.pop(context, true);
    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColour.red,
          content: Text(error, style: simple_text_style(color: AppColour.white)),
        ),
      );
    }
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
            Text('Address Details', style: simple_text_style(fontSize: 18)),
            const Spacer(),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(titleController, 'Home, Work etc..'),
              const SizedBox(height: 10),
              _buildTextField(recipientNameController, 'Name'),
              const SizedBox(height: 10),
              _buildTextField(recipientPhoneController, 'Number'),
              const SizedBox(height: 10),

              ElevatedButton(
                style: elevated_button_style(width: 200),
                onPressed: _isLoading ? null : _onAddAddress,
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: AppColour.white,
                    constraints: const BoxConstraints(maxWidth: 30, maxHeight: 30),
                  ),
                )
                    : Text(
                  "ADD ADDRESS",
                  style: simple_text_style(
                    color: AppColour.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppColour.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColour.primary, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: simple_text_style(color: AppColour.lightGrey),
        ),
      ),
    );
  }
}