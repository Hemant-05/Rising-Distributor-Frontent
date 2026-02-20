import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/coupon_service.dart';
import 'package:raising_india/models/model/coupon.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key, required this.isSelectionMode});
  final bool isSelectionMode;

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {

  @override
  void initState() {
    super.initState();
    // Fetch coupons on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Assuming 'fetchAllCoupons' gets all available coupons
      // You might need a specific user-facing method in service if 'fetchAllCoupons' is admin-only
      // For now, using what we have in the service.
      context.read<CouponService>().fetchAllCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Coupons', style: simple_text_style(fontSize: 20)),
          ],
        ),
      ),
      body: Consumer<CouponService>(
        builder: (context, couponService, child) {
          if (couponService.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColour.primary),
            );
          }

          // You might want to filter active coupons locally if the API returns everything
          final coupons = couponService.coupons;

          if (coupons.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return _buildCouponCard(coupon);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined, // Changed icon
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No coupons available',
            style: simple_text_style(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    // Determine status logic (assuming your model has isActive and expirationDate)
    bool isExpired = false;
    if (coupon.expirationDate != null) {
      isExpired = coupon.expirationDate!.isBefore(DateTime.now());
    }
    bool isActive = (coupon.isActive ?? true) && !isExpired;

    final Color statusColor = isActive ? Colors.green : Colors.red;
    final String statusText = isActive ? 'AVAILABLE' : 'EXPIRED';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppColour.primary.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative background circle
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColour.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header: Discount Tag & Status ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColour.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          // Show "50% OFF" or "₹100 OFF" based on type
                          coupon.discountType == 'PERCENTAGE'
                              ? '${coupon.discountValue?.toStringAsFixed(0)}% OFF'
                              : '₹${coupon.discountValue?.toStringAsFixed(0)} OFF',
                          style: simple_text_style(
                            color: AppColour.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          statusText,
                          style: simple_text_style(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // --- Coupon Code Section ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'COUPON CODE',
                          style: simple_text_style(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onLongPress: () => _copyCouponCode(coupon.code ?? ""),
                          child: Text(
                            coupon.code ?? "NO CODE",
                            style: simple_text_style(
                              color: AppColour.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Description & Terms ---
                  if (coupon.minOrderAmount != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Min Order: ₹${coupon.minOrderAmount}\nMax Discount: ₹${coupon.maxDiscountAmount}",
                        style: simple_text_style(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  // Terms Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Min Order
                      if (coupon.minOrderAmount != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Min Order',
                              style: simple_text_style(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '₹${coupon.minOrderAmount}',
                              style: simple_text_style(
                                color: AppColour.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                      // Max Discount (if Percentage)
                      if (coupon.discountType == 'PERCENTAGE' && coupon.maxDiscountAmount != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Max Discount',
                              style: simple_text_style(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '₹${coupon.maxDiscountAmount}',
                              style: simple_text_style(
                                color: AppColour.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Expiry Date
                  if (coupon.expirationDate != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Expires: ${DateFormat('MMM d, yyyy').format(coupon.expirationDate!)}',
                        style: simple_text_style(
                          color: isExpired ? Colors.red : Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // --- Action Button ---
                  if (isActive) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.isSelectionMode) {
                            // Return the Code to the previous screen (Cart)
                            Navigator.pop(context, coupon.code);
                          } else {
                            _copyCouponCode(coupon.code ?? "");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColour.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.isSelectionMode ? 'APPLY COUPON' : 'COPY CODE',
                          style: simple_text_style(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyCouponCode(String couponCode) async {
    if (couponCode.isEmpty) return;
    try {
      await Clipboard.setData(ClipboardData(text: couponCode));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Code "$couponCode" copied!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Ignore copy errors
    }
  }
}