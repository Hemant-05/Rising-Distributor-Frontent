import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/coupon_service.dart';
import 'package:raising_india/models/model/coupon.dart';

class AdminCreateCouponScreen extends StatefulWidget {
  const AdminCreateCouponScreen({super.key});

  @override
  State<AdminCreateCouponScreen> createState() => _AdminCreateCouponScreenState();
}

class _AdminCreateCouponScreenState extends State<AdminCreateCouponScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _minOrderController = TextEditingController();
  final TextEditingController _maxDiscountController = TextEditingController();

  String _discountType = 'PERCENTAGE'; // Default
  DateTime? _expirationDate;
  bool _isActive = true;
  bool _isSaving = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColour.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _expirationDate = picked);
    }
  }

  Future<void> _saveCoupon() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final coupon = Coupon(
      code: _codeController.text.trim().toUpperCase(),
      discountType: _discountType,
      discountValue: double.parse(_valueController.text.trim()),
      minOrderAmount: _minOrderController.text.isNotEmpty ? double.parse(_minOrderController.text.trim()) : null,
      maxDiscountAmount: _maxDiscountController.text.isNotEmpty ? double.parse(_maxDiscountController.text.trim()) : null,
      expirationDate: _expirationDate,
      isActive: _isActive,
    );

    final error = await context.read<CouponService>().createCoupon(coupon);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coupon Created!'), backgroundColor: Colors.green));
      Navigator.pop(context); // Go back to the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppColour.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        elevation: 0,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Create Coupon', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- COUPON CODE ---
              _buildLabel('Coupon Code *'),
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: _inputDecoration('e.g. SUMMER50'),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a code' : null,
              ),
              const SizedBox(height: 20),

              // --- DISCOUNT TYPE & VALUE ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Discount Type'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _discountType,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'PERCENTAGE', child: Text('Percentage (%)')),
                                DropdownMenuItem(value: 'FLAT', child: Text('Flat Amount (₹)')),
                              ],
                              onChanged: (val) => setState(() => _discountType = val!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Value *'),
                        TextFormField(
                          controller: _valueController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('0'),
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- CONSTRAINTS (Min Order & Max Discount) ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Min Order Amount (₹)'),
                        TextFormField(
                          controller: _minOrderController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Optional'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Max Discount (₹)'),
                        TextFormField(
                          controller: _maxDiscountController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Optional'),
                          enabled: _discountType == 'PERCENTAGE', // Only relevant for % discounts
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- EXPIRATION DATE ---
              _buildLabel('Expiration Date'),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _expirationDate == null ? 'Select Expiry Date (Optional)' : DateFormat('dd MMM yyyy').format(_expirationDate!),
                        style: simple_text_style(color: _expirationDate == null ? Colors.grey : AppColour.black),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- STATUS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('Coupon Status (Active)'),
                  Switch(
                    value: _isActive,
                    activeThumbColor: AppColour.primary,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: elevated_button_style(),
                  onPressed: _isSaving ? null : _saveCoupon,
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('SAVE COUPON', style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helpers for cleaner code
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: simple_text_style(fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: simple_text_style(color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColour.primary)),
    );
  }
}